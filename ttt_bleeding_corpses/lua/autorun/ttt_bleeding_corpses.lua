/*
Hi Modder,

If you'd like to use this script in any way, feel free to do so! Please just give me credit in some form and keep this comment. Thanks :-)! -St. Addi

*/

AddCSLuaFile();

if(CLIENT) then

local drawBlood = CreateConVar("cl_ttt_kg_draw_corpse_blood", "1", FCVAR_ARCHIVE, "Should blood from dead bodies be rendered?");

local corpses = {};

local oldPositions = {};

local intensities = {};

local function think()

	if(not drawBlood:GetBool()) then return end

	for k, ent in pairs(corpses) do
	
		if(IsValid(ent)) then
		
			if(oldPositions[ent:EntIndex()] ~= nil and oldPositions[ent:EntIndex()] != ent:GetPos() and math.random(0, 100) >= (100 - intensities[k]*10 ) ) then
		
				local tr = util.TraceLine({
				
				start = ent:GetPos() + Vector(0,0,100),
				endpos = ent:GetPos() + Vector(0, 0, -10000),
				filter = function(e) if(e:IsWorld()) then return true end  end
				
				});
		
				local decalpos = tr.HitPos
		
				util.Decal("Blood", decalpos, decalpos + Vector(0,0,-1) * 1000);
			
				if(math.random(0, 1000) == 1) then
					corpses[k] = nil
					table.remove(corpses, k);
					table.remove(oldPositions, k);
				else
				
					intensities[k] = intensities[k] - 0.01;
				end
			
			end
		
			oldPositions[ent:EntIndex()] = ent:GetPos()
		
		end
	
	end

end

local function clear()

	corpses = {};
	oldPositions = {};

end

local function isDeadBody(ent)

	return ( IsValid(ent) and ent:IsRagdoll() );

end

local function create(ent)

	if(isDeadBody(ent)) then
	
		corpses[ent:EntIndex()] = ent;
		intensities[ent:EntIndex()] = 1;
		
	end

end

local function rem(ent)

	if(corpses[ent:EntIndex()] ~= nil) then
	
		corpses[ent:EntIndex()] = nil;
		table.remove(corpses, ent:EntIndex());
		table.remove(oldPositions, ent:EntIndex());
	
	end

end

hook.Add("OnEntityCreated", "ttt_bleeding_corpses_create", create);

hook.Add("EntityRemoved", "ttt_bleeding_corpses_remove", rem);

hook.Add("Think", "ttt_bleeding_corpses", think);

hook.Add("TTTPrepareRound ", "ttt_bleeding_corpses_clear", clear);

end