Popup = Class{}

local button_template = {
    { type = 'Close', x1 = 882, x2 = 982, y1 = 594, y2 = 652}, -- Close button
    { type = 'Docs', x1 = 282, x2 = 382, y1 = 594, y2 = 652}, -- Enemy entry - 'landing page'
    { type = 'Def', x1 = 402, x2 = 502, y1 = 594, y2 = 652}, -- Further information about terms
    { type = 'LS', x1 = 522, x2 = 622, y1 = 594, y2 = 652}, -- Linear Search
    { type = 'BS', x1 = 642, x2 = 742, y1 = 594, y2 = 652}, -- Binary Search and Bubble Sort
    { type = 'BST', x1 = 762, x2 = 862, y1 = 594, y2 = 652} -- BST Sort and Search
}
local files = { Settings = 'algos/settings.png', Docs = 'algos/enemy.png', Def = 'algos/def.png', LS = 'algos/ls.png', Lock = 'algos/locked.png', Binary = 'algos/binary.png', Bubble = 'algos/bubble.png', BS = 'algos/bs.png' }
local hotspots = {
    LS = {
        { x1 = 391, x2 = 890, y1 = 302, y2 = 332, lines = 3, text = 'Define a function with 2 inputs\nx = Value to be found\ninput = List to be searched' }, -- def search x, input
        { x1 = 391, x2 = 890, y1 = 332, y2 = 360, lines = 1, text = 'Loop through all elements' },
        { x1 = 391, x2 = 890, y1 = 360, y2 = 428, lines = 1, text = 'If the value is x, return position i'},
        { x1 = 391, x2 = 890, y1 = 428, y2 = 452, lines = 1, text = 'Return None if value not found' }
    },
    Binary = {
        { x1 = 431, x2 = 893, y1 = 220, y2 = 248, lines = 4, text = 'Define a function with 2 inputs\nx = Value to be found\ninput = List to be searched\nList must be sorted' },
        { x1 = 431, x2 = 893, y1 = 248, y2 = 338, lines = 6, text = 'Initialize search parameters\nSize is length of list\ni = position to start search at\nInitialized to middle element\nleft = left limit (first index)\nright = right limit (last index)' },
        { x1 = 431, x2 = 893, y1 = 338, y2 = 360, lines = 3, text = 'Search condition\nif x is not in list\nthis becomes false' },
        { x1 = 431, x2 = 893, y1 = 360, y2 = 406, lines = 1, text = 'If the value is x, return position i' },
        { x1 = 431, x2 = 893, y1 = 406, y2 = 454, lines = 3, text = 'Else if the value is greater than x\nx must be in the left side\nUpdate right limit' },
        { x1 = 431, x2 = 893, y1 = 454, y2 = 498, lines = 2, text = 'Else, value must be smaller than x\nUpdate the left limit' },
        { x1 = 431, x2 = 893, y1 = 498, y2 = 524, lines = 3, text = 'Update search index =\nmiddle element of values\nbetween left and right limit' },
        { x1 = 431, x2 = 893, y1 = 524, y2 = 545, lines = 1, text = 'Return None if value not found' }
    },
    Bubble = {
        { x1 = 280, x2 = 1002, y1 = 281, y2 = 306, lines = 2, text = 'Define a function with 1 input\ninput = List to be sorted' },
        { x1 = 280, x2 = 1002, y1 = 306, y2 = 329, lines = 2, text = 'Define last element in loop\nLargest value "bubbles" to end' },
        { x1 = 280, x2 = 1002, y1 = 329, y2 = 373, lines = 2, text = 'Initialize loop condition\nStop looping when array is sorted' },
        { x1 = 280, x2 = 1002, y1 = 373, y2 = 398, lines = 1, text = 'Decrement limit per iteration' },
        { x1 = 280, x2 = 1002, y1 = 398, y2 = 420, lines = 1, text = '"Assume" array is sorted' },
        { x1 = 280, x2 = 1002, y1 = 420, y2 = 444, lines = 4, text = 'Check all valuepairs up to limit\nNotice that you can only\niterate until length - 1\nbecause of the next line' },
        { x1 = 280, x2 = 1002, y1 = 444, y2 = 467, lines = 2, text = 'Compare value with its neighbor\nIf value at i is greater\n' },
        { x1 = 280, x2 = 1002, y1 = 467, y2 = 516, lines = 2, text = 'Then array is not sorted\nAnd we swap the values' }
    }
}

