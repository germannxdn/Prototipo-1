Estado = require "estados.estado"

EstadoMuriendo = Class{__includes = Estado}


function EstadoMuriendo:init()

    self.jugador = nil
    self.trampa = nil
    self.maquina = nil
    self.sueloY = nil

end


function EstadoMuriendo:ingresar(parametros)

    self.jugador = parametros.jugador
    self.trampa = parametros.trampa
    self.maquina = parametros.maquina
    self.sueloY = parametros.sueloY

    self.jugador.muriendo = true

    self.trampa.frame = 1
    self.trampa.tiempoAnimacion = 0
end


function EstadoMuriendo:salir()

end


function EstadoMuriendo:actualizar(dt)

    self.trampa.tiempoAnimacion =
        self.trampa.tiempoAnimacion + dt


    if self.trampa.tiempoAnimacion >=
       self.trampa.velocidadAnimacion then

        self.trampa.tiempoAnimacion = 0

        self.trampa.frame =
            self.trampa.frame + 1


        if self.trampa.frame >
           #self.trampa.animacion then

            self.trampa.frame =
                #self.trampa.animacion

            self.jugador.muriendo = false
            self.jugador.muerto = true

            self.maquina:cambiar(
                "muerto",
                {
                    jugador = self.jugador,
                    trampa = self.trampa,
                    sueloY = self.sueloY,
                    maquina = self.maquina
                }
            )

        end

    end

end


function EstadoMuriendo:dibujar()
self.trampa:dibujar(self.sueloY)
end


return EstadoMuriendo