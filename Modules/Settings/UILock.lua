-- [[ Cryptic Hub - UI Lock ]]
-- تثبيت موضع النافذة وزر الفتح/الإغلاق
--
-- الحفظ: "Cryptic/CrypticHub_ScreenPin.dat" — داخل مجلد Cryptic (لو الـexecutor ما يدعم
--   المجلدات يرجع للجذر). الملف القديم CrypticHub_UILock.dat يتحذف تلقائياً بدون ما يُقرأ.
--   يحفظ: { enabled, timestamp, موضع النافذة, موضع زر الفتح }
--   ينكتب فوراً عند التفعيل/الإيقاف
--   ينتهي تلقائياً بعد 3 أيام من تفعيله (إجراء احترازي)
--
-- V2: المواضع المحفوظة تنرجع داخل الشاشة قبل ما تتثبّت (لو تغيّر الجهاز/الدقة)،
--     وإذا تغيّر حجم الشاشة (تدوير) يتحدّث القفل بدل ما يثبّت موضع قديم.

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end
    local function SafeT(key, fallback)
        local r = T(key); return (r == key) and fallback or r
    end

    local HttpService = game:GetService("HttpService")
    local CoreGui     = game:GetService("CoreGui")
    local Workspace   = game:GetService("Workspace")

    -- ─────────────────────────────────────────────────────────────────── --
    --  مسار الملف (مجلد Cryptic)
    -- ─────────────────────────────────────────────────────────────────── --
    local DATA_FOLDER = "Cryptic"
    local DAT_NAME    = "CrypticHub_ScreenPin.dat"      -- الاسم الجديد
    local OLD_DAT     = "CrypticHub_UILock.dat"         -- الاسم القديم (يتحذف بدون ما يُقرأ)

    local function ensureFolder()
        if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return false end
        local ok, exists = pcall(isfolder, DATA_FOLDER)
        if ok and exists then return true end
        pcall(makefolder, DATA_FOLDER)
        local ok2, exists2 = pcall(isfolder, DATA_FOLDER)
        return ok2 and exists2 == true
    end

    local DAT_FILE = ensureFolder() and (DATA_FOLDER .. "/" .. DAT_NAME) or DAT_NAME
    local LABEL    = SafeT("settings.ui_lock.label", "🔒 تثبيت الواجهة")

    -- ─────────────────────────────────────────────────────────────────── --
    --  حفظ / قراءة
    -- ─────────────────────────────────────────────────────────────────── --
    local EXPIRE_SECONDS = 3 * 24 * 60 * 60  -- 3 أيام بالثواني

    local function packPos(p)
        return { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
    end

    local function saveState(enabled, mainPos, openPos)
        pcall(function()
            if not writefile then return end
            if DAT_FILE ~= DAT_NAME then ensureFolder() end
            local d = { enabled = enabled }
            if enabled and mainPos and openPos then
                d.timestamp = os.time()  -- وقت التفعيل
                d.main = packPos(mainPos)
                d.open = packPos(openPos)
            end
            writefile(DAT_FILE, HttpService:JSONEncode(d))
        end)
    end

    local function readFileData(path)
        local ok, d = pcall(function()
            if isfile and isfile(path) then
                return HttpService:JSONDecode(readfile(path))
            end
        end)
        if ok and type(d) == "table" then return d end
        return nil
    end

    local function loadState()
        local d = readFileData(DAT_FILE)

        -- تنظيف لمرة وحدة: احذف ملف القفل القديم (الجذر + مجلد Cryptic) بدون ما نقرأه،
        -- عشان أي قفل قديم عالق عند المستخدمين ينفك وما ينتقل للنسخة الجديدة.
        if delfile and isfile then
            for _, path in ipairs({ OLD_DAT, DATA_FOLDER .. "/" .. OLD_DAT }) do
                local okOld, oldExists = pcall(isfile, path)
                if okOld and oldExists then pcall(delfile, path) end
            end
        end

        if type(d) ~= "table" then return {} end

        -- تحقق انتهاء الصلاحية: لو فات 3 أيام من التفعيل → أطفئه تلقائياً
        if d.enabled and type(d.timestamp) == "number" then
            if (os.time() - d.timestamp) >= EXPIRE_SECONDS then
                pcall(function()
                    if writefile then
                        writefile(DAT_FILE, HttpService:JSONEncode({ enabled = false }))
                    end
                end)
                return {}
            end
        end

        return d
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  مراجع الـ UI
    -- ─────────────────────────────────────────────────────────────────── --
    local function getUI()
        local frames  = getgenv().CrypticUIFrames
        local Main    = frames and frames.Main
        local Screen  = CoreGui:FindFirstChild("CrypticHub_V9_Premium")
        local OpenBtn = Screen and Screen:FindFirstChild("Launcher")
        return Main, OpenBtn, Screen
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  إبقاء المواضع داخل الشاشة
    -- ─────────────────────────────────────────────────────────────────── --
    local WIN_W, WIN_H = 470, 310   -- نفس أبعاد النافذة في Core
    local BTN_SIZE     = 26

    local function viewSize(Screen)
        local v = Screen and Screen.AbsoluteSize
        if not v or v.X <= 0 or v.Y <= 0 then
            local cam = Workspace.CurrentCamera
            v = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        end
        return v
    end

    -- النافذة: AnchorPoint (0.5, 0.5)  → نثبّت المركز بحيث النافذة كلها داخل الشاشة
    local function clampMainPos(pos, Screen)
        local view = viewSize(Screen)
        local sc   = (UI and UI.ResponsiveScale and UI.ResponsiveScale.Scale) or 1
        local halfW, halfH = WIN_W * sc * 0.5, WIN_H * sc * 0.5
        local cx = view.X * pos.X.Scale + pos.X.Offset
        local cy = view.Y * pos.Y.Scale + pos.Y.Offset
        local function axis(c, half, v)
            local lo, hi = half + 12, v - half - 12
            if hi < lo then return v * 0.5 end
            return math.clamp(c, lo, hi)
        end
        return UDim2.fromScale(axis(cx, halfW, view.X) / view.X, axis(cy, halfH, view.Y) / view.Y)
    end

    -- الزر: AnchorPoint (0, 0.5)
    local function clampOpenPos(pos, Screen)
        local view = viewSize(Screen)
        local x = view.X * pos.X.Scale + pos.X.Offset
        local cy = view.Y * pos.Y.Scale + pos.Y.Offset
        x  = math.clamp(x,  6, math.max(6, view.X - BTN_SIZE - 6))
        cy = math.clamp(cy, BTN_SIZE * 0.5 + 6, math.max(BTN_SIZE * 0.5 + 6, view.Y - BTN_SIZE * 0.5 - 6))
        return UDim2.fromScale(x / view.X, cy / view.Y)
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  اتصالات القفل
    -- ─────────────────────────────────────────────────────────────────── --
    local lockConns = {}
    local locked    = { main = nil, open = nil }

    local function disconnectLock()
        for _, c in pairs(lockConns) do pcall(function() c:Disconnect() end) end
        lockConns = {}
        locked.main, locked.open = nil, nil
    end

    local function applyLock(Main, OpenBtn, mainPos, openPos)
        disconnectLock()
        locked.main, locked.open = mainPos, openPos

        table.insert(lockConns,
            Main:GetPropertyChangedSignal("Position"):Connect(function()
                if locked.main and Main.Position ~= locked.main then
                    Main.Position = locked.main
                end
            end)
        )
        table.insert(lockConns,
            OpenBtn:GetPropertyChangedSignal("Position"):Connect(function()
                if locked.open and OpenBtn.Position ~= locked.open then
                    OpenBtn.Position = locked.open
                end
            end)
        )

        -- تدوير الشاشة / تغيّر الدقة: حدّث المواضع المقفولة بدل ما تبقى قديمة
        local function bindCamera()
            local cam = Workspace.CurrentCamera
            if not cam then return end
            table.insert(lockConns,
                cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    task.wait(0.15)  -- خل Core يخلص إعادة الحساب أولاً
                    if not locked.main then return end
                    local _, _, Screen = getUI()
                    locked.main = clampMainPos(locked.main, Screen)
                    locked.open = clampOpenPos(locked.open, Screen)
                    pcall(function() Main.Position    = locked.main end)
                    pcall(function() OpenBtn.Position = locked.open end)
                end)
            )
        end
        bindCamera()
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  تفعيل: يلتقط الموضع الحالي، يحفظه، يقفل
    -- ─────────────────────────────────────────────────────────────────── --
    local function enableLock()
        local Main, OpenBtn, Screen = getUI()
        if not Main or not OpenBtn then return end
        local mainPos = clampMainPos(Main.Position, Screen)
        local openPos = clampOpenPos(OpenBtn.Position, Screen)
        pcall(function() Main.Position    = mainPos end)
        pcall(function() OpenBtn.Position = openPos end)
        saveState(true, mainPos, openPos)
        applyLock(Main, OpenBtn, mainPos, openPos)
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  إيقاف
    -- ─────────────────────────────────────────────────────────────────── --
    local function disableLock()
        disconnectLock()
        saveState(false)
    end

    -- ─────────────────────────────────────────────────────────────────── --
    --  اقرأ الملف مرة واحدة عند تحميل الموديول (synchronous)
    -- ─────────────────────────────────────────────────────────────────── --
    local earlyData = loadState()

    -- ─────────────────────────────────────────────────────────────────── --
    --  0.3 ث: أعد الموضع المحفوظ وابدأ القفل المبكر
    -- ─────────────────────────────────────────────────────────────────── --
    task.spawn(function()
        task.wait(0.3)
        if not earlyData.enabled then return end

        local Main, OpenBtn, Screen = getUI()
        if not Main or not OpenBtn then return end

        local mainPos = Main.Position
        local openPos = OpenBtn.Position

        if earlyData.main then
            mainPos = UDim2.new(
                earlyData.main.xs, earlyData.main.xo,
                earlyData.main.ys, earlyData.main.yo
            )
        end
        if earlyData.open then
            openPos = UDim2.new(
                earlyData.open.xs, earlyData.open.xo,
                earlyData.open.ys, earlyData.open.yo
            )
        end

        -- لا تثبّت موضع خارج الشاشة أبداً
        mainPos = clampMainPos(mainPos, Screen)
        openPos = clampOpenPos(openPos, Screen)
        pcall(function() Main.Position    = mainPos end)
        pcall(function() OpenBtn.Position = openPos end)

        applyLock(Main, OpenBtn, mainPos, openPos)
    end)

    -- ─────────────────────────────────────────────────────────────────── --
    --  التوغل
    -- ─────────────────────────────────────────────────────────────────── --
    local toggleObj = Tab:AddToggle(LABEL, function(active)
        if active then
            enableLock()
        else
            disableLock()
        end
    end)

    -- ─────────────────────────────────────────────────────────────────── --
    --  0.5 ث: اعرض التوغل مفعّلاً (بعد ما رجع الموضع في 0.3 ث)
    -- ─────────────────────────────────────────────────────────────────── --
    if earlyData.enabled then
        task.spawn(function()
            task.wait(0.5)
            pcall(function() toggleObj:SetState(true) end)
        end)
    end
end
