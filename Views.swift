//
//  Views.swift
//  PairPerfect
//
//  SwiftUI Views for the wine pairing app
//

import SwiftUI

// MARK: - Main App Structure
@main
struct PairPerfectApp: App {
    @StateObject private var viewModel = WineMatcherViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                OnboardingView()
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - 1. Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var viewModel: WineMatcherViewModel
    @State private var showMainFlow = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "#4A148C"), Color(hex: "#7B1FA2"), Color(hex: "#9C27B0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image(systemName: "wineglass.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white)
                
                Text("PairPerfect")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Find the perfect wine for your steak")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 16) {
                    InfoRow(icon: "list.bullet", text: "Browse the wine menu")
                    InfoRow(icon: "fork.knife", text: "Tell us about your steak")
                    InfoRow(icon: "slider.horizontal.3", text: "Set your taste preferences")
                    InfoRow(icon: "star.fill", text: "Get personalized recommendations")
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    showMainFlow = true
                }) {
                    Text("Get Started")
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: "#4A148C"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showMainFlow) {
            SteakSelectionView()
                .environmentObject(viewModel)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 40)
            
            Text(text)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 2. Steak Selection View
struct SteakSelectionView: View {
    @EnvironmentObject var viewModel: WineMatcherViewModel
    @State private var navigateToPreferences = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF3E0").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What are you having?")
                                .font(.largeTitle.bold())
                            Text("Tell us about your steak")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Cut Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Steak Cut", systemImage: "fork.knife")
                                .font(.headline)
                            
                            Picker("Cut", selection: $viewModel.steakOrder.cut) {
                                ForEach(SteakCut.allCases, id: \.self) { cut in
                                    Text(cut.rawValue).tag(cut)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                        .padding(.horizontal)
                        
                        // Doneness Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Doneness", systemImage: "flame.fill")
                                .font(.headline)
                            
                            Picker("Doneness", selection: $viewModel.steakOrder.doneness) {
                                ForEach(Doneness.allCases, id: \.self) { doneness in
                                    Text(doneness.rawValue).tag(doneness)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                        .padding(.horizontal)
                        
                        // Add-ons
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Add-ons", systemImage: "plus.circle.fill")
                                .font(.headline)
                            
                            ForEach(AddOn.allCases, id: \.self) { addOn in
                                AddOnToggle(addOn: addOn, isSelected: viewModel.steakOrder.addOns.contains(addOn)) {
                                    if viewModel.steakOrder.addOns.contains(addOn) {
                                        viewModel.steakOrder.addOns.removeAll { $0 == addOn }
                                    } else {
                                        viewModel.steakOrder.addOns.append(addOn)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                        .padding(.horizontal)
                        
                        // Continue Button
                        Button(action: {
                            navigateToPreferences = true
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#7B1FA2"))
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToPreferences) {
                TastePreferencesView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct AddOnToggle: View {
    let addOn: AddOn
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color(hex: "#7B1FA2") : .gray)
                Text(addOn.rawValue)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 3. Taste Preferences View
struct TastePreferencesView: View {
    @EnvironmentObject var viewModel: WineMatcherViewModel
    @State private var navigateToResults = false
    
    var body: some View {
        ZStack {
            Color(hex: "#E8F5E9").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Taste Profile")
                            .font(.largeTitle.bold())
                        Text("Adjust to match your preferences")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Budget
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Budget", systemImage: "dollarsign.circle.fill")
                            .font(.headline)
                        
                        HStack {
                            Text("$\(Int(viewModel.preferences.budgetMin))")
                            Slider(value: $viewModel.preferences.budgetMax, in: 20...300, step: 10)
                            Text("$\(Int(viewModel.preferences.budgetMax))")
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8)
                    .padding(.horizontal)
                    
                    // Tolerance Sliders
                    ToleranceSlider(
                        title: "Tannin Tolerance",
                        icon: "circle.hexagongrid.fill",
                        lowLabel: "Light & Smooth",
                        highLabel: "Bold & Grippy",
                        value: $viewModel.preferences.tanninTolerance
                    )
                    
                    ToleranceSlider(
                        title: "Oak Tolerance",
                        icon: "tree.fill",
                        lowLabel: "Fresh & Crisp",
                        highLabel: "Rich & Oaky",
                        value: $viewModel.preferences.oakTolerance
                    )
                    
                    ToleranceSlider(
                        title: "Spice Tolerance",
                        icon: "flame.fill",
                        lowLabel: "Soft & Mellow",
                        highLabel: "Peppery & Spicy",
                        value: $viewModel.preferences.spiceTolerance
                    )
                    
                    ToleranceSlider(
                        title: "Funk Tolerance",
                        icon: "leaf.fill",
                        lowLabel: "Clean & Fruity",
                        highLabel: "Earthy & Funky",
                        value: $viewModel.preferences.funkTolerance
                    )
                    
                    // Find Wines Button
                    Button(action: {
                        viewModel.calculateRecommendations()
                        navigateToResults = true
                    }) {
                        Text("Find My Wines")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#388E3C"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsView()
                .environmentObject(viewModel)
        }
    }
}

struct ToleranceSlider: View {
    let title: String
    let icon: String
    let lowLabel: String
    let highLabel: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: 1...10, step: 1)
                
                HStack {
                    Text(lowLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(highLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8)
        .padding(.horizontal)
    }
}

// MARK: - 4. Results View
struct ResultsView: View {
    @EnvironmentObject var viewModel: WineMatcherViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Your Perfect Pairings")
                            .font(.largeTitle.bold())
                        Text("Top 3 recommendations")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    // Top 3 Recommendations
                    ForEach(Array(viewModel.recommendations.enumerated()), id: \.element.id) { index, rec in
                        WineRecommendationCard(recommendation: rec, rank: index + 1)
                    }
                    
                    // Swap Suggestion
                    if let swap = viewModel.swapSuggestion {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Want to try something different?")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            WineRecommendationCard(recommendation: swap, rank: nil)
                        }
                        .padding(.top)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button("Adjust Preferences") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Start Over") {
                            viewModel.reset()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
        }
    }
}

struct WineRecommendationCard: View {
    let recommendation: WineRecommendation
    let rank: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let rank = rank {
                    Text("#\(rank)")
                        .font(.title.bold())
                        .foregroundStyle(Color(hex: "#7B1FA2"))
                } else {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "#FF6F00"))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(recommendation.starRating) ? "star.fill" : "star")
                            .foregroundStyle(Color(hex: "#FFB300"))
                    }
                }
            }
            
            Text(recommendation.wine.name)
                .font(.title2.bold())
            
            HStack {
                Text(recommendation.wine.grape)
                Text("•")
                Text(recommendation.wine.region)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Text("$\(Int(recommendation.wine.price))")
                .font(.headline)
                .foregroundStyle(Color(hex: "#388E3C"))
            
            Divider()
            
            Text(recommendation.explanation)
                .font(.body)
                .foregroundStyle(.primary)
            
            Text(recommendation.scoreFormatted)
                .font(.caption.bold())
                .foregroundStyle(Color(hex: "#7B1FA2"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#7B1FA2").opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
