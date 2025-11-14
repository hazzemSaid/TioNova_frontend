# 🚀 Shorebird Code Push - دليل الاستخدام الكامل

## نظرة عامة

**Shorebird Code Push** يتيح لك إرسال تحديثات فورية للتطبيق بدون Google Play Store!

### ✅ المزايا:
- 📱 **توزيع مباشر**: ارسل APK عبر WhatsApp، Telegram، Email
- ⚡ **تحديثات فورية**: patches صغيرة (<300 KB) بدون إعادة تثبيت
- 🆓 **مجاني تماماً**: لا رسوم متاجر
- 🚫 **بدون Google Play**: يعمل مع أي طريقة توزيع

## 📋 المتطلبات

### 1. تثبيت Shorebird CLI

```bash
# Windows
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' -OutFile '$env:TEMP\install.ps1'; & $env:TEMP\install.ps1'"

# macOS/Linux
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

### 2. تسجيل الدخول

```bash
shorebird login
```

### 3. التحقق من التثبيت

```bash
shorebird doctor
```

## 🎯 السيناريو الكامل

### المرحلة 1: بناء ونشر Release الأولي

#### 1. بناء أول إصدار

```bash
# تأكد من version في pubspec.yaml
# version: 1.0.0+1

# بناء Release مع Shorebird
shorebird release android
```

**ما يحدث:**
- يبني Shorebird APK كامل
- يرفعه على خوادم Shorebird
- يسجل Release version: 1.0.0+1
- يحفظ App Bundle للمقارنة المستقبلية

**Output:**
```
✅ Published Release 1.0.0+1!
Your next step is to distribute the APK:
E:\TioNova_frontend\build\app\outputs\flutter-apk\app-release.apk
```

#### 2. توزيع APK للمستخدمين

**طرق التوزيع:**

**Option A: WhatsApp/Telegram**
```
1. افتح WhatsApp
2. أرسل app-release.apk
3. المستخدمون يحملون ويثبتون
```

**Option B: Google Drive/Dropbox**
```
1. ارفع APK على Drive
2. اجعله Public/Anyone with link
3. شارك الرابط مع المستخدمين
```

**Option C: سيرفرك الخاص**
```
1. ارفع APK على سيرفرك
2. وفر رابط تحميل مباشر
3. مثال: https://your-domain.com/tionova-v1.0.0.apk
```

**Option D: Email**
```
1. أرفق APK في email (إذا الحجم مناسب)
2. أرسل للمستخدمين
```

#### 3. المستخدمون يثبتون APK

**خطوات المستخدم:**

1. **تحميل APK** من الرابط/الرسالة
2. **فتح الملف** - Android سيطلب أذونات
3. **السماح بـ "مصادر غير معروفة"** (أول مرة فقط)
   ```
   Settings → Security → Unknown sources → Enable
   أو
   Settings → Apps → Special access → Install unknown apps → Browser → Allow
   ```
4. **تثبيت التطبيق** - اضغط Install
5. **فتح التطبيق** - جاهز للاستخدام!

### المرحلة 2: إرسال Patch (تحديث صغير)

#### سيناريو: اكتشفت bug وتريد إصلاحه فوراً

#### 1. إصلاح المشكلة في الكود

```dart
// مثال: أصلحت خطأ في lib/features/quiz/quiz_screen.dart
void submitAnswer() {
  // ❌ الكود القديم
  // if (answer = correctAnswer) { // خطأ مطبعي
  
  // ✅ الكود الجديد
  if (answer == correctAnswer) {
    // ...
  }
}
```

#### 2. بناء ونشر Patch

```bash
# بناء patch جديد (نفس الـ release version)
shorebird patch android --release-version=1.0.0+1
```

**ما يحدث:**
- Shorebird يبني الكود الجديد
- يقارنه بالـ release الأصلي
- يستخرج الفروقات فقط (patch صغير)
- يرفع الـ patch على الخوادم

**Output:**
```
✅ Published Patch 1!

