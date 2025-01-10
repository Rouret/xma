local State = {}
local love = require("love")

function State.load()
    State.x = 200
    State.y = 200
    State.speed = 300
    State.health = 100
    State.maxHealth = 100
    State.status = "idle" -- Example: "idle", "moving", "attacking", "invincible"
    State.WEAPON_SWITCH_COOLDOWN = 1
    State.currentWeaponIndex = 1
    State.weaponSwitchTime = 0
    State.weapons = {}
end

function State.switchWeapon()
    if #State.weapons > 0 then
        State.currentWeaponIndex = (State.currentWeaponIndex % #State.weapons) + 1
        print("Switched to weapon: " .. State.weapons[State.currentWeaponIndex].name)
    else
        print("No weapons to switch to.")
    end
end

function State.takeDamage(amount)
    State.health = math.max(0, State.health - amount)
    print("Player took " .. amount .. " damage. Health: " .. State.health)
end

function State.heal(amount)
    State.health = math.min(State.maxHealth, State.health + amount)
    print("Player healed " .. amount .. ". Health: " .. State.health)
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

function State.getAngleForGun()
    return State.getAngleToMouse() - math.pi / 2
end

return State
