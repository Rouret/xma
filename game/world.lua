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

    if(userDataA == nil or userDataB == nil) then
        return
    end

    if userDataA and userDataA.onCollision then
        userDataA:onCollision(userDataB)
    end

    if userDataB and userDataB.onCollision then
        userDataB:onCollision(userDataA)
    end
end

return World
