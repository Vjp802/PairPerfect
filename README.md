# PairPerfect - Setup Instructions

## Quick Setup (Recommended)

Follow these steps to get the app running in Xcode:

### Step 1: Create a New Xcode Project
1. Open **Xcode**
2. **File** → **New** → **Project**
3. Choose **iOS** → **App**
4. Click **Next**

### Step 2: Configure Project Settings
- **Product Name**: `PairPerfect`
- **Team**: Select your team (or leave as "None")
- **Organization Identifier**: `com.yourname` (any identifier)
- **Interface**: **SwiftUI** ← IMPORTANT!
- **Language**: **Swift**
- **Storage**: None
- **Include Tests**: Uncheck both boxes (optional)
- Click **Create** and save it wherever you want

### Step 3: Add the Code Files

You'll see a default file structure like this:
```
PairPerfect/
├── PairPerfectApp.swift  (DELETE THIS)
├── ContentView.swift     (DELETE THIS)
└── Assets.xcassets
```

**Delete** both `PairPerfectApp.swift` and `ContentView.swift`.

Now **add** our three files:

#### Option A: Copy-Paste (Easiest)

1. **Right-click** on the `PairPerfect` folder in the Project Navigator
2. Select **New File** → **Swift File**
3. Name it `Models.swift`
4. **Copy the contents** from `/Users/peta0006/iphone_wine_app/Models.swift` and paste into this file
5. Repeat for `WineMatcherViewModel.swift`
6. Repeat for `Views.swift`

#### Option B: Drag & Drop

1. Open Finder and navigate to `/Users/peta0006/iphone_wine_app/`
2. **Drag** the three `.swift` files into the Xcode Project Navigator
3. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Make sure your target is selected under "Add to targets"
   - Click **Finish**

### Step 4: Verify File Structure

Your project should now look like:
```
PairPerfect/
├── Models.swift
├── WineMatcherViewModel.swift
├── Views.swift
└── Assets.xcassets
```

### Step 5: Build & Run

1. Select a simulator (e.g., **iPhone 15 Pro**)
2. Press **⌘R** or click the **Play ▶️** button
3. The app should compile and launch!

---

## Troubleshooting

### Error: "Type 'WineMatcherViewModel' does not conform to protocol 'ObservableObject'"

**Fix**: Make sure `WineMatcherViewModel.swift` imports Combine:
```swift
import Foundation
import SwiftUI
import Combine  // ← This line must be present
```

### Error: "Cannot find 'Wine' in scope" or similar

**Fix**: All three files must be in the **same target**. When you added the files:
- Make sure you checked the box next to your app target name
- If you missed this, select each file and check the "Target Membership" panel on the right

### Build Failed: Multiple errors

**Fix**: Make sure you **deleted** the default `PairPerfectApp.swift` file. You can't have two `@main` entry points.

### Simulator shows blank screen

**Fix**: Stop the app (⌘.) and rebuild (⌘B), then run again (⌘R).

---

## Testing the App

Once running, try these scenarios:

### Test 1: Basic Flow
1. Tap "Get Started" on onboarding
2. Select **Ribeye** + **Medium-Rare**
3. Add **Blue Cheese**
4. Tap "Continue"
5. Leave defaults on preferences
6. Tap "Find My Wines"
7. You should see 3 wine recommendations!

### Test 2: Budget Filtering
1. Go through the flow again
2. On preferences screen, set budget slider to **$60**
3. Tap "Find My Wines"
4. You should only see wines under $60

### Test 3: Tolerance Testing
1. Set **Tannin Tolerance** to **2** (low)
2. Tap "Find My Wines"
3. You should see lighter wines recommended

---

## File Descriptions

- **Models.swift** (204 lines)
  - All data structures: Wine, SteakOrder, UserPreferences, etc.
  - Enum definitions for cuts, doneness, add-ons
  
- **WineMatcherViewModel.swift** (255 lines)
  - Scoring algorithm (100-point system)
  - Recommendation engine
  - 6 sample wines pre-loaded
  
- **Views.swift** (515 lines)
  - All SwiftUI screens
  - App entry point (@main)
  - Custom UI components

---

## Sample Wines Included

1. **Stag's Leap Artemis** - Cabernet Sauvignon, $65
2. **Duckhorn Merlot** - Merlot, $55
3. **Ridge Geyserville** - Zinfandel Blend, $48
4. **Antica Terra Willamette** - Pinot Noir, $75
5. **Caymus Cabernet** - Cabernet Sauvignon, $95
6. **Beaucastel Châteauneuf** - Grenache Blend, $85

---

## Next Steps

Once the app is working:
- **Add more wines** to the sample data in `WineMatcherViewModel.swift` (line 227)
- **Customize colors** in the hex color codes
- **Add more steak cuts** or expand to other proteins
- **Export as a real app** to your iPhone for testing

Enjoy! 🍷
