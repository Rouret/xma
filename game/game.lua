local Game = {}

function Game.load()
    Game.isGamePaused = false
    Game.needToGenerateChoice = false

    return Game
end

return Game
