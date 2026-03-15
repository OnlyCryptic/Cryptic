-- [[ Cryptic Hub - Animation Changer (Corrected IDs 100%) ]]
-- المطور: يامي | الوصف: مكتبة مصححة، نظام مفضلة (⭐)، وبحث نظيف

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local FavFileName = "CrypticHub_FavoriteAnims.json"
local FavoriteAnims = {}

pcall(function()
    if isfile and isfile(FavFileName) then
        local fileData = readfile(FavFileName)
        FavoriteAnims = HttpService:JSONDecode(fileData)
    end
end)

local function SaveFavorites()
    pcall(function()
        if writefile then
            writefile(FavFileName, HttpService:JSONEncode(FavoriteAnims))
        end
    end)
end

-- 🟢 مكتبة المشيات (تم تصحيح الأكواد الداخلية لمنع الانعكاس)
local AnimationPacks = {
    ["Ninja / النينجا"] = {idle="656117400", walk="656121766", run="656118852", jump="656117878", fall="656115606", climb="656114359", swim="656119721"},
    ["Cartoony / كارتوني"] = {idle="742637544", walk="742640026", run="742638842", jump="742637942", fall="742637151", climb="742636889", swim="742639220"},
    ["Superhero / بطل خارق"] = {idle="782841498", walk="782843345", run="782842708", jump="782842230", fall="782842046", climb="782841270", swim="782843136"},
    ["Mage / الساحر"] = {idle="707742142", walk="707897309", run="707861613", jump="707853694", fall="707829716", climb="707826056", swim="707876443"},
    ["Robot / الروبوت"] = {idle="616089559", walk="616095330", run="616091570", jump="616090535", fall="616088211", climb="616087119", swim="616094499"},
    ["Toy / اللعبة"] = {idle="782847240", walk="782847321", run="782847020", jump="782847767", fall="782846875", climb="782846665", swim="782847667"}, -- تم تصحيح المشي والقفز
    ["Sneaky / المتسلل"] = {idle="1132473842", walk="1132510127", run="1132494274", jump="1132489678", fall="1132461320", climb="1132456461", swim="1132512130"},
    ["Levitation / طيران سحري"] = {idle="616006778", walk="616013216", run="616010382", jump="616008936", fall="616005863", climb="616003713", swim="616011509"},
    ["Astronaut / رائد فضاء"] = {idle="891621366", walk="891636393", run="891636393", jump="891627522", fall="891617961", climb="891609353", swim="891639666"},
    ["Zombie / الزومبي"] = {idle="616158929", walk="616168032", run="616163682", jump="616161748", fall="616157476", climb="616156119", swim="616165109"},
    ["Elder / العجوز"] = {idle="845397899", walk="845400256", run="845398858", jump="845398230", fall="845398048", climb="845397193", swim="845400765"},
    ["Confident / الواثق"] = {idle="1065064003", walk="1065064438", run="1065064560", jump="1065064222", fall="1065064119", climb="1065063851", swim="1065064669"},
    ["Stylish / الأنيق"] = {idle="1058444315", walk="1058444737", run="1058444855", jump="1058444558", fall="1058444457", climb="1058444155", swim="1058445009"},
    ["Werewolf / المستذئب"] = {idle="1083195517", walk="1083216690", run="1083214717", jump="1083202519", fall="1083189019", climb="1083182000", swim="1083218792"},
    ["Vampire / مصاص دماء"] = {idle="1083445855", walk="1083473930", run="1083462077", jump="1083466540", fall="1083443587", climb="1083439240", swim="1083477197"},
    ["Bubbly / فقاعات"] = {idle="910004836", walk="910034870", run="910025107", jump="910016857", fall="910001910", climb="909997997", swim="910028158"},
    ["Pirate / القرصان"] = {idle="750781874", walk="750785693", run="750783738", jump="750782230", fall="750780242", climb="750779899", swim="750784579"}
}

