        -- =====================================================
        --  Grow a Garden 2 — Seed Shop Tracker  v5
        --
        --  قواعد الإرسال:
        --    ✅ فقط عند تغيّر UnixLastRestock (= وقت restock حقيقي)
        --    ✅ فقط إذا nextRestock على مضاعف 5 دقائق
        --    ✅ فحص سريع قبل الانتظار — يتخطى اللي أُبلغ مسبقاً
        --    ✅ jitter 8-45 ثانية لتفريق الطلبات
        --    ✅ Worker يتولى الـ dedup النهائي بـ atomic race lock
        --    ❌ لا إرسال عشوائي عند التشغيل
        --    ❌ لا فحص مزدوج بعد استقرار الستوك (يوسّع نافذة السباق)
        -- =====================================================

        local BASE_URL  = "https://gag2-shop.crypticluaobf.workers.dev"
        local API_TOKEN = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT"

        -- ─── HTTP ─────────────────────────────────────────
        local function req(options)
            if syn and syn.request   then return syn.request(options)   end
            if http and http.request then return http.request(options)  end
            if request               then return request(options)       end
            if http_request          then return http_request(options)  end
            error("[SeedShop] executor ما يدعم HTTP")
        end

        -- ─── JSON encoder ─────────────────────────────────
        local function json(v)
            local t = type(v)
            if t == "string"  then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"')..'"' end
            if t == "number" or t == "boolean" then return tostring(v) end
            if t == "table" then
                if #v > 0 then
                    local p = {}; for _,x in ipairs(v) do p[#p+1] = json(x) end
                    return "["..table.concat(p,",").."]"
                else
                    local p = {}; for k,x in pairs(v) do p[#p+1] = '"'..k..'":'..json(x) end
                    return "{"..table.concat(p,",").."}"
                end
            end
            return "null"
        end

        -- ─── hash البذور (للمقارنة) ────────────────────────
        local function hashSeeds(seeds)
            local h = ""
            for _, s in ipairs(seeds) do h = h .. s.name .. s.stock end
            return h
        end

        -- ─── انتظر استقرار الستوك ──────────────────────────
        local function waitForStableStock(getItems)
            local prev = hashSeeds(getItems())
            for _ = 1, 3 do
                task.wait(2)
                local items = getItems()
                local curr  = hashSeeds(items)
                if curr == prev and curr ~= "" then
                    return items
                end
                prev = curr
            end
            return getItems()
        end

        -- ─── فحص سريع: هل أُبلغ عن هذا الـ restock؟ ──────
        -- يُستخدم كـ fast path فقط — قبل الانتظار
        -- Worker هو المرجع النهائي للـ dedup
        local function alreadyReported(nextRestock)
            if nextRestock <= 0 then return false end
            local ok, res = pcall(req, {
                Url    = BASE_URL .. "/check/seed/" .. tostring(math.floor(nextRestock)),
                Method = "GET",
            })
            if not ok or res.StatusCode ~= 200 then return false end
            return res.Body:find('"skip":true') ~= nil
        end

        -- ─── تحقق أن الوقت على مضاعف 5 دقائق ────────────
        local function isValidRestockTime(nextRestock)
            if nextRestock <= 0 then return false end
            local rem = nextRestock % 300
            return rem <= 60 or rem >= 240
        end

        -- ─── انتظر SeedShop ────────────────────────────────
        print("🌱 Seed Shop Tracker v5 — بدأ التشغيل")

        local RS = game:GetService("ReplicatedStorage")

        local StockValues = RS:WaitForChild("StockValues", 30)
        if not StockValues then warn("[SeedShop] ❌ ما لقيت StockValues") return end

        local SeedShop = StockValues:WaitForChild("SeedShop", 15)
        if not SeedShop then warn("[SeedShop] ❌ ما لقيت StockValues.SeedShop") return end

        local Items       = SeedShop:WaitForChild("Items", 10)
        local NextRestock = SeedShop:FindFirstChild("UnixNextRestock")
        local LastRestock = SeedShop:FindFirstChild("UnixLastRestock")

        if not Items then warn("[SeedShop] ❌ ما لقيت Items") return end

        -- ─── جمع البذور ────────────────────────────────────
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

        -- ─── إرسال لـ Worker ───────────────────────────────
        local function reportRestock(source)
            local nr = NextRestock and math.floor(NextRestock.Value) or 0

            -- شرط 1: الوقت على مضاعف 5 دقائق
            if not isValidRestockTime(nr) then
                warn("[SeedShop] ⛔ " .. source .. " — الوقت مش مضاعف 5 دق (rem=" .. (nr%300) .. ")")
                return
            end

            -- شرط 2: فحص سريع قبل الانتظار (fast path)
            -- إذا Worker قال skip → تخطّ مباشرة بدون انتظار ثواني
            if alreadyReported(nr) then
                print("[SeedShop] ⏭️ " .. source .. " — تم الإبلاغ (fast check)")
                return
            end

            -- انتظر استقرار الستوك الكامل
            print("[SeedShop] ⏳ " .. source .. " — انتظار استقرار الستوك...")
            local seeds = waitForStableStock(getSeeds)
            if #seeds == 0 then
                warn("[SeedShop] ⚠️ الستوك فاضي — تم التخطي")
                return
            end

            -- ابعث مباشرة — Worker يتولى الـ dedup النهائي بـ atomic race lock
            local body = json({ seeds = seeds, nextRestock = nr })
            local ok, res = pcall(req, {
                Url     = BASE_URL .. "/report",
                Method  = "POST",
                Headers = {
                    ["Content-Type"]    = "application/json",
                    ["X-Cryptic-Token"] = API_TOKEN,
                },
                Body = body,
            })

            if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
                if res.Body:find('"skipped":true') then
                    print("[SeedShop] ⏭️ Worker: dedup — تم التخطي")
                elseif res.Body:find('"sent":true') then
                    print("[SeedShop] ✅ " .. source .. " | أُرسل | " .. #seeds .. " بذرة | nextRestock=" .. nr)
                else
                    print("[SeedShop] ℹ️ " .. source .. " | " .. res.Body)
                end
            else
                warn("[SeedShop] ❌ " .. tostring(ok and res.StatusCode or res))
            end
        end

        -- ─── عند التشغيل: فقط إذا كان الـ restock حديثاً ──
        do
            local lr   = LastRestock and LastRestock.Value or 0
            local diff = os.time() - lr
            if lr > 0 and diff <= 90 then
                print("[SeedShop] 🔄 restock حديث قبل " .. diff .. " ث — سنتحقق...")
                task.wait(math.random(3, 12))
                reportRestock("initial-check")
            else
                print("[SeedShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق — لا إرسال أولي")
            end
        end

        -- ─── مراقبة UnixLastRestock ────────────────────────
        -- jitter أكبر (8-45 ث) لتفريق الطلبات بين المستخدمين
        -- Worker يضمن رسالة واحدة فقط عبر atomic race lock
        if LastRestock then
            LastRestock.Changed:Connect(function()
                local jitter = math.random(8, 45)
                print("[SeedShop] 🔔 LastRestock تغيّر — jitter " .. jitter .. " ث")
                task.wait(jitter)
                reportRestock("restock-event")
            end)
        else
            warn("[SeedShop] ⚠️ UnixLastRestock غير موجود — لا يوجد event listener")
        end

        print("[SeedShop] 👂 ينتظر أحداث الـ restock...")
