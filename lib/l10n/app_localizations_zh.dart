// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get mascotName => '小伴';

  @override
  String get language => '语言';

  @override
  String languagePickerSubtitle(String mascot) {
    return '选择应用界面（按钮和菜单）显示的语言。这不会改变 $mascot 教学内容使用的语言。';
  }

  @override
  String get signInWelcomeBack => '欢迎回来！👋';

  @override
  String get signInEmailLabel => '电子邮件';

  @override
  String get signInEmailHint => 'your@email.com';

  @override
  String get signInPasswordLabel => '密码';

  @override
  String get signInForgotPassword => '忘记密码？';

  @override
  String get signInButton => '登录';

  @override
  String get signInOr => '或';

  @override
  String get signInUseBiometrics => '使用生物识别';

  @override
  String get signInFaceTouchId => 'Face ID / Touch ID';

  @override
  String get signInEnableBiometricHint => '先登录一次即可启用生物识别登录';

  @override
  String get signInNoAccount => '还没有账户？';

  @override
  String get signInCreateAccount => '创建账户 ✨';

  @override
  String get signInBiometricReason => '登录 Apalchi';

  @override
  String get signInErrorEmptyCredentials => '请输入电子邮件和密码';

  @override
  String get signInErrorBiometricsUnavailable => '此设备不支持生物识别';

  @override
  String get signInErrorBiometricsNotRegistered => '请先使用密码登录 —— 生物识别可在“设置”中启用';

  @override
  String get signInErrorPasswordFirst => '请先使用密码登录';

  @override
  String get biometricScanning => '扫描中……';

  @override
  String get biometricVerified => '验证成功！✨';

  @override
  String get biometricCouldntVerify => '无法验证';

  @override
  String get biometricScanningHint => '请放上手指或注视摄像头';

  @override
  String get biometricSigningIn => '正在为你登录……';

  @override
  String get biometricNotRecognised => '无法识别面容或指纹';

  @override
  String get biometricUsePassword => '改用密码';

  @override
  String get commonTryAgain => '重试';

  @override
  String get commonCancel => '取消';

  @override
  String get forgotPasswordTitle => '重置密码';

  @override
  String get forgotPasswordSend => '发送重置链接';

  @override
  String get forgotPasswordSent => '请查收邮件中的重置链接';

  @override
  String onboardingPageProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get onboardingNext => '下一步 →';

  @override
  String get onboardingLetsGo => '开始吧 →';

  @override
  String get onboardingPage1Title => '我学习你的材料——而不是整个互联网。';

  @override
  String get onboardingPage1Body =>
      '上传你的笔记、幻灯片或课堂讲义，我就会围绕你正在学的内容打造一个专属大脑——无论是为了小测、期末考、某个单元，还是单纯想把它弄懂。';

  @override
  String get onboardingContrastOk1Title => '你的笔记和幻灯片';

  @override
  String get onboardingContrastOk1Sub => '我学的正是你在学的内容';

  @override
  String get onboardingContrastOk2Title => '你的课堂讲义和阅读材料';

  @override
  String get onboardingContrastOk2Sub => '同样的材料，更精准的解答';

  @override
  String get onboardingContrastBadTitle => '网上随便找的文章';

  @override
  String get onboardingContrastBadSub => '泛泛的信息，未必符合你的课程';

  @override
  String get onboardingPage2Title => '一次给我一个科目——我会学得很深入。';

  @override
  String onboardingPage2Body(String mascot) {
    return '为每个科目或单元建立一个单独的 $mascot。每个 $mascot 只懂它自己的内容，所以解答始终精准——无论是中三化学还是大学的经济学单元。';
  }

  @override
  String onboardingFocusOkTitle(String mascot) {
    return '每个 $mascot 专注一个科目';
  }

  @override
  String get onboardingFocusOkSub => '为那门课提供深入、准确的解答';

  @override
  String onboardingFocusBadTitle(String mascot) {
    return '所有内容都塞进一个 $mascot';
  }

  @override
  String get onboardingFocusBadSub => '知识混在一起 = 解答含糊不清';

  @override
  String get onboardingPage3Title => '我记得你是怎么学习的。';

  @override
  String get onboardingPage3Body =>
      '当你做错时，我会留意到——并且会不断把它带回来，直到你真正掌握。我们学得越多，我就越适合你。';

  @override
  String get onboardingBeat1 => '难懂的知识点会不断回来，直到你记牢';

  @override
  String get onboardingBeat2 => '简单的内容会拉开复习间隔——不浪费时间';

  @override
  String get onboardingBeat3 => '你学得越多，它就越适合你';

  @override
  String onboardingThesis(String mascot) {
    return '“不是一个普通的 AI——而是一个懂你笔记的 $mascot。”';
  }

  @override
  String get libraryTitle => '学习库';

  @override
  String get libraryMyClasses => '我的班级';

  @override
  String get libraryLeave => '退出';

  @override
  String get libraryDelete => '删除';

  @override
  String libraryAvatarDeleted(String name) {
    return '已删除 $name';
  }

  @override
  String get libraryDeleteFailed => '删除失败，请重试。';

  @override
  String get libraryLeaveClassTitle => '退出这个班级？';

  @override
  String libraryLeaveClassBody(String name, String mascot) {
    return '你将无法再访问 $name 的材料和班级 $mascot。你的个人 $mascot 会保留。你可以用班级代码重新加入。';
  }

  @override
  String libraryLeftClass(String name) {
    return '已退出 $name';
  }

  @override
  String libraryStatusCompiling(String mascot) {
    return '📖 $mascot 正在阅读你的章节……';
  }

  @override
  String libraryStatusBrainPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🧠 $count 个知识页',
    );
    return '$_temp0';
  }

  @override
  String libraryStatusBuilding(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '⏳ 正在从 $count 个文件构建大脑……',
    );
    return '$_temp0';
  }

  @override
  String get libraryStatusNoNotes => '📂 还没有笔记——教我你的材料吧！';

  @override
  String libraryEmptyTitle(String mascot) {
    return '还没有 $mascot';
  }

  @override
  String libraryEmptySubtitle(String mascot) {
    return '在“主页”标签创建一个 $mascot，就会显示在这里。';
  }

  @override
  String get hubLearn => '学习';

  @override
  String hubModulesSubtitle(int count, int mastery) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个单元 · 掌握度 $mastery%',
    );
    return '$_temp0';
  }

  @override
  String get hubStartFirstModule => '开始你的第一个单元';

  @override
  String get hubSectionPractice => '练习';

  @override
  String get hubSectionProveIt => '证明掌握';

  @override
  String get hubSectionTools => '工具';

  @override
  String get hubCards => '卡片';

  @override
  String get hubCardsSubtitle => '快速记忆练习';

  @override
  String get hubTeach => '讲解';

  @override
  String hubTeachSubtitle(String mascot) {
    return '把学到的讲给 $mascot 听';
  }

  @override
  String get hubChat => '聊天';

  @override
  String hubChatSubtitle(String mascot) {
    return '有问题都可以问 $mascot';
  }

  @override
  String get hubNotes => '笔记';

  @override
  String get hubNotesSubtitle => '复习你的材料';

  @override
  String get hubUpload => '上传';

  @override
  String get hubUploadSubtitle => '添加更多材料';

  @override
  String get hubClassBadge => '班级';

  @override
  String get hubUploadNotesCta => '上传你的笔记，解锁小测、卡片和讲解练习。';

  @override
  String get hubQuiz => '小测';

  @override
  String get hubQuizSubtitleDefault => '用选择题考考自己';

  @override
  String get hubQuizSubtitleDoneToday => '今天已完成 · 随时可自由练习';

  @override
  String hubQuizSubtitleMastered(int mastered, int total) {
    return '考考自己 · 已掌握 $mastered/$total';
  }

  @override
  String get commonLoading => '加载中……';

  @override
  String get commonSomethingWrong => '出错了。';

  @override
  String chatCouldNotLoadMochis(String mascot) {
    return '无法加载 $mascot。';
  }

  @override
  String chatCreateMochiFirst(String mascot) {
    return '请先在“主页”标签创建一个 $mascot。';
  }

  @override
  String get chatCentreCuratedOnly => '仅提供机构精选的解答';

  @override
  String chatMenuTeach(String mascot) {
    return '教一教 $mascot';
  }

  @override
  String get chatMenuAddKnowledge => '添加知识';

  @override
  String chatMenuDelete(String mascot) {
    return '删除 $mascot';
  }

  @override
  String get chatLostTrain => '嗯，我刚才走神了。再问我一次吧！';

  @override
  String get chatNotSynced => '未同步——点按重试';

  @override
  String get chatSending => '发送中……';

  @override
  String get chatDailyDone => '今天的聊天次数用完了——明天再来，或升级 Premium。';

  @override
  String chatMessagesLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天还剩 $count 条消息',
    );
    return '$_temp0';
  }

  @override
  String get chatInputHint => '问我任何问题……';

  @override
  String get chatInputHintWait => '请稍候……';

  @override
  String get chatSnap => '拍照';

  @override
  String get chatEmptyTitle => '开始聊天吧！';

  @override
  String chatEmptySubtitle(String mascot) {
    return '有问题都可以问 $mascot，或点按 📷 拍下作业题目！';
  }

  @override
  String chatDisclaimer(String mascot) {
    return '$mascot 也可能会出错——请务必核对你的作业！';
  }

  @override
  String get chatDoubleCheckNumbers => '请对照你的练习纸核对数字';

  @override
  String get chatCheckedWithCalculator => '已用计算器核对';

  @override
  String get commonCheckConnection => '请检查网络连接后重试。';

  @override
  String get moduleHomeworkTooltip => '作业';

  @override
  String get moduleCouldNotLoad => '无法加载单元。';

  @override
  String get moduleNoNotesToBuild => '还没有可用于生成课程的笔记。';

  @override
  String get moduleBuildFailed => '无法生成课程。请检查网络连接后重试。';

  @override
  String get moduleNoLessonsYet => '还没有课程';

  @override
  String get moduleGenerateFromMaterials => '根据你的班级材料生成课程。';

  @override
  String get moduleNotesInBuildFirst => '你的笔记已就绪——来生成你的第一节课吧。';

  @override
  String get moduleGenerateLessons => '生成课程';

  @override
  String get moduleBuildFirstLesson => '生成我的第一节课';

  @override
  String get moduleAddNotesCta => '添加你的笔记，我会据此为你生成第一节课。';

  @override
  String get moduleStageLearn => '学习';

  @override
  String get moduleStageTest => '测验';

  @override
  String get moduleStageProve => '证明';

  @override
  String get moduleStageComplete => '已完成';

  @override
  String get moduleCtaReview => '复习';

  @override
  String get moduleCtaStartLearning => '开始学习';

  @override
  String get moduleCtaContinue => '继续';

  @override
  String get moduleTeacherReviewed => '教师已审核';

  @override
  String moduleRefreshing(String mascot) {
    return '$mascot 正在更新这节课——请稍后再来。';
  }

  @override
  String get moduleGoToLibrary => '前往学习库';

  @override
  String get moduleUnknownStage => '未知阶段';

  @override
  String get quizConfidence => '确信度';

  @override
  String get quizErrorRetry => '出错了——请重试。';

  @override
  String get quizFinish => '完成小测';

  @override
  String get quizNextQuestion => '下一题';

  @override
  String quizReviewingWeakSpot(String concept) {
    return '正在复习你的薄弱点：$concept。';
  }

  @override
  String get quizAnswerLocked => '答案已锁定——你将在结束时看到结果。';

  @override
  String get quizCorrect => '答对了！';

  @override
  String get quizNotQuite => '还差一点';

  @override
  String quizScoreResult(int score, int total) {
    return '你答对了 $total 题中的 $score 题。';
  }

  @override
  String get quizComplete => '小测完成！';

  @override
  String quizBackToMochi(String mascot) {
    return '返回 $mascot';
  }

  @override
  String quizAnswerLabel(String answer) {
    return '答案：$answer';
  }

  @override
  String get quizHowSure => '你有多确定？';

  @override
  String get quizConfNotSure => '不确定';

  @override
  String get quizConfKinda => '有点确定';

  @override
  String get quizConfVerySure => '非常确定';

  @override
  String get quizResultMastered => '已掌握';

  @override
  String get quizResultMisconception => '概念误解';

  @override
  String get quizResultLuckyGuess => '蒙对了';

  @override
  String get quizResultKnownGap => '已知薄弱';

  @override
  String quizFocusNext(String topic) {
    return '接下来重点：$topic';
  }

  @override
  String quizTrickyOne(String display) {
    return '我注意到 $display 对你来说有点难——我会很快再带你复习。';
  }

  @override
  String get quizTrickySome => '我注意到有些内容有点难——我会很快再带你复习。';

  @override
  String get quizBuilding => '正在生成你的小测……';

  @override
  String get quizNoQuizToday => '今天没有小测';

  @override
  String quizUploadNotesCta(String mascot) {
    return '上传一些笔记，$mascot 就能为你生成第一份小测！';
  }

  @override
  String get navHome => '主页';

  @override
  String get navLibrary => '学习库';

  @override
  String get navGroups => '小组';

  @override
  String get navMe => '我的';

  @override
  String get homeWelcomeBack => '欢迎回来！👋';

  @override
  String get homeReadyToLearn => '准备好继续学习了吗？';

  @override
  String homeNewMochi(String mascot) {
    return '新建 $mascot';
  }

  @override
  String get homeSectionMyClasses => '我的班级';

  @override
  String get homeSectionYourMochis => '你的 Mochi';

  @override
  String homeLevelBadge(int level) {
    return '⭐ 等级 $level';
  }

  @override
  String get homeMaxLevel => '满级 ⭐';

  @override
  String homeXpProgress(int xpInto, int xpSpan) {
    return '$xpInto / $xpSpan XP';
  }

  @override
  String homeCouldNotLoadMochis(String mascot) {
    return '无法加载 $mascot。下拉重试。';
  }

  @override
  String homeCouldNotLoadYourMochis(String mascot) {
    return '无法加载你的 $mascot。';
  }

  @override
  String get homeCheckConnectionPull => '请检查网络连接后下拉重试。';

  @override
  String homeConsentApprove(String mascot) {
    return '请让家长同意你的账户，才能创建 $mascot。';
  }

  @override
  String get homeResendEmail => '重新发送邮件';

  @override
  String get homeConsentCollapsedChip => '等待家长批准——点按查看选项';

  @override
  String get homeConsentWaitingTitle => '等待家长批准';

  @override
  String homeConsentEmailSent(String email) {
    return '已向 $email 发送同意邮件。家长批准后即可解锁 AI 功能。';
  }

  @override
  String get homeConsentSignOut => '退出登录';

  @override
  String get homeManageKnowledge => '管理知识';

  @override
  String get homeCouldNotActivate => '无法激活——请重试。';

  @override
  String homeMochiLocked(String name) {
    return '$name 已锁定';
  }

  @override
  String homeActivateError(String mascot) {
    return '出错了——这个 $mascot 应该处于激活状态。请下拉刷新。';
  }

  @override
  String homeActivateCapMessage(int cap, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      cap,
      locale: localeName,
      other:
          '在免费方案中，你已有 $cap 个激活的 $mascot。请先停用另一个 $mascot，再激活这一个。\n\n每 24 小时只能更换一次。',
    );
    return '$_temp0';
  }

  @override
  String get homeActivating => '激活中……';

  @override
  String homeActivateAvatar(String name) {
    return '激活 $name';
  }

  @override
  String get homeClose => '关闭';

  @override
  String get homeNudgeFlashcards => '你今天有卡片要复习了！';

  @override
  String get homeNudgeStreak => '保持你的连续学习记录！';

  @override
  String homeReteachMessage(String concept) {
    return '我们能复习一下 $concept 吗？我总是做错';
  }

  @override
  String get homeReteachThis => '这个';

  @override
  String get homeContinueLearning => '继续学习';

  @override
  String homeFlashcardsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张卡片待复习',
    );
    return '$_temp0';
  }

  @override
  String homeStartReview(String name) {
    return '从 $name 开始——2 分钟复习';
  }

  @override
  String get homeAssignments => '作业';

  @override
  String get homeAssignmentOverdue => '已逾期';

  @override
  String homeAssignmentDue(String date) {
    return '截止：$date';
  }

  @override
  String get homeAssignmentPreClass => '课前';

  @override
  String get homeAssignmentPostClass => '课后';

  @override
  String get homeAssignmentRevision => '复习';

  @override
  String get homeAssignmentCustom => '自定义';

  @override
  String homeEmptyHi(String name) {
    return '你好，$name！👋';
  }

  @override
  String homeEmptySetupFirst(String mascot) {
    return '来设置你的第一个 $mascot 吧';
  }

  @override
  String homeEmptyNoMochis(String mascot) {
    return '还没有 $mascot！';
  }

  @override
  String homeEmptyCreate(String mascot) {
    return '创建你的第一个 $mascot，开始学习精彩的知识 🚀';
  }

  @override
  String get homeEmptyPickBuddy => '挑一个伙伴，教它你的笔记，尽管问它任何问题！';

  @override
  String homeEmptyCreateButton(String mascot) {
    return '+ 创建我的第一个 $mascot ✨';
  }

  @override
  String get homeEmptyHaveCode => '🎟️  有邀请码？输入或扫描';

  @override
  String get homeEmptyChipLearn => '🧠 从你的笔记中学习';

  @override
  String get homeEmptyChipAsk => '💬 有问必答';

  @override
  String get homeEmptyChipEarn => '⭐ 赚取 XP 和奖励';

  @override
  String get moduleNext => '下一个';

  @override
  String get moduleReadyToTest => '准备好自我检测了';

  @override
  String get moduleTimeToProve => '该来证明你已经理解了';

  @override
  String moduleCardOf(int cardNumber, int total) {
    return '第 $cardNumber 张，共 $total 张';
  }

  @override
  String moduleCardFallback(int n) {
    return '第 $n 张卡片';
  }

  @override
  String get moduleKeyTerms => '关键术语';

  @override
  String get moduleComplete => '单元完成！';

  @override
  String moduleXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get moduleYourMastery => '你的掌握程度';

  @override
  String get moduleFocusArea => '重点领域';

  @override
  String moduleReviewToImprove(String concept) {
    return '复习“$concept”以提升你的掌握程度。';
  }

  @override
  String get moduleBackToModules => '返回单元列表';

  @override
  String get moduleRevisionMode => '复习模式——用新题目检验你的进度。';

  @override
  String get moduleWhichHardest => '哪部分最难？';

  @override
  String get moduleMuddiestHint => '点选你觉得最难懂的那一个。这能帮助你的导师知道接下来要复习什么。';

  @override
  String get moduleSkip => '跳过';

  @override
  String moduleFromYourNotes(String title) {
    return '来自你的笔记：$title';
  }

  @override
  String moduleComeback(String concept) {
    return '卷土重来——$concept 上次难住了你。';
  }

  @override
  String get moduleSubmitAllAnswers => '提交所有答案';

  @override
  String moduleFocusingOn(String concept) {
    return '重点关注 $concept——你在测试中被它难住了。';
  }

  @override
  String moduleQuestionNumber(int number) {
    return '第 $number 题';
  }

  @override
  String get moduleAnswerHint => '写下你的答案（1-3 句话）……';

  @override
  String moduleCompareReference(String mascot) {
    return '把你写的和参考答案对比一下。请诚实作答——这只是帮助 $mascot 了解需要重温的内容。';
  }

  @override
  String get moduleMarkOwnAnswers => '为自己的答案评分';

  @override
  String get modulePartly => '部分正确';

  @override
  String get moduleNo => '不对';

  @override
  String get moduleYourAnswer => '你的答案';

  @override
  String get moduleReference => '参考答案';

  @override
  String get moduleDidYouGetIt => '你做对了吗？';

  @override
  String get moduleNoItems => '暂无内容';

  @override
  String get moduleTrueOrFalse => '对还是错？';

  @override
  String get moduleAgree => '同意';

  @override
  String get moduleDisagree => '不同意';

  @override
  String get moduleCheckingAnswer => '正在检查你的答案……';

  @override
  String get moduleFeedbackUnavailable => '已记录你的答案——暂时无法加载反馈。';

  @override
  String get moduleSpotTheMistake => '找出错误';

  @override
  String get moduleSpotHint => '这里有什么问题？写下你发现的……';

  @override
  String get moduleRevealError => '揭示错误';

  @override
  String get moduleTheError => '错误所在：';

  @override
  String get moduleCorrectSolution => '正确解法：';

  @override
  String get moduleWereYouRight => '你答对了吗？';

  @override
  String get moduleYes => '对了';

  @override
  String get moduleChallenge => '挑战';

  @override
  String get moduleTypeYourAnswer => '输入你的答案……';

  @override
  String get moduleSubmit => '提交';

  @override
  String get moduleYourAnswerColon => '你的答案：';

  @override
  String get moduleExplanation => '解释：';

  @override
  String get moduleAnswer => '查看答案';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionSubscription => '订阅';

  @override
  String get settingsSectionReferral => '推荐';

  @override
  String get settingsSectionProfile => '个人资料';

  @override
  String get settingsSectionNotifications => '通知';

  @override
  String get settingsSectionSecurity => '安全';

  @override
  String get settingsSectionLearning => '学习';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsSectionAccount => '账户';

  @override
  String get settingsDisplayName => '显示名称';

  @override
  String get settingsSave => '保存';

  @override
  String get settingsNameUpdated => '名称已更新！';

  @override
  String get settingsNameSaveFailed => '无法保存名称——请检查你的网络连接';

  @override
  String get settingsDailyReminder => '每日小测提醒';

  @override
  String get settingsReminderTime => '提醒时间';

  @override
  String get settingsBiometricLogin => '生物识别登录';

  @override
  String get settingsBiometricUnavailable => '此设备不支持';

  @override
  String get settingsBiometricReason => '请验证以启用生物识别登录';

  @override
  String get settingsBiometricEnabled => '已启用生物识别登录';

  @override
  String get settingsBiometricEnableFailed => '无法启用生物识别登录';

  @override
  String get settingsBiometricDisabled => '已停用生物识别登录';

  @override
  String get settingsLearningStyle => '学习风格';

  @override
  String get settingsWhyDifferent => 'Apalchi 有何不同';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsAboutApalchi => '关于 Apalchi';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String get settingsHelpSupport => '帮助与支持';

  @override
  String get settingsEmailUs => '给我们发邮件';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get settingsSignOutTitle => '退出登录？';

  @override
  String get settingsSignOutBody => '你需要重新登录';

  @override
  String get settingsSubLoadError => '无法加载——点按重试';

  @override
  String settingsPremiumTrialLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '⭐ 高级版试用 · 还剩 $days 天',
    );
    return '$_temp0';
  }

  @override
  String settingsEndsLabel(String date) {
    return '结束于 $date';
  }

  @override
  String get settingsKeepPremiumPrice => '以每月 US\$9.99 起继续使用高级版';

  @override
  String get settingsKeepPremium => '继续使用高级版';

  @override
  String get settingsFamilyPlan => '家庭方案——由家长管理';

  @override
  String get settingsFreePlan => '免费方案';

  @override
  String get settingsPremiumManage => '点按“管理”以更新账单或取消。';

  @override
  String settingsFreePlanSubtitle(String mascot) {
    return '解锁无限 $mascot、聊天和家庭共享。';
  }

  @override
  String get settingsManage => '管理';

  @override
  String get settingsUpgrade => '升级';

  @override
  String get settingsManagedByParent => '你的订阅由家长账户管理。';

  @override
  String get settingsInviteFriends => '邀请好友';

  @override
  String get settingsInviteFriendsSubtitle => '查看你的邀请码、分享它、追踪谁加入了。';

  @override
  String get settingsHaveReferralCode => '有推荐码吗？';

  @override
  String get settingsHaveReferralCodeSubtitle => '输入推荐码，奖励你和邀请你的好友。';

  @override
  String get settingsEnterReferralCode => '输入推荐码';

  @override
  String get settingsShareReward => '与邀请你的好友分享奖励。';

  @override
  String get settingsCodes6Chars => '推荐码为 6 个字符';

  @override
  String get settingsCodeApplied => '推荐码已应用！完成一次小测即可激活奖励。';

  @override
  String get settingsApplyCode => '应用推荐码';

  @override
  String signupSignedInAs(String name) {
    return '你已以 $name 的身份登录。要退出并创建新账户吗？';
  }

  @override
  String get signupAlreadySignedIn => '你已经登录。要退出并创建新账户吗？';

  @override
  String get signupCreateNewAccount => '创建新账户？';

  @override
  String get signupLogOutContinue => '退出并继续';

  @override
  String signupStepOf(int step) {
    return '第 $step 步，共 3 步';
  }

  @override
  String get signupSelectAgeGroup => '请选择你的年龄段以继续。';

  @override
  String get signupCreateYourAccount => '创建你的账户';

  @override
  String signupStudyBuddy(String mascot) {
    return '$mascot 将成为你的专属学习伙伴。';
  }

  @override
  String get signupFieldName => '名字';

  @override
  String get signupHintYourName => '你的名字';

  @override
  String get signupValidatorName => '名字至少需要 2 个字符';

  @override
  String get signupFieldEmail => '电子邮箱';

  @override
  String get signupValidatorEmailEmpty => '请输入你的电子邮箱';

  @override
  String get signupValidatorEmailInvalid => '请输入有效的电子邮箱（例如 you@example.com）';

  @override
  String get signupFieldPassword => '密码';

  @override
  String get signupHintPassword => '至少 8 个字符';

  @override
  String get signupValidatorPassword => '密码至少需要 8 个字符';

  @override
  String get signupAgeGroup => '年龄段';

  @override
  String get signupAge13OrOlder => '我已满 13 岁';

  @override
  String get signupAgeUnder13 => '我未满 13 岁';

  @override
  String get signupFieldParentEmail => '家长的电子邮箱';

  @override
  String get signupValidatorParentEmailEmpty => '请输入家长的电子邮箱';

  @override
  String get signupValidatorParentEmailInvalid =>
      '请输入家长有效的电子邮箱（例如 parent@example.com）';

  @override
  String get signupParentApproval => '在你使用 AI 功能之前，我们会发邮件给你的家长以批准你的账户。';

  @override
  String get signupNext => '下一步';

  @override
  String get signupAlreadyHaveAccount => '已有账户？登录';

  @override
  String get signupWhatStudying => '你在学习什么？';

  @override
  String get signupPickSubject => '先选一个科目开始。之后可以再添加更多。';

  @override
  String get signupSubject => '科目';

  @override
  String get signupEducationStage => '教育阶段';

  @override
  String get signupCreateAccount => '创建账户';

  @override
  String get signupBookSplitChapters => '你的书被分成了多个章节';

  @override
  String signupPickChapters(String mascot) {
    return '选择你想让 $mascot 先学习的章节。';
  }

  @override
  String get signupChooseChapters => '选择章节';

  @override
  String get signupAddFirstNotes => '添加你的第一份笔记';

  @override
  String signupNotesInstructions(String mascot) {
    return '在下方输入或粘贴你的笔记。$mascot 会阅读它们，并为你生成一个学习单元。';
  }

  @override
  String get signupNotesHint => '在这里粘贴或输入你的笔记……';

  @override
  String signupCharCount(int count) {
    return '$count 个字符';
  }

  @override
  String signupCharCountMin(int count) {
    return '$count 个字符（至少 50 个）';
  }

  @override
  String signupAddToMochi(String mascot) {
    return '添加到 $mascot';
  }

  @override
  String get signupOr => '或';

  @override
  String get signupSnapPhoto => '或拍一张照片';

  @override
  String get signupChooseFile => '或选择一个文件';

  @override
  String get signupUploadFailed => '上传失败。请重试。';

  @override
  String get signupHaveCode => '🎟️  有班级或小组代码吗？输入或扫描';

  @override
  String get signupSkipForNow => '暂时跳过';

  @override
  String get signupUploading => '正在上传你的笔记……';

  @override
  String signupReadingNotes(String mascot) {
    return '$mascot 正在阅读你的笔记……';
  }

  @override
  String get signupCreatingModule => '正在创建你的第一个学习单元……';

  @override
  String get signupWorkingOnIt => '正在处理……';

  @override
  String get signupTakeMinute => '这可能需要一分钟。';

  @override
  String get signupThisSubject => '这个科目';

  @override
  String signupNotLikeMaterial(String subject) {
    return '这看起来不像是$subject的材料';
  }

  @override
  String signupCouldntMatch(String subject) {
    return '我们无法将它与$subject匹配。你可以照样使用它，或选择另一个文件。';
  }

  @override
  String get signupUseAnyway => '照样使用';

  @override
  String get signupChooseDifferentFile => '选择另一个文件';

  @override
  String signupModuleReady(String title) {
    return '你的“$title”单元准备好了！';
  }

  @override
  String get signupFirstModuleWord => '第一个';

  @override
  String signupMochiSetUp(String mascot) {
    return '你的 $mascot 已设置完成！';
  }

  @override
  String signupModuleBuilt(String mascot) {
    return '$mascot 已阅读你的笔记，并为你生成了一个学习单元。';
  }

  @override
  String get signupStartLearning => '开始学习';

  @override
  String get signupGoToHome => '前往主页';

  @override
  String get howDiffTitle => 'Apalchi 有何不同 🧠';

  @override
  String get howDiffSubtitle => '这就是你刚刚获得的——以及它为什么重要。';

  @override
  String get howDiffCard1Title => '从你的笔记构建';

  @override
  String howDiffCard1Body(String mascot) {
    return '你的 $mascot 学习你的材料——你的课本、你的课堂笔记、你的教学大纲。所以每个答案都贴合你老师真正教的内容，而不是泛泛的课本。';
  }

  @override
  String get howDiffCard2Title => '记住你的学习方式';

  @override
  String get howDiffCard2Body =>
      '它会追踪哪些主题难住了你，并不断带你复习直到掌握。简单的内容会拉长复习间隔。绝不浪费时间在你已经会的东西上。';

  @override
  String get howDiffCard3Title => '为真正的学习而打造';

  @override
  String howDiffCard3Body(String mascot) {
    return '每个科目都有 $mascot——抽认卡、每日小测、掌握度追踪、贴合课程——为认真的学习者设计的深度。';
  }

  @override
  String howDiffQuote(String mascot) {
    return '“不是泛泛的导师。是懂你的 $mascot。”';
  }

  @override
  String get howDiffGotIt => '明白了——开始学习吧！';

  @override
  String get subjectMaths => '数学';

  @override
  String get subjectScience => '科学';

  @override
  String get subjectEnglish => '英文';

  @override
  String get subjectHistory => '历史';

  @override
  String get subjectCoding => '编程';

  @override
  String get subjectArt => '美术';

  @override
  String get subjectGeography => '地理';

  @override
  String get subjectLanguages => '语言';

  @override
  String get subjectMusic => '音乐';

  @override
  String get subjectPhysicalEducation => '体育';

  @override
  String get subjectHealth => '健康';

  @override
  String get subjectLiterature => '文学';

  @override
  String get subjectGeneral => '综合';

  @override
  String get levelPrimary => '小学';

  @override
  String get levelSecondary => '中学';

  @override
  String get levelHighSchool => '高中';

  @override
  String get levelUniversity => '大学 / 成人';

  @override
  String get levelPrimarySubtitle => '约 6–11 岁';

  @override
  String get levelSecondarySubtitle => '约 11–16 岁';

  @override
  String get levelHighSchoolSubtitle => '约 16–18 岁';

  @override
  String get levelUniversitySubtitle => '18 岁以上';

  @override
  String get tierPremium => '高级版';

  @override
  String get tierMax => 'Max';

  @override
  String get tierPro => 'Pro';

  @override
  String get tierFree => '免费';

  @override
  String get tierFamily => '家庭';

  @override
  String get tierTrial => '试用';

  @override
  String get tierCentre => '中心';

  @override
  String get achievementsTitle => '成就';

  @override
  String get achievementsRecentlyEarned => '最近获得';

  @override
  String achievementsEarnedCount(int earned, int total) {
    return '已获得 $earned / $total';
  }

  @override
  String achievementsPercentOfAll(int pct) {
    return '全部成就的 $pct%';
  }

  @override
  String get progressFirstAchievement => '完成任务以获得你的第一个成就。';

  @override
  String get dailyGoalToday => '今日目标';

  @override
  String get dailyGoalPick => '选择你的每日目标';

  @override
  String get dailyGoalMinutes => '分钟';

  @override
  String get dailyGoalQuizzes => '小测';

  @override
  String get dailyGoalSet => '设定我的目标';

  @override
  String get dailyGoalCommit => '确定我的目标';

  @override
  String get dailyGoalRingHint => '每天完成这个圆环，保住你的连续记录。';

  @override
  String get dailyGoalSaveFailed => '无法保存目标。请重试。';

  @override
  String get levelRoadmapTitle => '等级奖励';

  @override
  String levelRoadmapCurrentOf(int current, int max) {
    return '第 $current 级，共 $max 级';
  }

  @override
  String levelRoadmapRewardsUnlocked(int earned, int total) {
    return '已解锁 $total 项奖励中的 $earned 项';
  }

  @override
  String levelN(int level) {
    return '第 $level 级';
  }

  @override
  String get levelUpTitle => '升级了！';

  @override
  String levelUpReached(int level) {
    return '达到第 $level 级——继续加油！';
  }

  @override
  String get levelUpKeepGoing => '继续加油！';

  @override
  String get levelUpSmarter => '你越来越聪明了！🎓';

  @override
  String get progressTitle => '我的进度';

  @override
  String get progressTotalXp => '总 XP';

  @override
  String get progressBadges => '徽章';

  @override
  String get progressCharacterShop => '角色商店';

  @override
  String get progressNeedsWork => '需要加强';

  @override
  String get progressPracticeWeak => '练习薄弱主题';

  @override
  String progressTopicsCount(int count) {
    return '$count 个主题';
  }

  @override
  String progressXpToLevel(int xp, int level) {
    return '距离第 $level 级还差 $xp XP';
  }

  @override
  String progressMinThisWeek(int min) {
    return '本周已学习 $min 分钟';
  }

  @override
  String progressWhichMochi(String mascot) {
    return '要测验哪个 $mascot？';
  }

  @override
  String get progressGoPremium => '升级高级版';

  @override
  String progressPremiumPitch(String mascot) {
    return '无限 $mascot、聊天和家庭共享——7 天免费试用';
  }

  @override
  String get progressEnterCode => '输入或扫描别人给你的代码';

  @override
  String get progressJoinClass => '加入班级或小组';

  @override
  String get progressReferralBonus => '当他们完成第一次小测时，你可获得额外星星';

  @override
  String get streakLadder => '连续记录阶梯';

  @override
  String streakDays(int days) {
    return '$days 天';
  }

  @override
  String streakBest(int days) {
    return '最佳：$days 天';
  }

  @override
  String streakMilestoneDay(int days) {
    return '$days 天连续记录';
  }

  @override
  String get streakBadge1Week => '一周徽章';

  @override
  String get streakBadge2Week => '两周徽章';

  @override
  String get streakBadge30Day => '30 天徽章';

  @override
  String get streak100Days => '100 天';

  @override
  String get streakFullYear => '整整一年';

  @override
  String streakMilestoneOverlayTitle(int days) {
    return '$days 天连续记录！';
  }

  @override
  String get streakKeepLit => '保持下去！';

  @override
  String get streakMilestoneReached => '达成里程碑——继续累积！';

  @override
  String streakDaysToNext(int days, String milestone) {
    return '还差 $days 天到 $milestone';
  }

  @override
  String get streakFreezeHint =>
      '连胜冻结能在你漏掉一天时保住连续记录。每达成一个新的 7 天里程碑就能获回一个（最多 3 个）。';

  @override
  String get achievementsCategoryStreak => '连续记录';

  @override
  String get achievementsCategoryMastery => '掌握';

  @override
  String get achievementsCategoryCuriosity => '好奇心';

  @override
  String get achievementsCategoryMilestones => '里程碑';

  @override
  String get streakUnitDay => '天';

  @override
  String get streakUnitDays => '天';

  @override
  String get streakFreezeActive => '冻结能在你漏掉一天时保住连续记录。';

  @override
  String get streakFreezeEarn => '达成新的 7 天里程碑即可获得一个冻结。';

  @override
  String get unitXp => 'XP';

  @override
  String get unitMin => '分钟';

  @override
  String get unitQuiz => '次小测';

  @override
  String get unitQuizzes => '次小测';

  @override
  String dailyGoalValueUnit(int count, String unit) {
    return '$count $unit';
  }

  @override
  String get groupTitle => '学习小组';

  @override
  String get groupsTitle => '学习小组';

  @override
  String get groupsEmpty => '还没有小组';

  @override
  String get groupsEmptyBody => '创建一个小组，或用好友的邀请码加入。';

  @override
  String get groupsHaveCode => '有邀请码吗？';

  @override
  String get groupJoin => '加入';

  @override
  String get groupJoinFailed => '无法加入——请检查代码';

  @override
  String get groupNewTitle => '新建小组';

  @override
  String get groupCreate => '创建小组';

  @override
  String get groupNameLabel => '小组名称';

  @override
  String get groupNameHint => '给你的小组起个名字';

  @override
  String get groupNameExample => '六年级科学伙伴';

  @override
  String get groupSubjectOptional => '科目（可选）';

  @override
  String get groupCreated => '小组已创建！';

  @override
  String get groupCreateFailed => '无法创建小组';

  @override
  String get groupLeave => '退出小组';

  @override
  String get groupLeaveConfirm => '要退出这个小组吗？';

  @override
  String get groupLeaveBody => '重新加入需要新的邀请码。';

  @override
  String get groupLeaveAction => '退出';

  @override
  String get groupAnswersReleased => '答案已公布';

  @override
  String get groupNewChallenge => '新挑战';

  @override
  String get groupMuddiest => '最难懂的地方';

  @override
  String get groupUpdate => '更新';

  @override
  String groupOpenAssignment(String mascot) {
    return '请从你的班级 $mascot 打开这项作业。';
  }

  @override
  String get groupInviteFriend => '邀请好友';

  @override
  String get groupCopy => '复制';

  @override
  String get groupCodeCopied => '代码已复制！';

  @override
  String get groupShareCode => '把这个代码分享给好友以邀请他们';

  @override
  String get groupNoNotes => '还没有共享的笔记';

  @override
  String get groupNoNotesHint => '从学习库打开一个知识页，点按“共享到小组”即可添加第一条笔记！';

  @override
  String get groupShareAnother => '从学习库共享另一条笔记';

  @override
  String get groupGoLibrary => '前往学习库';

  @override
  String get groupOffTopic => '跑题了？';

  @override
  String groupJoinedName(String name) {
    return '已加入 $name！';
  }

  @override
  String groupNoteBy(String name, String time) {
    return '由 $name · $time';
  }

  @override
  String groupMemberCodeLine(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 名成员 · 代码 $code',
    );
    return '$_temp0';
  }

  @override
  String get timeJustNow => '刚刚';

  @override
  String timeMinAgo(int n) {
    return '$n 分钟前';
  }

  @override
  String timeHourAgo(int n) {
    return '$n 小时前';
  }

  @override
  String timeDayAgo(int n) {
    return '$n 天前';
  }

  @override
  String get challengeTitle => '每日挑战';

  @override
  String get challengeRevealPending => '等待公布';

  @override
  String get challengeCorrectPrefix => '正确：';

  @override
  String get challengeYou => '（你）';

  @override
  String get challengeAnswerHint => '输入你的答案……';

  @override
  String challengeAnsweredReveals(String time) {
    return '已作答——将在 $time 后公布';
  }

  @override
  String challengeRevealsOn(String day, String month) {
    return '$day/$month 公布';
  }

  @override
  String get inviteTitle => '邀请与连接';

  @override
  String get inviteScanHint => '好友可以扫描它来获取你的代码';

  @override
  String get inviteShare => '分享';

  @override
  String get inviteBonus => '当他们完成第一次小测时，你们都能获得额外星星。';

  @override
  String get inviteCopied => '代码已复制';

  @override
  String get inviteLoadFailed => '无法加载你的代码——点按重试';

  @override
  String get inviteAction => '邀请';

  @override
  String get inviteDismiss => '忽略';

  @override
  String get inviteNudgeBody => '邀请好友——你们都能获得额外星星。';

  @override
  String milestoneStreakNice(int days) {
    return '$days 天连续记录——真棒！';
  }

  @override
  String get joinTitle => '输入或扫描代码';

  @override
  String get joinBody => '有班级或学习小组的代码吗？输入它，或扫描它的二维码。';

  @override
  String get joinEnterManually => '手动输入代码';

  @override
  String get joinScanQr => '扫描二维码';

  @override
  String get joinPointQr => '对准班级或小组的二维码';

  @override
  String get joinEnterFirst => '请先输入代码';

  @override
  String get joinInvalidCode => '这看起来不是有效的代码';

  @override
  String get joinParentUnsupported => '不再支持家长链接';

  @override
  String joinedSuccess(String name) {
    return '已加入 $name 🎉';
  }

  @override
  String get joinedFallback => '成功';

  @override
  String get shopEarnStars => '赚取星星';

  @override
  String get shopMyCollection => '我的收藏';

  @override
  String get shopMysteryBox => '神秘盒子';

  @override
  String get shopMysteryBoxHint => '打开以解锁一个随机角色！';

  @override
  String get shopPowerUps => '道具';

  @override
  String get shopQuizPowerUps => '小测道具';

  @override
  String get shopQuizPowerUpsHint => '花费星星，更聪明地学习。';

  @override
  String get shopHintToken => '提示令牌';

  @override
  String get shopDoubleXp => '双倍 XP 加成';

  @override
  String get shopBonusQuiz => '额外练习小测';

  @override
  String get shopStreakFreeze => '连续记录冻结';

  @override
  String get shopStreakFreezeHint => '漏掉一天时保住你的连续记录。';

  @override
  String get shopStreakFreezeSpend => '花费星星保护你的连续记录。';

  @override
  String get shopAlreadyUnlocked => '已解锁';

  @override
  String get shopAwesome => '太棒了！';

  @override
  String get shopNewCharacter => '解锁新角色！';

  @override
  String shopCanUseMochi(String mascot) {
    return '现在你可以用这个 $mascot 来学习了！';
  }

  @override
  String get shopLoadingOdds => '正在加载概率……';

  @override
  String get shopProbability => '💡 温馨提示——概率：';

  @override
  String get shopLearnHarder => '我会更努力学习，再试一次！';

  @override
  String shopFreezeAdded(int current, int cap) {
    return '❄️ 已添加冻结——你现在有 $current/$cap 个';
  }

  @override
  String shopBought(String label, int count) {
    return '已购买 $label——你现在有 $count 个';
  }

  @override
  String shopRarityBadge(String label) {
    return '✨ $label';
  }

  @override
  String get shopLabelHintToken => '一个提示令牌';

  @override
  String get shopLabelDoubleXp => '一个双倍 XP 加成';

  @override
  String get shopLabelBonusQuiz => '一次额外小测';

  @override
  String get shopLabelPowerup => '一个道具';

  @override
  String get flashcardsTitle => '抽认卡';

  @override
  String get flashcardQuestion => '问题';

  @override
  String get flashcardTapFlip => '点按翻面';

  @override
  String get flashcardEasy => '简单';

  @override
  String get flashcardOkay => '一般';

  @override
  String get flashcardHard => '困难';

  @override
  String get flashcardEmpty => '还没有抽认卡';

  @override
  String get flashcardReadyMake => '准备好制作卡片';

  @override
  String get flashcardReadyMakeYours => '准备好制作你的卡片';

  @override
  String get flashcardGenerate => '生成抽认卡';

  @override
  String get flashcardRegenerate => '重新生成卡片';

  @override
  String flashcardHasNotesNoCards(String mascot) {
    return '你的 $mascot 有笔记但还没有卡片。\n点按下方按钮来生成。';
  }

  @override
  String flashcardAboutPages(int count) {
    return '大约有 $count 页笔记。需要一点时间——准备好后点按。';
  }

  @override
  String flashcardGenerateN(int count) {
    return '生成卡片（约 $count 页）';
  }

  @override
  String get shopHintTokenSub => '在小测中揭示一个错误选项。';

  @override
  String get shopDoubleXpSub => '让你下一次小测的 XP 翻倍（在每日上限内）。';

  @override
  String get shopBonusQuizSub => '今天解锁一次额外的满 XP 小测。';

  @override
  String get flashcardFilterAll => '全部';

  @override
  String get flashcardFilterDue => '待复习';

  @override
  String get flashcardFilterWeak => '薄弱';

  @override
  String get flashcardFilterDone => '已完成';

  @override
  String photoBetterPhoto(String mascot) {
    return '更好的照片 = $mascot 给出更好的答案';
  }

  @override
  String get photoBrightLight => '光线充足';

  @override
  String get photoChartsX => '图表 ✕';

  @override
  String get photoClearNumbers => '清晰的数字 ✓';

  @override
  String get photoDiagramsWarn => '示意图 ⚠️';

  @override
  String get photoFillFrame => '填满画面';

  @override
  String get photoCloseTips => '明白了，关闭提示';

  @override
  String get photoGraphsWarn => '图形、图表和形状扫描效果不佳。请自行输入这些数值。';

  @override
  String get photoHoldStill => '保持稳定';

  @override
  String get photoKeepStraight => '保持平直';

  @override
  String get photoNeatHandwriting => '工整的手写 ✓';

  @override
  String get photoPrintedText => '印刷文字 ✓';

  @override
  String get photoSymbolsWarn => '符号 ⚠️';

  @override
  String get photoTypeInstead => '改为输入';

  @override
  String photoWhatReads(String mascot) {
    return '$mascot 能读取的内容：';
  }

  @override
  String get photoWhatCanRead => '我能读取什么？ ›';

  @override
  String get photoPointHomework => '📚 对准你的作业题目';

  @override
  String get photoTipsBest => '📷 获得最佳效果的技巧';

  @override
  String get photoHomeworkResults => '作业结果';

  @override
  String get photoNothingShare => '暂时没有可分享的内容。';

  @override
  String get photoShareResults => '分享结果';

  @override
  String get photoWhatNext => '接下来做什么？';

  @override
  String get photoQuizMe => '🎯 就这个测验我';

  @override
  String get photoAnotherExample => '💡 再来一个例子';

  @override
  String get photoShowWorking => '📝 显示完整解题过程';

  @override
  String photoQuestionCount(int count) {
    return '$count 道题';
  }

  @override
  String photoIFound(int count) {
    return '🔍 我找到了 $count 道题！以下是解答：';
  }

  @override
  String photoQuestionsFound(int count) {
    return '找到 $count 道题';
  }

  @override
  String photoSendQuestions(int count, String mascot) {
    return '发送 $count 道题给 $mascot ✨';
  }

  @override
  String get photoCouldNotRead => '无法读取照片';

  @override
  String get photoDetecting => '正在识别题目…… 🔍';

  @override
  String get photoEditQuestions => '编辑题目';

  @override
  String get photoRetake => '重拍';

  @override
  String get photoDoneUse => '完成——使用这些题目 ✓';

  @override
  String photoFixMisread(String mascot) {
    return '修正 $mascot 误读的任何文字';
  }

  @override
  String get photoEditQuestionsTitle => '✏️  编辑题目';

  @override
  String get photoChooseGallery => '从相册选择';

  @override
  String get photoKeepPhoto => '保留照片';

  @override
  String get photoRetakeConfirm => '重拍照片？';

  @override
  String get photoRetakeBody => '你将丢失当前的扫描。请选择要做什么：';

  @override
  String get photoGreat => '很好！ ✓';

  @override
  String photoFoundInPhoto(String mascot) {
    return '以下是 $mascot 在你照片中找到的内容：';
  }

  @override
  String get photoConfHigh => '高（>85%）';

  @override
  String photoReadingReport(String mascot) {
    return '$mascot 的识别报告';
  }

  @override
  String get photoConfOkish => '一般';

  @override
  String get photoPerQuestion => '每道题：';

  @override
  String get photoConfRisky => '有风险（<50%）';

  @override
  String photoSendAnyway(String mascot) {
    return '仍然发送（$mascot 会尽力）';
  }

  @override
  String get photoConfTricky => '有点难（50–85%）';

  @override
  String get photoTrickyWarn => '有点难 ⚠️';

  @override
  String get photoFixManually => '✏️  手动修正文字';

  @override
  String get photoBetterQuality => '💡 照片质量越好 = 答案越准确';

  @override
  String get photoChooseGalleryLower => '从相册选择';

  @override
  String get photoDone => '完成';

  @override
  String get photoEditText => '编辑题目文字……';

  @override
  String get photoKeepThisPhoto => '保留这张照片';

  @override
  String get photoRetakePhoto => '重拍照片';

  @override
  String get photoWhatToDo => '你想做什么？';

  @override
  String get ocrFixManually => '手动修正文字';

  @override
  String ocrHowWellReads(String mascot) {
    return '$mascot 对每道题的识别程度';
  }

  @override
  String ocrQuestionLine(int n, String text) {
    return '第 $n 题：$text';
  }

  @override
  String get ocrReadingConfidence => '识别置信度';

  @override
  String get ocrSendAnyway => '仍然发送';

  @override
  String get ocrIssuesDetected => '检测到问题';

  @override
  String get ocrQualityLow => '照片质量较低';

  @override
  String get ocrQualityScore => '质量评分';

  @override
  String get ocrRetakePhoto => '重拍照片 📸';

  @override
  String get ocrMayMisread => '你的导师可能会误读某些题目';

  @override
  String get ocrBestResults => '让你的相机发挥最佳效果';

  @override
  String get ocrGotItTakePhoto => '明白了——拍照';

  @override
  String get ocrMightNeedFix => '可能需要手动修正';

  @override
  String get ocrPhotoTips => '提升识别效果的拍照技巧';

  @override
  String get ocrWhatReadsWell => '哪些内容识别良好';

  @override
  String get ocrBestTip => '最佳建议：拍下文字和数字，然后自行输入任何图表数值。';

  @override
  String get ocrCantSee => '但它无法真正“看到”图形或形状之类的图片——它只能读取周围的文字。';

  @override
  String ocrReadsWell(String mascot) {
    return '$mascot 对文字和数字的识别非常出色';
  }

  @override
  String get ocrWhatCanRead => 'Apalchi 能读取什么？';

  @override
  String get ocrWarnDiagram => '这张图片包含示意图或图表。文字识别可能会遗漏视觉元素。';

  @override
  String get ocrWarnMaths => 'OCR 可能无法完美识别数学符号和方程式。';

  @override
  String get ocrWarnGeneric => '这张图片中的某些内容可能无法准确识别。';

  @override
  String get ocrFixDiagram => '点按“手动修正文字”来描述示意图的内容。';

  @override
  String get ocrFixSymbols => '点按“手动修正文字”来更正任何被误读的符号。';

  @override
  String get ocrFixGeneric => '点按“手动修正文字”来检查并更正文字。';

  @override
  String get ocrDiagramDetected => '检测到示意图';

  @override
  String get ocrMathsDetected => '检测到数学符号';

  @override
  String uploadErrCouldNotRead(String fileName) {
    return '无法读取“$fileName”——请重新选择。';
  }

  @override
  String uploadErrEmpty(String fileName) {
    return '“$fileName”似乎是空的。';
  }

  @override
  String uploadErrTooLarge(String fileName, String size) {
    return '“$fileName”有 ${size}MB——上限为 25MB。请将它拆分成更小的部分。';
  }

  @override
  String uploadErrUnsupported(String fileName, String ext) {
    return '“$fileName”是 .$ext 文件——只支持 PDF、图片和文本文件。';
  }

  @override
  String uploadErrCorrupted(String fileName) {
    return '无法读取“$fileName”——它可能是空的或已损坏。';
  }

  @override
  String get uploadErrSession => '会话已过期。请重新登录。';

  @override
  String get uploadErrPlanLimit => '你已达到方案上限。';

  @override
  String get uploadErrNoPermission => '你没有权限在此上传。';

  @override
  String uploadErrDuplicate(String fileName, String existing, String mascot) {
    return '“$fileName”与你 $mascot 大脑中已有的“$existing”完全相同。无需重复上传！';
  }

  @override
  String uploadErrSimilar(String fileName, String existing, String mascot) {
    return '“$fileName”与你 $mascot 大脑中已有的“$existing”非常相似。再次上传不会让 $mascot 学到新东西。';
  }

  @override
  String uploadErrTooLarge413(String fileName) {
    return '“$fileName”太大了（上限 25MB）。请将它拆分成更小的部分。';
  }

  @override
  String uploadErrUnsupported415(String fileName) {
    return '“$fileName”不是受支持的文件类型。请使用 PDF、图片或文本文件。';
  }

  @override
  String get uploadErrTooMany => '同时上传的文件太多了。请稍候再试。';

  @override
  String uploadErrProcessing(String fileName) {
    return '无法处理“$fileName”——它可能有密码保护或已损坏。请尝试另一个版本。';
  }

  @override
  String uploadErrServerBusy(String fileName) {
    return '服务器现在很忙。请稍候再上传“$fileName”。';
  }

  @override
  String uploadErrMochiBusy(String mascot) {
    return '$mascot 现在很忙——请稍后再试。';
  }

  @override
  String uploadErrStillWorking(String mascot) {
    return '$mascot 仍在后台处理你的笔记——请过几分钟再回来查看。';
  }

  @override
  String uploadErrTimeout(String fileName) {
    return '“$fileName”上传超时。请检查你的网络连接后重试。';
  }

  @override
  String get uploadErrNoInternet => '没有网络连接。请检查你的 WiFi 后重试。';

  @override
  String uploadErrFailed(String fileName) {
    return '“$fileName”上传失败。请重试。';
  }

  @override
  String uploadErrUnexpected(String fileName) {
    return '上传“$fileName”时发生意外错误。请重试。';
  }

  @override
  String get uploadExistingFileFallback => '一个已有文件';

  @override
  String get uploadExistingNotesFallback => '已有的笔记';

  @override
  String get uploadWarnBackup => '这个我用了备用识别器——请仔细检查一下是否正确。';

  @override
  String get uploadWarnLowText =>
      '我没能从中读取到多少文字——请重新上传更清晰的版本或手动输入。照现在这样它无法很好地训练我。';

  @override
  String get uploadEstShort => '30–60 秒';

  @override
  String get uploadEstMedium => '1–2 分钟';

  @override
  String get uploadEstLong => '3–5 分钟';

  @override
  String get uploadAddKnowledge => '添加知识';

  @override
  String get uploadBrainUpdated => '大脑已更新！';

  @override
  String get uploadBuildBrain => '构建我的大脑';

  @override
  String get uploadChoosePdf => '从你的设备选择一个 PDF';

  @override
  String get uploadExtractedTextHint => '提取的文字……';

  @override
  String get uploadLargeFile => '大文件——这需要几分钟';

  @override
  String get uploadLooksGood => '看起来不错';

  @override
  String get uploadPasteClipboard => '从剪贴板粘贴';

  @override
  String get uploadReupload => '重新上传';

  @override
  String get uploadReviewExtracted => '检查提取的文字';

  @override
  String get uploadSaveEdits => '保存修改';

  @override
  String get uploadSnapNotes => '拍下你的笔记或课本';

  @override
  String get uploadSource => '来源';

  @override
  String get uploadTagOptional => '为这次上传添加标签（可选）';

  @override
  String get uploadTakePhoto => '拍一张照片';

  @override
  String get uploadTopicHint => '主题（例如 代数）';

  @override
  String get uploadUploadPdf => '上传 PDF';

  @override
  String get uploadNotesBecomeBrain => '你的笔记会成为我的大脑。';

  @override
  String uploadAddingNotesTo(String subject) {
    return '正在向 $subject 添加笔记';
  }

  @override
  String uploadFilesUploaded(int count) {
    return '已上传 $count 个文件';
  }

  @override
  String uploadLargeFileNotice(String mb, String estimate, String mascot) {
    return '这是一个大文件（${mb}MB）。用它构建你的大脑大约需要 $estimate。你可以离开这个页面——$mascot 会在后台持续构建，准备好后自动更新。';
  }

  @override
  String uploadSuccessBody(String mascot) {
    return '$mascot 已阅读你的笔记并添加到大脑中。现在你可以聊天、测验和复习你的笔记了。';
  }

  @override
  String get uploadStartChatting => '开始聊天';

  @override
  String get uploadAddMore => '添加更多笔记';

  @override
  String get uploadStillBuilding => '仍在构建你的大脑';

  @override
  String get uploadTakingLonger => '比预期花的时间更长……';

  @override
  String get uploadSomethingWrong => '出错了';

  @override
  String uploadLargeTimeoutBody(String mascot) {
    return '大文件需要几分钟来编译。$mascot 仍在后台处理，准备好后会自动更新你的大脑——无需重新上传。';
  }

  @override
  String uploadTimeoutBody(String mascot) {
    return '$mascot 仍在后台处理你的笔记。请过几分钟再回来查看——大脑会自动更新。';
  }

  @override
  String uploadFailedBody(String mascot) {
    return '$mascot 无法处理你的笔记。请用更小的文件或不同的格式重新上传。';
  }

  @override
  String get uploadReturnHome => '返回主页';

  @override
  String uploadSplittingSections(String estimate) {
    return '大文档——正在拆分成多个部分（约 $estimate）';
  }

  @override
  String get uploadBuildingSections => '正在分段构建大脑……';

  @override
  String uploadDocLargeExpected(String mascot, String estimate) {
    return '你的文档很大——$mascot 会将它拆分成多个部分以提高准确度。预计：$estimate。你可以关闭这个页面；大脑会自动更新。';
  }

  @override
  String uploadPagesShortly(String estimate) {
    return '新页面很快会出现在你的学习库中。预计：$estimate。';
  }

  @override
  String get uploadTipBanner => '提示：清晰的、打字或印刷的页面识别效果最好。';

  @override
  String get uploadSourceTextbook => '课本';

  @override
  String get uploadSourceNotes => '笔记';

  @override
  String get uploadSourceWebsite => '网站';

  @override
  String get uploadSourceOther => '其他';

  @override
  String wikiChaptersNotCompiled(int count) {
    return '还有 $count 章未编译';
  }

  @override
  String wikiHasntReadChapters(int count, String mascot) {
    return '$mascot 还没有读这些章节——请选择要编译哪些。';
  }

  @override
  String get wikiChoose => '选择';

  @override
  String get wikiChooseChaptersCompile => '选择要编译的章节';

  @override
  String wikiCompileAll(int count) {
    return '全部编译（$count）';
  }

  @override
  String get wikiCouldntLoadChapters => '无法加载章节。请关闭后重试。';

  @override
  String wikiReadingChapters(String mascot) {
    return '$mascot 正在阅读你的章节！';
  }

  @override
  String wikiOnlyReadsPicked(String mascot) {
    return '$mascot 只会阅读你选择的章节——先从你现在正在学的开始。';
  }

  @override
  String get wikiNoChaptersCompile => '没有可编译的章节。';

  @override
  String wikiPagesRange(int from, int to, int count) {
    return '第 $from–$to 页 · 共 $count 页';
  }

  @override
  String wikiTakesFewMinutes(String mascot) {
    return '这需要几分钟。你可以在学习库中跟进——$mascot 会显示它正在阅读哪一章，完成后你的课程就会解锁。';
  }

  @override
  String wikiAskMochiNow(String mascot) {
    return '现在问 $mascot';
  }

  @override
  String get wikiBrainQuality => '大脑质量评分';

  @override
  String get wikiQuickQuiz => '快速小测';

  @override
  String get wikiViewBrain => '查看大脑';

  @override
  String get wikiAddReupload => '为这个页面添加或重新上传内容';

  @override
  String wikiAskConfirm(String title) {
    return '请让家长确认“$title”是否准确。';
  }

  @override
  String get wikiFixNotes => '修正我的笔记';

  @override
  String get wikiGetChecked => '让它接受检查';

  @override
  String get wikiRevoke => '撤销';

  @override
  String get wikiSendLink => '向任何人发送链接以检查它';

  @override
  String get wikiShareReviewLink => '分享审阅链接';

  @override
  String wikiCheckedBy(String name) {
    return '由 $name 检查过 ✓';
  }

  @override
  String wikiReviewerFlagged(String name) {
    return '$name 标记了一处问题：';
  }

  @override
  String get wikiLimitedNotes => '这是根据有限的笔记生成的——请仔细核对关键事实。';

  @override
  String get wikiUnverified => '未验证';

  @override
  String get wikiReviewerFallback => '一位审阅者';

  @override
  String get wikiReviewerFallbackCap => '一位审阅者';

  @override
  String wikiRemoveDoc(String fileName, String mascot) {
    return '“$fileName”将被移除，$mascot 的大脑会自动更新。';
  }

  @override
  String wikiMinAgo(int n) {
    return '$n 分钟前';
  }

  @override
  String get wikiBrainEmpty => '大脑是空的';

  @override
  String wikiCheckedByShort(String by, String more) {
    return '由 $by 检查过 ✓$more';
  }

  @override
  String get wikiConflict => '冲突';

  @override
  String get wikiConflictingInfo => '信息冲突';

  @override
  String get wikiCouldNotSave => '无法保存——请重试。';

  @override
  String get wikiEditPageContent => '编辑页面内容';

  @override
  String get wikiFailed => '失败';

  @override
  String get wikiFixNow => '立即修正';

  @override
  String get wikiGoToGroups => '前往小组';

  @override
  String wikiHowTeach(String mascot) {
    return '$mascot 应该怎样教你？';
  }

  @override
  String get wikiJoinGroupFirst => '请先加入一个小组';

  @override
  String wikiManageMochis(String mascot) {
    return '管理你的 $mascot';
  }

  @override
  String wikiReadingNotes(String mascot) {
    return '$mascot 正在阅读你的笔记——新页面会自动出现在这里。';
  }

  @override
  String get wikiOffTopic => '跑题';

  @override
  String get wikiRecentPages => '最近的页面';

  @override
  String get wikiReading => '正在阅读……';

  @override
  String get wikiRemove => '移除';

  @override
  String get wikiRemoveDocument => '移除文档';

  @override
  String get wikiRemoveDocumentConfirm => '要移除文档吗？';

  @override
  String get wikiSearchPages => '搜索页面……';

  @override
  String get wikiShareToGroup => '分享到哪个小组？';

  @override
  String wikiSourceDocuments(int count) {
    return '来源文档（$count）';
  }

  @override
  String wikiStylePrompt(String mascot) {
    return '点选一种风格或自己写——例如“分数用条形模型”或“始终展示完整解题过程”。$mascot 会在每节课和聊天中遵循它。';
  }

  @override
  String get wikiTeacherNotes => '老师的备注';

  @override
  String get wikiConflictBody =>
      '这个页面包含来自多个来源的信息，它们之间可能存在分歧。\n\n你可以手动修正内容来解决冲突。';

  @override
  String get wikiNoGroups => '你还没有加入任何学习小组。加入或创建一个，就可以分享笔记了！';

  @override
  String get wikiCentreKeepsUpdated => '你的中心会保持这个班级的材料为最新。';

  @override
  String wikiCentreSetsTeaching(String mascot) {
    return '你的中心设定这个班级 $mascot 的教学方式。';
  }

  @override
  String get wikiStyleExample => '例如：分数用模型法。展示所有步骤。';

  @override
  String wikiFrom(String sources) {
    return '来自：$sources';
  }

  @override
  String get wikiShareArrow => '↗ 分享';

  @override
  String wikiChaptersOverLimit(int remaining, int excess) {
    return '本月仅剩 $remaining 个 — 请取消选择 $excess 个。';
  }

  @override
  String wikiChaptersSelectedCount(int count) {
    return '已选 $count 个';
  }

  @override
  String get wikiSelectChapters => '选择一个或多个章节';

  @override
  String get createTutorSubjectTitle => '学习什么科目？';

  @override
  String createTutorSubjectPrompt(String name) {
    return '$name 可以帮你学什么？';
  }

  @override
  String get createTutorSubjectHint => '例如：数学、科学、吉他……';

  @override
  String get createTutorQuickPicks => '快速选择';

  @override
  String get createTutorGradeTitle => '就快好了！🎓';

  @override
  String createTutorGradePrompt(String name) {
    return '帮 $name 按合适的程度教学。（可选）';
  }

  @override
  String get createTutorSelectAge => '选择年龄（可选）';

  @override
  String get createTutorNotSet => '— 未设置 —';

  @override
  String createTutorCreateName(String name) {
    return '创建 $name！🎉';
  }

  @override
  String createTutorNameTitle(String mascot) {
    return '给你的 $mascot 取个名字';
  }

  @override
  String createTutorNamePrompt(String mascot) {
    return '你想给你的 $mascot 取什么名字？';
  }

  @override
  String get createTutorNameHint => '例如：Robo、Felix 教授……';

  @override
  String createTutorChooseTitle(String mascot) {
    return '选择你的 $mascot';
  }

  @override
  String createTutorChooseSubtitle(String mascot) {
    return '挑一个合你心意的 $mascot！🎉';
  }

  @override
  String createTutorLoadFailed(String mascot) {
    return '无法加载 $mascot — 点击重试。';
  }

  @override
  String get createTutorCharLocked => '角色未解锁';

  @override
  String createTutorUnlockPrompt(String name) {
    return '赚取 XP 打开神秘盒子，解锁 $name！';
  }

  @override
  String get createTutorOpenMysteryBox => '打开神秘盒子';

  @override
  String get createTutorStarsToUnlock => '600 ⭐ 解锁';

  @override
  String createTutorScreenTitle(String mascot) {
    return '创建 $mascot';
  }

  @override
  String createTutorErrFailed(String mascot) {
    return '无法创建 $mascot。请再试一次。';
  }

  @override
  String get chatGeneralKnowledge => '🌐 通用知识 — 上传笔记以获得针对性解答';

  @override
  String get chatFromYourNotes => '📖 来自你的笔记';

  @override
  String get reportTitle => '举报这条消息';

  @override
  String reportBlurb(String mascot) {
    return '帮我们让 $mascot 更安全、更有帮助。我们会跟进处理。';
  }

  @override
  String reportReasonUnsafe(String mascot) {
    return '$mascot 说的话不安全或让人难受';
  }

  @override
  String reportReasonWrong(String mascot) {
    return '$mascot 答错了或让人困惑';
  }

  @override
  String get reportReasonOther => '其他问题';

  @override
  String get reportCommentLabel => '想多告诉我们一些吗？（可选）';

  @override
  String get reportCommentHint => '在此输入……';

  @override
  String get reportSend => '发送举报';

  @override
  String reportFooter(String mascot) {
    return '你的举报有助于保障 $mascot 的安全。';
  }

  @override
  String get homeworkCouldNotSolve => '无法解答这些题目。请用更清晰的照片再试一次。';

  @override
  String get homeworkViewFullResults => '点击查看完整结果 →';

  @override
  String homeworkSolvedCount(int count) {
    return '已解答 $count 道题！';
  }

  @override
  String homeworkXpEarned(int xp) {
    return '+$xp XP 到手';
  }

  @override
  String get homeworkShowWorking => '📝 显示完整解题步骤';

  @override
  String get homeworkAnotherExample => '🔄 换个例子';

  @override
  String get homeworkQuizMe => '⚡ 就这个考考我';

  @override
  String homeworkFromPage(String page) {
    return '📖 来自 $page.md';
  }

  @override
  String photoQuestionsDetected(int count) {
    return '📷 检测到 $count 道题';
  }

  @override
  String get photoHomeworkPhoto => '📷 作业照片';

  @override
  String get photoReadingHomework => '稍等，我在看你的作业…… 🔍';

  @override
  String get answerCardShow => '显示 →';

  @override
  String get aiDisclosureTitle => '关于 AI 的简短说明';

  @override
  String get aiDisclosureBody =>
      'Apalchi 使用 AI 助手把你的笔记变成课程。你的笔记会发送给两家 AI 公司 — Anthropic（Claude）和 Google（Gemini）— 它们的服务器位于新加坡境外。它们只会用你的笔记来生成你的学习材料。';

  @override
  String get aiDisclosureGrownup => '这个选择由大人替你把关。';

  @override
  String get aiDisclosureOkToContinue => '可以继续吗？';

  @override
  String get aiDisclosureAnthropic => 'Anthropic（Claude）';

  @override
  String get aiDisclosureAnthropicDesc => '生成你的讲解、测验和聊天回复。';

  @override
  String get aiDisclosureGoogle => 'Google（Gemini）';

  @override
  String get aiDisclosureGoogleDesc => '帮助读取和理解你的笔记。';

  @override
  String get aiDisclosureOutside => '这些公司位于新加坡境外。我们只发送生成你的学习材料所需的内容。';

  @override
  String get aiDisclosureReadMore => '了解更多';

  @override
  String get aiDisclosureOk => '好的';

  @override
  String get aiDisclosureAgree => '我同意';

  @override
  String get consentNotNow => '暂不';

  @override
  String get consentApprovedTitle => '已批准';

  @override
  String consentApprovedBody(String mascot) {
    return '大人已经同意 — 你的账户已就绪。一起和 $mascot 开始学习吧！';
  }

  @override
  String get consentPendingSend => '发送';

  @override
  String consentPendingResent(String email) {
    return '批准邮件已重新发送至 $email — 请查看收件箱和垃圾邮件。';
  }

  @override
  String get consentPendingSending => '发送中……';

  @override
  String consentPendingResendIn(int seconds) {
    return '$seconds 秒后可重发';
  }

  @override
  String get consentPendingResendEmail => '重新发送邮件';

  @override
  String get consentPendingTitle => '就快好了！🎉';

  @override
  String get consentPendingSubtitle => '我们只需要一位大人点头同意。';

  @override
  String get consentPendingAskEmailBefore => '请他们查看邮箱 ';

  @override
  String get consentPendingAskEmailAfter => '，并点击其中的链接。';

  @override
  String get consentPendingSpamNote =>
      '这可能需要一会儿。如果他们没看到，请让他们检查垃圾邮件文件夹，并点击「不是垃圾邮件」，好让下一封能正常送达。';

  @override
  String get consentPendingAutoUnlock => '他们一同意，我们就会自动解锁 — 你可以关闭应用，回来时就绪。';

  @override
  String get consentPendingNotApproved => '尚未批准 — 请让大人点击链接，然后再试一次。';

  @override
  String get consentPendingGotIt => '知道了';

  @override
  String get deleteAccountAppBar => '删除账户';

  @override
  String get deleteAccountTitle => '删除你的账户？';

  @override
  String get deleteAccountIntro => '这将永久删除你的账户。恢复期结束后将无法撤销。';

  @override
  String get deleteAccountWhatDeleted => '将删除哪些内容';

  @override
  String deleteAccountItem1(String mascot) {
    return '你的 $mascot 以及它们从你笔记中学到的一切';
  }

  @override
  String get deleteAccountItem2 => '你上传的笔记、课程、测验和记忆卡';

  @override
  String get deleteAccountItem3 => '你的学习进度、连续记录、星星和聊天记录';

  @override
  String get deleteAccountGrace =>
      '你有 14 天可以反悔。在此期间重新登录即可恢复你的账户和所有数据。14 天后将永久消失。';

  @override
  String get deleteAccountKeep => '保留我的账户';

  @override
  String get deleteAccountConfirmTitle => '确认是你本人';

  @override
  String get deleteAccountConfirmBody => '为了你的安全，在我们安排删除之前请确认你的身份。';

  @override
  String get deleteAccountEmailCode => '改为向我发送验证码';

  @override
  String get deleteAccountCodeSent => '我们已向你发送 6 位验证码。请在下方输入以确认。';

  @override
  String get deleteAccountCodeLabel => '6 位验证码';

  @override
  String get deleteAccountConfirmBtn => '删除我的账户';

  @override
  String get deleteAccountBack => '返回';

  @override
  String get deleteAccountScheduledTitle => '你的账户已排定删除';

  @override
  String deleteAccountScheduledOn(String date) {
    return '将于 $date 永久删除。';
  }

  @override
  String get deleteAccountScheduledGeneric => '将在 14 天恢复期结束后永久删除。';

  @override
  String get deleteAccountChangedMind => '改变主意了？在那之前重新登录即可恢复你的账户和所有数据。';

  @override
  String get deleteAccountManualCancel =>
      '如果你是通过 App Store 或 Google Play 订阅的，请记得在设备的订阅设置中取消订阅 — 在此删除账户并不会取消订阅。';

  @override
  String get deleteAccountErrEnterCredential => '请输入你的密码或收到的验证码以确认。';

  @override
  String get restoreScheduledTitle => '此账户已排定删除';

  @override
  String restoreScheduledOn(String date) {
    return '将于 $date 永久删除。立即恢复以保留你的账户和所有数据。';
  }

  @override
  String get restoreGeneric => '立即恢复以保留你的账户和所有数据。';

  @override
  String get restoreBtn => '恢复我的账户';

  @override
  String get completeProfileTitle => '还有一件小事';

  @override
  String get completeProfileSubtitle => '告诉我们你的年龄段，好让我们安全地设置你的账户。';

  @override
  String get completeProfileAgeGroup => '年龄段';

  @override
  String get completeProfile13Plus => '我 13 岁或以上';

  @override
  String get completeProfileUnder13 => '我未满 13 岁';

  @override
  String get completeProfileErrSelectAge => '请选择你的年龄段以继续。';

  @override
  String get completeProfileErrParentEmail => '请输入你家长的电子邮箱地址。';

  @override
  String get completeProfileErrGeneric => '出了点问题。请再试一次。';

  @override
  String get monthJan => '1月';

  @override
  String get monthFeb => '2月';

  @override
  String get monthMar => '3月';

  @override
  String get monthApr => '4月';

  @override
  String get monthMay => '5月';

  @override
  String get monthJun => '6月';

  @override
  String get monthJul => '7月';

  @override
  String get monthAug => '8月';

  @override
  String get monthSep => '9月';

  @override
  String get monthOct => '10月';

  @override
  String get monthNov => '11月';

  @override
  String get monthDec => '12月';

  @override
  String dateFormatDMY(int day, String month, int year) {
    return '$year年$month$day日';
  }

  @override
  String get consentApprovedAllSet => '一切就绪！🎉';

  @override
  String get consentApprovedLetsGo => '开始吧！';

  @override
  String get consentPendingEmailLabel => '你大人的电子邮箱';

  @override
  String get consentPendingHelperText => '我们会改为把批准链接发送到这里。';

  @override
  String get consentPendingResendFailed => '刚才无法重发 — 请稍后再试。';

  @override
  String get consentPendingRefresh => '我已批准 — 刷新';

  @override
  String get consentPendingChangeEmail => '大人的邮箱填错了？点此修改';

  @override
  String get completeProfileParentEmailLabel => '家长的电子邮箱地址';

  @override
  String get completeProfileParentEmailRequired => '请输入你家长的电子邮箱';

  @override
  String get completeProfileParentEmailInvalid =>
      '请输入你家长的有效电子邮箱（例如 parent@example.com）';

  @override
  String get completeProfileParentEmailHelper =>
      '在你使用 AI 功能之前，我们会发邮件请你的家长批准你的账户。';

  @override
  String get commonTryAgainSentence => '再试一次';

  @override
  String teachTitle(String mascot) {
    return '教$mascot';
  }

  @override
  String teachIntro(String mascot) {
    return '选一个主题来教$mascot吧！把它讲解出来，是检验自己是否真正理解的最快方法。';
  }

  @override
  String teachAboutLabel(String mascot) {
    return '要教$mascot的主题';
  }

  @override
  String teachHint(String mascot) {
    return '假装$mascot从来没听过这个内容，用你自己的话来解释……';
  }

  @override
  String get teachSubmit => '写好了 — 看看我教得怎么样';

  @override
  String get teachPerfect => '你全教会了！';

  @override
  String get teachGreat => '教得很好！';

  @override
  String commonXpPlus(int xp) {
    return '+$xp XP';
  }

  @override
  String get teachYouExplained => '你讲到的概念';

  @override
  String get teachMissedConcepts => '遗漏的概念';

  @override
  String teachMochiAsks(String mascot, String question) {
    return '$mascot问：$question';
  }

  @override
  String get teachPickAnother => '换一个主题';

  @override
  String get teachNoTopics => '还没有可以教的主题';

  @override
  String teachNoTopicsPersonalDesc(String mascot) {
    return '先上传一些笔记，让$mascot有东西可学！';
  }

  @override
  String teachCouldntCheck(String mascot) {
    return '$mascot这次没能检查你的讲解';
  }

  @override
  String get teachEvalFailedFallback => '出了点问题 — 再试一次吧。';

  @override
  String get hwTitle => '功课';

  @override
  String get hwSubmit => '提交功课';

  @override
  String get hwEmptyTitle => '还没有功课';

  @override
  String get hwEmptyBody => '把你的功课拍照或以 PDF 提交，老师批改后会在这里发反馈给你。';

  @override
  String get hwBadgeFeedbackReady => '反馈已发布';

  @override
  String get hwBadgeRedo => '请重做';

  @override
  String get hwBadgeInReview => '批改中';

  @override
  String get hwHintReleasedBody => '老师已批改你的功课 — 请看下面的反馈。';

  @override
  String get hwHintReturnedTitle => '退回重做';

  @override
  String get hwHintReturnedBody => '老师请你再检查一遍，然后重新提交。';

  @override
  String get hwHintInReviewBody => '老师正在批改你的功课。反馈发布后会显示在这里。';

  @override
  String get hwTeacherFeedback => '老师的反馈';

  @override
  String get hwWhatYouSubmitted => '你提交的内容';

  @override
  String get hwFieldTitle => '标题';

  @override
  String get hwFieldTitleHint => '例如:数学练习卷 3';

  @override
  String get hwFieldSubject => '科目(可不填)';

  @override
  String get hwFieldSubjectHint => '例如:数学';

  @override
  String get hwYourWork => '你的功课';

  @override
  String get hwSubmitting => '提交中…';

  @override
  String get hwSubmitToTeacher => '提交给老师';

  @override
  String get hwReviewNote => '老师会先审阅每一份提交，然后才把反馈发给你。';

  @override
  String get hwChipScan => '扫描';

  @override
  String get hwChipPhoto => '照片';

  @override
  String get examPrepTitle => '备考';

  @override
  String get examPrepLoadError => '无法加载备考数据。';

  @override
  String get examPrepConceptMastery => '概念掌握度';

  @override
  String get examPrepEmptyTitle => '还没有备考数据';

  @override
  String get examPrepEmptyBody => '先完成一些学习模块，就能看到你的概念掌握度。';

  @override
  String get examPrepDaysUntilExam => '距离考试的天数';

  @override
  String examPrepDailyTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每天学习 $count 个模块，考试前就能学完',
    );
    return '$_temp0';
  }

  @override
  String get examPrepSelfAssessed => '自我评估';

  @override
  String get examPrepRedo => '重做';

  @override
  String get examPrepStartRevisionError => '无法开始复习，请再试一次。';

  @override
  String get commonCouldNotSaveConnection => '无法保存 — 请检查网络连接';

  @override
  String get referralTitle => '邀请朋友';

  @override
  String get referralFriendsInvited => '你邀请的朋友';

  @override
  String get referralLoadInvitesError => '无法加载你的邀请记录';

  @override
  String get referralYourCode => '你的邀请码';

  @override
  String get referralCodeCopied => '已复制邀请码';

  @override
  String referralShareMessage(String code) {
    return '来试试 Apalchi — AI 学习伙伴。注册时输入我的邀请码 $code，你完成第一次测验后，我们俩都能获得奖励星星。';
  }

  @override
  String referralActivatedOfTarget(int activated, int target) {
    return '已有 $activated/$target 位朋友激活';
  }

  @override
  String referralNextTier(int count, int bonus) {
    return '再邀请 $count 位 → 额外 +$bonus⭐ 奖励';
  }

  @override
  String get referralActivatedNote => '朋友完成第一次测验后才算“激活”。';

  @override
  String get referralEmptyInvites => '还没有邀请记录 — 分享上面的邀请码，开始吧！';

  @override
  String get referralStatusActivated => '已激活';

  @override
  String get referralStatusPending => '待激活';

  @override
  String get studyPlanTitle => '学习计划';

  @override
  String get studyPlanTodayTasks => '今日任务';

  @override
  String get studyPlanAllDone => '今天的计划完成啦！🎉 继续加油！';

  @override
  String get studyPlanComingUp => '接下来';

  @override
  String get studyPlanBubbleTitle => '这是你今天的计划！📅';

  @override
  String get studyPlanBubbleBody => '完成所有任务，保持连胜纪录，还能赚取奖励星星！';

  @override
  String get studyPlanMarkDone => '完成';

  @override
  String get studyPlanStart => '开始';

  @override
  String get studyPlanUpcoming => '即将到来';

  @override
  String get studyPlanTomorrow => '明天';

  @override
  String get studyPlanIn2Days => '后天';

  @override
  String get studyPlanUpcomingTest => '即将到来的测验';

  @override
  String studyPlanSubjectTest(String subject) {
    return '$subject测验';
  }

  @override
  String get studyPlanTestToday => '今天';

  @override
  String studyPlanDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '还剩 $days 天',
    );
    return '$_temp0';
  }

  @override
  String get studyPlanSetTestDate => '在设置里选一个测验日期，就能在这里看到倒计时。';

  @override
  String get brainHealthTitle => '大脑健康 🧠';

  @override
  String get brainHealthWikiPages => '知识页面';

  @override
  String get brainHealthWeakTopics => '薄弱主题';

  @override
  String get brainHealthScore => '大脑健康分数';

  @override
  String get brainHealthPages => '页面';

  @override
  String get brainHealthVerified => '已验证';

  @override
  String get brainHealthAvgQuality => '平均质量';

  @override
  String brainHealthErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个错误',
    );
    return '$_temp0';
  }

  @override
  String get quizDailyTitle => '每日测验';

  @override
  String quizQuestionOf(int current, int total) {
    return '第 $current 题，共 $total 题';
  }

  @override
  String quizXpEarnedLong(int xp) {
    return '获得 +$xp XP';
  }

  @override
  String get quizMasteryBreakdown => '掌握情况';

  @override
  String quizMoreItems(int count) {
    return '还有 $count 个';
  }

  @override
  String get centreJoinTitle => '加入班级';

  @override
  String get centreJoinEnterFull => '请输入完整的班级代码';

  @override
  String get centreJoinHeading => '输入班级代码';

  @override
  String get centreJoinBody => '向你的老师或补习中心询问他们控制台上的班级代码，然后在下面输入。';

  @override
  String get centreJoinYourClassFallback => '你的班级';

  @override
  String centreJoinSuccess(String className) {
    return '已加入$className 🎉';
  }

  @override
  String get centreJoinFailed => '无法加入 — 请检查代码后再试';

  @override
  String get centreJoinButton => '加入班级';

  @override
  String get assignTitle => '作业';

  @override
  String get assignPickedForYou => '为你精选';

  @override
  String get assignNotReleasedTitle => '答案尚未发布';

  @override
  String get assignNotReleasedBody => '老师还没有公布参考答案。公布后你就可以在这里对照。';

  @override
  String get assignReleasedBody => '把你的答案和下面的参考答案对照一下吧。';

  @override
  String assignQuestionNumber(int n) {
    return '第$n题';
  }

  @override
  String get assignYourAnswer => '你的答案';

  @override
  String get assignNoAnswerRecorded => '没有记录到答案';

  @override
  String get assignModelAnswer => '参考答案';

  @override
  String get assignEvaluation => '评估';

  @override
  String get assignEmptyReleased => '还没有可对照的答案';

  @override
  String get assignEmptyNotReleased => '等答案发布后再来吧';

  @override
  String get learningStyleTitle => '学习方式';

  @override
  String get learningStyleDefaultMode => '默认回答模式';

  @override
  String get learningStyleBody => '“引导我”帮助你建立理解 — 自己想出来的，记得更牢。你也可以在聊天中用开关按题切换。';

  @override
  String get learningStyleSaved => '已保存默认设置！';

  @override
  String get learningStyleRecommended => '推荐';

  @override
  String learningStyleGuideDesc(String mascot) {
    return '$mascot会引导你找到答案 — 建立真正的记忆。';
  }

  @override
  String learningStyleAnswerDesc(String mascot) {
    return '$mascot直接给出完整解答 — 适合用来检查你的功课。';
  }

  @override
  String get chatModeGuideMe => '引导我';

  @override
  String get chatModeJustAnswer => '直接给答案';

  @override
  String get chatModeTwoWays => '两种学习方式 🎓';

  @override
  String get chatModeSwitchAnyTime => '你随时可以用聊天上方的开关切换。';

  @override
  String chatModeGuideDesc(String mascot) {
    return '$mascot会用问题一步步引导你 — 答案由你自己想出来。自己发现的，记得最牢。';
  }

  @override
  String chatModeAnswerDesc(String mascot) {
    return '$mascot会直接给你完整解答。适合检查功课 — 但你记住的会比较少。';
  }

  @override
  String get chatModeDefaultGuide => '默认：引导我';

  @override
  String get chatModeGotIt => '明白了 — 开始学习吧！';

  @override
  String chatCoachTapToggle(String mascot) {
    return '点一下开关，切换$mascot帮助你的方式。';
  }

  @override
  String get chatAnswerNudge => '完整答案马上来 — 偶尔试试“引导我”，你会记得更牢。';

  @override
  String get chatEscapeGreatEffort => '很努力了！这是答案';

  @override
  String chatEscapeAddedPractice(String topic) {
    return '已把“$topic”加入你的练习清单';
  }

  @override
  String get chatHints => '提示：';

  @override
  String get chatAnswerReady => '— 可以看答案了';

  @override
  String get chatReported => '已举报';

  @override
  String get chatTabTitle => '聊天';

  @override
  String get reportThanks => '谢谢 — 我们会尽快查看';

  @override
  String get reportDoneButton => '完成';

  @override
  String get commonRetry => '重试';

  @override
  String get centreBlockTitle => '这是机构账户';

  @override
  String get centreBlockBody => 'Apalchi 应用只供学生使用。机构老师和管理者请到 apalchi.com 管理班级。';

  @override
  String get centreBlockLoginWeb => '到 apalchi.com 登录';

  @override
  String get centreBlockBackToSignIn => '返回登录';

  @override
  String avatarPickerCreateError(String mascot, String message) {
    return '无法创建$mascot — $message';
  }

  @override
  String avatarPickerTitle(String mascot) {
    return '选择你的$mascot ✨';
  }

  @override
  String get avatarPickerSubtitle => '每一只都独一无二 🍡 选一个和你一起学习的伙伴吧！';

  @override
  String get collectionTitle => '收藏';

  @override
  String collectionAlbumTitle(String mascot) {
    return '$mascot图鉴';
  }

  @override
  String createTutorWishHelp(String mascot) {
    return '你希望$mascot帮你学什么？';
  }

  @override
  String get groupCodeHint => '例如：AB23CD';

  @override
  String get joinCodeHint => '例如：5K7Q2X';

  @override
  String get moduleListTitle => '学习模块';

  @override
  String get uploadTypedNotesTip => '输入文字笔记效果最好。可以从 Google Docs 粘贴，或照着课本输入。';

  @override
  String get uploadSplitLongNotesTip => '较长的笔记建议分成几次上传，准确度会更高。';

  @override
  String voiceTalkTo(String mascot) {
    return '和$mascot说话';
  }

  @override
  String voiceExplainer(String mascot) {
    return '$mascot使用你手机的语音识别功能，把说话转成文字 — 你的语音不会被保存。';
  }

  @override
  String get voiceMicNeeded => '需要麦克风权限';

  @override
  String voiceMicGuidance(String mascot) {
    return '要和$mascot说话，请在设置里开启麦克风权限。你也可以继续用打字的方式回答。';
  }

  @override
  String get voiceNotNow => '暂时不要';

  @override
  String get voiceOpenSettings => '打开设置';

  @override
  String weaknessImproved(String topics) {
    return '你在$topics上进步了！📈';
  }

  @override
  String get weaknessFocusOn => '一起来攻克';

  @override
  String weaknessHelpPractise(String mascot) {
    return '$mascot会帮你练习这些内容。';
  }

  @override
  String tourStep1Title(String mascot) {
    return '嗨，我是$mascot！';
  }

  @override
  String get tourStep1Body => '让我快速给你看 4 个 Apalchi 和其他学习应用不一样的地方。';

  @override
  String tourStep2Title(String mascot) {
    return '每个科目都有自己的$mascot';
  }

  @override
  String tourStep2Body(String mascot) {
    return '每个科目创建一个$mascot — 它只学习你自己的笔记，所以每个回答都和老师教的完全一致。';
  }

  @override
  String get tourStep3Title => '学会它。测试它。证明它。';

  @override
  String get tourStep3Body =>
      '每个主题都是一个小任务：用卡片快速学习，用快问快答自测，再用挑战来证明 — 做错的部分，我会反复帮你复习，直到真正记牢。';

  @override
  String get tourStep4Title => '我记得你觉得难的地方';

  @override
  String get tourStep4Body => '书库会按主题记录你的掌握度。做错的内容，我会按计划间隔安排复习，直到你真正掌握。';

  @override
  String tourStep5Title(String mascot) {
    return '不是通用 AI — 是懂你笔记的$mascot。';
  }

  @override
  String get tourStep5Body => '上传你的笔记，每个回答、测验和挑战都来自你老师教的内容。';

  @override
  String get tourStep5Cta => '开始';

  @override
  String get tourBack => '← 返回';

  @override
  String get tourDone => '完成！';

  @override
  String get tourShowMe => '带我看看！';

  @override
  String get tourNext => '下一步 →';

  @override
  String get tourSkip => '跳过';

  @override
  String get moduleStageTitleLearn => '学习';

  @override
  String get moduleStageTitleTest => '测试';

  @override
  String get moduleStageTitleProve => '挑战';

  @override
  String get moduleStageTitleComplete => '完成';

  @override
  String get forceUpdateTitle => '该更新啦！';

  @override
  String get forceUpdateBody => '新版 Apalchi 已经准备好，包含重要改进。请更新后继续学习。';

  @override
  String get forceUpdateCta => '立即更新';

  @override
  String get uploadLargeFileSizeLabel => '大文件';

  @override
  String get consentGateAlmostThere => '就快好了！';

  @override
  String consentGateBody(String feature) {
    return '等大人批准你的账户后，就能使用「$feature」。我们已经发了邮件给他们 — 也可以点下面再发一次提醒。';
  }

  @override
  String get consentGateRemind => '提醒我的大人';

  @override
  String get consentGateFeatureUpload => '上传笔记';

  @override
  String consentGateFeatureCreateTutor(String mascot) {
    return '创建你自己的$mascot';
  }

  @override
  String get consentGateFeatureShareNote => '分享笔记';

  @override
  String get consentGateFeaturePersistChat => '保存对话';

  @override
  String get consentGateFeatureEarnXp => '赚取奖励';

  @override
  String get consentGateFeatureGeneric => '此功能';

  @override
  String get consentGateFinishSetup => '我们来完成账户设置，你就可以开始学习啦';

  @override
  String serverErrorRetry(int status) {
    return '服务器出错（$status）— 请再试一次';
  }

  @override
  String get consentPendingYourGrownUp => '你的大人';

  @override
  String get notifQuizTitle => '测验时间到！';

  @override
  String get notifQuizBody => '你的每日测验在等你 — 赚取 XP，保持连胜！';

  @override
  String get notifQuizChannelName => '每日测验提醒';

  @override
  String get notifQuizChannelDesc => '提醒你完成每日测验';

  @override
  String notifSrsTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name的 $count 张卡片到期了',
    );
    return '$_temp0';
  }

  @override
  String get notifSrsBodyOverdue => '花 2 分钟快速复习，把知识牢牢记住 📚';

  @override
  String get notifSrsBody => '坚持间隔复习，效果最好 💪';

  @override
  String get notifSrsChannelName => '卡片复习';

  @override
  String get notifSrsChannelDesc => '在间隔复习卡片到期时提醒你';

  @override
  String notifYourMascot(String mascot) {
    return '你的$mascot';
  }

  @override
  String deleteTutorTitle(String name) {
    return '要删除$name吗？';
  }

  @override
  String get deleteTutorBody => '这会永久删除这位导师及其所有知识、聊天记录和测验进度。此操作无法撤销。';

  @override
  String get deleteTutorKnowledgePages => '知识页面';

  @override
  String get deleteTutorChatMessages => '聊天记录';

  @override
  String get deleteTutorQuizProgress => '测验进度';

  @override
  String get deleteTutorAllDeleted => '将全部删除';

  @override
  String get deleteTutorAllLost => '将全部丢失';

  @override
  String get deleteTutorKeep => '保留导师';

  @override
  String get deleteTutorDelete => '删除';

  @override
  String get relevanceTitle => '嗯，这份材料可能不太合适！';

  @override
  String relevanceBody(String subject) {
    return '这个文件看起来和「$subject」不太相符。导师用该科目的笔记学习，效果最好。';
  }

  @override
  String get relevanceGoBack => '返回';

  @override
  String get relevanceAddAnyway => '仍要添加';

  @override
  String get routerGoHome => '回到主页';

  @override
  String get appAsyncDefaultError => '出了点问题。下拉即可重试。';

  @override
  String moduleItemsLearn(int count) {
    return '学习 $count 项';
  }

  @override
  String moduleItemsTest(int count) {
    return '测试 $count 项';
  }

  @override
  String moduleItemsProve(int count) {
    return '挑战 $count 项';
  }

  @override
  String get subReturnTitle => '订阅';

  @override
  String get subReturnSuccess => '你已是高级版用户！';

  @override
  String subReturnSuccessBody(String mascot) {
    return '一切都已解锁 — 无限个$mascot、家庭共享、家长面板等等。';
  }

  @override
  String get subReturnStartExploring => '开始探索';

  @override
  String get subReturnStillConfirming => '仍在确认中…';

  @override
  String get subReturnTimeoutBody => '你的付款可能仍在处理中。你可以过一两分钟到「设置 → 订阅」查看。';

  @override
  String get subReturnBackToApalchi => '返回 Apalchi';

  @override
  String get subReturnConfirming => '正在确认你的订阅…';

  @override
  String get webCtaDefaultIntro =>
      '订阅在 Apalchi 网站上管理。用同一个账户登录即可升级 — 你的应用会自动解锁。';

  @override
  String get webCtaContinueOnWeb => '在网页上继续';

  @override
  String get webCtaCouldntOpenBrowser => '无法打开你的浏览器。点上面的「复制链接」再粘贴。';

  @override
  String get webCtaEmailFailNow => '暂时无法发送 — 请改用上面的复制链接。';

  @override
  String get webCtaEmailBothSent => '已发送！请查收电子邮件 — 我们也推送了一条带链接的通知。';

  @override
  String get webCtaEmailSent => '已发送！请到电子邮件查收链接。';

  @override
  String get webCtaPushSent => '已给你推送一条带链接的通知。';

  @override
  String get webCtaRateLimited => '你已请求了几次 — 请稍后再试。';

  @override
  String get webCtaEmailError => '无法发送链接。请检查网络连接后重试。';

  @override
  String get webCtaNotActiveYet => '尚未生效。请在浏览器完成结账，然后再点一次。';

  @override
  String get webCtaCopied => '已复制';

  @override
  String get webCtaCopyLink => '复制链接';

  @override
  String get webCtaSending => '发送中…';

  @override
  String get webCtaEmailLink => '把链接发到我的邮箱';

  @override
  String get webCtaChecking => '检查中…';

  @override
  String get webCtaUpgradedRefresh => '我已升级 — 刷新';

  @override
  String trialTimeHoursLeft(int hours) {
    return '还剩 $hours 小时';
  }

  @override
  String trialTimeDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '还剩 $days 天',
    );
    return '$_temp0';
  }

  @override
  String trialBannerUrgent(String mascot, String time) {
    return '高级版最后一天！⏳ $time — 记得保留你的$mascot。';
  }

  @override
  String trialBannerWarning(String mascot, String time) {
    return '$time的高级版 — 订阅即可保留你所有的$mascot。';
  }

  @override
  String trialBannerCalm(String mascot, String time) {
    return '$time的高级版 · 喜欢无限个$mascot吗？之后也留住它们。';
  }

  @override
  String get trialKeepPremium => '保留高级版';

  @override
  String get trialWhenEnds => '试用结束后：';

  @override
  String trialLockMochis(String mascot) {
    return '🔒 额外的$mascot被锁定（你保留 1 个免费）';
  }

  @override
  String get trialLockChat => '💬 聊天限制为每天 80 条（原本无限）';

  @override
  String get trialLockQuiz => '📊 高级测验和学习计划受限';

  @override
  String get trialWelcomeTitle => '🎁 高级版免费畅享\n7 天！';

  @override
  String get trialWelcomeSubtitle => '无需信用卡。结束前我们会提醒你。';

  @override
  String trialWelcomePerk1Title(String mascot) {
    return '无限个$mascot';
  }

  @override
  String trialWelcomePerk1Sub(String mascot) {
    return '每个学习科目都能有一个$mascot';
  }

  @override
  String get trialWelcomePerk2Title => '无限畅聊';

  @override
  String get trialWelcomePerk2Sub => '随时想问就问 — 没有每日限制';

  @override
  String get trialWelcomePerk3Title => '完整的记忆卡和测验';

  @override
  String get trialWelcomePerk3Sub => '所有功能，毫无限制';

  @override
  String get trialWelcomeStart => '开始探索吧！🚀';

  @override
  String get trialWelcomeSubscribeNow => '立即订阅';

  @override
  String get trialExpiredTitle => '你的免费一周结束啦！⏰';

  @override
  String trialExpiredBody(String mascot) {
    return '你所有的$mascot都还在 — 没有删除任何东西。订阅即可全部保留，或选一个继续免费使用。';
  }

  @override
  String trialExpiredKeepAll(String mascot) {
    return '⭐ 保留你所有的$mascot';
  }

  @override
  String trialExpiredPerks(String mascot) {
    return '无限个$mascot、无限畅聊、完整的记忆卡和测验。';
  }

  @override
  String get trialExpiredUpTo4Kids => '最多 4 个孩子';

  @override
  String trialExpiredOrContinue(String mascot) {
    return '或者 — 继续免费使用 1 个$mascot';
  }

  @override
  String trialExpiredPickBody(String mascot) {
    return '选择保留哪个$mascot继续使用。其余的会被锁定（🔒）但不会删除 — 订阅后立即恢复。';
  }

  @override
  String trialExpiredContinueWith(String name) {
    return '继续免费使用 $name';
  }

  @override
  String trialKeeperFallback(String mascot) {
    return '1 个$mascot';
  }

  @override
  String get subPlansChooseTitle => '选择你的方案';

  @override
  String get subPlansLoadError => '无法加载订阅信息。请重试。';

  @override
  String get subPlansYourSubscription => '你的订阅';

  @override
  String get subPlansUpgradeTitle => '升级 Apalchi';

  @override
  String get subPlansProSubtitle => '1 名学生 · 全部 AI 功能';

  @override
  String get subPlansMaxSubtitle => '1 名学生 · 更聪明的 AI，攻克难题';

  @override
  String get subPlansFamilySubtitle => '最多 4 名学生';

  @override
  String get subPlansProFeat1 => '每天 100 条 AI 消息';

  @override
  String subPlansProFeat2(String mascot) {
    return '最多 5 个$mascot';
  }

  @override
  String get subPlansProFeat3 => '测验和记忆卡';

  @override
  String get subPlansProFeat4 => '功课拍照扫描';

  @override
  String get subPlansMaxFeat1 => '无限 AI 消息';

  @override
  String subPlansMaxFeat2(String mascot) {
    return '无限个$mascot';
  }

  @override
  String get subPlansMaxFeat3 => 'Sonnet 模型应对复杂问题';

  @override
  String get subPlansMaxFeat4 => '所有 Pro 功能';

  @override
  String get subPlansFamilyFeat1 => 'Max 的全部功能';

  @override
  String get subPlansFamilyFeat2 => '最多 4 个孩子账户';

  @override
  String get subPlansFamilyFeat3 => '家长面板';

  @override
  String get subPlansFamilyFeat4 => '共享星星奖励';

  @override
  String get subPlansBadgeExams => '备考首选';

  @override
  String get subPlansBadgePopular => '最受欢迎';

  @override
  String get subPlansBestValue => '最划算';

  @override
  String get subPlansCurrent => '当前';

  @override
  String get subPlansMonthly => '每月';

  @override
  String get subPlansAnnual => '每年 （省约 34%）';

  @override
  String subPlansFreeFeatures(String mascot) {
    return '每天 20 条消息 · 1 个$mascot · 基础功能';
  }

  @override
  String get subPlansCentreBanner => '⭐ 由你的中心提供的高级版';

  @override
  String subPlansHeaderCentre(String mascot) {
    return '你的高级版由你的中心提供。尽情享受无限畅聊和无限个$mascot吧！';
  }

  @override
  String subPlansHeaderTrial(int days, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '你的免费试用还剩 $_temp0。订阅即可保留你所有的$mascot。';
  }

  @override
  String subPlansHeaderPremium(String tier) {
    return '你当前是$tier。可随时在网页上管理或取消。';
  }

  @override
  String get subPlansHeaderFree => '先开始 7 天免费试用。可随时取消。';

  @override
  String get subPlansManageIntro => '在 Apalchi 网站上管理你的方案、更新银行卡，或随时取消。';

  @override
  String get subPlansManageOnWeb => '在网页上管理';

  @override
  String paywallHeadCreateTutor(String mascot) {
    return '想要更多$mascot吗？';
  }

  @override
  String get paywallHeadUpload => '需要上传更多吗？';

  @override
  String get paywallHeadCompile => '已编译你所有的章节';

  @override
  String get paywallHeadChat => '今天的聊天次数已用完';

  @override
  String get paywallHeadParent => '家长面板是高级版功能';

  @override
  String get paywallHeadCurriculum => '课程学习路径是高级版功能';

  @override
  String get paywallHeadFreeze => '累积更多连胜冻结';

  @override
  String get paywallHeadGroups => '学习小组是高级版功能';

  @override
  String get paywallHeadAddStudent => '需要更多学生账户吗？';

  @override
  String get paywallHeadDefault => '解锁 Apalchi 高级版';

  @override
  String paywallSubCreateTutor(String mascot) {
    return '免费用户可拥有 1 个$mascot。订阅高级版即可拥有无限个$mascot，让每个科目都有自己的$mascot。或者升到 5 级，解锁下一个$mascot名额！';
  }

  @override
  String paywallSubUpload(String mascot) {
    return '上传次数无限 — 免费或高级版都一样。限制的是你能拥有多少个$mascot。高级版让你每个科目都能有一个。';
  }

  @override
  String paywallSubCompile(String mascot) {
    return '大文件会拆分成章节，让你选择$mascot要读哪些。免费方案每月包含少量章节编译；高级版方案则多得多 — 按滚动的 30 天重置。';
  }

  @override
  String get paywallSubChat => '免费用户每天可聊 20 次。Pro 将上限提高到 100；Max 及以上则完全取消上限。';

  @override
  String get paywallSubParent => '家长可以追踪进度、设定目标，并查看每周报告。';

  @override
  String get paywallSubCurriculum => '用贴合教学大纲的学习路径，提前规划每个主题。';

  @override
  String get paywallSubFreeze => '高级版让你最多累积 3 个连胜冻结，这样漏了一天也不会中断连胜。';

  @override
  String get paywallSubGroups => '在共享学习小组里和同学一起学习。Pro 及以上可用。';

  @override
  String get paywallSubAddStudent => '家庭方案最多支持 4 名学生。中心方案最多支持 15 名学生。';

  @override
  String paywallSubDefault(String mascot) {
    return '尽享 Apalchi 的全部功能 — 无限个$mascot、家庭共享、高级分析。';
  }

  @override
  String paywallPerk1(String mascot) {
    return '无限个$mascot + 上传';
  }

  @override
  String get paywallPerk2 => '每天无限畅聊';

  @override
  String get paywallPerk3 => '家庭共享 — 最多 4 个孩子';

  @override
  String get paywallPerk4 => '家长面板 + 每周报告';

  @override
  String get paywallPerk5 => '3 个连胜冻结（原本 1 个）';

  @override
  String get paywallSeePlans => '查看方案';

  @override
  String get paywallMaybeLater => '以后再说';
}
