local Player = require("player.init")
local StationaryEnemy = require("enemies.stationary_enemy")
local GlobalState = require("game.state")
local Timer = require("timer")

local enemies = {}
local world

function love.conf(t)
    t.window.title = "Xma"
    t.version = "0.1"   
    t.window.fullscreen = true
end

function love.load()
    -- Créer le monde physique
    world = love.physics.newWorld(0, 0, true) -- Pas de gravité

    love.window.setMode(0, 0, {fullscreen=true})

    Player.load(world)
    table.insert(enemies, StationaryEnemy.new(400, 300, world))
end

function love.update(dt)
    world:update(dt) -- Mettre à jour la physique

    Timer:update(dt)
    Player.update(dt)

    GlobalState:update(dt)

    -- Mettre à jour tous les ennemis
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, player)

        -- Supprimer les ennemis morts
        if not enemy:isAlive() then
            table.remove(enemies, i)
        end
    end

end

function love.draw()
    Player.draw()

    GlobalState:draw()

    -- Dessiner tous les ennemis
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
   
end
