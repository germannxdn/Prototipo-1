require "dependencias"

Jugador = require "entidades.jugador"
Trampa = require "entidades.trampa"
Cuervo = require "entidades.cuervo"

MaquinaEstado = require "maquinaEstados"
EstadoJugando = require "estados.estadoJugando"
EstadoMuriendo = require "estados.estadoMuriendo"
EstadoMuerto = require "estados.estadoMuerto"
EstadoGanado = require "estados.estadoGanado"

Eventos = require "eventos"
HUD = require "hud"

Dialogo = require "dialogo"

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

-- =================== INTERFAZ ===================
-- Menu principal
estadoInterfaz = "menu"
opcionMenu = 1
mostrarControlesMenu = false
-- Menu de pausa
opcionPausa = 1
-- Guarda desde dónde se abrió el panel de controles
origenControles = "menu"

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

    -- ================= DIALOGO =================
    FuenteDialogo = love.graphics.newFont(
    "fuentes/SpecialElite-Regular.ttf",
    21
)

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
  
    jugador = Jugador(100, 478)

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

    -- ================= CUERVO =================

cuervo = Cuervo()

cuervo.spritesheet =
    love.graphics.newImage("img/cuervo/cuervo_vuelo.png")

local anchoFrameCuervo = 256
local altoFrameCuervo = 256

for i = 0, 7 do
    table.insert(
        cuervo.animacion,
        love.graphics.newQuad(
            i * anchoFrameCuervo,
            0,
            anchoFrameCuervo,
            altoFrameCuervo,
            cuervo.spritesheet
        )
    )
end

-- Tamaño visible del cuervo en el juego
cuervo.ancho = 80
cuervo.alto = 50
cuervo.velocidad = 260

    -- Jugador parado
    jugador.sprite = love.graphics.newImage("img/jugador/parado.png")
    -- Sprite del jugador agachado
    jugador.spriteAgachado =
    love.graphics.newImage("img/jugador/agachado.png")
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
    -- Imagen del Fondo
    Fondo = love.graphics.newImage("img/fondo.png")

    -- Imagen del Fondo del menú principal
FondoMenu = love.graphics.newImage("img/menu_fondo.png")

    -- Imagen del Panel de controles
PanelControles = love.graphics.newImage("img/panel_controles.png")

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
        paredDerecha = paredDerecha,
        cuervo = cuervo,
         xActivacionCuervo = 1200,
        sueloY = sueloMapa.y,
        alturaVueloCuervo = sueloMapa.y - 110
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
    cuervo:reiniciar()

    maquinaEstados:cambiar(
    "jugando",
    {
        jugador = jugador,
        trampas = {
            trampa1,
            trampa2
        },
        cuervo = cuervo,
        maquina = maquinaEstados,
        mundo = mundo,
        paredDerecha = paredDerecha,
        xActivacionCuervo = 1200,
        alturaVueloCuervo = sueloMapa.y - 110
    }
)

end

-- =================== INTERACCION ===================

function love.keypressed(key)

    -- Introduccion narrativa
    if estadoInterfaz == "dialogo" then
        if key == "return" or key == "kpenter" then
            Dialogo:avanzar()

            if Dialogo.finalizado then
                estadoInterfaz = "jugando"
            end
        end

        return
    end

        -- Navegación del menú principal
    if estadoInterfaz == "menu" then

        if key == "up" then
            opcionMenu = opcionMenu - 1

            if opcionMenu < 1 then
                opcionMenu = 3
            end

        elseif key == "down" then
            opcionMenu = opcionMenu + 1

            if opcionMenu > 3 then
                opcionMenu = 1
            end

        elseif key == "return" or key == "kpenter" then

            if opcionMenu == 1 then
            Dialogo:iniciar()
            estadoInterfaz = "dialogo"

            elseif opcionMenu == 2 then
                origenControles = "menu"
                mostrarControlesMenu = true
                estadoInterfaz = "controles"

            elseif opcionMenu == 3 then
                love.event.quit()
            end

        end

        return
    end
    -- Volver desde el panel de controles
if estadoInterfaz == "controles" then
    if key == "escape" then
        estadoInterfaz = origenControles
        mostrarControlesMenu = false
    end
    return
end

    -- Abrir y cerrar pausa con P
if key == "p" then
    if estadoInterfaz == "jugando" then
        estadoInterfaz = "pausa"
        opcionPausa = 1
        return
    elseif estadoInterfaz == "pausa" then
        estadoInterfaz = "jugando"
        return
    end
end
 -- Navegación del menú de pausa
    if estadoInterfaz == "pausa" then

        if key == "up" then
            opcionPausa = opcionPausa - 1

            if opcionPausa < 1 then
                opcionPausa = 4
            end

        elseif key == "down" then
            opcionPausa = opcionPausa + 1

            if opcionPausa > 4 then
                opcionPausa = 1
            end

        elseif key == "return" or key == "kpenter" then
            if opcionPausa == 1 then
                estadoInterfaz = "jugando"

            elseif opcionPausa == 2 then
                origenControles = "pausa"
                estadoInterfaz = "controles"
                mostrarControlesMenu = true

            elseif opcionPausa == 3 then
                ReiniciarJuego()
                estadoInterfaz = "jugando"

            elseif opcionPausa == 4 then
                estadoInterfaz = "menu"
                opcionMenu = 1
            end
        end

        return
    end



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

-- No actualizar el juego en el menú ni en otras pantallas.
-- Durante el diálogo, sí necesitamos actualizar la cámara.
if estadoInterfaz ~= "jugando"
and estadoInterfaz ~= "dialogo" then
    return
end

