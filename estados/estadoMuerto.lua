Estado = require "estados.estado"

EstadoMuerto = Class{__includes = Estado}


function EstadoMuerto:init()

    self.jugador = nil
    self.trampa = nil
    self.sueloY = nil

end


function EstadoMuerto:ingresar(parametros)

    self.jugador = parametros.jugador
    self.trampa = parametros.trampa
    self.sueloY = parametros.sueloY

    self.jugador.muerto = true

end


function EstadoMuerto:salir()

end


function EstadoMuerto:actualizar(dt)

end


function EstadoMuerto:dibujar()

    self.trampa:dibujar(self.sueloY)

    love.graphics.print(
        "HAS MUERTO",
        350,
        250
    )

    love.graphics.print(
        "Las profundidades te han reclamado...",
        280,
        280
    )

    love.graphics.print(
        "Presiona R para intentarlo nuevamente",
        270,
        310
    )

end


return EstadoMuerto