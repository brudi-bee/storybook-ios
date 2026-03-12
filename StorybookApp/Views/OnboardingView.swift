import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var child1Name = ""
    @State private var child1Gender: ChildGender = .female
    
    let pages = [
        OnboardingPage(
            icon: "book.fill",
            title: "Willkommen bei Storybook",
            description: "Persönliche Gute-Nacht-Geschichten für deine Kleinen. Mit ihren Namen, ihrem Geschlecht, und magischen Abenteuern."
        ),
        OnboardingPage(
            icon: "person.2.fill",
            title: "Kinderprofile anlegen",
            description: "Lege bis zu zwei Kinderprofile an. Die Geschichten werden persönlich für sie erzählt."
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "Magie erleben",
            description: "Wähle Genre, Setting und Moral. Die KI schreibt einzigartige Geschichten – immer neu, immer persönlich."
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.15, blue: 0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 400)
                
                // Child Profile Setup (last page)
                if currentPage == pages.count - 1 {
                    VStack(spacing: 16) {
                        Text("Erstes Kind einrichten")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Name", text: $child1Name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                        
                        Picker("Geschlecht", selection: $child1Gender) {
                            ForEach(ChildGender.allCases) { gender in
                                Text(gender.displayName).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 40)
                        .colorMultiply(.white)
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Bottom Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(currentPage == pages.count - 1 ? "Los geht's" : "Weiter")
                            .font(.headline)
                        Image(systemName: currentPage == pages.count - 1 ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(.linearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(page.title)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
