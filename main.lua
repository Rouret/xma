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
    print("Welcome to Xma")

    love.graphics.setDefaultFilter("nearest", "nearest")

    local seed = tonumber(generateRandomString(17))
    print("Seed: " .. string.format("%x", seed))
    love.math.setRandomSeed(seed)

    World.load()
    map = Map.new(World.world)
    Camera.init(State.x, State.y, 1, map)
    Player.load(World.world)
    UI.load()
    Debug.load(map)
end

function love.update(dt)
    -- Mettre à jour le choix si le jeu est en pause
    if Game.isGamePaused then
        World.update(dt)
        return
    end

    Debug.update(dt)

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

    Debug.draw()
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        Game.isGamePaused = not Game.isGamePaused
    end

    Debug.keypressed(key)
end
