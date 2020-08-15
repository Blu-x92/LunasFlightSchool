--DO NOT EDIT OR REUPLOAD THIS FILE

local NEXT_THINK = CurTime() + 1
local CURRENT_STEP = 0
local MAX_STEP = 0
local NPC_LIST = {}
local VEHICLE_LIST = {}

hook.Add( "Think", "!!!!lfsNPCRelationshipHandler", function()
	local TIME = CurTime()

	if NEXT_THINK < TIME then
		NEXT_THINK = TIME + 0.02 -- lets make sure we build relationship for only one vehicle per 0.02  seconds so it doesn't destroy your servers fps

		if CURRENT_STEP >= MAX_STEP then
			NPC_LIST = simfphys.LFS:NPCsGetAll() -- get all npcs
			VEHICLE_LIST = simfphys.LFS:PlanesGetAll() -- get all vehicles

			NEXT_THINK = TIME + 2 -- wait 2 seconds after each loop so it doesn't spam expensive Get-functions on tick
			
			CURRENT_STEP = 0 -- reset steps
			
			MAX_STEP = table.Count( VEHICLE_LIST )

		else
			CURRENT_STEP = CURRENT_STEP + 1

			local VEHICLE = VEHICLE_LIST[ CURRENT_STEP ]
			if not IsValid( VEHICLE ) then return end

			for _, NPC in ipairs( NPC_LIST ) do -- loop through all npcs
				if IsValid( NPC ) then -- make sure it's still valid
					local Enemy = NPC:GetEnemy()
					if IsValid( Enemy ) then
						if Enemy:IsPlayer() then
							NPC.lfsLastEnemy = Enemy

							if VEHICLE == Enemy:lfsGetPlane() then
								NPC:AddEntityRelationship( VEHICLE, D_HT, 99 )
							end
						else
							if Enemy == VEHICLE then
								if IsValid( NPC.lfsLastEnemy ) then
									if NPC.lfsLastEnemy:lfsGetPlane() ~= VEHICLE then
										NPC:AddEntityRelationship( VEHICLE, D_LI, 99 )
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
