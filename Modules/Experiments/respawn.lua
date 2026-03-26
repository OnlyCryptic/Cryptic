-- [[ Cryptic Hub - Respawn ]]  
  
return function(Tab, UI)  
    local Players = game:GetService("Players")  
    local StarterGui = game:GetService("StarterGui")  
    local lp = Players.LocalPlayer  
  
    local function Notify(ar, en)  
        pcall(function()  
            StarterGui:SetCore("SendNotification", {  
                Title = "Cryptic Hub",  
                Text = ar .. "\n" .. en,  
                Duration = 4  
            })  
        end)  
    end  
  
    local function AddAutoOffToggle(label, callback)  
        Tab.Order = Tab.Order or 0  
        Tab.Order = Tab.Order + 1  
        local ParentPage = Tab.Page or Tab.Container or Tab  
        local TweenService = game:GetService("TweenService")  
        local function Tw(obj, props, t)  
            TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()  
        end  
  
        local R = Instance.new("Frame", ParentPage)  
        R.LayoutOrder = Tab.Order  
        R.Size = UDim2.new(1, 0, 0, 52)  
        R.BackgroundColor3 = Color3.fromRGB(32, 32, 37)  
        R.BorderSizePixel = 0  
        local rCorner = Instance.new("UICorner", R); rCorner.CornerRadius = UDim.new(0, 10)  
  
        local Lbl = Instance.new("TextLabel", R)  
        Lbl.Text = label  
        Lbl.Size = UDim2.new(1, -80, 1, 0)  
        Lbl.Position = UDim2.new(0, 16, 0, 0)  
        Lbl.TextColor3 = Color3.fromRGB(230, 230, 235)  
        Lbl.BackgroundTransparency = 1  
        Lbl.TextXAlignment = Enum.TextXAlignment.Left  
        Lbl.Font = Enum.Font.GothamSemibold  
        Lbl.TextSize = 14  
        Lbl.TextTruncate = Enum.TextTruncate.AtEnd  
  
        local Track = Instance.new("Frame", R)  
        Track.Size = UDim2.new(0, 48, 0, 26)  
        Track.Position = UDim2.new(1, -64, 0.5, -13)  
        Track.BackgroundColor3 = Color3.fromRGB(65, 65, 73)  
        Track.BorderSizePixel = 0  
        local trCorner = Instance.new("UICorner", Track); trCorner.CornerRadius = UDim.new(1, 0)  
  
        local Thumb = Instance.new("Frame", Track)  
        Thumb.Size = UDim2.new(0, 20, 0, 20)  
        Thumb.Position = UDim2.new(0, 3, 0.5, -10)  
        Thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 205)  
        Thumb.BorderSizePixel = 0  
        local thCorner = Instance.new("UICorner", Thumb); thCorner.CornerRadius = UDim.new(1, 0)  
  
        local ClickBtn = Instance.new("TextButton", R)  
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)  
        ClickBtn.BackgroundTransparency = 1  
        ClickBtn.Text = ""  
        ClickBtn.ZIndex = 5  
  
        local isActive = false  
        local configKey = (Tab.TabName or "Tab") .. "_" .. label  
  
        local function setState(state, isManual)  
            isActive = state  
            if isActive then  
                Tw(Track, {BackgroundColor3 = Color3.fromRGB(225, 225, 230)}, 0.18)  
                Tw(Thumb, {Position = UDim2.new(0, 25, 0.5, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.18)  
            else  
                Tw(Track, {BackgroundColor3 = Color3.fromRGB(65, 65, 73)}, 0.18)  
                Tw(Thumb, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 205)}, 0.18)  
            end  
            if UI and UI.ConfigData then UI.ConfigData[configKey] = isActive end  
            pcall(callback, isActive, isManual)  
        end  
  
        ClickBtn.MouseEnter:Connect(function() Tw(R, {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}, 0.12) end)  
        ClickBtn.MouseLeave:Connect(function() Tw(R, {BackgroundColor3 = Color3.fromRGB(32, 32, 37)}, 0.12) end)  
        ClickBtn.MouseButton1Click:Connect(function() setState(not isActive, true) end)  
  
        local function setupDeathEvent(char)  
            local hum = char:WaitForChild("Humanoid", 5)  
            if hum then  
                hum.Died:Connect(function()  
                    if isActive then  
                        setState(false, false)  
                        Notify("💀 تم إيقاف الريسبون بسبب موتك", "💀 Respawn disabled due to death")  
                    end  
                end)  
            end  
        end  
  
        if lp.Character then task.spawn(function() setupDeathEvent(lp.Character) end) end  
        lp.CharacterAdded:Connect(setupDeathEvent)  
  
        return { SetState = function(self, state) setState(state, false) end }  
    end  
  
    -- 🔘 زر الريسبون  
    AddAutoOffToggle("🔄 ريستارت شخصية / Respawn", function(active)  
        if active then  
            local char = lp.Character  
            if not char then  
                Notify("⚠️ ما في شخصية حالياً", "⚠️ No character found")  
                return  
            end  
  
            local hum = char:FindFirstChildWhichIsA("Humanoid")  
            if not hum or hum.Health <= 0 then  
                Notify("⚠️ الشخصية ميتة أصلاً", "⚠️ Already dead")  
                return  
            end  
  
            Notify("🔄 جاري ريستارت الشخصية...", "🔄 Respawning character...")  
            hum.Health = 0  
        end  
    end)  
  
    Tab:AddLine()  
end