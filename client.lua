ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
			ESX = obj 
		end)
		Citizen.Wait(0)
	end

	for i = 1, #Config.DoorList do
		local doorID = Config.DoorList[i]

		local closeDoor = GetClosestObjectOfType(doorID.objCoords, 1.0, doorID.objName, false, false, false)

		if DoesEntityExist(closeDoor) then
			Config.DoorList[i]["startRotation"] = GetEntityRotation(closeDoor)
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerData = playerData

	ESX.TriggerServerCallback('esx_doorlock:getDoorInfo', function(doorInfo, count)
		--for localID = 1, count do
			if doorInfo[localID] ~= nil then
				Config.DoorList[doorInfo[localID].doorID].locked = doorInfo[localID].state
			end
		--end
	end)
end)

RegisterNetEvent( 'dooranim' )
AddEventHandler( 'dooranim', function()
    
    ClearPedSecondaryTask(GetPlayerPed(-1))
    exports['mythic_progbar']:Progress({
		name = "unique_action_name",
		duration = 300,
		label = 'Odemykání / Zamykání ...' ,
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "anim@heists@keycard@",
			anim = "exit",
			flags = 49,
		},
	}, function(cancelled)
		if not cancelled then
			ClearPedTasks(GetPlayerPed(-1))
		else
			ClearPedTasks(GetPlayerPed(-1))
		end
	end)
    --loadAnimDict( "anim@heists@keycard@" ) 
    --TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )

end)

RegisterNetEvent( 'dooranim2' )
AddEventHandler( 'dooranim2', function()
    
    ClearPedSecondaryTask(GetPlayerPed(-1))
    exports['mythic_progbar']:Progress({
		name = "unique_action_name",
		duration = 600,
		label = 'Odemykání / Zamykání ...' ,
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "mp_arresting",
			anim = "a_uncuff",
			flags = 49,
		},
	}, function(cancelled)
		if not cancelled then
			ClearPedTasks(GetPlayerPed(-1))
		else
			ClearPedTasks(GetPlayerPed(-1))
		end
	end)
    --loadAnimDict( "anim@heists@keycard@" ) 
    --TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, letSleep = GetEntityCoords(PlayerPedId()), true

		for k,doorID in ipairs(Config.DoorList) do
			local distance
			

			if doorID.doors then
				distance = #(playerCoords - doorID.doors[1].objCoords)
			else
				distance = #(playerCoords - doorID.objCoords)
			end

			local isAuthorized = IsAuthorized(doorID)
			local maxDistance, size, displayText = 1.25, 1
			
			if doorID.distance then
				maxDistance = doorID.distance
			end
			if doorID.distanceRender then
				renderdistance = doorID.distanceRender
			else 
				renderdistance = doorID.distance
			end

			if distance < maxDistance or distance <= renderdistance then
				
				letSleep = false

				if doorID.doors then
					for _,v in ipairs(doorID.doors) do
						FreezeEntityPosition(v.object, doorID.locked)

						if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
							SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
						end
					end
				else
					FreezeEntityPosition(doorID.object, doorID.locked)

					if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
						SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
					end
				end
			end

			if distance <= maxDistance then

				local size = 1.5
				if doorID.size then
					size = doorID.size
				end
				if doorID.locked then 
					if isAuthorized then
						closestString = "~b~[E]~w~ 🔒"
					else
						closestString = "🔒"
					end

					ESX.Game.Utils.DrawText3DCoords(vector3(doorID.textCoords.x, doorID.textCoords.y, doorID.textCoords.z-1.0), closestString, size)
				elseif doorID.locked == false then 
					if isAuthorized then
						closestString = "~b~[E]~w~ 🔓"
					else
						closestString = "🔓"
					end

					ESX.Game.Utils.DrawText3DCoords(vector3(doorID.textCoords.x, doorID.textCoords.y, doorID.textCoords.z-1.0), closestString, size)
				end



				if IsControlJustReleased(0, 38) then
					if isAuthorized then
						doorID.locked = not doorID.locked
						if doorID.vrata == true then
							TriggerEvent("dooranim")
							Citizen.Wait(850)
						else
							TriggerEvent("dooranim2")
							Citizen.Wait(1300)
						end

						TriggerServerEvent('esx_doorlock:updateState', k, doorID.locked) -- Broadcast new state of the door to everyone
					else
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(300)
		end
	end
end)

function ApplyDoorState(doorID)
	if tonumber(doorID.objName) == nil then
		doorID.objName = GetHashKey(doorID.objName)
	end

	local closeDoor = GetClosestObjectOfType(doorID.objCoords.x, doorID.objCoords.y, doorID.objCoords.z, 1.0, doorID.objName, false, false, false)

	if doorID["startRotation"] == nil then
		doorID["startRotation"] = GetEntityRotation(closeDoor)
	end

	if doorID["locked"] and GetEntityRotation(closeDoor) ~= doorID["startRotation"] then
		SetEntityRotation(closeDoor, doorID["startRotation"]) 
	end

	FreezeEntityPosition(closeDoor, doorID.locked)
end


function IsAuthorized(doorID)
	local Inventory = ESX.GetPlayerData().inventory

	for i = 1, #doorID.authorizedJobs, 1 do
		for invId = 1, #Inventory do
			if Inventory[invId]["count"] > 0 then
				if doorID.authorizedJobs[i] == Inventory[invId]["name"] then
					return true
				end
			end
		end
	end

	return false
end

RegisterNetEvent('esx_doorlock:setState')
AddEventHandler('esx_doorlock:setState', function(doorID, state)
	Config.DoorList[doorID].locked = state
end)

Citizen.CreateThread(function()
	while true do
	 Citizen.Wait(1500)
		for _,doorID in ipairs(Config.DoorList) do
			if doorID.doors then
				for k,v in ipairs(doorID.doors) do
					if not v.object or not DoesEntityExist(v.object) then
					Wait(100)
						v.object = GetClosestObjectOfType(v.objCoords, 1.0, GetHashKey(v.objName), false, false, false)
					end
				end
			else
				if not doorID.object or not DoesEntityExist(doorID.object) then
					doorID.object = GetClosestObjectOfType(doorID.objCoords, 1.0, GetHashKey(doorID.objName), false, false, false)
				end
			end
		end
	end
end)