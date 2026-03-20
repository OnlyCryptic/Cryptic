-- [[ Cryptic Hub - Ultimate Auto Clicker V3 ]]
-- المطور: arwa hope | الوصف: أوتو كليكر متطور، وضع الأداة (يمنع ضغط الـ UI)، وحفظ مخصص لكل ماب

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

return function(Tab, UI)
    -- ==========================================
    -- 🟢 نظام الحفظ المخصص للماب (PlaceId)
    -- ==========================================
    local SaveFileName = "CrypticAC_Saves_" .. tostring(game.PlaceId) .. ".json"
    local SavedProfiles = {}

    pcall(function()
        if isfile and isfile(SaveFileName) then
            local decoded = HttpService:JSONDecode(readfile(SaveFileName))
            if type(decoded) == "table" then SavedProfiles = decoded end
        end
    end)

    local function SaveToFile()
        pcall(function()
            if writefile then
                writefile(SaveFileName, HttpService:JSONEncode(SavedProfiles))
            end
        end)
    end

    local function Notify(title, text)
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title=title, Text=text, Duration=4}) end)
    end

    -- ==========================================
    -- 🟢 المتغيرات الأساسية للكليكر
    -- ==========================================
    local clickerCount = 0
    local ActivePoints = {} -- جدول يحفظ كل النقاط الشغالة

    -- حلقة تكرار مركزية (واحدة فقط) تمنع اللاق وتشغل كل النقاط
    task.spawn(function()
        while true do
            for _, point in pairs(ActivePoints) do
                if point.enabled then
                    if tick() - point.lastClick >= (point.speed / 1000) then
                        point.lastClick = tick()
                        
                        -- إذا كان وضع الأداة (بدون ضغط شاشة، كأنه كليكر داخلي)
                        if point.mode == "Tool" then
                            local char = lp.Character
                            if char then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end
                        -- إذا كان وضع الشاشة (يضغط مكان النقطة)
                        elseif point.mode == "Screen" and point.gui and point.gui.Parent then
                            local frame = point.frame
                            local cx = frame.AbsolutePosition.X + (frame.AbsoluteSize.X / 2)
                            local cy = frame.AbsolutePosition.Y + (frame.AbsoluteSize.Y / 2)
                            
                            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)

    -- ==========================================
    -- 🟢 دالة إنشاء النقطة (المؤشر)
    -- ==========================================
    local function CreateTarget(id, startX, startY)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CrypticClicker_" .. id
        ScreenGui.Parent = (gethui and gethui()) or CoreGui
        ScreenGui.IgnoreGuiInset = true 
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- الحاوية الأساسية المخفية (مساحة السحب)
        local DragContainer = Instance.new("Frame", ScreenGui)
        DragContainer.Size = UDim2.new(0, 45, 0, 45)
        DragContainer.Position = UDim2.new(startX or 0.5, 0, startY or 0.5, 0)
        DragContainer.BackgroundColor3 = Color3.new(0, 0, 0)
        DragContainer.BackgroundTransparency = 0.99 -- 🔥 سر حركة الجوال: شبه مخفي بس يلمس!
        DragContainer.Active = true

        -- تصميم التصويب (Crosshair)
        local OuterRing = Instance.new("Frame", DragContainer)
        OuterRing.Size = UDim2.new(0, 26, 0, 26)
        OuterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        OuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
        OuterRing.BackgroundTransparency = 1
        local RingStroke = Instance.new("UIStroke", OuterRing)
        RingStroke.Color = Color3.fromRGB(0, 255, 150) -- لون مميز
        RingStroke.Thickness = 2
        Instance.new("UICorner", OuterRing).CornerRadius = UDim.new(1, 0)

        local CenterDot = Instance.new("Frame", DragContainer)
        CenterDot.Size = UDim2.new(0, 6, 0, 6)
        CenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
        CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
        CenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel", DragContainer)
        Label.Size = UDim2.new(1, 0, 0, 15)
        Label.Position = UDim2.new(0.5, 0, 0, -10)
        Label.AnchorPoint = Vector2.new(0.5, 1)
        Label.BackgroundTransparency = 1
        Label.Text = tostring(id)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12
        local TextStroke = Instance.new("UIStroke", Label)
        TextStroke.Context = Enum.UIStrokeContext.Text
        TextStroke.Color = Color3.fromRGB(0, 0, 0)
        TextStroke.Thickness = 1.2

        -- 🔥 برمجة السحب (Drag) المضمونة
        local dragging, dragInput, dragStart, startPos
        DragContainer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = DragContainer.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        DragContainer.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                DragContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        return ScreenGui, DragContainer
    end

    -- ==========================================
    -- 🟢 دالة بناء نقطة وتحكمها في الواجهة
    -- ==========================================
    local function BuildPointUI(id, startX, startY, speedVal, modeVal)
        local gui, frame = CreateTarget(id, startX, startY)
        
        -- تسجيل النقطة في النظام
        ActivePoints[id] = {
            id = id,
            gui = gui,
            frame = frame,
            enabled = false,
            speed = speedVal or 500,
            mode = modeVal or "Tool",
            lastClick = 0
        }

        -- إنشاء مجلد مستقل للنقطة مباشرة في الـ Tab (عشان ما تختفي الأزرار)
        local PointFolder = Tab:AddFolder("🎯 إعدادات نقطة / Point #" .. id)
        
        PointFolder:AddToggle("تفعيل الضغط / Enable Click", function(state)
            if ActivePoints[id] then ActivePoints[id].enabled = state end
        end)

        PointFolder:AddInput("السرعة (ms) | 1000ms=1s", function(val)
            local num = tonumber(val)
            if num and num > 0 and ActivePoints[id] then
                ActivePoints[id].speed = num
            else
                Notify("خطأ", "أدخل رقم صحيح للسرعة!")
            end
        end)

        PointFolder:AddToggle("وضع الشاشة (إطفاء = أداة) / Screen Mode", function(state)
            if ActivePoints[id] then
                ActivePoints[id].mode = state and "Screen" or "Tool"
                if state then
                    Notify("وضع الشاشة", "سيضغط على إحداثيات الدائرة.")
                else
                    Notify("وضع الأداة", "سيضرب السلاح تلقائياً (لا يتداخل مع الواجهة).")
                end
            end
        end)

        PointFolder:AddButton("👁️ إخفاء النقطة / Toggle Vis", function()
            if gui then gui.Enabled = not gui.Enabled end
        end)
        
        PointFolder:AddButton("🗑️ حذف النقطة / Delete", function()
            if ActivePoints[id] then
                ActivePoints[id].enabled = false
                if ActivePoints[id].gui then ActivePoints[id].gui:Destroy() end
                ActivePoints[id] = nil
                Notify("حذف", "تم حذف النقطة #" .. id)
            end
        end)
    end

    -- ==========================================
    -- 🟢 واجهة الكليكر الرئيسية
    -- ==========================================
    Tab:AddButton("➕ إضافة نقطة جديدة / Add Point", function()
        clickerCount = clickerCount + 1
        BuildPointUI(clickerCount)
    end)
    
    Tab:AddLine()

    -- ==========================================
    -- 🟢 واجهة نظام الحفظ والمحفظة (احترافية)
    -- ==========================================
    local SaveFolder = Tab:AddFolder("💾 محفظة الكليكر (لهذا الماب) / Saves")
    local currentSaveName = "Default"

    SaveFolder:AddInput("اسم التشكيلة / Profile Name", function(val)
        if val ~= "" then currentSaveName = val end
    end)

    SaveFolder:AddButton("📥 حفظ النقاط الحالية / Save Config", function()
        local saveArray = {}
        for _, p in pairs(ActivePoints) do
            if p.gui and p.frame then
                table.insert(saveArray, {
                    id = p.id,
                    xScale = p.frame.Position.X.Scale,
                    yScale = p.frame.Position.Y.Scale,
                    speed = p.speed,
                    mode = p.mode
                })
            end
        end
        SavedProfiles[currentSaveName] = saveArray
        SaveToFile()
        Notify("Cryptic Hub", "تم حفظ التشكيلة باسم: " .. currentSaveName)
    end)

    SaveFolder:AddButton("📂 تشغيل التشكيلة / Load Config", function()
        if SavedProfiles[currentSaveName] then
            -- تنظيف النقاط القديمة قبل التشغيل
            for k, p in pairs(ActivePoints) do
                p.enabled = false
                if p.gui then p.gui:Destroy() end
            end
            table.clear(ActivePoints)
            
            -- تشغيل النقاط المحفوظة
            for _, pData in ipairs(SavedProfiles[currentSaveName]) do
                clickerCount = math.max(clickerCount, pData.id)
                BuildPointUI(pData.id, pData.xScale, pData.yScale, pData.speed, pData.mode)
            end
            Notify("Cryptic Hub", "تم تحميل التشكيلة: " .. currentSaveName)
        else
            Notify("خطأ", "لا يوجد حفظ بهذا الاسم!")
        end
    end)

    SaveFolder:AddButton("🗑️ حذف التشكيلة / Delete Save", function()
        if SavedProfiles[currentSaveName] then
            SavedProfiles[currentSaveName] = nil
            SaveToFile()
            Notify("Cryptic Hub", "تم حذف التشكيلة: " .. currentSaveName)
        else
            Notify("خطأ", "التشكيلة غير موجودة أصلاً!")
        end
    end)
end
