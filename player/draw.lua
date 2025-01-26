local State = require("player.state")
local Draw = {}

function Draw.draw()
    -- Dessiner le joueur black
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", State.x, State.y, State.radius)

    -- reset color
    love.graphics.setColor(1, 1, 1)

    -- Draw weapon
    local weapon = State.weapons[State.currentWeaponIndex]
    if weapon then
        weapon:draw()
    end
end

return Draw
