---------------------------------------------------------------------------------------------
---- FAÇA BOM USO, ALGUMAS DESSAS FUNÇÕES NÃO FORAM TESTADAS E PODEM PRECISAR DE AJUSTES ---- M4G - meta4games
---------------------------------------------------------------------------------------------
--há uma implementação de um script de alguem que não sei o nome, mas fez as funções de tecla no final do script, não fui eu quem fiz--

local P_Notif = {}
local P_Notif_i = 1
function NotifyMsg(Text)
	for k in pairs(P_Notif) do 
		ThefeedRemoveItem(P_Notif[k])
	end
	
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(Text)
	P_Notif[P_Notif_i] = EndTextCommandThefeedPostTicker(false, true)
	P_Notif_i = P_Notif_i + 1
end

-- simula uma simples fisica de ragdoll -- apenas para peds/personagens
function SimpleRagdoll(ped,time1,time2,type)
    SetPedToRagdoll(ped,time1 or 1000,time2 or 1000,type or 1,false,false,false)
end

-- retorna um valor boleano aleatório
function RandomBool()
	math.randomseed(os.time())
	local a={true,false}
	local rnd=Clamp(RandomNumber(1,2),0,2)
	return a[rnd]
end

function GetNearestPed(ped)
    local nearbyPeds = GetPedNearbyPeds(ped,100,-1)
    local nearestPed = nil
    local nearestDistance = math.huge

    for _, pd in ipairs(nearbyPeds) do
        local pedPosition = GetEntityCoords(ped, false)
        local distance = #(position - pedPosition)
        if distance < nearestDistance then
            nearestPed = ped
            nearestDistance = distance
        end
    end

    return nearestPed
end


function RandomBoolByChance(chanceRate)
	local ch = Chance(chanceRate or 50)
	if ch then
		return true
	else
		return false
	end
end


function DebugTABLE(tbl, parentName, indent)
    parentName = parentName or "ROOT"
    indent = indent or 0
    for key, value in pairs(tbl) do
        local formattedKey = parentName .. " > " .. tostring(key)
        if type(value) == "table" then
            print(formattedKey)
            DebugTABLE(value, formattedKey, indent + 1)
        elseif type(value) == "function" then
            print(formattedKey .. " > "..type(value))
        else
            print(formattedKey .. " > " .. tostring(value) .. " > " .. type(value))
        end
    end
end

function DebugTABLE_onlyFunctions(tbl, parentName, indent)
	if type(tbl) == "table" then
		parentName = parentName or "ROOT"
		indent = indent or 0
		for key, value in pairs(tbl) do
			local formattedKey = parentName .. " > " .. tostring(key)
			if type(value) == "table" then
				DebugTABLE_onlyFunctions(value, formattedKey, indent + 1)
			elseif type(value) == "function" then
				print(formattedKey .. " > "..type(value))
			end
		end
	end
end

function DebugTABLE_find(tbl, parentName, indent, findName)
    parentName = parentName or "ROOT";
    indent = indent or 0;
    for key, value in pairs(tbl) do
        local formattedKey = parentName .. " > " .. tostring(key);
        -- Procurar por palavras semelhantes
        local pattern = "%w*" .. findName .. "%w*";
        if strfind(strlower(key), strlower(pattern)) then
            print(formattedKey .. " > " .. tostring(value).."   Type:   "..type(value));
        end
        if type(value) == "table" then
			local check=function(ss)
                if type(ss) == "table" then
                    for i=1,getn(ss) do
                        return type(ss[i]) == "table";
                    end
                end
                return false;
			end;
			if check(value) == true then
				DebugTABLE_find(value, formattedKey, indent + 1, findName);
			end
        end
    end
end

function MultiDebugTABLE(valuesTable)
	for i,tbl in ipairs(valuesTable) do
		DebugTABLE(tbl)
	end
end

function CheckValueExistence(valuesTable)
	if type(valuesTable) == "table" then
		for i,val in ipairs(valuesTable) do
			print("INDEX:  "..i.."   Value:  "..val.."    type:  "..type(val))
		end
	else
		print("VALUE:  "..valuesTable.."  TYPE:  "..type(valuesTable))
	end
end

