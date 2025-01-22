# README

For more information, please refer to the [Change Log](CHANGELOG.md).


# Add a biome

- Copy [Forest](engine\map\biomes\forest.lua)
- Add in "biomeFiles" [Map](engine\map\map.lua)
- Add condition in [BiomeGenerator](engine\map\biomeGenerator.lua)

- [Build](build.bat).
- [Version](version.text).


# Chat GPT context
Je dev un jeu avec Lua avec Love2D.
Le joueur évolue dans un monde en 2D avec une vue du dessus. Il se déplace en utilisant les touches Z, Q, S, D (les flèches directionnelles), et vise avec la souris.

Le joueur tient deux armes en main et peut passer de l'une à l'autre, avec un délai de recharge (cooldown) entre chaque changement d'arme. Chaque arme possède trois compétences distinctes, que le joueur peut utiliser en fonction de la situation.
