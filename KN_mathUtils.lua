-- Check if is a 2DVector
function Is2DVector(val) 
    return IsTable(val) and TableCount(val) == 2 and val ~= nil or nil
end
-- Check if a vector
function IsVector(val) 
    return IsTable(val) and TableCount(val) == 3 and val ~= nil or nil 
end
-- Check if is an Function
function IsFunction(val)
    return type(val) == "function" 
    end
-- Check if is Number
function IsNumber(val) 
    return type(val) == 'number' and val ~= nil and val == math.floor(val) or nil 
end
-- Check if is string
function IsString(val)
    return type(val) == 'string' and val ~= nil or nil 
end
-- Check if is boolean
function IsBool(val) 
    return type(val) == "boolean" and val ~= nil or nil 
end
-- Check if is float
function IsFloat(val) 
    return type(val) == 'number' and val ~= nil or nil 
end
-- Check if is table
function IsTable(val) 
    return type(val) == 'table' and val ~= nil or nil 
end
-- Numero flutuante aleatório entre 'a' e 'b'
function RandomFloat(a, b) 
    if a and b then
        math.randomseed(os.time())
        return a + math.random() * (b - a)
    end
end
-- Numero aleatório entre 'a' e 'b'
function RandomNumber(a, b)
    if a and b then
        math.randomseed(os.time())
        return math.random(a, b)
    end
end
-- Item aleatório de 'tab'
function RandomTableItem(tab)
    local rnd = RandomNumber(1, TableCount(tab)) 
    return tab[rnd] 
end
-- Clamp Number
function Clamp(a, b, c) 
    return math.min(math.max(a, b), c) 
end
-- Clamp To up
function ClampUp(a,b)
    if a > b then
        a = b
    end
    return a
end
-- Clamp To Down
function ClampDown(a,b)
    if a < b then
        a = b
    end
    return a
end
-- Função para calcular a diferença entre dois valores (números ou tabelas tridimensionais)
function GetDifer(a, b) 
    return math.abs(a - b) 
end
-- Calcula a chance pela probabilidade, se a chance for maior que a probabilidade recebida, retorna true
function Chance(probability)
    if type(probability) == "number" and probability >= 0 and probability <= 100 then
        math.randomseed(os.time())
        local randomValue = math.random(100 - probability + 1)
        return randomValue == 1
    end
    return false
end

-- Verifica se a tabela contém 'value'
function TableContains(tbl, value)
    for i, val in ipairs(tbl) do
        if val == value then
            return true
        elseif tbl[i] == value then
            return true
        end
    end
    return false
end
-- Faz todos os index da tabela como numéricos
function TableToIndex(tbl)
    local idx = {}
    for i,val in pairs(tbl) do
        idx[i]=val
    end
    return idx
end
-- Obtém o número de elementos na tabela
function TableCount(tbl)
    if IsTable(tbl) then
        local count = 0
        for _ in ipairs(tbl) do
            count = count + 1
        end
        return count
    end
end
-- Obtem o item correspondente na tabela
function TableGetItem(tbl, value)
    for i, val in ipairs(tbl) do
        if val == value then
            return val
        elseif val == tbl[value] then
            return val
        else
            GLog("TableGetItem(): Não foi possível obter o valor " .. (value or "vazio"))
            return nil
        end
    end
end

-- obtem a diferença entre dois vetores
function GetVecDif(vec1,vec2)
    local a = vec1
    local b = vec2
    local c ={x=0,y=0,z=0}
    c.x = a.x - b.x
    c.y = a.y - b.y
    c.z = a.z - b.z
    return c
end

-- Verifica se a tabela está vazia
function TableIsEmpty(tbl)
    return TableCount(tbl) == 0 or tbl == nil
end
-- Função para interpolar linearmente entre dois valores
function lerp(start, finish, speed)return start + (finish - start) * speed end -- não ta funcionando muito certo

