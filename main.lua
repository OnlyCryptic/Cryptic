-- ============================================================
--  Cryptic Hub - main.lua  (Fast Loading + Compatibility)
--  الفكرة:
--   - تحميل كل الملفات بالتوازي بالخلفية، وبناء التابات بالترتيب بدون لاق
--   - كل دوال المشغّل الاختيارية (readfile / writefile / queue_on_teleport /
--     request / getgenv ...) يتم فحصها، وغيابها ما يوقف السكربت
--  الأقسام:
--   1) الخدمات والقدرات   2) حماية التشغيل المزدوج   3) الإعدادات
--   4) التشغيل التلقائي   5) محرك التحميل   6) i18n + الماب
--   7) هيكل التابات   8) أدوات البناء   9) بناء التابات
--  10) إعادة الدخول بعد تغيير اللغة   11) تشغيل الواجهة
-- ============================================================

-- ============================================================
-- 1) الخدمات والقدرات
-- ============================================================
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local lp               = Players.LocalPlayer

local function IsFn(f) return type(f) == "function" end

-- قراءة آمنة للمتغيرات العالمية.
local function Probe(fn)
    local ok, value = pcall(fn)
    if ok then return value end
    return nil
end

-- طبقة توافق صغيرة: لا نفترض وجود task أو os.clock في كل بيئة.
local TaskLib = Probe(function() return task end)
local Clock = (type(os) == "table" and IsFn(os.clock)) and os.clock or function()
    return (IsFn(tick) and tick()) or 0
end
local function Now()
    return (IsFn(tick) and tick()) or Clock()
end
local function Wait(seconds)
    seconds = seconds or 0
    if type(TaskLib) == "table" and IsFn(TaskLib.wait) then
        local ok, result = pcall(TaskLib.wait, seconds)
        if ok then return result end
    end
    if seconds > 0 then
        local started = Clock()
        while Clock() - started < seconds do
            if IsFn(wait) then pcall(wait) else break end
        end
    elseif IsFn(wait) then
        pcall(wait)
    end
end
local function Spawn(fn)
    if type(TaskLib) == "table" and IsFn(TaskLib.spawn) then
        local ok, thread = pcall(TaskLib.spawn, fn)
        if ok then return thread end
    end
    if type(coroutine) == "table" and IsFn(coroutine.wrap) then
        local ok = pcall(function() coroutine.wrap(fn)() end)
        if ok then return true end
    end
    return nil
end
local function Delay(seconds, fn)
    if type(TaskLib) == "table" and IsFn(TaskLib.delay) then
        local ok, result = pcall(TaskLib.delay, seconds, fn)
        if ok then return result end
    end
    return nil
end

-- getgenv اختياري: لو مو موجود نستخدم _G، ونعرّفه للموديولات اللي تناديه
if not IsFn(Probe(function() return getgenv end)) then
    pcall(function() getgenv = function() return _G end end)
end
local env = Probe(function() return getgenv() end)
if type(env) ~= "table" then env = _G end

-- قدرات المشغّل (كلها اختيارية)
local QueueFns, QueueSeen = {}, {}
local function AddQueue(fn)
    if IsFn(fn) and not QueueSeen[fn] then
        QueueSeen[fn] = true
        table.insert(QueueFns, fn)
    end
end
AddQueue(Probe(function() return queue_on_teleport end))
AddQueue(Probe(function() return syn and syn.queue_on_teleport end))
AddQueue(Probe(function() return fluxus and fluxus.queue_on_teleport end))
local QueueFn = QueueFns[1]

-- احتفظ بكل مزود request منفصلًا؛ فشل واحد لا يمنع تجربة المزود التالي.
local RequestFns, RequestSeen = {}, {}
local function AddRequest(fn)
    if IsFn(fn) and not RequestSeen[fn] then
        RequestSeen[fn] = true
        table.insert(RequestFns, fn)
    end
end
AddRequest(Probe(function() return syn and syn.request end))
AddRequest(Probe(function() return http and http.request end))
AddRequest(Probe(function() return http_request end))
AddRequest(Probe(function() return request end))
AddRequest(Probe(function() return fluxus and fluxus.request end))
local RequestFn = RequestFns[1]

local Caps = {
    readfile  = IsFn(Probe(function() return readfile end)),
    writefile = IsFn(Probe(function() return writefile end)),
    queue     = IsFn(QueueFn),
    request   = #RequestFns > 0,
    httpget   = true,
    loadstring = false,
}
pcall(function() env.CrypticCaps = Caps end)

-- لا نعتمد على وجود الدالة فقط: نختبر الترجمة فعليًا قبل تحميل أي ملف.
local LoadFn
local function TestCompiler(candidate)
    if not IsFn(candidate) then return nil end
    local ok, compiled = pcall(candidate, "return true")
    if not ok or not IsFn(compiled) then return nil end
    local ran, value = pcall(compiled)
    if not ran or value ~= true then return nil end
    return candidate
end
LoadFn = TestCompiler(Probe(function() return loadstring end))
if not LoadFn then LoadFn = TestCompiler(Probe(function() return load end)) end
Caps.loadstring = LoadFn ~= nil

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cryptic Hub", Text = text, Duration = 5,
        })
    end)
end

