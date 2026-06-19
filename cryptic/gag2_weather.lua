-- =====================================================
--  Grow a Garden 2 — Weather Tracker  v1
--
--  مستقل تماماً — لا علاقة له بـ Seed/Gear Shop
--
--  الحماية من التكرار:
--    طبقة 1 — Leader election (أصغر UserId في السيرفر)
--    طبقة 2 — Local guard (reportedWeathers)
--    طبقة 3 — Redis SETNX (cross-server dedup)
--
--  يبعث مباشرة لـ Discord Webhook (بدون Worker)
-- =====================================================

local WEBHOOK_URL = "https://discord.com/api/webhooks/1496631385807655084/_OUjVC3tF69dhNEVBW4YZJ6RJjlceOy5Q_wU6NudfVpkGm5QcgSwfysoMQM0vkiyhYwm"
local REDIS_URL   = "https://renewed-bream-149570.upstash.io"
local REDIS_TOKEN = "gQAAAAAAAkhCAAIgcDEwN2EyNmRhMGRhODM0YjJhOGU2OTQ1NDBjYWNkMzBjOA"

-- ─── بيانات الطقس (ترتيب: الأندر أولاً) ──────────────
local WEATHER_DATA = {
    Snowfall  = {
        role     = "1517600640954794225",
        emoji    = "<:Snowfall:1517600139546460320>",
        color    = 11393254,  -- 0xADD8E6 أزرق فاتح
        label    = "Snowfall",
        duration = "~2:30 دقيقة",
        ttl      = 300,
    },
    Starfall  = {
        role     = "1517600615193120810",
        emoji    = "<:emoji_200:1517600156076347573>",
        color    = 16766720,  -- 0xFFD700 ذهبي
        label    = "Starfall",
        duration = "~2:00 دقيقة",
        ttl      = 300,
    },
    Lightning = {
        role     = "1517600589742342155",
        emoji    = "<:Lightning:1517600111415398420>",
        color    = 16776960,  -- 0xFFFF00 أصفر
        label    = "Lightning",
        duration = "~5:00 دقائق",
        ttl      = 400,
    },
    Rainbow   = {
        role     = "1517600562902990890",
        emoji    = "<:Rainbow:1517600126737059910>",
        color    = 16744272,  -- 0xFF7750 برتقالي/قوس قزح
        label    = "Rainbow",
        duration = "~3:00 دقائق",
        ttl      = 300,
    },
    Rain      = {
        role     = "1517600532448153663",
        emoji    = "<:Rain:1517600093128101888>",
        color    = 4325457,   -- 0x4195D1 أزرق
        label    = "Rain",
        duration = "~3:00 دقائق",
        ttl      = 300,
    },
}

-- ─── HTTP ─────────────────────────────────────────────
local function req(options)
    if syn and syn.request   then return syn.request(options)   end
    if http and http.request then return http.request(options)  end
    if request               then return request(options)       end
    if http_request          then return http_request(options)  end
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
    local myId = LocalPlayer.UserId
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId < myId then return false end
    end
    return true
end

-- ─── Redis SETNX ─────────────────────────────────────
--  key: gag2:weather:{weatherName}:{timeWindow}
--  يرجع true  → نحن الأوائل
--  يرجع false → سيرفر آخر سبق
local function tryClaimRedis(weatherName, ttl)
    local window = math.floor(os.time() / ttl) * ttl
    local key    = "gag2:weather:" .. weatherName .. ":" .. window
    local url    = REDIS_URL .. "/set/" .. key .. "/1/EX/" .. (ttl + 30) .. "/NX"

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
        warn("[Weather] ⚠️ Redis error: " .. tostring(res) .. " — نكمل بدونه")
        return true  -- fallback
    end

    local body = res.Body or ""
    if body:find('"OK"') then
        print("[Weather] 🔑 Redis ✅ " .. weatherName .. " | window=" .. window)
        return true
    else
        print("[Weather] 🔑 Redis ⛔ " .. weatherName .. " — سيرفر آخر سبق")
        return false
    end
end

