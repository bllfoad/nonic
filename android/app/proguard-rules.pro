# Keep Flutter embedding and entry points
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep application and MainActivity (update if package changes)
-keep class com.example.nonic.** { *; }

# Keep serialization for kotlin/dart generated names
-keepattributes *Annotation*
-dontnote kotlinx.**
-dontwarn kotlin.**

# Keep notification compat
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class android.support.v4.app.NotificationCompat** { *; }

# Suppress Play Core warnings (Flutter deferred components references)
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**
