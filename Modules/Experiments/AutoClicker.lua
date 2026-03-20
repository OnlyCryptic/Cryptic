-- [[ Cryptic Hub - Advanced Multi-Point Auto Clicker ]]
-- المطور: arwa hope | الوصف: أوتو كليكر متعدد النقاط يدعم السحب على الجوال والبي سي مع تحكم مستقل

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

return function(Tab, UI)
    -- إنشاء المجلد الرئيسي للأوتو كليكر باستخدام دالتك الجديدة
    local ACMasterFolder = Tab:AddFolder("🖱️ أوتو كليكر متطور / Adv Auto Clicker")
    
    local clickerCount = 0
    local activeClickers = {}

    -- 🟢 دالة احترافية لإنشاء مؤشر قابل للسحب (يدعم لمس الجوال والماوس)
    local function CreateDraggableTarget(id)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CrypticClicker_" .. id
        -- وضع المؤشر في CoreGui عشان ما يكتشفه نظام الحماية حق الماب
        ScreenGui.Parent = (gethui and gethui()) or CoreGui
        ScreenGui.IgnoreGuiInset = true -- عشان تتطابق الإحداثيات 100%

        local Frame = Instance.new("Frame", ScreenGui)
        Frame.Size = UDim2.new(0, 40, 0, 40)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Frame.BackgroundTransparency = 0.4
        Frame.BorderSizePixel = 2
        Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(1, 0) -- يخليه دائري

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = tostring(id)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextScaled = true

        -- 🔥 برمجة السحب (Drag) لدعم الجوال والبي سي
        local dragging, dragInput, dragStart, startPos
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        Frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        return ScreenGui, Frame
    end

    -- 🟢 زر إضافة كليكر جديد
    ACMasterFolder:AddButton("➕ إضافة نقطة جديدة / Add Clicker Point", function()
        clickerCount = clickerCount + 1
        local currentID = clickerCount
        
        -- إنشاء المؤشر البصري
        local targetGui, targetFrame = CreateDraggableTarget(currentID)
        
        -- إنشاء مجلد فرعي للتحكم بهذا الكليكر فقط
        local SubFolder = ACMasterFolder:AddFolder("🎯 نقطة / Point #" .. currentID)
        
        local isEnabled = false
        local clickSpeed = 0.5 -- السرعة الافتراضية (نصف ثانية)

        -- 1. زر التفعيل
        SubFolder:AddToggle("تفعيل / Enable", function(state)
            isEnabled = state
            if isEnabled then
                task.spawn(function()
                    while isEnabled do
                        if targetFrame and targetGui.Parent then
                            -- أخذ إحداثيات مركز الدائرة الحمراء
                            local centerX = targetFrame.AbsolutePosition.X + (targetFrame.AbsoluteSize.X / 2)
                            local centerY = targetFrame.AbsolutePosition.Y + (targetFrame.AbsoluteSize.Y / 2)
                            
                            -- محاكاة الضغط الوهمي (تتجاهل واجهة السكربت إذا كانت النقطة برا الواجهة)
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                            task.wait(0.02)
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        end
                        task.wait(clickSpeed)
                    end
                end)
            end
        end)

        -- 2. مربع إدخال السرعة
        SubFolder:AddInput("السرعة (ثواني) / Speed (s)", function(val)
            local num = tonumber(val)
            if num and num > 0 then
                clickSpeed = num
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="الرجاء إدخال رقم صحيح!\nValid number please!", Duration=3})
            end
        end)

        -- 3. زر إخفاء وإظهار النقطة
        SubFolder:AddButton("👁️ إخفاء-إظهار النقطة / Toggle Visibility", function()
            if targetGui then
                targetGui.Enabled = not targetGui.Enabled
            end
        end)
        
        -- 4. زر حذف الكليكر نهائياً
        SubFolder:AddButton("🗑️ حذف النقطة / Delete Point", function()
            isEnabled = false -- إيقاف الضغط
            if targetGui then targetGui:Destroy() end -- مسح المؤشر من الشاشة
            -- ملاحظة: لا يمكن حذف الـ Folder نفسه برمجياً من الواجهة بسهولة، لكننا نعطل وظائفه.
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="تم الحذف!\nPoint Deleted!", Duration=3})
        end)
    end)
    
    ACMasterFolder:AddLine()
    
    -- تنبيه للاعب عشان يعرف كيف يتجنب الضغط على واجهة السكربت
    ACMasterFolder:AddButton("⚠️ نصيحة / Tip", function()
         game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub Tips", 
            Text = "ضع النقطة الحمراء خارج واجهة السكربت لتجنب الضغط عليها بالخطأ.\nPlace the red dot outside the menu.", 
            Duration = 6
        })
    end)
end
