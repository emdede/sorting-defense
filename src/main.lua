Class = require 'class'

require 'Game'
require 'Hud'
require 'Popup'
require 'Textfield'

-- Resizing factor
local sizemod = 1

-- Globals that other modules use as well
xp = 0
leveltimer = 0
ls_cannon_unlocked = false
bs_cannon_unlocked = false
bomb_unlocked = false
freeze_unlocked = false
charge_constant = 0.75
track_playing = 1
sounds = true

-- Small and Big font
defFont = love.graphics.newFont('graphics/pixellari.ttf')
bigFont = love.graphics.newFont('graphics/pixellari.ttf', 20)

-- Main gamedata that I do not want to be global
local cursor = love.image.newImageData('graphics/cursor.png')
cursor = love.mouse.newCursor(cursor, 10, 10)
love.mouse.setCursor(cursor)
local currentX = 0
local currentY = 0
local gamestate = 'Start'
local level = 1
local phase = 1
-- Music
local gametheme = love.sound.newSoundData('sounds/theme1.wav')
local menutheme = love.sound.newSoundData('sounds/theme2.wav')
local lettersound = love.sound.newSoundData('sounds/barhit.wav')
-- Variables to bullet Level Completion text
local levelstringtimer = 0
local levelstringlength = 0
-- Docs and Settings
local popup = nil
-- Story popup
local prof = nil
-- Menu background
local menubg = love.graphics.newImage('graphics/menubg.png')
local menu_delay = 0
local step = -1
local menubg_x = -1
local title = love.graphics.newImage('graphics/title.png')
local levelcomplete = love.graphics.newImage('graphics/levelcomplete.png')
local termination_messages = {'LEVEL COMPLETE', 'GAME OVER', 'VICTORY!'}
local sub_messages = {'Click to continue', 'Click to restart level', 'You are amazing!'}
local termination_index = nil
-- Variable to be able to restore last gamestate before pausing with space
local last_gamestate = nil

-- States table, used in draw function
local GAMESTATES = {
    ['Pausescreen'] = function()
        love.graphics.setColor(0.1,0.1,0.1,0.7)
        love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("Game Paused - Press 'Space' to continue", 0, 400, 1280 * sizemod, "center")
    end,
    ['Popup'] = function()
        if prof ~= nil then
            prof:render()
        end
        if popup ~= nil then
            popup:render()
        end
    end,
    ['Level Termination'] = function()
        local x = math.floor((love.graphics.getWidth() - levelcomplete:getWidth()) / 2)
        local y = math.floor((love.graphics.getHeight() - levelcomplete:getHeight()) / 2)
        love.graphics.setColor(1,1,1,levelstringtimer * 2)
        love.graphics.draw(levelcomplete, x, y)
        love.graphics.setColor(0,0,0,1)
        love.graphics.setFont(bigFont)
        love.graphics.printf(string.sub(termination_messages[termination_index], 1, levelstringlength), 0, math.floor(love.graphics.getHeight()/2) - 10, love.graphics.getWidth(), "center")
        love.graphics.setFont(defFont)
        if levelstringtimer >= 1 then
            love.graphics.printf(sub_messages[termination_index], 0, y + levelcomplete:getHeight() - 20, love.graphics.getWidth(), 'center')
        end
    end,
    ['Level Fade Out'] = function()
        love.graphics.setColor(0,0,0,levelstringtimer)
        love.graphics.rectangle('fill',0,0,1280,720)
    end,
    ['Level Fade In'] = function()
        love.graphics.setColor(0,0,0,levelstringtimer)
        love.graphics.rectangle('fill',0,0,1280,720)
    end,
    ['Default'] = function()
    end }


-- Initialize game modules
function love.load()
    -- Set up Screen
    local WINDOW_WIDTH = 1280
    local WINDOW_HEIGHT = 720
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        fullscreentype = 'exclusive',
        resizable = true,
        vsync = true
    })
    love.window.setTitle('SSS')
    
    love.graphics.setFont(defFont)
    theme = love.audio.newSource(menutheme, 'stream')
    theme:setLooping(true)
    theme:play()

    game = Game()
    hud = Hud(game)
    hud.level = level
end

