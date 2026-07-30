# zh UI strings — NEEDS NATIVE REVIEW (Singapore Chinese educator)

Every `zh` string in `app_zh.arb` is a **machine draft**. It must be reviewed by a
native Singapore Chinese educator before the Chinese UI is presented as complete
(see CLAUDE.md — half-translated UI teaches a 华文 centre the support is fake on
first contact; same reasoning as voice shipping dark).

> **⚠️ COVERAGE, not scope (2026-07-29).** Branch B was once called "COMPLETE" against a
> 13-surface scope list — a human walk then found ~750 hardcoded strings. Completeness is now
> measured by `test/guard/l10n_coverage_guard_test.dart` (a shrink-only baseline of every
> hardcoded user-facing string). "Complete" = that baseline is empty. This file grows as those
> surfaces get localized. See `DEFERRED.md` for the coverage number and the per-surface PR plan.

> **🐾 MASCOT NAME (operator decision, 2026-07-29).** The mascot renders as **小伴** in Chinese.
> There is ONE source of truth: the `mascotName` key (en `Mochi` / zh `小伴`). Every user-facing
> reference resolves through it via a `{mascot}` placeholder — never a baked-in literal. Reviewers:
> if 小伴 should be a different SG term, change `mascotName`'s zh value **once** and it propagates
> everywhere. (Class names / teacher content / student text / AI artifacts are still never translated.)
> Backend-generated zh content will be aligned to 小伴 separately (a pally_backend directive line,
> pending a diff for operator sign-off) so a compiled lesson never says "Mochi" while the app says 小伴.

**Singapore conventions apply to UI copy too** (not just AI-generated content):
Simplified script, SG register — e.g. 华语 (not 中文) when naming the *spoken subject*,
巴士 (not 公交车), 德士 (not 出租车), 组屋/HDB where relevant. Flag mainlandisms.

Sign-off = a reviewer initials each row below as ✅, or edits the draft in `app_zh.arb`.

| key | en (source of truth) | zh (machine draft) | reviewer notes / ✅ |
|-----|----------------------|--------------------|---------------------|
| `language` | Language | 语言 | |
| `languagePickerSubtitle` | Choose the language for the app's buttons and menus. This does not change the language your Mochi teaches in. | 选择应用界面（按钮和菜单）显示的语言。这不会改变 Mochi 教学内容使用的语言。 | "Mochi" stays untranslated (mascot name). Confirm 界面 / 教学内容 register for parents+students. |

### PR2 — sign-in screen (auth entry)

Brand/product names kept verbatim in zh: **Apalchi**, **Mochi**, **Face ID**, **Touch ID**. Example email
`your@email.com` left as-is. Emojis (👋 ✨) kept.

| key | en (source of truth) | zh (machine draft) | reviewer notes / ✅ |
|-----|----------------------|--------------------|---------------------|
| `signInWelcomeBack` | Welcome back! 👋 | 欢迎回来！👋 | |
| `signInEmailLabel` | Email | 电子邮件 | 电子邮件 vs 邮箱 — pick house style |
| `signInPasswordLabel` | Password | 密码 | |
| `signInForgotPassword` | Forgot password? | 忘记密码？ | |
| `signInButton` | Sign In | 登录 | |
| `signInOr` | or | 或 | |
| `signInUseBiometrics` | Use Biometrics | 使用生物识别 | 生物识别 register OK for students/parents? |
| `signInFaceTouchId` | Face ID / Touch ID | Face ID / Touch ID | kept (Apple product names) |
| `signInEnableBiometricHint` | Sign in once to enable biometric login | 先登录一次即可启用生物识别登录 | |
| `signInNoAccount` | Don't have an account? | 还没有账户？ | 账户 vs 帐号 — house style |
| `signInCreateAccount` | Create Account ✨ | 创建账户 ✨ | |
| `signInBiometricReason` | Sign in to Apalchi | 登录 Apalchi | |
| `signInErrorEmptyCredentials` | Please enter your email and password | 请输入电子邮件和密码 | |
| `signInErrorBiometricsUnavailable` | Biometrics not available on this device | 此设备不支持生物识别 | 设备 (SG) OK |
| `signInErrorBiometricsNotRegistered` | Sign in with your password first — biometrics will be enabled in Settings | 请先使用密码登录 —— 生物识别可在“设置”中启用 | check 设置 matches settings screen term |
| `signInErrorPasswordFirst` | Sign in with your password first | 请先使用密码登录 | |
| `biometricScanning` | Scanning... | 扫描中…… | |
| `biometricVerified` | Verified! ✨ | 验证成功！✨ | |
| `biometricCouldntVerify` | Couldn't verify | 无法验证 | |
| `biometricScanningHint` | Place your finger or look at your camera | 请放上手指或注视摄像头 | |
| `biometricSigningIn` | Signing you in... | 正在为你登录…… | |
| `biometricNotRecognised` | Face or fingerprint not recognised | 无法识别面容或指纹 | |
| `biometricUsePassword` | Use password instead | 改用密码 | |
| `commonTryAgain` | Try Again | 重试 | |
| `commonCancel` | Cancel | 取消 | |
| `forgotPasswordTitle` | Reset Password | 重置密码 | |
| `forgotPasswordSend` | Send Reset Link | 发送重置链接 | |
| `forgotPasswordSent` | Check your email for a reset link | 请查收邮件中的重置链接 | |

### PR3 — onboarding tour (`onboarding_screen.dart`, 3-page carousel)

Kept verbatim: **Mochi** (mascot). SG conventions applied: **中三** for "Sec 3". `{current}/{total}` is an
ICU placeholder. Curly quotes “ ” kept on the thesis line.

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `onboardingPageProgress` | {current} of {total} | {current} / {total} |
| `onboardingNext` | Next → | 下一步 → |
| `onboardingLetsGo` | Let's go → | 开始吧 → |
| `onboardingPage1Title` | I learn from your material — not the whole internet. | 我学习你的材料——而不是整个互联网。 |
| `onboardingPage1Body` | Upload your notes… just to get it. | 上传你的笔记、幻灯片或课堂讲义……还是单纯想把它弄懂。 |
| `onboardingContrastOk1Title` | Your notes & slides | 你的笔记和幻灯片 |
| `onboardingContrastOk1Sub` | I learn exactly what you're covering | 我学的正是你在学的内容 |
| `onboardingContrastOk2Title` | Your lecture decks & readings | 你的课堂讲义和阅读材料 |
| `onboardingContrastOk2Sub` | Same source material, sharper answers | 同样的材料，更精准的解答 |
| `onboardingContrastBadTitle` | Random internet articles | 网上随便找的文章 |
| `onboardingContrastBadSub` | Generic info that might not match your course | 泛泛的信息，未必符合你的课程 |
| `onboardingPage2Title` | Give me one subject at a time — I go deep. | 一次给我一个科目——我会学得很深入。 |
| `onboardingPage2Body` | Make a separate Mochi… uni economics module. | 为每个科目或单元建立一个单独的 Mochi……大学的经济学单元。 |
| `onboardingFocusOkTitle` | One subject per Mochi | 每个 Mochi 专注一个科目 |
| `onboardingFocusOkSub` | Deep, accurate answers for that course | 为那门课提供深入、准确的解答 |
| `onboardingFocusBadTitle` | Everything in one Mochi | 所有内容都塞进一个 Mochi |
| `onboardingFocusBadSub` | Mixed knowledge = muddled answers | 知识混在一起 = 解答含糊不清 |
| `onboardingPage3Title` | I remember how you learn. | 我记得你是怎么学习的。 |
| `onboardingPage3Body` | When you get something wrong… the better I fit you. | 当你做错时，我会留意到……我就越适合你。 |
| `onboardingBeat1` | Tricky topics come back until they stick | 难懂的知识点会不断回来，直到你记牢 |
| `onboardingBeat2` | Easy things get spaced out — no time wasted | 简单的内容会拉开复习间隔——不浪费时间 |
| `onboardingBeat3` | The more you study, the better it fits you | 你学得越多，它就越适合你 |
| `onboardingThesis` | "Not a generic AI — a Mochi that knows your notes." | “不是一个普通的 AI——而是一个懂你笔记的 Mochi。” |

### PR4 — library (home hub `library_screen.dart`)

Mochi kept verbatim. Two real ICU plurals (en 1-vs-N; zh `other`-only). `{name}` = Mochi/class name (not translated).

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `libraryTitle` | Library | 学习库 |
| `libraryMyClasses` | My classes | 我的班级 |
| `libraryLeave` | Leave | 退出 |
| `libraryDelete` | Delete | 删除 |
| `libraryAvatarDeleted` | {name} deleted | 已删除 {name} |
| `libraryDeleteFailed` | Delete failed. Try again. | 删除失败，请重试。 |
| `libraryLeaveClassTitle` | Leave this class? | 退出这个班级？ |
| `libraryLeaveClassBody` | You'll lose access to {name}'s materials and class Mochi… rejoin with the class code. | 你将无法再访问 {name} 的材料和班级 Mochi……用班级代码重新加入。 |
| `libraryLeftClass` | Left {name} | 已退出 {name} |
| `libraryStatusCompiling` | 📖 Mochi is reading your chapters… | 📖 Mochi 正在阅读你的章节…… |
| `libraryStatusBrainPages` | 🧠 {count} brain page(s) | 🧠 {count} 个知识页 |
| `libraryStatusBuilding` | ⏳ Building brain from {count} file(s)… | ⏳ 正在从 {count} 个文件构建大脑…… |
| `libraryStatusNoNotes` | 📂 No notes yet — teach me your material! | 📂 还没有笔记——教我你的材料吧！ |
| `libraryEmptyTitle` | No Mochis yet | 还没有 Mochi |
| `libraryEmptySubtitle` | Create a Mochi from the Home tab to see it here. | 在“主页”标签创建一个 Mochi，就会显示在这里。 |

Reuse note: the library "Cancel" button uses the existing `commonCancel` key (from PR2), not a new one.

### PR5 — avatar hub (`avatar_hub_screen.dart`, per-Mochi front door)

Mochi kept. ICU plural on module count (en 1-vs-N; zh `other`). `·` = middle dot (U+00B7). Terms to sanity-check
with the reviewer: 单元 (module/unit), 掌握度 (mastery), 证明掌握 (Prove it), 小测 (Quiz).

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `hubLearn` | Learn | 学习 |
| `hubModulesSubtitle` | {count} module(s) · {mastery}% mastery | {count} 个单元 · 掌握度 {mastery}% |
| `hubStartFirstModule` | Start your first module | 开始你的第一个单元 |
| `hubSectionPractice` | Practice | 练习 |
| `hubSectionProveIt` | Prove it | 证明掌握 |
| `hubSectionTools` | Tools | 工具 |
| `hubCards` / `hubCardsSubtitle` | Cards / Quick recall practice | 卡片 / 快速记忆练习 |
| `hubTeach` / `hubTeachSubtitle` | Teach / Explain it back to Mochi | 讲解 / 把学到的讲给 Mochi 听 |
| `hubChat` / `hubChatSubtitle` | Chat / Ask Mochi anything | 聊天 / 有问题都可以问 Mochi |
| `hubNotes` / `hubNotesSubtitle` | Notes / Review your material | 笔记 / 复习你的材料 |
| `hubUpload` / `hubUploadSubtitle` | Upload / Add more material | 上传 / 添加更多材料 |
| `hubClassBadge` | Class | 班级 |
| `hubUploadNotesCta` | Upload your notes to unlock quizzes, cards and teaching. | 上传你的笔记，解锁小测、卡片和讲解练习。 |
| `hubQuiz` | Quiz | 小测 |
| `hubQuizSubtitleDefault` | Test yourself with MCQs | 用选择题考考自己 |
| `hubQuizSubtitleDoneToday` | Done today · free play anytime | 今天已完成 · 随时可自由练习 |
| `hubQuizSubtitleMastered` | Test yourself · {mastered}/{total} mastered | 考考自己 · 已掌握 {mastered}/{total} |