📱 App: tionova
📦 Release Version: 1.0.0+1
🕹️  Platform: Android
   - arm32 (277 KB)
   - arm64 (262 KB)
   - x86_64 (243 KB)
```

#### 3. المستخدمون يستلمون التحديث تلقائياً

**ما يحدث عند المستخدم:**

1. **المستخدم يفتح التطبيق**
   ```
   ShorebirdService يفحص تلقائياً:
   "هل يوجد patch جديد؟"
   ```

2. **يظهر Dialog**
   ```
   ╔═══════════════════════════╗
   ║  🔄 تحديث متاح           ║
   ║                           ║
   ║  يتوفر إصدار جديد من     ║
   ║  TioNova مع تحسينات      ║
   ║  وإصلاحات.               ║
   ║                           ║
   ║  ℹ️ سيتم تطبيق التحديث   ║
   ║  عند إعادة التشغيل       ║
   ║                           ║
   ║  [لاحقاً]  [تحديث الآن]   ║
   ╚═══════════════════════════╝
   ```

3. **إذا اختار "تحديث الآن"**
   ```
   ⬇️ يتم التحميل في الخلفية
   ✅ تم التحميل بنجاح
   🔄 يطلب إعادة تشغيل التطبيق
   ```

4. **إعادة التشغيل**
   ```
   المستخدم يغلق ويفتح التطبيق
   ✨ Patch مطبق تلقائياً!
   🎉 التطبيق محدث مع الإصلاحات
   ```

### المرحلة 3: Release جديد (تغيير رئيسي)

#### متى تستخدم Release جديد؟

- ✅ **تغيير native code** (Android/iOS)
- ✅ **إضافة permissions جديدة**
- ✅ **تغيير version number**
- ✅ **إضافة dependencies جديدة**

#### الخطوات:

1. **تحديث version في pubspec.yaml**
   ```yaml
   version: 1.0.1+2  # من 1.0.0+1
   ```

2. **بناء Release جديد**
   ```bash
   shorebird release android
   ```

3. **توزيع APK الجديد**
   - نفس طرق التوزيع السابقة
   - المستخدمون يحملون APK جديد
   - يثبتونه فوق النسخة القديمة (upgrade)

## 🔍 فحص الحالة

### معلومات التطبيق

```bash
# قائمة التطبيقات
shorebird apps list

# تفاصيل التطبيق
shorebird apps show
```

### معلومات Releases

```bash
# قائمة جميع Releases
shorebird releases list

# تفاصيل release معين
shorebird releases info --release-version=1.0.0+1
```

### معلومات Patches

```bash
# قائمة patches لـ release معين
shorebird patches list --release-version=1.0.0+1

# تفاصيل patch معين
shorebird patches info --patch-number=1 --release-version=1.0.0+1
```

## 🎨 تخصيص السلوك

### تخصيص وقت الفحص

في `update_checker_widget.dart`:

```dart
// الفحص الدوري (افتراضي: كل 30 دقيقة)
_updateCheckTimer = Timer.periodic(
  const Duration(minutes: 30),  // غير هذا
  (_) => _checkForUpdates(),
);
```

### تعطيل Auto-Update

في `shorebird.yaml`:

```yaml
# تعطيل التحديث التلقائي
auto_update: false
```

ثم تحقق يدوياً:

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';

final shorebird = ShorebirdCodePush();
final isAvailable = await shorebird.isNewPatchAvailableForDownload();
if (isAvailable) {
  await shorebird.downloadUpdateIfAvailable();
}
```

## 📊 Best Practices

### 1. اختبار قبل النشر

```bash
# اختبر على جهاز فعلي
flutter build apk --release
# ثبت على جهاز واختبر

# إذا كل شيء تمام:
shorebird release android
```

### 2. Release Notes

احتفظ بسجل للتحديثات:

```markdown
## Version 1.0.1+2 (Patch 1)
- Fixed quiz answer validation bug
- Improved loading performance
- Updated Arabic translations

## Version 1.0.0+1 (Initial Release)
- Initial release
- Core features implemented
```

