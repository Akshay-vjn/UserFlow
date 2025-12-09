# 🚀 Platform-Specific Force Update - Quick Setup

## ✅ What's New

Your force update now supports **different minimum versions** for iOS and Android!

## 🔧 Firebase Console Setup

### Step 1: Add These Parameters

In Firebase Console → Remote Config:

```
force_update_required: true (Boolean)
minimum_version_android: 1.5.0 (String)
minimum_version_ios: 2.0.0 (String)
update_message: "Your app version is outdated. Please update to continue using the app." (String)
android_store_url: https://play.google.com/store/apps/details?id=YOUR_PACKAGE_ID (String)
ios_store_url: https://apps.apple.com/app/idYOUR_APP_ID (String)
```

### Step 2: Publish Changes

Click **"Publish changes"** in Firebase Console.

## 📱 How It Works

### Platform Detection:
- **Android** → Uses `minimum_version_android`
- **iOS** → Uses `minimum_version_ios`

### Example:
```
Android users need version 1.5.0+
iOS users need version 2.0.0+
```

## 🧪 Quick Test

### Test 1: Android Force Update

**Firebase:**
```
minimum_version_android: 2.0.0
minimum_version_ios: 1.0.0
force_update_required: true
```

**Android device with version 1.0.0:**
```
Expected: Force update dialog
Console: "Platform: Android", "Minimum Version: 2.0.0"
```

**iOS device with version 1.0.0:**
```
Expected: No dialog
Console: "Platform: iOS", "Minimum Version: 1.0.0"
```

### Test 2: iOS Force Update

**Firebase:**
```
minimum_version_android: 1.0.0
minimum_version_ios: 2.0.0
force_update_required: true
```

**Android device with version 1.0.0:**
```
Expected: No dialog
Console: "Platform: Android", "Minimum Version: 1.0.0"
```

**iOS device with version 1.0.0:**
```
Expected: Force update dialog
Console: "Platform: iOS", "Minimum Version: 2.0.0"
```

## 📊 Console Output

### Android:
```
=== Force Update Check ===
Platform: Android
Current Version: 1.0.0
Minimum Version: 1.5.0
Force Update Required: true
Result: FORCE UPDATE REQUIRED (below minimum version)
========================
```

### iOS:
```
=== Force Update Check ===
Platform: iOS
Current Version: 1.0.0
Minimum Version: 2.0.0
Force Update Required: true
Result: FORCE UPDATE REQUIRED (below minimum version)
========================
```

## 🎯 Common Scenarios

### Scenario 1: iOS App Store Delay
```
Android: Force to 2.0.0 (approved)
iOS: Keep 1.0.0 (waiting for review)
```

### Scenario 2: Platform-Specific Bug
```
Android: Force to 1.5.0 (has fix)
iOS: Keep 1.0.0 (no bug)
```

### Scenario 3: Different Release Cycles
```
Android: Weekly updates (1.8.0)
iOS: Monthly updates (1.5.0)
```

## ⚡ Quick Commands

```bash
# Test on Android
flutter run -d android

# Test on iOS
flutter run -d ios

# Check console logs for platform detection
```

## ✅ Benefits

- ✅ **Independent control** for iOS and Android
- ✅ **Handle App Store delays** gracefully
- ✅ **Platform-specific bug fixes**
- ✅ **Different release cycles**
- ✅ **Gradual rollouts**

## 🎉 You're Ready!

**Just update your Firebase Remote Config with the new parameters and you can control force updates independently for iOS and Android!**

---

**See `PLATFORM_SPECIFIC_FORCE_UPDATE.md` for detailed documentation!** 📚

