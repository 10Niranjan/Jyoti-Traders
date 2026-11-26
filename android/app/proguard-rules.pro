# Firebase SDKs occasionally reflect on their own model/config classes.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter's embedding references Play Core split-install classes even when
# deferred components aren't used; without this R8 fails with "Missing class".
-dontwarn com.google.android.play.core.**