### 3. Rollback Plan

إذا Patch سبب مشاكل:

```bash
# أنشئ patch جديد مع الكود القديم
# أو
# أصدر release جديد
shorebird release android
```

### 4. تتبع Analytics

```dart
// في app_update_service.dart
Future<void> checkForUpdate() async {
  analytics.logEvent('shorebird_check_started');
  
  final hasUpdate = await _shorebirdService.checkForUpdate();
  
  if (hasUpdate) {
    analytics.logEvent('shorebird_update_available');
  }
}
```

## ⚠️ القيود والمحددات

### ما يمكن تحديثه بـ Patch:

✅ Dart code
✅ Assets (images, fonts, etc.)
✅ Translations
✅ UI changes
✅ Business logic
✅ Bug fixes

### ما لا يمكن تحديثه بـ Patch:

❌ Native Android/iOS code
❌ New permissions
❌ New dependencies (packages)
❌ AndroidManifest.xml changes
❌ Version number changes
❌ Gradle configurations

**الحل:** استخدم Release جديد لهذه التغييرات

## 🐛 Troubleshooting

### المشكلة: "No patch available" دائماً

**الحل:**
```bash
# 1. تحقق من shorebird.yaml
cat shorebird.yaml
# يجب أن يحتوي على app_id

# 2. تحقق من البناء
shorebird doctor

# 3. تحقق من Release
shorebird releases list
```

### المشكلة: Patch لا يطبق على بعض الأجهزة

**السبب:**
- Architecture مختلف (arm32, arm64, x86_64)
- Version مختلف

**الحل:**
```bash
# بناء patch لجميع architectures
shorebird patch android --release-version=1.0.0+1
```

### المشكلة: "Shorebird not available" في release build

**السبب:**
- تم البناء بـ `flutter build` بدلاً من `shorebird release`

**الحل:**
```bash
# استخدم دائماً shorebird CLI
shorebird release android
# ليس flutter build apk --release
```

## 📱 نصائح للمستخدمين النهائيين

### رسالة للمستخدمين:

```
📱 تثبيت تطبيق TioNova

1. حمّل ملف التطبيق (APK)
2. افتح الملف
3. إذا ظهرت رسالة أمان، اسمح بالتثبيت من مصادر غير معروفة
4. اضغط تثبيت
5. افتح التطبيق

🔄 التحديثات التلقائية:
- التطبيق يتحدث تلقائياً
- لا حاجة لتحميل ملفات جديدة
- فقط أعد تشغيل التطبيق عند طلب التحديث
```

## 📈 الخطة المستقبلية

### المرحلة القادمة:

1. **Analytics**: تتبع نسبة المستخدمين المحدثين
2. **Rollout**: نشر تدريجي (10% → 50% → 100%)
3. **A/B Testing**: اختبار features مختلفة
4. **Crash Reporting**: رصد الأخطاء بعد Patch

## 🎯 الخلاصة

### Workflow الكامل:

```
1. تطوير → البناء مع shorebird release
2. توزيع APK → WhatsApp/Drive/etc
3. المستخدمون يثبتون
4. إصلاح bug → shorebird patch
5. المستخدمون يستلمون تلقائياً
6. تكرار 4-5 حسب الحاجة
7. تحديث رئيسي → release جديد (العودة للخطوة 1)
```

### الفوائد الرئيسية:

- 🚀 **سرعة**: تحديثات فورية بدون انتظار
- 💰 **توفير**: لا رسوم متاجر
- 🎯 **مرونة**: تحكم كامل في التوزيع
- 📦 **حجم صغير**: patches أقل من 300 KB
- ✨ **تجربة سلسة**: تحديثات تلقائية للمستخدمين

---

**🎉 Shorebird جاهز للاستخدام! ابدأ بـ `shorebird release android` الآن!**

لأي استفسارات: [Shorebird Discord](https://discord.gg/shorebird)
