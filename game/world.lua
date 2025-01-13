local World = {}

function World.load()
    World.world = love.physics.newWorld(0, 0, true)
    World.world:setCallbacks(World.beginContact)
    World.width = love.graphics.getWidth()
    World.height = love.graphics.getHeight()

    -- Création des limites du monde (bords)
    edges = {}
    local function createEdge(x1, y1, x2, y2)
        local edgeBody = love.physics.newBody(World.world, 0, 0, "static")
        local edgeShape = love.physics.newEdgeShape(x1, y1, x2, y2)
        local edgeFixture = love.physics.newFixture(edgeBody, edgeShape)
        table.insert(edges, {body = edgeBody, shape = edgeShape, fixture = edgeFixture})
    end

    -- createEdge(0, 0, World.width, 0) -- Bord supérieur
    -- createEdge(0, 0, 0, World.height) -- Bord gauche
    -- createEdge(World.width, 0, World.width, World.height) -- Bord droit
    -- createEdge(0, World.height, World.width, World.height) -- Bord inférieur

    return World
end

function World.update(dt)
    World.world:update(dt) -- Mettre à jour la physique
end

function World:draw()
    love.graphics.setColor(1, 1, 1)
    for _, edge in ipairs(edges) do
        love.graphics.line(edge.shape:getPoints())
    end
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

return World
