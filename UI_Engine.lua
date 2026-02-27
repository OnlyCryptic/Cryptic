-- [[ Cryptic Hub - محرك الواجهة المطور V2.2 ]]
-- تحديث: دعم الخطوط التلقائية والتحكم الذكي بالحالات

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ArwaHub_V2_2"
    Screen.ResetOnSpawn = false

    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22); OpenBtn.Visible = false; OpenBtn.Text = "C"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = "Left"

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 110, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40); Content.Size = UDim2.new(1, -120, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function() for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; Page.Visible = true end)

        local TabOps = {}

        -- وظيفة الخط الفاصل
        function TabOps:AddLine()
            local Line = Instance.new("Frame", Page)
            Line.Size = UDim2.new(0.95, 0, 0, 1); Line.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Line.BackgroundTransparency = 0.5; Line.BorderSizePixel = 0
        end

        function TabOps:AddToggle(label, callback)
            local Row = Instance.new("Frame", Page); Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            local active = false
            local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); callback(active) end
            Tgl.MouseButton1Click:Connect(function() active = not active; update() end)
            return { SetState = function(s) active = s; update() end }
        end

        function TabOps:AddInput(label, placeholder, callback)
            local Row = Instance.new("Frame", Page); Row.Size = UDim2.new(0.95, 0, 0, 60); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0.9, 0, 0, 25); Inp.Position = UDim2.new(0.05, 0, 0, 30); Inp.PlaceholderText = placeholder; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Inp)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() callback(Inp.Text) end)
            return { SetText = function(t) Inp.Text = t end }
        end

        function TabOps:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page); Btn.Size = UDim2.new(0.95, 0, 0, 40); Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Btn.Text = text; Btn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(function() callback() end)
            return { SetText = function(t) Btn.Text = t end }
        end

        -- (باقي الوظائف AddLabel, AddImage, AddParagraph كما هي...)
        function TabOps:AddLabel(t) local R = Instance.new("Frame", Page); R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner", R); local L = Instance.new("TextLabel", R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0,255,150); L.BackgroundTransparency = 1; L.TextXAlignment = "Right"; return {SetText=function(nt) L.Text=nt end} end
        function TabOps:AddImage(u) local I = Instance.new("ImageLabel", Page); I.Size = UDim2.new(0.95,0,0,120); I.Image = u; I.BackgroundTransparency = 1; I.ScaleType = "Fit" end
        function TabOps:AddParagraph(t) local L = Instance.new("TextLabel", Page); L.Size = UDim2.new(0.95,0,0,25); L.Text = t; L.TextColor3 = Color3.fromRGB(150,150,150); L.BackgroundTransparency = 1; L.TextXAlignment = "Right"; L.TextSize = 11 end
        
        return TabOps
    end
    return Window
end

function UI:Notify(msg) warn("[Cryptic Hub]: " .. msg) end
return UI
