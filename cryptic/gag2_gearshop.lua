      -- =====================================================
      --  Grow a Garden 2 — Gear Shop Tracker  v7
      --
      --  الفلسفة: الـ Lua تبعث بس — Worker يقرر
      --
      --  Worker v10 يعمل 3 مستويات dedup:
      --    1. window cooldown  → رسالة وحدة كل 5 دقائق
      --    2. content hash     → نفس الستوك → لا إرسال أبداً
      --    3. write-then-read  → race condition proof
      --
      --  الـ Lua مسؤوليتها فقط:
      --    - jitter (8-45 ث) لتوزيع الضغط
      --    - انتظار استقرار الستوك
      --    - local guard ضد الإرسال المزدوج من نفس السكربت
      -- =====================================================

      local BASE_URL  = "https://gag2-shop.crypticluaobf.workers.dev"
      local API_TOKEN = "SUf4RmxL1Pv_ECaNfI6KRRk1dAdW2cDT"

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

      -- ─── تحقق أن nextRestock على مضاعف 5 دق ──────────────
      local function isValidRestockTime(nr)
          if nr <= 0 then return false end
          local rem = nr % 300
          return rem <= 60 or rem >= 240
      end

      -- ─── تشغيل ────────────────────────────────────────────
      print("⚙️ Gear Shop Tracker v7 — بدأ التشغيل")

      local RS = game:GetService("ReplicatedStorage")

      local StockValues = RS:WaitForChild("StockValues", 30)
      if not StockValues then warn("[GearShop] ❌ ما لقيت StockValues") return end

      -- ─── نبحث عن GearShop ─────────────────────────────────
      local GEAR_NAMES = { "GearShop","EquipmentShop","ItemShop","ToolShop","ShopGear","Gear" }
      local GearShop

      for _, name in ipairs(GEAR_NAMES) do
          GearShop = StockValues:FindFirstChild(name)
          if GearShop then
              print("[GearShop] ✅ وجدناه: " .. name)
              break
          end
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

      -- ─── guard: نفس السكربت لا يبعث مرتين لنفس النافذة ───
      local reportedWindows = {}

      -- ─── الإبلاغ لـ Worker ────────────────────────────────
      local function reportRestock(source)
          -- 1. انتظر استقرار الستوك
          print("[GearShop] ⏳ " .. source .. " — انتظار الاستقرار...")
          local gear = waitForStableStock(getGear)

          if #gear == 0 then
              warn("[GearShop] ⚠️ الستوك فاضي — تخطي")
              return
          end

          -- 2. أعد قراءة nextRestock بعد الاستقرار
          local nr = NextRestock and math.floor(NextRestock.Value) or 0

          -- 3. تحقق من المضاعف
          if not isValidRestockTime(nr) then
              warn("[GearShop] ⛔ " .. source .. " — rem=" .. (nr % 300) .. " ليس على مضاعف 5 دق")
              return
          end

          -- 4. window guard (nearest 5-min boundary)
          local windowKey = math.floor(nr / 300) * 300
          if reportedWindows[windowKey] then
              print("[GearShop] ⏭️ هذا الـ window سبق أُبلغ عنه محلياً")
              return
          end

          -- 5. ابعث — Worker يعمل الـ dedup الكامل
          reportedWindows[windowKey] = true
          print("[GearShop] 📤 " .. source .. " | " .. #gear .. " عنصر | nr=" .. nr .. " | window=" .. windowKey)

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
                  print("[GearShop] ⏭️ Worker: skip — " .. reason)
              else
                  print("[GearShop] ℹ️ " .. body)
              end
          else
              -- فشل — امسح الـ guard للمحاولة التالية
              reportedWindows[windowKey] = nil
              warn("[GearShop] ❌ " .. tostring(ok and res.StatusCode or res))
          end
      end

      -- ─── فحص أولي عند التشغيل ────────────────────────────
      do
          local lr   = LastRestock and LastRestock.Value or 0
          local diff = os.time() - lr
          if lr > 0 and diff <= 90 then
              print("[GearShop] 🔄 restock حديث منذ " .. diff .. " ث — فحص أولي...")
              task.wait(math.random(5, 20))
              reportRestock("startup")
          else
              print("[GearShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق — لا حاجة للفحص")
          end
      end

      -- ─── مراقبة LastRestock ──────────────────────────────
      if LastRestock then
          LastRestock.Changed:Connect(function()
              local jitter = math.random(8, 45)
              print("[GearShop] 🔔 restock! jitter=" .. jitter .. " ث")
              task.wait(jitter)
              reportRestock("event")
          end)
      else
          warn("[GearShop] ⚠️ UnixLastRestock غير موجود")
      end

      print("[GearShop] 👂 جاهز...")
