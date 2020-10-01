Hud = Class{}

function Hud:init(game)
    self.game = game
    self.mouseX = 0
    self.mouseY = 0
    self.level = 1
    self.cannon_names = { 'LS', 'BS', 'BST' }
    self.settings = love.graphics.newImage('graphics/settings.png')
    self.info = love.graphics.newImage('graphics/info.png')
    self.freezebtn = love.graphics.newImage('graphics/freeze.png')
    self.bombbtn = love.graphics.newImage('graphics/bomb.png')
    self.lockedbtn = love.graphics.newImage('graphics/locked.png')
    self.buttons = {
        { type = "Settings", x = 1215, y = 10, x2 = 1255, y2 = 50 },
        { type = "Docs", x = 1215, y = 55, x2 = 1255, y2 = 95 }}
end

function Hud:update(dt, x, y)
    self.mouseX = x
    self.mouseY = y
    -- Update charge amt
    if self.game.charging then
        self.charge_amount = self.game.chargetime * 2 * math.pi / charge_constant
    end
end

function Hud:render(state)

    -- Draw panels' outline
    love.graphics.setLineWidth(3)
    love.graphics.setColor(0.8,0.5,0.3,1)
    -- Left panel
    love.graphics.rectangle("line", 20, 500, 100, 200, 5, 5)
    love.graphics.rectangle("line", 25, 508, 90, 40, 5, 5)
    love.graphics.rectangle("line", 25, 556, 90, 40, 5, 5)
    love.graphics.rectangle("line", 25, 604, 90, 40, 5, 5)
    love.graphics.rectangle("line", 25, 652, 90, 40, 5, 5)
    -- Right panel
    love.graphics.rectangle("line", 1200, 500, 60, 104, 5, 5)
    love.graphics.rectangle("line", 1205, 508, 50, 40, 5, 5)
    love.graphics.rectangle("line", 1205, 556, 50, 40, 5, 5)
    
    
    -- Settings and info buttons
    love.graphics.rectangle("line", 1215, 10, 40, 40, 5, 5)
    love.graphics.rectangle("line", 1215, 55, 40, 40, 5, 5)
    
    love.graphics.setLineWidth(1)
    -- Draw panels' fill
    love.graphics.setColor(0.3,0.3,0.3,0.6)
    -- Left panel
    love.graphics.rectangle("fill", 20, 500, 100, 200, 5, 5)
    love.graphics.rectangle("fill", 25, 508, 90, 40, 5, 5)
    love.graphics.rectangle("fill", 25, 556, 90, 40, 5, 5)
    love.graphics.rectangle("fill", 25, 604, 90, 40, 5, 5)
    love.graphics.rectangle("fill", 25, 652, 90, 40, 5, 5)
    -- Right panel
    love.graphics.rectangle("fill", 1200, 500, 60, 104, 5, 5)
    love.graphics.rectangle("fill", 1205, 508, 50, 40, 5, 5)
    love.graphics.rectangle("fill", 1205, 556, 50, 40, 5, 5)

    
    -- Settings and info buttons
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", 1215, 10, 40, 40, 5, 5)
    love.graphics.rectangle("fill", 1215, 55, 40, 40, 5, 5)

    love.graphics.draw(self.settings, 1215, 10)
    love.graphics.draw(self.info, 1215, 55)
    
    -- Abilities right panel
    if not bomb_unlocked then
        love.graphics.draw(self.lockedbtn, 1205, 508)
    else
        love.graphics.draw(self.bombbtn, 1205, 508)
        if not game.bomb_ready then
            local y_off = math.max((game.bombtimer/10 * 40), 0)
            love.graphics.setColor(0.1,0.1,0.1,0.8)
            love.graphics.rectangle('fill', 1205, 548 - y_off, 50, y_off, 3, 3)
            love.graphics.setColor(1,1,1,1)
        end
    end
    if not freeze_unlocked then
        love.graphics.draw(self.lockedbtn, 1205, 556)
    else
        love.graphics.draw(self.freezebtn, 1205, 556)
        if not game.freeze_ready then
            local y_off = math.max((game.freezetimer/15 * 40), 0)
            love.graphics.setColor(0.1,0.1,0.1,0.8)
            love.graphics.rectangle('fill', 1205, 596 - y_off, 50, y_off, 3, 3)
            love.graphics.setColor(1,1,1,1)
        end
    end

    -- Draw labels left panel
    love.graphics.rectangle("fill", 40, 503, 60, 12, 3, 3)
    love.graphics.rectangle("fill", 40, 551, 60, 12, 3, 3)
    love.graphics.rectangle("fill", 40, 599, 60, 12, 3, 3)
    love.graphics.rectangle("fill", 40, 647, 60, 12, 3, 3)

    -- Cannon_index label
    love.graphics.rectangle("fill", 25, 540, 12, 12, 3, 3)

    love.graphics.setFont(bigFont)
    if not ls_cannon_unlocked then
        love.graphics.printf('Cannon', 25, 524, 95, "center")
    else
        love.graphics.printf(self.cannon_names[game.cannon_index], 25, 524, 95, "center")
    end
    love.graphics.printf(xp, 25, 572, 95, "center")
    love.graphics.printf(math.floor(leveltimer), 25, 620, 95, "center")
    love.graphics.printf(self.level, 25, 668, 95, "center")
    love.graphics.setFont(defFont)
    
    -- Draw keys right panel
    love.graphics.print("Q", 1206, 536)
    love.graphics.print("W", 1206, 584)
    
    -- Label Text left panel
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf("CANNON", 40, 504, 60, "center")
    love.graphics.printf("SCORE", 40, 552, 60, "center")
    love.graphics.printf("TIME", 40, 600, 60, "center")
    love.graphics.printf("LEVEL", 40, 648, 60, "center")
    love.graphics.printf(self.game.cannon_index, 25, 541, 12, "center")

    -- Draw charge circle
    if state == 'Default' then
        love.graphics.setLineWidth(5)
        if self.game.charging then
            if self.game.chargetime >= charge_constant then
                love.graphics.setColor(0.6,0.2,0.2,1)
            else
                love.graphics.setColor(0.2,0.4,0.8,1)
            end
            love.graphics.arc("line", "open", self.mouseX, self.mouseY, 20, math.pi, math.pi + self.charge_amount)
            love.graphics.setColor(1,1,1,1)
        end
        love.graphics.setLineWidth(1)
    end
end

function Hud:clicked(button, x, y)
    if x > button.x and x < button.x2 and y > button.y and y < button.y2 then
        return true
    end
end