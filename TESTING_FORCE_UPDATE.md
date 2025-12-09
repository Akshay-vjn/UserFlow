# Testing Force Update Feature

## 🚀 Immediate Fetch in Debug Mode

The app now **automatically fetches the latest Remote Config values immediately** when running in debug mode!

### What Changed:

✅ **Debug Mode** (Development):
- Fetch interval: **0 seconds** (immediate)
- Every version check fetches latest config from Firebase
- Changes in Firebase Console reflect **immediately** on app restart
- Console logs show all values for debugging

✅ **Release Mode** (Production):
- Fetch interval: **1 hour** (to save bandwidth)
- Respects Firebase's caching mechanism
- No debug logs

## 🔍 Debug Logs

When running in debug mode, you'll see detailed logs in the console:

### On App Launch:
```
Remote Config initialized in DEBUG mode - immediate fetch enabled
force_update_required: false
minimum_version: 1.0.0
latest_version: 1.0.0
```

### On Version Check:
```
Fetching latest Remote Config values...
Remote Config refresh successful
force_update_required: true
minimum_version: 2.0.0
latest_version: 2.0.0

=== Force Update Check ===
Current Version: 1.0.0
Minimum Version: 2.0.0
Latest Version: 2.0.0
Force Update Required: true
Result: FORCE UPDATE REQUIRED
========================
```

## 🧪 Testing Scenarios

### Test 1: Force Update

1. **In Firebase Console**, set:
   ```
   force_update_required: true
   minimum_version: 2.0.0
   latest_version: 2.0.0
   ```

2. **Click "Publish changes"** in Firebase

3. **Restart your app** (hot reload won't work, need full restart)

4. **Expected Result:**
   - Console shows: `Result: FORCE UPDATE REQUIRED`
   - Force update dialog appears
   - Cannot dismiss dialog
   - Only "Update Now" button available

### Test 2: Optional Update

1. **In Firebase Console**, set:
   ```
   force_update_required: false
   minimum_version: 1.0.0
   latest_version: 1.5.0
   ```

2. **Click "Publish changes"**

3. **Restart your app**

4. **Expected Result:**
   - Console shows: `Result: OPTIONAL UPDATE AVAILABLE`
   - Optional update dialog appears
   - Can dismiss with "Later" button
   - Can update with "Update Now" button

### Test 3: No Update

1. **In Firebase Console**, set:
   ```
   force_update_required: false
   minimum_version: 1.0.0
   latest_version: 1.0.0
   ```

2. **Click "Publish changes"**

3. **Restart your app**

4. **Expected Result:**
   - Console shows: `Result: NO UPDATE REQUIRED`
   - No dialog appears
   - App proceeds to login/home

### Test 4: Changing from Force Update to No Update

This is the scenario you mentioned! Here's how to test it:

1. **Start with Force Update**:
   ```
   force_update_required: true
   minimum_version: 2.0.0
   latest_version: 2.0.0
   ```
   - Publish and restart app
   - Force dialog appears ✅

2. **Change to No Update**:
   ```
   force_update_required: false
   minimum_version: 1.0.0
   latest_version: 1.0.0
   ```
   - Click "Publish changes" in Firebase
   - **Stop your app completely** (don't just hot reload)
   - **Restart the app**

3. **Expected Result:**
   - Console shows new values immediately
   - Console shows: `Result: NO UPDATE REQUIRED`
   - No dialog appears
   - App proceeds normally

## 📱 How to Test Properly

### ✅ DO:
1. **Always stop and restart** the app after changing Firebase config
2. **Check console logs** to verify values are updated
3. **Click "Publish changes"** in Firebase Console
4. **Wait 2-3 seconds** after publishing before restarting app

### ❌ DON'T:
1. Don't use hot reload - it won't fetch new config
2. Don't forget to publish changes in Firebase
3. Don't test in release mode - it has 1-hour cache

## 🐛 Troubleshooting

### Issue: Still showing old dialog after changing config

**Solution:**
```bash
# Stop the app completely
# In terminal:
flutter clean
flutter pub get
flutter run

# Or in your IDE:
# 1. Stop the app
# 2. Clear build cache
# 3. Restart
```

### Issue: No console logs visible

**Check:**
- Running in debug mode (not release)
- Console/terminal is visible in your IDE
- No filters hiding logs

### Issue: Changes not reflecting

**Steps:**
1. Verify you clicked "Publish changes" in Firebase Console
2. Wait 5 seconds after publishing
3. Completely stop the app (kill process)
4. Start fresh: `flutter run`
5. Check console logs for latest values

## 🔄 Quick Test Cycle

```bash
# 1. Change config in Firebase Console
# 2. Publish changes
# 3. In terminal:
flutter run

# Watch console output:
# Should see "Fetching latest Remote Config values..."
# Followed by all the config values
# Then the update check result
```

## 📊 Understanding the Logic

### Force Update Decision:
```
IF force_update_required = true 
   AND current_version < minimum_version
THEN show force update dialog
```

### Optional Update Decision:
```
IF force_update_required = false
   AND current_version < latest_version
THEN show optional update dialog
```

### No Update:
```
IF force_update_required = false
   AND current_version >= latest_version
THEN no dialog, proceed normally
```

## 💡 Pro Tips

1. **Always check console logs** - They tell you exactly what's happening
2. **Test all three scenarios** - Force, Optional, No Update
3. **Test the transition** - From force to optional, optional to none, etc.
4. **Full restart required** - Changes only apply on full app restart
5. **Debug mode is your friend** - Immediate fetch makes testing easy

## 🎯 Quick Test Commands

```bash
# Clean restart for fresh test
flutter clean && flutter pub get && flutter run

# Just restart (faster)
flutter run

# Check if running in debug mode
# Look for console logs starting with:
# "Remote Config initialized in DEBUG mode"
```

## ✅ Verification Checklist

- [ ] Console shows "DEBUG mode - immediate fetch enabled"
- [ ] Console displays all Remote Config values
- [ ] Force update dialog appears when expected
- [ ] Optional update dialog appears when expected
- [ ] No dialog when force_update_required = false and versions match
- [ ] Can dismiss optional update with "Later"
- [ ] Cannot dismiss force update (no X button, no back button)
- [ ] "Update Now" opens the correct store

## 🚀 You're Ready!

Now you can test Firebase Remote Config changes **immediately** in debug mode. Just:
1. Change values in Firebase Console
2. Click "Publish changes"
3. Restart your app
4. See changes instantly!

Happy testing! 🎉



