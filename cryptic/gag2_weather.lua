-- =====================================================
--  Grow a Garden 2 — Weather Tracker  v2
--
--  الهيكل الحقيقي:
--    RS.WeatherValues.{WeatherName}.Playing (BoolValue)
--    RS.WeatherValues.{WeatherName}.EndTime (NumberValue)
--
--  الحماية من التكرار:
--    طبقة 1 — Leader election (أصغر UserId)
--    طبقة 2 — Local guard (endTime كـ event ID)
--    طبقة 3 — Redis SETNX (cross-server dedup)
-- =====================================================

local WEBHOOK_URL = "https://discord.com/api/webhooks/1496631385807655084/_OUjVC3tF69dhNEVBW4YZJ6RJjlceOy5Q_wU6NudfVpkGm5QcgSwfysoMQM0vkiyhYwm"
local REDIS_URL   = "https://renewed-bream-149570.upstash.io"
local REDIS_TOKEN = "gQAAAAAAAkhCAAIgcDEwN2EyNmRhMGRhODM0YjJhOGU2OTQ1NDBjYWNkMzBjOA"

local WEATHER_DATA = {
    Snowfall  = { role = "1517600640954794225", emoji = "<:Snowfall:1517600139546460320>",  color = 11393254, label = "Snowfall"  },
    Starfall  = { role = "1517600615193120810", emoji = "<:emoji_200:1517600156076347573>", color = 16766720, label = "Starfall"  },
    Lightning = { role = "1517600589742342155", emoji = "<:Lightning:1517600111415398420>", color = 16776960, label = "Lightning" },
    Rainbow   = { role = "1517600562902990890", emoji = "<:Rainbow:1517600126737059910>",   color = 16744272, label = "Rainbow"   },
    Rain      = { role = "1517600532448153663", emoji = "<:Rain:1517600093128101888>",      color = 4325457,  label = "Rain"      },
}

-- ─── HTTP ─────────────────────────────────────────────
local function req(opts)
    if syn and syn.request    then return syn.request(opts)    end
    if http and http.request  then return http.request(opts)   end
    if request                then return request(opts)        end
    if http_request           then return http_request(opts)   end
    error("[Weather] executor ما يدعم HTTP")
end

