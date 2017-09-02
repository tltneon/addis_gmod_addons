local detectiveEnabled = CreateConVar("ttt_doorbuster_detective", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should Detectives be able to buy the Door Mine?")
local traitorEnabled = CreateConVar("ttt_doorbuster_traitor", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should Traitors be able to buy the Door Mine?")

if (SERVER) then
	resource.AddWorkshop("621565420")
	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "gamemodes/terrortown/entities/entities/entity_doorbuster/cl_init.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false


	SWEP.PrintName			= "Door Mine"
	SWEP.Author				= "St. Addi"
	SWEP.Slot				= 6
	SWEP.SlotPos			= 11
   SWEP.Icon = "VGUI/ttt/icon_doorbust"
   SWEP.EquipMenuData = {
   type = "Weapon",
   desc = "Placeable on doors. \nThe Door will explode when opened \nand kill everyone in its way."
};
end
local ValidDoors = {"prop_door_rotating", "func_door_rotating", "prop_door", "func_door"}

SWEP.Author			= "-Kenny-"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Place on Door"

//GeneralSettings\\
SWEP.Base				= "weapon_tttbase"
SWEP.AutoSpawnable = !detectiveEnabled:GetBool() and !traitorEnabled:GetBool()
SWEP.AdminSpawnable = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Kind = !detectiveEnabled:GetBool() and !traitorEnabled:GetBool() and WEAPON_NADE or WEAPON_EQUIP1
SWEP.HoldType			= "slam"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_c4.mdl"
SWEP.WorldModel			= "models/weapons/w_c4.mdl"


SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= -1
SWEP.Primary.NumShots			= 1
SWEP.Primary.Cone			  	= 0
SWEP.Primary.Delay				= 1
SWEP.Primary.ClipSize			= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo					= "slam"
SWEP.CanBuy = {}
if (detectiveEnabled:GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
end
if (traitorEnabled:GetBool()) then
	table.insert(SWEP.CanBuy, ROLE_TRAITOR)
end
SWEP.LimitedStock = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 2


local doorbusters = {}

hook.Add("Initialize", "doorbusterinit_kg", function() 
	if(SERVER) then
		util.AddNetworkString( "TTT_DOORMINE_RECEIVE" )
		util.AddNetworkString( "TTT_DOORMINE_DEL_RECEIVE" )
	end
end)


function delNWMine()

	if(CLIENT) then
	
		local idx = net.ReadUInt(16)

		for id, idx_ in pairs(doorbusters) do
		
			if(idx == idx_) then
				table.remove(doorbusters, id);
				return;
			end
		
		end
	end
		
end

net.Receive("TTT_DOORMINE_DEL_RECEIVE", delNWMine)

function addMine(ent, ply)

	local armed = true;

	net.Start("TTT_DOORMINE_RECEIVE")
        net.WriteUInt(ent:EntIndex(), 16)
		
	if(ply:GetRole() == ROLE_TRAITOR) then
		print("SENDING TO TRAITORS")
		net.Send(GetTraitorFilter(true))
	elseif(ply:GetRole() == ROLE_DETECTIVE) then
		net.Send(GetDetectiveFilter(true))
	else
		net.Send(ply)
	end
end

function addNWMine()

	if(CLIENT) then
	
		local idx = net.ReadUInt(16)

		table.insert(doorbusters, idx);
	end
		
end

net.Receive("TTT_DOORMINE_RECEIVE", addNWMine)


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	util.PrecacheSound("weapons/gamefreak/beep.wav")
	util.PrecacheSound("weapons/c4/c4_plant.wav")
	util.PrecacheSound("weapons/gamefreak/johncena.wav")
	self:SetMaterial("c4_green/w/c4_green")
end

function SWEP:OnRemove()
  if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
    RunConsoleCommand("lastinv")
  end
  
end

/*function SWEP:Deploy()
	if SERVER then self:CallOnClient("Deploy","") end
	self.Owner:GetViewModel():SetSubMaterial(1,"c4_green/v/c4_green")
return true
end*/

/*function SWEP:PreDrop()
	if IsValid(self.Owner) then self.Owner:GetViewModel():SetSubMaterial(1,"") end
	return true
end*/


function SWEP:Plant()
	if(!SERVER) then return end

    local tr = self.Owner:GetEyeTrace()
    local angle = tr.HitNormal:Angle()
    local bomb = ents.Create("entity_doorbuster")
    local ent = tr.Entity

    bomb:SetPos(tr.HitPos)
    bomb:SetAngles(angle+Angle(-90,0,180))
    bomb:Spawn()
    bomb:SetOwner(self.Owner)
    bomb:SetParent(ent)
    bomb:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    bomb:EmitSound("weapons/c4/c4_plant.wav")
    --bomb:EmitSound("weapons/gamefreak/beep.wav")
	addMine(bomb, self.Owner);
    self:Remove()
end


function SWEP:CanPrimaryAttack()
  local tr = self.Owner:GetEyeTrace()
    local hitpos = tr.HitPos
    local dist = self.Owner:GetShootPos():Distance(hitpos)
    local InWorld = true;
    if SERVER then
        InWorld = util.IsInWorld(tr.HitNormal*-50 + tr.HitPos)
    end
	//print(tr.Entity:GetClass())
    return tr.Entity and table.HasValue(ValidDoors,tr.Entity:GetClass()) and dist<90 and self.Weapon:Clip1() > 0 and InWorld
end


function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	self:Plant()
end





function drawWarn(tgt, size_, offset, no_shrink)

   local dist = LocalPlayer():GetPos():Distance(tgt:GetPos())
   
   if(dist > 400) then return end

   local size = size_ / dist * 100
   
   local o3dpos = tgt:GetPos() 

   local scrpos = o3dpos:ToScreen() -- sweet
   local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size/2 or size

   scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
   scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

   surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

   -- Drawing full size?
   if sz == size then
      local text = math.ceil(dist)
      local w, h = surface.GetTextSize(text)

      -- Show range to target
      surface.SetTextPos(scrpos.x - w/2, scrpos.y + (offset * sz) - h/2)
      surface.DrawText(text)

      text = "Door Mine. Don't Open"
      w, h = surface.GetTextSize(text)

      surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
      surface.DrawText(text)
	  
	  
	end
end

local function cleanup()

	doorbusters = {}

end

hook.Add( "TTTBeginRound", "door_buster_remove", cleanup )

function HUDPaint()
	
	local size = 50
	
	surface.SetFont("HudSelectionText")

	surface.SetTexture(surface.GetTextureID("vgui/ttt/icon_c4warn"))
	
	for id, idx in pairs(doorbusters) do
		
		local ent = ents.GetByIndex(idx)
		
		if(IsValid(ent)) then
		
			if(ent.Owner:GetRole() == ROLE_TRAITOR) then
				surface.SetDrawColor(255, 0, 0, 200)
				surface.SetTextColor(255, 0, 0, 220)
				drawWarn(ent, size, 0, true)
			elseif(ent.Owner:GetRole() == ROLE_DETECTIVE) then
				surface.SetDrawColor(51, 153, 255, 200)
				surface.SetTextColor(51, 153, 255, 220)
				drawWarn(ent, size, 0, true)
			else
				surface.SetDrawColor(51, 204, 51, 200)
				surface.SetTextColor(51, 204, 51, 220)
				drawWarn(ent, size, 0, true)
			end
		
		end
		
	end
end

hook.Add( "HUDPaint", "HUDPaint_DrawDoorBusters", HUDPaint)































