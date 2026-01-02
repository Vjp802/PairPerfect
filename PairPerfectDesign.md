# PairPerfect - Wine Pairing App Design

## Overview
PairPerfect is an iPhone app that helps diners choose the perfect wine from a restaurant's menu based on their steak order and personal taste preferences.

---

## Screen List

### 1. **Onboarding/Welcome Screen**
- App logo and tagline
- Brief explanation of how it works
- "Get Started" button

### 2. **Wine Menu Input Screen**
- Option to:
  - Scan menu (future feature placeholder)
  - Manual entry of wines
  - Load sample menu (for demo)
- List view of entered wines

### 3. **Steak Selection Screen**
- **Cut Selection**: Dropdown/picker for cuts (Ribeye, Filet Mignon, NY Strip, Porterhouse, T-Bone, Sirloin, etc.)
- **Doneness**: Segmented control (Rare, Medium-Rare, Medium, Medium-Well, Well-Done)
- **Add-ons**: Multi-select checkboxes
  - Au Poivre
  - Bordelaise
  - Blue Cheese
  - Demi-glace
  - Bourbon Glaze
  - Shrimp Oscar

### 4. **Taste Preferences Screen**
- **Budget Slider**: Price range ($-$$$$)
- **Tolerance Sliders** (0-10 scale):
  - Tannin Tolerance (Light & Smooth ↔ Bold & Grippy)
  - Oak Tolerance (Fresh & Crisp ↔ Rich & Oaky)
  - Spice Tolerance (Soft & Mellow ↔ Peppery & Spicy)
  - Funk Tolerance (Clean & Fruity ↔ Earthy & Funky)
- "Find My Wines" button

### 5. **Results Screen**
- **Top 3 Recommendations** (cards with):
  - Wine name
  - Grape/style
  - Region
  - Price
  - Match score (percentage or stars)
  - Friendly explanation (2-3 sentences)
  - "Select This Wine" button
- **Swap Suggestion Section**:
  - "Want to try something different?" header
  - One alternative wine with explanation
- "Start Over" button
- "Adjust Preferences" button (returns to screen 4)

### 6. **Wine Detail Screen**
- Full wine information
- Why it pairs well (detailed)
- Tasting notes
- "I'll Take It" button

---

## Navigation Flow

```
Onboarding → Wine Menu Input → Steak Selection → Taste Preferences → Results
                                                                         ↓
                                                                   Wine Detail
```

**Flow Details:**
1. User launches app → Onboarding (first time only)
2. User inputs/loads wine menu → Wine Menu Input
3. User selects steak and add-ons → Steak Selection
4. User adjusts taste preferences → Taste Preferences
5. User taps "Find My Wines" → Results
6. User can:
   - Tap a wine card → Wine Detail
   - Tap "Adjust Preferences" → Back to Taste Preferences
   - Tap "Start Over" → Back to Wine Menu Input

---

## Data Models

### Wine
```swift
struct Wine: Identifiable, Codable {
    let id: UUID
    var name: String
    var grape: String           // e.g., "Cabernet Sauvignon"
    var style: String           // e.g., "Full-bodied red"
    var region: String          // e.g., "Napa Valley, CA"
    var price: Double
    var vintage: Int?
    
    // Internal characteristics (for scoring)
    var tanninLevel: Int        // 1-10
    var oakLevel: Int           // 1-10
    var spiceLevel: Int         // 1-10
    var funkLevel: Int          // 1-10 (earthiness/brett)
    var bodyLevel: Int          // 1-10 (light to full)
    var acidityLevel: Int       // 1-10
}
```

