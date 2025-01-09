local player = {}
local Gun = require("weapons.gun")
local Sword = require("weapons.sword")

local addProjectileCallback

function player.load()
    player.x = 10
    player.y = 10
    player.speed = 300
    player.image = love.graphics.newImage("sprites/player.png")
    player.idleTime = 0
    player.idleAmplitude = 5
    player.idleSpeed = 2
    player.WEAPON_SWITCH_COOLDOWN = 1
    player.weaponSwitchTime = 0

    -- Charger les armes
    player.weapons = {
        Gun.new(),
        Sword.new(),
    }
    player.currentWeaponIndex = 1
end

function player.switchWeapon()
    player.currentWeaponIndex = (player.currentWeaponIndex % #player.weapons) + 1
    print("Switched to weapon: " .. player.weapons[player.currentWeaponIndex].name)
end

function player.update(dt)
    -- Animation idle
    player.idleTime = player.idleTime + dt * player.idleSpeed
    player.y = player.y + math.sin(player.idleTime) * player.idleAmplitude * dt

    -- Mouvements
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

    -- Utilisation des compétences de l'arme active
    local weapon = player.weapons[player.currentWeaponIndex]
    if love.keyboard.isDown("1") then
        weapon.skills[1]:use(love.timer.getTime(), player.x, player.y, player.getAngleToMouse(), addProjectileCallback)
    end
    if love.keyboard.isDown("2") then
        weapon.skills[2]:use(love.timer.getTime())
    end
    if love.keyboard.isDown("3") then
        weapon.skills[3]:use(love.timer.getTime(), player)
    end

    -- Changement d'arme avec "E"
    if love.keyboard.isDown("e") then
        if love.timer.getTime() - player.weaponSwitchTime > player.WEAPON_SWITCH_COOLDOWN then
            player.switchWeapon()
            player.weaponSwitchTime = love.timer.getTime()
        end
    end
end

function player.getAngleToMouse()
    local mouseX, mouseY = love.mouse.getPosition()
    return math.atan2(mouseY - player.y, mouseX - player.x)
end

function player.draw()
    local angle = player.getAngleToMouse()
    love.graphics.draw(player.image, player.x, player.y, angle, 1, 1, player.image:getWidth() / 2, player.image:getHeight() / 2)

    -- Afficher les informations de l'arme active et ses cooldowns
    local weapon = player.weapons[player.currentWeaponIndex]
    love.graphics.print("Weapon: " .. weapon.name .. " (E to switch)", 10, 10)
    for i, skill in ipairs(weapon.skills) do
        local remaining = math.max(0, skill.cooldown - (love.timer.getTime() - skill.lastUsed))
        love.graphics.print(skill.name .. ": " .. string.format("%.1f", remaining) .. "s", 10, 30 + i * 20)
    end
end

return player
