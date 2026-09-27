Jugador = require "entidades.jugador"
Trampa = require "entidades.trampa"

MaquinaEstado = require "maquinaEstados"
EstadoJugando = require "estados.estadoJugando"
EstadoMuriendo = require "estados.estadoMuriendo"
EstadoMuerto = require "estados.estadoMuerto"
EstadoGanado = require "estados.estadoGanado"

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

-- MaquinaEstado
maquinaEstados = MaquinaEstado({

        jugando = function()
            return EstadoJugando()
        end,

        muriendo = function()
            return EstadoMuriendo()
        end,

        muerto = function()
            return EstadoMuerto()
        end,

        ganado = function()
            return EstadoGanado()
        end

    })

    maquinaEstados:cambiar(
        "jugando",
        {
            jugador = jugador,
            trampa = trampa,
            sueloY = Suelo.y,
            maquina = maquinaEstados
        }
    )
end


-- =================== REINICIAR JUEGO ===================

function ReiniciarJuego()

    jugador:reiniciar(
        100,
        Suelo.y - jugador.alto
    )

    trampa:reiniciar()

    maquinaEstados:cambiar(
        "jugando",
        {
            jugador = jugador,
            trampa = trampa,
            sueloY = Suelo.y,
            maquina = maquinaEstados
        }
    )

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

    maquinaEstados:actualizar(dt)

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
    
-- ================= JUEGO =================
maquinaEstados:dibujar()

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