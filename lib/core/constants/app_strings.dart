/// All user-facing (Arabic) strings in one place.
abstract final class AppStrings {
  // App
  static const String appName = 'ملاحظاتي';
  static const String appShortName = 'ملاحظاتي';
  static const String appSubtitle = 'إصدار ٢٫٠ • تخزين محلي على الجهاز';
  static const String localBadge = 'محلي';
  static const String localOnly = 'محلي فقط';
  static const String savedLocally = 'محفوظة محلياً';

  // Home
  static const String searchHint = 'البحث في ملاحظاتك...';
  static const String pinned = 'المثبتة';
  static const String others = 'أخرى';
  static const String notesCountSuffix = 'ملاحظة';
  static const String filterAll = 'الكل';
  static const String filterAudio = 'صوتيات';
  static const String filterChecklists = 'قوائم مهام';
  static const String filterAttachments = 'مرفقات وصور';
  static const String filterDrawings = 'رسومات';
  static const String gridView = 'عرض شبكي';
  static const String listView = 'عرض قائمة';
  static const String openMenu = 'القائمة';
  static const String newNote = 'ملاحظة جديدة';
  static const String editNote = 'تعديل الملاحظة';
  static const String newChecklist = 'قائمة جديدة';
  static const String newDrawing = 'رسم جديد';
  static const String newVoice = 'تسجيل صوتي';
  static const String newImage = 'صورة جديدة';
  static const String emptyNotes = 'الملاحظات التي تضيفها ستظهر هنا';
  static const String emptySearch = 'لا توجد نتائج مطابقة';
  static const String emptyArchive = 'الملاحظات المؤرشفة ستظهر هنا';
  static const String emptyTrash = 'لا توجد ملاحظات في سلة المهملات';
  static const String emptyTrashAction = 'إفراغ السلة';
  static const String emptyTrashConfirm =
      'سيتم حذف كل الملاحظات في السلة نهائياً مع مرفقاتها. هل تريد المتابعة؟';
  static const String trashHint =
      'الملاحظات هنا يمكن استعادتها أو حذفها نهائياً';
  static const String tagPrefix = '#';

  // Multi-select
  static const String selectedSuffix = 'محددة';
  static const String selectAll = 'تحديد الكل';
  static const String clearSelection = 'إلغاء التحديد';
  static const String deleteSelectedConfirm =
      'سيتم حذف الملاحظات المحددة نهائياً مع مرفقاتها. لا يمكن التراجع.';
  static const String dragHandle = 'اسحب لإعادة الترتيب';

  // Drawer
  static const String mainNotes = 'الملاحظات الرئيسية';
  static const String voiceRecordings = 'التسجيلات الصوتية';
  static const String checklists = 'القوائم والمهام';
  static const String drawings = 'الرسومات الحرة';
  static const String labels = 'التصنيفات والوسوم';
  static const String noLabels = 'أضف وسوماً لملاحظاتك لتظهر هنا';
  static const String localStorage = 'التخزين المحلي على الهاتف';
  static const String localStorageSubtitle = 'قاعدة بيانات Hive محلية';
  static const String usedSpace = 'المساحة المستهلكة محلياً';
  static const String storageAudio = 'صوتيات';
  static const String storageImages = 'صور';
  static const String storageText = 'نصوص وملفات';
  static const String backup = 'نسخ احتياطي محلي (ملف Zip)';
  static const String restore = 'استعادة نسخة من الذاكرة';
  static const String archive = 'الأرشيف والمحفوظات';
  static const String trash = 'سلة المهملات';
  static const String darkMode = 'المظهر الليلي';
  static const String darkModeSubtitle = 'تغيير السمة حسب رغبتك';
  static const String followSystem = 'حسب النظام';
  static const String themeColor = 'لون التطبيق';
  static const String about = 'حول التطبيق';
  static const String aboutBody =
      'تطبيق ملاحظات يعمل بالكامل دون إنترنت. كل الملاحظات والصور والملفات والتسجيلات تُحفظ على جهازك فقط.';
  static const String privacy = 'الخصوصية';
  static const String openPrivacyPolicy = 'عرض سياسة الخصوصية';
  static const String privacyBody =
      'تُحفظ الملاحظات والمرفقات والتسجيلات على جهازك. لا ينشئ التطبيق حساباً ولا يرسل محتواك إلى خوادم. يمكنك تصدير نسخة احتياطية إلى مكان تختاره أو حذف الملاحظات من التطبيق.';

