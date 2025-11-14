# TioNova - نظام التحديثات المباشر

## نظرة عامة

تم تهيئة التطبيق بنظام تحديثات مباشر لتوزيع APK خارج Google Play Store.

## 🎯 الميزات

### 1. **فحص تلقائي للتحديثات**
- يفحص عند فتح التطبيق
- فحص دوري كل 6 ساعات
- رسائل واضحة للمستخدم

### 2. **تحميل تلقائي للتحديثات**
- تحميل APK مع progress bar
- يدعم استكمال التحميل
- حجم الملف يظهر قبل التحميل

### 3. **تثبيت سلس**
- تثبيت APK تلقائي
- أذونات التثبيت تُطلب تلقائياً
- دعم Android 8+

### 4. **تحديثات إلزامية**
- يمكنك إجبار المستخدمين على التحديث
- يمنع استخدام التطبيق بدون تحديث
- مفيد للتحديثات الأمنية

## 📋 المتطلبات

### Backend API

يجب أن يكون لديك API endpoint يعود بهذا الشكل:

```
GET https://your-api.com/api/check-update?current_version=1.0.0&current_build=1&platform=android
```

**Response Example:**
```json
{
  "update_available": true,
  "latest_version": "1.0.1",
  "latest_build_number": 2,
  "download_url": "https://your-server.com/tionova-latest.apk",
  "release_notes": "• إصلاحات أخطاء\n• تحسينات الأداء",
  "file_size_mb": 93.5,
  "is_mandatory": false
}
```

راجع [`DIRECT_APK_UPDATE_GUIDE.md`](DIRECT_APK_UPDATE_GUIDE.md) لأمثلة كاملة على Backend.

## ⚙️ التكوين

### 1. تحديث API URL

في الملف `lib/core/services/app_update_service.dart`:

```dart
static const String _updateCheckUrl = 'https://YOUR-ACTUAL-API.com/api/check-update';
```

### 2. رفع APK على السيرفر

بعد بناء APK:
```bash
flutter build apk --release
```

ارفع الملف من:
```
build/app/outputs/flutter-apk/app-release.apk
```

على سيرفرك في:
```
https://your-server.com/downloads/tionova-latest.apk
```

### 3. تحديث Backend

حدث معلومات النسخة في Backend API:
- `latest_version`: "1.0.1"
- `latest_build_number`: 2
- `download_url`: "https://..."
- `release_notes`: "..."
- `file_size_mb`: 93.5
- `is_mandatory`: false

## 🚀 الاستخدام

### للمستخدمين:

1. **فتح التطبيق** - يتم الفحص تلقائياً
2. **إشعار بالتحديث** - يظهر dialog عند توفر تحديث
3. **تحميل التحديث** - اضغط "Update Now"
4. **تثبيت التحديث** - سيفتح APK للتثبيت تلقائياً

### للمطورين:

#### إصدار نسخة جديدة:

```bash
# 1. تحديث version في pubspec.yaml
version: 1.0.1+2  # version+build_number

# 2. بناء APK
flutter build apk --release

# 3. رفع APK على السيرفر
# upload build/app/outputs/flutter-apk/app-release.apk

# 4. تحديث Backend API
# update version info in your backend
```

#### اختبار التحديثات:

```bash
# 1. ثبت نسخة قديمة على الجهاز
flutter build apk --release --build-number=1
# ثبت على الجهاز

# 2. ارفع نسخة جديدة على السيرفر
flutter build apk --release --build-number=2

# 3. حدث Backend API

# 4. افتح التطبيق وستظهر رسالة التحديث
```

## 📁 الملفات المهمة

```
lib/
├── core/
│   ├── services/
│   │   ├── app_update_service.dart       # خدمة التحديثات الرئيسية
│   │   └── shorebird_service.dart        # (للـ Play Store فقط)
│   └── widgets/
│       └── update_checker_widget.dart    # Widget فحص التحديثات
├── main.dart                              # تهيئة الخدمة
└── ...

android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml        # أذونات التثبيت

DIRECT_APK_UPDATE_GUIDE.md                 # دليل شامل مع أمثلة Backend
```

## 🔒 الأذونات المطلوبة

تم إضافة الأذونات تلقائياً في `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

## ⚠️ ملاحظات مهمة

### للمستخدمين:
- يجب تفعيل "تثبيت من مصادر غير معروفة" في إعدادات Android
- التطبيق يطلب الإذن تلقائياً عند أول تحديث

### للمطورين:
- ✅ **Android Only** - لا يعمل على iOS
- ✅ **خارج Play Store** - للتوزيع المباشر فقط
- ✅ **نفس التوقيع** - استخدم نفس مفتاح التوقيع لكل النسخ
- ✅ **HTTPS** - استخدم HTTPS للأمان

## 🎨 تخصيص UI

يمكنك تخصيص رسائل التحديث في:
- `AppUpdateService.showUpdateDialog()` - dialog التحديث
- `AppUpdateService.showDownloadingDialog()` - dialog التحميل

## 📊 Monitoring

لتتبع التحديثات، أضف analytics في:
```dart
// في app_update_service.dart
Future<UpdateInfo?> checkForUpdate() async {
  // أضف هنا
  analytics.logEvent('update_check_started');
  
  // ...
  
  if (updateInfo != null) {
    analytics.logEvent('update_available', parameters: {
      'version': updateInfo.latestVersion,
    });
  }
}
```

## 🐛 Troubleshooting

### المشكلة: لا تظهر رسالة التحديث
**الحل:**
1. تحقق من API URL في `app_update_service.dart`
2. تحقق من أن Backend يعود بـ response صحيح
3. افحص logs: ابحث عن "UpdateChecker" أو "AppUpdateService"

### المشكلة: فشل التحميل
**الحل:**
1. تحقق من أن download_url صحيح ومتاح
2. تحقق من أذونات Storage
3. تحقق من مساحة التخزين المتاحة

### المشكلة: فشل التثبيت
**الحل:**
1. تحقق من أن APK موقع بنفس المفتاح
2. تحقق من إذن REQUEST_INSTALL_PACKAGES
3. اطلب من المستخدم تفعيل "مصادر غير معروفة"

## 📚 مصادر إضافية

- [DIRECT_APK_UPDATE_GUIDE.md](DIRECT_APK_UPDATE_GUIDE.md) - دليل شامل مع أمثلة Backend
- [Android Package Installer](https://developer.android.com/reference/android/content/pm/PackageInstaller)
- [Flutter Permission Handler](https://pub.dev/packages/permission_handler)

## 💡 Tips

1. **اختبر دائماً** على أجهزة حقيقية، ليس emulator
2. **احتفظ بنسخ قديمة** لاختبار upgrade path
3. **استخدم is_mandatory** للتحديثات المهمة فقط
4. **أضف release_notes** واضحة لكل تحديث
5. **راقب file_size** - لا تجعله كبير جداً

---

**تم التطوير بواسطة:** TioNova Team
**آخر تحديث:** 2025
