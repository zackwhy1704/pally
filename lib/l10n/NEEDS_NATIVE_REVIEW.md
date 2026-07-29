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

**DO NOT translate** (carry their own language already): Mochi's name, class names,
teacher-uploaded content, student-generated text, any AI-generated artifact.

Running count of zh keys drafted this branch: **29** (PR1: 2 — scaffolding + picker chrome; PR2: 27 — sign-in screen).
Remaining core-loop extraction (onboarding tour · sign-up form · chat · modules · quiz · library) lands in later PRs;
each appends its rows here.
