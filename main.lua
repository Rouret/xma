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
local enemies = {}
local nbMonster = 3
local map

function love.load()
    World.load()
    Camera.init(State.x, State.y, 1)
    Choice.load()
    Player.load(World.world)
    UI.load()
    map = Map.new(World.world)

    generateEnemiesFromPlayerLevel(nbMonster)
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

    World.update(dt)
    Timer:update(dt)
    Player.update(dt)

    Camera.i:setPosition(State.x, State.y)

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
        generateEnemiesFromPlayerLevel(nbMonster)
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
    if key == "escape" then
        Game.isGamePaused = not Game.isGamePaused
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
