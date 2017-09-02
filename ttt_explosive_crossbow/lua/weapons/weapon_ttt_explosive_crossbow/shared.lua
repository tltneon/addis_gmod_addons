
/*

feel free to mod / reup my code as long as this comment remains and you give me credit

-St. Addi :)

*/

if SERVER then

   	AddCSLuaFile( "shared.lua" )
	
	
	
end


SWEP.HoldType           = "crossbow"

BOLT_MODEL		= "models/crossbow_bolt.mdl"

BOLT_AIR_VELOCITY	= 7000
BOLT_WATER_VELOCITY	= 700
BOLT_SKIN_NORMAL	= 0
BOLT_SKIN_GLOW		= 1

CROSSBOW_GLOW_SPRITE	= "sprites/light_glow02_noz.vmt"
CROSSBOW_GLOW_SPRITE2	= "sprites/blueflare1.vmt"

if CLIENT then
   
   SWEP.PrintName          = "X-Plosive X-Bow"           
   SWEP.Author             = "St. Addi"
   SWEP.IconLetter         = "w"
   SWEP.Icon = "vgui/entities/weapon_portalgun.vtf"    
   
   SWEP.ViewModelFlip = false
end

SWEP.Slot               = 7
SWEP.SlotPos            = 1

if SERVER then
   resource.AddFile("vgui/entities/weapon_portalgun.vtf")
end

SWEP.Base               = "weapon_tttbase"
SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_ROLE

SWEP.AutoReload = true
SWEP.DrawCrosshair = false
SWEP.Primary.Tracer = 1
SWEP.Primary.Delay          = 1
SWEP.Primary.Recoil         = 5
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Force = 10000000
SWEP.Primary.Cone = 0.001
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipMax = 0
SWEP.AutoReload          = false
SWEP.AmmoEnt = ""
SWEP.Primary.AmmoType		= "crossbow_bolt"
SWEP.AutoSpawnable      = false
SWEP.ViewModel = "models/weapons/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 65

SWEP.Primary.Reload	= Sound( "Weapon_Crossbow.Reload" )
SWEP.Primary.Sound = Sound ("Weapon_Crossbow.Single")
SWEP.Primary.Special1		= Sound( "Weapon_Crossbow.BoltElectrify" )
SWEP.Primary.Special2		= Sound( "Weapon_Crossbow.BoltFly" )

--SWEP.IronSightsPos        = Vector( 5, 0, 1 )
SWEP.IronSightsPos = Vector(0, 0, -15)
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

SWEP.fingerprints = {}

SWEP.EquipMenuData = {
   type = "Weapon",
   model="models/weapons/w_crossbow.mdl",
   desc = "One shot, x kills. It's explosive!!. \n Boom and they're dead!\nMod by St. Addi."

};
SWEP.AllowDrop = true 
SWEP.AllowPickup = false
SWEP.IsSilent = true

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.ReloadAnim = ACT_VM_RELOAD_SILENCED

//maps entity index to bool armed
local hitEnts = {}
local countHitEnts = 0

if(CLIENT) then

local warnTex = surface.GetTextureID("vgui/ttt/icon_c4warn")

end

hook.Add("Initialize", "xxbowinit", function() 
	if(SERVER) then
		util.AddNetworkString( "TTT_XX_BOW_CHARGE" )
	end
end)

local function drawWarn(tgt, size, offset, no_shrink)


if(CLIENT) then

   local o3dpos = tgt:GetPos() 

   local scrpos = o3dpos:ToScreen() -- sweet
   local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size/2 or size

   scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
   scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

   surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

   -- Drawing full size?
   if sz == size then
      local text = math.ceil(LocalPlayer():GetPos():Distance(tgt:GetPos()))
      local w, h = surface.GetTextSize(text)

      -- Show range to target
      surface.SetTextPos(scrpos.x - w/2, scrpos.y + (offset * sz) - h/2)
      surface.DrawText(text)

      text = "Explosive Charge"
      w, h = surface.GetTextSize(text)

      surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
      surface.DrawText(text)
end

   end
end

function cleanup()

	hitEnts = {}
	countHitEnts = 0

end

hook.Add( "TTTPrepareRound", "XXBOW_REMOVE_TGTS", cleanup )

function HUDPaint()

if(CLIENT) then

	surface.SetFont("HudSelectionText")

	surface.SetTexture(surface.GetTextureID("vgui/ttt/icon_c4warn"))
      	surface.SetTextColor(252, 24, 6, 220)
      	surface.SetDrawColor(252, 24, 6, 200)

	for k, v in pairs(hitEnts) do

		local ent = ents.GetByIndex(k);

		
		if(IsValid(ent) and v) then
	
			drawWarn(ent, 18, 0, true);		
	
		end		
		
		
	end

end

end

