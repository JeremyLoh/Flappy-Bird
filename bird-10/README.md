# bird-10: Audio update

Adds audio for the game:

1. Background music (Samuel Truth - Rua https://www.youtube.com/watch?v=5DIdmFcUa4c)
1. Score sound effect (`score.wav`)
1. Jump sound effect (`jump.wav`)
1. Collision sound effect (from `explosion.wav` and `hurt.wav`)

```Lua
-- Create sounds
function love.load()
    -- ...
    sounds = {
        ["jump"] = love.audio.newSource("sounds/jump.wav", "static"),
        ["hurt"] = love.audio.newSource("sounds/hurt.wav", "static"),
        ["explosion"] = love.audio.newSource("sounds/explosion.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
    }

    backgroundMusic = love.audio.newSource("sounds/Samuel Truth - Black & White - 02 Rua.mp3", "stream")
    backgroundMusic:setVolume(0.7)
    backgroundMusic:setLooping(true)
    backgroundMusic:play()
end
```
