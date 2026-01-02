//
//  WineMatcherViewModel.swift
//  PairPerfect
//
//  ViewModel and scoring logic
//

import Foundation
import SwiftUI
import Combine

class WineMatcherViewModel: ObservableObject {
    @Published var wines: [Wine] = []
    @Published var steakOrder: SteakOrder = SteakOrder()
    @Published var preferences: UserPreferences = UserPreferences()
    @Published var recommendations: [WineRecommendation] = []
    @Published var swapSuggestion: WineRecommendation?
    
    init() {
        loadSampleWines()
    }
    
    // MARK: - Main Recommendation Engine
    func calculateRecommendations() {
        // Filter by budget
        let affordableWines = wines.filter { wine in
            wine.price >= preferences.budgetMin && wine.price <= preferences.budgetMax
        }
        
        guard !affordableWines.isEmpty else {
            recommendations = []
            swapSuggestion = nil
            return
        }
        
        // Calculate food profile
        let foodProfile = calculateFoodProfile(steak: steakOrder)
        
        // Score each wine
        var scoredWines: [(wine: Wine, score: Double, explanation: String)] = []
        
        for wine in affordableWines {
            let score = scoreWine(wine: wine, foodProfile: foodProfile, preferences: preferences)
            let explanation = generateExplanation(wine: wine, steak: steakOrder, score: score)
            scoredWines.append((wine, score, explanation))
        }
        
        // Sort by score
        scoredWines.sort { $0.score > $1.score }
        
        // Get top 3
        recommendations = scoredWines.prefix(3).map { item in
            WineRecommendation(
                id: UUID(),
                wine: item.wine,
                score: item.score,
                explanation: item.explanation,
                isSwapSuggestion: false
            )
        }
        
        // Generate swap suggestion
        swapSuggestion = generateSwapSuggestion(
            wines: scoredWines,
            topWines: Array(scoredWines.prefix(3))
        )
    }
    
    // MARK: - Food Profile Calculation
    private func calculateFoodProfile(steak: SteakOrder) -> FoodProfile {
        var profile = FoodProfile()
        
        profile.fattiness = steak.cut.fattiness
        profile.intensity = steak.cut.intensity
        profile.charLevel = donenessToCharLevel(steak.doneness)
        profile.tanninNeed = Double(profile.intensity) * steak.doneness.tanninBoost
        
        for addOn in steak.addOns {
            profile.spiceLevel += addOn.spiceAdjustment
            profile.funkLevel += addOn.funkAdjustment
            profile.richness += addOn.richnessAdjustment
        }
        
        return profile
    }
    
    // MARK: - Wine Scoring
    private func scoreWine(wine: Wine, foodProfile: FoodProfile, preferences: UserPreferences) -> Double {
        var totalScore: Double = 0
        var maxScore: Double = 0
        
        // Component 1: Structural Match (40 points)
        let idealTannin = foodProfile.tanninNeed
        let tanninDiff = abs(Double(wine.tanninLevel) - idealTannin)
        let tanninScore = max(0, 10 - tanninDiff) * 2
        totalScore += tanninScore
        maxScore += 20
        
        let idealBody = Double(foodProfile.fattiness)
        let bodyDiff = abs(Double(wine.bodyLevel) - idealBody)
        let bodyScore = max(0, 10 - bodyDiff) * 2
        totalScore += bodyScore
        maxScore += 20
        
        // Component 2: Flavor Harmony (30 points)
        let spiceDiff = abs(wine.spiceLevel - foodProfile.spiceLevel)
        let spiceScore = max(0, 10 - Double(spiceDiff)) * 1.5
        totalScore += spiceScore
        maxScore += 15
        
        let funkDiff = abs(wine.funkLevel - foodProfile.funkLevel)
        let funkScore = max(0, 10 - Double(funkDiff)) * 1.5
        totalScore += funkScore
        maxScore += 15
        
        // Component 3: User Preference Alignment (20 points)
        totalScore += calculateToleranceScore(wineLevel: wine.tanninLevel, userTolerance: preferences.tanninTolerance) * 5
        totalScore += calculateToleranceScore(wineLevel: wine.oakLevel, userTolerance: preferences.oakTolerance) * 5
        totalScore += calculateToleranceScore(wineLevel: wine.spiceLevel, userTolerance: preferences.spiceTolerance) * 5
        totalScore += calculateToleranceScore(wineLevel: wine.funkLevel, userTolerance: preferences.funkTolerance) * 5
        maxScore += 20
        
        // Component 4: Value Bonus (10 points)
        let budgetRange = preferences.budgetMax - preferences.budgetMin
        if budgetRange > 0 {
            let priceRatio = (preferences.budgetMax - wine.price) / budgetRange
            let valueBonus = priceRatio * 10
            totalScore += valueBonus
        }
        maxScore += 10
        
        let finalScore = (totalScore / maxScore) * 100
        return min(100, max(0, finalScore))
    }
    
