local World = {}

function World.load()
    World.world = love.physics.newWorld(0, 0, true)
    World.world:setCallbacks(World.beginContact, World.endContact)
    World.width = love.graphics.getWidth()
    World.height = love.graphics.getHeight()

    World.delayCallbacks = {}

    return World
end

function World.update(dt)
    World.world:update(dt) -- Mettre à jour la physique

    if #World.delayCallbacks > 0 then
        for i = #World.delayCallbacks, 1, -1 do
            local callback = World.delayCallbacks[i]
            callback()
            table.remove(World.delayCallbacks, i)
        end
    end
end

function World:draw()
end

function World.beginContact(fixtureA, fixtureB, contact)
    local userDataA = fixtureA:getUserData()
    local userDataB = fixtureB:getUserData()

    if (userDataA == nil or userDataB == nil) then
        return
    end

    if userDataA and userDataA.onCollision then
        userDataA:onCollision(userDataB)
    end

    if userDataB and userDataB.onCollision then
        userDataB:onCollision(userDataA)
    end
end

function World.endContact(fixtureA, fixtureB, contact)
    local userDataA = fixtureA:getUserData()
    local userDataB = fixtureB:getUserData()

    if (userDataA == nil or userDataB == nil) then
        return
    end

    if userDataA and userDataA.onEndCollision then
        userDataA:onEndCollision(userDataB)
    end

    if userDataB and userDataB.onEndCollision then
        userDataB:onEndCollision(userDataA)
    end
end

return World
