local Skills = {}
Skills.__index = Skills

-- Créer une compétence
function Skills.new(name, cooldown,bind, effect)
    local self = setmetatable({}, Skills)
    self.name = name
    self.cooldown = cooldown -- Temps de recharge en secondes
    self.lastUsed = -cooldown -- Assure que la compétence est utilisable au début
    self.effect = effect -- Fonction déclenchant l'effet de la compétence
    self.bind = bind
    return self
end

-- Vérifie si la compétence est prête
function Skills:isReady(currentTime)
    return currentTime - self.lastUsed >= self.cooldown
end

-- Utilise la compétence si elle est prête
function Skills:use(currentTime, ...)
    if self:isReady(currentTime) then
        self.lastUsed = currentTime
        if self.effect then
            self.effect(...) -- Applique l'effet de la compétence
        end
        return true -- Compétence utilisée avec succès
    else
        return false -- Compétence encore en cooldown
    end
end

return Skills
