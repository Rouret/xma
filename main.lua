local Player = require("player.init")
local ChasingEnemy = require("enemies.chasing_enemy")
local GlobalState = require("game.state")
local UI = require("game.ui")
local State = require("player.state")
local Timer = require("timer")
local World = require("game.world")
local Game = require("game.game")
local Choice = require("game.choice")
local Camera = require("engine.camera")
local Map = require("engine.map.map")
local ProFi = require("engine.profiler")
local enemies = {}
local nbMonster = 3
local map

local PROFILING = false
local MODE_FREE_CAMERA = false
local CAMERA_SPEED = 3000

function generateRandomString(length)
    local chars = "0123456789"
    local randomString = ""

    for i = 1, length do
        local randIndex = love.math.random(1, #chars)
        randomString = randomString .. chars:sub(randIndex, randIndex)
    end

    return randomString
end

function love.load(args)
    love.graphics.setDefaultFilter("nearest", "nearest")
    print("F1: Start profiling")
    print("F2: Stop profiling")
    print("F3: Toggle free camera mode")
    print("F8: Restart")

    local seed = tonumber(generateRandomString(17))
    print("Seed: " .. string.format("%x", seed))
    love.math.setRandomSeed(seed)

    World.load()
    map = Map.new(World.world)
    Camera.init(State.x, State.y, 1, map)
    Choice.load()
    Player.load(World.world)
    UI.load()

    -- generateEnemiesFromPlayerLevel(nbMonster)
end

function love.update(dt)
    -- Générer un choix si nécessaire
    if Game.needToGenerateChoice then
        Choice.generateChoice()
        Game.needToGenerateChoice = false
        return
    end

    -- Mettre à jour le choix si le jeu est en pause
    if Game.isGamePaused then
        World.update(dt)
        Choice.update(dt)
        return
    end

    if MODE_FREE_CAMERA then
        if love.keyboard.isDown("z") then
            Camera.i.y = Camera.i.y - CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("s") then
            Camera.i.y = Camera.i.y + CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("q") then
            Camera.i.x = Camera.i.x - CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("d") then
            Camera.i.x = Camera.i.x + CAMERA_SPEED * dt
        end
    else
        World.update(dt)
        Timer:update(dt)
        Player.update(dt)
        Camera.i:setPosition(State.x, State.y)
    end

    -- Mettre à jour tous les ennemis
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, World.world)

        -- Supprimer les ennemis morts
        if not enemy:isAlive() then
            table.remove(enemies, i)
        end
    end

    -- Ajouter des ennemis si nécessaire
    if #enemies < nbMonster then
    -- generateEnemiesFromPlayerLevel(nbMonster)
    end

    GlobalState:update(dt, World.World)
end

function love.draw()
    Camera.i:apply()

    map:draw(camera)
    World:draw()
    Player.draw()
    drawEnemies()
    GlobalState:draw()

    Camera.i:reset()

    UI:draw()

    if Choice.hasGeneratedChoices then
        Choice.draw()
    end
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function love.mousepressed(x, y, button)
    Choice.mousepressed(x, y, button)
end

--de zoom when scrolling
function love.wheelmoved(x, y)
    Camera.i.scale = Camera.i.scale + y * 0.1
end

function love.keypressed(key)
    -- if key is F1
    if key == "f1" then
        print("Start profiling")
        ProFi:start()
    end
    if key == "f2" then
        print("Stop profiling")
        ProFi:stop()
        ProFi:writeReport("profiler.txt")
        love.event.quit()
    end
    if key == "f8" then
        -- restart
        love.event.quit("restart")
    end
    if key == "escape" then
        Game.isGamePaused = not Game.isGamePaused
    end
    if key == "f3" then
        MODE_FREE_CAMERA = not MODE_FREE_CAMERA
        print("Free Camera Mode: " .. tostring(MODE_FREE_CAMERA))
    end
end

function generateEnemiesFromPlayerLevel(nbMonster)
    for i = #enemies + 1, nbMonster do
        local x = love.math.random(0, love.graphics.getWidth())
        local y = love.math.random(0, love.graphics.getHeight())
        local enemy =
            ChasingEnemy:new(
            {
                x = x,
                y = y,
                speed = 100 + State.level * 10,
                radius = 20,
                health = 100 + State.level * 10,
                maxHealth = 100 + State.level * 10
            }
        )
        table.insert(enemies, enemy)
    end
    return enemies
end

function drawEnemies()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
end
