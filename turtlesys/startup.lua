local gS = term.getSize
local gCP = term.getCursorPos
local sCP = term.setCursorPos
local scr = term.scroll
local wr = term.write
local cl = term.clear
local clL = term.clearLine
local pr = print

_G.readNumber = function(txt)
	local x,y = gCP()
	local sx,sy = gS()
	if y == sy then
		scr(1)
		y = y - 1
	end
	while true do
		sCP(1,y)
		clL()
		wr(txt.." ")
		local i = tostring(read())
		if tostring(tonumber(i)) == i then
			return tonumber(i)
		end
	end
end

_G.readPos = function(txt, ...) -- read possibilities
	if not txt or txt == "" then
		txt = "("
	else
		txt = txt.." ("
	end
	for k,v in pairs({...}) do
		txt = txt..tostring(v).."|"
	end
	txt = txt:sub(1,txt:len() - 1).."):"
	local x,y = gCP()
	local sx,sy = gS()
	if y == sy then
		scr(1)
		y = y - 1
	end
	while true do
		sCP(1,y)
		clL()
		wr(txt)
		local i = tostring(read())
		for k,v in pairs({...}) do
			if tostring(v) == i then
				return i
			end
		end
	end
end

local x,y,z,f -- f= 0:south 1:west 2:north 3:east
local old = {
	locate = _G.gps.locate,
}
local gpsSig = false

for k,v in pairs({"forward","back","up","down","turnLeft","turnRight"}) do
	old[v] = turtle[v]
end

turtle.forward = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.forward() then
			return false
		end
		if f == 0 then
			z = z + 1
		elseif f == 1 then
			x = x - 1
		elseif f == 2 then
			z = z - 1
		elseif f == 3 then
			x = x + 1
		end
	end
	return true
end

turtle.back = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.back() then
			return false
		end
		if f == 0 then
			z = z - 1
		elseif f == 1 then
			x = x + 1
		elseif f == 2 then
			z = z + 1
		elseif f == 3 then
			x = x - 1
		end
	end
	return true
end

turtle.up = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.up() then
			return false
		end
		y = y + 1
	end
	return true
end

turtle.down = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.down() then
			return false
		end
		y = y - 1
	end
	return true
end

turtle.turnLeft = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.turnLeft() then
			return false
		end
		f = f - 1
		if f < 0 then
			f = 3
		end
	end
	return true
end

turtle.turnRight = function(c)
	if not c then
		c = 1
	end
	for i = 1,c,1 do
		if not old.turnRight() then
			return false
		end
		f = f + 1
		if f > 3 then
			f = 0
		end
	end
	return true
end

_G.gps.locate = function(tO, deb)
	if x then
		if deb then
			print("Position is "..x..", "..y..", "..z)
		end
		return x,y,z
	else
		error("Saved Position missing!",1)
	end
end

turtle.checkFuelFor = function(need)
	local x,y = gCP()
	local l = turtle.getFuelLevel()
	while l < need do
		clL()
		sCP(1,y)
		wr("Need "..(need-l).." units more fuel")
		while not turtle.refuel() do
			sleep(1)
		end
		l = turtle.getFuelLevel()
	end
	clL()
	sCP(1,y)
end

cl()
sCP(1,1)
pr("TurtleSYS by Zocker1999_NET")
pr()

local modem
if peripheral.getType("left") == "modem" then
	modem = peripheral.wrap("left")
	pr("Found modem on the left side")
end
if modem then
	pr("Search for gps signal")
	local ox,oy,oz = old.locate()
	if ox then
		x,y,z = ox,oy,oz
		pr("Found position at "..x..", "..y..", "..z)
		turtle.checkFuelFor(2)
		pr("Try to get facing direction")
		local bC = 0
		while not old.forward() do
			old.turnRight()
			bC = (bC % 4) + 1
		end
		pr("Request new position")
		local nx,ny,nz = old.locate()
		old.back()
		if nx then
			if nx > x then
				f = 3
			elseif nx < x then
				f = 1
			elseif nz > z then
				f = 0
			elseif nz < z then
				f = 2
			end
			if bC == 3 then
				turtle.turnRight()
			else
				turtle.turnLeft(bC)
			end
		else
			pr("Signal lost!")
			if bC == 3 then
				old.turnRight()
			else
				while bC > 0 do
					old.turnLeft()
					bC = bC - 1
				end
			end
		end
	else
		pr("No signal found!")
	end
end
if not x then
	pr("Request position from user")
	x = readNumber("X:")
	y = readNumber("Y:")
	z = readNumber("Z:")
end
if not f then
	pr("In which direction does this turtle look now?")
	local fS = readPos("","n","e","s","w")
	if fS == "s" then
		f = 0
	elseif fS == "w" then
		f = 1
	elseif fS == "n" then
		f = 2
	elseif fS == "e" then
		f = 3
	end
end
cl()
sCP(1,1)
pr(os.version())