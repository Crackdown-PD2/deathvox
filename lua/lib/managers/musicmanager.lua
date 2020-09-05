Hooks:PostHook(MusicManager, "jukebox_ghost_specific", "Crackdown_MusicManagerJukeBoxGhostSpecific", function(self)

	if managers.job:current_level_id() == "kosugi_CD" then
        return self:track_attachment("heist_kosugi")
    end
end)

Hooks:PostHook(MusicManager, "jukebox_heist_specific", "Crackdown_MusicManagerJukeBoxHeistSpecific", function(self)
	
    if not Global.music_manager.track_attachment.jolly_cd then
        Global.music_manager.track_attachment.jolly_cd = "track_30"
    end
	
    if not Global.music_manager.track_attachment.wwh_CD then
        Global.music_manager.track_attachment.wwh_CD = "track_54"
    end
	
    if not Global.music_manager.track_attachment.branchbank_cash_CD then
        Global.music_manager.track_attachment.branchbank_cash_CD = "track_07"
    end

    if not Global.music_manager.track_attachment.spa_CD then
        Global.music_manager.track_attachment.spa_CD = "track_51"
    end

    if not Global.music_manager.track_attachment.family_CD then
        Global.music_manager.track_attachment.family_CD = "track_04"
    end
	
    if not Global.music_manager.track_attachment.cd_arm_cro then
        Global.music_manager.track_attachment.cd_arm_cro = "track_09"
    end

    if not Global.music_manager.track_attachment.arm_und_CD then
        Global.music_manager.track_attachment.arm_und_CD = "track_09"
    end
    
    -- local job_data = Global.job_manager.current_job
	
    if managers.job:current_level_id() == "jolly_cd" then
        return self:track_attachment("jolly_cd") or "all"
    end

    if managers.job:current_level_id() == "wwh_CD" then
        return self:track_attachment("wwh_CD") or "all"
    end	
	
    if managers.job:current_level_id() == "branchbank_cash_CD" then
        return self:track_attachment("branchbank_cash_CD") or "all"
    end

    if managers.job:current_level_id() == "spa_CD" then
        return self:track_attachment("spa_CD") or "all"
    end

    if managers.job:current_level_id() == "family_CD" then
        return self:track_attachment("family_CD") or "all"
    end

    if managers.job:current_level_id() == "cd_arm_cro" then
        return self:track_attachment("cd_arm_cro") or "all"
    end

    if managers.job:current_level_id() == "arm_und_CD" then
        return self:track_attachment("arm_und_CD") or "all"
    end
end)