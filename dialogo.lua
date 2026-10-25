
local Dialogo = {}

Dialogo.frases = {
    "Llegamos a esta ciudad portuaria hace apenas unos dias, con la esperanza de dejar atras una vida que nunca nos permitio conocer la tranquilidad.",
    "Mi familia creyo que, entre aquellas calles desconocidas, podriamos comenzar de nuevo. Que poco sabiamos del lugar que habiamos elegido.",
    "Mi hermana y yo compartimos una misma desgracia: una mente que, en ocasiones, se vuelve contra si misma. Un tratamiento experimental nos permite mantenerla a raya.",
    "Al principio, los cambios fueron sutiles. Miradas perdidas, conversaciones incoherentes, hombres que discutian con enemigos invisibles.",
    "Despues llegaron los gritos. La violencia se extendio por las calles, y en los rostros de quienes conociamos comenzo a manifestarse algo que no me atrevo a llamar humano.",
    "Mi propia familia ha sucumbido a esta calamidad. Sin embargo, mi hermana y yo permanecemos lucidos.",
    "No se si debemos agradecer al medicamento o temer aquello que nos mantiene a salvo.",
    "Ignoro que fuerza se ha apoderado de esta ciudad. Solo se que debo encontrar una respuesta, antes de que la cordura que nos queda desaparezca para siempre."
}

function Dialogo:iniciar()
    self.indice = 0
    self.textoActual = nil
    self.finalizado = false

    self.corrutina = coroutine.create(function()
        for _, frase in ipairs(self.frases) do
            self.indice = self.indice + 1
            self.textoActual = frase

            -- Esperar hasta que el jugador presione Enter.
            coroutine.yield()
        end

        self.textoActual = nil
        self.finalizado = true
    end)

    -- Iniciar la corrutina y mostrar la primera frase.
    local ok, errorMensaje = coroutine.resume(self.corrutina)

    if not ok then
        error(errorMensaje)
    end
end

function Dialogo:avanzar()
    if not self.corrutina or self.finalizado then
        return
    end

    local ok, errorMensaje = coroutine.resume(self.corrutina)

    if not ok then
        error(errorMensaje)
    end
end

function Dialogo:dibujar()
    if not self.textoActual then
        return
    end

    local ancho = love.graphics.getWidth()
    local alto = love.graphics.getHeight()

    -- Panel de narracion.
    local anchoPanel = math.min(ancho - 100, 600)
    local altoPanel = 180
    local xPanel = (ancho - anchoPanel) / 2
    local yPanel = alto - altoPanel - 250

    love.graphics.setColor(0, 0, 0, 0.88)
    love.graphics.rectangle(
        "fill", xPanel, yPanel,
        anchoPanel, altoPanel, 8, 8
    )

    -- Aplicar la fuente Special Elite
    love.graphics.setFont(FuenteDialogo)

    love.graphics.setColor(0.65, 0.25, 0.18, 1)
    love.graphics.rectangle(
        "line", xPanel, yPanel,
        anchoPanel, altoPanel, 8, 8
    )

    love.graphics.setColor(0.9, 0.8, 0.72, 1)

    love.graphics.printf(
        self.textoActual,
        xPanel + 30,
        yPanel + 35,
        anchoPanel - 60,
        "left"
    )

    love.graphics.setColor(0.75, 0.7, 0.68, 1)

    love.graphics.printf(
        "ENTER - Continuar",
        xPanel + 20,
        yPanel + altoPanel - 35,
        anchoPanel - 40,
        "right"
    )

    love.graphics.setColor(1, 1, 1, 1)
end

return Dialogo
