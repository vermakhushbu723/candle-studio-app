/// App-wide settings. Public values only — secrets live on the server.
///
/// Every value can be overridden at build time, e.g.
///   flutter run --dart-define=API_URL=http://10.0.2.2:5050/api
class AppConfig {
  AppConfig._();

  /// Jyotessa REST API (candle-studio-backend).
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.jyotessa.com/api');

  /// Website — product photos (`/images/...`) and share links are served from here.
  static const siteUrl = String.fromEnvironment('SITE_URL', defaultValue: 'https://jyotessa.com');

  /// Google sign-in: the OAuth **Web** client ID (the backend checks the token's audience against it).
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '1030821160613-vg3i6mkdatu6keb7j5e9kboe4opt0o0b.apps.googleusercontent.com',
  );

  /// Firebase (push notifications). Project values match the website; the Android app ID comes from
  /// Firebase Console → Project settings → Your apps → Android app (com.jyotessa.jyotessa_app).
  /// Push stays off until it is set.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyDp8LJscgKXOe-6yybwCquiquoBWl7UDu0');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'jyotessa');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID', defaultValue: '265451778916');
  static const firebaseAndroidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: '');
  static const firebaseIosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: '');

  static const brandColorHex = '#6C2408';
}
