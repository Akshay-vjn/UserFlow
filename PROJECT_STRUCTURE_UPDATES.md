# Project Structure Updates - Force Update Feature

## 📁 New File Structure

```
UserFlow/
│
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── connectivity_service.dart
│   │   │   ├── notification_provider.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── remote_config_service.dart      ✨ NEW
│   │   │   └── force_update_service.dart       ✨ NEW
│   │   │
│   │   └── widgets/
│   │       ├── no_network_screen.dart
│   │       └── force_update_dialog.dart        ✨ NEW
│   │
│   ├── features/
│   │   └── auth/
│   │       └── presentation/
│   │           ├── splash_screen.dart          🔧 MODIFIED
│   │           └── ...
│   │
│   ├── main.dart                               🔧 MODIFIED
│   └── ...
│
├── pubspec.yaml                                🔧 MODIFIED
├── FORCE_UPDATE_SETUP.md                       ✨ NEW (Documentation)
├── QUICK_START_FORCE_UPDATE.md                 ✨ NEW (Quick Reference)
├── IMPLEMENTATION_SUMMARY.md                   ✨ NEW (Summary)
└── PROJECT_STRUCTURE_UPDATES.md                ✨ NEW (This file)
```

## 🔄 Service Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Main Application                    │
│                      (main.dart)                        │
│                                                         │
│  1. Initialize Firebase                                │
│  2. Initialize RemoteConfigService                     │
│  3. Provide to app via Riverpod                        │
└─────────────────────────────────────────────────────────┘
                           │
                           ├──────────────────────────────┐
                           │                              │
                           ▼                              ▼
┌─────────────────────────────────────┐  ┌─────────────────────────────────┐
│    RemoteConfigService              │  │    ForceUpdateService           │
│                                     │  │                                 │
│  • Initialize Firebase RC           │  │  • Check for updates            │
│  • Set default values               │  │  • Compare versions             │
│  • Fetch & activate                 │  │  • Determine update status      │
│  • Get config values                │  │  • Open app store               │
│  • Refresh config                   │  │                                 │
│                                     │  │  Depends on:                    │
│  Provides:                          │  │  • RemoteConfigService          │
│  • force_update_required            │  │  • PackageInfo                  │
│  • minimum_version                  │◄─┤  • UrlLauncher                  │
│  • latest_version                   │  │                                 │
│  • update_message                   │  │  Returns:                       │
│  • optional_update_message          │  │  • UpdateInfo                   │
│  • android_store_url                │  │    - status                     │
│  • ios_store_url                    │  │    - current_version            │
└─────────────────────────────────────┘  │    - latest_version             │
                                         │    - message                    │
                                         │    - store_url                  │
                                         └─────────────────────────────────┘
                                                        │
                                                        │ Used by
                                                        ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                          Splash Screen                                   │
│                                                                          │
│  1. Show splash animation                                               │
│  2. Check for updates (ForceUpdateService)                              │
│  3. Show dialog if needed:                                              │
│     • Force Update → Show blocking dialog                               │
│     • Optional Update → Show dismissible dialog                         │
│     • No Update → Continue to app                                       │
└──────────────────────────────────────────────────────────────────────────┘
                                         │
                                         │ Uses
                                         ▼
                    ┌─────────────────────────────────┐
                    │   ForceUpdateDialog (Widget)    │
                    │                                 │
                    │  • Display update info          │
                    │  • Version comparison UI        │
                    │  • Update/Later buttons         │
                    │  • Blocking/Non-blocking        │
                    └─────────────────────────────────┘
```

## 📊 Data Flow

```
Firebase Remote Config (Cloud)
        │
        │ Fetch & Activate
        ▼
RemoteConfigService
        │
        │ Config Values
        ▼
ForceUpdateService
        │
        │ checkForUpdate()
        ├─────────────────────┬─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   Force Update        Optional Update        No Update
        │                     │                     │
        ▼                     ▼                     ▼
  Show Blocking         Show Dismissible      Continue to
     Dialog                  Dialog               App
        │                     │                     │
        ▼                     ├────────────────────►│
  Open Store                  │                     │
                             ▼                     │
                       Open Store                  │
                       or Skip                     │
                             │                     │
                             └────────────────────►│
                                                   ▼
                                              Login/Home