### SteakOrder
```swift
struct SteakOrder: Codable {
    var cut: SteakCut
    var doneness: Doneness
    var addOns: [AddOn]
}

enum SteakCut: String, CaseIterable, Codable {
    case ribeye = "Ribeye"
    case filetMignon = "Filet Mignon"
    case nyStrip = "NY Strip"
    case porterhouse = "Porterhouse"
    case tBone = "T-Bone"
    case sirloin = "Sirloin"
    case flatIron = "Flat Iron"
    case skirt = "Skirt Steak"
    
    // Base characteristics
    var fattiness: Int { // 1-10
        switch self {
        case .ribeye: return 9
        case .filetMignon: return 4
        case .nyStrip: return 7
        case .porterhouse: return 8
        case .tBone: return 8
        case .sirloin: return 5
        case .flatIron: return 6
        case .skirt: return 6
        }
    }
    
    var intensity: Int { // 1-10 (flavor intensity)
        switch self {
        case .ribeye: return 9
        case .filetMignon: return 5
        case .nyStrip: return 8
        case .porterhouse: return 8
        case .tBone: return 8
        case .sirloin: return 6
        case .flatIron: return 7
        case .skirt: return 8
        }
    }
}

enum Doneness: String, CaseIterable, Codable {
    case rare = "Rare"
    case mediumRare = "Medium-Rare"
    case medium = "Medium"
    case mediumWell = "Medium-Well"
    case wellDone = "Well-Done"
    
    var tanninBoost: Double { // Charring increases tannin affinity
        switch self {
        case .rare: return 0.7
        case .mediumRare: return 0.85
        case .medium: return 1.0
        case .mediumWell: return 1.15
        case .wellDone: return 1.3
        }
    }
}

enum AddOn: String, CaseIterable, Codable {
    case auPoivre = "Au Poivre"
    case bordelaise = "Bordelaise"
    case blueCheese = "Blue Cheese"
    case demiGlace = "Demi-glace"
    case bourbonGlaze = "Bourbon Glaze"
    case shrimpOscar = "Shrimp Oscar"
    
    var spiceAdjustment: Int {
        switch self {
        case .auPoivre: return 3       // Peppery = needs spice tolerance
        case .bordelaise: return 1
        case .blueCheese: return 0
        case .demiGlace: return 0
        case .bourbonGlaze: return 1
        case .shrimpOscar: return 0
        }
    }
    
    var funkAdjustment: Int {
        switch self {
        case .blueCheese: return 4     // Funky cheese = needs funk tolerance
        case .bordelaise: return 2     // Wine sauce = earthier pairing
        case .auPoivre: return 1
        case .demiGlace: return 1
        case .bourbonGlaze: return 0
        case .shrimpOscar: return -2   // Seafood = cleaner wine
        }
    }
    
    var richnessAdjustment: Int {
        switch self {
        case .demiGlace: return 2
        case .bourbonGlaze: return 2
        case .blueCheese: return 2
        case .bordelaise: return 1
        case .shrimpOscar: return 2
        case .auPoivre: return 1
        }
    }
}
```

### UserPreferences
```swift
struct UserPreferences: Codable {
    var tanninTolerance: Int        // 1-10
    var oakTolerance: Int           // 1-10
    var spiceTolerance: Int         // 1-10
    var funkTolerance: Int          // 1-10
    var budgetMax: Double
    var budgetMin: Double
}
```

### WineRecommendation
```swift
struct WineRecommendation: Identifiable {
    let id: UUID
    let wine: Wine
    let score: Double               // 0-100
    let explanation: String
    let isSwapSuggestion: Bool
    
    var scoreFormatted: String {
        String(format: "%.0f%% Match", score)
    }
}
```

### AppState
```swift
class WineMatcherViewModel: ObservableObject {
    @Published var wines: [Wine] = []
    @Published var steakOrder: SteakOrder = SteakOrder(cut: .ribeye, doneness: .mediumRare, addOns: [])
    @Published var preferences: UserPreferences = UserPreferences(
        tanninTolerance: 5,
        oakTolerance: 5,
        spiceTolerance: 5,
        funkTolerance: 5,
        budgetMax: 200,
        budgetMin: 0
    )
    @Published var recommendations: [WineRecommendation] = []
    @Published var swapSuggestion: WineRecommendation?
}
```

---

## Pseudocode Scoring Logic

### Core Algorithm

