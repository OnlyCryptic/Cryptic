-- [[ Cryptic Hub - نظام المحادثة المتطور ]]
-- رسائل اللاعب + ردود المطور بالترتيب الزمني مع صور

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local lp = Players.LocalPlayer

    local WORKER_URL = "https://cryptic-chat.bossekasiri2.workers.dev"
    local SECRET_KEY = "CRYPTIC_SECRET_2025"
    local REPLIES_URL = "https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/replies.json"

    local userMessage = ""
    local lastMessageCount = 0
    local notifDot = nil
    local chatGui = nil
    local isOpen = false

    -- ==============================
    -- دالة طلب HTTP
    -- ==============================
    local function HttpRequest(method, path, body)
        local HttpReq = (request or http_request or syn and syn.request)
        if not HttpReq then return nil end
        local ok, res = pcall(function()
            return HttpReq({
                Url = WORKER_URL .. path,
                Method = method,
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["X-Cryptic-Key"] = SECRET_KEY
                },
                Body = body and game:GetService("HttpService"):JSONEncode(body) or nil
            })
        end)
        if ok and res and res.Body then
            local sok, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(res.Body)
            end)
            if sok then return data end
        end
        return nil
    end

    -- ==============================
    -- جلب الردود من GitHub
    -- ==============================
    local function FetchReplies()
        local ok, raw = pcall(game.HttpGet, game, REPLIES_URL .. "?v=" .. tick())
        if ok and raw then
            local sok, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(raw)
            end)
            if sok and type(data) == "table" then return data end
        end
        return {}
    end

    -- ==============================
    -- تنسيق الوقت
    -- ==============================
    local function FormatTime(iso)
        if not iso then return "" end
        -- iso: 2025-01-01T22:30:00.000Z
        local h, m = iso:match("T(%d+):(%d+)")
        if h and m then
            local hour = tonumber(h)
            local ampm = hour >= 12 and "PM" or "AM"
            hour = hour % 12
            if hour == 0 then hour = 12 end
            return string.format("%d:%s %s", hour, m, ampm)
        end
        return ""
    end

    -- ==============================
    -- بناء واجهة الشات
    -- ==============================
    local function BuildChatUI()
        if chatGui then chatGui:Destroy() end

        chatGui = Instance.new("ScreenGui")
        chatGui.Name = "CrypticChatUI"
        chatGui.ResetOnSpawn = false
        pcall(function() chatGui.Parent = CoreGui end)
        if not chatGui.Parent then chatGui.Parent = lp:WaitForChild("PlayerGui") end

        -- الخلفية الداكنة
        local bg = Instance.new("Frame", chatGui)
        bg.Size = UDim2.new(0, 340, 0, 480)
        bg.Position = UDim2.new(0.5, -170, 0.5, -240)
        bg.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
        bg.BackgroundTransparency = 0.05
        bg.Active = true
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
        local bgStroke = Instance.new("UIStroke", bg)
        bgStroke.Thickness = 1.2
        local bgGrad = Instance.new("UIGradient", bgStroke)
        bgGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        }

        -- هيدر
        local header = Instance.new("Frame", bg)
        header.Size = UDim2.new(1, 0, 0, 44)
        header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        header.BackgroundTransparency = 0.2
        header.BorderSizePixel = 0
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

        local headerLine = Instance.new("Frame", header)
        headerLine.Size = UDim2.new(1, 0, 0, 2)
        headerLine.Position = UDim2.new(0, 0, 1, -2)
        headerLine.BorderSizePixel = 0
        local hlGrad = Instance.new("UIGradient", headerLine)
        hlGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        }

        local headerTitle = Instance.new("TextLabel", header)
        headerTitle.Text = "💬 المحادثة / Chat"
        headerTitle.Size = UDim2.new(1, -50, 1, 0)
        headerTitle.Position = UDim2.new(0, 12, 0, 0)
        headerTitle.BackgroundTransparency = 1
        headerTitle.TextColor3 = Color3.new(1, 1, 1)
        headerTitle.Font = Enum.Font.GothamBold
        headerTitle.TextSize = 13
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton", header)
        closeBtn.Text = "✕"
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
        closeBtn.BackgroundTransparency = 1
        closeBtn.TextColor3 = Color3.fromRGB(200, 75, 75)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 16
        closeBtn.MouseButton1Click:Connect(function()
            isOpen = false
            TweenService:Create(bg, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            chatGui:Destroy()
            chatGui = nil
        end)

        -- منطقة الرسائل
        local msgArea = Instance.new("ScrollingFrame", bg)
        msgArea.Position = UDim2.new(0, 8, 0, 50)
        msgArea.Size = UDim2.new(1, -16, 1, -110)
        msgArea.BackgroundTransparency = 1
        msgArea.ScrollBarThickness = 3
        msgArea.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
        msgArea.CanvasSize = UDim2.new(0, 0, 0, 0)
        local msgLayout = Instance.new("UIListLayout", msgArea)
        msgLayout.Padding = UDim.new(0, 8)
        msgLayout.SortOrder = Enum.SortOrder.LayoutOrder
        msgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            msgArea.CanvasSize = UDim2.new(0, 0, 0, msgLayout.AbsoluteContentSize.Y + 16)
            msgArea.CanvasPosition = Vector2.new(0, math.huge)
        end)

        -- منطقة الكتابة
        local inputArea = Instance.new("Frame", bg)
        inputArea.Size = UDim2.new(1, -16, 0, 50)
        inputArea.Position = UDim2.new(0, 8, 1, -58)
        inputArea.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        inputArea.BackgroundTransparency = 0.3
        Instance.new("UICorner", inputArea).CornerRadius = UDim.new(0, 8)

        local textBox = Instance.new("TextBox", inputArea)
        textBox.Size = UDim2.new(1, -60, 1, -10)
        textBox.Position = UDim2.new(0, 8, 0, 5)
        textBox.BackgroundTransparency = 1
        textBox.TextColor3 = Color3.new(1, 1, 1)
        textBox.PlaceholderText = "اكتب رسالتك... / Type here..."
        textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 12
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextWrapped = true
        textBox.ClearTextOnFocus = false
        textBox.Text = ""

        local sendBtn = Instance.new("TextButton", inputArea)
        sendBtn.Size = UDim2.new(0, 44, 0, 34)
        sendBtn.Position = UDim2.new(1, -50, 0.5, -17)
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        sendBtn.Text = "↑"
        sendBtn.TextColor3 = Color3.new(1, 1, 1)
        sendBtn.Font = Enum.Font.GothamBold
        sendBtn.TextSize = 18
        Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 8)

        -- ==============================
        -- دالة إضافة رسالة للواجهة
        -- ==============================
        local function AddMessage(msgData, order)
            local isPlayer = msgData.type == "player"
            local isMe = msgData.playerName == lp.Name

            local row = Instance.new("Frame", msgArea)
            row.LayoutOrder = order
            row.Size = UDim2.new(1, 0, 0, 64)
            row.BackgroundTransparency = 1

            -- صورة اللاعب (فقط لرسائل اللاعبين)
            if isPlayer then
                local avatarFrame = Instance.new("Frame", row)
                avatarFrame.Size = UDim2.new(0, 40, 0, 40)
                avatarFrame.Position = UDim2.new(0, 0, 0, 4)
                avatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

                -- تحميل الصورة
                local img = Instance.new("ImageLabel", avatarFrame)
                img.Size = UDim2.new(1, 0, 1, 0)
                img.BackgroundTransparency = 1
                img.Image = msgData.avatar or ""
                img.ScaleType = Enum.ScaleType.Crop
                Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
            end

            -- اسم اللاعب أو "المطور"
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Position = isPlayer and UDim2.new(0, 48, 0, 0) or UDim2.new(0, 0, 0, 0)
            nameLbl.Size = UDim2.new(1, -48, 0, 18)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = isPlayer and (msgData.displayName or msgData.playerName) or "👑 المطور / Dev"
            nameLbl.TextColor3 = isPlayer and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(0, 255, 150)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 11
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            -- نص الرسالة
            local msgBubble = Instance.new("Frame", row)
            msgBubble.Position = isPlayer and UDim2.new(0, 48, 0, 20) or UDim2.new(0, 0, 0, 20)
            msgBubble.Size = UDim2.new(0.85, 0, 0, 32)
            msgBubble.BackgroundColor3 = isPlayer and Color3.fromRGB(25, 25, 32) or Color3.fromRGB(0, 60, 40)
            msgBubble.BackgroundTransparency = 0.3
            Instance.new("UICorner", msgBubble).CornerRadius = UDim.new(0, 8)

            local msgLbl = Instance.new("TextLabel", msgBubble)
            msgLbl.Size = UDim2.new(1, -8, 1, 0)
            msgLbl.Position = UDim2.new(0, 6, 0, 0)
            msgLbl.BackgroundTransparency = 1
            msgLbl.Text = msgData.message or ""
            msgLbl.TextColor3 = Color3.new(1, 1, 1)
            msgLbl.Font = Enum.Font.Gotham
            msgLbl.TextSize = 11
            msgLbl.TextXAlignment = Enum.TextXAlignment.Left
            msgLbl.TextWrapped = true

            -- الوقت
            local timeLbl = Instance.new("TextLabel", row)
            timeLbl.Position = UDim2.new(1, -50, 0, 0)
            timeLbl.Size = UDim2.new(0, 50, 0, 18)
            timeLbl.BackgroundTransparency = 1
            timeLbl.Text = FormatTime(msgData.timestamp)
            timeLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
            timeLbl.Font = Enum.Font.Gotham
            timeLbl.TextSize = 9
            timeLbl.TextXAlignment = Enum.TextXAlignment.Right

            -- ضبط حجم الـ row حسب طول الرسالة
            local textLen = string.len(msgData.message or "")
            local extraH = math.floor(textLen / 35) * 14
            row.Size = UDim2.new(1, 0, 0, 68 + extraH)
            msgBubble.Size = UDim2.new(0.85, 0, 0, 32 + extraH)
        end

        -- ==============================
        -- تحميل الرسائل
        -- ==============================
        local function LoadMessages()
            -- مسح الرسائل القديمة
            for _, c in pairs(msgArea:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end

            task.spawn(function()
                -- جلب رسائل اللاعب من Worker
                local playerMsgs = HttpRequest("GET", "/messages") or {}
                -- جلب ردود المطور من GitHub
                local devReplies = FetchReplies()

                -- دمج الكل في قائمة وحدة
                local allMessages = {}
                for _, m in ipairs(playerMsgs) do
                    if m.playerName == lp.Name then
                        table.insert(allMessages, m)
                    end
                end
                for _, r in ipairs(devReplies) do
                    if r.to == lp.Name then
                        table.insert(allMessages, {
                            type = "dev",
                            message = r.msg,
                            timestamp = r.timestamp or "",
                            displayName = "المطور"
                        })
                    end
                end

                -- ترتيب حسب الوقت
                table.sort(allMessages, function(a, b)
                    return (a.timestamp or "") < (b.timestamp or "")
                end)

                -- عرض الرسائل
                for i, m in ipairs(allMessages) do
                    AddMessage(m, i)
                end

                -- تعليم كمقروء
                HttpRequest("POST", "/markread", { playerName = lp.Name })
            end)
        end

        -- ==============================
        -- إرسال رسالة
        -- ==============================
        local function SendMessage()
            local msg = textBox.Text
            if not msg or string.len(msg) < 2 then return end

            textBox.Text = ""
            sendBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

            task.spawn(function()
                local result = HttpRequest("POST", "/send", {
                    playerName = lp.Name,
                    displayName = lp.DisplayName,
                    userId = lp.UserId,
                    message = msg
                })

                if result and result.success then
                    -- إضافة الرسالة فوراً للواجهة
                    local count = 0
                    for _, c in pairs(msgArea:GetChildren()) do
                        if c:IsA("Frame") then count = count + 1 end
                    end
                    AddMessage({
                        type = "player",
                        playerName = lp.Name,
                        displayName = lp.DisplayName,
                        avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=150&height=150&format=png",
                        message = msg,
                        timestamp = DateTime.now():ToIsoDate()
                    }, count + 1)

                    -- إرسال للـ webhook
                    if getgenv().CrypticLog then
                        getgenv().CrypticLog("OnSuggestion", "💬 رسالة جديدة من " .. lp.DisplayName, 16766720, {
                            {name = "📝 الرسالة:", value = msg, inline = false}
                        })
                    end
                else
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "Cryptic Hub ❌",
                            Text = "فشل الإرسال، حاول مرة ثانية.\nFailed to send.",
                            Duration = 3
                        })
                    end)
                end

                sendBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
            end)
        end

        sendBtn.MouseButton1Click:Connect(SendMessage)
        textBox.FocusLost:Connect(function(enter)
            if enter then SendMessage() end
        end)

        LoadMessages()
        return msgArea
    end

    -- ==============================
    -- نقطة الإشعار الحمراء
    -- ==============================
    local function CheckNewMessages()
        task.spawn(function()
            while true do
                task.wait(30) -- فحص كل 30 ثانية
                if not isOpen then
                    local msgs = HttpRequest("GET", "/messages")
                    if msgs then
                        local unread = 0
                        for _, m in ipairs(msgs) do
                            if m.playerName == lp.Name and not m.read then
                                unread = unread + 1
                            end
                        end
                        -- فحص ردود جديدة من GitHub
                        local replies = FetchReplies()
                        for _, r in ipairs(replies) do
                            if r.to == lp.Name and not r.read then
                                unread = unread + 1
                            end
                        end
                        if unread > 0 and notifDot then
                            notifDot.Visible = true
                        end
                    end
                end
            end
        end)
    end

    -- ==============================
    -- الواجهة الرئيسية في التاب
    -- ==============================
    Tab:AddParagraph(
        "💬 المحادثة مع المطور / Chat with Dev",
        "اكتب رسالتك أو اقتراحك وسيرد عليك المطور مباشرة.\nSend your message and the developer will reply."
    )

    Tab:AddLine()

    -- زر فتح المحادثة مع نقطة إشعار
    local openBtn = Tab:AddButton("💬 فتح المحادثة / Open Chat", function()
        if isOpen then return end
        isOpen = true
        if notifDot then notifDot.Visible = false end
        BuildChatUI()
    end)

    -- نقطة حمراء للإشعار (نحطها على الزر)
    task.spawn(function()
        task.wait(1)
        -- نبحث عن زر الاقتراحات في الـ Tab ونضيف نقطة حمراء
        if openBtn and openBtn.Parent then
            notifDot = Instance.new("Frame", openBtn.Parent)
            notifDot.Size = UDim2.new(0, 10, 0, 10)
            notifDot.Position = UDim2.new(1, -18, 0, 8)
            notifDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            notifDot.BackgroundTransparency = 0
            notifDot.Visible = false
            Instance.new("UICorner", notifDot).CornerRadius = UDim.new(1, 0)
            local pulse = Instance.new("UIStroke", notifDot)
            pulse.Color = Color3.fromRGB(255, 100, 100)
            pulse.Thickness = 1.5
        end
    end)

    CheckNewMessages()
end
