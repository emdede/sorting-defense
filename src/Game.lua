Game = Class{}

require 'Enemy'
require 'Bullet'

function Game:init()
    self.leveldata = require 'leveldata/level1'
    
    self.bullets = {}
    self.enemies = {}
    self.boss = {}
    -- Background image
    self.bg = love.graphics.newImage('graphics/bg.png')
    
    -- Weapon-related initialization
    self.cannons = { { sprite = 'graphics/bfcannon.png' }, { sprite = 'graphics/bscannon.png'} }
    self.cannon_index = 1
    self.cannon_sprite = love.graphics.newImage(self.cannons[1]['sprite'])
    self.cannon_width = self.cannon_sprite:getWidth()
    self.cannon_height = self.cannon_sprite:getHeight()
    
    self.chargeable = false
    self.charging = false
    self.chargetime = 0
    
    -- Init Abilities
    self.bomb_sound = love.sound.newSoundData('sounds/bomb.wav')
    self.freeze_ready = false
    self.frozen = false
    self.unfrozen = false
    self.freezetimer = 0
    self.bomb_ready = false
    self.bombtimer = 0
    
    -- Sounds
    self.beamsound = love.sound.newSoundData('sounds/beamshot.wav')
    self.bulletsound = love.sound.newSoundData('sounds/bullet.wav')
    
    -- Progression-related variables
    self.elapsed = 0
    self.storyphase = 'Default'
    self.enemy_interval = 2.5
    self.story_prompts = 3
    self.win_condition = false
    self.story_condition = true

    -- Mouse values
    self.mouseX = 0
    self.mouseY = 0
end

function Game:render()
    -- Draw bg
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.bg,0,0)
    
    -- Draw cannon
    angle = math.atan2((540 - self.mouseY) ,(610 - self.mouseX))
    love.graphics.draw(self.cannon_sprite, 610, 540, angle, 1, 1, self.cannon_width, self.cannon_height/2)
    
    -- Draw bullets / beam
    for i, bullet in ipairs(self.bullets) do
        bullet:render()
    end
    -- Draw enemies
    for i, enemy in ipairs(self.enemies) do
        enemy:render()
    end
    -- Draw bosses
    for i, boss in ipairs(self.boss) do
        boss:render()
    end
end

-- Switch cannons based on index in cannons table
function Game:switchCannon(i)
    self:cancelCharge()
    self.cannon_index = i
    if self.cannon_index ~= 1 then
        self.chargeable = true
    else
        self.chargeable = false
    end
    self.cannon_sprite = love.graphics.newImage(self.cannons[self.cannon_index]['sprite'])
    self.cannon_width = self.cannon_sprite:getWidth()
    self.cannon_height = self.cannon_sprite:getHeight()
end

-- Shoot search bullet
function Game:shoot(x, y)
    table.insert(self.bullets, Bullet(math.atan2((540 - y) ,(610 - x)), self.cannon_width, 'Bullet', self.cannon_index))
    local shot = love.audio.newSource(self.bulletsound, "static")
    if sounds then love.audio.play(shot) end
end

-- Shoot sort beam
function Game:shootBeam(x, y)
    table.insert(self.bullets, Bullet(math.atan2((540 - y) ,(610 - x)), self.cannon_width, 'Beam', self.cannon_index))
    local beam = love.audio.newSource(self.beamsound, "static")
    if sounds then love.audio.play(beam) end
    self.charging = false
    self.chargetime = 0
end

-- Button released before finished charging resets the charge
function Game:cancelCharge()
    self.charging = false
    self.chargetime = 0
end

-- Freeze all enemies currently on screen
function Game:freeze()
    self.frozen = true
    self.unfrozen = false
    self.freeze_ready = false
    self.freezetimer = 15
    for i, boss in ipairs(self.boss) do
        boss.frozen = true
    end
    for i, enemy in ipairs(self.enemies) do
        enemy.frozen = true
    end
end

-- Unfreeze enemies when the timer has run out
function Game:unfreeze()
    self.unfrozen = true
    for i, boss in ipairs(self.boss) do
        boss.frozen = false
    end
    for i, enemy in ipairs(self.enemies) do
        enemy.frozen = false
    end
end

-- Bomb ability
function Game:bomb()
    self.bomb_ready = false
    self.bombtimer = 10
    local bombsound = love.audio.newSource(self.bomb_sound)
    if sounds then bombsound:play() end
    -- Delete 1 bar from every enemy that is in a Default state
    local j = 1
    local enemy = nil
    local num_enemies = #self.enemies
    while j <= num_enemies do
        enemy = self.enemies[j]
        if enemy.state == "Default" then
            xp = xp + 1
            local to_remove = enemy.bars
            if to_remove <= 1 then
                self.enemies[j] = self.enemies[num_enemies]
                self.enemies[num_enemies] = nil
                num_enemies = num_enemies - 1
            else
                if enemy.values[to_remove] == enemy.vulnerable_value then
                    to_remove = to_remove - 1
                    enemy.values[to_remove] = enemy.vulnerable_value
                    enemy.values[to_remove + 1] = nil
                else
                    enemy.values[to_remove] = nil
                end
                enemy.bars = enemy.bars - 1
                if enemy.sorted == 1 then
                    enemy.sorted = enemy:check_sort()
                end
                j = j + 1
            end
        else
            j = j + 1
        end
    end
end

function Game:remove_bullet(index, num)
    self.bullets[index] = self.bullets[num]
    self.bullets[num] = nil
    return nil
end