```swift
func calculateRecommendations(
    wines: [Wine],
    steak: SteakOrder,
    preferences: UserPreferences
) -> (top3: [WineRecommendation], swap: WineRecommendation?) {
    
    // 1. FILTER by budget
    let affordableWines = wines.filter { wine in
        wine.price >= preferences.budgetMin && 
        wine.price <= preferences.budgetMax
    }
    
    if affordableWines.isEmpty {
        return ([], nil)
    }
    
    // 2. CALCULATE base food profile from steak order
    let foodProfile = calculateFoodProfile(steak: steak)
    
    // 3. SCORE each wine
    var scoredWines: [(wine: Wine, score: Double, explanation: String)] = []
    
    for wine in affordableWines {
        let score = scoreWine(
            wine: wine,
            foodProfile: foodProfile,
            preferences: preferences
        )
        let explanation = generateExplanation(
            wine: wine,
            steak: steak,
            score: score
        )
        scoredWines.append((wine, score, explanation))
    }
    
    // 4. SORT by score descending
    scoredWines.sort { $0.score > $1.score }
    
    // 5. SELECT top 3
    let top3 = scoredWines.prefix(3).map { item in
        WineRecommendation(
            id: UUID(),
            wine: item.wine,
            score: item.score,
            explanation: item.explanation,
            isSwapSuggestion: false
        )
    }
    
    // 6. GENERATE swap suggestion (different style, still good match)
    let swap = generateSwapSuggestion(
        wines: scoredWines,
        topWines: Array(scoredWines.prefix(3)),
        steak: steak,
        preferences: preferences
    )
    
    return (Array(top3), swap)
}

// Calculate composite food characteristics
func calculateFoodProfile(steak: SteakOrder) -> FoodProfile {
    var profile = FoodProfile()
    
    // Base from cut
    profile.fattiness = steak.cut.fattiness
    profile.intensity = steak.cut.intensity
    
    // Adjust for doneness
    profile.charLevel = donenessToCharLevel(steak.doneness)
    profile.tanninNeed = Double(profile.intensity) * steak.doneness.tanninBoost
    
    // Accumulate add-on effects
    for addOn in steak.addOns {
        profile.spiceLevel += addOn.spiceAdjustment
        profile.funkLevel += addOn.funkAdjustment
        profile.richness += addOn.richnessAdjustment
    }
    
    return profile
}

// Core scoring function
func scoreWine(
    wine: Wine,
    foodProfile: FoodProfile,
    preferences: UserPreferences
) -> Double {
    
    var totalScore: Double = 0
    var maxScore: Double = 0
    
    // --- COMPONENT 1: Structural Match (40 points) ---
    // Tannin match
    let idealTannin = foodProfile.tanninNeed
    let tanninDiff = abs(Double(wine.tanninLevel) - idealTannin)
    let tanninScore = max(0, 10 - tanninDiff) * 2  // 0-20 points
    totalScore += tanninScore
    maxScore += 20
    
    // Body match (fattier cuts need fuller wines)
    let idealBody = Double(foodProfile.fattiness)
    let bodyDiff = abs(Double(wine.bodyLevel) - idealBody)
    let bodyScore = max(0, 10 - bodyDiff) * 2  // 0-20 points
    totalScore += bodyScore
    maxScore += 20
    
    // --- COMPONENT 2: Flavor Harmony (30 points) ---
    // Spice compatibility
    let spiceDiff = abs(wine.spiceLevel - foodProfile.spiceLevel)
    let spiceScore = max(0, 10 - Double(spiceDiff)) * 1.5  // 0-15 points
    totalScore += spiceScore
    maxScore += 15
    
    // Funk/earthiness compatibility
    let funkDiff = abs(wine.funkLevel - foodProfile.funkLevel)
    let funkScore = max(0, 10 - Double(funkDiff)) * 1.5  // 0-15 points
    totalScore += funkScore
    maxScore += 15
    
    // --- COMPONENT 3: User Preference Alignment (20 points) ---
    // Tannin tolerance
    let tanninTolScore = calculateToleranceScore(
        wineLevel: wine.tanninLevel,
        userTolerance: preferences.tanninTolerance
    ) * 5  // 0-5 points
    totalScore += tanninTolScore
    maxScore += 5
    
    // Oak tolerance
    let oakTolScore = calculateToleranceScore(
        wineLevel: wine.oakLevel,
        userTolerance: preferences.oakTolerance
    ) * 5  // 0-5 points
    totalScore += oakTolScore
    maxScore += 5
    
    // Spice tolerance
    let spiceTolScore = calculateToleranceScore(
        wineLevel: wine.spiceLevel,
        userTolerance: preferences.spiceTolerance
    ) * 5  // 0-5 points
    totalScore += spiceTolScore
    maxScore += 5
    
    // Funk tolerance
    let funkTolScore = calculateToleranceScore(
        wineLevel: wine.funkLevel,
        userTolerance: preferences.funkTolerance
    ) * 5  // 0-5 points
    totalScore += funkTolScore
    maxScore += 5
    
    // --- COMPONENT 4: Value Bonus (10 points) ---
    // Reward wines at lower end of budget (better value)
    let budgetRange = preferences.budgetMax - preferences.budgetMin
    if budgetRange > 0 {
        let priceRatio = (preferences.budgetMax - wine.price) / budgetRange
        let valueBonus = priceRatio * 10  // 0-10 points
        totalScore += valueBonus
        maxScore += 10
    } else {
        maxScore += 10
    }
    
    // Normalize to 0-100
    let finalScore = (totalScore / maxScore) * 100
    return min(100, max(0, finalScore))
}

// Helper: Calculate how well wine level matches user tolerance
func calculateToleranceScore(wineLevel: Int, userTolerance: Int) -> Double {
    // If user tolerance is high, any wine level is OK
    // If user tolerance is low, wine level must also be low
    if wineLevel <= userTolerance {
        return 1.0  // Perfect match
    } else {
        // Penalty for exceeding tolerance
        let excess = Double(wineLevel - userTolerance)
        return max(0, 1.0 - (excess / 10.0))
    }
}

// Generate swap suggestion (different style but still compatible)
func generateSwapSuggestion(
    wines: [(wine: Wine, score: Double, explanation: String)],
    topWines: [(wine: Wine, score: Double, explanation: String)],
    steak: SteakOrder,
    preferences: UserPreferences
) -> WineRecommendation? {
    
    // Find the most common grape in top 3
    let topGrapes = Set(topWines.map { $0.wine.grape })
    
    // Look for a well-scoring wine with different grape/style
    for candidate in wines where candidate.score >= 65 {
        if !topGrapes.contains(candidate.wine.grape) {
            let swapExplanation = "If you want to mix it up, try this \(candidate.wine.grape) – " +
                                  "it's a different style but still pairs beautifully with your \(steak.cut.rawValue)."
            return WineRecommendation(
                id: UUID(),
                wine: candidate.wine,
                score: candidate.score,
                explanation: swapExplanation,
                isSwapSuggestion: true
            )
        }
    }
    
    return nil
}

// Generate friendly explanation
func generateExplanation(wine: Wine, steak: SteakOrder, score: Double) -> String {
    var parts: [String] = []
    
    // Opening
    if score >= 85 {
        parts.append("This is a fantastic match!")
    } else if score >= 70 {
        parts.append("This pairs really well!")
    } else {
        parts.append("This is a solid choice.")
    }
    
    // Reason 1: Tannin
    if wine.tanninLevel >= 7 {
        parts.append("The grippy tannins complement the richness of your \(steak.cut.rawValue).")
    } else if wine.tanninLevel <= 4 {
        parts.append("Soft tannins won't overpower your steak.")
    }
    
    // Reason 2: Add-ons
    if steak.addOns.contains(.auPoivre) && wine.spiceLevel >= 6 {
        parts.append("The peppery notes echo your au poivre sauce beautifully.")
    }
    if steak.addOns.contains(.blueCheese) && wine.funkLevel >= 5 {
        parts.append("Its earthy character plays nicely with the blue cheese.")
    }
    if steak.addOns.contains(.shrimpOscar) {
        parts.append("Fresh enough to handle the shrimp oscar topping.")
    }
    
    // Reason 3: Region/Style
    parts.append("This \(wine.region) \(wine.grape) brings \(getStyleDescriptor(wine: wine)).")
    
    return parts.prefix(3).joined(separator: " ")
}

func getStyleDescriptor(wine: Wine) -> String {
    if wine.bodyLevel >= 8 && wine.tanninLevel >= 7 {
        return "bold, powerful flavors"
    } else if wine.oakLevel >= 7 {
        return "rich, toasty oak notes"
    } else if wine.acidityLevel >= 7 {
        return "bright freshness"
    } else if wine.funkLevel >= 6 {
        return "earthy, complex character"
    } else {
        return "smooth, approachable fruit"
    }
}

// Supporting struct
struct FoodProfile {
    var fattiness: Int = 5
    var intensity: Int = 5
    var charLevel: Int = 5
    var tanninNeed: Double = 5.0
    var spiceLevel: Int = 0
    var funkLevel: Int = 0
    var richness: Int = 5
}

func donenessToCharLevel(_ doneness: Doneness) -> Int {
    switch doneness {
    case .rare: return 2
    case .mediumRare: return 4
    case .medium: return 6
    case .mediumWell: return 8
    case .wellDone: return 10
    }
}
```

