local tostring_g = tostring

function PlayerInventory:load(data)
	if data.equipped_weapon_index then
		self._weapon_add_clbk = "playerinventory_load" .. tostring_g(self._unit:key())
		local delayed_data = {
			equipped_weapon_index = data.equipped_weapon_index,
			blueprint_string = data.blueprint_string,
			cosmetics_string = data.cosmetics_string,
			gadget_on = data.gadget_on,
			gadget_color = data.gadget_color
		}

		managers.enemy:add_delayed_clbk(self._weapon_add_clbk, callback(self, self, "_clbk_weapon_add", delayed_data), Application:time() + 1)
	end

	self._mask_visibility = data.mask_visibility and true or false

	local jammer_data = data._jammer_data

	if jammer_data then
		local t = TimerManager:game():time()

		if jammer_data.effect == "feedback" then
			self:_start_feedback_effect(jammer_data.t + t, jammer_data.interval, jammer_data.range) --start locally for player that loaded in
		elseif jammer_data.effect == "jamming" then
			self:_start_jammer_effect(jammer_data.t + t) --start locally for player that loaded in
		end
	end
end

local sync_net_event_original = PlayerInventory.sync_net_event
function PlayerInventory:sync_net_event(event_id, peer)
	local net_events = self._NET_EVENTS

	if event_id == net_events.jammer_start then
		self:_start_jammer_effect()
	elseif event_id == net_events.jammer_stop then
		self:_stop_jammer_effect()
	elseif event_id == net_events.feedback_start then
		self:_start_feedback_effect()
	elseif event_id == net_events.feedback_stop then
		self:_stop_feedback_effect()
	else
		sync_net_event_original(self, event_id, peer)
	end
end

function PlayerInventory:get_jammer_time() --checking for a player upgrade that can actually be missing (local player isn't using the perk deck or lacks the first card) is not how you do this, defaulting to 0 also isn't smart
	return tweak_data.upgrades.values.player.pocket_ecm_jammer_base and tweak_data.upgrades.values.player.pocket_ecm_jammer_base.duration or 6
end

function PlayerInventory:_send_net_event_to_host(event_id) --if only OVK made a send_to_host_synched function to avoid having to do this all the time
	managers.network:session():send_to_peer_synched(managers.network:session():peer(1), "sync_unit_event_id_16", self._unit, "inventory", event_id)
end

function PlayerInventory:_start_jammer_effect(end_time) --if end_time isn't nil here, it's under the assumption of having added current time to it (i.e. TimerManager:game():time() )
	end_time = end_time or self:get_jammer_time() + TimerManager:game():time()

	local key_str = tostring_g(self._unit:key())

	self._jammer_data = {
		effect = "jamming",
		t = end_time,
		sound = self._unit:sound_source():post_event("ecm_jammer_jam_signal"),
		stop_jamming_callback_key = "jammer" .. key_str
	}

	if Network:is_server() then --while the register_ecm_jammer function checks for this, you usually check for it locally anyway to avoid confusion
		managers.groupai:state():register_ecm_jammer(self._unit, {
			pager = true,
			call = true,
			camera = true
		})
	end

	managers.enemy:add_delayed_clbk(self._jammer_data.stop_jamming_callback_key, callback(self, self, "_stop_jammer_effect"), self._jammer_data.t) --call _stop_jammer_effect to only stop the effect locally

	local is_local_player = managers.player:player_unit() == self._unit
	local dodge = is_local_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. key_str

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end
end

function PlayerInventory:stop_jammer_effect()
	self:_stop_jammer_effect()

	--make sure the unit using the pocket ecm exists and that they're the local player before sending an event to stop the effect prematurely. Shouldn't be necessary but I'm just making sure
	if alive(self._unit) and managers.player:player_unit() == self._unit then
		self:_send_net_event(self._NET_EVENTS.jammer_stop)
	end
end

function PlayerInventory:_stop_jammer_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "jamming" then
		return
	end

	self._jammer_data.effect = nil

	if self._jammer_data.sound then
		self._jammer_data.sound:stop()
		self._unit:sound_source():post_event("ecm_jammer_jam_signal_stop") --make sure the sound event even happened, like with normal ECMs
	end

	if Network:is_server() then
		managers.groupai:state():register_ecm_jammer(self._unit, false)
	end

	managers.enemy:remove_delayed_clbk(self._jammer_data.stop_jamming_callback_key, true) --callbacks get removed on execution, this is in here for cases where the effect needs to end prematurely

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end
end

function PlayerInventory:start_feedback_effect(...)
	self:_start_feedback_effect(...)
	self:_send_net_event(self._NET_EVENTS.feedback_start) --just like with the jamming effect, the local player starts the effect locally and syncs it. There's no reason to do it the way it was done
end

function PlayerInventory:_start_feedback_effect(end_time, interval, range)
	local t = TimerManager:game():time()
	local key_str = tostring_g(self._unit:key())

	end_time = end_time or self:get_jammer_time() + t
	self._jammer_data = {
		effect = "feedback",
		t = end_time,
		interval = interval or 1, --"granting a chance to stun enemies on the map every second for a 6 second duration." ; EVERY 1 SECOND, not 1.5
		range = range or 2500,
		sound = self._unit:sound_source():post_event("ecm_jammer_puke_signal"),
		feedback_callback_key = "feedback" .. key_str
	}

	local is_local_player = managers.player:player_unit() == self._unit
	local dodge = is_local_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")
	local heal = is_local_player and self._unit:base():upgrade_value("player", "pocket_ecm_heal_on_kill") or self._unit:base():upgrade_value("team", "pocket_ecm_heal_on_kill") --local player with self-healing upgrade, or teammate benefitting from team-healing

	if heal then
		self._jammer_data.heal = heal
		self._jammer_data.heal_listener_key = "feedback_heal" .. key_str

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, callback(self, self, "_feedback_heal_on_kill"))
	end

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. key_str

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end

	if Network:is_server() then --host still handles the stun aspect for other important reasons
		--optional, start immediately as this gets executed locally for the host player or synced
		--use m_head_pos for a more accurate position (won't be super accurate for client husks unless you have my huskplayermovement improvements)
		--ECMJammerBase._detect_and_give_dmg(self._unit:movement():m_head_pos(), nil, self._unit, 2500)

		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_do_feedback"), t + self._jammer_data.interval)
	else
		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_stop_feedback_effect"), self._jammer_data.t) --call _stop_feedback_effect to only stop the effect locally
	end
end

function PlayerInventory:stop_feedback_effect()
	self:_stop_feedback_effect()

	--make sure the unit using the pocket ecm exists and that they're the local player before sending an event to stop the effect prematurely. Shouldn't be necessary but I'm just making sure
	if alive(self._unit) and managers.player:player_unit() == self._unit then
		self:_send_net_event(self._NET_EVENTS.feedback_stop)
	end
end

function PlayerInventory:_stop_feedback_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "feedback" then
		return
	end

	self._jammer_data.effect = nil

	if self._jammer_data.sound then
		self._jammer_data.sound:stop()
		self._unit:sound_source():post_event("ecm_jammer_puke_signal_stop") --make sure the sound event even happened, like with normal ECMs
	end

	if self._jammer_data.heal_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, true)
	end

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end

	managers.enemy:remove_delayed_clbk(self._jammer_data.feedback_callback_key, true)
