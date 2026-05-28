# CLAUDE CODE — PALLY (小伴) MASTER IMPLEMENTATION PROMPT
## Full-stack: Flutter mobile app + Java Spring Boot backend + PostgreSQL
## Read this entire file before writing a single line of code.

---

# PART 00 — MANDATORY WORKFLOW (run every time, no exceptions)

After **every** code change, before marking a task complete:
1. Run `dart analyze lib/` — must show zero errors and zero warnings.
2. Run `flutter build apk --debug` — must complete without errors.
3. If either fails: fix all issues, then re-run both commands until clean.
4. Only report the task as done after both commands pass.

---

# PART 0 — WHO YOU ARE & WHAT YOU'RE BUILDING

You are an expert Flutter + Java engineer implementing Pally (小伴), a kids AI tutor app for ages 6–14. Children create multiple AI tutor avatar characters, each with its own subject-specific knowledge base built from uploaded photos and PDFs. They chat with each avatar to get homework help.

**Figma file:** `https://www.figma.com/design/1hRxGTRdLmTCOyca8vpmdV/tutorly`
**Page:** `Pally · 小伴 — Flutter UI v2`

Before implementing ANY screen, open Figma and inspect the exact frame. Extract all spacing, colours, border radii, and typography values from Figma. Never guess values.

**Mandatory reading before any code:**
- `flutter_coding_practices.md` — Dart rules, widget rules, state management rules
- `flutter_architecture.md` — MVVM, Feature-First structure, shared components

---

# PART 1 — FIGMA SCREEN INVENTORY & FLOW

## Row 1 — Core User Journey (implement first)

```
① Home Screen (01 — Home)
   Entry point. Avatar grid 2-col. Tap avatar → Chat. "+ New" → Character Picker.
   Bottom nav: Home (active), Library, Chat, Me.

② Character Picker (02 — Avatar Showcase)
   12 blind-box characters in 3×4 grid. Tap to select. Name field. Subject chips.
   "Choose [Name]!" CTA → saves avatar, navigates to Add Knowledge.

③ Add Knowledge (02 — Add Knowledge Improved)
   Avatar speech bubble. Amber tip banner: "Only add [Subject] content!".
   3 upload tiles: Camera, PDF, Paste. Wiki brain preview chips at bottom.
   Relevance check fires before any upload completes → may show Screen ⑦.

④ Wiki Compiled (03 — Wiki Compiled 🎉)
   Post-upload success. Confetti. List of new wiki pages learned.
   3 CTAs: Ask tutor now / Quick quiz / View brain.

⑤ Tutor Brain — Wiki Viewer (05 — Zap's Brain 🧠)
   Stats row: pages, topics, sources, links.
   Search bar. Topic list with mastery bars. Recent pages with certainty badges.
   Conflict warning badge on pages with contradictions.
   Accessible from Library nav tab.

⑥ Chat Screen (03 — Chat with Photo Q)
   Avatar in AppBar. Date chip. Message bubbles (user purple, tutor light-purple).
   Tutor messages cite source .md file (small badge).
   Quick reply chips. Photo button (📷) + Gallery button above input.
   Typing indicator (3 animated dots).
   Photo sends → F7 result inline in chat.

⑦ Relevance Warning Dialog (04 — Relevance Check)
   Modal over dimmed background.
   ⚠️ icon circle. Filename chip. Explanation. "Go Back" + "Add Anyway" buttons.
   Triggered automatically when relevance score < 0.45.
```

## Row 2 — Feature Screens (implement after core loop)

```
F1 — Daily Quiz + Spaced Repetition (F1 — Daily Quiz + Spaced Rep)
   Streak + XP header. Question card (MCQ). Green correct / red wrong feedback.
   Source citation on each question. +XP earned display. Next question button.
   Due-today counter at bottom. Accessible via Library tab → "Quiz" button.

F2 — Flashcard Deck (F2 — Auto Flashcard Deck)
   Filter chips: All / Due / Weak / Done. Flashcard flip card (front/back).
   Self-rate: Hard / Okay / Easy → feeds SM-2 algorithm.
   "Up Next" queue. "Auto-generate more" button.
   Accessible from Library tab → "Flashcards" button.

F3 — Progress Dashboard (F3 — Progress Dashboard)
   Level circle + XP bar. Week/Month/All Time tabs.
   Bar chart: minutes per day. Needs Work list with mastery bars.
   "Practice Weak Topics" CTA. Badges row.
   This IS the "Me" tab screen.

F4 — Blind Box Shop (F4 — Blind Box Unlock ✨)
   Star balance. Mystery box visual. "Open Box" button (600⭐).
   Earn methods list. Collection count.
   Accessible from Me tab → "Character Shop".

F5 — Parent Dashboard (F5 — Parent Dashboard 👨‍👩‍👧)
   Child switcher + Add Child. This week stats row.
   Subject breakdown with mastery bars. Alert cards (⚠️ / ✅ / 💡).
   Screen time limit toggle.
   Accessible via Me tab → "Parent Mode" (requires parent PIN).

F6 — AI Study Plan (F6 — AI Study Plan 🗓)
   Avatar speech bubble intro. Today's tasks (Done / Start).
   Coming Up list (day label + task). Test countdown dark card.
   Accessible from Home → "Study Plan" chip, or Library tab.

F7 — Homework Photo Scan Result (F7 — Homework Scan Result 📸)
   Scanned image preview. Blue scan overlay showing question count.
   Expandable answer cards (first expanded by default). XP badge. Follow-up CTA.
   Rendered inline in chat as a special message bubble type.
```

---

# PART 2 — DESIGN TOKEN SYSTEM

## Colours — AppColors

```dart
// lib/core/theme/app_colors.dart
abstract class AppColors {
  static const purple    = Color(0xFF7042ED);
  static const purpleL   = Color(0xFFEBE0FF);
  static const purpleC   = Color(0xFF8F66FA);
  static const teal      = Color(0xFF00BBA4);
  static const tealL     = Color(0xFFD7F7F3);
  static const coral     = Color(0xFFFF6660);
  static const coralL    = Color(0xFFFFE5E4);
  static const amber     = Color(0xFFFFB81A);
  static const amberL    = Color(0xFFFFF5D1);
  static const green     = Color(0xFF2EC870);
  static const greenL    = Color(0xFFDBF9E8);
  static const pink      = Color(0xFFFF6BAE);
  static const pinkL     = Color(0xFFFFE0F0);
  static const gold      = Color(0xFFFFD100);
  static const goldL     = Color(0xFFFFF8CC);
  static const bg        = Color(0xFFFAFAFF);
  static const surface   = Color(0xFFFFFFFF);
  static const surf2     = Color(0xFFF5F2FC);
  static const outline   = Color(0xFFE0DAF0);
  static const text1     = Color(0xFF1F1733);
  static const text2     = Color(0xFF6B618A);
  static const text3     = Color(0xFFA8A0BD);
}
```

## Typography — AppTextStyles (use Google Fonts Nunito)

```dart
// lib/core/theme/app_text_styles.dart
abstract class AppTextStyles {
  static const heading1  = TextStyle(fontFamily:'Nunito', fontSize:22, fontWeight:FontWeight.w800, color:AppColors.text1);
  static const title     = TextStyle(fontFamily:'Nunito', fontSize:18, fontWeight:FontWeight.w700, color:AppColors.text1);
  static const body      = TextStyle(fontFamily:'Nunito', fontSize:14, fontWeight:FontWeight.w400, color:AppColors.text1);
  static const bodySmall = TextStyle(fontFamily:'Nunito', fontSize:12, fontWeight:FontWeight.w400, color:AppColors.text2);
  static const label     = TextStyle(fontFamily:'Nunito', fontSize:11, fontWeight:FontWeight.w600, color:AppColors.text2);
  static const caption   = TextStyle(fontFamily:'Nunito', fontSize:9,  fontWeight:FontWeight.w400, color:AppColors.text3);
}
```

## Spacing — AppSpacing

```dart
abstract class AppSpacing {
  static const double xs = 4;   static const double sm = 8;
  static const double md = 16;  static const double lg = 24;
  static const double xl = 32;  static const double xxl = 48;
  static const screenH = EdgeInsets.symmetric(horizontal:16);
  static const card    = EdgeInsets.all(16);
}
```

---

# PART 3 — FLUTTER PROJECT STRUCTURE

```
lib/
├── app/
│   ├── app.dart              # MaterialApp + ProviderScope
│   ├── router.dart           # GoRouter — all routes typed
│   └── app_theme.dart        # ThemeData using AppColors + Nunito
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_spacing.dart
│   ├── ui/
│   │   ├── pally_button.dart          # filled / outlined / text
│   │   ├── pally_card.dart            # tappable card with shadow
│   │   ├── pally_loading_spinner.dart
│   │   ├── pally_error_card.dart
│   │   ├── pally_bottom_nav.dart      # Material 3 NavigationBar
│   │   ├── pally_avatar_painter.dart  # CustomPainter registry
│   │   └── pally_relevance_dialog.dart
│   └── utils/
│       ├── logger.dart
│       └── extensions.dart
│
├── features/
│   ├── home/                   # ① Home Screen
│   ├── avatar_picker/          # ② Character selection + creation
│   ├── upload/                 # ③ Add knowledge + ④ wiki compiled + ⑦ relevance dialog
│   ├── wiki_viewer/            # ⑤ Tutor brain viewer
│   ├── chat/                   # ⑥ Chat screen + photo scan result (F7)
│   ├── quiz/                   # F1 Daily quiz
│   ├── flashcards/             # F2 Flashcard deck
│   ├── progress/               # F3 Progress dashboard (= "Me" tab)
│   ├── shop/                   # F4 Blind box shop
│   ├── parent/                 # F5 Parent dashboard
│   └── study_plan/             # F6 AI study plan
│
└── shared/
    ├── models/                 # Avatar, WikiPage, ChatMessage, etc.
    └── providers/              # Riverpod providers wiring
```

