        -- =====================================================
        --  Grow a Garden 2 — Seed Shop Tracker
        --  يرسل مباشرة لـ Cloudflare Worker
        -- =====================================================

        local WORKER_URL = "https://gag2-shop.crypticluaobf.workers.dev/report"

        -- ─── HTTP ─────────────────────────────────────────
        local function req(options)
            if syn and syn.request   then return syn.request(options)   end
            if http and http.request then return http.request(options)  end
            if request               then return request(options)       end
            if http_request          then return http_request(options)  end
            error("[SeedShop] executor ما يدعم HTTP")
        end

        -- ─── JSON بسيط ────────────────────────────────────
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

        -- ─── انتظر SeedShop ────────────────────────────────
        print("🌱 Seed Shop Tracker — بدأ التشغيل")

        local RS       = game:GetService("ReplicatedStorage")
        local Players  = game:GetService("Players")

        local StockValues = RS:WaitForChild("StockValues", 30)
        if not StockValues then
            warn("[SeedShop] ❌ ما لقيت StockValues")
            return
        end
        local SeedShop = StockValues:WaitForChild("SeedShop", 15)
        if not SeedShop then
            warn("[SeedShop] ❌ ما لقيت StockValues.SeedShop")
            return
        end

        local Items       = SeedShop:WaitForChild("Items", 10)
        local NextRestock = SeedShop:FindFirstChild("UnixNextRestock")
        local LastRestock = SeedShop:FindFirstChild("UnixLastRestock")

        if not Items then
            warn("[SeedShop] ❌ ما لقيت Items")
            return
        end

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
            local hash = ""
            for _, s in ipairs(seeds) do hash = hash .. s.name .. s.stock end
            if not force and hash == lastSentHash then return end
            if #seeds == 0 then return end

            local body = json({
                seeds       = seeds,
                nextRestock = NextRestock and NextRestock.Value or 0,
            })

            local ok, res = pcall(req, {
                Url     = WORKER_URL,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json", ["X-Cryptic-Token"] = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT" },
                Body    = body,
            })

            if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
                lastSentHash = hash
                print("[SeedShop] ✅ أُرسل | " .. #seeds .. " بذرة | discord.gg شيك")
            else
                warn("[SeedShop] ❌ " .. tostring(ok and res.StatusCode or res))
            end
        end

        -- ─── إرسال أولي (بعد تأخير عشوائي حتى لا يتزاحم كل اللاعبين) ───
        task.wait(2 + math.random(0, 20))
        send(getSeeds(), true)

        -- ─── مراقبة UnixLastRestock ────────────────────────
        if LastRestock then
            LastRestock.Changed:Connect(function()
                -- تأخير عشوائي 5-30 ث → يفرّق الطلبات ويمنع التزاحم على الـ Worker
                task.wait(5 + math.random(0, 25))
                send(getSeeds(), true)
            end)
        end

        -- ─── Polling كل دقيقتين كـ fallback ─────────────────
        while task.wait(120) do
            send(getSeeds(), false)
        end
