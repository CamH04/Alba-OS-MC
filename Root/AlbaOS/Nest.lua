--Nest File System 

local w, h = term.getSize()
local hidden = false
local dir = ""
local WhereAt = 0
local running = true
local mTime = true
local files = {}
local scroll = 0
local copy = {}

local function setColour(bc, tc)
	if not bc then bc = 32768 end
	if not tc then tc = 1 end
	term.setBackgroundColor(bc)
	term.setTextColor(tc)
end
--.write allows for le bacroudn colours !
local function printLeft(y, str, bc, tc)
	setColour(bc, tc)
	term.setCursorPos(1, y)
	term.write(str)
end
local function printRight(y, str, bc, tc)
	setColour(bc, tc)
	term.setCursorPos(w-#str+1, y)
	term.write(str)
end
local function printCentred(y, str, bc, tc)
	setColour(bc, tc)
	term.setCursorPos(w/2-#str/2, y)
	term.write(str)
end
local function printHere(x, y, str, bc, tc)
	setColour(bc, tc)
	term.setCursorPos(x, y)
	term.write(str)
end
local function getTime()
	return textutils.formatTime(os.time(), mTime)
end
local function printTime(x, y, bc, tc)
	local tTime = getTime()
	if x == "default" then x = w-#tTime+1 end
	printHere(x, y, tTime, bc, tc)
end
local function getFiles()
	files = {}
	if hidden then
		files = fs.list(dir)
	else
		local temp = fs.list(dir)
		for k, v in pairs(temp) do
			if v:sub(1, 1) ~= '.' then
				files[#files+1] = v
			end
		end
	end
end
local function drawError(msg)
	printCentred(h/2-1, string.rep(' ', #msg), 128)
	printCentred(h/2, msg, 128, 16384)
	printCentred(h/2+1, string.rep(' ', #msg), 128)
	sleep(1)
end
--header of desktop
local function drawHeader()
	printHere(1, 1, string.rep(' ', w), 128, 1)
	printHere(1, h, string.rep(' ', w), 128, 1)
	printLeft(1, 'X', 16384, 32768)
	printHere(3, 1, dir, 128, 1)
	printTime("default", h, 128, 1)
	if dir ~= "" then
		printLeft(h, "<back> <home>", 128, 1)
	end
	if copy[1] then
		printRight(1, "Copied: "..copy[1]..copy[2], 128, 1)
	end
	for i = 2, h-1 do
		if i == 2 then
			printRight(i, '^', 256, 1)
		elseif i == h-1 then
			printRight(i, 'v', 256, 1)
		else
			printRight(i, ' ', 256, 1)
		end
	end
end
local function drawMenu()
	for i = 2, h-1 do
		printHere(w-11, i, "           ", 2048, 1)
	end
	if WhereAt == 0 then
		if hidden then
			printHere(w-11, 5, "Hide hidden", 2048, 1)
		else
			printHere(w-11, 5, "Show hidden", 2048, 1)
		end
		if copy[1] then
			printHere(w-11, 6, " De-copy   ", 2048, 1)
		end
		printHere(w-11, 2, " New file  ", 2048, 1)
		printHere(w-11, 3, " New dir   ", 2048, 1)
		printHere(w-11, 4, " Paste     ", 2048, 1)
	elseif WhereAt > 0 then
		if fs.isDir(dir..files[WhereAt]) then
			printHere(w-11, 2, " Open      ", 2048, 1)
		else
			printHere(w-11, 2, " Run       ", 2048, 1)
			printHere(w-11, 8, " Edit      ", 2048, 1)
		end
		printHere(w-11, 3, " Deselect  ", 2048, 1)
		printHere(w-11, 4, " Rename    ", 2048, 1)
		printHere(w-11, 5, " Copy      ", 2048, 1)
		printHere(w-11, 6, " Cut       ", 2048, 1)
		printHere(w-11, 7, " Remove    ", 2048, 1)
	end
end
local function clickMenu(event)
	if WhereAt == 0 then
		if event[1] == "mouse_click" then
			if event[3] >= w-11 and event[3] <= w-1 and event[4] == 2 then
				printHere(w-11, 2, "           ", 2048, 1)
				term.setCursorPos(w-11, 2)
				local nName = io.read()
				if nName ~= "" then
					if fs.exists(dir..nName) then
						drawError("File already exists")
					else
						local f = io.open(dir..nName, 'w')
						f:close()
					end
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 3 then
				printHere(w-11, 3, "           ", 2048, 1)
				term.setCursorPos(w-11, 3)
				local nName = io.read()
				if nName ~= "" then
					if fs.exists(dir..nName) then
						drawError("Dir already exists")
					else
						fs.makeDir(dir..nName)
					end
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 4 then
				if copy[1] then
					local problem = false
					if dir == copy[1]..copy[2]..'/' then problem = true end
					if copy[3] == "copy" and not problem then
						if fs.exists(dir..copy[2]) then
							drawError("Path already exists")
						else
							fs.copy(copy[1]..copy[2], dir..copy[2])
						end
					elseif copy[3] == "move" and not problem then
						if fs.exists(dir..copy[2]) then
							drawError("Can't move to same dir")
						else
							fs.move(copy[1]..copy[2], dir..copy[2])
							copy = {}
						end
					else
						drawError("Can't copy a directory inside it self")
					end
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 5 then
				if hidden then
					hidden = false
				else
					hidden = true
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 6 then
				if copy[1] then
					copy = {}
				end
			end
		end
	elseif WhereAt > 0 then
		if event[1] == "mouse_click" then
			if event[3] >= w-11 and event[3] <= w-1 and event[4] == 2 then
				if fs.isDir(dir..files[WhereAt]) then
					dir = dir..files[WhereAt].."/"
					WhereAt = 0
					scroll = 0
				else
					setColour(32768, 1)
					return shell.run(dir..files[WhereAt])
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 3 then
				WhereAt = 0
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 4 then
				local tc = 32768
				if fs.isDir(dir..files[WhereAt]) then tc = 32 end
				printHere(2, 2+WhereAt-scroll, string.rep(' ', #files[WhereAt]), 1, tc)
				term.setCursorPos(2, 2+WhereAt-scroll)
				local nName = io.read()
				if nName ~= "" then
					fs.move(dir..files[WhereAt], dir..nName)
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 5 then
				if dir..files[WhereAt] ~= "rom" then
					copy[1] = dir
					copy[2] = files[WhereAt]
					copy[3] = "copy"
				else
					drawError("Access Denied")
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 6 then
				if dir..files[WhereAt] ~= "rom" and dir..files[WhereAt] ~= "disk" then
					copy[1] = dir
					copy[2] = files[WhereAt]
					copy[3] = "move"
				else
					drawError("Access Denied")
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 7 then
				printCentred(h/2, "Are you sure? ", 2048, 32768)
				printCentred(h/2+1, " Yes       No ", 2048, 32768)
				local run = true
				while run do
					os.startTimer(0.1)
					local temp = {os.pullEvent()}
					if temp[1] == "timer" then
						printTime("default", h, 128, 1)
					elseif temp[1] == "mouse_click" then
						if temp[2] == 1 and temp[4] == math.floor(h/2+1) then
							if temp[3] >= math.floor(w/2-6) and temp[3] <= math.floor(w/2-4) then
								if dir..files[WhereAt] ~= "rom" and dir..files[WhereAt] ~= "disk" then
									fs.delete(dir..files[WhereAt])
									WhereAt = 0
								else
									drawError("Access Denied")
								end
								run = false
							elseif temp[3] >= math.floor(w/2+4) and temp[3] <= math.floor(w/2+5) then
								run = false
							end
						end
					end
				end
			elseif event[3] >= w-11 and event[3] <= w-1 and event[4] == 8 then
				if not fs.isDir(dir..files[WhereAt]) then
					return shell.run("edit "..dir..files[WhereAt])
				end
			end
		end
	end
	if event[1] == "mouse_click" and event[2] == 1 and event[3] >= 1 and event[3] <= 6 and event[4] == h and dir ~= "" then
		local slash = 0
		for i = 1, #dir-1 do
			if dir:sub(i, i) == '/' then
				slash = i
			end
		end
		if slash == 0 then dir = ""
		else dir = dir:sub(1, slash) end
		WhereAt = 0
		scroll = 0
	elseif event[1] == "mouse_click" and event[2] == 1 and event[3] >= 8 and event[3] <= 13 and event[4] == h and dir ~= "" then
		dir = ""
		WhereAt = 0
		scroll = 0
	end
end
local function drawFiles()
	for k, v in pairs(files) do
		local bc, tc = 1, 32768
		if fs.isDir(dir..v) then tc = 32 end
		if k == WhereAt then bc = 256 end
		printHere(2, 2+k-scroll, v, bc, tc)
	end
	drawMenu()
end
local function scrollFiles(upDown)
	if upDown == -1 then
		if scroll > 0 then scroll = scroll-1 end
	elseif upDown == 1 then
		if scroll < #files-h/1.2 then scroll = scroll+1 end
	end
end
local function clickFiles(event)
	if event[1] == "mouse_scroll" then
		scrollFiles(event[2])
	elseif event[1] == "mouse_click" or "mouse_drag" then
		if event[2] == 1 then
			if event[3] == 1 and event[4] == 1 then
				running = false
				return nil
			elseif event[3] >= w-#getTime()+1 and event[3] <= w and event[4] == h then
				if mTime then mTime = false
				else mTime = true end
			elseif event[3] == w and event[4] >= 2 and event[4] <= h/2 then
				scrollFiles(-1)
			elseif event[3] == w and event[4] > h/2 and event[4] <= h-1 then
				scrollFiles(1)
			end
			for k, v in pairs(files) do
				if event[3] >= 2 and event[3] <= #v+1 and event[4] == 2+k-scroll and event[4] ~= 1 and event[4] ~= h then
					if WhereAt == k and fs.isDir(dir..files[WhereAt]) then
						dir = dir..files[WhereAt].."/"
						WhereAt = 0
						scroll = 0
					elseif WhereAt == k and not fs.isDir(dir..files[WhereAt]) then
						setColour(32768, 1)
						return shell.run(dir..files[WhereAt])
					else
						WhereAt = k
					end
				end
			end
		end
	end
	clickMenu(event)
end
local function drawDesktop()
	if running then
		setColour(1)
		term.clear()
		drawFiles()
		drawHeader()
	else
		setColour(32768, 1)
		term.clear()
		printCentred(1, "The Nest File System")
		printHere(1, 2, string.rep("-", w), 32768, 1)
		term.setCursorPos(1, 3)
	end
end

--Start Point ! 
getFiles()
drawDesktop()
while running do
	os.startTimer(0.1)
	local event = {os.pullEvent()}
	if event[1] == "timer" then
		printTime("default", h, 128, 1)
	else
		clickFiles(event)
		getFiles()
		drawDesktop()
	end
end