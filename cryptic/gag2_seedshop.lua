        -- =====================================================
        --  Grow a Garden 2 — Seed Shop Tracker  v8
        --
        --  الحل القطعي — 3 طبقات:
        --
        --  طبقة 1 — Roblox server leader election
        --    فقط المستخدم بأصغر UserId في السيرفر يبعث
        --    → كل سيرفر Roblox يبعث طلب واحد بالضبط
        --
        --  طبقة 2 — Lua debounce + window guard
        --    debounce 10 ث يمنع إطلاق الحدث أكثر من مرة
        --    window guard يمنع نفس السكربت من الإرسال مرتين
        --
        --  طبقة 3 — Worker v10 (Cloudflare)
        --    • 5-min window lock  → رسالة واحدة كل 5 دقائق
        --    • Cache API          → نفس datacenter فوري
        --    • double KV verify   → cross-datacenter
        --
        --  النتيجة: مستحيل وصول أكثر من رسالة لـ Discord
        -- =====================================================

        local BASE_URL   = "https://gag2-shop.crypticluaobf.workers.dev"
        local API_TOKEN  = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT"
        local DEBOUNCE_S = 10  -- تجاهل الأحداث المتكررة خلال 10 ث

        -- ─── HTTP ─────────────────────────────────────────────
        local function req(options)
            if syn and syn.request   then return syn.request(options)   end
            if http and http.request then return http.request(options)  end
            if request               then return request(options)       end
            if http_request          then return http_request(options)  end
            error("[SeedShop] executor ما يدعم HTTP")
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

        -- ─── hash البذور ──────────────────────────────────────
        local function hashSeeds(seeds)
            local h = ""
            for _, s in ipairs(seeds) do h = h .. s.name .. s.stock end
            return h
        end

        -- ─── انتظار استقرار الستوك ────────────────────────────
        local function waitForStableStock(getItems)
            local prev = hashSeeds(getItems())
            for _ = 1, 3 do
                task.wait(2)
                local items = getItems()
                local curr  = hashSeeds(items)
                if curr == prev and curr ~= "" then return items end
                prev = curr
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
        --  داخل كل سيرفر Roblox، واحد فقط هو "القائد"
        --  بقية المستخدمين يتجاهلون الحدث تماماً
        -- ─────────────────────────────────────────────────────
        local Players  = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local function isLeader()
            local myId = LocalPlayer.UserId
            -- أصغر UserId في السيرفر = القائد
            for _, player in ipairs(Players:GetPlayers()) do
                if player.UserId < myId then
                    return false  -- في واحد أصغر، مو قائد
                end
            end
            return true  -- أنا الأصغر = القائد
        end

        -- ─── تشغيل ────────────────────────────────────────────
        print("🌱 Seed Shop Tracker v8 — بدأ التشغيل")
        print("[SeedShop] 🆔 UserId=" .. LocalPlayer.UserId)

        local RS = game:GetService("ReplicatedStorage")

        local StockValues = RS:WaitForChild("StockValues", 30)
        if not StockValues then warn("[SeedShop] ❌ ما لقيت StockValues") return end

        local SeedShop = StockValues:WaitForChild("SeedShop", 15)
        if not SeedShop then warn("[SeedShop] ❌ ما لقيت SeedShop") return end

        local Items       = SeedShop:WaitForChild("Items", 10)
        local NextRestock = SeedShop:FindFirstChild("UnixNextRestock")
        local LastRestock = SeedShop:FindFirstChild("UnixLastRestock")

        if not Items then warn("[SeedShop] ❌ ما لقيت Items") return end

        -- ─── جمع البذور ───────────────────────────────────────
        local function getSeeds()
            local seeds = {}
            for _, v in ipairs(Items:GetChildren()) do
                if v:IsA("NumberValue") and v.Value > 0 then
                    table.insert(seeds, { name = v.Name, stock = v.Value })
                end
            end
            table.sort(seeds, function(a, b) return a.stock > b.stock end)
            return seeds
        end

        -- ─── حماية محلية ─────────────────────────────────────
        local reportedWindows = {}

        -- ─── الإبلاغ لـ Worker ────────────────────────────────
        local function reportRestock(source)
            -- تحقق: هل أنا القائد في هذا السيرفر؟
            if not isLeader() then
                print("[SeedShop] 👤 لست القائد في هذا السيرفر — تخطي")
                return
            end

            -- انتظر استقرار الستوك
            print("[SeedShop] ⏳ " .. source .. " — القائد، انتظار الاستقرار...")
            local seeds = waitForStableStock(getSeeds)

            if #seeds == 0 then
                warn("[SeedShop] ⚠️ الستوك فاضي — تخطي")
                return
            end

            -- أعد قراءة nextRestock بعد الاستقرار
            local nr = NextRestock and math.floor(NextRestock.Value) or 0

            -- تحقق من المضاعف
            if not isValidRestockTime(nr) then
                warn("[SeedShop] ⛔ " .. source .. " — rem=" .. (nr % 300) .. " ليس مضاعف 5 دق")
                return
            end

            -- window guard
            local windowKey = math.floor(nr / 300) * 300
            if reportedWindows[windowKey] then
                print("[SeedShop] ⏭️ هذا الـ window سبق أُبلغ عنه محلياً")
                return
            end

            -- ابعث — Worker يعمل الـ dedup النهائي
            reportedWindows[windowKey] = true
            print("[SeedShop] 📤 " .. source .. " | قائد | " .. #seeds .. " بذرة | nr=" .. nr)

            local ok, res = pcall(req, {
                Url     = BASE_URL .. "/report",
                Method  = "POST",
                Headers = {
                    ["Content-Type"]    = "application/json",
                    ["X-Cryptic-Token"] = API_TOKEN,
                },
                Body = json({ seeds = seeds, nextRestock = nr }),
            })

            if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
                local body = res.Body or ""
                if body:find('"sent":true') then
                    print("[SeedShop] ✅ أُرسل لـ Discord بنجاح")
                elseif body:find('"skipped":true') then
                    local reason = body:match('"reason":"([^"]+)"') or "?"
                    print("[SeedShop] ⏭️ Worker skip — " .. reason)
                else
                    print("[SeedShop] ℹ️ " .. body)
                end
            else
                reportedWindows[windowKey] = nil
                warn("[SeedShop] ❌ " .. tostring(ok and res.StatusCode or res))
            end
        end

        -- ─── فحص أولي ────────────────────────────────────────
        do
            local lr   = LastRestock and LastRestock.Value or 0
            local diff = os.time() - lr
            if lr > 0 and diff <= 90 then
                print("[SeedShop] 🔄 restock حديث منذ " .. diff .. " ث")
                task.wait(math.random(3, 12))
                reportRestock("startup")
            else
                print("[SeedShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق")
            end
        end

        -- ─── مراقبة LastRestock مع DEBOUNCE ──────────────────
        if LastRestock then
            local lastFiredAt = 0
            local lastFiredNr = 0

            LastRestock.Changed:Connect(function()
                local now = os.clock()
                local nr  = NextRestock and math.floor(NextRestock.Value) or 0

                local windowKey  = math.floor(nr / 300) * 300
                local lastWindow = math.floor(lastFiredNr / 300) * 300

                -- DEBOUNCE: نفس النافذة وسريع جداً → تجاهل
                if windowKey == lastWindow and (now - lastFiredAt) < DEBOUNCE_S then
                    print("[SeedShop] 🔕 debounce — تكرار سريع")
                    return
                end

                lastFiredAt = now
                lastFiredNr = nr

                -- jitter: يفرّق بين طلبات السيرفرات المختلفة
                local jitter = math.random(8, 45)
                print("[SeedShop] 🔔 restock! jitter=" .. jitter .. " ث | nr=" .. nr)
                task.wait(jitter)
                reportRestock("event")
            end)
        else
            warn("[SeedShop] ⚠️ UnixLastRestock غير موجود")
        end

        print("[SeedShop] 👂 جاهز — v8 leader election + debounce")
