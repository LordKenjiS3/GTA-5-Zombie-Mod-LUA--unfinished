---------------------------------------------------------------------------------------------
---------- FAÇA BOM USO, ESSAS FUNÇÕES FORAM TESTADAS MAS PODEM PRECISAR DE AJUSTES --------- M4G - meta4games
---------------------------------------------------------------------------------------------
--essas são funções para criar e manipular variaveis de uma forma mais flexivel, basta você criar uma variavel com NewVar ou uma subVariavel com NewSubVar
--e manipular essas funções com:SetVar(),GetVar(),SetSubVar(),GetSubVar(),DeleteVar(),DeleteSubVar(),FindVar() e ToggleVar()
--Divirta-se! ==META-4-GAMES==

-- função para criar um arquivo de log em formato de texto e inserir nele a mensagem junto da data e hora
function Glog(message)
    local scriptDirectory = arg[0]:match("(.*[/\\])")
    if scriptDirectory then
        local logFilePath = scriptDirectory .. "Log.txt"
        local file = io.open(logFilePath, "a")
        local parentDirectory = scriptDirectory:match("(.-)[/\\][^/\\]*[/\\]?$")
        while not file and parentDirectory do
            logFilePath = parentDirectory .. "Log.txt"
            file = io.open(logFilePath, "a")
            parentDirectory = parentDirectory:match("(.-)[/\\][^/\\]*[/\\]?$")
        end
        if file then
            file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
            print(message)
            file:close()
        else
            print("Erro ao abrir o arquivo de log.")
        end
    else
        print("Não foi possível obter o diretório do script.")
    end
end

--tabela das variaveis
_global_vars = {}

--Cria uma nova variavel
function NewVar(name, value)
    _global_vars[name] = value
end
-- Cria uma nova sub-variavel
function NewSubVar(var_name, sub_var_name, value)
    if _global_vars[var_name] == nil then
        _global_vars[var_name] = {}
    end
    _global_vars[var_name][sub_var_name] = value
end
--Modifica a variavel
function SetVar(name, value)
    if _global_vars[name] then
        _global_vars[name] = value
    end
end
-- Modifica a sub-variavel
function SetSubVar(var_name, sub_var_name, value)
    if _global_vars[var_name] ~= nil then
        _global_vars[var_name][sub_var_name] = value
    end
end
--Obtém a variavel
function GetVar(name)
    return _global_vars[name]
end
--Obtém a sub-variavel
function GetSubVar(var_name, sub_var_name)
    if _global_vars[var_name] ~= nil then
        return _global_vars[var_name][sub_var_name]
    end
end
-- Procura pela variavel e retorna uma tabela com finded(bool),tbl(table) e val(value)
function FindVar(name)
    local result={finded=false,tbl=nil,val=nil}
    for key, value in pairs(_global_vars) do
        if key == name then
            result.finded=true
            result.tbl=_global_vars
            result.val=_global_vars[key]
            return result
        elseif type(value) == "table" then
            for sub_key, sub_value in pairs(value) do
                if sub_key == name then
                    result.finded=true
                    result.tbl=value
                    result.val=value[sub_key]
                    return result
                end
            end
        end
    end
    return result
end
-- Alterna uma variavel entre verdadeiro ou falso
function ToggleVar(name)
    local fnd = FindVar(name)
    if fnd.finded then
        fnd.tbl[name] = not fnd.tbl[name]
    end
end
-- deleta uma variavel
function DeleteVar(name)
    _global_vars[name] = nil
end
-- deleta uma sub-variavel
function DeleteSubVar(var_name, sub_var_name)
    if _global_vars[var_name] ~= nil then
        _global_vars[var_name][sub_var_name] = nil
    end
end