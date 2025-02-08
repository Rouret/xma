local State = {}
local love = require("love")

function State.load()
    State.name = "player"
    State.status = "idle" -- Example: "idle", "immobilized"

    -- Position
    State.x = 50 * 32
    State.y = 50 * 32

    -- Effects
    State.effects = {}

    -- Velocity
    State.speed = 1000

    -- Stamina
    State.stamina = 100
    State.maxStamina = 100
    State.staminaRegen = 10
    State.staminaRegenCooldown = 2

    -- Health
    State.health = 100
    State.maxHealth = 100
    State.radius = 10

    -- Damage
    State.damage = 1000

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

    State.temp = 0
end

function State.switchWeapon()
    if #State.weapons > 0 then
        State.currentWeaponIndex = (State.currentWeaponIndex % #State.weapons) + 1
    end
end

function State.getCurrentWeapon()
    return State.weapons[State.currentWeaponIndex] or nil
end

function State.getNextWeapon()
    return State.weapons[(State.currentWeaponIndex % #State.weapons) + 1] or nil
end

function State.canSwitchWeapon()
    return love.timer.getTime() - State.weaponSwitchTime > State.WEAPON_SWITCH_COOLDOWN
end

function State.takeDamage(amount)
    print("Taking damage: " .. amount)
    State.health = State.health - amount

    if State.health <= 0 then
        love.event.quit()
    end
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
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local playerScreenX = screenWidth / 2
    local playerScreenY = screenHeight / 2
    return math.atan2(mouseY - playerScreenY, mouseX - playerScreenX)
end

function State.gainExperience(amount)
    State.experience = State.experience + amount
    if State.experience >= State.level * 100 then
        State.level = State.level + 1
        State.experience = 0
    end
end
function State.addEffect(effect)
    local existingEffect = nil
    for _, e in ipairs(State.effects) do
        if e.name == effect.name then
            existingEffect = e
            break
        end
    end

    if existingEffect then
        existingEffect.duration = math.max(existingEffect.duration, effect.duration)
    else
        table.insert(State.effects, effect)
        effect:apply(State)
    end
end

function State:updateEffects(dt)
    for i = #State.effects, 1, -1 do
        local effect = State.effects[i]
        if not effect:update(dt, State) then
            table.remove(State.effects, i)
        end
    end
end

function State.hasEffect(effectName)
    for _, effect in ipairs(State.effects) do
        if effect.name == effectName then
            return true
        end
    end
    return false
end

return State
