# Flutter default safe rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# OkHttp/Okio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# ExoPlayer / Media3
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }

# CameraX / Camera
-dontwarn androidx.camera.**
-keep class androidx.camera.** { *; }

# Glide (если используется)
-dontwarn com.bumptech.glide.**
-keep class com.bumptech.glide.** { *; }

# LiveKit / WebRTC (если используется)
-dontwarn io.livekit.**
-keep class io.livekit.** { *; }
-dontwarn org.webrtc.**
-keep class org.webrtc.** { *; }

# Gson / JSON (если используется)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepclassmembers class ** {
    @kotlin.Metadata *;
}
