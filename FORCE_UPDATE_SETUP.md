# Firebase Remote Config Force Update Setup Guide

This guide explains how to configure and use the Force Update feature in your Flutter app using Firebase Remote Config.

## Overview

The Force Update feature has been successfully implemented in your app. It allows you to:
- **Force Update**: Require users to update the app before they can continue using it
- **Optional Update**: Show a notification about available updates that users can skip
- Compare app versions automatically
- Redirect users to Play Store (Android) or App Store (iOS)

## Architecture

### Files Created/Modified:

1. **`lib/core/services/remote_config_service.dart`** - Manages Firebase Remote Config
2. **`lib/core/services/force_update_service.dart`** - Handles version comparison and update logic
3. **`lib/core/widgets/force_update_dialog.dart`** - UI dialog for update notifications
4. **`lib/main.dart`** - Initialize Remote Config on app startup
5. **`lib/features/auth/presentation/splash_screen.dart`** - Check for updates during splash screen

## Firebase Console Setup

### Step 1: Add Remote Config Parameters

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Remote Config** in the left sidebar
4. Click **"Add parameter"** and create the following parameters:

#### Required Parameters:

| Parameter Key | Type | Default Value | Description |
|--------------|------|---------------|-------------|
| `force_update_required` | Boolean | `false` | Enable/disable force update |
| `minimum_version` | String | `1.0.0` | Minimum app version required |
| `latest_version` | String | `1.0.0` | Latest available version |
| `update_message` | String | "A new version is available. Please update to continue using the app." | Force update message |
| `optional_update_message` | String | "A new version is available with exciting new features!" | Optional update message |
| `android_store_url` | String | `https://play.google.com/store/apps/details?id=YOUR_PACKAGE_ID` | Google Play Store URL |
| `ios_store_url` | String | `https://apps.apple.com/app/idYOUR_APP_ID` | App Store URL |

### Step 2: Configure Store URLs

#### Android Store URL:
Replace `YOUR_PACKAGE_ID` with your actual Android package ID (found in `android/app/build.gradle.kts`):
```
https://play.google.com/store/apps/details?id=com.example.userflow
```

#### iOS Store URL:
Replace `YOUR_APP_ID` with your actual App Store ID:
```
https://apps.apple.com/app/id123456789
```

### Step 3: Publish Your Changes

After adding all parameters, click **"Publish changes"** in the Firebase Console.

## How It Works

### Version Comparison Logic

The app compares versions using semantic versioning (e.g., `1.2.3`):
- **Major.Minor.Patch** format
- Compares each part sequentially
- `1.0.0` < `1.0.1` < `1.1.0` < `2.0.0`

### Update Flow

1. **App Launch**: Remote Config is initialized in `main.dart`
2. **Splash Screen**: Version check is performed
3. **Force Update Required**:
   - User sees a dialog they cannot dismiss
   - Must tap "Update Now" to go to the store
   - App navigation is blocked until update
4. **Optional Update Available**:
   - User sees a dialog with "Later" and "Update Now" options
   - Can dismiss and continue using the app
   - App proceeds to login/home screen

## Usage Examples

### Example 1: Force Update for All Users Below Version 2.0.0

Set these values in Firebase Remote Config:
```json
{
  "force_update_required": true,
  "minimum_version": "2.0.0",
  "latest_version": "2.0.0",
  "update_message": "Critical security update required. Please update to version 2.0.0 to continue."
}
```

### Example 2: Optional Update Notification

Set these values in Firebase Remote Config:
```json
{
  "force_update_required": false,
  "minimum_version": "1.0.0",
  "latest_version": "1.5.0",
  "optional_update_message": "Version 1.5.0 is now available with new features and improvements!"
}
```

### Example 3: No Update (Default)

```json
{
  "force_update_required": false,
  "minimum_version": "1.0.0",
  "latest_version": "1.0.0"
}
```

## Testing

### Test Force Update:

1. Note your current app version in `pubspec.yaml` (e.g., `1.0.0`)
2. In Firebase Remote Config, set:
   - `force_update_required` = `true`
   - `minimum_version` = `2.0.0`
   - `latest_version` = `2.0.0`
3. Publish changes
4. Restart your app
5. You should see the force update dialog on the splash screen

### Test Optional Update:

1. In Firebase Remote Config, set:
   - `force_update_required` = `false`
   - `minimum_version` = `1.0.0`
   - `latest_version` = `1.5.0`
2. Publish changes
3. Restart your app
4. You should see the optional update dialog with "Later" button

## Customization

### Modify Update Check Timing

Currently, the update check happens on the splash screen. You can also add it to other screens:

```dart
// In any screen
final forceUpdateService = ref.read(forceUpdateServiceProvider);
final updateInfo = await forceUpdateService.checkForUpdate();

if (updateInfo.status == UpdateStatus.forceUpdateRequired) {
  // Show force update dialog
}
```

### Customize Dialog Appearance

Edit `lib/core/widgets/force_update_dialog.dart` to change:
- Colors
- Text styles
- Button appearance
- Dialog layout

### Change Fetch Interval

Edit `lib/core/services/remote_config_service.dart`:

```dart
await _remoteConfig!.setConfigSettings(
  RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1), // Change this value
  ),
);
```

## Troubleshooting

### Remote Config not updating

1. Check if you published changes in Firebase Console
2. Wait for the fetch interval to pass (default: 1 hour)
3. For immediate testing, lower the `minimumFetchInterval` in development

### Update dialog not showing

1. Verify Remote Config is initialized in `main.dart`
2. Check Firebase Console for correct parameter values
3. Ensure your app version in `pubspec.yaml` is set correctly
4. Check console logs for any errors

### Store links not working

1. Verify store URLs are correct in Remote Config
2. Ensure package ID (Android) or App ID (iOS) matches your published app
3. For testing, use a published app's URL

## Version Update Checklist

When releasing a new version:

1. ✅ Update version in `pubspec.yaml`
2. ✅ Update `latest_version` in Firebase Remote Config
3. ✅ Decide if force update is needed
4. ✅ Set `minimum_version` if forcing update
5. ✅ Update `force_update_required` accordingly
6. ✅ Customize update messages if needed
7. ✅ Publish changes in Firebase Console
8. ✅ Build and release your app

## Best Practices

1. **Gradual Rollout**: Don't force update immediately. Give users time to update voluntarily.
2. **Clear Messages**: Provide clear, user-friendly update messages explaining why the update is needed.
3. **Test First**: Always test the update flow before enabling for all users.
4. **Version Strategy**: Use force update only for critical security updates or breaking changes.
5. **Monitor**: Watch app analytics to see update adoption rates.

## Additional Resources

- [Firebase Remote Config Documentation](https://firebase.google.com/docs/remote-config)
- [Flutter Package Info Plus](https://pub.dev/packages/package_info_plus)
- [URL Launcher Plugin](https://pub.dev/packages/url_launcher)

## Support

If you encounter any issues or need modifications to the force update feature, refer to the source files or consult the Flutter and Firebase documentation.



