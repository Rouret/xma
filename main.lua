local Player = require("player.init")
local StationaryEnemy = require("enemies.stationary_enemy")
local GlobalState = require("game.state")
local Timer = require("timer")
local World = require("game.world")
local enemies = {}


function love.conf(t)
    t.window.title = "Xma"
    t.version = "0.1"   
    t.window.fullscreen = true
end

function love.load()
    World.load()

    love.window.setMode(0, 0, {fullscreen=true})

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
    Player.draw()

  
    -- Dessiner tous les ennemis
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    GlobalState:draw()

   
end