---

# PART 4 — 4 BOTTOM NAV MODULES (full backbone)

## 🏠 HOME TAB

**Entry:** `HomeScreen` — Avatar grid, streak/XP bar, "+ New" button, Study Plan chip.

**Sub-routes from Home tab:**
- `HomeScreen` → tap avatar → `ChatScreen(avatarId)`
- `HomeScreen` → "+ New" → `AvatarPickerScreen`
- `AvatarPickerScreen` → created → `UploadScreen(avatarId)` (first time)
- `UploadScreen` → upload succeeds → `WikiCompiledScreen(avatarId, newPages)`
- `WikiCompiledScreen` → "Ask now" → `ChatScreen(avatarId)`
- `WikiCompiledScreen` → "Quick quiz" → `QuizScreen(avatarId)`
- `WikiCompiledScreen` → "View brain" → `WikiViewerScreen(avatarId)`
- `ChatScreen` → 📷 tap → `CameraScreen` → returns photo → `HomeworkScanResult` inline

**ViewModel:** `HomeViewModel` — loads avatars, streak, XP level.

---

## 📚 LIBRARY TAB

**Entry:** `LibraryScreen` — shows all avatars as rows. Each row: avatar name, subject, brain stats, 3 action buttons.

**Action buttons per avatar row:**
- `Chat →` → `ChatScreen(avatarId)`
- `Add Content +` → `UploadScreen(avatarId)`
- `Quiz ⚡` → `QuizScreen(avatarId)`

**Sub-routes from Library tab:**
- Tap avatar row → `WikiViewerScreen(avatarId)`
- "Flashcards" chip → `FlashcardScreen(avatarId)`
- "Study Plan" chip → `StudyPlanScreen(avatarId)`

**ViewModel:** `LibraryViewModel` — loads all avatars with stats.

---

## 💬 CHAT TAB

**Entry:** `ChatTabScreen` — if no avatar selected, shows avatar picker grid (same as Home grid but no "+New"). Tap avatar → enters `ChatScreen(avatarId)`.

**This is a navigation shell.** The actual `ChatScreen` is shared between Home and Chat tabs via the same route.

**ChatScreen features:**
- Streaming response from Claude API (SSE)
- Quick reply chips (generated from wiki topics)
- 📷 Photo button → camera → on-device OCR → send to Claude → `HomeworkScanResultBubble`
- 🖼 Gallery button → image picker → same OCR flow
- Source badge on tutor messages
- Typing indicator (animated dots)

**ViewModel:** `ChatViewModel(avatarId)` — manages messages, streaming, wiki context loading.

---

## 👤 ME TAB

**Entry:** `ProgressScreen` = `F3 — Progress Dashboard`
This IS the Me tab. Shows the child's full progress.

**Sub-routes from Me tab:**
- "Practice Weak Topics" → `QuizScreen(weakTopicFilter: true)`
- Badge row → `BadgeDetailScreen` (simple modal)
- "Character Shop ✨" → `ShopScreen` (F4)
- "Parent Mode 🔒" → PIN entry → `ParentDashboardScreen` (F5)
- Settings gear → `SettingsScreen`

**SettingsScreen (simple):**
- Display name
- Notification preferences (daily quiz reminder time)
- Test date setter (feeds Study Plan)
- About / version

---

# PART 5 — CHARACTER PAINTERS

Implement each of the 12 characters as a `CustomPainter`. They must scale cleanly from size 32 (nav badge) to size 120 (shop screen). All coordinates use a `scale` factor based on `size / 60.0`.

**Character list:**
```
Nomi    — pink bunny, asymmetric ears, star patches
Zuzu    — cloud ghost, surprised O-eyes, wispy bottom
Bolt    — green dino, lightning horn, spiky back, toothy grin
Mochi   — beige dumpling bear, tiny bead eyes, chonky
Lumi    — orange fox, sleepy half-lid eyes, glow dot forehead
Quill   — blue alien, huge eyes, mismatched antennae
Fern    — cream mushroom spirit, polka-dot red cap
Cleo    — bandaged mummy cat, one eye peeking
Piko    — cloud + rainbow headband, sparkle X eyes
Fizz    — translucent soda bubble, straw on head, fizzy spots
Tanko   — square tank robot, visor eyes, treads at bottom
Wisp    — yellow flame spirit, teardrop body, sleepy eyes
```

**Usage pattern:**
```dart
class PallyAvatarWidget extends StatelessWidget {
  const PallyAvatarWidget({required this.character, required this.size, super.key});
  final CharacterType character;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size * 1.15),
    painter: _getPainter(character, size),
  );
}
```

---

# PART 6 — STATE MANAGEMENT (Riverpod 3.x)

All providers use `@riverpod` codegen. Run `dart run build_runner build --delete-conflicting-outputs` after every change.

## Key providers

```dart
// Avatar list
@riverpod
class AvatarListViewModel extends _$AvatarListViewModel {
  @override Future<List<Avatar>> build() => ref.watch(avatarRepositoryProvider).getAll();
  Future<void> createAvatar(String name, CharacterType char, Subject subject) async { ... }
  Future<void> deleteAvatar(String id) async { ... }
}

// Chat (per-avatar, auto-dispose)
@riverpod
class ChatViewModel extends _$ChatViewModel {
  @override ChatState build(String avatarId) { ... }
  Future<void> sendMessage(String text) async { ... }
  Future<void> sendPhotoMessage(File photo) async { ... }
}

// Upload (per-avatar)
@riverpod
class UploadViewModel extends _$UploadViewModel {
  @override UploadState build(String avatarId) => const UploadState.idle();
  Future<void> uploadFile(File file, UploadType type) async { ... } // triggers relevance check first
  Future<void> confirmUploadAnyway(File file) async { ... }
}

// Quiz (per-avatar)
@riverpod
class QuizViewModel extends _$QuizViewModel {
  @override Future<QuizState> build(String avatarId) async { ... }
  void answerQuestion(int answerIndex) { ... }
  void nextQuestion() { ... }
}

// Progress (per-user)
@riverpod
class ProgressViewModel extends _$ProgressViewModel {
  @override Future<ProgressState> build() async { ... }
}

// Shop
@riverpod
class ShopViewModel extends _$ShopViewModel {
  @override ShopState build() => ShopState.initial();
  Future<void> openMysteryBox() async { ... }
}
```

---

# PART 7 — BACKEND API CONTRACT

## Base configuration

```dart
// No --dart-define needed; all builds point to the Railway production host by default.
const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://pallybackend-production.up.railway.app',
);
```

## All endpoints Flutter must call

```
# AVATARS
POST   /api/v1/avatars                              Create avatar
GET    /api/v1/avatars                              List all (for current user)
GET    /api/v1/avatars/{id}                         Get single
DELETE /api/v1/avatars/{id}                         Delete

# KNOWLEDGE / UPLOAD
POST   /api/v1/avatars/{id}/relevance               Check relevance before upload
POST   /api/v1/avatars/{id}/files                   Upload file (multipart)
GET    /api/v1/avatars/{id}/files                   List files
DELETE /api/v1/avatars/{id}/files/{fileId}          Delete file
GET    /api/v1/avatars/{id}/wiki/pages              List wiki pages
GET    /api/v1/avatars/{id}/wiki/pages/{slug}       Get single page content

# CHAT
POST   /api/v1/avatars/{id}/chat  (SSE stream)      Send message, get streaming response
GET    /api/v1/avatars/{id}/chat/history            Load chat history

# QUIZ + FLASHCARDS (generated server-side from wiki)
GET    /api/v1/avatars/{id}/quiz/daily              Get today's quiz questions
POST   /api/v1/avatars/{id}/quiz/answers            Submit answers + update SM-2 schedule
GET    /api/v1/avatars/{id}/flashcards              Get flashcard deck
POST   /api/v1/avatars/{id}/flashcards/{cardId}/rate  Rate card (hard/okay/easy)

# PROGRESS
GET    /api/v1/progress                             Get user progress summary
GET    /api/v1/progress/study-plan                  Get AI-generated study plan

# SHOP
GET    /api/v1/shop/stars                           Get star balance
POST   /api/v1/shop/open-box                        Open mystery box (costs 600 stars)

# AUTH (simple for MVP)
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/parent-pin                      Set/verify parent PIN
```

## Key Dart DTO types (@freezed records)

