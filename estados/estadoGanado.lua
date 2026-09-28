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

end


return EstadoGanado