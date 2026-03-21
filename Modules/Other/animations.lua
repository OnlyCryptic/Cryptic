-- [[ Cryptic Hub - Animation Changer (The Golden Fix - Final V6) ]]
-- المطور: يامي | الوصف: دعم متطور، إزالة المفضلات بنجاح، ومكتبة خالية من قلتش التمثال مع نظام صارم لـ idle2 يمنع السبام

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

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

-- ✅ الأيديات الصحيحة المؤكدة
local AnimationPacks = {
    ["idk / مدري"] = {
        idle="4417977954", idle2="4417978624", walk="10921269718", jump="10921263860", fall="10921262864", climb="10921257536", swim="10921264784"
    },
    ["elder / الشيخ"] = {
        idle="10921101664", idle2="10921102574", walk="10921111375", run="10921104374", jump="10921107367", fall="10921105765", climb="10921100400", swim="10921108971"
    },
    ["ninja / نينجا"] = {
        idle="10921155160", idle2="10921155867", walk="10921162768", run="10921157929", jump="10921160088", fall="10921159222", climb="10921154678", swim="10921161002"
    },
    ["amazon unboxed / مشية صراخ"] = {
        idle="98281136301627", idle2="138183121662404", walk="90478085024465", run="134824450619865", jump="121454505477205", fall="94788218468396", climb="121145883950231", swim="105962919001086"
    },
    ["dancing through life/ مشية الرقص"] = {
        idle="92849173543269", idle2="132238900951109", walk="73718308412641", run="135515454877967", jump="78508480717326", fall="78147885297412", climb="129447497744818", swim="110657013921774"
    },
    ["wicked popular / مشية بنات"] = {
        idle="118832222982049", idle2="76049494037641", walk="92072849924640", run="72301599441680", jump="104325245285198", fall="121152442762481", climb="131326830509784", swim="99384245425157"
    },
    ["glow motion / حركة متوهجة"] = {
        idle="137764781910579", idle2="96439737641086", walk="85809016093530", run="101925097435036", jump="74159004634379", fall="98070939608691", climb="108236155509584", swim="83003487432457"
    },
    ["Toy / دمية"] = {
        idle="10921301576", idle2="10921302207", walk="10921312010", run="10921306285", jump="10921308158", fall="10921307241", climb="10921300839", swim="10921309319"
    },
    ["NFL / لاعب أمريكي"] = {
        idle="92080889861410", idle2="74451233229259", walk="110358958299415", run="117333533048078", jump="119846112151352", fall="129773241321032", climb="134630013742019", swim="132697394189921"
    },
    ["Adidas Community / تزحلق"] = {
        idle="122257458498464", idle2="102357151005774", walk="122150855457006", run="82598234841035", jump="75290611992385", fall="98600215928904", climb="88763136693023", swim="133308483266208"
    },
    ["Vampire / مصاص دماء"] = {
        idle="10921315373", idle2="10921316709", walk="10921326949", run="10921320299", jump="10921322186", fall="10921321317", climb="10921314188", swim="10921324408"
    },
    ["Robot / الروبوت"] = {
        idle="10921301576", idle2="10921302207", walk="10921312010", run="10921306285", jump="10921308158", fall="10921307241", climb="10921300839", swim="10921309319"
    },
    ["Zombie / الزومبي"] = {
        idle="10921344533", walk="10921355261", run="616163682", jump="10921351278", fall="10921350320", climb="10921343576", swim="10921352344"
    },
    ["Levitation / طيران سحري"] = {
        idle="10921132962", idle2="10921133721", walk="10921140719", run="10921135644", fall="10921136539", climb="10921132092", swim="10921138209"
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
        idle="110211186840347", idle2="114191137265065", walk="83842218823011", run="118320322718866", jump="109996626521204", fall="95603166884636", climb="97824616490448", swim="134530128383903"
    },
}

