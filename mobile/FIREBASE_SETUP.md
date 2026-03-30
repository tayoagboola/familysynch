# Firebase Setup

## Steps

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app: package `com.familysynch.app`
   - Download `google-services.json` → place at `android/app/google-services.json`
3. Add iOS app: bundle ID `com.familysynch.app`
   - Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`

## Android gradle changes

`android/build.gradle` — add to `dependencies`:
```
classpath 'com.google.gms:google-services:4.4.2'
```

`android/app/build.gradle` — add at the bottom:
```
apply plugin: 'com.google.gms.google-services'
```

## iOS

In `ios/Runner/Info.plist` add your custom URL scheme for deep links:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>familysynch</string>
    </array>
  </dict>
</array>
```

## Android deep links

In `android/app/src/main/AndroidManifest.xml` inside the `<activity>` tag:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="familysynch"/>
</intent-filter>
```
