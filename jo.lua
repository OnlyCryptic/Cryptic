-- إنشاء الشاشة الرئيسية (ScreenGui)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

-- مربع النص لعرض الـ ID
local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0.8, 0, 0.4, 0)
TextBox.Position = UDim2.new(0.1, 0, 0.1, 0)
TextBox.PlaceholderText = "ID الرقصة هنا"
TextBox.Text = ""

-- زر النسخ
local CopyButton = Instance.new("TextButton", Frame)
CopyButton.Size = UDim2.new(0.8, 0, 0.4, 0)
CopyButton.Position = UDim2.new(0.1, 0, 0.55, 0)
CopyButton.Text = "نسخ الـ ID"
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

-- دالة النسخ
CopyButton.MouseButton1Click:Connect(function()
    if TextBox.Text ~= "" then
        setclipboard(TextBox.Text)
        CopyButton.Text = "تم النسخ!"
        task.wait(1)
        CopyButton.Text = "نسخ الـ ID"
    end
end)

-- تحديث السكربت السابق لربطه بالواجهة
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

Humanoid.AnimationPlayed:Connect(function(animationTrack)
    local animation = animationTrack.Animation
    if animation then
        local animId = string.match(animation.AnimationId, "%d+")
        if animId then
            TextBox.Text = animId
        end
    end
end)