return function(Tab, UI)
    local isToggleOn = false
    local selectedAnimData = nil
    local originalAnims = nil

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 }) end)
    end

    local function AddAdvancedDropdown(tabRef, title, options, callback)
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
        SearchBox.Text = "" 
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
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 

        local isOpen = false
        local optionItems = {}

        local function UpdateListDisplay()
            local searchText = SearchBox.Text:lower()
            for _, item in ipairs(optionItems) do
                local isFav = FavoriteAnims[item.RealName]
                local matchSearch = (searchText == "" or string.find(item.LowerName, searchText) ~= nil)
                
                item.Frame.Visible = matchSearch
                item.Frame.LayoutOrder = isFav and 1 or 2 
                item.StarBtn.Text = isFav and "⭐" or "☆"
                item.StarBtn.TextColor3 = isFav and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
            end
        end

        for optName, data in pairs(options) do
            local ItemFrame = Instance.new("Frame", ListFrame)
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", ItemFrame)
            
            local SelectBtn = Instance.new("TextButton", ItemFrame)
            SelectBtn.Size = UDim2.new(0.85, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            SelectBtn.Text = "  " .. optName
            SelectBtn.TextXAlignment = Enum.TextXAlignment.Left

            local StarBtn = Instance.new("TextButton", ItemFrame)
            StarBtn.Size = UDim2.new(0.15, 0, 1, 0)
            StarBtn.Position = UDim2.new(0.85, 0, 0, 0)
            StarBtn.BackgroundTransparency = 1
            StarBtn.Text = "☆"
            StarBtn.TextSize = 16

            table.insert(optionItems, {Frame = ItemFrame, SelectBtn = SelectBtn, StarBtn = StarBtn, RealName = optName, LowerName = optName:lower()})

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. optName
                isOpen = false
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                callback(optName, data)
            end)

            StarBtn.MouseButton1Click:Connect(function()
                if FavoriteAnims[optName] then
                    FavoriteAnims[optName] = nil 
                else
                    FavoriteAnims[optName] = true 
                end
                SaveFavorites()
                UpdateListDisplay() 
            end)
        end

        UpdateListDisplay() 

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        MainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 40)
            MainBtn.Text = (isOpen and "▲ " or "▼ ") .. title
        end)

        SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateListDisplay)
    end

    local function ApplyAnimation(animData, isRestoring)
        local char = lp.Character
        if not char then return end
        
        local hum = char:WaitForChild("Humanoid", 3)
        local animate = char:WaitForChild("Animate", 3)
        
        if not hum or not animate then return end
        
        if hum.RigType == Enum.HumanoidRigType.R6 then
            Notify("تنبيه / Warning ⚠️", "هذا الماب يستخدم أجسام R6، المشيات تدعم R15 فقط!\nAnimations require R15!")
            return
        end

        pcall(function()
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

            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end

            local function setAnim(animType, animName, id)
                local trackValue = animate:FindFirstChild(animType)
                if trackValue then
                    local animObj = trackValue:FindFirstChild(animName)
                    local finalId = "rbxassetid://" .. id
                    
                    if animObj then animObj.AnimationId = finalId end
                    if trackValue:IsA("StringValue") then trackValue.Value = finalId end
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
            
            animate.Disabled = true
            task.wait(0.05)
            animate.Disabled = false

            local oldSpeed = hum.WalkSpeed
            hum.WalkSpeed = 0
            task.wait(0.01)
            hum.WalkSpeed = oldSpeed
        end)
    end
    
    AddAdvancedDropdown(Tab, "اختر مشية / Select Animation", AnimationPacks, function(name, data)
        selectedAnimData = data
        if isToggleOn then
            ApplyAnimation(data, false)
            Notify("نجاح / Success 🏃‍♂️", "تم تغيير المشية إلى / Changed to:\n" .. name)
        end
    end)

    Tab:AddToggle("تفعيل المشية / Toggle Animation", function(state)
        isToggleOn = state
        
        if state then
            if not selectedAnimData then
                Notify("تنبيه / Warning ⚠️", "يرجى اختيار مشية من القائمة أولاً!\nPlease select an animation first!")
                return
            end
            ApplyAnimation(selectedAnimData, false)
            Notify("تفعيل / Applied ✅", "تم تفعيل المشية بنجاح!\nAnimation applied!")
        else
            if originalAnims then
                ApplyAnimation(originalAnims, true)
                Notify("إيقاف / Restored 🔄", "تم استرجاع مشيتك الأصلية!\nOriginal animation restored!")
            end
        end
    end)

    lp.CharacterAdded:Connect(function()
        originalAnims = nil 
        task.delay(1, function()
            if isToggleOn and selectedAnimData then
                ApplyAnimation(selectedAnimData, false)
            end
        end)
    end)

    Tab:AddLine()
end
