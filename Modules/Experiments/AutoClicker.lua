-- [[ Cryptic Hub - Ultimate Auto Clicker PRO V4 ]]
-- المطور: arwa hope | الوصف: أوتو كليكر احترافي، تخطيط أقسام، ضرب ذكي (أداة/شاشة)، إدخال سرعة مرن (ms/s)، وتصميم برو

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local lp = Players.LocalPlayer

return function(Tab, UI)
    -- ==========================================
    -- 🟢 نظام الحفظ المخصص للماب (PlaceId)
    -- ==========================================
    local SaveFileName = "CrypticAC_ProSaves_" .. tostring(game.PlaceId) .. ".json"
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

    local function Notify(title, arText, enText, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = arText .. "\n" .. enText,
                Duration = duration or 4
            })
        end)
    end

    -- ==========================================
    -- 🟢 المتغيرات الأساسية للكليكر
    -- ==========================================
    local clickerCount = 0
    local ActivePoints = {} -- جدول يحفظ كل النقاط الشغالة

    -- حلقة تكرار مركزية واحدة للأداء العالي تمنع اللاق وتشغل كل النقاط
    task.spawn(function()
        while true do
            for _, point in pairs(ActivePoints) do
                if point.enabled then
                    if tick() - point.lastClick >= (point.speed / 1000) then
                        point.lastClick = tick()
                        
                        -- وضع الأداة (يضرب الأداة داخلياً، لا يتداخل مع الـ UI)
                        if point.mode == "Tool" then
                            local char = lp.Character
                            if char then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end
                        -- وضع الشاشة (يضغط إحداثيات النقطة)
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
    -- 🟢 إنشاء الحاوية الرئيسية للكليكر المتطور (برو)
    -- ==========================================
    -- إنشاء صفحة Tab وهمية داخل مجلد منسدل
    local ACMasterTab = Tab:AddFolder("🖱️ أوتو كليكر برو / Adv Auto Clicker PRO")

    -- ==========================================
    -- 🟢 دالة تحليل وتحويل إدخال السرعة
    -- ==========================================
    local function parseSpeedInput(val)
        -- البحث عن نمط "رقما وحدة"
        local number, unit = string.match(val, "^(%-?%d+%.?%d*)%s*(%a*)$")
        if number then
            number = tonumber(number)
            if number and number > 0 then
                unit = unit:lower()
                if unit == "s" then
                    return number * 1000 -- تحويل الثواني إلى مللي ثانية
                elseif unit == "ms" or unit == "" then
                    return number -- بالفعل مللي ثانية أو افتراضي
                end
            end
        end
        return nil -- إدخال غير صالح
    end

    -- ==========================================
    -- 🟢 دالة إنشاء المؤشر (التصميم الأنيق)
    -- ==========================================
    local function CreateDraggableTarget(id, startX, startY)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CrypticClicker_" .. id
        ScreenGui.Parent = (gethui and gethui()) or CoreGui
        ScreenGui.IgnoreGuiInset = true 
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local DragContainer = Instance.new("Frame", ScreenGui)
        DragContainer.Size = UDim2.new(0, 45, 0, 45)
        DragContainer.Position = UDim2.new(startX or 0.5, 0, startY or 0.5, 0)
        DragContainer.BackgroundColor3 = Color3.new(0, 0, 0)
        DragContainer.BackgroundTransparency = 0.99 -- 🔥 شفاف للجوال
        DragContainer.Active = true

        -- تصميم التصويب (Crosshair)
        local OuterRing = Instance.new("Frame", DragContainer)
        OuterRing.Size = UDim2.new(0, 26, 0, 26)
        OuterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        OuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
        OuterRing.BackgroundTransparency = 1
        local RingStroke = Instance.new("UIStroke", OuterRing)
        RingStroke.Color = Color3.fromRGB(255, 60, 60)
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
    -- 🟢 دالة بناء واجهة نقطة مستقلة في Tab فرعي
    -- ==========================================
    local function BuildPointUI(id, startX, startY, speedVal, modeVal)
        local gui, frame = CreateDraggableTarget(id, startX, startY)
        
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

        -- 🔥 بناء صفحة Tab وهمية منفصلة تماماً للنقطة
        local PointTab = ACMasterTab:AddFolder("🎯 إعدادات نقطة / Point #" .. id)
        
        PointTab:AddToggle("تفعيل الضغط / Enable Click", function(state)
            if ActivePoints[id] then ActivePoints[id].enabled = state end
        end)

        -- 🟢 تحسين خانة إدخال السرعة الاحترافية
        local SpeedInputContainer = PointTab:AddLargeInput("السرعة / Speed", function(val)
            local parsedSpeed = parseSpeedInput(val)
            if parsedSpeed then
                ActivePoints[id].speed = parsedSpeed
                Notify("Cryptic Hub", 
                       "تم تعيين السرعة إلى: " .. parsedSpeed .. "ms", 
                       "Speed set to: " .. parsedSpeed .. "ms", 
                       3)
            else
                Notify("خطأ / Error", 
                       "أدخل رقماً صالحاً متبوعاً بـ ms أو s!", 
                       "Enter valid number followed by ms or s!", 
                       4)
            end
        end)
        SpeedInputContainer.PlaceholderText = "مثال: 500 أو 2s أو 50ms"
        
        -- إضافة نصوص توضيحية احترافية
        local LabelMs = PointTab:AddLabel("1000ms = 1s")
        LabelMs.TextColor3 = Color3.fromRGB(180, 180, 180) -- لون رمادي خفيف
        
        local LabelFormat = PointTab:AddLabel("أدخل رقماً لـ ms، أو أضف 's' لـ s")
        LabelFormat.TextColor3 = Color3.fromRGB(180, 180, 180)
        LabelFormat.TextScaled = false
        LabelFormat.TextSize = 10

        PointTab:AddToggle("وضع الشاشة (إطفاء=أداة) / Screen Mode", function(state)
            if ActivePoints[id] then
                ActivePoints[id].mode = state and "Screen" or "Tool"
                if state then
                    Notify("وضع الشاشة", "سيضغط على إحداثيات الدائرة.", "Will click circle coords.", 4)
                else
                    Notify("وضع الأداة", "سيضرب السلاح تلقائياً (لا يتداخل).", "Will auto-swing weapon (no conflict).", 4)
                end
            end
        end)

        PointTab:AddButton("👁️ إخفاء النقطة / Toggle Vis", function()
            if gui then gui.Enabled = not gui.Enabled end
        end)
        
        PointTab:AddButton("🗑️ حذف النقطة / Delete Point", function()
            if ActivePoints[id] then
                ActivePoints[id].enabled = false
                if ActivePoints[id].gui then ActivePoints[id].gui:Destroy() end
                ActivePoints[id] = nil
                -- ملاحظة: ملف المجلد (Folder) لا يزال موجوداً في الواجهة لكن تم تعطيل وظائفه.
                Notify("حذف", "تم حذف النقطة #" .. id .. " بنجاح!", "Point Deleted!", 4)
            end
        end)
    end

    -- ==========================================
    -- 🟢 قسم أدوات التحكم الرئيسية
    -- ==========================================
    ACMasterTab:AddButton("➕ إضافة نقطة جديدة / Add Point", function()
        clickerCount = clickerCount + 1
        BuildPointUI(clickerCount)
    end)
    
    ACMasterTab:AddButton("💡 ملاحظة حول الـ UI / Note about UI", function()
        Notify("Cryptic Hub", 
               "لتجنب ضغط القائمة بالخطأ، ضع مؤشر التصويب خارج واجهة السكربت أو استخدم وضع الأداة.", 
               "To avoid UI conflicts, place the crosshair target outside the hub or use Tool Mode.", 
               6)
    end)
    
    ACMasterTab:AddLine()

    -- ==========================================
    -- 🟢 قسم المحفظة (الحفظ والمقترحات)
    -- ==========================================
    local SavesTab = ACMasterTab:AddFolder("💾 محفظة الكليكر لهذا الماب / PRO Saves Wallet")
    local currentProfileName = "Default"

    SavesTab:AddInput("اسم الملف الشخصي / Profile Name", function(val)
        if val ~= "" then currentProfileName = val end
    end)

    SavesTab:AddButton("📥 حفظ التشكيلة الحالية / Save Config", function()
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
        SavedProfiles[currentProfileName] = saveArray
        SaveToFile()
        Notify("حفظ التشكيلة / Saved", 
               "تم حفظ تشكيلتك باسم: " .. currentProfileName, 
               "Profile saved as: " .. currentProfileName, 
               4)
    end)

    SavesTab:AddButton("📂 تشغيل تشكيلة / Load Config", function()
        if SavedProfiles[currentProfileName] then
            -- تنظيف النقاط النشطة القديمة قبل التحميل
            for _, p in pairs(ActivePoints) do
                p.enabled = false
                if p.gui then p.gui:Destroy() end
            end
            table.clear(ActivePoints)
            
            -- تشغيل النقاط المحفوظة في ملفات Tab فرعية
            for _, pData in ipairs(SavedProfiles[currentProfileName]) do
                clickerCount = math.max(clickerCount, pData.id)
                BuildPointUI(pData.id, pData.xScale, pData.yScale, pData.speed, pData.mode)
            end
            Notify("تم تحميل / Loaded", 
                   "تم تحميل التشكيلة: " .. currentProfileName, 
                   "Profile loaded: " .. currentProfileName, 
                   4)
        else
            Notify("خطأ / Error", "الملف الشخصي غير موجود!", "Profile non-existent!", 3)
        end
    end)

    SavesTab:AddButton("🗑️ حذف تشكيلة / Delete Save", function()
        if SavedProfiles[currentProfileName] then
            SavedProfiles[currentProfileName] = nil
            SaveToFile()
            Notify("تم الحذف / Deleted", 
                   "تم حذف ملف التشكيلة: " .. currentProfileName, 
                   "Profile deleted: " .. currentProfileName, 
                   4)
        else
            Notify("خطأ / Error", "الملف الشخصي غير موجود!", "Profile non-existent!", 3)
        end
    end)
    
    ACMasterTab:AddLine()
end
