require 'gooi'
tween = require 'tween.tween'
function love.load()
	--[[
		Draw Formating
	]]
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineJoin("bevel")
	
	winW, winH  = love.graphics.getWidth(), love.graphics.getHeight()
	--[[
		Paper is the drawing surface
	]]
	paper = love.graphics.newCanvas()
	
	--[[
		Brush Stuff
	]]
	brush = {
		color     = {1,1,1,1},
		mode      = "draw",
		isErase   = false,
		isDown    = false,
		brushSize = 4,
		oldmx     = 0,
		oldmy     = 0,
		maxSize   = 20,
		curLine   = {},
		update    = function(self, dt)
			local mx,my = love.mouse.getPosition()
			if self.isDown then
				if #self.curLine == 0 then
					self.curLine[#self.curLine+1] = self.oldmx
					self.curLine[#self.curLine+1] = self.oldmy
					self.curLine[#self.curLine+1] = mx
					self.curLine[#self.curLine+1] = my
				end
				if self.isErase then
					love.graphics.setBlendMode("replace")
					love.graphics.setColor(0,0,0,0)
				else
					love.graphics.setColor(self.color)
				end
				love.graphics.setCanvas(paper)
					love.graphics.setLineWidth(self.brushSize)
					love.graphics.line(self.curLine)
					love.graphics.setColor(255,255,255)
				love.graphics.setCanvas()
				love.graphics.setBlendMode("alpha")	
			end
			
			self.color = {gooi.get("redSlider").value*255, gooi.get("greenSlider").value*255, gooi.get("blueSlider").value*255}
			self.brushSize  = gooi.get("sizeSlider").value * self.maxSize
			self.isErase = gooi.get("toggleErase").checked
			self.oldmx, self.oldmy = mx,my
		end,
		moved    = function(self,x,y,dx,dy)
			if self.isDown and dx ~= 0 and dy ~= 0 then
				self.curLine[#self.curLine+1] = x
				self.curLine[#self.curLine+1] = y
			end
		end
		
	}
	
	controlls = {
		width  = winW*0.25,
		height = winH*0.5,
		x      = 0,
		y      = 0,
		hidden = false,
		show_hide   = function(self)
			if self.hidden then
				self.brushMenu:setX(0)
				self.hidden = false
			else
				self.brushMenu:setX(-self.width)
				self.hidden = true
			end
		end
	}
	gui   = love.graphics.newCanvas()
	--[[
		Drawing Controlls
	]]
	
	controlls.brushMenu = gooi.newPanel("brushControlls",controlls.x,controlls.y,controlls.width,controlls.height, "grid 9x1", "brush_controlls")
	local widgets = {
		gooi.newLabel("redLabel", "Red"):setOrientation("left"),
		gooi.newSlider("redSlider"):setValue(1),
		gooi.newLabel("greenLabel", "Green"):setOrientation("left"),
		gooi.newSlider("greenSlider"):setValue(1),
		gooi.newLabel("blueLabel", "Blue"):setOrientation("left"),
		gooi.newSlider("blueSlider"):setValue(1),
		gooi.newLabel("sizeLabel", "Size"):setOrientation("left"),
		gooi.newSlider("sizeSlider"):setValue(1),
		gooi.newCheck("toggleErase","Erase Mode"),
	}
	local i
	controlls.brushMenu.x = 100
	controlls.brushMenu:rebuild()
	for i = 1, #widgets do
		widgets[i].group = "brush_controlls"
		controlls.brushMenu:add(widgets[i])
	end
	controlls.controllSelector = gooi.newPanel("controllSelector",controlls.x+controlls.width,controlls.y,controlls.width/4,controlls.height, "grid 2x1", "controll_selector")
	local widgets = {
		gooi.newButton("showHideBrush","b\nr\nu\ns\nh\ne\ns"):setDirection("vertical"):onRelease(function(c) controlls:show_hide() end),
	}
	local i
	for i = 1, #widgets do
		widgets[i].group = "controll_selector"
		controlls.controllSelector:add(widgets[i])
	end
	
	love.graphics.setCanvas(gui)
	
	love.graphics.setCanvas()
	
	controlls.controllSelector.layout.debug = true
end

function love.draw()
	love.graphics.print(love.timer.getFPS(),500,500)
	love.graphics.draw(paper,0,0)
	love.graphics.setColor(100,100,100)
	love.graphics.rectangle("fill",0,0,controlls.width,controlls.height)
	love.graphics.setColor(255,255,255)
	gooi.draw("brush_controlls")
	gooi.draw("controll_selector")
end

function love.update(dt)
	gooi.update(dt)
	brush:update(dt)
	love.graphics.setCanvas(gui)
	love.graphics.clear(0,0,0,0)
	gooi.draw("brush_controlls")
	gooi.draw("controll_selector")
	love.graphics.setCanvas()
	
end

function love.mousepressed(x,y,m,istouch)
	gooi.pressed(nil,x-controlls.x,y)
	if not ((controlls.x < x and x < controlls.width + controlls.x ) and 
			(controlls.y < y and y < controlls.y + controlls.brushMenu.h )) then
		brush.isDown = true
	end
end

function love.mousemoved(x,y,dx,dy)
	brush:moved(x,y,dx,dy)
	
end

function love.mousereleased()
	gooi.released()
	brush.isDown = false
	brush.curLine = {}
end