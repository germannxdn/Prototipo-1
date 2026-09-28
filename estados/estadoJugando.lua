Estado = require "estados.estado"

EstadoJugando = Class{__includes = Estado}


function EstadoJugando:init()

    self.jugador = nil
    self.trampas = {}
    self.sueloY = nil
    self.maquina = nil
    self.mundo = nil
    self.paredDerecha = nil

end


function EstadoJugando:ingresar(parametros)

    self.jugador = parametros.jugador
    self.trampas = parametros.trampas
    self.sueloY = parametros.sueloY
    self.maquina = parametros.maquina
    self.mundo = parametros.mundo
    self.paredDerecha = parametros.paredDerecha
end


function EstadoJugando:salir()

end


function EstadoJugando:actualizar(dt)

    -- ================= JUGADOR =================

    self.jugador:actualizar(dt, self.mundo)


    -- ================= TRAMPA =================

    for _, trampa in ipairs(self.trampas) do
    trampa:actualizar(dt)
end


    -- ================= COLISION =================

for _, trampa in ipairs(self.trampas) do

    if HayColision(
        self.jugador,
        trampa
    ) then

        trampa:activar()

        self.jugador.velocidadY = 0

        self.maquina:cambiar(
            "muriendo",
            {
                jugador = self.jugador,
                trampa = trampa,
                maquina = self.maquina
            }
        )

        return
    end

end


    -- ================= GANAR =================

    if self.jugador.x + self.jugador.ancho >= self.paredDerecha.x then

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

    for _, trampa in ipairs(self.trampas) do
    trampa:dibujar()
end
    self.jugador:dibujar()

end


return EstadoJugando