-- ============================================================
-- 2) حماية التشغيل المزدوج
-- ============================================================
-- أي تشغيل ثاني بنفس الجلسة يوصل خلال هالمدة (ثواني) يعتبر تشغيل تلقائي مكرر
-- (من زر إعادة دخول، تبديل سيرفر، تغيير لغة، التشغيل التلقائي...) ونتجاهله بصمت.
local DUP_WINDOW = 20 -- يحتفظ به للتوافق مع إعدادات الإصدارات السابقة؛ القفل لم يعد ينتهي زمنيًا.
local now = Now()
local sameSession = env.CrypticHub_Loaded == true and env.CrypticHub_Player == lp

-- القفل مرتبط بكائن اللاعب/الجلسة وليس بمهلة زمنية، فلا تبدأ واجهتان بعد 20 ثانية.
if sameSession then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cryptic Hub", Text = "Cryptic Hub is already running in this session.", Duration = 5
        })
    end)
    return
end

env.CrypticHub_Loaded  = true
env.CrypticHub_Player  = lp
env.CrypticHub_StartAt = now
env.CrypticHub_Booting = true

-- ============================================================
-- 3) الإعدادات
-- ============================================================
local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "hm",
        Discord = "https://discord.gg/QSvQJs7BdP"
    },
    -- ملاحظة: سجل الماب (GameIds بالـ Universe ID) موجود في
    -- Cryptic/Maps/index.lua لإبقاء هذا الملف نظيف.
}

local RAW_BASE = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    Cryptic.Config.UserName, Cryptic.Config.RepoName, Cryptic.Config.Branch
)

-- يضبط نفسه تلقائياً حسب الجهاز: جوال (لمس بدون كيبورد) أو كمبيوتر
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local SESSION_V           = tostring(Now())              -- نفس الرقم لكل طلبات هالتشغيل
local WORKER_MAX          = IS_MOBILE and 4 or 8          -- أقصى تحميلات متوازية (تنقص تلقائياً لو النت ضعيف)
local BASE_BUDGET         = IS_MOBILE and 0.006 or 0.010  -- وقت عمل (ثواني) قبل ما نعطي اللعبة فريم (يقل لو الجهاز بطيء)
local MODULE_TIMEOUT      = 6                              -- بعدها نكمل على الموديول اللي بعده (الموديول يظل شغال)
local MODULE_HARD_TIMEOUT = 45                             -- حد تشخيصي فقط؛ لا نلغي الموديولات تلقائياً
local MAX_BUFFER          = (IS_MOBILE and 12 or 40) * 1024 * 1024 -- أقصى حجم ملفات محملة ومنتظرة التشغيل

-- مشغّل بدون identifyexecutor غالباً قديم/بسيط: نبدأ بتحميل متوازي أقل
if not IsFn(Probe(function() return identifyexecutor end)) then
    WORKER_MAX = math.min(WORKER_MAX, 3)
end

-- وضع آمن يدوي: getgenv().CrypticSafeMode = true قبل تشغيل السكربت
if env.CrypticSafeMode then
    WORKER_MAX  = 1
    BASE_BUDGET = 0.003
end

-- ============================================================
-- 4) التشغيل التلقائي بعد النقل / إعادة الدخول
-- ============================================================
local AUTOEXEC_FILE = "CrypticAutoExec.json"

-- كود يتحط بطابور النقل. conditional = true يعني: يشتغل بس لو التوغل لسا مفعّل
local function BuildLoader(conditional)
    local url = RAW_BASE .. "main.lua"
    local check = ""
    if conditional then
        check = string.format([[
    local on = false
    pcall(function()
        on = game:GetService("HttpService"):JSONDecode(readfile(%q)).enabled == true
    end)
    if not on then return end
]], AUTOEXEC_FILE)
    end

    return string.format([[
local function safeWait(t)
    local ok = pcall(function()
        if task and task.wait then task.wait(t) else wait(t) end
    end)
    return ok
end
pcall(function()
    local loadedOk, loaded = pcall(function() return game:IsLoaded() end)
    if loadedOk and not loaded then pcall(function() game.Loaded:Wait() end) end
    safeWait(2)
%s    local genv = _G
    pcall(function() if getgenv then genv = getgenv() end end)
    if type(genv) ~= "table" then genv = _G end
    genv.CrypticAutoLaunchAt = (tick and tick()) or os.clock()
    local url = %q .. "?v=" .. tostring((tick and tick()) or os.clock())
    local src
    pcall(function() src = game:HttpGet(url) end)
    if type(src) ~= "string" or src == "" then
        local providers = {}
        pcall(function() if syn and syn.request then table.insert(providers, syn.request) end end)
        pcall(function() if http and http.request then table.insert(providers, http.request) end end)
        pcall(function() if http_request then table.insert(providers, http_request) end end)
        pcall(function() if request then table.insert(providers, request) end end)
        for _, req in ipairs(providers) do
            local ok, res = pcall(req, {Url = url, Method = "GET"})
            if ok and type(res) == "table" and type(res.Body) == "string" and res.Body ~= "" then
                local code = tonumber(res.StatusCode)
                if not code or (code >= 200 and code < 300) then src = res.Body break end
            end
        end
    end
    if type(src) ~= "string" or src == "" then return end
    local compilers = {}
    pcall(function() if type(loadstring) == "function" then table.insert(compilers, loadstring) end end)
    pcall(function() if type(load) == "function" then table.insert(compilers, load) end end)
    for _, compiler in ipairs(compilers) do
        local testOk, testChunk = pcall(compiler, "return true")
        if testOk and type(testChunk) == "function" then
            local ran, value = pcall(testChunk)
            if ran and value == true then
                local ok, chunk = pcall(compiler, src)
                if ok and type(chunk) == "function" then pcall(chunk); break end
            end
        end
    end
end)
]], check, url)
end
-- اختياري: لو المشغّل ما يدعم queue_on_teleport نرجع false ونكمل عادي
local function QueueOnTeleport(code)
    for _, provider in ipairs(QueueFns) do
        local ok, result = pcall(provider, code)
        if ok and result ~= false then return true end
    end
    return false
