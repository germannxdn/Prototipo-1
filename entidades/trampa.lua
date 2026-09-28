Class = require "lib.class"

Trampa = Class{}

function Trampa:init(x, y)

    -- =========================
    -- POSICION Y TAMAÑO
    -- =========================

    self.x = x
    self.y = y

    self.ancho = 100
    self.alto = 30


    -- =========================
    -- ESTADO
    -- =========================

    self.activa = false


    -- =========================
    -- SPRITES
    -- =========================

    self.sprite = nil
    self.spritesheet = nil


    -- =========================
    -- ANIMACION
    -- =========================

    self.animacion = {}

    self.frame = 1

    self.tiempoAnimacion = 0

    self.velocidadAnimacion = 0.15

end


-- ==========================================
-- ACTUALIZAR ANIMACION
-- ==========================================

function Trampa:actualizar(dt)

    if not self.activa then
        return
    end


    self.tiempoAnimacion =
        self.tiempoAnimacion + dt


    if self.tiempoAnimacion >=
       self.velocidadAnimacion then

        self.tiempoAnimacion = 0

        self.frame =
            self.frame + 1


        if self.frame > #self.animacion then

            self.frame =
                #self.animacion

        end

    end

end


-- ==========================================
-- ACTIVAR TRAMPA
-- ==========================================

function Trampa:activar()

    if self.activa then
        return
    end

    self.activa = true

    self.frame = 1

    self.tiempoAnimacion = 0

end


-- ==========================================
-- DIBUJAR TRAMPA
-- ==========================================

function Trampa:dibujar()

    if self.activa then

        local _, _, anchoFrame, altoFrame =
            self.animacion[self.frame]:getViewport()


        local escala =
            self.ancho / anchoFrame


        local anchoDibujo =
            anchoFrame * escala


        local altoDibujo =
            altoFrame * escala


        local xDibujo =
            self.x +
            (self.ancho - anchoDibujo) / 2


        local yDibujo =
        self.y + self.alto - altoDibujo + 10


        love.graphics.draw(

            self.spritesheet,

            self.animacion[self.frame],

            xDibujo,

            yDibujo,

            0,

            escala,

            escala

        )

    else

        local escala =
            self.ancho /
            self.sprite:getWidth()


        local anchoDibujo =
            self.sprite:getWidth() * escala


        local altoDibujo =
            self.sprite:getHeight() * escala


        local xDibujo =
            self.x +
            (self.ancho - anchoDibujo) / 2


        local yDibujo =
        self.y + self.alto - altoDibujo + 10


        love.graphics.draw(

            self.sprite,

            xDibujo,

            yDibujo,

            0,

            escala,

            escala

        )

    end

end

function Trampa:reiniciar()

    self.activa = false

    self.frame = 1

    self.tiempoAnimacion = 0

end

return Trampa