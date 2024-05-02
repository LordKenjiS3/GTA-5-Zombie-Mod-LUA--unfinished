local zMod={}
local Started=false --mod está ativo ou inativo
local zombifiedPeds={} --tabela onde estão os zumbis (peds zumbificados)
--local zombiePedsDef={} --não utilizado, era pra guardar definições dos peds para certos eventos, porém não é mais nessesário
local nonZombiePeds={} --para peds que não são zumbis, como os sobreviventes
local weaponCr={} --tabela para armazenar as armas ja criadas
local waponsSpawn={ --não utilizado, é uma lista de hash das armas que podem ser spawnadas ou dadas ao jogador
    453432689,2634544996,4024951519,736523883,2578377531,1317494643,
    1593441988,2227010557,615608432,3125143736,2024373456,1141786504,
    324215364,2982836145,1924557585,3347935668,177293209,3441901897,
    317205821,3249783761,1649403952,4019527611,3675956304,2636060646,
    94989220,2285322324,2481070269,3800352039,2640438543,2017895192,
    487013001,487013001,2634544996,2937143193,100416529,2726580491,
}

local rnd = math.random

function zMod.init()
    if not HasClipSetLoaded("move_m@drunk@verydrunk") then --carrega o clipset de animação para verydrunk, usado para simular o movimento de zumbi
        RequestClipSet("move_m@drunk@verydrunk")
    end
end

-- alterna entre o ambiente "thunder" ou "rain"
local function SetAmbience()
    local wt=RandomStringFrom("THUNDER","RAIN")
    SetWeatherTypeNowPersist(wt)
end

-- não testado, o objetivo disso era quando um ped "não" zumbi fosse morto por um zumbi, consequentemente ele se levantaria como um zumbi
local function ReviveInPlace(ped)
    if DoesEntityExist(ped) and IsEntityDead(ped) then
        SetEntityHealth(ped, 3000) -- Definindo a vida para 3000
        SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false) -- Fazendo o ped simular ragdoll
        SetEntityInvincible(ped, false) -- Remove a invencibilidade
        SetPedConfigFlag(ped, 324, true) -- Configura o flag para o ped não entrar em veículos
    end
end

