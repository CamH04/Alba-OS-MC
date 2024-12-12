s.pullEvent = os.pullEventRaw
 
local w,h = term.getSize()
 
function centerPrint  (y,s)
    local x = math.floor(( w - string.len(s)) / 2)
    term.setCursorPos(x,y)
    term.clearLine()
    term.write(s)
end
 
 
local nOption = 1
--GUII
term.clear()
 
local function drawFrontend()
    -- round down lmao
    centerPrint( math.floor(h/2) - 3, "")
    centerPrint( math.floor(h/2) - 2, "Start Menu")
    centerPrint( math.floor(h/2) - 1, "")
    centerPrint( math.floor(h/2) + 0, ((nOption == 1) and "> Command <") or "Command" )
    centerPrint( math.floor(h/2) + 1, ((nOption == 2) and "> Programs <") or "Programs" )
    centerPrint( math.floor(h/2) + 2, ((nOption == 3) and "> Shutdown <") or "Shutdown" )
    centerPrint( math.floor(h/2) + 3, ((nOption == 4) and "> Uninstall <") or " Uninstall" )
    centerPrint( math.floor(h/2) + 4, "")
end 

local function drawMenu()
    term.clear()
    term.setCursorPos(1,2)
    term.write(" (0,0)")
    term.setCursorPos(1,3)
    term.write(" /)_)/")
    term.setCursorPos(1,4)
    term.write("  **  ")
    term.setCursorPos(1,5)
    term.write(" -----")
    term.setCursorPos(1,6)
    term.write("Alba OS")
    --god help us
    --center menu
    term.setCursorPos(w - 11,1)
    if NOption == 1 then
        term.write("Cli")
    elseif nOption == 2 then
        term.write("Programs")
    elseif nOption == 3 then
        term.write("Shutdown")
    else
        end
end
 
--Start Point 
drawMenu()
drawFrontend()  
while true do
    local e,p = os.pullEvent()
        if e == "key" then
            local key = p
            if key == keys.w or key == keys.up then 
                if nOption > 1 then 
                    nOption = nOption - 1
                    drawMenu()
                    drawFrontend()
                end
        elseif key == keys.s or key == keys.down then
            if nOption < 4 then 
                nOption = nOption + 1
                drawMenu()
                drawFrontend()
   
         end 
         elseif key == keys.e or keys.enter then 
         break
         end
     end  
end
term.clear()
 
-- Conditions
if nOption == 1 then 
    shell.run("AlbaOS/.command")
elseif nOption == 2 then
    shell.run("AlbaOS/.programs") 
elseif nOption == 3 then
    os.shutdown()
else
    shell.run("AlbaOS/.UninstallDialog")
end 
nOption = 1 