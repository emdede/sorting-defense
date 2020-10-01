Textfield = Class{}

local level_textdata = nil


function Textfield:init(level, phase)
    self.img = love.graphics.newImage('graphics/prof.png')
    if phase ~= 0 then
        level_textdata = require('leveldata/level'  .. tostring(level) .. 'text')
        if phase > #level_textdata then
            phase = #level_textdata
        end
        self.data = level_textdata[phase]
        self.counter = 1
        self:load_text()
    else
        self.data = {}
        self.counter = 0
        self:load_text(level)
    end
    self.textspeed = 65
    self.x = 160
    self.y = 520
    self.width = 1000
    self.height = 190

end

-- Type out text
function Textfield:update(dt)
    self.delay = self.delay - dt
    if self.delay <= 0 then
        self.clickable = true
    end
    if self.currentlength and self.currentlength < self.length then
        self.currentlength = math.floor(self.currentlength + self.textspeed * dt)
    elseif self.currentlength and self.currentlength >= self.length then
        self.clickable = true
    end
end

function Textfield:render()
    love.graphics.setColor(0.2,0.2,0.2,0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 3, 3)
    love.graphics.setColor(0.8,0.5,0.3,1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 3, 3)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(bigFont)
    love.graphics.printf(string.sub(self.text, 1, self.currentlength), self.x + 180, self.y + 10, 800, 'left')
    love.graphics.draw(self.img, self.x + 2, self.y + 2)
    love.graphics.setFont(defFont)
end

function Textfield:click()
    if self.clickable and self.currentlength >= self.length then
        if self.data[self.counter+1] then
            self.counter = self.counter + 1
            self:load_text()
        else
            return false
        end
    elseif self.clickable then
        self.currentlength = self.length
        return true
    end
end

function Textfield:load_text(str)
    self.text = str or self.data[self.counter]
    self.clickable = false
    self.delay = 0.5
    self.currentlength = 0
    self.length = string.len(self.text)
end