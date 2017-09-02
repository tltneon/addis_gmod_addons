/*
Hi Modder,

If you'd like to use this script in any way, feel free to do so! Please just give me credit in some form and keep this comment. Thanks :-)!


The script might seem overcomplicated, but it's as simple as it can get.

The palyer NWBool "ttt_wepdraw_prim_draw" indicates, if a weapon should be rendered or not
It might seem redundant, however setting the player NWEntity "ttt_wepdraw_prim" to nil simply does not change the value for some reason, so this is a (slightly bodgy) fix to that problem.

Removing this boolean will cause dropped or removed weapons to be drawn (pointed out to me by a friendly user named Vick)

*/


local offsetvec_prim_front = Vector( 0, -5, -5 )
local offsetang_prim_front = Angle( 30,-20,0 )

local offsetvec_sec = Vector(1,5,-4.5)
local offsetang_sec = Angle( 0,0,90 )

local allModels = {}

if(SERVER) then 

local cv_draw_sec = CreateConVar("ttt_kg_holsters_draw_secondary", "1", FCVAR_ARCHIVE, "Should secondary weapons be drawn?");
local cv_draw_prim = CreateConVar("ttt_kg_holsters_draw_primary", "1", FCVAR_ARCHIVE, "Should primary weapons be drawn?");

hook.Add("Think", "ttt_weapon_draw_t", function()

	for k,v in pairs(player.GetAll()) do
	
		local primary = nil
		
		local secondary = nil
	
		local weapons = v:GetWeapons()
	
		for k_,v_ in pairs(weapons) do
	
			if(v_.Kind == WEAPON_HEAVY) then

				primary = v_
			
			elseif(v_.Kind == WEAPON_PISTOL) then
			
				secondary = v_
			
			end
		
		end
	
		if(cv_draw_prim:GetBool() and (v:GetNWEntity("ttt_wepdraw_prim", nil) != primary and not (!IsValid(v:GetNWEntity("ttt_wepdraw_prim", nil)) and primary == nil )) ) then
		
			v:SetNWEntity("ttt_wepdraw_prim", primary);
			v:SetNWBool("ttt_wepdraw_prim_draw", true);
		
		end
		
		if(!IsValid(primary) or (IsValid(v:GetNWEntity("ttt_wepdraw_prim", nil)) and not cv_draw_prim:GetBool() ) ) then
		
			v:SetNWBool("ttt_wepdraw_prim_draw", false);
		
		end
		
		if(cv_draw_sec:GetBool() and (v:GetNWEntity("ttt_wepdraw_sec", nil) != secondary and not (!IsValid(v:GetNWEntity("ttt_wepdraw_sec", nil)) and secondary == nil) ) ) then
		
			v:SetNWEntity("ttt_wepdraw_sec", secondary);
			v:SetNWBool("ttt_wepdraw_sec_draw", true);
		
		end
		
		if(!IsValid(secondary) or (IsValid(v:GetNWEntity("ttt_wepdraw_sec", nil)) and not cv_draw_sec:GetBool() ) ) then
		
			v:SetNWBool("ttt_wepdraw_sec_draw", false);
			
		
		end
	
	end

end)

hook.Add("Initialize", "init_ttt_weapon_draw", function() 

if(SERVER) then
	
end	

end)

end

if(CLIENT) then

local cl_enabled = CreateClientConVar( "cl_ttt_kg_holsters_enabled", "1", true, false, "Should you render weapon holsters? May decrease FPS slightly." )

local function renderSecondary(gun, ply, render_mode)


	if(!IsValid(gun) or gun == ply:GetActiveWeapon() ) then return end
	
	if(!IsValid(allModels[gun:GetModel()])) then
	
		allModels[gun:GetModel()] = ClientsideModel( gun:GetModel() );
	
	end
	
	local boneid = ply:LookupBone( "ValveBiped.Bip01_R_Thigh" )

	if not boneid then
		return
	end

	local matrix = ply:GetBoneMatrix( boneid )

	if not matrix then
		return
	end
	
	local offsetang_this = offsetang_sec
	local offsetvec_this = offsetvec_sec
	
	//usp being upside down fix
	if(gun:GetClass() == "weapon_ttt_pistol") then
	
		offsetang_this = offsetang_this + Angle(180, 0, 0)
		offsetvec_this = offsetvec_this + Vector(6, -5, 0)
	
	end

	local newpos, newang = LocalToWorld( offsetvec_this, offsetang_this, matrix:GetTranslation(), matrix:GetAngles() )

	local model = allModels[gun:GetModel()];
	
	if(!IsValid(model)) then return end;
	
	model:SetNoDraw( true )
	
	model:SetRenderMode(render_mode)
	
	model_color = model:GetColor();
	model:SetColor({r=model_color.r, g=model_color.g, b=model_color.b, a=(ply:GetColor().a * model_color.a)})
	
	model:SetMaterial(ply:GetMaterial())
	
	model:SetPos( newpos )
	model:SetAngles( newang )
	model:SetupBones()
	model:DrawModel()

end

function renderPrimary(primary, ply, render_mode)

	if(!IsValid(primary) or primary == ply:GetActiveWeapon() ) then return end
	
	if(!IsValid(allModels[primary:GetModel()])) then
	
		allModels[primary:GetModel()] = ClientsideModel( primary:GetModel() );
	
	end
	
	
	local boneid = ply:LookupBone( "ValveBiped.Bip01_Spine2" )

	if not boneid then
		return
	end

	local matrix = ply:GetBoneMatrix( boneid )

	if not matrix then
		return
	end
	
	local offsetang_this = offsetang_prim_front


	local newpos, newang = LocalToWorld( offsetvec_prim_front, offsetang_prim_front, matrix:GetTranslation(), matrix:GetAngles() )

	
	local model = allModels[primary:GetModel()];
	
	if(!IsValid(model)) then return end;
	
	model:SetNoDraw( true )
	
	model:SetRenderMode(render_mode)
	
	model_color = model:GetColor();
	model:SetColor({r=model_color.r, g=model_color.g, b=model_color.b, a=(ply:GetColor().a * model_color.a)})
	
	model:SetMaterial(ply:GetMaterial())
	
	model:SetPos( newpos )
	model:SetAngles( newang )
	model:SetupBones()
	model:DrawModel()

end

hook.Add( "PostPlayerDraw" , "ttt_weapon_draw" , function( ply )

	
	if(not cl_enabled:GetBool()) then return end;

	if(!IsValid(ply) or !ply:Alive()) then return end

	local primary = nil

	if(ply:GetNWBool("ttt_wepdraw_prim_draw", false)) then
		primary = ply:GetNWEntity("ttt_wepdraw_prim")
	end
	
	local secondary = nil

	if(ply:GetNWBool("ttt_wepdraw_sec_draw", false)) then
		secondary = ply:GetNWEntity("ttt_wepdraw_sec")
	end
	
	local render_mode = ply:GetRenderMode();
	
	renderSecondary(secondary, ply, render_mode);
	
	renderPrimary(primary, ply, render_mode)

end )

end