local BiomeEnemies = require("engine.enemy.biomeenemies")
local GlobalState = require("game.state")
local Map = require("engine.map.map")
local Config = require("config")
local State = require("player.state")
local EnemyManager = {}

EnemyManager.lastSpawnTimeA = 0
EnemyManager.lastSpawnTimeB = 0
local maxTry = 10
local maxMultiplier = 5 -- Limite max pour éviter une explosion

-- Spawn
-- Type A
local minSpawnRangeTypeA = 200 * 32 -- 200 tiles
local maxSpawnRangeTypeA = 600 * 32 -- 400 tiles
local maxTypeA = 5
local minSpawnTimeTypeA = 10 -- secondes
local maxSpawnTimeTypeA = 20 -- secondes
local nextSpawnTimeTypeA = (maxSpawnTimeTypeA - minSpawnTimeTypeA) / 2
local maxRangeTypeA = 700 * 32 -- 1200 tiles
-- Type B
local minSpawnRangeTypeB = 150 * 32 -- 150 tiles
local maxSpawnRangeTypeB = 300 * 32 -- 300 tiles
local maxTypeB = 0
local minSpawnTimeTypeB = 4 -- secondes
local maxSpawnTimeTypeB = 10 -- secondes
local nextSpawnTimeTypeB = (maxSpawnTimeTypeB - minSpawnTimeTypeB) / 2
local maxRangeTypeB = 400 * 32 -- 700 tiles*

-- Session
local sessionDuration = 12 * 60 -- 12 minutes
local specialWaveDuration = 3 * 60 -- 3 minutes

local lastWaveChange = love.timer.getTime()
-- Difficulté
local kHealthMultiplier = math.log(2) / 30
local kSpeedMultiplier = math.log(1.15) / 30
local kDamageMultiplier = math.log(2.2) / 30

local waveModels = {
    speed = {spawnMultiplier = 1.5, healthMultiplier = 0.5, speedMultiplier = 2, damageMultiplier = 0.5},
    strong = {spawnMultiplier = 0.5, healthMultiplier = 3, speedMultiplier = 0.7, damageMultiplier = 2},
    swarm = {spawnMultiplier = 2, healthMultiplier = 0.7, speedMultiplier = 1.2, damageMultiplier = 0.7},
    sniper = {spawnMultiplier = 0.7, healthMultiplier = 1, speedMultiplier = 1.5, damageMultiplier = 2},
    mixed = {spawnMultiplier = 1, healthMultiplier = 1, speedMultiplier = 1, damageMultiplier = 1},
    berserk = {spawnMultiplier = 1, healthMultiplier = 1.5, speedMultiplier = 1.5, damageMultiplier = 1.5}
}
EnemyManager.currentHealthMultiplier = 1
EnemyManager.currentSpeedMultiplier = 1
EnemyManager.currentDamageMultiplier = 1
EnemyManager.currentWaveModel = waveModels.mixed
EnemyManager.waveNumber = 1

function EnemyManager.log(message)
    if Config.ENNEMIES_MANAGER_LOG then
        print(message)
    end
end

-- ======================== SPAWN
function EnemyManager.getEnemiesForBiome(biomeName)
    return BiomeEnemies[biomeName] or {} -- Retourne la liste des ennemis pour ce biome
end

function EnemyManager.exp(waveNumber, k)
    return math.exp(waveNumber * k)
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
            target = target,
            healthMultiplier = EnemyManager.currentWaveModel.healthMultiplier * EnemyManager.currentHealthMultiplier,
            speedMultiplier = EnemyManager.currentWaveModel.speedMultiplier * EnemyManager.currentSpeedMultiplier,
            damageMultiplier = EnemyManager.currentWaveModel.damageMultiplier * EnemyManager.currentDamageMultiplier
        }
    )

    GlobalState:addEntity(enemy)
end

-- ======================== UPDATE
function EnemyManager.update()
    local currentTime = love.timer.getTime()

    if EnemyManager.waveNumber % 2 == 0 then -- Current wave is a special wave
        if currentTime - lastWaveChange > specialWaveDuration then -- Special wave is over
            EnemyManager.log("Special wave is over")
            -- Update the multipliers
            EnemyManager.currentDamageMultiplier =
                math.min(EnemyManager.exp(EnemyManager.waveNumber, kDamageMultiplier), maxMultiplier)
            EnemyManager.currentHealthMultiplier =
                math.min(EnemyManager.exp(EnemyManager.waveNumber, kHealthMultiplier), maxMultiplier)
            EnemyManager.currentSpeedMultiplier =
                math.min(EnemyManager.exp(EnemyManager.waveNumber, kSpeedMultiplier), maxMultiplier)

            --Next wave is a normal wave
            EnemyManager.currentWaveModel = waveModels.mixed

            lastWaveChange = currentTime
            EnemyManager.waveNumber = EnemyManager.waveNumber + 1
        end
    else
        if currentTime - lastWaveChange > sessionDuration then -- Normal wave is over
            -- Next one is a special wave
            EnemyManager.log("Normal wave is over, next one is a special wave")
            local waveModelKeys = {}
            for key in pairs(waveModels) do
                table.insert(waveModelKeys, key)
            end
            local randomKey = waveModelKeys[love.math.random(1, #waveModelKeys)]
            EnemyManager.currentWaveModel = waveModels[randomKey]
            lastWaveChange = currentTime
            EnemyManager.waveNumber = EnemyManager.waveNumber + 1
        end
    end

    -- Spawn des ennemis Type A (attaque le beacon)
    if currentTime - EnemyManager.lastSpawnTimeA > nextSpawnTimeTypeA and GlobalState:getAEnemies() < maxTypeA then
        EnemyManager.spawnEnemy(minSpawnRangeTypeA, maxSpawnRangeTypeA, "A", "beacon")
        EnemyManager.lastSpawnTimeA = currentTime

        -- Random next spawn time
        nextSpawnTimeTypeA =
            love.math.random(minSpawnTimeTypeA, maxSpawnTimeTypeA) / EnemyManager.currentWaveModel.spawnMultiplier
    end

    -- Spawn des ennemis Type B (autour du joueur)
    if currentTime - EnemyManager.lastSpawnTimeB > nextSpawnTimeTypeB and GlobalState:getBEnemies() < maxTypeB then
        EnemyManager.spawnEnemy(minSpawnRangeTypeB, maxSpawnRangeTypeB, "B", "player")
        EnemyManager.lastSpawnTimeB = currentTime
        -- Random next spawn time
        nextSpawnTimeTypeB =
            love.math.random(minSpawnTimeTypeB, maxSpawnTimeTypeB) / EnemyManager.currentWaveModel.spawnMultiplier
    end

    -- Kill
    local enemies = GlobalState:getEntitiesByType("enemy")

    for _, enemy in ipairs(enemies) do
        if not enemy.enemiesType then
            return
        end

        if enemy.enemiesType == "A" then
            -- calculate the range beetween beacon and enemy
            local dx = Map.beacon.x - enemy.x
            local dy = Map.beacon.y - enemy.y
            if (dx * dx + dy * dy) > (maxRangeTypeA * maxRangeTypeA) then
                GlobalState:removeEntity(enemy)
            end
        end

        if enemy.enemiesType == "B" then
            -- calculate the range beetween beacon and enemy
            local dx = State.x - enemy.x
            local dy = State.y - enemy.y
            if (dx * dx + dy * dy) > (maxRangeTypeB * maxRangeTypeB) then
                GlobalState:removeEntity(enemy)
            end
        end
    end
end

return EnemyManager
