-- =====================================================
--  Grow a Garden 2 — Gear Shop Tracker  v10
--
--  طبقات الحماية من التكرار:
--
--  طبقة 1 — Leader election (Roblox)
--    فقط اللاعب بأصغر UserId في السيرفر يبعث
--    → يقلل الطلبات من نفس السيرفر لطلب واحد
--
--  طبقة 2 — Lua local guard
--    reportedWindows يمنع نفس السكربت من الإرسال مرتين
--
--  طبقة 3 — Upstash Redis SETNX (global dedup)
--    كل ستوك جديد له مفتاح في Redis مدته 360 ث
--    أول سيرفر يحجز المفتاح → يبعث
--    كل السيرفرات الأخرى → يشوفون "مأخوذ" ويتخطون
--    هذا يحل مشكلة كتير سيرفرات في نفس الماب
--
--  طبقة 4 — Worker (Cloudflare)
--    خط دفاع أخير في حال تجاوز Redis
--
--  stable stock: 3 ث انتظار + 3 قراءات متطابقة
-- =====================================================

local BASE_URL    = "https://gag2-shop.crypticluaobf.workers.dev"
local API_TOKEN   = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT"
local REDIS_URL   = "https://renewed-bream-149570.upstash.io"
local REDIS_TOKEN = "gQAAAAAAAkhCAAIgcDEwN2EyNmRhMGRhODM0YjJhOGU2OTQ1NDBjYWNkMzBjOA"
local DEBOUNCE_S  = 12

-- ─── HTTP ─────────────────────────────────────────────
local function req(options)
    if syn and syn.request   then return syn.request(options)   end
    if http and http.request then return http.request(options)  end
    if request               then return request(options)       end
    if http_request          then return http_request(options)  end
    error("[GearShop] executor ما يدعم HTTP")
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

-- ─── hash الـ gear ────────────────────────────────────
local function hashGear(gear)
    local h = ""
    for _, g in ipairs(gear) do h = h .. g.name .. g.stock end
    return h
end

-- ─────────────────────────────────────────────────────
--  waitForStableStock — ضمان ستوك كامل بدون قلتشات
-- ─────────────────────────────────────────────────────
local function waitForStableStock(getItems)
    task.wait(3)
    for attempt = 1, 3 do
        local reads = {}
        reads[1] = hashGear(getItems())
        task.wait(2)
        reads[2] = hashGear(getItems())
        task.wait(2)
        reads[3] = hashGear(getItems())

        if reads[1] == reads[2] and reads[2] == reads[3] and reads[1] ~= "" then
            return getItems()
        end
        print("[GearShop] ⏳ محاولة " .. attempt .. "/3 للاستقرار...")
    end
    return getItems()
end

-- ─── تحقق من مضاعف 5 دق ─────────────────────────────
local function isValidRestockTime(nr)
    if nr <= 0 then return false end
    local rem = nr % 300
    return rem <= 60 or rem >= 240
end

-- ─────────────────────────────────────────────────────
--  LEADER ELECTION — فقط المستخدم بأصغر UserId يبعث
-- ─────────────────────────────────────────────────────
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function isLeader()
    local myId = LocalPlayer.UserId
    for _, player in ipairs(Players:GetPlayers()) do
        if player.UserId < myId then return false end
    end
    return true
end

-- ─────────────────────────────────────────────────────
--  Redis SETNX — global dedup بين السيرفرات
--  المفتاح: gag2:gear:{windowKey}
--  TTL: 360 ث (أكثر من نافذة الـ 5 دق)
--  يرجع true  → نحن الأوائل، تابع
--  يرجع false → سيرفر آخر سبقنا، تخطى
-- ─────────────────────────────────────────────────────
local function tryClaimRedis(windowKey)
    local key = "gag2:gear:" .. windowKey
    local url = REDIS_URL .. "/set/" .. key .. "/1?nx=true&ex=360"

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
        warn("[GearShop] ⚠️ Redis خطأ: " .. tostring(res) .. " — نكمل بدونه")
        return true  -- fallback: إذا Redis فشل نكمل عشان لا يضيع الإشعار
    end

    local body = res.Body or ""
    if body:find('"OK"') then
        print("[GearShop] 🔑 Redis ✅ حجزنا window=" .. windowKey)
        return true
    else
        print("[GearShop] 🔑 Redis ⛔ سيرفر آخر سبق — window=" .. windowKey)
        return false
    end
end

-- ─── تشغيل ────────────────────────────────────────────
print("⚙️ Gear Shop Tracker v10 — بدأ التشغيل")
print("[GearShop] 🆔 UserId=" .. LocalPlayer.UserId)

local RS = game:GetService("ReplicatedStorage")

local StockValues = RS:WaitForChild("StockValues", 30)
if not StockValues then warn("[GearShop] ❌ ما لقيت StockValues") return end

-- ─── البحث عن GearShop ────────────────────────────────
local GEAR_NAMES = { "GearShop","EquipmentShop","ItemShop","ToolShop","ShopGear","Gear" }
local GearShop

for _, name in ipairs(GEAR_NAMES) do
    GearShop = StockValues:FindFirstChild(name)
    if GearShop then print("[GearShop] ✅ وجدناه: " .. name) break end
end

