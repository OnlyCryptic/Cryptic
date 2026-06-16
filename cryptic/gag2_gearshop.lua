      -- =====================================================
      --  Grow a Garden 2 — Gear Shop Tracker  v4
      --
      --  قواعد الإرسال:
      --    ✅ فقط عند تغيّر UnixLastRestock (= وقت restock حقيقي)
      --    ✅ فقط إذا nextRestock على مضاعف 5 دقائق
      --    ✅ فقط إذا لم يُبلَّغ عن هذا الـ restock مسبقاً
      --    ✅ فقط بعد استقرار الستوك (يقرأ مرتين ويقارن)
      --    ❌ لا إرسال عشوائي عند التشغيل
      --    ❌ لا polling بدون حدث restock
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

      -- ─── hash الـ gear (للمقارنة) ──────────────────────────
      local function hashGear(gear)
          local h = ""
          for _, g in ipairs(gear) do h = h .. g.name .. g.stock end
          return h
      end

      -- ─── انتظر استقرار الستوك ──────────────────────────────
      -- يقرأ الـ gear، ينتظر ثانيتين، يقرأ ثانية
      -- إذا متطابقتين → الستوك مكتمل ✅
      local function waitForStableStock(getItems)
          local prev = hashGear(getItems())
          for _ = 1, 3 do
              task.wait(2)
              local items = getItems()
              local curr  = hashGear(items)
              if curr == prev and curr ~= "" then
                  return items  -- استقر ✅
              end
              prev = curr
          end
          return getItems()
      end

      -- ─── تحقق هل بعثنا لهذا الـ restock ──────────────────
      local function alreadyReported(nextRestock)
          if nextRestock <= 0 then return false end
          local ok, res = pcall(req, {
              Url    = BASE_URL .. "/check/gear/" .. tostring(math.floor(nextRestock)),
              Method = "GET",
          })
          if not ok or res.StatusCode ~= 200 then return false end
          return res.Body:find('"skip":true') ~= nil
      end

      -- ─── تحقق أن الوقت على مضاعف 5 دقائق ────────────────
      local function isValidRestockTime(nextRestock)
          if nextRestock <= 0 then return false end
          local rem = nextRestock % 300
          return rem <= 60 or rem >= 240
      end

      -- ─── انتظر اللعبة تحمّل ───────────────────────────────
      print("⚙️ Gear Shop Tracker v4 — بدأ التشغيل")

      local RS = game:GetService("ReplicatedStorage")

      local StockValues = RS:WaitForChild("StockValues", 30)
      if not StockValues then warn("[GearShop] ❌ ما لقيت StockValues") return end

      -- ─── نبحث عن GearShop ─────────────────────────────────
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

      -- ─── إرسال لـ Worker ───────────────────────────────────
      local function reportRestock(source)
          local nr = NextRestock and math.floor(NextRestock.Value) or 0

          -- شرط 1: الوقت على مضاعف 5 دقائق
          if not isValidRestockTime(nr) then
              warn("[GearShop] ⛔ " .. source .. " — الوقت مش مضاعف 5 دق (rem=" .. (nr%300) .. ")")
              return
          end

          -- شرط 2: لم يُبلَّغ مسبقاً
          if alreadyReported(nr) then
              print("[GearShop] ⏭️ " .. source .. " — تم الإبلاغ مسبقاً")
              return
          end

          -- شرط 3: انتظر استقرار الستوك الكامل
          print("[GearShop] ⏳ " .. source .. " — انتظار استقرار الستوك...")
          local gear = waitForStableStock(getGear)
          if #gear == 0 then
              warn("[GearShop] ⚠️ الستوك فاضي — تم التخطي")
              return
          end

          -- تحقق أخير (أثناء الانتظار ممكن أحد سبق)
          if alreadyReported(nr) then
              print("[GearShop] ⏭️ أحد بعث أثناء الانتظار — تم التخطي")
              return
          end

          -- ── ابعث POST ──────────────────────────────────
          local body = json({ items = gear, nextRestock = nr })
          local ok, res = pcall(req, {
              Url     = BASE_URL .. "/report/gear",
              Method  = "POST",
              Headers = {
                  ["Content-Type"]    = "application/json",
                  ["X-Cryptic-Token"] = API_TOKEN,
              },
              Body = body,
          })

          if ok and (res.StatusCode == 200 or res.StatusCode == 204) then
              if res.Body:find('"skipped":true') then
                  print("[GearShop] ⏭️ Worker: تم الإبلاغ مسبقاً")
              else
                  print("[GearShop] ✅ " .. source .. " | أُرسل | " .. #gear .. " عنصر | nextRestock=" .. nr)
              end
          else
              warn("[GearShop] ❌ " .. tostring(ok and res.StatusCode or res))
          end
      end

      -- ─── عند التشغيل: فقط إذا كان الـ restock حديثاً ──────
      do
          local lr   = LastRestock and LastRestock.Value or 0
          local diff = os.time() - lr
          if lr > 0 and diff <= 90 then
              print("[GearShop] 🔄 restock حديث قبل " .. diff .. " ث — سنتحقق...")
              task.wait(math.random(3, 12))
              reportRestock("initial-check")
          else
              print("[GearShop] 💤 آخر restock منذ " .. math.floor(diff/60) .. " دق — لا إرسال أولي")
          end
      end

      -- ─── مراقبة UnixLastRestock ────────────────────────────
      if LastRestock then
          LastRestock.Changed:Connect(function()
              local jitter = math.random(3, 15)
              print("[GearShop] 🔔 LastRestock تغيّر — انتظار " .. jitter .. " ث")
              task.wait(jitter)
              reportRestock("restock-event")
          end)
      else
          warn("[GearShop] ⚠️ UnixLastRestock غير موجود — لا يوجد event listener")
      end

      print("[GearShop] 👂 ينتظر أحداث الـ restock...")
