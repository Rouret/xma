local State = {}
local Gun = require("weapons.gun.gun")
local Sword = require("weapons.sword")
function State.load()
    State.x = 10
    State.y = 10
    State.speed = 300
    State.health = 100
    State.maxHealth = 100
    State.status = "idle" -- Exemple : "idle", "moving", "attacking", "invincible"
    State.WEAPON_SWITCH_COOLDOWN = 1
    State.currentWeaponIndex = 1
    State.weaponSwitchTime = 0
    State.weapons = {
        Gun.new(),
        Sword.new(),
    }
end

function State.switchWeapon()
    State.currentWeaponIndex = (State.currentWeaponIndex % #State.weapons) + 1
    print("Switched to weapon: " .. State.weapons[State.currentWeaponIndex].name)
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

return State