### PR6 — chat (highest-traffic student surface)

Mochi kept. ICU plural on the daily-cap counter (en 1-vs-N; zh `other`). Reuses `libraryEmptyTitle`,
`libraryAvatarDeleted`, `libraryDeleteFailed` + 2 new common keys (`commonLoading`, `commonSomethingWrong`).
Note: chat MESSAGES are AI-generated (already language-tagged) — only chrome is localized here.

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `commonLoading` | Loading… | 加载中…… |
| `commonSomethingWrong` | Something went wrong. | 出错了。 |
| `chatCouldNotLoadMochis` | Could not load Mochis. | 无法加载 Mochi。 |
| `chatCreateMochiFirst` | Create a Mochi from the Home tab first. | 请先在“主页”标签创建一个 Mochi。 |
| `chatCentreCuratedOnly` | Centre-curated answers only | 仅提供机构精选的解答 |
| `chatMenuTeach` / `chatMenuAddKnowledge` / `chatMenuDelete` | Teach Mochi / Add knowledge / Delete Mochi | 教一教 Mochi / 添加知识 / 删除 Mochi |
| `chatLostTrain` | Hmm, I lost my train of thought. Ask me again! | 嗯，我刚才走神了。再问我一次吧！ |
| `chatNotSynced` | Not synced — tap to retry | 未同步——点按重试 |
| `chatSending` | Sending… | 发送中…… |
| `chatDailyDone` | Daily chats done — come back tomorrow or go Premium. | 今天的聊天次数用完了——明天再来，或升级 Premium。 |
| `chatMessagesLeftToday` | {count} message(s) left today | 今天还剩 {count} 条消息 |
| `chatInputHint` / `chatInputHintWait` | Ask anything… / Please wait… | 问我任何问题…… / 请稍候…… |
| `chatSnap` | Snap | 拍照 |
| `chatEmptyTitle` / `chatEmptySubtitle` | Start the conversation! / Ask your Mochi anything, or tap 📷… | 开始聊天吧！ / 有问题都可以问 Mochi，或点按 📷… |
| `chatDisclaimer` | Mochi can make mistakes — always double-check your work! | Mochi 也可能会出错——请务必核对你的作业！ |
| `chatDoubleCheckNumbers` | Double-check the numbers against your worksheet | 请对照你的练习纸核对数字 |
| `chatCheckedWithCalculator` | checked with calculator | 已用计算器核对 |

### PR7 — module SCREENS (list + player shell; item bodies deferred — see handoff)

Mochi kept. Stage labels LEARN/TEST/PROVE/COMPLETE → 学习/测验/证明/已完成 (pedagogical, review the register).
Reuses `commonTryAgain` (PR2) + new `commonCheckConnection`. SCOPE: the module-list + player CHROME only;
the LEARN/TEST/PROVE item BODY widgets (hot-take/spot-mistake/challenge) are NOT localized yet.

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `commonCheckConnection` | Check your connection and try again. | 请检查网络连接后重试。 |
| `moduleHomeworkTooltip` | Homework | 作业 |
| `moduleCouldNotLoad` | Could not load modules. | 无法加载单元。 |
| `moduleNoNotesToBuild` | No notes to build lessons from yet. | 还没有可用于生成课程的笔记。 |
| `moduleBuildFailed` | Could not build lessons. Check your connection and try again. | 无法生成课程。请检查网络连接后重试。 |
| `moduleNoLessonsYet` | No lessons yet | 还没有课程 |
| `moduleGenerateFromMaterials` | Generate lessons from your class materials. | 根据你的班级材料生成课程。 |
| `moduleNotesInBuildFirst` | Your notes are in — let's build your first lesson. | 你的笔记已就绪——来生成你的第一节课吧。 |
| `moduleGenerateLessons` / `moduleBuildFirstLesson` | Generate lessons / Build my first lesson | 生成课程 / 生成我的第一节课 |
| `moduleAddNotesCta` | Add your notes and I'll build your first lesson from them. | 添加你的笔记，我会据此为你生成第一节课。 |
| `moduleStageLearn/Test/Prove/Complete` | LEARN / TEST / PROVE / COMPLETE | 学习 / 测验 / 证明 / 已完成 |
| `moduleCtaReview/StartLearning/Continue` | Review / Start learning / Continue | 复习 / 开始学习 / 继续 |
| `moduleTeacherReviewed` | Teacher-reviewed | 教师已审核 |
| `moduleRefreshing` | Mochi is refreshing this lesson — check back soon. | Mochi 正在更新这节课——请稍后再来。 |
| `moduleGoToLibrary` | Go to Library | 前往学习库 |
| `moduleUnknownStage` | Unknown stage | 未知阶段 |

### PR8 — quiz (question chrome, results, confidence, re-teach nudge)

Mochi kept. Placeholders on score/answer/weak-spot/focus/tricky-concept. Reuses `moduleCtaReview` for the
results "Review" button. Terms to sanity-check: 确信度 (confidence), 概念误解 (Misconception), 蒙对了 (Lucky guess).

| key | en | zh (machine draft) |
|-----|----|--------------------|
| `quizConfidence` | Confidence | 确信度 |
| `quizErrorRetry` | Something went wrong — try again. | 出错了——请重试。 |
| `quizFinish` / `quizNextQuestion` | Finish Quiz / Next Question | 完成小测 / 下一题 |
| `quizReviewingWeakSpot` | Reviewing your weak spot: {concept}. | 正在复习你的薄弱点：{concept}。 |
| `quizAnswerLocked` | Answer locked in — you'll see your results at the end. | 答案已锁定——你将在结束时看到结果。 |
| `quizCorrect` / `quizNotQuite` | Correct! / Not quite | 答对了！ / 还差一点 |
| `quizScoreResult` | You got {score} out of {total} correct. | 你答对了 {total} 题中的 {score} 题。 |
| `quizComplete` | Quiz Complete! | 小测完成！ |
| `quizBackToMochi` | Back to Mochi | 返回 Mochi |
| `quizAnswerLabel` | Answer: {answer} | 答案：{answer} |
| `quizHowSure` | How sure are you? | 你有多确定？ |
| `quizConfNotSure/Kinda/VerySure` | Not sure / Kinda / Very sure | 不确定 / 有点确定 / 非常确定 |
| `quizResultMastered/Misconception/LuckyGuess/KnownGap` | Mastered / Misconception / Lucky guess / Known gap | 已掌握 / 概念误解 / 蒙对了 / 已知薄弱 |
| `quizFocusNext` | Focus next: {topic} | 接下来重点：{topic} |
| `quizTrickyOne` | I noticed {display} is tricky for you — I'll bring it back soon. | 我注意到 {display} 对你来说有点难——我会很快再带你复习。 |
| `quizTrickySome` | I noticed some topics were tricky — I'll bring them back soon. | 我注意到有些内容有点难——我会很快再带你复习。 |
| `quizBuilding` | Building your quiz… | 正在生成你的小测…… |
| `quizNoQuizToday` / `quizUploadNotesCta` | No quiz today / Upload some notes so Mochi can build your first quiz! | 今天没有小测 / 上传一些笔记，Mochi 就能为你生成第一份小测！ |

### PR-home — home screen + bottom nav (`scaffold_shell` · `home_screen` · home banners)

| key | en | zh (draft) |
|-----|----|-----------|
| `navHome` / `navLibrary` / `navGroups` / `navMe` | Home / Library / Groups / Me | 主页 / 学习库 / 小组 / 我的 |
| `homeWelcomeBack` / `homeReadyToLearn` | Welcome back! 👋 / Ready to keep learning? | 欢迎回来！👋 / 准备好继续学习了吗？ |
| `homeNewMochi` | New Mochi | 新建 Mochi |
| `homeSectionMyClasses` / `homeSectionYourMochis` | MY CLASSES / YOUR MOCHIS | 我的班级 / 你的 Mochi |
| `homeLevelBadge` | ⭐ Level {level} | ⭐ 等级 {level} |
| `homeMaxLevel` / `homeXpProgress` | MAX LEVEL ⭐ / {xpInto} / {xpSpan} XP | 满级 ⭐ / {xpInto} / {xpSpan} XP |
| `homeCouldNotLoadMochis` | Could not load Mochis. Pull down to retry. | 无法加载 Mochi。下拉重试。 |
| `homeCouldNotLoadYourMochis` / `homeCheckConnectionPull` | Could not load your Mochis. / Check your connection and pull down to retry. | 无法加载你的 Mochi。 / 请检查网络连接后下拉重试。 |
| `homeConsentApprove` | Ask a grown-up to approve your account to make a Mochi. | 请让家长同意你的账户，才能创建 Mochi。 |
| `homeResendEmail` | Resend email | 重新发送邮件 |
| `homeConsentCollapsedChip` | Awaiting parental approval — tap for options | 等待家长批准——点按查看选项 |
| `homeConsentWaitingTitle` | Waiting for parental approval | 等待家长批准 |
| `homeConsentEmailSent` | A consent email was sent to {email}. AI features unlock once your parent approves. | 已向 {email} 发送同意邮件。家长批准后即可解锁 AI 功能。 |
| `homeConsentSignOut` | Sign out | 退出登录 |
| `homeManageKnowledge` | Manage knowledge | 管理知识 |
| `homeMochiLocked` | {name} is locked | {name} 已锁定 |
| `homeCouldNotActivate` | Could not activate — try again. | 无法激活——请重试。 |
| `homeActivateError` | Something went wrong — this Mochi should be active. Pull to refresh. | 出错了——这个 Mochi 应该处于激活状态。请下拉刷新。 |
| `homeActivateCapMessage` | You have {cap} active Mochi(s) on your free plan. Deactivate another Mochi first… (24h swap) | 在免费方案中，你已有 {cap} 个激活的 Mochi。请先停用另一个 Mochi…（每 24 小时更换一次） |
| `homeActivating` / `homeActivateAvatar` / `homeClose` | Activating… / Activate {name} / Close | 激活中…… / 激活 {name} / 关闭 |
| `homeNudgeFlashcards` / `homeNudgeStreak` | You have flashcards due today! / Keep your streak going! | 你今天有卡片要复习了！ / 保持你的连续学习记录！ |
| `homeReteachMessage` / `homeReteachThis` | Can we review {concept}? I keep getting it wrong / this | 我们能复习一下 {concept} 吗？我总是做错 / 这个 |
| `homeContinueLearning` | CONTINUE LEARNING | 继续学习 |
| `homeFlashcardsDue` | {count} flashcard(s) due | {count} 张卡片待复习 |
| `homeStartReview` | Start with {name} — 2-min review | 从 {name} 开始——2 分钟复习 |
| `homeAssignments` / `homeAssignmentOverdue` / `homeAssignmentDue` | ASSIGNMENTS / Overdue / Due: {date} | 作业 / 已逾期 / 截止：{date} |
| `homeAssignmentPreClass/PostClass/Revision/Custom` | Pre-class / Post-class / Revision / Custom | 课前 / 课后 / 复习 / 自定义 |
| `homeEmptyHi` / `homeEmptySetupFirst` | Hi {name}! 👋 / Let's set up your first Mochi | 你好，{name}！👋 / 来设置你的第一个 Mochi 吧 |
| `homeEmptyNoMochis` / `homeEmptyCreate` / `homeEmptyPickBuddy` | No Mochis yet! / Create your first Mochi… 🚀 / Pick a buddy, teach it your notes, ask it anything! | 还没有 Mochi！ / 创建你的第一个 Mochi… 🚀 / 挑一个伙伴，教它你的笔记，尽管问它任何问题！ |
| `homeEmptyCreateButton` / `homeEmptyHaveCode` | + Create My First Mochi ✨ / 🎟️ Have a code? Enter or scan it | + 创建我的第一个 Mochi ✨ / 🎟️ 有邀请码？输入或扫描 |
| `homeEmptyChipLearn/Ask/Earn` | 🧠 Learn from your notes / 💬 Ask any question / ⭐ Earn XP & rewards | 🧠 从你的笔记中学习 / 💬 有问必答 / ⭐ 赚取 XP 和奖励 |

