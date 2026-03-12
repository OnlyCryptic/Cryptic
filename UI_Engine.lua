-- [[ Cryptic Hub - محرك الواجهة المطور V6.7 (النسخة الخفيفة) ]]
local UI = { Logger = nil, ConfigData = {}, TabMethods = {} } 
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
        if type(data) == "table" and next(data) ~= nil then UI.ConfigData = data; hasSavedData = true end
    end
end)

function UI:SaveConfig()
    local success, err = pcall(function() writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData)) end)
    local StarterGui = game:GetService("StarterGui")
    if success then StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم حفظ الإعدادات بنجاح!", Duration = 5})
    else StarterGui:SetCore("SendNotification", {Title = "⚠️ خطأ", Text = "فشل الحفظ.", Duration = 5}) end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then queue_tp([[ task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua"))() ]]) end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V6"; Screen.ResetOnSpawn = false

    if hasSavedData then
        local Callback = Instance.new("BindableFunction")
        Callback.OnInvoke = function(btn) if btn == "مسح اعدادات محفوضه" then UI.ConfigData = {}; task.spawn(function() task.wait(0.5); UI:ResetConfig() end) end end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Cryptic Hub", Text = "تم تحميل إعداداتك بنجاح.", Duration = 10, Button1 = "حسناً", Button2 = "مسح اعدادات محفوضه", Callback = Callback}) end)
    end

    -- زر הפתיחה المصغر
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 70, 0, 28); OpenBtn.Position = UDim2.new(0, 10, 0.5, -14); OpenBtn.Visible = false; OpenBtn.Text = "Cryptic"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.BackgroundTransparency = 0.2
    OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 13
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(0, 255, 150); OpenStroke.Thickness = 1.2; OpenStroke.Transparency = 0.3

    local dragT, dragInpT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragT = true; dragStartT = input.Position; startPosT = OpenBtn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragT = false end end)
        end
    end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInpT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInpT and dragT then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 480, 0, 300); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Main.ClipsDescendants = true 

    -- نافذة التأكيد
    local ConfirmFrame = Instance.new("Frame", Main)
    ConfirmFrame.Size = UDim2.new(1, 0, 1, 0); ConfirmFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); ConfirmFrame.BackgroundTransparency = 0.4; ConfirmFrame.ZIndex = 10; ConfirmFrame.Visible = false
    local ConfirmBox = Instance.new("Frame", ConfirmFrame)
    ConfirmBox.Size = UDim2.new(0, 250, 0, 110); ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0); ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5); ConfirmBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ConfirmBox.ZIndex = 11; Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", ConfirmBox).Color = Color3.fromRGB(0, 255, 150)
    local ConfirmLbl = Instance.new("TextLabel", ConfirmBox); ConfirmLbl.Size = UDim2.new(1, 0, 0, 50); ConfirmLbl.Position = UDim2.new(0, 0, 0, 5); ConfirmLbl.BackgroundTransparency = 1; ConfirmLbl.Text = "هل أنت متأكد من الإغلاق؟"; ConfirmLbl.TextColor3 = Color3.new(1,1,1); ConfirmLbl.Font = Enum.Font.GothamBold; ConfirmLbl.TextSize = 14; ConfirmLbl.ZIndex = 12
    local BtnYes = Instance.new("TextButton", ConfirmBox); BtnYes.Size = UDim2.new(0, 90, 0, 32); BtnYes.Position = UDim2.new(0, 20, 0, 60); BtnYes.BackgroundColor3 = Color3.fromRGB(200, 50, 50); BtnYes.Text = "نعم"; BtnYes.TextColor3 = Color3.new(1,1,1); BtnYes.Font = Enum.Font.GothamBold; BtnYes.ZIndex = 12; Instance.new("UICorner", BtnYes)
    local BtnNo = Instance.new("TextButton", ConfirmBox); BtnNo.Size = UDim2.new(0, 90, 0, 32); BtnNo.Position = UDim2.new(1, -110, 0, 60); BtnNo.BackgroundColor3 = Color3.fromRGB(50, 200, 50); BtnNo.Text = "لا"; BtnNo.TextColor3 = Color3.new(1,1,1); BtnNo.Font = Enum.Font.GothamBold; BtnNo.ZIndex = 12; Instance.new("UICorner", BtnNo)
    BtnYes.MouseButton1Click:Connect(function() Screen:Destroy() end); BtnNo.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)

    local TitleBar = Instance.new("Frame", Main); TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar); TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 13

    local dragM, dragInpM, dragStartM, startPosM
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragM = true; dragStartM = input.Position; startPosM = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragM = false end end) end
    end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInpM = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInpM and dragM then local delta = input.Position - dragStartM; Main.Position = UDim2.new(startPosM.X.Scale, startPosM.X.Offset + delta.X, startPosM.Y.Scale, startPosM.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.Font = Enum.Font.GothamBold; Close.TextSize = 16; Close.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.Font = Enum.Font.GothamBold; Hide.TextSize = 18; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("ScrollingFrame", Main); Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 145, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)
    local Content = Instance.new("Frame", Main); Content.Position = UDim2.new(0, 150, 0, 40); Content.Size = UDim2.new(1, -155, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 38); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0; TabBtn.Font = Enum.Font.Gotham; TabBtn.TextSize = 13; TabBtn.TextWrapped = true
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
        
        -- [[ هنا السحر: ربط الدوال المفقودة من الملف الخارجي ]]
        setmetatable(TabOps, {
            __index = function(self, key)
                if UI.TabMethods[key] then return function(selfObj, ...) return UI.TabMethods[key](Page, UI.ConfigData, name, ...) end end
                return nil
            end
        })

        -- الدوال الأساسية الثابتة
        function TabOps:AddLine() local L = Instance.new("Frame", Page); L.LayoutOrder = #Page:GetChildren() + 1; L.Size = UDim2.new(0.95, 0, 0, 2); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0 end
        function TabOps:AddButton(t, c) local B = Instance.new("TextButton", Page); B.LayoutOrder = #Page:GetChildren() + 1; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); B.Font = Enum.Font.GothamBold; B.TextSize = 14; Instance.new("UICorner", B); B.MouseButton1Click:Connect(c) end

        return TabOps
    end
    return Window
end

return UI
