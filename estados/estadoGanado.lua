Estado = require "estados.estado"

EstadoGanado = Class{__includes = Estado}


function EstadoGanado:init()

    self.jugador = nil
    self.maquina = nil

end


function EstadoGanado:ingresar(parametros)

    self.jugador = parametros.jugador
    self.maquina = parametros.maquina

    self.jugador.gano = true

end


function EstadoGanado:salir()

end


function EstadoGanado:actualizar(dt)

end


function EstadoGanado:dibujar()

    self.jugador:dibujar()

    love.graphics.print(
        "HAS ESCAPADO",
        340,
        250
    )

    love.graphics.print(
        "Has logrado atravesar la zona.",
        300,
        280
    )

    love.graphics.print(
        "Presiona R para jugar nuevamente",
        270,
        310
    )

end


return EstadoGanado