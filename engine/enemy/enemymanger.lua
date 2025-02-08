local BiomeEnemies = require("engine.enemy.biomeenemies")
local GlobalState = require("game.state")
local Map = require("engine.map.map")
local State = require("player.state")
local EnemyManager = {}

EnemyManager.lastSpawnTimeA = 0
EnemyManager.lastSpawnTimeB = 0

local minSpawnRangeTypeA = 1000
local maxSpawnRangeTypeA = 2000
local maxTry = 10

function EnemyManager.getEnemiesForBiome(biomeName)
    return BiomeEnemies[biomeName] or {} -- Retourne la liste des ennemis pour ce biome
end

function EnemyManager.spawnEnemyA()
    print("spawnEnemyA")
    local randomRange = love.math.random(minSpawnRangeTypeA, maxSpawnRangeTypeA)
    local randomX, randomY
    local try = 0
    local found = false

    while try < maxTry do
        -- Génération des coordonnées en tenant compte du range
        randomX = love.math.random(Map.beacon.x - randomRange, Map.beacon.x + randomRange)
        randomY = love.math.random(Map.beacon.y - randomRange, Map.beacon.y + randomRange)

        -- Vérifier si les coordonnées respectent les limites de la carte
        if randomX >= 0 and randomX <= Map.WORLD_WIDTH and randomY >= 0 and randomY <= Map.WORLD_HEIGHT then
            found = true
            break
        end

        try = try + 1
    end

    if not found then
        print("Can't spawn enemy A")
        return
    end

    local biomeAtPosition = Map.getBiomeAtPosition(randomX, randomY)

    if not biomeAtPosition then
        print("No biome at this position")
        return
    end

    local biomeName = biomeAtPosition.name

    print("Biome name: " .. biomeName)

    local possibleEnemies = EnemyManager.getEnemiesForBiome(biomeName)

    if #possibleEnemies == 0 then
        print("No enemies for this biome")
        return
    end
    local enemyToInvoke = possibleEnemies[love.math.random(1, #possibleEnemies)]
    local enemy = enemyToInvoke:new({x = randomX, y = randomY})

    GlobalState:addEntity(enemy)

    EnemyManager.lastSpawnTimeA = love.timer.getTime()
end

function EnemyManager.spawnEnemyB()
    print("spawnEnemyB")
    EnemyManager.lastSpawnTimeB = love.timer.getTime()
end

function EnemyManager.update(dt)
    local currentTime = love.timer.getTime()

    -- Spawn des ennemis Type A (attaque le beacon)
    if currentTime - EnemyManager.lastSpawnTimeA > 5 then
        EnemyManager.spawnEnemyA()
        EnemyManager.lastSpawnTimeA = currentTime
    end

    -- Spawn des ennemis Type B (autour du joueur)
    if currentTime - EnemyManager.lastSpawnTimeB > 1000 then
        EnemyManager.spawnEnemyB()
        EnemyManager.lastSpawnTimeB = currentTime
    end
end

return EnemyManager
