# Isar rules
-keep class io.isar.** { *; }
-keep class * extends io.isar.IsarLink { *; }
-keep class * extends io.isar.IsarLinks { *; }
-keep class * extends io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarObject { *; }

# FFmpegKit rules
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# mpv_audio_kit rules
-keep class com.alesdrnz.mpv_audio_kit.** { *; }
-keep class androidx.media3.** { *; }

# Keep model classes (to prevent Isar stripping)
-keep class looper_player.features.library.domain.models.** { *; }
-keep @io.isar.Collection class * { *; }
-keep @io.isar.Id class * { *; }
-keep @io.isar.Index class * { *; }
-keep @io.isar.Name class * { *; }
-keep @io.isar.Ignore class * { *; }
-keep @io.isar.TypeConverter class * { *; }

# Keep resource identifiers
-keep class **.R$* {
    <fields>;
}