function Popup:init(type)
    self.type = type
    self.state = 'Default'
    self.img = love.graphics.newImage(files[type])
    self.x = 240
    self.y = 60
    self.width = 800
    self.height = 600
    self.mouseX = 0
    self.mouseY = 0
    self.hotspots = {}
    if self.type == "Settings" then
        self.buttons = {
            { type = 'Close', x1 = 882, x2 = 982, y1 = 594, y2 = 652 },
            { type = 'music1', x1 = self.x + self.width / 4 - 10, x2 = self.x + self.width / 4 + 10, y1 = self.y + self.height / 2 - 80, y2 = self.y + self.height / 2 - 60 },
            { type = 'music2', x1 = self.x + self.width / 2 - 10, x2 = self.x + self.width / 2 + 10, y1 = self.y + self.height / 2 - 80, y2 = self.y + self.height / 2 - 60 },
            { type = 'music0', x1 = self.x + self.width / 4 * 3 - 10, x2 = self.x + self.width / 4 * 3 + 10, y1 = self.y + self.height / 2 - 80, y2 = self.y + self.height / 2 - 60 },
            { type = 'onsound', x1 = self.x + 200 - 10, x2 = self.x + 210, y1 = self.y + self.height / 2 + 50, y2 = self.y + self.height / 2 + 70 },
            { type = 'ofsound', x1 = self. x + 600 - 10, x2 = self.x + 610, y1 = self.y + self.height / 2 + 50, y2 = self.y + self.height / 2 + 70 },
            { type = 'exit', x1 = self.x + self.width / 2 - 80, x2 = self.x + self.width / 2 + 80, y1 = 500, y2 = 540 }
        }
    else
        self.buttons = button_template
        self.animation_clock = 0
        self:load_values()
        self.lockbtn = love.graphics.newImage(files['Lock'])
        -- Lock buttons depending on what is available at this point
        if bs_cannon_unlocked then
            self.lock_x = 762
        elseif ls_cannon_unlocked then
            self.lock_x = 642
        else
            self.lock_x = 402
        end
        for i, button in ipairs(self.buttons) do
            if button.x1 >= self.lock_x and button.x1 < 882 then
                button.type = 'Locked'
            end
        end
    end
end
    
-- Update mouse value for hover effect
function Popup:update(dt, x, y)
    self.mouseX = x
    self.mouseY = y
    if self.state == 'Finished' then
        self.animation_clock = self.animation_clock + dt
        if self.animation_clock >= 0.25 then
            self.state = 'Default'
            self.animation_clock = 0
        end
    elseif self.state == 'Presentation' then
        self.animation_clock = self.animation_clock + dt
        if self.animation_clock >= 0.25 then
            self.animation_clock = self.animation_clock - 0.25
            if self.type == 'Bubble' then
                self:sort()
            else
                self:search()
            end
        end
    end

end

function Popup:render()
    local x = self.mouseX
    local y = self.mouseY
    local draw_or_not = false
    -- Draw Frame and shadow
    love.graphics.setColor(0,0,0,.8)
    love.graphics.rectangle("fill", self.x + 10, self.y + 10, self.width, self.height, 10, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.img, self.x, self.y)
    -- Draw Code info box
    for i, v in pairs(self.hotspots) do
        if x > v.x1 and x < v.x2 and y >= v.y1 and y < v.y2 then
            draw_or_not = true
            if self.state == 'Default' then
                self.state = 'Presentation'
                if self.type ~= 'Bubble' then
                    self:initsearch(self.type)
                else
                    self:initsort()
                end
            end
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle('line', v.x1, v.y1, v.x2 - v.x1, v.y2 - v.y1)
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle('fill', self.mouseX - 450, self.mouseY + 70, 320, 10 + 24 * v['lines'], 10,10)
            love.graphics.setColor(0,0,0,1)
            love.graphics.setFont(bigFont)
            love.graphics.printf(v.text, self.mouseX - 450, self.mouseY + 80, 320, 'center')
            love.graphics.setFont(defFont)
        end
    end
    for i, button in ipairs(self.buttons) do
        love.graphics.setColor(1,1,1,1)
        if button.type == 'Locked' then love.graphics.draw(self.lockbtn, button.x1, button.y1) end
        if x > button.x1 and x < button.x2 and y > button.y1 and y < button.y2 then
            love.graphics.setColor(0,0.5,0.5,0.5)
        elseif self.type == "Settings" and button.type ~= 'Close' then
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.setColor(1,1,1,0)
        end
        love.graphics.rectangle("fill", button.x1, button.y1, button.x2 - button.x1, button.y2 - button.y1)
        if button.type:sub(6,6) == tostring(track_playing) or (button.type:sub(1,2) == 'on' and sounds) or (button.type:sub(1,2) == 'of' and not sounds) then
            love.graphics.setColor(0,0,0,1)
            love.graphics.line(button.x1, button.y1, button.x2, button.y2)
            love.graphics.line(button.x2, button.y1, button.x1, button.y2)
        end
    end
    if self.type == "Settings" then
        love.graphics.setColor(0,0,0,1)
        love.graphics.setFont(bigFont)
        love.graphics.printf("BATTLE THEME", self.x, 250, 400, 'center')
        love.graphics.printf("SPACE THEME",self.x + 200, 250, 400, 'center')
        love.graphics.printf("MUSIC OFF", self.x + 400, 250, 400, "center")
        love.graphics.printf("ON", 240, 380, 400, "center")
        love.graphics.printf("OFF", 640, 380, 400, "center")
        love.graphics.setFont(defFont)
    love.graphics.printf("EXIT GAME", self.x, 515, self.width, "center")
    end
    if draw_or_not then
        self:draw_example()
    end
end

