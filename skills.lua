local Skills = {}
Skills.__index = Skills

-- Créer une compétence
function Skills.new(params)
    local self = setmetatable({}, Skills)
    self.name = params.name
    self.cooldown = params.cooldown -- Temps de recharge en secondes
    self.lastUsed = -params.cooldown -- Assure que la compétence est utilisable au début
    self.effect = params.effect -- Fonction déclenchant l'effet de la compétence
    self.damage = params.damage -- Dégâts infligés par la compétence
    self.image = love.graphics.newImage(params.image or "sprites/weapons/empty_skill.png") -- Image de la compétence
    self.song = love.audio.newSource(params.song or "sprites/weapons/empty_skill.wav", "static") -- Son de la compétence

    -- Initialisation du cooldown restant
    self.remainingCooldownInSeconds = 0
    return self
end

-- Met à jour le temps de recharge restant
function Skills:updateCooldown(currentTime)
    if self:isReady() then
        return
    end
    self.remainingCooldownInSeconds = math.max(0, self.cooldown - (currentTime - self.lastUsed))
end

-- Vérifie si la compétence est prête
function Skills:isReady()
    return self.remainingCooldownInSeconds <= 0
end

-- Utilise la compétence si elle est prête
function Skills:use(currentTime, ...)
    self:updateCooldown(currentTime) -- Toujours mettre à jour avant de vérifier
    if self:isReady() then
        self.lastUsed = currentTime
        self.remainingCooldownInSeconds = self.cooldown
        if self.effect then
            self.song:stop() -- Arrête le son de la compétence si déjà en cours
            self.effect(...) -- Applique l'effet de la compétence*
            self.song:play() -- Joue le son de la compétence
        end
        return true -- Compétence utilisée avec succès
    else
        return false -- Compétence encore en cooldown
    end
end



return Skills
