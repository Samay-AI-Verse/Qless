# Flutter Code
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (Fix for missing classes error)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Mobile Scanner & ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Generic Ignore Warnings (Use cautiously, but needed for successful build sometimes)
-ignorewarnings
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
