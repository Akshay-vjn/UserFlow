# Firebase Remote Config Troubleshooting

## 🔍 Why Firebase Values Aren't Showing

If you're still seeing default values (1.0.0) instead of your Firebase values, here are the most common causes and solutions:

## ✅ Step-by-Step Debugging

### Step 1: Verify Firebase Console Setup

**Check these in Firebase Console:**

1. **Go to:** Firebase Console → Your Project → Remote Config
2. **Look for these exact parameter names:**
   ```
   ✅ force_update_required
   ✅ minimum_version_android  
   ✅ minimum_version_ios
   ✅ update_message
   ✅ android_store_url
   ✅ ios_store_url
   ```

3. **Check parameter values:**
   ```
   minimum_version_android: 2.0.0  ← Your value
   minimum_version_ios: 2.0.0      ← Your value
   force_update_required: true     ← Your value
   ```

4. **Verify you clicked "Publish changes":**
   - Look for green "Published" status
   - Check the timestamp shows recent publish

### Step 2: Check Console Logs

**Look for these specific log messages:**

#### ✅ Good Logs (Working):
```
Remote Config initialized - immediate fetch enabled (no cache)
Fetching latest Remote Config values...
Remote Config refresh successful
force_update_required: true
minimum_version_android: 2.0.0
minimum_version_ios: 2.0.0
current_platform: Android
```

#### ❌ Problem Logs (Not Working):
```
Remote Config refresh no changes  ← Firebase not updated
Error refreshing Remote Config: [error]  ← Network/Config error
minimum_version_android: 1.0.0  ← Still showing default
```

### Step 3: Common Issues & Solutions

#### Issue 1: Wrong Parameter Names
**Problem:** Using old parameter names
```
❌ minimum_version (old)
✅ minimum_version_android
✅ minimum_version_ios
```

**Solution:** Use exact parameter names from the code

#### Issue 2: Not Published
**Problem:** Saved but not published
```
❌ Shows "Saved" but not "Published"
✅ Click "Publish changes" button
```

**Solution:** 
1. Click "Publish changes" in Firebase Console
2. Wait for "Published" status
3. Restart app

#### Issue 3: App Not Restarted
**Problem:** Hot reload doesn't fetch new config
```
❌ flutter hot reload
✅ flutter run (full restart)
```

**Solution:**
```bash
# Stop the app completely
# Then restart
flutter run
```

#### Issue 4: Network/Firebase Connection
**Problem:** Can't reach Firebase
```
❌ "Error refreshing Remote Config"
✅ Check internet connection
```

**Solution:**
1. Check internet connection
2. Verify Firebase project is correct
3. Check Firebase project permissions

#### Issue 5: Firebase Project Mismatch
**Problem:** Wrong Firebase project
```
❌ App connected to different project
✅ Verify correct project in firebase_options.dart
```

**Solution:**
1. Check `lib/firebase_options.dart`
2. Verify project ID matches Firebase Console
3. Re-download `google-services.json` (Android) if needed

### Step 4: Force Refresh Test

**Try this to force a fresh fetch:**

1. **Clear Firebase cache:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Restart app:**
   ```bash
   flutter run
   ```

3. **Check console logs immediately**

### Step 5: Manual Verification

**Test with a simple change:**

1. **In Firebase Console:**
   ```
   minimum_version_android: 999.0.0  ← Very high number
   ```

2. **Publish changes**

3. **Restart app**

4. **Check console:**
   ```
   Should show: minimum_version_android: 999.0.0
   If still shows 1.0.0 → Firebase not connected
   ```

## 🛠️ Advanced Debugging

### Debug 1: Check Firebase Connection

**Add this temporary code to `main.dart`:**

```dart
// Add after Firebase.initializeApp()
print('Firebase project: ${Firebase.app().options.projectId}');
print('Firebase app name: ${Firebase.app().name}');
```

**Expected output:**
```
Firebase project: your-project-id
Firebase app name: [DEFAULT]
```

### Debug 2: Check Remote Config Status

**Add this to RemoteConfigService.initialize():**

```dart
// After fetchAndActivate()
final lastFetchTime = _remoteConfig?.lastFetchTime;
final lastFetchStatus = _remoteConfig?.lastFetchStatus;
print('Last fetch time: $lastFetchTime');
print('Last fetch status: $lastFetchStatus');
```

**Expected output:**
```
Last fetch time: [recent timestamp]
Last fetch status: RemoteConfigFetchStatus.success
```

### Debug 3: Check Parameter Values Directly

**Add this to RemoteConfigService.initialize():**

```dart
// After fetchAndActivate()
print('Raw Firebase values:');
print('force_update_required: ${_remoteConfig?.getValue('force_update_required').asBool()}');
print('minimum_version_android: ${_remoteConfig?.getValue('minimum_version_android').asString()}');
print('minimum_version_ios: ${_remoteConfig?.getValue('minimum_version_ios').asString()}');
```

## 🚨 Emergency Fix

**If nothing works, try this complete reset:**

### Step 1: Clear Everything
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle
flutter pub get
cd ios && pod install && cd ..
```

### Step 2: Verify Firebase Setup
1. Check `google-services.json` is in `android/app/`
2. Check `GoogleService-Info.plist` is in `ios/Runner/`
3. Verify `firebase_options.dart` has correct project ID

### Step 3: Test with Simple Values
```
Firebase Console:
force_update_required: true
minimum_version_android: 999.0.0
minimum_version_ios: 999.0.0
```

### Step 4: Restart and Check
```bash
flutter run
# Check console for 999.0.0 values
```

## 📊 Success Indicators

**You'll know it's working when you see:**

```
✅ "Remote Config refresh successful"
✅ "minimum_version_android: [your value]"
✅ "minimum_version_ios: [your value]"
✅ Values match what you set in Firebase Console
```

## 🎯 Quick Checklist

- [ ] Firebase Console has correct parameter names
- [ ] Parameter values are set correctly
- [ ] "Publish changes" was clicked
- [ ] App was fully restarted (not hot reload)
- [ ] Internet connection is working
- [ ] Firebase project is correct
- [ ] Console shows "refresh successful"

## 💡 Pro Tips

1. **Always restart app** after Firebase changes
2. **Check console logs** for error messages
3. **Use simple test values** first (like 999.0.0)
4. **Verify parameter names** match exactly
5. **Test on both platforms** (Android/iOS)

---

**If you're still having issues after trying these steps, share your console logs and I'll help you debug further!** 🔧