function Popup:clicked(x, y)
    for i, button in ipairs(self.buttons) do
        if x > button.x1 and x < button.x2 and y > button.y1 and y < button.y2 then
            if i == 1 then
                return 'Close'
            elseif button.type == 'exit' then
                love.event.quit()
            elseif button.type:sub(3,7) == "sound" then
                sounds = not sounds
            elseif button.type:sub(1,5) == 'music' then
                change_music(button.type:sub(6,6))
            elseif button.type ~= 'Locked' then
                if self.type == 'BS' then
                    table.remove(self.buttons, #self.buttons)
                    table.remove(self.buttons, #self.buttons)
                end
                self.type = button.type                
                if self.type == 'BS' then
                    table.insert(self.buttons, { type = 'Binary', x1 = 349, x2 = 599, y1 = 393, y2 = 492})
                    table.insert(self.buttons, { type = 'Bubble', x1 = 675, x2 = 925, y1 = 393, y2 = 492})
                end
                self.img = love.graphics.newImage(files[self.type])
                if hotspots[self.type] then
                    self.hotspots = hotspots[self.type]
                else
                    self.hotspots = {}
                end
                self.state = 'Default'
                self:load_values()
            end
        end
    end
end

function Popup:initsearch(type)
    self.search_type = type
    self.vulnerable_value = self.values[love.math.random(self.bars)]
    if type == 'LS' then
        self.search_index = 0
    elseif type == 'Binary' then
        self.search_index = math.ceil(self.bars / 2)
        self.left_bound = 1
        self.right_bound = self.bars
    end
end

function Popup:initsort()
    self.sortpair = -1
    self.sort_index = 1
    self.sort_complement = 2
    self.bubble_end = self.bars
    -- Shuffle values
    for i = 1, self.bars do
        local r = love.math.random(i, self.bars)
        self.values[i], self.values[r] = self.values[r], self.values[i]
    end
end

function Popup:draw_example()
    local x = self.mouseX - 400
    local y = self.mouseY
    if self.type == 'Bubble' then
        for i,v in ipairs(self.values) do
            if i == self.sortpair or i == self.sortpair + 1 then
                love.graphics.setColor(0,1,0,1)
            elseif i == self.sort_index or i == self.sort_complement then
                love.graphics.setColor(1,0,0,1)
            else
                love.graphics.setColor(1,1,1,1)
            end
            love.graphics.rectangle("fill", x, y - 5 * v, 30 - self.bars, 60 + v * 5, 2, 2)
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("line", x, y - 5 * v, 30 - self.bars, 60 + v * 5, 2, 2)
            x = x + 30 - self.bars
        end
    else
        for i,v in ipairs(self.values) do
            if v == self.vulnerable_value and i == self.search_index then
                love.graphics.setColor(0,1,0,1)
            elseif v == self.vulnerable_value then
                love.graphics.setColor(1,1,0,1)
            elseif i == self.search_index then
                love.graphics.setColor(1,0,0,1)
            else
                love.graphics.setColor(1,1,1,1)
            end
            love.graphics.rectangle("fill", x, y - 5 * v, 30 - self.bars, 60 + v * 5, 2, 2)
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("line", x, y - 5 * v, 30 - self.bars, 60 + v * 5, 2, 2)
            x = x + 30 - self.bars
        end
    end
end

function Popup:search()
    -- Linear search
    if self.search_type == 'LS' then
        self.search_index = self.search_index + 1
        if self.values[self.search_index] == self.vulnerable_value then
            self.state = 'Finished'
        end
    -- Binary search
    else
        if self.values[self.search_index] == self.vulnerable_value then
            self.state = "Finished"
        elseif self.values[self.search_index] > self.vulnerable_value then
            self.right_bound = self.search_index
            self.search_index = self.search_index - math.ceil((self.right_bound - self.left_bound) / 2)
        elseif self.values[self.search_index] < self.vulnerable_value then
            self.left_bound = self.search_index
            self.search_index = self.search_index + math.ceil((self.right_bound - self.left_bound) / 2)
        end
    end
end

function Popup:load_values()
    if self.type == 'LS' then
        self.values = {6,1,8,4,5,10,2,7,3,9}
        self.bars = 10
    elseif self.type == 'Binary' then
        self.values = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
        self.bars = 15
    -- Bubble Sort
    else
        self.bars = 10
        self.values = {1,2,3,4,5,6,7,8,9,10}
    end
end


function Popup:sort()
    -- Optimized bubble sort
    self.sortpair = -1
    if self.values[self.sort_index] > self.values[self.sort_complement] then
        self.sortpair = self.sort_complement
        self.bubb_sorted = true
        self.values[self.sort_index], self.values[self.sort_complement] = self.values[self.sort_complement], self.values[self.sort_index]
    end
    self.sort_index = self.sort_index + 1
    self.sort_complement = self.sort_complement + 1
    -- Finished sorting
    if self.sort_complement > self.bubble_end and not self.bubb_sorted then
        self.state = "Finished"
    -- Increment loop
    elseif self.sort_complement > self.bubble_end then
        self.bubb_sorted = false
        self.sort_index = 1
        self.sort_complement = 2
        self.bubble_end = self.bubble_end - 1
    end
end