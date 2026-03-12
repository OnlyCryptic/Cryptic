-- [[ Cryptic Hub - حزمة الأدوات المكملة للواجهة (UI_2) ]]
-- المطور: يامي (Yami)

return function(UI)
    
    -- دالة الملف الشخصي
    UI.TabMethods["AddProfileCard"] = function(Page, ConfigData, TabName, player)
        local R = Instance.new("Frame", Page); R.LayoutOrder = #Page:GetChildren() + 1; R.Size = UDim2.new(0.98, 0, 0, 75); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8)
        local Avatar = Instance.new("ImageLabel", R); Avatar.Size = UDim2.new(0, 55, 0, 55); Avatar.Position = UDim2.new(1, -65, 0, 10); Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
        task.spawn(function() local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and thumb then Avatar.Image = thumb end end)
        local NameLbl = Instance.new("TextLabel", R); NameLbl.Size = UDim2.new(1, -80, 0, 25); NameLbl.Position = UDim2.new(0, 10, 0, 12); NameLbl.BackgroundTransparency = 1; NameLbl.Text = "أهلاً بك، " .. player.DisplayName; NameLbl.TextColor3 = Color3.fromRGB(0, 255, 150); NameLbl.TextXAlignment = Enum.TextXAlignment.Right; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 16
        local UserLbl = Instance.new("TextLabel", R); UserLbl.Size = UDim2.new(1, -80, 0, 20); UserLbl.Position = UDim2.new(0, 10, 0, 37); UserLbl.BackgroundTransparency = 1; UserLbl.Text = "@" .. player.Name; UserLbl.TextColor3 = Color3.fromRGB(170, 170, 170); UserLbl.TextXAlignment = Enum.TextXAlignment.Right; UserLbl.Font = Enum.Font.Gotham; UserLbl.TextSize = 13
    end

    -- دالة النص العادي
    UI.TabMethods["AddLabel"] = function(Page, ConfigData, TabName, t)
        local R = Instance.new("Frame", Page); R.LayoutOrder = #Page:GetChildren() + 1; R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R)
        local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0, 255, 150); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; L.Font = Enum.Font.Gotham; L.TextSize = 14
        return {SetText=function(nt) L.Text=nt end}
    end

    -- دالة القطعة النصية (Paragraph)
    UI.TabMethods["AddParagraph"] = function(Page, ConfigData, TabName, text)
        local Lbl = Instance.new("TextLabel", Page); Lbl.LayoutOrder = #Page:GetChildren() + 1; Lbl.Size = UDim2.new(0.95, 0, 0, 0); Lbl.AutomaticSize = Enum.AutomaticSize.Y; Lbl.TextWrapped = true; Lbl.Text = text; Lbl.TextColor3 = Color3.fromRGB(170, 170, 170); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
    end

    -- دالة الإدخال (TextBox)
    UI.TabMethods["AddInput"] = function(Page, ConfigData, TabName, label, placeholder, callback)
        local R = Instance.new("Frame", Page); R.LayoutOrder = #Page:GetChildren() + 1; R.Size = UDim2.new(0.95, 0, 0, 65); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
        local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14
        local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 30); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; I.Font = Enum.Font.Gotham; I.TextSize = 14; Instance.new("UICorner", I)
        
        local configKey = TabName .. "_" .. label .. "_Input"
        if ConfigData[configKey] ~= nil then I.Text = ConfigData[configKey]; task.spawn(function() task.wait(1.5) callback(I.Text) end) end
        I:GetPropertyChangedSignal("Text"):Connect(function() ConfigData[configKey] = I.Text; callback(I.Text) end)
        return { SetText = function(t) I.Text = t end, TextBox = I }
    end

    -- دالة التحكم بالسرعة (Slider/Input combo)
    UI.TabMethods["AddSpeedControl"] = function(Page, ConfigData, TabName, label, callback, default)
        local Row = Instance.new("Frame", Page); Row.LayoutOrder = #Page:GetChildren() + 1; Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
        local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14
        local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
        local startVal = tostring(default or 50); local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = startVal; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Inp.Font = Enum.Font.Gotham; Inp.TextSize = 14; Instance.new("UICorner", Inp)
        
        local active = false; local configKey = TabName .. "_" .. label .. "_Speed"
        if ConfigData[configKey] ~= nil then active = ConfigData[configKey].active; Inp.Text = tostring(ConfigData[configKey].val) end
        
        local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); local val = tonumber(Inp.Text) or tonumber(startVal); ConfigData[configKey] = {active = active, val = val}; callback(active, val) end
        if active then task.spawn(function() task.wait(1.5) update() end) end
        
        Tgl.MouseButton1Click:Connect(function() active = not active; update() end)
        Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
    end

    -- دالة زر التفعيل (Toggle)
    UI.TabMethods["AddToggle"] = function(Page, ConfigData, TabName, label, callback)
        local R = Instance.new("Frame", Page); R.LayoutOrder = #Page:GetChildren() + 1; R.Size = UDim2.new(0.95, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
        local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
        local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14
        
        local a = false; local configKey = TabName .. "_" .. label
        if ConfigData[configKey] ~= nil then a = ConfigData[configKey] end
        
        local function set(s) a = s; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); ConfigData[configKey] = a; pcall(callback, a) end
        B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
        
        if a then task.spawn(function() task.wait(1.5); pcall(callback, a) end) end
        B.MouseButton1Click:Connect(function() set(not a) end)
        return { SetState = function(self, s) set(s) end, Set = function(self, s) set(s) end }
    end

    -- دالة التفعيل المؤقت
    UI.TabMethods["AddTimedToggle"] = function(Page, ConfigData, TabName, label, callback)
        local R = Instance.new("Frame", Page); R.LayoutOrder = #Page:GetChildren() + 1; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
        local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
        local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14
        local isRunning = false
        B.MouseButton1Click:Connect(function() 
            if isRunning then return end; isRunning = true; B.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            task.spawn(function() pcall(callback, true); task.wait(2); if B then B.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end; pcall(callback, false); isRunning = false end)
        end)
        return { Set = function() end, SetState = function() end }
    end

    -- دالة القائمة المنسدلة (Dropdown)
    UI.TabMethods["AddDropdown"] = function(Page, ConfigData, TabName, label, options, callback)
        local DropdownFrame = Instance.new("Frame", Page)
        DropdownFrame.LayoutOrder = #Page:GetChildren() + 1; DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); DropdownFrame.ClipsDescendants = true; DropdownFrame.Size = UDim2.new(0.95, 0, 0, 45); Instance.new("UICorner", DropdownFrame)
        local MainBtn = Instance.new("TextButton", DropdownFrame); MainBtn.Size = UDim2.new(1, 0, 0, 45); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""
        local TitleLbl = Instance.new("TextLabel", MainBtn); TitleLbl.Size = UDim2.new(1, -15, 1, 0); TitleLbl.Position = UDim2.new(0, -10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = label .. " : [اختر]"; TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150); TitleLbl.TextXAlignment = Enum.TextXAlignment.Right; TitleLbl.Font = Enum.Font.Gotham; TitleLbl.TextSize = 14
        local ArrowLbl = Instance.new("TextLabel", MainBtn); ArrowLbl.Size = UDim2.new(0, 30, 1, 0); ArrowLbl.Position = UDim2.new(0, 5, 0, 0); ArrowLbl.BackgroundTransparency = 1; ArrowLbl.Text = "▼"; ArrowLbl.TextColor3 = Color3.new(1, 1, 1); ArrowLbl.Font = Enum.Font.GothamBold; ArrowLbl.TextSize = 16
        
        local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame)
        OptionsContainer.Size = UDim2.new(1, 0, 1, -45); OptionsContainer.Position = UDim2.new(0, 0, 0, 45); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.ScrollBarThickness = 2
        local ListLayout = Instance.new("UIListLayout", OptionsContainer); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local optionHeight = 35; local maxDropdownHeight = 45 + (#options * optionHeight)
        if maxDropdownHeight > 185 then maxDropdownHeight = 185 end
        OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight)

        local isOpen = false; local configKey = TabName .. "_" .. label .. "_Dropdown"
        if ConfigData[configKey] ~= nil then
            local savedOption = ConfigData[configKey]; TitleLbl.Text = label .. " : [" .. savedOption .. "]"; task.spawn(function() task.wait(1.5) pcall(callback, savedOption) end)
        end

        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, optionHeight); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200); OptBtn.Text = opt; OptBtn.LayoutOrder = i; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 14
            OptBtn.MouseButton1Click:Connect(function()
                isOpen = false; DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 45), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▼"; TitleLbl.Text = label .. " : [" .. opt .. "]"
                ConfigData[configKey] = opt; pcall(callback, opt)
            end)
        end

        MainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, maxDropdownHeight), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▲"
            else DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 45), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▼" end
        end)
    end

end
