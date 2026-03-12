-- [[ Cryptic Hub - محرك الواجهة المطور V6.5 ]]
-- المطور: يامي (Yami) | التحديث: أبعاد ديناميكية، تأكيد الإغلاق، ودعم الملفات الخارجية (UI_2)

local UI = { Logger = nil, ConfigData = {}, TabMethods = {} } -- إضافة TabMethods لدعم الملفات الخارجية
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local ConfigFile = "CrypticHub_Settings.json"
local hasSavedData = false

pcall(function()
    if isfile and isfile(ConfigFile) then
        local content = readfile(ConfigFile)
        local data = HttpService:JSONDecode(content)
        if type(data) == "table" and next(data) ~= nil then
            UI.ConfigData = data
            hasSavedData = true
        end
    end
end)

function UI:SaveConfig()
    local success, err = pcall(function() writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData)) end)
    local StarterGui = game:GetService("StarterGui")
    if success then StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم حفظ الإعدادات بنجاح!", Duration = 5})
    else StarterGui:SetCore("SendNotification", {Title = "⚠️ خطأ", Text = "فشل الحفظ: المشغل لا يدعم هذه الميزة.", Duration = 5}) end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then queue_tp([[ task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua"))() ]]) end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V6"; Screen.ResetOnSpawn = false

    -- [[ 1. تحسين زر الفتح ]]
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 110, 0, 40); OpenBtn.Position = UDim2.new(0, 15, 0.5, -20)
    OpenBtn.Visible = false; OpenBtn.Text = "🔮 Cryptic"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.BackgroundTransparency = 0.2
    OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 16
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(0, 255, 150); OpenStroke.Thickness = 1.5

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputT and dragToggle then
            local delta = input.Position - dragStartT
            OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y)
        end
    end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 480, 0, 300); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Main.ClipsDescendants = true 

    -- [[ 2. نافذة تأكيد الإغلاق (مخفية بالبداية) ]]
    local ConfirmFrame = Instance.new("Frame", Main)
    ConfirmFrame.Size = UDim2.new(1, 0, 1, 0); ConfirmFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); ConfirmFrame.BackgroundTransparency = 0.3; ConfirmFrame.ZIndex = 10; ConfirmFrame.Visible = false
    local ConfirmBox = Instance.new("Frame", ConfirmFrame)
    ConfirmBox.Size = UDim2.new(0, 250, 0, 120); ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0); ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5); ConfirmBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ConfirmBox.ZIndex = 11; Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", ConfirmBox).Color = Color3.fromRGB(0, 255, 150)
    local ConfirmLbl = Instance.new("TextLabel", ConfirmBox)
    ConfirmLbl.Size = UDim2.new(1, 0, 0, 50); ConfirmLbl.Position = UDim2.new(0, 0, 0, 10); ConfirmLbl.BackgroundTransparency = 1; ConfirmLbl.Text = "هل أنت متأكد من إغلاق السكربت؟"; ConfirmLbl.TextColor3 = Color3.new(1,1,1); ConfirmLbl.Font = Enum.Font.GothamBold; ConfirmLbl.TextSize = 15; ConfirmLbl.ZIndex = 12
    local BtnYes = Instance.new("TextButton", ConfirmBox)
    BtnYes.Size = UDim2.new(0, 90, 0, 35); BtnYes.Position = UDim2.new(0, 20, 0, 70); BtnYes.BackgroundColor3 = Color3.fromRGB(200, 50, 50); BtnYes.Text = "نعم (إغلاق)"; BtnYes.TextColor3 = Color3.new(1,1,1); BtnYes.Font = Enum.Font.GothamBold; BtnYes.ZIndex = 12; Instance.new("UICorner", BtnYes)
    local BtnNo = Instance.new("TextButton", ConfirmBox)
    BtnNo.Size = UDim2.new(0, 90, 0, 35); BtnNo.Position = UDim2.new(1, -110, 0, 70); BtnNo.BackgroundColor3 = Color3.fromRGB(50, 200, 50); BtnNo.Text = "لا (تراجع)"; BtnNo.TextColor3 = Color3.new(1,1,1); BtnNo.Font = Enum.Font.GothamBold; BtnNo.ZIndex = 12; Instance.new("UICorner", BtnNo)
    BtnYes.MouseButton1Click:Connect(function() Screen:Destroy() end)
    BtnNo.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 13

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputMain and draggingMain then
            local delta = input.Position - dragStartMain
            Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)

    -- زر الإغلاق مربوط بنافذة التأكيد
    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.Font = Enum.Font.GothamBold; Close.TextSize = 16
    Close.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
    
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.Font = Enum.Font.GothamBold; Hide.TextSize = 18; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- [[ 3. توسيع القائمة الجانبية وتعديل المحتوى ]]
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 145, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 150, 0, 40); Content.Size = UDim2.new(1, -155, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 38); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0; TabBtn.Font = Enum.Font.Gotham; TabBtn.TextSize = 14; TabBtn.TextWrapped = true
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15) end)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true; TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150) end
        TabBtn.MouseButton1Click:Connect(function() 
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.new(1,1,1) end end
            Page.Visible = true; TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        end)

        local TabOps = {}
        local orderIndex = 0 

        -- ربط النظام الخارجي (UI_2) بالقائمة الحالية
        setmetatable(TabOps, {
            __index = function(self, key)
                if UI.TabMethods[key] then
                    return function(selfObj, ...) return UI.TabMethods[key](Page, UI.ConfigData, name, ...) end
                end
                return nil
            end
        })

        -- الدوال الأساسية
        function TabOps:AddLine() orderIndex = orderIndex + 1; local L = Instance.new("Frame", Page); L.LayoutOrder = orderIndex; L.Size = UDim2.new(0.95, 0, 0, 2); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0 end
        
        function TabOps:AddButton(t, c) orderIndex = orderIndex + 1; local B = Instance.new("TextButton", Page); B.LayoutOrder = orderIndex; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); B.Font = Enum.Font.GothamBold; B.TextSize = 15; Instance.new("UICorner", B); B.MouseButton1Click:Connect(c) end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; 
            local a = false
            local configKey = name .. "_" .. label
            if UI.ConfigData[configKey] ~= nil then a = UI.ConfigData[configKey] end
            local function set(s) a = s; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); UI.ConfigData[configKey] = a; pcall(callback, a) end
            B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
            if a then task.spawn(function() task.wait(1.5); pcall(callback, a) end) end
            B.MouseButton1Click:Connect(function() set(not a) end)
            return { SetState = function(self, s) set(s) end }
        end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 65); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 30); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; I.Font = Enum.Font.Gotham; I.TextSize = 14; Instance.new("UICorner", I); 
            local configKey = name .. "_" .. label .. "_Input"
            if UI.ConfigData[configKey] ~= nil then I.Text = UI.ConfigData[configKey]; task.spawn(function() task.wait(1.5) callback(I.Text) end) end
            I:GetPropertyChangedSignal("Text"):Connect(function() UI.ConfigData[configKey] = I.Text; callback(I.Text) end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddDropdown(label, options, callback)
            orderIndex = orderIndex + 1
            local DropdownFrame = Instance.new("Frame", Page)
            DropdownFrame.LayoutOrder = orderIndex; DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); DropdownFrame.ClipsDescendants = true; DropdownFrame.Size = UDim2.new(0.95, 0, 0, 45); Instance.new("UICorner", DropdownFrame)
            local MainBtn = Instance.new("TextButton", DropdownFrame); MainBtn.Size = UDim2.new(1, 0, 0, 45); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""
            local TitleLbl = Instance.new("TextLabel", MainBtn); TitleLbl.Size = UDim2.new(1, -15, 1, 0); TitleLbl.Position = UDim2.new(0, -10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = label .. " : [اختر]"; TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150); TitleLbl.TextXAlignment = Enum.TextXAlignment.Right; TitleLbl.Font = Enum.Font.Gotham; TitleLbl.TextSize = 14
            local ArrowLbl = Instance.new("TextLabel", MainBtn); ArrowLbl.Size = UDim2.new(0, 30, 1, 0); ArrowLbl.Position = UDim2.new(0, 5, 0, 0); ArrowLbl.BackgroundTransparency = 1; ArrowLbl.Text = "▼"; ArrowLbl.TextColor3 = Color3.new(1, 1, 1); ArrowLbl.Font = Enum.Font.GothamBold; ArrowLbl.TextSize = 16
            
            local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame)
            OptionsContainer.Size = UDim2.new(1, 0, 1, -45); OptionsContainer.Position = UDim2.new(0, 0, 0, 45); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.ScrollBarThickness = 2
            local ListLayout = Instance.new("UIListLayout", OptionsContainer); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local optionHeight = 35; local maxDropdownHeight = 45 + (#options * optionHeight)
            if maxDropdownHeight > 185 then maxDropdownHeight = 185 end
            OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight)

            local isOpen = false; local configKey = name .. "_" .. label .. "_Dropdown"
            if UI.ConfigData[configKey] ~= nil then
                local savedOption = UI.ConfigData[configKey]; TitleLbl.Text = label .. " : [" .. savedOption .. "]"; task.spawn(function() task.wait(1.5) pcall(callback, savedOption) end)
            end

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, optionHeight); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200); OptBtn.Text = opt; OptBtn.LayoutOrder = i; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 14
                OptBtn.MouseButton1Click:Connect(function()
                    isOpen = false; DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 45), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▼"; TitleLbl.Text = label .. " : [" .. opt .. "]"
                    UI.ConfigData[configKey] = opt; pcall(callback, opt)
                end)
            end

            MainBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, maxDropdownHeight), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▲"
                else DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 45), "Out", "Quad", 0.2, true); ArrowLbl.Text = "▼" end
            end)
        end

        return TabOps
    end
    return Window
end

return UI
