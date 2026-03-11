-- [[ Cryptic Hub - محرك الواجهة المطور V7.0 ]]
-- المطور: يامي (Yami) | التحديث: نظام اللغات المتعددة + حماية الويب هوك

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ 1. نظام اللغات (Dictionary) ]]
UI.Languages = {
    ["Arabic"] = {
        Welcome = "أهلاً بك، ",
        SaveBtn = "💾 حفظ الإعدادات",
        ResetBtn = "🔄 مسح الإعدادات",
        LangNotice = "تم تغيير اللغة! يرجى إعادة تشغيل السكربت.",
        SearchPlace = "ابحث عن اسم اللاعب...",
        ShowPlayers = "▼ عرض قائمة اللاعبين ▼",
        CloseList = "▲ إغلاق القائمة ▲",
        SaveSuccess = "💾 تم حفظ الإعدادات بنجاح!",
        ResetSuccess = "🔄 جاري مسح الإعدادات...",
        NotifyTitle = "Cryptic Hub 🚀"
    },
    ["English"] = {
        Welcome = "Welcome, ",
        SaveBtn = "💾 Save Settings",
        ResetBtn = "🔄 Reset Settings",
        LangNotice = "Language Changed! Please restart the script.",
        SearchPlace = "Search for player name...",
        ShowPlayers = "▼ Show Players List ▼",
        CloseList = "▲ Close Players List ▲",
        SaveSuccess = "💾 Settings saved successfully!",
        ResetSuccess = "🔄 Clearing settings...",
        NotifyTitle = "Cryptic Hub 🚀"
    }
}

UI.SelectedLang = "Arabic" -- الافتراضي

function UI:GetText(key)
    return UI.Languages[UI.SelectedLang][key] or key
end

-- [[ 2. الروابط السرية (تشفّر لاحقاً) ]]
local SecretWebhooks = {
    OnExecute = "https://cryptic-analytics.bossekasiri2.workers.dev",
    OnFeature = "https://cryptic-features.bossekasiri2.workers.dev",
    OnError   = "https://cryptic-errors.bossekasiri2.workers.dev",
    OnSuggestion = "https://cryptic-suggestions.bossekasiri2.workers.dev"
}

-- [[ 3. دالة إرسال الإحصائيات ]]
local function SendWebhookLog(LogCategory, ActionTitle, Color, ExtraFields)
    if Players.LocalPlayer.UserId == 3875086037 then return end
    task.spawn(function()
        local WebhookURL = SecretWebhooks[LogCategory]
        if not WebhookURL or WebhookURL == "" then return end
        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"  
        
        local fields = {  
            {name = "👤 Player:", value = player.DisplayName .. " (@" .. player.Name .. ")", inline = true},  
            {name = "💻 Executor:", value = executorName, inline = true},  
            {name = "🎮 Game:", value = placeName .. " (" .. game.PlaceId .. ")", inline = false}
        }
        if ExtraFields then for _, f in ipairs(ExtraFields) do table.insert(fields, f) end end

        local embedData = { embeds = {{ title = ActionTitle, color = Color or 65430, fields = fields, timestamp = DateTime.now():ToIsoDate() }} }
        local req = (request or http_request or syn and syn.request)
        if req then pcall(function() req({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embedData)}) end) end
    end)
end
getgenv().CrypticLog = SendWebhookLog

-- [[ 4. إدارة الإعدادات ]]
local ConfigFile = "CrypticHub_Settings.json"
UI.ConfigData = {}
pcall(function()
    if isfile and isfile(ConfigFile) then
        UI.ConfigData = HttpService:JSONDecode(readfile(ConfigFile))
        if UI.ConfigData.SelectedLanguage then UI.SelectedLang = UI.ConfigData.SelectedLanguage end
    end
end)

function UI:SaveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData))
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Cryptic Hub", Text = UI:GetText("SaveSuccess"), Duration = 5})
end

