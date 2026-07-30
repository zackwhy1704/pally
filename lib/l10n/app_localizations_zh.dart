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
}
