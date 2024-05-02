local zMod = {}
local ZManager = {
    Misc = {
        Weapons = {
            453432689,2634544996,4024951519,736523883,2578377531,1317494643,
            1593441988,2227010557,615608432,3125143736,2024373456,1141786504,
            324215364,2982836145,1924557585,3347935668,177293209,3441901897,
            317205821,3249783761,1649403952,4019527611,3675956304,2636060646,
            94989220,2285322324,2481070269,3800352039,2640438543,2017895192,
            487013001,487013001,2634544996,2937143193,100416529,2726580491,
        }
    },
    Peds = {},
    Zombies = {},
    Survivors = {},
    NormalPedestrians = {},
    Vehicles = {},
    NeededVehicles = {},
    AbandonedVehicles = {},
    ZombiesMaxSpawn = 30,
    ZombieSpawnChance = 70,
    ZombieSpecialSpawnChance = 30,
    ZombieHealth = 3000,
    InvasionMode = false,
    ZModOn = false,
    Weather = {
        ZombieWeather = {"THUNDER", "RAIN", "FOGGY"},
        NormalWeather = {"CLEAR", "EXTRASUNNY", "DAY"}
    }
}

local zSound=RequestScriptAudioBank("waveload_pain_female",true)
local tcount=TableCount

JM36.CreateThread(function ()
    while true do
        ZManager.Peds=GetPedNearbyPeds(PlayerPedId(),2000,-1)
        local v=GetPedNearbyVehicles(PlayerPedId(),2000)
        local validVehicles={}
        for i,vehicle in ipairs(v) do
            if vehicle ~= GetVehiclePedIsIn(PlayerPedId(),false) then
                validVehicles[tcount(validVehicles)+1]=vehicle
            end
        end
        for a,veh in ipairs(validVehicles) do
            if veh == GetVehiclePedIsIn(PlayerPedId(),false) or veh == GetVehiclePedIsIn(PlayerPedId(),true) then
                validVehicles[a]=nil
            end
        end
        JM36.Wait(0)
    end
end)

