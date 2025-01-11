local World = {}

function World.load()
    World.world = love.physics.newWorld(0, 0, true)
    World.world:setCallbacks(World.beginContact)

    -- Définir les murs qui sont au niveau des bords de l'écran
    World.walls = {}

    -- Mur gauche en rouge
    World.walls.left = {}
    World.walls.left.body = love.physics.newBody(World.world, 0, love.graphics.getHeight() / 2, "static")
    World.walls.left.shape = love.physics.newRectangleShape(0, 0, 1, love.graphics.getHeight())
    World.walls.left.fixture = love.physics.newFixture(World.walls.left.body, World.walls.left.shape)
    World.walls.left.fixture:setUserData(World.walls.left)
    -- Mur droite en rouge
    World.walls.right = {}
    World.walls.right.body = love.physics.newBody(World.world, love.graphics.getWidth() + 1, love.graphics.getHeight() / 2, "static")
    World.walls.right.shape = love.physics.newRectangleShape(0, 0, 1, love.graphics.getHeight())
    World.walls.right.fixture = love.physics.newFixture(World.walls.right.body, World.walls.right.shape)
    World.walls.right.fixture:setUserData(World.walls.right)

    -- Mur haut en rouge
    World.walls.top = {}
    World.walls.top.body = love.physics.newBody(World.world, love.graphics.getWidth() / 2, -1, "static")
    World.walls.top.shape = love.physics.newRectangleShape(0, 0, love.graphics.getWidth(), 1)
    World.walls.top.fixture = love.physics.newFixture(World.walls.top.body, World.walls.top.shape)
    World.walls.top.fixture:setUserData(World.walls.top)


    -- Mur bas en rouge
    World.walls.bottom = {}
    World.walls.bottom.body = love.physics.newBody(World.world, love.graphics.getWidth() / 2, love.graphics.getHeight(), "static")
    World.walls.bottom.shape = love.physics.newRectangleShape(0, 0, love.graphics.getWidth(), 1)
    World.walls.bottom.fixture = love.physics.newFixture(World.walls.bottom.body, World.walls.bottom.shape)
    World.walls.bottom.fixture:setUserData(World.walls.bottom)
    return World
end


function World.update(dt)
    World.world:update(dt) -- Mettre à jour la physique
end

function World:draw()
    -- Dessiner les murs
    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.polygon("fill", World.walls.left.body:getWorldPoints(World.walls.left.shape:getPoints()))
    love.graphics.polygon("fill", World.walls.right.body:getWorldPoints(World.walls.right.shape:getPoints()))
    love.graphics.polygon("fill", World.walls.top.body:getWorldPoints(World.walls.top.shape:getPoints()))
    love.graphics.polygon("fill", World.walls.bottom.body:getWorldPoints(World.walls.bottom.shape:getPoints()))
    love.graphics.setColor(1, 1, 1) -- Reset color to white
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