  // Editor
  static const String titleHint = 'العنوان';
  static const String contentHint = 'ملاحظة...';
  static const String listItemHint = 'عنصر في القائمة';
  static const String addListItem = 'إضافة عنصر';
  static const String completedItems = 'عناصر مكتملة';
  static const String attachments = 'المرفقات والصور';
  static const String voiceNotes = 'الملاحظات الصوتية';
  static const String addTag = 'إضافة وسم';
  static const String tagHint = 'اسم الوسم';
  static const String autoSaved = 'تم الحفظ تلقائياً';
  static const String done = 'تم';
  static const String edited = 'آخر تعديل';
  static const String pin = 'تثبيت';
  static const String unpin = 'إلغاء التثبيت';
  static const String archiveAction = 'أرشفة';
  static const String unarchive = 'إلغاء الأرشفة';
  static const String delete = 'حذف';
  static const String moveToTrash = 'نقل إلى السلة';
  static const String shareNote = 'مشاركة';
  static const String copyText = 'نسخ النص';
  static const String duplicateNote = 'إنشاء نسخة';
  static const String textCopied = 'تم نسخ النص';
  static const String noteDuplicated = 'تم إنشاء نسخة من الملاحظة';
  static const String checkedBox = '☑';
  static const String uncheckedBox = '☐';
  static const String notesSeparator = '\n\n────────\n\n';
  static const String nothingToShare = 'لا يوجد نص للمشاركة';
  static const String restoreNote = 'استعادة';
  static const String deleteForever = 'حذف نهائي';
  static const String deleteForeverConfirm =
      'سيتم حذف الملاحظة ومرفقاتها نهائياً. لا يمكن التراجع.';
  static const String makeCopy = 'إنشاء نسخة';
  static const String changeColor = 'لون الملاحظة';
  static const String colorDefault = 'افتراضي';
  static const String checklistMode = 'قائمة مهام';
  static const String textMode = 'نص عادي';
  static const String drawing = 'رسم';
  static const String record = 'تسجيل صوتي';
  static const String gallery = 'المعرض';
  static const String camera = 'الكاميرا';
  static const String attachFile = 'إرفاق ملف';
  static const String addImage = 'إضافة صورة';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String add = 'إضافة';
  static const String back = 'رجوع';
  static const String more = 'المزيد';
  static const String emptyNoteDiscarded = 'تم تجاهل الملاحظة الفارغة';
  static const String movedToTrash = 'تم نقل الملاحظة إلى السلة';
  static const String archived = 'تمت الأرشفة';
  static const String undo = 'تراجع';

  // Recorder
  static const String voiceNote = 'ملاحظة صوتية';
  static const String recordingLocal = 'تخزين محلي مباشر • AAC';
  static const String recording = 'جاري التسجيل...';
  static const String paused = 'متوقف مؤقتاً';
  static const String tapToRecord = 'اضغط للبدء في التسجيل';
  static const String saveRecording = 'حفظ الملاحظة الصوتية';
  static const String discard = 'تجاهل';
  static const String pause = 'إيقاف مؤقت';
  static const String resume = 'استئناف';
  static const String play = 'تشغيل';
  static const String speed = 'السرعة';
  static const String recordingPrefix = 'تسجيل';

  // Drawing
  static const String drawingTitle = 'رسم حر';
  static const String undoStroke = 'تراجع';
  static const String redoStroke = 'إعادة';
  static const String clearCanvas = 'مسح اللوحة';
  static const String eraser = 'ممحاة';
  static const String strokeWidth = 'سُمك الخط';
  static const String saveDrawing = 'حفظ الرسم';
  static const String emptyDrawing = 'اللوحة فارغة';

  // Backup
  static const String backupDone = 'تم حفظ النسخة الاحتياطية بنجاح';
  static const String restoreDone = 'تمت استعادة الملاحظات بنجاح';
  static const String backupWorking = 'جاري تجهيز النسخة الاحتياطية...';
  static const String restoreWorking = 'جاري الاستعادة...';

  // Errors
  static const String errorGeneric = 'حدث خطأ غير متوقع، حاول مرة أخرى';
  static const String errorLoad = 'تعذر تحميل الملاحظات';
  static const String errorSave = 'تعذر حفظ الملاحظة';
  static const String errorShare = 'تعذرت مشاركة الملاحظة';
  static const String errorDelete = 'تعذر حذف الملاحظة';
  static const String errorMedia = 'تعذر حفظ الملف على الجهاز';
  static const String errorOpenFile = 'لا يوجد تطبيق لفتح هذا الملف';
  static const String errorFileMissing = 'الملف غير موجود على الجهاز';
  static const String errorPlayback = 'تعذر تشغيل التسجيل';
  static const String errorRecording = 'تعذر بدء التسجيل';
  static const String errorMicPermission =
      'يرجى السماح بالوصول إلى الميكروفون من الإعدادات';
  static const String errorCameraPermission =
      'يرجى السماح بالوصول إلى الكاميرا أو الصور';
  static const String errorPicker = 'تعذر اختيار الملف';
  static const String errorBackup = 'تعذر إنشاء النسخة الاحتياطية';
  static const String errorRestore = 'ملف النسخة الاحتياطية غير صالح';
  static const String errorDrawing = 'تعذر حفظ الرسم';
  static const String errorSettings = 'تعذر حفظ الإعدادات';
  static const String errorScreen = 'تعذر عرض هذا الجزء';

  // Dates
  static const String today = 'اليوم';
  static const String yesterday = 'أمس';
  static const String am = 'ص';
  static const String pm = 'م';
  static const List<String> months = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  // File sizes
  static const String bytes = 'بايت';
  static const String kiloBytes = 'كيلوبايت';
  static const String megaBytes = 'ميجابايت';
  static const String gigaBytes = 'جيجابايت';
}
