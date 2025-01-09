local State = require("player.state")
local Interaction = {}

function Interaction.update(dt)
    -- Exemple : Appuyer sur une touche pour interagir ou attaquer
    if love.keyboard.isDown("space") then
        print("Player interacting...")
    end
end

return Interaction
