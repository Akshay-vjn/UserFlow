# Understanding minimum_version in Force Update

## 🎯 What is minimum_version?

**`minimum_version`** is the **lowest acceptable app version** that users can continue using without being forced to update.

If a user's app version is **below** the minimum version, they **must update** (force update).

## 📊 The Three Version Parameters

### 1. **Current Version** (Your App)
- Defined in `pubspec.yaml`
- Example: `version: 1.0.0+1`
- The version currently installed on the user's device

### 2. **minimum_version** (Firebase Remote Config)
- **Purpose:** The minimum acceptable version
- **Action:** If user's version < minimum → **FORCE UPDATE**
- **Example:** `1.5.0`

### 3. **latest_version** (Firebase Remote Config)
- **Purpose:** The newest version available
- **Action:** If user's version < latest → **OPTIONAL UPDATE**
- **Example:** `2.0.0`

## 🎮 How They Work Together

```
Timeline of Your App Versions:
1.0.0 → 1.2.0 → 1.5.0 → 1.8.0 → 2.0.0
                  ↑              ↑
            minimum_version   latest_version
```

### Example Scenario:

**Firebase Remote Config:**
```
force_update_required: true
minimum_version: 1.5.0
latest_version: 2.0.0
```

**User Experiences:**

| User's App Version | What Happens | Why |
|-------------------|--------------|-----|
| **1.0.0** | 🚫 FORCE UPDATE | 1.0.0 < 1.5.0 (below minimum) |
| **1.2.0** | 🚫 FORCE UPDATE | 1.2.0 < 1.5.0 (below minimum) |
| **1.5.0** | ✅ OPTIONAL UPDATE | 1.5.0 = minimum, but < 2.0.0 (latest) |
| **1.8.0** | ✅ OPTIONAL UPDATE | 1.8.0 > minimum, but < 2.0.0 (latest) |
| **2.0.0** | ✅ NO UPDATE | 2.0.0 = latest (up to date) |

## 🔍 Detailed Logic Flow

```
User opens app with version X

Step 1: Check Force Update
├─ Is force_update_required = true?
│  ├─ YES → Check: Is X < minimum_version?
│  │  ├─ YES → 🚫 FORCE UPDATE (must update)
│  │  └─ NO → Continue to Step 2
│  └─ NO → Continue to Step 2

Step 2: Check Optional Update
├─ Is X < latest_version?
│  ├─ YES → ✅ OPTIONAL UPDATE (can skip)
│  └─ NO → ✅ NO UPDATE NEEDED

Result: User proceeds to app
```

## 💡 Real-World Examples

### Example 1: Critical Security Fix

**Scenario:** Version 1.3.0 has a security vulnerability

**Firebase Config:**
```
force_update_required: true
minimum_version: 1.4.0    ← Fixed version
latest_version: 1.5.0     ← Newest version
```

**Results:**
- Users on 1.0.0, 1.1.0, 1.2.0, 1.3.0 → **MUST UPDATE** (security risk)
- Users on 1.4.0 → See optional update to 1.5.0
- Users on 1.5.0+ → No dialog

---

### Example 2: Breaking API Change

**Scenario:** Your backend API changed in a way that only works with app v2.0.0+

**Firebase Config:**
```
force_update_required: true
minimum_version: 2.0.0    ← First version compatible with new API
latest_version: 2.0.0     ← Same as minimum (no newer version yet)
```

