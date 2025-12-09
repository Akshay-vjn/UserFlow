# Force Update Quick Start Guide

## ⚡ Immediate Fetch Feature

**Good News!** In debug mode, the app fetches Firebase Remote Config **immediately** (0 second interval).

- ✅ Changes in Firebase Console reflect **instantly** on app restart
- ✅ No waiting for 1-hour cache
- ✅ Full debug logging in console
- ✅ Production uses 1-hour cache for bandwidth optimization

**Just restart your app after changing Firebase values - changes appear immediately!**

## 🚀 Quick Setup (5 Minutes)

### Step 1: Configure Firebase Remote Config

Go to [Firebase Console](https://console.firebase.google.com/) → Your Project → Remote Config

Add these 7 parameters:

```
force_update_required: false (Boolean)
minimum_version: 1.0.0 (String)
latest_version: 1.0.0 (String)
update_message: "A new version is available. Please update to continue using the app." (String)
optional_update_message: "A new version is available with exciting new features!" (String)
android_store_url: https://play.google.com/store/apps/details?id=YOUR_PACKAGE_ID (String)
ios_store_url: https://apps.apple.com/app/idYOUR_APP_ID (String)
```

**Remember to click "Publish changes"!**

### Step 2: Update Store URLs

Replace placeholder URLs with your actual app URLs:

**Android:**
```
https://play.google.com/store/apps/details?id=com.yourapp.package
```

**iOS:**
```
https://apps.apple.com/app/id123456789
```

### Step 3: Test It!

1. Set in Firebase:
   - `force_update_required` = `true`
   - `minimum_version` = `2.0.0`
   - `latest_version` = `2.0.0`

2. Publish changes

3. Restart your app

4. You should see the force update dialog!

## 🎯 Common Scenarios

### Scenario 1: Force Critical Update
```json
{
  "force_update_required": true,
  "minimum_version": "2.0.0",
  "latest_version": "2.0.0",
  "update_message": "Security update required. Please update now."
}
```
Result: Users **must** update to continue

### Scenario 2: Notify About New Version
```json
{
  "force_update_required": false,
  "minimum_version": "1.0.0",
  "latest_version": "1.5.0",
  "optional_update_message": "New features available! Update now."
}
```
Result: Users can skip and update later

### Scenario 3: No Update Needed
```json
{
  "force_update_required": false,
  "minimum_version": "1.0.0",
  "latest_version": "1.0.0"
}
```
Result: No dialog shown

## 📦 What's Included

✅ **RemoteConfigService** - Manages Firebase Remote Config  
✅ **ForceUpdateService** - Version checking logic  
✅ **ForceUpdateDialog** - Beautiful update UI  
✅ **Auto-check on splash** - Checks on app launch  
✅ **Store redirection** - Opens Play Store/App Store  

## 🔧 Files Created

- `lib/core/services/remote_config_service.dart`
- `lib/core/services/force_update_service.dart`
- `lib/core/widgets/force_update_dialog.dart`

## 📝 Files Modified

- `pubspec.yaml` - Added dependencies
- `lib/main.dart` - Initialize Remote Config
- `lib/features/auth/presentation/splash_screen.dart` - Update check

## 📚 Dependencies Added

```yaml
firebase_remote_config: ^6.0.1
url_launcher: ^6.3.1
package_info_plus: ^8.1.3
```

## ⚠️ Important Notes

1. **Always test** before enabling for all users
2. **Use force update** only for critical updates
3. **Update store URLs** before release
4. **Version format**: Use semantic versioning (e.g., 1.2.3)
5. **Publish changes** in Firebase Console after any update

## 🐛 Troubleshooting

**Dialog not showing?**
- Check if you published changes in Firebase
- Verify your app version in `pubspec.yaml`
- Wait for fetch interval (1 hour) or reduce it for testing

**Store link not working?**
- Verify package ID and App ID are correct
- Use actual published app URLs for testing

## 📖 Full Documentation

See `FORCE_UPDATE_SETUP.md` for detailed documentation.

---

**Need help?** Check the console logs or refer to the source code comments.