end

-- اختياري: بدون readfile التشغيل التلقائي يعتبر مطفي
local function AutoExecEnabled()
    if not Caps.readfile then return false end
    local read = Probe(function() return readfile end)
    if not IsFn(read) then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(read(AUTOEXEC_FILE))
    end)
    return ok and type(data) == "table" and data.enabled == true
end

-- يجهّز التشغيل التلقائي مرة وحدة لكل جلسة (الطابور يشتغل بس على أول نقل،
-- فكل ما يشتغل السكربت نجهّزه من جديد). يرجع false لو غير مدعوم.
local function ArmAutoExec()
    if env.CrypticAutoExecArmed == lp then return true end
    if QueueOnTeleport(BuildLoader(true)) then
        env.CrypticAutoExecArmed = lp
        return true
    end
    return false
end
env.CrypticArmAutoExec = ArmAutoExec -- يستخدمه توغل التشغيل التلقائي

-- ============================================================
-- 5) محرك التحميل
-- ============================================================
-- حالة كل ملف: nil (ما انطلب) | "loading" | "ready" (نصه بـ Body)
--              | "used" (انشغل ونصه انحذف) | "failed" | "missing" (404)
local State, Body = {}, {}
local BufferedBytes = 0

local RETRY_DELAYS = { 0.3, 0.8 }
local WorkerLimit  = WORKER_MAX   -- الحد الحالي للتحميلات المتوازية (ينقص لو فيه فشل، ويرجع يزيد لو استقر)
local NetFails     = 0
local Streak       = 0

