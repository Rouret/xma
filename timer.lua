local Timer = {}
Timer.timers = {}

-- Ajouter un timer
function Timer:after(delay, callback)
    table.insert(self.timers, {
        time = delay, -- Temps restant avant d'exécuter le callback
        callback = callback
    })
end

-- Mettre à jour tous les timers
function Timer:update(dt)
    for i = #self.timers, 1, -1 do
        local timer = self.timers[i]
        timer.time = timer.time - dt
        if timer.time <= 0 then
            timer.callback() -- Appeler la fonction
            table.remove(self.timers, i) -- Supprimer le timer terminé
        end
    end
end

return Timer
