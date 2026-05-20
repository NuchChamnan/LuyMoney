# 💰 Luy Money — Flutter GetX App

> Subscription-based financial content learning platform built with Flutter, GetX, and Firebase.

---

## 🏗️ Architecture

```
lib/
├── app/
│   ├── data/
│   │   ├── models/           # UserModel, SubscriptionModel, VideoModel, ArticleModel, ChatModel
│   │   └── providers/        # Firebase repository implementations
│   ├── domain/
│   │   └── repositories/     # Abstract interfaces (AuthRepository, ContentRepository, SubscriptionRepository)
│   ├── modules/
│   │   ├── auth/             # Splash, Login, Register, ForgotPassword
│   │   ├── home/             # Dashboard with subscription status + content previews
│   │   ├── subscription/     # Plans, Payment, PromoCode, Referral
│   │   ├── content/          # Videos, Articles with search/filter/bookmark
│   │   ├── support/          # In-app chat + Telegram deep link
│   │   ├── settings/         # Profile, Theme, Language, Notifications
│   │   └── admin/            # Users, Content, Analytics, Notifications
│   ├── routes/               # GetX named routes + Auth/Subscription/Admin middlewares
│   ├── services/             # AuthService, NotificationService, StorageService, AnalyticsService
│   └── shared/
│       ├── constants/        # Colors, dimensions, text styles
│       ├── themes/           # White/Black/OldBlue theme system + ThemeController
│       ├── translations/     # English, Khmer, Chinese i18n
│       ├── utils/            # Validators, DateHelper, CurrencyHelper, ResponsiveLayout
│       └── widgets/          # GoldButton, CustomTextField, VideoCard, ArticleCard, etc.
├── main.dart
└── app_config.dart
```

---

## 🎨 Features

### Themes (3)
| Theme    | Background | Accent     |
|----------|------------|------------|
| White    | #FFFFFF    | #D4AF37 Gold |
| Black    | #0A0A0A    | #D4AF37 Gold |
| Old Blue | #1B2A4A    | #D4AF37 Gold |

### Languages (3)
- 🇺🇸 English (default)
- 🇰🇭 ភាសាខ្មែរ Khmer
- 🇨🇳 中文 Chinese Simplified

### Subscription Plans
| Plan       | Price | Duration | Badge       |
|------------|-------|----------|-------------|
| Monthly    | $5    | 30 days  | —           |
| Quarterly  | $12   | 90 days  | —           |
| Biannual   | $20   | 180 days | 🔥 Popular  |
| Annual     | $35   | 365 days | ✅ Best Value |

### Payment Methods
- 💳 Stripe (international cards)
- 🏦 ABA Pay (Cambodia QR)
- 📱 Wing Money (Cambodia)
- 💰 PayPal

---

## 🚀 Getting Started

### 1. Prerequisites
```bash
flutter --version   # Requires Flutter 3.x+ (Dart 3.0+)
```

### 2. Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 3. Environment
Create `.env` from `.env.example`:
```
STRIPE_PUBLISHABLE_KEY=pk_test_...
ABA_MERCHANT_ID=...
```

### 4. Install & Run
```bash
flutter pub get
flutter run
```

---

## 🔒 Security
- Firebase Auth with email/password
- Biometric login (Face ID / Fingerprint)
- Firestore security rules — users see only their own data
- Storage rules — 2MB avatar limit
- Firebase App Check ready

---

## 📊 Admin Panel
Access: users with `role: 'admin'` in Firestore automatically see admin entry point in settings.

Sections:
- **Users** — search, filter (active/expired/free), extend/deactivate/delete
- **Content** — upload/edit/delete videos and articles
- **Analytics** — user stats, monthly revenue chart, distribution pie chart
- **Notifications** — send push to all/active/expiring users with templates

---

## 🧪 Tests
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests
flutter test
```

---

## 📦 Key Packages

| Package | Purpose |
|---------|---------|
| `get` | State, routing, DI |
| `get_storage` | Persistent key-value storage |
| `firebase_*` | Backend (Auth, Firestore, Storage, FCM) |
| `youtube_player_flutter` | YouTube video playback |
| `flutter_html` | Article HTML rendering |
| `flutter_local_notifications` | Subscription reminders |
| `fl_chart` | Admin analytics charts |
| `shimmer` | Loading placeholders |
| `cached_network_image` | Image caching |
| `local_auth` | Biometric auth |
| `in_app_review` | Rate app prompt |
| `share_plus` | Referral sharing |

---

## 🗺️ Roadmap
- [ ] Offline article cache (Hive)
- [ ] Video progress tracking
- [ ] Stripe webhook verification (Cloud Functions)
- [ ] ABA Pay QR generation
- [ ] Firebase Dynamic Links for referrals
- [ ] Windows/macOS desktop layout
- [ ] Web SEO meta tags
