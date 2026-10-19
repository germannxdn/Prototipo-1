
Estado = require "estados.estado"

EstadoMuerto = Class{__includes = Estado}

function EstadoMuerto:init()
    self.jugador = nil
    self.trampa = nil
end

function EstadoMuerto:ingresar(parametros)
    self.jugador = parametros.jugador
    self.trampa = parametros.trampa

    self.jugador.muerto = true
end

function EstadoMuerto:salir()
end

function EstadoMuerto:actualizar(dt)
end

function EstadoMuerto:dibujar()
    -- Dibujar la trampa solo si la muerte
    -- fue causada por una trampa.
    if self.trampa then
        self.trampa:dibujar()
    end
end

return EstadoMuerto
