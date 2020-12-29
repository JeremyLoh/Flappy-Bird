# bird-11: Mouse update

Add mouse click control for the game

# Functions used

`love.mousepressed(x, y, button, istouch, presses)`

1. Callback function triggered when a mouse button is pressed.

1. Use `love.wheelmoved` to detect mouse wheel motion. It will not register as a button press in version 0.10.0 and newer.

1. `number x`

   Mouse x position, in pixels.

1. `number y`

   Mouse y position, in pixels.

1. `number button`

   The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.

1. `boolean istouch`

   True if the mouse button press originated from a touchscreen touch-press.

1. `number presses`

   The number of presses in a short time frame and small area, used to simulate double, triple clicks

`main.lua` changes

```Lua
function love.load()
    -- ...
    love.mouse.buttonsPressed = {}
end

function love.mousepressed(x, y, button, istouch, presses)
    primaryMouseButton = 1
    -- touchscreen touch-press or mouse click detected
    if button == primaryMouseButton or istouch then
        love.mouse.buttonsPressed["primary"] = true
    end
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    -- ...
    love.mouse.buttonsPressed = {}
end
```

`Bird.lua` changes

```Lua
function Bird:update(dt)
    self.dy = self.dy + (GRAVITY * dt)
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed("primary") then
        sounds["jump"]:play()
        self.dy = ANTI_GRAVITY
    end
    self.y = math.max(0, self.y + self.dy)
end
```
