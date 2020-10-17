if deathvox:IsTotalCrackdownEnabled() then

	function PlayerEquipment:use_armor_plates()
		local ray = self:valid_shape_placement("armor_kit",{dummy_unit = tweak_data.equipments.armor_kit.dummy_unit})
		local pos = ray.position
		local rot = Rotation(self:_m_deploy_rot():yaw(),0,0)
		
		local bits = 4 --not actually used
		
		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "ArmorPlatesBase", pos, rot, bits)
			return true
		else
			local unit = ArmorPlatesBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
			return true
		end
	end
end