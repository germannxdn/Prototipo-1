Estado = require "estados.estado"

EstadoJugando = Class{__includes = Estado}


function EstadoJugando:init()

    self.jugador = nil
    self.trampa = nil
    self.sueloY = nil
    self.maquina = nil

end


function EstadoJugando:ingresar(parametros)

    self.jugador = parametros.jugador
    self.trampa = parametros.trampa
    self.sueloY = parametros.sueloY
    self.maquina = parametros.maquina

end


function EstadoJugando:salir()

end


function EstadoJugando:actualizar(dt)

    -- ================= JUGADOR =================

    self.jugador:actualizar(
        dt,
        self.sueloY
    )


    -- ================= TRAMPA =================

    self.trampa:actualizar(dt)


    -- ================= COLISION =================

    if HayColision(
    self.jugador,
    self.trampa
) then

    self.trampa:activar()

    self.jugador.velocidadY = 0

    self.maquina:cambiar(
        "muriendo",
        {
            jugador = self.jugador,
            trampa = self.trampa,
            sueloY = self.sueloY,
            maquina = self.maquina
            
        }
    )

    return

end


    -- ================= GANAR =================

    if self.jugador.x + self.jugador.ancho >= 800 then

    self.maquina:cambiar(
        "ganado",
        {
            jugador = self.jugador,
            trampa = self.trampa,
            maquina = self.maquina
        }
    )

    return

end

end


function EstadoJugando:dibujar()

    self.trampa:dibujar(self.sueloY)
    self.jugador:dibujar()

end


return EstadoJugando