      -- =====================================================
      --  Grow a Garden 2 — Gear Shop Tracker  v8
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
      local DEBOUNCE_S = 10

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

      -- ─── انتظار استقرار الستوك ────────────────────────────
      local function waitForStableStock(getItems)
          local prev = hashGear(getItems())
          for _ = 1, 3 do
              task.wait(2)
              local items = getItems()
              local curr  = hashGear(items)
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
      print("⚙️ Gear Shop Tracker v8 — بدأ التشغيل")
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
                  print("[GearShop] ✅ وجدناه (partial): " .. child.Name)
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
          -- تحقق: هل أنا القائد؟
          if not isLeader() then
              print("[GearShop] 👤 لست القائد في هذا السيرفر — تخطي")
              return
          end

          print("[GearShop] ⏳ " .. source .. " — القائد، انتظار الاستقرار...")
          local gear = waitForStableStock(getGear)

          if #gear == 0 then
              warn("[GearShop] ⚠️ الستوك فاضي — تخطي")
              return
          end

          local nr = NextRestock and math.floor(NextRestock.Value) or 0

          if not isValidRestockTime(nr) then
              warn("[GearShop] ⛔ " .. source .. " — rem=" .. (nr % 300) .. " ليس مضاعف 5 دق")
              return
          end

          local windowKey = math.floor(nr / 300) * 300
          if reportedWindows[windowKey] then
              print("[GearShop] ⏭️ هذا الـ window سبق أُبلغ عنه محلياً")
              return
          end

          reportedWindows[windowKey] = true
          print("[GearShop] 📤 " .. source .. " | قائد | " .. #gear .. " عنصر | nr=" .. nr)

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
                  print("[GearShop] ✅ أُرسل لـ Discord بنجاح")
              elseif body:find('"skipped":true') then
                  local reason = body:match('"reason":"([^"]+)"') or "?"
                  print("[GearShop] ⏭️ Worker skip — " .. reason)
              else
                  print("[GearShop] ℹ️ " .. body)
              end
          else
              reportedWindows[windowKey] = nil
              warn("[GearShop] ❌ " .. tostring(ok and res.StatusCode or res))
          end
      end

      -- ─── فحص أولي ────────────────────────────────────────
      do
          local lr   = LastRestock and LastRestock.Value or 0
          local diff = os.time() - lr
          if lr > 0 and diff <= 90 then
              print("[GearShop] 🔄 restock حديث منذ " .. diff .. " ث")
              task.wait(math.random(3, 12))
              reportRestock("startup")
          else
              print("[GearShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق")
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

              if windowKey == lastWindow and (now - lastFiredAt) < DEBOUNCE_S then
                  print("[GearShop] 🔕 debounce — تكرار سريع")
                  return
              end

              lastFiredAt = now
              lastFiredNr = nr

              local jitter = math.random(8, 45)
              print("[GearShop] 🔔 restock! jitter=" .. jitter .. " ث | nr=" .. nr)
              task.wait(jitter)
              reportRestock("event")
          end)
      else
          warn("[GearShop] ⚠️ UnixLastRestock غير موجود")
      end

      print("[GearShop] 👂 جاهز — v8 leader election + debounce")