function love.update(dt)
    -- Flow control - Manage states
    currentX = love.mouse.getX()
    currentY = love.mouse.getY()
    if gamestate == 'Default' then
        game:update(dt, currentX, currentY)
        hud:update(dt, currentX, currentY)
    elseif gamestate == 'Popup' then
        if popup then
            popup:update(dt, currentX, currentY)
        end
        if prof ~= nil then
            prof:update(dt)
        end
    elseif gamestate == 'Start' then
        -- Scrolling background
        menu_delay = menu_delay + dt
        if menu_delay > 0.25 then
            if menubg_x + step + menubg:getWidth() == 1281 or menubg_x + step == -1 then
                step = - step
            end
            menubg_x = menubg_x + step 
            menu_delay = menu_delay - 0.25
        end
    -- Timing letter generation
    elseif gamestate == 'Level Termination' then
        levelstringtimer = levelstringtimer + dt
        local target_length = string.len(termination_messages[termination_index])
        if levelstringtimer >= 0.6 and levelstringlength < target_length then
            levelstringtimer = levelstringtimer - 0.1
            if levelstringlength < target_length then
                levelstringlength = levelstringlength + 1
                if sounds then
                    local lettereffect = love.audio.newSource(lettersound)
                    lettereffect:play()
                end
            end
        end
    elseif gamestate == 'Level Fade Out' then
        levelstringtimer = levelstringtimer + dt
        if levelstringtimer > 1.5 then
            levelstringtimer = 1
            level_clear()
        end
    elseif gamestate == 'Level Fade In' then
        levelstringtimer = levelstringtimer - dt
        if levelstringtimer <= 0 then
            gamestate = 'Default'
        end
    end
end

local function drawmenu()
    love.graphics.draw(menubg, menubg_x, 0)
    love.graphics.setFont(bigFont)
    love.graphics.draw(title, 150, 250)
    local x = 1020
    local y = 780 / 2
    local button_texts = { "Start Game", "Quit" }
    for i = 1, 2 do
        if currentX > x and currentX < x + 180 and currentY > y and currentY < y + 40 then
            love.graphics.setColor(0,0.5,0.5,0.5)
        else
            love.graphics.setColor(0,0,0,0.5)
        end
        love.graphics.rectangle("fill", x, y, 180, 40, 2, 2)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(button_texts[i], x, y+14, 180, "center")
        y = y + 50
    end
end

-- Graphics function
function love.draw()
    -- Push to translate game to resized screen
    love.graphics.push()
    
    love.graphics.translate(0, sizemod)
    love.graphics.scale(sizemod,sizemod)

    -- Render game according to states
    if gamestate == 'Start' then
        drawmenu(menubg_x)
    else
        game:render()
        hud:render(gamestate)
        -- Draw anything else that might pop up like Docs and Dialogue
        GAMESTATES[gamestate]()
    end
    love.graphics.pop()
end

-- Check for mouse events
function love.mousepressed(x, y, click)
    -- If game is in a paused state ignore inputs that would affect gameplay
    if gamestate == 'Pausescreen' then
        return
    -- Level transition
    elseif gamestate == 'Level Termination' and levelstringlength == string.len(termination_messages[termination_index]) then
            if termination_index == 1 then
                gamestate = 'Level Fade Out'
                -- Restart level after Game Over
            elseif termination_index == 2 then
                gamestate = 'Default'
            else
                popup = Popup('Docs')
                gamestate = 'Popup'
            end
            levelstringtimer = 0
    elseif click == 1 and gamestate ~= 'Start' then
        -- If there is a Popup (Settings or Docs) check for a click here first
        if popup ~= nil then
            if popup:clicked(x, y) == 'Close' then
                popup = nil
                -- Continue normal gameplay when closing only if there is not a story text playing right now
                if prof == nil then
                    gamestate = 'Default'
                end
            end
            return
        end
        -- Click on Buttons in top right corner
        for i, button in ipairs(hud.buttons) do
            if hud:clicked(button, x, y) then
                popup = nil
                popup = Popup(button.type)
                gamestate = 'Popup'
            end
        end
        if gamestate == 'Default' then
            if not game.charging and not (game.cannon_index == 2 and level == 3 and phase < 4) then
                game:shoot(x, y)
            end
        elseif prof and popup == nil then
            if prof:click() == false then
                prof = nil
                gamestate = 'Default'
            end
        end
        -- Charge sorting beam with rightclick
    elseif click == 2 and gamestate == 'Default' and game.chargeable then
        game.charging = true
        
        -- Text popup
    elseif click == 2 and gamestate == 'Popup' then
        popup = nil
        if prof == nil then
            gamestate = 'Default'
        end
        
        -- Startmenu
    elseif gamestate == 'Start' then
        if currentX > 1020 and currentX < 1200 and currentY > 390 and currentY < 430 then
            theme:stop()
            theme = love.audio.newSource(gametheme)
            theme:setLooping(true)
            theme:play()
            gamestate = 'Default'
        elseif currentX > 1020 and currentX < 1200 and currentY > 440 and currentY < 480 then
            love.event.quit()
        end
    end
