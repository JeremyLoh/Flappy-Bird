# bird-1: Parallax Update

Parallax scrolling is a technique in computer graphics where background images move past the camera more slowly than foreground images, creating an illusion of depth in a 2D scene of distance. The technique grew out of the multiplane camera technique used in traditional animation since the 1930s

- https://en.wikipedia.org/wiki/Parallax_scrolling

```Lua
-- Load images into memory from files, to draw onto the screen
local background = love.graphics.newImage("background.png")
local backgroundScroll = 0
local ground = love.graphics.newImage("ground.png")
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 25
local GROUND_SCROLL_SPEED = 60
local BACKGROUND_LOOPING_POINT = 413
```

1. Keep track of scroll amount for images

```Lua
function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    push:finish()
end
```

1. Draw based on scroll amound set for x-axis

```Lua
function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
end
```

1. Limit the `backgroundScroll` value to be within 0 and (`BACKGROUND_LOOPING_POINT` - 1).
1. Limit the `groundScroll` to be within `VIRTUAL_WIDTH`
