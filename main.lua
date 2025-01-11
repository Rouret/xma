local Player = require("player.init")
local StationaryEnemy = require("enemies.stationary_enemy")
local GlobalState = require("game.state")
local UI = require("game.ui")
local Timer = require("timer")
local World = require("game.world")
local enemies = {}

function love.load()
    World.load()
    
    Player.load(World.world)
    table.insert(enemies, StationaryEnemy.new(400, 300, World.world))
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
