-- =====================================================
--  Grow a Garden 2 — Gear Shop Tracker
--  يرسل لـ Cloudflare Worker /report/gear
-- =====================================================

local WORKER_URL = "https://gag2-shop.crypticluaobf.workers.dev/report/gear"

-- ─── HTTP ─────────────────────────────────────────────
local function req(options)
    if syn and syn.request   then return syn.request(options)   end
    if http and http.request then return http.request(options)  end
    if request               then return request(options)       end
    if http_request          then return http_request(options)  end
    error("[GearShop] executor ما يدعم HTTP")
end

-- ─── JSON بسيط ────────────────────────────────────────
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

-- ─── انتظر اللعبة تحمّل ───────────────────────────────
print("⚙️ Gear Shop Tracker — بدأ التشغيل")

local RS      = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local StockValues = RS:WaitForChild("StockValues", 30)
if not StockValues then
    warn("[GearShop] ❌ ما لقيت StockValues")
    return
end

-- ─── نبحث عن GearShop تحت StockValues ────────────────
-- اللعبة ممكن تستخدم أي اسم، نجرّب أكثر الأسماء شيوعاً
local GEAR_NAMES = { "GearShop", "EquipmentShop", "ItemShop", "ToolShop", "ShopGear", "Gear" }
local GearShop

for _, name in ipairs(GEAR_NAMES) do
    GearShop = StockValues:FindFirstChild(name)
    if GearShop then
        print("[GearShop] ✅ وجدناه: StockValues." .. name)
        break
    end
end

if not GearShop then
    -- بحث بالـ partial match
    for _, child in ipairs(StockValues:GetChildren()) do
        local n = child.Name:lower()
        if n:find("gear") or n:find("equip") or n:find("tool") then
            GearShop = child
            print("[GearShop] ✅ وجدناه (partial): " .. child.Name)
            break
        end
    end
end

if not GearShop then
    warn("[GearShop] ❌ ما لقيت Gear Shop تحت StockValues")
    warn("[GearShop] الأولاد الموجودون:")
    for _, c in ipairs(StockValues:GetChildren()) do
        warn("  - " .. c.Name)
    end
    return
end

local Items       = GearShop:WaitForChild("Items", 10)
local NextRestock = GearShop:FindFirstChild("UnixNextRestock")
local LastRestock = GearShop:FindFirstChild("UnixLastRestock")

if not Items then
    warn("[GearShop] ❌ ما لقيت Items — جرّب تشغّل السكان وتبعث لنا النتيجة")
    return
end

-- ─── جمع الـ Gear ─────────────────────────────────────
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

-- ─── إرسال للـ Worker ─────────────────────────────────
local lastSentHash = ""

local function send(gear, force)
    local hash = ""
    for _, g in ipairs(gear) do hash = hash .. g.name .. g.stock end
    if not force and hash == lastSentHash then return end
    if #gear == 0 then return end

    local body = json({
        items       = gear,
        nextRestock = NextRestock and NextRestock.Value or 0,
    })

    local ok, res = pcall(req, {
        Url     = WORKER_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    })

    if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
        lastSentHash = hash
        local resp = pcall(function()
            local j = game:GetService("HttpService"):JSONDecode(res.Body)
            if j.skipped then
                print("[GearShop] ⏭️ Slot مقفول — لا تكرار")
                return
            end
        end)
        print("[GearShop] ✅ أُرسل | " .. #gear .. " عنصر")
    else
        warn("[GearShop] ❌ " .. tostring(ok and res.StatusCode or res))
    end
end

-- ─── إرسال أولي ────────────────────────────────────────
task.wait(2)
send(getGear(), true)

-- ─── مراقبة UnixLastRestock ────────────────────────────
if LastRestock then
    LastRestock.Changed:Connect(function()
        task.wait(0.5)
        send(getGear(), true)
    end)
end

-- ─── Polling كل دقيقتين كـ fallback ────────────────────
while task.wait(120) do
    send(getGear(), false)
end
