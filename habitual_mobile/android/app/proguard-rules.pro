# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Don't warn about Play Core (we don't use it)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**

# Keep Play Core classes if they exist (but don't fail if missing)
-keep class com.google.android.play.core.** { *; }

# Hive
-keep class * extends com.hivedb.** { *; }
-keep class * implements com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.** { *; }
-keep class hive_flutter.** { *; }

# Keep all model classes (adjust package name as needed)
-keep class com.example.habitual_mobile.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
