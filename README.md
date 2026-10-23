# Jyotessa — Flutter app

Android & iOS app for **jyotessa.com**: same products, collections, cart, checkout (Razorpay / COD),
login (mobile OTP + Google), order tracking, notifications and support as the website.
It talks to the same backend (`candle-studio-backend`, `https://api.jyotessa.com/api`).

## Run

```bash
flutter pub get
flutter run                       # debug on a phone/emulator
flutter build apk --release       # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle           # for the Play Store
```

Local backend instead of live: `flutter run --dart-define=API_URL=http://10.0.2.2:5050/api`

## Folder structure

```
lib/
├── main.dart                 App start (storage, push, Riverpod)
├── app.dart                  MaterialApp + theme + router
├── core/
│   ├── config/app_config.dart    API URL, site URL, Google & Firebase IDs
│   ├── theme/                    Brand colours (same as website) + fonts + widget styles
│   ├── network/api_client.dart   Dio client, adds the login token, readable errors
│   ├── storage/local_storage.dart Session, cart, wishlist on the phone
│   ├── router/app_router.dart    Every screen route + push-notification links
│   └── utils/format.dart         ₹ prices, dates, image URLs
├── data/
│   ├── models/               Product, Category, Order, AppUser, ShippingSettings
│   ├── repositories/         One function per API endpoint (see table below)
│   └── content/              Page copy from the website: FAQs, policies, reviews, chatbot…
├── state/                    Riverpod providers: catalog, cart (+ totals), wishlist, session
├── services/                 Razorpay, Google sign-in, push (FCM), phone/WhatsApp/maps launcher
├── widgets/                  Shared UI: product card, image, order summary, headings, buttons
└── features/                 Screens, one folder per area
    ├── splash/   shell/ (bottom tabs, side menu, push popup)
    ├── home/     home_screen + widgets/ (15 homepage sections)
    ├── shop/     shop, collections
    ├── product/  cart/  checkout/  auth/  account/  orders/  wishlist/
    ├── info/     about, faq, policies + disclaimer, 404
    ├── contact/  support/ (Diya chatbot)
```

## Screens (website page → app screen)

| Website | App |
|---|---|
| Intro loader | Splash (native splash + animated logo) |
| `/` Home — all 15 sections | Home tab |
| `/shop?line= / ?category= / ?q=` | Shop tab (line chips, search, filters, sort) |
| Collections grid / mega menu | Collections screen + side menu |
| `/product/:id` | Product detail (gallery, fragrance, qty, buy now, share) |
| Cart drawer + `/cart` | Cart tab |
| `/checkout` | Checkout (login gate → shipping → payment → success) |
| `/login` | Login (mobile OTP or Google) |
| Account / My orders | Account tab, My orders, Edit profile |
| `/track-order` | Track order |
| `/wishlist` | Wishlist tab |
| `/about`, `/faq`, `/contact` | About, FAQs, Contact |
| `/policies/*`, `/disclaimer` | Policy screen (5 pages) |
| Chat bot + call/WhatsApp dock | Chat with Diya + floating help button |
| Push prompt | Notification popup (15 s, then every 10 min) |
| 404 | Not found |

## API used (all customer endpoints)

| Endpoint | Where |
|---|---|
| `GET /products`, `GET /products/:slug` | Catalogue, product page |
| `GET /collections` | Home, shop, menu, collections |
| `GET /settings` | Shipping charges everywhere |
| `POST /coupons/validate` | Order summary |
| `POST /auth/otp/send`, `POST /auth/otp/verify` | Login |
| `POST /auth/google` | Login with Google |
| `POST /auth/phone/status` | (ready for Firebase SMS) |
| `GET /auth/me`, `PUT /auth/me` | Session refresh, edit profile |
| `POST /orders` | Place order |
| `POST /orders/:id/verify-payment` | After Razorpay |
| `POST /orders/:id/retry-payment` | "Pay now" on unpaid orders |
| `GET /orders/mine` | Account, My orders |
| `GET /orders/track/:id` | Track order |
| `POST /notifications/devices`, `DELETE …` | Push on/off for this phone |
| `GET/PUT /notifications/preferences` | Offers switch |
| `POST /inquiries` | Contact form |
| `POST /tickets` | Chatbot "leave a message" |

## One-time setup (Google login & push)

**Google login on Android** — Google Cloud Console (same project as the website's client ID)
→ APIs & Services → Credentials → Create OAuth client ID → **Android**:
- Package name: `com.jyotessa.jyotessa_app`
- SHA-1: run `cd android && ./gradlew signingReport` (debug and your release key)

**Push notifications** — Firebase Console → project *jyotessa* → Add app → **Android**,
package `com.jyotessa.jyotessa_app`. Copy the **App ID** (`1:265451778916:android:…`) into
`firebaseAndroidAppId` in `lib/core/config/app_config.dart` (or `--dart-define=FIREBASE_ANDROID_APP_ID=…`).
Push stays switched off until this is set; everything else works without it.

**Release signing** — create a keystore and replace the debug `signingConfig` in
`android/app/build.gradle.kts` before uploading to the Play Store.
