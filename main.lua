local Player = require("player.init")
local GlobalState = require("game.state")
local UI = require("game.ui")
local State = require("player.state")
local Timer = require("engine.timer")
local World = require("game.world")
local Game = require("game.game")
local Camera = require("engine.camera")
local Map = require("engine.map.map")
local Debug = require("engine.debug")
local Config = require("config")
local EnemyManager = require("engine.enemy.enemymanger")

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
    print("Welcome to Xma")

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Custom cursor
    local cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0)
    love.mouse.setCursor(cursor)

    -- Seed
    local seed = tonumber(generateRandomString(17))
    print("Seed: " .. string.format("%x", seed))
    love.math.setRandomSeed(seed)

    -- Init
    World.load()
    local map = Map.load(World.world)
    Camera.init(State.x, State.y, 1, map)
    Player.load(World.world)
    UI.load()
    Debug.load(map)

    -- TP the player close to the beacon
    local beacon = map.beacon
    if beacon then
        local spawnX = beacon.x + beacon.width / 2 + 50
        local spawnY = beacon.y + beacon.height / 2 + 50
        State.body:setPosition(spawnX, spawnY)
        State.x = spawnX
        State.y = spawnY
    end
end

function love.update(dt)
    -- Mettre à jour le choix si le jeu est en pause
    if Game.isGamePaused then
        World.update(dt)
        return
    end

    Debug.update(dt)

    if not Config.MODE_FREE_CAMERA then
        EnemyManager.update(dt)
        World.update(dt)
        Timer:update(dt)
        Player.update(dt)
        Camera.i:setPosition(State.x, State.y)
    end

    GlobalState:update(dt, World.World)
end

function love.draw()
    Camera.i:apply()

    Map.draw()
    World:draw()
    GlobalState:draw()
    Player.draw()
    Camera.i:reset()
    UI:draw()

    Debug.draw()
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        Game.isGamePaused = not Game.isGamePaused
    end

    Debug.keypressed(key)
end

function love.keyreleased(key)
    Debug.keyreleased(key)
end
