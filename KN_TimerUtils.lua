local timers = {}

function StartTimerA(value)
    if value ~= nil and type(value) == 'number' then
       Settimera(value)
    end
end

function StartTimerB(value)
    if value ~= nil and type(value) == 'number' then
       Settimerb(value)
    end
end

function GetTimerA()
    return Timera()
end

function GetTimerB()
    return Timerb
end