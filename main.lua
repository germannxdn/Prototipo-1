-- =================== DECLARACION ===================

Jugador = {
    x = 100,
    y = 400,
    ancho = 64,
    alto = 64,
    vel = 200,
    velSalto = 500,
    muerto = false,
    muriendo = false,
    gano = false,
    sprite = nil,

    spritesheetCorrer = nil,
    mirandoDerecha = true,
    animCorrer = {},
    frameCorrer = 1,
    tiempoAnimacion = 0,
    velocidadAnimacion = 0.10
}

Suelo = {
    x = 0,
    y = 500,
    ancho = 800,
    alto = 1
}

Trampa = {
    x = 450,
    y = 490,
    ancho = 100,
    alto = 30,
    activa = false,

    sprite = nil,

    spritesheet = nil,
    animacion = {},
    frame = 1,

    tiempoAnimacion = 0,
    velocidadAnimacion = 0.15
}

gravedad = 1000
velocidadY = 0

Fondo = nil
MusicaFondo = nil

mostrarControles = false

-- =================== COLISION ===================

function HayColision(a, b)

    return a.x < b.x + b.ancho
       and a.x + a.ancho > b.x
       and a.y < b.y + b.alto
       and a.y + a.alto > b.y

end
-- =================== INICIALIZACION ===================

function love.load()
    -- Jugador parado
    Jugador.sprite = love.graphics.newImage("img/jugador/parado.png")
    
    -- Spritesheet de correr
    Jugador.spritesheetCorrer =
        love.graphics.newImage("img/jugador/correr.png")
    
    -- Dividimos el spritesheet en 4 frames
    local anchoFrame = Jugador.spritesheetCorrer:getWidth() / 4
    local altoFrame = Jugador.spritesheetCorrer:getHeight()

    for i = 0, 3 do

        table.insert(
            Jugador.animCorrer,
            love.graphics.newQuad(
                anchoFrame * i,
                0,
                anchoFrame,
                altoFrame,
                Jugador.spritesheetCorrer
            )
        )

    end
    -- Sprite Fondo
    Fondo = love.graphics.newImage("img/fondo.png")
    -- Musica de fondo
    MusicaFondo = love.audio.newSource("musicadefondo.wav", "stream")
MusicaFondo:setLooping(true)
MusicaFondo:play()

    -- Spritesheet de trampa
    Trampa.sprite =
    love.graphics.newImage("img/trampa/charco.png")

Trampa.spritesheet =
    love.graphics.newImage("img/trampa/activacion.png")
    
-- Dividir spritesheet de activación
-- 4 columnas x 3 filas = 12 frames

local anchoFrame = Trampa.spritesheet:getWidth() / 4
local altoFrame = Trampa.spritesheet:getHeight() / 3

for fila = 0, 2 do

    for columna = 0, 3 do

        table.insert(
            Trampa.animacion,
            love.graphics.newQuad(
                anchoFrame * columna,
                altoFrame * fila,
                anchoFrame,
                altoFrame,
                Trampa.spritesheet
            )
        )

end
end
end
-- =================== REINICIAR JUEGO ===================

function ReiniciarJuego()

    Jugador.x = 100
    Jugador.y = Suelo.y - Jugador.alto

    Jugador.muerto = false
    Jugador.muriendo = false
    Jugador.gano = false

    Jugador.mirandoDerecha = true

    Jugador.frameCorrer = 1
    Jugador.tiempoAnimacion = 0

    velocidadY = 0

    Trampa.activa = false
    Trampa.frame = 1
    Trampa.tiempoAnimacion = 0

end

-- =================== INTERACCION ===================

function love.keypressed(key)

    -- Reiniciar juego
    if key == "r" then
        ReiniciarJuego()
        return
    end
    -- Saltar
    if key == "space" then

        if not Jugador.muerto
        and not Jugador.muriendo
        and not Jugador.gano
        and Jugador.y + Jugador.alto >= Suelo.y then

            velocidadY = -Jugador.velSalto

        end

    end
    -- MOSTRAR / OCULTAR CONTROLES
    if key == "h" then
        mostrarControles = not mostrarControles
    end

end


-- =================== ACTUALIZACION ===================

function love.update(dt)

    -- Si está muerto, no puede moverse
    if Jugador.muerto or Jugador.gano then 
        return
    end

    -- Si está muriendo, reproducir animación de muerte
    -- ================= ANIMACION DE MUERTE =================

    if Jugador.muriendo then

        Trampa.tiempoAnimacion =
            Trampa.tiempoAnimacion + dt

        if Trampa.tiempoAnimacion >= Trampa.velocidadAnimacion then

            Trampa.tiempoAnimacion = 0

            Trampa.frame =
                Trampa.frame + 1

            -- Llegamos al último cuadro
            if Trampa.frame > #Trampa.animacion then

                Trampa.frame = #Trampa.animacion

                Jugador.muriendo = false
                Jugador.muerto = true

            end

        end

        return

    end
    -- ================= MOVIMIENTO =================

    if love.keyboard.isDown("left") then
        Jugador.x = Jugador.x - (Jugador.vel * dt)
        Jugador.mirandoDerecha = false
    end

    if love.keyboard.isDown("right") then
        Jugador.x = Jugador.x + (Jugador.vel * dt)
        Jugador.mirandoDerecha = true
    end

    -- ================= ANIMACION =================

    local corriendo = false

    if love.keyboard.isDown("left") or love.keyboard.isDown("right") then
    corriendo = true
    end

    if corriendo then

    Jugador.tiempoAnimacion =
        Jugador.tiempoAnimacion + dt

    if Jugador.tiempoAnimacion >= Jugador.velocidadAnimacion then

        Jugador.tiempoAnimacion = 0

        Jugador.frameCorrer =
            Jugador.frameCorrer + 1

        if Jugador.frameCorrer > #Jugador.animCorrer then
            Jugador.frameCorrer = 1
        end

    end

