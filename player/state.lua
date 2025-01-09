local State = {}

function State.load()
    State.x = 10
    State.y = 10
    State.speed = 300
    State.health = 100
    State.maxHealth = 100
    State.status = "idle" -- Exemple : "idle", "moving", "attacking", "invincible"
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
