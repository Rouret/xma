local Player = require("player.init")
local StationaryEnemy = require("enemies.stationary_enemy")
local ChasingEnemy = require("enemies.chasing_enemy")
local GlobalState = require("game.state")
local UI = require("game.ui")
local Timer = require("timer")
local World = require("game.world")
local enemies = {}

local nbMonster = 3

function love.load()
    World.load()
    
    Player.load(World.world)

    UI.load()
    
    for i = 1, nbMonster do
        local enemy = ChasingEnemy.new(love.math.random(0, 800), love.math.random(0, 600))
        table.insert(enemies, enemy)
    end
end

function love.update(dt)
    World.update(dt)

    Timer:update(dt)
    Player.update(dt)

    -- Mettre à jour tous les ennemis
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, World.world)

        -- Supprimer les ennemis morts
        if not enemy:isAlive() then
            table.remove(enemies, i)
        end
    end

    --if table.remove(enemies, is less than nbMonster then add a new enemy)
    if #enemies < nbMonster then
        for i = #enemies + 1, nbMonster do
            local enemy = ChasingEnemy.new(love.math.random(0, 800), love.math.random(0, 600))
            table.insert(enemies, enemy)
        end
    end

    GlobalState:update(dt, World.World)
end

function love.draw()
    -- Draw world walls
    World:draw()
    Player.draw()

    -- Dessiner tous les ennemis
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    GlobalState:draw()

    UI:draw()
end