-- ─── JSON encoder ─────────────────────────────────────
local function json(v)
    local t = type(v)
    if t == "string"  then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"')..'"' end
    if t == "number" or t == "boolean" then return tostring(v) end
    if t == "table" then
        if #v > 0 then
            local p = {}
            for _, x in ipairs(v) do p[#p+1] = json(x) end
            return "["..table.concat(p,",").."]"
        else
            local p = {}
            for k, x in pairs(v) do p[#p+1] = '"'..k..'":'..json(x) end
            return "{"..table.concat(p,",").."}"
        end
    end
    return "null"
end

-- ─── Leader election ─────────────────────────────────
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function isLeader()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId < LocalPlayer.UserId then return false end
    end
    return true
end

-- ─── Redis SETNX ─────────────────────────────────────
-- key: gag2:weather:{name}:{endTime}  → فريد لكل event
local function tryClaimRedis(weatherName, endTime)
    local key = "gag2:weather:" .. weatherName .. ":" .. math.floor(endTime)
    local url = REDIS_URL .. "/set/" .. key .. "/1/EX/600/NX"

    local ok, res = pcall(req, {
        Url     = url,
        Method  = "POST",
        Headers = {
            ["Authorization"] = "Bearer " .. REDIS_TOKEN,
            ["Content-Type"]  = "application/json",
        },
        Body = "",
    })

    if not ok then
        warn("[Weather] ⚠️ Redis error: " .. tostring(res))
        return true  -- fallback: نكمل
    end

    local body = res.Body or ""
    if body:find('"OK"') then
        print("[Weather] 🔑 Redis ✅ " .. weatherName)
        return true
    else
        print("[Weather] 🔑 Redis ⛔ " .. weatherName .. " — سيرفر سبق")
        return false
    end
end

-- ─── تحويل الثواني لـ mm:ss ──────────────────────────
local function fmtDuration(secs)
    if secs <= 0 then return "؟" end
    local m = math.floor(secs / 60)
    local s = math.floor(secs % 60)
    return string.format("%d:%02d", m, s)
end

-- ─── إرسال Discord ────────────────────────────────────
local function sendAlert(weatherName, data, endTime)
    -- احسب المدة من EndTime (Roblox workspace time)
    local duration = "؟"
    if endTime and endTime > 0 then
        local remaining = endTime - workspace:GetServerTimeNow()
        if remaining > 0 then
            duration = fmtDuration(remaining) .. " دقيقة"
        end
    end

    local mention = "<@&" .. data.role .. ">"
    local payload = json({
        username = "🌦️ Grow a Garden 2 — Weather",
        content  = mention,
        embeds   = {
            {
                title       = data.emoji .. "  " .. data.label .. " بدأت!",
                description = "**" .. data.label .. "** نشطة الآن — استفد منها قبل ما تنتهي!",
                color       = data.color,
                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                fields      = {
                    { name = "⏱️ المدة المتبقية", value = duration, inline = true },
                },
                footer = {
                    text = "GAG2 Weather Tracker  •  Dev: @d8u_  •  discord.gg/QSvQJs7BdP"
                },
            }
        }
    })

    local ok, res = pcall(req, {
        Url     = WEBHOOK_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = payload,
    })

    if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
        print("[Weather] ✅ أُرسل: " .. weatherName .. " | duration=" .. duration)
        return true
    else
        warn("[Weather] ❌ Discord error: " .. tostring(ok and res.StatusCode or res))
        return false
    end
end

-- ─── معالجة activation ───────────────────────────────
local reportedEvents = {}

local function onWeatherActivated(weatherName, playingVal, endTimeVal)
    local data = WEATHER_DATA[weatherName]
    if not data then
        print("[Weather] ⚪ طقس غير مراقب: " .. weatherName)
        return
    end

    local endTime = endTimeVal and endTimeVal.Value or 0

    print("[Weather] 🌦️ " .. weatherName .. " بدأ | endTime=" .. endTime)

    -- طبقة 1: leader
    if not isLeader() then
        print("[Weather] 👤 لست القائد — تخطي")
        return
    end

    -- طبقة 2: local guard (endTime كـ event ID)
    local eventKey = weatherName .. ":" .. math.floor(endTime)
    if reportedEvents[eventKey] then
        print("[Weather] ⏭️ local: " .. weatherName .. " سبق أُبلغ عنه")
        return
    end

    -- طبقة 3: Redis
    if not tryClaimRedis(weatherName, endTime) then
        reportedEvents[eventKey] = true
        return
    end

    reportedEvents[eventKey] = true

    task.wait(math.random(1, 3))
    sendAlert(weatherName, data, endTime)
end

-- ─── ربط الأحداث ─────────────────────────────────────
print("🌦️ Weather Tracker v2 — بدأ التشغيل")

local RS = game:GetService("ReplicatedStorage")
local WeatherValues = RS:WaitForChild("WeatherValues", 15)

if not WeatherValues then
    warn("[Weather] ❌ ما لقينا RS.WeatherValues — توقف")
    return
end

print("[Weather] ✅ RS.WeatherValues موجود")

-- دالة تربط weather folder
local function bindWeather(folder)
    local name      = folder.Name
    local playingVal = folder:WaitForChild("Playing", 5)
    local endTimeVal = folder:FindFirstChild("EndTime")

    if not playingVal then
        warn("[Weather] ⚠️ " .. name .. " ما عنده Playing value")
        return
    end

    print("[Weather] 👂 ربطنا: " .. name .. " | Playing=" .. tostring(playingVal.Value))

    -- لو الطقس شغال عند التشغيل
    if playingVal.Value == true then
        task.wait(math.random(2, 4))
        onWeatherActivated(name, playingVal, endTimeVal)
    end

    -- راقب التغييرات
    playingVal.Changed:Connect(function(newVal)
        if newVal == true then
            onWeatherActivated(name, playingVal, endTimeVal)
        else
            print("[Weather] 🔚 " .. name .. " انتهت")
        end
    end)
end

-- اربط الـ folders الموجودة الآن
for _, folder in ipairs(WeatherValues:GetChildren()) do
    if folder:IsA("Folder") then
        task.spawn(bindWeather, folder)
    end
end

-- راقب لو ضافوا weathers جديدة مستقبلاً
WeatherValues.ChildAdded:Connect(function(child)
    if child:IsA("Folder") then
        print("[Weather] 🆕 طقس جديد اكتُشف: " .. child.Name)
        task.spawn(bindWeather, child)
    end
end)

print("[Weather] 👂 جاهز — يراقب " .. #WeatherValues:GetChildren() .. " طقس")
