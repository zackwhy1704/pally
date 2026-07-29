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

**DO NOT translate** (carry their own language already): Mochi's name, class names,
teacher-uploaded content, student-generated text, any AI-generated artifact.

Running count of zh keys drafted this branch: **52** (PR1: 2 · PR2: 27 · PR3: 23 — onboarding tour).
Remaining core-loop extraction (onboarding tour · sign-up form · chat · modules · quiz · library) lands in later PRs;
each appends its rows here.