local function MakeZombie(ped)
    if not ZManager.Zombies[ped] and not ZManager.Survivors[ped] then
        ZManager.Zombies[ped] = {
            id = ped,
            isDead = IsEntityDead(ped),
        }
        if HasClipSetLoaded("move_m@drunk@verydrunk") then
            SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1048576000)
        end
        
        StopPedSpeaking(ped, true)
        ClearPedTasks(ped)
        SetPedKeepTask(ped, true)
        DisablePedPainAudio(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedDiesInWater(ped,true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedConfigFlag(ped, 324, true)
        SetPedCanCowerInCover(ped,false)
        SetPedPathCanUseLadders(ped,false)
        SetPedPathCanUseClimbovers(ped,false)
        SetPedCanPeekInCover(ped,false)
        SetPedCanBeShotInVehicle(ped,false)
        for i,zomb in pairs(ZManager.Survivors) do
            if #(GetEntityCoords(zomb.id,nil) - GetEntityCoords(PlayerPedId(),nil)) < 100 then
                TaskGoToEntity(ped, PlayerPedId(), -1, 0, 0.1, 0.0, 0)
            else
                local a = GetPedNearbyPeds(zomb.id,200,-1)
                for _,pd in ipairs(a) do
                    if #(GetEntityCoords(zomb.id,nil) - GetEntityCoords(pd.id,nil)) then
                        TaskGoToEntity(pd.id, PlayerPedId(), -1, 0, 0.1, 0.0, 0)
                    end
                end
            end
        end
        SetPedAsEnemy(ped, true)
        SetEntityMaxHealth(ped, 4000)
        SetEntityHealth(ped, 4000)
        SetPedSuffersCriticalHits(ped, false)
        SetPedAlertness(ped, 0)

        ApplyPedDamagePack(ped, GetHashKey('BigHitByVehicle'), 0.0, 0.9)

        local vehicle = GetVehiclePedIsIn(ped, false)
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) and GetVehiclePedIsIn(PlayerPedId(),false) ~= vehicle then
            SetVehicleOutOfControl(vehicle,RandomBoolByChance(55),RandomBoolByChance(60))
            SetVehicleEngineHealth(vehicle,0)
            if Chance(70) then
                SetVehicleHandbrake(vehicle,true)
            end
            if IsPedInAnyVehicle(ped,false) and GetEntitySpeed(4)*3.6 then
                TaskLeaveVehicle(ped,vehicle,4160)
            end
        end
        SetEntityAsNoLongerNeeded(ped)
    end
end

local function MakeSurvivor(ped)
    if not ZManager.Zombies[ped] and not ZManager.Survivors[ped] then
        ZManager.Survivors[ped]={
            id=ped,
            isDead=IsEntityDead(ped),
        }
        SetEntityHealth(ped,500)
        SetPedAsEnemy(ped,false)
        SetPedAsCop(ped,true)
        GiveWeaponToPed(ped,ZManager.Misc.Weapons[RandomNumber(1,TableCount(ZManager.Misc.Weapons))],RandomNumber(90,120),false,false)
        SetPedInfiniteAmmoClip(ped,true)
    end
end

local function ToggleAmbience()
    ZManager.ZModOn= not ZManager.ZModOn
    if ZManager.ZModOn then
        SetWeatherTypeNow(ZManager.Weather.ZombieWeather[RandomNumber(1,TableCount(ZManager.Weather.ZombieWeather))])
        SetArtificialLightsState(false)
        SetMaxWantedLevel(0)
        print("Z MODE ON")
    else
        SetWeatherTypeNow(ZManager.Weather.NormalWeather[RandomNumber(1,TableCount(ZManager.Weather.NormalWeather))])
        SetMaxWantedLevel(5)
        SetArtificialLightsState(true)
        print("Z MODE OFF")
    end
end

local function IsZombie(ped)
    for i,zomb in ipairs(ZManager.Zombies) do
        if ped.id == zomb then
            return true
        end
    end
    return false
end

local function IsSurvivor(ped)
    for i,surv in ipairs(ZManager.Survivors) do
        if ped.id == surv then
            return true
        end
    end
    return false
end

local function UpdateZ_and_S()
    if #ZManager.Peds > 0 then
        for i,ped in ipairs(ZManager.Peds) do
            if not IsZombie(ped) and not IsSurvivor(ped) then
                if Chance(20) and not ZManager.InvasionMode then
                    MakeSurvivor(ped)
                elseif Chance(90) and ZManager.InvasionMode then
                    MakeZombie(ped)
                end
            else
                ZManager.Peds[i]=nil
            end
        end
    end
end

function zMod.init()
end

local function CalculatePos(pos)
    local spawnPosz=GetOffsetFromEntityInWorldCoords(pos,RandomNumber(1,5),RandomNumber(1,5),20)
    local groundz=GetGroundZ(spawnPosz)
    local waterz=GetWaterZ(spawnPosz)
    local canSpawn=false
    if type(groundz) == 'number' and type(waterz) == 'number' then
        if ground and not spawnPosz.z < waterz then
            spawnPosz.z=groundz
        end
    end
    return canSpawn or false ,spawnPosz or nil
end

local function CreatePolicePatrols(playerPos, numPatrols, numPolicePerPatrol)
    for i=1,RandomNumber(1,3) do
        if i == 2 then
            local patrolRadius = 100.0 -- Raio de busca das patrulhas
            local attackRadius = 50.0 -- Raio de ataque das patrulhas
            local canSpawn,spawnpos=CalculatePos(PlayerPedId())
            -- Criação das patrulhas
            if spawnpos ~= nil and canSpawn == true then
                for x = 1, numPatrols do
                    local patrolPosition = playerPos + vector3.new(math.random(-patrolRadius, patrolRadius), math.random(-patrolRadius, patrolRadius), 0.0)
                    local patrolVehicle = CreateVehicle(GetHashKey("police"), patrolPosition, 0.0, true, true)
                    if DoesEntityExist(patrolVehicle) and IsPointOnRoad(spawnPos.x,spawnPos.y,spawnPos.z,patrolVehicle) then
                        -- Adiciona policias ao veículo da patrulha
                        for j = 1, numPolicePerPatrol do
                            --local spawnPos = GetOffsetFromEntityInWorldCoords(patrolVehicle, math.random(-5.0, 5.0), math.random(-5.0, 5.0), 0.0)
                            local patrolPed = CreatePedInsideVehicle(patrolVehicle, 6, GetHashKey("s_m_y_cop_01"), -1, true, true)
                            MakeSurvivor(patrolPed)
                            if DoesEntityExist(patrolPed) then
                                TaskCombatPed(patrolPed, PlayerPedId())
                                GiveWeaponToPed(patrolPed,ZManager.Misc.Weapons[RandomNumber(0,TableCount(ZManager.Misc.Weapons))],RandomNumber(60,100),false,false)
                                SetPedInfiniteAmmoClip(ped,true)
                                SetPedKeepTask(patrolPed, true)
                                TaskVehicleDriveToCoord(patrolPed, patrolVehicle, playerPos.x, playerPos.y, playerPos.z, 30.0, 1, GetEntityModel(patrolVehicle), 524419, 1.0, true)
                            end
                        end
                    end
                end
            end
        end
    end
end


--[[local function SurvivorsBehaviors()

end]]

local function SpawnZombies()
    for z = 1, RandomNumber(1, 3) do
        if CanCreateRandomPed(1) and z == 2 then
			local spawnPos=GetOffsetFromEntityInWorldCoords(PlayerPedId(),RandomNumber(1,5),RandomNumber(1,5),20)
            local canSpawn,spawnPoint=CalculatePos(spawnPos)
			if spawnPoint and spawnPoint ~= nil and canSpawn == true then
				local randZomb = CreateRandomPed(spawnPoint.x, spawnPoint.y, spawnPoint.z)
				if DoesEntityExist(randZomb) then
                    MakeZombie(randZomb)
					SetEntityAsNoLongerNeeded(randZomb)
				end
			end
        end
    end
end

local function SpawnSurvivor()
    for z = 1, RandomNumber(1, 8) do
        if CanCreateRandomPed(1)  and z == 5 then
			local spawnPos=GetOffsetFromEntityInWorldCoords(PlayerPedId(),RandomNumber(1,5),RandomNumber(1,5),20)
            local canSpawn,spawnPoint=CalculatePos(spawnPos)
			if spawnPoint and spawnPoint ~= nil and canSpawn == true then
				local randZomb = CreateRandomPed(spawnPoint.x, spawnPoint.y, spawnPoint.z)
				if DoesEntityExist(randZomb) then
                    MakeSurvivor(randZomb)
					SetEntityAsNoLongerNeeded(randZomb)
				end
			end
        end
    end
end

local function tmOn()
    Settimera(0)
end

local function UpdateKey()
    if OnKeyJustPressed("K") then
        ToggleAmbience()
	end
end

local function UpdateSZ()
    -- If the chance is 80 or up, create police patrols
    if Chance(80) then
        CreatePolicePatrols(GetEntityCoords(PlayerPedId(),nil),RandomNumber(1,4),RandomNumber(1,3))
    end
    
    -- turn off the mod if the player is dead
    if IsPlayerDead(PlayerPedId()) then
        ZManager.ZModOn=false
    end

    if ZManager.ZModOn then
        --Spawn zombies with ZManager.ZombiesSpawnChance
        if Chance(30) and not ZManager.InvasionMode then
            SpawnZombies()
        elseif Chance(85) and ZManager.InvasionMode then
            SpawnZombies()
        elseif Chance(20) then
            SpawnSurvivor()
        end

        -- set ped and vehicle density
        SetPedDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetDisableRandomTrainsThisFrame(false)
        for _, ped in ipairs(ZManager.Peds) do
            local vehicle = GetVehiclePedIsIn(ped, false)

            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local driver = GetPedInVehicleSeat(vehicle, -1) -- get vehicle driver seat
                if DoesEntityExist(driver) then
                    if Chance(86) then
                        MakeZombie(ped)
                    elseif Chance(20) then
                        MakeSurvivor(ped)
                    end
                    local nearByPeople2 = GetPedNearbyPeds(driver, 500,-1)
                    local maxArrSize = #nearByPeople2 > 5 and 5 or #nearByPeople2
                    for j = 1, maxArrSize do
                        if nearByPeople2[j] ~= PlayerPedId() and IsEntityAPed(nearByPeople2[j]) and not IsPedInGroup(nearByPeople2[j]) then
                            MakeZombie(nearByPeople2[j])
                        end
                    end
                end
                SetVehicleEngineHealth(vehicle, 0)
            end

            if IsEntityAPed(ped) and not IsPedInGroup(ped) and IsPedHuman(ped) then
                local dist = #(GetEntityCoords(PlayerPedId(),nil) - GetEntityCoords(ped,nil))
                if dist < 1.2 and not IsPedGettingUp(PlayerPedId()) and not IsPedRagdoll(PlayerPedId()) and not IsPedClimbing(ped) and not IsPedFleeing(ped) then
                    Once(tmOn)
                    local t=GetTimerA()
                    if t > 1000 then
                        ApplyDamageToPed(PlayerPedId(),15,false)
                        ResetOnce(tmOn)
                    end
                    JM36.Wait(1)
                    if not IsPedRagdoll(ped) then
                        SetPedToRagdoll(PlayerPedId(), 9000, 9000, 1, false, false,false)
                        SetPedToRagdoll(ped, 100, 100, 1, false, false,false)
                        ApplyForceToEntity(PlayerPedId(), 1, 0, 2, 0, 0, 0, 0, false, false, true, false, false, true)
                        ApplyForceToEntity(ped, 1, 0, -2, -10, 0, 0, 0, false, false, true, false, false, true)
                    end
                end
                MakeZombie(ped)
            end
        end
    end
end

function zMod.tick()
    UpdateKey()
    if ZManager.ZModOn then
        UpdateSZ()
        UpdateZ_and_S()
    end
end

function zMod.unload()
end

return zMod