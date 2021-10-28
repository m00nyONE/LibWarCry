LibWarCry = LibWarCry or {}
LibWarCry.name = "LibWarCry"
LibWarCry.color = "8B0000"
LibWarCry.credits = "@m00nyONE"
LibWarCry.version = "1.0.0"
LibWarCry.slashCmdShort = "/wc"
LibWarCry.slashCmdLong = "/warcry"
LibWarCry.variableVersion = 1
LibWarCry.List = {}
LibWarCry.defaultVariables = {
    groupCommands = true,
}

-- function that creates a warcry and adds it to the internal list
function LibWarCry:CreateWarCry(name, ids)
    -- error catching to prevent addon developers from doing something bad
    if name == nil then d("|c8B0000LibWarCry:|r name must not be nil!") return end
    if type(ids) ~= "table" then d("|c8B0000LibWarCry:|r ids must be a table!") return end

    -- iterate over the inserted id's
    for index, value in ipairs(ids) do
        -- check if they are numbers
        if type(value) ~="number" then d("|c8B0000LibWarCry:|r id must be a number!") return end
    end

    -- create a new table inside of the warcry list and fill it with nessecary information
    LibWarCry.List[name] = {}
    LibWarCry.List[name].collectibleIDs = ids

    -- tell the user that the warcry has been created - this will usually not be seen because of the Chat UI loading slower than the addons
    d("|c8B0000LibWarCry:|r " .. name .. " has been created")
end

-- function that plays the collectible/s
function LibWarCry:PlayWarCry(name)
    -- error handling to not crash when a user inserts numbers or tables into chat
    if name == nil then return end
    if type(name) ~= "string" then return end

    -- create a new table called playable - it will store the ID's of the warcry the player has access to
    local playable = {}
    -- check if the warcry exists
    if LibWarCry.List[name] ~= nil then
        -- iterate over the collectible ids of the warcry
        for index, value in ipairs(LibWarCry.List[name].collectibleIDs) do
            -- check if the collectible is unlocked
            if GetCollectibleUnlockStateById(value) == 2 then
                -- if so, insert it into the playable table/array
                table.insert(playable, value)
            else 
                -- otherwise display a message which collectible is missing and where to get it from
                d("You are missing |H1:collectible:".. value .."|h|h")
            end
        end

        -- return when there is nothing that can be played
        if #playable == 0 then  return end
        -- play random collectible from array
        UseCollectible(playable[ math.random(#playable)])
        return
    end

end

-- callback function that gets excecuted when a message is sent to the group channel
local chatCallback = function(_, messageType, _, message, _, fromDisplayName)
    -- check if message is in group chat
    if messageType == CHAT_CHANNEL_PARTY then
        -- check if message is the one we are listening for
        if LibWarCry.List[string.lower(message)] ~= nil then
            -- check if the message is from the group leader
            if fromDisplayName == GetUnitDisplayName(GetGroupLeaderUnitTag()) then
                -- play the warcry from the list
                LibWarCry:PlayWarCry(string.lower(message))
            end
        end
    end
end

-- start listener by subscribing to EVENT_CHAT_MESSAGE_CHANNEL
local function startChatListener()
    EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL, chatCallback)
    d("|c8B0000LibWarCry: group listener enabled|r")
end
-- stop listener by unsubscribing from EVENT_CHAT_MESSAGE_CHANNEL
local function stopChatListener()
    EVENT_MANAGER:UnregisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL)
    d("|c8B0000LibWarCry: group listener disabled|r")
end

-- toggles the group listener on and off
function LibWarCry.toggleListener(value)
    if value then
        startChatListener()
    else
        stopChatListener()
    end

    -- write value to saved vars
    LibWarCry.savedVariables.groupCommands = value
end

-- donate to me if you want to
function LibWarCry.donate()
    -- show message window
	SCENE_MANAGER:Show('mailSend')
    -- wait 200 ms async
	zo_callLater(
		function()
            -- fill out messagebox
			ZO_MailSendToField:SetText("@m00nyONE")
			ZO_MailSendSubjectField:SetText("Donation for LibWarCry")
			QueueMoneyAttachment(1)
			ZO_MailSendBodyField:TakeFocus()
		end,
	200)
end

-- function to play warcry when entering /wc $NAME
local function slashCommand(str)
    if str ~= nil then
        if LibWarCry.List[string.lower(str)] ~= nil then
            LibWarCry:PlayWarCry(string.lower(str))
        end
    end
end

function LibWarCry.OnAddOnLoaded(event, addonName)
    if addonName == LibWarCry.name then

        -- load saved variables ( global )
        LibWarCry.savedVariables = LibWarCry.savedVariables or {}
        LibWarCry.savedVariables = ZO_SavedVars:NewAccountWide("LibWarCryVars", LibWarCry.variableVersion, nil, LibWarCry.defaultVariables, GetWorldName())

        -- create the LibAddonMenu entry
        LibWarCry.createMenu()

        -- check if the group listener is enabled. if so, start it
        if LibWarCry.savedVariables.groupCommands == true then
            startChatListener()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_ADD_ON_LOADED, LibWarCry.OnAddOnLoaded)

--- create SLASH_COMMAND that can play every warcry available in the list
SLASH_COMMANDS[LibWarCry.slashCmdShort] = slashCommand
SLASH_COMMANDS[LibWarCry.slashCmdLong] = slashCommand