-- ─── بناء وإرسال الـ Discord embed ────────────────────
local function sendWeatherAlert(weatherName, data)
    local mention = "<@&" .. data.role .. ">"
    local payload = json({
        username = "🌦️ Grow a Garden 2 — Weather",
        content  = mention,
        embeds   = {
            {
                title       = data.emoji .. " " .. data.label .. " بدأت!",
                description = "**" .. data.label .. "** نشطة الآن في السيرفر\nاستفد منها قبل ما تنتهي!",
                color       = data.color,
                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                fields      = {
                    { name = "⏱️ المدة التقريبية", value = data.duration, inline = true },
                },
                footer      = {
                    text = "Grow a Garden 2 Weather Tracker  •  Dev: @d8u_  •  discord.gg/QSvQJs7BdP"
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
        print("[Weather] ✅ أُرسل لـ Discord: " .. weatherName)
        return true
    else
        warn("[Weather] ❌ Discord HTTP " .. tostring(ok and res.StatusCode or res))
        return false
    end
end

-- ─── حماية محلية ─────────────────────────────────────
local reportedWeathers = {}

-- ─── معالجة تغيير الطقس ───────────────────────────────
local function onWeatherChanged(newWeather)
    -- نظف الاسم (بعض الألعاب تحط مسافات أو UpperCase)
    local clean = (newWeather or ""):match("^%s*(.-)%s*$")

    local data = WEATHER_DATA[clean]
    if not data then
        print("[Weather] ☁️ طقس عادي أو غير مراقب: '" .. clean .. "'")
        return
    end

    print("[Weather] 🌦️ طقس جديد: " .. clean)

    -- طبقة 1: leader election
    if not isLeader() then
        print("[Weather] 👤 لست القائد — تخطي")
        return
    end

    -- طبقة 2: local guard (نافذة 5 دقائق)
    local window = math.floor(os.time() / data.ttl) * data.ttl
    local localKey = clean .. ":" .. window
    if reportedWeathers[localKey] then
        print("[Weather] ⏭️ local: " .. clean .. " سبق أُبلغ عنه")
        return
    end

    -- طبقة 3: Redis SETNX
    if not tryClaimRedis(clean, data.ttl) then
        reportedWeathers[localKey] = true
        return
    end

    reportedWeathers[localKey] = true

    -- jitter صغير 1-3 ث
    local jitter = math.random(1, 3)
    task.wait(jitter)

    local sent = sendWeatherAlert(clean, data)
    if not sent then
        -- فشل — أطلق المحلي (Redis محجوز ما نعيد)
        reportedWeathers[localKey] = nil
    end
end

-- ─── البحث عن مصدر الطقس ─────────────────────────────
print("🌦️ Weather Tracker v1 — بدأ التشغيل")
print("[Weather] 🆔 UserId=" .. LocalPlayer.UserId)

local RS = game:GetService("ReplicatedStorage")

-- جرب مسارات مختلفة للطقس
local weatherSource = nil
local weatherPaths = {
    -- StringValue مباشر
    function() return RS:WaitForChild("CurrentWeather", 8) end,
    function() return RS:WaitForChild("Weather", 5) end,
    -- قد يكون داخل مجلد
    function()
        local ws = RS:FindFirstChild("WeatherService") or RS:FindFirstChild("WeatherData")
        return ws and ws:FindFirstChild("CurrentWeather")
    end,
    function()
        local gd = RS:FindFirstChild("GameData") or RS:FindFirstChild("GameValues")
        return gd and gd:FindFirstChild("CurrentWeather")
    end,
}

for i, pathFn in ipairs(weatherPaths) do
    local ok, result = pcall(pathFn)
    if ok and result then
        weatherSource = result
        print("[Weather] ✅ وجدنا مصدر الطقس (مسار " .. i .. "): " .. result:GetFullName())
        print("[Weather] 📋 النوع: " .. result.ClassName .. " | القيمة الحالية: " .. tostring(result.Value))
        break
    end
end

if not weatherSource then
    -- fallback: ابحث في كل RS
    warn("[Weather] ⚠️ ما لقينا CurrentWeather في المسارات المعروفة")
    warn("[Weather] 🔍 المحتويات المتاحة في ReplicatedStorage:")
    for _, child in ipairs(RS:GetChildren()) do
        warn("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    warn("[Weather] ❌ Weather Tracker متوقف — راجع الـ output أعلاه")
    return
end

-- ─── فحص الطقس الحالي عند التشغيل ───────────────────
do
    local current = tostring(weatherSource.Value or "")
    if current ~= "" and current ~= "None" and current ~= "Day" and current ~= "Night" then
        print("[Weather] 🔄 طقس حالي عند التشغيل: " .. current)
        task.wait(math.random(2, 5))
        onWeatherChanged(current)
    else
        print("[Weather] ☀️ لا يوجد طقس خاص حالياً: '" .. current .. "'")
    end
end

-- ─── مراقبة التغييرات ─────────────────────────────────
weatherSource.Changed:Connect(function(newValue)
    onWeatherChanged(tostring(newValue))
end)

print("[Weather] 👂 جاهز — يراقب تغييرات الطقس")
