-- Cryptic Hub - UI/ma.lua (ترجمات رسائل الإشراف لشات الـ Global — 21 لغة)
-- نصوص: تحذير الكلمة الممنوعة (ban_warn) · الإهانة الخفيفة (soft_hit) · المحظور من الشات (chat_banned)
-- لتعديل نص: غيّره تحت اللغة المطلوبة. لإضافة نص جديد: ضيف المفتاح لكل اللغات، واستدعيه  M("key", "English default", {vars}).
-- اللغة: من env.CrypticI18n (نظامكم العام) إذا موجود، وإلا من لغة روبلوكس عند اللاعب (RobloxLocaleId).
local env = (getgenv and getgenv()) or {}
local D = {}
-- en · English
D.en = {
    ban_warn = "Not sent — banned word: “{w}”. Warning: next time you'll be muted.",
    soft_hit = "Not sent — please keep it respectful (“{w}”).",
    chat_banned = "You are banned from using Cryptic Global Chat.",
}
-- ar · العربية
D.ar = {
    ban_warn = "لم تُرسل — كلمة ممنوعة: «{w}». تحذير: في المرة القادمة سيتم كتمك.",
    soft_hit = "لم تُرسل — رجاءً التزم بالاحترام («{w}»).",
    chat_banned = "أنت محظور من استخدام دردشة Cryptic العامة.",
}
-- ru · Русский
D.ru = {
    ban_warn = "Не отправлено — запрещённое слово: «{w}». Предупреждение: в следующий раз вы получите мут.",
    soft_hit = "Не отправлено — пожалуйста, соблюдайте уважение («{w}»).",
    chat_banned = "Вам запрещено использовать глобальный чат Cryptic.",
}
-- pt · Português
D.pt = {
    ban_warn = "Não enviada — palavra proibida: “{w}”. Aviso: da próxima vez você será silenciado.",
    soft_hit = "Não enviada — mantenha o respeito (“{w}”).",
    chat_banned = "Você está banido de usar o chat global do Cryptic.",
}
-- es · Español
D.es = {
    ban_warn = "No enviado — palabra prohibida: “{w}”. Aviso: la próxima vez serás silenciado.",
    soft_hit = "No enviado — por favor, mantén el respeto (“{w}”).",
    chat_banned = "Tienes prohibido usar el chat global de Cryptic.",
}
-- fr · Français
D.fr = {
    ban_warn = "Non envoyé — mot interdit : « {w} ». Avertissement : la prochaine fois, vous serez mis en sourdine.",
    soft_hit = "Non envoyé — merci de rester respectueux (« {w} »).",
    chat_banned = "Vous êtes banni du chat global de Cryptic.",
}
-- id · Indonesia
D.id = {
    ban_warn = "Tidak terkirim — kata terlarang: “{w}”. Peringatan: lain kali kamu akan dibisukan.",
    soft_hit = "Tidak terkirim — harap tetap sopan (“{w}”).",
    chat_banned = "Kamu dilarang menggunakan chat global Cryptic.",
}
-- fil · Filipino
D.fil = {
    ban_warn = "Hindi naipadala — bawal na salita: “{w}”. Babala: sa susunod ay i-mu-mute ka.",
    soft_hit = "Hindi naipadala — pakiusap, maging magalang (“{w}”).",
    chat_banned = "Bawal kang gumamit ng global chat ng Cryptic.",
}
-- tr · Türkçe
D.tr = {
    ban_warn = "Gönderilmedi — yasaklı kelime: “{w}”. Uyarı: bir dahaki sefere susturulacaksın.",
    soft_hit = "Gönderilmedi — lütfen saygılı ol (“{w}”).",
    chat_banned = "Cryptic genel sohbetini kullanman yasaklandı.",
}
-- hi · हिन्दी
D.hi = {
    ban_warn = "भेजा नहीं गया — प्रतिबंधित शब्द: “{w}”। चेतावनी: अगली बार आपको म्यूट कर दिया जाएगा।",
    soft_hit = "भेजा नहीं गया — कृपया सम्मानजनक रहें (“{w}”)।",
    chat_banned = "आपको Cryptic ग्लोबल चैट इस्तेमाल करने से प्रतिबंधित किया गया है।",
}
-- de · Deutsch
D.de = {
    ban_warn = "Nicht gesendet — verbotenes Wort: „{w}“. Warnung: Beim nächsten Mal wirst du stummgeschaltet.",
    soft_hit = "Nicht gesendet — bitte bleib respektvoll („{w}“).",
    chat_banned = "Du bist von der Nutzung des Cryptic-Globalchats ausgeschlossen.",
}
-- nl · Nederlands
D.nl = {
    ban_warn = "Niet verzonden — verboden woord: “{w}”. Waarschuwing: de volgende keer word je gedempt.",
    soft_hit = "Niet verzonden — blijf alsjeblieft respectvol (“{w}”).",
    chat_banned = "Je bent verbannen van het gebruik van de Cryptic-globale chat.",
}
-- pl · Polski
D.pl = {
    ban_warn = "Nie wysłano — zakazane słowo: „{w}”. Ostrzeżenie: następnym razem zostaniesz wyciszony.",
    soft_hit = "Nie wysłano — zachowaj szacunek („{w}”).",
    chat_banned = "Masz zakaz korzystania z globalnego czatu Cryptic.",
}
-- uk · Українська
D.uk = {
    ban_warn = "Не надіслано — заборонене слово: «{w}». Попередження: наступного разу ви отримаєте мут.",
    soft_hit = "Не надіслано — будь ласка, поважайте інших («{w}»).",
    chat_banned = "Вам заборонено користуватися глобальним чатом Cryptic.",
}
-- it · Italiano
D.it = {
    ban_warn = "Non inviato — parola vietata: “{w}”. Avviso: la prossima volta verrai silenziato.",
    soft_hit = "Non inviato — per favore, sii rispettoso (“{w}”).",
    chat_banned = "Ti è vietato usare la chat globale di Cryptic.",
}
-- vi · Tiếng Việt
D.vi = {
    ban_warn = "Chưa gửi — từ bị cấm: “{w}”. Cảnh báo: lần sau bạn sẽ bị tắt tiếng.",
    soft_hit = "Chưa gửi — vui lòng giữ thái độ tôn trọng (“{w}”).",
    chat_banned = "Bạn bị cấm sử dụng chat toàn cục của Cryptic.",
}
-- th · ไทย
D.th = {
    ban_warn = "ไม่ได้ส่ง — คำต้องห้าม: “{w}” คำเตือน: ครั้งหน้าคุณจะถูกปิดเสียง",
    soft_hit = "ไม่ได้ส่ง — กรุณาใช้คำที่สุภาพ (“{w}”)",
    chat_banned = "คุณถูกห้ามใช้แชตส่วนกลางของ Cryptic",
}
-- zh · 简体中文
D.zh = {
    ban_warn = "未发送 — 违禁词：“{w}”。警告：下次将被禁言。",
    soft_hit = "未发送 — 请保持礼貌（“{w}”）。",
    chat_banned = "你已被禁止使用 Cryptic 全局聊天。",
}
-- tw · 繁體中文
D.tw = {
    ban_warn = "未傳送 — 違禁詞：「{w}」。警告：下次將被禁言。",
    soft_hit = "未傳送 — 請保持禮貌（「{w}」）。",
    chat_banned = "你已被禁止使用 Cryptic 全域聊天。",
}
-- ko · 한국어
D.ko = {
    ban_warn = "전송 안 됨 — 금지어: “{w}”. 경고: 다음에는 채팅이 금지됩니다.",
    soft_hit = "전송 안 됨 — 예의를 지켜 주세요 (“{w}”).",
    chat_banned = "Cryptic 글로벌 채팅 사용이 금지되었습니다.",
}
-- ja · 日本語
D.ja = {
    ban_warn = "送信されませんでした — 禁止ワード：「{w}」。警告：次回はミュートされます。",
    soft_hit = "送信されませんでした — 礼儀正しくお願いします（「{w}」）。",
    chat_banned = "Cryptic グローバルチャットの利用を禁止されています。",
}

