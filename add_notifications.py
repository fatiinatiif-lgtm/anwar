import os, re, sys

mode = sys.argv[1] if len(sys.argv) > 1 else ''

# ======================================================================
# الوضع الأول: dart  ->  يضيف كود الإشعارات لملف main.dart
#   python3 add_notifications.py dart lib/main.dart
# ======================================================================
DART_CODE = r'''

// ---------- التذكيرات: إشعار كل ساعتين ----------
const reminderMessages = [
  'صل على الحبيب محمد ﷺ',
  'اقرأ صلوات الأنوار على سيد الأبرار تلق الهنا والسعد والأسرار',
  'دندن بمديح المصطفى ﷺ',
  'هل قمت بإنهاء ورد منهج الصلاة، هيا قم وسارع، فالحبيبﷺ قريب يرد السلام عليك',
  'ألا تقرأ في مدح رسول الله؟!',
  'اقرأ مناجاة الأشواق',
  'أتمم ما بدأت قراءته',
  'اتخذ لك وردا يوميا من هذه الأنوار، لتنور حياتك وروحك',
  'افتح عداد الصلاة على الحبيب ﷺ واختر صيغة واذكر ألفاً وألفينَ وثلاثة وزد.',
];

// الإشعارات طول اليوم (بدون ساعات راحة)
const reminderQuietFrom = 24;
const reminderQuietTo = 0;

final FlutterLocalNotificationsPlugin _notifPlugin = FlutterLocalNotificationsPlugin();

Future<void> initReminders() async {
  try {
    tzdata.initializeTimeZones();
    await _notifPlugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    await _notifPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await scheduleReminders();
  } catch (e) {
    debugPrint('reminders error: $e');
  }
}

// نجدول إشعارات الأسبوع القادم دفعة واحدة (كل ساعتين)، وكل مرة يُفتح فيها التطبيق نعيد الجدولة
Future<void> scheduleReminders() async {
  await _notifPlugin.cancelAllPendingNotifications();
  final rnd = math.Random();
  var last = -1;
  var id = 1;
  for (var k = 1; k <= 84; k++) {
    final t = DateTime.now().add(Duration(hours: 2 * k));
    final quiet = t.hour >= reminderQuietFrom || t.hour < reminderQuietTo;
    if (quiet) continue;
    var i = rnd.nextInt(reminderMessages.length);
    if (i == last) i = (i + 1) % reminderMessages.length;
    last = i;
    final msg = reminderMessages[i];
    await _notifPlugin.zonedSchedule(
      id: id++,
      title: 'مكتبة الأنوار المحمدية',
      body: msg,
      scheduledDate: tz.TZDateTime.from(t, tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'anwar_reminders',
          'تذكيرات الأنوار',
          channelDescription: 'تذكير كل ساعتين بالصلاة على الحبيب ﷺ',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(msg),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
'''

def patch_dart(path):
    s = open(path, encoding='utf-8').read()
    if 'initReminders' in s:
        print('reminders already added')
        return
    imports = (
        "import 'dart:math' as math;\n"
        "import 'package:flutter_local_notifications/flutter_local_notifications.dart';\n"
        "import 'package:timezone/data/latest_all.dart' as tzdata;\n"
        "import 'package:timezone/timezone.dart' as tz;\n"
    )
    m = list(re.finditer(r"^import .*;\s*$", s, re.M))
    if not m:
        sys.exit('ERROR: no imports found in main.dart')
    last = m[-1]
    s = s[:last.end()] + "\n" + imports.rstrip("\n") + s[last.end():]
    if not re.search(r"\n(\s*)runApp\(", s):
        sys.exit('ERROR: could not find runApp( in main.dart')
    s = re.sub(r"\n(\s*)runApp\(", r"\n\1initReminders();\n\1runApp(", s, count=1)
    s += DART_CODE
    open(path, 'w', encoding='utf-8').write(s)
    print('reminders added to main.dart')

# ======================================================================
# الوضع التاني: android  ->  يجهّز ملفات أندرويد (لازم يشتغل بعد flutter create)
#   python3 add_notifications.py android
# ======================================================================
RECEIVERS = '''
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
'''

def patch_manifest():
    p = 'android/app/src/main/AndroidManifest.xml'
    s = open(p, encoding='utf-8').read()
    if 'ScheduledNotificationReceiver' in s:
        print('manifest already patched')
        return
    m = re.search(r"<manifest[^>]*>", s)
    if not m or '</application>' not in s:
        sys.exit('ERROR: unexpected AndroidManifest.xml')
    perm = '\n    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>'
    s = s[:m.end()] + perm + s[m.end():]
    s = s.replace('</application>', RECEIVERS + '    </application>', 1)
    open(p, 'w', encoding='utf-8').write(s)
    print('manifest patched')

def patch_gradle():
    kts = 'android/app/build.gradle.kts'
    groovy = 'android/app/build.gradle'
    if os.path.exists(kts):
        p, is_kts = kts, True
    elif os.path.exists(groovy):
        p, is_kts = groovy, False
    else:
        sys.exit('ERROR: app build.gradle not found')
    s = open(p, encoding='utf-8').read()
    if 'esugaring' not in s:
        if not re.search(r"compileOptions\s*\{", s):
            sys.exit('ERROR: compileOptions block not found in ' + p)
        flag = 'isCoreLibraryDesugaringEnabled = true' if is_kts else 'coreLibraryDesugaringEnabled true'
        s = re.sub(r"(compileOptions\s*\{)", lambda m: m.group(1) + "\n        " + flag, s, count=1)
        if is_kts:
            s += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
        else:
            s += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
    # الإضافة محتاجة جافا 17
    s = s.replace('JavaVersion.VERSION_11', 'JavaVersion.VERSION_17').replace('JavaVersion.VERSION_1_8', 'JavaVersion.VERSION_17')
    open(p, 'w', encoding='utf-8').write(s)
    print('gradle patched:', p)

def patch_keep():
    os.makedirs('android/app/src/main/res/raw', exist_ok=True)
    open('android/app/src/main/res/raw/keep.xml', 'w', encoding='utf-8').write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources xmlns:tools="http://schemas.android.com/tools" tools:keep="@mipmap/ic_launcher" />\n')
    print('keep.xml written')

if mode == 'dart':
    patch_dart(sys.argv[2])
elif mode == 'android':
    patch_manifest()
    patch_gradle()
    patch_keep()
else:
    sys.exit('usage: add_notifications.py dart <main.dart> | android')