hook.Add( "HUDPaint", "HUDPaint_DrawExplosiveXCharges", HUDPaint)

function addHitEnt(hitEnt)

	local armed = true;

	net.Start("TTT_XX_BOW_CHARGE")
        net.WriteUInt(hitEnt:EntIndex(), 16)
        net.WriteBit(armed)
	net.Send(GetTraitorFilter(true))

end

function addNWHitEnt()

	local idx = net.ReadUInt(16)
   	local armed = net.ReadBit() == 1

	hitEnts[idx] = armed;
	
	countHitEnts = table.getn(hitEnts);

end

net.Receive("TTT_XX_BOW_CHARGE", addNWHitEnt)


function SWEP:Precache()

	util.PrecacheSound( "Weapon_Crossbow.BoltHitBody" );
	util.PrecacheSound( "Weapon_Crossbow.BoltHitWorld" );
	util.PrecacheSound( "Weapon_Crossbow.BoltSkewer" );

	util.PrecacheModel( CROSSBOW_GLOW_SPRITE );
	util.PrecacheModel( CROSSBOW_GLOW_SPRITE2 ); 

	self.BaseClass:Precache();

end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
      
	if ( self.m_bInZoom && IsMultiplayer() ) then
//		self:FireSniperBolt();
		self:FireBolt();
	else
		self:FireBolt();
	end
	
	// Signal a reload
	self.m_bMustReload = true;
	
end

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return true
end

function SWEP:SetZoom(state)
    if CLIENT then 
       return
    else
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self.Weapon:GetNextSecondaryFire() > CurTime() then return end
    
    bIronsights = not self:GetIronsights()
    
    self:SetIronsights( bIronsights )
    
    if SERVER then
        self:SetZoom(bIronsights)
    end
    
    self.Weapon:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
    self:SetIronsights( false )
    self:SetZoom(false)
end  

function SWEP:Reload()
    
end


function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    return true
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local x = ScrW() / 2.0
         local y = ScrH() / 2.0
         local scope_size = ScrH()

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)

      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end

   function SWEP:FireBolt()

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 2 ) then
			self:Reload();
	        self:ShootBullet( 150, 1, 0.01 )
		else
			self.Weapon:SetNextPrimaryFire( 5 );
		
		end

		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end
	
	
if ( SERVER ) then
	local vecAiming		= pOwner:GetAimVector();
	local vecSrc		= pOwner:GetShootPos();

	local angAiming = vecAiming:Angle();

	local bullet = {}
	bullet.Damage = self.Primary.Damage
	bullet.Dir = vecAiming;
	bullet.Src = vecSrc;
	bullet.Spread = Vector(self.Primary.Cone, self.Primary.cone, 0)
	bullet.Callback = function(att, tr, dmginfo)
        	if tr.Entity and not tr.Entity:IsWorld() then
	
			local self_owner = self.Owner
		
			self:Remove()
	
            		local name = tr.Entity:GetName();

			addHitEnt(tr.Entity); 

			if(name == nil || string.len(name) == 0) then
				name = "something"
			end

			self_owner:ChatPrint("You hit " .. name .. " with an explosive charge.")
			self_owner:ChatPrint("Use the remote to detonate them.")
			remote = self_owner:Give("weapon_ttt_explosive_crossbow_remote");

	
			remote:SetNWEntity("owner", self.Owner);
			remote:SetNWEntity("exp_ent", tr.Entity);

			self_owner:SelectWeapon("weapon_ttt_explosive_crossbow_remote");

		else
			self.Owner:ChatPrint("You did not hit anything... noob...")

			local explosion = ents.Create( "env_explosion" )
	        	explosion:SetPos( tr.HitPos )
	        	explosion:SetOwner(self.Owner)
	        	explosion:SetKeyValue( "iMagnitude", 1 )
	        	explosion:SetKeyValue( "rendermode", "4")
			explosion:Spawn()
	        	explosion:Fire( "Explode", "", 0 )
	        	explosion:EmitSound( "siege/big_explosion.wav", 500, 75, 0.4)
	
			local effect = EffectData()
	      		effect:SetOrigin(exp_ent:GetPos())
	      		util.Effect("Explosion_2_FireSmoke", effect)	
			
        	end
	end
	self.Owner:FireBullets( bullet )
	
	
end
	
	
	self:SetIronsights(false)
    	self:SetZoom(false)
	
	

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	if ( !pOwner:IsNPC() ) then
		pOwner:ViewPunch( Angle( -2, 0, 0 ) );
	end

	self.Weapon:EmitSound( self.Primary.Sound );
	self.Owner:EmitSound( self.Primary.Special2 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	// self:DoLoadEffect();
	// self:SetChargerState( CHARGER_STATE_DISCHARGE );
	
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end

function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer:GiveAmmo( 1, "XXBowBolt" )
   end
end 
