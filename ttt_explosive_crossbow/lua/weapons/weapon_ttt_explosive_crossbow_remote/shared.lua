/*

feel free to mod / reup my code as long as this comment remains and you give me credit

-St. Addi :)

*/

AddCSLuaFile()

local TIME_DELAY = 3
local EXPLOSION_MAGNITUDE = "170"

SWEP.HoldType			= "slam"

if CLIENT then
   
   SWEP.PrintName          = "Explosion Remote Activator"           
   SWEP.Author             = "St. Addi"
   
   SWEP.ViewModelFlip = false
end

SWEP.Slot               = 7
SWEP.SlotPos            = 1

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {} 

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
/*SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
*/
SWEP.Primary.Delay = 4.0


SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

SWEP.NoSights = true
   
local beep = Sound("weapons/c4/c4_beep1.wav")

function SWEP:Precache()

	self.BaseClass:Precache();
	

end

function SWEP:Deploy()

if(SERVER) then

	self.Owner:StripWeapon("weapon_ttt_explosive_crossbow");
end
	
end

function SWEP:SendWarn(armed)


	
	net.Start("TTT_XX_BOW_CHARGE")
        net.WriteUInt(self:GetNWEntity("exp_ent"):EntIndex(), 16)
        net.WriteBit(armed)
    net.Send(GetTraitorFilter(true))


end

function SWEP:PrimaryAttack()

	self.BaseClass.ShootEffects( self )
	self.Weapon:SetNextPrimaryFire(CurTime() + TIME_DELAY + 1) ;
	function explode()

		if(SERVER) then
			local owner = self.Owner;
			
			local exp_ent = self:GetNWEntity("exp_ent");

			if(IsValid(exp_ent)) then

			if(exp_ent:IsPlayer() and !exp_ent:Alive()) then
		
				if(IsValid(exp_ent:GetRagdollEntity())) then
					exp_ent = exp_ent:GetRagdollEntity();
				else
					self:SendWarn(false);
					self:Remove();
					return;
				end
	
			end

			local explosion = ents.Create( "env_explosion" )
	        	explosion:SetPos( exp_ent:GetPos() )
	        	explosion:SetOwner(self.Owner)
	        	explosion:SetKeyValue( "iMagnitude", EXPLOSION_MAGNITUDE )
	        	explosion:SetKeyValue( "rendermode", "4")
			explosion:Spawn()
	        	explosion:Fire( "Explode", "", 0 )
	        	explosion:EmitSound( "siege/big_explosion.wav", 500, 500 )
	
			local effect = EffectData()
	      		effect:SetOrigin(exp_ent:GetPos())
	      		util.Effect("Explosion_2_FireSmoke", effect)

			end
			self:SendWarn(false);
			self:Remove();
		end
	end	
	//explode();
	timer.Create( self.Owner:GetName() .. "_explosive_crossbow_charge", TIME_DELAY, 1,  explode);
	//timer.Create( self.Owner:GetName() .. "_explosive_crossbow_start_beep", TIME_DELAY - 0.55, 1,  self:startBeeping);
end

function SWEP:PreDrop()
	
	timer.Destroy(self.Owner:GetName() .. "_explosive_crossbow_charge")

end


function SWEP:CanPrimaryAttack()
	return true
end
