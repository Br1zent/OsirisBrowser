# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLCipher
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# PointyCastle
-keep class org.bouncycastle.** { *; }

# Biometric
-keep class androidx.biometric.** { *; }

# Keep model classes
-keep class com.brizproject.osiris.** { *; }

# Prevent stripping of encryption classes
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }

# Play Core (optional, used by Flutter deferred components)
-dontwarn com.google.android.play.core.**
