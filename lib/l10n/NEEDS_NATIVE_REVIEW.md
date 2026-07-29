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

**DO NOT translate** (carry their own language already): Mochi's name, class names,
teacher-uploaded content, student-generated text, any AI-generated artifact.

Running count of zh keys drafted this branch: **2** (PR1 — scaffolding + language picker chrome).
Core-loop extraction (onboarding · chat · modules · quiz · library ≈ 900 strings) lands in later PRs;
each appends its rows here.