```dart
@freezed class CreateAvatarRequest with _$CreateAvatarRequest {
  const factory CreateAvatarRequest({
    required String name, required Subject subject, required CharacterType characterType,
  }) = _CreateAvatarRequest;
  factory CreateAvatarRequest.fromJson(Map<String,dynamic> j) => _$CreateAvatarRequestFromJson(j);
}

@freezed class RelevanceCheckResponse with _$RelevanceCheckResponse {
  const factory RelevanceCheckResponse({
    required double score, required String reason, required bool isRelevant,
  }) = _RelevanceCheckResponse;
  factory RelevanceCheckResponse.fromJson(Map<String,dynamic> j) => _$RelevanceCheckResponseFromJson(j);
}

@freezed class ChatStreamEvent with _$ChatStreamEvent {
  const factory ChatStreamEvent.token({required String text})                = TokenEvent;
  const factory ChatStreamEvent.done({required String? sourceFile})          = DoneEvent;
  const factory ChatStreamEvent.error({required String message})             = ErrorEvent;
}

@freezed class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id, required String question, required List<String> options,
    required int correctIndex, required String sourcePageSlug, required String sourceSummary,
  }) = _QuizQuestion;
  factory QuizQuestion.fromJson(Map<String,dynamic> j) => _$QuizQuestionFromJson(j);
}

@freezed class FlashCard with _$FlashCard {
  const factory FlashCard({
    required String id, required String front, required String back,
    required String sourceFile, required CardRating lastRating,
    required DateTime nextReview,
  }) = _FlashCard;
  factory FlashCard.fromJson(Map<String,dynamic> j) => _$FlashCardFromJson(j);
}
```

---

# PART 8 — BACKEND IMPLEMENTATION (Java Spring Boot)

## Stack

- Java 21 · Spring Boot 3.3 · Gradle Kotlin DSL
- PostgreSQL 16 + Flyway migrations
- Spring WebClient for streaming (SSE to Claude)
- JWT auth (stateless) — simple for MVP
- Virtual threads: `spring.threads.virtual.enabled=true`

## Package structure

```
com.pally/
├── PallyApplication.java
├── shared/
│   ├── exception/      # PallyException, AvatarNotFoundException, etc.
│   ├── response/       # ApiResponse<T> record
│   └── util/           # IdGenerator (UUID v7), TextSampler
├── domain/
│   ├── avatar/         # Avatar entity, AvatarRepository port, use cases
│   ├── knowledge/      # KnowledgeFile, WikiPage, ports, use cases
│   ├── chat/           # ChatMessage, ChatRepository, SendMessageUseCase
│   ├── quiz/           # QuizQuestion, FlashCard, SM-2 scheduler
│   └── progress/       # ProgressSummary, StudyPlanGenerator
├── infrastructure/
│   ├── persistence/    # JPA entities + repository adapters
│   ├── ai/             # ClaudeApiClient, ClaudeRelevanceChecker, ClaudeChatProxy,
│   │                   #   ClaudeQuizGenerator, ClaudeStudyPlanGenerator
│   ├── ocr/            # TesseractOcrService, PdfTextExtractor
│   └── storage/        # S3StorageService / LocalStorageService
└── api/
    ├── avatar/         # AvatarController + DTOs
    ├── knowledge/      # KnowledgeController + DTOs
    ├── chat/           # ChatController (SSE) + DTOs
    ├── quiz/           # QuizController + DTOs
    ├── progress/       # ProgressController + DTOs
    ├── shop/           # ShopController + DTOs
    └── auth/           # AuthController + JWT filter
```

## Database schema (Flyway V1)

```sql
CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY, email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(100), parent_pin_hash VARCHAR(100),
  stars INT NOT NULL DEFAULT 0, xp INT NOT NULL DEFAULT 0,
  level INT NOT NULL DEFAULT 1, streak_days INT NOT NULL DEFAULT 0,
  last_active_date DATE, created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE avatars (
  id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL, subject VARCHAR(20) NOT NULL, character_type VARCHAR(20) NOT NULL,
  wiki_page_count INT NOT NULL DEFAULT 0, created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE knowledge_files (
  id VARCHAR(36) PRIMARY KEY, avatar_id VARCHAR(36) NOT NULL REFERENCES avatars(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL, storage_key VARCHAR(500) NOT NULL,
  upload_type VARCHAR(20) NOT NULL, page_count INT DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'PROCESSING', created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE wiki_pages (
  id VARCHAR(36) PRIMARY KEY, avatar_id VARCHAR(36) NOT NULL REFERENCES avatars(id) ON DELETE CASCADE,
  slug VARCHAR(200) NOT NULL, title VARCHAR(255) NOT NULL, content TEXT NOT NULL,
  certainty VARCHAR(20) NOT NULL DEFAULT 'INFERRED',
  has_conflict BOOLEAN NOT NULL DEFAULT FALSE, updated_at TIMESTAMPTZ NOT NULL,
  UNIQUE (avatar_id, slug)
);

CREATE TABLE chat_messages (
  id VARCHAR(36) PRIMARY KEY, avatar_id VARCHAR(36) NOT NULL REFERENCES avatars(id) ON DELETE CASCADE,
  user_id VARCHAR(36) NOT NULL, role VARCHAR(10) NOT NULL,
  content TEXT NOT NULL, source_file VARCHAR(255), created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE flashcards (
  id VARCHAR(36) PRIMARY KEY, avatar_id VARCHAR(36) NOT NULL REFERENCES avatars(id) ON DELETE CASCADE,
  front TEXT NOT NULL, back TEXT NOT NULL, source_slug VARCHAR(200),
  last_rating VARCHAR(10), next_review_at TIMESTAMPTZ, repetitions INT DEFAULT 0,
  ease_factor REAL DEFAULT 2.5, interval_days INT DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE quiz_sessions (
  id VARCHAR(36) PRIMARY KEY, avatar_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL, score INT, total INT,
  xp_earned INT DEFAULT 0, completed_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE unlocked_characters (
  user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  character_type VARCHAR(20) NOT NULL, unlocked_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, character_type)
);

CREATE INDEX idx_avatars_user ON avatars(user_id);
CREATE INDEX idx_wiki_avatar  ON wiki_pages(avatar_id);
CREATE INDEX idx_chat_avatar  ON chat_messages(avatar_id, created_at DESC);
CREATE INDEX idx_flash_avatar ON flashcards(avatar_id, next_review_at);
```

## Claude API — system prompt for chat

```java
String buildSystemPrompt(Avatar avatar, List<WikiPage> wikiContext) {
  String wiki = wikiContext.stream()
    .map(p -> "## " + p.title() + "\n" + p.content())
    .collect(Collectors.joining("\n\n"));

  return """
    You are %s, a friendly and encouraging AI tutor for a child studying %s.
    You explain things simply using examples kids love: food, games, sports, animals.
    Keep sentences short. Use emojis occasionally. Never be condescending.
    ONLY answer questions about %s. For off-topic questions, kindly redirect.

    When you can, ask a Socratic question to guide the child rather than giving the answer directly.

    Your knowledge base (the child's own notes):
    ---
    %s
    ---

    When you reference the knowledge base, end your reply with:
    SOURCE: [page-slug]
    """.formatted(avatar.name(), avatar.subject().label(), avatar.subject().label(), wiki);
}
```

## Relevance check prompt

```java
String buildRelevancePrompt(String avatarSubject, String indexSummary, String sample) {
  return """
    The tutor avatar specialises in: %s

    What the tutor already knows (index summary):
    %s

    New content being uploaded (first 500 tokens):
    %s

    Rate the relevance of the new content to the tutor's subject on a scale of 0.0 to 1.0.
    0.0 = completely unrelated. 1.0 = perfectly on-topic.

    Reply ONLY with valid JSON (no markdown, no explanation):
    {"score": 0.0, "reason": "one sentence"}
    """.formatted(avatarSubject, indexSummary, sample);
}
```

## Quiz generation prompt

```java
String buildQuizPrompt(List<WikiPage> pages) {
  return """
    Based on the following study material, generate 5 multiple-choice quiz questions.
    Each question should test understanding, not just memorisation.
    Questions must come directly from the provided material.

    Material:
    %s

    Reply ONLY with a JSON array:
    [{"question":"...","options":["A...","B...","C...","D..."],"correctIndex":0,"sourcePage":"slug","explanation":"..."}]
    """.formatted(pages.stream().map(p->p.title()+": "+p.content()).collect(Collectors.joining("\n\n")));
}
```

---

# PART 9 — GAMIFICATION & SM-2 SPACED REPETITION

## XP actions (backend awards XP on these events)

```java
enum XpAction {
  COMPLETE_QUIZ(20), STREAK_DAY(10), MASTER_TOPIC(50),
  PHOTO_QUESTION(5), UPLOAD_CONTENT(15), FIRST_CHAT(30);
  final int points;
}
// Level thresholds: 0,100,250,500,900,1400,2000,2800,3800,5000...
// Level = computed from total XP
// Stars = separate from XP. Stars earned = XP earned * 0.5 (rounded)
// Mystery box costs 600 stars
```

## SM-2 Algorithm (Java)

```java
// SuperMemo 2 scheduling — runs in QuizService
public FlashCard applyRating(FlashCard card, CardRating rating) {
  double ef = card.easeFactor();
  int reps = card.repetitions();
  int interval = card.intervalDays();

  int q = switch(rating) { case HARD -> 2; case OKAY -> 4; case EASY -> 5; };
  ef = Math.max(1.3, ef + 0.1 - (5-q) * (0.08 + (5-q) * 0.02));

  if (q < 3) { reps = 0; interval = 1; }
  else if (reps == 0) { interval = 1; reps = 1; }
  else if (reps == 1) { interval = 6; reps = 2; }
  else { interval = (int)Math.round(interval * ef); reps++; }

  return card.withEaseFactor(ef).withRepetitions(reps).withIntervalDays(interval)
             .withNextReviewAt(Instant.now().plus(interval, ChronoUnit.DAYS))
             .withLastRating(rating);
}
```