**Results:**
- Users on 1.x.x → **MUST UPDATE** (won't work with new API)
- Users on 2.0.0 → No dialog

---

### Example 3: Encouraging Updates (No Force)

**Scenario:** You released new features, but old versions still work fine

**Firebase Config:**
```
force_update_required: false
minimum_version: 1.0.0    ← Any version is acceptable
latest_version: 2.5.0     ← New version with cool features
```

**Results:**
- Users on < 2.5.0 → See optional update (can skip)
- Users on 2.5.0 → No dialog

---

### Example 4: Gradual Rollout

**Scenario:** Rolling out v3.0.0, but keeping v2.0.0 as minimum

**Firebase Config:**
```
force_update_required: true
minimum_version: 2.0.0    ← Users must be at least here
latest_version: 3.0.0     ← Newest available
```

**Results:**
- Users on 1.x.x → **FORCE UPDATE** (too old)
- Users on 2.x.x → Optional update to 3.0.0
- Users on 3.0.0 → No dialog

## 🎯 When to Use minimum_version

### Use Cases for Setting minimum_version:

1. **Security Fixes**
   - Old versions have vulnerabilities
   - Force users to update to secure version

2. **Breaking Changes**
   - API changes that break old app versions
   - Database schema changes
   - Protocol updates

3. **Critical Bug Fixes**
   - App-breaking bugs in older versions
   - Data corruption issues

4. **Compliance Requirements**
   - Legal or regulatory requirements
   - Terms of service changes

5. **Deprecating Features**
   - Removing support for old features
   - Sunsetting old APIs

## ⚙️ How to Set minimum_version

### Strategy 1: Conservative (Recommended)

Keep minimum_version **1-2 major versions behind** latest:

```
Current app in store: 3.0.0
minimum_version: 2.0.0
latest_version: 3.0.0

→ Users on v1.x must update
→ Users on v2.x see optional update
```

### Strategy 2: Aggressive

Force everyone to latest version:

```
minimum_version: 3.0.0
latest_version: 3.0.0

→ Everyone below 3.0.0 must update
```

### Strategy 3: Permissive

Allow older versions, just notify:

```
force_update_required: false
minimum_version: 1.0.0
latest_version: 3.0.0

→ No force updates
→ Everyone sees optional update notification
```

## 📱 Version Comparison Examples

### How Versions are Compared:

```
Format: major.minor.patch

1.0.0 < 1.0.1   ← Patch increase
1.0.1 < 1.1.0   ← Minor increase
1.1.0 < 2.0.0   ← Major increase
```

### Real Comparison Examples:

| User Version | minimum: 1.5.0 | minimum: 2.0.0 | minimum: 1.9.5 |
|--------------|----------------|----------------|----------------|
| 1.0.0        | ❌ Force Update | ❌ Force Update | ❌ Force Update |
| 1.4.9        | ❌ Force Update | ❌ Force Update | ❌ Force Update |
| 1.5.0        | ✅ OK          | ❌ Force Update | ❌ Force Update |
| 1.9.5        | ✅ OK          | ❌ Force Update | ✅ OK          |
| 2.0.0        | ✅ OK          | ✅ OK          | ✅ OK          |

## 🔄 Common Patterns

### Pattern 1: Initial Release
```
App Version: 1.0.0
minimum_version: 1.0.0
latest_version: 1.0.0
force_update_required: false

→ Everyone on 1.0.0, no updates needed
```

### Pattern 2: Bug Fix Release
```
App Version: 1.0.1
minimum_version: 1.0.0  ← Still accept 1.0.0
latest_version: 1.0.1   ← New version available
force_update_required: false

→ Users on 1.0.0 see optional update
→ Users on 1.0.1 see nothing
```

### Pattern 3: Critical Fix
```
App Version: 1.0.2
minimum_version: 1.0.2  ← Must have this version
latest_version: 1.0.2
force_update_required: true

→ Everyone below 1.0.2 must update immediately
```

### Pattern 4: Major Update with Grace Period
```
App Version: 2.0.0
minimum_version: 1.5.0  ← Give grace period
latest_version: 2.0.0
force_update_required: true

→ Users on < 1.5.0 must update
→ Users on 1.5.0-1.9.9 see optional update
→ Users on 2.0.0 see nothing
```

## ✅ Best Practices

### 1. **Start Conservative**
```
Don't force update unless necessary
minimum_version: [few versions behind latest]
```

### 2. **Give Warning Before Force Update**
```
Week 1: Optional update (force_update_required: false)
Week 2: Force update (force_update_required: true)
```

### 3. **Monitor Adoption**
```
Check analytics to see update adoption rates
Adjust minimum_version based on data
```

### 4. **Test Before Enabling**
```
Test force update on beta users first
Ensure update flow works smoothly
```

### 5. **Clear Communication**
```
update_message: "Critical security update required"
Be specific about why users need to update
```

## 🎓 Summary

| Parameter | Purpose | Effect |
|-----------|---------|--------|
| **minimum_version** | Lowest acceptable version | Users below this **must** update (if force enabled) |
| **latest_version** | Newest version available | Users below this **may** update (optional) |
| **force_update_required** | Enable force update | `true` = enforce minimum, `false` = suggest latest |

### Key Takeaway:
```
minimum_version = "You MUST be at least this version"
latest_version = "This is the newest version available"
```

## 🚀 Your Current Setup

From your logs:
```
Current Version: 1.0.0
Minimum Version: 1.0.0  ← You're meeting minimum requirement
Latest Version: 2.0.0   ← Newer version available
Force Update Required: false
Result: OPTIONAL UPDATE AVAILABLE  ← Can skip the update
```

**Translation:**
- ✅ Your version (1.0.0) is acceptable (meets minimum)
- ℹ️ A newer version (2.0.0) exists
- ✅ You can choose to update or skip

**To remove the dialog:**
Set `latest_version: 1.0.0` in Firebase Remote Config

---

**Questions? Check the other documentation files or see the console logs for real-time version checking!** 📚



