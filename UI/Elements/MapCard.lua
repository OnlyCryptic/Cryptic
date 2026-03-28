-- [[ Cryptic Hub - Element: MapCard ]]
-- اسم السكربت + زر تشغيل فقط

return function(TabOps, mapData)
    local TweenService = game:GetService("TweenService")
    local StarterGui  = game:GetService("StarterGui")

    local function Tween(inst, props, t)
        TweenService:Create(inst, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local function Notify(title, text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 })
        end)
    end

    local scripts = mapData.Scripts
    if not scripts then
        scripts = { { Name = mapData.Name, Script = mapData.Script } }
    end

    for _, scriptEntry in ipairs(scripts) do
        TabOps.Order = TabOps.Order + 1

        -- صف: اسم السكربت على اليسار + زر تشغيل على اليمين
        local Row = Instance.new("Frame", TabOps.Page)
        Row.LayoutOrder = TabOps.Order
        Row.Size = UDim2.new(0.97, 0, 0, 40)
        Row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        Row.BorderSizePixel = 0
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)

        -- اسم السكربت
        local NameLbl = Instance.new("TextLabel", Row)
        NameLbl.Size = UDim2.new(1, -105, 1, 0)
        NameLbl.Position = UDim2.new(0, 12, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = scriptEntry.Name
        NameLbl.TextColor3 = Color3.new(1, 1, 1)
        NameLbl.Font = Enum.Font.GothamSemibold
        NameLbl.TextSize = 13
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left

        -- زر تشغيل
        local RunBtn = Instance.new("TextButton", Row)
        RunBtn.Size = UDim2.new(0, 88, 0, 28)
        RunBtn.Position = UDim2.new(1, -96, 0.5, -14)
        RunBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 78)
        RunBtn.Text = "▶  تشغيل"
        RunBtn.TextColor3 = Color3.new(1, 1, 1)
        RunBtn.Font = Enum.Font.GothamBold
        RunBtn.TextSize = 12
        RunBtn.BorderSizePixel = 0
        Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 6)

        RunBtn.MouseEnter:Connect(function()
            Tween(RunBtn, { BackgroundColor3 = Color3.fromRGB(0, 190, 100) }, 0.15)
        end)
        RunBtn.MouseLeave:Connect(function()
            Tween(RunBtn, { BackgroundColor3 = Color3.fromRGB(0, 150, 78) }, 0.2)
        end)

        local entry = scriptEntry
        RunBtn.MouseButton1Click:Connect(function()
            Tween(RunBtn, { BackgroundColor3 = Color3.fromRGB(0, 100, 50) }, 0.08)
            task.delay(0.12, function()
                Tween(RunBtn, { BackgroundColor3 = Color3.fromRGB(0, 150, 78) }, 0.15)
            end)

            Notify("🚀 " .. entry.Name, "جاري تشغيل السكربت...", 3)

            task.delay(0.3, function()
                local ok, err = pcall(function() loadstring(entry.Script)() end)
                if not ok then
                    Notify("⚠️ خطأ", tostring(err), 6)
                end
            end)

            if TabOps.LogAction then
                TabOps.LogAction("🗺️ ماب سكربت", "السكربت:", entry.Name .. " | " .. mapData.Name, 65430)
            end
        end)
    end
end
