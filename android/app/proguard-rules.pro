# Flutter Engine
-keep class io.flutter.engine.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.app.** { *; }

# Flutter Plugins
-keep class io.flutter.plugins.** { *; }
-keep class com.gkeyes.markdownviewultra.** { *; }

# Play Store deferred components
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }