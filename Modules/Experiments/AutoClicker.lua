-- [[ Cryptic Hub - Advanced Multi-Point Auto Clicker V2 ]]
-- المطور: arwa hope | الوصف: أوتو كليكر احترافي، تصميم مؤشر تصويب، تحكم بالـ ms، ودعم كامل للجوال

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

return function(Tab, UI)
    -- إنشاء المجلد الرئيسي
    local ACMasterFolder = Tab:AddFolder("🖱️ أوتو كليكر متطور / Adv Auto Clicker")
    
    local clickerCount = 0

    -- 🟢 دالة تصميم مؤشر التصويب الاحترافي (Crosshair Style)
    local function CreateDraggableTarget(id)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CrypticClicker_" .. id
        ScreenGui.Parent = (gethui and gethui()) or CoreGui
        ScreenGui.IgnoreGuiInset = true 
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- الحاوية الأساسية المخفية (مساحة السحب)
        local DragContainer = Instance.new("Frame", ScreenGui)
        DragContainer.Size = UDim2.new(0, 40, 0, 40)
        DragContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        DragContainer.BackgroundTransparency = 1 
        DragContainer.Active = true

        -- الحلقة الخارجية (الدائرة المفرغة)
        local OuterRing = Instance.new("Frame", DragContainer)
        OuterRing.Size = UDim2.new(0, 24, 0, 24)
        OuterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        OuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
        OuterRing.BackgroundTransparency = 1
        local RingStroke = Instance.new("UIStroke", OuterRing)
        RingStroke.Color = Color3.fromRGB(255, 60, 60)
        RingStroke.Thickness = 2
        Instance.new("UICorner", OuterRing).CornerRadius = UDim.new(1, 0)

        -- النقطة الصغيرة في المنتصف (المركز الفعلي للضغط)
        local CenterDot = Instance.new("Frame", DragContainer)
        CenterDot.Size = UDim2.new(0, 4, 0, 4)
        CenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
        CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
        CenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

        -- رقم الكليكر (صغير وأنيق)
        local Label = Instance.new("TextLabel", DragContainer)
        Label.Size = UDim2.new(1, 0, 0, 15)
        Label.Position = UDim2.new(0.5, 0, 0, -8) -- مرفوع شوي فوق الدائرة
        Label.AnchorPoint = Vector2.new(0.5, 1)
        Label.BackgroundTransparency = 1
        Label.Text = tostring(id)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 11
        local TextStroke = Instance.new("UIStroke", Label)
        TextStroke.Context = Enum.UIStrokeContext.Text
        TextStroke.Color = Color3.fromRGB(0, 0, 0)
        TextStroke.Thickness = 1.2

        -- 🔥 برمجة السحب (Drag) ناعمة جداً لدعم الجوال والبي سي
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

    -- 🟢 زر إضافة كليكر جديد
    ACMasterFolder:AddButton("➕ إضافة نقطة جديدة / Add Point", function()
        clickerCount = clickerCount + 1
        local currentID = clickerCount
        
        -- إنشاء المؤشر البصري الجديد
        local targetGui, targetFrame = CreateDraggableTarget(currentID)
        
        -- مجلد التحكم الخاص بهذه النقطة فقط
        local SubFolder = ACMasterFolder:AddFolder("🎯 إعدادات نقطة / Point #" .. currentID)
        
        local isEnabled = false
        local clickSpeedMs = 500 -- السرعة الافتراضية (500ms = نصف ثانية)

        -- 1. زر التفعيل
        SubFolder:AddToggle("تفعيل الضغط / Enable Click", function(state)
            isEnabled = state
            if isEnabled then
                task.spawn(function()
                    while isEnabled do
                        if targetFrame and targetGui.Parent then
                            -- حساب المركز الفعلي للمؤشر للضغط عليه
                            local centerX = targetFrame.AbsolutePosition.X + (targetFrame.AbsoluteSize.X / 2)
                            local centerY = targetFrame.AbsolutePosition.Y + (targetFrame.AbsoluteSize.Y / 2)
                            
                            -- محاكاة كليك الماوس الأيسر (لتحت ثم لفوق بسرعة)
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                            task.wait(0.01) 
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        end
                        -- تحويل الـ ms إلى ثواني عشان محرك اللعبة يفهمها
                        task.wait(clickSpeedMs / 1000)
                    end
                end)
            end
        end)

        -- 2. مربع إدخال السرعة بالـ ms (بتصميم نصي واضح)
        SubFolder:AddInput("السرعة (ms) | 1000ms=1s", function(val)
            local num = tonumber(val)
            if num and num >= 0 then
                clickSpeedMs = num
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="خطأ! أرجوك اكتب رقم صحيح.\nInvalid number!", Duration=3})
            end
        end)

        -- 3. زر إخفاء وإظهار النقطة (عشان ما تزعج العين وقت اللعب)
        SubFolder:AddButton("👁️ إخفاء-إظهار النقطة / Toggle Vis", function()
            if targetGui then
                targetGui.Enabled = not targetGui.Enabled
            end
        end)
        
        -- 4. زر الحذف النهائي للنقطة
        SubFolder:AddButton("🗑️ حذف النقطة / Delete Point", function()
            isEnabled = false 
            if targetGui then targetGui:Destroy() end 
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="تم حذف النقطة #"..currentID.." بنجاح!\nPoint Deleted!", Duration=3})
        end)
    end)
    
    ACMasterFolder:AddLine()
    
    -- نصيحة أنيقة للمستخدمين
    ACMasterFolder:AddButton("💡 ملاحظة / Note", function()
         game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "كيف تتجنب ضغط القائمة؟", 
            Text = "اسحب مؤشر التصويب (الدائرة) وضعه خارج نافذة السكربت ليعمل بشكل صحيح.", 
            Duration = 6
        })
    end)
end