### PR9 — module item BODY widgets (`learn/test/prove/complete/muddiest/self_assess_body` · `proof_chips`)

Static chrome only — item CONTENT (questions, statements, explanations, key terms, concept names,
wiki titles) is AI-generated and carries its own `content_language`; it is NOT translated.

| key | en | zh (draft) |
|-----|----|-----------|
| `moduleNext` / `moduleReadyToTest` / `moduleTimeToProve` | Next / Ready to test yourself / Time to prove you understand | 下一个 / 准备好自我检测了 / 该来证明你已经理解了 |
| `moduleCardOf` / `moduleCardFallback` | Card {cardNumber} of {total} / Card {n} | 第 {cardNumber} 张，共 {total} 张 / 第 {n} 张卡片 |
| `moduleKeyTerms` | Key terms | 关键术语 |
| `moduleComplete` / `moduleXpEarned` | Module complete! / +{xp} XP | 单元完成！ / +{xp} XP |
| `moduleYourMastery` / `moduleFocusArea` | Your mastery / Focus area | 你的掌握程度 / 重点领域 |
| `moduleReviewToImprove` | Review "{concept}" to improve your mastery. | 复习“{concept}”以提升你的掌握程度。 |
| `moduleBackToModules` | Back to modules | 返回单元列表 |
| `moduleRevisionMode` | Revision mode — fresh questions to check your progress. | 复习模式——用新题目检验你的进度。 |
| `moduleWhichHardest` / `moduleMuddiestHint` / `moduleSkip` | Which part was hardest? / Tap the one that felt the muddiest… / Skip | 哪部分最难？ / 点选你觉得最难懂的那一个…… / 跳过 |
| `moduleFromYourNotes` / `moduleComeback` | From your notes: {title} / That's a comeback — {concept} got you last time. | 来自你的笔记：{title} / 卷土重来——{concept} 上次难住了你。 |
| `moduleSubmitAllAnswers` / `moduleFocusingOn` / `moduleQuestionNumber` | Submit all answers / Focusing on {concept} — this tripped you up in the Test. / Question {number} | 提交所有答案 / 重点关注 {concept}—…… / 第 {number} 题 |
| `moduleAnswerHint` | Write your answer (1-3 sentences)... | 写下你的答案（1-3 句话）…… |
| `moduleMarkOwnAnswers` / `moduleCompareReference` | Mark your own answers / Compare what you wrote to the reference. Be honest… | 为自己的答案评分 / 把你写的和参考答案对比一下。请诚实作答…… |
| `moduleYourAnswer` / `moduleReference` / `moduleDidYouGetIt` | Your answer / Reference / Did you get it? | 你的答案 / 参考答案 / 你做对了吗？ |
| `moduleYes` / `modulePartly` / `moduleNo` | Yes / Partly / No | 对了 / 部分正确 / 不对 |
| `moduleNoItems` / `moduleTrueOrFalse` | No items / True or False? | 暂无内容 / 对还是错？ |
| `moduleAgree` / `moduleDisagree` | Agree / Disagree | 同意 / 不同意 |
| `moduleCheckingAnswer` / `moduleFeedbackUnavailable` | Checking your answer… / Answer recorded — couldn't load feedback right now. | 正在检查你的答案…… / 已记录你的答案——暂时无法加载反馈。 |
| `moduleSpotTheMistake` / `moduleSpotHint` / `moduleRevealError` | Spot the mistake / What's wrong here? Type what you spotted... / Reveal the error | 找出错误 / 这里有什么问题？写下你发现的…… / 揭示错误 |
| `moduleTheError` / `moduleCorrectSolution` / `moduleWereYouRight` | The error: / Correct solution: / Were you right? | 错误所在： / 正确解法： / 你答对了吗？ |
| `moduleChallenge` / `moduleTypeYourAnswer` / `moduleSubmit` | Challenge / Type your answer... / Submit | 挑战 / 输入你的答案…… / 提交 |
| `moduleYourAnswerColon` / `moduleExplanation` / `moduleAnswer` | Your answer: / Explanation: / Answer | 你的答案： / 解释： / 查看答案 |
| (reused) `quizCorrect` / `quizNotQuite` / `moduleCtaContinue` | Correct! / Not quite / Continue | 答对了！ / 还差一点 / 继续 |

### PR10 — settings screen (`settings_screen.dart`)

⚠️ **COMPLIANCE — read before editing the two flagged rows.** The price string exists to satisfy
App Store guideline 3.1.1 (anti-steering). It is gated in code behind `allowPriceDisplay(ref)` so it
renders ONLY where price display is permitted. When reviewing the zh:
- Keep it faithful in MEANING. It must **not** imply the user can pay outside the app, and must not add
  any purchase step or steering the English doesn't contain.
- Do **not** reword for naturalness in a way that changes the commercial meaning. Keep `US$9.99/mo`
  and `Premium` verbatim.
- The `ios_price_gate_guard_test` now follows the l10n indirection: any file that references a
  price-valued ARB key must still gate it. Don't defeat that by minting an un-gated price key.

| key | en | zh (draft) |
|-----|----|-----------|
| **`settingsKeepPremiumPrice`** 🔒COMPLIANCE | Keep Premium from US$9.99/mo | 以每月 US$9.99 起继续使用高级版 |
| **`settingsKeepPremium`** 🔒(no-price variant) | Keep Premium | 继续使用高级版 |
| `settingsTitle` | Settings | 设置 |
| `settingsSection*` (Subscription/Referral/Profile/Notifications/Security/Learning/About/Account) | Subscription / Referral / Profile / Notifications / Security / Learning / About / Account | 订阅 / 推荐 / 个人资料 / 通知 / 安全 / 学习 / 关于 / 账户 |
| `settingsDisplayName` / `settingsSave` | Display Name / Save | 显示名称 / 保存 |
| `settingsNameUpdated` / `settingsNameSaveFailed` | Name updated! / Could not save name — check your connection | 名称已更新！ / 无法保存名称——请检查你的网络连接 |
| `settingsDailyReminder` / `settingsReminderTime` | Daily quiz reminder / Reminder time | 每日小测提醒 / 提醒时间 |
| `settingsBiometricLogin` / `settingsBiometricUnavailable` | Biometric Login / Not available on this device | 生物识别登录 / 此设备不支持 |
| `settingsBiometricReason` / `settingsBiometricEnabled` / `settingsBiometricEnableFailed` / `settingsBiometricDisabled` | Verify to enable biometric login / Biometric login enabled / Could not enable biometric login / Biometric login disabled | 请验证以启用生物识别登录 / 已启用生物识别登录 / 无法启用生物识别登录 / 已停用生物识别登录 |
| `settingsLearningStyle` | Learning style | 学习风格 |
| `settingsWhyDifferent` / `settingsVersion` / `settingsAboutApalchi` | Why Apalchi is different / Version / About Apalchi | Apalchi 有何不同 / 版本 / 关于 Apalchi |
| `settingsPrivacyPolicy` / `settingsTermsOfService` / `settingsHelpSupport` / `settingsEmailUs` | Privacy Policy / Terms of Service / Help & Support / Email us | 隐私政策 / 服务条款 / 帮助与支持 / 给我们发邮件 |
| `settingsSignOut` / `settingsDeleteAccount` | Sign Out / Delete Account | 退出登录 / 删除账户 |
| `settingsSignOutTitle` / `settingsSignOutBody` | Sign Out? / You'll need to sign in again | 退出登录？ / 你需要重新登录 |
| `settingsSubLoadError` | Could not load — tap to retry | 无法加载——点按重试 |
| `settingsPremiumTrialLeft` | ⭐ Premium Trial · {days} day(s) left | ⭐ 高级版试用 · 还剩 {days} 天 |
| `settingsEndsLabel` | Ends {date} | 结束于 {date} |
| `settingsFamilyPlan` / `settingsFreePlan` | Family plan — managed by parent / Free plan | 家庭方案——由家长管理 / 免费方案 |
| `settingsPremiumManage` / `settingsFreePlanSubtitle` | Tap Manage to update billing or cancel. / Unlock unlimited Mochis, chat, and family sharing. | 点按“管理”以更新账单或取消。 / 解锁无限 Mochi、聊天和家庭共享。 |
| `settingsManage` / `settingsUpgrade` | Manage / Upgrade | 管理 / 升级 |
| `settingsManagedByParent` | Your subscription is managed by the parent account. | 你的订阅由家长账户管理。 |
| `settingsInviteFriends` / `settingsInviteFriendsSubtitle` | Invite friends / See your code, share it, track who joined. | 邀请好友 / 查看你的邀请码、分享它、追踪谁加入了。 |
| `settingsHaveReferralCode` / `settingsHaveReferralCodeSubtitle` | Have a referral code? / Enter it to reward you and the friend who sent it. | 有推荐码吗？ / 输入推荐码，奖励你和邀请你的好友。 |
| `settingsEnterReferralCode` / `settingsShareReward` | Enter referral code / Share the reward with the friend who invited you. | 输入推荐码 / 与邀请你的好友分享奖励。 |
| `settingsCodes6Chars` / `settingsCodeApplied` / `settingsApplyCode` | Codes are 6 characters / Code applied! Take a quiz to activate the reward. / Apply code | 推荐码为 6 个字符 / 推荐码已应用！完成一次小测即可激活奖励。 / 应用推荐码 |
| (reused) `commonCancel` / `commonLoading` / `language` | Cancel / Loading… / Language | 取消 / 加载中… / 语言 |

### PR11 — sign-up form (`direct_onboarding_screen.dart`, 1507 lines)

The 3-step direct-signup flow: already-signed-in interstitial, Step 1 (account + age-group +
under-13 parental consent), Step 2 (subject/level), Step 3 (upload: typed notes / photo / file,
processing states, irrelevant-upload override, ready). ~55 new zh strings.

