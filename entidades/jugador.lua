Class = require "lib.class"

Jugador = Class{}

function Jugador:init(x, y)
    self.x = x
    self.y = y

    self.ancho = 64
    self.alto = 64

    self.vel = 200
    self.velSalto = 500

    self.gravedad = 1000
    self.velocidadY = 0

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
end
function Jugador:actualizar(dt, sueloY)

    -- Movimiento horizontal

    if love.keyboard.isDown("left") then

        self.x = self.x - (self.vel * dt)
        self.mirandoDerecha = false

    end


    if love.keyboard.isDown("right") then

        self.x = self.x + (self.vel * dt)
        self.mirandoDerecha = true

    end


    -- Gravedad

    self.velocidadY =
        self.velocidadY + (self.gravedad * dt)

    self.y =
        self.y + (self.velocidadY * dt)


    -- Suelo

    if self.y + self.alto >= sueloY then

        self.y = sueloY - self.alto

        self.velocidadY = 0

    end


    -- Animación de correr

    local corriendo =
        love.keyboard.isDown("left")
        or love.keyboard.isDown("right")


    if corriendo then

        self.tiempoAnimacion =
            self.tiempoAnimacion + dt


        if self.tiempoAnimacion >=
           self.velocidadAnimacion then

            self.tiempoAnimacion = 0

            self.frameCorrer =
                self.frameCorrer + 1


            if self.frameCorrer >
               #self.animCorrer then

                self.frameCorrer = 1

            end

        end

    else

        self.frameCorrer = 1
        self.tiempoAnimacion = 0

    end

end


function Jugador:saltar()
    self.velocidadY = -self.velSalto
end

function Jugador:dibujar()

    -- El jugador no se dibuja si está muriendo o muerto

    if self.muriendo or self.muerto then
        return
    end


    -- Si está corriendo

    if love.keyboard.isDown("left")
    or love.keyboard.isDown("right") then

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