-- طلب HTTP واحد. يرجع: body | nil, سبب الفشل, هل الملف غير موجود (404)
local function HttpFetch(url)
    local errors = {}

    if Caps.httpget then
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and type(result) == "string" and result ~= "" then
            if result == "404: Not Found" then return nil, "404", true end
            return result
        end
        local message = tostring(result)
        table.insert(errors, "HttpGet: " .. message)
        if not ok and (message:lower():find("not a valid member", 1, true)
            or message:lower():find("unknown member", 1, true)
            or message:lower():find("httpget", 1, true) and message:lower():find("nil", 1, true)) then
            Caps.httpget = false
        end
        if message:find("404", 1, true) then return nil, message, true end
    end

    for index, provider in ipairs(RequestFns) do
        local ok, response = pcall(provider, {Url = url, Method = "GET"})
        if ok and type(response) == "table" then
            local code = tonumber(response.StatusCode or response.Status or response.status_code)
            local body = response.Body or response.body
            if code == 404 then return nil, "404", true end
            if type(body) == "string" and body ~= "" then
                if not code or (code >= 200 and code < 300) then
                    if body == "404: Not Found" then return nil, "404", true end
                    return body
                end
                table.insert(errors, "request[" .. index .. "]: HTTP " .. tostring(code))
            else
                table.insert(errors, "request[" .. index .. "]: empty/invalid body")
            end
        else
            table.insert(errors, "request[" .. index .. "]: " .. tostring(response))
        end
    end

    return nil, (#errors > 0 and table.concat(errors, " | ") or "no supported HTTP provider")
end
local Pump -- يتعرّف تحت

local function DownloadInner(path, attempts)
    local body, missing
    for attempt = 1, attempts do
        local b, _, isMissing = HttpFetch(RAW_BASE .. path .. "?v=" .. SESSION_V)
        if b then
            body = b
            break
        end
        if isMissing then
            missing = true
            break
        end

        -- فشل شبكة: كل 3 فشلات ننزّل التحميل المتوازي للنصف (لين يوصل 1 = واحد واحد)
        NetFails = NetFails + 1
        Streak   = 0
        if NetFails % 3 == 0 and WorkerLimit > 1 then
            WorkerLimit = math.max(1, math.floor(WorkerLimit / 2))
        end
        if attempt < attempts then Wait(RETRY_DELAYS[attempt] or 1) end
    end

    if body then
        Body[path] = body
        BufferedBytes = BufferedBytes + #body
        State[path] = "ready"

        -- استقرار: كل 20 نجاح متتالي نزيد عامل واحد (لين الحد الأقصى)
        Streak = Streak + 1
        if Streak >= 20 and WorkerLimit < WORKER_MAX then
            Streak = 0
            WorkerLimit = WorkerLimit + 1
        end
    else
        State[path] = missing and "missing" or "failed"
    end
end

-- يحمّل ملف ويضمن إن حالته ما تظل "loading" مهما صار
local function Download(path, attempts)
    State[path] = "loading"
    local ok, err = pcall(DownloadInner, path, attempts)
    if not ok then
        warn("Cryptic Hub: download error - " .. path .. " - " .. tostring(err))
    end
    if State[path] == "loading" then State[path] = "failed" end
end

-- يجيب نص ملف (من الجاهز لو موجود). لو أحد ثاني يحمّله الحين ننتظره بدل ما نكرر الطلب
local function GetSource(path)
    local state = State[path]
    if state == "ready" then return Body[path] end
    if state == "missing" then return nil end

    if state == "loading" then
        local started = Clock()
        while State[path] == "loading" and Clock() - started < 40 do Wait(0.05) end
        -- لا نمسح حالة loading؛ العامل الأصلي قد يكون ما زال يعمل.
        if State[path] == "loading" then
            warn("Cryptic Hub: still waiting for download - " .. path)
            return nil
        end
        if State[path] == "ready" then return Body[path] end
        if State[path] == "missing" then return nil end
    end

    if State[path] == nil or State[path] == "failed" or State[path] == "used" then
        Download(path, 2)
        if State[path] == "ready" then return Body[path] end
    end
    return nil
end
-- طابور تحميل مشترك + عمّال بالخلفية (عددهم يتبع WorkerLimit)
local Queue, QHead, Active = {}, 1, 0
local Queued = {}
local Pumping = false

local function PopQueue()
    while QHead <= #Queue do
        local path = Queue[QHead]
        QHead = QHead + 1
        if path then Queued[path] = nil end
        if path and State[path] == nil then
            Queued[path .. "#active"] = true
            return path
        end
    end
    return nil
end

Pump = function()
    if Pumping then return end
    Pumping = true
    while Active < WorkerLimit and QHead <= #Queue do
        Active = Active + 1
        local thread = Spawn(function()
            local ok, err = pcall(function()
                while true do
                    if Active > WorkerLimit then break end
                    local path = PopQueue()
                    if not path then break end

                    -- ضغط عكسي فعلي: لا يبدأ عامل تنزيلًا جديدًا عند تجاوز حد الذاكرة.
                    -- GetSource يستطيع تحميل الملف المطلوب مباشرة، لذلك لا يتوقف البناء بانتظار العامل.
                    while BufferedBytes > MAX_BUFFER do Wait(0.08) end
                    if State[path] == nil then Download(path, 3) end
                    Queued[path .. "#active"] = nil
                end
            end)
            Active = math.max(0, Active - 1)
            if not ok then warn("Cryptic Hub: worker error - " .. tostring(err)) end
            Pump()
        end)
        if not thread then
            Active = math.max(0, Active - 1)
            break
        end
    end
    Pumping = false
end
-- يضيف ملفات للطابور ويبدأ تحميلها بالتوازي بالخلفية (ما يوقف شي)
local function Prefetch(paths)
    for _, path in ipairs(paths) do
        if State[path] == nil and not Queued[path] then
            Queued[path] = true
            table.insert(Queue, path)
        end
    end
    Pump()
end

-- يعطي اللعبة فريم لو شغلنا أكثر من الميزانية. الميزانية تقل تلقائياً لو الجهاز بطيء
-- (نقيس طول الفريم من task.wait نفسها): فريم بطيء = ننتظر بعد كل ملف.
local lastYield = Clock()
local frameDt   = 1 / 60
local function Breathe()
    local budget = BASE_BUDGET
    if frameDt > 0.045 then
        budget = 0
    elseif frameDt > 0.03 then
        budget = BASE_BUDGET * 0.5
    end
    if Clock() - lastYield >= budget then
        local dt = Wait()
        if type(dt) == "number" then frameDt = dt end
        lastYield = Clock()
    end
end

-- يجيب الملف ويشغّله ويرجع نتيجته. أخطاء التحميل والترجمة والتشغيل كل واحد منفصل.
local Importing, ImportDone, ImportResult = {}, {}, {}
local function Import(path)
    if ImportDone[path] then return ImportResult[path] end
    if Importing[path] then
        local started = Clock()
        while Importing[path] and Clock() - started < 40 do Wait(0.05) end
        if ImportDone[path] then return ImportResult[path] end
        if Importing[path] then
            warn("Cryptic Hub: import still running - " .. path)
            return nil
        end
    end

    Importing[path] = true
    local function Finish(value, cache)
        Importing[path] = nil
        if cache then
            ImportDone[path] = true
            ImportResult[path] = value
        end
        return value
    end

    local src = GetSource(path)
    if not src then
        warn("Cryptic Hub: could not download - " .. path)
        return Finish(nil, false)
    end

    -- نفرّغ النص من الذاكرة فوراً بعد أخذه من المخزن.
    Body[path] = nil
    BufferedBytes = math.max(0, BufferedBytes - #src)
    State[path] = "used"

    if not LoadFn then
        warn("Cryptic Hub: this executor cannot compile downloaded Lua modules")
        Notify("This executor does not support dynamic Lua loading")
        return Finish(nil, false)
    end

    local okCompile, chunk, compileError = pcall(LoadFn, src)
    src = nil
    if not okCompile or type(chunk) ~= "function" then
        warn("Cryptic Hub: compile error - " .. path .. " - " .. tostring(okCompile and compileError or chunk))
        return Finish(nil, false)
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("Cryptic Hub: runtime error - " .. path .. " - " .. tostring(result))
        return Finish(nil, false)
    end
    return Finish(result, true)
end
-- يفرّغ الملفات اللي انحملت ولا انطلبت (غير العناصر) بعد ما ينتهي البناء
local function ReleaseUnused()
    for p, st in pairs(State) do
        if st == "ready" and p:sub(1, 12) ~= "UI/Elements/" then
            Body[p] = nil
            State[p] = nil
        end
    end
    local total = 0
    for _, b in pairs(Body) do total = total + #b end
    BufferedBytes = total
end

-- عند إعادة التشغيل اليدوي: نسمح بإعادة تحميل اللي انشغل أو فشل
local function ResetForReboot()
    for p, st in pairs(State) do
        if st == "used" or st == "failed" then State[p] = nil end
    end
end

-- عناصر الواجهة: تنحمل مرة وحدة وتنحفظ (الدالة نفسها، مو النص).
-- لو موديولين طلبوا نفس العنصر بنفس اللحظة، الثاني ينتظر الأول بدل ما نحمّله مرتين.
local ElementCache, ElementLoading = {}, {}
local function LoadElement(elementName)
    if ElementCache[elementName] then return ElementCache[elementName] end

    if ElementLoading[elementName] then
        local t0 = Clock()
        while ElementLoading[elementName] and Clock() - t0 < 40 do Wait() end
        return ElementCache[elementName]
    end

    ElementLoading[elementName] = true
    local ok, func = pcall(Import, "UI/Elements/" .. elementName .. ".lua")
    ElementLoading[elementName] = nil

    if ok and func then
        ElementCache[elementName] = func
        return func
    end
    warn("Cryptic Hub: Failed to load element - " .. elementName)
    return nil
end

-- ============================================================
-- 6) i18n + سجل الماب + Physics Guard
-- ============================================================
-- نبدأ تحميل الأساسيات بالتوازي أول شي
Prefetch({ "i18n.lua", "Maps/index.lua", "Modules/Core/physics_guard.lua" })

do
    local registry = Import("Maps/index.lua")
    if type(registry) == "table" then
        Cryptic.GameIds = registry.GameIds or {}
    else
        Cryptic.GameIds = {}
    end
end

-- i18n يتحمل ويتاح عالمياً قبل أي شي. فشله (مثلاً بدون readfile) ما يوقف السكربت
local i18n = Import("i18n.lua")
if type(i18n) ~= "table" then i18n = nil end
if i18n then
    pcall(function() i18n.Load() end)  -- يقرأ اللغة المحفوظة لو موجودة
    env.CrypticI18n = i18n             -- متاح لكل الموديولات
end

-- Physics Guard: يعمل بصمت، يمنع اهتزاز الفيزياء في كل الميزات
pcall(function() Import("Modules/Core/physics_guard.lua") end)

local function T(key)
    if i18n then
        local ok, v = pcall(i18n.T, key)
        if ok and v ~= nil then return v end
    end
    return key
end

-- ============================================================
-- 7) هيكل التابات
-- ============================================================
-- قوائم ملفات التابات الخاصة
local TARGET_MAIN   = {"target_select"}
local TARGET_SPY    = {"target_spectate", "target_tp", "Target_follow", "target_esp", "skinz", "info_t"}
local TARGET_FUN    = {"bang", "target_facesit", "jark", "target_hug", "target_sit", "backpack", "carry", "target_dee", "lkm", "target_shit"}
local TARGET_TRICKS = {"target_fling", "bring_parts", "target_mimic", "copy_walk", "target_aimbot", "target_emotes"}
local OTHER_LIST    = {"lol", "animations", "vfly", "zero_gravity", "anti_block", "anti_sit", "fling_all", "night", "infinite_zoom", "no_camera_clip", "anti_afk", "aimbot"}

