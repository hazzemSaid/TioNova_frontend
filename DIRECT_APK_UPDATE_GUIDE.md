# Direct APK Update System - Backend API

## Overview
نظام لتوزيع تحديثات التطبيق مباشرة عبر APK (بدون Google Play Store)

## Required API Endpoint

### Check for Updates
**Endpoint:** `GET /api/check-update`

**Query Parameters:**
- `current_version`: string - النسخة الحالية (مثال: "1.0.0")
- `current_build`: string - رقم البناء الحالي (مثال: "1")
- `platform`: string - المنصة ("android" أو "ios")

**Response (Update Available):**
```json
{
  "update_available": true,
  "latest_version": "1.0.1",
  "latest_build_number": 2,
  "download_url": "https://your-server.com/downloads/tionova-1.0.1.apk",
  "release_notes": "• Fixed bugs\n• Improved performance\n• Added new features",
  "file_size_mb": 93.5,
  "is_mandatory": false,
  "min_required_version": "1.0.0"
}
```

**Response (No Update):**
```json
{
  "update_available": false
}
```

## Backend Implementation Examples

### Option 1: Simple PHP Backend

```php
<?php
// check_update.php

header('Content-Type: application/json');

// Get request parameters
$currentVersion = $_GET['current_version'] ?? '0.0.0';
$currentBuild = intval($_GET['current_build'] ?? '0');
$platform = $_GET['platform'] ?? 'android';

// Latest app info (update this when you release new version)
$latestVersion = '1.0.1';
$latestBuild = 2;
$downloadUrl = 'https://your-server.com/downloads/tionova-latest.apk';
$releaseNotes = "• Fixed critical bugs\n• Improved app stability\n• Enhanced user interface";
$fileSizeMB = 93.5;
$isMandatory = false; // Set to true if users MUST update
$minRequiredVersion = '1.0.0';

// Check if update is needed
$needsUpdate = version_compare($currentVersion, $latestVersion, '<') || 
               ($currentVersion === $latestVersion && $currentBuild < $latestBuild);

$response = [
    'update_available' => $needsUpdate,
];

if ($needsUpdate) {
    $response = array_merge($response, [
        'latest_version' => $latestVersion,
        'latest_build_number' => $latestBuild,
        'download_url' => $downloadUrl,
        'release_notes' => $releaseNotes,
        'file_size_mb' => $fileSizeMB,
        'is_mandatory' => $isMandatory,
        'min_required_version' => $minRequiredVersion,
    ]);
}

echo json_encode($response);
?>
```

### Option 2: Node.js/Express Backend

```javascript
// server.js
const express = require('express');
const app = express();

// Latest app configuration
const latestAppInfo = {
  version: '1.0.1',
  buildNumber: 2,
  downloadUrl: 'https://your-server.com/downloads/tionova-latest.apk',
  releaseNotes: '• Fixed critical bugs\n• Improved app stability\n• Enhanced user interface',
  fileSizeMB: 93.5,
  isMandatory: false,
  minRequiredVersion: '1.0.0'
};

app.get('/api/check-update', (req, res) => {
  const { current_version, current_build, platform } = req.query;
  
  const currentBuild = parseInt(current_build) || 0;
  
  // Simple version comparison
  const needsUpdate = compareVersions(current_version, latestAppInfo.version) < 0 ||
                     (current_version === latestAppInfo.version && currentBuild < latestAppInfo.buildNumber);
  
  if (needsUpdate) {
    res.json({
      update_available: true,
      latest_version: latestAppInfo.version,
      latest_build_number: latestAppInfo.buildNumber,
      download_url: latestAppInfo.downloadUrl,
      release_notes: latestAppInfo.releaseNotes,
      file_size_mb: latestAppInfo.fileSizeMB,
      is_mandatory: latestAppInfo.isMandatory,
      min_required_version: latestAppInfo.minRequiredVersion
    });
  } else {
    res.json({ update_available: false });
  }
});

function compareVersions(v1, v2) {
  const parts1 = v1.split('.').map(Number);
  const parts2 = v2.split('.').map(Number);
  
  for (let i = 0; i < 3; i++) {
    if (parts1[i] > parts2[i]) return 1;
    if (parts1[i] < parts2[i]) return -1;
  }
  return 0;
}

app.listen(3000, () => console.log('Update server running on port 3000'));
```

### Option 3: Python/Flask Backend

