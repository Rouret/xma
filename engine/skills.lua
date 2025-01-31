local UI = require("game.ui")

local Skills = {}
Skills.__index = Skills

-- Créer une compétence
function Skills.new(params)
    local self = setmetatable({}, Skills)
    self.name = params.name
    self.cooldown = params.cooldown -- Temps de recharge en secondes
    self.lastUsed = -params.cooldown -- Assure que la compétence est utilisable au début
    self.effect = params.effect -- Fonction déclenchant l'effet de la compétence
    self.damage = params.damage or 0 -- Dégâts infligés par la compétence
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

function Skills:drawUI(x, y, mouseX, mouseY)
    local skillSize = UI.skills.skillSize
    love.graphics.draw(self.image, x, y)
    if self.remainingCooldownInSeconds > 0 then
        love.graphics.draw(UI.cooldownOverlay, x, y)
        local cooldownText = UI.formatTime(self.remainingCooldownInSeconds)
        love.graphics.setFont(UI.font.big)
        local textWidth = UI.font.big:getWidth(cooldownText)
        local textHeight = UI.font.big:getHeight()
        love.graphics.print(cooldownText, x + (skillSize - textWidth) / 2, y + (skillSize - textHeight) / 2)
    end

    -- Detect hover
    local isHovered = mouseX >= x and mouseX <= x + skillSize and mouseY >= y and mouseY <= y + skillSize

    -- draw a popup with defailt folow the mouse
    if isHovered then
        -- white background
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(UI.font.small)
        local text = self.name
        local textWidth = UI.font.small:getWidth(text)
        local textHeight = UI.font.small:getHeight()

        -- 32 padding
        local padding = 32
        local popupWidth = textWidth + padding
        local popupHeight = textHeight + padding
        local popupX = mouseX - popupWidth / 2
        local popupY = mouseY - popupHeight - 10
        -- draw the name of the skill
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(text, popupX + padding / 2, popupY + padding / 2)
    end
end

return Skills
