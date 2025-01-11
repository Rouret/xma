local State = {}
local love = require("love")

function State.load()
    State.x = 200
    State.y = 200
    State.speed = 1000
    State.health = 100
    State.maxHealth = 100
    State.radius = 10
    State.name = "player"
    State.status = "idle" -- Example: "idle", "moving", "attacking", "invincible", "immobilized"
    State.WEAPON_SWITCH_COOLDOWN = 1
    State.currentWeaponIndex = 1
    State.weaponSwitchTime = 0
    State.weapons = {}
    State.body = nil
    State.shape = nil
    State.fixture = nil
end

function State.switchWeapon()
    if #State.weapons > 0 then
        State.currentWeaponIndex = (State.currentWeaponIndex % #State.weapons) + 1
    end
end

function State.takeDamage(amount)
    State.health = math.max(0, State.health - amount)

end

function State.heal(amount)
    State.health = math.min(State.maxHealth, State.health + amount)
end

function State.isAlive()
    return State.health > 0
end

function State.isWeaponEquipped(weaponName)
    return State.weapons[State.currentWeaponIndex] and State.weapons[State.currentWeaponIndex].name == weaponName
end

function State.getAngleToMouse()
    local mouseX, mouseY = love.mouse.getPosition()
    return math.atan2(mouseY - State.y, mouseX - State.x)
end


return State
