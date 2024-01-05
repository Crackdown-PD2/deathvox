function LevelsTweakData:get_ai_group_type() -- We can use this to easily swap visuals for "factions" based on difficulty.
	local group_to_use = "zeal"
	-- Instead of if statements, we can just instead change what faction it's looking for.
	-- This makes swapping difficulties on the fly much, much easier, along with maintaining a clean codebase.
	local level_id
	if Global.level_data and Global.level_data.level_id then
		level_id = Global.level_data.level_id
	end
	
	if not Global.game_settings then
		return group_to_use
	end
	
	-- draft implementation of asset swapping between waves for Holdout mode. Courtesy of iamgoofball.
	if managers and managers.skirmish and managers.skirmish:is_skirmish() then
		local current_wave = managers.skirmish:current_wave_number()
		local wave_table = {
			"cop", -- wave 1
			"cop",
			"fbi",
			"fbi",
			"fbi",
			"gensec",
			"gensec",
			"classic",
			"zeal" --wave 9
		}
		if current_wave == 0 or not current_wave then
			return "cop"
		elseif current_wave > 0 and current_wave <= #wave_table then
			return wave_table[current_wave]
		else
			return "zeal"
		end
	end
	
	local difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local map_faction_override = {}
	local packagemgr = BeardLib.managers.package
	if packagemgr:HasPackage("packages/deathvoxclassics") then
		--map_faction_override["Enemy_Spawner"] = "classic"
		map_faction_override["pal"] = "classic"
		self.pal.package = {"packages/narr_pal", "packages/narr_rvd", "packages/deathvoxclassics"}
		
		map_faction_override["dah"] = "classic"
		self.dah.package = {"packages/lvl_dah", "packages/deathvoxclassics"}
		map_faction_override["red2"] = "classic"
		self.red2.package = {"packages/narr_red2", "packages/deathvoxclassics"}
		map_faction_override["glace"] = "classic"
		self.glace.package = {"packages/narr_glace", "packages/deathvoxclassics"}
		map_faction_override["run"] = "classic"
		self.run.package = {"packages/narr_run", "packages/deathvoxclassics"}
		map_faction_override["flat"] = "classic"
		self.flat.package = {"packages/narr_flat", "packages/deathvoxclassics"}
		map_faction_override["dinner"] = "classic"
		self.dinner.package = {"packages/narr_dinner", "packages/deathvoxclassics"}
		map_faction_override["man"] = "classic"
		self.man.package = {"packages/narr_man", "packages/deathvoxclassics"}
		map_faction_override["nmh"] = "classic"
		self.nmh.package = {"packages/dlcs/nmh/job_nmh", "packages/deathvoxclassics"}
		
		-- whurr's map edits
		map_faction_override["bridge"] = "classic"
		map_faction_override["apartment"] = "classic"
		map_faction_override["street"] = "classic"
		
		-- HOLDOUT STUFF
		self.skm_run.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_watchdogs_stage2.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_cas.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_big2.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_mallcrasher.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_arena.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_bex.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_mus.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		self.skm_red2.package = {"packages/dlcs/skm/job_skm", "packages/deathvoxclassics"}
		map_faction_override["bank"] = "classic"
		
		--gangster voice stuff from fuglore that was originally from rino that was originally from resmod
		self.spa.package = {"packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds", "packages/deathvoxclassics"}
	end
	
	--gangster voice stuff from fuglore that was originally from rino that was originally from resmod
	self.short2_stage1.package = {"packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.nightclub.package = {"packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.friend.package = {"levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend"}
	self.cane.package = {"packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds"}	
	
	
	if packagemgr:HasPackage("packages/deathvoxmurkies") then
		--Murky faction overrides begin here. Uncomment to apply the Murkywater faction on the Whitehouse, Henry's Rock, Hell's Island, and Beneath the Mountain heists.
		self.pbr.package = {"packages/deathvoxmurkies", "packages/narr_jerry1"}
		map_faction_override["pbr"] = "murkywater"
		
		self.vit.package = {"packages/deathvoxmurkies", "packages/dlcs/vit/job_vit"}
		map_faction_override["vit"] = "murkywater"
		
		self.des.package = {"packages/deathvoxmurkies", "packages/job_des"}
		map_faction_override["des"] = "murkywater"
		
		self.bph.package = {"packages/deathvoxmurkies", "packages/dlcs/bph/job_bph"}
		map_faction_override["bph"] = "murkywater"
	end
	
	--Reaper faction overrides begin here.
	--map_faction_override["mad"] = "russia"
	
	if packagemgr:HasPackage("packages/deathvoxfederales") then
		--Federales faction overrides begin here.
		self.bex.package = {"packages/deathvoxfederales", "packages/job_bex"}
		map_faction_override["bex"] = "federales"
		--map_faction_override["skm_bex"] = "federales"
		
		self.pex.package = {"packages/deathvoxfederales", "packages/job_pex"}
		map_faction_override["pex"] = "federales"
		
		self.fex.package = {"packages/deathvoxfederales", "packages/job_fex"}
		map_faction_override["fex"] = "federales"
	end
	
	--Halloween overrides begin here.
	
	local diff_index = table.index_of(difficulties, Global.game_settings.difficulty)
	if diff_index <= 3 then
		group_to_use = "cop"
	elseif diff_index <= 5 then
		group_to_use = "fbi"
	elseif diff_index <= 7 then
		group_to_use = "gensec"
	end
	if level_id then
		if map_faction_override[level_id] then
			group_to_use = map_faction_override[level_id]
		end
	end
	if diff_index == 8 then -- zeal units on CD for all maps.
		group_to_use = "zeal"
	end
	return group_to_use
end


local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
	old_level_init(self)

	--fix for safehouse raid failing to spawn assault group enemies. Base heist uses "safehouse" data that clones beseige.
	self.chill_combat.group_ai_state = "besiege"

	--setting wave count for revised holdouts.
	self.skm_mus.wave_count = 9
	self.skm_red2.wave_count = 9
	self.skm_run.wave_count = 9
	self.skm_watchdogs_stage2.wave_count = 9

	--this crashes the game so i commented it out
	--self.skmc_fish.wave_count = 6
	--self.skmc_mad.wave_count = 6
	--self.skmc_ovengrill.wave_count = 6
	
	self.mia2_new.teams = self.mia_2.teams
end
