local State = require("player.state")
local Interaction = {}

function Interaction.update(dt)
    local weapon = State.weapons[State.currentWeaponIndex]
    if love.keyboard.isDown("1") then
        weapon.skills[1]:use(love.timer.getTime(), State.x, State.y, 0)
    end
    if love.keyboard.isDown("2") then
        weapon.skills[2]:use(love.timer.getTime())
    end
    if love.keyboard.isDown("3") then
        weapon.skills[3]:use(love.timer.getTime(), State)
    end
    -- Changement d'arme avec "E"
    if love.keyboard.isDown("e") then
        if love.timer.getTime() - State.weaponSwitchTime > State.WEAPON_SWITCH_COOLDOWN then
            State.switchWeapon()
            State.weaponSwitchTime = love.timer.getTime()
        end
    end
end

return Interaction
