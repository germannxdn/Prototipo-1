local Signal = require "lib.signal"

local Eventos = {}

function Eventos.registrar(nombre, callback)
    return Signal.register(nombre, callback)
end

function Eventos.emitir(nombre, ...)
    Signal.emit(nombre, ...)
end

function Eventos.quitar(nombre, callback)
    Signal.remove(nombre, callback)
end

return Eventos