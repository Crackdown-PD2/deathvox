-- Ultimately this file will be included in multiple places, so we should keep a reference to it in the _G.deathvox table
-- For not it's not initialised until after weapontweakdata is loaded, so don't use that for now
local Balance = nil -- _G.deathvox._sys_balance

-- Working with above, if the class is already defined then don't reload everything
if Balance then
	return Balance
end

-- Keep a reference to ModPath since it changes
local ModPath = ModPath

-- Create the class table, and once _G.deathvox is sorted place a reference in that
Balance = {}
-- _G.deathvox._sys_Balance = balance

-- Initialise function for the weapon balance manager
-- This loads the specification file from `data/weapons.xml`, parses it, validates it, and stores
-- the resulting data into self._weapons for later use
function Balance:init()
	-- Open the weapon file, check it exists, read it to a string, and close it
	local file = assert(io.open(ModPath .. "data/weapons.xml"), "cannot find weapons XML spec")
	local file_contents = file:read("*all")
	file:close()

	-- Parse it with SuperBLT's XML parser
	local xml = assert(blt.parsexml(file_contents), "cannot parse weapons XMl spec")

	-- Validate the root tag
	assert(xml.name == "weapons", "root weapon XML tag must be named 'weapons'")

	-- This is where we will store the weapon data. The key is the weapon ID (as used in weapontweakdata), the
	-- key is the info about it - currently just the parameters from XML.
	self._weapons = {}

	-- Here's how the XML is supposed to look
	-- <weapons>
	--     <category id="light_ar">
	--         <weapon name="amcar" ... />
	--     </category>
	--     <category id="handguns">
	--         <weapon name="p226" ... /> <!-- signature .40 -->
	--         <weapon name="colt_1911" ... /> <!-- crosskill pistol -->
	--     </category>
	-- </weapons>
	--
	-- Currently it doesn't matter what category a weapon is in, and it's not even recorded, but later on we
	-- should be able to do stuff (eg, tweak attachments) across all weapons in a category.

	-- Loop through each category tag
	for _, category in ipairs(xml) do
		assert(category.name == "category", "weapon category XML tag must be named 'category'")

		-- Loop through each weapon in that category
		for _, weapon in ipairs(category) do
			assert(weapon.name == "weapon", "weapon descriptor XML tag must be named 'weapon'")

			-- Add the weapon into the weapons table
			local info = weapon.params
			self._weapons[info.name] = info
		end

	end
end

-- Apply weapon balance to the weapontweakdata
-- This should be called from weapontweakdata's constructor, passing in 'self' as the argument
-- The function will then step through it's internal list of weapons, and apply the changes to the tweakdata
function Balance:apply_weapons(td)
	-- Before we can start, we have to build up a table to find out what index should be
	-- used for the various threat values.
	--
	-- Values in the weapontweakdata.stats.suppression are 1/10th the value of the threat value plus two.
	-- So for example the amcar has threat of 14. It's suppression value is thus 1.6 (14+2=16, 16/10=1.6)
	--
	-- Since these aren't linear unlike the tables for damage, stability, accuracy, etc we can't just do
	-- a little bit of maths to find the table index for a given desired value. Instead, we have to build
	-- a table to convert from values to indexes.
	local threat_table = {}
	for i, n in ipairs(td.stats.suppression) do
		local threat = 10 * n - 2
		threat_table[threat] = i
	end

	-- Loop thorugh every tweaked weapon
	for id, weapon in pairs(self._weapons) do

		-- Grab the weapon descriptor - ie, the table that contains all the info about the weapon, and
		-- assert that it does indeed exist.
		local wd = td[id]
		assert(wd, "unknown weapon '" .. id .. "'")

		-- A function that gets a number parameter passed into the XML tag. This verifies the property exists and
		-- is a number, and returns it as a number rather than as a string.
		local function chknum(name)
			return assert(tonumber(weapon[name]), "parameter '" .. name .. "' does not exist or is not a number")
		end

		-- Get the table index value for a parameter that represents a table value, such as stability or accuracy. This
		-- converts it to the index, and errors if the user specifies a misaligned value (one that the table cannot accept).
		local function chktbl(name, step, max)
			local val = chknum(name)

			if val % step ~= 0 then
				-- Round the specified value to the nearest valid value. Adding 0.5 pushes anything that should be rounded
				-- up into the next value.
				local suggestion = math.floor(val / step + 0.5) * step
				error("parameter '" .. name .. "' is not aligned to table of step size " .. tostring(size) ..
					" - closest available value is " .. tostring(suggestion))
			end

			-- Ensure it is not negative
			assert(val >= 0, "parameter '" .. name .. "' cannot be negative")

			-- The table starts at 1, even for a value of zero.
			return val / step + 1
		end

		-- Set the magazine size and total ammunition pool
		wd.CLIP_AMMO_MAX = chknum("mag")
		wd.AMMO_MAX = chknum("ammo_pool")

		-- this fire_rate property is used for almost everything, except for the AI and some VR stuff
		wd.fire_mode_data.fire_rate = 60 / chknum("rof")

		-- used for AI and some VR stuff
		wd.auto.fire_rate = wd.fire_mode_data.fire_rate

		-- Damage and concealment stats go unmodified
		wd.stats.damage = chknum("dmg")
		wd.stats.concealment = chknum("concealment")

		-- As do the timers
		wd.timers.reload_not_empty = chknum("tact_reload")
		wd.timers.reload_empty = chknum("full_reload")
		wd.timers.equip = chknum("equip_time")

		-- Look up the threat ID for the required value, and error if it's not available
		wd.stats.suppression = assert(threat_table[chknum("threat")], "threat value not in threat table")

		-- As per the Long Guide:
		-- spread = 2*(1-accuracy/100)
		-- And since spread is in 0.08° increments over a 2° range (see lib/tweak_data/weapontweakdata), there are 25 possible values
		wd.stats.spread = chktbl("acc", 4)
		assert(wd.stats.spread <= #td.stats.spread)

		-- As per the Long Guide:
		-- spread = 0.5 + 2.5*(1-stability/100)
		-- Recoil ranges from 3 to 0.5 inclusive, in 0.1 steps (see lib/tweak_data/weapontweakdata)
		-- This works out as idx=stab/4 + 1
		wd.stats.recoil = chknum("stb") / 4 + 1
		assert(wd.stats.recoil <= #td.stats.recoil)

		-- Set the ammo pickup rates
		-- These are the min and max values, expressed as a percentage of the weapon's total ammo pool, hence
		-- the divide-by-100
		wd.AMMO_PICKUP = {
			chknum("pickup_low") / 100 * wd.AMMO_MAX,
			chknum("pickup_high") / 100 * wd.AMMO_MAX
		}
	end
end

--
Balance:init()
return Balance
