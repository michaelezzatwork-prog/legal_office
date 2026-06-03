# مكتب المستشار القانوني المتكامل
## دليل الإعداد والنشر الكامل

---

## 🗂️ هيكل المشروع

```
legal_office/
├── lib/                          # كود Flutter
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/app_theme.dart
│   │   ├── router/app_router.dart
│   │   ├── network/api_client.dart
│   │   ├── security/security_service.dart
│   │   └── database/database_helper.dart
│   ├── models/models.dart
│   ├── providers/providers.dart
│   └── screens/
│       ├── pin_lock_screen.dart
│       ├── main_shell_screen.dart    ← Logo يفتح الجلسات
│       ├── dashboard_screen.dart
│       ├── cases_screen.dart
│       ├── sessions_screen.dart
│       └── other_screens.dart
├── android/
│   ├── app/
│   │   ├── build.gradle            ← ProGuard + Signing
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/.../MainActivity.kt  ← FLAG_SECURE
│   │       └── res/xml/network_security_config.xml
│   └── keystore.properties         ← لا ترفعه
└── backend/                        # Node.js + MongoDB
    ├── server.js
    ├── models/index.js
    ├── routes/index.js
    ├── middleware/auth.js
    └── .env                        ← لا ترفعه
```

---

## 🔐 ميزات الأمان

| الميزة | التفاصيل |
|--------|----------|
| **PIN Lock** | 4 أرقام مشفرة بـ SHA-256 + ملح |
| **Biometric** | بصمة إصبع / Face ID |
| **FLAG_SECURE** | منع تصوير الشاشة نهائياً |
| **Secure Storage** | AES-GCM مشفر على الجهاز |
| **JWT** | 8 ساعات صلاحية + Refresh |
| **Rate Limiting** | 100 طلب/15 دقيقة |
| **NoSQL Injection** | express-mongo-sanitize |
| **HTTPS Only** | منع HTTP في الإنتاج |
| **ProGuard/R8** | تشفير الكود في Release |
| **Session Lock** | قفل تلقائي بعد 8 ساعات |
| **5 محاولات** | قفل مؤقت 30 ثانية |

---

## 🚀 خطوات الإعداد

### 1. Backend (Node.js + MongoDB)

```bash
cd backend
npm install

# إنشاء ملف .env
cp .env.example .env
# عدّل MONGODB_URI و JWT_SECRET

# تشغيل
npm run dev          # Development
npm start            # Production
```

### 2. MongoDB Atlas (مجاني)

1. سجّل على [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas)
2. أنشئ Cluster مجاني (M0)
3. انسخ connection string في `.env`

```
MONGODB_URI=mongodb+srv://user:pass@cluster.xxxxx.mongodb.net/legal_office
```

### 3. Flutter App

```bash
# تنزيل الخطوط العربية (Cairo)
# ضع ملفات .ttf في assets/fonts/
# حمّلها من: https://fonts.google.com/specimen/Cairo

# تثبيت الحزم
flutter pub get

# تشغيل
flutter run

# Build Release APK
flutter build apk --release --split-per-abi

# Build AAB لـ Google Play
flutter build appbundle --release
```

### 4. توليد Keystore للـ Release

```bash
# في مجلد android/keystore/
keytool -genkey -v \
  -keystore legal_office_keystore.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias legal_office_key

# أضف في android/keystore.properties
storeFile=../keystore/legal_office_keystore.jks
storePassword=YOUR_PASSWORD
keyAlias=legal_office_key
keyPassword=YOUR_PASSWORD
```

### 5. تحديث رابط الـ API

```dart
// lib/core/network/api_endpoints.dart
static const String baseUrl = 'https://YOUR_SERVER.com/api/v1';
```

---

## 📱 Logo يفتح أجندة الجلسات

في `main_shell_screen.dart`:
```dart
GestureDetector(
  onTap: () => context.go('/sessions'),  // ← الضغط على Logo
  child: Container(/* Logo ⚖️ */),
)
```

---

## 🏪 رفع على Google Play

1. **Build AAB**: `flutter build appbundle --release`
2. **الملف**: `build/app/outputs/bundle/release/app-release.aab`
3. ارفع على [Google Play Console](https://play.google.com/console)
4. أضف:
   - اسم التطبيق: **مكتب المستشار القانوني المتكامل**
   - الفئة: Business / Productivity
   - Content Rating: Everyone
   - Privacy Policy (مطلوب)

---

## 🔧 .gitignore (مهم!)

```
android/keystore.properties
android/app/keystore/
backend/.env
*.jks
*.keystore
```