else

    Jugador.frameCorrer = 1
    Jugador.tiempoAnimacion = 0

end

    -- ================= SALTO / GRAVEDAD =================
    velocidadY = velocidadY + (gravedad * dt)

    Jugador.y = Jugador.y + (velocidadY * dt)
    -- Mantener al jugador sobre el suelo
    if Jugador.y + Jugador.alto >= Suelo.y then

        Jugador.y = Suelo.y - Jugador.alto
        velocidadY = 0

    end


    -- TRAMPA
    if HayColision(Jugador, Trampa) then
        Trampa.activa = true
        Jugador.muriendo = true

        velocidadY = 0

    end

    -- ================= GANAR =================
    if Jugador.x + Jugador.ancho >= 800 then
    Jugador.gano = true
end

end
-- =================== RENDERIZADO ===================

function love.draw()

        -- FONDO
    love.graphics.draw(
        Fondo,
        0,
        0,
        0,
        800 / Fondo:getWidth(),
        600 / Fondo:getHeight()
    )
    
    -- TRAMPA
    if Trampa.activa then

    local _, _, anchoFrame, altoFrame =
        Trampa.animacion[Trampa.frame]:getViewport()

    local escala = Trampa.ancho / anchoFrame

    local anchoDibujo = anchoFrame * escala
    local altoDibujo = altoFrame * escala

    local xDibujo =
        Trampa.x + (Trampa.ancho - anchoDibujo) / 2

    local yDibujo =
        Suelo.y - altoDibujo

    love.graphics.draw(
        Trampa.spritesheet,
        Trampa.animacion[Trampa.frame],
        xDibujo,
        yDibujo,
        0,
        escala,
        escala
    )

else

    local escala =
        Trampa.ancho / Trampa.sprite:getWidth()

    local anchoDibujo =
        Trampa.sprite:getWidth() * escala

    local altoDibujo =
        Trampa.sprite:getHeight() * escala

    local xDibujo =
        Trampa.x + (Trampa.ancho - anchoDibujo) / 2

    local yDibujo =
        Suelo.y - altoDibujo

    love.graphics.draw(
        Trampa.sprite,
        xDibujo,
        yDibujo,
        0,
        escala,
        escala
    )

end

    -- ================= SPRITE DEL JUGADOR =================
    -- El jugador solamente se dibuja si está vivo
    if not Jugador.muriendo and not Jugador.muerto then
    if love.keyboard.isDown("left") or love.keyboard.isDown("right") then
        -- Dibujamos la animación de correr
    local escala =
            64 / (Jugador.spritesheetCorrer:getWidth() / 4)

        if Jugador.mirandoDerecha then

            love.graphics.draw(
                Jugador.spritesheetCorrer,
                Jugador.animCorrer[Jugador.frameCorrer],
                Jugador.x,
                Jugador.y - 21,
                0,
                escala,
                escala
            )

        else

            love.graphics.draw(
                Jugador.spritesheetCorrer,
                Jugador.animCorrer[Jugador.frameCorrer],
                Jugador.x + Jugador.ancho,
                Jugador.y - 21,
                0,
                -escala,
                escala
            )

        end
else
-- Sprite parado
    love.graphics.draw(
        Jugador.sprite,
        Jugador.x,
        Jugador.y - 32,
        0,
        0.0625,
        0.0625
    )
end
end
-- ================= MUERTE =================

    if Jugador.muerto then

        love.graphics.print(
            "HAS MUERTO",
            350,
            250
        )
        love.graphics.print(
        "Las profundidades te han reclamado...",
        280,
        280
    )

        love.graphics.print(
            "Presiona R para intentarlo nuevamente",
            270,
            310
        )

    end

    -- ================= GANAR =================
    if Jugador.gano then

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

    -- ================= CONTROLES =================

    if mostrarControles then

        love.graphics.print(
            "CONTROLES",
            330,
            80
        )

        love.graphics.print(
            "FLECHAS IZQ / DER  -  MOVERSE",
            250,
            120
        )

        love.graphics.print(
            "ESPACIO  -  SALTAR",
            280,
            150
        )

        love.graphics.print(
            "R  -  REINICIAR",
            300,
            180
        )

        love.graphics.print(
            "H  -  OCULTAR CONTROLES",
            260,
            210
        )

    end
    -- ================= AYUDA =================

if not Jugador.muerto and not Jugador.gano then

    love.graphics.print(
        "Presiona H para ver los controles",
        20,
        20
    )

end
end