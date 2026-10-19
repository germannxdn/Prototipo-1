Class = require "lib.class"

Jugador = Class{}

function Jugador:init(x, y)
    self.x = x
    self.y = y

    self.ancho = 64
    self.alto = 64

    -- Agachado
self.altoNormal = 64
self.altoAgachado = 36
self.agachado = false
self.spriteAgachado = nil

    self.vel = 200
    self.velSalto = 500

    self.gravedad = 1000
    self.velocidadY = 0
    self.estaEnSuelo = false

    self.muerto = false
    self.muriendo = false
    self.gano = false

    self.sprite = nil
    self.spritesheetCorrer = nil

    self.mirandoDerecha = true

    self.animCorrer = {}
    self.frameCorrer = 1
    self.tiempoAnimacion = 0
    self.velocidadAnimacion = 0.10

    self.corriendo = false
    
end
function Jugador:actualizar(dt, mundo)

-- Estado de agachado
local quiereAgacharse = love.keyboard.isDown("down")

if quiereAgacharse and not self.agachado then
    self.agachado = true

    -- Mantener los pies en el mismo lugar
    self.y = self.y + (self.altoNormal - self.altoAgachado)
    self.alto = self.altoAgachado

    mundo:update(self, self.x, self.y, self.ancho, self.alto)

elseif not quiereAgacharse and self.agachado then
    self.agachado = false

    self.y = self.y - (self.altoNormal - self.altoAgachado)
    self.alto = self.altoNormal

    mundo:update(self, self.x, self.y, self.ancho, self.alto)
end

-- Movimiento horizontal
local movimientoX = 0

if not self.agachado then
    if love.keyboard.isDown("left") then
        movimientoX = -self.vel * dt
        self.mirandoDerecha = false
    end

    if love.keyboard.isDown("right") then
        movimientoX = self.vel * dt
        self.mirandoDerecha = true
    end
end

-- Gravedad

self.velocidadY =
    self.velocidadY + (self.gravedad * dt)


-- Movimiento total

local nuevaX =
    self.x + movimientoX

local nuevaY =
    self.y + (self.velocidadY * dt)


local x, y, cols, len =
    mundo:move(
        self,
        nuevaX,
        nuevaY
    )


self.x = x
self.y = y


-- Colisiones verticales
self.estaEnSuelo = false
for i = 1, len do

    local col = cols[i]

    if col.normal.y == -1 then
        self.velocidadY = 0
        self.estaEnSuelo = true
    end

end


    -- Animación de correr
    self.corriendo =
        love.keyboard.isDown("left")
        or love.keyboard.isDown("right")

    if self.corriendo then
        self.tiempoAnimacion =
            self.tiempoAnimacion + dt

        if self.tiempoAnimacion >= self.velocidadAnimacion then
            self.tiempoAnimacion = 0
            self.frameCorrer = self.frameCorrer + 1

            if self.frameCorrer > #self.animCorrer then
                self.frameCorrer = 1
            end
        end
    else
        self.frameCorrer = 1
        self.tiempoAnimacion = 0
    end
end

function Jugador:saltar()
    if self.agachado then return end

    self.velocidadY = -self.velSalto
end


function Jugador:reiniciar(x, y)

    self.x = x
    self.y = y

    self.muerto = false
    self.muriendo = false
    self.gano = false

    self.mirandoDerecha = true

    self.frameCorrer = 1
    self.tiempoAnimacion = 0

    self.velocidadY = 0
    self.estaEnSuelo = false

    self.corriendo = false

    self.agachado = false
    self.alto = self.altoNormal

end

function Jugador:dibujar()

    -- El jugador no se dibuja si está muriendo o muerto

    if self.muriendo or self.muerto then
        return
    end

    -- Dibujar al jugador agachado
if self.agachado then
    local escala = 64 / self.spriteAgachado:getWidth()
    local altoDibujo =
        self.spriteAgachado:getHeight() * escala

    love.graphics.draw(
        self.spriteAgachado,
        self.x,
        self.y + self.alto - altoDibujo,
        0,
        escala,
        escala
    )

    return
end


    -- Si está corriendo

    if self.corriendo then

        local escala =
            64 / (self.spritesheetCorrer:getWidth() / 4)


        if self.mirandoDerecha then

            love.graphics.draw(
                self.spritesheetCorrer,
                self.animCorrer[self.frameCorrer],
                self.x,
                self.y - 21,
                0,
                escala,
                escala
            )

        else

            love.graphics.draw(
                self.spritesheetCorrer,
                self.animCorrer[self.frameCorrer],
                self.x + self.ancho,
                self.y - 21,
                0,
                -escala,
                escala
            )

        end


    -- Si está quieto

    else

        love.graphics.draw(
            self.sprite,
            self.x,
            self.y - 32,
            0,
            0.0625,
            0.0625
        )

    end

end
return Jugador