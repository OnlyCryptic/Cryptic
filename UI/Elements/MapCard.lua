-- [[ Cryptic Hub - Element: MapCard ]]
-- سكربتات الماب: ترجمة + تشغيل تلقائي + إضافة سكربت مخصص (＋)

return function(TabOps, mapData)
    local TweenService = game:GetService("TweenService")
    local StarterGui   = game:GetService("StarterGui")
    local HttpService  = game:GetService("HttpService")
    local Players      = game:GetService("Players")
    local env          = getgenv()
    local lp           = Players.LocalPlayer
    local FOLDER       = "Cryptic"
    local FILE         = FOLDER .. "/MapCustomScripts.json" -- سكربتات الماب المخصصة + التشغيل التلقائي

    -- ============ الترجمات ============
    local L = {
        en = {run="Run", auto="Auto", add="Add custom script", name="Script name", paste="Paste script here...", save="Save", cancel="Cancel", empty="Enter a name and a script", running="Running script...", err="Error", autoon="Auto-run ON", autooff="Auto-run OFF", log="Map script", logk="Script:"},
        ar = {run="تشغيل", auto="تلقائي", add="إضافة سكربت مخصص", name="اسم السكربت", paste="الصق السكربت هنا...", save="حفظ", cancel="إلغاء", empty="اكتب الاسم والسكربت", running="جاري تشغيل السكربت...", err="خطأ", autoon="التشغيل التلقائي مفعّل", autooff="التشغيل التلقائي متوقف", log="ماب سكربت", logk="السكربت:"},
        ru = {run="Запуск", auto="Авто", add="Добавить свой скрипт", name="Название скрипта", paste="Вставьте скрипт сюда...", save="Сохранить", cancel="Отмена", empty="Введите название и скрипт", running="Запуск скрипта...", err="Ошибка", autoon="Автозапуск вкл", autooff="Автозапуск выкл", log="Скрипт карты", logk="Скрипт:"},
        pt = {run="Executar", auto="Auto", add="Adicionar script próprio", name="Nome do script", paste="Cole o script aqui...", save="Salvar", cancel="Cancelar", empty="Digite nome e script", running="Executando script...", err="Erro", autoon="Auto ligado", autooff="Auto desligado", log="Script do mapa", logk="Script:"},
        es = {run="Ejecutar", auto="Auto", add="Añadir script propio", name="Nombre del script", paste="Pega el script aquí...", save="Guardar", cancel="Cancelar", empty="Escribe nombre y script", running="Ejecutando script...", err="Error", autoon="Auto activado", autooff="Auto desactivado", log="Script de mapa", logk="Script:"},
        fr = {run="Lancer", auto="Auto", add="Ajouter un script perso", name="Nom du script", paste="Collez le script ici...", save="Enregistrer", cancel="Annuler", empty="Entrez un nom et un script", running="Lancement du script...", err="Erreur", autoon="Auto activé", autooff="Auto désactivé", log="Script de map", logk="Script :"},
        id = {run="Jalankan", auto="Otomatis", add="Tambah skrip sendiri", name="Nama skrip", paste="Tempel skrip di sini...", save="Simpan", cancel="Batal", empty="Isi nama dan skrip", running="Menjalankan skrip...", err="Kesalahan", autoon="Otomatis aktif", autooff="Otomatis mati", log="Skrip map", logk="Skrip:"},
        fil = {run="Patakbuhin", auto="Auto", add="Magdagdag ng custom script", name="Pangalan ng script", paste="I-paste ang script dito...", save="I-save", cancel="Kanselahin", empty="Maglagay ng pangalan at script", running="Pinapatakbo ang script...", err="Error", autoon="Auto-run naka-ON", autooff="Auto-run naka-OFF", log="Map script", logk="Script:"},
        tr = {run="Çalıştır", auto="Otomatik", add="Özel script ekle", name="Script adı", paste="Scripti buraya yapıştır...", save="Kaydet", cancel="İptal", empty="Ad ve script gir", running="Script çalışıyor...", err="Hata", autoon="Otomatik açık", autooff="Otomatik kapalı", log="Harita scripti", logk="Script:"},
        hi = {run="चलाएँ", auto="ऑटो", add="कस्टम स्क्रिप्ट जोड़ें", name="स्क्रिप्ट का नाम", paste="स्क्रिप्ट यहाँ पेस्ट करें...", save="सेव करें", cancel="रद्द करें", empty="नाम और स्क्रिप्ट दर्ज करें", running="स्क्रिप्ट चल रही है...", err="त्रुटि", autoon="ऑटो-रन चालू", autooff="ऑटो-रन बंद", log="मैप स्क्रिप्ट", logk="स्क्रिप्ट:"},
        de = {run="Starten", auto="Auto", add="Eigenes Skript hinzufügen", name="Skriptname", paste="Skript hier einfügen...", save="Speichern", cancel="Abbrechen", empty="Name und Skript eingeben", running="Skript läuft...", err="Fehler", autoon="Auto an", autooff="Auto aus", log="Map-Skript", logk="Skript:"},
        nl = {run="Uitvoeren", auto="Auto", add="Eigen script toevoegen", name="Scriptnaam", paste="Plak het script hier...", save="Opslaan", cancel="Annuleren", empty="Voer naam en script in", running="Script wordt uitgevoerd...", err="Fout", autoon="Auto-run aan", autooff="Auto-run uit", log="Map-script", logk="Script:"},
        pl = {run="Uruchom", auto="Auto", add="Dodaj własny skrypt", name="Nazwa skryptu", paste="Wklej skrypt tutaj...", save="Zapisz", cancel="Anuluj", empty="Wpisz nazwę i skrypt", running="Uruchamianie skryptu...", err="Błąd", autoon="Autostart włączony", autooff="Autostart wyłączony", log="Skrypt mapy", logk="Skrypt:"},
        uk = {run="Запуск", auto="Авто", add="Додати свій скрипт", name="Назва скрипта", paste="Вставте скрипт сюди...", save="Зберегти", cancel="Скасувати", empty="Введіть назву та скрипт", running="Запуск скрипта...", err="Помилка", autoon="Автозапуск увімк.", autooff="Автозапуск вимк.", log="Скрипт мапи", logk="Скрипт:"},
        it = {run="Esegui", auto="Auto", add="Aggiungi script personale", name="Nome dello script", paste="Incolla lo script qui...", save="Salva", cancel="Annulla", empty="Inserisci nome e script", running="Esecuzione script...", err="Errore", autoon="Auto attivo", autooff="Auto disattivo", log="Script mappa", logk="Script:"},
        vi = {run="Chạy", auto="Tự động", add="Thêm script riêng", name="Tên script", paste="Dán script vào đây...", save="Lưu", cancel="Hủy", empty="Nhập tên và script", running="Đang chạy script...", err="Lỗi", autoon="Tự động chạy: BẬT", autooff="Tự động chạy: TẮT", log="Script map", logk="Script:"},
        th = {run="เรียกใช้", auto="อัตโนมัติ", add="เพิ่มสคริปต์ของคุณ", name="ชื่อสคริปต์", paste="วางสคริปต์ที่นี่...", save="บันทึก", cancel="ยกเลิก", empty="ใส่ชื่อและสคริปต์", running="กำลังรันสคริปต์...", err="ข้อผิดพลาด", autoon="เปิดรันอัตโนมัติ", autooff="ปิดรันอัตโนมัติ", log="สคริปต์แมพ", logk="สคริปต์:"},
        zh = {run="运行", auto="自动", add="添加自定义脚本", name="脚本名称", paste="在此粘贴脚本...", save="保存", cancel="取消", empty="请输入名称和脚本", running="正在运行脚本...", err="错误", autoon="自动运行已开启", autooff="自动运行已关闭", log="地图脚本", logk="脚本:"},
        tw = {run="執行", auto="自動", add="新增自訂腳本", name="腳本名稱", paste="在此貼上腳本...", save="儲存", cancel="取消", empty="請輸入名稱和腳本", running="正在執行腳本...", err="錯誤", autoon="自動執行已開啟", autooff="自動執行已關閉", log="地圖腳本", logk="腳本:"},
        ko = {run="실행", auto="자동", add="커스텀 스크립트 추가", name="스크립트 이름", paste="여기에 스크립트를 붙여넣기...", save="저장", cancel="취소", empty="이름과 스크립트를 입력하세요", running="스크립트 실행 중...", err="오류", autoon="자동 실행 켜짐", autooff="자동 실행 꺼짐", log="맵 스크립트", logk="스크립트:"},
        ja = {run="実行", auto="自動", add="カスタムスクリプトを追加", name="スクリプト名", paste="ここにスクリプトを貼り付け...", save="保存", cancel="キャンセル", empty="名前とスクリプトを入力", running="スクリプトを実行中...", err="エラー", autoon="自動実行オン", autooff="自動実行オフ", log="マップスクリプト", logk="スクリプト:"},
    }

    local function TT(k)
        local i = env.CrypticI18n
        if i and i.T then -- لو أضفت المفتاح map.<k> في i18n يستخدمه أول
            local ok, v = pcall(i.T, "map." .. k)
            if ok and type(v) == "string" and v ~= "map." .. k then return v end
        end
        local c = "en"
        if i and i.Get then pcall(function() c = tostring(i.Get()) end) end
        c = c:lower()
        local t = L[c] or L[c:sub(1, 2)] or L.en
        return t[k] or L.en[k]
    end

    -- ============ التخزين ============
    pcall(function() if not isfolder(FOLDER) then makefolder(FOLDER) end end)

    local function loadData()
        local ok, d = pcall(function()
            if isfile(FILE) then return HttpService:JSONDecode(readfile(FILE)) end
        end)
        if not ok or type(d) ~= "table" then d = {} end
        d.auto = d.auto or {}; d.custom = d.custom or {}
        return d
    end
    local function saveData(d)
        pcall(function() if not isfolder(FOLDER) then makefolder(FOLDER) end end)
        pcall(writefile, FILE, HttpService:JSONEncode(d))
    end

    local gid  = tostring(game.GameId)
    local data = loadData()
    data.auto[gid]   = data.auto[gid] or {}
    data.custom[gid] = data.custom[gid] or {}

    -- ============ أدوات ============
    local GREEN, GREEN_H, GREEN_D = Color3.fromRGB(0,150,78), Color3.fromRGB(0,190,100), Color3.fromRGB(0,100,50)
    local ROW, DARK, GRAY, RED = Color3.fromRGB(22,22,28), Color3.fromRGB(14,14,18), Color3.fromRGB(48,48,56), Color3.fromRGB(170,45,55)

    local function Tween(inst, props, t)
        TweenService:Create(inst, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
    local function Notify(title, text, dur)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 4}) end)
    end
    local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
    end
    local function round(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r or 7)}, o) end
    local function hover(btn, base, over)
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = over}, 0.15) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = base}, 0.2) end)
    end

    local function Exec(entry)
        Notify("🚀 " .. entry.Name, TT("running"), 3)
        task.spawn(function()
            local code = entry.Script
            if type(code) == "string" and code:match("^%s*https?://[^%s]+%s*$") then
                code = 'loadstring(game:HttpGet("' .. code:gsub("%s", "") .. '"))()'
            end
            local ok, err = pcall(function()
                local f, perr = loadstring(code)
                if not f then error(perr) end
                f()
            end)
            if not ok then Notify("⚠️ " .. TT("err"), tostring(err), 6) end
        end)
        if TabOps.LogAction then
            pcall(TabOps.LogAction, "🗺️ " .. TT("log"), TT("logk"), entry.Name .. " | " .. tostring(mapData.Name), 65430)
        end
    end

    -- ============ الحاوية ============
    local builtin = mapData.Scripts or {{Name = mapData.Name, Script = mapData.Script}}
    TabOps.Order = TabOps.Order + 1
    local root = mk("Frame", {LayoutOrder = TabOps.Order, Size = UDim2.new(0.97,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, TabOps.Page)
    mk("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, root)

    -- زر ＋
    local addBtn = mk("TextButton", {LayoutOrder = 0, Size = UDim2.new(1,0,0,38), BackgroundColor3 = ROW, BorderSizePixel = 0, AutoButtonColor = false,
        Text = "＋  " .. TT("add"), TextColor3 = Color3.fromRGB(0,210,110), Font = Enum.Font.GothamBold, TextSize = 13}, root)
    round(addBtn); hover(addBtn, ROW, Color3.fromRGB(30,30,38))

    -- نموذج الإضافة
    local form = mk("Frame", {LayoutOrder = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, BorderSizePixel = 0, Visible = false}, root)
    round(form)
    mk("UIPadding", {PaddingTop = UDim.new(0,8), PaddingBottom = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}, form)
    mk("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, form)

    local function box(h, ph, multi, order)
        local b = mk("TextBox", {LayoutOrder = order, Size = UDim2.new(1,0,0,h), BackgroundColor3 = DARK, BorderSizePixel = 0,
            TextColor3 = Color3.new(1,1,1), PlaceholderText = ph, PlaceholderColor3 = Color3.fromRGB(120,120,130), Text = "",
            Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, MultiLine = multi, TextWrapped = multi,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            ClipsDescendants = true}, form)
        round(b, 6)
        mk("UIPadding", {PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,6)}, b)
        return b
    end
    local nameBox = box(32, TT("name"), false, 1)
    local codeBox = box(90, TT("paste"), true, 2)

    local btns = mk("Frame", {LayoutOrder = 3, Size = UDim2.new(1,0,0,32), BackgroundTransparency = 1}, form)
    local saveB = mk("TextButton", {Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = GREEN, BorderSizePixel = 0, Text = TT("save"),
        TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12}, btns)
    local cancelB = mk("TextButton", {Position = UDim2.new(0.5,3,0,0), Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = GRAY, BorderSizePixel = 0,
        Text = TT("cancel"), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12}, btns)
    round(saveB, 6); round(cancelB, 6)
    hover(saveB, GREEN, GREEN_H); hover(cancelB, GRAY, Color3.fromRGB(65,65,75))

    local list = mk("Frame", {LayoutOrder = 2, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, root)
    mk("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    -- ============ الصفوف ============
    local refresh
    local function addRow(entry, key, order, customIdx)
        local Row = mk("Frame", {LayoutOrder = order, Size = UDim2.new(1,0,0,42), BackgroundColor3 = ROW, BorderSizePixel = 0}, list)
        round(Row)
        local right = 8

        if customIdx then
            local del = mk("TextButton", {AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-right,0.5,0), Size = UDim2.new(0,28,0,28),
                BackgroundColor3 = RED, BorderSizePixel = 0, Text = "✕", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12}, Row)
            round(del, 6)
            del.MouseButton1Click:Connect(function()
                table.remove(data.custom[gid], customIdx)
                data.auto[gid][key] = nil
                saveData(data); refresh()
            end)
            right = right + 34
        end

        local RunBtn = mk("TextButton", {AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-right,0.5,0), Size = UDim2.new(0,92,0,28),
            BackgroundColor3 = GREEN, BorderSizePixel = 0, Text = "▶  " .. TT("run"), TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold, TextSize = 12}, Row)
        round(RunBtn, 6); hover(RunBtn, GREEN, GREEN_H)
        RunBtn.MouseButton1Click:Connect(function()
            Tween(RunBtn, {BackgroundColor3 = GREEN_D}, 0.08)
            task.delay(0.12, function() Tween(RunBtn, {BackgroundColor3 = GREEN}, 0.15) end)
            Exec(entry)
        end)
        right = right + 98

        local AutoBtn = mk("TextButton", {AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-right,0.5,0), Size = UDim2.new(0,78,0,28),
            BorderSizePixel = 0, Font = Enum.Font.GothamSemibold, TextSize = 11}, Row)
        round(AutoBtn, 6)
        local function paint()
            local on = data.auto[gid][key] == true
            AutoBtn.Text = (on and "● " or "○ ") .. TT("auto")
            AutoBtn.BackgroundColor3 = on and Color3.fromRGB(18,80,55) or GRAY
            AutoBtn.TextColor3 = on and Color3.fromRGB(120,255,190) or Color3.fromRGB(160,160,170)
        end
        paint()
        AutoBtn.MouseButton1Click:Connect(function()
            local on = not (data.auto[gid][key] == true)
            data.auto[gid][key] = on or nil
            saveData(data); paint()
            Notify(entry.Name, on and TT("autoon") or TT("autooff"), 3)
        end)
        right = right + 84

        mk("TextLabel", {Size = UDim2.new(1,-(right+12),1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = entry.Name,
            TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd}, Row)
    end

    local function customEntries()
        local out = {}
        for i, c in ipairs(data.custom[gid]) do
            table.insert(out, {Name = c.name, Script = c.code, _key = "c:" .. c.name, _i = i})
        end
        return out
    end

    refresh = function()
        for _, ch in ipairs(list:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
        local n = 0
        for _, e in ipairs(builtin) do n += 1; addRow(e, "b:" .. tostring(e.Name), n, nil) end
        for _, e in ipairs(customEntries()) do n += 1; addRow(e, e._key, n, e._i) end
    end

    addBtn.MouseButton1Click:Connect(function() form.Visible = not form.Visible end)
    cancelB.MouseButton1Click:Connect(function() form.Visible = false; nameBox.Text = ""; codeBox.Text = "" end)
    saveB.MouseButton1Click:Connect(function()
        local nm = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        local cd = codeBox.Text
        if nm == "" or cd:gsub("%s", "") == "" then Notify("⚠️", TT("empty"), 3) return end
        table.insert(data.custom[gid], {name = nm, code = cd})
        saveData(data)
        nameBox.Text = ""; codeBox.Text = ""; form.Visible = false
        refresh()
    end)

    refresh()

    -- ============ التشغيل التلقائي (مرة وحدة لكل جلسة) ============
    if env.CrypticMapAutoRan ~= lp then
        env.CrypticMapAutoRan = lp
        task.spawn(function()
            task.wait(1.5)
            for _, e in ipairs(builtin) do
                if data.auto[gid]["b:" .. tostring(e.Name)] then Exec(e) end
            end
            for _, e in ipairs(customEntries()) do
                if data.auto[gid][e._key] then Exec(e) end
            end
        end)
    end
end