-- transforma o ped em zumbi
local function Zombify(ped)
    if not TableContains(zombifiedPeds,ped) then
        if HasClipSetLoaded("move_m@drunk@verydrunk") then
            SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1048576000)
        end
	-- define o comportamento do ped "zumbi"
        StopPedSpeaking(ped, true)
        DisablePedPainAudio(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedDiesInWater(ped,true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedConfigFlag(ped, 324, true)
        TaskGoToEntity(ped, PlayerPedId(), -1, 0, 0.1, 0.0, 0)
        SetPedKeepTask(ped, true)
        SetPedAsEnemy(ped, true)
        SetEntityMaxHealth(ped, 2000)
        SetEntityHealth(ped, 2000)

        ApplyPedDamagePack(ped, GetHashKey('BigHitByVehicle'), 0.0, 0.9)

	-- evento para os veículos ao redor, faz eles perderem o controle e baterem, ou explodirem ou morrerem no veiculo dependendo da probabilidade "Chance(probabilidade)"
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
        local idx=#zombifiedPeds
        zombifiedPeds[idx+1]=ped
    end
end

local function CreatePolicePatrols(playerPos, numPatrols, numPolicePerPatrol) --cria patrulhas policiais pelo mapa
    for i=1,RandomNumber(1,3) do
        if i == 2 or i == 3 then
            local spawnPosz=GetOffsetFromEntityInWorldCoords(PlayerPedId(),RandomNumber(1,5),RandomNumber(1,5),20)
			local groundz=GetGroundZ(spawnPosz)
			local waterz=GetWaterZ(spawnPosz)
			local canSpawn=false
            if type(groundz) == 'number' and type(waterz) == 'number' then
                if ground and not spawnPosz.z < waterz then
                    spawnPosz.z=groundz
                end
            end
            local patrolRadius = 100.0 -- Raio de busca das patrulhas
            local attackRadius = 50.0 -- Raio de ataque das patrulhas
            -- Criação das patrulhas
            if spawnPosz and spawnPosz ~= nil and canSpawn then
                for i = 1, numPatrols do
                    local patrolPosition = playerPos + vector3.new(math.random(-patrolRadius, patrolRadius), math.random(-patrolRadius, patrolRadius), 0.0)
                    local patrolVehicle = CreateVehicle(GetHashKey("police"), patrolPosition, 0.0, true, true)
                    if DoesEntityExist(patrolVehicle) and IsPointOnRoad(spawnPos.x,spawnPos.y,spawnPos.z,patrolVehicle) then
                        -- Adiciona policias ao veículo da patrulha
                        for j = 1, numPolicePerPatrol do
                            --local spawnPos = GetOffsetFromEntityInWorldCoords(patrolVehicle, math.random(-5.0, 5.0), math.random(-5.0, 5.0), 0.0)
                            local patrolPed = CreatePedInsideVehicle(patrolVehicle, 6, GetHashKey("s_m_y_cop_01"), -1, true, true)
                            nonZombiePeds[#nonZombiePeds+1] = patrolPed
                            for i,zomb in ipairs(zombifiedPeds) do
                                if zomb == patrolPed then
                                    zombifiedPeds[i]=nil
                                end
                            end
                            for i,pat in ipairs(nonZombiePeds) do
                                if IsEntityDead(pat,false) then
                                    local function DiesFromZombiePed(z)
                                        for i,ped in pairs(zombifiedPeds) do
                                            if GetPedSourceOfDeath(z) == ped then
                                                return true
                                            end
                                        end
                                        return false
                                    end
                                    if DiesFromZombiePed(ped) then
                                        SetEntityHealth(pat,4000)
                                    end
                                    nonZombiePeds[i]=nil
                                    Zombify(pat)
                                end
                            end
                            if DoesEntityExist(patrolPed) then
                                TaskCombatPed(patrolPed, PlayerPedId())
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


local function SPZombified() --cria zumbis aleatórios ao redor
    for z = 1, rnd(1, 3) do
        if CanCreateRandomPed(1) then
			local spawnPos=GetOffsetFromEntityInWorldCoords(PlayerPedId(),RandomNumber(1,5),RandomNumber(1,5),20)
			local groundz=GetGroundZ(spawnPos)
			local waterz=GetWaterZ(spawnPos)
			local canSpawn=false
			if z == 1 or z == 3 then
				if type(groundz) == 'number' and type(waterz) == 'number' then
					if ground and not spawnPos.z < waterz then
						spawnPos.z=groundz
					end
				end
			end
			if spawnPoint and spawnPoint ~= nil and canSpawn == true then
				local randZomb = CreateRandomPed(spawnPoint.x, spawnPoint.y, spawnPoint.z)
				if DoesEntityExist(randZomb) then
					print("spawned")
					Zombify(randZomb)
					SetEntityAsNoLongerNeeded(randZomb)
				end
			end
        end
		JM36.Wait(0)
    end
end
function tmOn()
    Settimera(0)
end

function zMod.tick()

	if OnKeyJustPressed("K") then --alterna o modo zumbi
		Started=not Started
		if Started then
            Once(SetAmbience)
			SetArtificialLightsState(true) --desliga as luzes artificiais do mapa (luzes de casas, carros, janelas de prédios,etc...)
			SetMaxWantedLevel(0)
			print("Z MODE ON")
		else
            
            ResetOnce(SetAmbience)
			SetArtificialLightsState(false)
			SetMaxWantedLevel(5)
			print("Z MODE OFF")
		end
	end
    if IsPlayerDead(PlayerPedId()) then
        OnceSet(Started,false)
    else
        if IsOnceSet("Started") and not IsPlayerDead(PlayerPedId()) then
            ResetOnceSet("Started")
        end
    end
    if Started then
        CreatePolicePatrols(GetEntityCoords(PlayerPedId(),nil),3,RandomNumber(1,3)) --cria patrulhas, não testei
        if not IsPlayerDead(PlayerId()) then
            if rnd(1, 5) == 1 then
                SPZombified()
            end
            SetPedDensityMultiplierThisFrame(0.0) --defina a densidade de peds,veiculos e "desativa" trens, acho eu
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetDisableRandomTrainsThisFrame(false)
		
            local nearByPeople = GetPedNearbyPeds(PlayerPedId(), 1500,-1)
            for _, ped in ipairs(nearByPeople) do
                local vehicle = GetVehiclePedIsIn(ped, false)
                if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                    local driver = GetPedInVehicleSeat(vehicle, -1)
                    if DoesEntityExist(driver) then
                        Zombify(driver)
                        local nearByPeople2 = GetPedNearbyPeds(driver, 300,-1)
                        local maxArrSize = #nearByPeople2 > 5 and 5 or #nearByPeople2
                        for j = 1, maxArrSize do --obtém peds próximos e transofrma em zumbis
                            if nearByPeople2[j] ~= PlayerPedId() and IsEntityAPed(nearByPeople2[j]) and not IsPedInGroup(nearByPeople2[j]) then
                                Zombify(nearByPeople2[j])
                            end
                            JM36.Wait(0)
                        end
                    end
                    SetVehicleEngineHealth(vehicle, 0)
                end

                if IsEntityAPed(ped) and not IsPedInGroup(ped) and IsPedHuman(ped) then --Aplica dano quando os zumbis estão proximos do jogador
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
                    Zombify(ped)
                    JM36.Wait(0)
                end
            end
        end
    end
end

function zMod.unload()
end

return zMod