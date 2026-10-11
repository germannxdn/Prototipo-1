require "dependencias"

Jugador = require "entidades.jugador"
Trampa = require "entidades.trampa"

MaquinaEstado = require "maquinaEstados"
EstadoJugando = require "estados.estadoJugando"
EstadoMuriendo = require "estados.estadoMuriendo"
EstadoMuerto = require "estados.estadoMuerto"
EstadoGanado = require "estados.estadoGanado"

Eventos = require "eventos"
HUD = require "hud"


-- =================== DECLARACION ===================


Fondo = nil
MusicaFondo = nil
Mapa = nil
mostrarControles = false
camara_principal = nil
mundo = nil
paredDerecha = nil
sueloMapa = nil

-- Efecto visual de muerte
tiempoParpadeo = 0
duracionParpadeo = 2.0
intervaloParpadeo = 0.1

-- Vibración de cámara
tiempoVibracion = 0
duracionVibracion = 2.0
intensidadVibracion = 8

-- =================== COLISION ===================

function HayColision(a, b)

    return a.x < b.x + b.ancho
       and a.x + a.ancho > b.x
       and a.y < b.y + b.alto
       and a.y + a.alto > b.y

end
-- =================== INICIALIZACION ===================

function love.load()

    Mapa = STI("mapa/nivel1.lua")

    mundo = Bump.newWorld(64)

    -- Buscamos la pared derecha en el mapa
    for _, objeto in ipairs(Mapa.layers["Colisiones"].objects) do

    if objeto.name == "ParedDerecha" then
        paredDerecha = objeto
    end
    if objeto.name == "P1" then
        sueloMapa = objeto
    end

end



for _, objeto in ipairs(Mapa.layers["Colisiones"].objects) do

    mundo:add(
        objeto,
        objeto.x,
        objeto.y,
        objeto.width,
        objeto.height
    )

end
Mapa.layers["Colisiones"].visible = false

    -- Inicializamos la camara
    camara_principal = Camara()
  
    jugador = Jugador(100, 400)

    -- Agregamos el jugador al mundo de colisiones
    mundo:add(
    jugador,
    jugador.x,
    jugador.y,
    jugador.ancho,
    jugador.alto
)
    -- Agregamos las trampas al mundo de colisiones
    trampa1 = Trampa(450, 0)
trampa1.y =
    sueloMapa.y - trampa1.alto + 2

trampa2 = Trampa(1000, 0)
trampa2.y =
    sueloMapa.y - trampa2.alto + 2

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


-----------Audio-----------------
    -- Musica de fondo
    MusicaFondo = love.audio.newSource("audio/musicadefondo.wav", "stream")
MusicaFondo:setLooping(true)
MusicaFondo:play()

-- Sonido de muerte
sonidoMuerte = love.audio.newSource(
    "audio/grito_muerte.wav",
    "static"
)

-- ================= TRAMPAS =================

local spriteTrampa =
    love.graphics.newImage("img/trampa/charco.png")

local spritesheetTrampa =
    love.graphics.newImage("img/trampa/activacion.png")


-- Dividir spritesheet de activación
-- 4 columnas x 3 filas = 12 frames

local anchoFrame =
    spritesheetTrampa:getWidth() / 4

local altoFrame =
    spritesheetTrampa:getHeight() / 3


local animacionTrampa = {}


for fila = 0, 2 do

    for columna = 0, 3 do

        table.insert(
            animacionTrampa,
            love.graphics.newQuad(
                anchoFrame * columna,
                altoFrame * fila,
                anchoFrame,
                altoFrame,
                spritesheetTrampa
            )
        )

    end

end
-- Configurar trampa 1

trampa1.sprite = spriteTrampa
trampa1.spritesheet = spritesheetTrampa
trampa1.animacion = animacionTrampa


-- Configurar trampa 2

trampa2.sprite = spriteTrampa
trampa2.spritesheet = spritesheetTrampa
trampa2.animacion = animacionTrampa

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
        trampas = {
            trampa1,
            trampa2
        },
        maquina = maquinaEstados,
        mundo = mundo,
        paredDerecha = paredDerecha
    }
)
end

hud = HUD()

