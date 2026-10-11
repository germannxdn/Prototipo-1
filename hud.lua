local HUD = Class{}

function HUD:init()
    self.muertes = 0

    Eventos.registrar("jugador-muere", function()
        self.muertes = self.muertes + 1
    end)
end

function HUD:Draw()
    love.graphics.setColor(1, 1, 1)

    love.graphics.print("NIVEL 1", 20, 20)
    love.graphics.print("Objetivo: Encontrá una salida", 20, 45)
    love.graphics.print("Muertes: " .. self.muertes, 20, 70)
end

return HUD