# Image Generation Workflow Documentation

## Overview

This document describes the image generation workflow for the Storybook iOS app, including avatar/character generation and scene illustration using DALL-E 3.

## Table of Contents

1. [API Endpoints](#api-endpoints)
2. [Prompt Templates](#prompt-templates)
3. [Cost Estimation](#cost-estimation)
4. [Weekly Automation Plan](#weekly-automation-plan)
5. [Implementation Details](#implementation-details)

---

## API Endpoints

### DALL-E 3 Image Generation

**Endpoint:** `POST https://api.openai.com/v1/images/generations`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {OPENAI_API_KEY}
```

**Request Body:**
```json
{
  "model": "dall-e-3",
  "prompt": "Your detailed prompt here...",
  "n": 1,
  "size": "1024x1024",
  "quality": "standard",
  "response_format": "b64_json"
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | string | Yes | Must be `"dall-e-3"` |
| `prompt` | string | Yes | Max 4000 characters |
| `n` | integer | Yes | Number of images (1 for DALL-E 3) |
| `size` | string | Yes | `"1024x1024"`, `"1024x1792"`, or `"1792x1024"` |
| `quality` | string | No | `"standard"` or `"hd"` (2x cost) |
| `response_format` | string | No | `"url"` or `"b64_json"` |
| `style` | string | No | `"vivid"` or `"natural"` |

**Response:**
```json
{
  "created": 1704067200,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANS...",
      "revised_prompt": "Enhanced prompt used by DALL-E..."
    }
  ]
}
```

### Error Handling

**Status Codes:**

| Code | Meaning | Action |
|------|---------|--------|
| 400 | Bad Request | Check prompt for policy violations |
| 401 | Unauthorized | Verify API key |
| 429 | Rate Limited | Implement exponential backoff |
| 500 | Server Error | Retry with backoff |
| 503 | Service Unavailable | Retry with backoff |

---

## Prompt Templates

### 1. Character/Avatar Generation

**Base Template:**
```
Create a children's storybook character portrait of {name}, a {gender} child 
with {hair_color}, {skin_tone}, and {eye_color}. {style_description}. 
{clothing_description}. 
The character should be friendly, age 4-8, with a warm smile. 
Style: children's book illustration, soft colors, gentle lighting, 
suitable for ages 3-8, wholesome and safe.
```

**Style Descriptions:**

| Style | Description |
|-------|-------------|
| `animalRabbit` | "Cute anthropomorphic rabbit character with soft fur and long ears" |
| `animalBear` | "Cute anthropomorphic bear character with fluffy fur and round ears" |
| `animalFox` | "Cute anthropomorphic fox character with bushy tail and pointy ears" |
| `cartoon` | "Cartoon style with big expressive eyes and rounded features" |
| `realistic` | "Semi-realistic illustration style with detailed features" |

**Example Prompt:**
```
Create a children's storybook character portrait of Emma, a female child 
with blonde hair, light skin tone, and blue eyes. Cartoon style with big 
expressive eyes and rounded features. Wearing comfortable blue children's 
clothing. The character should be friendly, age 4-8, with a warm smile. 
Style: children's book illustration, soft colors, gentle lighting, 
suitable for ages 3-8, wholesome and safe.
```

### 2. Character Sheet Generation

**Template:**
```
{base_character_prompt} View: {view_angle}. Character reference sheet 
style, multiple angles, consistent character design.
```

**View Angles:**
- `"front view, full body"`
- `"side profile view, full body"`
- `"three-quarter view, full body"`
- `"back view, full body"`

### 3. Scene Image Generation

**Template:**
```
Children's book illustration scene: {scene_description}. 
Character: {character_description}. 
Scene mood: {mood}. 
Style: soft watercolor-like digital art, warm lighting, storybook aesthetic, 
safe for children ages 3-8, no scary elements.
```

**Mood Keywords:**
- `calm` → "peaceful, serene, gentle"
- `happy` → "joyful, bright, cheerful"
- `adventure` → "exciting, dynamic, exploratory"
- `mysterious` → "intriguing, magical, wonder"
- `sleepy` → "soft, dreamy, restful"

**Example:**
```
Children's book illustration scene: A child discovers a magical glowing 
flower in an enchanted forest clearing. Character: A 6-year-old girl with 
blonde hair in a blue dress, curious expression. Scene mood: wonder and 
discovery. Style: soft watercolor-like digital art, warm lighting, 
storybook aesthetic, safe for children ages 3-8, no scary elements.
```

### 4. Character Consistency Prompts

To maintain character consistency across scenes:

```
Using the same character from previous images: {character_description}. 
{scene_description}. Maintain consistent appearance, clothing, and 
art style throughout.
```

---

## Cost Estimation

### DALL-E 3 Pricing (as of 2024)

| Quality | Size | Price per Image |
|---------|------|-----------------|
| Standard | 1024x1024 | $0.04 |
| Standard | 1024x1792 | $0.08 |
| Standard | 1792x1024 | $0.08 |
| HD | 1024x1024 | $0.08 |
| HD | 1024x1792 | $0.12 |
| HD | 1792x1024 | $0.12 |

### Usage Estimates

**Per Story Generation:**

| Component | Images | Cost (Standard) |
|-----------|--------|-----------------|
| Character Avatar | 1 | $0.04 |
| Character Sheet (optional) | 2-3 | $0.08 - $0.12 |
| Scene Illustrations (6 scenes) | 6 | $0.24 |
| **Total per story** | **7-10** | **$0.28 - $0.40** |

**Monthly Estimates (assuming 10 stories/month):**

| Plan | Stories | Images | Monthly Cost |
|------|---------|--------|--------------|
| Basic | 10 | 70-100 | $2.80 - $4.00 |
| Standard | 30 | 210-300 | $8.40 - $12.00 |
| Premium | 100 | 700-1000 | $28.00 - $40.00 |

### Cost Optimization Strategies

1. **Use Mock Service for Development**
   - Always use `MockAvatarService` during development and testing
   - Switch to DALL-E only for production builds

2. **Cache Generated Images**
   - Store all generated images locally
   - Reuse character sheets for multiple stories

3. **Batch Scene Generation**
   - Generate scenes only when needed
   - Pre-generate during off-peak hours

4. **Quality Selection**
   - Use `standard` quality for most images
   - Reserve `hd` quality for featured/premium content

5. **Size Optimization**
   - Use `1024x1024` for avatars and character sheets
   - Use `1024x1792` for full-page illustrations

---

## Weekly Automation Plan

### Overview

Automate image generation tasks to optimize costs and user experience.

### Schedule

#### Monday: Weekly Character Generation
```swift
// Generate character sheets for new profiles
func weeklyCharacterGeneration() async {
    let newProfiles = await fetchProfilesWithoutAvatars()
    for profile in newProfiles {
        await generateCharacterSheet(for: profile)
    }
}
```

**Time:** 2:00 AM (low traffic)
**Estimated Cost:** $0.08 per new profile

#### Tuesday-Thursday: Scene Pre-generation
```swift
// Pre-generate scenes for upcoming stories
func pregenerateScenes() async {
    let upcomingStories = await fetchUpcomingStories()
    for story in upcomingStories {
        await generateSceneImages(for: story)
    }
}
```

**Time:** 3:00 AM
**Estimated Cost:** $0.24 per story

#### Friday: Image Cleanup
```swift
// Remove unused/generated images older than 30 days
func cleanupOldImages() async {
    let oldImages = await fetchImages(olderThan: 30.days)
    await deleteImages(oldImages)
}
```

**Time:** 1:00 AM
**Estimated Cost:** $0 (cleanup only)

#### Saturday-Sunday: Low Activity
- Monitor usage
- Handle user-triggered generations

### Automation Implementation

```swift
import BackgroundTasks

class ImageGenerationScheduler {
    static let shared = ImageGenerationScheduler()
    
    func scheduleWeeklyTasks() {
        // Schedule character generation
        let characterTask = BGProcessingTaskRequest(identifier: "com.storybook.weeklyCharacters")
        characterTask.earliestBeginDate = Date().nextMonday.at2AM
        characterTask.requiresNetworkConnectivity = true
        
        // Schedule scene pre-generation
        let sceneTask = BGProcessingTaskRequest(identifier: "com.storybook.pregenerateScenes")
        sceneTask.earliestBeginDate = Date().nextTuesday.at3AM
        sceneTask.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(characterTask)
            try BGTaskScheduler.shared.submit(sceneTask)
        } catch {
            print("Failed to schedule tasks: \(error)")
        }
    }
}
```

### Cost Monitoring

```swift
struct CostTracker {
    private var dailyCosts: [Date: Double] = [:]
    private var monthlyBudget: Double = 50.0 // $50/month
    
    mutating func trackGeneration(cost: Double) {
        let today = Date().startOfDay
        dailyCosts[today, default: 0] += cost
        
        // Alert if approaching budget
        let monthlySpend = dailyCosts.values.reduce(0, +)
        if monthlySpend > monthlyBudget * 0.8 {
            notifyBudgetWarning(remaining: monthlyBudget - monthlySpend)
        }
    }
    
    func canGenerate() -> Bool {
        let monthlySpend = dailyCosts.values.reduce(0, +)
        return monthlySpend < monthlyBudget
    }
}
```

---

## Implementation Details

### Service Architecture

```
AvatarGenerationService (Protocol)
    ├── MockAvatarService (Development/Testing)
    └── DALLEAvatarService (Production)
```

### Data Flow

```
1. User creates profile
   ↓
2. Select avatar configuration (style, colors)
   ↓
3. AvatarGenerationService.generateAvatar()
   ↓
4. Store imageData in ChildProfile.avatarImageData
   ↓
5. Generate character sheet (optional)
   ↓
6. Use character reference for scene generation
```

### Error Handling Strategy

```swift
enum AvatarGenerationError {
    case rateLimited          // Retry after delay
    case contentPolicyViolation // Show user-friendly message
    case insufficientCredits   // Prompt to upgrade
    case networkError          // Auto-retry with backoff
}
```

### Security Considerations

1. **API Key Storage**
   - Store in Keychain, not UserDefaults
   - Use environment variables for CI/CD
   - Rotate keys quarterly

2. **Content Safety**
   - All prompts include "safe for children ages 3-8"
   - Filter user input before adding to prompts
   - Review generated images before displaying

3. **Rate Limiting**
   - Max 5 generations per minute per user
   - Queue requests if limit exceeded
   - Show progress indicator for queued items

### Testing Strategy

```swift
// Unit Tests
func testMockAvatarGeneration() async throws {
    let service = MockAvatarService()
    let config = AvatarConfiguration.default
    let result = try await service.generateAvatar(
        for: config,
        name: "Test",
        gender: .neutral
    )
    XCTAssertNotNil(result.imageData)
}

// Integration Tests (with real API)
func testDALLEAvatarGeneration() async throws {
    guard let service = DALLEAvatarService() else {
        throw XCTSkip("No API key available")
    }
    // Test with real API (use sparingly due to cost)
}
```

---

## Appendix

### A. SwiftData Schema Migration

When adding avatar fields to existing ChildProfile:

```swift
// Migration is automatic for optional fields
// For required fields, use schema versioning:

@Model
final class ChildProfileV2 {
    // ... existing fields ...
    
    // New fields (optional by default)
    var avatarStyleRaw: String?
    var avatarImageData: Data?
    // ...
}
```

### B. API Response Caching

```swift
actor ImageCache {
    private var cache: [String: Data] = [:]
    
    func get(for key: String) -> Data? {
        cache[key]
    }
    
    func set(_ data: Data, for key: String) {
        cache[key] = data
    }
}
```

### C. Prompt Versioning

Track prompt versions for reproducibility:

```swift
struct PromptVersion {
    let version: String // "1.0.0"
    let template: String
    let date: Date
}
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-03-14 | Initial documentation |

## References

- [OpenAI DALL-E API Documentation](https://platform.openai.com/docs/guides/images)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Background Tasks Framework](https://developer.apple.com/documentation/backgroundtasks)