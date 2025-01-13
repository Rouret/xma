local LayerGenerator = {}

-- Génère le sol
function LayerGenerator.generateGround(width, height, groundQuads)
    local tiles = {}
    for y = 1, height do
        tiles[y] = {}
        for x = 1, width do
            local randomGroundQuad = groundQuads[love.math.random(1, #groundQuads)]
            tiles[y][x] = {quad = randomGroundQuad, collision = false}
        end
    end
    return tiles
end

-- Génère les buissons avec clusters
function LayerGenerator.generateBushClusters(width, height, clusterCount, minSize, maxSize, bushQuad, world)
    local tiles = {}
    for y = 1, height do
        tiles[y] = {}
        for x = 1, width do
            tiles[y][x] = nil -- Initialisation vide
        end
    end

    for i = 1, clusterCount do
        local startX = love.math.random(1, width)
        local startY = love.math.random(1, height)
        local clusterSize = love.math.random(minSize, maxSize)

        LayerGenerator.growBushCluster(startX, startY, clusterSize, tiles, bushQuad, world, width, height)
    end

    return tiles
end

-- Fait croître un cluster de buissons
function LayerGenerator.growBushCluster(startX, startY, size, tiles, bushQuad, world, width, height)
    local directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}} -- Haut, droite, bas, gauche
    local bushCount = 0
    local queue = {{x = startX, y = startY}}

    while bushCount < size and #queue > 0 do
        local current = table.remove(queue, 1)
        local x, y = current.x, current.y

        if x >= 1 and x <= width and y >= 1 and y <= height and not tiles[y][x] then
            tiles[y][x] = {quad = bushQuad, collision = true}
            bushCount = bushCount + 1

            local body = love.physics.newBody(world, (x - 0.5) * 32, (y - 0.5) * 32, "static")
            local shape = love.physics.newRectangleShape(32, 32)
            local fixture = love.physics.newFixture(body, shape)
            fixture:setUserData({name = "wall"})

            for _, dir in ipairs(directions) do
                local nx, ny = x + dir[1], y + dir[2]
                if love.math.random() > 0.3 then
                    table.insert(queue, {x = nx, y = ny})
                end
            end
        end
    end
end

return LayerGenerator