| key group | en (sample) | zh (sample) |
|-----------|-------------|-------------|
| `signupSignedInAs` / `signupAlreadySignedIn` / `signupCreateNewAccount` / `signupLogOutContinue` | You're signed in as {name}. Log out to create a new account? / … / Create a new account? / Log out & continue | 你已以 {name} 的身份登录。要退出并创建新账户吗？ / … / 创建新账户？ / 退出并继续 |
| `signupStepOf` | Step {step} of 3 | 第 {step} 步，共 3 步 |
| `signupCreateYourAccount` / `signupStudyBuddy` | Create your account / Mochi will become your personal study buddy. | 创建你的账户 / Mochi 将成为你的专属学习伙伴。 |
| `signupFieldName` / `signupHintYourName` / `signupValidatorName` | Name / Your name / Name must be at least 2 characters | 名字 / 你的名字 / 名字至少需要 2 个字符 |
| `signupFieldEmail` / `signupValidatorEmailEmpty` / `signupValidatorEmailInvalid` | Email / Please enter your email / Please enter a valid email (e.g. you@example.com) | 电子邮箱 / 请输入你的电子邮箱 / 请输入有效的电子邮箱（例如 you@example.com） |
| `signupFieldPassword` / `signupHintPassword` / `signupValidatorPassword` | Password / At least 8 characters / Password must be at least 8 characters | 密码 / 至少 8 个字符 / 密码至少需要 8 个字符 |
| `signupAgeGroup` / `signupAge13OrOlder` / `signupAgeUnder13` | Age group / I am 13 or older / I am under 13 | 年龄段 / 我已满 13 岁 / 我未满 13 岁 |
| `signupFieldParentEmail` / `signupValidatorParentEmailEmpty` / `signupValidatorParentEmailInvalid` / `signupParentApproval` | Parent's email address / Please enter your parent's email / …valid email (e.g. parent@example.com) / We'll email your parent to approve your account before you can use AI features. | 家长的电子邮箱 / 请输入家长的电子邮箱 / …有效的电子邮箱（例如 parent@example.com） / 在你使用 AI 功能之前，我们会发邮件给你的家长以批准你的账户。 |
| `signupNext` / `signupAlreadyHaveAccount` | Next / Already have an account? Sign in | 下一步 / 已有账户？登录 |
| `signupWhatStudying` / `signupPickSubject` / `signupSubject` / `signupEducationStage` / `signupCreateAccount` | What are you studying? / Pick one subject to start with. You can add more later. / Subject / Education stage / Create account | 你在学习什么？ / 先选一个科目开始。之后可以再添加更多。 / 科目 / 教育阶段 / 创建账户 |
| `signupBookSplitChapters` / `signupPickChapters` / `signupChooseChapters` | Your book is split into chapters / Pick the chapters you want Mochi to study first. / Choose chapters | 你的书被分成了多个章节 / 选择你想让 Mochi 先学习的章节。 / 选择章节 |
| `signupAddFirstNotes` / `signupNotesInstructions` / `signupNotesHint` | Add your first notes / Type or paste your notes below. Mochi will read them… / Paste or type your notes here... | 添加你的第一份笔记 / 在下方输入或粘贴你的笔记。Mochi 会阅读它们… / 在这里粘贴或输入你的笔记…… |
| `signupCharCount` / `signupCharCountMin` | {count} chars / {count} chars (min 50) | {count} 个字符 / {count} 个字符（至少 50 个） |
| `signupAddToMochi` / `signupOr` / `signupSnapPhoto` / `signupChooseFile` / `signupUploadFailed` | Add to Mochi / or / Or snap a photo / Or choose a file / Upload failed. Please try again. | 添加到 Mochi / 或 / 或拍一张照片 / 或选择一个文件 / 上传失败。请重试。 |
| `signupHaveCode` / `signupSkipForNow` | 🎟️ Have a class or group code? Enter or scan it / Skip for now | 🎟️ 有班级或小组代码吗？输入或扫描 / 暂时跳过 |
| `signupUploading` / `signupReadingNotes` / `signupCreatingModule` / `signupWorkingOnIt` / `signupTakeMinute` | Uploading your notes... / Mochi is reading your notes... / Creating your first study module... / Working on it... / This may take a minute. | 正在上传你的笔记…… / Mochi 正在阅读你的笔记…… / 正在创建你的第一个学习单元…… / 正在处理…… / 这可能需要一分钟。 |
| `signupThisSubject` / `signupNotLikeMaterial` / `signupCouldntMatch` / `signupUseAnyway` / `signupChooseDifferentFile` | this subject / This doesn't look like {subject} material / We couldn't match it to {subject}. Use it anyway… / Use it anyway / Choose a different file | 这个科目 / 这看起来不像是{subject}的材料 / 我们无法将它与{subject}匹配。你可以照样使用它… / 照样使用 / 选择另一个文件 |
| `signupModuleReady` / `signupFirstModuleWord` / `signupMochiSetUp` / `signupModuleBuilt` / `signupStartLearning` / `signupGoToHome` | Your "{title}" module is ready! / first / Your Mochi is set up! / Mochi has read your notes and built a study module for you. / Start learning / Go to home | 你的“{title}”单元准备好了！ / 第一个 / 你的 Mochi 已设置完成！ / Mochi 已阅读你的笔记，并为你生成了一个学习单元。 / 开始学习 / 前往主页 |
| (reused) `commonCancel` | Cancel | 取消 |

**DO NOT translate** (carry their own language already): class names, teacher-uploaded content,
student-generated text, any AI-generated artifact, and a teacher's OWN free-text subject (an unknown
subject passes through the localizer untranslated). The mascot name is now localized via `mascotName`
(→ 小伴). Email-format hint examples (`your@email.com`, `parent@example.com`) are kept verbatim as
illustrations. (The subject/education-stage/plan-tier labels that were previously "left as-is" are now
localized in PR-B — see below.)

### PR12 — "What makes Apalchi different" explainer (`how_pally_is_different.dart`)

Shown once after first tutor creation and from Settings → About. 10 strings.

| key | en | zh (draft) |
|-----|----|-----------|
| `howDiffTitle` / `howDiffSubtitle` | What makes Apalchi different 🧠 / Here's what you just got — and why it matters. | Apalchi 有何不同 🧠 / 这就是你刚刚获得的——以及它为什么重要。 |
| `howDiffCard1Title` / `howDiffCard1Body` | Built from your notes / Your Mochi learns your material — … not a generic textbook. | 从你的笔记构建 / 你的 Mochi 学习你的材料——…而不是泛泛的课本。 |
| `howDiffCard2Title` / `howDiffCard2Body` | Remembers how you learn / It tracks which topics trip you up… | 记住你的学习方式 / 它会追踪哪些主题难住了你…… |
| `howDiffCard3Title` / `howDiffCard3Body` | Made for real studying / Mochis for every subject — … serious learners. | 为真正的学习而打造 / 每个科目都有 Mochi——…为认真的学习者设计的深度。 |
| `howDiffQuote` | "Not a generic tutor. A Mochi that knows yours." | “不是泛泛的导师。是懂你的 Mochi。” |
| `howDiffGotIt` | Got it — let's study! | 明白了——开始学习吧！ |

### PR-B — subject / education-stage / plan-tier labels (shared-data resolver)

