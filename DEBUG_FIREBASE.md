# 🔧 Firebase Remote Config Debug Guide

## 🚨 Quick Diagnostic Steps

### Step 1: Check Your Console Logs

Run your app and look for this output:

```bash
flutter run
```

**Look for these logs:**

#### ✅ Working (Good):
```
=== Remote Config Debug Info ===
Fetch result: true
Last fetch time: [recent timestamp]
Last fetch status: RemoteConfigFetchStatus.success
force_update_required: true
minimum_version_android: 2.0.0  ← Your Firebase value
minimum_version_ios: 2.0.0      ← Your Firebase value
Raw Firebase values:
  force_update_required: true
  minimum_version_android: 2.0.0
  minimum_version_ios: 2.0.0
================================
```

#### ❌ Not Working (Problem):
```
=== Remote Config Debug Info ===
Fetch result: false
Last fetch time: null
Last fetch status: RemoteConfigFetchStatus.failure
force_update_required: false
minimum_version_android: 1.0.0  ← Still default
minimum_version_ios: 1.0.0      ← Still default
Raw Firebase values:
  force_update_required: false
  minimum_version_android: 1.0.0
  minimum_version_ios: 1.0.0
================================
```

## 🔍 Common Issues & Solutions

### Issue 1: Fetch Result = false

**Problem:** Firebase fetch failed
**Solution:**
1. Check internet connection
2. Verify Firebase project is correct
3. Check Firebase project permissions

### Issue 2: Last Fetch Status = failure

**Problem:** Network or authentication issue
**Solution:**
1. Check `google-services.json` (Android)
2. Check `GoogleService-Info.plist` (iOS)
3. Verify Firebase project ID matches

### Issue 3: Raw Firebase values show defaults

**Problem:** Firebase parameters not set correctly
**Solution:**
1. Check parameter names in Firebase Console
2. Verify you clicked "Publish changes"
3. Check parameter values are correct

### Issue 4: Values don't match Firebase Console

**Problem:** Caching or sync issue
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Test with Simple Values

### Test 1: Set Obvious Values

**In Firebase Console:**
```
force_update_required: true
minimum_version_android: 999.0.0
minimum_version_ios: 888.0.0
```

**Expected Console Output:**
```
minimum_version_android: 999.0.0
minimum_version_ios: 888.0.0
```

**If still shows 1.0.0 → Firebase not connected**

### Test 2: Check Parameter Names

**Verify exact names in Firebase Console:**
```
✅ force_update_required
✅ minimum_version_android
✅ minimum_version_ios
✅ update_message
✅ android_store_url
✅ ios_store_url
```

**❌ Wrong names:**
```
❌ minimum_version (old)
❌ force_update (missing _required)
❌ min_version_android (missing _version)
```

## 🚀 Quick Fix Commands

### Complete Reset:
```bash
# 1. Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle

# 2. Reinstall
flutter pub get
cd ios && pod install && cd ..

# 3. Run and check logs
flutter run
```

### Force Firebase Refresh:
```bash
# Stop app completely
# Change Firebase values
# Publish changes
# Restart app
flutter run
```

## 📊 Debug Checklist

- [ ] Firebase Console has correct parameter names
- [ ] Parameter values are set (not empty)
- [ ] "Publish changes" was clicked
- [ ] App was fully restarted (not hot reload)
- [ ] Console shows "Fetch result: true"
- [ ] Console shows "Last fetch status: success"
- [ ] Raw Firebase values match your console settings
- [ ] No error messages in console

## 🎯 What to Share for Help

If you're still having issues, share:

1. **Console logs** (the debug output)
2. **Firebase Console screenshot** (showing your parameters)
3. **Parameter names** you're using
4. **Any error messages**

## 💡 Pro Tips

1. **Always use exact parameter names** from the code
2. **Test with simple values first** (like 999.0.0)
3. **Check console logs immediately** after restart
4. **Verify "Publish changes"** was clicked
5. **Use full restart** (not hot reload)

---

**Run `flutter run` and share the console output - I'll help you identify the exact issue!** 🔧

