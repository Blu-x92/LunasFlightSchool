--DO NOT EDIT OR REUPLOAD THIS FILE

local meta = FindMetaTable( "Player" )

-- Optimizations ; localing globals is gr8
local GetInfoNum = meta.GetInfoNum
local CLIENT = CLIENT
local SERVER = SERVER
local IsValid = IsValid
local pairs = pairs
local tonumber = tonumber
local CreateConVar = CreateConVar
local istable = istable
local tableEmpty = table.Empty
local clamp = math.Clamp
local round = math.Round
local cos = math.cos
local rad = math.rad
local sin = math.sin
local abs = math.abs
local max = math.max
local pi = math.pi
local TraceLine = util.TraceLine
local TraceHull = util.TraceHull
local IsInWorld = util.IsInWorld

local cVar_playerignore = GetConVar( "ai_ignoreplayers" )

local lfs_controls_plane_pitch_up = "lfs_controls_plane_pitch_up"
local lfs_controls_plane_pitch_down = "lfs_controls_plane_pitch_down"
local lfs_controls_plane_roll_left = "lfs_controls_plane_roll_left"
local lfs_controls_plane_roll_right = "lfs_controls_plane_roll_right"
local lfs_controls_plane_yaw_left = "lfs_controls_plane_yaw_left"
local lfs_controls_plane_yaw_right = "lfs_controls_plane_yaw_right"
local lfs_controls_plane_exit = "lfs_controls_plane_exit"
local lfs_controls_plane_engine = "lfs_controls_plane_engine"
local lfs_controls_plane_gear = "lfs_controls_plane_gear"
local lfs_controls_plane_hover = "lfs_controls_plane_hover"
local lfs_controls_plane_freeview = "lfs_controls_plane_freeview"
local lfs_controls_plane_throttle_inc = "lfs_controls_plane_throttle_inc"
local lfs_controls_plane_throttle_dec = "lfs_controls_plane_throttle_dec"

local lfs_controls_heli_pitch_up = "lfs_controls_heli_pitch_up"
local lfs_controls_heli_pitch_down = "lfs_controls_heli_pitch_down"
local lfs_controls_heli_roll_left = "lfs_controls_heli_roll_left"
local lfs_controls_heli_roll_right = "lfs_controls_heli_roll_right"
local lfs_controls_heli_yaw_left = "lfs_controls_heli_yaw_left"
local lfs_controls_heli_yaw_right = "lfs_controls_heli_yaw_right"
local lfs_controls_heli_exit = "lfs_controls_heli_exit"
local lfs_controls_heli_engine = "lfs_controls_heli_engine"
local lfs_controls_heli_gear = "lfs_controls_heli_gear"
local lfs_controls_heli_hover = "lfs_controls_heli_hover"
local lfs_controls_heli_freeview = "lfs_controls_heli_freeview"
local lfs_controls_heli_throttle_inc = "lfs_controls_heli_throttle_inc"
local lfs_controls_heli_throttle_dec = "lfs_controls_heli_throttle_dec"

