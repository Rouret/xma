local State = require("player.state")
local Movement = {}

function Movement.update(dt)
    if love.keyboard.isDown("q") then
        Movement.move(-1, 0, dt)
    end
    if love.keyboard.isDown("d") then
        Movement.move(1, 0, dt)
    end
    if love.keyboard.isDown("z") then
        Movement.move(0, -1, dt)
    end
    if love.keyboard.isDown("s") then
        Movement.move(0, 1, dt)
    end
end

function Movement.move(dx, dy, dt)
    State.x = State.x + dx * State.speed * dt
    State.y = State.y + dy * State.speed * dt
end

return Movement
