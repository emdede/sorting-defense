Enemy = Class{}

function Enemy:init(num)

    -- Init data
    self.state = "Default"
    self.bars = num
    self.values = {}
    if self.bars == 1 then
        self.bar_sizeX = 50
    elseif self.bars <= 10 then
        self.bar_sizeX = 18
    elseif self.bars <= 20 then
        self.bar_sizeX = 16
    else
        self.bar_sizeX = 14
    end
    self.bar_sizeY = 2
    
    -- Types according to weapon types: 1,2 initialized to brute force
    self.search_type = 1

    self.frozen = false 
    self.elapsed = 0


    -- Generate values
    for i = 1, self.bars do
        table.insert(self.values, i)
    end
    -- Shuffle table
    for i = 1, self.bars do
        local r = love.math.random(i, self.bars)
        self.values[i], self.values[r] = self.values[r], self.values[i]
    end

    self.vulnerable_value = self.values[love.math.random(self.bars)]
    self.hitsound = love.sound.newSoundData('sounds/barhit.wav')
    
    
    -- Sorting data
    self.sorted = self:check_sort()
    
    -- Spawn location and angle
    self.x = love.math.random(1000)
    self.y = -20
    -- Make targets go towards domes at the bottom of the screen
    -- 350, 670 left dome
    if self.x < 600 then
        self.angle = math.atan2((670 - 0) ,(350 - self.x))
        self.dx = math.cos(self.angle) * 5
        self.dy = math.sin(self.angle) * 5
    
    -- 920, 670 right dome
    else
        self.angle = math.atan2((670 - 0) ,(920 - self.x))
        self.dx = math.cos(self.angle) * 5
        self.dy = math.sin(self.angle) * 5
    end
    self.bounds = {x = self.x - 2, y = self.y + 38 - self:max_val() * self.bar_sizeY, x2 = self.x + 2 + self.bars*self.bar_sizeX, y2 = self.y + 102}
end

function Enemy:update(dt)
    if self.state == "Found" then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 0.05 then
            self.elapsed = 0
            self:found()
        end
    elseif self.state == "Search" then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 0.1 then
            self.elapsed = self.elapsed - 0.2
            self:search()
        end
    elseif self.state == "Sorting" then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 0.2 then
            self.elapsed = self.elapsed - 0.1
            self:sort()
        end
    end

    -- Stop enemy in place when sorting or freeze ability was cast
    if not self.frozen then
        if self.state == "Sorting" then
            self.x = self.x + (self.dx * dt) / 4
            self.y = self.y + (self.dy * dt) / 4
        else
            self.x = self.x + self.dx * dt 
            self.y = self.y + self.dy * dt
        end
    end
    self.bounds = {x = self.x - 2, y = self.y + 38 - self:max_val() * self.bar_sizeY, x2 = self.x + 2 + self.bars*self.bar_sizeX, y2 = self.y + 102}
end

function Enemy:render()
    local x = self.x
    local i = 1
    while i <= self.bars do
        v = self.values[i]
        if self.state == "Sorting" and (i == self.sort_index or i == self.sort_complement) then
            love.graphics.setColor(1,0,0,1)
        elseif self.state == "Found" and i == self.search_index then
            love.graphics.setColor(0,1,0,1)
        elseif self.state == "Search" and i == self.search_index then
            love.graphics.setColor(1,0,0,1)
        elseif v == self.vulnerable_value then
            love.graphics.setColor(1,1,0,1)
        else
            love.graphics.setColor(1,1,1,1)
        end
        love.graphics.rectangle("fill", x, self.y + 40 - self.bar_sizeY * v, self.bar_sizeX, 60 + v * self.bar_sizeY, 2, 2)
        if self.frozen then
            love.graphics.setColor(0,0,1,0.5)
            love.graphics.rectangle("fill", x, self.y + 40 - self.bar_sizeY * v, self.bar_sizeX, 60 + v * self.bar_sizeY, 2, 2)
        end
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle("line", x, self.y + 40 - self.bar_sizeY * v, self.bar_sizeX, 60 + v * self.bar_sizeY, 2, 2)
        if self.bars ~= 1 then love.graphics.printf(v, x, self.y + 60, self.bar_sizeX, "center") end
        x = x + self.bar_sizeX
        i = i + 1
    end
end

function Enemy:collides(x, y)
    if x > self.bounds['x'] and x < self.bounds['x2'] and y > self.bounds['y'] and y < self.bounds['y2'] then
        return true
    else
        return false
    end
end

function Enemy:initsearch(type)
    self.search_type = type
    self.state = 'Search'
    if type == 1 then
        self.search_index = 0
    else
        self.search_index = math.ceil(self.bars / 2)
        self.left_bound = 1
        self.right_bound = self.bars
    end
end

function Enemy:search()
    -- Linear search
    if self.search_type == 1 then
        self.search_index = self.search_index + 1
        if self.values[self.search_index] == self.vulnerable_value then self.state = "Found" end
    -- Binary search
    else
        if self.values[self.search_index] == self.vulnerable_value then
            self.state = "Found"
        elseif self.values[self.search_index] > self.vulnerable_value then
            self.right_bound = self.search_index
            self.search_index = self.search_index - math.ceil((self.right_bound - self.left_bound) / 2)
        elseif self.values[self.search_index] < self.vulnerable_value then
            self.left_bound = self.search_index
            self.search_index = self.search_index + math.ceil((self.right_bound - self.left_bound) / 2)
        end
    end
end

-- Delete value from table after it was found
function Enemy:found()
    if self.search_index == self.bars then
        self.values[self.bars] = nil
        self.bars = self.bars - 1
        self.vulnerable_value = self.values[love.math.random(self.bars)]
        self.state = "Default"
        xp = xp + 1
        local hit = love.audio.newSource(self.hitsound, 'static')
        if sounds then hit:play() end
        if self.sorted == 1 and self.bars > 0 then self.sorted = self:check_sort() end
    else
        self.values[self.search_index], self.values[self.search_index + 1] = self.values[self.search_index + 1], self.values[self.search_index]
        self.search_index = self.search_index + 1
    end
end

function Enemy:initsort(type)
    self.state = "Sorting"
    self.sort_index = 1
    self.sort_complement = 2
    self.bubble_end = self.bars
end

function Enemy:sort()
    -- Bubblesort
    if self.bars == 1 then
        self.state = "Default"
    elseif self.values[self.sort_index] > self.values[self.sort_complement] then
        self.bubb_sorted = true
        self.values[self.sort_index], self.values[self.sort_complement] = self.values[self.sort_complement], self.values[self.sort_index]
    end
    self.sort_index = self.sort_index + 1
    self.sort_complement = self.sort_complement + 1
    -- Finished sorting
    if self.sort_complement > self.bubble_end and not self.bubb_sorted then
        self.state = "Default"
        self.sorted = 2
    -- Increment loop
    elseif self.sort_complement > self.bubble_end then
        self.bubb_sorted = false
        self.sort_index = 1
        self.sort_complement = 2
        self.bubble_end = self.bubble_end - 1
    end
end


function Enemy:check_sort()
    if self.bars == 1 then
        return 2
    else
        local k = 1
        local l = 2
        while l <= self.bars do
            if self.values[k] > self.values[l] then
                return 1
            end
            k = k + 1
            l = l + 1
        end
        return 2
    end
end


function Enemy:max_val()
    local i = 1
    local m = 0
    while i <= self.bars do
        if self.values[i] > m then
            m = self.values[i]
        end
        i = i + 1
    end
    return m
end