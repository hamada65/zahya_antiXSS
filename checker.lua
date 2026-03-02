local ALLOWED_TAGS = AntiXSSConfig.allowed_tags
local SKIPPED_SCRIPTS = AntiXSSConfig.skipped_scripts
local DEBUG = AntiXSSConfig.debug
local _GetCurrentResourceName = GetCurrentResourceName

local function isSkipped()
    local name = _GetCurrentResourceName()
    return SKIPPED_SCRIPTS[name]
end

local function decodeHtmlEntities(s)
    if type(s) ~= "string" then return s end
    for _ = 1, 3 do
        local prev = s
        s = s:gsub("&#(%d+);", function(n) return string.char(tonumber(n)) end)
        s = s:gsub("&#[xX](%x+);", function(n) return string.char(tonumber(n, 16)) end)
        if s == prev then break end
    end
    return s
end

local function looksDangerous(str)
    if not str then return false end
    local decoded = decodeHtmlEntities(str)
    local lower = decoded:lower()
    return decoded:find("<", 1, true)
        or lower:find("javascript:", 1, true)
        or lower:find("vbscript:", 1, true)
        or lower:find("data:text/html", 1, true)
        or lower:find("onerror", 1, true)
        or lower:find("onclick", 1, true)
        or lower:find("onload", 1, true)
        or lower:find("onmouseover", 1, true)
        or lower:find("<script", 1, true)
        or lower:find("<svg", 1, true)
        or lower:find("expression%s*%(", 1, true)
end

local function stripDangerousAttrs(attrs)
    if not attrs or attrs == "" then return attrs end
    attrs = attrs:gsub("on%w+%s*=%s*['\"].-['\"]", "")
    attrs = attrs:gsub("on%w+%s*=%s*[^%s>]*", "")
    attrs = attrs:gsub('style%s*=%s*["\'][^"\']*expression[^"\']*["\']', "")
    return attrs
end

local function sanitizeHtml(input, foundBad)
    if type(input) ~= "string" then
        return input
    end

    input = decodeHtmlEntities(input)

    input = input:gsub("<%s*/?%s*script.-?>", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[script]") end
        return ""
    end)
    input = input:gsub("<%s*/?%s*svg.-?>", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[svg]") end
        return ""
    end)
    input = input:gsub("on%w+%s*=%s*['\"].-['\"]", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[on* handler]") end
        return ""
    end)
    input = input:gsub("on%w+%s*=%s*[^%s>]*", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[on* unquoted]") end
        return ""
    end)
    input = input:gsub('style%s*=%s*["\'][^"\']*expression[^"\']*["\']', function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[expression]") end
        return ""
    end)
    input = input:gsub("javascript:%s*", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[javascript:]") end
        return ""
    end)
    input = input:gsub("vbscript:%s*", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[vbscript:]") end
        return ""
    end)
    input = input:gsub("data:text/html,.-[\"']", function(m)
        if foundBad and DEBUG then table.insert(foundBad, "[data:text/html]") end
        return ""
    end)

    input = input:gsub("<(/?)(%w+)(.-)>", function(close, tag, attrs)
        tag = tag:lower()
        if ALLOWED_TAGS[tag] then
            attrs = stripDangerousAttrs(attrs)
            return "<" .. close .. tag .. attrs .. ">"
        end
        if foundBad and DEBUG then table.insert(foundBad, "[" .. tag .. "]") end
        return ""
    end)

    return input
end

local function deepSanitize(data, foundBad)
    local t = type(data)

    if t == "string" then
        if looksDangerous(data) then
            return sanitizeHtml(data, foundBad)
        end
        return data
    end

    if t == "table" then
        for k, v in pairs(data) do
            data[k] = deepSanitize(v, foundBad)
        end
    end

    return data
end

if SendNUIMessage then
    local _SendNUIMessage = SendNUIMessage
    SendNUIMessage = function(data)
        if isSkipped() then
            _SendNUIMessage(data)
            return
        end
        local foundBad = {}
        local sanitized = deepSanitize(data, foundBad)
        if DEBUG and #foundBad > 0 then
            local sender = GetCurrentResourceName and GetCurrentResourceName() or "?"
            print("^1[zahya_antiXSS]^7 Blocked in ^3" .. tostring(sender) .. "^7: " .. table.concat(foundBad, " "))
        end
        _SendNUIMessage(sanitized)
    end
end