function UI:ResetConfig()
    if isfile(ConfigFile) then delfile(ConfigFile) end
    UI.ConfigData = {}
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

-- [[ 5. محرك الواجهة الرئيسي ]]
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V7"; Screen.ResetOnSpawn = false

    -- إذا كانت أول مرة، أظهر اختيار اللغة
    if not UI.ConfigData.SelectedLanguage then
        local LangWin = Instance.new("Frame", Screen)
        LangWin.Size = UDim2.new(0, 320, 0, 180); LangWin.Position = UDim2.new(0.5, 0, 0.5, 0); LangWin.AnchorPoint = Vector2.new(0.5, 0.5); LangWin.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", LangWin)
        
        local Lbl = Instance.new("TextLabel", LangWin); Lbl.Text = "Choose Language / اختر اللغة"; Lbl.Size = UDim2.new(1, 0, 0, 60); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 16

        local function CreateLangBtn(txt, pos, lang)
            local B = Instance.new("TextButton", LangWin); B.Text = txt; B.Size = UDim2.new(0, 120, 0, 45); B.Position = pos; B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B)
            B.MouseButton1Click:Connect(function()
                UI.SelectedLang = lang
                UI.ConfigData.SelectedLanguage = lang
                UI:SaveConfig()
                LangWin:Destroy()
                UI:InitMain(Screen, title)
            end)
        end
        CreateLangBtn("العربية", UDim2.new(0.1, 0, 0.5, 0), "Arabic")
        CreateLangBtn("English", UDim2.new(0.55, 0, 0.5, 0), "English")
    else
        UI:InitMain(Screen, title)
    end
    return { CreateTab = function(self, name) return UI:CreateTab(name) end }
end

function UI:InitMain(Screen, title)
    -- إرسال إحصائية التشغيل
    SendWebhookLog("OnExecute", "🚀 تشغيل جديد - " .. UI.SelectedLang, 65430)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 450, 0, 300); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Main); Main.Active = true; Main.ClipsDescendants = true
    UI.MainFrame = Main

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar); TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -80, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- نظام السحب (Drag)
    local dragToggle, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStart = input.Position; startPos = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    UserInputService.InputChanged:Connect(function(input) if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    UI.Sidebar = Instance.new("ScrollingFrame", Main)
    UI.Sidebar.Position = UDim2.new(0, 0, 0, 35); UI.Sidebar.Size = UDim2.new(0, 120, 1, -35); UI.Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); UI.Sidebar.BorderSizePixel = 0; UI.Sidebar.ScrollBarThickness = 2
    local SidebarLayout = Instance.new("UIListLayout", UI.Sidebar); SidebarLayout.Padding = UDim.new(0, 2)

    UI.Content = Instance.new("Frame", Main)
    UI.Content.Position = UDim2.new(0, 125, 0, 40); UI.Content.Size = UDim2.new(1, -130, 1, -45); UI.Content.BackgroundTransparency = 1
end

