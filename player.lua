local player = {}
local Skills = require("skills") -- Importation du module de compétences
local addProjectileCallback

-- Initialisation du joueur
function player.load()
    player.x = 10
    player.y = 10
    player.speed = 300
    player.image = love.graphics.newImage("sprites/player.png")
    player.idleTime = 0
    player.idleAmplitude = 5
    player.idleSpeed = 2

    -- Initialiser les compétences du joueur
    player.skills = {
        fireball = Skills.new("Fireball", 0.5,"Left Mouse", player.fireball),
        mutliShot = Skills.new("MultiShot", 1,"e", player.multishoot),
        dash = Skills.new("Dash", 5, "space", player.flash)
    }
end

function player.setProjectileCallback(callback)
    addProjectileCallback = callback
end

-- Mise à jour des mouvements du joueur et gestion des compétences
function player.update(dt)
    -- Animation idle (mouvement sinusoïdal)
    player.idleTime = player.idleTime + dt * player.idleSpeed
    player.y = player.y + math.sin(player.idleTime) * player.idleAmplitude * dt

    -- Contrôles clavier pour mouvement
    if love.keyboard.isDown("q") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("z") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end

    -- Gestion des compétences
    if love.mouse.isDown(1) then
        local direction = player.getAngleToMouse()
        player.skills.fireball:use(love.timer.getTime(), player.x, player.y, direction)
    end
    
    if love.keyboard.isDown("space") then
        player.skills.dash:use(love.timer.getTime())
    end

    if love.keyboard.isDown("e") then
        player.skills.mutliShot:use(love.timer.getTime())
    end
end

-- Rotation du joueur vers la souris
function player.getAngleToMouse()
    local mouseX, mouseY = love.mouse.getPosition()
    return math.atan2(mouseY - player.y, mouseX - player.x)
end

-- Dessin du joueur
function player.draw()
    local angle = player.getAngleToMouse() + math.rad(90)
    love.graphics.draw(player.image, player.x, player.y, angle, 1, 1, player.image:getWidth() / 2, player.image:getHeight() / 2)

    -- Dessiner les cooldowns des compétences
    local yOffset = 0
    for name, skill in pairs(player.skills) do
        local remaining = math.max(0, skill.cooldown - (love.timer.getTime() - skill.lastUsed))
        love.graphics.print(name .."(" .. skill.bind .. ")" ..": " .. string.format("%.1f", remaining) .. "s", 10, 20 + yOffset)
        yOffset = yOffset + 20
    end
end

-- Fireball
function player.fireball(x, y, direction)
    if addProjectileCallback then
        addProjectileCallback(x, y, direction)
    end
end

-- Flash
function player.flash()
    player.x = player.x + 200 * math.cos(player.getAngleToMouse())
    player.y = player.y + 200 * math.sin(player.getAngleToMouse())
end

-- Multishot
function player.multishoot()
    local nbFireballs = 3
    local direction = player.getAngleToMouse()
    for i = 1, nbFireballs do
        addProjectileCallback(player.x, player.y, direction - math.rad(10) + math.rad(20) * (i - 1) / (nbFireballs - 1))
    end

end


return player
