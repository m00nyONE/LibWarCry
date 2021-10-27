LibWarCry = LibWarCry or {}
LibWarCry.name = "LibWarCry"
LibWarCry.color = "8B0000"
LibWarCry.credits = "@m00nyONE"
LibWarCry.version = "0.5.0"
LibWarCry.slashCmd = "/wc"
LibWarCry.variableVersion = 1
LibWarCry.List = {}
LibWarCry.defaultVariables = {
    groupCommands = true,
}

function LibWarCry:CreateWarCry(name, ids)
    if name == nil then d("|c8B0000LibWarCry:|r name must not be nil!") return end
    if type(ids) ~= "table" then d("|c8B0000LibWarCry:|r ids must be a table!") return end

    for index, value in ipairs(ids) do
        if type(value) ~="number" then d("|c8B0000LibWarCry:|r id must be a number!") return end
    end

    ---table.insert(WarCry.List, name, ids)
    LibWarCry.List[name] = {}
    LibWarCry.List[name].collectibleIDs = ids

    d("|c8B0000LibWarCry:|r " .. name .. " has been created")
end

function LibWarCry:PlayWarCry(name)
    if name == nil then return end
    if type(name) ~= "string" then return end

    local playable = {}
    if LibWarCry.List[name] ~= nil then
        for index, value in ipairs(LibWarCry.List[name].collectibleIDs) do
            if GetCollectibleUnlockStateById(value) == 2 then
                table.insert(playable, value)
            else 
                d("You are missing |H1:collectible:".. value .."|h|h")
            end
        end

        if #playable == 0 then  return end
        --- play random collectible from array
        UseCollectible(playable[ math.random(#playable)])
        return
    end

end

local chatCallback = function(_, messageType, _, message, _, fromDisplayName)
    -- check if message is in group chat
    if messageType == CHAT_CHANNEL_PARTY then
        -- check if message is the one we are listening for
        if LibWarCry.List[string.lower(message)] ~= nil then
            if fromDisplayName == GetUnitDisplayName(GetGroupLeaderUnitTag()) then
                -- play the warcry from the list
                LibWarCry:PlayWarCry(string.lower(message))
            end
        end
    end
end

local function startChatListener()
    EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL, chatCallback)
    d("|c8B0000LibWarCry: group listener enabled|r")
end
local function stopChatListener()
    EVENT_MANAGER:UnregisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL)
    d("|c8B0000LibWarCry: group listener disabled|r")
end

function LibWarCry.toggleListener(value)
    -- toggle listener
    if value then
        startChatListener()
    else
        stopChatListener()
    end

    -- write value to saved vars
    LibWarCry.savedVariables.groupCommands = value
end

function LibWarCry.donate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(
		function()
			ZO_MailSendToField:SetText("@m00nyONE")
			ZO_MailSendSubjectField:SetText("Donation for LibWarCry")
			QueueMoneyAttachment(1)
			ZO_MailSendBodyField:TakeFocus()
		end,
	200)
end

function LibWarCry.OnAddOnLoaded(event, addonName)
    if addonName == LibWarCry.name then
        --EVENT_MANAGER:RegisterForEvent("WarCry.name", EVENT_PLAYER_ACTIVATED, self.Init)

        LibWarCry.savedVariables = LibWarCry.savedVariables or {}
        LibWarCry.savedVariables = ZO_SavedVars:NewAccountWide("LibWarCryVars", LibWarCry.variableVersion, nil, LibWarCry.defaultVariables, GetWorldName())

        LibWarCry.createMenu()

        if LibWarCry.savedVariables.groupCommands == true then
            startChatListener()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_ADD_ON_LOADED, LibWarCry.OnAddOnLoaded)

--- create SLASH_COMMAND that can play every warcry available in the list
SLASH_COMMANDS["/warcry"] = function(str)
    if str ~= nil then
        if LibWarCry.List[string.lower(str)] ~= nil then
            LibWarCry:PlayWarCry(string.lower(str))
        end
    end
end