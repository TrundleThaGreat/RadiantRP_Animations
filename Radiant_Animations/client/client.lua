local playerCurrentlyAnimated = false
local playerCurrentlyHasProp = false
local LastAD
local playerPropList = {}

Citizen.CreateThread( function()

	while true do
		Citizen.Wait(5)
		if (IsControlJustPressed(0,Config.RadioKey))  then
			local player = PlayerPedId()
			if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then 

				loadAnimDict( "random@arrests" )
				if IsEntityPlayingAnim(player, "random@arrests", "generic_radio_chatter", 3) then
					ClearPedSecondaryTask(player)
				else
					TaskPlayAnim(player, "random@arrests", "generic_radio_chatter", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
					RemoveAnimDict("random@arrests")
				end
			end
		elseif (IsControlJustPressed(0,Config.HandsUpKey)) then
			local player = PlayerPedId()
	
			if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then
	
				loadAnimDict( "random@mugging3" )
	
				if IsEntityPlayingAnim(player, "random@mugging3", "handsup_standing_base", 3) then
					ClearPedSecondaryTask(player)
				else
					TaskPlayAnim(player, "random@mugging3", "handsup_standing_base", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
					RemoveAnimDict("random@mugging3")
				end
			end

		elseif (IsControlJustPressed(0,Config.HoverHolsterKey)) then
			local player = PlayerPedId()
	
			if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then
	
				loadAnimDict( "move_m@intimidation@cop@unarmed" )
	
				if IsEntityPlayingAnim(player, "move_m@intimidation@cop@unarmed", "idle", 3) then
					ClearPedSecondaryTask(player)
				else
					TaskPlayAnim(player, "move_m@intimidation@cop@unarmed", "idle", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
					RemoveAnimDict("move_m@intimidation@cop@unarmed")
				end
			end
		end
	end
end)

RegisterNetEvent('Radiant_Animations:KillProps')
AddEventHandler('Radiant_Animations:KillProps', function()
	for _,v in pairs(playerPropList) do
		DeleteEntity(v)
	end

	playerCurrentlyHasProp = false
end)

RegisterNetEvent('Radiant_Animations:AttachProp')
AddEventHandler('Radiant_Animations:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
	local player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(player))

	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end

	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, player, GetPedBoneIndex(player, boneone), x1, y1, z1, r1, r2, r3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

local firstAnim = true
RegisterNetEvent('Radiant_Animations:Animation')
AddEventHandler('Radiant_Animations:Animation', function(ad, anim, body)
	local player = PlayerPedId()
	if playerCurrentlyAnimated then -- Cancel Old Animation

		loadAnimDict(ad)
		TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, body, 0, 0, 0, 0 )
		Wait(750)
		ClearPedSecondaryTask(player)
		RemoveAnimDict(LastAD)
		RemoveAnimDict(ad)
		LastAD = ad
		playerCurrentlyAnimated = false
		TriggerEvent('Radiant_Animations:KillProps')
		return
	end

	if firstAnim then
		LastAD = ad
		firstAnim = false
	end

	loadAnimDict(ad)
	TaskPlayAnim(player, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0 )  --- We actually play the animation here
	RemoveAnimDict(ad)
	playerCurrentlyAnimated = true

end)

RegisterNetEvent('Radiant_Animations:StopAnimations')
AddEventHandler('Radiant_Animations:StopAnimations', function()
	local player = PlayerPedId()
	if playerCurrentlyAnimated then
		RemoveAnimDict(LastAD)
		ClearPedSecondaryTask(player)
		TriggerEvent('Radiant_Animations:KillProps')
		playerCurrentlyHasProp = false
		playerCurrentlyAnimated = false
	end
end)

RegisterNetEvent('Radiant_Animations:Scenario')
AddEventHandler('Radiant_Animations:Scenario', function(ad)
	local player = PlayerPedId()
	TaskStartScenarioInPlace(player, ad, 0, 1)   
end)

RegisterNetEvent('Radiant_Animations:Surrender')  -- Too many waits to make it work properly within the config
AddEventHandler('Radiant_Animations:Surrender', function()
	local player = PlayerPedId()
	local surrendered = false

	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
		loadAnimDict( "random@arrests" )
		loadAnimDict( "random@arrests@busted" )
		if ( IsEntityPlayingAnim( player, "random@arrests@busted", "idle_a", 3 ) ) then 
			TaskPlayAnim( player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (3000)
			TaskPlayAnim( player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
			surrendered = false
			RemoveAnimDict("random@arrests" )
			RemoveAnimDict("random@arrests@busted")
		else
			TaskPlayAnim( player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (4000)
			TaskPlayAnim( player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (500)
			TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (1000)
			TaskPlayAnim( player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
			Wait(100)
			surrendered = true
		end     
	end

	Citizen.CreateThread(function() --disabling controls while surrendering
		while surrendered do
			Citizen.Wait(1000)
			if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@arrests@busted", "idle_a", 3) then
				DisableControlAction(1, 140, true)
				DisableControlAction(1, 141, true)
				DisableControlAction(1, 142, true)
				DisableControlAction(0,21,true)
			end
		end
	end)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('Radiant_Animations:KillProps')
		playerCurrentlyHasProp = false
	end
end)

RegisterCommand("e", function(source, args)

	local player = PlayerPedId()
	local argh = tostring(args[1])

	if argh == 'help' then -- List Anims in Chat Command
		TriggerEvent('chat:addMessage', { args = { '[^1Animations^0]: salute, finger, finger2, phonecall, surrender, facepalm, notes, brief, brief2, foldarms, foldarms2, damn, fail, gang1, gang2, no, pickbutt, grabcrotch, peace, cigar, cigar2, joint, cig, holdcigar, holdcig, holdjoint, dead, holster, aim, aim2, slowclap, box, cheer, bum, leanwall, copcrowd, copcrowd2, copidle, shotbar, drunkbaridle, djidle, djidle2, fdance1, fdance2, mdance1, mdance2' } })
	elseif argh == 'stuckprop' then -- Deletes Clients Props Command
		TriggerEvent('Radiant_Animations:KillProps')
	elseif argh == 'surrender' then -- I'll figure out a better way to do animations with this much depth later.
		TriggerEvent('Radiant_Animations:Surrender')
	elseif argh == 'stop' then -- Cancel Animations
		TriggerEvent('Radiant_Animations:StopAnimations')
	else
		for i = 1, #Config.Anims, 1 do
			local name = Config.Anims[i].name
			if argh == name then				
				local prop_one = Config.Anims[i].data.prop
				local boneone = Config.Anims[i].data.boneone
				if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 

					if playerCurrentlyHasProp then --- Delete Old Prop

						TriggerEvent('Radiant_Animations:KillProps')
					end

					if Config.Anims[i].data.type == 'prop' then

						TriggerEvent('Radiant_Animations:AttachProp', prop_one, boneone, Config.Anims[i].data.x, Config.Anims[i].data.y, Config.Anims[i].data.z, Config.Anims[i].data.xa, Config.Anims[i].data.yb, Config.Anims[i].data.zc)

					elseif Config.Anims[i].data.type == 'brief' then

						if name == 'brief' then
							GiveWeaponToPed(player, 0x88C78EB7, 1, false, true)
						else
							GiveWeaponToPed(player, 0x01B79F17, 1, false, true)
						end
						return
					elseif Config.Anims[i].data.type == 'scenario' then
						local ad = Config.Anims[i].data.ad

						if vehiclecheck() then
							if IsPedActiveInScenario(player) then
								ClearPedTasks(player)
							else
								TriggerEvent('Radiant_Animations:Scenario', ad)
							end 
						end
					else

						if vehiclecheck() then
							local ad = Config.Anims[i].data.ad
							local anim = Config.Anims[i].data.anim
							local body = Config.Anims[i].data.body
							
							TriggerEvent('Radiant_Animations:Animation', ad, anim, body) -- Load/Start animation

							if prop_one ~= 0 then
								local prop_two = Config.Anims[i].data.proptwo
								local bonetwo = nil

								loadPropDict(prop_one)
								TriggerEvent('Radiant_Animations:AttachProp', prop_one, boneone, Config.Anims[i].data.x, Config.Anims[i].data.y, Config.Anims[i].data.z, Config.Anims[i].data.xa, Config.Anims[i].data.yb, Config.Anims[i].data.zc)
								if prop_two ~= 0 then
									bonetwo = Config.Anims[i].data.bonetwo
									prop_two = Config.Anims[i].data.proptwo
									loadPropDict(prop_two)
									TriggerEvent('Radiant_Animations:AttachProp', prop_two, bonetwo, Config.Anims[i].data.twox, Config.Anims[i].data.twoy, Config.Anims[i].data.twoz, Config.Anims[i].data.twoxa, Config.Anims[i].data.twoyb, Config.Anims[i].data.twozc)
								end
							end
						end
					end
				end
			end
		end
	end
end)

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(100)
	end
end

function loadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
		RequestModel(GetHashKey(model))
		Citizen.Wait(100)
	end
end

function vehiclecheck()
	local player = PlayerPedId()
	if IsPedInAnyVehicle(player, false) then
		return false
	end
	return true
end
