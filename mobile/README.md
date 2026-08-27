# Flutter setup

This repository includes the app source. Generate platform folders using the
Flutter SDK installed on your computer:

1. `flutter doctor`
2. From this `mobile` folder run:
   `flutter create --platforms=android,ios .`
3. Run `flutter pub get`.

## Android

Add above `<application>` in:
`android/app/src/main/AndroidManifest.xml`

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>

For local HTTP development only, add to `<application>`:
android:usesCleartextTraffic="true"

## iOS

Inside `ios/Runner/Info.plist` add:

<key>NSCameraUsageDescription</key>
<string>The camera is used to scan vehicle registration plates.</string>

## Run

Android emulator:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

Physical phone on same Wi-Fi:
flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000/api/v1

Production:
flutter run --dart-define=API_BASE_URL=https://parking.yourdomain.com/api/v1