if CLIENT then -- Not using CreateClientConvar because I'm gonna use player:GetInfoNum() with these
	
	local GetConVar = GetConVar
	local stringLen = string.len
	
	CreateConVar(lfs_controls_plane_pitch_up		,KEY_S,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_pitch_down		,KEY_W,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_roll_left		,KEY_A,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_roll_right		,KEY_D,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_yaw_left		,KEY_Q,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_yaw_right		,KEY_E,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_exit			,KEY_J,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_engine			,KEY_R,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	
	CreateConVar(lfs_controls_plane_gear			,KEY_SPACE,		{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_freeview		,KEY_LALT,		{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_throttle_inc	,KEY_LSHIFT,	{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_plane_throttle_dec	,KEY_LCONTROL,	{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	
	CreateConVar(lfs_controls_heli_pitch_up			,KEY_S,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_pitch_down		,KEY_W,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_roll_left		,KEY_A,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_roll_right		,KEY_D,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_yaw_left			,KEY_Q,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_yaw_right		,KEY_E,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_exit				,KEY_J,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_engine			,KEY_R,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_hover			,KEY_X,			{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
		
	CreateConVar(lfs_controls_heli_gear				,KEY_SPACE,		{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_freeview			,KEY_LALT,		{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_throttle_inc		,KEY_LSHIFT,	{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
	CreateConVar(lfs_controls_heli_throttle_dec		,KEY_LCONTROL,	{ FCVAR_USERINFO, FCVAR_ARCHIVE }) 
end

simfphys = istable( simfphys ) and simfphys or {} -- lets check if the simfphys table exists. if not, create it!
simfphys.LFS = {} -- lets add another table for this project. We will be storing all our global functions and variables here. LFS means LunasFlightSchool

simfphys.LFS.VERSION = 135 -- note to self: Workshop is 10-version increments ahead. (next workshop update at 136)

simfphys.LFS.PlanesStored = {}
simfphys.LFS.NextPlanesGetAll = 0
simfphys.LFS.IgnorePlayers = cVar_playerignore and cVar_playerignore:GetBool() or false

simfphys.LFS.FreezeTeams = CreateConVar( "lfs_freeze_teams", "0", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"enable/disable auto ai-team switching" )
simfphys.LFS.PlayerDefaultTeam = CreateConVar( "lfs_default_teams", "0", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"set default player ai-team" )

simfphys.LFS.pSwitchKeys = {
	[KEY_1] = 1,
	[KEY_2] = 2,
	[KEY_3] = 3,
	[KEY_4] = 4,
	[KEY_5] = 5,
	[KEY_6] = 6,
	[KEY_7] = 7,
	[KEY_8] = 8,
	[KEY_9] = 9,
	[KEY_0] = 10,
}

simfphys.LFS.pSwitchKeysInv = {
	[1] = KEY_1,
	[2] = KEY_2,
	[3] = KEY_3,
	[4] = KEY_4,
	[5] = KEY_5,
	[6] = KEY_6,
	[7] = KEY_7,
	[8] = KEY_8,
	[9] = KEY_9,
	[10] = KEY_0,
}

simfphys.LFS.NotificationVoices = {
	["RANDOM"] = "0",
	["LFSORIGINAL"] = "1",
	["Charles"] = "2",
	["Grace"] = "3",
	["Darren"] = "4",
	["Susan"] = "5",
	["Graham"] = "6",
	["Peter"] = "7",
	["Rachel"] = "8",
	["Gabriel"] = "9",
	["Gabriella"] = "10",
	["Rod"] = "11",
	["Mike"] = "12",
	["Sharon"] = "13",
	["Tim"] = "14",
	["Ryan"] = "15",
	["Tracy"] = "16",
	["Amanda"] = "17",
	["Selene"] = "18",
	["Audrey"] = "19",
}

simfphys.LFS.Controls = {
	["PlaneKeys"] = {
		["MenuName"] = {
			Name = "Plane controls",
			Default = 0,
		},
		
		[lfs_controls_plane_pitch_up] = {
			Name = "Pitch up",
			Pointer = "PitchUp",
			-- Toggle = false,
			Default = KEY_S,
		},
		[lfs_controls_plane_pitch_down] = {
			Name = "Pitch down",
			Pointer = "PitchDown",
			-- Toggle = false,
			Default = KEY_W,
		},
		
		[lfs_controls_plane_roll_right] = {
			Name = "Roll right",
			Pointer = "RollRight",
			-- Toggle = false,
			Default = KEY_D,
		},
		[lfs_controls_plane_roll_left] = {
			Name = "Roll left",
			Pointer = "RollLeft",
			-- Toggle = false,
			Default = KEY_A,
		},
		
		[lfs_controls_plane_yaw_left] = {
			Name = "Yaw left",
			Pointer = "YawLeft",
			-- Toggle = false,
			Default = KEY_Q,
		},
		[lfs_controls_plane_yaw_right] = {
			Name = "Yaw right",
			Pointer = "YawRight",
			-- Toggle = false,
			Default = KEY_E,
		},
		
		[lfs_controls_plane_throttle_inc] = {
			Name = "Throttle +",
			Pointer = "ThrottleInc",
			-- Toggle = false,
			Default = KEY_LSHIFT,
		},
		[lfs_controls_plane_throttle_dec] = {
			Name = "Throttle -",
			Pointer = "ThrottleDec",
			-- Toggle = false,
			Default = KEY_LCONTROL,
		},
		
		[lfs_controls_plane_exit] = {
			Name = "Exit",
			Pointer = "Exit",
			-- Toggle = false,
			Default = KEY_J,
		},
		
		[lfs_controls_plane_engine] = {
			Name = "Toggle engine",
			Pointer = "ToggleEngine",
			-- Toggle = false,
			Default = KEY_R,
		},
		
		[lfs_controls_plane_freeview] = {
			Name = "Toggle freeview",
			Pointer = "ToggleFreeview",
			-- Toggle = false,
			Default = KEY_LALT,
		},
		
		[lfs_controls_plane_gear] = {
			Name = "Toggle landing gear",
			Pointer = "ToggleGear",
			-- Toggle = false,
			Default = KEY_SPACE,
		},
	},
	
	["HelicopterKeys"] = {
		["MenuName"] = {
			Name = "Helicopter controls",
			Default = 0,
		},
		
		[lfs_controls_heli_pitch_up] = {
			Name = "Pitch up",
			Pointer = "PitchUp",
			-- Toggle = false,
			Default = KEY_S,
		},
		[lfs_controls_heli_pitch_down] = {
			Name = "Pitch down",
			Pointer = "PitchDown",
			-- Toggle = false,
			Default = KEY_W,
		},
		
		[lfs_controls_heli_roll_right] = {
			Name = "Roll right",
			Pointer = "RollRight",
			-- Toggle = false,
			Default = KEY_D,
		},
		[lfs_controls_heli_roll_left] = {
			Name = "Roll left",
			Pointer = "RollLeft",
			-- Toggle = false,
			Default = KEY_A,
		},
		
		[lfs_controls_heli_yaw_left] = {
			Name = "Yaw left",
			Pointer = "YawLeft",
			-- Toggle = false,
			Default = KEY_Q,
		},
		[lfs_controls_heli_yaw_right] = {
			Name = "Yaw right",
			Pointer = "YawRight",
			-- Toggle = false,
			Default = KEY_E,
		},
		
		[lfs_controls_heli_throttle_inc] = {
			Name = "Throttle +",
			Pointer = "ThrottleInc",
			-- Toggle = false,
			Default = KEY_LSHIFT,
		},
		[lfs_controls_heli_throttle_dec] = {
			Name = "Throttle -",
			Pointer = "ThrottleDec",
			-- Toggle = false,
			Default = KEY_LCONTROL,
		},
		
		[lfs_controls_heli_exit] = {
			Name = "Exit",
			Pointer = "Exit",
			-- Toggle = false,
			Default = KEY_J,
		},
		
		[lfs_controls_heli_engine] = {
			Name = "Toggle engine",
			Pointer = "ToggleEngine",
			-- Toggle = false,
			Default = KEY_R,
		},
		
		[lfs_controls_heli_hover] = {
			Name = "Hover",
			Pointer = "Hover",
			-- Toggle = false,
			Default = KEY_X,
		},
		
		[lfs_controls_heli_freeview] = {
			Name = "Toggle freeview",
			Pointer = "ToggleFreeview",
			-- Toggle = false,
			Default = KEY_LALT,
		},
		
		[lfs_controls_heli_gear] = {
			Name = "Toggle landing gear",
			Pointer = "ToggleGear",
			-- Toggle = false,
			Default = KEY_SPACE,
		},
	},
}

function simfphys.LFS.CheckUpdates()
	http.Fetch("https://github.com/Blu-x92/LunasFlightSchool", function(contents,size) 
		local LatestVersion = tonumber( string.match( contents, "%s*(%d+)\n%s*</span>\n%s*commits" ) ) or 0  -- i took this from acf. I hope they don't mind
		
		if simfphys.LFS.GetVersion() >= LatestVersion then
			print("[LFS] is up to date, Version: "..simfphys.LFS.GetVersion())
		else
			print("[LFS] a newer version is available! Version: "..LatestVersion..", You have Version: "..simfphys.LFS.GetVersion())
			print("[LFS] get the latest version at https://github.com/Blu-x92/LunasFlightSchool")
			
			if CLIENT then 
				timer.Simple(18, function() 
					chat.AddText( Color( 255, 0, 0 ), "[LFS] a newer version is available!" )
					surface.PlaySound( "lfs/notification/ding.ogg" )
					timer.Simple(0.5, function() 
						simfphys.LFS.PlayNotificationSound()
					end )
				end)
			end
		end
	end)
end

function simfphys.LFS.GetVersion()
	return simfphys.LFS.VERSION
end

function simfphys.LFS:PlanesGetAll()
	local Time = CurTime()
	
	if simfphys.LFS.NextPlanesGetAll < Time then
		simfphys.LFS.NextPlanesGetAll = Time + FrameTime()
		
		tableEmpty( simfphys.LFS.PlanesStored )
		
		local Index = 0

		for _,v in pairs( ents.GetAll() ) do
			if v.LFS then
				Index = Index + 1
				simfphys.LFS.PlanesStored[Index] = v
			end
		end
	end
	
	return simfphys.LFS.PlanesStored
end

function meta:lfsGetPlane()
	if not self:InVehicle() then return NULL end
	
	local Pod = self:GetVehicle()
	
	if not IsValid( Pod ) then return NULL end
	
	if Pod.LFSchecked == true then
		
		return Pod.LFSBaseEnt
		
	elseif Pod.LFSchecked == nil then
		
		local Parent = Pod:GetParent()
		
		if not IsValid( Parent ) then Pod.LFSchecked = false return NULL end
		
		if not Parent.LFS then Pod.LFSchecked = false return NULL end
		
		Pod.LFSchecked = true
		Pod.LFSBaseEnt = Parent
		
		return Parent
	else
		return NULL
	end
end

function meta:GetIsKeyDown(key)
	if CLIENT then
		return input.IsKeyDown(key)
	else
		
	end
end

function meta:lfsGetAITeam()
	return self:GetNWInt( "lfsAITeam", simfphys.LFS.PlayerDefaultTeam:GetInt() )
end

if SERVER then 
	resource.AddWorkshop("1571918906")
	
	util.AddNetworkString( "lfs_failstartnotify" )
	util.AddNetworkString( "lfs_shieldhit" )
	util.AddNetworkString( "lfs_admin_setconvar" )
	
	net.Receive( "lfs_admin_setconvar", function( length, ply )
		if not IsValid( ply ) or not ply:IsSuperAdmin() then return end
		
		local ConVar = net.ReadString()
		local Value = tonumber( net.ReadString() )
		
		RunConsoleCommand( ConVar, Value ) 
	end)
	
	function meta:lfsSetAITeam( nTeam )
		nTeam = nTeam or simfphys.LFS.PlayerDefaultTeam:GetInt()
		
		if self:lfsGetAITeam() ~= nTeam then
			self:PrintMessage( HUD_PRINTTALK, "[LFS] Your AI-Team has been updated to: Team "..nTeam )
		end
		
		self:SetNWInt( "lfsAITeam", nTeam )
	end
	
	hook.Add("CanExitVehicle","!!!lfsCanExitVehicle",function(vehicle,ply)
		local veh = ply:lfsGetPlane()
		if IsValid(veh) then return false end
	end)
	
	--[[hook.Add("PlayerBindPress","!!!lfsCanPressKey",function(ply,bind,pressed)
		if IsValid(ply:lfsGetPlane()) then
			return false
		end
	end)]]
	
	hook.Add( "PlayerButtonDown", "!!!lfsKeyStuffDown", function( ply, button )
		local vehicle = ply:lfsGetPlane()
		
		if not IsValid( vehicle ) then return end
		
		if button == KEY_1 then
			if not IsValid( vehicle:GetDriver() ) and not vehicle:GetAI() then
				ply:ExitVehicle()
				
				local DriverSeat = vehicle:GetDriverSeat()
				
				if IsValid( DriverSeat ) then
					timer.Simple( FrameTime(), function()
						if not IsValid( vehicle ) or not IsValid( ply ) then return end
						if IsValid( vehicle:GetDriver() ) or not IsValid( DriverSeat ) or vehicle:GetAI() then return end
						
						ply:EnterVehicle( DriverSeat )
						
						timer.Simple( FrameTime() * 2, function()
							if not IsValid( ply ) or not IsValid( vehicle ) then return end
							ply:SetEyeAngles( Angle(0,vehicle:GetAngles().y,0) )
						end)
					end)
				end
			end
		else
			if simfphys.LFS.pSwitchKeys[button] then
				for _, Pod in pairs( vehicle:GetPassengerSeats() ) do
					if IsValid( Pod ) then
						if Pod:GetNWInt( "pPodIndex", 3 ) == simfphys.LFS.pSwitchKeys[ button ] then
							if not IsValid( Pod:GetDriver() ) then
								ply:ExitVehicle()
							
								timer.Simple( FrameTime(), function()
									if not IsValid( Pod ) or not IsValid( ply ) then return end
									if IsValid( Pod:GetDriver() ) then return end
									
									ply:EnterVehicle( Pod )
								end)
							end
						end
					end
				end
			else
				if vehicle:GetDriver() == ply then
					
					hook.Run("LFSButtonDown",button,vehicle,ply)
					
					if vehicle.Base == "lunasflightschool_basescript_heli" then
						for k,v in pairs(simfphys.LFS.Controls.HelicopterKeys) do
							local var = GetInfoNum(ply,k,v.Default)
							if button == var then
								local tab = simfphys.LFS.Controls.HelicopterKeys[k]
								if tab then
									vehicle.ControlInput[tab.Pointer] = true
									if tab.Name == "Exit" then
										ply:ExitVehicle()
									end
									break
								end
							end
						end
					else
						for k,v in pairs(simfphys.LFS.Controls.PlaneKeys) do
							local var = GetInfoNum(ply,k,v.Default)
							if button == var then
								local tab = simfphys.LFS.Controls.PlaneKeys[k]
								if tab then
									vehicle.ControlInput[tab.Pointer] = true
									if tab.Name == "Exit" then
										ply:ExitVehicle()
									end
									break
								end
							end
						end
					end
				end
			end
		end
	end )
	
	hook.Add("PlayerButtonUp","!!!lfsKeyStuffUp",function(ply,button)
		local vehicle = ply:lfsGetPlane()
		
		if not IsValid(vehicle) then return end
		if not vehicle:GetDriver() == ply then return end
		
		hook.Run("LFSButtonUp",button,vehicle,ply)
		
		if vehicle.Base == "lunasflightschool_basescript_heli" then
			for k,v in pairs(simfphys.LFS.Controls.HelicopterKeys) do
				local var = GetInfoNum(ply,k,v.Default)
				if button == var then
					local tab = simfphys.LFS.Controls.HelicopterKeys[k]
					if tab then
						vehicle.ControlInput[tab.Pointer] = false
						if tab.Name == "Exit" then
							ply:ExitVehicle()
						end
						break
					end
				end
			end
		else 
			for k,v in pairs(simfphys.LFS.Controls.PlaneKeys) do
				local var = GetInfoNum(ply,k,v.Default)
				if button == var then
					local tab = simfphys.LFS.Controls.PlaneKeys[k]
					if tab then
						vehicle.ControlInput[tab.Pointer] = false
						if tab.Name == "Exit" then
							ply:ExitVehicle()
						end
						break
					end
				end
			end
		end
	end)
	
	hook.Add( "PlayerLeaveVehicle", "!!LFS_Exit", function( ply, vehicle )
		if not ply:IsPlayer() then return end
		
		local Pod = ply:GetVehicle()
		local Parent = ply:lfsGetPlane()
		
		if not IsValid( Pod ) or not IsValid( Parent ) then return end
		
		if not simfphys.LFS.FreezeTeams:GetBool() then
			ply:lfsSetAITeam( Parent:GetAITEAM() )
		end
		
		local ent = Pod
		local b_ent = Parent
		
		local Center = b_ent:LocalToWorld( b_ent:OBBCenter() )
		local vel = b_ent:GetVelocity()
		local radius = b_ent:BoundingRadius()
		local HullSize = Vector(18,18,0)
		local Filter1 = {ent,ply}
		local Filter2 = {ent,ply,b_ent}
		
		if vel:Length() > 250 then
			local pos = b_ent:GetPos()
			local dir = vel:GetNormalized()
			local targetpos = pos - dir *  (radius + 40)
			
			local tr = TraceHull( {
				start = Center,
				endpos = targetpos - Vector(0,0,10),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter2
			} )
			
			local exitpoint = tr.HitPos + Vector(0,0,10)
			
			if IsInWorld( exitpoint ) then
				ply:SetPos(exitpoint)
				ply:SetEyeAngles((pos - exitpoint):Angle())
			end
		else
			local pos = ent:GetPos()
			local targetpos = (pos + ent:GetRight() * 80)
			
			local tr1 = TraceLine( {
				start = targetpos,
				endpos = targetpos - Vector(0,0,100),
				filter = {}
			} )
			local tr2 = TraceHull( {
				start = targetpos,
				endpos = targetpos + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = targetpos,filter = Filter2} )
			
			local HitGround = tr1.Hit
			local HitWall = tr2.Hit or traceto.Hit
			
			local check0 = (HitWall == true or HitGround == false or IsInWorld( targetpos ) == false) and (pos - ent:GetRight() * 80) or targetpos
			local tr = TraceHull( {
				start = check0,
				endpos = check0 + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = check0,filter = Filter2} )
			local HitWall = tr.Hit or traceto.hit
			
			local check1 = (HitWall == true or HitGround == false or IsInWorld( check0 ) == false) and (pos + ent:GetUp() * 100) or check0
			
			local tr = TraceHull( {
				start = check1,
				endpos = check1 + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = check1,filter = Filter2} )
			local HitWall = tr.Hit or traceto.hit
			local check2 = (HitWall == true or IsInWorld( check1 ) == false) and (pos - ent:GetUp() * 100) or check1
			
			local tr = TraceHull( {
				start = check2,
				endpos = check2 + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = check2,filter = Filter2} )
			local HitWall = tr.Hit or traceto.hit
			local check3 = (HitWall == true or IsInWorld( check2 ) == false) and b_ent:LocalToWorld( Vector(0,radius,0) ) or check2
			
			local tr = TraceHull( {
				start = check3,
				endpos = check3 + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = check3,filter = Filter2} )
			local HitWall = tr.Hit or traceto.hit
			local check4 = (HitWall == true or IsInWorld( check3 ) == false) and b_ent:LocalToWorld( Vector(0,-radius,0) ) or check3
			
			local tr = TraceHull( {
				start = check4,
				endpos = check4 + Vector(0,0,80),
				maxs = HullSize,
				mins = -HullSize,
				filter = Filter1
			} )
			local traceto = TraceLine( {start = Center,endpos = check4,filter = Filter2} )
			local HitWall = tr.Hit or traceto.hit
			local exitpoint = (HitWall == true or IsInWorld( check4 ) == false) and b_ent:LocalToWorld( Vector(0,0,0) ) or check4
			
			if isvector( ent.ExitPos ) then
				exitpoint = b_ent:LocalToWorld( ent.ExitPos )
			end
			
			if IsInWorld( exitpoint ) then
				ply:SetPos(exitpoint)
				ply:SetEyeAngles((pos - exitpoint):Angle())
			end
		end
	end )
end

if CLIENT then
	local CreateClientConVar = CreateClientConVar
	
	local cvarVolume = CreateClientConVar( "lfs_volume", 1, true, false)
	local cvarCamFocus = CreateClientConVar( "lfs_camerafocus", 0, true, false)
	local cvarShowPlaneIdent = CreateClientConVar( "lfs_show_identifier", 1, true, false)
	local cvarNotificationVoice = CreateClientConVar( "lfs_notification_voice", "RANDOM", true, false)
	local ShowPlaneIdent = cvarShowPlaneIdent and cvarShowPlaneIdent:GetBool() or true

	function simfphys.LFS.PlayNotificationSound()
		local soundfile = simfphys.LFS.NotificationVoices[GetConVar( "lfs_notification_voice" ):GetString()]

		if soundfile == "0" or not soundfile then
			surface.PlaySound( "lfs/notification/"..math.random(1,19)..".ogg" )
		else
			surface.PlaySound( "lfs/notification/"..soundfile..".ogg" )
		end
	end

	local HintPlayerAboutHisFuckingIncompetence = true
	local smTran = 0
	hook.Add( "CalcView", "!!!!LFS_calcview", function(ply, pos, angles, fov)
		HintPlayerAboutHisFuckingIncompetence = false
	 
		if ply:GetViewEntity() ~= ply then return end
		
		local Pod = ply:GetVehicle()
		local Parent = ply:lfsGetPlane()
		
		if not IsValid( Pod ) or not IsValid( Parent ) then return end
		
		local cvarFocus = clamp( cvarCamFocus:GetFloat() , -1, 1 )
		
		smTran = smTran + ((Parent.ControlInput.ToggleFreeview and 0 or 1) - smTran) * FrameTime() * 10
		
		local view = {}
		view.origin = pos
		view.fov = fov
		view.drawviewer = true
		view.angles = (Parent:GetForward() * (1 + cvarFocus) * smTran * 0.8 + ply:EyeAngles():Forward() * max(1 - cvarFocus, 1 - smTran)):Angle()
		view.angles.r = 0
		
		if Parent:GetDriverSeat() ~= Pod then
			view.angles = ply:EyeAngles()
		end
		
		if not Pod:GetThirdPersonMode() then
			
			view.drawviewer = false
			
			return Parent:LFSCalcViewFirstPerson( view, ply )
		end
		
		local radius = 550
		radius = radius + radius * Pod:GetCameraDistance()
		
		local TargetOrigin = view.origin - view.angles:Forward() * radius  + view.angles:Up() * radius * 0.2
		local WallOffset = 4

		local tr = TraceHull( {
			start = view.origin,
			endpos = TargetOrigin,
			filter = function( e )
				local c = e:GetClass()
				local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS
				
				return collide
			end,
			mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
			maxs = Vector( WallOffset, WallOffset, WallOffset ),
		} )
		
		view.origin = tr.HitPos
		
		if tr.Hit and not tr.StartSolid then
			view.origin = view.origin + tr.HitNormal * WallOffset
		end

		return Parent:LFSCalcViewThirdPerson( view, ply )
	end )

	local function DrawCircle( X, Y, radius )
		local segmentdist = 360 / ( 2 * pi * radius / 2 )
		
		for a = 0, 360, segmentdist do
			surface.DrawLine( X + cos( rad( a ) ) * radius, Y - sin( rad( a ) ) * radius, X + cos( rad( a + segmentdist ) ) * radius, Y - sin( rad( a + segmentdist ) ) * radius )
			
			surface.DrawLine( X + cos( rad( a ) ) * radius, Y - sin( rad( a ) ) * radius, X + cos( rad( a + segmentdist ) ) * radius, Y - sin( rad( a + segmentdist ) ) * radius )
		end
	end

	surface.CreateFont( "LFS_FONT", {
		font = "Verdana",
		extended = false,
		size = 20,
		weight = 2000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "LFS_FONT_SWITCHER", {
		font = "Verdana",
		extended = false,
		size = 16,
		weight = 2000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	} )
	
	surface.CreateFont( "LFS_FONT_PANEL", {
		font = "Arial",
		extended = false,
		size = 14,
		weight = 1,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	
	local MinZ = 0
	local function PaintPlaneHud( ent, X, Y )

		if not IsValid( ent ) then return end
		
		local vel = ent:GetVelocity():Length()
		
		local Throttle = ent:GetThrottlePercent()
		local Col = Throttle <= 100 and Color(255,255,255,255) or Color(255,0,0,255)
		draw.SimpleText( "THR", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( Throttle.."%" , "LFS_FONT", 120, 10, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		local speed = round(vel * 0.09144,0)
		draw.SimpleText( "IAS", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( speed.."km/h" , "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		local ZPos = round( ent:GetPos().z,0)
		if (ZPos + MinZ)< 0 then MinZ = abs(ZPos) end
		
		local alt = round( (ent:GetPos().z + MinZ) * 0.0254,0)
		
		draw.SimpleText( "ALT", "LFS_FONT", 10, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( alt.."m" , "LFS_FONT", 120, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		local AmmoPrimary = ent:GetAmmoPrimary()
		local AmmoSecondary = ent:GetAmmoSecondary()
		
		if ent:GetMaxAmmoPrimary() > -1 then
			draw.SimpleText( "PRI", "LFS_FONT", 10, 85, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( ent:GetAmmoPrimary(), "LFS_FONT", 120, 85, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		if ent:GetMaxAmmoSecondary() > -1 then
			draw.SimpleText( "SEC", "LFS_FONT", 10, 110, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( ent:GetAmmoSecondary(), "LFS_FONT", 120, 110, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		ent:LFSHudPaint( X, Y, {speed = speed, altitude = alt, PrimaryAmmo = AmmoPrimary, SecondaryAmmo = AmmoSecondary, Throttle = Throttle}, ply )
	end
	
	local smHider = 0
	local function PaintSeatSwitcher( ent, X, Y )
		local me = LocalPlayer()
		
		if not IsValid( ent ) then return end
		
		local pSeats = ent:GetPassengerSeats()
		local SeatCount = table.Count( pSeats ) 
		
		if SeatCount <= 0 then return end
		
		pSeats[0] = ent:GetDriverSeat()
		
		draw.NoTexture() 
		
		local MySeat = me:GetVehicle():GetNWInt( "pPodIndex", -1 )
		
		local Passengers = {}
		for _, ply in pairs( player.GetAll() ) do
			if ply:lfsGetPlane() == ent then
				local Pod = ply:GetVehicle()
				Passengers[ Pod:GetNWInt( "pPodIndex", -1 ) ] = ply:GetName()
			end
		end
		if ent:GetAI() then
			Passengers[1] = "[AI] "..ent.PrintName
		end
		
		me.SwitcherTime = me.SwitcherTime or 0
		me.oldPassengers = me.oldPassengers or {}
		
		local Time = CurTime()
		for k, v in pairs( Passengers ) do
			if me.oldPassengers[k] ~= v then
				me.oldPassengers[k] = v
				me.SwitcherTime = Time + 2
			end
		end
		for k, v in pairs( me.oldPassengers ) do
			if not Passengers[k] then
				me.oldPassengers[k] = nil
				me.SwitcherTime = Time + 2
			end
		end
		
		for _, v in pairs( simfphys.LFS.pSwitchKeysInv ) do
			if input.IsKeyDown(v) then
				me.SwitcherTime = Time + 2
			end
		end
		
		local Hide = me.SwitcherTime > Time
		smHider = smHider + ((Hide and 1 or 0) - smHider) * FrameTime() * 15
		local Alpha1 = 135 + 110 * smHider 
		local HiderOffset = 300 * smHider
		local Offset = -50
		local yPos = Y - (SeatCount + 1) * 30 - 10
		
		for _, Pod in pairs( pSeats ) do
			local I = Pod:GetNWInt( "pPodIndex", -1 )
			if I >= 0 then
				if I == MySeat then
					draw.RoundedBox(5, X + Offset - HiderOffset, yPos + I * 30, 35 + HiderOffset, 25, Color(127,0,0,100 + 50 * smHider) )
				else
					draw.RoundedBox(5, X + Offset - HiderOffset, yPos + I * 30, 35 + HiderOffset, 25, Color(0,0,0,100 + 50 * smHider) )
				end
				if Hide then
					if Passengers[I] then
						draw.DrawText( Passengers[I], "LFS_FONT_SWITCHER", X + 40 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255,  Alpha1 ), TEXT_ALIGN_LEFT )
					else
						draw.DrawText( "-", "LFS_FONT_SWITCHER", X + 40 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255,  Alpha1 ), TEXT_ALIGN_LEFT )
					end
					
					draw.DrawText( "["..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
				else
					if Passengers[I] then
						draw.DrawText( "[^"..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
					else
						draw.DrawText( "["..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
					end
				end
			end
		end
	end

	local NextFind = 0
	local AllPlanes = {}
	local function PaintPlaneIdentifier( ent )
		if not ShowPlaneIdent then return end
		
		if NextFind < CurTime() then
			NextFind = CurTime() + 3
			AllPlanes = simfphys.LFS:PlanesGetAll()
		end
		
		local MyPos = ent:GetPos()
		local MyTeam = ent:GetAITEAM()
		
		for _, v in pairs( AllPlanes ) do
			if IsValid( v ) then
				if v ~= ent then
					if isvector( v.SeatPos ) then
						local rPos = v:LocalToWorld( v.SeatPos )
						local Pos = rPos:ToScreen()
						local Size = 60
						local Dist = (MyPos - rPos):Length()
						
						if Dist < 13000 then
							local Alpha = max(255 - Dist * 0.015,0)
							local Team = v:GetAITEAM()
							
							if Team == 0 then
								surface.SetDrawColor( 255, 150, 0, Alpha )
							else
								if Team ~= MyTeam then
									surface.SetDrawColor( 255, 0, 0, Alpha )
								else
									surface.SetDrawColor( 0, 127, 255, Alpha )
								end
							end
							
							surface.DrawLine( Pos.x - Size, Pos.y + Size, Pos.x + Size, Pos.y + Size )
							surface.DrawLine( Pos.x - Size, Pos.y - Size, Pos.x - Size, Pos.y + Size )
							surface.DrawLine( Pos.x + Size, Pos.y - Size, Pos.x + Size, Pos.y + Size )
							surface.DrawLine( Pos.x - Size, Pos.y - Size, Pos.x + Size, Pos.y - Size )
						end
					end
				end
			end
		end
	end

	local LFS_TIME_NOTIFY = 0
	net.Receive( "lfs_failstartnotify", function( len )
		surface.PlaySound( "common/wpn_hudon.ogg" )
		LFS_TIME_NOTIFY = CurTime() + 2
	end )
	
	net.Receive( "lfs_shieldhit", function( len )
		local Pos = net.ReadVector()
		if isvector( Pos ) then
			local effectdata = EffectData()
				effectdata:SetOrigin( Pos )
			util.Effect( "lfs_shield_deflect", effectdata )
		end
	end )

	hook.Add( "HUDPaint", "!!!!LFS_hud", function()
		local ply = LocalPlayer()
		
		if ply:GetViewEntity() ~= ply then return end
		
		local Pod = ply:GetVehicle()
		local Parent = ply:lfsGetPlane()
		
		if not IsValid( Pod ) or not IsValid( Parent ) then 
			ply.oldPassengers = {}
			
			return
		end
		
		local X = ScrW()
		local Y = ScrH()
		
		PaintSeatSwitcher( Parent, X, Y )
		
		if Parent:GetDriverSeat() ~= Pod then 
			Parent:LFSHudPaintPassenger( X, Y, ply )
			
			return
		end
		
		if HintPlayerAboutHisFuckingIncompetence then
			if not Parent.ERRORSOUND then
				surface.PlaySound( "error.wav" )
				Parent.ERRORSOUND = true
			end
			
			local HintCol = Color(255,0,0, 255 )
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, X, Y ) 
			surface.SetDrawColor( 255, 255, 255, 255 )
			
			draw.SimpleText( "OOPS! SOMETHING WENT WRONG :( ", "LFS_FONT", X * 0.5, Y * 0.5 - 40, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "ONE OF YOUR ADDONS IS BREAKING THE CALCVIEW HOOK. PLANES WILL NOT BE USEABLE", "LFS_FONT", X * 0.5, Y * 0.5 - 20, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "HOW TO FIX?", "LFS_FONT", X * 0.5, Y * 0.5 + 20, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "DISABLE ALL ADDONS THAT COULD POSSIBLY MESS WITH THE CAMERA-VIEW", "LFS_FONT", X * 0.5, Y * 0.5 + 40, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "(THIRDPERSON ADDONS OR SIMILAR)", "LFS_FONT", X * 0.5, Y * 0.5 + 60, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			draw.SimpleText( ">>PRESS YOUR USE-KEY TO LEAVE THE VEHICLE & HIDE THIS MESSAGE<<", "LFS_FONT", X * 0.5, Y * 0.5 + 120, Color(255,0,0, abs( cos( CurTime() ) * 255) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			return
		end
		
		PaintPlaneHud( Parent, X, Y )
		PaintPlaneIdentifier( Parent )
		
		local startpos =  Parent:GetRotorPos()
		local Filter = Parent:LFSHUDPaintFilter()
		local TracePlane = TraceLine( {
			start = startpos,
			endpos = (startpos + Parent:GetForward() * 50000),
			filter = Filter
		} )
		
		local TracePilot = TraceLine( {
			start = startpos,
			endpos = (startpos + ply:EyeAngles():Forward() * 50000),
			filter = Filter
		} )
		
		local HitPlane = TracePlane.HitPos:ToScreen()
		local HitPilot = TracePilot.HitPos:ToScreen()

		local Sub = Vector(HitPilot.x,HitPilot.y,0) - Vector(HitPlane.x,HitPlane.y,0)
		local Len = Sub:Length()
		local Dir = Sub:GetNormalized()
		surface.SetDrawColor( 255, 255, 255, 100 )
		if Len > 34 then
			local FailStart = LFS_TIME_NOTIFY > CurTime()
			if FailStart then
				surface.SetDrawColor( 255, 0, 0, abs( cos( CurTime() * 10 ) ) * 255 )
			end
			
			if not Parent.ControlInput.ToggleFreeview or FailStart then
				surface.DrawLine( HitPlane.x + Dir.x * 10, HitPlane.y + Dir.y * 10, HitPilot.x - Dir.x * 34, HitPilot.y- Dir.y * 34 )
				
				-- shadow
				surface.SetDrawColor( 0, 0, 0, 50 )
				surface.DrawLine( HitPlane.x + Dir.x * 10 + 1, HitPlane.y + Dir.y * 10 + 1, HitPilot.x - Dir.x * 34+ 1, HitPilot.y- Dir.y * 34 + 1 )
			end
		end
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		DrawCircle( HitPlane.x, HitPlane.y, 10 )
		surface.DrawLine( HitPlane.x + 10, HitPlane.y, HitPlane.x + 20, HitPlane.y ) 
		surface.DrawLine( HitPlane.x - 10, HitPlane.y, HitPlane.x - 20, HitPlane.y ) 
		surface.DrawLine( HitPlane.x, HitPlane.y + 10, HitPlane.x, HitPlane.y + 20 ) 
		surface.DrawLine( HitPlane.x, HitPlane.y - 10, HitPlane.x, HitPlane.y - 20 ) 
		DrawCircle( HitPilot.x, HitPilot.y, 34 )
		
		-- shadow
		surface.SetDrawColor( 0, 0, 0, 80 )
		DrawCircle( HitPlane.x + 1, HitPlane.y + 1, 10 )
		surface.DrawLine( HitPlane.x + 11, HitPlane.y + 1, HitPlane.x + 21, HitPlane.y + 1 ) 
		surface.DrawLine( HitPlane.x - 9, HitPlane.y + 1, HitPlane.x - 16, HitPlane.y + 1 ) 
		surface.DrawLine( HitPlane.x + 1, HitPlane.y + 11, HitPlane.x + 1, HitPlane.y + 21 ) 
		surface.DrawLine( HitPlane.x + 1, HitPlane.y - 19, HitPlane.x + 1, HitPlane.y - 16 ) 
		DrawCircle( HitPilot.x + 1, HitPilot.y + 1, 34 )
	end )
	
	local Frame
	local bgMat = Material( "lfs_controlpanel_bg.png" )
	local adminMat = Material( "icon16/shield.png" )
	local soundPreviewMat = Material( "materials/icon16/sound.png" )
	
	local IsClientSelected = true
	
	local function OpenControlsSettings()
		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 490, 300 )
		Frame:SetTitle( "" )
		Frame:SetDraggable( true )
		Frame:MakePopup()
		Frame:Center()
		Frame.Paint = function(self, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
			draw.RoundedBox( 8, 1, 46, w-2, h-47, Color( 120, 120, 120, 255 ) )
			
			-- local ColorSelected = Color( 120, 120, 120, 255 )
			
			-- local Col_C = IsClientSelected and Color( 120, 120, 120, 255 ) or Color( 80, 80, 80, 255 )
			-- local Col_S = IsClientSelected and Color( 80, 80, 80, 255 ) or Color( 120, 120, 120, 255 )
			
			-- draw.RoundedBox( 4, 1, 26, 199, IsClientSelected and 36 or 19, Col_C )
			-- draw.RoundedBox( 4, 201, 26, 198, IsClientSelected and 19 or 36, Col_S )
			
			draw.RoundedBox( 8, 0, 0, w, h, Color( 127, 0, 0, 255 ) )
			draw.SimpleText( "[LFS] Planes - Controls ", "LFS_FONT", 5, 11, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			
			surface.SetDrawColor( 255, 255, 255, 50 )
			surface.SetMaterial( bgMat )
			surface.DrawTexturedRect( 0, -50, w, w )
			
			draw.DrawText( "v"..simfphys.LFS.GetVersion()..".WS", "LFS_FONT_PANEL", w - 15, h - 20, Color( 200, 200, 200, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		end
			
		local DScrollPanel = vgui.Create("DScrollPanel",Frame)
		DScrollPanel:Dock(FILL)
		DScrollPanel.Binders = {}
		local x,y = 100,-30
		local tab
		local GetKeyName = input.GetKeyName
		
		for k,v in pairs(simfphys.LFS.Controls) do
			if k != tab then 
				tab = k
				-- y = y == -30 and y or y + 50
				local DLabel = vgui.Create("DLabel",DScrollPanel)
				DLabel:SetPos(0,y == -30 and y or y - 30)
				DLabel:SetFont("LFS_FONT")
				DLabel:SetText(v.MenuName.Name)
				DLabel:SetSize(500,80)
				y = y == -30 and 30 or y + 30
			end
			for a,b in SortedPairsByMemberValue(v,"Name") do
				if a != "MenuName" then
					local var = GetConVar(a)
					local int = var:GetInt()
					local keyname = GetKeyName(int)
					local DBinder = vgui.Create("DBinder",DScrollPanel)
					DBinder:SetValue(int)
					DBinder:SetPos(x,y)
					DBinder.var = var
					DBinder:SetSize(100,30)
					DBinder.OnChange = function(self,iNum)
						self.var:SetInt(iNum)
					end
					DScrollPanel.Binders[k..a] = DBinder
					local DLabel = vgui.Create("DLabel",DScrollPanel)
					DLabel:SetPos(x-100,y)
					DLabel:SetText(b.Name)
					DLabel:SetSize(100,30)

					y = (x + 220) > 400 and y + 50 or y
					x = (x + 220) > 400 and 100 or x + 220
				end
			end
		end
		local DButton = vgui.Create("DButton",DScrollPanel)
		DButton:SetPos(0,y + 40)
		DButton:SetSize(420,50)
		DButton:SetText("Reset to defaults")
		DButton.DoClick = function()
			for k,v in pairs(simfphys.LFS.Controls) do
				for a,b in pairs(v) do
					if a != "MenuName" then
						DScrollPanel.Binders[k..a]:SetValue(b.Default)
					end
				end
			end
		end
	end
	
	local function OpenClientSettings( Frame )
		IsClientSelected = true
		
		if IsValid( Frame.SV_PANEL ) then
			Frame.SV_PANEL:Remove()
		end
		
		if not IsValid( Frame.CL_PANEL ) then
			
			local DPanel = vgui.Create( "DPanel", Frame )
			DPanel:SetPos( 0, 45 )
			DPanel:SetSize( 400, 175 )
			DPanel.Paint = function(self, w, h ) 
				draw.DrawText( "( -1 = Focus Mouse   1 = Focus Plane )", "LFS_FONT_PANEL", 20, 65, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				draw.DrawText( "Update Notification Voice", "LFS_FONT_PANEL", 20, 100, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			Frame.CL_PANEL = DPanel
			
			local slider = vgui.Create( "DNumSlider", DPanel )
			slider:SetPos( 20, 10 )
			slider:SetSize( 300, 20 )
			slider:SetText( "Engine Volume" )
			slider:SetMin( 0 )
			slider:SetMax( 1 )
			slider:SetDecimals( 2 )
			slider:SetConVar( "lfs_volume" )
			
			local slider = vgui.Create( "DNumSlider", DPanel )
			slider:SetPos( 20, 50 )
			slider:SetSize( 300, 20 )
			slider:SetText( "Camera Focus" )
			slider:SetMin( -1 )
			slider:SetMax( 1 )
			slider:SetDecimals( 2 )
			slider:SetConVar( "lfs_camerafocus" )
			
			local CheckBox = vgui.Create( "DCheckBoxLabel", DPanel )
			CheckBox:SetText( "Show Plane Identifier" )
			CheckBox:SetConVar("lfs_show_identifier") 
			CheckBox:SizeToContents()
			CheckBox:SetPos( 20, 120 )
			
			local DComboBox = vgui.Create( "DComboBox", DPanel )
			DComboBox:SetPos( 150, 100 )
			DComboBox:SetSize( 100, 20 )
			for voicename, _ in pairs( simfphys.LFS.NotificationVoices ) do DComboBox:AddChoice( voicename ) end
			DComboBox:SetValue( cvarNotificationVoice:GetString() )
			DComboBox.OnSelect = function( self, index, value )
				cvarNotificationVoice:SetString( value ) 
			end
			
			local DermaButton = vgui.Create( "DButton", DPanel )
			DermaButton:SetText( "" )
			DermaButton:SetPos( 260, 101 )
			DermaButton:SetSize( 16, 16 )
			DermaButton.DoClick = function() simfphys.LFS.PlayNotificationSound() end
			DermaButton.Paint = function(self, w, h ) 
				surface.SetMaterial( soundPreviewMat )
				surface.DrawTexturedRect( 0, 0, w, h ) 
			end
			
			local DButton = vgui.Create("DButton",DPanel)
			DButton:SetText("Controls")
			DButton:SetPos(20,145)
			DButton:SetSize(50,20)
			DButton.DoClick = function() OpenControlsSettings() end
		end
	end
	
	local function OpenServerSettings( Frame )
		IsClientSelected = false
		
		if IsValid( Frame.CL_PANEL ) then
			Frame.CL_PANEL:Remove()
		end
		
		if not IsValid( Frame.SV_PANEL ) then
			local DPanel = vgui.Create( "DPanel", Frame )
			DPanel:SetPos( 0, 45 )
			DPanel:SetSize( 400, 175 )
			DPanel.Paint = function(self, w, h )
				draw.DrawText( "( This will only affect new connected Players )", "LFS_FONT_PANEL", 20, 25, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			Frame.SV_PANEL = DPanel
		
			local slider = vgui.Create( "DNumSlider", DPanel )
			slider:SetPos( 20, 10 )
			slider:SetSize( 300, 20 )
			slider:SetText( "Player Default AI-Team" )
			slider:SetMin( 0 )
			slider:SetMax( 2 )
			slider:SetDecimals( 0 )
			slider:SetConVar( "lfs_default_teams" )
			function slider:OnValueChanged( val )
				net.Start("lfs_admin_setconvar")
					net.WriteString("lfs_default_teams")
					net.WriteString( tostring( val ) )
				net.SendToServer()
			end
			
			local CheckBox = vgui.Create( "DCheckBoxLabel", DPanel )
			CheckBox:SetPos( 20, 65 )
			CheckBox:SetText( "Freeze Player AI-Team" )
			CheckBox:SetValue( GetConVar( "lfs_freeze_teams" ):GetInt() )
			CheckBox:SizeToContents()
			function CheckBox:OnChange( val )
				net.Start("lfs_admin_setconvar")
					net.WriteString("lfs_freeze_teams")
					net.WriteString( tostring( val and 1 or 0 ) )
				net.SendToServer()
			end
		end
	end
	
	local function OpenMenu()
		if not IsValid( Frame ) then
			Frame = vgui.Create( "DFrame" )
			Frame:SetSize( 400, 220 )
			Frame:SetTitle( "" )
			Frame:SetDraggable( true )
			Frame:MakePopup()
			Frame:Center()
			Frame.Paint = function(self, w, h )
				draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
				draw.RoundedBox( 8, 1, 46, w-2, h-47, Color( 120, 120, 120, 255 ) )
				
				local ColorSelected = Color( 120, 120, 120, 255 )
				
				local Col_C = IsClientSelected and Color( 120, 120, 120, 255 ) or Color( 80, 80, 80, 255 )
				local Col_S = IsClientSelected and Color( 80, 80, 80, 255 ) or Color( 120, 120, 120, 255 )
				
				draw.RoundedBox( 4, 1, 26, 199, IsClientSelected and 36 or 19, Col_C )
				draw.RoundedBox( 4, 201, 26, 198, IsClientSelected and 19 or 36, Col_S )
				
				draw.RoundedBox( 8, 0, 0, w, 25, Color( 127, 0, 0, 255 ) )
				draw.SimpleText( "[LFS] Planes - Control Panel ", "LFS_FONT", 5, 11, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				
				surface.SetDrawColor( 255, 255, 255, 50 )
				surface.SetMaterial( bgMat )
				surface.DrawTexturedRect( 0, -50, w, w )
				
				draw.DrawText( "v"..simfphys.LFS.GetVersion()..".WS", "LFS_FONT_PANEL", w - 15, h - 20, Color( 200, 200, 200, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
			end
			OpenClientSettings( Frame )
			
			local DermaButton = vgui.Create( "DButton", Frame )
			DermaButton:SetText( "" )
			DermaButton:SetPos( 0, 25 )
			DermaButton:SetSize( 200, 20 )
			DermaButton.DoClick = function()
				surface.PlaySound( "buttons/button14.wav" )
				OpenClientSettings( Frame )
			end
			DermaButton.Paint = function(self, w, h ) 
				local Col = (self:IsHovered() or IsClientSelected) and Color( 255, 255, 255, 255 ) or Color( 150, 150, 150, 255 )
				draw.DrawText( "CLIENT", "LFS_FONT", w * 0.5, 0, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			
			local DermaButton = vgui.Create( "DButton", Frame )
			DermaButton:SetText( "" )
			DermaButton:SetPos( 200, 25 )
			DermaButton:SetSize( 200, 20 )
			DermaButton.DoClick = function()
				if LocalPlayer():IsSuperAdmin() then
					surface.PlaySound( "buttons/button14.wav" )
					OpenServerSettings( Frame )
				else
					surface.PlaySound( "buttons/button11.wav" )
				end
			end
			DermaButton.Paint = function(self, w, h ) 
				local Highlight = (self:IsHovered() or not IsClientSelected)
				
				local Col = Highlight and Color( 255, 255, 255, 255 ) or Color( 150, 150, 150, 255 )
				draw.DrawText( "SERVER", "LFS_FONT", w * 0.5, 0, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				surface.SetDrawColor( 255, 255, 255, Highlight and 255 or 50 )
				surface.SetMaterial( adminMat )
				surface.DrawTexturedRect( 3, 2, 16, 16 )
			end
		end
	end
	
	local LFSSoundList = {}
	hook.Add( "EntityEmitSound", "!!!lfs_volumemanager", function( t )
		if t.Entity.LFS then
			local SoundFile = t.SoundName
			
			if LFSSoundList[ SoundFile ] == true then
				t.Volume = t.Volume * cvarVolume:GetFloat()
				return true
				
			elseif LFSSoundList[ SoundFile ] == false then
				return false
				
			else
				local File = string.Replace( SoundFile, "^", "" )

				local Exists = file.Exists( "sound/"..File , "GAME" )
				
				LFSSoundList[ SoundFile ] = Exists
				
				if not Exists then
					print("[LFS] '"..SoundFile.."' not found. Soundfile will not be played and is filtered for this game session to avoid fps issues.")
				end
			end
		end
	end )

	list.Set( "DesktopWindows", "LFSMenu", {
		title = "[LFS] Settings",
		icon = "icon64/iconlfs.png",
		init = function( icon, window )
			OpenMenu()
		end
	} )
	
	concommand.Add( "lfs_openmenu", function( ply, cmd, args ) OpenMenu() end )
	
	timer.Simple(10, function()
		if not istable( scripted_ents ) or not isfunction( scripted_ents.GetList ) then return end
		
		for _, v in pairs( scripted_ents.GetList()  ) do
			if v and istable( v.t ) then
				if v.t.Spawnable then
					if v.t.Base and string.StartWith( v.t.Base:lower(), "lunasflightschool_basescript" ) then
						if v.t.Category and v.t.PrintName then
							if istable( killicon ) and isfunction( killicon.Add ) then
								killicon.Add( v.t.ClassName, "HUD/killicons/lfs_plane", Color( 255, 80, 0, 255 ) )
							end
						end
					end
				end
			end
		end
	end)
	
	cvars.AddChangeCallback( "lfs_show_identifier", function( convar, oldValue, newValue ) 
		ShowPlaneIdent = tonumber( newValue ) ~=0
	end)
end

cvars.AddChangeCallback( "ai_ignoreplayers", function( convar, oldValue, newValue ) 
	simfphys.LFS.IgnorePlayers = tonumber( newValue ) ~=0
end)

 simfphys.LFS.CheckUpdates()