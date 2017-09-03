
if ( CLIENT ) then

	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false


	SWEP.PrintName			= "Death Link"
	SWEP.Author				= "St. Addi"
	SWEP.Icon = "VGUI/ttt/ttt_death_link.png"
	SWEP.EquipMenuData = {
   type = "Weapon",
   desc = "Use on any Player. Once they die, you die and vice versa."
};
end

SWEP.Slot				= 6
SWEP.SlotPos			= 11

SWEP.Author			= "St. Addi"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Fire on any other Player"

SWEP.Base = "weapon_tttbase"
SWEP.AutoSpawnable = false
SWEP.AdminSpawnable = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Kind = WEAPON_EQUIP1
SWEP.HoldType			= "slam"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true


SWEP.ViewModel  = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")


SWEP.Primary.Automatic		= false
SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.LimitedStock = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 2

SWEP.Primary.Delay = 0.3

SWEP.Primary.Automatic = false

SWEP.AllowDrop = false

function SWEP:PrimaryAttack()

	if(!self.Owner or !SERVER) then return end
	
	local tr = self.Owner:GetEyeTrace();
	
	local ply = tr.Entity;
	
	if(IsValid(ply) and ply:IsPlayer()) then
	
		self.BaseClass.ShootEffects( self );
		
		self.Owner:ChatPrint("You linked yourself with " .. ply:Nick());
		
		self.Owner:SetNWEntity("deathlinked_player", ply);
		ply:SetNWEntity("deathlinked_player", self.Owner);
		ply:SetNWBool("deathlink_used", false);
		self.Owner:SetNWBool("deathlink_used", false);
		self:Remove();
	
	end

end

function SWEP:ShouldDropOnDie() 
	
	return false

end

function playerDeath(victim, inflictor, attacker ) 

	if(!SERVER) then return end

	if(victim == attacker or victim:GetNWBool("deathlink_used", false)) then return end

	local ent = victim:GetNWEntity("deathlinked_player", nil);
	
	if(IsValid(ent)) then
	
	
		ent:SetNWEntity("deathlinked_player", nil);
		victim:SetNWEntity("deathlinked_player", nil);
	
		ent:SetNWBool("deathlink_used", true);
		victim:SetNWBool("deathlink_used", true);
		
		local explosion = ents.Create( "env_explosion" )
	    explosion:SetPos( ent:GetPos() )
	    explosion:SetOwner(victim)
	    explosion:SetKeyValue( "iMagnitude", 180 )
	    explosion:SetKeyValue( "rendermode", "4")
		explosion:Spawn()
	    explosion:Fire( "Explode", "", 0 )
	    explosion:EmitSound( "siege/big_explosion.wav", 500, 500 )
	
		local effect = EffectData()
	    effect:SetOrigin(ent:GetPos())
	    util.Effect("Explosion_2_FireSmoke", effect)

		
	end
end

hook.Add("PlayerDeath", "ttt_death_link_hook", playerDeath);

hook.Add("TTTPrepareRound", "ttt_death_link_cleanup", function() 

	for k,ent in pairs(player.GetAll()) do
	
		ent:SetNWEntity("deathlinked_player", nil);
		ent:SetNWBool("deathlink_used", true);
	
	end

end)






