```

## 🎯 Update Decision Logic

```
┌─────────────────────────────────────┐
│   Check Current App Version         │
└─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│   Get Remote Config Values:         │
│   • force_update_required           │
│   • minimum_version                 │
│   • latest_version                  │
└─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│   Is force_update_required = true   │
│   AND                               │
│   current_version < minimum_version?│
└─────────────────────────────────────┘
        │               │
       Yes             No
        │               │
        ▼               ▼
  ┌─────────┐   ┌─────────────────────────┐
  │  FORCE  │   │ current_version <       │
  │ UPDATE  │   │ latest_version?         │
  └─────────┘   └─────────────────────────┘
                    │               │
                   Yes             No
                    │               │
                    ▼               ▼
              ┌──────────┐   ┌──────────┐
              │ OPTIONAL │   │    NO    │
              │  UPDATE  │   │  UPDATE  │
              └──────────┘   └──────────┘
```

## 🔌 Dependency Graph

```
package_info_plus
        │
        ▼
ForceUpdateService ─────► RemoteConfigService ─────► Firebase Remote Config
        │                                                    │
        │                                                    │
        ▼                                                    │
  url_launcher                                              │
        │                                                    │
        └──────────► Open App Store                         │
                                                            │
                                                            ▼
                                                      Firebase Console
                                                      (Configuration)
```

## 📝 Configuration Flow

```
Developer                Firebase Console              User Device
    │                           │                           │
    │  1. Add Parameters        │                           │
    ├──────────────────────────►│                           │
    │                           │                           │
    │  2. Set Values            │                           │
    ├──────────────────────────►│                           │
    │                           │                           │
    │  3. Publish Changes       │                           │
    ├──────────────────────────►│                           │
    │                           │                           │
    │                           │  4. App Launches          │
    │                           │◄──────────────────────────│
    │                           │                           │
    │                           │  5. Fetch Config          │
    │                           ├──────────────────────────►│
    │                           │                           │
    │                           │  6. Compare Versions      │
    │                           │                           │
    │                           │  7. Show Dialog (if needed)│
    │                           │                           │
```

## 🛠️ Code Dependencies

### RemoteConfigService Dependencies:
```dart
firebase_remote_config: ^6.0.1
flutter_riverpod: ^2.6.1
```

### ForceUpdateService Dependencies:
```dart
package_info_plus: ^8.1.3
url_launcher: ^6.3.1
dart:io (Platform detection)
```

### ForceUpdateDialog Dependencies:
```dart
flutter/material.dart
```

## 📱 Platform Support

```
┌────────────────────────────────┐
│   Force Update Feature         │
│                                │
│   ✅ Android (Play Store)      │
│   ✅ iOS (App Store)           │
│   ✅ Web (Future support)      │
│                                │
└────────────────────────────────┘
```

## 🔄 Version Comparison Logic

```dart
Version: "1.2.3"
          │ │ │
          │ │ └─ Patch
          │ └─── Minor
          └───── Major

Comparison Examples:
1.0.0 < 1.0.1  ✅
1.0.1 < 1.1.0  ✅
1.1.0 < 2.0.0  ✅
2.0.0 = 2.0.0  ✅
2.0.1 > 2.0.0  ✅
```

## 🎨 UI Components

```
ForceUpdateDialog
├── Title (with icon)
│   └── "Update Required" or "Update Available"
├── Content
│   ├── Update message
│   └── Version comparison card
│       ├── Current Version
│       ├── Arrow icon
│       └── Latest Version
└── Actions
    ├── "Later" button (optional update only)
    └── "Update Now" button
```

## 🧩 Integration Points

```
1. main.dart
   └── Initialize RemoteConfigService
       └── Provide to app

2. splash_screen.dart
   └── Check for updates
       ├── Force update → Show blocking dialog
       ├── Optional update → Show dismissible dialog
       └── No update → Continue

3. Any future screen (optional)
   └── Can also check for updates
       └── Use forceUpdateServiceProvider
```

---

This structure provides a clean, maintainable, and scalable implementation of the force update feature.



