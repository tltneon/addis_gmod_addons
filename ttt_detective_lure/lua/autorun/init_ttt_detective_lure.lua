
/*

Dear Modder, 

If you wish to edit and redistribute the code, feel free to do so as long as you give me credit and keep this comment. Thank you!

 - St. Addi


*/
hook.Add("OnEntityCreated", "ttt_buy_decoy_lure", function(ent) 
	
	if(ent:GetClass()  == "weapon_ttt_decoy" ) then
	
		timer.Simple(1, function() 
		
		function ent:PrimaryAttack()
		
		if(SERVER) then
			self:SetNextPrimaryFire(CurTime()+3);
		
			local ply = self.Owner
		
			local detectives = {}
		
			for k,v in pairs(player.GetAll()) do
		
				if(IsValid(v) and v:GetRole() == ROLE_DETECTIVE and v:IsActive()) then
			
					table.insert(detectives, v);
			
				end
		
			end
	
			local pos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Calf"));
	
			if(#detectives != 0) then
		
				net.Start("TTT_CorpseCall")
				net.WriteVector(pos)
				net.Send(detectives)
			
			end
		
			local nickname = "someone"
		
			local confirmedPlyNick = {}
		
			for k,ply in pairs(player.GetAll()) do
			
				if( ply:GetNWBool("body_found", false) ) then
				
					table.insert(confirmedPlyNick, ply:Nick())
				
				end
				
			end
			
			if(#confirmedPlyNick != 0) then
			
				nickname = confirmedPlyNick[math.random(1,#confirmedPlyNick)]
			
			end
		
			LANG.Msg("body_call", {player = ply:Nick(),
			victim = nickname})
		
			return true
		
		end
		
		end
		
		end)
	
	end

end)