-- =================== EVENTOS ===================
Eventos.registrar("jugador-muere", function()
    sonidoMuerte:stop()
    sonidoMuerte:play()
end)
-- Efecto visual de muerte
Eventos.registrar("jugador-muere", function()
    tiempoParpadeo = duracionParpadeo
end)
-- Vibración de cámara
Eventos.registrar("jugador-muere", function()
    tiempoVibracion = duracionVibracion
end)

-- =================== REINICIAR JUEGO ===================

function ReiniciarJuego()

    jugador:reiniciar(
        100,
        478
    )

    mundo:update(
        jugador,
        jugador.x,
        jugador.y
    )

    trampa1:reiniciar()
    trampa2:reiniciar()

    maquinaEstados:cambiar(
        "jugando",
        {
            jugador = jugador,
            trampas = {
                trampa1,
                trampa2
            },
            maquina = maquinaEstados,
            mundo = mundo,
            paredDerecha = paredDerecha
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
        and jugador.estaEnSuelo then

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

    -- Efecto visual de muerte
    if tiempoParpadeo > 0 then
    tiempoParpadeo = math.max(0, tiempoParpadeo - dt)
end
    if tiempoVibracion > 0 then
    tiempoVibracion = math.max(
        0,
        tiempoVibracion - dt
    )
end

-- Actualizamos la maquina de estados
    maquinaEstados:actualizar(dt)

    local anchoMapa =
        Mapa.width * Mapa.tilewidth

    local altoMapa =
        Mapa.height * Mapa.tileheight

    local mitadPantallaX =
        love.graphics.getWidth() / 2

    local mitadPantallaY =
        love.graphics.getHeight() / 2

    local centroJugadorX =
    jugador.x + jugador.ancho / 2

local camaraX =
    math.max(
        mitadPantallaX,
        math.min(
            centroJugadorX,
            anchoMapa - mitadPantallaX
        )
    )

    local camaraY =
        math.max(
            mitadPantallaY,
            math.min(
                jugador.y,
                altoMapa - mitadPantallaY
            )
        )

    -- ================= CAMARA Y VIBRACIÓN =================

if tiempoVibracion > 0 then

    local desplazamientoX =
        (love.math.random() * 2 - 1) * intensidadVibracion

    local desplazamientoY =
        (love.math.random() * 2 - 1) * intensidadVibracion

    camara_principal:lookAt(
        camaraX + desplazamientoX,
        camaraY + desplazamientoY
    )

else

    camara_principal:lookAt(
        camaraX,
        camaraY
    )

end

end
-- =================== RENDERIZADO ===================

function love.draw()

    camara_principal:attach()

    -- ================= FONDO =================
love.graphics.draw(Fondo, 0, 0)

    -- ================= MAPA =================
    Mapa:drawLayer(Mapa.layers["Piso"])
    Mapa:drawLayer(Mapa.layers["Decoracion"])
-- ================= JUEGO =================
maquinaEstados:dibujar()

camara_principal:detach()

-- ================= PARPADEO OSCURO =================

if tiempoParpadeo > 0 then

    local tiempoTranscurrido =
        duracionParpadeo - tiempoParpadeo

    local parpadeo =
        math.floor(tiempoTranscurrido / intervaloParpadeo)

    -- Alternar entre oscuro y visible
    if parpadeo % 2 == 0 then

        love.graphics.setColor(0, 0, 0, 0.85)

        love.graphics.rectangle(
            "fill",
            0,
            0,
            love.graphics.getWidth(),
            love.graphics.getHeight()
        )

        love.graphics.setColor(1, 1, 1, 1)

    end

end

hud:Draw()

if jugador.muerto then
    love.graphics.printf(
        "¡HAS MUERTO!",
        0,
        250,
        love.graphics.getWidth(),
        "center"
    )

    love.graphics.printf(
        "Las profundidades te han reclamado...",
        0,
        280,
        love.graphics.getWidth(),
        "center"
    )

    love.graphics.printf(
        "Presiona R para intentarlo nuevamente",
        0,
        310,
        love.graphics.getWidth(),
        "center"
    )
end

if jugador.gano then
    love.graphics.printf(
        "¡GANASTE! Presiona R para reiniciar",
        0,
        250,
        love.graphics.getWidth(),
        "center"
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