return function(Tab, UI)
    local isToggleOn = false
    local selectedAnimData = nil
    local originalAnims = nil
    
    -- متغيرات نظام التشغيل الإجباري لـ idle2
    local customIdleConnection = nil
    local loadedIdle2Track = nil

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
        end)
    end
    
    -- دالة إيقاف التشغيل الإجباري
    local function StopCustomIdle()
        if customIdleConnection then
            customIdleConnection:Disconnect()
            customIdleConnection = nil
        end
        if loadedIdle2Track then
            loadedIdle2Track:Stop()
            loadedIdle2Track = nil
        end
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

        hum.Jump = true
        task.wait(0.1)

        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        if not originalAnims then
            originalAnims = {
                idle   = animate:FindFirstChild("idle")  and animate.idle:FindFirstChild("Animation1")  and animate.idle.Animation1.AnimationId  or "",
                idle2  = animate:FindFirstChild("idle")  and animate.idle:FindFirstChild("Animation2")  and animate.idle.Animation2.AnimationId  or "",
                walk   = animate:FindFirstChild("walk")  and animate.walk:FindFirstChild("WalkAnim")    and animate.walk.WalkAnim.AnimationId    or "",
                walk2  = animate:FindFirstChild("walk")  and animate.walk:FindFirstChild("WalkAnim2")   and animate.walk.WalkAnim2.AnimationId   or "",
                run    = animate:FindFirstChild("run")   and animate.run:FindFirstChild("RunAnim")      and animate.run.RunAnim.AnimationId      or "",
                run2   = animate:FindFirstChild("run")   and animate.run:FindFirstChild("RunAnim2")     and animate.run.RunAnim2.AnimationId     or "",
                jump   = animate:FindFirstChild("jump")  and animate.jump:FindFirstChild("JumpAnim")    and animate.jump.JumpAnim.AnimationId    or "",
                jump2  = animate:FindFirstChild("jump")  and animate.jump:FindFirstChild("JumpAnim2")   and animate.jump.JumpAnim2.AnimationId   or "",
                fall   = animate:FindFirstChild("fall")  and animate.fall:FindFirstChild("FallAnim")    and animate.fall.FallAnim.AnimationId    or "",
                fall2  = animate:FindFirstChild("fall")  and animate.fall:FindFirstChild("FallAnim2")   and animate.fall.FallAnim2.AnimationId   or "",
                climb  = animate:FindFirstChild("climb") and animate.climb:FindFirstChild("ClimbAnim")  and animate.climb.ClimbAnim.AnimationId  or "",
                climb2 = animate:FindFirstChild("climb") and animate.climb:FindFirstChild("ClimbAnim2") and animate.climb.ClimbAnim2.AnimationId or "",
                swim   = animate:FindFirstChild("swim")  and animate.swim:FindFirstChild("Swim")        and animate.swim.Swim.AnimationId        or "",
                swim2  = animate:FindFirstChild("swim")  and animate.swim:FindFirstChild("Swim2")       and animate.swim.Swim2.AnimationId       or "",
            }
        end

        local function setAnim(parent, childName, id)
            if not parent then return end
            if id and tostring(id) ~= "" then
                local animObj = parent:FindFirstChild(childName)
                if not animObj then
                    animObj = Instance.new("Animation")
                    animObj.Name = childName
                    animObj.Parent = parent
                end
                animObj.AnimationId = "rbxassetid://" .. tostring(id)
            else
                local animObj = parent:FindFirstChild(childName)
                if animObj then animObj:Destroy() end
            end
        end

        setAnim(animate:FindFirstChild("idle"),  "Animation1", animData.idle)
        setAnim(animate:FindFirstChild("idle"),  "Animation2", animData.idle2)

        setAnim(animate:FindFirstChild("walk"),  "WalkAnim",   animData.walk)
        setAnim(animate:FindFirstChild("walk"),  "WalkAnim2",  animData.walk2)

        setAnim(animate:FindFirstChild("run"),   "RunAnim",    animData.run)
        setAnim(animate:FindFirstChild("run"),   "RunAnim2",   animData.run2)

        setAnim(animate:FindFirstChild("jump"),  "JumpAnim",   animData.jump)
        setAnim(animate:FindFirstChild("jump"),  "JumpAnim2",  animData.jump2)

        setAnim(animate:FindFirstChild("fall"),  "FallAnim",   animData.fall)
        setAnim(animate:FindFirstChild("fall"),  "FallAnim2",  animData.fall2)

        setAnim(animate:FindFirstChild("climb"), "ClimbAnim",  animData.climb)
        setAnim(animate:FindFirstChild("climb"), "ClimbAnim2", animData.climb2)

        setAnim(animate:FindFirstChild("swim"),  "Swim",       animData.swim)
        setAnim(animate:FindFirstChild("swim"),  "Swim2",      animData.swim2)

        -- إيقاف أي دورة شغالة قديمة
        StopCustomIdle()

        -- 🔥 إعادة تشغيل السكربت الأساسي
        animate.Disabled = true
        task.wait(0.05)
        animate.Disabled = false

        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
            
            -- 🔥 النظام الصارم لتشغيل idle2 كل 12 ثانية بدون سبام
            if animData.idle2 then
                local customIdleAnim = Instance.new("Animation")
                customIdleAnim.AnimationId = "rbxassetid://" .. animData.idle2
                loadedIdle2Track = animator:LoadAnimation(customIdleAnim)
                
                -- إعدادات تمنع السبام والتكرار التلقائي
                loadedIdle2Track.Priority = Enum.AnimationPriority.Idle
                loadedIdle2Track.Looped = false 
                
                local lastMoveTime = tick()
                local isIdle2Active = false
                
                customIdleConnection = RunService.Heartbeat:Connect(function()
                    if hum.MoveDirection.Magnitude > 0 then
                        -- لو تحرك، نصفر كل شي
                        lastMoveTime = tick()
                        if isIdle2Active then
                            loadedIdle2Track:Stop(0.5)
                            isIdle2Active = false
                        end
                    else
                        -- لو واقف
                        if isIdle2Active then
                            -- ننتظر الين تخلص الحركة بالكامل
                            if not loadedIdle2Track.IsPlaying then
                                isIdle2Active = false
                                lastMoveTime = tick() -- نبدأ نحسب 12 ثانية جديدة فقط بعد ما توقف الحركة
                            end
                        else
                            -- إذا مرت 12 ثانية وهو واقف
                            if tick() - lastMoveTime >= 12 then
                                isIdle2Active = true
                                loadedIdle2Track:Play(0.5)
                            end
                        end
                    end
                end)
            end
        end
    end

    local function RestoreOriginalAnims()
        if not originalAnims then return end
        
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")
        
        StopCustomIdle() -- إيقاف النظام الإجباري

        if not hum or not animate then return end

        hum.Jump = true
        task.wait(0.1)

        local function restoreAnim(parent, childName, fullId)
            if not parent then return end
            if fullId and fullId ~= "" then
                local animObj = parent:FindFirstChild(childName)
                if not animObj then
                    animObj = Instance.new("Animation")
                    animObj.Name = childName
                    animObj.Parent = parent
                end
                animObj.AnimationId = fullId
            else
                local animObj = parent:FindFirstChild(childName)
                if animObj then animObj:Destroy() end
            end
        end

        restoreAnim(animate:FindFirstChild("idle"),  "Animation1", originalAnims.idle)
        restoreAnim(animate:FindFirstChild("idle"),  "Animation2", originalAnims.idle2)

        restoreAnim(animate:FindFirstChild("walk"),  "WalkAnim",   originalAnims.walk)
        restoreAnim(animate:FindFirstChild("walk"),  "WalkAnim2",  originalAnims.walk2)

        restoreAnim(animate:FindFirstChild("run"),   "RunAnim",    originalAnims.run)
        restoreAnim(animate:FindFirstChild("run"),   "RunAnim2",   originalAnims.run2)

        restoreAnim(animate:FindFirstChild("jump"),  "JumpAnim",   originalAnims.jump)
        restoreAnim(animate:FindFirstChild("jump"),  "JumpAnim2",  originalAnims.jump2)

        restoreAnim(animate:FindFirstChild("fall"),  "FallAnim",   originalAnims.fall)
        restoreAnim(animate:FindFirstChild("fall"),  "FallAnim2",  originalAnims.fall2)

        restoreAnim(animate:FindFirstChild("climb"), "ClimbAnim",  originalAnims.climb)
        restoreAnim(animate:FindFirstChild("climb"), "ClimbAnim2", originalAnims.climb2)

        restoreAnim(animate:FindFirstChild("swim"),  "Swim",       originalAnims.swim)
        restoreAnim(animate:FindFirstChild("swim"),  "Swim2",      originalAnims.swim2)

        animate.Disabled = true
        task.wait(0.05)
        animate.Disabled = false

        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        originalAnims = nil
    end

    -- ==========================================
    -- واجهة المستخدم (UI) (نفسها بدون تغيير)
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
        StopCustomIdle() -- نظف لو مات ورجع
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
