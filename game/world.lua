local World = {}

function World.load()
    World.world = love.physics.newWorld(0, 0, true)
    World.world:setCallbacks(World.beginContact)
    return World
end

function World.update(dt)
    World.world:update(dt) -- Mettre à jour la physique
end

function World.beginContact(fixtureA, fixtureB, contact)
    local userDataA = fixtureA:getUserData()
    local userDataB = fixtureB:getUserData()

    -- print de debug
    print("Collision entre " .. tostring(userDataA.name) .. " et " .. tostring(userDataB.name))

    -- Vérifiez si l'une des entités est une balle
    if userDataA and userDataA.onCollision then
        userDataA:onCollision(userDataB)
    end

    if userDataB and userDataB.onCollision then
        userDataB:onCollision(userDataA)
    end
end

return World
