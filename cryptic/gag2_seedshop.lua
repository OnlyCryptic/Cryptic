        -- =====================================================
        --  Grow a Garden 2 — Seed Shop Tracker  v3
        --
        --  المنطق:
        --    1. عند تغيّر UnixLastRestock أو عند التشغيل:
        --       → تحقق أولاً من الـ Worker هل بعثنا لهذا الـ restock
        --       → إذا لا: ابعث POST (رسالة واحدة مضمونة)
        --       → إذا نعم: تجاهل (لا تكرار)
        --    2. Polling كل دقيقتين كـ fallback فقط إذا تغيّر الستوك
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

        -- ─── JSON encoder بسيط ────────────────────────────
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

        -- ─── تحقق هل بعثنا لهذا الـ restock من قبل ────────
        -- يسأل الـ Worker مباشرة قبل ما يبعث — هذا يمنع التكرار
        local function alreadyReported(nextRestock)
            if nextRestock <= 0 then return false end
            local ok, res = pcall(req, {
                Url    = BASE_URL .. "/check/seed/" .. tostring(math.floor(nextRestock)),
                Method = "GET",
            })
            if not ok or res.StatusCode ~= 200 then return false end
            return res.Body:find('"skip":true') ~= nil
        end

        -- ─── انتظر SeedShop ────────────────────────────────
        print("🌱 Seed Shop Tracker v3 — بدأ التشغيل")

        local RS      = game:GetService("ReplicatedStorage")

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

        -- ─── إرسال ─────────────────────────────────────────
        local lastSentHash = ""

        local function send(seeds, force)
            if #seeds == 0 then return end

            -- hash للتحقق من تغيّر المحتوى (للـ polling فقط)
            local hash = ""
            for _, s in ipairs(seeds) do hash = hash .. s.name .. s.stock end
            if not force and hash == lastSentHash then return end

            local nr = NextRestock and math.floor(NextRestock.Value) or 0

            -- ── تحقق من الـ Worker أولاً ──────────────────────
            -- هذا السطر هو قلب منع التكرار:
            -- إذا أحد سبقنا وبعث لهذا الـ restock → تجاهل
            if alreadyReported(nr) then
                print("[SeedShop] ⏭️ تم الإبلاغ مسبقاً لهذا الـ restock — تم التخطي")
                lastSentHash = hash
                return
            end

            -- ── ابعث POST ──────────────────────────────────
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
                lastSentHash = hash
                -- تحقق من الرد: هل أُرسل أم تخُطي؟
                if res.Body:find('"skipped":true') then
                    print("[SeedShop] ⏭️ Worker: تم الإبلاغ مسبقاً")
                else
                    print("[SeedShop] ✅ أُرسل | " .. #seeds .. " بذرة")
                end
            else
                warn("[SeedShop] ❌ " .. tostring(ok and res.StatusCode or res))
            end
        end

        -- ─── إرسال أولي ────────────────────────────────────
        -- تأخير عشوائي لتفريق اللاعبين — بعدها check أولاً
        task.wait(math.random(3, 15))
        send(getSeeds(), true)

        -- ─── مراقبة UnixLastRestock ────────────────────────
        if LastRestock then
            LastRestock.Changed:Connect(function()
                -- تأخير عشوائي 3-20 ث → يفرّق الطلبات
                -- الأول يبعث، الباقين يشوفون skip من الـ check
                task.wait(3 + math.random(0, 17))
                send(getSeeds(), true)
            end)
        end

        -- ─── Polling كل دقيقتين كـ fallback ─────────────────
        -- يبعث فقط لو تغيّر الستوك (hash مختلف) ولو لم يُبلَّغ بعد
        while task.wait(120) do
            send(getSeeds(), false)
        end
