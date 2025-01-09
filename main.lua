local player = require("player")
local Projectile = require("projectile")

local projectiles = {}

function love.conf(t)
    t.window.title = "Xma"
    t.version = "0.1"   
    t.window.fullscreen = true
end

function love.load()
    player.load()
    love.window.setMode(0, 0, {fullscreen=true})
end

function love.update(dt)
    player.update(dt)
    
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj:update(dt)
        if not proj:isAlive() then
            table.remove(projectiles, i)
        end
    end
end

function love.draw()
    player.draw()
    for _, proj in ipairs(projectiles) do
        proj:draw()
    end
end