local function BuildStructure()
    Cryptic.Structure = {
        ["player"]   = { Icon = "👤", Key = "tab.player",   Folder = "Player",   Files = {"so", "blox", "gold", "auto_apple", "vi", "speed", "fly", "jumppower", "noclip", "antifling", "walkfling", "flyfling", "wallwalk", "nofall", "infinitejump", "3d", "restart", "out", "discord", "di2"} },
        ["tools"]    = { Icon = "🔧", Key = "tab.tools",    Folder = "Misc",     Files = {"lol", "tptool", "auto_tool", "fling_tool", "noclip_tool", "emotes", "esp", "nbc_esp", "tool_esp", "shiftlock", "invis_tool", "spin_tool", "x-ray", "fullbright", "no_fog", "camera"} },
        ["target"]   = { Icon = "🎯", Key = "tab.target",   Folder = "Combat",   Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "bring_parts", "carry", "jark", "Target_follow", "target_esp", "copy_skin1", "target_emotes", "target_facesit", "info_t", "skinz"} },
        ["server"]   = { Icon = "🌐", Key = "tab.server",   Folder = "Server",   Files = {"server", "rejoin", "join_id", "players"} },
        ["teleport"] = { Icon = "📍", Key = "tab.teleport", Folder = "Teleport", Files = {"lol", "tp_locations", "checkpoint"} },
        ["other"]    = { Icon = "⚡", Key = "tab.other",    Folder = "Other",    Files = OTHER_LIST },
        ["settings"] = { Icon = "⚙️", Key = "tab.settings", Folder = "Settings", Files = {"transparency", "anti_lag", "ui_lock", "ui_toggle", "auto_execute", "settings", "suggestion_box"} },
    }
    Cryptic.TabsOrder = {
        "player", "tools", "target", "other", "teleport", "server", "settings"
    }
end

-- التعرف على الماب بالـ Universe ID فقط (game.GameId)
local function GetMapPath()
    local p = Cryptic.GameIds and Cryptic.GameIds[game.GameId]
    return p and (p .. ".lua") or nil
end

