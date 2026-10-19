Estado = require "estados.estado"

EstadoJugando = Class{__includes = Estado}


function EstadoJugando:init()

    self.jugador = nil
    self.trampas = {}
    self.sueloY = nil
    self.maquina = nil
    self.mundo = nil
    self.paredDerecha = nil
    self.cuervo = nil
    self.xActivacionCuervo = 1200
    self.alturaVueloCuervo = 0
end


function EstadoJugando:ingresar(parametros)

    self.jugador = parametros.jugador
    self.trampas = parametros.trampas
    self.sueloY = parametros.sueloY
    self.maquina = parametros.maquina
    self.mundo = parametros.mundo
    self.paredDerecha = parametros.paredDerecha
    self.cuervo = parametros.cuervo
    self.xActivacionCuervo = parametros.xActivacionCuervo or 1200
    self.alturaVueloCuervo =
    parametros.alturaVueloCuervo or (self.sueloY - 110)
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

-- ================= CUERVO =================
-- El cuervo aparece una sola vez al superar la segunda trampa
if self.cuervo
and not self.cuervo.aparecio
and self.jugador.x >= self.xActivacionCuervo then

    self.cuervo:iniciar(
        self.jugador.x + love.graphics.getWidth() / 2,
        self.alturaVueloCuervo
    )
end

-- Actualizar el cuervo y detectar el impacto
if self.cuervo then
    local impacto = self.cuervo:actualizar(dt, self.jugador)

    if impacto then
        Eventos.emitir("jugador-muere")

        self.maquina:cambiar("muriendo", {
            jugador = self.jugador,
            maquina = self.maquina
        })

        return
    end
end

    -- ================= COLISION =================

for _, trampa in ipairs(self.trampas) do

    if HayColision(
        self.jugador,
        trampa
    ) then

        trampa:activar()

        self.jugador.velocidadY = 0

        Eventos.emitir("jugador-muere")

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

    if self.cuervo then
        self.cuervo:dibujar()
    end

    self.jugador:dibujar()
end


return EstadoJugando