end

function love.mousereleased(x,y, button, istouch, presses)
    if button == 2 and game.chargetime >= charge_constant then
        game:shootBeam(x, y)
    elseif button == 2 and game.charging == true then
        game:cancelCharge()
    end
end

-- Check key inputs
function love.keypressed(key)
    
    -- Pause/unpause game
    if key == 'space' then
        if gamestate == 'Pausescreen' then
            gamestate = last_gamestate
            last_gamestate = nil
        else
            last_gamestate = gamestate
            gamestate = 'Pausescreen'
        end
    end

    -- Ignore key inputs that would affect gameplay if game is paused
    if gamestate == 'Default' then
        if key == '1' then
            game:switchCannon(1)
        elseif key == '2' and bs_cannon_unlocked then
            game:switchCannon(2)
        elseif key == '3' and bst_cannon_unlocked then
            game:switchCannon(3)
        elseif key == 'q' and game.bomb_ready then
            game:bomb()
        elseif key == 'w' and game.freeze_ready then
            game:freeze()
        end
    end
end


-- Resize window (called on default because of fullscreen)
function love.resize(w, h)
    -- Get factor for mouse positioning
    sizemod = love.graphics.getWidth() / WINDOW_WIDTH
end


function prompt_story()
    prof = Textfield(level, phase)
    gamestate = 'Popup'
    phase = phase + 1
end

function prompt_reminder(text)
    prof = Textfield(text, 0)
    gamestate = 'Popup'
end

function change_music(track)
    if track_playing ~= '0' then
        theme:stop()
    end
    if track == '1' then
        theme = love.audio.newSource(gametheme, 'stream')
        theme:setLooping(true)
        theme:play()
    elseif track == '2' then
        theme = love.audio.newSource(menutheme, 'stream')
        theme:setLooping(true)
        theme:play()
    else
        theme = nil
    end
    track_playing = track
end

local function set_game_variables()
    game.enemies = {}
    game.bullets = {}
    game.boss = {}
    phase = 1
    leveltimer = 0
    game.win_condition = false
    game.storyphase = 'Default'
    game.story_condition = true
    if level == 1 then
        ls_cannon_unlocked = false
        game.story_prompts = 3
    elseif level == 2 then
        bomb_unlocked = false
        game.bomb_ready = false
        game.freeze_ready = false
        game.enemy_interval = 5
    elseif level == 3 then
        bs_cannon_unlocked = false
        game.bomb_ready = true
        game.freeze_ready = false
        game.enemy_interval = 3
    elseif level == 4 then
        game.bomb_ready = true
        game.freeze_ready = true
        game.enemy_interval = 9
        freeze_unlocked = true
    end
end

function level_clear()
    if gamestate == 'Level Fade Out' then
        level = level + 1
        hud.level = level
        game.updatefunction = require('leveldata/level' .. tostring(level))
        set_game_variables()
        gamestate = 'Level Fade In'
    else
        gamestate = 'Level Termination'
        levelstringtimer = 0
        levelstringlength = 0
        termination_index = 1
    end
end

function game_over()
    gamestate = 'Level Termination'
    set_game_variables()
    levelstringtimer = 0
    levelstringlength = 0
    termination_index = 2
end

function victory()
    gamestate = 'Level Termination'
    termination_index = 3
end