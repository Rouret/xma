local State = {}
local love = require("love")
local Game = require("game.game")
local Choice = require("game.choice")

function State.load()
    State.name = "player"
    State.status = "idle" -- Example: "idle", "immobilized"

    -- Position
    State.x = 200
    State.y = 200

    -- Velocity
    State.speed = 1000

    -- Health
    State.health = 100
    State.maxHealth = 100
    State.radius = 10

    -- Damage
    State.damage = 100

    -- Experience
    State.experience = 0
    State.level = 1

    -- Weapon
    State.WEAPON_SWITCH_COOLDOWN = 1
    State.currentWeaponIndex = 1
    State.weaponSwitchTime = 0
    State.weapons = {}

    -- Physics
    State.body = nil
    State.shape = nil
    State.fixture = nil
end

function State.switchWeapon()
    if #State.weapons > 0 then
        State.currentWeaponIndex = (State.currentWeaponIndex % #State.weapons) + 1
    end
end

function State.canSwitchWeapon()
    return love.timer.getTime() - State.weaponSwitchTime > State.WEAPON_SWITCH_COOLDOWN
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

function State.gainExperience(amount)
    State.experience = State.experience + amount
    if State.experience >= State.level * 100 then
        State.level = State.level + 1
        State.experience = 0
        State.maxHealth = State.maxHealth + 10
        State.health = State.maxHealth

        Game.isGamePaused = true
        Choice.generateChoice()
    end
end


return State
