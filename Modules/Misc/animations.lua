-- [[ Cryptic Hub - ميزة تغيير المشيات الشاملة (بدون قلتشات + تحديث تلقائي) ]]
-- المطور: يامي | الوصف: مكتبة ضخمة، تشغيل/إيقاف، إيقاف تداخل الحركات، واسترجاع عند الموت

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 🟢 مكتبة ضخمة تضم أشهر حزم المشيات في روبلوكس
local AnimationPacks = {
    ["Ninja / النينجا"] = {idle="656117400", walk="656121766", run="656118852", jump="656117878", fall="656117606", climb="656114359", swim="656121397"},
    ["Zombie / الزومبي"] = {idle="616158929", walk="616168032", run="616163682", jump="616161748", fall="616157476", climb="616156119", swim="616165109"},
    ["Vampire / مصاص الدماء"] = {idle="1083445855", walk="1083473930", run="1083462077", jump="1083466540", fall="1083443587", climb="1083439240", swim="1083477197"},
    ["Cartoony / كارتوني"] = {idle="742637095", walk="742640026", run="742638842", jump="742637982", fall="742637497", climb="742636889", swim="742641262"},
    ["Superhero / بطل خارق"] = {idle="782841498", walk="782843345", run="782842708", jump="782842230", fall="782842046", climb="782841270", swim="782843136"},
    ["Mage / الساحر"] = {idle="1084999930", walk="1085001851", run="1085001188", jump="1085000438", fall="1085000213", climb="1084999554", swim="1085001603"},
    ["Robot / الروبوت"] = {idle="616089559", walk="616095330", run="616091901", jump="616090535", fall="616088211", climb="616087119", swim="616094499"},
    ["Astronaut / رائد فضاء"] = {idle="891621366", walk="891633237", run="891626245", jump="891623143", fall="891617351", climb="891609353", swim="891631310"},
    ["Werewolf / المستذئب"] = {idle="1083195517", walk="1083216690", run="1083214717", jump="1083202519", fall="1083189019", climb="1083182000", swim="1083218792"},
    ["Pirate / القرصان"] = {idle="750781874", walk="750785693", run="750784481", jump="750782230", fall="750780242", climb="750779899", swim="750787378"}
}

