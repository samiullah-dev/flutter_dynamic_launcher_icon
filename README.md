# Flutter Dynamic Launcher Icon

A Flutter package to **change your app’s launcher icon dynamically** at runtime on Android and iOS.

---

## 📌 Features

* Change launcher icons dynamically without restarting the app.
* Supports multiple icons.
* Works for both Android and iOS.
* Simple and clean API.

---

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dynamic_launcher_icon:
    git:
      url: https://github.com/your-repo/flutter_dynamic_launcher_icon.git
```

Run:

```bash
flutter pub get
```

---

## ⚙ Android Setup

Android requires special manifest configuration using `activity-alias`.

### Step 1 — Remove LAUNCHER intent from MainActivity

Open `android/app/src/main/AndroidManifest.xml` and locate your `MainActivity` entry. Remove the following block:

```xml
<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>
```

After removal, your `MainActivity` should look like:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    <meta-data
        android:name="io.flutter.embedding.android.NormalTheme"
        android:resource="@style/NormalTheme" />
</activity>
```

### Step 2 — Add `activity-alias` entries

For each icon variant, add an alias in `AndroidManifest.xml` inside the `<application>` tag:

```xml
<activity-alias
    android:name=".default"
    android:enabled="true"
    android:exported="true"
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher"
    android:targetActivity=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity-alias>

<activity-alias
    android:name=".icon_1"
    android:enabled="false"
    android:exported="true"
    android:icon="@mipmap/ic_launcher_2"
    android:roundIcon="@mipmap/ic_launcher_2"
    android:targetActivity=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity-alias>
```

Only one alias can have `android:enabled="true"`. Changing the enabled alias changes the launcher icon.

### Step 3 — Add icon files

Put your icons in:

```
android/app/src/main/res/mipmap-<density>/
```

Example:

```
mipmap-hdpi/ic_launcher_2.png
mipmap-mdpi/ic_launcher_2.png
mipmap-xhdpi/ic_launcher_2.png
```

Each alias in the manifest should match the icon name.

---

## 🍏 iOS Setup

### Step 1 — Add alternate icons

Add icons to:

```
ios/Runner/Assets.xcassets/
```

For each alternate icon, create an `.appiconset` folder. Example:

```
Icon1.appiconset/
```

This folder should include all icon sizes with correct naming.

### Step 2 — Add entries to `Info.plist`

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
        <key>UIPrerenderedIcon</key>
        <false/>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>Icon1</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>Icon1</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
    </dict>
</dict>
```

Replace "Icon1" with the alternate icon name.

---

## 💻 Usage

### Change icon

```dart
import 'package:flutter_dynamic_launcher_icon/flutter_dynamic_launcher_icon.dart';

await FlutterDynamicLauncherIcon.changeIcon("icon_1");
```

### Reset to default

```dart
await FlutterDynamicLauncherIcon.changeIcon(null);
```

---

## ⚠️ Notes

* **Android**: Only one alias can be enabled at a time.
* **iOS**: Changing icons prompts the user for confirmation.
* **iOS**: Alternate icons must be declared in `Info.plist` and bundled with the app.
* **Android**: Removing the LAUNCHER intent from MainActivity is required.

---

## 📚 References

* [Android activity-alias documentation](https://developer.android.com/guide/topics/manifest/activity-alias-element)
* [iOS alternate icons documentation](https://developer.apple.com/documentation/uikit/uiapplication/1623094-setalternateiconname)

---

## 🛠 License

MIT © [Your Name]
