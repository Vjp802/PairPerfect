//
//  Models.swift
//  PairPerfect
//
//  Data models for the wine pairing app
//

import Foundation

// MARK: - Wine Model
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
    
    init(id: UUID = UUID(), name: String, grape: String, style: String, region: String,
         price: Double, vintage: Int? = nil, tanninLevel: Int, oakLevel: Int,
         spiceLevel: Int, funkLevel: Int, bodyLevel: Int, acidityLevel: Int) {
        self.id = id
        self.name = name
        self.grape = grape
        self.style = style
        self.region = region
        self.price = price
        self.vintage = vintage
        self.tanninLevel = tanninLevel
        self.oakLevel = oakLevel
        self.spiceLevel = spiceLevel
        self.funkLevel = funkLevel
        self.bodyLevel = bodyLevel
        self.acidityLevel = acidityLevel
    }
}

// MARK: - Steak Models
enum SteakCut: String, CaseIterable, Codable {
    case ribeye = "Ribeye"
    case filetMignon = "Filet Mignon"
    case nyStrip = "NY Strip"
    case porterhouse = "Porterhouse"
    case tBone = "T-Bone"
    case sirloin = "Sirloin"
    case flatIron = "Flat Iron"
    case skirt = "Skirt Steak"
    
    var fattiness: Int {
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
    
    var intensity: Int {
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
    
    var tanninBoost: Double {
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
        case .auPoivre: return 3
        case .bordelaise: return 1
        case .blueCheese: return 0
        case .demiGlace: return 0
        case .bourbonGlaze: return 1
        case .shrimpOscar: return 0
        }
    }
    
    var funkAdjustment: Int {
        switch self {
        case .blueCheese: return 4
        case .bordelaise: return 2
        case .auPoivre: return 1
        case .demiGlace: return 1
        case .bourbonGlaze: return 0
        case .shrimpOscar: return -2
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

struct SteakOrder: Codable {
    var cut: SteakCut
    var doneness: Doneness
    var addOns: [AddOn]
    
    init(cut: SteakCut = .ribeye, doneness: Doneness = .mediumRare, addOns: [AddOn] = []) {
        self.cut = cut
        self.doneness = doneness
        self.addOns = addOns
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var tanninTolerance: Int        // 1-10
    var oakTolerance: Int           // 1-10
    var spiceTolerance: Int         // 1-10
    var funkTolerance: Int          // 1-10
    var budgetMax: Double
    var budgetMin: Double
    
    init(tanninTolerance: Int = 5, oakTolerance: Int = 5, spiceTolerance: Int = 5,
         funkTolerance: Int = 5, budgetMax: Double = 200, budgetMin: Double = 0) {
        self.tanninTolerance = tanninTolerance
        self.oakTolerance = oakTolerance
        self.spiceTolerance = spiceTolerance
        self.funkTolerance = funkTolerance
        self.budgetMax = budgetMax
        self.budgetMin = budgetMin
    }
}

// MARK: - Recommendation
struct WineRecommendation: Identifiable {
    let id: UUID
    let wine: Wine
    let score: Double               // 0-100
    let explanation: String
    let isSwapSuggestion: Bool
    
    var scoreFormatted: String {
        String(format: "%.0f%% Match", score)
    }
    
    var starRating: Double {
        score / 20.0  // Convert 0-100 to 0-5 stars
    }
}

// MARK: - Food Profile (Internal)
struct FoodProfile {
    var fattiness: Int = 5
    var intensity: Int = 5
    var charLevel: Int = 5
    var tanninNeed: Double = 5.0
    var spiceLevel: Int = 0
    var funkLevel: Int = 0
    var richness: Int = 5
}