---

## User Experience Notes

### Friendly, Non-Snobby Language
- **Avoid**: "This wine exhibits tertiary aromas with significant brett character"
- **Use**: "This wine has earthy, funky notes that play really well with blue cheese"

- **Avoid**: "The wine's phenolic structure creates astringency that cuts adipose tissue"
- **Use**: "The tannins help balance the richness of your steak"

- **Avoid**: "An elegant expression with moderate oak influence"
- **Use**: "Smooth and balanced with a hint of toasty oak"

### Tolerance Slider Labels
- **Tannin**: "Light & Smooth" ← → "Bold & Grippy"
- **Oak**: "Fresh & Crisp" ← → "Rich & Oaky"
- **Spice**: "Soft & Mellow" ← → "Peppery & Spicy"
- **Funk**: "Clean & Fruity" ← → "Earthy & Funky"

### Error States
- **No wines in budget**: "Hmm, no wines match your budget. Want to adjust your price range?"
- **No wines loaded**: "Let's start by adding some wines from the menu!"
- **Poor matches**: Still show best available with "These might work, but they're not perfect matches. Want to adjust your preferences?"

---

## Future Enhancements
- Menu scanning via camera
- Save favorite pairings
- Share recommendations
- Support for other proteins (fish, lamb, chicken)
- Wine education mode
- Restaurant integration
