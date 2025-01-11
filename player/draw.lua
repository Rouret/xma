local State = require("player.state")
local Draw = {}

function Draw.draw()
    -- Dessiner le joueur
    love.graphics.circle("fill", State.x, State.y, State.radius)

    -- Draw weapon
    local weapon = State.weapons[State.currentWeaponIndex]
    weapon:draw()
end

return Draw
