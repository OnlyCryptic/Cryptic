-- [[ Cryptic Hub - محرك الواجهة المطور V3.0 ]]
-- إصلاح: إضافة الوظائف المفقودة ومعالجة سحب الهاتف باللمس

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ArwaHub_V3"
    Screen.ResetOnSpawn = false

    -- زر C العائم المطور للسحب
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
    OpenBtn.Visible = false; OpenBtn.Text = "C"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

    local dC, dSC, pSC
    OpenBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dC = true; dSC = i.Position; pSC = OpenBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dC and i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - dSC; OpenBtn.Position = UDim2.new(pSC.X.Scale, pSC.X.Offset + d.X, pSC.Y.Scale, pSC.Y.Offset + d.Y) end end)
    OpenBtn.InputEnded:Connect(function() dC = false end)

    -- الإطار الرئيسي
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    
    local dM, dSM, pSM
    TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dM = true; dSM = i.Position; pSM = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dM and i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - dSM; Main.Position = UDim2.new(pSM.X.Scale, pSM.X.Offset + d.X, pSM.Y.Scale, pSM.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function() dM = false end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 110, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40); Content.Size = UDim2.new(1, -120, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function() for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; Page.Visible = true end)

        local TabOps = {}

        -- وظيفة التحكم في السرعة والطيران (التي سببت الخطأ)
        function TabOps:AddSpeedControl(label, callback)
            local Row = Instance.new("Frame", Page); Row.Size = UDim2.new(0.98, 0, 0, 75); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0, 40); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 60, 0, 22); Inp.Position = UDim2.new(0, 10, 0, 40); Inp.Text = "50"; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Inp)
            local active = false
            local function up() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); callback(active, tonumber(Inp.Text) or 50) end
            Tgl.MouseButton1Click:Connect(function() active = not active; up() end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then up() end end)
        end

        function TabOps:AddLine()
            local L = Instance.new("Frame", Page); L.Size = UDim2.new(0.95, 0, 0, 1); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0
        end

        function TabOps:AddToggle(l, c)
            local R = Instance.new("Frame", Page); R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
            local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
            local a = false; B.MouseButton1Click:Connect(function() a = not a; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); c(a) end)
            return { SetState = function(s) a = s; B.BackgroundColor3 = s and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60) end }
        end

        function TabOps:AddInput(l, p, c)
            local R = Instance.new("Frame", Page); R.Size = UDim2.new(0.95, 0, 0, 60); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
            local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 25); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = p; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", I)
            local ig = false; I:GetPropertyChangedSignal("Text"):Connect(function() if not ig then c(I.Text) end end)
            I.Focused:Connect(function() ig = true; I.Text = ""; ig = false; c("") end)
            return { SetText = function(t) ig = true; I.Text = t; ig = false end, TextBox = I }
        end

        function TabOps:AddButton(t, c) local B = Instance.new("TextButton", Page); B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B); B.MouseButton1Click:Connect(function() c() end) end
        function TabOps:AddLabel(t) local R = Instance.new("Frame", Page); R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0,255,150); L.BackgroundTransparency = 1; L.TextXAlignment = "Right"; return {SetText=function(nt) L.Text=nt end} end
        function TabOps:AddParagraph(t) local L = Instance.new("TextLabel",Page); L.Size = UDim2.new(0.95,0,0,25); L.Text = t; L.TextColor3 = Color3.fromRGB(150,150,150); L.BackgroundTransparency = 1; L.TextXAlignment = "Right"; L.TextSize = 11 end

        return TabOps
    end
    return Window
end

function UI:Notify(msg) warn("[Cryptic Hub]: " .. msg) end
return UI