---

# PART 10 — IMPLEMENTATION ORDER

Build in this exact sequence. Each step is deployable and testable.

## Phase 1 — Core skeleton (Week 1)
1. Flutter project setup: packages, theme, AppColors, AppTextStyles
2. All 12 `CustomPainter` character implementations
3. GoRouter with all typed routes (stubbed screens)
4. `PallyBottomNav` with 4 tabs (stubbed content)
5. `PallyButton`, `PallyCard`, `PallyLoadingSpinner`, `PallyErrorCard`
6. Backend: Spring Boot project, Flyway schema, JWT auth endpoints

## Phase 2 — Avatar creation + upload (Week 2)
7. `HomeScreen` with avatar grid
8. `AvatarPickerScreen` + `CreateAvatarUseCase`
9. `UploadScreen` with camera + PDF + paste options
10. Relevance check API call + `PallyRelevanceDialog`
11. Wiki compilation pipeline (Claude API → markdown → DB)
12. `WikiCompiledScreen` post-upload celebration

## Phase 3 — Chat (Week 3)
13. `ChatScreen` with streaming SSE
14. Message bubble widgets (user, tutor, photo-result)
15. Photo capture → on-device OCR → Claude → `HomeworkScanResultBubble`
16. Quick reply chip generation from wiki topics
17. `WikiViewerScreen` (Library tab entry)

## Phase 4 — Features (Week 4)
18. Daily quiz: generation + `QuizScreen` + SM-2 scheduling
19. `FlashcardScreen` + self-rating + SM-2 integration
20. `ProgressScreen` (Me tab) + charts + badges
21. `ShopScreen` + mystery box animation + star balance
22. `StudyPlanScreen` + test date setting
23. `ParentDashboardScreen` + PIN gate

## Phase 5 — Polish (Week 5)
24. Push notifications (daily quiz reminder)
25. Offline mode (MMKV cache for recent chat + wiki)
26. Onboarding flow (first launch)
27. Settings screen
28. Performance audit + golden tests

---

# PART 11 — CRITICAL RULES (repeat from coding practices)

❌ Never hardcode colours — always `AppColors.*`
❌ Never put logic in `build()` — only UI composition
❌ Never use `Navigator.push` — always `GoRouter.of(context).go()`
❌ Never call `ref.read()` inside `build()` — only in callbacks
❌ Never skip `super.key` on widget constructors
❌ Never create image assets for avatars — use `CustomPainter`
❌ Never use `GetX` or `Provider` package — only Riverpod 3.x
❌ Never hardcode API key — use `--dart-define`
❌ Never put business logic in `@RestController` — use cases only (Java)
❌ Never let JPA entities leave the `infrastructure` layer (Java)
❌ Never use field injection `@Autowired` on fields — constructor injection only (Java)
❌ Never ignore lint warnings — `treat_warnings_as_errors: true`

✅ Run `dart analyze` before every commit
✅ Run `dart run build_runner build` after every `@riverpod` change
✅ Every provider has a unit test with `ProviderScope` overrides
✅ Every screen has a widget test
✅ Backend: every use case has a unit test with Mockito
✅ Backend: every controller has an integration test with Testcontainers

---

# PART 12 — QUICK START COMMANDS

```bash
# Flutter
flutter pub add flutter_riverpod riverpod_annotation go_router drift sqlite3_flutter_libs \
  flutter_secure_storage shared_preferences path_provider file_picker \
  google_mlkit_text_recognition dio image_picker cached_network_image \
  freezed_annotation json_annotation logger uuid intl google_fonts

flutter pub add --dev build_runner riverpod_generator freezed json_serializable drift_dev \
  flutter_test mocktail

dart run build_runner build --delete-conflicting-outputs

# Java / Spring Boot (build.gradle.kts)
implementation("org.springframework.boot:spring-boot-starter-web")
implementation("org.springframework.boot:spring-boot-starter-data-jpa")
implementation("org.springframework.boot:spring-boot-starter-security")
implementation("org.springframework.boot:spring-boot-starter-webflux")  // SSE streaming
implementation("org.flywaydb:flyway-core")
implementation("org.postgresql:postgresql")
implementation("io.jsonwebtoken:jjwt-api:0.12.5")
implementation("net.sourceforge.tess4j:tess4j:5.11.0")    // OCR
implementation("org.apache.pdfbox:pdfbox:3.0.2")          // PDF extraction
implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
testImplementation("org.testcontainers:postgresql")
testImplementation("org.mockito:mockito-core")
```

---

# PART 13 — TEST, BUILD & RESTART PROTOCOL

> **Run this protocol automatically after EVERY code change, no exceptions.**

## DIRECTORY ASSUMPTIONS

```
AndroidStudioProjects/
├── pally/          ← Flutter mobile app  (was: pally-flutter)
└── pally-backend/  ← Java Spring Boot backend
```

## THE PROTOCOL (run every time)

```
PHASE 1 — Static analysis & formatting
PHASE 2 — Flutter unit tests
PHASE 3 — Flutter widget + golden tests
PHASE 4 — Flutter build (compile check)
PHASE 5 — Backend unit tests
PHASE 6 — Backend integration tests (Testcontainers)
PHASE 7 — Backend compile & package
PHASE 8 — API smoke tests (live endpoint calls)
PHASE 9 — Restart servers
PHASE 10 — Post-restart health check
EXIT — report summary
```

If any phase fails, stop, fix the issue, re-run from **the beginning of that phase**.

---

## PHASE 1 — Static Analysis & Formatting

```bash
# From pally/ (Flutter root):
dart format --set-exit-if-changed .
dart analyze --fatal-infos --fatal-warnings

# From pally-backend/:
./gradlew checkstyleMain spotbugsMain --no-daemon   # skip if not configured
```

**Pass criteria:** Both commands exit 0. Zero warnings. Zero formatting diffs.

---

## PHASE 2 — Flutter Unit Tests

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/unit/ --coverage --reporter expanded
```

**Pass criteria:** `All tests passed!` — zero failures, zero skipped.

---

## PHASE 3 — Flutter Widget & Golden Tests

```bash
flutter test test/widget/ --reporter expanded
flutter test test/golden/ --reporter expanded
# For intentional UI change only: flutter test test/golden/ --update-goldens
```

---

## PHASE 4 — Flutter Build Compile Check

```bash
flutter build apk --debug --no-pub 2>&1 | tee /tmp/flutter_build_android.log
# Must end with: "Built build/app/outputs/flutter-apk/app-debug.apk"
```

---

## PHASE 5 — Backend Unit Tests

```bash
cd pally-backend/
./gradlew test --tests "*Test" --exclude-task integrationTest --no-daemon \
  2>&1 | tee /tmp/backend_unit_tests.log