The previously scoped-out shared-data labels — the "Maths → 数学" gap. Localized via a resolver
(`lib/core/i18n/label_localizer.dart`) that takes `AppLocalizations`: it maps the KNOWN enum labels
and passes an UNKNOWN free-text subject (a teacher's own words, typed in create-tutor) through
untranslated. ⚠️ **SG review**: these are the terms most likely to need a SG-classroom check —
e.g. 英文 vs 华文/母语 conventions, 综合 for "General", 语言 vs 语文.

| key | en | zh (draft) |
|-----|----|-----------|
| `subjectMaths` / `subjectScience` / `subjectEnglish` / `subjectHistory` | Maths / Science / English / History | 数学 / 科学 / 英文 / 历史 |
| `subjectCoding` / `subjectArt` / `subjectGeography` / `subjectLanguages` | Coding / Art / Geography / Languages | 编程 / 美术 / 地理 / 语言 |
| `subjectMusic` / `subjectPhysicalEducation` / `subjectHealth` / `subjectLiterature` / `subjectGeneral` | Music / Physical Education / Health / Literature / General | 音乐 / 体育 / 健康 / 文学 / 综合 |
| `levelPrimary` / `levelSecondary` / `levelHighSchool` / `levelUniversity` | Primary School / Secondary School / High School / University / Adult | 小学 / 中学 / 高中 / 大学 / 成人 |
| `levelPrimarySubtitle` … `levelUniversitySubtitle` | Ages ~6–11 / ~11–16 / ~16–18 / 18+ | 约 6–11 岁 / 约 11–16 岁 / 约 16–18 岁 / 18 岁以上 |
| `tierPremium` / `tierMax` / `tierPro` / `tierFree` / `tierFamily` / `tierTrial` / `tierCentre` | Premium / Max / Pro / Free / Family / Trial / Centre | 高级版 / Max / Pro / 免费 / 家庭 / 试用 / 中心 |

Running count of zh keys drafted this branch: **~400** (PR1–PR12 ~371 · PR-B: 28 — subject/level/tier labels).

**Branch B is ~35% coverage, IN PROGRESS** (guard-enforced; see `DEFERRED.md` for the coverage number and
the PR-C…PR-K plan). The earlier "COMPLETE" here was scope-based and wrong. Standing launch gates: this
whole file (native-SG review), the 🔒 PR10 anti-steering price copy, and the backend PERSONAL_DATA/HIGH
moderation false-positive.

### PR-C — progress / achievements / goals / streaks (63 keys)

`progress_screen`, `achievements_screen`, `daily_goal_ring`, `level_roadmap_screen`, `level_up_overlay`,
`streak_card`, `streak_milestone_overlay`. Titles, stat labels, streak/goal/milestone copy, badge names,
level-up overlays. ICU plurals: `streakDaysToNext`. Placeholders throughout (level/xp/days/pct/counts).
Reuses `settingsInviteFriends`; mascot via `{mascot}` (progressWhichMochi/progressPremiumPitch). Also
caught ternary/switch strings the coverage scanner misses (category labels, day/days units, freeze copy).
⚠️ SG review: 综合(General-subject unrelated — here it's achievement "Milestones"→里程碑), 连续记录 for
"streak", 高级版 for Premium — confirm classroom-natural.

### PR-D — study groups / join / invite (67 keys)

`group_list/detail/create`, `challenge_card`, `join_screen`, `invite_screen`, `milestone_invite_nudge`.
Group CRUD + membership, daily challenge, join-by-code/QR, invite/referral, relative-time (`timeDayAgo`
etc.), ICU plural `groupMemberCodeLine`. Reuses commonCancel/moduleSubmit/groupJoin; mascot via {mascot}.
Also fixed cta_invariant_test to resolve the join CTA per test-locale (was hardcoded 'Join').
⚠️ SG review: 学习小组 (study group), 组屋/HDB not relevant here, 二维码 (QR).

### PR-E — character shop / flashcards (48 keys)

`shop_screen` (mystery box, power-ups, streak-freeze, collection, unlock dialogs), `flashcard_screen`
(generate CTA, flip card, difficulty ratings, filters). ICU plurals `flashcardAboutPages`/`flashcardGenerateN`.
Reuses moduleAnswer, progressCharacterShop; mascot via {mascot}. Converted static-const record lists
(_items powerups, filter chips) to l-taking methods (scanner-missed strings). `flashcard_view_model`'s
'your Mochi' fallback left (VM, no context) — one baseline remnant.

### PR-G — photo-question / camera / OCR-preview (58 keys)

`camera_screen` (capture tips, content chips), `photo_preview`/`photo_review` (detect/send/retake),
`edit_questions_sheet`, `retake_confirmation_dialog`, `homework_scan_detail`, `ocr_confidence_preview`.
ICU plurals for question counts (photoQuestionCount/photoIFound/photoQuestionsFound/photoSendQuestions).
Reuses commonTryAgain; mascot via {mascot}. Fixed cta_invariant to match the send CTA by its locale-stable
' ✨' suffix and Try-Again per-locale. (upload + ocr_awareness dirs are separate follow-up PRs.)

### PR-G2 — OCR-awareness (27 keys)

`ocr_confidence_preview`, `ocr_quality_warning`, `ocr_tips_overlay`, `ocr_what_can_read`,
`ocr_diagram_warning`, and `confidence_utils` (warning-note/fix-instruction helpers, l threaded).
"What can Apalchi read", photo-tips, quality-warning, diagram/maths-detected copy. Mascot via {mascot}.

### PR-G3 — upload flow + TYPED upload errors (64 keys)

`upload_screen`, `ocr_review_screen`, `upload_tips_banner`, and the upload view-model's errors/warnings/
estimates. Architectural: the VM now returns a typed `UploadError{kind, fileName?, detail?}` (+ UploadWarningKind,
UploadEstimate); `localizedUploadError` (upload_error_localizer.dart) resolves wording at RENDER time — the
notifier never holds AppLocalizations (layering), and errors re-localize after a live locale switch.
serverMessage carries the backend's own (content_language-localized) copy verbatim. ~21 error kinds +
warnings + estimates + upload chrome. Mascot via {mascot}; reuses signupReadingNotes/signupAddToMochi/
signupNotesHint/signupCharCount/commonCancel/photoDone/photoRetakePhoto/photoTypeInstead. The scanner-missed
`_sourceTypes` dropdown (`uploadSourceTextbook`/`uploadSourceNotes`/`uploadSourceWebsite`/`uploadSourceOther`)
was FOLDED IN here (inline switch in upload_screen.dart), not deferred.

### PR-H — wiki viewer / compiled + chapters (64 `wiki*` keys)

`chapter_lock_banner`, `chapter_picker_sheet`, `wiki_compiled_screen`, `get_it_checked_sheet`,
`review_status_widgets`, `wiki_viewer_screen`. The compiled-brain surface (brain quality, quick-quiz,
view-brain, "ask {mascot} now"), the chapter picker/lock banner (choose-chapters, not-compiled plural,
compile-all count, over-limit/selected-count/select-prompt), the wiki viewer (statuses reading/failed/
off-topic, get-it-checked / share-review-link / fix-my-notes, could-not-save). ICU plurals on chapter
counts (`wikiChaptersNotCompiled`, `wikiHasntReadChapters`, `wikiChaptersOverLimit`,
`wikiChaptersSelectedCount`, `wikiCompileAll`); mascot via {mascot}. serverMessage-style backend copy
(conflict/delete dialogs) untouched — those are AI/teacher content, not chrome.

### PR-I — create-tutor flow + chat residue (44 keys)

`subject_step`, `grade_step`, `name_step`, `character_picker_step`, `create_tutor_screen` +
`create_tutor_view_model` (typed error), and the chat widget residue after PR6:
`chat_screen` (source-badge chips), `report_message_sheet`, `homework_scan_result_bubble`,
`photo_message_bubble`, `photo_processing_bubble`, `answer_card`.

The create-tutor stepper (subject/age/name/character prompts, quick-picks, mystery-box unlock),
the report-message sheet (title, blurb, 3 reason tiles, comment field, send/footer), homework-scan
result (solved-count plural, XP earned, follow-up chips, source badge), photo bubbles (questions-detected
plural, homework-photo caption), the answer-card "Show →". ICU plurals on `homeworkSolvedCount` /
`photoQuestionsDetected`; mascot via {mascot}; tutor-name via {name}. Architectural: `create_tutor_view_model`
now returns a typed `CreateTutorError{kind, detail?}` resolved by `create_tutor_error_localizer` at render
(same PR-G3 layering pattern — notifier free of AppLocalizations). Reuses `onboardingNext`/`inviteDismiss`/
`commonTryAgain`/`uploadErrNoInternet`.

DEFERRED (not string-extraction work — ledgered, NOT silently skipped):
- `chat_view_model` **system-message CONTENT** (`'Sorry, I had trouble answering that…'`, `'📷 Homework photo'`
  as a persisted message, the two consent lines) is written into the message stream and saved to the local DB +
  synced to the backend — localizing it needs a typed system-message-kind on the Message model (render the words
  in the bubble from the kind), which is a data-model change out of scope here.
- The two **consent** lines in `chat_view_model` (`'Your account is waiting for a grown-up…'`,
  `'Mochi needs your consent to chat…'`) are COMPLIANCE copy → belong to **PR-J** with the byte-faithful care.

### PR-J — 🔒 COMPLIANCE: consent + account-deletion + auth (84 keys)

**These zh renderings are LEGAL ARTIFACTS — a mistranslated consent or deletion line is what the DPIA
and the App Store / Play data-safety declarations describe. Native-SG review is a launch precondition
for this set, alongside the anti-steering price copy (PR10/PR-F). en was extracted BYTE-FAITHFULLY — no
"improving" the source while localizing.**

Files: `ai_disclosure_screen` (the AI-companies disclosure — Anthropic/Google, data-leaves-Singapore,
grown-up-looks-after-this), `consent_approved_overlay`, `parental_consent_pending_sheet` (grown-up email,
resend/cooldown, spam-folder guidance, auto-unlock), `delete_account_screen` + `delete_account_view_model`
(what-gets-deleted, 14-day grace/restore, re-auth, store-cancellation note), `restore_account_sheet`,
`complete_profile_screen` + `complete_profile_view_model` (age-gate, parent-email + approval helper).

Typed errors (PR-G3 pattern): `CompleteProfileError` + `DeleteAccountError` — VMs hold identity, screens
localize at render (`*_error_localizer`); serverMessage/authFailed carry the backend/AuthException/PallyError
copy verbatim. Shared month names + `dateFormatDMY` ({year}年{month}{day}日 for zh) localize the deletion
dates in both delete + restore. Reuses commonCancel / signInPasswordLabel / moduleCtaContinue /
homeConsentSignOut / commonTryAgain.

DELIBERATELY NOT WIRED (honest boundary — flagged for the reviewer, drafted zh below):
- The two `chat_view_model` **consent MESSAGES** are written into the persisted message stream
  (`_markStreamingMessageWithText` sets `content`), so localizing at generation-time would BAKE the
  language into saved history (the exact content_language trap). They ride the deferred typed-system-
  message-kind refactor (see PR-I ledger). Drafted zh for the native reviewer:
    • "Your account is waiting for a grown-up to approve it. Ask them to check their email."
      → "你的账户正在等待一位大人批准。请他们查看邮箱。"
    • "Mochi needs your consent to chat. Tap to give consent." (Mochi = {mascot} = 小伴)
      → "{mascot} 需要你的同意才能聊天。点击以给予同意。"
- The shared `PallyError.userMessage` network-error strings (surfaced via delete VM serverMessage
  passthrough) remain English — localizing the central error mapper is a separate cross-cutting PR.


### PR-K1 — feature-dir widget-tree strings (teach/homework/exam-prep/referral/study-plan/quiz/brain-health/assignments/centre-join/chat/learning-style/tour/voice/misc)

Brand/product names kept verbatim in zh: **Apalchi**, **Google Docs**. `{mascot}` placeholders resolve
through `mascotName` (en Mochi / zh 小伴). SG register notes: homework=功课, assignment=作业,
quiz=测验 — confirm house style.

| key | en (source of truth) | zh (machine draft) | reviewer notes / ✅ |
|-----|----------------------|--------------------|---------------------|
| `commonTryAgainSentence` | Try again | 再试一次 | |
| `teachTitle` | Teach {mascot} | 教{mascot} | |
| `teachIntro` | Pick a topic and TEACH {mascot}! Explaining is the fastest way to know you really understand. | 选一个主题来教{mascot}吧！把它讲解出来，是检验自己是否真正理解的最快方法。 | |
| `teachAboutLabel` | Teach {mascot} about | 要教{mascot}的主题 | |
| `teachHint` | Pretend {mascot} has never heard of this. Use your own words… | 假装{mascot}从来没听过这个内容，用你自己的话来解释…… | |
| `teachSubmit` | Done — show me how I did | 写好了 — 看看我教得怎么样 | |
| `teachPerfect` | You taught it all! | 你全教会了！ | |
| `teachGreat` | Great teaching! | 教得很好！ | |
| `commonXpPlus` | +{xp} XP | +{xp} XP | |
| `teachYouExplained` | You explained | 你讲到的概念 | |
| `teachMissedConcepts` | Missed concepts | 遗漏的概念 | |
| `teachMochiAsks` | {mascot} asks: {question} | {mascot}问：{question} | |
| `teachPickAnother` | Pick another | 换一个主题 | |
| `teachNoTopics` | No topics to teach yet | 还没有可以教的主题 | |
| `teachNoTopicsPersonalDesc` | Upload some notes first so {mascot} has something to learn from! | 先上传一些笔记，让{mascot}有东西可学！ | |
| `teachCouldntCheck` | {mascot} couldn't check this one | {mascot}这次没能检查你的讲解 | |
| `teachEvalFailedFallback` | Something went wrong — give it another go. | 出了点问题 — 再试一次吧。 | |
| `hwTitle` | Homework | 功课 | |
| `hwSubmit` | Submit homework | 提交功课 | |
| `hwEmptyTitle` | No homework yet | 还没有功课 | |
| `hwEmptyBody` | Submit a photo or PDF of your work and your teacher will send back feedback here. | 把你的功课拍照或以 PDF 提交，老师批改后会在这里发反馈给你。 | |
| `hwBadgeFeedbackReady` | Feedback ready | 反馈已发布 | |
| `hwBadgeRedo` | Please redo | 请重做 | |
| `hwBadgeInReview` | In review | 批改中 | |
| `hwHintReleasedBody` | Your teacher has reviewed your work — read their feedback below. | 老师已批改你的功课 — 请看下面的反馈。 | |
| `hwHintReturnedTitle` | Returned for another go | 退回重做 | |
| `hwHintReturnedBody` | Your teacher asked you to take another look and resubmit. | 老师请你再检查一遍，然后重新提交。 | |
| `hwHintInReviewBody` | Your teacher is reviewing your work. You'll see their feedback here once they share it. | 老师正在批改你的功课。反馈发布后会显示在这里。 | |
| `hwTeacherFeedback` | Teacher's feedback | 老师的反馈 | |
| `hwWhatYouSubmitted` | What you submitted | 你提交的内容 | |
| `hwFieldTitle` | Title | 标题 | |
| `hwFieldTitleHint` | e.g. Maths worksheet 3 | 例如:数学练习卷 3 | |
| `hwFieldSubject` | Subject (optional) | 科目(可不填) | |
| `hwFieldSubjectHint` | e.g. Mathematics | 例如:数学 | |
| `hwYourWork` | Your work | 你的功课 | |
| `hwSubmitting` | Submitting… | 提交中… | |
| `hwSubmitToTeacher` | Submit to teacher | 提交给老师 | |
| `hwReviewNote` | Your teacher reviews every submission before sending feedback back to you. | 老师会先审阅每一份提交，然后才把反馈发给你。 | |
| `hwChipScan` | Scan | 扫描 | |
| `hwChipPhoto` | Photo | 照片 | |
| `examPrepTitle` | Exam Prep | 备考 | |
| `examPrepLoadError` | Could not load exam prep data. | 无法加载备考数据。 | |
| `examPrepConceptMastery` | CONCEPT MASTERY | 概念掌握度 | |
| `examPrepEmptyTitle` | No exam prep data yet | 还没有备考数据 | |
| `examPrepEmptyBody` | Complete some modules first to see your concept mastery. | 先完成一些学习模块，就能看到你的概念掌握度。 | |
| `examPrepDaysUntilExam` | days until exam | 距离考试的天数 | |
| `examPrepDailyTarget` | {count, plural, one{Study 1 module/day to finish by exam} other{Study {count} modules/day to finish by exam}} | {count, plural, other{每天学习 {count} 个模块，考试前就能学完}} | |
| `examPrepSelfAssessed` | Self-assessed | 自我评估 | |
| `examPrepRedo` | Re-do | 重做 | |
| `examPrepStartRevisionError` | Could not start revision. Try again. | 无法开始复习，请再试一次。 | |
| `commonCouldNotSaveConnection` | Could not save — check your connection | 无法保存 — 请检查网络连接 | |
| `referralTitle` | Invite friends | 邀请朋友 | |
| `referralFriendsInvited` | Friends you invited | 你邀请的朋友 | |
| `referralLoadInvitesError` | Could not load your invites | 无法加载你的邀请记录 | |
| `referralYourCode` | Your invite code | 你的邀请码 | |
| `referralCodeCopied` | Code copied | 已复制邀请码 | |
| `referralShareMessage` | Try Apalchi — the AI study companion. Use my code {code} at sign-up so we both earn bonus stars when you take your first quiz. | 来试试 Apalchi — AI 学习伙伴。注册时输入我的邀请码 {code}，你完成第一次测验后，我们俩都能获得奖励星星。 | |
| `referralActivatedOfTarget` | {activated} of {target} friends activated | 已有 {activated}/{target} 位朋友激活 | |
| `referralNextTier` | Refer {count} more → +{bonus}⭐ bonus | 再邀请 {count} 位 → 额外 +{bonus}⭐ 奖励 | |
| `referralActivatedNote` | Friends count as "activated" after they complete their first quiz. | 朋友完成第一次测验后才算“激活”。 | |
| `referralEmptyInvites` | No invites yet — share your code above to get started! | 还没有邀请记录 — 分享上面的邀请码，开始吧！ | |
| `referralStatusActivated` | Activated | 已激活 | |
| `referralStatusPending` | Pending | 待激活 | |
| `studyPlanTitle` | Study Plan | 学习计划 | |
| `studyPlanTodayTasks` | Today's Tasks | 今日任务 | |
| `studyPlanAllDone` | Today's plan done! 🎉 Keep it up! | 今天的计划完成啦！🎉 继续加油！ | |
| `studyPlanComingUp` | Coming Up | 接下来 | |
| `studyPlanBubbleTitle` | Here's your plan for today! 📅 | 这是你今天的计划！📅 | |
| `studyPlanBubbleBody` | Complete all tasks to keep your streak going and earn bonus stars! | 完成所有任务，保持连胜纪录，还能赚取奖励星星！ | |
| `studyPlanMarkDone` | Done | 完成 | |
| `studyPlanStart` | Start | 开始 | |
| `studyPlanUpcoming` | Upcoming | 即将到来 | |
| `studyPlanTomorrow` | Tomorrow | 明天 | |
| `studyPlanIn2Days` | In 2 days | 后天 | |
| `studyPlanUpcomingTest` | Upcoming Test | 即将到来的测验 | |
| `studyPlanSubjectTest` | {subject} Test | {subject}测验 | |
| `studyPlanTestToday` | Today | 今天 | |
| `studyPlanDaysLeft` | {days, plural, one{1 day left} other{{days} days left}} | {days, plural, other{还剩 {days} 天}} | |
| `studyPlanSetTestDate` | Set a test date in Settings to see a countdown here. | 在设置里选一个测验日期，就能在这里看到倒计时。 | |
| `brainHealthTitle` | Brain Health 🧠 | 大脑健康 🧠 | |
| `brainHealthWikiPages` | Wiki Pages | 知识页面 | |
| `brainHealthWeakTopics` | Weak Topics | 薄弱主题 | |
| `brainHealthScore` | Brain Health Score | 大脑健康分数 | |
| `brainHealthPages` | Pages | 页面 | |
| `brainHealthVerified` | Verified | 已验证 | |
| `brainHealthAvgQuality` | Avg Quality | 平均质量 | |
| `brainHealthErrors` | {count, plural, one{1 error} other{{count} errors}} | {count, plural, other{{count} 个错误}} | |
| `quizDailyTitle` | Daily Quiz | 每日测验 | |
| `quizQuestionOf` | Question {current} of {total} | 第 {current} 题，共 {total} 题 | |
| `quizXpEarnedLong` | +{xp} XP earned | 获得 +{xp} XP | |
| `quizMasteryBreakdown` | Mastery breakdown | 掌握情况 | |
| `quizMoreItems` | +{count} more | 还有 {count} 个 | |
| `centreJoinTitle` | Join a class | 加入班级 | |
| `centreJoinEnterFull` | Enter the full class code | 请输入完整的班级代码 | |
| `centreJoinHeading` | Enter the class code | 输入班级代码 | |
| `centreJoinBody` | Ask your teacher or tuition centre for the class code on their dashboard, then type it in below. | 向你的老师或补习中心询问他们控制台上的班级代码，然后在下面输入。 | |
| `centreJoinYourClassFallback` | your class | 你的班级 | |
| `centreJoinSuccess` | Joined {className} 🎉 | 已加入{className} 🎉 | |
| `centreJoinFailed` | Could not join — check the code and try again | 无法加入 — 请检查代码后再试 | |
| `centreJoinButton` | Join class | 加入班级 | |
| `assignTitle` | Assignment | 作业 | |
| `assignPickedForYou` | Picked for you | 为你精选 | |
| `assignNotReleasedTitle` | Answers not released yet | 答案尚未发布 | |
| `assignNotReleasedBody` | Your teacher hasn't shared the model answers. You'll be able to compare here once they do. | 老师还没有公布参考答案。公布后你就可以在这里对照。 | |
| `assignReleasedBody` | Compare your answers with the model answers below. | 把你的答案和下面的参考答案对照一下吧。 | |
| `assignQuestionNumber` | Q{n} | 第{n}题 | |
| `assignYourAnswer` | Your answer | 你的答案 | |
| `assignNoAnswerRecorded` | No answer recorded | 没有记录到答案 | |
| `assignModelAnswer` | Model answer | 参考答案 | |
| `assignEvaluation` | Evaluation | 评估 | |
| `assignEmptyReleased` | No answers to compare yet | 还没有可对照的答案 | |
| `assignEmptyNotReleased` | Come back after answers are released | 等答案发布后再来吧 | |
| `learningStyleTitle` | Learning style | 学习方式 | |
| `learningStyleDefaultMode` | Default answer mode | 默认回答模式 | |
| `learningStyleBody` | Guide Me builds understanding — you figure it out, you remember more. You can switch per question with the toggle in chat. | “引导我”帮助你建立理解 — 自己想出来的，记得更牢。你也可以在聊天中用开关按题切换。 | |
| `learningStyleSaved` | Default saved! | 已保存默认设置！ | |
| `learningStyleRecommended` | RECOMMENDED | 推荐 | |
| `learningStyleGuideDesc` | {mascot} guides you to the answer — builds real retention. | {mascot}会引导你找到答案 — 建立真正的记忆。 | |
| `learningStyleAnswerDesc` | {mascot} gives the worked solution — great for checking your work. | {mascot}直接给出完整解答 — 适合用来检查你的功课。 | |
| `chatModeGuideMe` | Guide Me | 引导我 | |
| `chatModeJustAnswer` | Just answer | 直接给答案 | |
| `chatModeTwoWays` | Two ways to learn 🎓 | 两种学习方式 🎓 | |
| `chatModeSwitchAnyTime` | You can switch any time with the toggle above the chat. | 你随时可以用聊天上方的开关切换。 | |
| `chatModeGuideDesc` | {mascot} asks you guiding questions — you figure it out yourself. What you discover, you remember. | {mascot}会用问题一步步引导你 — 答案由你自己想出来。自己发现的，记得最牢。 | |
| `chatModeAnswerDesc` | {mascot} gives you the worked solution directly. Great for checking your work — but you'll remember less. | {mascot}会直接给你完整解答。适合检查功课 — 但你记住的会比较少。 | |
| `chatModeDefaultGuide` | Default: Guide Me | 默认：引导我 | |
| `chatModeGotIt` | Got it — let's learn! | 明白了 — 开始学习吧！ | |
| `chatCoachTapToggle` | Tap the toggle to switch how {mascot} helps you. | 点一下开关，切换{mascot}帮助你的方式。 | |
| `chatAnswerNudge` | Full answer coming up — try Guide Me sometimes, you'll remember more. | 完整答案马上来 — 偶尔试试“引导我”，你会记得更牢。 | |
| `chatEscapeGreatEffort` | Great effort! Here's the answer | 很努力了！这是答案 | |
| `chatEscapeAddedPractice` | Added "{topic}" to your practice list | 已把“{topic}”加入你的练习清单 | |
| `chatHints` | Hints:  | 提示： | |
| `chatAnswerReady` | — answer ready | — 可以看答案了 | |
| `chatReported` | Reported | 已举报 | |
| `chatTabTitle` | Chat | 聊天 | |
| `reportThanks` | Thanks — we'll take a look | 谢谢 — 我们会尽快查看 | |
| `reportDoneButton` | Done | 完成 | |
| `commonRetry` | Retry | 重试 | |
| `centreBlockTitle` | This is a Centre account | 这是机构账户 | |
| `centreBlockBody` | The Apalchi app is for students only. Centre teachers and owners manage their classes at apalchi.com. | Apalchi 应用只供学生使用。机构老师和管理者请到 apalchi.com 管理班级。 | |
| `centreBlockLoginWeb` | Log in at apalchi.com | 到 apalchi.com 登录 | |
| `centreBlockBackToSignIn` | Back to Sign In | 返回登录 | |
| `avatarPickerCreateError` | Could not create {mascot} — {message} | 无法创建{mascot} — {message} | |
| `avatarPickerTitle` | Choose Your {mascot} ✨ | 选择你的{mascot} ✨ | |
| `avatarPickerSubtitle` | Each one is unique 🍡 Pick who you want to learn with! | 每一只都独一无二 🍡 选一个和你一起学习的伙伴吧！ | |
| `collectionTitle` | Collection | 收藏 | |
| `collectionAlbumTitle` | {mascot} Album | {mascot}图鉴 | |
| `createTutorWishHelp` | WHAT DO YOU WISH {mascot} TO HELP YOU WITH? | 你希望{mascot}帮你学什么？ | |
| `groupCodeHint` | e.g. AB23CD | 例如：AB23CD | |
| `joinCodeHint` | e.g. 5K7Q2X | 例如：5K7Q2X | |
| `moduleListTitle` | Modules | 学习模块 | |
| `uploadTypedNotesTip` | Typed notes give the best results. Paste from Google Docs or type from your textbook. | 输入文字笔记效果最好。可以从 Google Docs 粘贴，或照着课本输入。 | |
| `uploadSplitLongNotesTip` | Consider splitting long notes into separate uploads for better accuracy. | 较长的笔记建议分成几次上传，准确度会更高。 | |
| `voiceTalkTo` | Talk to {mascot} | 和{mascot}说话 | |
| `voiceExplainer` | {mascot} uses your phone's speech recognition to turn talking into text — your voice isn't saved. | {mascot}使用你手机的语音识别功能，把说话转成文字 — 你的语音不会被保存。 | |
| `voiceMicNeeded` | Microphone access needed | 需要麦克风权限 | |
| `voiceMicGuidance` | To talk to {mascot}, turn on microphone access in Settings. You can still type your answer. | 要和{mascot}说话，请在设置里开启麦克风权限。你也可以继续用打字的方式回答。 | |
| `voiceNotNow` | Not now | 暂时不要 | |
| `voiceOpenSettings` | Open Settings | 打开设置 | |
| `weaknessImproved` | You improved on {topics}! 📈 | 你在{topics}上进步了！📈 | |
| `weaknessFocusOn` | Let's focus on | 一起来攻克 | |
| `weaknessHelpPractise` | {mascot} will help you practise these. | {mascot}会帮你练习这些内容。 | |
| `tourStep1Title` | Hi, I'm {mascot}! | 嗨，我是{mascot}！ | |
| `tourStep1Body` | Let me show you 4 quick things that make Apalchi different from any other study app. | 让我快速给你看 4 个 Apalchi 和其他学习应用不一样的地方。 | |
| `tourStep2Title` | A {mascot} for every subject | 每个科目都有自己的{mascot} | |
| `tourStep2Body` | Create one {mascot} per subject — each one learns only YOUR notes, so every answer matches exactly what your teacher taught. | 每个科目创建一个{mascot} — 它只学习你自己的笔记，所以每个回答都和老师教的完全一致。 | |
| `tourStep3Title` | Learn it. Test it. Prove it. | 学会它。测试它。证明它。 | |
| `tourStep3Body` | Every topic becomes a mini-mission: quick cards to learn, hot-takes to test yourself, and a challenge to prove it — what you get wrong, I bring back until it sticks. | 每个主题都是一个小任务：用卡片快速学习，用快问快答自测，再用挑战来证明 — 做错的部分，我会反复帮你复习，直到真正记牢。 | |
| `tourStep4Title` | I remember what you find hard | 我记得你觉得难的地方 | |
| `tourStep4Body` | The Library tracks your mastery by topic. When you get something wrong, I bring it back — spaced and scheduled — until it sticks. | 书库会按主题记录你的掌握度。做错的内容，我会按计划间隔安排复习，直到你真正掌握。 | |
| `tourStep5Title` | Not a generic AI — a {mascot} that knows yours. | 不是通用 AI — 是懂你笔记的{mascot}。 | |
| `tourStep5Body` | Upload your notes and every answer, quiz, and challenge comes from what YOUR teacher taught. | 上传你的笔记，每个回答、测验和挑战都来自你老师教的内容。 | |
| `tourStep5Cta` | Start | 开始 | |
| `tourBack` | ← Back | ← 返回 | |
| `tourDone` | Done! | 完成！ | |
| `tourShowMe` | Show me! | 带我看看！ | |
| `tourNext` | Next → | 下一步 → | |
| `tourSkip` | Skip | 跳过 | |
| `moduleStageTitleLearn` | Learn | 学习 | |
| `moduleStageTitleTest` | Test | 测试 | |
| `moduleStageTitleProve` | Prove | 挑战 | |
| `moduleStageTitleComplete` | Complete | 完成 | |
| `forceUpdateTitle` | Time to update! | 该更新啦！ | |
| `forceUpdateBody` | A newer version of Apalchi is ready with important improvements. Please update to keep learning. | 新版 Apalchi 已经准备好，包含重要改进。请更新后继续学习。 | |
| `forceUpdateCta` | Update now | 立即更新 | |
| `uploadLargeFileSizeLabel` | large file | 大文件 | |


### PR-K2 — 🔒 consent-gate sheet + API-client toasts (parental-approval compliance surface)

**🔒 CONSENT-FAMILY.** These strings gate a child's access pending parental approval — same
compliance handling as the PR-J consent set: en extracted byte-faithfully; every zh draft below
requires native-SG review as a launch precondition. Layering: the API client now passes only the
typed reason CODE — the sheet (features/consent) localizes at render; the masked-email fallback
("your grown-up") resolves INSIDE the pending sheet, never pre-rendered by a context-less caller.

| key | en (source of truth) | zh (machine draft) | reviewer notes / ✅ |
|-----|----------------------|--------------------|---------------------|
| `consentGateAlmostThere` | Almost there! | 就快好了！ | |
| `consentGateBody` | {feature} unlocks once a grown-up approves your account. We've already sent them an email — or tap below to send a reminder. | 等大人批准你的账户后，就能使用「{feature}」。我们已经发了邮件给他们 — 也可以点下面再发一次提醒。 | |
| `consentGateRemind` | Remind my grown-up | 提醒我的大人 | |
| `consentGateFeatureUpload` | Upload notes | 上传笔记 | |
| `consentGateFeatureCreateTutor` | Create your own {mascot} | 创建你自己的{mascot} | |
| `consentGateFeatureShareNote` | Share notes | 分享笔记 | |
| `consentGateFeaturePersistChat` | Save conversations | 保存对话 | |
| `consentGateFeatureEarnXp` | Earn rewards | 赚取奖励 | |
| `consentGateFeatureGeneric` | This feature | 此功能 | |
| `consentGateFinishSetup` | Let's finish setting up your account so you can start learning | 我们来完成账户设置，你就可以开始学习啦 | |
| `serverErrorRetry` | Server error ({status}) — please try again | 服务器出错（{status}）— 请再试一次 | |
| `consentPendingYourGrownUp` | your grown-up | 你的大人 | |


### PR-K3 — core/shared infra (delete-tutor + relevance dialogs, router error, notifications)

Notification copy resolves context-free via `lookupAppLocalizations(persisted locale)` — a scheduled
notification keeps the language it was scheduled in until the next idempotent reschedule. `{mascot}`
via `mascotName`. Module item-count chips localize the closed backend set (learn/test/prove).

| key | en (source of truth) | zh (machine draft) | reviewer notes / ✅ |
|-----|----------------------|--------------------|---------------------|
| `notifQuizTitle` | Quiz time! | 测验时间到！ | |
| `notifQuizBody` | Your daily quiz is waiting — earn XP and keep your streak! | 你的每日测验在等你 — 赚取 XP，保持连胜！ | |
| `notifQuizChannelName` | Daily Quiz Reminder | 每日测验提醒 | |
| `notifQuizChannelDesc` | Reminds you to take your daily quiz | 提醒你完成每日测验 | |
| `notifSrsTitle` | {count, plural, one{1 card due for {name}} other{{count} cards due for {name}}} | {count, plural, other{{name}的 {count} 张卡片到期了}} | |
| `notifSrsBodyOverdue` | Quick 2-min review to lock it in your memory 📚 | 花 2 分钟快速复习，把知识牢牢记住 📚 | |
| `notifSrsBody` | Spaced repetition works best when you keep the streak 💪 | 坚持间隔复习，效果最好 💪 | |
| `notifSrsChannelName` | Flashcard reviews | 卡片复习 | |
| `notifSrsChannelDesc` | Reminds you when spaced-repetition flashcards are due | 在间隔复习卡片到期时提醒你 | |
| `notifYourMascot` | your {mascot} | 你的{mascot} | |
| `deleteTutorTitle` | Delete {name}? | 要删除{name}吗？ | |
| `deleteTutorBody` | This permanently deletes this tutor and all their knowledge, chat history, and quiz progress. This cannot be undone. | 这会永久删除这位导师及其所有知识、聊天记录和测验进度。此操作无法撤销。 | |
| `deleteTutorKnowledgePages` | Knowledge pages | 知识页面 | |
| `deleteTutorChatMessages` | Chat messages | 聊天记录 | |
| `deleteTutorQuizProgress` | Quiz progress | 测验进度 | |
| `deleteTutorAllDeleted` | All will be deleted | 将全部删除 | |
| `deleteTutorAllLost` | All will be lost | 将全部丢失 | |
| `deleteTutorKeep` | Keep Tutor | 保留导师 | |
| `deleteTutorDelete` | Delete | 删除 | |
| `relevanceTitle` | Hmm, this might not fit! | 嗯，这份材料可能不太合适！ | |
| `relevanceBody` | This file doesn't seem to match "{subject}". Your tutor works best with notes from that subject. | 这个文件看起来和「{subject}」不太相符。导师用该科目的笔记学习，效果最好。 | |
| `relevanceGoBack` | Go Back | 返回 | |
| `relevanceAddAnyway` | Add Anyway | 仍要添加 | |
| `routerGoHome` | Go home | 回到主页 | |
| `appAsyncDefaultError` | Something went wrong. Pull down to retry. | 出了点问题。下拉即可重试。 | |
| `moduleItemsLearn` | {count} learn | 学习 {count} 项 | |
| `moduleItemsTest` | {count} test | 测试 {count} 项 | |
| `moduleItemsProve` | {count} prove | 挑战 {count} 项 | |


---

## PR-F — subscription surface (en source of truth + zh machine draft)

Total PR-F keys: 113. en byte-identical to the pre-PR source (verified). Prices stay as gated literals (not localized). {mascot}=Mochi(en)/小伴(zh).

### 🔒 TOP-PRIORITY native-compliance review (App Store 3.1.1 anti-steering)
These MUST be vetted by a native SG reviewer that the zh does NOT imply external payment or add purchase steering the en doesn't contain, BEFORE any zh flag flips.

| key | en (source of truth) | zh (machine draft) |
|-----|----------------------|--------------------|
| `subPlansHeaderFree` | Start with a 7-day free trial. Cancel anytime. | 先开始 7 天免费试用。可随时取消。 |
| `subPlansHeaderPremium` | You're on {tier}. Manage or cancel anytime on the web. | 你当前是{tier}。可随时在网页上管理或取消。 |
| `subPlansManageIntro` | Manage your plan, update your card, or cancel anytime on the Apalchi website. | 在 Apalchi 网站上管理你的方案、更新银行卡，或随时取消。 |
| `subPlansManageOnWeb` | Manage on web | 在网页上管理 |
| `subReturnTimeoutBody` | Your payment may still be processing. You can check Settings → Subscription in a minute or two. | 你的付款可能仍在处理中。你可以过一两分钟到「设置 → 订阅」查看。 |
| `webCtaContinueOnWeb` | Continue on web | 在网页上继续 |
| `webCtaDefaultIntro` | Subscriptions are managed on the Apalchi website. Sign in with the same account to upgrade — your app unlocks automatically. | 订阅在 Apalchi 网站上管理。用同一个账户登录即可升级 — 你的应用会自动解锁。 |
| `webCtaNotActiveYet` | Not active yet. Finish checkout in your browser, then tap again. | 尚未生效。请在浏览器完成结账，然后再点一次。 |

### Remaining PR-F strings (marketing / UI — standard native review)

| key | en | zh |
|-----|----|----|
| `paywallHeadAddStudent` | Need more student accounts? | 需要更多学生账户吗？ |
| `paywallHeadChat` | Out of chats for today | 今天的聊天次数已用完 |
| `paywallHeadCompile` | Compiled all your chapters | 已编译你所有的章节 |
| `paywallHeadCreateTutor` | Want more {mascot}s? | 想要更多{mascot}吗？ |
| `paywallHeadCurriculum` | Curriculum journey is premium | 课程学习路径是高级版功能 |
| `paywallHeadDefault` | Unlock Apalchi Premium | 解锁 Apalchi 高级版 |
| `paywallHeadFreeze` | Stack more streak freezes | 累积更多连胜冻结 |
| `paywallHeadGroups` | Study groups are premium | 学习小组是高级版功能 |
| `paywallHeadParent` | Parent dashboard is premium | 家长面板是高级版功能 |
| `paywallHeadUpload` | Need more uploads? | 需要上传更多吗？ |
| `paywallMaybeLater` | Maybe later | 以后再说 |
| `paywallPerk1` | Unlimited {mascot}s + uploads | 无限个{mascot} + 上传 |
| `paywallPerk2` | Unlimited daily chats | 每天无限畅聊 |
| `paywallPerk3` | Family sharing — up to 4 kids | 家庭共享 — 最多 4 个孩子 |
| `paywallPerk4` | Parent dashboard + weekly reports | 家长面板 + 每周报告 |
| `paywallPerk5` | 3 streak freezes (up from 1) | 3 个连胜冻结（原本 1 个） |
| `paywallSeePlans` | See plans | 查看方案 |
| `paywallSubAddStudent` | Family plan supports up to 4 students. Centre plan supports up to 15 students. | 家庭方案最多支持 4 名学生。中心方案最多支持 15 名学生。 |
| `paywallSubChat` | Free users get 20 chats a day. Pro lifts the cap to 100; Max and above remove it entirely. | 免费用户每天可聊 20 次。Pro 将上限提高到 100；Max 及以上则完全取消上限。 |
| `paywallSubCompile` | Big documents split into chapters so you pick what {mascot} reads. Free plans include a handful of chapter compiles a month; premium plans give you many more — reset on a rolling 30 days. | 大文件会拆分成章节，让你选择{mascot}要读哪些。免费方案每月包含少量章节编译；高级版方案则多得多 — 按滚动的 30 天重置。 |
| `paywallSubCreateTutor` | Free users get 1 {mascot}. Sign up for premium for unlimited {mascot}s so each subject gets its own {mascot}. Or, level up to level 5 to unlock your next {mascot} slot! | 免费用户可拥有 1 个{mascot}。订阅高级版即可拥有无限个{mascot}，让每个科目都有自己的{mascot}。或者升到 5 级，解锁下一个{mascot}名额！ |
| `paywallSubCurriculum` | Plan ahead with a syllabus-aware journey across every topic. | 用贴合教学大纲的学习路径，提前规划每个主题。 |
| `paywallSubDefault` | Get everything Apalchi has to offer — unlimited {mascot}s, family sharing, premium analytics. | 尽享 Apalchi 的全部功能 — 无限个{mascot}、家庭共享、高级分析。 |
| `paywallSubFreeze` | Premium lets you stack up to 3 streak freezes so a missed day never costs your streak. | 高级版让你最多累积 3 个连胜冻结，这样漏了一天也不会中断连胜。 |
| `paywallSubGroups` | Collaborate with classmates in shared study groups. Available on Pro and above. | 在共享学习小组里和同学一起学习。Pro 及以上可用。 |
| `paywallSubParent` | Parents track progress, set goals, and read weekly reports. | 家长可以追踪进度、设定目标，并查看每周报告。 |
| `paywallSubUpload` | Uploads are unlimited — free or premium. The gate is how many {mascot}s you can have. Premium gives you one per subject. | 上传次数无限 — 免费或高级版都一样。限制的是你能拥有多少个{mascot}。高级版让你每个科目都能有一个。 |
| `subPlansAnnual` | Annual  (save ~34%) | 每年 （省约 34%） |
| `subPlansBadgeExams` | Best for exams | 备考首选 |
| `subPlansBadgePopular` | Most popular | 最受欢迎 |
| `subPlansBestValue` | Best value | 最划算 |
| `subPlansCentreBanner` | ⭐ Premium via your centre | ⭐ 由你的中心提供的高级版 |
| `subPlansChooseTitle` | Choose your plan | 选择你的方案 |
| `subPlansCurrent` | Current | 当前 |
| `subPlansFamilyFeat1` | Everything in Max | Max 的全部功能 |
| `subPlansFamilyFeat2` | Up to 4 child accounts | 最多 4 个孩子账户 |
| `subPlansFamilyFeat3` | Parent dashboard | 家长面板 |
| `subPlansFamilyFeat4` | Shared star rewards | 共享星星奖励 |
| `subPlansFamilySubtitle` | Up to 4 students | 最多 4 名学生 |
| `subPlansFreeFeatures` | 20 messages/day · 1 {mascot} · basic features | 每天 20 条消息 · 1 个{mascot} · 基础功能 |
| `subPlansHeaderCentre` | Your Premium comes from your centre. Enjoy unlimited chat and {mascot}s! | 你的高级版由你的中心提供。尽情享受无限畅聊和无限个{mascot}吧！ |
| `subPlansHeaderTrial` | Your free trial ends in {days, plural, one{1 day} other{{days} days}}. Subscribe to keep all your {mascot}s. | 你的免费试用还剩 {days, plural, other{{days} 天}}。订阅即可保留你所有的{mascot}。 |
| `subPlansLoadError` | Could not load subscription info. Try again. | 无法加载订阅信息。请重试。 |
| `subPlansMaxFeat1` | Unlimited AI messages | 无限 AI 消息 |
| `subPlansMaxFeat2` | Unlimited {mascot}s | 无限个{mascot} |
| `subPlansMaxFeat3` | Sonnet model for complex questions | Sonnet 模型应对复杂问题 |
| `subPlansMaxFeat4` | All Pro features | 所有 Pro 功能 |
| `subPlansMaxSubtitle` | 1 student · smarter AI for hard problems | 1 名学生 · 更聪明的 AI，攻克难题 |
| `subPlansMonthly` | Monthly | 每月 |
| `subPlansProFeat1` | 100 AI messages / day | 每天 100 条 AI 消息 |
| `subPlansProFeat2` | Up to 5 {mascot}s | 最多 5 个{mascot} |
| `subPlansProFeat3` | Quiz & flashcards | 测验和记忆卡 |
| `subPlansProFeat4` | Homework photo scan | 功课拍照扫描 |
| `subPlansProSubtitle` | 1 student · all AI features | 1 名学生 · 全部 AI 功能 |
| `subPlansUpgradeTitle` | Upgrade Apalchi | 升级 Apalchi |
| `subPlansYourSubscription` | Your subscription | 你的订阅 |
| `subReturnBackToApalchi` | Back to Apalchi | 返回 Apalchi |
| `subReturnConfirming` | Confirming your subscription… | 正在确认你的订阅… |
| `subReturnStartExploring` | Start exploring | 开始探索 |
| `subReturnStillConfirming` | Still confirming… | 仍在确认中… |
| `subReturnSuccess` | You are premium! | 你已是高级版用户！ |
| `subReturnSuccessBody` | Everything just unlocked — unlimited {mascot}s, family sharing, parent dashboard, and more. | 一切都已解锁 — 无限个{mascot}、家庭共享、家长面板等等。 |
| `subReturnTitle` | Subscription | 订阅 |
| `trialBannerCalm` | {time} of Premium · Enjoying unlimited {mascot}s? Keep them after. | {time}的高级版 · 喜欢无限个{mascot}吗？之后也留住它们。 |
| `trialBannerUrgent` | Last day of Premium! ⏳ {time} — keep your {mascot}s. | 高级版最后一天！⏳ {time} — 记得保留你的{mascot}。 |
| `trialBannerWarning` | {time} of Premium — subscribe to keep all your {mascot}s. | {time}的高级版 — 订阅即可保留你所有的{mascot}。 |
| `trialExpiredBody` | You still have all your {mascot}s — nothing was deleted. Subscribe to keep them all, or pick one to stay free. | 你所有的{mascot}都还在 — 没有删除任何东西。订阅即可全部保留，或选一个继续免费使用。 |
| `trialExpiredContinueWith` | Continue free with {name} | 继续免费使用 {name} |
| `trialExpiredKeepAll` | ⭐ Keep all your {mascot}s | ⭐ 保留你所有的{mascot} |
| `trialExpiredOrContinue` | Or — continue free with 1 {mascot} | 或者 — 继续免费使用 1 个{mascot} |
| `trialExpiredPerks` | Unlimited {mascot}s, unlimited chat, full flashcards & quizzes. | 无限个{mascot}、无限畅聊、完整的记忆卡和测验。 |
| `trialExpiredPickBody` | Choose which {mascot} stays active. The rest are locked (🔒) but not deleted — subscribing restores them instantly. | 选择保留哪个{mascot}继续使用。其余的会被锁定（🔒）但不会删除 — 订阅后立即恢复。 |
| `trialExpiredTitle` | Your free week is up! ⏰ | 你的免费一周结束啦！⏰ |
| `trialExpiredUpTo4Kids` | up to 4 kids | 最多 4 个孩子 |
| `trialKeepPremium` | Keep Premium | 保留高级版 |
| `trialKeeperFallback` | 1 {mascot} | 1 个{mascot} |
| `trialLockChat` | 💬 Chat capped at 80/day (was unlimited) | 💬 聊天限制为每天 80 条（原本无限） |
| `trialLockMochis` | 🔒 Extra {mascot}s locked (you keep 1 free) | 🔒 额外的{mascot}被锁定（你保留 1 个免费） |
| `trialLockQuiz` | 📊 Advanced quiz & study plan limited | 📊 高级测验和学习计划受限 |
| `trialTimeDaysLeft` | {days, plural, one{1 day left} other{{days} days left}} | {days, plural, other{还剩 {days} 天}} |
| `trialTimeHoursLeft` | {hours}h left | 还剩 {hours} 小时 |
| `trialWelcomePerk1Sub` | One {mascot} for every subject you study | 每个学习科目都能有一个{mascot} |
| `trialWelcomePerk1Title` | Unlimited {mascot}s | 无限个{mascot} |
| `trialWelcomePerk2Sub` | Ask anything, any time — no daily limit | 随时想问就问 — 没有每日限制 |
| `trialWelcomePerk2Title` | Unlimited chat | 无限畅聊 |
| `trialWelcomePerk3Sub` | Every feature, zero restrictions | 所有功能，毫无限制 |
| `trialWelcomePerk3Title` | Full flashcards & quizzes | 完整的记忆卡和测验 |
| `trialWelcomeStart` | Start exploring! 🚀 | 开始探索吧！🚀 |
| `trialWelcomeSubscribeNow` | Subscribe now | 立即订阅 |
| `trialWelcomeSubtitle` | No card needed. We'll remind you before it ends. | 无需信用卡。结束前我们会提醒你。 |
| `trialWelcomeTitle` | 🎁 Premium is on us / for 7 days! | 🎁 高级版免费畅享 / 7 天！ |
| `trialWhenEnds` | When your trial ends: | 试用结束后： |
| `webCtaChecking` | Checking… | 检查中… |
| `webCtaCopied` | Copied | 已复制 |
| `webCtaCopyLink` | Copy link | 复制链接 |
| `webCtaCouldntOpenBrowser` | Couldn't open your browser. Tap “Copy link” above and paste it. | 无法打开你的浏览器。点上面的「复制链接」再粘贴。 |
| `webCtaEmailBothSent` | Sent! Check your email — we also pushed a notification with the link. | 已发送！请查收电子邮件 — 我们也推送了一条带链接的通知。 |
| `webCtaEmailError` | Couldn't send the link. Check your connection and try again. | 无法发送链接。请检查网络连接后重试。 |
| `webCtaEmailFailNow` | Couldn't send right now — copy the link above instead. | 暂时无法发送 — 请改用上面的复制链接。 |
| `webCtaEmailLink` | Email me the link | 把链接发到我的邮箱 |
| `webCtaEmailSent` | Sent! Check your email for the link. | 已发送！请到电子邮件查收链接。 |
| `webCtaPushSent` | Sent you a notification with the link. | 已给你推送一条带链接的通知。 |
| `webCtaRateLimited` | You've requested this a few times — try again in a little while. | 你已请求了几次 — 请稍后再试。 |
| `webCtaSending` | Sending… | 发送中… |
| `webCtaUpgradedRefresh` | I've upgraded — refresh | 我已升级 — 刷新 |