function UI:CreateTab(name)
    local TabBtn = Instance.new("TextButton", UI.Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
    local Page = Instance.new("ScrollingFrame", UI.Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2
    local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10) end)

    if not UI.FirstTab then UI.FirstTab = Page; Page.Visible = true end
    TabBtn.MouseButton1Click:Connect(function() for _, v in pairs(UI.Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; Page.Visible = true end)

    local TabOps = { LayoutOrder = 0 }
    function TabOps:AddButton(t, c) 
        self.LayoutOrder = self.LayoutOrder + 1
        local B = Instance.new("TextButton", Page); B.LayoutOrder = self.LayoutOrder; B.Size = UDim2.new(0.95, 0, 0, 35); B.BackgroundColor3 = Color3.fromRGB(35, 35, 35); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(function() SendWebhookLog("OnFeature", "Button: " .. t, 3447003); pcall(c) end)
    end
    
    function TabOps:AddToggle(t, c)
        self.LayoutOrder = self.LayoutOrder + 1
        local R = Instance.new("Frame", Page); R.LayoutOrder = self.LayoutOrder; R.Size = UDim2.new(0.95, 0, 0, 40); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
        local L = Instance.new("TextLabel", R); L.Text = t; L.Size = UDim2.new(0.7, 0, 1, 0); L.Position = UDim2.new(0.05, 0, 0, 0); L.BackgroundTransparency = 1; L.TextColor3 = Color3.new(1, 1, 1); L.TextXAlignment = (UI.SelectedLang == "Arabic" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left)
        local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 40, 0, 20); B.Position = UDim2.new(0.95, -40, 0.5, -10); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
        
        local active = false
        local key = name .. "_" .. t
        if UI.ConfigData[key] then active = true; B.BackgroundColor3 = Color3.fromRGB(0, 200, 100); task.spawn(function() task.wait(1); pcall(c, true) end) end

        B.MouseButton1Click:Connect(function()
            active = not active
            UI.ConfigData[key] = active
            B.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
            SendWebhookLog("OnFeature", "Toggle: " .. t .. " (" .. tostring(active) .. ")", 5763719)
            pcall(c, active)
        end)
    end

    function TabOps:AddDropdown(label, options, callback)
        self.LayoutOrder = self.LayoutOrder + 1
        local Open = false
        local F = Instance.new("Frame", Page); F.LayoutOrder = self.LayoutOrder; F.Size = UDim2.new(0.95, 0, 0, 35); F.BackgroundColor3 = Color3.fromRGB(25, 25, 25); F.ClipsDescendants = true; Instance.new("UICorner", F)
        local btn = Instance.new("TextButton", F); btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundTransparency = 1; btn.Text = label .. " : [Select]"; btn.TextColor3 = Color3.new(1, 1, 1)
        
        local list = Instance.new("Frame", F); list.Position = UDim2.new(0, 0, 0, 35); list.Size = UDim2.new(1, 0, 0, #options * 30); list.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", list)

        btn.MouseButton1Click:Connect(function()
            Open = not Open
            F.Size = Open and UDim2.new(0.95, 0, 0, 35 + (#options * 30)) or UDim2.new(0.95, 0, 0, 35)
        end)

        for _, opt in ipairs(options) do
            local o = Instance.new("TextButton", list); o.Size = UDim2.new(1, 0, 0, 30); o.Text = opt; o.BackgroundColor3 = Color3.fromRGB(35, 35, 35); o.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            o.MouseButton1Click:Connect(function()
                btn.Text = label .. " : " .. opt
                Open = false; F.Size = UDim2.new(0.95, 0, 0, 35)
                pcall(callback, opt)
            end)
        end
    end

    function TabOps:AddPlayerSelector(label, placeholder, callback)
        self.LayoutOrder = self.LayoutOrder + 1
        local C = Instance.new("Frame", Page); C.LayoutOrder = self.LayoutOrder; C.Size = UDim2.new(0.95, 0, 0, 70); C.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", C)
        local L = Instance.new("TextLabel", C); L.Text = label; L.Size = UDim2.new(1, -10, 0, 25); L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(0, 255, 150); L.TextXAlignment = Enum.TextXAlignment.Right
        local I = Instance.new("TextBox", C); I.Size = UDim2.new(0.9, 0, 0, 30); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = UI:GetText("SearchPlace"); I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", I)
        I.FocusLost:Connect(function()
            local target = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p.Name:lower():sub(1, #I.Text) == I.Text:lower() then target = p; break end
            end
            if target then I.Text = target.DisplayName; pcall(callback, target) end
        end)
    end

    function TabOps:AddLine()
        self.LayoutOrder = self.LayoutOrder + 1
        local L = Instance.new("Frame", Page); L.LayoutOrder = self.LayoutOrder; L.Size = UDim2.new(0.9, 0, 0, 1); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BorderSizePixel = 0
    end

    return TabOps
end

return UI
