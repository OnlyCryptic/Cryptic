        -- =====================================================
        --  Grow a Garden 2 — Seed Shop Tracker  v9
        --
        --  الحل النهائي القطعي — 4 طبقات:
        --
        --  طبقة 1 — Leader election (Roblox)
        --    فقط اللاعب بأصغر UserId في السيرفر يبعث
        --    → الـ 50+ لاعب في السيرفر يصبحون طلباً واحداً
        --
        --  طبقة 2 — Lua local guard
        --    reportedWindows يمنع نفس السكربت من الإرسال مرتين
        --
        --  طبقة 3 — Jitter 30-90 ث
        --    يفصل بين طلبات السيرفرات المختلفة
        --    30 ث > KV propagation time (عادة 5-10 ث)
        --    → لما يصل السيرفر الثاني، الـ Worker يرى SENT في KV
        --
        --  طبقة 4 — Worker v12 (Cloudflare)
        --    • in-memory Set  → نفس isolate، صفر زمن
        --    • Cache API      → نفس datacenter
        --    • KV "SENT"      → cross-datacenter، بعد الإرسال
        --    • KV claim+verify → write-then-read
        --
        --  stable stock: 3 ث انتظار أولي + 3 قراءات ثابتة
        --    → يضمن الستوك كامل بدون قلتشات
        --
        --  لماذا 30-90 ث وليس 8-45 ث؟
        --    KV يحتاج 5-15 ث للانتشار بين الـ datacenters
        --    الـ jitter الصغير يسمح لسيرفرين بالإرسال قبل KV
        --    الـ jitter الكبير (30 ث minimum) يضمن أن السيرفر
        --    الثاني يرى "SENT" في KV قبل أن يرسل
        -- =====================================================

        local BASE_URL   = "https://gag2-shop.crypticluaobf.workers.dev"
        local API_TOKEN  = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT"
        local DEBOUNCE_S = 12

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

        -- ─────────────────────────────────────────────────────
        --  waitForStableStock — ضمان ستوك كامل بدون قلتشات
        --
        --  خوارزمية:
        --    1. انتظر 3 ث (للسماح بتحميل البيانات الأولي)
        --    2. خذ 3 قراءات بفاصل 2 ث بين كل قراءة
        --    3. إذا تطابقت 3 قراءات متتالية → الستوك مستقر
        --    4. إذا لم يستقر → أعد من الخطوة 2 (max 3 جولات)
        -- ─────────────────────────────────────────────────────
        local function waitForStableStock(getItems)
            -- انتظار أولي: يعطي اللعبة وقتاً لتحديث البيانات
            task.wait(3)

            for attempt = 1, 3 do
                local reads = {}
                reads[1] = hashSeeds(getItems())
                task.wait(2)
                reads[2] = hashSeeds(getItems())
                task.wait(2)
                reads[3] = hashSeeds(getItems())

                -- الثلاث قراءات متطابقة وغير فارغة = مستقر
                if reads[1] == reads[2] and reads[2] == reads[3] and reads[1] ~= "" then
                    return getItems()
                end

                print("[SeedShop] ⏳ محاولة " .. attempt .. "/3 للاستقرار...")
            end

            -- استسلم — أرجع ما تيسر
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
                if player.UserId < myId then
                    return false
                end
            end
            return true
        end

        -- ─── تشغيل ────────────────────────────────────────────
        print("🌱 Seed Shop Tracker v9 — بدأ التشغيل")
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
            -- طبقة 1: leader election
            if not isLeader() then
                print("[SeedShop] 👤 لست القائد — تخطي")
                return
            end

            -- طبقة 4 — stable stock (3 ث + 3 قراءات)
            print("[SeedShop] ⏳ " .. source .. " — القائد، أنتظر استقرار الستوك...")
            local seeds = waitForStableStock(getSeeds)

            if #seeds == 0 then
                warn("[SeedShop] ⚠️ الستوك فاضي بعد الانتظار — تخطي")
                return
            end

            -- أعد قراءة nextRestock بعد الاستقرار
            local nr = NextRestock and math.floor(NextRestock.Value) or 0

            if not isValidRestockTime(nr) then
                warn("[SeedShop] ⛔ rem=" .. (nr%300) .. " ليس مضاعف 5 دق — تخطي")
                return
            end

            -- طبقة 2: local window guard
            local windowKey = math.floor(nr / 300) * 300
            if reportedWindows[windowKey] then
                print("[SeedShop] ⏭️ window=" .. windowKey .. " سبق أُبلغ عنه")
                return
            end

            -- أرسل
            reportedWindows[windowKey] = true
            print("[SeedShop] 📤 " .. source .. " | " .. #seeds .. " بذرة | nr=" .. nr)

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
                    print("[SeedShop] ✅ أُرسل لـ Discord")
                elseif body:find('"skipped":true') then
                    local reason = body:match('"reason":"([^"]+)"') or "?"
                    print("[SeedShop] ⏭️ Worker skip: " .. reason)
                else
                    print("[SeedShop] ℹ️ " .. body)
                end
            else
                -- فشل — أطلق الـ lock لمحاولة لاحقة
                reportedWindows[windowKey] = nil
                warn("[SeedShop] ❌ HTTP " .. tostring(ok and res.StatusCode or res))
            end
        end

        -- ─── فحص أولي (startup) ──────────────────────────────
        do
            local lr   = LastRestock and LastRestock.Value or 0
            local diff = os.time() - lr
            if lr > 0 and diff <= 90 then
                print("[SeedShop] 🔄 restock حديث (منذ " .. diff .. " ث) — فحص أولي")
                task.wait(math.random(3, 10))
                reportRestock("startup")
            else
                print("[SeedShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق")
            end
        end

        -- ─── مراقبة LastRestock ───────────────────────────────
        if LastRestock then
            local lastFiredAt  = 0
            local lastFiredNr  = 0

            LastRestock.Changed:Connect(function()
                local now = os.clock()
                local nr  = NextRestock and math.floor(NextRestock.Value) or 0

                local curWindow  = math.floor(nr / 300) * 300
                local lastWindow = math.floor(lastFiredNr / 300) * 300

                -- DEBOUNCE: نفس النافذة وسريع جداً
                if curWindow == lastWindow and (now - lastFiredAt) < DEBOUNCE_S then
                    print("[SeedShop] 🔕 debounce (نفس النافذة، " .. string.format("%.1f", now-lastFiredAt) .. " ث)")
                    return
                end

                lastFiredAt = now
                lastFiredNr = nr

                -- ─── طبقة 3: Jitter 30-90 ث ─────────────────────
                --
                --  لماذا 30 ث كحد أدنى؟
                --    KV يحتاج 5-15 ث للانتشار cross-datacenter
                --    30 ث > 2× الحد الأقصى → أي سيرفر آخر يصل بعدنا
                --    سيجد "SENT" في KV ولن يرسل
                --
                --  لماذا 90 ث كحد أقصى؟
                --    الـ restock كل 5 دق (300 ث)
                --    90 ث < 300 ث → الإشعار يصل دائماً خلال نفس الـ window
                local jitter = math.random(30, 90)
                print("[SeedShop] 🔔 restock! jitter=" .. jitter .. " ث | nr=" .. nr)
                task.wait(jitter)
                reportRestock("event")
            end)
        else
            warn("[SeedShop] ⚠️ UnixLastRestock غير موجود")
        end

        print("[SeedShop] 👂 جاهز — v9 (leader+30-90s jitter+stable stock)")