local function InjectMapTab()
    local mapFilePath = GetMapPath()
    if not mapFilePath then return end

    local mapData = Import(mapFilePath)
    if type(mapData) ~= "table" then return end

    local id = "map_current"
    Cryptic.Structure[id] = { _isMapTab = true, _mapData = mapData }
    table.insert(Cryptic.TabsOrder, 2, id)
end

local function TabDisplayName(id)
    local data = Cryptic.Structure[id]
    if not data then return id end
    if data._isMapTab and data._mapData then
        return "🗺️ " .. tostring(data._mapData.Name)
    end
    return T(data.Key)
end

local function TabIcon(id)
    local data = Cryptic.Structure[id]
    if not data or data._isMapTab then return nil end
    return data.Icon
end

-- ============================================================
-- 8) أدوات بناء التابات
-- ============================================================
local TAB_ELEMENTS = {
    "Button", "Toggle", "LockedToggle", "ExclusiveToggle", "TimedToggle", "Input", "LargeInput",
    "SpeedControl", "Dropdown", "PlayerSelector", "AddAutoOffToggle", "ProfileCard",
    "Line", "Label", "Paragraph", "Folder", "Versions", "HotkeyToggle"
}

local OPEN_ELEMENTS = {
    "Button", "Toggle", "LockedToggle", "ExclusiveToggle", "TimedToggle", "Input", "LargeInput",
    "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard", "Label", "Paragraph", "Folder", "Line"
}

-- يجمع كل الملفات اللي راح نحتاجها بترتيب الأولوية: واجهة، عناصر، ثم موديولات التابات
local function CollectPaths()
    local paths, seen = {}, {}
    local function add(p)
        if not seen[p] then
            seen[p] = true
            table.insert(paths, p)
        end
    end
    local function addModules(folder, list)
        for _, fname in ipairs(list) do
            add("Modules/" .. folder .. "/" .. fname .. ".lua")
        end
    end

    local mapPath = GetMapPath()
    if mapPath then add(mapPath) end

    add("UI/Core.lua")
    add("UI/LanguagePicker.lua")
    add("UI/Elements/Open.lua")
    if mapPath then add("UI/Elements/MapCard.lua") end

    for _, el in ipairs(TAB_ELEMENTS) do
        if el ~= "AddAutoOffToggle" then add("UI/Elements/" .. el .. ".lua") end
    end
    for _, el in ipairs(OPEN_ELEMENTS) do
        add("UI/Elements/" .. el .. ".lua")
    end

    for _, tabId in ipairs(Cryptic.TabsOrder) do
        local data = Cryptic.Structure[tabId]
        if data then
            if tabId == "target" then
                addModules("Combat", TARGET_MAIN)
                addModules("Combat", TARGET_SPY)
                addModules("Combat", TARGET_FUN)
                addModules("Combat", TARGET_TRICKS)
            elseif tabId == "other" then
                addModules("Other", OTHER_LIST)
                addModules("Other", {"build"})
            else
                addModules(data.Folder, data.Files)
            end
        end
    end

    add("Modules/Inbox.lua")
    return paths
end

-- يربط دوال Add... بالتاب (كل عنصر يتحمل أول ما ينطلب)
local function AttachElements(tab, elementNames)
    for _, el in ipairs(elementNames) do
        tab["Add" .. el] = function(self, ...)
            local f = LoadElement(el)
            if f then return f(self, ...) end
        end
    end
end

-- يسوي كرت Open داخل تاب. يرجع nil لو العنصر ما انحمل
local function MakeOpen(parentTab, title, icon)
    local openFunc = LoadElement("Open")
    if not openFunc then return nil end
    local openTab = openFunc(parentTab, title, icon)
    if not openTab then return nil end
    AttachElements(openTab, OPEN_ELEMENTS)
    return openTab
end

-- يعرض MakeOpen لباقي الملفات (مثل aimbot.lua) عشان تستخدم نفس كرت Open
env.CrypticMakeOpen = MakeOpen

-- يشغّل دالة موديول بحماية كاملة:
--  * أي خطأ يتحول لتحذير (ما يوقف البناء)
--  * بعد MODULE_TIMEOUT نكمل على اللي بعده، والموديول يظل شغال (ممكن بس بطيء)
--  * بعد MODULE_HARD_TIMEOUT نلغيه نهائياً لو لسا معلّق (مثلاً WaitForChild ما راح ينتهي)
--  * لو خلّص متأخر نضيف الخط الفاصل بعدها بدل ما نتجاهله
-- يرجع true لو الموديول خلّص طبيعي وما رجّع false (يعني نحط AddLine)
local function RunGuarded(init, arg1, arg2, name, addLineAfter)
    local done, timedOut = false, false
    local ok, result

    local thread = Spawn(function()
        ok, result = pcall(init, arg1, arg2)
        done = true
        if not ok then
            warn("Cryptic Hub: module error - " .. name .. " - " .. tostring(result))
        elseif timedOut and addLineAfter and result ~= false then
            pcall(function() arg1:AddLine() end)
        end
    end)
    if not thread then
        warn("Cryptic Hub: unable to schedule module - " .. name)
        return false
    end

    local started = Clock()
    while not done and Clock() - started < MODULE_TIMEOUT do Wait() end
    if done then return ok and result ~= false end

    timedOut = true
    warn("Cryptic Hub: module is slow, continuing without cancelling - " .. name)

    -- مهلة طويلة للتشخيص فقط؛ لا نلغي الموديول حتى لا نوقف تهيئة صحيحة بطيئة.
    Delay(MODULE_HARD_TIMEOUT - MODULE_TIMEOUT, function()
        if not done then
            warn("Cryptic Hub: module is still running after hard-timeout threshold - " .. name)
        end
    end)
    return false
