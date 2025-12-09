# 🎯 Version Parameters - Quick Reference

## The Three Versions Explained

```
┌─────────────────────────────────────────────────────────┐
│                    VERSION TIMELINE                      │
│                                                          │
│  1.0.0 ─────── 1.5.0 ────────── 2.0.0 ─────── 3.0.0    │
│                  ↑                ↑                      │
│           minimum_version    latest_version             │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 1️⃣ **Current Version** (Your App)
- Where: `pubspec.yaml` → `version: 1.0.0+1`
- What: The version installed on user's device
- Example: `1.0.0`

### 2️⃣ **minimum_version** (Firebase)
- Where: Firebase Remote Config
- What: **Minimum acceptable version**
- Rule: If user's version < minimum → **FORCE UPDATE**
- Example: `1.5.0`

### 3️⃣ **latest_version** (Firebase)
- Where: Firebase Remote Config  
- What: **Newest version available**
- Rule: If user's version < latest → **OPTIONAL UPDATE**
- Example: `2.0.0`

---

## 🎮 The Decision Tree

```
User Opens App (version X)
          │
          ▼
    ┌─────────────────────────┐
    │ force_update_required?  │
    └─────────────────────────┘
              │
       ┌──────┴──────┐
       │             │
      YES           NO
       │             │
       ▼             │
  ┌─────────────┐    │
  │ X < minimum?│    │
  └─────────────┘    │
       │             │
    ┌──┴──┐          │
   YES    NO         │
    │     │          │
    ▼     │          │
  🚫 FORCE │         │
  UPDATE  │          │
          ▼          ▼
      ┌──────────────────┐
      │  X < latest?     │
      └──────────────────┘
              │
         ┌────┴────┐
        YES       NO
         │         │
         ▼         ▼
    ✅ OPTIONAL  ✅ NO UPDATE
       UPDATE       NEEDED
```

---

## 📊 Real Examples

### Your Current Situation:
```
Current Version: 1.0.0
Minimum Version: 1.0.0  ← You meet minimum ✅
Latest Version: 2.0.0   ← Newer exists ℹ️
Force Required: false   ← No forcing

Result: OPTIONAL UPDATE AVAILABLE
→ Shows dismissible dialog
→ You can skip or update
```

### To Show NO Dialog:
```
Current Version: 1.0.0
Minimum Version: 1.0.0
Latest Version: 1.0.0   ← Change this to 1.0.0
Force Required: false

Result: NO UPDATE REQUIRED
→ No dialog shown
→ Proceeds to app
```

---

## 🎯 Common Scenarios

### Scenario 1: **Force Critical Update**
```yaml
Firebase Config:
  minimum_version: 2.0.0
  latest_version: 2.0.0
  force_update_required: true

User on 1.0.0 → 🚫 MUST UPDATE (blocking dialog)
User on 2.0.0 → ✅ NO DIALOG
```

### Scenario 2: **Encourage Update (No Force)**
```yaml
Firebase Config:
  minimum_version: 1.0.0
  latest_version: 2.0.0
  force_update_required: false

User on 1.0.0 → ✅ OPTIONAL UPDATE (can dismiss)
User on 2.0.0 → ✅ NO DIALOG
```

### Scenario 3: **Disable All Updates**
```yaml
Firebase Config:
  minimum_version: 1.0.0
  latest_version: 1.0.0
  force_update_required: false

User on 1.0.0 → ✅ NO DIALOG
```

---

## 🔢 Version Comparison Logic

### How It Compares:
```
Format: major.minor.patch

Examples:
1.0.0 < 1.0.1  (patch +1)
1.0.1 < 1.1.0  (minor +1)
1.1.0 < 2.0.0  (major +1)
```

### Comparison Table:

| Your App | minimum_version | Result |
|----------|----------------|---------|
| 1.0.0    | 1.5.0         | ❌ Below minimum (force update) |
| 1.5.0    | 1.5.0         | ✅ Meets minimum (OK) |
| 2.0.0    | 1.5.0         | ✅ Above minimum (OK) |

| Your App | latest_version | Result |
|----------|---------------|---------|
| 1.0.0    | 2.0.0        | ℹ️ Below latest (optional update) |
| 2.0.0    | 2.0.0        | ✅ At latest (no update) |

---

## 💡 What minimum_version Really Means

### In Simple Terms:

```
minimum_version = "The oldest version I'll allow"

If user's version < minimum_version:
  → They MUST update (if force_update_required = true)
  
If user's version >= minimum_version:
  → They're OK (but might see optional update)
```

### Use Cases:

| Situation | minimum_version | Why |
|-----------|----------------|-----|
| **Security bug in v1.3** | 1.4.0 | Force users off vulnerable version |
| **API changed** | 2.0.0 | Old versions won't work |
| **Critical crash** | 1.2.5 | Force to fixed version |
| **Just new features** | 1.0.0 | Keep minimum low, encourage update |

---

## 🛠️ How to Configure

### In Firebase Console:

```
1. Go to: Remote Config
2. Find parameter: minimum_version
3. Set value: 1.0.0 (or your choice)
4. Click: Publish changes
```

### Decision Guide:

**Want to force update?**
```
minimum_version = [version they must have]
force_update_required = true
```

**Want to suggest update?**
```
minimum_version = [keep low, like 1.0.0]
latest_version = [newest version]
force_update_required = false
```

**Want no dialogs?**
```
minimum_version = [current app version]
latest_version = [current app version]
force_update_required = false
```

---

## 📱 What Users See

### Force Update (minimum not met):
```
┌─────────────────────────────┐
│  ⚠️  Update Required         │
│                             │
│  A critical update is       │
│  required to continue.      │
│                             │
│  Current: 1.0.0             │
│  Required: 2.0.0            │
│                             │
│      [Update Now]           │
│                             │
│  (Cannot dismiss)           │
└─────────────────────────────┘
```

### Optional Update (latest available):
```
┌─────────────────────────────┐
│  ℹ️  Update Available        │
│                             │
│  New features available!    │
│                             │
│  Current: 1.0.0             │
│  Latest: 2.0.0              │
│                             │
│  [Later]    [Update Now]    │
│                             │
│  (Can dismiss)              │
└─────────────────────────────┘
```

---

## ✅ Quick Checklist

To understand your current setup:

- [ ] Check `pubspec.yaml` for **current app version**
- [ ] Check Firebase for **minimum_version** value
- [ ] Check Firebase for **latest_version** value  
- [ ] Check Firebase for **force_update_required** value
- [ ] Compare: current vs minimum vs latest

### Formula:
```
IF current < minimum AND force_required = true:
  → FORCE UPDATE 🚫

ELSE IF current < latest:
  → OPTIONAL UPDATE ✅

ELSE:
  → NO UPDATE NEEDED ✅
```

---

## 🎯 Your Quick Fix

**From your logs:**
```
Current: 1.0.0
Minimum: 1.0.0  ✅ (you meet it)
Latest: 2.0.0   ℹ️ (newer available)
Result: Optional update shown
```

**To remove dialog:**
```
Change in Firebase:
latest_version: 1.0.0  (match your current version)
```

**Or to force update:**
```
Change in Firebase:
minimum_version: 2.0.0
force_update_required: true
```

---

**See `MINIMUM_VERSION_EXPLAINED.md` for detailed explanation!** 📚



