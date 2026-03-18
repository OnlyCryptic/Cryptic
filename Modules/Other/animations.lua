-- [[ Cryptic Hub - Animation Changer (The Golden Fix - Final V3) ]]
-- المطور: يامي | الوصف: تغيير مباشر، أيديات أنيميشن أصلية، إزالة المفضلات بنجاح، ومكتبة خالية من قلتش التمثال

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 🟢 نظام حفظ المفضلات
local FavFileName = "CrypticHub_FavoriteAnims.json"
local FavoriteAnims = {}

pcall(function()
    if isfile and isfile(FavFileName) then
        local decoded = HttpService:JSONDecode(readfile(FavFileName))
        if type(decoded) == "table" then
            FavoriteAnims = decoded
        end
    end
end)

local function SaveFavorites()
    pcall(function()
        if writefile then
            writefile(FavFileName, HttpService:JSONEncode(FavoriteAnims))
        end
    end)
end

-- ✅ الأيديات الصحيحة المؤكدة (Animation IDs وليست Bundle IDs)
local AnimationPacks = {
    ["wicked popular / مشية بنات"] = {
        idle="118832222982049", walk="92072849924640", run="72301599441680", jump="104325245285198", fall="121152442762481", climb="131326830509784", swim="99384245425157"
    },
    ["glow motion / حركة متوهجة"] = {
        idle="137764781910579", walk="85809016093530", run="101925097435036", jump="74159004634379", fall="98070939608691", climb="108236155509584", swim="83003487432457"
    },
    ["Toy / دمية"] = {
        idle="10921301576", walk="10921312010", run="10921306285", jump="10921308158", fall="10921307241", climb="10921300839", swim="10921309319"
    },
    ["NFL / لاعب أمريكي"] = {
        idle="92080889861410", walk="110358958299415", run="117333533048078", jump="119846112151352", fall="129773241321032", climb="134630013742019", swim="132697394189921"
    },
    ["Adidas Community / تزحلق"] = {
        idle="122257458498464", walk="122150855457006", run="82598234841035", jump="75290611992385", fall="98600215928904", climb="88763136693023", swim="133308483266208"
    },
    ["Vampire / مصاص دماء"] = {
        idle="10921315373", walk="10921326949", run="10921320299", jump="10921322186", fall="10921321317", climb="10921314188", swim="10921324408"
    },
    ["Robot / الروبوت"] = {
        idle="616089559", walk="616095330", run="616091570",
        jump="616090535", fall="616088211", climb="616087119", swim="616094499"
    },
    ["Zombie / الزومبي"] = {
        idle="10921344533", walk="10921355261", run="616163682", jump="10921351278", fall="10921350320", climb="10921343576", swim="10921352344"
    },
    ["Levitation / طيران سحري"] = {
        idle="616006778", walk="616013216", run="616010382",
        jump="616008936", fall="616005863", climb="616003713", swim="616011509"
    },
    ["Mage / الساحر"] = {
        idle="707742142", walk="707897309", run="707861613",
        jump="707853694", fall="707829716", climb="707826056", swim="707876443"
    },
    ["Bubbly / فقاعات"] = {
        idle="910004836", walk="910034870", run="910025107",
        jump="910016857", fall="910001910", climb="909997997", swim="910028158"
    },
    ["Adidas Aura / أورا"] = {
        idle="110211186840347", walk="83842218823011", run="118320322718866", 
        jump="109996626521204", fall="95603166884636", climb="97824616490448", swim="134530128383903"
    },
}

