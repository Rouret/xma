local Player = require("player.init")
local GlobalState = require("game.state")
local UI = require("game.ui")
local State = require("player.state")
local Timer = require("timer")
local World = require("game.world")
local Game = require("game.game")
local Choice = require("game.choice")
local Camera = require("engine.camera")
local Map = require("engine.map.map")
local Debug = require("engine.debug")
local Config = require("config")
local TestEnemy = require("enemies.test_enemy")
local enemies = {}
local map

function generateRandomString(length)
    local chars = "0123456789"
    local randomString = ""

    for i = 1, length do
        local randIndex = love.math.random(1, #chars)
        randomString = randomString .. chars:sub(randIndex, randIndex)
    end

    return randomString
end

function love.load()
    Debug.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    local seed = tonumber(generateRandomString(17))
    print("Seed: " .. string.format("%x", seed))
    love.math.setRandomSeed(seed)

    World.load()
    map = Map.new(World.world)
    Camera.init(State.x, State.y, 1, map)
    Choice.load()
    Player.load(World.world)
    UI.load()

    local enemy =
        TestEnemy:new(
        {
            x = State.x + 500,
            y = State.y + 500,
            speed = 100,
            radius = 20,
            health = 500,
            maxHealth = 500
        }
    )
    table.insert(enemies, enemy)

    print(enemy)
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

    Debug.update(dt)
    for _, enemy in ipairs(enemies) do
        enemy:update(dt, World.World)
    end

    if not Config.MODE_FREE_CAMERA then
        World.update(dt)
        Timer:update(dt)
        Player.update(dt)
        Camera.i:setPosition(State.x, State.y)
    end

    GlobalState:update(dt, World.World)
end

function love.draw()
    Camera.i:apply()

    map:draw()
    World:draw()
    GlobalState:draw()
    Player.draw()
    Camera.i:reset()
    UI:draw()

    -- draw enemy
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    if Choice.hasGeneratedChoices then
        Choice.draw()
    end
    Debug.draw()
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
    if key == "escape" then
        Game.isGamePaused = not Game.isGamePaused
    end

    Debug.keypressed(key)
end
