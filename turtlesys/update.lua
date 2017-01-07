--[[
	Manual Update Client for TurtleSys by Zocker1999NET
	
	Based on the Github Repository Downloader by max96at
	CC-Forum: http://www.computercraft.info/forums2/index.php?/topic/4072-github-repository-downloader/
	Pastebin: http://pastebin.com/wPtGKMam
]]

local gUser, gRepo, gBranch = "Zocker1999NET", "CCTools-Turtle", "master"

local fileList = {dirs={},files={}}
local x , y = term.getSize()

-- GUI
function printTitle()
	local line = 2
	term.setCursorPos(1,line)
	for i = 2, x, 1 do write("-") end
	term.setCursorPos((x-title:len())/2,line+1)
	print(title)
	for i = 2, x, 1 do write("-") end
end

function writeCenter( str )
	term.clear()
	printTitle()
	term.setCursorPos((x-str:len())/2-1,y/2-1)
	for i = -1, str:len(), 1 do write("-") end
	term.setCursorPos((x-str:len())/2-1,y/2)
	print("|"..str.."|")
	term.setCursorPos((x-str:len())/2-1,y/2+1)
	for i = -1, str:len(), 1 do write("-") end
end

-- Download File
function downloadFile( path, url, name )
	writeCenter("Downloading File: "..name)
	dirPath = path:gmatch('([%w%_%.% %-%+%,%;%:%*%#%=%/]+)/'..name..'$')()
	if dirPath ~= nil and not fs.isDir(dirPath) then fs.makeDir(dirPath) end
	local content = http.get(url)
	local file = fs.open(path,"w")
	file.write(content.readAll())
	file.close()
end

-- Get Directory Contents
function getGithubContents( path )
	local pType, pPath, pName, checkPath = {}, {}, {}, {}
	local response = http.get("https://api.github.com/repos/"..gUser.."/"..gRepo.."/contents/"..path.."/?ref="..gBranch)
	if response then
		response = response.readAll()
		if response ~= nil then
			for str in response:gmatch('"type":"(%w+)"') do table.insert(pType, str) end
			for str in response:gmatch('"path":"([^\"]+)"') do table.insert(pPath, str) end
			for str in response:gmatch('"name":"([^\"]+)"') do table.insert(pName, str) end
		end
	else
		writeCenter( "Error: Can't resolve URL" )
		sleep(2)
		term.clear()
		term.setCursorPos(1,1)
		error()
	end
	return pType, pPath, pName
end

-- Blacklist Function
function isBlackListed( path )
	if blackList:gmatch("@"..path)() ~= nil then
		return true
	end
end

-- Download Manager
function downloadManager( path )
	local fType, fPath, fName = getGithubContents( path )
	for i,data in pairs(fType) do
		if data == "file" then
			checkPath = http.get("https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i])
			if checkPath == nil then
				fPath[i] = fPath[i].."/"..fName[i]
			end
			local path = fPath[i]
			if not fileList.files[path] and not isBlackListed(fPath[i]) then
				fileList.files[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
			end
		end
	end
	for i, data in pairs(fType) do
		if data == "dir" then
			local path = fPath[i]
			if not fileList.dirs[path] then 
				writeCenter("Listing directory: "..fName[i])
				fileList.dirs[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
				downloadManager( fPath[i] )
			end
		end
	end
end

-- Main Function
function main()
	writeCenter("Connecting to Github")
	downloadManager("")
	for i, data in pairs(fileList.files) do
		downloadFile( i, data[1], data[2] )
	end
	writeCenter("Download completed")
	sleep(2,5)
	term.clear()
	term.setCursorPos(1,1)
end

if not http then
	writeCenter("You need to enable the HTTP API!")
	sleep(3)
	term.clear()
	term.setCursorPos(1,1)
else
	main()
	os.reboot()
end