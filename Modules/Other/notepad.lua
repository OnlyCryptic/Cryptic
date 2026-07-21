-- [[ Cryptic Hub – Misc v2: notepad (مذكرة متكاملة) ]]
-- المسار: Miscv2/notepad.lua
-- مفاتيح i18n: misc.notepad.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end
    local TweenService = game:GetService("TweenService")
    local StarterGui   = game:GetService("StarterGui")

    -- ── ثيم متوافق مع Cryptic Hub ─────────────────────────
    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)
    local WARN    = Color3.fromRGB(255, 200, 60)
    local DANGER  = Color3.fromRGB(255, 80, 80)
    local BG_DEEP = Color3.fromRGB(10, 11, 16)
    local BG      = Color3.fromRGB(16, 17, 23)
    local BG2     = Color3.fromRGB(20, 22, 30)
    local TEXT    = Color3.fromRGB(228, 232, 245)
    local MUTED   = Color3.fromRGB(110, 115, 135)

    local FILE_BODY  = "CrypticHub_Notepad_body.txt"
    local FILE_TITLE = "CrypticHub_Notepad_title.txt"

    -- ── أدوات مساعدة ─────────────────────────────────────
    local function tw(obj, props, t)
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            props
        ):Play()
    end

    local function Notify(txt)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "📝 " .. T("misc.notepad.title"),
                Text  = txt,
                Duration = 2,
            })
        end)
    end

    local function GradStroke(parent, thick, trans)
        local s = Instance.new("UIStroke", parent)
        s.Thickness    = thick  or 1.2
        s.Transparency = trans  or 0.45
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2),
        }
        g.Rotation = 45
        return s
    end

    local function Corner(parent, r)
        Instance.new("UICorner", parent).CornerRadius = UDim.new(0, r or 10)
    end

    -- ══════════════════════════════════════════════════════
    -- الحاوية الرئيسية (تُدرج في Tab.Page)
    -- ══════════════════════════════════════════════════════
    Tab.Order = Tab.Order + 1
    local Root = Instance.new("Frame", Tab.Page)
    Root.LayoutOrder          = Tab.Order
    Root.Size                 = UDim2.new(0.98, 0, 0, 370)
    Root.BackgroundColor3     = BG
    Root.BackgroundTransparency = 0.08
    Root.ClipsDescendants     = false
    Corner(Root, 12)
    GradStroke(Root, 1.3, 0.4)

    local RootPad = Instance.new("UIPadding", Root)
    RootPad.PaddingLeft   = UDim.new(0, 10)
    RootPad.PaddingRight  = UDim.new(0, 10)
    RootPad.PaddingTop    = UDim.new(0, 10)
    RootPad.PaddingBottom = UDim.new(0, 10)

    -- ── رأس المذكرة (أيقونة + عنوان ثابت) ───────────────
    local Header = Instance.new("Frame", Root)
    Header.Size               = UDim2.new(1, 0, 0, 26)
    Header.Position           = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1

    local IconLbl = Instance.new("TextLabel", Header)
    IconLbl.Size              = UDim2.new(0, 24, 1, 0)
    IconLbl.Position          = UDim2.new(0, 0, 0, 0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text              = "📝"
    IconLbl.TextSize          = 14
    IconLbl.Font              = Enum.Font.Gotham
    IconLbl.TextXAlignment    = Enum.TextXAlignment.Left

    local SectionLbl = Instance.new("TextLabel", Header)
    SectionLbl.Size           = UDim2.new(1, -28, 1, 0)
    SectionLbl.Position       = UDim2.new(0, 26, 0, 0)
    SectionLbl.BackgroundTransparency = 1
    SectionLbl.Text           = T("misc.notepad.title")
    SectionLbl.TextColor3     = ACCENT
    SectionLbl.Font           = Enum.Font.GothamBold
    SectionLbl.TextSize       = 12
    SectionLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- خط فاصل تحت الرأس
    local Divider = Instance.new("Frame", Root)
    Divider.Size              = UDim2.new(1, 0, 0, 1)
    Divider.Position          = UDim2.new(0, 0, 0, 30)
    Divider.BackgroundTransparency = 0.6
    local DivGrad = Instance.new("UIGradient", Divider)
    DivGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT2),
    }

    -- ── حقل العنوان ──────────────────────────────────────
    local TitleBG = Instance.new("Frame", Root)
    TitleBG.Size              = UDim2.new(1, 0, 0, 34)
    TitleBG.Position          = UDim2.new(0, 0, 0, 38)
    TitleBG.BackgroundColor3  = BG2
    TitleBG.BackgroundTransparency = 0.1
    Corner(TitleBG, 8)
    GradStroke(TitleBG, 1, 0.6)

    local TitleBox = Instance.new("TextBox", TitleBG)
    TitleBox.Size             = UDim2.new(1, -14, 1, 0)
    TitleBox.Position         = UDim2.new(0, 7, 0, 0)
    TitleBox.BackgroundTransparency = 1
    TitleBox.Text             = ""
    TitleBox.PlaceholderText  = T("misc.notepad.title_ph")
    TitleBox.TextColor3       = ACCENT
    TitleBox.PlaceholderColor3 = MUTED
    TitleBox.Font             = Enum.Font.GothamBold
    TitleBox.TextSize         = 12
    TitleBox.TextXAlignment   = Enum.TextXAlignment.Left
    TitleBox.ClearTextOnFocus = false

    -- ── منطقة النص الرئيسية ──────────────────────────────
    local TextBG = Instance.new("Frame", Root)
    TextBG.Size               = UDim2.new(1, 0, 0, 208)
    TextBG.Position           = UDim2.new(0, 0, 0, 80)
    TextBG.BackgroundColor3   = BG_DEEP
    TextBG.BackgroundTransparency = 0.05
    Corner(TextBG, 8)
    GradStroke(TextBG, 1, 0.55)

    -- شريط رقم الأسطر (ديكور)
    local GutterBG = Instance.new("Frame", TextBG)
    GutterBG.Size             = UDim2.new(0, 28, 1, -2)
    GutterBG.Position         = UDim2.new(0, 1, 0, 1)
    GutterBG.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
    GutterBG.BackgroundTransparency = 0.3
    GutterBG.ClipsDescendants = true
    Corner(GutterBG, 7)

    local GutterLine = Instance.new("Frame", GutterBG)
    GutterLine.Size           = UDim2.new(0, 1, 1, 0)
    GutterLine.Position       = UDim2.new(1, 0, 0, 0)
    GutterLine.BackgroundColor3 = ACCENT
    GutterLine.BackgroundTransparency = 0.7

    local NoteBox = Instance.new("TextBox", TextBG)
    NoteBox.Size              = UDim2.new(1, -38, 1, -10)
    NoteBox.Position          = UDim2.new(0, 34, 0, 5)
    NoteBox.BackgroundTransparency = 1
    NoteBox.Text              = ""
    NoteBox.PlaceholderText   = T("misc.notepad.placeholder")
    NoteBox.TextColor3        = TEXT
    NoteBox.PlaceholderColor3 = MUTED
    NoteBox.Font              = Enum.Font.Code
    NoteBox.TextSize          = 12
    NoteBox.TextXAlignment    = Enum.TextXAlignment.Left
    NoteBox.TextYAlignment    = Enum.TextYAlignment.Top
    NoteBox.TextWrapped       = true
    NoteBox.MultiLine         = true
    NoteBox.ClearTextOnFocus  = false

    -- ── شريط الإحصاءات ───────────────────────────────────
    local StatsRow = Instance.new("Frame", Root)
    StatsRow.Size             = UDim2.new(1, 0, 0, 20)
    StatsRow.Position         = UDim2.new(0, 0, 0, 294)
    StatsRow.BackgroundTransparency = 1

    local CharLbl = Instance.new("TextLabel", StatsRow)
    CharLbl.Size              = UDim2.new(0.5, 0, 1, 0)
    CharLbl.BackgroundTransparency = 1
    CharLbl.Text              = "0 " .. T("misc.notepad.chars")
    CharLbl.TextColor3        = MUTED
    CharLbl.Font              = Enum.Font.Gotham
    CharLbl.TextSize          = 10
    CharLbl.TextXAlignment    = Enum.TextXAlignment.Left

    local WordLbl = Instance.new("TextLabel", StatsRow)
    WordLbl.Size              = UDim2.new(0.5, 0, 1, 0)
    WordLbl.Position          = UDim2.new(0.5, 0, 0, 0)
    WordLbl.BackgroundTransparency = 1
    WordLbl.Text              = "0 " .. T("misc.notepad.words")
    WordLbl.TextColor3        = MUTED
    WordLbl.Font              = Enum.Font.Gotham
    WordLbl.TextSize          = 10
    WordLbl.TextXAlignment    = Enum.TextXAlignment.Right

    -- تحديث الإحصاءات لحظياً
    NoteBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt   = NoteBox.Text
        local chars = #txt
        local words = 0
        for _ in txt:gmatch("%S+") do words = words + 1 end
        CharLbl.Text = tostring(chars) .. " " .. T("misc.notepad.chars")
        WordLbl.Text = tostring(words) .. " " .. T("misc.notepad.words")
    end)

    -- ── صف الأزرار ───────────────────────────────────────
    local BtnRow = Instance.new("Frame", Root)
    BtnRow.Size               = UDim2.new(1, 0, 0, 38)
    BtnRow.Position           = UDim2.new(0, 0, 0, 320)
    BtnRow.BackgroundTransparency = 1

    local BtnLayout = Instance.new("UIListLayout", BtnRow)
    BtnLayout.FillDirection       = Enum.FillDirection.Horizontal
    BtnLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    BtnLayout.Padding             = UDim.new(0, 6)
    BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BtnLayout.VerticalAlignment   = Enum.VerticalAlignment.Center

    local function MakeBtn(label, color, order, onClick)
        local Btn = Instance.new("TextButton", BtnRow)
        Btn.LayoutOrder          = order
        Btn.Size                 = UDim2.new(0, 72, 0, 34)
        Btn.BackgroundColor3     = Color3.fromRGB(18, 20, 28)
        Btn.BackgroundTransparency = 0.05
        Btn.AutoButtonColor      = false
        Btn.Text                 = label
        Btn.TextColor3           = color
        Btn.Font                 = Enum.Font.GothamBold
        Btn.TextSize             = 10
        Btn.TextWrapped          = false
        Corner(Btn, 8)

        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color             = color
        Stroke.Thickness         = 1.2
        Stroke.Transparency      = 0.5

        Btn.MouseEnter:Connect(function()
            tw(Btn,   {BackgroundTransparency = 0,   BackgroundColor3 = Color3.fromRGB(22, 26, 38)}, 0.12)
            tw(Stroke, {Transparency = 0.1}, 0.12)
        end)
        Btn.MouseLeave:Connect(function()
            tw(Btn,   {BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(18, 20, 28)}, 0.12)
            tw(Stroke, {Transparency = 0.5}, 0.12)
        end)
        Btn.MouseButton1Click:Connect(function()
            tw(Btn, {BackgroundColor3 = Color3.fromRGB(30, 35, 50)}, 0.07)
            task.delay(0.14, function()
                tw(Btn, {BackgroundColor3 = Color3.fromRGB(18, 20, 28)}, 0.12)
            end)
            pcall(onClick)
        end)
        return Btn
    end

    -- 💾 حفظ
    MakeBtn(T("misc.notepad.save"), ACCENT, 1, function()
        local saved = false
        pcall(function()
            if writefile then
                writefile(FILE_BODY,  NoteBox.Text)
                writefile(FILE_TITLE, TitleBox.Text)
                saved = true
            end
        end)
        Notify(saved and T("misc.notepad.saved") or T("misc.notepad.no_save"))
    end)

    -- 📂 تحميل
    MakeBtn(T("misc.notepad.load"), ACCENT2, 2, function()
        pcall(function()
            if readfile then
                local okB, body  = pcall(readfile, FILE_BODY)
                local okT, title = pcall(readfile, FILE_TITLE)
                if okB and type(body)  == "string" then NoteBox.Text  = body  end
                if okT and type(title) == "string" then TitleBox.Text = title end
                if okB then Notify(T("misc.notepad.loaded")) end
            end
        end)
    end)

    -- 🗑️ مسح
    MakeBtn(T("misc.notepad.clear"), DANGER, 3, function()
        NoteBox.Text  = ""
        TitleBox.Text = ""
        Notify(T("misc.notepad.cleared"))
    end)

    -- 📋 نسخ
    MakeBtn(T("misc.notepad.copy"), WARN, 4, function()
        pcall(function()
            if setclipboard then
                local content = (TitleBox.Text ~= "" and (TitleBox.Text .. "\n\n") or "") .. NoteBox.Text
                setclipboard(content)
                Notify(T("misc.notepad.copied"))
            end
        end)
    end)

    -- ── تحميل تلقائي عند فتح المذكرة ─────────────────────
    task.spawn(function()
        task.wait(0.3)
        pcall(function()
            if readfile then
                local okB, body  = pcall(readfile, FILE_BODY)
                local okT, title = pcall(readfile, FILE_TITLE)
                if okB and type(body)  == "string" and body  ~= "" then NoteBox.Text  = body  end
                if okT and type(title) == "string" and title ~= "" then TitleBox.Text = title end
            end
        end)
    end)
end
