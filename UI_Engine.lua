local UI = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 400, 0, 250)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- نيون علوي
    local Bar = Instance.new("Frame", Main)
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)

    -- العنوان
    local Txt = Instance.new("TextLabel", Main)
    Txt.Text = title
    Txt.Size = UDim2.new(1, -20, 0, 30)
    Txt.BackgroundTransparency = 1
    Txt.TextColor3 = Color3.new(1, 1, 1)
    Txt.TextXAlignment = "Right"

    -- حاوية الأقسام (Tabs)
    local TabContainer = Instance.new("ScrollingFrame", Main)
    TabContainer.Size = UDim2.new(1, -20, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", TabContainer)

    local Window = {}
    function Window:CreateTab(name)
        local TabFrame = Instance.new("Frame", TabContainer)
        TabFrame.Size = UDim2.new(1, 0, 0, 30)
        TabFrame.BackgroundTransparency = 1
        
        local TabTitle = Instance.new("TextLabel", TabFrame)
        TabTitle.Text = "-- " .. name .. " --"
        TabTitle.Size = UDim2.new(1, 0, 1, 0)
        TabTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
        TabTitle.BackgroundTransparency = 1

        local TabOps = {}
        function TabOps:AddButton(text, callback)
            local Btn = Instance.new("TextButton", TabContainer)
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(callback)
        end
        return TabOps
    end
    return Window
end

function UI:Notify(msg)
    print("[Cryptic]: " .. msg)
end

return UI
