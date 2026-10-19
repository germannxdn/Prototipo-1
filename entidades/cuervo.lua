
Class = require "lib.class"

Cuervo = Class{}

function Cuervo:init()
    self.x = 0
    self.y = 0

    self.ancho = 80
    self.alto = 25
    self.velocidad = 260

    self.activo = false
    self.aparecio = false
    self.terminado = false

    self.spritesheet = nil
    self.animacion = {}
    self.frame = 1
    self.tiempoAnimacion = 0
    self.velocidadAnimacion = 0.09
end

function Cuervo:iniciar(x, y)
    if self.aparecio then return end

    self.x = x
    self.y = y

    self.activo = true
    self.aparecio = true
    self.frame = 1
    self.tiempoAnimacion = 0
end

function Cuervo:actualizar(dt, jugador)
    if not self.activo then return false end

    -- Animación de vuelo
    self.tiempoAnimacion = self.tiempoAnimacion + dt

    if self.tiempoAnimacion >= self.velocidadAnimacion then
        self.tiempoAnimacion = 0
        self.frame = self.frame + 1

        if self.frame > #self.animacion then
            self.frame = 1
        end
    end

    -- Vuelo constante hacia la izquierda
    self.x = self.x - self.velocidad * dt

    -- Colisión: solo mata si el jugador está de pie
    if not jugador.agachado
    and not jugador.muerto
    and not jugador.muriendo
    and not jugador.gano then

        local colision =
            self.x < jugador.x + jugador.ancho
            and self.x + self.ancho > jugador.x
            and self.y < jugador.y + jugador.alto
            and self.y + self.alto > jugador.y

        if colision then
            return true
        end
    end

    -- El cuervo desaparece al salir de la zona
    if self.x + self.ancho < 0 then
        self.activo = false
        self.terminado = true
    end

    return false
end

function Cuervo:dibujar()
    if not self.activo or #self.animacion == 0 then return end

    local _, _, anchoFrame, altoFrame =
        self.animacion[self.frame]:getViewport()

    -- Mantiene las proporciones originales del sprite
    local escala = self.ancho / anchoFrame

    love.graphics.draw(
        self.spritesheet,
        self.animacion[self.frame],
        self.x,
        self.y,
        0,
        escala,
        escala
    )
end

function Cuervo:reiniciar()
    self.x = 0
    self.y = 0

    self.activo = false
    self.aparecio = false
    self.terminado = false

    self.frame = 1
    self.tiempoAnimacion = 0
end

return Cuervo
