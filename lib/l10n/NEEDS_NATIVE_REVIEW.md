# zh UI strings — NEEDS NATIVE REVIEW (Singapore Chinese educator)

Every `zh` string in `app_zh.arb` is a **machine draft**. It must be reviewed by a
native Singapore Chinese educator before the Chinese UI is presented as complete
(see CLAUDE.md — half-translated UI teaches a 华文 centre the support is fake on
first contact; same reasoning as voice shipping dark).

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

**DO NOT translate** (carry their own language already): Mochi's name, class names,
teacher-uploaded content, student-generated text, any AI-generated artifact.

Running count of zh keys drafted this branch: **~256** (PR1: 2 · PR2: 27 · PR3: 23 · PR4: 15 · PR5: 22 · PR6: 21 · PR7: 21 · PR8: 26 · PR-home: ~51 · PR9: ~48 — module item bodies).
Remaining core-loop extraction (settings · sign-up form · HowPallyIsDifferent) lands in later PRs;
each appends its rows here.
