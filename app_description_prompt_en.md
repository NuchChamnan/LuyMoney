# Prompt: Description of the "Luy Money" App

## Overview
**Luy Money** is a mobile app (Flutter, GetX architecture) that delivers educational content on finance, investing, and business (videos + articles) through a paid subscription model. It integrates with Firebase (Auth, Firestore, Storage, Analytics, FCM) and supports 3 languages (English, Khmer, Chinese).

---

## 1. Authentication
- Email/password login and registration (Firebase Auth + Firestore profile)
- "Remember me" and biometric (fingerprint) login
- Forgot password — sends a password-reset link via email
- Input validation (email format, password ≥ 8 chars, confirm-password match, name)
- Role-based redirect after login (admin → admin dashboard, user → home)
- Sign out with confirmation dialog

## 2. Home
- Shows recent videos and articles (top 5 of each)
- Displays the number of content categories
- Shows subscription status: active, expiring soon, or days remaining
- Bottom navigation bar for switching sections

## 3. Content — Videos & Articles
- Lists videos/articles from Firestore ordered by publish date
- Category filter: finance, investment, mindset, trading, savings, business...
- Search content by title, category, or excerpt (debounced ~300ms)
- Bookmark videos and articles to view later
- Some content is locked as "Premium" — requires an active subscription to view
- Video detail screen: YouTube player, stats (view count, duration, date), Like/Save/More actions, related videos
- Article detail screen: full article content and bookmarking

## 4. Subscription & Payment
- 4 subscription plans: monthly, quarterly, biannual, and annual (with a "Popular" badge)
- Payment via ABA Pay (KHQR): scan the QR code, take a screenshot of the payment receipt, and send it to the admin's Telegram (@Noch_Chamnan) for manual verification and activation
- Promo codes: validates the code's validity, expiry date, max usage limit, and applicable plans; supports both percentage and fixed-amount discounts
- Referral program: auto-generates a unique referral code per user, shareable via deep link, applying a friend's code (with self-referral and double-use prevention), and the referrer earns a 30-day subscription extension when the referee makes their first purchase

## 5. Settings & Profile
- Edit name, phone number, and profile picture (base64, ≤ 500KB)
- Change password (requires re-authentication)
- Delete account (also removes Firestore data)
- Toggle notifications: subscription reminders, new content alerts, promotional messages
- Rate the app, open privacy policy, terms of service, FAQ, and Telegram support
- Switch language: English, Khmer, or Chinese (preference is persisted)

## 6. Customer Support
- Real-time chat with the support team (via Firestore)
- Send text messages and images (uploaded to Firebase Storage)
- Open the Telegram support channel directly

## 7. Admin Dashboard
A management dashboard available to accounts with the admin role, with 5 main sections:
- **Users**: search/filter (all/active/expired/free), extend subscription by N days, deactivate, delete, promote/demote admin role, and send password-reset emails
- **Content**: add/delete videos and articles, manage content categories (add, update, delete)
- **Analytics**: total/active/expired/free user counts, monthly and total revenue, and a 6-month revenue chart
- **Notifications**: compose and send push notifications to a targeted audience (delivered via Cloud Function/FCM)
- **Chats**: view and reply to all user support conversations, with unread-message indicators

---

## Key Technical Services
- **AuthService**: manages login state, role (admin/user), and subscription access rights
- **NotificationService**: sends push (FCM) and local notifications (subscription reminders 7 days, 1 day, and on the expiry date)
- **AnalyticsService**: logs usage events (content viewed, video completed, article bookmarked, subscription started/renewed/expired, language/theme changes)
- **StorageService**: persists local preferences (theme, language, biometric, notifications) and the local bookmark list