end

--this is how you do proper healing checks + make sure players with active berserker effects block healing from teammates
function PlayerInventory:_feedback_heal_on_kill()
	if not self._jammer_data or not alive(self._unit) then
		return
	end

	local local_player = managers.player:player_unit()

	if not local_player then
		return
	end

	local damage_ext = local_player:character_damage()

	if not damage_ext or damage_ext:dead() or damage_ext:need_revive() or damage_ext:is_berserker() then
		return
	end

	local chk_health_ratio = self._unit ~= local_player and true

	damage_ext:restore_health(self._jammer_data.heal, true, chk_health_ratio)
end

function PlayerInventory:_jamming_kill_dodge()
	local data = self._jammer_data

	if not data or not alive(self._unit) then
		return
	end

	local local_player = managers.player:player_unit()

	if not local_player then
		return
	end

	if data.dodge_kills then
		data.dodge_kills = data.dodge_kills - 1

		if data.dodge_kills == 0 then
			managers.player:activate_temporary_upgrade("temporary", "pocket_ecm_kill_dodge")
			managers.player:unregister_message(Message.OnEnemyKilled, data.dodge_listener_key, true)
		end
	end
end

function PlayerInventory:_do_feedback()
	local data = self._jammer_data

	if not data or not alive(self._unit) then
		self:_stop_feedback_effect()

		return
	end

	--use m_head_pos for a more accurate position (won't be super accurate for client husks unless you have my huskplayermovement improvements)
	ECMJammerBase._detect_and_give_dmg(self._unit:movement():m_head_pos(), nil, self._unit, 2500)

	local t = TimerManager:game():time()

	if t >= data.t then --already expired (could rarely happen due to delayed callback frame-by-frame updating or if an interval matches the end time and was scheduled because of it)
		self:_stop_feedback_effect()
	else
		local next_feedback_t = t + data.interval

		if next_feedback_t > data.t then --schedule the effect stop if the next interval would happen after the timer ends, else schedule another interval
			managers.enemy:add_delayed_clbk(data.feedback_callback_key, callback(self, self, "_stop_feedback_effect"), data.t) --call _stop_feedback_effect to only stop the effect locally
		else
			managers.enemy:add_delayed_clbk(data.feedback_callback_key, callback(self, self, "_do_feedback"), next_feedback_t)
		end
	end
end