end
-- يشغّل مجموعة ملفات بسيطة (بدون AddLine) على تاب معيّن
local function RunSimple(targetTab, folder, fileList, UI)
    for _, fname in ipairs(fileList) do
        local init = Import("Modules/" .. folder .. "/" .. fname .. ".lua")
        if type(init) == "function" then
            RunGuarded(init, targetTab, UI, fname, false)
        end
        Breathe()
    end
end

-- يشغّل الموديولات واحد ورا الثاني، وبعد كل موديول ناجح يضيف خط فاصل
local function RunModules(targetTab, folder, fileList, UI)
    for _, fname in ipairs(fileList) do
        local filePath = (folder == "") and (fname .. ".lua") or ("Modules/" .. folder .. "/" .. fname .. ".lua")
        local init = Import(filePath)
        if type(init) == "function" then
            local finished = RunGuarded(init, targetTab, UI, fname, true)
            if finished then
                pcall(function() targetTab:AddLine() end)
            end
        end
        Breathe()
    end
end

-- يخلي التوغلات داخل كرت معيّن حصرية: تشغيل وحدة يطفي الباقي
local function MakeExclusiveGroup(openTab)
    local group = {}

    local function wrap(getObj, callback)
        return function(active)
            if active then
                local me = getObj()
                for _, other in ipairs(group) do
                    if other ~= me then
                        pcall(function() other:SetState(false) end)
                    end
                end
            end
            if callback then callback(active) end
        end
    end

    local origToggle = openTab.AddToggle
    openTab.AddToggle = function(self, label, callback)
        local obj
        obj = origToggle(self, label, wrap(function() return obj end, callback))
        if obj then table.insert(group, obj) end
        return obj
    end

    local origLocked = openTab.AddLockedToggle
    openTab.AddLockedToggle = function(self, label, reasonOrCb, callbackOrNil)
        local reason, callback
        if type(reasonOrCb) == "function" then
            reason, callback = "", reasonOrCb
        else
            reason, callback = reasonOrCb, callbackOrNil
        end
        local obj
        obj = origLocked(self, label, reason, wrap(function() return obj end, callback))
        if obj then table.insert(group, obj) end
        return obj
    end
end

-- ============================================================
-- 9) بناء كل تاب
-- ============================================================
local function BuildMapTab(tab, mapData, UI)
    if type(mapData.Render) == "function" then
        RunGuarded(mapData.Render, tab, UI, "map render", false)
    else
        pcall(function() tab:AddLabel("🗺️ " .. T("tab.map_scripts")) end)
        local MapCardFunc = LoadElement("MapCard")
        if MapCardFunc then RunGuarded(MapCardFunc, tab, mapData, "MapCard", false) end
    end
end

local function BuildTargetTab(tab, UI)
    RunSimple(tab, "Combat", TARGET_MAIN, UI)

    local spyTab = MakeOpen(tab, T("open.spy"), "👁️") or tab
    RunSimple(spyTab, "Combat", TARGET_SPY, UI)

    local funTab = MakeOpen(tab, T("open.fun"), "😂") or tab
    if funTab ~= tab then MakeExclusiveGroup(funTab) end
    RunSimple(funTab, "Combat", TARGET_FUN, UI)

    local tricksTab = MakeOpen(tab, T("open.tricks"), "🎭") or tab
    RunSimple(tricksTab, "Combat", TARGET_TRICKS, UI)
end

local function BuildOtherTab(tab, data, UI)
    RunModules(tab, data.Folder, OTHER_LIST, UI)

    local buildTab = MakeOpen(tab, T("other.build.tab"), "🏗️") or tab
    RunSimple(buildTab, "Other", {"build"}, UI)
    pcall(function() tab:AddLine() end)
end

-- ============================================================
-- 10) إعادة الدخول للسيرفر بعد تغيير اللغة
-- ============================================================
local function RejoinForLanguage()
    -- بدون شرط: تغيير اللغة لازم يعيد التشغيل حتى لو التشغيل التلقائي مطفي.
    -- ولو التشغيل التلقائي مفعّل، النسخة المكررة تتجاهل نفسها بصمت.
    -- (بدون queue_on_teleport ينتقل اللاعب بس والسكربت يتشغّل يدوياً بعدها)
    QueueOnTeleport(BuildLoader(false))

    Notify(T("lang.rejoining"))
    local sameOk, sameErr = pcall(function()
        return TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end)
    if sameOk then return end

    Notify(T("lang.hopping"))
    local hopOk = false
    pcall(function()
        local cursor = ""
        for _ = 1, 4 do
            local apiUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
            local res = HttpFetch(apiUrl)
            if not res or res == "" then break end
            local data = HttpService:JSONDecode(res)
            if data and data.data then
                for _, srv in ipairs(data.data) do
                    if srv.id ~= game.JobId
                       and type(srv.playing) == "number"
                       and type(srv.maxPlayers) == "number"
                       and srv.playing < srv.maxPlayers then
                        local ok = pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, lp)
                        end)
                        if ok then hopOk = true return end
                    end
                end
                if data.nextPageCursor and data.nextPageCursor ~= "" then
                    cursor = data.nextPageCursor
                else break end
            else break end
        end
    end)
    if hopOk then return end

    Notify(T("lang.fail"))
