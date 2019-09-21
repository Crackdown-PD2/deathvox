function DialogManager:queue_dialog(id, params)
	local anti_skm_dialog_table = {
		"Play_loc_skm_01",
		"Play_loc_skm_05",
		"Play_loc_skm_07",
		"Play_loc_skm_08",
		"Play_loc_skm_09",
		"Play_loc_skm_10"
	}
	local deny_skm = nil
	for _, skm_dialog in ipairs(anti_skm_dialog_table) do
		if id == skm_dialog then
			deny_skm = true
		end
	end
	
	if not deny_skm then
		if not params.skip_idle_check and managers.platform:presence() == "Idle" then
			return
		end

		if params.delay then
			self:_add_delayed_dialog({
				id,
				params
			})

			return
		end

		if not self._dialog_list[id] then
			local error_message = "The dialog script tries to queue a dialog with id '" .. tostring(id) .. "' which doesn't seem to exist!"

			if Application:editor() then
				managers.editor:output_error(error_message, false, true)
			else
				debug_pause(error_message)
			end

			return false
		end

		if not self._current_dialog then
			self._current_dialog = {
				id = id,
				params = params
			}

			self:_play_dialog(self._dialog_list[id], params)
		else
			local dialog = self._dialog_list[id]

			if self._next_dialog and self._dialog_list[self._next_dialog.id].priority < dialog.priority then
				self:_call_done_callback(params and params.done_cbk, "skipped")

				return false
			end

			if dialog.priority < self._dialog_list[self._current_dialog.id].priority then
				if self._next_dialog then
					self:_call_done_callback(self._dialog_list[self._next_dialog.id].params and self._dialog_list[self._next_dialog.id].params.done_cbk, "skipped")
				end

				self._next_dialog = {
					id = id,
					params = params
				}
			else
				self:_call_done_callback(params and params.done_cbk, "skipped")
			end
		end

		return true
	end
end


function DialogManager:queue_narrator_dialog(id, params)
	local anti_skm_dialog_table = {
		"Play_loc_skm_01",
		"Play_loc_skm_05",
		"Play_loc_skm_07",
		"Play_loc_skm_08",
		"Play_loc_skm_09",
		"Play_loc_skm_10"
	}
	local deny_skm = nil
	for _, skm_dialog in ipairs(anti_skm_dialog_table) do
		if id == skm_dialog then
			deny_skm = true
		end
	end
	
	if not deny_skm then
		self:queue_dialog(self._narrator_prefix .. id, params)
	end
end
