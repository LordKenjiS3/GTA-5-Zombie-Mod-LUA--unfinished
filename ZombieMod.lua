local zMod = {}
local ZManager = {
    Weapons = {
        453432689, 2634544996, 4024951519, 736523883, 2578377531, 1317494643,
        1593441988, 2227010557, 615608432, 3125143736, 2024373456, 1141786504,
        324215364, 2982836145, 1924557585, 3347935668, 177293209, 3441901897,
        317205821, 3249783761, 1649403952, 4019527611, 3675956304, 2636060646,
        94989220, 2285322324, 2481070269, 3800352039, 2640438543, 2017895192,
        487013001, 487013001, 2634544996, 2937143193, 100416529, 2726580491,
    },
    Timers={},
    Zombies = {},
    Survivors = {},
    BlackoutMode = true,
    ZModOn = false,
}
local z,s,mod,tms=ZManager.Zombies,ZManager.Survivors,ZManager.ZModOn,ZManager.Timers

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
        SetPedAsEnemy(ped, true)
        SetEntityMaxHealth(ped, 4000)
        SetEntityHealth(ped, 4000)
        SetPedAlertness(ped, 0)
        ApplyPedDamagePack(ped, GetHashKey("BigHitByVehicle"), 0.0, 0.9)
        ApplyPedDamagePack(ped, GetHashKey("SCR_Torture"), 0.0, 0.9)
        ApplyPedDamagePack(ped, GetHashKey("SCR_Dumpster"), 0.0, 0.9)
        SetEntityAsNoLongerNeeded(ped)
        z[TableCount(z)+1]=ped
    end
end

local function addTmr(name,value,started)
    if name ~= "" then
        tms[name]={
            start=started and type(started) == "boolean" or false,
            counter=value and type(value) == "number" or 0
        }
    end
end

local function getTmrCounter(name)
    if tms[name] then
        return tms[name].counter
    end
end

local function deleteTmr(name)
    if tms[name] then
        rms[name] = nil
    end
end

local function MakeSurvivor(ped)
    SetEntityMaxHealth(ped,500)
    SetEntityHealth(ped,500)
    SetEntityAsNoLongerNeeded(ped)
    s[TableCount(s)+1]=ped
end

local function IsZombie(ped)
    return z[ped] ~= nil
end

local function IsSurvivor(ped)
    return s[ped] ~= nil
end

local function UpdateSZ()
    local peds=GetPedNearbyPeds(PlayerPedId(),2000,-1)
    local vehicles=GetPedNearbyVehicles(PlayerPedId(),2000)

    for i,ped in ipairs(peds) do
        if not IsZombie(ped) and not IsSurvivor(ped) then
            if RandomNumber(1,7) ==5 then
                MakeSurvivor(ped)
            else
                MakeZombie(ped)
            end
        end
    end

    for i,vehicle in ipairs(vehicles) do
        if GetVehicleNumberOfPassengers(vehicle,-1) == 0 then
            if Chance(60) then
                SetVehicleAlarm(vehicle,true)
            end
        end
    end
end

function zMod.init()
    
end

function zMod.tick()
    for _,timer in ipairs(tms) do
        if timer.start == true then
            timer=timer+0.001
        else
            timer=0
        end
    end
    if OnKeyJustPressed("K") then
        mod = not mod
        if mod == true then
            SetMaxWantedLevel(0)
            SetArtificialLightsState(false)
            SetPoliceIgnorePlayer(PlayerPedId(),true)
            SetWeatherTypeNowPersist(RandomStringFrom("RAIN","THUNDER"))
        else
            SetPoliceIgnorePlayer(PlayerPedId(),false)
            SetMaxWantedLevel(5)
            SetArtificialLightsState(true)
            SetWeatherTypeNowPersist(RandomStringFrom("CLEAR","DAY"))
        end
    end

    if mod then
        UpdateSZ()
    end
end