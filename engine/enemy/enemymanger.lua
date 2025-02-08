local BiomeEnemies = require("engine.enemy.biomeenemies")
local GlobalState = require("game.state")
local Map = require("engine.map.map")
local Config = require("config")

local EnemyManager = {}

EnemyManager.lastSpawnTimeA = 0
EnemyManager.lastSpawnTimeB = 0
local maxTry = 10

-- Type A
local minSpawnRangeTypeA = 200 * 32 -- 200 tiles
local maxSpawnRangeTypeA = 600 * 32 -- 400 tiles
local maxTypeA = 5
local minSpawnTimeTypeA = 10 -- secondes
local maxSpawnTimeTypeA = 20 -- secondes
local nextSpawnTimeTypeA = (maxSpawnTimeTypeA - minSpawnTimeTypeA) / 2
-- Type B
local minSpawnRangeTypeB = 150 * 32 -- 150 tiles
local maxSpawnRangeTypeB = 300 * 32 -- 300 tiles
local maxTypeB = 5
local minSpawnTimeTypeB = 4 -- secondes
local maxSpawnTimeTypeB = 10 -- secondes
local nextSpawnTimeTypeB = (maxSpawnTimeTypeB - minSpawnTimeTypeB) / 2

function EnemyManager.log(message)
    if Config.ENNEMIES_MANAGER_LOG then
        print(message)
    end
end

function EnemyManager.getEnemiesForBiome(biomeName)
    return BiomeEnemies[biomeName] or {} -- Retourne la liste des ennemis pour ce biome
end

function EnemyManager.spawnEnemy(minSpawnRangeType, maxSpawnRangeType, enemiesType, target)
    local randomRange = love.math.random(minSpawnRangeType, maxSpawnRangeType)
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
        print("Can't spawn enemy " .. enemiesType)
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

    local enemy =
        enemyToInvoke:new(
        {
            x = randomX,
            y = randomY,
            enemiesType = enemiesType,
            target = target
        }
    )

    GlobalState:addEntity(enemy)
end

function EnemyManager.update()
    local currentTime = love.timer.getTime()

    -- Spawn des ennemis Type A (attaque le beacon)
    if currentTime - EnemyManager.lastSpawnTimeA > nextSpawnTimeTypeA and GlobalState:getAEnemies() < maxTypeA then
        EnemyManager.log("Spawn enemy A")
        EnemyManager.spawnEnemy(minSpawnRangeTypeA, maxSpawnRangeTypeA, "beacon")
        EnemyManager.lastSpawnTimeA = currentTime

        -- Random next spawn time
        nextSpawnTimeTypeA = love.math.random(minSpawnTimeTypeA, maxSpawnTimeTypeA)
        EnemyManager.log("Next spawn time: " .. nextSpawnTimeTypeA)
    end

    -- Spawn des ennemis Type B (autour du joueur)
    if currentTime - EnemyManager.lastSpawnTimeB > nextSpawnTimeTypeB and GlobalState:getBEnemies() < maxTypeB then
        EnemyManager.log("Spawn enemy B")
        EnemyManager.spawnEnemy(minSpawnRangeTypeB, maxSpawnRangeTypeB, "B", "player")
        EnemyManager.lastSpawnTimeB = currentTime
        -- Random next spawn time
        nextSpawnTimeTypeB = love.math.random(minSpawnTimeTypeB, maxSpawnTimeTypeB)
        EnemyManager.log("Next spawn time: " .. nextSpawnTimeTypeB)
    end
end

return EnemyManager