return function(Tab, UI)
    local isToggleOn = false
    local selectedAnimData = nil
    local originalAnims = nil

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
        end)
    end

    local function ApplyAnimation(animData)
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if hum.RigType == Enum.HumanoidRigType.R6 then
            Notify("تنبيه / Warning ⚠️", "المشيات تعمل على R15 فقط!\nAnimations work on R15 only!")
            return
        end

        -- 🚀 إجبار الشخصية على القفز لتحديث الحركة فوراً
        hum.Jump = true
        task.wait(0.1)

        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        if not originalAnims then
            originalAnims = {
                idle  = animate:FindFirstChild("idle")  and animate.idle:FindFirstChild("Animation1")  and animate.idle.Animation1.AnimationId  or "",
                walk  = animate:FindFirstChild("walk")  and animate.walk:FindFirstChild("WalkAnim")    and animate.walk.WalkAnim.AnimationId    or "",
                run   = animate:FindFirstChild("run")   and animate.run:FindFirstChild("RunAnim")      and animate.run.RunAnim.AnimationId      or "",
                jump  = animate:FindFirstChild("jump")  and animate.jump:FindFirstChild("JumpAnim")    and animate.jump.JumpAnim.AnimationId    or "",
                fall  = animate:FindFirstChild("fall")  and animate.fall:FindFirstChild("FallAnim")    and animate.fall.FallAnim.AnimationId    or "",
                climb = animate:FindFirstChild("climb") and animate.climb:FindFirstChild("ClimbAnim")  and animate.climb.ClimbAnim.AnimationId  or "",
                swim  = animate:FindFirstChild("swim")  and animate.swim:FindFirstChild("Swim")        and animate.swim.Swim.AnimationId        or "",
            }
        end

        local function set(parent, child, id)
            if parent and parent:FindFirstChild(child) then
                if id and tostring(id) ~= "" then
                    parent[child].AnimationId = "rbxassetid://" .. tostring(id)
                end
            end
        end

        set(animate:FindFirstChild("idle"),  "Animation1", animData.idle)
        set(animate:FindFirstChild("idle"),  "Animation2", animData.idle)
        set(animate:FindFirstChild("walk"),  "WalkAnim",   animData.walk)
        set(animate:FindFirstChild("run"),   "RunAnim",    animData.run)
        set(animate:FindFirstChild("jump"),  "JumpAnim",   animData.jump)
        set(animate:FindFirstChild("fall"),  "FallAnim",   animData.fall)
        set(animate:FindFirstChild("climb"), "ClimbAnim",  animData.climb)
        set(animate:FindFirstChild("swim"),  "Swim",       animData.swim)

        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
    end

    local function RestoreOriginalAnims()
        if not originalAnims then return end
        
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")
        if not hum or not animate then return end

        -- 🚀 إجبار الشخصية على القفز عند العودة للمشية الأصلية
        hum.Jump = true
        task.wait(0.1)

        local function restoreSet(parent, child, fullId)
            if parent and parent:FindFirstChild(child) and fullId ~= "" then
                parent[child].AnimationId = fullId
            end
        end

        restoreSet(animate:FindFirstChild("idle"),  "Animation1", originalAnims.idle)
        restoreSet(animate:FindFirstChild("idle"),  "Animation2", originalAnims.idle)
        restoreSet(animate:FindFirstChild("walk"),  "WalkAnim",   originalAnims.walk)
        restoreSet(animate:FindFirstChild("run"),   "RunAnim",    originalAnims.run)
        restoreSet(animate:FindFirstChild("jump"),  "JumpAnim",   originalAnims.jump)
        restoreSet(animate:FindFirstChild("fall"),  "FallAnim",   originalAnims.fall)
        restoreSet(animate:FindFirstChild("climb"), "ClimbAnim",  originalAnims.climb)
        restoreSet(animate:FindFirstChild("swim"),  "Swim",       originalAnims.swim)

        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        originalAnims = nil
    end

    -- ==========================================
    -- واجهة المستخدم (UI)
    -- ==========================================
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

            table.insert(optionItems, {
                Frame = ItemFrame, SelectBtn = SelectBtn, StarBtn = StarBtn, 
                RealName = optName, LowerName = optName:lower()
            })

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ محدد / Selected: " .. optName
                isOpen = false
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                callback(optName, data)
            end)

            -- 🚀 تحسين منطق الإضافة والإزالة من المفضلة ليكون مضموناً
            StarBtn.MouseButton1Click:Connect(function()
                if FavoriteAnims[optName] then
                    FavoriteAnims[optName] = nil -- إزالة من المفضلة إذا كانت موجودة
                else
                    FavoriteAnims[optName] = true -- إضافة للمفضلة إذا لم تكن موجودة
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
            MainBtn.Text = (isOpen and "▲ " or "▼ ") .. (selectedAnimData and ("محدد / Selected: " .. title) or title)
        end)

        SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateListDisplay)
    end

    -- ==========================================
    -- ربط الأزرار والأحداث / Events
    -- ==========================================
    AddAdvancedDropdown(Tab, "اختر مشية / Select Animation", AnimationPacks, function(name, data)
        selectedAnimData = data
        if isToggleOn then
            ApplyAnimation(data)
            Notify("تم التغيير / Changed 🏃‍♂️", "المشية الحالية / Current:\n" .. name)
        end
    end)

    Tab:AddToggle("تفعيل المشية / Toggle Animation", function(state)
        isToggleOn = state
        if state then
            if not selectedAnimData then
                Notify("تنبيه / Warning ⚠️", "يرجى اختيار مشية أولاً!\nPlease select an animation first!")
                return
            end
            ApplyAnimation(selectedAnimData)
            Notify("تم التفعيل / Applied ✅", "استمتع بالمشية الجديدة!\nEnjoy your new animation!")
        else
            RestoreOriginalAnims()
            Notify("إيقاف / Restored 🔄", "تم استرجاع المشية الأصلية.\nOriginal animation restored.")
        end
    end)

    lp.CharacterAdded:Connect(function(char)
        originalAnims = nil 
        task.delay(1, function()
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum or hum.Health <= 0 then return end
            if isToggleOn and selectedAnimData then
                ApplyAnimation(selectedAnimData)
            end
        end)
    end)
    
    Tab:AddLine()
end
