
Estado = require "estados.estado"

EstadoMuriendo = Class{__includes = Estado}

function EstadoMuriendo:init()
    self.jugador = nil
    self.trampa = nil
    self.maquina = nil
    self.tiempoMuerte = 0
    self.duracionMuerte = 0.8
end

function EstadoMuriendo:ingresar(parametros)
    self.jugador = parametros.jugador
    self.trampa = parametros.trampa
    self.maquina = parametros.maquina

    self.jugador.muriendo = true
    self.tiempoMuerte = 0

    -- Si la muerte fue causada por una trampa,
    -- reiniciamos su animación.
    if self.trampa then
        self.trampa.frame = 1
        self.trampa.tiempoAnimacion = 0
    end
end

function EstadoMuriendo:salir()
end

function EstadoMuriendo:actualizar(dt)
    self.tiempoMuerte = self.tiempoMuerte + dt

    if self.trampa then
        self.trampa.tiempoAnimacion =
            self.trampa.tiempoAnimacion + dt

        if self.trampa.tiempoAnimacion >=
           self.trampa.velocidadAnimacion then

            self.trampa.tiempoAnimacion = 0
            self.trampa.frame = self.trampa.frame + 1

            if self.trampa.frame > #self.trampa.animacion then
                self.trampa.frame = #self.trampa.animacion
            end
        end
    end

    -- La muerte termina cuando concluye la animación
    -- de la trampa o cuando vence el tiempo del cuervo.
    local terminarMuerte = false

    if self.trampa then
        terminarMuerte =
            self.trampa.frame >= #self.trampa.animacion
            and self.trampa.tiempoAnimacion == 0
    else
        terminarMuerte =
            self.tiempoMuerte >= self.duracionMuerte
    end

    if terminarMuerte then
        self.jugador.muriendo = false
        self.jugador.muerto = true

        self.maquina:cambiar(
            "muerto",
            {
                jugador = self.jugador,
                trampa = self.trampa,
                maquina = self.maquina
            }
        )
    end
end

function EstadoMuriendo:dibujar()
    if self.trampa then
        self.trampa:dibujar()
    end
end

return EstadoMuriendo