if not GearShop then
    for _, child in ipairs(StockValues:GetChildren()) do
        local n = child.Name:lower()
        if n:find("gear") or n:find("equip") or n:find("tool") then
            GearShop = child
            print("[GearShop] ✅ وجدناه (fuzzy): " .. child.Name)
            break
        end
    end
end

if not GearShop then
    warn("[GearShop] ❌ ما لقيت Gear Shop تحت StockValues")
    for _, c in ipairs(StockValues:GetChildren()) do warn("  - " .. c.Name) end
    return
end

local Items       = GearShop:WaitForChild("Items", 10)
local NextRestock = GearShop:FindFirstChild("UnixNextRestock")
local LastRestock = GearShop:FindFirstChild("UnixLastRestock")

if not Items then warn("[GearShop] ❌ ما لقيت Items") return end

-- ─── جمع الـ Gear ──────────────────────────────────────
local function getGear()
    local gear = {}
    for _, v in ipairs(Items:GetChildren()) do
        if v:IsA("NumberValue") and v.Value > 0 then
            table.insert(gear, { name = v.Name, stock = v.Value })
        end
    end
    table.sort(gear, function(a, b) return a.stock > b.stock end)
    return gear
end

-- ─── حماية محلية ─────────────────────────────────────
local reportedWindows = {}

-- ─── الإبلاغ لـ Worker ────────────────────────────────
local function reportRestock(source)
    -- طبقة 1: leader election
    if not isLeader() then
        print("[GearShop] 👤 لست القائد — تخطي")
        return
    end

    -- stable stock
    print("[GearShop] ⏳ " .. source .. " — القائد، أنتظر استقرار الستوك...")
    local gear = waitForStableStock(getGear)

    if #gear == 0 then
        warn("[GearShop] ⚠️ الستوك فاضي بعد الانتظار — تخطي")
        return
    end

    local nr = NextRestock and math.floor(NextRestock.Value) or 0

    if not isValidRestockTime(nr) then
        warn("[GearShop] ⛔ rem=" .. (nr%300) .. " ليس مضاعف 5 دق — تخطي")
        return
    end

    local windowKey = math.floor(nr / 300) * 300

    -- طبقة 2: local window guard
    if reportedWindows[windowKey] then
        print("[GearShop] ⏭️ local: window=" .. windowKey .. " سبق أُبلغ عنه")
        return
    end

    -- طبقة 3: Redis global dedup
    if not tryClaimRedis(windowKey) then
        reportedWindows[windowKey] = true  -- نحفظ محلياً عشان ما نعيد المحاولة
        return
    end

    reportedWindows[windowKey] = true
    print("[GearShop] 📤 " .. source .. " | " .. #gear .. " عنصر | nr=" .. nr)

    local ok, res = pcall(req, {
        Url     = BASE_URL .. "/report/gear",
        Method  = "POST",
        Headers = {
            ["Content-Type"]    = "application/json",
            ["X-Cryptic-Token"] = API_TOKEN,
        },
        Body = json({ items = gear, nextRestock = nr }),
    })

    if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
        local body = res.Body or ""
        if body:find('"sent":true') then
            print("[GearShop] ✅ أُرسل لـ Discord")
        elseif body:find('"skipped":true') then
            local reason = body:match('"reason":"([^"]+)"') or "?"
            print("[GearShop] ⏭️ Worker skip: " .. reason)
        else
            print("[GearShop] ℹ️ " .. body)
        end
    else
        -- فشل — أطلق الـ lock المحلي فقط (Redis محجوز، ما نعيد)
        reportedWindows[windowKey] = nil
        warn("[GearShop] ❌ HTTP " .. tostring(ok and res.StatusCode or res))
    end
end

-- ─── فحص أولي ────────────────────────────────────────
do
    local lr   = LastRestock and LastRestock.Value or 0
    local diff = os.time() - lr
    if lr > 0 and diff <= 90 then
        print("[GearShop] 🔄 restock حديث (منذ " .. diff .. " ث) — فحص أولي")
        task.wait(math.random(3, 10))
        reportRestock("startup")
    else
        print("[GearShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق")
    end
end

-- ─── مراقبة LastRestock ───────────────────────────────
if LastRestock then
    local lastFiredAt = 0
    local lastFiredNr = 0

    LastRestock.Changed:Connect(function()
        local now = os.clock()
        local nr  = NextRestock and math.floor(NextRestock.Value) or 0

        local curWindow  = math.floor(nr / 300) * 300
        local lastWindow = math.floor(lastFiredNr / 300) * 300

        if curWindow == lastWindow and (now - lastFiredAt) < DEBOUNCE_S then
            print("[GearShop] 🔕 debounce (" .. string.format("%.1f", now-lastFiredAt) .. " ث)")
            return
        end

        lastFiredAt = now
        lastFiredNr = nr

        -- jitter 5-15 ث (Redis يتكفل بـ cross-server dedup، ما نحتاج 30-90 ث)
        local jitter = math.random(5, 15)
        print("[GearShop] 🔔 restock! jitter=" .. jitter .. " ث | nr=" .. nr)
        task.wait(jitter)
        reportRestock("event")
    end)
else
    warn("[GearShop] ⚠️ UnixLastRestock غير موجود")
end

print("[GearShop] 👂 جاهز — v10 (leader + Redis SETNX + stable stock)")