```python
# app.py
from flask import Flask, request, jsonify
from packaging import version

app = Flask(__name__)

# Latest app configuration
LATEST_APP_INFO = {
    'version': '1.0.1',
    'build_number': 2,
    'download_url': 'https://your-server.com/downloads/tionova-latest.apk',
    'release_notes': '• Fixed critical bugs\n• Improved app stability\n• Enhanced user interface',
    'file_size_mb': 93.5,
    'is_mandatory': False,
    'min_required_version': '1.0.0'
}

@app.route('/api/check-update', methods=['GET'])
def check_update():
    current_version = request.args.get('current_version', '0.0.0')
    current_build = int(request.args.get('current_build', '0'))
    platform = request.args.get('platform', 'android')
    
    # Check if update is needed
    needs_update = (
        version.parse(current_version) < version.parse(LATEST_APP_INFO['version']) or
        (current_version == LATEST_APP_INFO['version'] and current_build < LATEST_APP_INFO['build_number'])
    )
    
    if needs_update:
        return jsonify({
            'update_available': True,
            'latest_version': LATEST_APP_INFO['version'],
            'latest_build_number': LATEST_APP_INFO['build_number'],
            'download_url': LATEST_APP_INFO['download_url'],
            'release_notes': LATEST_APP_INFO['release_notes'],
            'file_size_mb': LATEST_APP_INFO['file_size_mb'],
            'is_mandatory': LATEST_APP_INFO['is_mandatory'],
            'min_required_version': LATEST_APP_INFO['min_required_version']
        })
    else:
        return jsonify({'update_available': False})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
```

## App Configuration

في الملف `lib/core/services/app_update_service.dart`، قم بتحديث:

```dart
static const String _updateCheckUrl = 'https://your-actual-api.com/api/check-update';
```

## File Hosting Options

### 1. **Self-Hosted Server**
رفع APK على سيرفرك الخاص:
```
https://your-server.com/downloads/tionova-1.0.1.apk
```

### 2. **Firebase Storage**
```dart
// استخدم Firebase Storage للملفات الكبيرة
final downloadUrl = await FirebaseStorage.instance
    .ref('apps/tionova-1.0.1.apk')
    .getDownloadURL();
```

### 3. **AWS S3**
```
https://your-bucket.s3.amazonaws.com/apps/tionova-1.0.1.apk
```

### 4. **Google Drive (Public Link)**
شارك الملف كـ public واحصل على direct download link

## Required Android Permissions

تأكد من إضافة هذه الأذونات في `AndroidManifest.xml`:

```xml
<manifest>
    <!-- للتحميل -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />
    
    <!-- للتثبيت (Android 8+) -->
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    
    <application>
        <!-- للوصول للملفات في Android 7+ -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
```

## Workflow

### 1. عند إصدار نسخة جديدة:
```bash
# 1. بناء APK جديد
flutter build apk --release

# 2. رفع APK على السيرفر
# upload build/app/outputs/flutter-apk/app-release.apk

# 3. تحديث معلومات النسخة في Backend API
# update version number, download URL, release notes
```

### 2. عند فتح التطبيق:
1. التطبيق يفحص API للتحديثات
2. إذا وجد تحديث، يعرض dialog
3. عند موافقة المستخدم، يحمل APK
4. بعد التحميل، يفتح APK للتثبيت
5. المستخدم يثبت التحديث يدوياً

## Testing

```bash
# للاختبار في debug mode
flutter run

# للاختبار الكامل (release mode)
flutter build apk --release
# ثم ثبت APK على جهاز حقيقي
```

## Security Considerations

1. **HTTPS Only:** استخدم HTTPS للـ API وتحميل APK
2. **APK Signing:** تأكد من توقيع جميع APKs بنفس المفتاح
3. **Checksum Verification:** أضف MD5/SHA256 hash للتحقق من صحة الملف
4. **Version Control:** احتفظ بسجل لجميع النسخ المنشورة

## Advantages of This System

✅ **كامل التحكم** - أنت تتحكم بكل شيء
✅ **سريع** - تحديثات فورية بدون موافقة متجر
✅ **مجاني** - لا رسوم متاجر
✅ **مرن** - يمكنك التحديث متى تشاء

## Important Notes

⚠️ **لا يعمل على iOS** - Apple لا تسمح بهذا
⚠️ **يحتاج "Unknown Sources"** - المستخدمون يجب أن يفعلوا التثبيت من مصادر غير معروفة
⚠️ **لا توجد مراجعة** - تأكد من اختبار التحديثات جيداً قبل النشر