    private func calculateToleranceScore(wineLevel: Int, userTolerance: Int) -> Double {
        if wineLevel <= userTolerance {
            return 1.0
        } else {
            let excess = Double(wineLevel - userTolerance)
            return max(0, 1.0 - (excess / 10.0))
        }
    }
    
    // MARK: - Explanation Generation
    private func generateExplanation(wine: Wine, steak: SteakOrder, score: Double) -> String {
        var parts: [String] = []
        
        if score >= 85 {
            parts.append("This is a fantastic match!")
        } else if score >= 70 {
            parts.append("This pairs really well!")
        } else {
            parts.append("This is a solid choice.")
        }
        
        if wine.tanninLevel >= 7 {
            parts.append("The grippy tannins complement the richness of your \(steak.cut.rawValue).")
        } else if wine.tanninLevel <= 4 {
            parts.append("Soft tannins won't overpower your steak.")
        }
        
        if steak.addOns.contains(.auPoivre) && wine.spiceLevel >= 6 {
            parts.append("The peppery notes echo your au poivre sauce beautifully.")
        }
        if steak.addOns.contains(.blueCheese) && wine.funkLevel >= 5 {
            parts.append("Its earthy character plays nicely with the blue cheese.")
        }
        if steak.addOns.contains(.shrimpOscar) {
            parts.append("Fresh enough to handle the shrimp oscar topping.")
        }
        
        parts.append("This \(wine.region) \(wine.grape) brings \(getStyleDescriptor(wine: wine)).")
        
        return parts.prefix(3).joined(separator: " ")
    }
    
    private func getStyleDescriptor(wine: Wine) -> String {
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
    
    // MARK: - Swap Suggestion
    private func generateSwapSuggestion(
        wines: [(wine: Wine, score: Double, explanation: String)],
        topWines: [(wine: Wine, score: Double, explanation: String)]
    ) -> WineRecommendation? {
        let topGrapes = Set(topWines.map { $0.wine.grape })
        
        for candidate in wines where candidate.score >= 65 {
            if !topGrapes.contains(candidate.wine.grape) {
                let swapExplanation = "If you want to mix it up, try this \(candidate.wine.grape) – " +
                    "it's a different style but still pairs beautifully with your \(steakOrder.cut.rawValue)."
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
    
    // MARK: - Helpers
    private func donenessToCharLevel(_ doneness: Doneness) -> Int {
        switch doneness {
        case .rare: return 2
        case .mediumRare: return 4
        case .medium: return 6
        case .mediumWell: return 8
        case .wellDone: return 10
        }
    }
    
    // MARK: - Reset Function
    func reset() {
        steakOrder = SteakOrder()
        preferences = UserPreferences()
        recommendations = []
        swapSuggestion = nil
    }
    
    // MARK: - Sample Data
    private func loadSampleWines() {
        wines = [
            Wine(name: "Stag's Leap Artemis", grape: "Cabernet Sauvignon", style: "Full-bodied red",
                 region: "Napa Valley, CA", price: 65, vintage: 2020, tanninLevel: 8, oakLevel: 7,
                 spiceLevel: 4, funkLevel: 2, bodyLevel: 9, acidityLevel: 6),
            
            Wine(name: "Duckhorn Merlot", grape: "Merlot", style: "Medium to full-bodied red",
                 region: "Napa Valley, CA", price: 55, vintage: 2021, tanninLevel: 6, oakLevel: 6,
                 spiceLevel: 3, funkLevel: 2, bodyLevel: 7, acidityLevel: 5),
            
            Wine(name: "Ridge Geyserville", grape: "Zinfandel Blend", style: "Bold red blend",
                 region: "Sonoma, CA", price: 48, vintage: 2021, tanninLevel: 7, oakLevel: 5,
                 spiceLevel: 8, funkLevel: 3, bodyLevel: 8, acidityLevel: 6),
            
            Wine(name: "Antica Terra Willamette", grape: "Pinot Noir", style: "Medium-bodied red",
                 region: "Willamette Valley, OR", price: 75, vintage: 2020, tanninLevel: 5, oakLevel: 4,
                 spiceLevel: 5, funkLevel: 6, bodyLevel: 6, acidityLevel: 7),
            
            Wine(name: "Caymus Cabernet", grape: "Cabernet Sauvignon", style: "Full-bodied red",
                 region: "Napa Valley, CA", price: 95, vintage: 2021, tanninLevel: 9, oakLevel: 8,
                 spiceLevel: 3, funkLevel: 1, bodyLevel: 10, acidityLevel: 5),
            
            Wine(name: "Beaucastel Châteauneuf", grape: "Grenache Blend", style: "Full-bodied red",
                 region: "Rhône, France", price: 85, vintage: 2019, tanninLevel: 7, oakLevel: 3,
                 spiceLevel: 7, funkLevel: 7, bodyLevel: 8, acidityLevel: 6)
        ]
    }
}
