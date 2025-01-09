local State = require("player.state")
local Draw = {}

function Draw.draw()
    -- Dessiner le joueur
    love.graphics.circle("fill", State.x, State.y, 10)

    -- Draw weapon
    local weapon = State.weapons[State.currentWeaponIndex]
    love.graphics.print(weapon.name, State.x - 20, State.y + 20)
    for i, skill in ipairs(weapon.skills) do
        local cooldownText = skill.cooldown > 0 and " (Cooldown: " .. skill.cooldown .. "s)" or " (Ready)"
        love.graphics.print(i .. ": " .. skill.name .. cooldownText, State.x - 20, State.y + 20 + i * 10)
        weapon:draw()
    end
end

return Draw
