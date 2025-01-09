local player = {}
local Gun = require("weapons.gun")
local Sword = require("weapons.sword")

local addProjectileCallback

function player.load()
    player.state = {
        x = 10,
        y = 10,
        speed = 300,
        idleTime = 0,
        idleAmplitude = 5,
        idleSpeed = 2,
        health = 100,
        maxHealth = 100
    }
    player.image = love.graphics.newImage("sprites/player.png")
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


function player.move(dx, dy, dt)
    player.state.x = player.state.x + dx * player.state.speed * dt
    player.state.y = player.state.y + dy * player.state.speed * dt
end

function player.handleInputs(dt)
    if love.keyboard.isDown("q") then
        player.move(-1, 0, dt)
    end
    if love.keyboard.isDown("d") then
        player.move(1, 0, dt)
    end
    if love.keyboard.isDown("z") then
        player.move(0, -1, dt)
    end
    if love.keyboard.isDown("s") then
        player.move(0, 1, dt)
    end

    -- Utilisation des compétences de l'arme active
    local weapon = player.weapons[player.currentWeaponIndex]
    if love.keyboard.isDown("1") then
        weapon.skills[1]:use(love.timer.getTime(), player.state.x, player.state.y, player.getAngleToMouse(), addProjectileCallback)
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

function player.update(dt)
    if not player.isAlive() then
        return -- Le joueur est mort, pas de mise à jour
    end

    player.handleInputs(dt)
end

function player.getAngleToMouse()
    local mouseX, mouseY = love.mouse.getPosition()
    return math.atan2(mouseY - player.state.y, mouseX - player.state.x)
end

function player.draw()
    local angle = player.getAngleToMouse()
    love.graphics.draw(player.image, player.state.x, player.state.y, angle, 1, 1, player.image:getWidth() / 2, player.image:getHeight() / 2)

    -- Afficher les informations de l'arme active et ses cooldowns
    local weapon = player.weapons[player.currentWeaponIndex]
    love.graphics.print("Weapon: " .. weapon.name .. " (E to switch)", 10, 10)
    for i, skill in ipairs(weapon.skills) do
        local remaining = math.max(0, skill.cooldown - (love.timer.getTime() - skill.lastUsed))
        love.graphics.print(skill.name .. ": " .. string.format("%.1f", remaining) .. "s", 10, 30 + i * 20)
    end
end

function player.takeDamage(amount)
    player.state.health = math.max(0, player.state.health - amount)
    print("Player took " .. amount .. " damage. Health: " .. player.state.health)
end

function player.heal(amount)
    player.state.health = math.min(player.state.maxHealth, player.state.health + amount)
    print("Player healed " .. amount .. ". Health: " .. player.state.health)
end

function player.isAlive()
    return player.state.health > 0
end


return player