return function(Tab, UI)
    
    local isToggleOn = false
    local selectedAnimData = nil
    local originalAnims = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 }) end)
    end

    -- ==========================================
    -- دالة الدروب داون (مع مربع البحث)
    -- ==========================================
    local function AddSearchableDropdown(tabRef, title, options, callback)
        tabRef.Order = tabRef.Order + 1
        
        local Container = Instance.new("Frame", tabRef.Page)
        Container.LayoutOrder = tabRef.Order
        Container.Size = UDim2.new(0.95, 0, 0, 40)
        Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Container.ClipsDescendants = true
        Instance.new("UICorner", Container)
        
        local MainBtn = Instance.new("TextButton", Container)
        MainBtn.Size = UDim2.new(1, 0, 0, 40)
        MainBtn.BackgroundTransparency = 1
        MainBtn.Text = "▼ " .. title
        MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        MainBtn.Font = Enum.Font.GothamBold
        MainBtn.TextSize = 13

        local SearchBox = Instance.new("TextBox", Container)
        SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
        SearchBox.Position = UDim2.new(0.05, 0, 0, 45)
        SearchBox.PlaceholderText = "بحث / Search"
        SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SearchBox.TextColor3 = Color3.new(1, 1, 1)
        SearchBox.ClearTextOnFocus = false
        Instance.new("UICorner", SearchBox)

        local ListFrame = Instance.new("ScrollingFrame", Container)
        ListFrame.Size = UDim2.new(0.9, 0, 0, 130)
        ListFrame.Position = UDim2.new(0.05, 0, 0, 80)
        ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ListFrame.ScrollBarThickness = 2
        Instance.new("UICorner", ListFrame)
        
        local ListLayout = Instance.new("UIListLayout", ListFrame)
        ListLayout.Padding = UDim.new(0, 5)

        local isOpen = false
        local optionButtons = {}

        for optName, data in pairs(options) do
            local btn = Instance.new("TextButton", ListFrame)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Text = optName
            Instance.new("UICorner", btn)
            
            table.insert(optionButtons, {Button = btn, Name = optName:lower()})

            btn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. optName
                isOpen = false
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                callback(optName, data)
            end)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        MainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 40)
            MainBtn.Text = (isOpen and "▲ " or "▼ ") .. title
        end)

        -- الفلترة عند الكتابة
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = SearchBox.Text:lower()
            for _, item in ipairs(optionButtons) do
                item.Button.Visible = (searchText == "" or string.find(item.Name, searchText) ~= nil)
            end
        end)
    end

    -- ==========================================
    -- دالة تطبيق المشيات مع حل القلتشات
    -- ==========================================
    local function ApplyAnimation(animData, isRestoring)
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animate = char and char:FindFirstChild("Animate")
        
        if not hum or not animate then return end

        pcall(function()
            -- 🟢 حفظ المشية الأصلية قبل تغييرها (أول مرة فقط)
            if not originalAnims and not isRestoring then
                originalAnims = {
                    idle = animate.idle.Animation1.AnimationId,
                    walk = animate.walk.WalkAnim.AnimationId,
                    run = animate.run.RunAnim.AnimationId,
                    jump = animate.jump.JumpAnim.AnimationId,
                    fall = animate.fall.FallAnim.AnimationId,
                    climb = animate.climb.ClimbAnim.AnimationId,
                    swim = animate.swim.Swim.AnimationId
                }
            end

            -- 🟢 حل القلتش: إيقاف كل الحركات الشغالة حالياً لكي لا تتداخل مع الجديدة!
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end

            -- تركيب الأكواد الجديدة
            local function setAnim(animType, animName, id)
                local track = animate:FindFirstChild(animType)
                if track then
                    local animObj = track:FindFirstChild(animName)
                    if animObj then
                        animObj.AnimationId = string.find(id, "http") and id or "http://www.roblox.com/asset/?id=" .. id
                    end
                end
            end

            setAnim("idle", "Animation1", animData.idle)
            setAnim("idle", "Animation2", animData.idle)
            setAnim("walk", "WalkAnim", animData.walk)
            setAnim("run", "RunAnim", animData.run)
            setAnim("jump", "JumpAnim", animData.jump)
            setAnim("fall", "FallAnim", animData.fall)
            setAnim("climb", "ClimbAnim", animData.climb)
            setAnim("swim", "Swim", animData.swim)
            
            -- إعادة تشغيل السكربت لتحديث الحركة للجميع
            animate.Disabled = true
            task.wait(0.05)
            animate.Disabled = false
        end)
    end

    -- ==========================================
    -- بناء الواجهة وربط الأزرار
    -- ==========================================
    
    AddSearchableDropdown(Tab, "اختر مشية / Select Animation", AnimationPacks, function(name, data)
        selectedAnimData = data
        if isToggleOn then
            ApplyAnimation(data, false)
            Notify("Cryptic Hub 🏃‍♂️", "✅ تم تغيير المشية إلى / Changed to:\n" .. name)
        end
    end)

    Tab:AddToggle("تفعيل المشية / Toggle Animation", function(state)
        isToggleOn = state
        
        if state then
            if not selectedAnimData then
                Notify("Cryptic Hub ⚠️", "يرجى اختيار مشية من القائمة أولاً!\nPlease select an animation first!")
                return
            end
            ApplyAnimation(selectedAnimData, false)
            Notify("Cryptic Hub ✅", "تم تفعيل المشية للجميع!\nAnimation applied for everyone!")
        else
            if originalAnims then
                ApplyAnimation(originalAnims, true)
                Notify("Cryptic Hub 🔄", "تم استرجاع مشيتك الأصلية!\nOriginal animation restored!")
            end
        end
    end)

    -- 🟢 حل مشكلة الموت: عند الترسبن يرجع يركب المشية تلقائياً
    lp.CharacterAdded:Connect(function(char)
        originalAnims = nil -- تصفير الأصلي لأن روبلوكس يركب لك مشيتك العادية عند الترسبن
        task.delay(1, function()
            if isToggleOn and selectedAnimData then
                ApplyAnimation(selectedAnimData, false)
            end
        end)
    end)

    Tab:AddLine()
end
