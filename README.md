# zahya_antiXSS

[⬇ اقرأ باللغة العربية](#arabic)

---

## English

### The Problem

**XSS** (Cross-Site Scripting) attacks have become increasingly common in FiveM servers. These vulnerabilities allow attackers to execute malicious code in player UIs, posing a risk to server and user security.

### The Solution

**zahya_antiXSS** sanitizes all data sent via `SendNUIMessage` before it reaches the NUI layer. It aims to block approximately **90%** of common XSS attacks.

> **Disclaimer:** This is not the ultimate solution for XSS. Defense in depth is essential.

> **Important:** You must avoid using `innerHTML` in your NUI. Use `textContent` or safe DOM methods instead, as `innerHTML` can execute scripts even with sanitized data.

### About Us

**Zahya Dev (زاهية ديف)** — An Arabic FiveM development team.

- Website: [https://zahya.dev/](https://zahya.dev/)
- Discord: [discord.zahya.dev](https://discord.zahya.dev)

### Contributing

You can help the community by adding new features or optimizing the script. Contributions are welcome via Discord or the repository.

---

### How to Use

#### 1. Installation

- [Download](https://github.com/hamada65/zahya_antiXSS/archive/refs/heads/main.zip) from GitHub, extract, and place the folder inside `resources`. If the folder is named `zahya_antiXSS-main`, rename it to `zahya_antiXSS`
- Add at the **top** of `server.cfg`:

```cfg
add_filesystem_permission zahya_antiXSS write *
ensure zahya_antiXSS
```

**Important:** This resource must start **first** before other resources.

#### 2. Install Protection on Resources

The script **automatically** adds `shared_script` to all resources when the server starts. If it didn't install (e.g. due to permissions), run from the **server console**:

```
zahyaxss install
```

#### 3. Uninstall

To remove protection from resources:

```
zahyaxss uninstall
```

---

### Configuration

**checker.lua** — Edit the `Config` table at the top:

| Setting | Description |
|---------|-------------|
| `allowed_tags` | Whitelist of allowed HTML tags (font, span, div, ...) |
| `skipped_scripts` | Resources that skip sanitization at runtime |
| `debug` | When `true`, prints blocked content to F8 console |

**server/command.js** — Install bypass (resources that never get the checker installed). Edit `BYPASS_RESOURCES`:

```javascript
const BYPASS_RESOURCES = [
  'my_trusted_ui',
  'another_resource',
];
```

---

### Notes

- Commands are server-console only
- You may need `add_filesystem_permission zahya_antiXSS write *` in `server.cfg` in some artifact versions
- The script auto-installs on every server start

---

<a id="arabic"></a>

## العربية

### المشكلة

في الآونة الأخيرة، أصبحت هجمات **XSS** (Cross-Site Scripting) شائعة جداً في سيرفرات FiveM. هذه الثغرات تسمح للمهاجمين بتنفيذ أكواد خبيثة في واجهات اللاعبين، مما يشكل خطراً على أمان السيرفر والمستخدمين.

### الحل

**zahya_antiXSS** هو سكربت حماية يعمل على تعقيم جميع البيانات المرسلة عبر `SendNUIMessage` قبل وصولها لواجهة NUI. الهدف هو تقليل ما يقارب **90%** من هجمات XSS الشائعة.

> **تنبيه:** هذا ليس الحل الأمثل لثغرات XSS. الحماية المتعددة الطبقات ضرورية.

> **مهم:** يجب تجنب استخدام `innerHTML` في واجهة NUI. استخدم `textContent` أو دوال DOM الآمنة بدلاً منها، لأن `innerHTML` قد ينفذ أكواد حتى مع البيانات المعقمة.

### من نحن

**زاهية ديف (Zahya Dev)** — فريق تطوير عربي متخصص في FiveM.

- الموقع: [https://zahya.dev/](https://zahya.dev/)
- ديسكورد: [discord.zahya.dev](https://discord.zahya.dev)

### المساهمة

يمكنك مساعدة المجتمع بإضافة ميزات جديدة أو تحسين أداء السكربت. نرحب بمساهماتكم عبر الديسكورد.

---

### طريقة الاستخدام

#### 1. التثبيت

- [حمّل](https://github.com/hamada65/zahya_antiXSS/archive/refs/heads/main.zip) من GitHub، فك الضغط، وضع المجلد داخل `resources`. إذا كان اسم المجلد `zahya_antiXSS-main` غيّره إلى `zahya_antiXSS`
- أضف في بداية `server.cfg`:

```cfg
add_filesystem_permission zahya_antiXSS write *
ensure zahya_antiXSS
```

**مهم:** يجب تشغيل السكربت **أولاً** قبل باقي السكربتات.

#### 2. تثبيت الحماية على السكربتات

السكربت يضيف `shared_script` **تلقائياً** لجميع السكربتات عند تشغيل السيرفر. إذا لم يتم التثبيت (مثلاً بسبب الصلاحيات)، نفّذ من **كونسول السيرفر**:

```
zahyaxss install
```

#### 3. إلغاء التثبيت

لإزالة الحماية من السكربتات:

```
zahyaxss uninstall
```

---

### الإعدادات

**checker.lua** — عدّل جدول `Config` في بداية الملف:

| الإعداد | الوصف |
|--------|-------|
| `allowed_tags` | قائمة التاق المسموح بها (font, span, div, ...) |
| `skipped_scripts` | السكربتات المستثناة من التعقيم أثناء التشغيل |
| `debug` | عند `true` يطبع المحتوى الخطير في كونسول F8 |

**server/command.js** — استثناء التثبيت (سكربتات لا تُثبَّت عليها الحماية أبداً). عدّل `BYPASS_RESOURCES`:

```javascript
const BYPASS_RESOURCES = [
  'my_trusted_ui',
  'another_resource',
];
```

---

### ملاحظات

- الأوامر تعمل من كونسول السيرفر فقط
- قد تحتاج `add_filesystem_permission zahya_antiXSS write *` في `server.cfg` في بعض نسخ artifact
- السكربت يعيد التثبيت تلقائياً عند كل تشغيل للسيرفر
