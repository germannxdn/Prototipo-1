Jugador = require "entidades.jugador"
Trampa = require "entidades.trampa"
-- =================== DECLARACION ===================
Suelo = {
    x = 0,
    y = 500,
    ancho = 800,
    alto = 1
}

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
    jugador = Jugador(100, 400)

    trampa = Trampa (450, 490)

    -- Jugador parado
    jugador.sprite = love.graphics.newImage("img/jugador/parado.png")
    
    -- Spritesheet de correr
    jugador.spritesheetCorrer =
        love.graphics.newImage("img/jugador/correr.png")
    
    -- Dividimos el spritesheet en 4 frames
    local anchoFrame = jugador.spritesheetCorrer:getWidth() / 4
    local altoFrame = jugador.spritesheetCorrer:getHeight()

    for i = 0, 3 do

        table.insert(
            jugador.animCorrer,
            love.graphics.newQuad(
                anchoFrame * i,
                0,
                anchoFrame,
                altoFrame,
                jugador.spritesheetCorrer
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
    trampa.sprite =
    love.graphics.newImage("img/trampa/charco.png")

trampa.spritesheet =
    love.graphics.newImage("img/trampa/activacion.png")
    
-- Dividir spritesheet de activación
-- 4 columnas x 3 filas = 12 frames

local anchoFrame = trampa.spritesheet:getWidth() / 4
local altoFrame = trampa.spritesheet:getHeight() / 3

for fila = 0, 2 do

    for columna = 0, 3 do

        table.insert(
            trampa.animacion,
            love.graphics.newQuad(
                anchoFrame * columna,
                altoFrame * fila,
                anchoFrame,
                altoFrame,
                trampa.spritesheet
            )
        )

end
end
end
-- =================== REINICIAR JUEGO ===================

function ReiniciarJuego()

    jugador.x = 100
    jugador.y = Suelo.y - jugador.alto

    jugador.muerto = false
    jugador.muriendo = false
    jugador.gano = false

    jugador.mirandoDerecha = true

    jugador.frameCorrer = 1
    jugador.tiempoAnimacion = 0

    jugador.velocidadY = 0

    trampa.activa = false
    trampa.frame = 1
    trampa.tiempoAnimacion = 0

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

        if not jugador.muerto
        and not jugador.muriendo
        and not jugador.gano
        and jugador.y + jugador.alto >= Suelo.y then

            jugador:saltar()

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
    if jugador.muerto or jugador.gano then 
        return
    end

    -- Si está muriendo, reproducir animación de muerte
    -- ================= ANIMACION DE MUERTE =================

    if jugador.muriendo then

        trampa.tiempoAnimacion =
            trampa.tiempoAnimacion + dt

        if trampa.tiempoAnimacion >= trampa.velocidadAnimacion then

            trampa.tiempoAnimacion = 0

            trampa.frame =
                trampa.frame + 1

            -- Llegamos al último cuadro
            if trampa.frame > #trampa.animacion then

                trampa.frame = #trampa.animacion

                jugador.muriendo = false
                jugador.muerto = true

            end

        end

        return

    end

    -- ================= JUGADOR =================

    jugador:actualizar(dt, Suelo.y)

    trampa:actualizar(dt)

    -- TRAMPA
    if HayColision(jugador, trampa) then
        trampa:activar()
        jugador.muriendo = true

        jugador.velocidadY = 0

    end

    -- ================= GANAR =================
    if jugador.x + jugador.ancho >= 800 then
    jugador.gano = true
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
    trampa:dibujar(Suelo.y)

    -- ================= SPRITE DEL JUGADOR =================
    jugador:dibujar()

-- ================= MUERTE =================

    if jugador.muerto then

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
    if jugador.gano then

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

    if not jugador.muerto and not jugador.gano then

    love.graphics.print(
        "Presiona H para ver los controles",
        20,
        20
    )

end
end