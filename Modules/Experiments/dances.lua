-- [[ Cryptic Hub - نظام الرقصات المتقدم (Emotes Player) ]]
-- المطور: يامي | الوصف: مكتبة رقصات تظهر للجميع، تصميم نظيف، وبحث سريع

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 🟢 مكتبة الرقصات (أشهر رقصات روبلوكس)
local EmotePacks = {
    ["Dance 1 / رقصة 1 (الكلاسيكية)"] = "183288746",
    ["Dance 2 / رقصة 2"] = "183289666",
    ["Dance 3 / رقصة 3"] = "183289283",
    ["Floss / رقصة الفلوس"] = "5934994276",
    ["Shrug / لا أعلم"] = "3576856615",
    ["Salute / تحية عسكرية"] = "3360689775",
    ["Stadium / تشجيع"] = "3360689776",
    ["Tilt / ميلان"] = "3360692915",
    ["Point / تأشير"] = "3576827124",
    ["Hello / ترحيب"] = "3576686446",
    ["Cheer / احتفال"] = "3576686446",
    ["Laugh / ضحك"] = "3360689778",
    ["God's Plan / رقصة تيك توك"] = "4049551434",
    ["Ninja Rest / استراحة النينجا"] = "3886364007",
    ["Zombie / مشية الزومبي"] = "3360692693"
}

return function(Tab, UI)
    local currentSelectedEmote = nil
    local playingTrack = nil -- متغير لحفظ الرقصة الشغالة عشان نقدر نوقفها

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    -- ==========================================
    -- دالة تشغيل وإيقاف الرقصة (Replicated to Server)
    -- ==========================================
    local function PlayEmote(emoteId)
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return end

        -- إيقاف أي رقصة شغالة حالياً
        if playingTrack then
            playingTrack:Stop()
            playingTrack = nil
        end

        pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. emoteId
            
            playingTrack = animator:LoadAnimation(anim)
            playingTrack.Priority = Enum.AnimationPriority.Action -- إعطاء الرقصة أولوية قصوى لتشتغل فوق المشي
            playingTrack:Play()
        end)
    end

    local function StopEmote()
        if playingTrack then
            playingTrack:Stop()
            playingTrack = nil
            Notify("إيقاف 🛑", "تم إيقاف الرقصة!")
        else
            -- إذا لم تكن مسجلة، نفرض إيقاف كل الأكشن
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Priority == Enum.AnimationPriority.Action then
                        track:Stop()
                    end
                end
            end
            Notify("إيقاف 🛑", "تم مسح الرقصات الشغالة!")
        end
    end

    -- ==========================================
    -- بناء القائمة الاحترافية المبسطة
    -- ==========================================
    local DropdownContainer = Instance.new("Frame", Tab.Page)
    DropdownContainer.LayoutOrder = Tab.Order + 1
    Tab.Order = Tab.Order + 1
    DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
    DropdownContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownContainer.ClipsDescendants = true
    Instance.new("UICorner", DropdownContainer)
    
    local MainBtn = Instance.new("TextButton", DropdownContainer)
    MainBtn.Size = UDim2.new(1, 0, 0, 40)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = "▼ اختر رقصة | Select Emote"
    MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 13

    local SearchBox = Instance.new("TextBox", DropdownContainer)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 45)
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "بحث عن رقصة / Search Emote"
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.ClearTextOnFocus = false
    Instance.new("UICorner", SearchBox)

    local ListFrame = Instance.new("ScrollingFrame", DropdownContainer)
    ListFrame.Size = UDim2.new(0.9, 0, 0, 130)
    ListFrame.Position = UDim2.new(0.05, 0, 0, 80)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ListFrame.ScrollBarThickness = 2
    Instance.new("UICorner", ListFrame)
    
    local ListLayout = Instance.new("UIListLayout", ListFrame)
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local isOpen = false
    local optionItems = {}

    local function UpdateListDisplay()
        local searchText = SearchBox.Text:lower()
        for _, item in ipairs(optionItems) do
            local matchSearch = (searchText == "" or string.find(item.LowerName, searchText) ~= nil)
            item.Frame.Visible = matchSearch
        end
    end

    local function RebuildDropdown()
        for _, item in ipairs(optionItems) do item.Frame:Destroy() end
        optionItems = {}
        
        local sortedNames = {}
        for emoteName, _ in pairs(EmotePacks) do table.insert(sortedNames, emoteName) end
        table.sort(sortedNames)

        for _, emoteName in ipairs(sortedNames) do
            local emoteId = EmotePacks[emoteName]
            
            local ItemFrame = Instance.new("Frame", ListFrame)
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", ItemFrame)
            
            local SelectBtn = Instance.new("TextButton", ItemFrame)
            SelectBtn.Size = UDim2.new(1, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            SelectBtn.Text = emoteName
            SelectBtn.TextXAlignment = Enum.TextXAlignment.Center

            table.insert(optionItems, {Frame = ItemFrame, Name = emoteName, LowerName = emoteName:lower(), SelectBtn = SelectBtn})

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. emoteName
                currentSelectedEmote = emoteId
                isOpen = false
                DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
                
                -- تشغيل الرقصة فوراً عند الاختيار
                PlayEmote(emoteId)
                Notify("Cryptic Hub 💃", "جاري أداء الرقصة للجميع!\nPlaying emote for everyone!")
            end)
        end
        UpdateListDisplay()
    end

    RebuildDropdown()

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)

    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownContainer.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 40)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateListDisplay)

    -- ==========================================
    -- أزرار التحكم الخارجي
    -- ==========================================
    Tab:AddLine()
    Tab:AddButton("🛑 إيقاف الرقصة | Stop Emote", function()
        StopEmote()
    end)

    Tab:AddLine()
end