```

**Pass criteria:** `BUILD SUCCESSFUL` — 0 failures.

---

## PHASE 6 — Backend Integration Tests

```bash
docker info > /dev/null 2>&1 || echo "ERROR: Docker not running"
./gradlew integrationTest --no-daemon 2>&1 | tee /tmp/backend_integration_tests.log
```

**Pass criteria:** `BUILD SUCCESSFUL` — 0 failures.

---

## PHASE 7 — Backend Compile & Package

```bash
./gradlew clean bootJar --no-daemon 2>&1 | tee /tmp/backend_build.log
ls -la build/libs/*.jar   # must show pally-backend-*.jar
```

---

## PHASE 8 — API Smoke Tests (19 checks)

All smoke tests run against the **remote Railway host**. No local backend needed.

```bash
BASE="https://pallybackend-production.up.railway.app/api/v1"

# 1. Register (201 or 409)
# 2. Login → capture TOKEN
# 3. Create avatar (201) → capture AVATAR_ID
# 4. List avatars (200)
# 5. Get single avatar (200)
# 6. Relevance check on-topic (200, isRelevant=true)
# 7. Relevance check off-topic (200, isRelevant=false)
# 8. List wiki pages (200)
# 9. Chat SSE stream — must see "data:" lines + "done"
# 10. Photo question — must see "answer" in response
# 11. Get daily quiz (200)
# 12. Get flashcards (200)
# 13. Progress summary (200)
# 14. Study plan (200)
# 15. Star balance (200)
# 16. Unknown avatar → 404
# 17. No auth token → 401
# 18. Off-topic relevance check → 200 (always 200, check isRelevant)
# 19. Delete test avatar (204)
```

**Pass criteria:** All 19 checks pass against the remote host.

---

## PHASE 9 — Deploy Backend

```bash
# Backend deploys automatically on git push to main via Railway.
# No local server management needed.
git -C ../pally-backend push origin main
# Watch Railway dashboard or: railway logs --tail
```

---

## PHASE 10 — Post-Deploy Health Check

```bash
REMOTE="https://pallybackend-production.up.railway.app"
curl -sf "$REMOTE/actuator/health" | grep -q '"status":"UP"' || exit 1
echo "PASS: Remote backend healthy"
```

---

## EXIT — Final Summary Format

```
╔══════════════════════════════════════════════════════════════╗
║           PALLY — FULL TEST & BUILD PROTOCOL COMPLETE        ║
╠══════════════════════════════════════════════════════════════╣
║  Phase 1  Static analysis + formatting       ✅ PASSED       ║
║  Phase 2  Flutter unit tests                 ✅ PASSED       ║
║  Phase 3  Flutter widget + golden tests      ✅ PASSED       ║
║  Phase 4  Flutter build (Android APK)        ✅ PASSED       ║
║  Phase 5  Backend unit tests                 ✅ PASSED       ║
║  Phase 6  Backend integration tests          ✅ PASSED       ║
║  Phase 7  Backend compile + JAR              ✅ PASSED       ║
║  Phase 8  API smoke tests (19 checks)        ✅ PASSED       ║
║  Phase 9  Servers restarted                  ✅ DONE         ║
║  Phase 10 Post-restart health check          ✅ PASSED       ║
╚══════════════════════════════════════════════════════════════╝
```

---

## FAILURE RESOLUTION RULES

| Symptom | Likely cause | Fix |
|---|---|---|
| `dart analyze` warning | Unused var, wrong nullability | Fix in source, never suppress |
| `flutter test` failure | Logic bug or broken mock | Fix source first |
| Golden test diff | Unintentional UI regression | Fix widget, not golden |
| `BUILD FAILED` Gradle | Compile error, wrong dep | Fix compile error |
| Testcontainers timeout | Docker not running | `docker info`, check ports |
| Smoke test 500 | Backend exception | Check Railway logs: `railway logs --tail` |
| Smoke test 401 | JWT filter issue | Fix auth or add correct header |
| SSE timeout | Stream never closes | Check Claude API call in Railway logs |
| Deploy not live | Railway build failed | Check Railway dashboard for build errors |

## ENVIRONMENT VARIABLES (set in Railway dashboard, not locally)

```
CLAUDE_API_KEY   — Anthropic API key
DB_URL           — Railway PostgreSQL internal URL
JWT_SECRET       — min 32 chars
PORT             — injected by Railway automatically
```

## SPECIAL RULES

- **After `@riverpod` change:** always run `build_runner` first
- **After DB schema change:** run `./gradlew flywayValidate --no-daemon`
- **After Claude prompt change:** run integration test + smoke test for that endpoint
- **After new API endpoint:** add it to Phase 8 smoke tests before declaring protocol complete
- **After GoRouter change:** test every affected route manually on device

---

# PART 14 — LOGGING, DIAGNOSTICS & API VISIBILITY
## Read this section before diagnosing any runtime issue or touching any logging code.

---

## IMMEDIATE TRIAGE — CONNECTION TIMEOUT

**All traffic goes to the Railway remote host. There is no local backend.**

Remote host: `https://pallybackend-production.up.railway.app`

If you see a connection timeout in Logcat, run this diagnostic sequence:

---

### STEP 1 — Verify remote backend is up

```bash
REMOTE="https://pallybackend-production.up.railway.app"
curl -sf "$REMOTE/actuator/health"
# Expected: {"status":"UP"}
# If not UP: check Railway dashboard for deploy errors or restart the service.
```

---

### STEP 2 — Check Railway logs for backend errors

```bash
# Via Railway CLI:
railway logs --tail

# Or check the Railway dashboard → pally-backend → Deployments → most recent deploy → Logs
```

**Common Railway failure patterns:**

| Log pattern | Cause | Fix |
|---|---|---|
| `Connection refused` to PostgreSQL | DB env var missing | Set `DB_URL` in Railway variables |
| `FlywayException: Migration checksum mismatch` | Migration file edited after apply | Create a new migration file, never edit old ones |
| `CLAUDE_API_KEY not set` or empty | Missing Railway env var | Add `CLAUDE_API_KEY` in Railway → Variables |
| `BeanCreationException` | Spring config error | Read full stack trace in Railway logs |
| Build times out | Gradle OOM | Add `JAVA_OPTS=-Xmx512m` in Railway variables |

---

### STEP 3 — Verify Flutter is pointing at the remote host

```bash
grep -r "API_BASE_URL\|baseUrl\|pallybackend\|railway" lib/ --include="*.dart"
# Should show: defaultValue: 'https://pallybackend-production.up.railway.app'
# No --dart-define override should be set for production builds.
```

---

### STEP 4 — Re-run the failing Flutter request and read the full log

```bash
# Watch Logcat filtered to Pally while reproducing the issue:
adb logcat -s flutter:V PallyAPI:V PallyDio:V AndroidRuntime:E \
  | grep -E "DioException|REQUEST|RESPONSE|ERROR|WARN|status|timeout|connect"
```

---

## FLUTTER LOGGING STANDARD

Every API call made by the Flutter app MUST be visible in Logcat with full detail. Implement this in `lib/core/network/dio_client.dart`.

### Dio HTTP Client with full logging

```dart
// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: false,           // Logcat handles colour
    printEmojis: true,
    printTime: true,
  ),
);

class PallyDioClient {
  static Dio create({required String baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),   // raised from 10
      receiveTimeout: const Duration(seconds: 30),   // for SSE streams
      sendTimeout:    const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      _PallyLoggingInterceptor(),
      _PallyAuthInterceptor(),
      _PallyErrorInterceptor(),
    ]);

    return dio;
  }
}

// ── Logging interceptor — logs EVERY request and response ────
class _PallyLoggingInterceptor extends Interceptor {
  static const _tag = 'PallyAPI';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.i(
      '[$_tag] ──► REQUEST\n'
      '  Method : ${options.method}\n'
      '  URL    : ${options.baseUrl}${options.path}\n'
      '  Headers: ${_sanitiseHeaders(options.headers)}\n'
      '  Query  : ${options.queryParameters}\n'
      '  Body   : ${_truncate(options.data?.toString())}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.i(
      '[$_tag] ◄── RESPONSE\n'
      '  Status : ${response.statusCode} ${response.statusMessage}\n'
      '  URL    : ${response.requestOptions.baseUrl}${response.requestOptions.path}\n'
      '  Body   : ${_truncate(response.data?.toString())}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;

    // Build a human-readable failure reason
    final reason = switch (err.type) {
      DioExceptionType.connectionTimeout  => 'CONNECTION TIMEOUT — backend unreachable or too slow\n'
          '  Tried  : ${req.baseUrl}${req.path}\n'
          '  Timeout: ${req.connectTimeout?.inSeconds}s\n'
          '  Fix    : Check backend is running on correct host:port',
      DioExceptionType.receiveTimeout    => 'RECEIVE TIMEOUT — backend connected but response took too long\n'
          '  URL    : ${req.baseUrl}${req.path}\n'
          '  Timeout: ${req.receiveTimeout?.inSeconds}s\n'
          '  Fix    : Check for slow DB queries or Claude API latency',
      DioExceptionType.sendTimeout       => 'SEND TIMEOUT — request body took too long to upload\n'
          '  URL    : ${req.baseUrl}${req.path}',
      DioExceptionType.connectionError   => 'CONNECTION ERROR — network unreachable or backend down\n'
          '  URL    : ${req.baseUrl}${req.path}\n'
          '  Error  : ${err.error}\n'
          '  Fix    : Is backend running? Correct IP/port? Check emulator vs physical device URL',
      DioExceptionType.badResponse       => 'BAD RESPONSE — server returned HTTP error\n'
          '  Status : ${err.response?.statusCode} ${err.response?.statusMessage}\n'
          '  URL    : ${req.baseUrl}${req.path}\n'
          '  Body   : ${_truncate(err.response?.data?.toString())}',
      DioExceptionType.cancel            => 'REQUEST CANCELLED\n'
          '  URL    : ${req.baseUrl}${req.path}',
      DioExceptionType.unknown           => 'UNKNOWN ERROR\n'
          '  URL    : ${req.baseUrl}${req.path}\n'
          '  Error  : ${err.error}\n'
          '  Message: ${err.message}',
      DioExceptionType.badCertificate    => 'BAD SSL CERTIFICATE\n'
          '  URL    : ${req.baseUrl}${req.path}\n'
          '  Fix    : Check SSL cert or use HTTP for local dev',
    };

    _log.e(
      '[$_tag] ✗✗✗ FAILURE\n'
      '  Method : ${req.method}\n'
      '  $reason',
      error: err.error,
      stackTrace: err.stackTrace,
    );

    handler.next(err);
  }

  // Remove sensitive headers from logs
  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = 'Bearer [REDACTED]';
    }
    if (copy.containsKey('x-api-key')) {
      copy['x-api-key'] = '[REDACTED]';
    }
    return copy;
  }

  String _truncate(String? s, {int max = 500}) {
    if (s == null) return 'null';
    return s.length > max ? '${s.substring(0, max)}... [truncated ${s.length - max} chars]' : s;
  }
}

// ── Auth interceptor — attaches JWT to every request ─────────
class _PallyAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip auth header for auth endpoints
    if (options.path.contains('/auth/')) {
      handler.next(options);
      return;
    }
    final token = _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      _log.w('[PallyAPI] No auth token — unauthenticated request to ${options.path}');
    }
    handler.next(options);
  }
}

// ── Error interceptor — maps HTTP codes to user-friendly state
class _PallyErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    // Map to typed app exceptions
    final appException = switch (statusCode) {
      401 => PallyException.unauthenticated('Session expired — please log in again'),
      403 => PallyException.forbidden('You do not have permission to do this'),
      404 => PallyException.notFound(err.requestOptions.path),
      422 => PallyException.validation(
          err.response?.data?['error'] ?? 'Validation failed'),
      429 => PallyException.rateLimited('Too many requests — slow down a little'),
      500 => PallyException.serverError(
          err.response?.data?['error'] ?? 'Server error — try again'),
      503 => PallyException.serverError('Service unavailable — backend may be restarting'),
      null => switch (err.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.connectionError =>
            PallyException.networkError(
              'Cannot reach Pally server\n'
              'Check: backend running? Correct URL? WiFi connected?'),
          _ => PallyException.unknown(err.message ?? 'Unknown error'),
        },
      _ => PallyException.unknown('Unexpected error ($statusCode)'),
    };

    handler.reject(
      err.copyWith(error: appException),
      true,
    );
  }
}
```

### Log levels — use correctly throughout the app

```dart
// lib/core/utils/logger.dart

import 'package:logger/logger.dart';

final appLog = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 10,
    lineLength: 100,
    colors: false,
    printEmojis: true,
    printTime: true,
  ),
  level: kReleaseMode ? Level.warning : Level.trace,
);

// Usage rules — ENFORCE THESE EVERYWHERE:
//
// appLog.t('Trace: entering method X with params Y')     // verbose flow
// appLog.d('Debug: avatar loaded from cache')            // useful dev info
// appLog.i('Info: user created avatar Zuzu [id=abc]')   // key business events
// appLog.w('Warn: relevance score 0.3 — below threshold') // non-fatal issues
// appLog.e('Error: wiki compile failed', error: e, stackTrace: st) // failures
// appLog.f('Fatal: app cannot start — missing config')  // unrecoverable

// NEVER use print() or debugPrint() — use appLog
// NEVER swallow exceptions with empty catch blocks
// ALWAYS pass error: and stackTrace: to appLog.e()
```

### Log every key user action and state transition

```dart
// In every ViewModel — log state changes

@riverpod
class ChatViewModel extends _$ChatViewModel {

  Future<void> sendMessage(String text) async {
    appLog.i('[Chat] Sending message to avatar $avatarId: "${text.substring(0,min(50,text.length))}"');

    try {
      state = state.copyWith(isTyping: true);
      appLog.d('[Chat] Calling /api/v1/avatars/$avatarId/chat');

      final stream = ref.read(claudeApiServiceProvider).streamResponse(...);

      await for (final event in stream) {
        appLog.t('[Chat] SSE event: ${event.type}');
        // ... handle event
      }

      appLog.i('[Chat] Message complete. Source: ${state.messages.last.sourceFile}');

    } on PallyException catch (e) {
      appLog.e('[Chat] API call failed', error: e, stackTrace: StackTrace.current);
      state = state.copyWith(error: e.userMessage, isTyping: false);

    } catch (e, st) {
      appLog.e('[Chat] Unexpected error', error: e, stackTrace: st);
      state = state.copyWith(error: 'Something went wrong', isTyping: false);
    }
  }
}
```

---

## BACKEND LOGGING STANDARD

Every HTTP request, response, and error must appear in the Spring Boot log with full detail. Implement this in `com.pally.shared.logging`.

### Request/Response logging filter

```java
// com/pally/shared/logging/PallyRequestLoggingFilter.java

@Component
@Slf4j
public class PallyRequestLoggingFilter extends OncePerRequestFilter {

    private static final Set<String> SENSITIVE_HEADERS =
        Set.of("authorization", "x-api-key", "cookie");

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        long start = System.currentTimeMillis();
        String requestId = UUID.randomUUID().toString().substring(0, 8);
        String userId = request.getHeader("X-User-Id");

        // Log incoming request
        log.info("[{}] ──► {} {} | user={} | ip={}",
            requestId,
            request.getMethod(),
            request.getRequestURI() + formatQuery(request.getQueryString()),
            userId != null ? userId : "anonymous",
            getClientIp(request));

        // Log headers at debug level
        if (log.isDebugEnabled()) {
            Enumeration<String> headerNames = request.getHeaderNames();
            while (headerNames != null && headerNames.hasMoreElements()) {
                String name = headerNames.nextElement();
                String value = SENSITIVE_HEADERS.contains(name.toLowerCase())
                    ? "[REDACTED]"
                    : request.getHeader(name);
                log.debug("[{}]   Header: {}: {}", requestId, name, value);
            }
        }

        // Wrap response to capture status
        ContentCachingResponseWrapper responseWrapper =
            new ContentCachingResponseWrapper(response);

        try {
            filterChain.doFilter(request, responseWrapper);
        } finally {
            long duration = System.currentTimeMillis() - start;
            int status = responseWrapper.getStatus();

            if (status >= 500) {
                log.error("[{}] ◄── {} {} {}ms | {}",
                    requestId, status, request.getRequestURI(), duration,
                    new String(responseWrapper.getContentAsByteArray(), StandardCharsets.UTF_8)
                        .substring(0, Math.min(500, responseWrapper.getContentSize())));
            } else if (status >= 400) {
                log.warn("[{}] ◄── {} {} {}ms | {}",
                    requestId, status, request.getRequestURI(), duration,
                    new String(responseWrapper.getContentAsByteArray(), StandardCharsets.UTF_8)
                        .substring(0, Math.min(500, responseWrapper.getContentSize())));
            } else {
                log.info("[{}] ◄── {} {} {}ms",
                    requestId, status, request.getRequestURI(), duration);
            }

            responseWrapper.copyBodyToResponse();
        }
    }

    private String formatQuery(String query) {
        return query != null ? "?" + query : "";
    }

    private String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        return ip != null ? ip.split(",")[0].trim() : req.getRemoteAddr();
    }
}
```

### Claude API call logging

```java
// In ClaudeApiClient.java — log every call to Claude

@Slf4j
@Component
public class ClaudeApiClient {

    public Mono<String> complete(String model, int maxTokens, String prompt) {
        String callId = UUID.randomUUID().toString().substring(0, 8);
        int promptLen = prompt.length();

        log.info("[Claude-{}] REQUEST model={} maxTokens={} promptChars={}",
            callId, model, maxTokens, promptLen);
        log.debug("[Claude-{}] Prompt preview: {}",
            callId, prompt.substring(0, Math.min(200, promptLen)));

        long start = System.currentTimeMillis();

        return webClient.post()
            .uri(CLAUDE_API_URL)
            .bodyValue(buildBody(model, maxTokens, prompt))
            .retrieve()
            .bodyToMono(String.class)
            .doOnSuccess(response -> {
                long ms = System.currentTimeMillis() - start;
                log.info("[Claude-{}] RESPONSE {}ms responseChars={}",
                    callId, ms, response.length());
                log.debug("[Claude-{}] Response preview: {}",
                    callId, response.substring(0, Math.min(300, response.length())));
            })
            .doOnError(error -> {
                long ms = System.currentTimeMillis() - start;
                log.error("[Claude-{}] FAILED after {}ms: {} — {}",
                    callId, ms, error.getClass().getSimpleName(), error.getMessage());
            });
    }

    public Flux<String> stream(String model, int maxTokens, String systemPrompt,
                               List<Map<String,String>> messages) {
        String callId = UUID.randomUUID().toString().substring(0, 8);
        log.info("[Claude-{}] STREAM REQUEST model={} messages={}",
            callId, model, messages.size());
        long start = System.currentTimeMillis();
        int[] tokenCount = {0};

        return webClient.post()
            .uri(CLAUDE_API_URL)
            .bodyValue(buildStreamBody(model, maxTokens, systemPrompt, messages))
            .retrieve()
            .bodyToFlux(String.class)
            .doOnNext(chunk -> tokenCount[0]++)
            .doOnComplete(() -> log.info("[Claude-{}] STREAM COMPLETE {}ms ~{}chunks",
                callId, System.currentTimeMillis() - start, tokenCount[0]))
            .doOnError(error -> log.error("[Claude-{}] STREAM ERROR: {} — {}",
                callId, error.getClass().getSimpleName(), error.getMessage()));
    }
}
```

### application.yml logging config

```yaml
# src/main/resources/application.yml — add this logging section

logging:
  level:
    root: INFO
    com.pally: DEBUG                        # all Pally code at DEBUG
    com.pally.infrastructure.ai: DEBUG      # Claude API calls
    com.pally.shared.logging: DEBUG         # request/response filter
    org.springframework.web: INFO
    org.springframework.security: WARN      # quiet unless debugging auth
    org.hibernate.SQL: DEBUG                # show SQL queries
    org.hibernate.orm.jdbc.bind: TRACE      # show SQL parameters (DEV only)
    org.flywaydb: INFO

  pattern:
    # Structured, readable log format for Logcat / terminal
    console: "%d{HH:mm:ss.SSS} [%thread] %highlight(%-5level) %cyan(%logger{30}) - %msg%n"

  # In production, switch to JSON:
  # file:
  #   name: /var/log/pally/pally.log
```

---

## READING LOGCAT — COMMANDS TO USE

Run these while the Flutter app is open on your device/emulator:

```bash
# ── All Pally logs (clean, no noise) ─────────────────────────
adb logcat -s flutter:V \
  | grep -E "PallyAPI|PallyDio|Chat\]|Upload\]|Quiz\]|Auth\]|ERROR|WARN|DioException"

# ── Full verbose (everything including Flutter framework) ─────
adb logcat flutter:V *:S

# ── API calls only (requests and responses) ──────────────────
adb logcat -s flutter:V | grep -E "──►|◄──|✗✗✗|REQUEST|RESPONSE|FAILURE"

# ── Errors only ───────────────────────────────────────────────
adb logcat -s flutter:V AndroidRuntime:E | grep -v "^---"

# ── Filter to specific feature ────────────────────────────────
adb logcat -s flutter:V | grep "\[Chat\]"
adb logcat -s flutter:V | grep "\[Upload\]"
adb logcat -s flutter:V | grep "\[Quiz\]"

# ── Clear logcat before reproducing an issue ─────────────────
adb logcat -c && adb logcat -s flutter:V

# ── Save to file for sharing ──────────────────────────────────
adb logcat -s flutter:V > /tmp/pally_logcat_$(date +%Y%m%d_%H%M%S).txt &
# (then reproduce the issue, then kill the background job)
```

---

## READING BACKEND LOGS

```bash
# ── Live backend log (follow mode) ───────────────────────────
tail -f /tmp/backend.log

# ── Filter to API calls only ──────────────────────────────────
tail -f /tmp/backend.log | grep -E "──►|◄──|\[Claude-|\[Pally"

# ── Filter to errors only ─────────────────────────────────────
tail -f /tmp/backend.log | grep -E "ERROR|WARN|Exception|Caused by" | grep -v "org.apache"

# ── SQL queries (must have org.hibernate.SQL=DEBUG in config) ─
tail -f /tmp/backend.log | grep "Hibernate:\|binding parameter"

# ── Claude API calls specifically ─────────────────────────────
tail -f /tmp/backend.log | grep "\[Claude-"

# ── All 4xx and 5xx responses ─────────────────────────────────
tail -f /tmp/backend.log | grep -E "◄── [45][0-9]{2}"

# ── If using Docker ───────────────────────────────────────────
docker logs -f pally-backend 2>&1 | grep -E "──►|◄──|ERROR|Claude"
```

---

## WHAT EVERY LOG LINE MUST SHOW

### Flutter (Logcat) — required fields per API call

```
[PallyAPI] ──► REQUEST
  Method : POST
  URL    : https://pallybackend-production.up.railway.app/api/v1/avatars/abc-123/chat
  Headers: {Authorization: Bearer [REDACTED], Content-Type: application/json}
  Body   : {"message":"What is 2+2?","wikiPageIds":[]}

[PallyAPI] ◄── RESPONSE
  Status : 200 OK
  URL    : https://pallybackend-production.up.railway.app/api/v1/avatars/abc-123/chat
  Body   : {"data":{"text":"2 + 2 = 4 🎉",...}}

[PallyAPI] ✗✗✗ FAILURE
  Method : POST
  CONNECTION TIMEOUT — backend unreachable or too slow
  Tried  : https://pallybackend-production.up.railway.app/api/v1/avatars/abc-123/chat
  Timeout: 15s
  Fix    : Check backend is running on correct host:port
```

### Backend (Spring log) — required fields per request

```
00:28:16.414 [http-nio-8080-exec-1] INFO  c.p.s.l.PallyRequestLoggingFilter
  [a1b2c3d4] ──► POST /api/v1/avatars/abc-123/chat | user=user-456 | ip=<railway-proxy>

00:28:16.890 [http-nio-8080-exec-1] INFO  c.p.s.l.PallyRequestLoggingFilter
  [a1b2c3d4] ◄── 200 /api/v1/avatars/abc-123/chat 476ms

00:28:16.100 [http-nio-8080-exec-2] INFO  c.p.i.ai.ClaudeApiClient
  [Claude-x9y8z7] REQUEST model=claude-sonnet-4-6 maxTokens=1024 promptChars=1843

00:28:17.640 [http-nio-8080-exec-2] INFO  c.p.i.ai.ClaudeApiClient
  [Claude-x9y8z7] RESPONSE 1540ms responseChars=312
```

---

## COMMON ERROR PATTERNS — WHAT TO LOOK FOR AND FIX

### Pattern 1 — Connection timeout

**Flutter Logcat:**
```
[PallyAPI] ✗✗✗ FAILURE
  CONNECTION TIMEOUT — backend unreachable or too slow
  Tried  : https://pallybackend-production.up.railway.app/api/v1/...
  Fix    : Check remote host is up
```

**Diagnosis:**
1. Check Railway health: `curl -sf https://pallybackend-production.up.railway.app/actuator/health`
2. If DOWN: check Railway dashboard for deploy failures.
3. If UP but app still times out: check device WiFi / mobile data connectivity.

---

### Pattern 2 — 401 Unauthorized

**Flutter Logcat:**
```
[PallyAPI] ✗✗✗ FAILURE
  BAD RESPONSE
  Status : 401 Unauthorized
  URL    : .../api/v1/avatars
  Body   : {"error":"JWT token expired or invalid"}
```

**Fix:**
- Token expired → trigger re-login flow
- Token not being sent → check `_PallyAuthInterceptor` is attached
- Token format wrong → must be `Bearer <token>`, not just `<token>`

---

### Pattern 3 — 500 Internal Server Error

**Backend log:**
```
ERROR c.p.s.l.PallyRequestLoggingFilter
  [req-id] ◄── 500 /api/v1/avatars/abc/chat 203ms
  {"error":"Internal server error"}

ERROR c.p.a.c.ChatController - Unhandled exception in chat stream
  java.lang.NullPointerException: Cannot invoke String.length() because wiki content is null
    at com.pally.infrastructure.ai.ClaudeChatProxy.buildSystemPrompt(ClaudeChatProxy.java:87)
```

**Fix:** Read the Java stack trace in the backend log — it tells you exactly the class, method, and line number.

---

### Pattern 4 — SSE stream opens but nothing arrives (timeout on receive)

**Flutter Logcat:**
```
[PallyAPI] ✗✗✗ FAILURE
  RECEIVE TIMEOUT — backend connected but response took too long
  Timeout: 30s
  Fix    : Check for slow DB queries or Claude API latency
```

**Railway log to check:**
```bash
railway logs --tail | grep "\[Claude-"
# If you see REQUEST but no RESPONSE after 30s → Claude API is slow or CLAUDE_API_KEY is wrong
# If you see no REQUEST at all → the bug is before the Claude call (DB query, wiki loading)
```

---

### Pattern 5 — App compiles but crashes at startup (no API calls ever appear)

**Logcat:**
```
AndroidRuntime E FATAL EXCEPTION: main
  PallyException: CLAUDE_API_KEY is not configured
  at com.pally.app.PallyApp.<init>(PallyApp.dart:34)
```

**Fix:**
```bash
flutter run -d <device> --dart-define=API_BASE_URL=https://pallybackend-production.up.railway.app
```

---

## RULES — ALWAYS ENFORCE

- ❌ Never use `print()` or `debugPrint()` anywhere in Flutter code — use `appLog.*`
- ❌ Never catch an exception without logging it with `appLog.e(error: e, stackTrace: st)`
- ❌ Never log a raw JWT token, password, or API key — redact them in `_sanitiseHeaders`
- ❌ Never swallow a `DioException` — always let `_PallyErrorInterceptor` map it to a typed error
- ✅ Every Riverpod ViewModel must log state transitions at `appLog.d` level
- ✅ Every API call result (success AND failure) must appear in Logcat
- ✅ Every failure shown to the user must have a corresponding `appLog.e` with full stack trace
- ✅ Backend must log every request with method, path, user ID, and response time in milliseconds
- ✅ Claude API calls must log prompt character count and response time
- ✅ Use `[FeatureName]` tags in log messages so `grep` filtering works: `[Chat]`, `[Upload]`, `[Quiz]`, `[Auth]`, `[Shop]`, `[Claude-xxxx]`

---

# PART 15 — UI OVERFLOW PREVENTION RULES

> **Apply these 5 rules to every existing and future screen file. No exceptions.**

---

## Rule 1 — Spacer() safety checklist

Before using `Spacer()`, confirm the parent `Column`/`Row` has a **guaranteed bounded constraint** (e.g. inside `Expanded`, `Flexible`, or a container with explicit height). If unsure → use `SizedBox(height: AppSpacing.XX)` instead.

```dart
// ✅ SAFE — Column is the direct child of Scaffold.body, which is bounded:
Scaffold(
  body: Column(children: [
    Expanded(child: ListView(...)),
    Spacer(),   // fine — siblings are bounded
    Button(),
  ]),
)

// ❌ UNSAFE — Spacer inside a scrollable Column has no bounded height:
SingleChildScrollView(
  child: Column(children: [Spacer(), ...])
)
// ✅ FIX:
SingleChildScrollView(
  child: Column(children: [SizedBox(height: 24), ...])
)

// ❌ UNSAFE — Spacer inside a Column with no parent constraint:
Column(children: [
  Text('header'),
  Spacer(),       // no parent Expanded/Flexible → overflow on small screens
  PallyButton(),
])
// ✅ FIX — wrap content in Expanded(SingleChildScrollView), pin button:
Column(children: [
  Expanded(child: SingleChildScrollView(child: Column(children: [
    Text('header'),
    // ... scrollable content ...
    SizedBox(height: AppSpacing.md),
  ]))),
  PallyButton(),
  SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
])
```

**Exception:** `Spacer()` inside a `Row` is always safe — it pushes items apart horizontally.

---

## Rule 2 — ClipRRect wrapping fixed-height containers

`ClipRRect` around a `Container(height: N)` inside a scroll view can cause a "sliced header" visual glitch. Move `borderRadius` to `BoxDecoration` on the container and remove the `ClipRRect` wrapper.

```dart
// ❌ BAD — ClipRRect wrapping a fixed-height container:
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Container(height: 300, decoration: BoxDecoration(gradient: ...)),
)

// ✅ GOOD — borderRadius on BoxDecoration directly:
Container(
  height: MediaQuery.of(context).size.height * 0.35,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: ...,
  ),
)
```

**Exception:** `ClipRRect` wrapping a `LinearProgressIndicator` or `Image` to round its edges is valid — keep it.

---

## Rule 3 — Dialog responsive width

Dialogs must **never** use a fixed width that could exceed `(screenWidth - 48)`. Always constrain:

```dart
final maxW = (MediaQuery.of(context).size.width - 48).clamp(0.0, 346.0);
return Dialog(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxW),
    child: Padding(...),
  ),
);
```

---

## Rule 4 — resizeToAvoidBottomInset on form Scaffolds

Every `Scaffold` containing a `TextField` must set `resizeToAvoidBottomInset`:
- `true` (default) — if the screen is a simple form. The system resizes the body to avoid the keyboard.
- `false` — **only** if the screen manually handles keyboard insets (e.g. `AnimatedContainer` with `MediaQuery.of(context).viewInsets.bottom`, like `ChatScreen`). In this case, content above the input must be inside `SingleChildScrollView` or `Expanded`.

```bash
# Audit command — find Scaffolds missing the declaration:
grep -rn "Scaffold(" lib/features/ --include="*.dart" -A 3 | grep -B 1 "resizeToAvoidBottomInset"
```

---

## Rule 5 — SafeArea placement

`SafeArea` must be a **direct child of `Scaffold.body`**, never nested inside a `Stack` inside a `SingleChildScrollView`. Nesting causes double top padding on notched devices.

```dart
// ❌ BAD:
Scaffold(body: SingleChildScrollView(child: Stack(children: [SafeArea(...)])))

// ✅ GOOD:
Scaffold(body: SafeArea(child: SingleChildScrollView(...)))
```

---

## Rule 6 — Fixed pixel heights for bottom sheets

Bottom sheets must use `MediaQuery`-based heights, not hardcoded pixel values, to prevent overflow on short screens:

```dart
// ❌ BAD:
Container(height: 434, ...)

// ✅ GOOD:
final sheetHeight = (MediaQuery.of(context).size.height * 0.55).clamp(360.0, 480.0);
Container(height: sheetHeight, ...)
```

---

## Rule 7 — Every Text inside a Row must have maxLines + overflow

A `Text` widget inside a `Row` must always declare `maxLines` and `overflow` unless the Row is inside a horizontal `SingleChildScrollView`.

```dart
// ❌ NEVER — "Physical Education" overflows by 24px
Row(children: [Text(avatar.name), SubjectBadge(avatar.subject)])

// ✅ CORRECT — name shrinks, badge stays readable
Row(children: [
  Flexible(child: Text(avatar.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
  SubjectBadge(avatar.subject),
])
```

**Badge/pill widgets** (Container wrapping a short Text) must also declare `constraints: BoxConstraints(maxWidth: N)` (80–140px for subject badges), plus `maxLines: 1` and `overflow: TextOverflow.ellipsis` on the inner Text.

---

## Rule 8 — Row with spaceBetween needs Flexible on the growing child

```dart
// ❌ NEVER
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [Text(longSubjectName), Text('94%')],
)

// ✅ CORRECT
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Flexible(child: Text(longSubjectName, maxLines: 1, overflow: TextOverflow.ellipsis)),
    const SizedBox(width: 8),
    Text('94%'),
  ],
)
```

---

## Rule 9 — Container pill/badge/chip inside a Row needs maxWidth

A `Container` with a dynamic `Text` child inside a `Row` will expand to fit the text. If the text is user input, an API response, or any unknown value, it WILL overflow on long inputs.

```dart
// ❌ OVERFLOW — pill expands with long answer, pushes Row past screen edge
Row(children: [
  Expanded(child: Text(title)),
  Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: Text(dynamicText),  // "= Sunlight, water, carbon dioxide…"
  ),
])

// ✅ SAFE — pill bounded, text ellipses
Row(children: [
  Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
  Flexible(
    flex: 0,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      constraints: BoxConstraints(maxWidth: 140), // ← REQUIRED
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Text(
        dynamicText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // ← REQUIRED
      ),
    ),
  ),
])
```

**Reasonable maxWidth values:**
- Answer/result pill: `140`
- Subject badge: `120`
- File name pill: `160`
- Status badge (1–2 words): `80`
- XP/score pill: `100`

---

## Rule 10 — Never use raw `Dialog()` with a button Row — use `PallyDialog` or `AlertDialog`

Flutter's `Dialog` has `insetPadding: EdgeInsets.symmetric(horizontal: 40)` by default — 40px per side, NOT 24px. A `Row` with two buttons inside a `Dialog` with `Padding(24)` leaves only `360 - 80 - 48 = 232px` on a 360px phone, which overflows by sub-pixel amounts (the infamous 0.451px error).

```dart
// ❌ OVERFLOWS on 360px phones — Dialog default insetPadding is 40px
Dialog(
  child: Padding(
    padding: EdgeInsets.all(24),
    child: Row(
      children: [
        Expanded(child: OutlinedButton(child: Text('Cancel'))),
        SizedBox(width: 8),
        Expanded(child: FilledButton(child: Text('Confirm'))),
      ],
    ),
  ),
)

// ✅ OPTION A — AlertDialog (handles button overflow via OverflowBar)
AlertDialog(
  title: Text('Title'),
  content: Text('Body'),
  actions: [
    TextButton(onPressed: ..., child: Text('Cancel')),
    FilledButton(onPressed: ..., child: Text('Confirm')),
  ],
)

// ✅ OPTION B — PallyDialog wrapper (explicit insetPadding + LayoutBuilder)
PallyDialog(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Title'),
      Text('Body'),
      PallyDialog.buttonRow(
        secondary: PallyButton(label: 'Cancel', ...),
        primary: PallyButton(label: 'Confirm', ...),
      ),
    ],
  ),
)
```

**Rules:**
1. For `title` + `content` + `actions` → use `AlertDialog` (built-in overflow handling via `OverflowBar`)
2. For custom layouts → use `PallyDialog` (not raw `Dialog`)
3. If you must use raw `Dialog`, ALWAYS set `insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24)`
4. Two-button rows must use `PallyDialog.buttonRow` (stacks vertically below 280px)
5. `AlertDialog.title` Rows must wrap text in `Flexible` to handle long titles

---

## Rule 11 — No fixed pixel widths > 150px — use Adaptive helpers

Kotlin's ConstraintLayout uses percentage constraints. Flutter has no direct equivalent — you must use `MediaQuery`, `Expanded`/`Flexible`, `LayoutBuilder`, or the `Adaptive` helper in `lib/core/ui/adaptive_layout.dart`.

```dart
// ❌ Kotlin thinking — fixed dp value, breaks on 360px phones, wastes space on tablets
Container(width: 274)

// ✅ Adaptive — percentage of screen with optional cap
Container(width: Adaptive.width(context, 0.7, max: 274))
// = 252px on 360px phone, 274px on 393px phone, 274px on tablet (capped)
```

Exceptions: decorative elements (background circles in Stack with negative offsets), and PIN-pad-like layouts that must keep exact column counts.

---

## Rule 12 — GridView must use maxCrossAxisExtent, not fixed crossAxisCount

```dart
// ❌ Fixed 2 columns — cramped on small phones, wasted on tablets
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
)

// ✅ Adaptive columns — items ≤ 200px wide, columns auto-calculate
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
)
```

On a 360px phone this gives 1–2 columns. On a tablet it gives 3–4 columns. Automatically.

Exception: PIN pads or number pads where exact column count is part of the design.

---

## Rule 13 — Image.file must always be bounded

```dart
// ❌ Image fills whatever space is available — unpredictable on different devices
Image.file(file, fit: BoxFit.cover)

// ✅ Inside a Stack(fit: StackFit.expand) — fine, intentional full-bleed
Stack(fit: StackFit.expand, children: [Image.file(file, fit: BoxFit.cover), ...])

// ✅ Bounded by AspectRatio
AspectRatio(aspectRatio: 3/4, child: Image.file(file, fit: BoxFit.cover))

// ✅ Bounded by SizedBox / ConstrainedBox
SizedBox(height: 180, child: Image.file(file, fit: BoxFit.cover))
```

---

## Quick grep audit — run before every PR

```bash
# Find potential overflow violations in lib/:
grep -rn "Spacer()\|ClipRRect\|height: [3-9][0-9][0-9]\b" lib/ \
  --include="*.dart" \
  | grep -v ".g.dart\|.freezed.dart\|//\|fontSize\|borderRadius\|blurRadius\|elevation\|strokeWidth"
```

Inspect every match. If a `Spacer()` is in a `Column` without bounded constraints, fix it. If a `ClipRRect` wraps a fixed-height container in a scroll view, refactor it. If a `height: NNN` is a hardcoded bottom sheet or dialog size, make it responsive.