end

-- ============================================================
-- 11) تشغيل الواجهة والبوابة الرئيسية
-- ============================================================
local function StartCrypticHub()
    if env.CrypticHub_UIStarted then return end
    if env.CrypticHub_Window then
        local existing = env.CrypticHub_Window
        local destroyed = false
        pcall(function() if IsFn(existing.Destroy) then existing:Destroy(); destroyed = true end end)
        if not destroyed then
            Notify("Cryptic Hub window is already open")
            return
        end
        env.CrypticHub_Window = nil
    end
    InjectMapTab()

    local UI = Import("UI/Core.lua")
    if not UI then
        Notify("Failed to load UI - check your internet and try again")
        env.CrypticHub_Booting = false
        env.CrypticHub_Loaded = false
        env.CrypticHub_Player = nil
        return
    end

    local okWin, MainWin = pcall(function()
        return UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    end)
    if not okWin or not MainWin then
        warn("Cryptic Hub: CreateWindow failed - " .. tostring(MainWin))
        Notify("Failed to create the window")
        env.CrypticHub_Booting = false
        env.CrypticHub_Loaded = false
        env.CrypticHub_Player = nil
        return
    end
    env.CrypticHub_Window = MainWin
    env.CrypticHub_UIStarted = true
    env.CrypticHub_Booting = false

    env.CrypticOpenLangPicker = function()
        local Picker = Import("UI/LanguagePicker.lua")
        if Picker and i18n then
            pcall(function()
                Picker.Show(i18n, function(code)
                    if not code then return end
                    if code == i18n.Get() then return end
                    pcall(function() i18n.Set(code) end)
                    RejoinForLanguage()
                end, { closable = true, preselected = i18n.Get() })
            end)
        end
    end

    -- أزرار كل التابات تظهر فوراً (رخيص)، والمحتوى ينبني بعدها بالترتيب
    local tabs = {}
    for _, tabId in ipairs(Cryptic.TabsOrder) do
        local tabData = Cryptic.Structure[tabId]
        if tabData then
            local okTab, tab = pcall(function()
                return MainWin:CreateTab(TabDisplayName(tabId), TabIcon(tabId))
            end)
            if okTab and tab then
                AttachElements(tab, TAB_ELEMENTS)
                table.insert(tabs, { id = tabId, data = tabData, tab = tab })
            else
                warn("Cryptic Hub: CreateTab failed - " .. tostring(tabId))
            end
        end
    end

    -- بناء المحتوى تاب ورا تاب بخيط واحد: الملفات جاهزة من التحميل المسبق،
    -- والتنفس بين الملفات يمنع اللاق. أي تاب أو موديول يفشل ما يوقف الباقي.
    Spawn(function()
        for _, entry in ipairs(tabs) do
            local ok, err = pcall(function()
                if entry.data._isMapTab and entry.data._mapData then
                    BuildMapTab(entry.tab, entry.data._mapData, UI)
                elseif entry.id == "target" then
                    BuildTargetTab(entry.tab, UI)
                elseif entry.id == "other" then
                    BuildOtherTab(entry.tab, entry.data, UI)
                else
                    RunModules(entry.tab, entry.data.Folder, entry.data.Files, UI)
                end
            end)
            if not ok then
                warn("Cryptic Hub: tab failed - " .. tostring(entry.id) .. " - " .. tostring(err))
            end
        end
        ReleaseUnused()
    end)
end

-- فحص صندوق الرسائل (Inbox)
local function RunInboxCheck()
    Spawn(function()
        local CheckInbox = Import("Modules/Inbox.lua")
        if type(CheckInbox) == "function" then
            local ok, err = pcall(CheckInbox, Cryptic.Config)
            if not ok then warn("Cryptic Hub: inbox error - " .. tostring(err)) end
        end
    end)
end

local function Boot()
    if not LoadFn then
        Notify("This executor cannot load remote Lua modules")
        env.CrypticHub_Booting = false
        env.CrypticHub_Loaded = false
        env.CrypticHub_Player = nil
        env.CrypticHub_StartAt = nil
        return
    end
    -- لو التشغيل التلقائي مفعّل نجهّزه للنقلة الجاية
    if AutoExecEnabled() then ArmAutoExec() end

    -- نبدأ تحميل كل الملفات بالتوازي من الحين (حتى أثناء اختيار اللغة)
    ResetForReboot()
    BuildStructure()
    Prefetch(CollectPaths())

    RunInboxCheck()

    if not i18n then
        StartCrypticHub()
        return
    end

    local hasSaved = false
    pcall(function() hasSaved = i18n.HasSaved() == true end)
    if hasSaved then
        StartCrypticHub()
        return
    end

    local Picker = Import("UI/LanguagePicker.lua")
    if not Picker then
        StartCrypticHub()
        return
    end

    local okPick = pcall(function()
        Picker.Show(i18n, function(code)
            if code then pcall(function() i18n.Set(code) end) end
            StartCrypticHub()
        end, { closable = false })
    end)
    if not okPick then StartCrypticHub() end
end

-- القفل حُجز في بداية الملف. لا ننشئ واجهة ثانية في الجلسة نفسها.
if env.CrypticHub_Booting then
    Boot()
end