local function Norm(c)
    c = tostring(c or "en"):lower():gsub("_", "-")
    if c == "zh-tw" or c == "zh-hk" or c == "zh-hant" then return "tw" end
    if c == "tl" or c:sub(1, 3) == "fil" or c:sub(1, 3) == "tl-" then return "fil" end
    if D[c] then return c end
    c = c:sub(1, 2)
    if c == "zh" then return "zh" end
    return D[c] and c or "en"
end

local function Lang()
    local i = env.CrypticI18n
    local c
    if i and i.Get then pcall(function() c = tostring(i.Get()) end) end
    if not c or c == "" or c == "nil" then
        pcall(function() c = game:GetService("LocalizationService").RobloxLocaleId end)
    end
    if not c or c == "" then pcall(function() c = game:GetService("Players").LocalPlayer.LocaleId end) end
    return Norm(c)
end

local function Fmt(s, v)
    if v then
        s = s:gsub("{(%w+)}", function(k)
            local x = v[k]
            if x ~= nil then return tostring(x) end
        end)
    end
    return s
end

-- M(key, default, vars)
local function M(k, def, vars)
    local s
    local i = env.CrypticI18n
    if i and i.T then
        local ok, v = pcall(i.T, "chat." .. k)
        if ok and type(v) == "string" and v ~= "chat." .. k then s = v end
    end
    if not s then
        local t = D[Lang()] or D.en
        s = t[k] or D.en[k] or def or k
    end
    return Fmt(s, vars)
end

return {T = M, Lang = Lang, Data = D}
