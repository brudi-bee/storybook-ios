import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.12, green: 0.14, blue: 0.28)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HeaderView(count: store.stories.count)
                        
                        if store.stories.isEmpty {
                            EmptyLibraryView()
                        } else {
                            BooksGridView(
                                stories: store.stories,
                                onSelect: { story in
                                    selectedStory = story
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedStory) { story in
                ReaderView(story: convertToDTO(story))
            }
        }
    }
    
    private func convertToDTO(_ story: Story) -> StoryDTO {
        StoryDTO(
            id: story.id,
            title: story.title,
            language: story.language,
            genre: story.genre,
            setting: story.setting,
            moral: story.moral,
            children: [],
            scenes: story.scenes,
            createdAt: story.createdAt
        )
    }
}

// MARK: - Header
struct HeaderView: View {
    let count: Int
    
    var body: some View {
        HStack {
            Text("Meine Bibliothek")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count) Geschichten")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 24)
    }
}

// MARK: - Empty State
struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Noch keine Geschichten")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Erstelle ein Kinderprofil und öffne eine Geschichte.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

// MARK: - Books Grid
struct BooksGridView: View {
    let stories: [Story]
    let onSelect: (Story) -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(stories) { story in
                BookCoverView(story: story, onTap: {
                    onSelect(story)
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - Book Cover
struct BookCoverView: View {
    let story: Story
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            BookCoverContent(story: story, isPressed: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressAction {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Book Cover Content
struct BookCoverContent: View {
    let story: Story
    let isPressed: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(gradient)
                    .frame(height: 200)
                
                VStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                    Spacer()
                }
                
                VStack(spacing: 4) {
                    Text(story.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .shadow(radius: 2)
                    
                    Text(story.genre.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .black.opacity(0.3), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
                .frame(height: 4)
                .padding(.top, 2)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(isPressed ? 0.5 : 0.3),
            radius: isPressed ? 16 : 10,
            x: 0,
            y: isPressed ? 12 : 6
        )
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
    }
    
    private var gradient: LinearGradient {
        switch story.genre {
        case .adventure:
            return LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .friendship:
            return LinearGradient(colors: [.green, .teal.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .fantasy:
            return LinearGradient(colors: [.purple, .pink.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .animals:
            return LinearGradient(colors: [.brown, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .bedtime:
            return LinearGradient(colors: [.blue, .indigo.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var icon: String {
        switch story.genre {
        case .adventure: return "map.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
}

// MARK: - Press Action Modifier
struct PressActionModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActionModifier(onPress: onPress, onRelease: onRelease))
    }
}

#Preview {
    LibraryView()
        .environmentObject(SDAppStore())
}