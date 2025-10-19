# Firebase Setup Instructions

## Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Create a project" or "Add project"
3. Name it "PBD Solar Wind Projects"
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Flutter App to Firebase
1. In your Firebase project, click "Add app"
2. Select the Flutter icon
3. Register your app with package name: `com.example.pbd_solar_wind_projects`
4. Download the `google-services.json` file for Android
5. Download the `GoogleService-Info.plist` file for iOS

## Step 3: Place Configuration Files
- Place `google-services.json` in: `android/app/google-services.json`
- Place `GoogleService-Info.plist` in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for now
4. Select a location (choose closest to your users)

## Step 5: Configure Android (android/app/build.gradle)
Add this line to the top of android/app/build.gradle:
```
plugins {
    id 'com.google.gms.google-services'
}
```

And add this to android/build.gradle (project level):
```
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

## Step 6: Configure iOS
Add GoogleService-Info.plist to your iOS project in Xcode.

After completing these steps, run:
```bash
flutter pub get
```

Then you can proceed with the implementation.