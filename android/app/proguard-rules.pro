# Razorpay
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Flutter plugins are called from Dart over platform channels — R8 can't see those calls,
# so keep their classes (fixes SharedPreferences "NoSuchMethodError" on release builds)
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class dev.fluttercommunity.** { *; }
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class kotlin.coroutines.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn io.flutter.embedding.**
