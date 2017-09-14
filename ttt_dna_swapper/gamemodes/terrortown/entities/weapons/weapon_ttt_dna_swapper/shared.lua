

if SERVER then 
	resource.AddWorkshop("1133619836");
end

AddCSLuaFile();

if CLIENT then
   SWEP.PrintName = "DNA Changer"
   SWEP.Author = "St. Addi"
   
   SWEP.Icon = "vgui/ttt/dnaswapper"
   
   SWEP.ViewModelFOV  = 58
   SWEP.ViewModelFlip = false
   
   SWEP.EquipMenuData = {
   type = "Weapon",
   desc = "Primary: Collect DNA\nSecondary: Insert DNA into corpse"
   };
end

SWEP.Base = "weapon_tttbase"

SWEP.Slot      = 6

SWEP.UseHands	= true
SWEP.ViewModel	= "models/weapons/c_medkit.mdl"
SWEP.WorldModel	= "models/weapons/w_medkit.mdl"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54

SWEP.DrawCrosshair      = false
SWEP.Primary.Damage         = 5
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo       = "none"
SWEP.Secondary.ClipSize     = 2
SWEP.Secondary.DefaultClip  = 2
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.4

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once

SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2



function SWEP:setDNAFake(ent)

	self:SetNWEntity("dna_fake", ent)

end

function SWEP:getDNAFake()

	return self:GetNWEntity("dna_fake", nil)

end

function SWEP:PrimaryAttack()

	if(self:GetNextPrimaryFire() > CurTime() )  then return end

   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

   
   if not IsValid(self.Owner) then return end

   self.Owner:LagCompensation(true)

   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 70)

   local kmins = Vector(1,1,1) * -10
   local kmaxs = Vector(1,1,1) * 10

   local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

   -- Hull might hit environment stuff that line does not hit
   if not IsValid(tr.Entity) then
      tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   end

   local hitEnt = tr.Entity

   -- effects
   if IsValid(hitEnt) then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      local edata = EffectData()
      edata:SetStart(spos)
      edata:SetOrigin(tr.HitPos)
      edata:SetNormal(tr.Normal)
      edata:SetEntity(hitEnt)

      if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
         util.Effect("BloodImpact", edata)
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end

   if SERVER then
      self.Owner:SetAnimation( PLAYER_ATTACK1 )
   end


   if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
      if hitEnt:IsPlayer() then
         -- knife damage is never karma'd, so don't need to take that into
         -- account we do want to avoid rounding error strangeness caused by
         -- other damage scaling, causing a death when we don't expect one, so
         -- when the target's health is close to kill-point we just kill
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(self.Owner)
            dmg:SetInflictor(self.Weapon or self)
            dmg:SetDamageForce(self.Owner:GetAimVector() * 5)
            dmg:SetDamagePosition(self.Owner:GetPos())
            dmg:SetDamageType(DMG_SLASH)

            hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)
			
			self:setDNAFake(hitEnt)
			self.Owner:ChatPrint( "Retrieved ".. hitEnt:GetName() .."'s DNA successfully!")
      end
			self:setDNAFake(hitEnt)

   end

   self.Owner:LagCompensation(false)
end



function SWEP:SecondaryAttack()

	if(self:GetNextSecondaryFire() > CurTime() )  then return end

   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   
   
   
  
    local spos = self.Owner:GetShootPos()
	   local sdest = spos + (self.Owner:GetAimVector() * 70)

	   local kmins = Vector(1,1,1) * -10
	   local kmaxs = Vector(1,1,1) * 10

	   local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})
	 
	   if not IsValid(tr.Entity) then
		  tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	   end

	   local hitEnt = tr.Entity
   
	if(not IsValid(hitEnt)) then
	
		self.Owner:ChatPrint( "DNA can only be inserted into corpses!")
	
	end
	
	
	if not IsValid(self:getDNAFake()) then
		self.Owner:ChatPrint( "You need to retrieve DNA first!")
	end
	
   
   	   if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
	   if hitEnt:IsRagdoll() and IsValid(self:getDNAFake()) then
			self.Owner:ChatPrint( "Inserted " .. self:getDNAFake():GetName() .. "'s DNA")
				local dist = hitEnt:GetPos():Distance(self.Owner:GetPos())

				local sample = {}
				   sample.killer = self:getDNAFake()
				   sample.killer_uid = self:getDNAFake():UniqueID()
				   sample.victim = hitEnt.victim
				   sample.t      = CurTime() + (-1 * (0.019 * dist)^2 + GetConVarNumber("ttt_killer_dna_basetime"))
				
				hitEnt.killer_sample = sample
			 
	   end
	   end
   
   
   
   
   end


function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:PreDrop()
   -- for consistency, dropped knife should not have DNA/prints
   self.fingerprints = {}
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end