--[[

function AngleToVector(rotation)
    local z = math.rad(rotation.z)
    local x = math.rad(rotation.x)
    local num = math.abs(math.cos(x))

    return vector3.new(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function GetCamForwardVector(cam)
	local force = 5
    local CamRot = GetGameplayCamRot(2)
    -- Converter ângulos de rotação em radianos
    local Fx = -( math.sin(math.rad(CamRot.z)) * force*10 )
	local Fy = ( math.cos(math.rad(CamRot.z)) * force*10 )
	local Fz = force * (CamRot.x*0.2)
    
    return vector3.new(Fx, Fy, Fz)
end

function test()
	if OnKeyPressed("Q") then
		local cam = GetRenderingCam()
		local pos = GetEntityCoords(PlayerPedId(), nil)
		local CamRot = GetGameplayCamRot(2)

		local force = 5

		local Fx = -( math.sin(math.rad(CamRot.z)) * force*10 )
		local Fy = ( math.cos(math.rad(CamRot.z)) * force*10 )
		local Fz = force * (CamRot.x*0.2)

		local forward=vector3.new(Fx,Fy,Fz) * force

		local targetPos = -forward * 5
		
		local peds = GetPedNearbyPeds(PlayerPedId(), 300, -1)
		local vehicles = GetPedNearbyVehicles(PlayerPedId(), 300)

		for i, ped in ipairs(peds) do
			if GetDistance(PlayerPedId(),ped) then
				ApplyForceToEntity(ped, 1, targetPos.x, targetPos.y, targetPos.z, 0, 0, 0, false, false, true, false, false, true)
			end
		end

		for i, veh in ipairs(vehicles) do
			if GetDistance(PlayerPedId(),veh) then
				ApplyForceToEntity(veh, 1, targetPos.x, targetPos.y, targetPos.z, 0, 0, 0, false, false, true, false, false, true)
			end
		end
	end
end
]]

function GetDistance(a,b)
	local pos1,pos2 = GetEntityCoords(a,nil),GetEntityCoords(b,nil)
	return GetDistanceBetweenCoords(pos1.x,pos1.y,pos1.z,pos2.x,pos2.y,pos2.z,false)
end

function GetGroundZ(position,groundOffset)
	local retval , groundZ = GetGroundZFor3dCoord(position.x,position.y,position.z,groundOffset or 1)
	if retval and groundZ then
		return groundZ
	else
		return nil
	end
end

function GetWaterZ(position,waterOffset)
	local retval, height =GetWaterHeightNoWaves(position.x,position.y,position.z,waterOffset or 1)
	local val = 0
	if retval and height then
		val = height
		return val
	else
		return nil
	end
end

-- Move a entidade em uma direção --não testado
function MoveEntity(entity, direction, speed)
	if entity and direction and speed then
		local currentPosition = GetEntityCoords(entity)
		local newPosition = {
			x = currentPosition.x + direction.x * speed,
			y = currentPosition.y + direction.y * speed,
			z = currentPosition.z + direction.z * speed
		}
		SetEntityCoords(entity, newPosition.x, newPosition.y, newPosition.z, false, false, false, false)
	end
end

-- Move a entidade para a posição desejada --não testado
function MoveEntityTo(entity, targetPosition, interpolate, speed)
	if entity and targetPosition then
		if interpolate then
			while true do
				local currentPosition = GetEntityCoords(entity)
				local distance = Vdist(currentPosition.x, currentPosition.y, currentPosition.z, targetPosition.x, targetPosition.y, targetPosition.z)
				if distance < 0.5 then
					break
				end
				local direction = {
					x = (targetPosition.x - currentPosition.x) / distance,
					y = (targetPosition.y - currentPosition.y) / distance,
					z = (targetPosition.z - currentPosition.z) / distance
				}
				MoveEntity(entity, direction, speed)
				Wait(0)
			end
		else
			SetEntityCoordsNoOffset(entity, targetPosition.x, targetPosition.y, targetPosition.z, false, false, false)
		end
	end
end

function RandomNumber(a,b)
	math.randomseed(os.time())
	if a and b then
		return math.floor(math.random(a,b))
	elseif a then
		return math.floor(math.random(a))
	else
		return math.floor(math.random())
	end
end

function RandomNumberByChance(a,b,numChance)
	if Chance(numChance) then
		return b
	else
		return a
	end
end

-- executa uma função aleatória das recebidas na função, exemplo: RandomFunction(funcao1,funcao2,funcao3) resultado> escolhe uma função aleatória e a executa retornando o resultado
function RandomFunction(...)
	local tb = {...}
	local rnd = RandomNumber(1,TableCount(tb))
	if IsFunction(tb[rnd]) then
		return tb[rnd]()
	else
		GLog("RandomFunction(): Valores recebidos não são funções")
		return nil
	end
end

-- função para estados de uma execução, use: Onde(funcao1), resultado: executa uma vez apenas, use ResetOnce() com o nome da função usada no once para resetar
local onceStates = {}
function Once(func,args)
    if not onceStates[func] and IsFunction(func) then
		if args ~= nil then
			func(args)
			onceStates[func] = true
		else
			func()
			onceStates[func] = true
		end
    end
end

local onceVarsStates = {}

function OnceSet(var, value)
    if not onceVarsStates[var] then
        onceVarsStates[var] = value
    end
end

function ResetOnceSet(var)
    if onceVarsStates[var] == true then
        onceVarsStates[var] = false
    end
end

function IsOnceSet(var)
    return onceVarsStates[var]
end

function DebugTABLE(tbl, parentName, indent)
    parentName = parentName or "ROOT"
    indent = indent or 0
    for key, value in pairs(tbl) do
        local formattedKey = parentName .. " > " .. tostring(key)
        if type(value) == "table" then
            print(formattedKey .. " > "..type(value))
            DebugTABLE(value, formattedKey, indent + 1)
        else
            print(formattedKey .. " > " .. tostring(value).." > "..type(value))
        end
    end
end


-- verifica se a função ja foi executada
function IsOnce(func)
	if onceStates[func] then
		return onceStates[func] == true
	end
	return false
end

-- reseta a função se ja foi executada com Once()
function ResetOnce(func)
	if onceStates[func] then
    	onceStates[func] = false
	end
end

-- retorna uma string aleatória
function RandomStringFrom(...)
	local str={...}
	local rnd=Clamp(RandomNumber(0,TableCount(str)),0,TableCount(str))
	return tostring(str[rnd])
end

-- alterna entre duas strings de acordo com o boleano
function SwitchStrings(stringA,stringB,bol)
	if stringA ~= "" and stringB ~= "" and bol ~= nil then
		if bol == true then
			return stringB
		else
			return stringA
		end
	end
end

-- funções de chaves --não foi criado por mim
--como usar: essas funções como "OnKeyJustPressed()" precisam de um argumento de string, a sua função é obter o código da chave com uma string e verificar se foi pressionada
--todas as variaveis de keys.lua, use seus nomes para se referir a uma tecla, exemplo: "Keys.E" OnKeyPressed("E"), apenas o nome da variavel e o resultado vai retornar se a tecla foi pressionada
local pKeys = {[65535] = false, [65536] = false, [131072] = false, [262144] = false, [-65536] = false}

for i = 0, 254 do
	pKeys[i] = false
end

-- retorna se a tecla "key" foi pressionada, apenas pressionada
function OnKeyJustPressed(key)
	if get_key_pressed(Keys[key]) then
		if pKeys[Keys[key]] == false then
			pKeys[Keys[key]] = true
			return true
		end
	elseif pKeys[Keys[key]] == true then
		pKeys[Keys[key]] = false
	end
end
-- retorna se a tecla "key" foi solta, apenas solta
function OnKeyJustReleased(key)
	if get_key_pressed(Keys[key]) then
		if pKeys[Keys[key]] == false then
			pKeys[Keys[key]] = true
		end
	elseif pKeys[Keys[key]] == true then
		pKeys[Keys[key]] = false
		return true
	end
end
-- retorna se a tecla "key" estiver sendo pressionada
function OnKeyPressed(key)
	if get_key_pressed(Keys[key]) then
		if pKeys[Keys[key]] == false then
			pKeys[Keys[key]] = true
		else
			return true
		end
	elseif pKeys[Keys[key]] == true then
		pKeys[Keys[key]] = false
	end
end
-- retorna se a tecla "key" estiver solta
function OnKeyReleased(key)
	if get_key_pressed(Keys[key]) then
		if pKeys[Keys[key]] == false then
			pKeys[Keys[key]] = true
		end
	elseif pKeys[Keys[key]] == true then
		pKeys[Keys[key]] = false
	else
		return true
	end
end
-- retorna o status da tecla, mais usado para debug do código
function GetKeyStatus(key)
	if get_key_pressed(Keys[key]) then
		if pKeys[Keys[key]] == false then
			pKeys[Keys[key]] = true
			return "key "..key.." just pressed"
		else
			return "key "..key.." pressed"
		end
	elseif pKeys[Keys[key]] == true then
		pKeys[Keys[key]] = false
		return "key "..key.." just released"
	else
		return "key "..key.." released"
	end
end


local _pKeys = {}
--[[
function _pKeys.init()
end

function _pKeys.tick()
end

function _pKeys.unload()
end
]]
return _pKeys
