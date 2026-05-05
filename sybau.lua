local ADDON_NAME = ...

local PREFIX = "|cff66d9efSYBAU|r:"

local FILTER_EVENTS = {
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_RAID_BOSS_WHISPER",
}

sybauDB = sybauDB or {}
local db = sybauDB

local compiledPatterns = {}
local compiledExtraPatterns = {}

local function EscapePattern(text)
    return (text:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

local function CompileLine(line)
    local pattern = EscapePattern(line)

    pattern = pattern:gsub("<[^>]+>", ".+")

    return "^" .. pattern .. "$"
end

local function CompileUserLine(line)
    local pattern = EscapePattern(line)

    pattern = pattern:gsub("%%%*", ".*")
    pattern = pattern:gsub("<[^>]+>", ".+")

    return "^" .. pattern
end

local function BuildPatterns()
    wipe(compiledPatterns)
    wipe(compiledExtraPatterns)

    local rawLines = SYBAU_BLOCKED_LINES or ""
    for line in rawLines:gmatch("[^\r\n]+") do
        line = strtrim(line)

        if line ~= "" and line:sub(1, 1) ~= "#" then
            table.insert(compiledPatterns, CompileLine(line))
        end
    end

    for _, line in ipairs(db.extraPatterns or {}) do
        if type(line) == "string" and line ~= "" then
            table.insert(compiledExtraPatterns, CompileUserLine(line))
        end
    end
end

local function EnsureDefaults()
    if db.enabled == nil then
        db.enabled = true
    end

    db.blocked = tonumber(db.blocked) or 0
    db.extraPatterns = db.extraPatterns or {}

    if db.tutorial == nil then
        db.tutorial = true
    end
end

local function Say(message)
    print(PREFIX .. " " .. message)
end

local function IsBlockedMessage(message)
    if type(message) ~= "string" or message == "" then
        return false
    end

    for _, pattern in ipairs(compiledPatterns) do
        if message:find(pattern) then
            return true
        end
    end

    for _, pattern in ipairs(compiledExtraPatterns) do
        if message:find(pattern) then
            return true
        end
    end

    return false
end

local function ChatFilter(_, _, message)
    if not db.enabled then
        return false
    end

    if IsBlockedMessage(message) then
        db.blocked = db.blocked + 1
        return true
    end

    return false
end

local function ListExtraPatterns()
    if #db.extraPatterns == 0 then
        Say("no extra patterns.")
        return
    end

    Say("extra patterns:")
    for index, pattern in ipairs(db.extraPatterns) do
        print(index .. ". " .. pattern)
    end
end

local function RemoveExtraPattern(indexText)
    local index = tonumber(indexText)
    if not index or not db.extraPatterns[index] then
        Say("usage: /sybau remove <number>")
        return
    end

    local removed = table.remove(db.extraPatterns, index)
    BuildPatterns()
    Say("removed: " .. removed)
end

local function PrintHelp()
    Say((db.enabled and "on" or "off") .. ", blocked " .. db.blocked .. " lines. commands: /sybau, /sybau toggle, /sybau tutorial, /sybau reset, /sybau add <text>, /sybau list, /sybau remove <number>")
end

local function HandleSlash(input)
    input = strtrim(input or "")

    local command, rest = input:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" or command == "status" then
        PrintHelp()
    elseif command == "toggle" then
        db.enabled = not db.enabled
        Say(db.enabled and "on." or "off.")
    elseif command == "tutorial" then
        db.tutorial = not db.tutorial
        Say("tutorial " .. (db.tutorial and "on." or "off."))
    elseif command == "reset" then
        db.blocked = 0
        Say("count reset.")
    elseif command == "add" then
        rest = strtrim(rest or "")
        if rest == "" then
            Say("usage: /sybau add <text>")
            return
        end

        table.insert(db.extraPatterns, rest)
        BuildPatterns()
        Say("added: " .. rest)
    elseif command == "remove" or command == "rm" then
        RemoveExtraPattern(rest)
    elseif command == "list" then
        ListExtraPatterns()
    else
        PrintHelp()
    end
end

EnsureDefaults()
BuildPatterns()

for _, event in ipairs(FILTER_EVENTS) do
    ChatFrame_AddMessageEventFilter(event, ChatFilter)
end

SLASH_SYBAU1 = "/sybau"
SlashCmdList.SYBAU = HandleSlash

local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("ADDON_LOADED")
loadedFrame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == ADDON_NAME then
        EnsureDefaults()
        BuildPatterns()
        if db.tutorial then
            print('SYBAU Tutorial (deactivate with /sybau tutorial): Toggle ON/OFF with "/sybau toggle". SYBAU is default ON. You can add your own lines with "/sybau add" followed by full line or just the starting word(s). Use * anywhere in the line and in any number to replace variables such as race, class, or missing word(s). <race>, <class> formatting also works if you copy from warcraft.wiki.gg.')
        end
    end
end)
