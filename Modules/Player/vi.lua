-- [[ Cryptic Hub - Global Chat (Maintenance Placeholder) ]]
-- توقل وهمي للشات: مقفول دايماً ومحد يقدر يفتحه لين تخلص الصيانة.
-- ارجع حط سكربت الشات الحقيقي (cryptic_global_chat_v4.lua) مكان هذا الملف لما تخلص.
-- الترجمات مدمجة (21 لغة) بنفس نظام PlayerSelector / MapCard.

local StarterGui = game:GetService("StarterGui")
local env = getgenv()

return function(Tab, UI)
    -- ============ الترجمات المدمجة (21 لغة) ============
    local L = {
        en = {locked="🛠 Under maintenance", notify="Chat is under maintenance, please try again later"},
        ar = {locked="🛠 تحت الصيانة", notify="الشات تحت الصيانة، حاول مرة ثانية لاحقاً"},
        ru = {locked="🛠 На обслуживании", notify="Чат на обслуживании, попробуйте позже"},
        pt = {locked="🛠 Em manutenção", notify="O chat está em manutenção, tente novamente mais tarde"},
        es = {locked="🛠 En mantenimiento", notify="El chat está en mantenimiento, inténtalo más tarde"},
        fr = {locked="🛠 En maintenance", notify="Le chat est en maintenance, réessayez plus tard"},
        id = {locked="🛠 Sedang perbaikan", notify="Obrolan sedang dalam perbaikan, coba lagi nanti"},
        fil = {locked="🛠 Under maintenance", notify="Under maintenance ang chat, subukan ulit mamaya"},
        tr = {locked="🛠 Bakımda", notify="Sohbet bakımda, lütfen daha sonra tekrar deneyin"},
        hi = {locked="🛠 रखरखाव जारी है", notify="चैट रखरखाव में है, कृपया बाद में पुनः प्रयास करें"},
        de = {locked="🛠 Wartungsarbeiten", notify="Der Chat wird gewartet, bitte versuche es später erneut"},
        nl = {locked="🛠 In onderhoud", notify="De chat is in onderhoud, probeer het later opnieuw"},
        pl = {locked="🛠 Konserwacja", notify="Czat jest w trakcie konserwacji, spróbuj ponownie później"},
        uk = {locked="🛠 Технічне обслуговування", notify="Чат на технічному обслуговуванні, спробуйте пізніше"},
        it = {locked="🛠 In manutenzione", notify="La chat è in manutenzione, riprova più tardi"},
        vi = {locked="🛠 Đang bảo trì", notify="Chat đang bảo trì, vui lòng thử lại sau"},
        th = {locked="🛠 อยู่ระหว่างปรับปรุง", notify="แชทอยู่ระหว่างปรับปรุง โปรดลองใหม่ภายหลัง"},
        zh = {locked="🛠 维护中", notify="聊天正在维护中，请稍后再试"},
        tw = {locked="🛠 維護中", notify="聊天正在維護中，請稍後再試"},
        ko = {locked="🛠 점검 중", notify="채팅이 점검 중입니다. 나중에 다시 시도해 주세요"},
        ja = {locked="🛠 メンテナンス中", notify="チャットはメンテナンス中です。後でもう一度お試しください"},
    }

    -- يستخدم مفتاح i18n لو موجود، وإلا الترجمة المدمجة حسب لغة الواجهة
    local function TT(k)
        local i = env.CrypticI18n
        if i and i.T then
            local ok, v = pcall(i.T, "chat.maintenance_" .. k)
            if ok and type(v) == "string" and v ~= "chat.maintenance_" .. k then return v end
        end
        local c = "en"
        if i and i.Get then pcall(function() c = tostring(i.Get()) end) end
        c = c:lower()
        local t = L[c] or L[c:sub(1, 2)] or L.en
        return t[k] or L.en[k]
    end

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 3,
            })
        end)
    end

    local toggleRef

    local function Lock()
        if not toggleRef then return end
        pcall(function() toggleRef:SetState(false) end)
        pcall(function() toggleRef:SetLocked(true) end)
    end

    -- نفس اسم التوقل الأصلي عشان يبان مكانه
    toggleRef = Tab:AddLockedToggle("Global script chat", TT("locked"), function(active)
        -- احتياط: لو أي تعديل في الـ UI فتحه بالغلط، نرجعه مقفول
        if active then
            Notify(TT("notify"))
            task.defer(Lock)
        end
    end)

    -- قفل دائم من البداية + تأكيد بعد ما الواجهة تخلص تحميل
    task.defer(Lock)
    task.delay(1.5, Lock)
end