-- Actualizamos la máquina de estados solamente durante el juego.
if estadoInterfaz == "jugando" then
    maquinaEstados:actualizar(dt)
end



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

    -- Mostrar menú principal
    if estadoInterfaz == "menu" then
        local ancho = love.graphics.getWidth()
        local alto = love.graphics.getHeight()

        love.graphics.draw(
            FondoMenu,
            0, 0,
            0,
            ancho / FondoMenu:getWidth(),
            alto / FondoMenu:getHeight()
        )

                -- Botones del menú
        local botones = {"JUGAR", "CONTROLES", "SALIR"}

        local anchoBoton = 260
        local altoBoton = 55
        local espacio = 18

        local xBoton = ancho * 0.16
        local yInicial = alto * 0.52

        for i, texto in ipairs(botones) do
            local y = yInicial + (i - 1) * (altoBoton + espacio)

            -- Fondo del botón
            if opcionMenu == i then
                love.graphics.setColor(0.35, 0.05, 0.05, 0.95)
            else
                love.graphics.setColor(0.05, 0.04, 0.04, 0.90)
            end

            love.graphics.rectangle(
                "fill",
                xBoton,
                y,
                anchoBoton,
                altoBoton,
                8,
                8
            )

            -- Borde del botón
            love.graphics.setColor(0.65, 0.25, 0.18, 1)
            love.graphics.rectangle(
                "line",
                xBoton,
                y,
                anchoBoton,
                altoBoton,
                8,
                8
            )

            -- Texto
            love.graphics.setColor(1, 0.85, 0.75, 1)
            love.graphics.printf(
                texto,
                xBoton,
                y + 17,
                anchoBoton,
                "center"
            )
        end

        love.graphics.setColor(1, 1, 1, 1)

        return
    end



-- Introduccion narrativa sobre el juego real
if estadoInterfaz == "dialogo" then


    -- Dibujar el escenario con la camara habitual.
    camara_principal:attach()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Fondo, 0, 0)

    Mapa:drawLayer(Mapa.layers["Piso"])
    Mapa:drawLayer(Mapa.layers["Decoracion"])

    -- Dibujar el personaje y los elementos del nivel.
    maquinaEstados:dibujar()

    camara_principal:detach()

    -- Dibujar el dialogo por encima del escenario.
    Dialogo:dibujar()

    return
end


-- Panel de controles

if estadoInterfaz == "controles" then
    local anchoVentana = love.graphics.getWidth()
    local altoVentana = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        PanelControles,
        0,
        0,
        0,
        anchoVentana / PanelControles:getWidth(),
        altoVentana / PanelControles:getHeight()
    )

    return
end


    --  ================= CAMARA =================
    camara_principal:attach()

    -- ================= FONDO =================
love.graphics.draw(Fondo, 0, 0)

    -- ================= MAPA =================
    Mapa:drawLayer(Mapa.layers["Piso"])
    Mapa:drawLayer(Mapa.layers["Decoracion"])
-- ================= JUEGO =================
maquinaEstados:dibujar()

camara_principal:detach()


    -- ================= MENU DE PAUSA =================
    if estadoInterfaz == "pausa" then

        local ancho = love.graphics.getWidth()
        local alto = love.graphics.getHeight()

        -- Oscurecer el juego de fondo
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle(
            "fill", 0, 0, ancho, alto
        )

        -- Dimensiones del panel
        local anchoPanel = 420
        local altoPanel = 370
        local xPanel = (ancho - anchoPanel) / 2
        local yPanel = (alto - altoPanel) / 2

        -- Panel oscuro
        love.graphics.setColor(0.06, 0.05, 0.06, 0.96)
        love.graphics.rectangle(
            "fill",
            xPanel, yPanel,
            anchoPanel, altoPanel,
            10, 10
        )

        -- Borde rojizo
        love.graphics.setColor(0.65, 0.20, 0.16, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle(
            "line",
            xPanel, yPanel,
            anchoPanel, altoPanel,
            10, 10
        )

        -- Título
        love.graphics.setColor(0.90, 0.78, 0.68, 1)
        love.graphics.printf(
            "JUEGO EN PAUSA",
            xPanel, yPanel + 28,
            anchoPanel, "center"
        )

        -- Opciones
        local opciones = {
            "CONTINUAR",
            "CONTROLES",
            "REINICIAR NIVEL",
            "MENU PRINCIPAL"
        }

        local altoBoton = 48
        local espacio = 12
        local yInicial = yPanel + 85

        for i, texto in ipairs(opciones) do
            local xBoton = xPanel + 40
            local yBoton = yInicial + (i - 1) * (altoBoton + espacio)
            local anchoBoton = anchoPanel - 80

            -- Resaltar la opción seleccionada
            if opcionPausa == i then
                love.graphics.setColor(0.35, 0.06, 0.06, 1)
            else
                love.graphics.setColor(0.12, 0.10, 0.11, 1)
            end

            love.graphics.rectangle(
                "fill",
                xBoton, yBoton,
                anchoBoton, altoBoton,
                6, 6
            )

            love.graphics.setColor(0.65, 0.25, 0.18, 1)
            love.graphics.rectangle(
                "line",
                xBoton, yBoton,
                anchoBoton, altoBoton,
                6, 6
            )

            love.graphics.setColor(1, 0.85, 0.75, 1)
            love.graphics.printf(
                texto,
                xBoton, yBoton + 14,
                anchoBoton, "center"
            )
        end

        love.graphics.setColor(1, 1, 1, 1)
    end


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


    -- ================= AYUDA =================

    if not jugador.muerto and not jugador.gano then

    love.graphics.print(
        "Presiona P para pausar",
        20,
        95
    )

end
end