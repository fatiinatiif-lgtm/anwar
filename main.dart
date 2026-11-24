import 'dart:async';
import 'dart:math' as dmath;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
const levelNames = ['الأول','الثاني','الثالث','الرابع','الخامس'];
const hijriMonths = ['محرم','صفر','ربيع الأول','ربيع الآخر','جمادى الأولى','جمادى الآخرة','رجب','شعبان','رمضان','شوال','ذو القعدة','ذو الحجة'];

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

// ---------- الألوان ----------
class AppPalette {
  final String name;
  final Color primary, accent, third, bg;
  // primary = اللون الأساسي، accent = لون مميّز فاتح، third = لون ثالث بيتمزج معاهم في التدرّجات
  const AppPalette(this.name, this.primary, this.accent, this.third, this.bg);
}

const palettes = [
  AppPalette('الأخضر والذهبي', Color(0xFF0B5D3B), Color(0xFFC9A227), Color(0xFF2E8B6E), Color(0xFFFBF7EC)),
  AppPalette('الزمرد والمرجان', Color(0xFF0B6B4A), Color(0xFFFF8A75), Color(0xFF26A69A), Color(0xFFF3FAF6)),
  AppPalette('الفيروز والخوخ', Color(0xFF00796B), Color(0xFFFFAB91), Color(0xFF7E57C2), Color(0xFFF0F8F7)),
  AppPalette('الأزرق والمرجان', Color(0xFF1565C0), Color(0xFFFF8A65), Color(0xFF00ACC1), Color(0xFFF2F7FD)),
  AppPalette('الكحلي والتركواز', Color(0xFF1B2A49), Color(0xFF4FD1C5), Color(0xFFEC6F8F), Color(0xFFF4F5F9)),
  AppPalette('البنفسجي والنعناع', Color(0xFF5E35B1), Color(0xFF6EE7B7), Color(0xFFEC407A), Color(0xFFF6F2FB)),
  AppPalette('الأرجواني والليموني', Color(0xFF7B1FA2), Color(0xFFC5E85A), Color(0xFF039BE5), Color(0xFFF8F1FB)),
  AppPalette('العنابي والتركواز', Color(0xFF8E1B2D), Color(0xFF5FD3D9), Color(0xFFE57399), Color(0xFFFCF4F5)),
  AppPalette('الوردي والأخضر', Color(0xFFAD1457), Color(0xFF81C784), Color(0xFFF57C00), Color(0xFFFDF2F6)),
  AppPalette('البرتقالي والسماوي', Color(0xFFD84315), Color(0xFF6EDCEB), Color(0xFF5C6BC0), Color(0xFFFFF6EE)),
  AppPalette('الأحمر والتركواز', Color(0xFFC62828), Color(0xFF7BEAD9), Color(0xFF5E35B1), Color(0xFFFDF3F3)),
  AppPalette('الزيتي والوردي', Color(0xFF556B2F), Color(0xFFF9A8C9), Color(0xFF8D6E63), Color(0xFFF6F7EE)),
  AppPalette('النيلي والمشمشي', Color(0xFF3F51B5), Color(0xFFFFB38A), Color(0xFF26A69A), Color(0xFFF4F5FC)),
  AppPalette('الأزرق الملكي والنعناع', Color(0xFF1E3A8A), Color(0xFF9AF0B8), Color(0xFFD81B60), Color(0xFFF3F6FD)),
  AppPalette('البترولي والمرجان', Color(0xFF0B525B), Color(0xFFFF9A8B), Color(0xFFF9A825), Color(0xFFEFF7F8)),
  AppPalette('الخمري والنعناع', Color(0xFF6B1F3A), Color(0xFF80E4C8), Color(0xFFB565A7), Color(0xFFFBF3F6)),
  AppPalette('الغابة والخزامى', Color(0xFF14532D), Color(0xFFCDB8FF), Color(0xFFE76F8A), Color(0xFFF1F8F3)),
  AppPalette('الفحمي والنيون', Color(0xFF263238), Color(0xFF6EF0B0), Color(0xFF29B6F6), Color(0xFFF2F4F5)),
  AppPalette('البني والفيروزي', Color(0xFF5D4037), Color(0xFF59D6C6), Color(0xFFEF8A5F), Color(0xFFFAF5F0)),
  AppPalette('السماوي والوردي', Color(0xFF0277BD), Color(0xFFFF9FC6), Color(0xFF26C6DA), Color(0xFFF0F8FD)),
  AppPalette('الليلكي والأخضر', Color(0xFF6A4FA3), Color(0xFFA8F0CF), Color(0xFFFB8C00), Color(0xFFF7F4FC)),
  AppPalette('الفوشيا والسماوي', Color(0xFFA21CAF), Color(0xFF8AD8FF), Color(0xFFF9A825), Color(0xFFFDF4FF)),
  AppPalette('التراكوتا والأزرق', Color(0xFFB5523B), Color(0xFF94D5EA), Color(0xFF2E8B8B), Color(0xFFFBF4F0)),
  AppPalette('الأخضر والزهري', Color(0xFF2E7D5B), Color(0xFFFFB6CB), Color(0xFF0288D1), Color(0xFFF2FAF5)),
  AppPalette('الزمردي والأرجواني', Color(0xFF047857), Color(0xFFCFA2FF), Color(0xFFF59E0B), Color(0xFFF0FBF6)),
  AppPalette('الليلي والليموني', Color(0xFF172554), Color(0xFFC3F26B), Color(0xFF0EA5E9), Color(0xFFF1F4FB)),
  AppPalette('الأرجواني والبرتقالي', Color(0xFF701A75), Color(0xFFFFBF80), Color(0xFF14B8A6), Color(0xFFFBF2FC)),
  AppPalette('الوردي الداكن والتركواز', Color(0xFF9D174D), Color(0xFF72E6F2), Color(0xFF84CC16), Color(0xFFFDF2F8)),
  AppPalette('الكاكي والخوخ', Color(0xFF6B705C), Color(0xFFFFB9AB), Color(0xFF4F9DA6), Color(0xFFF6F6F1)),
  AppPalette('الفولاذي والكهرماني', Color(0xFF334E68), Color(0xFFFFC77D), Color(0xFF3FB68B), Color(0xFFF3F6F9)),
  AppPalette('الأسود والنعناع', Color(0xFF1C1C1C), Color(0xFF8FF0CB), Color(0xFFFF6B9A), Color(0xFFF7F6F2)),
  AppPalette('الأزرق والمشمشي والوردي', Color(0xFF4C6EF5), Color(0xFFFFC078), Color(0xFFF06595), Color(0xFFF4F6FF)),
  AppPalette('الغروب', Color(0xFF7B2D5B), Color(0xFFFFA574), Color(0xFFFF5D8F), Color(0xFFFCF3F7)),
  AppPalette('المحيط', Color(0xFF0D4F7A), Color(0xFF62E3E8), Color(0xFF2BB673), Color(0xFFF0F7FB)),
  AppPalette('الربيع', Color(0xFF2F7D32), Color(0xFFFF9DBA), Color(0xFFFBC02D), Color(0xFFF3FAF1)),
  AppPalette('الكحلي والذهبي', Color(0xFF1B2A49), Color(0xFFD4AF37), Color(0xFF3F6FB5), Color(0xFFF4F5F9)),
];

final paletteIndex = ValueNotifier<int>(0);
final hijriOffset = ValueNotifier<int>(0);

class PaletteExt extends ThemeExtension<PaletteExt> {
  final Color primary, accent, third;
  const PaletteExt(this.primary, this.accent, this.third);
  @override
  PaletteExt copyWith({Color? primary, Color? accent, Color? third}) =>
      PaletteExt(primary ?? this.primary, accent ?? this.accent, third ?? this.third);
  @override
  PaletteExt lerp(ThemeExtension<PaletteExt>? other, double t) {
    if (other is! PaletteExt) return this;
    return PaletteExt(Color.lerp(primary, other.primary, t)!, Color.lerp(accent, other.accent, t)!, Color.lerp(third, other.third, t)!);
  }
}

Color pri(BuildContext c) => Theme.of(c).extension<PaletteExt>()?.primary ?? const Color(0xFF0B5D3B);
Color sec(BuildContext c) => Theme.of(c).extension<PaletteExt>()?.accent ?? const Color(0xFFC9A227);
Color tri(BuildContext c) => Theme.of(c).extension<PaletteExt>()?.third ?? const Color(0xFF2E8B6E);
Color accent(BuildContext c) => isDark(c) ? sec(c) : pri(c);
// ألوان متنوّعة للأيقونات: بتلف بين اللون الأساسي والمميّز والثالث
Color mixIcon(BuildContext c, int i) {
  final list = [accent(c), tri(c), sec(c)];
  return list[i % list.length];
}
void toggleDark() {
  final d = themeMode.value != ThemeMode.dark;
  themeMode.value = d ? ThemeMode.dark : ThemeMode.light;
  Repo.prefs.setBool('dark', d);
}

int _jdn(int y, int m, int d) {
  final a = (14 - m) ~/ 12, yy = y + 4800 - a, mm = m + 12 * a - 3;
  return d + (153 * mm + 2) ~/ 5 + 365 * yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
}

int _i2jd(int y, int m, int d) => d + (59 * (m - 1) + 1) ~/ 2 + (y - 1) * 354 + (3 + 11 * y) ~/ 30 + 1948440 - 1;

String hijriText(DateTime t) {
  final jd = _jdn(t.year, t.month, t.day);
  final hy = (30 * (jd - 1948440) + 10646) ~/ 10631;
  final x = jd - (29 + _i2jd(hy, 1, 1));
  var hm = (2 * x + 58) ~/ 59 + 1;
  if (hm > 12) hm = 12;
  final hd = jd - _i2jd(hy, hm, 1) + 1;
  return '$hd ${hijriMonths[hm - 1]} $hy هـ';
}

// التاريخ الهجري بعد تطبيق التعديل (زيادة أو نقص أيام) اللي اختاره المستخدم
String hijriNow(DateTime t) => hijriText(DateTime(t.year, t.month, t.day + hijriOffset.value));

class Book {
  final String id, title;
  const Book(this.id, this.title);
  String get pdf => 'assets/books/$id.pdf';
  String get cover => 'assets/covers/$id.jpg';
}

// كتيّب التعريف بمنهج الصلاة (بيتفتح من تبويب منهج الصلاة، مش من قايمة الكتب)
const manhajBook = Book('manhaj', 'تعرف على منهج الصلاة');

class Entry {
  final String book, title;
  final int page;
  Entry(this.book, this.title, this.page);
  String get key => '$book|$page|$title';
  static Entry? parse(String s) {
    final p = s.split('|');
    if (p.length < 3) return null;
    return Entry(p[0], p.sublist(2).join('|'), int.tryParse(p[1]) ?? 1);
  }
}

String norm(String s) => s
    .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u0640«»]'), '')
    .replaceAll(RegExp('[إأآٱ]'), 'ا')
    .replaceAll('ى', 'ي').replaceAll('ة', 'ه').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي')
    .trim();

class Repo {
  static const books = [
    Book('mesk', 'مسك الكلام في مدح خير الأنام'),
    Book('menhatu', 'منحة الله العلي القدير في مولد السراج المنير'),
    Book('tagaliyat', 'تجليات الكتاب المبين في حق الصادق الأمين'),
    Book('tohfa', 'تحفة المادحين لسيد المرسلين'),
    Book('hekma', 'الحكمة والموعظة الحسنة'),
    Book('salawat', 'صلوات الأنوار على سيد الأبرار'),
    Book('borda', 'بردة الأنوار المحمدية'),
    Book('elhama', 'الهمزية في مدح الكمالات الأحمدية'),
    Book('raheeq', 'رحيق الياسمين في حب خير المرسلين'),
    Book('diaa', 'ضياء القلوب بمدح الحبيب المحبوب'),
    Book('nabd', 'نبض الأشواق لرسول الله صلى الله عليه وسلم'),
    Book('sera', 'المنظومة اللطيفة في السيرة النبوية الشريفة'),
    Book('elmaw', 'المولد النبوي الشريف'),
    Book('alf', 'روضة العشاق في سيرة المتمم الأخلاق'),
    Book('zad', 'زاد المسير في الصلاة على الحبيب البشير'),
  ];
  static final Map<String, List<Entry>> index = {};
  static late SharedPreferences prefs;
  static final favs = ValueNotifier<List<Entry>>([]);

  static Book byId(String id) => books.firstWhere((b) => b.id == id);

  // آخر صفحة وقف عندها القارئ في كل كتاب
  static int? lastPage(String id) => prefs.getInt('last_$id');
  static void saveLast(String id, int p) {
    prefs.setInt('last_$id', p);
    if (books.any((b) => b.id == id)) prefs.setString('last_book', id);
    readTick.value++;
  }

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    themeMode.value = (prefs.getBool('dark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    final pi = prefs.getInt('palette') ?? 0;
    paletteIndex.value = (pi >= 0 && pi < palettes.length) ? pi : 0;
    hijriOffset.value = prefs.getInt('hijri_off') ?? 0;
    for (final b in books) {
      final list = <Entry>[];
      try {
        final t = await rootBundle.loadString('assets/index/${b.id}.txt');
        for (var line in t.replaceAll('\uFEFF', '').split('\n')) {
          line = line.trim();
          final i = line.lastIndexOf('|');
          if (i < 1) continue;
          final pg = int.tryParse(line.substring(i + 1).trim());
          if (pg != null) list.add(Entry(b.id, line.substring(0, i).trim(), pg));
        }
      } catch (_) {}
      index[b.id] = list;
    }
    favs.value = (prefs.getStringList('favs') ?? []).map(Entry.parse).whereType<Entry>().toList();
    recordGradeLevel();
  }

  static bool isFav(Entry e) => favs.value.any((x) => x.key == e.key);
  static void toggle(Entry e) {
    final l = [...favs.value];
    isFav(e) ? l.removeWhere((x) => x.key == e.key) : l.add(e);
    favs.value = l;
    prefs.setStringList('favs', l.map((x) => x.key).toList());
  }

  static List<Entry> search(String q) {
    final words = norm(q).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return [];
    final r = <Entry>[];
    for (final e in index.values.expand((x) => x)) {
      final t = norm(e.title);
      if (words.every(t.contains)) r.add(e);
    }
    return r;
  }
}

const pageCounts = {'borda': 32, 'diaa': 216, 'elhama': 28, 'elmaw': 50, 'hekma': 177, 'menhatu': 135, 'mesk': 185, 'nabd': 11, 'raheeq': 240, 'salawat': 110, 'sera': 40, 'tagaliyat': 280, 'tohfa': 217, 'alf': 120, 'manhaj': 16, 'zad': 46};

Future<void> openPdf(BuildContext c, Book b, int page) {
  final max = pageCounts[b.id] ?? 1;
  return Navigator.push(c, MaterialPageRoute(builder: (_) => PdfScreen(b, page.clamp(1, max))));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // fullscreen_all
  await Repo.init();
  loadCustomSebha();
  initReminders();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: paletteIndex,
        builder: (_, pi, __) => ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (_, mode, __) {
            final p = palettes[pi];
            final ext = PaletteExt(p.primary, p.accent, p.third);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'مكتبة الأنوار المحمدية',
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeMode: mode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: p.primary, primary: p.primary, secondary: p.accent, tertiary: p.third),
                scaffoldBackgroundColor: p.bg,
                appBarTheme: AppBarTheme(backgroundColor: p.primary, foregroundColor: Colors.white),
                useMaterial3: true,
                extensions: [ext],
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(seedColor: p.primary, brightness: Brightness.dark, tertiary: p.third),
                scaffoldBackgroundColor: Color.lerp(const Color(0xFF121212), p.primary, .12),
                cardColor: Color.lerp(const Color(0xFF1E1E1E), p.primary, .15),
                appBarTheme: AppBarTheme(backgroundColor: Color.lerp(p.primary, Colors.black, .35), foregroundColor: Colors.white),
                useMaterial3: true,
                extensions: [ext],
              ),
              home: const SplashScreen(),
            );
          },
        ),
      );
}

// ---------- متغيرات عامة ----------
final shellIndex = ValueNotifier<int>(0);
final readTick = ValueNotifier<int>(0); // بيتغير لما القراءة تتقدم (كمّل القراءة وشريط الكتب)
final wirdTick = ValueNotifier<int>(0); // بيتغير كل ما الورد يتعدّل، عشان دايرة الرئيسية تتحدّث

// قلوب بتطير لفوق احتفالاً بإتمام الهدف
void showHearts(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => HeartsBurst(onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Heart {
  final double x, size, delay, rise, phase, amp;
  final Color color;
  const _Heart(this.x, this.size, this.delay, this.rise, this.phase, this.amp, this.color);
}

class HeartsBurst extends StatefulWidget {
  final VoidCallback onDone;
  const HeartsBurst({super.key, required this.onDone});
  @override
  State<HeartsBurst> createState() => _HeartsBurstState();
}

class _HeartsBurstState extends State<HeartsBurst> with SingleTickerProviderStateMixin {
  late final AnimationController c;
  late final List<_Heart> hearts;

  @override
  void initState() {
    super.initState();
    final r = dmath.Random();
    const colors = [Color(0xFFE91E63), Color(0xFFFF5252), Color(0xFFFF80AB), Color(0xFFF06292), Color(0xFFFFD54F)];
    hearts = List.generate(
      220,
      (i) => _Heart(
        r.nextDouble(),
        14 + r.nextDouble() * 34,
        r.nextDouble() * 0.6,
        0.6 + r.nextDouble() * 0.4,
        r.nextDouble() * 6.28,
        8 + r.nextDouble() * 18,
        colors[r.nextInt(colors.length)],
      ),
    );
    c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))
      ..addStatusListener((st) {
        if (st == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Widget heartAt(_Heart h, double t, double w, double ht) {
    final lt = (t - h.delay) / (1 - h.delay);
    if (lt <= 0) return const SizedBox.shrink();
    final p = lt > 1 ? 1.0 : lt;
    final top = ht - (ht * h.rise + 40) * p;
    final left = h.x * (w - h.size) + dmath.sin(p * 6.28 * 1.5 + h.phase) * h.amp;
    final op = p < 0.7 ? 1.0 : (1 - (p - 0.7) / 0.3);
    return Positioned(
      left: left,
      top: top,
      child: Opacity(opacity: op < 0 ? 0.0 : op, child: Icon(Icons.favorite, size: h.size, color: h.color)),
    );
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: LayoutBuilder(
          builder: (_, bc) => AnimatedBuilder(
            animation: c,
            builder: (_, __) => Stack(children: [for (final h in hearts) heartAt(h, c.value, bc.maxWidth, bc.maxHeight)]),
          ),
        ),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  @override
  void initState() {
    super.initState();
    i = shellIndex.value;
    shellIndex.addListener(onIdx);
  }

  void onIdx() {
    if (mounted && i != shellIndex.value) setState(() => i = shellIndex.value);
  }

  @override
  void dispose() {
    shellIndex.removeListener(onIdx);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(index: i, children: const [HomeTab(), BooksTab(), PrayerHubTab(), FavsTab(), MoreTab()]),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                color: isDark(context) ? Theme.of(context).cardColor : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: accent(context).withOpacity(.25)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  for (var k = 0; k < _navIcons.length; k++)
                    Expanded(child: _navItem(context, k)),
                ],
              ),
            ),
          ),
        ),
      );

  static const _navIcons = [Icons.home, Icons.menu_book, Icons.event_available, Icons.star, Icons.more_horiz];
  static const _navLabels = ['الرئيسية', 'الكتب', 'منهج الصلاة', 'المفضلة', 'المزيد'];

  Widget _navItem(BuildContext context, int k) {
    final sel = i == k;
    final ac = accent(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => shellIndex.value = k,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 52,
          decoration: BoxDecoration(
            color: sel ? ac : ac.withOpacity(.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(_navIcons[k], size: 31, color: sel ? (isDark(context) ? Colors.black87 : Colors.white) : ac),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _navLabels[k],
            maxLines: 1,
            style: TextStyle(fontSize: 13.5, fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? ac : Colors.grey),
          ),
        ),
      ]),
    );
  }
}

// ---------- الرئيسية ----------
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  String q = '';
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    // دورة 24 ثانية؛ كل الحركات مضاعفات صحيحة لها فبتتكرر بدون "نَطّة"
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    if (shellIndex.value != 0) _ac.stop();
    shellIndex.addListener(_onTab);
  }

  // الحركة بتقف لما تسيبي الرئيسية عشان توفّر البطارية
  void _onTab() {
    if (!mounted) return;
    if (shellIndex.value == 0) {
      if (!_ac.isAnimating) _ac.repeat();
    } else {
      _ac.stop();
    }
  }

  @override
  void dispose() {
    shellIndex.removeListener(_onTab);
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Repo.search(q);
    return Stack(fit: StackFit.expand, children: [
      _HomeBackdrop(t: _ac),
      Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: InputDecoration(
                  hintText: 'ابحث في عناوين كل الكتب...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            IconButton(
              tooltip: 'الوضع الليلي',
              icon: Icon(isDark(context) ? Icons.light_mode : Icons.dark_mode),
              onPressed: toggleDark,
            ),
          ]),
        ),
        Expanded(
          child: q.trim().isEmpty
              ? ListView(padding: EdgeInsets.zero, children: [
                  const Clock(),
                  const SizedBox(height: 16),
                  const _HeroFrame(),
                  const SizedBox(height: 4),
                  const _TitleRibbon(),
                  const SizedBox(height: 18),
                  const _SalawatCarousel(),
                  const SizedBox(height: 22),
                  const _SectionTitle('عن الكاتب'),
                  const SizedBox(height: 12),
                  HomeActionCard(
                    icon: Icons.person,
                    title: 'التعريف بالكاتب',
                    subtitle: 'تعرّف على الكاتب وسيرته',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TextScreen('التعريف بالكاتب', 'assets/texts/author.txt'))),
                  ),
                  const SizedBox(height: 10),
                  HomeActionCard(
                    icon: Icons.favorite,
                    title: 'فضل الصلاة والسلام على الحبيب ﷺ',
                    subtitle: 'ما ورد في فضل الصلاة على النبي ﷺ',
                    gold: true,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TextScreen('فضل الصلاة والسلام على الحبيب ﷺ', 'assets/texts/fadl_salah.txt'))),
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('وردك اليومي'),
                  const SizedBox(height: 12),
                  const TodayWirdCard(),
                  const SizedBox(height: 10),
                  const ContinueReadingCard(),
                  const SizedBox(height: 26),
                  const _HomeFooter(),
                  const SizedBox(height: 26),
                ])
              : res.isEmpty
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.separated(
                      itemCount: res.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, k) {
                        final e = res[k], b = Repo.byId(e.book);
                        return ListTile(
                          title: Text(e.title),
                          subtitle: Text('${b.title} • صفحة ${e.page}'),
                          onTap: () => openPdf(context, b, e.page),
                        );
                      }),
        ),
      ]),
    ]);
  }
}

// ----- بطاقة إجراء في الرئيسية (التعريف بالكاتب / فضل الصلاة) -----
class HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool gold;
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = pri(context), sc = sec(context);
    final base = gold ? Color.lerp(sc, Colors.black, .3)! : p;
    final c1 = Color.lerp(base, Colors.white, .08)!;
    final c2 = Color.lerp(Color.lerp(base, tri(context), .3)!, Colors.black, .35)!;
    final edge = Color.lerp(sc, Colors.white, .25)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: edge.withOpacity(.8), width: 1.5),
        boxShadow: [BoxShadow(color: base.withOpacity(.4), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(children: [
              // أيقونة كبيرة باهتة كزخرفة في الخلفية
              Positioned(
                left: -14,
                bottom: -18,
                child: Icon(icon, size: 96, color: Colors.white.withOpacity(.09)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                child: Row(children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.16),
                      border: Border.all(color: edge, width: 1.5),
                    ),
                    child: Icon(icon, color: Colors.white, size: 27),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title,
                          style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(.82))),
                    ]),
                  ),
                  Icon(Icons.chevron_left, color: edge, size: 28),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ================= الرئيسية المزخرفة =================

// خلفية: تدرّج + نقش النجوم + نجوم صغيرة بتلمع
class _HomeBackdrop extends StatelessWidget {
  final Animation<double> t;
  const _HomeBackdrop({required this.t});

  static final List<List<double>> _pts = () {
    final r = dmath.Random(11);
    return List.generate(34, (_) => [r.nextDouble(), r.nextDouble(), r.nextDouble() * 6.2832, 2 + r.nextDouble() * 3.5]);
  }();

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        const PageBackdrop(child: SizedBox.shrink()),
        IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: _TwinklePainter(t, _pts, sec(context))))),
      ]);
}

class _TwinklePainter extends CustomPainter {
  final Animation<double> t;
  final List<List<double>> pts;
  final Color color;
  _TwinklePainter(this.t, this.pts, this.color) : super(repaint: t);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    for (final q in pts) {
      final a = (dmath.sin(t.value * 2 * dmath.pi * 12 + q[2]) + 1) / 2;
      p.color = color.withOpacity(.10 + .45 * a);
      final o = Offset(q[0] * s.width, q[1] * s.height);
      final r = q[3] * (.6 + .4 * a);
      final path = Path()
        ..moveTo(o.dx, o.dy - r * 1.8)
        ..quadraticBezierTo(o.dx, o.dy, o.dx + r * 1.8, o.dy)
        ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r * 1.8)
        ..quadraticBezierTo(o.dx, o.dy, o.dx - r * 1.8, o.dy)
        ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r * 1.8)
        ..close();
      c.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _TwinklePainter old) => old.color != color;
}

// إطار هادئ ووقور حول الصورة (بدون حركة)
class _HeroFrame extends StatelessWidget {
  const _HeroFrame();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 290,
        child: Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(size: const Size(280, 280), painter: _CalmFramePainter(sec(context), isDark(context))),
              const AuthorPhoto(size: 170),
            ]),
          ),
        ),
      );
}

class _CalmFramePainter extends CustomPainter {
  final Color gold;
  final bool dark;
  const _CalmFramePainter(this.gold, this.dark);

  Path _star8(double r) {
    final p = Path();
    for (var k = 0; k < 16; k++) {
      final rr = k.isEven ? r : r * .5;
      final a = -dmath.pi / 2 + k * dmath.pi / 8;
      final pt = Offset(dmath.cos(a) * rr, dmath.sin(a) * rr);
      if (k == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas c, Size s) {
    final ctr = Offset(s.width / 2, s.height / 2);
    final r0 = s.width / 2;
    // هالة ناعمة
    c.drawCircle(
      ctr,
      r0,
      Paint()
        ..shader = RadialGradient(
          colors: [gold.withOpacity(dark ? .26 : .20), gold.withOpacity(0)],
          stops: const [.55, 1.0],
        ).createShader(Rect.fromCircle(center: ctr, radius: r0)),
    );
    // حلقتان رفيعتان
    c.drawCircle(
        ctr,
        116,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = gold.withOpacity(.9));
    c.drawCircle(
        ctr,
        123,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = gold.withOpacity(.55));
    // نقاط دقيقة
    final dot = Paint()..color = gold.withOpacity(.6);
    for (var i = 0; i < 72; i++) {
      final a = i * 2 * dmath.pi / 72;
      c.drawCircle(ctr + Offset(dmath.cos(a), dmath.sin(a)) * 130, i % 6 == 0 ? 1.6 : .9, dot);
    }
    // معيّنات صغيرة في الجهات الأربع
    final fill = Paint()..color = gold;
    for (var k = 0; k < 4; k++) {
      final a = k * dmath.pi / 2;
      if (k == 3) continue; // الأعلى مكانه النجمة
      c.save();
      c.translate(ctr.dx + dmath.cos(a) * 119.5, ctr.dy + dmath.sin(a) * 119.5);
      c.rotate(dmath.pi / 4);
      c.drawRect(Rect.fromCenter(center: Offset.zero, width: 7, height: 7), fill);
      c.restore();
    }
    // نجمة ثمانية هادئة في الأعلى
    c.save();
    c.translate(ctr.dx, ctr.dy - 119.5);
    c.drawCircle(Offset.zero, 11, Paint()..color = dark ? const Color(0xFF1E1E1E) : Colors.white);
    c.drawPath(_star8(10), fill);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _CalmFramePainter old) => old.gold != gold || old.dark != dark;
}

// شريط العنوان تحت الصورة
class _TitleRibbon extends StatelessWidget {
  const _TitleRibbon();

  @override
  Widget build(BuildContext context) {
    final s = sec(context), p = pri(context), th = tri(context);
    final dark = isDark(context);
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color.lerp(p, Colors.black, .15)!, Color.lerp(p, th, .5)!, Color.lerp(p, Colors.black, .15)!]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: s, width: 1.6),
          boxShadow: [BoxShadow(color: s.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome, color: s, size: 16),
          const SizedBox(width: 10),
          const Text('شاعر رسول الله ﷺ', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 10),
          Icon(Icons.auto_awesome, color: s, size: 16),
        ]),
      ),
      const SizedBox(height: 10),
      Text('الشيخ عبدالرحمن مصطفى الأزهري',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: dark ? Colors.white : Color.lerp(p, Colors.black, .25))),
      const SizedBox(height: 8),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 48), child: OrnamentDivider()),
    ]);
  }
}

// عنوان قسم مزخرف
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final s = sec(context);
    Widget line(bool fadeLeft) => Expanded(
          child: Container(
            height: 1.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: fadeLeft ? [s.withOpacity(0), s] : [s, s.withOpacity(0)]),
            ),
          ),
        );
    Widget dia() => Transform.rotate(angle: dmath.pi / 4, child: Container(width: 7, height: 7, color: s));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [
          line(true),
          const SizedBox(width: 8),
          dia(),
          const SizedBox(width: 10),
          Text(text, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent(context))),
          const SizedBox(width: 10),
          dia(),
          const SizedBox(width: 8),
          line(false),
        ]),
      ),
    );
  }
}

// زخارف الأركان (بتتستخدم فوق البطاقات)
class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter(this.color);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final f = Paint()..color = color;
    void corner() {
      final path = Path()
        ..moveTo(10, 38)
        ..lineTo(10, 18)
        ..quadraticBezierTo(10, 10, 18, 10)
        ..lineTo(38, 10);
      c.drawPath(path, p);
      c.drawCircle(const Offset(10, 10), 2.4, f);
      c.drawArc(const Rect.fromLTWH(16, 16, 12, 12), dmath.pi, dmath.pi / 2, false, p);
    }

    corner();
    c.save();
    c.translate(s.width, 0);
    c.scale(-1, 1);
    corner();
    c.restore();
    c.save();
    c.translate(0, s.height);
    c.scale(1, -1);
    corner();
    c.restore();
    c.save();
    c.translate(s.width, s.height);
    c.scale(-1, -1);
    corner();
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}

// بطاقة آية/حديث/صيغة صلاة بتتبدّل لوحدها
class _SalawatCarousel extends StatefulWidget {
  const _SalawatCarousel();
  @override
  State<_SalawatCarousel> createState() => _SalawatCarouselState();
}

class _SalawatCarouselState extends State<_SalawatCarousel> {
  static const items = <List<String>>[
    ['قال الله تعالى', '﴿ إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا ﴾', 'سورة الأحزاب - الآية ٥٦'],
    ['قال رسول الله ﷺ', 'مَنْ صَلَّى عَلَيَّ وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا', 'رواه مسلم'],
    ['صلاة على النبي ﷺ', 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ أَجْمَعِينَ', ''],
    ['قال رسول الله ﷺ', 'إِنَّ أَوْلَى النَّاسِ بِي يَوْمَ الْقِيَامَةِ أَكْثَرُهُمْ عَلَيَّ صَلَاةً', 'رواه الترمذي'],
  ];

  int i = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 9), (_) => _next());
  }

  void _next() {
    if (mounted) setState(() => i = (i + 1) % items.length);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = sec(context), a = accent(context), dark = isDark(context);
    final it = items[i];
    return GestureDetector(
      onTap: _next,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? [Theme.of(context).cardColor, Color.lerp(Theme.of(context).cardColor, s, .10)!]
                : [Colors.white, Color.lerp(Colors.white, s, .16)!],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: s.withOpacity(.85), width: 1.5),
          boxShadow: [BoxShadow(color: s.withOpacity(.22), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Stack(children: [
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _CornerPainter(s)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 14),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 170),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (w, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: Tween(begin: const Offset(0, .08), end: Offset.zero).animate(anim), child: w),
                  ),
                  child: Column(
                    key: ValueKey(i),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(it[0], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: s)),
                      const SizedBox(height: 10),
                      Text(it[1],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, height: 1.9, fontWeight: FontWeight.w600, color: dark ? Colors.white : Color.lerp(a, Colors.black, .2))),
                      if (it[2].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(it[2], style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var k = 0; k < items.length; k++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: k == i ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(color: k == i ? s : s.withOpacity(.3), borderRadius: BorderRadius.circular(4)),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ختام الصفحة
class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    final s = sec(context);
    return Column(children: [
      const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: OrnamentDivider()),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite, size: 14, color: s),
        const SizedBox(width: 8),
        Text('اللهم صلِّ وسلِّم على سيدنا محمد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accent(context))),
        const SizedBox(width: 8),
        Icon(Icons.favorite, size: 14, color: s),
      ]),
    ]);
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});
  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late Timer t;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => now = DateTime.now()));
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  String two(int n) => n.toString().padLeft(2, '0');

  String greet() {
    final h = now.hour;
    if (h < 5) return 'ليلة مباركة';
    if (h < 12) return 'صباح النور';
    if (h < 17) return 'طاب يومك';
    if (h < 20) return 'مساء الخير';
    return 'ليلة مباركة';
  }

  Widget pill(IconData ic, String text, Color s, Color deep, bool gold) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: gold ? s : Colors.white.withOpacity(.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold ? Colors.white.withOpacity(.5) : Colors.white.withOpacity(.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(ic, size: 15, color: gold ? deep : Colors.white),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: gold ? deep : Colors.white)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final p = pri(context), s = sec(context), th = tri(context);
    final c1 = Color.lerp(p, Colors.white, .06)!;
    final c2 = Color.lerp(Color.lerp(p, th, .35)!, Colors.black, .38)!;
    final edge = Color.lerp(s, Colors.white, .25)!;
    final deep = Color.lerp(p, Colors.black, .55)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2]),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: edge.withOpacity(.85), width: 1.6),
        boxShadow: [BoxShadow(color: p.withOpacity(.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(children: [
          Positioned(left: -16, bottom: -20, child: FaIcon(FontAwesomeIcons.mosque, size: 120, color: Colors.white.withOpacity(.08))),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _CornerPainter(edge.withOpacity(.75))))),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(greet(), style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: edge)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    text: '${two(h)}:${two(now.minute)}:${two(now.second)} ',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black38, blurRadius: 8)]),
                    children: [TextSpan(text: now.hour < 12 ? 'ص' : 'م', style: TextStyle(fontSize: 20, color: edge))],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 6, children: [
                  pill(Icons.calendar_today, '${now.day} ${months[now.month - 1]} ${now.year}', s, deep, false),
                  pill(Icons.nights_stay, hijriNow(now), s, deep, true),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class AuthorPhoto extends StatelessWidget {
  final double size;
  const AuthorPhoto({super.key, this.size = 215});
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: sec(context).withOpacity(.15)),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [sec(context), Color.lerp(sec(context), Colors.white, .5)!, sec(context), Color.lerp(sec(context), Colors.black, .2)!, sec(context)]),
              boxShadow: [BoxShadow(color: sec(context).withOpacity(.3), blurRadius: 18, spreadRadius: 1)],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(child: Image.asset('assets/images/author.png', width: size, height: size, fit: BoxFit.cover, cacheWidth: 640)),
            ),
          ),
        ),
      );
}

// ---------- الكتب (3 أقسام) ----------
class BookSection {
  final String title;
  final IconData icon;
  final List<String> ids; // أرقام كتب القسم (لو فاضية: كل الكتب اللي مش في الأقسام التانية)
  const BookSection(this.title, this.icon, this.ids);
}

const sectionSalat = BookSection('الصلاة على النبي ﷺ', Icons.favorite, ['salawat', 'zad']);
const sectionMadaeh = BookSection('المدائح النبوية', Icons.music_note, []);
const sectionSera = BookSection('السيرة النبوية الشريفة', Icons.auto_stories, ['sera', 'alf']);
const bookSections = [sectionSalat, sectionMadaeh, sectionSera];

List<Book> sectionBooks(BookSection sec) {
  if (sec.ids.isNotEmpty) {
    return [for (final id in sec.ids) ...Repo.books.where((b) => b.id == id)];
  }
  final taken = <String>{...sectionSalat.ids, ...sectionSera.ids};
  return Repo.books.where((b) => !taken.contains(b.id)).toList();
}

String booksCountText(int n) {
  if (n == 1) return 'كتاب واحد';
  if (n == 2) return 'كتابان';
  if (n <= 10) return '$n كتب';
  return '$n كتاباً';
}

class BooksTab extends StatelessWidget {
  const BooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    var total = 0;
    for (final s in bookSections) {
      total += sectionBooks(s).length + (s.title == sectionSalat.title ? 1 : 0);
    }
    return PageBackdrop(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        children: [
          _LibraryHeader(total: total),
          for (var i = 0; i < bookSections.length; i++) _Reveal(delay: i, child: SectionCard(bookSections[i], idx: i)),
        ],
      ),
    );
  }
}

// ظهور هادئ للبطاقات: تلاشي + صعود خفيف، كل بطاقة بعد اللي قبلها
class _Reveal extends StatelessWidget {
  final int delay;
  final Widget child;
  const _Reveal({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 420 + 140 * delay),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, 22 * (1 - v)), child: c),
        ),
        child: child,
      );
}

// ترويسة المكتبة: ميدالية ذهبية بين خطّين متلاشيين + عنوان وعدد الأقسام والكتب
class _LibraryHeader extends StatelessWidget {
  final int total;
  const _LibraryHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    final pc = pri(context), tc = tri(context);
    final gold = Color.lerp(sec(context), Colors.white, .15)!;
    Widget fade(bool solidOnRight) => Expanded(
          child: Container(
            height: 1.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: solidOnRight ? [gold.withOpacity(0), gold] : [gold, gold.withOpacity(0)],
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 14),
      child: Column(children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(children: [
            fade(true),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color.lerp(pc, tc, .3)!, Color.lerp(pc, Colors.black, .5)!],
                ),
                border: Border.all(color: gold, width: 1.8),
                boxShadow: [BoxShadow(color: pc.withOpacity(.45), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Icon(Icons.local_library, color: gold, size: 29),
            ),
            fade(false),
          ]),
        ),
        const SizedBox(height: 8),
        Text('المكتبة',
            style: TextStyle(fontSize: 30, height: 1.3, fontWeight: FontWeight.bold, color: accent(context))),
        Text('${bookSections.length} أقسام  •  ${booksCountText(total)}',
            style: TextStyle(fontSize: 13.5, color: Theme.of(context).hintColor)),
      ]),
    );
  }
}

class SectionCard extends StatelessWidget {
  final BookSection bs;
  final int idx;
  const SectionCard(this.bs, {super.key, this.idx = 0});

  @override
  Widget build(BuildContext context) {
    final list = sectionBooks(bs);
    final isSalat = bs.title == sectionSalat.title;
    final count = list.length + (isSalat ? 1 : 0);
    final pc = pri(context), tc = tri(context), sc = sec(context);
    final edge = Color.lerp(sc, Colors.white, .25)!;
    // كل قسم له درجة لون مختلفة شوية
    final base = [pc, Color.lerp(pc, tc, .7)!, Color.lerp(Color.lerp(pc, sc, .35)!, Colors.black, .35)!][idx % 3];
    final c1 = Color.lerp(Color.lerp(base, Colors.white, .06)!, tc, .12)!;
    final c2 = Color.lerp(base, Colors.black, .5)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: edge, width: 1.8),
        boxShadow: [BoxShadow(color: base.withOpacity(.45), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: edge.withOpacity(.5), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(23),
            child: InkWell(
              borderRadius: BorderRadius.circular(23),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(bs))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(children: [
                  Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(edge)))),
                  Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _CornerPainter(edge.withOpacity(.7))))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(.14),
                            border: Border.all(color: edge, width: 1.7),
                            boxShadow: [BoxShadow(color: edge.withOpacity(.35), blurRadius: 10)],
                          ),
                          child: Icon(bs.icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(bs.title,
                                style: const TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: edge.withOpacity(.55)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.menu_book, size: 14, color: edge),
                                const SizedBox(width: 5),
                                Text(booksCountText(count), style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(.9))),
                              ]),
                            ),
                          ]),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: edge.withOpacity(.7), width: 1.2)),
                          child: Icon(Icons.chevron_left, color: edge, size: 24),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const FractionallySizedBox(widthFactor: .6, child: OrnamentDivider()),
                      const SizedBox(height: 14),
                      _gallery(context, list, isSalat, edge),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // معرض الأغلفة: أغلفة كبيرة وواضحة بالعنوان تحتها، وتتسحب أفقياً لو كتير
  Widget _gallery(BuildContext context, List<Book> list, bool isSalat, Color edge) {
    const cw = 98.0, ch = 138.0, gap = 14.0;
    final items = <Widget>[
      if (isSalat)
        _CoverItem(
          w: cw,
          title: 'صلوات الأنوار',
          child: const TasbihCover(width: cw, height: ch),
        ),
      for (final b in list)
        _CoverItem(
          w: cw,
          title: b.title,
          child: _CoverImg(b.cover, cw, ch),
        ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: edge.withOpacity(.35), width: 1),
      ),
      child: LayoutBuilder(
        builder: (_, bc) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: bc.maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  items[i],
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// غلاف + عنوانه تحته (الضغط عليه بيفتح القسم زي باقي البطاقة)
class _CoverItem extends StatelessWidget {
  final double w;
  final String title;
  final Widget child;
  const _CoverItem({required this.w, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: w,
        child: Column(children: [
          child,
          const SizedBox(height: 8),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(.94))),
        ]),
      );
}

// غلاف كتاب واضح: صورة بدقة أعلى، ظل، وإطار رفيع، وتظليل خفيف جداً عند كعب الكتاب
class _CoverImg extends StatelessWidget {
  final String asset;
  final double w, h;
  const _CoverImg(this.asset, this.w, this.h);

  @override
  Widget build(BuildContext context) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.55), blurRadius: 9, offset: const Offset(0, 4))],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(.22), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(
              asset,
              fit: BoxFit.cover,
              cacheWidth: 420,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white.withOpacity(.12),
                child: const Icon(Icons.menu_book, color: Colors.white54, size: 34),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.black.withOpacity(.22), Colors.transparent]),
                ),
              ),
            ),
          ]),
        ),
      );
}

class SectionScreen extends StatelessWidget {
  final BookSection sec;
  const SectionScreen(this.sec, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(sec.title, style: const TextStyle(fontSize: 17))),
        body: PageBackdrop(
          child: ValueListenableBuilder<int>(
            valueListenable: readTick,
            builder: (context, _, __) {
              final list = sectionBooks(sec);
              final extra = sec.title == sectionSalat.title ? 1 : 0;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                itemCount: list.length + extra,
                itemBuilder: (_, j) {
                  final Widget tile = j < extra ? const AnwarTile() : BookTile(list[j - extra]);
                  return j < 6 ? _Reveal(delay: j, child: tile) : tile;
                },
              );
            },
          ),
        ),
      );
}

Widget _shelfPill(BuildContext context, IconData ic, String t) {
  final sc = sec(context), a = accent(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: sc.withOpacity(.16),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: sc.withOpacity(.7)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(ic, size: 15, color: a),
      const SizedBox(width: 5),
      Text(t, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: a)),
    ]),
  );
}

// بطاقة كتاب في شاشة القسم: غلاف كبير + عنوان + تقدّم القراءة
class _ShelfCard extends StatelessWidget {
  final Widget cover, info;
  final String title;
  final VoidCallback onTap;
  const _ShelfCard({required this.cover, required this.title, required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sc = sec(context), a = accent(context);
    final dark = isDark(context);
    final top = dark ? Theme.of(context).cardColor : Colors.white;
    final bot = Color.lerp(top, sc, dark ? .10 : .16)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bot]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: sc.withOpacity(.85), width: 1.5),
        boxShadow: [BoxShadow(color: sc.withOpacity(.22), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(children: [
              Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(sc)))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  cover,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.bold, color: a)),
                      const SizedBox(height: 10),
                      info,
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: sc.withOpacity(.16), border: Border.all(color: sc.withOpacity(.8))),
                    child: Icon(Icons.chevron_left, color: a, size: 24),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  final Book b;
  const BookTile(this.b, {super.key});
  @override
  Widget build(BuildContext context) {
    final last = Repo.lastPage(b.id);
    final total = pageCounts[b.id] ?? 1;
    final prog = last == null ? 0.0 : (last >= total ? 1.0 : last / total);
    final started = last != null && last > 1;
    final sc = sec(context);
    return _ShelfCard(
      cover: _CoverImg(b.cover, 100, 140),
      title: b.title,
      onTap: () {
        if (Repo.index[b.id]!.isEmpty) {
          openPdf(context, b, Repo.lastPage(b.id) ?? 1);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(b)));
        }
      },
      info: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (started) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: prog,
              minHeight: 7,
              backgroundColor: sc.withOpacity(.22),
              valueColor: AlwaysStoppedAnimation<Color>(sc),
            ),
          ),
          const SizedBox(height: 6),
          Text('وصلت لصفحة $last من $total  •  ${(prog * 100).round()}%',
              style: TextStyle(fontSize: 12.5, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
        ],
        _shelfPill(context, started ? Icons.play_arrow_rounded : Icons.auto_stories, started ? 'كمّل القراءة' : 'ابدأ القراءة'),
      ]),
    );
  }
}

class BookScreen extends StatefulWidget {
  final Book b;
  const BookScreen(this.b, {super.key});
  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  Future<void> open(int page) async {
    await openPdf(context, widget.b, page);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    final list = Repo.index[b.id]!;
    final last = Repo.lastPage(b.id);
    return Scaffold(
      appBar: AppBar(title: Text(b.title, style: const TextStyle(fontSize: 16))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: FilledButton.icon(
                  onPressed: () => open(1), icon: const Icon(Icons.menu_book), label: const Text('من البداية')),
            ),
            if (last != null && last > 1) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                    onPressed: () => open(last), icon: const Icon(Icons.bookmark), label: Text('متابعة (ص $last)')),
              ),
            ],
          ]),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Entry>>(
            valueListenable: Repo.favs,
            builder: (_, __, ___) => ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, k) {
                final e = list[k];
                final f = Repo.isFav(e);
                return ListTile(
                  title: Text(e.title),
                  subtitle: Text('صفحة ${e.page}'),
                  trailing: IconButton(
                    icon: Icon(f ? Icons.star : Icons.star_border, color: sec(context)),
                    onPressed: () => Repo.toggle(e),
                  ),
                  onTap: () => open(e.page),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}

// نتيجة رسم صفحة: الصورة + نسبة (الارتفاع ÷ العرض)
class PdfPageImg {
  final Uint8List bytes;
  final double ratio;
  const PdfPageImg(this.bytes, this.ratio);
}

class PdfScreen extends StatefulWidget {
  final Book book;
  final int page;
  const PdfScreen(this.book, this.page, {super.key});
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

// عارض الكتاب: الصفحات ورا بعضها بالتمرير لتحت، من غير تكبير ولا تصغير،
// والصفحة بتترسم بدقة شاشة الموبايل بالظبط، والصفحات اللي جاية بتتجهز قبل ما توصلها
class _PdfScreenState extends State<PdfScreen> {
  PdfDocument? doc;
  bool failed = false;
  double firstRatio = 1.4;
  late int current;
  late final ValueNotifier<int> pageNo;
  final positions = ItemPositionsListener.create();
  final itemScroll = ItemScrollController();
  late List<Bm> bms;
  final futures = <int, Future<PdfPageImg?>>{};
  Future<void> lock = Future<void>.value();
  double pxWidth = 1080;
  bool closed = false;

  int get total => doc?.pagesCount ?? (pageCounts[widget.book.id] ?? 1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    current = widget.page;
    pageNo = ValueNotifier<int>(widget.page);
    if (Repo.books.any((b) => b.id == widget.book.id)) Repo.prefs.setString('last_book', widget.book.id);
    if (Repo.lastPage(widget.book.id) == null) Repo.prefs.setInt('last_${widget.book.id}', widget.page);
    WidgetsBinding.instance.addPostFrameCallback((_) => readTick.value++);
    positions.itemPositions.addListener(onPositions);
    bms = loadBookmarks(widget.book.id);
    openDoc();
  }

  Future<void> openDoc() async {
    try {
      final d = await PdfDocument.openAsset(widget.book.pdf);
      final p = await d.getPage(1);
      final r = p.height / p.width;
      await p.close();
      if (!mounted) {
        await d.close();
        return;
      }
      setState(() {
        doc = d;
        firstRatio = r;
      });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    closed = true;
    positions.itemPositions.removeListener(onPositions);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final d = doc;
    lock.then((_) => d?.close());
    pageNo.dispose();
    super.dispose();
  }

  // رسم الصفحات واحدة ورا التانية (أندرويد بيفتح صفحة واحدة في المرة)
  Future<PdfPageImg?> pageImage(int i) => futures.putIfAbsent(i, () => enqueue(i));

  Future<PdfPageImg?> enqueue(int i) {
    final job = lock.then<PdfPageImg?>((_) async {
      // الصفحات البعيدة عن مكان القراءة نتخطاها عشان القريبة تظهر بسرعة
      if (closed || doc == null || (i + 1 - current).abs() > 8) return null;
      try {
        final page = await doc!.getPage(i + 1);
        final ratio = page.height / page.width;
        final img = await page.render(
          width: pxWidth,
          height: pxWidth * ratio,
          format: PdfPageImageFormat.jpeg,
          quality: 92,
          backgroundColor: '#FFFFFF',
        );
        await page.close();
        if (img == null) return null;
        return PdfPageImg(img.bytes, ratio);
      } catch (_) {
        return null;
      }
    });
    lock = job.then<void>((_) {});
    job.then((v) {
      if (v == null) futures.remove(i);
    });
    return job;
  }

  bool isMarked(int p) => bms.any((b) => b.page == p);

  void jumpTo(int page) {
    var p = page;
    if (p < 1) p = 1;
    if (p > total) p = total;
    itemScroll.jumpTo(index: p - 1);
  }

  Future<String?> askNote() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('علامة مرجعية'),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'ملاحظة (اختياري)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('حفظ')),
        ],
      ),
    );
  }

  Future<void> addBookmark() async {
    final note = await askNote();
    if (note == null) return;
    final list = loadBookmarks(widget.book.id)
      ..removeWhere((b) => b.page == current)
      ..add(Bm(current, note));
    saveBookmarks(widget.book.id, list);
    if (mounted) setState(() => bms = loadBookmarks(widget.book.id));
  }

  void removeBookmark(int page) {
    final list = loadBookmarks(widget.book.id)..removeWhere((b) => b.page == page);
    saveBookmarks(widget.book.id, list);
    setState(() => bms = loadBookmarks(widget.book.id));
  }

  Future<void> askPage() async {
    final c = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اذهب إلى صفحة'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'من 1 إلى $total'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, int.tryParse(latinDigits(c.text.trim()))), child: const Text('اذهب')),
        ],
      ),
    );
    if (n != null) jumpTo(n);
  }

  void openBookmarks() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final list = bms;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await addBookmark();
                      setSheet(() {});
                    },
                    icon: const Icon(Icons.bookmark_add),
                    label: Text('علامة في صفحة $current'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    askPage();
                  },
                  icon: const Icon(Icons.find_in_page_outlined),
                  label: const Text('اذهب لصفحة'),
                ),
              ]),
              const Divider(height: 20),
              if (list.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد علامات في هذا الكتاب بعد'))
              else
                Flexible(
                  child: ListView(shrinkWrap: true, children: [
                    for (final b in list)
                      ListTile(
                        leading: CircleAvatar(child: Text('${b.page}', style: const TextStyle(fontSize: 13))),
                        title: Text(b.note.isEmpty ? 'صفحة ${b.page}' : b.note),
                        subtitle: b.note.isEmpty ? null : Text('صفحة ${b.page}'),
                        onTap: () {
                          Navigator.pop(ctx);
                          jumpTo(b.page);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            removeBookmark(b.page);
                            setSheet(() {});
                          },
                        ),
                      ),
                  ]),
                ),
            ]),
          ),
        );
      }),
    );
  }

  // نعرف رقم الصفحة اللي في نص الشاشة ونحفظه
  void onPositions() {
    final pos = positions.itemPositions.value;
    if (pos.isEmpty) return;
    int? best;
    for (final p in pos) {
      if (p.itemLeadingEdge < 0.5 && p.itemTrailingEdge >= 0.5) {
        if (best == null || p.index < best) best = p.index;
      }
    }
    final idx = best ?? pos.map((p) => p.index).reduce((a, b) => a < b ? a : b);
    final page = idx + 1;
    if (page != current) {
      current = page;
      pageNo.value = page;
      Repo.saveLast(widget.book.id, page);
      if (futures.length > 60) {
        futures.removeWhere((k, _) => (k + 1 - page).abs() > 30);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    final mq = MediaQuery.of(context);
    var w = mq.size.width * mq.devicePixelRatio;
    if (w < 720) w = 720;
    if (w > 2000) w = 2000;
    pxWidth = w;
    final n = doc?.pagesCount ?? 1;
    var start = widget.page - 1;
    if (start < 0) start = 0;
    if (start >= n) start = n - 1;
    return Scaffold(
      backgroundColor: dark ? Colors.black : const Color(0xFFE0E0E0),
      body: Stack(children: [
        if (failed)
          const Center(child: Text('تعذر فتح الكتاب'))
        else if (doc == null)
          const Center(child: CircularProgressIndicator())
        else
          ColorFiltered(
            colorFilter: dark
                ? const ColorFilter.matrix(<double>[-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0])
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: ScrollablePositionedList.builder(
              itemCount: n,
              initialScrollIndex: start,
              itemPositionsListener: positions,
              itemScrollController: itemScroll,
              minCacheExtent: 1800,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _PdfTile(this, i, firstRatio),
              ),
            ),
          ),
        Positioned(
          top: 6,
          right: 6,
          child: SafeArea(
            child: Row(children: [
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: Icon(dark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                  onPressed: toggleDark,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: ValueListenableBuilder<int>(
                  valueListenable: pageNo,
                  builder: (_, p, __) => IconButton(
                    icon: Icon(isMarked(p) ? Icons.bookmark : Icons.bookmark_border,
                        color: isMarked(p) ? const Color(0xFFFFD54F) : Colors.white),
                    onPressed: openBookmarks,
                  ),
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          bottom: 6,
          left: 0,
          right: 0,
          child: Center(
            child: ValueListenableBuilder<int>(
              valueListenable: pageNo,
              builder: (_, p, __) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
                child: Text('$p / $total', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PdfTile extends StatefulWidget {
  final _PdfScreenState host;
  final int index;
  final double ratio;
  const _PdfTile(this.host, this.index, this.ratio);
  @override
  State<_PdfTile> createState() => _PdfTileState();
}

class _PdfTileState extends State<_PdfTile> {
  PdfPageImg? img;
  int tries = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final r = await widget.host.pageImage(widget.index);
    if (!mounted) return;
    if (r == null) {
      tries++;
      if (tries > 8) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) load();
      return;
    }
    setState(() => img = r);
  }

  @override
  Widget build(BuildContext context) {
    final i = img;
    if (i == null) {
      return AspectRatio(
        aspectRatio: 1 / widget.ratio,
        child: const ColoredBox(color: Colors.white, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return Image.memory(i.bytes,
        width: double.infinity, fit: BoxFit.fitWidth, gaplessPlayback: true, filterQuality: FilterQuality.high);
  }
}

// ---------- المفضلة ----------
class FavsTab extends StatelessWidget {
  const FavsTab({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Entry>>(
        valueListenable: Repo.favs,
        builder: (_, list, __) => list.isEmpty
            ? const Center(child: Text('لا توجد عناوين في المفضلة بعد\nاضغط ⭐ بجوار أي عنوان في فهرس الكتاب', textAlign: TextAlign.center))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, k) {
                  final e = list[k], b = Repo.byId(e.book);
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text('${b.title} • صفحة ${e.page}'),
                    trailing: IconButton(icon: Icon(Icons.star, color: sec(context)), onPressed: () => Repo.toggle(e)),
                    onTap: () => openPdf(context, b, e.page),
                  );
                },
              ),
      );
}

// ---------- من نحن / نصوص ----------
// ---------- خلفية زخرفية + فاصل زخرفي (للصفحات النصية والقصائد) ----------
class PageBackdrop extends StatelessWidget {
  final Widget child;
  const PageBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    final p = pri(context), s = sec(context);
    final base = Theme.of(context).scaffoldBackgroundColor;
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(base, p, dark ? .14 : .10)!, base, Color.lerp(base, s, dark ? .08 : .15)!],
          ),
        ),
      ),
      RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(dark ? s : p))),
      child,
    ]);
  }
}

class _StarPatternPainter extends CustomPainter {
  final Color color;
  const _StarPatternPainter(this.color);

  void star(Canvas c, Offset o, double r, Paint p) {
    for (final rot in const [0.0, dmath.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final ang = rot + dmath.pi / 4 + i * dmath.pi / 2;
        final pt = o + Offset(dmath.cos(ang), dmath.sin(ang)) * r;
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      c.drawPath(path, p);
    }
  }

  @override
  void paint(Canvas c, Size sz) {
    const cell = 64.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withOpacity(.09);
    final rows = (sz.height / (cell / 2)).ceil() + 1, cols = (sz.width / cell).ceil() + 1;
    for (var r = 0; r < rows; r++) {
      for (var k = 0; k < cols; k++) {
        star(c, Offset(k * cell + (r.isOdd ? cell / 2 : 0), r * cell / 2), cell * .34, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarPatternPainter old) => old.color != color;
}

class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final s = sec(context);
    Widget diamond(double d) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.rotate(angle: dmath.pi / 4, child: Container(width: d, height: d, color: s)),
        );
    Widget line(bool toRight) => Expanded(
          child: Container(
            height: 1.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: toRight ? [s.withOpacity(0), s] : [s, s.withOpacity(0)],
              ),
            ),
          ),
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(children: [line(true), diamond(5), diamond(8), diamond(5), line(false)]),
    );
  }
}

class TextView extends StatelessWidget {
  final String asset;
  final String? title;
  final bool backdrop;
  const TextView(this.asset, {super.key, this.title, this.backdrop = true});

  @override
  Widget build(BuildContext context) {
    final a = accent(context), s = sec(context), dark = isDark(context);
    final body = FutureBuilder<String>(
      future: rootBundle.loadString(asset),
      builder: (_, snap) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: dark ? Colors.black.withOpacity(.30) : Colors.white.withOpacity(.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: s.withOpacity(.75), width: 1.4),
            boxShadow: [BoxShadow(color: a.withOpacity(.14), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            if (title != null) ...[
              Text(title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: a, height: 1.6)),
              const SizedBox(height: 4),
            ],
            const OrnamentDivider(),
            const SizedBox(height: 12),
            SelectableText(
              snap.data?.replaceAll('\uFEFF', '') ?? '',
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18, height: 1.9),
            ),
            const SizedBox(height: 12),
            const OrnamentDivider(),
          ]),
        ),
      ),
    );
    return backdrop ? PageBackdrop(child: body) : body;
  }
}

class TextScreen extends StatelessWidget {
  final String title, asset;
  const TextScreen(this.title, this.asset, {super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text(title)), body: TextView(asset, title: title));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const channelUrl = 'https://whatsapp.com/channel/0029VbDUiUG2ER6g2kWq7D1E';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('من نحن')),
        body: PageBackdrop(
          child: Column(children: [
          const Expanded(child: TextView('assets/texts/about_us.txt', backdrop: false)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: const EdgeInsets.all(14)),
                onPressed: () => launchUrl(Uri.parse(channelUrl), mode: LaunchMode.externalApplication),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: const Text('قناة صلوات الأنوار «واتساب»',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
          const ContactCard(),
        ]),
        ),
      );
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});
  static const numbers = ['01146050106'];

  // 01xxxxxxxxx -> 201xxxxxxxxx (صيغة واتساب لمصر)
  Future<void> openWhatsApp(String n) =>
      launchUrl(Uri.parse('https://wa.me/20${n.substring(1)}'), mode: LaunchMode.externalApplication);

  Widget line(BuildContext context, String n) => Row(children: [
        Icon(Icons.phone_in_talk, color: sec(context), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
        ),
        InkWell(
          onTap: () => openWhatsApp(n),
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
            child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 28),
          ),
        ),
      ]);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [pri(context), Color.lerp(pri(context), Colors.white, .15)!]),
          border: Border.all(color: sec(context), width: 1.5),
          boxShadow: [BoxShadow(color: sec(context).withOpacity(.35), blurRadius: 14)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          line(context, numbers[0]),
        ]),
      );
}

// ---------- تبويب منهج الصلاة: قسمين (منهج الصلاة | اختبارات الحفظ) ----------
class PrayerHubTab extends StatefulWidget {
  const PrayerHubTab({super.key});
  @override
  State<PrayerHubTab> createState() => _PrayerHubTabState();
}

class _PrayerHubTabState extends State<PrayerHubTab> {
  int sub = 0;

  Widget _pill(BuildContext context, int k, String label, IconData icon) {
    final ac = accent(context);
    final sel = sub == k;
    final onSel = isDark(context) ? Colors.black87 : Colors.white;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => sub = k),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: sel ? ac : ac.withOpacity(.12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 20, color: sel ? onSel : ac),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: sel ? onSel : ac)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(children: [
          _pill(context, 0, 'منهج الصلاة', Icons.event_available),
          const SizedBox(width: 10),
          _pill(context, 1, 'اختبارات الحفظ', Icons.quiz),
        ]),
      ),
      Expanded(
        child: IndexedStack(index: sub, children: const [PrayerTab(), MemorizationTestsTab()]),
      ),
    ]);
  }
}

// ---------- اختبارات الحفظ ----------
class QuizOption {
  final String id, title;
  final IconData icon;
  const QuizOption(this.id, this.title, this.icon);
}

// القسم الأول: اختبار في حفظ (صيغ الصلاة / المدائح / السيرة)
const _quizTopics = [
  QuizOption('salat', 'صيغ الصلاة على سيدنا النبي', Icons.favorite),
  QuizOption('madaeh', 'كتب المدائح النبوية', Icons.music_note),
  QuizOption('sera', 'كتب السيرة النبوية', Icons.auto_stories),
];

// صيغ الصلاة: الثلاثة المطلوبين
const _quizSalatOptions = [
  QuizOption('mub', 'الصلوات المباركات على سيد السادات', Icons.favorite),
  QuizOption('anwar', 'صلوات الأنوار على سيد الأبرار', Icons.favorite),
  QuizOption('munajat', 'مناجاة الأشواق', Icons.favorite),
];

// أسماء الكتب بتتجاب من أقسام الكتب نفسها، فأي كتاب يتضاف للقسم بيظهر هنا لوحده
List<QuizOption> _quizBookOptions(BookSection sec) =>
    [for (final b in sectionBooks(sec)) QuizOption(b.id, b.title, sec.icon)];

class MemorizationTestsTab extends StatelessWidget {
  const MemorizationTestsTab({super.key});

  void _pick(BuildContext context, QuizOption t) {
    late final List<QuizOption> opts;
    switch (t.id) {
      case 'salat':
        opts = _quizSalatOptions;
        break;
      case 'madaeh':
        opts = _quizBookOptions(sectionMadaeh);
        break;
      default:
        opts = _quizBookOptions(sectionSera);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizChoiceScreen(
          title: t.title,
          question: 'هل تريد الاختبار في:',
          options: opts,
          onPick: (ctx, o) => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => QuizStartScreen(topic: t.title, name: o.title, id: o.id)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Text('اختبار في حفظ:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent(context))),
          ),
          for (var k = 0; k < _quizTopics.length; k++)
            _QuizCard(option: _quizTopics[k], color: mixIcon(context, k), onTap: () => _pick(context, _quizTopics[k])),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizOption option;
  final Color color;
  final VoidCallback onTap;
  const _QuizCard({required this.option, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withOpacity(.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(14)),
              child: Icon(option.icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(option.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.5)),
            ),
            Icon(Icons.chevron_left, color: color),
          ]),
        ),
      ),
    );
  }
}

// شاشة اختيار عامة (سؤال + خيارات)
class QuizChoiceScreen extends StatelessWidget {
  final String title, question;
  final List<QuizOption> options;
  final void Function(BuildContext, QuizOption) onPick;
  const QuizChoiceScreen({super.key, required this.title, required this.question, required this.options, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(fontSize: 17))),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                child: Text(question,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent(context))),
              ),
              for (var k = 0; k < options.length; k++)
                _QuizCard(option: options[k], color: mixIcon(context, k), onTap: () => onPick(context, options[k])),
            ],
          ),
        ),
      ),
    );
  }
}

// مؤقتًا: شاشة بداية الاختبار (لحد ما نحدد شكل الأسئلة)
class QuizStartScreen extends StatelessWidget {
  final String topic, name, id;
  const QuizStartScreen({super.key, required this.topic, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    if (id == 'sera') {
      return PoemQuizScreen(title: name, questions: seraQuiz, bestKey: 'quiz_best_sera');
    }
    if (id == 'borda') {
      return QuizChoiceScreen(
        title: name,
        question: 'هل تريد الاختبار في:',
        options: const [
          QuizOption('borda_anwar', 'بردة الأنوار المحمدية', Icons.menu_book),
          QuizOption('borda_habibi', 'قصيدة حبيبي محمد', Icons.menu_book),
        ],
        onPick: (ctx, o) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => o.id == 'borda_anwar'
                  ? PoemQuizScreen(title: o.title, questions: bordaQuiz, bestKey: 'quiz_best_borda')
                  : PoemQuizScreen(title: o.title, questions: habibiQuiz, bestKey: 'quiz_best_habibi'),
            ),
          );
        },
      );
    }
    if (id == 'alf') {
      return QuizChoiceScreen(
        title: name,
        question: 'هل تريد الاختبار في:',
        options: [
          for (var k = 0; k < alfChapterTitles.length; k++) QuizOption('alf$k', alfChapterTitles[k], Icons.menu_book),
        ],
        onPick: (ctx, o) {
          final k = int.parse(o.id.substring(3));
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PoemQuizScreen(title: o.title, questions: alfQuiz[k], bestKey: 'quiz_best_alf_$k'),
            ),
          );
        },
      );
    }
    final ac = accent(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختبار الحفظ', style: TextStyle(fontSize: 17))),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.quiz, size: 64, color: ac),
                const SizedBox(height: 14),
                Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ac, height: 1.6)),
                const SizedBox(height: 8),
                Text(topic, style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 18),
                Text('الاختبار قريبًا إن شاء الله', style: TextStyle(color: Theme.of(context).hintColor)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- اختبار المنظومة اللطيفة (100 سؤال اختياري) ----------
class PoemQ {
  final String prompt, stem;
  final List<String> options;
  final int answer;
  const PoemQ(this.prompt, this.stem, this.options, this.answer);
}

const seraQuiz = <PoemQ>[
  PoemQ('أكمل الشطر الثاني من البيت:', 'بِسْمِ القَدِيرِ الوَاجِدِ المَنَّانِ', ['وَاخْتَارَهُنَّ اللهُ رَبُّ العَالَمِينْ', 'ذِي الفَضْلِ وَالتَّوفِيقِ وَالإحْسَانِ', 'مُنَادِيًا لِلزَّوجَةِ الحَنُونِ', 'مَحَبَّةٌ فِي اللهِ بِاليَقِينِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٍ وَآلِهِ الأطْهَارِ\nوَصَحْبِهِ السَّادَاتِ وَالأبْرَارِ', ['هُوَ الحَبِيبُ رَبُّنَا اصْطَفَاهُ', 'أبْدَأُ فِي نَظْمٍ بَدِيعٍ شَافِي', 'وَانطَلَقَ النَّبِيُّ وَالصِّدِّيقُ', 'وَمُؤتَةُ أمَامَ جَيشِ الرُّومِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِطَالِبِ السِّيرَةِ فَهُوَ وَافِي', ['فَقَالَ زَمِّلُونِي زَمِّلُونِي', 'أكُنتُمُ مُصَدِّقِينَ قَولِي', 'وَقَاطَعَتْ قُرَيشُ آلَ المُصطَفَى', 'أبْدَأُ فِي نَظْمٍ بَدِيعٍ شَافِي'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'أبْدَأُ بَعدَ ذَاكَ بِالمِيلَادِ', ['لِلسَّيِّدِ المُطَهَّرِ الأجْدَادِ', 'وَرَأفَةٌ بِالخَلْقِ لَا تُعَدُّ', 'غَزوَةُ بَدرٍ دُونَما استِعدَادِ', 'عَلَى النَّبِيِّ الطَّيِّبِ المُمَجَّدِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ آدَمَ وَالنُّورُ فِي الأصْلَابِ\nيَسرِي بِفَضْلِ الوَاحِدِ الوَهَّابِ', ['فَوَصَفَتْهُ خَيرَ وَصفٍ كَانَا', 'وَقَاطَعَتْ قُرَيشُ آلَ المُصطَفَى', 'حَتَّى استَقَرَّ عِندَ عَبدِ اللهِ', 'قَدِ انتَهَى بِفَضلِهِ الخِصَامُ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَخَيرِ أُمٍّ شَرُفَتْ فِي النَّسَبِ', ['وَأهلُ طَيبَةَ عَلَى الأبوَابِ', 'فَجَاءَ لِلأكْوَانِ مِنْ خَيرِ أبِ', 'مِنْ آدَمَ وَالنُّورُ فِي الأصْلَابِ', 'وَبَعدَهَا الخَندَقُ وَالأحزَابُ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مَاتَ أبُوهُ قَبلَ أنْ يَرَاهُ', ['إلَى مُلُوكِ الدُّوَلِ الكَبِيرَةْ', 'وَجَدُّهُ مِنْ بَعدِهِ رَعَاهُ', 'وَصَدَّقُوا وَأخلَصُوا اتِّبَاعَهْ', 'بِغَارِ حِرَاءَ وَقَدْ رَآهُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعِندَهَا قَدْ جَاءَتِ الآيَاتُ\nفِي المَولِدِ الشَّرِيفِ بُشْرَيَاتُ', ['فَالفَتحُ كَانَ كَامِلًا مُبِينا', 'قَدْ خَصَّهُ الرَّحمَنُ بِالتَّفضِيلِ', 'فَقَدْ كَفَاهُم نِقمَةَ التَّنَازُعِ', 'وَبَعدَ خَمسٍ مَعَ ثَلَاثِينَ أتَى'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَخُذْ لِهَذَا الشَّرحِ وَالتَّفصِيلِ', ['وَبَعدَ ذَاكَ جَاءَهُ الرَّسُولُ', 'فَوَقَفَ النَّبِيُّ فَوقَ الجَبَلِ', 'قَدْ خَصَّهُ الرَّحمَنُ بِالتَّفضِيلِ', 'فَغَاصَ مِنهُ خَيلُهُ فِي الرَّملِ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَخَمَدَتْ فِي الفُرسِ نَارُ كِسرَى', ['وَكَانَ مِنْ أهلِ العُلُومِ وَالنُّهَى', 'مُعجِزَةً حَتمًا لِمَنْ كَانَ يَرَى', 'وَقَدْ نَهَى النَّاسَ عَنِ التَّبَاهِي', 'إلَيكُمُ تَجَنَّبُوا المَنَاهِي'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'آيَاتُ هَذَا المَولِدِ الشَّرِيفِ\nتَوَاتَرَتْ بِالجَمعِ وَالتَّصنِيفِ', ['وَبَعْدَهَا زَيْنَبُ بِنْتُ خُزَيْمَةِ', 'وَبَاضَتِ الحَمَامُ عِندَ الغَارِ', 'وَقَدْ أتَى لِكَوْنِنَا مَختُونًا', 'وَعِندَمَا أتَمَّ مُصطَفَانَا'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ذَاتُ الوَفَاءِ السَّيِّدَةْ الكَرِيمَةُ', ['وَأرْضَعَتهُ أُمُّهُ حَلِيمَةُ', 'وَبَعْدَهَا هِنْدُ أَيْ أُمُّ سَلَمَةْ', 'خَوفًا عَلَيهِ عِندَ شَقِّ صَدرِهِ', 'فِي السَّنَةِ الثَّانِيَةِ بَعدَ الهِجرَةِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَعِندَهَا عَادَتْ بِهِ حَلِيمَةُ', ['مُؤمِنَةً بِشَأنِهِ وَقَدرِهِ', 'لِبِنتِ وَهْبٍ أُمِّهِ العَظِيمَةِ', 'فِي قَلبِهِ وَلَمْ تَزَلْ مُكَرَّمَةْ', 'وَلِتَنطِقُوا بِكَلِمَةِ الشَّهَادَةْ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَوفًا عَلَيهِ عِندَ شَقِّ صَدرِهِ\nمُؤمِنَةً بِشَأنِهِ وَقَدرِهِ', ['فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما', 'وَبَعدَ سِتٍّ مِنْ سِنِينَ عُمرِهِ', 'حُبُّكَ فِي القُلُوبِ وَالسَّلَامُ', 'وَحِينَ ذَاكَ جَاءَهُ المَلَكَانِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِسَنَتَينِ مِثلِهَا أيْضًا ذَهَبْ', ['وَبَعدَهَا جَدُّهُ عَبدُ المُطَّلِبْ', 'مِنْ آدَمَ وَالنُّورُ فِي الأصْلَابِ', 'وَأقبَلَ الوُفُودُ مِنْ كُلِّ العَرَبْ', 'فَجَاءَ لِلأكْوَانِ مِنْ خَيرِ أبِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَمُّهُ أخُو أبِيهِ بَعدَهُ', ['وَصَدَّقُوا وَأخلَصُوا اتِّبَاعَهْ', 'رَعَاهُ حُبًّا وَأطَاعَ جَدَّهُ', 'لِقَلْبِهِ الشَّرِيفِ وَالمُقَرَّبَةْ', 'مِنْ أهلِ طَيبَةَ وَبَايَعُوهُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعِندَمَا أتَمَّ مُصطَفَانَا\nخَمسًا وَعِشرِينَ كَمَا أتَانَا', ['بِاسمِ الكَرِيمِ الوَاحِدِ الَّذِي خَلَقْ', 'فَالنَّصرُ مِنْ عِندِ الإلَهِ يَاتِي', 'تَزَوَّجَ السَّيِّدَةَ الكَرِيمَةْ', 'وَمُؤتَةُ أمَامَ جَيشِ الرُّومِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خَدِيجَةَ الحَبِيبَةَ العَظِيمَةْ', ['تَزَوَّجَ السَّيِّدَةَ الكَرِيمَةْ', 'أَخْلَاقُهُ جَلَّتْ عَنِ التَّشْبِيهِ', 'وَبَعدَهَا تَبُوكُ جَيشُ العُسرَةِ', 'قَالَ لَهُم إنِّي رَسُولُ اللهِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'كَانَتْ تَقُومُ دَائِمًا لِخِدمَتِهْ', ['بِنَفسِهَا وَمَالِهَا لِنُصرَتِهْ', 'لِبِنتِ وَهْبٍ أُمِّهِ العَظِيمَةِ', 'وَرَمْلَةُ وَبَعْدَهَا صَفِيَّةْ', 'امْرَأَةً نُفُوسُهُم مُطَهَّرَهْ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَنَالَتِ المَكَانَةَ المُعَظَّمَةْ\nفِي قَلبِهِ وَلَمْ تَزَلْ مُكَرَّمَةْ', ['قَدْ خَصَّهُ الرَّحمَنُ بِالتَّفضِيلِ', 'وَمِنهُمُ خَدِيجَةُ الكَرِيمَةُ', 'مَاذَا تَرَوْنِي فِيكُمُ أجِيبُوا', 'وَأنجَبَتْ لأحْمَدَ البَنِينَا'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِنَاءُ كَعبَةٍ كَمَا قَدْ ثَبَتَا', ['أنْ يَنصُرَ النَّبِيَّ دَائِمًا عَلَى', 'أبْدَأُ فِي نَظْمٍ بَدِيعٍ شَافِي', 'فَالنَّصرُ مِنْ عِندِ الإلَهِ يَاتِي', 'وَبَعدَ خَمسٍ مَعَ ثَلَاثِينَ أتَى'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَضَعَ الأَمِينُ ذَلِكَ الحَجَرْ', ['كِسرَى بِغَيرِ شَكٍّ فِي الحِوَارِ', 'يَهُودُهُم لِعَهدِهِم كَمَا اشتَهَرْ', 'وَعَمَّتِ الأفرَاحُ مَا بَينَ البَشَرْ', 'لِيَقتُلُوا الَّذِي أتَى بِالذِّكرِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعدَ ذَاكَ جَاءَهُ الرَّسُولُ\nمِنَ الإلَهِ مُنَزَّلًا جِبرِيلُ', ['وَهَاجَرَ الأصْحَابُ لِلنَّجَاشِي', 'وَاخْلِصُوهُ وَحدَهُ العِبَادَةْ', 'فَلَمْ يَكُنْ لَدَيهَا غَيرُ شَاةِ', 'فِي عَامِ أربَعِينَ مِنْ سِنِينِهِ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِغَارِ حِرَاءَ وَقَدْ رَآهُ', ['وَأنَّ قَومَهُ سَيُخرِجُونَهُ', 'فِي عَامِ أربَعِينَ مِنْ سِنِينِهِ', 'قَالَ لَهُ اقْرَأْ عِندَمَا أتَاهُ', 'أُوَلُهُنَّ السَّيِّدَةْ خَدِيجَةْ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'بِاسمِ الكَرِيمِ الوَاحِدِ الَّذِي خَلَقْ', ['وَمُنكِرِ الخُبثِ مَعَ النِّفَاقِ', 'فَهُوَ الحَبِيبُ وَهُوَ الرَّفِيقُ', 'كَمَا أتَى فِي سُورَةٍ هِيَ العَلَقْ', 'لِغَارِ ثَورٍ مَعْهُمَا رَفِيقُ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَقَالَ زَمِّلُونِي زَمِّلُونِي\nمُنَادِيًا لِلزَّوجَةِ الحَنُونِ', ['فَذَهَبَتْ بِهِ إلَى ابنِ عَمِّهَا', 'نَجَا بِعَونِ اللهِ مِنْ أذَاهُم', 'وَبَعدَ سِتٍّ مِنْ سِنِينَ عُمرِهِ', 'وَقَاطَعَتْ قُرَيشُ آلَ المُصطَفَى'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَانَ مِنْ أهلِ العُلُومِ وَالنُّهَى', ['فَحَرَّمَ الرِّبَا عَلَيهِمُ بِهَا', 'أنْ يَأخُذَ الأمْوَالَ وَالجِمَالَا', 'فَذَهَبَتْ بِهِ إلَى ابنِ عَمِّهَا', 'مَاذَا تَرَوْنِي فِيكُمُ أجِيبُوا'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَأنَّ هَذَا الوَحيَ كَانَ يَنزِلُ', ['عَلَى نَبِيِّ اللهِ مُوسَى الأوَّلُ', 'وَأنَّ مَنْ أتاهُ ذا جِبرِيلُ', 'مِنَ الإلَهِ مُنَزَّلًا جِبرِيلُ', 'مُنَادِيًا فِي قَومِهِ بِالأمَلِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأنَّ قَومَهُ سَيُخرِجُونَهُ\nوَعَنْ بِلَادِهِ سَيَمنَعُونَهُ', ['وَقَدْ تَمَنَّى أنْ يَكُونَ حَاضِرًا', 'وَزَيْنَبُ الأُخْرَى كَذَا جُوَيْرِيَةْ', 'وَعَمُّهُ أخُو أبِيهِ بَعدَهُ', 'وَبَعدَهَا تُوُفِّيَ الحَبِيبُ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي السِّرِّ لِلأهلِ وَلِلعَبِيدِ', ['فَقَدْ أحَبَّهَا بِغَيرِ حَدِّ', 'وَبَعدَهَا بِسَنَةٍ كَانَتْ أُحُدْ', 'وَبَعدَهَا دَعَى إلَى التَّوحِيدِ', 'وَبَعدَهَا جَاءَتْ بِلَا مِيعَادِ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'فَآمَنَتْ بِدِينِهِ جَمَاعَةْ', ['أُمُّ ابْنِهِ وَهَذِهِ القِبْطِيَّةْ', 'وَصَدَّقُوا وَأخلَصُوا اتِّبَاعَهْ', 'فِي قَلبِهِ وَلَمْ تَزَلْ مُكَرَّمَةْ', 'عَاجِزَةٍ مَلَّتْ مِنَ الحَيَاةِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمِنهُمُ خَدِيجَةُ الكَرِيمَةُ\nالزَّوجَةُ الشَّرِيفَةُ العَلِيمَةُ', ['صَلَّى عَلَيكَ اللهُ يَا نَبِيَّنَا', 'وَمِنهُمُ عَلِيٌّ الكَرَّارُ', 'وَعَمُّهُ أخُو أبِيهِ بَعدَهُ', 'قَالَ لَهُ اقْرَأْ عِندَمَا أتَاهُ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَغَيرُهُم أصْحَابُهُ الأطْهَارُ', ['وَبَعْدَهَا حَفْصَةُ بِنْتُ عُمَرَ', 'وَبَاضَتِ الحَمَامُ عِندَ الغَارِ', 'وَمِنهُمُ عَلِيٌّ الكَرَّارُ', 'وَبَعدَهَا بِعَامٍ كَانَتْ خَيبَرُ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ إذْنُ الدَّعوَةِ الجَهرِيَّةِ', ['فِي عَامِ تِسعٍ ضِدَّ رُومِ الحُمرَةِ', 'كَمْ حَيَّرَتْ مِنْ عَاقِلٍ نَبِيهِ', 'ذَاتُ الوَفَاءِ وَالنَّدَى الكَرِيمَةْ', 'بَعدَ سِنِينَ الدَّعوَةِ السِّرِّيَّةِ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَاذَا تَرَوْنِي فِيكُمُ أجِيبُوا\nقَالُوا صَدُوقٌ طَاهِرٌ حَبِيبُ', ['قَالَ لَهُمْ لَو أنَّنِي أخبَرتُكُم', 'أضَاءَ مِنهَا كُلُّ شَيءٍ عِندَمَا', 'وَبَعدَهَا النَّضِيرُ عِندَمَا غَدَرْ', 'وَمِنهُمُ خَدِيجَةُ الكَرِيمَةُ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أنَّ العَدُوَّ خَلفَ هَذَا جَاءَكُم', ['قَدِ انتَهَى بِفَضلِهِ الخِصَامُ', 'فَلَمْ يَرَوْهُ أُغشِيَتْ أبصَارُهُم', 'قَالَ لَهُمْ لَو أنَّنِي أخبَرتُكُم', 'السَّابِقُونَ الأوَّلُونَ نَعتُهُمْ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُم إنِّي رَسُولُ اللهِ', ['لِطَالِبِ السِّيرَةِ فَهُوَ وَافِي', 'مُعجِزَةً حَتمًا لِمَنْ كَانَ يَرَى', 'إلَيكُمُ تَجَنَّبُوا المَنَاهِي', 'وَقَدْ نَهَى النَّاسَ عَنِ التَّبَاهِي'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاخْلِصُوهُ وَحدَهُ العِبَادَةْ\nوَلِتَنطِقُوا بِكَلِمَةِ الشَّهَادَةْ', ['وَحِينَ ذَاكَ جَاءَهُ المَلَكَانِ', 'وَأسلَمَ الحَمزَةُ وَالفَارُوقُ', 'وَصَالَحَ اليَهُودَ فِي المَدِينَةِ', 'فَعَانَدُوهُ عِندَهَا وَخَالَفُوا'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَذَّبُوا بِقَولِهِ تَكذِيبا', ['وَقَدْ أتَى لِكَوْنِنَا مَختُونًا', 'وَعَذَّبُوا أصْحَابَهُ تَعذِيبا', 'فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما', 'أجَابَهُمْ بِعَفوِهِ رَحِيما'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَهَاجَرَ الأصْحَابُ لِلنَّجَاشِي', ['مُعجِزَةً حَتمًا لِمَنْ كَانَ يَرَى', 'حَيثُ الأمَانُ وَالوَفَاءُ فَاشِي', 'لِطَالِبِ السِّيرَةِ فَهُوَ وَافِي', 'إلَيكُمُ تَجَنَّبُوا المَنَاهِي'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى انتَهَى بِقُدرَةِ الإلَهِ\nوَقَرَّ فِي الصَّحِيفَةِ اسمُ اللهِ', ['وَأسلَمَ الحَمزَةُ وَالفَارُوقُ', 'فَهَاجَرَ الأصْحَابُ أوَّلًا إلَى', 'لَهَا كَلَامٌ فِيهِ لَا مَثِيلَ لَهْ', 'هُوَ الحَبِيبُ رَبُّنَا اصْطَفَاهُ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَكَانَ نَصرًا ظَاهِرًا يَفُوقُ', ['وَانطَلَقَ النَّبِيُّ وَالصِّدِّيقُ', 'مِنهُم أبُو بَكرٍ هُوَ الصِّدِّيقُ', 'بِأحمَدَ الهَادِي إلَى الأخلَاقِ', 'وَأسلَمَ الحَمزَةُ وَالفَارُوقُ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَمَاتَ عَمُّ المُصطَفَى وَزَوجَتُهُ', ['وَقَرَّ فِي الصَّحِيفَةِ اسمُ اللهِ', 'وَعَنْ بِلَادِهِ سَيَمنَعُونَهُ', 'وَذَاكَ عَامُ الحُزنِ حَيثُ شِدَّتُهُ', 'عَاجِزَةٍ مَلَّتْ مِنَ الحَيَاةِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَارَ لِلطَّائِفِ يَدعُوهُمْ إلَى\nرِضَا الكَرِيمِ مِثلَ مَا قَدْ أُرسِلَا', ['فَأطلَقُوا السُّفَهَاءَ بِالإيذَاءِ', 'بِسْمِ القَدِيرِ الوَاجِدِ المَنَّانِ', 'مُحَمَّدٍ وَآلِهِ الأطْهَارِ', 'وَزَيْنَبُ الأُخْرَى كَذَا جُوَيْرِيَةْ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيَطلُبَا الهَلَاكَ لِلمَكَانِ', ['وَكُلُّهُنَّ أُمَّهَاتُ المُؤْمِنِينْ', 'بِسْمِ القَدِيرِ الوَاجِدِ المَنَّانِ', 'مَنْطِقُهُ بِالوَحْيِ وَالقُرْآنِ', 'وَحِينَ ذَاكَ جَاءَهُ المَلَكَانِ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعدَهَا حَادِثَةُ المِعرَاجِ', ['وَأنَّ مَنْ أتاهُ ذا جِبرِيلُ', 'وَبَعدَهَا قَبَائِلُ الحُجَّاجِ', 'تَحْكِي لَنَا سِيرَتَهُ المُعَطَّرَةْ', 'بِكَفِّهِ فَأنزَلَتْ حَلِيبَهَا'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'جَاءُوا لِمَكَّةَ وَصَدَّقُوهُ\nمِنْ أهلِ طَيبَةَ وَبَايَعُوهُ', ['أنْ يَأخُذَ الأمْوَالَ وَالجِمَالَا', 'وَهَاجَرَ الأصْحَابُ لِلنَّجَاشِي', 'فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما', 'وَبَعدَهَا قَدْ جَاءَ إذْنُ الهِجرَةِ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَدِينَةِ الأنْوَارِ أرضِ النُّبَلَا', ['بِوعَدِهِ بِتَركِهِم سِوَارِي', 'فَقَالَ زَمِّلُونِي زَمِّلُونِي', 'أبْدَأُ فِي نَظْمٍ بَدِيعٍ شَافِي', 'فَهَاجَرَ الأصْحَابُ أوَّلًا إلَى'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَانطَلَقَ النَّبِيُّ وَالصِّدِّيقُ', ['لِغَارِ ثَورٍ مَعْهُمَا رَفِيقُ', 'فَهُوَ الحَبِيبُ وَهُوَ الرَّفِيقُ', 'فَكَانَ نَصرًا ظَاهِرًا يَفُوقُ', 'وَمُنكِرِ الخُبثِ مَعَ النِّفَاقِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَدْ أتَى لِلغَارِ أهلُ الكُفرِ\nلِيَقتُلُوا الَّذِي أتَى بِالذِّكرِ', ['وَقَدْ تَمَنَّى أنْ يَكُونَ حَاضِرًا', 'فِي عَرَفَاتٍ تَمَّ دِينُ اللهِ', 'فَلَمْ يَرَوْهُ أُغشِيَتْ أبصَارُهُم', 'وَمُؤتَةُ أمَامَ جَيشِ الرُّومِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالعَنكَبُوتُ أُنسِجَتْ أمَامَهُم', ['ثُمَّ الحُدَيبِيَّة بَعدَ عَامِ', 'فَلَمْ يَرَوْهُ أُغشِيَتْ أبصَارُهُم', 'حُبُّكَ فِي القُلُوبِ وَالسَّلَامُ', 'السَّابِقُونَ الأوَّلُونَ نَعتُهُمْ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'نَجَا بِعَونِ اللهِ مِنْ أذَاهُم', ['أنَّ العَدُوَّ خَلفَ هَذَا جَاءَكُم', 'عَهدٌ عَلَى الصُّلحِ مَعَ السَّلَامِ', 'وَسَارَ لِلأنصَارِ قَدْ هَوَاهُم', 'فِي ذَلِكَ اليَومِ عَلَى التَّمَامِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَوَدَّعَ النَّبِيُّ أرضَهُ مَعَا\nبُكَاءِه وَالعَينُ فَاضَتْ أدْمُعَا', ['وَقَدْ أتَى لِكَوْنِنَا مَختُونًا', 'فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما', 'فَقَدْ أحَبَّهَا بِغَيرِ حَدِّ', 'فَأصبَحَتْ أخُوَّةٌ فِي الدِّينِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'نَبِيَّنَا وَنَفسُهُ تَوَّاقَةْ', ['قَالَ لَهُ اقْرَأْ عِندَمَا أتَاهُ', 'فَآمَنَتْ بِدِينِهِ جَمَاعَةْ', 'تَزَوَّجَ السَّيِّدَةَ الكَرِيمَةْ', 'وَفِي الطَّرِيقِ قَدْ رَأى سُرَاقَةْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'أنْ يَأخُذَ الأمْوَالَ وَالجِمَالَا', ['مُسَارِعًا إلَيهِمُ إقبَالَا', 'بِنَصرِهِ وَدِينِهِ الأمِينَا', 'وَكَذَّبُوا بِقَولِهِ تَكذِيبا', 'أكْرِمْ بِصَدرٍ قَدْ وَعَى القُرْآنَا'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما\nعَلَيهِ فأجَابَهُ مُكَلِّما', ['بِوعَدِهِ بِتَركِهِم سِوَارِي', 'فَوَقَفَ النَّبِيُّ فَوقَ الجَبَلِ', 'وَنَقَضَتْ قُرَيظَةُ العُهُودَا', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ السَّرمَدِي'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُنَافِحًا لأجْلِهِ مُعِينا', ['فَعَادَ نَحوَ قَومِهِ أمِينا', 'أجَابَهُمْ بِعَفوِهِ رَحِيما', 'فَعَانَدُوهُ عِندَهَا وَخَالَفُوا', 'آخَىٰ النَّبِيُّ بَينَ مَنْ قَدْ هَاجَرَا'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعدَهَا أتَوا لأُمِّ مَعبَدِ', ['لِلسَّيِّدِ المُطَهَّرِ الأجْدَادِ', 'دَومًا بِلَا حَدٍّ وَلَا تَعدَادِ', 'فِي السِّرِّ لِلأهلِ وَلِلعَبِيدِ', 'مَنْ وَصَفَتْ لِسَيِّدِي المُمَجَّدِ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'دَعَا بِهَا المُختَارُ ثُمَّ مَسَّهَا\nبِكَفِّهِ فَأنزَلَتْ حَلِيبَهَا', ['فَآمَنَتْ بِدِينِهِ جَمَاعَةْ', 'فَالفَتحُ كَانَ كَامِلًا مُبِينا', 'السَّابِقُونَ الأوَّلُونَ نَعتُهُمْ', 'فَشَرِبُوا جَمِيعُهُم وَشَبِعُوا'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَفِي المَسِيرِ بَعدَ ذَاكَ شَرَعُوا', ['فَشَرِبُوا جَمِيعُهُم وَشَبِعُوا', 'دَعَا بِهَا المُختَارُ ثُمَّ مَسَّهَا', 'وَقَدْ أتَى لِكَوْنِنَا مَختُونًا', 'فَأصبَحُوا بِفَضلِهِ جَمِيعا'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'فَوَصَفَتْهُ خَيرَ وَصفٍ كَانَا', ['أكْرِمْ بِصَدرٍ قَدْ وَعَى القُرْآنَا', 'حِصنًا عَلَى أعْدَائِهِم مَنِيعا', 'وَاللهُ رَبُّنَا أعَزَّ الدِّينَا', 'وَعَمَّرَتْ أوصَافُهَا الزَّمَانَا'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَهَا كَلَامٌ فِيهِ لَا مَثِيلَ لَهْ\nوَوَصفُهَا فِي المُصطَفَى مَا أجمَلَهْ', ['وَأهلُ طَيبَةَ عَلَى الأبوَابِ', 'كَانَتْ تَقُومُ دَائِمًا لِخِدمَتِهْ', 'وَمِنهُمُ عَلِيٌّ الكَرَّارُ', 'فَقَدْ كَفَاهُم نِقمَةَ التَّنَازُعِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكُلُّهُم يَهتِفُ بِالأشعَارْ', ['وَبَعدَهَا بِعَامٍ كَانَتْ خَيبَرُ', 'وَبَعْدَهَا حَفْصَةُ بِنْتُ عُمَرَ', 'وَوَضَعَ الأَمِينُ ذَلِكَ الحَجَرْ', 'فَجَاءَهُم نَبِيُّنَا المُختَارْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'أضَاءَ مِنهَا كُلُّ شَيءٍ عِندَمَا', ['كُلِّ الأعَادِي نَصرَهُ المُعَجَّلَا', 'عَامَ ثَمَانٍ إذْ طَغَتْ عَنْ حَدِّهَا', 'مُسَارِعًا إلَيهِمُ إقبَالَا', 'دَخَلَهَا المُختَارُ وَالخَيرُ نَمَا'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدِ انتَهَى بِفَضلِهِ الخِصَامُ\nمِنْ بَينِهِم وَالكُرهُ وَالظَّلَامُ', ['بِاسمِ الكَرِيمِ الوَاحِدِ الَّذِي خَلَقْ', 'لَهَا كَلَامٌ فِيهِ لَا مَثِيلَ لَهْ', 'هُوَ الحَبِيبُ رَبُّنَا اصْطَفَاهُ', 'وَشَاعَ مِنْ بَينِهِمُ الوِئَامُ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالحُبُّ وَالوِدَادُ وَالسَّلَامُ', ['قَدِ انتَهَى بِفَضلِهِ الخِصَامُ', 'ثُمَّ الحُدَيبِيَّة بَعدَ عَامِ', 'وَشَاعَ مِنْ بَينِهِمُ الوِئَامُ', 'حُبُّكَ فِي القُلُوبِ وَالسَّلَامُ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'آخَىٰ النَّبِيُّ بَينَ مَنْ قَدْ هَاجَرَا', ['مَعَ الَّذِي مِنهُم لَهُ قَدْ نَاصَرَا', 'بِنَصرِهِ وَدِينِهِ الأمِينَا', 'عَنِ الأَذَى مُنَزَّهًا سَلِيمًا', 'صَارُوا عَلَى عَدَائِهِ تَحَالَفُوا'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَشُرِعَ الأذَانُ لِلصَّلَاةِ\nوَشُيِّدَتْ مَعَالِمُ الحَيَاةِ', ['حَتَّى انتَهَى بِقُدرَةِ الإلَهِ', 'وَصَالَحَ اليَهُودَ فِي المَدِينَةِ', 'أبْدَأُ فِي نَظْمٍ بَدِيعٍ شَافِي', 'وَعَادَ نَحوَ بَيتِهِ عَلَيهِ مِنْ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيَرتَعُوا بِعِيشَةٍ أمِينَةِ', ['وَبَعْدَهَا سَوْدَةُ بِنْتُ زَمْعَةْ', 'وَصَالَحَ اليَهُودَ فِي المَدِينَةِ', 'يَدُلُّهُمْ إلَى الطَّرِيقِ إنَّهُ', 'وَبَعدَهَا قَدْ جَاءَ إذْنُ الهِجرَةِ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'فِي السَّنَةِ الثَّانِيَةِ بَعدَ الهِجرَةِ', ['ابنُ أرِيقِطَ وَذَاكَ فَنُّهُ', 'وَانتَصَرُوا فِيهَا بِإذْنِ الحَضرَةِ', 'فَاحْفَظْ لِهَذَا العِلْمِ تَلْقَ المَنْفَعَةْ', 'فِيهَا دُرُوسٌ لِلقُلُوبِ المُؤمِنَةْ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَالنَّصرُ مِنْ عِندِ الإلَهِ يَاتِي\nفَعَمَّهُم بِالنَّصرِ وَالثَّبَاتِ', ['مِنْ آدَمَ وَالنُّورُ فِي الأصْلَابِ', 'وَنَقَضَتْ قُرَيظَةُ العُهُودَا', 'وَبَعدَهَا بِسَنَةٍ كَانَتْ أُحُدْ', 'وَعَذَّبُوا أصْحَابَهُ تَعذِيبا'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَدْ خَالَفُوا كَلَامَهُ المُعَظَّمَا', ['مَاذَا تَرَوْنِي فِيكُمُ أجِيبُوا', 'فَحَرَّمَ الرِّبَا عَلَيهِمُ بِهَا', 'فَأصبَحُوا بِفَضلِهِ جَمِيعا', 'انهَزَمَ الرُّمَاةُ وَحدَهُم لِمَا'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعدَهَا النَّضِيرُ عِندَمَا غَدَرْ', ['وَكُلُّهُم يَهتِفُ بِالأشعَارْ', 'يَهُودُهُم لِعَهدِهِم كَمَا اشتَهَرْ', 'وَكَانَ نَصرًا لِلنَّبِيِّ مُظَفَّرُ', 'وَغَيرُهُم أصْحَابُهُ الأطْهَارُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَنَقَضَتْ قُرَيظَةُ العُهُودَا\nفَأخرَجَ اللهُ بِذَا اليَهُودَا', ['فَقَدْ كَفَاهُم نِقمَةَ التَّنَازُعِ', 'ثُمَّ الحُدَيبِيَّة بَعدَ عَامِ', 'وَعِندَمَا أتَمَّ مُصطَفَانَا', 'فَوَقَفَ النَّبِيُّ فَوقَ الجَبَلِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَهدٌ عَلَى الصُّلحِ مَعَ السَّلَامِ', ['ثُمَّ الحُدَيبِيَّة بَعدَ عَامِ', 'السَّابِقُونَ الأوَّلُونَ نَعتُهُمْ', 'فَلَمْ يَرَوْهُ أُغشِيَتْ أبصَارُهُم', 'حُبُّكَ فِي القُلُوبِ وَالسَّلَامُ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَمُؤتَةُ أمَامَ جَيشِ الرُّومِ', ['أنَّ العَدُوَّ خَلفَ هَذَا جَاءَكُم', 'فِي الذِّكرِ وَالرَّحمَنُ أعْلَى قَدرَهُم', 'عَلَيكَ لَا يُحصِيهِمَا الكَلَامُ', 'وَالفَضلُ فَضلُ الوَاحِدِ القَيُّومِ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أنْ يَنصُرَ النَّبِيَّ دَائِمًا عَلَى\nكُلِّ الأعَادِي نَصرَهُ المُعَجَّلَا', ['وَفَتحُ مَكَّةَ أتَى مِنْ بَعدِهَا', 'شَجَاعَةٌ فِي الحَقِّ لَا تُحَدُّ', 'أكُنتُمُ مُصَدِّقِينَ قَولِي', 'وَزَيْنَبُ الأُخْرَى كَذَا جُوَيْرِيَةْ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِنَصرِهِ وَدِينِهِ الأمِينَا', ['أجَابَهُمْ بِعَفوِهِ رَحِيما', 'فَجَاءَ فَتحُ رَبِّنَا مُبِينا', 'فَالفَتحُ كَانَ كَامِلًا مُبِينا', 'وَعَادَ زَوجُهَا فَكَانَ مُعجَبا'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعدَهَا تَبُوكُ جَيشُ العُسرَةِ', ['رَعَاهُ حُبًّا وَأطَاعَ جَدَّهُ', 'الزَّوجَةُ الشَّرِيفَةُ العَلِيمَةُ', 'فِي عَامِ تِسعٍ ضِدَّ رُومِ الحُمرَةِ', 'في السِّيرَةِ النَّبَوِيَّةِ الشَّرِيفَةْ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأقبَلَ الوُفُودُ مِنْ كُلِّ العَرَبْ\nفِي عَامِ عَشرٍ أقبَلُوا بِلَا عَجَبْ', ['وَمِنهُمُ عَلِيٌّ الكَرَّارُ', 'بُيُوتُهُ فِي طَيْبَةَ المُنَوَّرَةْ', 'فَالفَتحُ كَانَ كَامِلًا مُبِينا', 'وَحِينَ ذَاكَ جَاءَهُ المَلَكَانِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمُنكِرِ الخُبثِ مَعَ النِّفَاقِ', ['وَانطَلَقَ النَّبِيُّ وَالصِّدِّيقُ', 'بِأحمَدَ الهَادِي إلَى الأخلَاقِ', 'وَأسلَمَ الحَمزَةُ وَالفَارُوقُ', 'بِاسمِ الكَرِيمِ الوَاحِدِ الَّذِي خَلَقْ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَأرسَلَ الرَّسَائِلَ الكَثِيرَةْ', ['بِالوَحيِ مِنْ رَبِّي إلَى أمِينِهِ', 'ابنُ أرِيقِطَ وَذَاكَ فَنُّهُ', 'إلَى مُلُوكِ الدُّوَلِ الكَبِيرَةْ', 'امْرَأَةً نُفُوسُهُم مُطَهَّرَهْ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَحَرَّمَ الرِّبَا عَلَيهِمُ بِهَا\nوَصَّاهُمُ عَلَى الصَّلَاةِ وَقتَهَا', ['وَحَرَّمَ الخَمرَ وَظُلمَ النَّاسِ', 'وَمُؤتَةُ أمَامَ جَيشِ الرُّومِ', 'انهَزَمَ الرُّمَاةُ وَحدَهُم لِمَا', 'وَوَدَّعَ النَّبِيُّ أرضَهُ مَعَا'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَذِّرًا مِنْ نِقمَةِ الإفلَاسِ', ['وُلِدَ فِي مَكَّةَ عَامَ الفِيلِ', 'وَحَرَّمَ الخَمرَ وَظُلمَ النَّاسِ', 'تَوَاضُعٌ للهِ بَيْنَ النَّاسِ', 'أنْ يَنصُرَ النَّبِيَّ دَائِمًا عَلَى'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعدَهَا تُوُفِّيَ الحَبِيبُ', ['بِسَنَتَينِ مِثلِهَا أيْضًا ذَهَبْ', 'وَخَيرِ أُمٍّ شَرُفَتْ فِي النَّسَبِ', 'فِي عَامِ عَشرٍ أقبَلُوا بِلَا عَجَبْ', 'دَاعِي لِقَاءِ رَبِّهِ يُجِيبُ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بُيُوتُهُ فِي طَيْبَةَ المُنَوَّرَةْ\nتَحْكِي لَنَا سِيرَتَهُ المُعَطَّرَةْ', ['فِي عَامِ أربَعِينَ مِنْ سِنِينِهِ', 'وَبَعدَ ذَاكَ حَجَّةُ الوَدَاعِ', 'وَبَعدَهَا تَبُوكُ جَيشُ العُسرَةِ', 'تَزَوَّجَ النَّبِيُّ إِحْدَى عَشَرَهْ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ذَاتُ الوَفَاءِ وَالنَّدَى الكَرِيمَةْ', ['أُوَلُهُنَّ السَّيِّدَةْ خَدِيجَةْ', 'وَبَعْدَهَا هِنْدُ أَيْ أُمُّ سَلَمَةْ', 'هُوَ الحَبِيبُ رَبُّنَا اصْطَفَاهُ', 'وَبَعدَهَا حُنَينُ فِي نَفسِ السَّنَةْ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهَا سَوْدَةُ بِنْتُ زَمْعَةْ', ['بِالوَحيِ مِنْ رَبِّي إلَى أمِينِهِ', 'الأُمُّ مَاتَتْ مِنْ كَمَالِ صَبرِهِ', 'وَذَاكَ عَامُ الحُزنِ حَيثُ شِدَّتُهُ', 'فَاحْفَظْ لِهَذَا العِلْمِ تَلْقَ المَنْفَعَةْ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَهَا حَفْصَةُ بِنْتُ عُمَرَ\nوَحْيًا مِنَ اللهِ كَمَا قَدْ أَمَرَا', ['وَبَعْدَهَا زَيْنَبُ بِنْتُ خُزَيْمَةِ', 'أنْ يَنصُرَ النَّبِيَّ دَائِمًا عَلَى', 'قَالَ لَهُمْ لَو أنَّنِي أخبَرتُكُم', 'وُلِدَ فِي مَكَّةَ عَامَ الفِيلِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'شَرِيفَةٌ أَصِيلَةٌ مُعَلِّمَةْ', ['بُيُوتُهُ فِي طَيْبَةَ المُنَوَّرَةْ', 'وَمَاتَ عَمُّ المُصطَفَى وَزَوجَتُهُ', 'وَعِندَهَا عَادَتْ بِهِ حَلِيمَةُ', 'وَبَعْدَهَا هِنْدُ أَيْ أُمُّ سَلَمَةْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَزَيْنَبُ الأُخْرَى كَذَا جُوَيْرِيَةْ', ['كَمَا أَتَانَا فِي نُصُوصٍ بَاقِيَةْ', 'بِغَارِ حِرَاءَ وَقَدْ رَآهُ', 'وَرَمْلَةُ وَبَعْدَهَا صَفِيَّةْ', 'فِي عَامِ تِسعٍ ضِدَّ رُومِ الحُمرَةِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكُلُّهُنَّ أُمَّهَاتُ المُؤْمِنِينْ\nوَاخْتَارَهُنَّ اللهُ رَبُّ العَالَمِينْ', ['بِاسمِ الكَرِيمِ الوَاحِدِ الَّذِي خَلَقْ', 'وَأنَّ هَذَا الوَحيَ كَانَ يَنزِلُ', 'وَفِي الجِنَانِ مَرْيَمُ وَآسِيَةْ', 'وَبَعدَهَا حُنَينُ فِي نَفسِ السَّنَةْ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَمَا أَتَانَا فِي نُصُوصٍ بَاقِيَةْ', ['وَفِي الجِنَانِ مَرْيَمُ وَآسِيَةْ', 'وَبَعدَ سِتٍّ مِنْ سِنِينَ عُمرِهِ', 'فِي السَّنَةِ الثَّانِيَةِ بَعدَ الهِجرَةِ', 'وَمِنهُمُ خَدِيجَةُ الكَرِيمَةُ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'حَيَاؤُهُ وَبِرُّهُ وَرِفْقُهُ', ['وَجُودُهُ وَعَفْوُهُ وَصِدْقُهُ', 'لِبِنتِ وَهْبٍ أُمِّهِ العَظِيمَةِ', 'تَحْكِي لَنَا سِيرَتَهُ المُعَطَّرَةْ', 'أَكْرِمْ بِهَا مِنْ زَوْجَةٍ كَرِيمَةِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تَوَاضُعٌ للهِ بَيْنَ النَّاسِ\nوَرَحْمَةٌ فَاقَتْ عَلَى القِيَاسِ', ['خَوفًا عَلَيهِ عِندَ شَقِّ صَدرِهِ', 'شَجَاعَةٌ فِي الحَقِّ لَا تُحَدُّ', 'وَفَتحُ مَكَّةَ أتَى مِنْ بَعدِهَا', 'فَقَالَ زَمِّلُونِي زَمِّلُونِي'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالسُّنَّةِ الطَّاهِرَةِ الأَرْكَانِ', ['بِسْمِ القَدِيرِ الوَاجِدِ المَنَّانِ', 'فَأصبَحَتْ أخُوَّةٌ فِي الدِّينِ', 'مَنْطِقُهُ بِالوَحْيِ وَالقُرْآنِ', 'وَعَادَ نَحوَ بَيتِهِ عَلَيهِ مِنْ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'عَاشَ كَرِيمًا طَيِّبًا رَحِيمًا', ['مِنْ بَعدِ ذَا وَأعلَنُوا إعلَانَا', 'فَأخرَجَ اللهُ بِذَا اليَهُودَا', 'خَمسًا وَعِشرِينَ كَمَا أتَانَا', 'عَنِ الأَذَى مُنَزَّهًا سَلِيمًا'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'صَلَّى عَلَيكَ اللهُ يَا نَبِيَّنَا\nدَومًا كَمَا بِدِينِهِ أتَيتَنَا', ['وَشَاعَ مِنْ بَينِهِمُ الوِئَامُ', 'وَبَعدَهَا جَدُّهُ عَبدُ المُطَّلِبْ', 'عَلَى الهُدَى وَالحُبِّ قَدْ رَبَّيتَنَا', 'فِي عَرَفَاتٍ تَمَّ دِينُ اللهِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمِنْ عُلُومِ اللهِ قَدْ سَقَيتَنَا', ['فَجَاءَ نَحوَ المُصطَفَى مُسَلِّما', 'فَأصبَحُوا بِفَضلِهِ جَمِيعا', 'أنْ يَأخُذَ الأمْوَالَ وَالجِمَالَا', 'عَلَى الهُدَى وَالحُبِّ قَدْ رَبَّيتَنَا'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَالحَمدُ للهِ العَظِيمِ الهَادِي', ['عَلَى النَّبِيِّ الطَّيِّبِ المُمَجَّدِ', 'دَومًا بِلَا حَدٍّ وَلَا تَعدَادِ', 'فِي السِّرِّ لِلأهلِ وَلِلعَبِيدِ', 'مَنْ وَصَفَتْ لِسَيِّدِي المُمَجَّدِ'], 1),
];

// ---------- اختبار بردة الأنوار المحمدية (100 سؤال اختياري) ----------
const bordaQuiz = <PoemQ>[
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحمدٌ واصلٌ للضيفِ والرَّحِمِ', ['مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'المُصطَفَى المُجتبى مِنْ قَبلِ نَشأتِنا', ['ما ثَمَّ مِنْ شاعرٍ يُوْفِيهِ بالكَلِمِ', 'تَمضي حياتي حديثاً عنهُ لمْ أَنَمِ', 'واقبلْ مَديحِي لِخيرِالخَلقِ نورِ فَمِي', 'وما قرأتَ معَ القرآنِ للحِكَمِ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'لو أنَّ لي ........ مِن عينِكم لكفى', ['نُورٌ', 'نعرفُها', 'نَظرةً', 'ناجاه'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'آياتُ ربي في القرآنِ كالقِمَمِ', ['آباؤُهُ خيرُ مَن مُدِحتْ شمائلُهم', 'مِن أينَ آتي بوصفٍ بعدمَا شَهدتْ', 'له المكارمُ جَلَّ اللهُ مانحُهُ', 'يُعطي ويمنحُ مَناناً بِلا سَبَبٍ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يا خيرَ مَن بَلَّغَ التنزيلَ مُلتزِماً\nصِدقَ البَلاغِ وصِدقَ الفعلِ والذِمَمِ', ['واللهُ كلمَّهُ واللهُ علمَّهُ', '(اقرأ) بها خاطبَ الرحمنُ سيدَّنا', 'ماذا عسى كَلِمِي تُوْفي مدائحَكم', 'إنِّي إذا رُمتُ أنْ أحكي محاسنَهُ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'اللهُ أرسلَهُ بالعلمِ مُتصِفاً', ['أزكى مِن المسكِ مِن صدقٍ ومِن كَرَمِ', 'واقبلْ مَديحِي لِخيرِالخَلقِ نورِ فَمِي', 'مِن بعدِ ما أخبرَ القرآنُ بالقَسَمِ', 'نوراً سراجاً مُنيراً دائمَ الكَرمِ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'واغفرْ لأمةِ طه كُلَّما قُرأَتْ\nللهِ ربي أبُثُّ الشوقَ في كَلِمي', ['الجُودُ حرفتُهُ خُلقاً وسيرتُهُ', 'إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'والشكرُ مُتصلٌ للمصطفى أبداً', 'اللهُ أرسلَهُ بالعلمِ مُتصِفاً'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ نورِه ليلةَ المعراجِ بِالحِكَمِ', ['اللهُ أرسلَهُ بالعلمِ مُتصِفاً', 'له المكارمُ جَلَّ اللهُ مانحُهُ', 'يا ربِّ صلِّ وسلمْ بالكمالِ على', 'اللهُ علَّمَهُ أوحى له قَبَساً'], 3),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ به طيبةٌ مِن يومِ هجرتِه', ['نورِ', 'وناظمٍ', 'يَرى', 'ضاءتْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'فرَأتْ قُصورَ الشامِ حِينَ مولدِهِ', ['في القلبِ أكتمُه للمصطفى العَلَمِ', 'تَسطعُ مِن نُورِهِ الوضاءِ في الظُّلَمِ', 'بِالطُّهْرِ في سائِرِ الأَصْلابِ وَالرَّحِمِ', 'ذاتُ المكارمِ والأخلاقِ والهِمَمِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ما ثَمَّ مِنْ شاعرٍ يُوْفِيهِ بالكَلِمِ', ['ياربِّ صلِّ على النورِ الذي سَطعتْ', 'لا وصفَ يُدركُهُ لا قولَ يُنصفُهُ', 'ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ صلِّ على النورِ الذي سَطعتْ', ['يأتي', 'يَنطفي', 'يمحو', 'ياربِّ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ\nوَمَدْحُهُ نِعْمَةٌ مِن أَعْظَمِ النِّعَمِ', ['(اقرأ) بها خاطبَ الرحمنُ سيدَّنا', 'محمَّدٌ سيِّدُ السَّاداتِ أشرَفُهُمْ', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ', 'واجعلْ حياتي وِصالاً منْهُ يا أملي'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'امْنُنْ عَلىٰ عَاشِقٍ يَهْوَاكَ لَيْسَ لَهُ\nإلَّاكَ أنْتَ وَأنْتَ قَاسِمُ النِّعَمِ', ['إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'ضاءتْ به طيبةٌ مِن يومِ هجرتِه', 'يا ربِّ صلِّ وسلمْ بالكمالِ على', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', '(والنجمِ) ثُمّ َ(الضحى) والشرحُ قد نَظمَتْ\nأوصافَ نورٍ وألغتْ سائرَ التُّهَمِ', ['(ما ضلَّ صاحبُكم) حاشاهُ إنَّ لهُ', 'المُصطَفَى المُجتبى مِنْ قَبلِ نَشأتِنا', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ', 'في فارسٍ ظهرتْ آياتُ مولدِه'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يا ربِّ صلِّ وسلمْ بالكمالِ على\nمُحمدٍ قدوةِ الأطهارِ كُلِّهِمِ', ['ياربِّ صلِّ على النورِ الذي سَطعتْ', 'الجُودُ حرفتُهُ خُلقاً وسيرتُهُ', 'فرَأتْ قُصورَ الشامِ حِينَ مولدِهِ', 'عذراً رسولَ اللهِ مَنْ مثلي ليمدحَكمْ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تعدادَ ما خَلقَ الرحمنُ مِنٔ بَشَرٍ\nوعَدَّ ما خُطَّ في الألواحِ بالقلمِ', ['واللهُ كلمَّهُ واللهُ علمَّهُ', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ', 'مِنْ أينَ أبدأُ نظمي والمديحَ وما', 'وتباركَ اللهُ ربُّ العرشِ خالقُهُ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ثُمَّ السلامُ عليه كلَّما طلَعتْ\nشَمسُ النهارِ وجاءَ الليلُ بالظُّلَمِ', ['لا وصفَ يُدركُهُ لا قولَ يُنصفُهُ', 'ضاءتْ به طيبةٌ مِن يومِ هجرتِه', 'تعدادَ ما خَلقَ الرحمنُ مِنٔ بَشَرٍ', 'أوقفتُ عُمري أُغني في مدائحِكم'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَمضي حياتي حديثاً عنهُ لمْ أَنَمِ', ['إنِّي إذا رُمتُ أنْ أحكي محاسنَهُ', 'يُعطي ويمنحُ مَناناً بِلا سَبَبٍ', 'اللهُ علَّمَهُ أوحى له قَبَساً', 'مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'يا شوقُ مَهلاً على قَلبِي فَقَافِيَتي', ['تكادُ تنطقُ بالأشواقِ والنَغَمِ', 'مُحمدٍ قدوةِ الأطهارِ كُلِّهِمِ', 'ثاني الذَّبيحينِ عبدِاللهِ ذي الكَرمِ', 'في العالَمينَ شَبيهٌ كامِلُ الشِّيَمِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَحْيٌ وَرَحْمَتُهُ عَمَّتْ عَلَى الأُمَمِ', ['ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً', 'يا خَيْرَ مَبْعوثٍ إلى الأَكْوانِ مَنْطِقُهُ', 'وتَظلُّ سيرتُه شَمساً تُحيرُني'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يمحو ويُثبتُ فضلاً منه كالدِيَمِ', ['والشكرُ مُتصلٌ للمصطفى أبداً', 'للهِ ربي أبُثُّ الشوقَ في كَلِمي', 'وَشاهَدَ الحَقَّ تَحقيقًا بِرَحْمَتِهِ', 'يُعطي ويمنحُ مَناناً بِلا سَبَبٍ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يأتي يقولُ لكلِّ الخلقِ إنِّيْ لها\nيبكي ويسجدُ للرحمنِ ذي الكَرَمِ', ['أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ', 'يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'ياربِّ صلِّ على النورِ الذي سَطعتْ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الذَّبيحينِ عبدِاللهِ ذي الكَرمِ', ['رسولَ', 'ثاني', 'علمَّهُ', 'الليلُ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ كامِلُ الأَوْصافِ لَيْسَ لَهُ', ['لكنَّني عاشقٌ بالبابِ مُلتزَمِي', 'في العالَمينَ شَبيهٌ كامِلُ الشِّيَمِ', 'رحمةُ ربي إلى الأكوانِ والأُمَمِ', 'ما كُلُّ شيءٍ يُدركُ الإنسانُ بالهِمَمِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'والأمُّ آمنةُ الأنوارِ نعرفُها\nذاتُ المكارمِ والأخلاقِ والهِمَمِ', ['مِن بَطنِ آمنةٍ للكونِ قد خَرجتْ', 'مُحَمَّدٌ صاحِبُ المِعْراجِ مَن نَظَرَتْ', 'يُعطي ويمنحُ مَناناً بِلا سَبَبٍ', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'والمدحُ في ........ أمْني ومُعتصَمِي', ['أستفتحُ', 'المصطفى', 'الأطهارِ', 'الشوقَ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'آباؤُهُ خيرُ مَن مُدِحتْ شمائلُهم\nخيرُ البريةِ مِنْ عُربٍ ومِنْ عَجَمِ', ['مُحَمَّدٌ طاهِرُ الأَنْسابِ مُتَّصِلٌ', 'باللهِ أُقسِمُ إنَّ المصطفى قَمَرٌ', 'ثُمَّ السلامُ عليه كلَّما طلَعتْ', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'والتابعينَ لهُمْ صِدقاً على قَدَمِ', ['له المكارمُ جَلَّ اللهُ مانحُهُ', 'ثُمَّ السلامُ على آلٍ وأصحابٍ', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'ما كُلُّ شيءٍ يُدركُ ........ بالهِمَمِ', ['إليكم', 'الإنسانُ', 'المسكِ', 'النِّعمِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'واجعلْ حياتي وِصالاً منْهُ يا أملي\nواجعلْ وفاتي بروضِ النورِ والعِظَمِ', ['واغفرْ لمُنشدِها ربي وسامعِها', 'وما عرفتَ كتاباً مُحكماً أبداً', 'مُحَمَّدٌ كامِلُ الأَوْصافِ لَيْسَ لَهُ', 'أستفتحُ القولَ بِاسمِ اللهِ خالقِنا'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ صاحِبُ المِعْراجِ مَن نَظَرَتْ', ['واختُصَّ مِن صَفوةِ الأصلابِ والرَّحِمِ', 'عَيْناهُ في حَضْرَةِ الرَّحمنِ وَالكَرَمِ', 'لو كنتَ تعرفُ مَعنى الحُبِ لم تَلُمِ', 'نبراسُ أهلِ التقى في الخُلقِ والشِّيَمِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هذا مقامُ الحَمدِ وهذا سَيدُ الأُمَمِ', ['والشكرُ مُتصلٌ للمصطفى أبداً', 'ضاءتْ به طيبةٌ مِن يومِ هجرتِه', 'يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'العجزُ أوقفَني والفقرُ مَعذرتي', ['للهِ ربي أبُثُّ الشوقَ في كَلِمي', 'والشوقُ لا يَنطفي كالنارِ في ضَرَمِ', 'ما ثَمَّ مِنْ شاعرٍ يُوْفِيهِ بالكَلِمِ', 'فضلاً على سائرِ الأكوانِ مِن قِدَمِ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الذي خَلقَ الأكوانَ مِن عَدَمِ', ['بِاسمِ', 'بها', 'بوصفٍ', 'بشرٌ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مُتصلٌ للمصطفى أبداً', ['ومُلتزمٌ', 'والهِمَمِ', 'والشكرُ', 'ويسجدُ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حسبي دُعائي مَليكاً واهبَ النِّعمِ', ['خَيْرُ الخَلائِقِ مَوْلانا الَّذي كَمُلَتْ', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ', 'مِن بَطنِ آمنةٍ للكونِ قد خَرجتْ', 'للهِ ربي أبُثُّ الشوقَ في كَلِمي'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُنَزَّهٌ فِي العُلا عَنْ سَائِرِ التُّهَمِ', ['العجزُ أوقفَني والفقرُ مَعذرتي', 'مُحَمَّدٌ طَيِّبٌ والطِيبُ عُنصُرُهُ', 'مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً\nواختُصَّ مِن صَفوةِ الأصلابِ والرَّحِمِ', ['تعدادَ ما خَلقَ الرحمنُ مِنٔ بَشَرٍ', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ', 'والأمُّ آمنةُ الأنوارِ نعرفُها'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ ........ على المختارِ في القِدَمِ', ['إلَّاكَ', 'الأَنْسابِ', 'الصلاة', 'الأكوانَ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَشاهَدَ الحَقَّ تَحقيقًا ........', ['بَدأي', 'بصدقِ', 'بِرَحْمَتِهِ', 'بالظُّلَمِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِن بَطنِ آمنةٍ للكونِ قد خَرجتْ\nرحمةُ ربي إلى الأكوانِ والأُمَمِ', ['يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'امْنُنْ عَلىٰ عَاشِقٍ يَهْوَاكَ لَيْسَ لَهُ', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ', 'فرَأتْ قُصورَ الشامِ حِينَ مولدِهِ'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وتَظلُّ سيرتُه شَمساً تُحيرُني\nوتُحيرُ الخَلقَ طُراً في سَمَا النِّعَمِ', ['يا خيرَ مَن بَلَّغَ التنزيلَ مُلتزِماً', 'عذراً رسولَ اللهِ مَنْ مثلي ليمدحَكمْ', 'يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'واغفرْ لمُنشدِها ربي وسامعِها'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'والأنبياءُ جميعاً بَعدَهُ وقفوا\nلِيؤمَّهُم سَيدُ الساداتِ في الحَرَمِ', ['فرَأتْ قُصورَ الشامِ حِينَ مولدِهِ', 'مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'ضاءتْ به طيبةٌ مِن يومِ هجرتِه', 'نُورٌ تَسلسَلَ في الأصلابِ مُتصلاً'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَيْرُ الخَلائِقِ ........ الَّذي كَمُلَتْ', ['مُلْتَمِسًا', 'مَوْلانا', 'مُنَزَّهٌ', 'مَليكاً'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِمَدْحِكُمْ ذِمَّةً يا حافِظَ الذِّمَمِ', ['اِعْطِفْ عَلَى الخادِمِ المِسْكينِ إِنَّ لَهُ', 'مُحَمَّدٌ طَيِّبٌ والطِيبُ عُنصُرُهُ', 'يا خيرَ مَن بَلَّغَ التنزيلَ مُلتزِماً', 'وتباركَ اللهُ ربُّ العرشِ خالقُهُ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'وناظمٍ عاشقٍ للمصطفى ........', ['العُربِ', 'العَلَمِ', 'الحَقَّ', 'النبيُّ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحمدٌ حُبُّهُ فرضٌ ومُلتزمٌ\nومدحُهُ بَلسمٌ يشفي مِنْ السقَمِ', ['إنِّي إذا رُمتُ أنْ أحكي محاسنَهُ', 'خَيْرُ الخَلائِقِ مَوْلانا الَّذي كَمُلَتْ', 'يا ربِّ صلِّ وسلمْ بالكمالِ على', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً\nمِنْ عِطرِ سيرتِه دَوماً بلا سَئَمِ', ['يا شوقُ مَهلاً على قَلبِي فَقَافِيَتي', 'مِن بَطنِ آمنةٍ للكونِ قد خَرجتْ', 'يا مَنْ تلومُ مُحباً في محبتِه', 'واجعلْ حياتي وِصالاً منْهُ يا أملي'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قدْراً على سائرِ الأخلاقِ والشِّيَمِ', ['اللهُ أرسلَهُ بالعلمِ مُتصِفاً', 'يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'بالعجزِ أمدحُهُ والعُذرُ أنَّ لهُ', 'آباؤُهُ خيرُ مَن مُدِحتْ شمائلُهم'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', '(ما ضلَّ صاحبُكم) حاشاهُ إنَّ لهُ\nفضلاً على سائرِ الأكوانِ مِن قِدَمِ', ['اللهُ علَّمَهُ أوحى له قَبَساً', 'وَاسْمَحْ لَهُ أَنْ يَرى الوَجْهَ الَّذي سَطَعَتْ', 'يَنفَضُّ موقفُهم مِن بَعدِ سجدتِه', 'مُحمدٌ حُبُّهُ فرضٌ ومُلتزمٌ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'باللهِ أُقسِمُ إنَّ المصطفى قَمَرٌ', ['ومُحمدٌ حامدٌ للهِ ذي النِّعَمِ', 'نبراسُ أهلِ التقى في الخُلقِ والشِّيَمِ', 'مُحِبُّهُ آمِنٌ في الحَشرِ مِن نَدَمِ', 'قدْراً على سائرِ الأخلاقِ والشِّيَمِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'ماذا عسى كَلِمِي تُوْفي مدائحَكم', ['مِن بعدِ ما أخبرَ القرآنُ بالقَسَمِ', 'صارتْ مُنورةً بالحبِّ لمْ تَنَمِ', 'صِدقَ البَلاغِ وصِدقَ الفعلِ والذِمَمِ', 'كلَّ المَحاسنِ مُتَّسِقٍ ومُنتَظِمِ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مِن المسكِ مِن صدقٍ ومِن كَرَمِ', ['آمنةُ', 'أبداً', 'أزكى', 'أنْتَ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كلَّ المَحاسنِ مُتَّسِقٍ ومُنتَظِمِ', ['له المكارمُ جَلَّ اللهُ مانحُهُ', 'محمَّدٌ سيِّدُ السَّاداتِ أشرَفُهُمْ', 'يا مَنْ تلومُ مُحباً في محبتِه', 'تعدادَ ما خَلقَ الرحمنُ مِنٔ بَشَرٍ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحمدٌ زمزمُ الأخلاقِ سَيدُها\nنبراسُ أهلِ التقى في الخُلقِ والشِّيَمِ', ['اللهُ أرسلَهُ بالعلمِ مُتصِفاً', 'مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'يا شوقُ مَهلاً على قَلبِي فَقَافِيَتي', 'امْنُنْ عَلىٰ عَاشِقٍ يَهْوَاكَ لَيْسَ لَهُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا\nمِنك الرِّضا وَجِوارًا في الجِنانِ سَمِي', ['مُحمدٌ زمزمُ الأخلاقِ سَيدُها', 'لو أنَّ لي نَظرةً مِن عينِكم لكفى', 'والأنبياءُ جميعاً بَعدَهُ وقفوا', 'امْنُنْ عَلىٰ عَاشِقٍ يَهْوَاكَ لَيْسَ لَهُ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'نُورٌ تَسلسَلَ في الأصلابِ مُتصلاً', ['وما قرأتَ معَ القرآنِ للحِكَمِ', 'إلَّاكَ أنْتَ وَأنْتَ قَاسِمُ النِّعَمِ', 'والتابعينَ لهُمْ صِدقاً على قَدَمِ', 'بالطاهرينَ أُولي الأخلاقِ والشِيَمِ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ورضاك يا مصطفى كَسْبي ومُغْتنَمي', ['إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'يا ربِّ صلِّ وسلمْ بالكمالِ على', 'والأنبياءُ جميعاً بَعدَهُ وقفوا', 'أوقفتُ عُمري أُغني في مدائحِكم'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'عذراً رسولَ اللهِ مَنْ مثلي ليمدحَكمْ', ['لكنَّني عاشقٌ بالبابِ مُلتزَمِي', 'وتُحيرُ الخَلقَ طُراً في سَمَا النِّعَمِ', 'وَمَدْحُهُ نِعْمَةٌ مِن أَعْظَمِ النِّعَمِ', 'ثُمَّ الصلاة على المختارِ في القِدَمِ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنْوارُهُ فَيُضيءَ القَلْبُ ........', ['بَدأي', 'بوصفٍ', 'بِالحِكَمِ', 'بالكَلِمِ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'يا مَنْ تلومُ مُحباً في محبتِه', ['لو كنتَ تعرفُ مَعنى الحُبِ لم تَلُمِ', 'عَيْناهُ في حَضْرَةِ الرَّحمنِ وَالكَرَمِ', 'صارتْ مُنورةً بالحبِّ لمْ تَنَمِ', 'ما كنتَ ذا سُنَّةٍ يوماً ولا قِيَمِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'في القلبِ أكتمُه للمصطفى العَلَمِ', ['مِنْ أينَ أبدأُ نظمي والمديحَ وما', 'أوقفتُ عُمري أُغني في مدائحِكم', 'ثُمَّ السلامُ على آلٍ وأصحابٍ', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'والنارُ قد أُخمدَتْ ........ ولمْ تَقُمِ', ['قرأتَ', 'قَدَراً', 'قهراً', 'قَاسِمُ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وما قرأتَ معَ القرآنِ للحِكَمِ', ['إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'وما عرفتَ كتاباً مُحكماً أبداً', 'يا ربِّ صلِّ وسلمْ بالكمالِ على', 'يا مَنْ تلومُ مُحباً في محبتِه'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'محمَّدٌ سيِّدُ السَّاداتِ ........', ['الخادِمِ', 'أشرَفُهُمْ', 'الأنوارِ', 'المصطفى'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ', ['ما كنتَ ذا سُنَّةٍ يوماً ولا قِيَمِ', 'شَمسُ النهارِ وجاءَ الليلُ بالظُّلَمِ', 'تكادُ تنطقُ بالأشواقِ والنَغَمِ', 'بِمَدْحِكُمْ ذِمَّةً يا حافِظَ الذِّمَمِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'واللهُ كلمَّهُ واللهُ علمَّهُ', ['مِنْ عِطرِ سيرتِه دَوماً بلا سَئَمِ', 'والشوقُ لا يَنطفي كالنارِ في ضَرَمِ', 'الشافعُ المُرتضى في الحشرِ للأُمَمِ', 'في العالَمينَ شَبيهٌ كامِلُ الشِّيَمِ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ طاهِرُ ........ مُتَّصِلٌ', ['الأَنْسابِ', 'الأُمَمِ', 'الرحمنُ', 'البَلاغِ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'ما مثلهُ بشرٌ ........ مُتَّسِمِ', ['بِالطُّهْرِ', 'بالقلمِ', 'بالحُسنِ', 'بصدقِ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَاسْمَحْ لَهُ أَنْ يَرى الوَجْهَ الَّذي سَطَعَتْ', ['وعَدَّ ما خُطَّ في الألواحِ بالقلمِ', 'مُحمدٍ قدوةِ الأطهارِ كُلِّهِمِ', 'أَنْوارُهُ فَيُضيءَ القَلْبُ بِالحِكَمِ', 'يبكي ويسجدُ للرحمنِ ذي الكَرَمِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'واختُصَّ مِن صَفوةِ الأصلابِ والرَّحِمِ', ['لو أنَّ لي نَظرةً مِن عينِكم لكفى', 'مُحَمَّدٌ طَيِّبٌ والطِيبُ عُنصُرُهُ', 'إِنِّي أُحِبُّكَ يا مُخْتارُ مُلْتَمِسًا', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً'], 3),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحمدٌ واصلٌ للضيفِ ........', ['والنَغَمِ', 'والرَّحِمِ', 'وَأنْتَ', 'ومُخْتتَمِي'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ', ['وتُحيرُ الخَلقَ طُراً في سَمَا النِّعَمِ', 'للهِ ربي أبُثُّ الشوقَ في كَلِمي', 'ثاني الذَّبيحينِ عبدِاللهِ ذي الكَرمِ', 'ورضاك يا مصطفى كَسْبي ومُغْتنَمي'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أوصافَ نورٍ وألغتْ سائرَ التُّهَمِ', ['مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً', 'وَاسْمَحْ لَهُ أَنْ يَرى الوَجْهَ الَّذي سَطَعَتْ', '(والنجمِ) ثُمّ َ(الضحى) والشرحُ قد نَظمَتْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ', ['والمدحُ في المصطفى أمْني ومُعتصَمِي', 'ما مثلهُ بشرٌ بالحُسنِ مُتَّسِمِ', 'حاشاك تَحرمُ مسكيناً وذا أَلَمِ', 'مُحمدٌ واصلٌ للضيفِ والرَّحِمِ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَحْيٌ ........ عَمَّتْ عَلَى الأُمَمِ', ['والذِمَمِ', 'واقبلْ', 'وتباركَ', 'وَرَحْمَتُهُ'], 3),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'إنِّي إذا رُمتُ أنْ ........ محاسنَهُ', ['أبُثُّ', 'أوقفَني', 'الخَلقَ', 'أحكي'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيؤمَّهُم سَيدُ الساداتِ في الحَرَمِ', ['والأنبياءُ جميعاً بَعدَهُ وقفوا', 'مِنْ أينَ أبدأُ نظمي والمديحَ وما', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ', 'ثُمَّ السلامُ على آلٍ وأصحابٍ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'ضاءتْ به طيبةٌ مِن يومِ هجرتِه', ['صارتْ مُنورةً بالحبِّ لمْ تَنَمِ', 'بالطاهرينَ أُولي الأخلاقِ والشِيَمِ', 'للهِ ربي أبُثُّ الشوقَ في كَلِمي', 'مِنْ نورِه ليلةَ المعراجِ بِالحِكَمِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'باللهِ أُقسِمُ إنَّ المصطفى قَمَرٌ\nومُحمدٌ حامدٌ للهِ ذي النِّعَمِ', ['نُورٌ تَسلسَلَ في الأصلابِ مُتصلاً', 'خَيْرُ الخَلائِقِ مَوْلانا الَّذي كَمُلَتْ', 'مِنْ أينَ أبدأُ نظمي والمديحَ وما', 'للهِ ربي أبُثُّ الشوقَ في كَلِمي'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ أينَ أبدأُ نظمي ........ وما', ['والمديحَ', 'ومدحُهُ', 'والهِمَمِ', 'وَشاهَدَ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يا شوقُ مَهلاً على قَلبِي فَقَافِيَتي\nتكادُ تنطقُ بالأشواقِ والنَغَمِ', ['عذراً رسولَ اللهِ مَنْ مثلي ليمدحَكمْ', 'واغفرْ لمُنشدِها ربي وسامعِها', 'وَاسْمَحْ لَهُ أَنْ يَرى الوَجْهَ الَّذي سَطَعَتْ', 'مُحَمَّدٌ طَيِّبٌ والطِيبُ عُنصُرُهُ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ذاتُ المكارمِ والأخلاقِ والهِمَمِ', ['أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ', 'أوقفتُ عُمري أُغني في مدائحِكم', 'واغفرْ لأمةِ طه كُلَّما قُرأَتْ', 'والأمُّ آمنةُ الأنوارِ نعرفُها'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يبكي ويسجدُ للرحمنِ ذي الكَرَمِ', ['نُورٌ تَسلسَلَ في الأصلابِ مُتصلاً', 'واغفرْ لمُنشدِها ربي وسامعِها', 'له المكارمُ جَلَّ اللهُ مانحُهُ', 'يأتي يقولُ لكلِّ الخلقِ إنِّيْ لها'], 3),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'وما عرفتَ كتاباً مُحكماً ........', ['أُقسِمُ', 'أوحى', 'إِنِّي', 'أبداً'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'واغفرْ لمُنشدِها ربي وسامعِها', ['ما كُلُّ شيءٍ يُدركُ الإنسانُ بالهِمَمِ', 'وَمَدْحُهُ نِعْمَةٌ مِن أَعْظَمِ النِّعَمِ', 'وناظمٍ عاشقٍ للمصطفى العَلَمِ', 'خيرُ البريةِ مِنْ عُربٍ ومِنْ عَجَمِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'رحمةُ ربي إلى الأكوانِ والأُمَمِ', ['مِن بَطنِ آمنةٍ للكونِ قد خَرجتْ', 'ياربِّ صلِّ على النورِ الذي سَطعتْ', 'مُحَمَّدٌ حُبُّهُ حُبٌّ لِخالِقِهِ', 'أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ كامِلُ الأَوْصافِ لَيْسَ لَهُ\nفي العالَمينَ شَبيهٌ كامِلُ الشِّيَمِ', ['مُحمدٌ شَرَّفَ الأكوانَ مولدُهُ', 'ثُمَّ السلامُ عليه كلَّما طلَعتْ', 'مُحَمَّدٌ طَيِّبٌ والطِيبُ عُنصُرُهُ', 'مُحَمَّدٌ كامِلُ الأَوْصافِ لَيْسَ لَهُ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'كلَّ المَحاسنِ ........ ومُنتَظِمِ', ['مُتَّسِقٍ', 'مُتَّصِلٌ', 'مَعنى', 'مُحمدٍ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'لو أنَّ لي نَظرةً مِن عينِكم لكفى', ['حاشاك تَحرمُ مسكيناً وذا أَلَمِ', 'الشافعُ المُرتضى في الحشرِ للأُمَمِ', 'ما ثَمَّ مِنْ شاعرٍ يُوْفِيهِ بالكَلِمِ', 'إلَّاكَ أنْتَ وَأنْتَ قَاسِمُ النِّعَمِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عذراً رسولَ اللهِ مَنْ مثلي ليمدحَكمْ\nلكنَّني عاشقٌ بالبابِ مُلتزَمِي', ['مُحَمَّدٌ صاحِبُ المِعْراجِ مَن نَظَرَتْ', 'لا وصفَ يُدركُهُ لا قولَ يُنصفُهُ', 'أكرمْ بوالدِه مَنْ ذِكرُهُ شَرفٌ', 'أوقفتُ عُمري أُغني في مدائحِكم'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فرَأتْ قُصورَ الشامِ حِينَ مولدِهِ\nتَسطعُ مِن نُورِهِ الوضاءِ في الظُّلَمِ', ['أخشى ذنوبي وما أسلفتُ مِن عَمَلٍ', 'في الساجدينَ تَقَلَّبَ نورُهُ قَدَراً', 'وتَظلُّ سيرتُه شَمساً تُحيرُني', 'في فارسٍ ظهرتْ آياتُ مولدِه'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'نبراسُ أهلِ التقى في الخُلقِ والشِّيَمِ', ['(والنجمِ) ثُمّ َ(الضحى) والشرحُ قد نَظمَتْ', '(اقرأ) بها خاطبَ الرحمنُ سيدَّنا', 'مُحمدٌ زمزمُ الأخلاقِ سَيدُها', 'يا مَنْ تلومُ مُحباً في محبتِه'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'خَيْرُ الخَلائِقِ مَوْلانا الَّذي كَمُلَتْ', ['والتابعينَ لهُمْ صِدقاً على قَدَمِ', 'حسبي دُعائي مَليكاً واهبَ النِّعمِ', 'لَهُ المَحاسِنُ خَيْرُ العُرْبِ وَالعَجَمِ', 'ورضاك يا مصطفى كَسْبي ومُغْتنَمي'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خيرُ البريةِ مِنْ عُربٍ ومِنْ عَجَمِ', ['نُورٌ تَسلسَلَ في الأصلابِ مُتصلاً', 'آباؤُهُ خيرُ مَن مُدِحتْ شمائلُهم', 'اللهُ علَّمَهُ أوحى له قَبَساً', 'خَيْرُ الخَلائِقِ مَوْلانا الَّذي كَمُلَتْ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ ........ على آلٍ وأصحابٍ', ['الأصلابِ', 'القِدَمِ', 'أملي', 'السلامُ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'وَشاهَدَ الحَقَّ تَحقيقًا بِرَحْمَتِهِ', ['بالطاهرينَ أُولي الأخلاقِ والشِيَمِ', 'أَلْقى عَلَيْهِ تَحِيَّتَهُ بِخَيْرِ فَمِ', 'هذا مقامُ الحَمدِ وهذا سَيدُ الأُمَمِ', 'شَمسُ النهارِ وجاءَ الليلُ بالظُّلَمِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'المُصطَفَى المُجتبى مِنْ قَبلِ نَشأتِنا\nواقبلْ مَديحِي لِخيرِالخَلقِ نورِ فَمِي', ['بالعجزِ أمدحُهُ والعُذرُ أنَّ لهُ', 'ثُمَّ السلامُ على آلٍ وأصحابٍ', 'ناجاه دَمعي بصدقِ الحُبِّ مُرتشفاً', 'الجُودُ حرفتُهُ خُلقاً وسيرتُهُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لولا النبيُّ الذي جَلَّتْ فضائلُهُ\nما كنتَ ذا سُنَّةٍ يوماً ولا قِيَمِ', ['وما عرفتَ كتاباً مُحكماً أبداً', 'والأنبياءُ جميعاً بَعدَهُ وقفوا', '(والنجمِ) ثُمّ َ(الضحى) والشرحُ قد نَظمَتْ', 'تعدادَ ما خَلقَ الرحمنُ مِنٔ بَشَرٍ'], 0),
];

// ---------- اختبار قصيدة حبيبي محمد (60 سؤال اختياري) ----------
const habibiQuiz = <PoemQ>[
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ\nمُحَمَّدٌ حَافِظٌ لِلْعَهْدِ وَالرَّحِمِ', ['مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ', 'مُحَمَّدٌ لَمْ تَلِدْ أُنْثَى كَطَلْعَتِهِ', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ طَيِّبٌ وَالنُّورُ مَعْدِنُهُ', ['مُحَمَّدٌ نَاطِقٌ بِالْحَقِّ لِلْأُمَمِ', 'مُحَمَّدٌ مُرْشِدٌ لِلْحَقِّ بِالْقِيَمِ', 'هُوَ الْمُمِدُّ وَذُو الْإِحْسَانِ وَالْكَرَمِ', 'مُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', ['تَنَامُ أَعْيُنُهُ وَالْقَلْبُ لَمْ يَنَمِ', 'كُلَّ الْخَلَائِقِ مِنْ عُرْبٍ وَمِنْ عَجَمِ', 'كَلَّا فَمَا مِثْلُهُ فِي سَائِرِ الْأُمَمِ', 'هُوَ الْمُمِدُّ وَذُو الْإِحْسَانِ وَالْكَرَمِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ عَالِمٌ بِاللهِ شَاهِدُهُ\nمُحَمَّدٌ صَادِقٌ فِي الْوَعْدِ وَالْقَسَمِ', ['مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', 'مُحَمَّدٌ ذِكْرُهُ تِرْيَاقُ مَادِحِهِ', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ أُمُّهُ بِاللهِ مُؤْمِنَةٌ', ['مُحَمَّدٌ طَيِّبٌ حَقًّا مِنَ الْقِدَمِ', 'مُحَمَّدٌ حَافِظٌ لِلْعَهْدِ وَالرَّحِمِ', 'عِطْرًا يُعَطِّرُ لِلْأَرْجَاءِ بِالنَّغَمِ', 'مُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كُلَّ الْخَلَائِقِ مِنْ عُرْبٍ وَمِنْ عَجَمِ', ['مُحَمَّدٌ ذِكْرُهُ تِرْيَاقُ مَادِحِهِ', 'مُحَمَّدٌ مَنْ كَمِثْلِ الْمُصْطَفَى شَرَفًا؟!', 'يَا رَبِّ صَلِّ عَلَى الْهَادِي مُحَمَّدِنَا', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى', ['مُحَمَّدٌ نَاطِقٌ بِالْحَقِّ لِلْأُمَمِ', 'كَلَّا فَمَا مِثْلُهُ فِي سَائِرِ الْأُمَمِ', 'عِطْرًا يُعَطِّرُ لِلْأَرْجَاءِ بِالنَّغَمِ', 'تَنَامُ أَعْيُنُهُ وَالْقَلْبُ لَمْ يَنَمِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ شَافِعٌ فِي الْحَشْرِ ذُو هِمَمِ', ['مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ حُبُّهُ مَنْجى مِنَ ........', ['النَّدَمِ', 'الظُّلَمِ', 'الْمُصْطَفَى', 'الْمِسْكِينِ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ حُبُّهُ يَشْفِي مِنَ الْأَلَمِ', ['مُحَمَّدٌ ذِكْرُهُ تِرْيَاقُ مَادِحِهِ', 'مُحَمَّدٌ بِسْمِ رَبِّ النَّاسِ أَمْدَحُهُ', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ', 'مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا'], 0),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ', ['مُحَمَّدٌ كَافِلُ الْأَيْتَامِ وَالرَّحِمِ', 'فِي الْحُسْنِ وَالطُّهْرِ وَالْأَخْلَاقِ وَالشِّيَمِ', 'مُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ', 'مُحَمَّدٌ حُبُّهُ يَشْفِي مِنَ الْأَلَمِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ\nمُحَمَّدٌ جَدُّهُ ذُو الْفَضْلِ وَالْكَرَمِ', ['مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ', 'يَا رَبِّ صَلِّ عَلَى الْهَادِي مُحَمَّدِنَا', 'مُحَمَّدٌ نِعْمَةُ الرَّحْمَنِ أَرْسَلَهُ', 'مُحَمَّدٌ مَنْ كَمِثْلِ الْمُصْطَفَى شَرَفًا؟!'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'هُوَ الْمُمِدُّ وَذُو ........ وَالْكَرَمِ', ['الْحَشْرِ', 'الظُّلَمِ', 'الْإِحْسَانِ', 'الْأُمَمِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ عَاشَ فِي الدُّنْيَا فَنَوَّرَهَا\nمُحَمَّدٌ مُرْشِدٌ لِلْحَقِّ بِالْقِيَمِ', ['مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ عَاشَ فِي الدُّنْيَا فَنَوَّرَهَا'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَاغْفِرْ إِلَهِي لِتَالِيهَا ........', ['وَالنُّورُ', 'وَالْقَسَمِ', 'وَسَامِعِهَا', 'وَالْكَرَمِ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ صَاحِبُ التَّنْزِيلِ ........', ['وَالشِّيَمِ', 'وَالْكَرَمِ', 'وَالْكَلِمِ', 'وَالْقَلْبُ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَشْفِي الْخَلَائِقَ بِالتَّقْوَى مِنَ السَّقَمِ', ['مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ', 'مُحَمَّدٌ نِعْمَةُ الرَّحْمَنِ أَرْسَلَهُ', 'مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ السَّلَامِ وَكُلِّ الْآلِ وَالرَّحِمِ', ['مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'يَا رَبِّ صَلِّ عَلَى الْهَادِي مُحَمَّدِنَا', 'مُحَمَّدٌ طَيِّبٌ وَالنُّورُ مَعْدِنُهُ', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي الْحُسْنِ وَالطُّهْرِ وَالْأَخْلَاقِ ........', ['وَالْقَسَمِ', 'وَارْضَ', 'وَالشِّيَمِ', 'وَالِدُهُ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ', ['مُحَمَّدٌ صَاحِبُ التَّنْزِيلِ وَالْكَلِمِ', 'مُحَمَّدٌ حُبُّهُ يَشْفِي مِنَ الْأَلَمِ', 'مُحَمَّدٌ حُبُّهُ دِينِي وَمُعْتَصَمِي', 'مُحَمَّدٌ فَائِقٌ لِلرُّسْلِ كُلِّهِمِ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَلَّا فَمَا مِثْلُهُ فِي سَائِرِ الْأُمَمِ', ['مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ', 'مُحَمَّدٌ مَنْ كَمِثْلِ الْمُصْطَفَى شَرَفًا؟!', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا', ['يَا رَبِّ وَارْضَ عَنِ الْأَصْحَابِ كُلِّهِمِ', 'مُحَمَّدٌ نَاطِقٌ بِالْحَقِّ لِلْأُمَمِ', 'عِطْرًا يُعَطِّرُ لِلْأَرْجَاءِ بِالنَّغَمِ', 'أُفٍّ وَمَا رَدَّ مُحْتَاجًا بِلَا نِعَمِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ\nمُحَمَّدٌ حُبُّهُ دِينِي وَمُعْتَصَمِي', ['وَاغْفِرْ إِلَهِي لِتَالِيهَا وَسَامِعِهَا', 'مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ عَالِمٌ بِاللهِ شَاهِدُهُ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ\nمُحَمَّدٌ مُنْقِذُ الدُّنْيَا مِنَ الظُّلَمِ', ['مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا ........', ['لِلْحَقِّ', 'لِلرُّسْلِ', 'لِسَائِلِهِ', 'لِلْأُمَمِ'], 2),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَلَّا فَمَا مِثْلُهُ فِي ........ الْأُمَمِ', ['لِلْأُمَمِ', 'فَائِقٌ', 'سَائِرِ', 'هَوًى'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ\nمُحَمَّدٌ فَائِقٌ لِلرُّسْلِ كُلِّهِمِ', ['مُحَمَّدٌ بِسْمِ رَبِّ النَّاسِ أَمْدَحُهُ', 'مُحَمَّدٌ أُمُّهُ بِاللهِ مُؤْمِنَةٌ', 'مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى', 'مُحَمَّدٌ طَيِّبٌ وَالنُّورُ مَعْدِنُهُ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ مُرْشِدٌ لِلْحَقِّ بِالْقِيَمِ', ['مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ', 'مُحَمَّدٌ عَاشَ فِي الدُّنْيَا فَنَوَّرَهَا'], 3),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا\nعِطْرًا يُعَطِّرُ لِلْأَرْجَاءِ بِالنَّغَمِ', ['مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ', 'مُحَمَّدٌ مَنْ كَمِثْلِ الْمُصْطَفَى شَرَفًا؟!', 'مُحَمَّدٌ لَمْ تَلِدْ أُنْثَى كَطَلْعَتِهِ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ', ['مَعَ السَّلَامِ وَكُلِّ الْآلِ وَالرَّحِمِ', 'أُفٍّ وَمَا رَدَّ مُحْتَاجًا بِلَا نِعَمِ', 'مُحَمَّدٌ صَادِقٌ فِي الْوَعْدِ وَالْقَسَمِ', 'مُحَمَّدٌ شَافِعٌ فِي الْحَشْرِ ذُو هِمَمِ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَا رَبِّ صَلِّ عَلَى ........ مُحَمَّدِنَا', ['الْهَادِي', 'أُنْثَى', 'الْوَعْدِ', 'الْخَلَائِقَ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ ........ تِرْيَاقُ مَادِحِهِ', ['ذِكْرُهُ', 'شَافِعٌ', 'أَعْيُنُهُ', 'جَدُّهُ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ نِعْمَةُ ........ أَرْسَلَهُ', ['الْعَالَمِينَ', 'الْفَضْلِ', 'الرَّحْمَنِ', 'أُمَّتَهُ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى\nمُحَمَّدٌ نَاطِقٌ بِالْحَقِّ لِلْأُمَمِ', ['مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ مَنْ كَمِثْلِ الْمُصْطَفَى شَرَفًا؟!'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ أُمُّهُ بِاللهِ مُؤْمِنَةٌ\nمُحَمَّدٌ طَيِّبٌ حَقًّا مِنَ الْقِدَمِ', ['مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ بِسْمِ رَبِّ النَّاسِ أَمْدَحُهُ'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ بِسْمِ رَبِّ النَّاسِ أَمْدَحُهُ', ['مُحَمَّدٌ مُنْقِذُ الدُّنْيَا مِنَ الظُّلَمِ', 'مُحَمَّدٌ حُبُّهُ مَنْجى مِنَ النَّدَمِ', 'هُوَ الْمُمِدُّ وَذُو الْإِحْسَانِ وَالْكَرَمِ', 'يَشْفِي الْخَلَائِقَ بِالتَّقْوَى مِنَ السَّقَمِ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ حُبُّهُ دِينِي وَمُعْتَصَمِي', ['مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ', 'مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ قَدْ دَعَا لِلهِ ........', ['الْأَلَمِ', 'أُمَّتَهُ', 'السَّلَامِ', 'الْقِدَمِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ حَافِظٌ لِلْعَهْدِ وَالرَّحِمِ', ['مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ', 'مُحَمَّدٌ كَفُّهُ بِالْجُودِ مُنْبَسِطٌ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', ['مُحَمَّدٌ صَاحِبُ التَّنْزِيلِ وَالْكَلِمِ', 'مُحَمَّدٌ حُبُّهُ مَنْجى مِنَ النَّدَمِ', 'عِطْرًا يُعَطِّرُ لِلْأَرْجَاءِ بِالنَّغَمِ', 'مُحَمَّدٌ مُنْقِذُ الدُّنْيَا مِنَ الظُّلَمِ'], 1),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ لَمْ تَلِدْ أُنْثَى كَطَلْعَتِهِ', ['أُفٍّ وَمَا رَدَّ مُحْتَاجًا بِلَا نِعَمِ', 'فِي الْحُسْنِ وَالطُّهْرِ وَالْأَخْلَاقِ وَالشِّيَمِ', 'مُحَمَّدٌ حُبُّهُ مَنْجى مِنَ النَّدَمِ', 'مُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ'], 1),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ\nتَنَامُ أَعْيُنُهُ وَالْقَلْبُ لَمْ يَنَمِ', ['مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى', 'يَا رَبِّ صَلِّ عَلَى الْهَادِي مُحَمَّدِنَا', 'وَاغْفِرْ إِلَهِي لِتَالِيهَا وَسَامِعِهَا'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ جَدُّهُ ذُو الْفَضْلِ وَالْكَرَمِ', ['مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ طَيِّبٌ وَالنُّورُ مَعْدِنُهُ\nمُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ', ['مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ رَحْمَةٌ مِنْ رَبِّنَا شَمِلَتْ'], 2),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ مُنْقِذُ الدُّنْيَا مِنَ الظُّلَمِ', ['مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'كُلَّ ........ مِنْ عُرْبٍ وَمِنْ عَجَمِ', ['الْخَلَائِقِ', 'الْمِسْكِينِ', 'الْهَادِي', 'الْمُمِدُّ'], 0),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَا رَبِّ وَارْضَ عَنِ الْأَصْحَابِ كُلِّهِمِ', ['مُحَمَّدٌ بِسْمِ رَبِّ النَّاسِ أَمْدَحُهُ', 'مُحَمَّدٌ قَدْ دَعَا لِلهِ أُمَّتَهُ', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ', 'وَاغْفِرْ إِلَهِي لِتَالِيهَا وَسَامِعِهَا'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ صَادِقٌ فِي الْوَعْدِ وَالْقَسَمِ', ['مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ أُمُّهُ بِاللهِ مُؤْمِنَةٌ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ', 'مُحَمَّدٌ عَالِمٌ بِاللهِ شَاهِدُهُ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', ['مُحَمَّدٌ حُبُّهُ مَنْجى مِنَ النَّدَمِ', 'تَنَامُ أَعْيُنُهُ وَالْقَلْبُ لَمْ يَنَمِ', 'مُحَمَّدٌ صَاحِبُ التَّنْزِيلِ وَالْكَلِمِ', 'مُحَمَّدٌ حُبُّهُ يَشْفِي مِنَ الْأَلَمِ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ\nمُحَمَّدٌ كَافِلُ الْأَيْتَامِ وَالرَّحِمِ', ['وَاغْفِرْ إِلَهِي لِتَالِيهَا وَسَامِعِهَا', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ لَيْسَ لِي إِلَّاهُ مِنْ أَحَدٍ', 'مُحَمَّدٌ عَالِمٌ بِاللهِ شَاهِدُهُ'], 3),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ ذِكْرُهُ تِرْيَاقُ مَادِحِهِ', ['مُحَمَّدٌ مُرْشِدٌ لِلْحَقِّ بِالْقِيَمِ', 'مُحَمَّدٌ حُبُّهُ يَشْفِي مِنَ الْأَلَمِ', 'مُحَمَّدٌ نَاطِقٌ بِالْحَقِّ لِلْأُمَمِ', 'يَشْفِي الْخَلَائِقَ بِالتَّقْوَى مِنَ السَّقَمِ'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ ........ الدُّنْيَا مِنَ الظُّلَمِ', ['مُنْشَغِلٌ', 'مُنْقِذُ', 'مَنَاقِبُهُ', 'مُحْتَاجًا'], 1),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ جَدُّهُ ذُو ........ وَالْكَرَمِ', ['الْفَضْلِ', 'الْقِدَمِ', 'أُمَّتَهُ', 'الْإِحْسَانِ'], 0),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ\nأُفٍّ وَمَا رَدَّ مُحْتَاجًا بِلَا نِعَمِ', ['مُحَمَّدٌ عَاشَ فِي الدُّنْيَا فَنَوَّرَهَا', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ', 'مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا', 'يَا رَبِّ صَلِّ عَلَى الْهَادِي مُحَمَّدِنَا'], 0),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ صَادِقٌ فِي الْوَعْدِ ........', ['وَارْضَ', 'وَالْقَسَمِ', 'وَسَامِعِهَا', 'وَالْكَرَمِ'], 1),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَنَامُ أَعْيُنُهُ وَالْقَلْبُ لَمْ يَنَمِ', ['مُحَمَّدٌ ذِكْرُهُ فِي الْعَالَمِينَ غَدَا', 'مُحَمَّدٌ طَيِّبٌ طَابَتْ مَنَاقِبُهُ', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ شَرَّفَ الْأَكْوَانَ وَالِدُهُ'], 2),
  PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا\nمُحَمَّدٌ صَاحِبُ التَّنْزِيلِ وَالْكَلِمِ', ['مُحَمَّدٌ أُمُّهُ بِاللهِ مُؤْمِنَةٌ', 'مُحَمَّدٌ قَلْبُهُ بِاللهِ مُنْشَغِلٌ', 'مُحَمَّدٌ لَمْ يَقُلْ يَوْمًا لِسَائِلِهِ', 'مُحَمَّدٌ لَيْسَ فِي الْخَلْقِ لَهُ شَبَهٌ'], 3),
  PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَا رَبِّ ........ عَنِ الْأَصْحَابِ كُلِّهِمِ', ['وَالْقَسَمِ', 'وَالْقَلْبُ', 'وَارْضَ', 'وَذُو'], 2),
  PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ نِعْمَةُ الرَّحْمَنِ أَرْسَلَهُ', ['مُحَمَّدٌ تَمَّمَ الْأَخْلَاقَ لِلْأُمَمِ', 'مُحَمَّدٌ صَاحِبُ التَّنْزِيلِ وَالْكَلِمِ', 'مُحَمَّدٌ شَافِعٌ فِي الْحَشْرِ ذُو هِمَمِ', 'يَشْفِي الْخَلَائِقَ بِالتَّقْوَى مِنَ السَّقَمِ'], 3),
  PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدٌ كَافِلُ الْأَيْتَامِ وَالرَّحِمِ', ['مُحَمَّدٌ قَوْلُهُ وَحْيٌ وَلَيْسَ هَوًى', 'مُحَمَّدٌ مُطْعِمُ الْمِسْكِينِ رَاحِمُهُ', 'مُحَمَّدٌ جَاءَنَا بِالنُّورِ أَنْقَذَنَا', 'مُحَمَّدٌ قُدْوَتِي وَالْقَلْبُ يَعْشَقُهُ'], 1),
];

// ---------- اختبار الألفية (فصول، 30 سؤال لكل فصل، وغزوتا بدر وأحد 70 سؤالًا) ----------
const alfChapterTitles = <String>['المقدمة — وبيان عظمة قدر النبي ﷺ', 'النسب الطاهر الشريف', 'حفر زمزم — وفداء السيد عبدالله والد النبي ﷺ', 'حادثة الفيل — وتعريف بأشراف العرب', 'زواج السيد عبدالله من السيدة آمنة عليهما السلام', 'ميلاد النور ﷺ — (رضاع النبي ﷺ وشق صدره ووفاة أمه)', 'أسماؤهُ الشريفةُ', 'كفالة النبي ﷺ — من جده ثم عمه أبي طالب ورعي النبي للغنم', 'حرب الفجار', 'رحلة النبي ﷺ إلى الشام مع عمه', 'زواج النبي ﷺ من السيدة خديجة', 'بناء الكعبة — والتحكيم في وضع الحجر الأسود', 'نزول الوحي على النبي ﷺ', 'البعثة النبوية — وبداية الدعوة السرية', 'الدعوة الجهرية', 'من معجزات النبوة', 'إيذاء المشركين للنبي ﷺ وأصحابه — ومواقف الصديق أبي بكر', 'حماية أبي طالب للنبي ﷺ — وانتشار الدعوة الإسلامية وانشقاق القمر', 'الهجرة الأولى إلى الحبشة', 'الهجرة الثانية إلى الحبشة — وإسلام الفاروق', 'الهجرة إلى المدينة', 'المؤاخاة بين المهاجرين والأنصار — ووثيقة المدينة', 'غزوة بدر', 'غزوة أحد', 'شعب أبي طالب وعام الحزن', 'خروج النبي ﷺ إلى الطائف', 'الإسراء والمعراج', 'بيعتا العقبة الأولى والثانية', 'أم معبد', 'بُريدَةُ', 'دخول النبي ﷺ أرض المدينة', 'غزوتا بني سليم وبني قينقاع', 'خطبة السيدة فاطمة وزواجها', 'كعب بن الأشرف', 'غزوة أنمار', 'غزوةُ الخندق', 'صلح الحديبية وبيعَةُ الرضوان', 'مَحَبةُ الصحابة للنبي ﷺ', 'استشهاد سيدنا حمزة', 'غزوة حمراء الأسد', 'غزوة بني النضير', 'غزوة ذات الرقاع', 'غزوة بدر الموعد — دومة الجندل وبني المصطلق', 'غزوة بني قريظة', 'خيبر، وادي القرى، عمرة القضاء ومؤتة', 'فتح مكة', 'غزوة حنين', 'حصار الطائف وغزوة تبوك', 'وفود القبائل إلى المدينة', 'حجة الوداع', 'اختيار النبي الرفيق الأعلى', 'معجزات النبي الحبيب ﷺ', 'الخاتمة'];

const alfQuiz = <List<PoemQ>>[
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِسْمِ الْكَرِيمِ الْوَاهِبِ الْمَنَّانِ', ['الْبَاسِطِ الْمَعْرُوفِ ذِي الْإِحْسَانِ', 'جَاءُوا إِلَيْكُمْ خَلْفَ هَذَا سَائِرِين', 'رُزِقْتُ حُبَّهَا بِكُلِّ لِينٍ', 'الْمُصْطَفَى وَالصَّادِقُ الْبَرُّ الْأَمِين'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي\nعَلَى حَبِيبِ رَبِّنَا مُحَمَّدِ', ['وَآلِهِ جَمِيعِهِمْ وَصَحْبِهِ', 'فِي دَارِ أَرْقَمٍ كَانَ الْأَصْحَابُ', 'يُعْرَفُ فِي قَوْمِهِ بِالْمُصَارَعَة', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَنْظُومَةٌ فِي السِّيرَةِ النَّبَوِيَّةْ', ['فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ', 'وَبَعْدَ ذَا فَهَذِهِ أَلْفِيَّةْ', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي سِيرَةِ الْمُتَمِّمِ ........', ['الْخَلْقِ', 'الصَّادِقُ', 'الصِّدِّيقُ', 'الْأَخْلَاقِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فيها المَغازي وَكَذا أَيّامُهُ', ['مَنْظُومَةٌ فِي السِّيرَةِ النَّبَوِيَّةْ', 'وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ', 'فَتَمَّ مَا قَالُوا لَهُ فِي حِينِهِ', 'وَكُنْتُ أَسْتَظِلُّ تَحْتَ شَجَرَةٍ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمَواقِفُ الأَصْحابِ كَيْفَ تَحَمَّلوا\nوَلِأَجْلِ هَذا الدّينِ ماذا عَمِلوا', ['يَقُولُ إِنَّ لِابْنِي هَذَا شَانَا', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا', 'مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', 'فَبِها تَكونُ زِيادَةُ الإيمانِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبِها بُلوغُ مَراتِبِ الإِحْسانِ', ['بِسْمِ الْكَرِيمِ الْوَاهِبِ الْمَنَّانِ', 'أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'فَبِها تَكونُ زِيادَةُ الإيمانِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَتّى ........ أَسْعَدَ السُّعَداءِ', ['مُشْرِقا', 'يَكونوا', 'النُّورَا', 'مُمَجَّدَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَتَعَرَّفونَ عَلَى الحَبيبِ وَآلِهِ', ['وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'وَبَهائِهِ مِنْ نورِ طَهَ وَحُسْنِهِ', 'حَرْبَ الْفِجَارِ يَرْمِي بِسِهَامِهِ', 'يَتَأَدَّبونَ بِذِكْرِ طِيبِ خِصالِهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَيَنْبَغي قَبْلَ الشُّروعِ أوَّلاً\nالعِلْمُ أَنَّ اللهَ رَبّي فَضَّلا', ['سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا', 'فَكَانَ مِمَّنْ أَعْتَقَ بِلَالَا', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ', 'عَنْ سائِرِ الخَلْقِ قُرَيْشاً وَالعَرَبْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْعَالَمِينَ طَيِّبًا مُفَضَّلًا', ['قَالَتْ قُرَيْشٌ إِنَّهَا مِنْ حَقِّنَا', 'بَسَطَ فِيهَا رِجْلَهُ وَقَالَا', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِوَعْيٍ صِيغَةَ الْخِطَابِ', ['فَدَفَعَا', 'فَعَلِمُوا', 'فَأَشْرِكْنَا', 'فَاقْرَأْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ', ['الطَّيِّبُ الْمُطَيَّبُ الْمَقْبُولُ', 'فَأَرَّخوا بِالحادِثِ الجَليلِ', 'فَإِنَّهُ الْمُطَهَّرُ الْمَقْبُولُ', 'الخاتَمُ المُعَظَّمُ الجَليلُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ\nعَنْ عُمَرَ الفاروقِ وَالمَليحِ', ['فِي عَامِ الْفِيلِ وُلِدَ الرَّسُولُ', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَنْ آدَمَ رَأى اسْمَهُ مُنَوَّرا', ['مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'قالَ يا رَبَّنا بِحَقِّ أَحْمَدا', 'مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قالَ لَهُ لَوْلاهُ ما ........', ['خَلَقْتُكَ', 'الْمَسَالِكِ', 'مَالِكِ', 'الْإِفْكِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَفي الشِّفاءِ لِلْقاضي عِياضْ', ['بَعْضَ الَّذي إِلَيْهِ عَنْهُمْ وَصَلوا', 'نَسائِمٌ تُشْفى بِها الأَمْراضْ', 'هَذَا النَّبِيَّ بِطَيْبَةَ مُبَشِّرَا', 'يَدْعو إِلى اتِّباعِهِ يَقولْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْها الَّذي رَواهُ لَمّا أَكَلا\nآدَمُ مِنَ الشَّجَرَةِ وَأَقْبَلا', ['قَالَ لَهُمْ إِنِّي رَسُولُ رَبِّكُمْ', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى', 'قالَ يا رَبَّنا بِحَقِّ أَحْمَدا', 'بِصَخْرَةٍ مِنْ فَوْقِهِ عَظِيمَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ رَبِّهِ تَلَقّى لِلْكَلِماتْ', ['وَسُئِلَ الصِّدِّيقُ هَلْ رَأَيْتَ', 'أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ', 'فَأَبَتْ قُرَيْشٌ وَقَفَتْ وَمَنَعَتْ', 'تابَ عَلَيْهِ قَدْ أَتَتْ آياتْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَنَّ هَذا القَوْلَ في ........', ['آمَنْتَا', 'تَنْزيلِها', 'أَخْبَرَهَا', 'أَيَّامَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِأَنَّ رَبَّ العَرْشِ قَدْ أَوْحى إِلى', ['عيسَى المَسيحِ آمِراً وَمُرْسِلا', 'قَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا', 'مُحَمَّدًا حَبِيبَنَا الْأَمِينَا', 'مِنْ آيَةٍ مِنْ قَبْلِ مَا آمَنْتَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ\nأُمَّتَكَ أَنْ يُؤْمِنوا كُلٌّ يُقِرّ', ['لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'أَمَرَهُمْ فَأَقْبَلَ الْجَمَاعَة', 'وَجَا بِنَاءُ كَعْبَةٍ مِنْ بَعْدِهَا', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالنّارَ وَالجَنَّةَ لَمْ أَخْلُقْهُما', ['لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا', 'أَنْفُسَهُمْ لِيَنْصُرُوا الْإِسْلَامَا', 'وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَتّى ........ لا إِلهَ إِلّا', ['كَتَبْتُ', 'كَادَتْ', 'كَلَامِ', 'كَمُلَتْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ الهَادي رَسولُ اللهِ', ['لِلْبَدْرِ فَانْشَقَّ لَهُمْ لِنِصْفِهِ', 'في قَوْمِهِ ذو عِزَّةٍ كَبيرَةِ', 'فَسَكَنَ العَرْشُ بِلا اشْتِباهِ', 'وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجاءَ عَنْ سَلْمانَ الفارِسيِّ ما\nرَواهُ ابنُ عَساكِرَ مُعَلِّما', ['مِنَ النِّسَاءِ خَمْسَةٌ وَضِعْفُهُمْ', 'مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا', 'بِأَنَّ جِبْريلَ الأَمينَ أَقْبَلا', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِنّي اتَّخَذْتُ إِبْراهيمَ قَبْلَكَ', ['اللهُ يا مُحَمَّدٌ يَقولُ لَكَ', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك', 'قالَ لَهُ لَوْلاهُ ما خَلَقْتُكَ', 'لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الخَليلَ لكِنْ أَنْتَ يا', ['قَوْمِهِ', 'آمِنَةُ', 'جَعَلْتُهُ', 'الْمَرْضِيَّة'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', ['وَبَارَكَ اللَّهُ بِهِ فِي عَيْشِهِمْ', 'ذِكْرُكَ مَرْفوعٌ مَدى الأَيّامِ', 'مِنْ رَبِّنَا المَنَّانِ فَهْوَ مُكَرَّمٌ', 'فِي شَهْرِ شَوَّالَ الَّذِي مِنْ عَامِهِمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِ ذَا نَشْرَعُ فِي الْمَقْصُودِ', ['كَذَا ابْنُ عَوْفٍ آمَنُوا مِنْ بَعْدُ', 'وَالْعَوْنُ مِنْ إِلَهِنَا الْمَعْبُودِ', 'وَبِالْبَنَاتِ ثُمَّ بِالْأَحْفَادِ', 'وَرَأَى رُكَانَة سَيِّدَ الْأَسْيَادِ'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'نَبِيُّنَا الْمُخْتَارُ مِنْ بَيْنِ الْأُمَمْ', ['خُلُقَ السَّكِينَةِ وَالْوَقَارِ مُلْتَزَمْ', 'وَأَحْمَدُ الْإِحْسَانِ ذُو النُّورِ الْأَتَمّ', 'وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', 'بَلْ كُلُّ رُسْلِ اللَّهِ قَدْ أُوحِي لَهُمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِهِ جَمِيعُ الْأَنْبِيَاءِ بَشَّرُوا\nأَقْوَامَهُمْ لِيُؤْمِنُوا وَيَظْفَرُوا', ['لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ', 'قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ', 'مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَلْ كُلُّ رُسْلِ اللَّهِ قَدْ أُوحِي لَهُمْ', ['مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْهُمْ عَلَى اتِّبَاعِهِ ........', ['اتِّفَاقَا', 'يَذْبَحُوا', 'أَعلَنَا', 'تَوَقِّيَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَالْبَيْهَقِيُّ قَدْ رَوى وَأَثْبَتا', ['مَعَ الصَّحَابَةِ الَّذِي فِيهِ اختَفَى', 'قَالُوا نَعَمْ هَذَا الصَّحِيحُ وَالْجَلِي', 'لَيْسَ بِهَا مِنْ لَبَنٍ لِكَيْ يَرَى', 'عَنْ ابنِ عَبّاسِ الإِمامِ قَدْ أَتى'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَنِ الحَبيبِ سَيِّدِ المِلاحِ\nقالَ لَهُمْ وُلِدْتُ مِنْ نِكاحِ', ['لِأَنَّهُ في صُلْبِهِ الرَّسولُ', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى', 'فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ', 'وَلَمْ يَكُنْ في نَسَبي سِفاحُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَكُلُّ آباءِ النَّبِي صِحاحُ', ['وَلَمْ يَكُنْ في نَسَبي سِفاحُ', 'عَنِ الحَبيبِ سَيِّدِ المِلاحِ', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ', 'فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ما قالَهُ جِبْريلُ مِنْ ........', ['الْفُضُولِ', 'شَمائِلِ', 'الجَليلُ', 'يَقُولُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا', ['فَلَمْ أَجِدْ مِنْ قَلْبِ طَهَ أَطْيَبا', 'ذِئْبٌ فَصِيحٌ بِالْكَلَامِ عَبَّرَا', 'وَفَائِهِ لَهَا وَمَا تَحَوَّلَا', 'لِصَفْوَةِ الْأَطْهَارِ قَوْمٍ كُرَمَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَلَمْ أَجِدْ كَمِثْلِهِ فِي النَّسَبِ\nوَلا كَمِثْلِ هاشِمٍ بَني أَبِ', ['النُّورُ يَسْرِي مِنْ أَبِيهِ آدَمَا', 'قَدِ اصْطَفَاهَا اللَّهُ مِنْ بَيْنِ الْبَشَر', 'يَا أَيُّهَا النَّبِيُّ قَدْ قَالَ لَهُ', 'عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِصَفْوَةِ الْأَطْهَارِ قَوْمٍ كُرَمَا', ['وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'مَضَى إِلَى سَبِيلِهِ كَرِيمًا', 'وَالْبَيْهَقِيُّ قَدْ رَوى وَأَثْبَتا', 'النُّورُ يَسْرِي مِنْ أَبِيهِ آدَمَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَكْرِمْ بِهِ أَصْلًا لَهُ هُوَ ........', ['أَسْتَظِلُّ', 'الرَّسُولْ', 'جِبْريلَ', 'الْخَلِيل'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِهِ نَسَبُهُ امْتَدَّ إِلَى', ['أَحْبَابَهَا لِأَجْلِهَا مُعَظَّمَا', 'أَرْبَعَةً فَأَسْعَدِ الْأَيَّامَا', 'عَدْنَانَ مِنْ نَسْلِ الْكِرَامِ الْفُضَلَا', 'أَحَدٌ مِنَ الْخَلْقِ وَيَأْكُلُ مِنْهَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'نَبِيُّنَا وَإسْمُهُ مُحَمَّدٌ\nحَبِيبُنَا رَسُولُنَا الْمُؤَيَّدُ', ['وَمُضَرُ كانَ جَميلاً مُشْرِقا', 'أَبُوهُ عَبْدُاللَّهِ عَبْدُالْمُطَّلِبْ', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَذَاكَ جَدُّ سَيِّدِي إِذْ يَنْتَسِبْ', ['عَنْ سائِرِ الخَلْقِ قُرَيْشاً وَالعَرَبْ', 'أَبُوهُ عَبْدُاللَّهِ عَبْدُالْمُطَّلِبْ', 'زَكَّاهُ رَبُّ الْعَرْشِ فِي الْكِتَابِ', 'فَإِنَّهُ الْمَذْكُورُ فِي الْكِتَابِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِهَاشِمٍ عَبْدِ ........ وَقُصَيْ', ['مَنَافٍ', 'شَريفٌ', 'الرَّؤُوفُ', 'الشَّرِيفُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ', ['إِنّي اتَّخَذْتُ إِبْراهيمَ قَبْلَكَ', 'فَاحْفَظْ لِنَصٍّ وَاضِحِ الْمَسَالِكِ', 'وَخَلَقْتُهُمْ لِيَعْرِفوا رِضايَ عَنْك', 'وَإِذا تَشَفَّعْتَ بِهِ شَفَّعْتُكَ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَالنَّضْرِ بَعْدَ ذَلِكَ كِنَانَةُ\nأُولُو التُّقَى وَالْبِرِّ وَالْأَمَانَةِ', ['سَارَتْ بِهِ تَقْصِدُ بَيْتَ وَرَقَةْ', 'مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ', 'وَرَعْيُهَا لِلْأَنْبِيَا كَمَالُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَا مِنْهُمُ قَطُّ نُفُوسٌ مُشْرِكَةْ', ['وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'وَكانَ جَدُّ المُصْطَفى كِنانَة', 'مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِلَى الْخَلِيلِ إِبْرَاهِيمَ ........', ['عَنْهُمْ', 'الْأَكْرَمِ', 'تَعْظِيمِهِمْ', 'الكَريمُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة', ['وَبِنْتُ وَهْبٍ إِنَّهَا عَظِيمَة', 'شَبَهُ وَزَيَّنَهُ الَّذِي أُوحِي لَهُ', 'حَرْبَ الْفِجَارِ يَرْمِي بِسِهَامِهِ', 'فَرَبُّنَا الرَّحْمَنُ أَعْلَى قَدْرَهُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَبْدُ مَنَافٍ جَدُّهَا وَزُهْرَة\nأَبُوهُ بَعْدَهُ كِلَابُ مُرَّة', ['حَتّى كَتَبْتُ لا إِلهَ إِلّا', 'أَمَرَ اللهُ أرْمِياءَ كانا', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ', 'كَمَا أَتَى فِي آلِ عِمْرَانَ وَإِذْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَكْرِمْ بِهَذَا النَّسَبِ الْإِيمَانِي', ['أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ', 'دَعَاهُمُ الصِّدِّيقُ لِلْإِيمَانِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نَسَبٌ شَرِيفٌ طَاهِرٌ ........', ['التَّمَامِ', 'الْقَوْمِ', 'مُعَظَّمٌ', 'أَمَرَهُمْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', ['مِنْهُمْ عَلَى اتِّبَاعِهِ اتِّفَاقَا', 'سَطَعَتْ تَفُوقُ الشَّمْسَ عِنْدَ ظُهُورِهَا', 'أَسْعَدَهَا بِأَحْمَدَ الْمُعَظَّمَا', 'هُوَ الَّذِي يُذْبَحُ فِي هَذَا الْفِدَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَتَزَيَّنَتْ بِمَنِ انْتَمَتْ شَرَفًا لَهُ\nالمُصْطَفَى العَالِي المُعَظَّمُ فَضْلُهُ', ['عَقْدٌ فَرِيدٌ فِي العَوَالِمِ مَا لَهُ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'وَسَافَرَتْ بِهِ إِلَى الْمَدِينَة'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَاللهُ مِنْ أَنْوَارِهِ طَرَّزَهَا', ['وَأَنَّ قَوْمَهُ سَيَأْخُذُونَا', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', 'حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'أَكْرَمَهُمْ فِي أَرْضِهِ إِكْرَامَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نُورٍ وَفَوْقَ الخَلْقِ ........ عَلَا', ['كُلْثُومٍ', 'كَرِيمُ', 'كَلَامِ', 'كُلِّهِمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى', ['مَا قَدْ رَأَوْا وَخَالَفُوا الْحَبِيبَا', 'نورُ النَّبِيِّ في العُيونِ لامِعَا', 'هَذَا النَّبِيُّ يَخْرُجُ بِصَوْتِهَا', 'مَا زَالَ طَهَ فِي الكِتَابِ مُمَجَّدَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', ['نَرْجُو بِهِ مِنْ رَبِّنَا الْإِكْرَامَا', 'بِجَنَّةِ الْخُلُودِ فِيهَا يَنْعَمُوا', 'الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', 'وَبِقَوْمِهِ كَانَ الأَمِينَ مُلَقَّبَا'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَدُهُ الشَّرِيفُ عَبْدُ الْمُطَّلِب', ['فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', 'فَعَلِمُوا بِصِدْقِ الِاقْتِرَابِ', 'كَانَ يُجِلُّ الْمُصْطَفَى وَلَهُ مُحِب', 'فَإِنَّهُمْ ساداتُ أَشْرافِ العَرَب'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا\nفَإِنَّهُ بِفَضْلِ طَهَ سَعِدَا', ['قَدْ صَدَّقُوهُ بِالْقُلُوبِ لَكِنْ', 'يُكْرِمُ طَهَ غَايَةَ التَّكْرِيمِ', 'أَخْبَرَهَا عَمَّا رَأَى فَرَغِبَتْ', 'فَإِنَّهَا خَدِيجَةُ الْحَبِيبَةُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَنْ غَيْرِهِ وَغَايَةَ التَّعْظِيمِ', ['مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'قَالَ النَّبِيُّ إِنَّ فِي أَهْلِ الْغَنَمْ', 'يُكْرِمُ طَهَ غَايَةَ التَّكْرِيمِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَهُوَ ........ حَفَرَ زَمْزَمَ بَعْدَ أَنْ', ['الْخُدْرِيْ', 'يَضْرِبْنِي', 'الَّذِي', 'النَّبِيِّ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', ['وَأَعَادَهَا الشَّرِيفُ جَدُّ الْمُؤْتَمَن', 'قَدْ رُدِمَتْ لِمُدَّةٍ مِنَ الزَّمَنْ', 'أَسْبابَ تَنْزيلٍ وَكُلَّ مَكانِ', 'الْبَاسِطِ الْمَعْرُوفِ ذِي الْإِحْسَانِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَانَ ذَا عَنْ رُؤْيَا قَدْ رَآهَا\nفَقَامَ مِنْ نَوْمِهِ وَأَتَاهَا', ['مُدْرِكَةُ وَخُزَيْمَةُ وَنِزارُ', 'فَكَانَ مِمَّنْ أَعْتَقَ بِلَالَا', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'كانَ عَلى دينِ النَّبِيِّ إِسْماعيل'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَضْمُونَةٌ وَزَمْزَمُ الْمُحَبَّبَة', ['لَوْ أَنَّكَ أَعْتَقْتَ أَهْلَ الْقُوَّةِ', 'وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'وَالنَّضْرُ أَيْضاً مِنْ نَضارَةِ وَجْهِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مَا بَيْنَ فَرْثٍ وَدَمِ', ['مَكَانُهُ', 'أَتَاهُ', 'عَشَرَةْ', 'مُعْجِزَةً'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعِنْدَ نُقْرَةِ الْغُرَابِ الْأَعْصَمِ', ['وَبَارَكَ اللَّهُ بِهِ فِي عَيْشِهِمْ', 'تَجِدُهَا وَسُمِّيَتْ بِزَمْزَمِ', 'وَبِفَتْحِ مَكَّةَ أَعْلَنَ الْإِسْلَامْ', 'فِي شَهْرِ شَوَّالَ الَّذِي مِنْ عَامِهِمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا\nوَلَا يَقِلُّ وَلَيْسَ يُلْحَقُ قَعْرُهَا', ['مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا', 'بِأَنَّ جِبْريلَ الأَمينَ أَقْبَلا', 'وَجَدُّهُ إِلْياسُ كانَ يَسْمَعُ', 'مُبَشِّراً بِبِعْثَةِ الرَّسولْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَى كُلِّ غَيْرِ مُؤْمِنٍ بِرَبِّهَا', ['أَمَرَ اللهُ أرْمِياءَ كانا', 'مُبَشِّرًا مَنْ صَدَّقُوا وَآمَنُوا', 'لُقِّبَ بِالفَارُوقِ لَمَّا أَعلَنَا', 'مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ذَلِكَ ........ وَمَا كَانَ لَهُ', ['حَمَلَتْ', 'أَسْدَتْ', 'ذُبِحَتْ', 'الْوَقْتِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ', ['ثَلَاثَةً كَمُلَتْ عَلَى التَّمَامِ', 'مِنْ بَعْدِ مَا آمَنَ بِالْإِسْلَامِ', 'الشَّاهِدُ النُّورُ الْمُبَشِّرُ الْكَرِيمُ', 'وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَتْ قُرَيْشٌ إِنَّهَا مِنْ حَقِّنَا\nأَيْضًا فَأَشْرِكْنَا تَكُنْ لِكُلِّنَا', ['وَاسْتَحْسَنَ الْأَشْيَاخُ عِنْدَ ذِكْرِهِمْ', 'أَمَرَهُم خَيرُ الوَرَى أَن يَفتَحُوا', 'سَمَّيْتُهَا بِرَوْضَةِ الْعُشَّاقِ', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يُحَكِمُوهَا فِي الْأُمُورِ الرَّاهِنَة', ['أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'وَنَجْلُهُ مِنْ بَعْدِهِ أَوْصَاهُ', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَيْقَنُوا بِالْمَوْتِ لَكِنْ ........', ['خَلَقْتُ', 'نَبَعَتْ', 'آمَنَتْ', 'خَافَتْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', ['عُتْبَةَ مَنْ آذَاهُ يَقْتُلُونَا', 'أَحْبَابَهَا لِأَجْلِهَا مُعَظَّمَا', 'فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا', 'وَأَنَّ هَذا القَوْلَ في تَنْزيلِها'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا\nوَرَجَعُوا مِنْ فَوْرِهِمْ وَأَيْقَنُوا', ['فَعَادَ عَمُّهُ بِهِ سَرِيعًا', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', 'لَكِنَّ بَعْضَ الْقَوْمِ آذَاهُ بِمَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَيْسَ لَهُ مِنْ كَثْرَةٍ فَأَقْسَمَا', ['وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'لَكِنَّ بَعْضَ الْقَوْمِ آذَاهُ بِمَا', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا', 'فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَلَدٍ يُسَاعِدُهُ عَلَى عَيْشِ ........', ['الْجَبِينِ', 'الزَّمَن', 'الْقُرْآنِ', 'يَتَأَدَّبونَ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَتَّى آتَاهُ اللَّهُ بَعْدَ عَشَرَةْ', ['يَتَأَدَّبونَ بِذِكْرِ طِيبِ خِصالِهِ', 'فَهَمَّ أَنْ يُوفِي بِمَا قَدْ نَذَرَهْ', 'بْنُ رَبِيعَةَ وَالْكُلُّ رَغِبَهْ', 'وَكُنْتُ أَسْتَظِلُّ تَحْتَ شَجَرَةٍ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا\nقِدَاحَهُمْ وَمَنْ تُصِبْهُ يَذْبَحُوا', ['فَكَانَ عَبْدُ اللَّهِ وَالِدُ أَحْمَدَا', 'وَنَجْلُهُ مِنْ بَعْدِهِ أَوْصَاهُ', 'وَجاءَ في الحَديثِ لا تَسُبّوا', 'أَكْرَمَهَا الرَّحْمَنُ بِالْأَوْلَادِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هُوَ الَّذِي يُذْبَحُ فِي هَذَا الْفِدَا', ['فَكَانَ عَبْدُ اللَّهِ وَالِدُ أَحْمَدَا', 'فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ حَيْثُ هُنَاكَ الْكَاهِنَة', ['لِسَائِرِ', 'لِلنُّورِ', 'لِخَيْرِ', 'لِخَيْبَرَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ', ['فِي حَقِّهِمْ وَغَيْرُهُمْ مُحَالُ', 'الصّادِقِ الطّاهِرِ وَالبَرِّ النَّبيل', 'وَكَمْ تَكُونُ بِقِيمَةِ الْأَمْوَالِ', 'فَأَرَّخوا بِالحادِثِ الجَليلِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالُوا لَهَا هِيَ عَشَرَةٌ مِنْ إِبِلِنَا\nقَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا', ['فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ', 'خَمْسَ قُرونٍ بَعْدَها سِتّونا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَشَرًا مِنَ الْإِبِلِ هُنَاكَ وَاضْرِبُوا', ['لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا', 'وَجاءَ في الحَديثِ لا تَسُبّوا', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فَعَلُوا إِلَى أَنْ بَلَغَتْ', ['وَهَكَذَا', 'وَبِها', 'وَرَبُّنَا', 'وَلَدًا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا', ['نَسْلُ النَّبِيِّ الْمُصْطَفَى وَنَبَتَا', 'تُدْلَى لِي عَلَى رَأْسِي أُبْصِرُهَا', 'وَعاشَ في دِيارِهِ وَثَبَتا', 'أَحَدٌ مِنَ الْخَلْقِ وَيَأْكُلُ مِنْهَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'الطَّيْرُ وَالْوُحُوشُ وَالسِّبَاعْ', ['الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ', 'وَانْتَشَرَتْ فِي سَائِرِ الْبِقَاعْ', 'مِنْ طَيْبَةَ لِدِينِ طَهَ مُتَّبِعْ', 'مَنَعَ الشَّيَاطِينَ اسْتِرَاقَ السَّمْعِ'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ', ['فَسَأَلَ المَوْلى وَمَنْ مُحَمَّدُ', 'حَادِثَةُ الْفِيلِ بِذِي الْبِلَادِ', 'أَن يَهدِيَهُ اللَّهُ إِلَى الرَّشَادِ', 'وَرَأَى رُكَانَة سَيِّدَ الْأَسْيَادِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَجَاءَهُمْ طَيْرٌ أَبَابِيلُ وَمَا\nتَرَكَ مِنْهُمْ وَاحِدًا لَمَّا رَمَى', ['بِكَفِّهِ الشَّرِيفَةِ قَدْ مَسَّهَا', 'أَلْقَى عَلَيْهِمْ هَذِهِ الْحِجَارَةْ', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', 'قَالَ الرَّاعِي وَاعَجَبًا مِمَّا أَرَى'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَجَيْشُهُمْ فِيهَا لَقِي دَمَارَهْ', ['أَلْقَى عَلَيْهِمْ هَذِهِ الْحِجَارَةْ', 'بِصَخْرَةٍ مِنْ فَوْقِهِ عَظِيمَة', 'يَتَعَرَّفونَ عَلَى الحَبيبِ وَآلِهِ', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِقَوْمِهِ ........ مُبَشِّرا', ['بِالمُصْطَفى', 'بِالْوَحْيِ', 'بِالنَّبِيِّ', 'بِالْأَذَى'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَعِظْهُمُ فيهِ كَذا يُخْبِرُهُمْ', ['وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', 'ذِكْرُكَ مَرْفوعٌ مَدى الأَيّامِ', 'قَدْ هَاجَرُوا بِدِينِهِمْ نَحْوَ السَّلَامْ', 'عَنْ ذَلِكَ المَبْعوثِ وَيُنْبِئُهُمْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ\nيَأْمُرُهُمْ حَثّاً عَلى اتِّباعِهِ', ['مَكَانُهُ مَا بَيْنَ فَرْثٍ وَدَمِ', 'يُعْلِمُهُمْ بِحُرْمَةِ البَيْتِ العَظيم', 'وَدَعَا الزُّبَيْرُ عَمُّ الْمُصْطَفَى إِلَى', 'فِي عَامِ الْفِيلِ وُلِدَ الرَّسُولُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَيْنَهُمَا كانوا يُؤَرِّخُونَا', ['خَافَتْ حَلِيمَةُ عَلَيْهِ عِنْدَهَا', 'خَمْسَ قُرونٍ بَعْدَها سِتّونا', 'وَعَنِ ابنِ عَبّاسٍ رَوَى مَرْفوعا', 'فَجَاءَهُمْ طَيْرٌ أَبَابِيلُ وَمَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَها بِمَوْتِ عَبْدِ ........', ['أَعْجَبُ', 'الْحَرْبِ', 'المُطَّلِب', 'يَذْهَبُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكانَ جَدُّ المُصْطَفى كِنانَة', ['فَأَرَادَ مِنْ أَحْمَدَ أَنْ يُصَارِعَهْ', 'فَسَكَنَ العَرْشُ بِلا اشْتِباهِ', 'مُعَظَّماً في العِلْمِ وَالأَمانَة', 'يَتَأَدَّبونَ بِذِكْرِ طِيبِ خِصالِهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ آنَ أنْ يَخْرُجَ يُدْعى أَحْمَدا\nفَاتَّبِعوهُ كَيْ تَنالوا الرَّشَدا', ['قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة', 'وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'أَتَاهُ آتٍ فِي الْمَنَامِ قَالَ لَهْ', 'يَدْعو إِلى البِرِّ وَلِلْأَخْلاقِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'في صُلْبِهِ يُلَبّي مَنْ سَيَشْفَعُ', ['تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ', 'حَمَى لَهُ غَنَمَهُ حَتَّى رَجَعْ', 'الطَّيْرُ وَالْوُحُوشُ وَالسِّبَاعْ', 'وَجَدُّهُ إِلْياسُ كانَ يَسْمَعُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'في قَوْمِهِ ذو عِزَّةٍ ........', ['كَعْبَةٍ', 'كَامِنَة', 'كَمِثْلِهِ', 'كَبيرَةِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجاءَ في الحَديثِ لا تَسُبّوا', ['فَإِنَّهُ بِفَضْلِ طَهَ سَعِدَا', 'بَعْضَ الَّذي إِلَيْهِ عَنْهُمْ وَصَلوا', 'سَقَاهُ رَبُّهُ لِأَجْلِ عِتْقِهَا', 'إِلْياسَ فَاسْتَجيبوا وَأَحِبّوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا\nرَبيعَةَ كَذا كَما قَدْ أَخْبَرَا', ['كانَ عَلى دينِ النَّبِيِّ إِسْماعيل', 'يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ', 'كَمَا أَتَى فِي آلِ عِمْرَانَ وَإِذْ', 'حَمَى لَهُ غَنَمَهُ حَتَّى رَجَعْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الصّادِقِ الطّاهِرِ وَالبَرِّ النَّبيل', ['كانَ عَلى دينِ النَّبِيِّ إِسْماعيل', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول', 'وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ', 'بَيْنَ الْمَقَاعِدِ وَبَيْنَهُمْ يَحُولْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هِيَ نورُ خَيْرِ ........ طَهَ المُصْطَفى', ['أَعْتَقَ', 'الخَلْقِ', 'الصَّادِقُ', 'الْمَصْدُوقُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَلَمّا وُلِدَ نِزارُ سَطَعا', ['ابْنُ مَظْعُونٍ وَمَسْعُودٌ أَسْرَعَا', 'نورُ النَّبِيِّ في العُيونِ لامِعَا', 'أَسْعَدَهَا بِأَحْمَدَ الْمُعَظَّمَا', 'مَا قَدْ رَأَوْا وَخَالَفُوا الْحَبِيبَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكانَ خَيْرَ أَهْلِ ذا الزَّمانِ\nوَكامِلاً في العَقْلِ وَالبَيانِ', ['وَهَزَّهُ فَاهتَزَّ مِن هَيبَتِهِ', 'فَعَطِشُوا بِوَسَطِ الطَّرِيقِ', 'جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بُخْتُنَصَّرْ عَلَى العَرَبْ وَأَفْرَطا', ['وَجاءَ أَنَّ اللهَ لَمّا سَلَّطا', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا', 'فَاقْتَتَلُوا أَرْبَعَةَ أَيَّامَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَمَرَ اللهُ أرْمِياءَ ........', ['كَذَّبُوا', 'كَادُوا', 'كانا', 'كَرِيمًا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِأَنَّهُ في صُلْبِهِ الرَّسولُ', ['كَانَ أَبُو بَكْرٍ بِلَا أَدْنَى جِدَالْ', 'قَدْ آمَنُوا بِالسَّيِّدِ الْمُبَجَّلِ', 'الخاتَمُ المُعَظَّمُ الجَليلُ', 'الطَّيِّبُ الْمُطَيَّبُ الْمَقْبُولُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ بَعْدِ مَوْتِ بُخْتُنَصَّرَ أَتى\nوَعاشَ في دِيارِهِ وَثَبَتا', ['لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا', 'وَشَرِبُوا مِنْهَا إِذًا وَعَادَتْ', 'وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْكَعْبَةِ كِسْوَتَها وَأَلْبَسا', ['أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمِنْ أَذى الوِسْوَاسِ ........', ['النَّفِيسُ', 'إِلْيَاسُ', 'الخَنّاسِ', 'يُقَاس'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَمُضَرُ كانَ جَميلاً مُشْرِقا', ['وَرَجَعُوا مِنْ فَوْرِهِمْ وَأَيْقَنُوا', 'وَصَوْتُهُ نورٌ إِذا ما نَطَقا', 'وَعاشَ في دِيارِهِ وَثَبَتا', 'بِهِ سَرِيعًا وَلْيَكُنْ سَعِيدًا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يَحْدو بِصَوْتٍ يَأْخُذُ الأَلْبابا\nيُذْهِلُ مَنْ يَسْمَعُهُ إِعْجابا', ['وَقَبْرُهُ الكَريمُ بِالرَّوْحاءِ', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك', 'يُكْرِمُ طَهَ غَايَةَ التَّكْرِيمِ', 'وَرُوِيَ عَنْ سَمُرَةَ بْنِ جُنْدُبِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَعَدَّ لِلْحُروبِ كانَ شَهْمَا', ['وَجَدُّهُ مَعَدٌّ سُمِّيَ لِمَا', 'فَوَافَقُوا قَالُوا بِهِ رَضِينَا', 'حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'فَإِنَّهُ كانَ حَكيماً طَيِّبا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ سُمِّي بِذاكَ لَمَّا', ['وَجَاءَهُ', 'وَزَيَّنَهُ', 'وَصَحْبِهِ', 'وَخُزَيْمَةُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا', ['كُلَّ الفَخارِ بِالنَّبِيِّ ما أَشْرَكا', 'ذَاكَ الْوَلِيدَ الطَّاهِرَ الْمُنَوَّرَا', 'العِلْمُ أَنَّ اللهَ رَبّي فَضَّلا', 'بَعْضَ الَّذي إِلَيْهِ عَنْهُمْ وَصَلوا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'صَلّى عَلَيْهِمْ ذو الجَلالِ وَسَلَّما', ['شِيَاهَهُ رَأَى ذِئْبًا فَدَفَعَا', 'نَسَبٌ شَريفٌ بِالحَبيبِ تَكَرَّما', 'وَلِأَجْلِ هَذا الدّينِ ماذا عَمِلوا', 'قِدَاحَهُمْ وَمَنْ تُصِبْهُ يَذْبَحُوا'], 1),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ ........', ['وَأَمْرِهِ', 'وَالِدِهْ', 'وَمَعَهُ', 'وَاللَّهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَبْنِي بِهَا فَأَبَى الشَّرِيفُ الْمُؤْتَمَنْ', ['خَرَجَ مِنْهَا ذَلِكَ النُّورُ الْمُبِين', 'قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ', 'أَعْظَمُهَا قَدْرًا هُوَ الْقُرْآنُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'رَغِبَتْ بِهِ كَانَ وَسِيمًا نَاضِرَا', ['فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', 'قَدْ آنَ أنْ يَخْرُجَ يُدْعى أَحْمَدا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِذْ حَمَلَتْ بِالنُّورِ طَهَ ........', ['وَلَدَهْ', 'وَالجَنَّةَ', 'وَأَمْرِهِ', 'وَفَاطِمَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أُمًّا لِخَيْرِ خَلْقِهِ ........', ['الرَّشَدا', 'مُحَمَّدًا', 'الْأَمِينَا', 'ذَهَبُوا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَمْ تَشْكُ عِنْدَ حَمْلِهِ أَثْقَالَا', ['عَدْنَانَ مِنْ نَسْلِ الْكِرَامِ الْفُضَلَا', 'إِلى الحَبيبِ الهاشِميِّ قائِلا', 'لَكِنَّهَا نَالَتْ بِهِ الْأَفْضَالَا', 'لِقَوْمِهِ بِالمُصْطَفى مُبَشِّرا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِمَا لَهُ مِنْ شَرَفٍ ........', ['يَكْفِيهِ', 'أَرْبَعَةَ', 'جُمُعَةِ', 'اللَّهِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', ['صَاحِبِكُمْ عِيدُوا وَزِيدُوا الْإِبِلَا', 'أَضَاءَ بُصْرَى نَوَّرَ الْقُصُورَا', 'دَعُوهُ وَاتْرُكُوا لَهُ الْمَكَانَا', 'أُمًّا لِخَيْرِ خَلْقِهِ الْأَمِينَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَبْنِي بِهَا ........ الشَّرِيفُ الْمُؤْتَمَنْ', ['فَنَادَى', 'فَأَبَى', 'فَمَضَى', 'فُؤَادِي'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَمْ تَشْكُ عِنْدَ حَمْلِهِ أَثْقَالَا\nلَكِنَّهَا نَالَتْ بِهِ الْأَفْضَالَا', ['أَنْفُسَهُمْ لِيَنْصُرُوا الْإِسْلَامَا', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', 'سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا', 'وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ\nيَبْنِي بِهَا فَأَبَى الشَّرِيفُ الْمُؤْتَمَنْ', ['آمِنَةُ وَمَنْ كَمِثْلِ آمِنَة؟!', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا', 'قَالَ لَهُ أَعْجَبُ مِنِّي أَنْ تَرَى', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَنِ اصْطَفَاهَا اللهُ كَيْ ........', ['مِنْهَا', 'تَكُونَا', 'آمَنُوا', 'مُعَظَّمَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَغَيْرُهَا مِنْ قَوْمِهِ الْكَثِيرُ\nلَكِنَّهُ بِدِينِهِ بَصِيرُ', ['وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'وَهَكَذَا فَعَلُوا إِلَى أَنْ بَلَغَتْ', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كُنَّ جَمِيعًا ........ فِيهِ', ['قَلَّبْتُ', 'ذُبِحَتْ', 'ذَهَبَتْ', 'رَاغِبَاتٍ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَكِنَّهُ بِدِينِهِ ........', ['بُخْتُنَصَّرْ', 'بَصِيرُ', 'بِذِكْرِ', 'بِخَبَرٍ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ........', ['يُصَدِّقُوا', 'ظَاهِرَا', 'تَشَرَّفا', 'يَنْطِقُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِمَا لَهُ مِنْ شَرَفٍ يَكْفِيهِ', ['وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِذْ حَمَلَتْ بِالنُّورِ طَهَ وَلَدَهْ', ['وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَغِبَتْ بِهِ كَانَ وَسِيمًا ........', ['أَعلَنَا', 'الْأَمِينَا', 'أَيُّهَا', 'نَاضِرَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أُمًّا لِخَيْرِ خَلْقِهِ الْأَمِينَا', ['مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'أَمَرَ اللهُ أرْمِياءَ كانا', 'خَمْسَ قُرونٍ بَعْدَها سِتّونا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ', ['مَنْظُومَةٌ فِي السِّيرَةِ النَّبَوِيَّةْ', 'مَا مِنْهُمُ قَطُّ نُفُوسٌ مُشْرِكَةْ', 'لِمَا لَهُ مِنْ شَرَفٍ يَكْفِيهِ', 'أُولُو التُّقَى وَالْبِرِّ وَالْأَمَانَةِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ذَاتِ ........ الْعِظَامِ الْكَامِنَة', ['عَلَامَاتٍ', 'الْمُرْشِدَاتِ', 'الْكَمَالَاتِ', 'الْآيَاتُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ\nلِمَا لَهُ مِنْ شَرَفٍ يَكْفِيهِ', ['وَمَاتَ عَبْدُاللَّهِ قَبْلَ أَنْ يَرَى', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ', 'وَقِيلَ بَلْ يُنَاوِلُ السِّهَامَا', 'فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', ['ذَاتِ الْكَمَالَاتِ الْعِظَامِ الْكَامِنَة', 'وَلَمْ يَجِدْ مِنْ دَمْعَةٍ رَحِيمَة', 'لَكِنَّهُ مَا خَانَ لِلْأَمَانَةْ', 'مَنْظُومَةٌ فِي السِّيرَةِ النَّبَوِيَّةْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', ['إِذْ حَمَلَتْ بِالنُّورِ طَهَ وَلَدَهْ', 'وَمِن مَجَامِعِ الثِّيَابِ أَمسَكَه', 'عَنْ غَيْرِهِ مَوْلَاهُ قَدْ فَضَّلَهُ', 'فَأَرَادَ مِنْ أَحْمَدَ أَنْ يُصَارِعَهْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَمَضَى إِلَى بَيْتِ ........ آمِنَة', ['دَعْوَتُهُ', 'الْخَاتِمَة', 'الْكَرِيمَةِ', 'مَضْمُونَةٌ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا', ['لِلَّهِ فِيهِ دَائِمًا وَشَاهِدًا', 'لِصَفْوَةِ الْأَطْهَارِ قَوْمٍ كُرَمَا', 'رَغِبَتْ بِهِ كَانَ وَسِيمًا نَاضِرَا', 'السَّابِقِينَ الأَوَّلِينَ ذَوِي الوَفَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَغَيْرُهَا مِنْ قَوْمِهِ الْكَثِيرُ', ['لَكِنَّهُ بِدِينِهِ بَصِيرُ', 'فَأَدْرَكَتْهُ رَحْمَةُ الْغَفَّارِ', 'مِن جَانِبَيهِ مَعَهُمَا يَسِيرُ', 'حَيْثُ النُّزُولُ ذَاكَ الرَّأْيُ الْمُعْتَبَرْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ', ['دُسْتُورُ هَذَا الدِّينِ وَالْبَيَانُ', 'الْبَاسِطِ الْمَعْرُوفِ ذِي الْإِحْسَانِ', 'وَأَخْرَجُوهُ مِنْ حِمَى الْأَوْطَانِ', 'يَبْنِي بِهَا فَأَبَى الشَّرِيفُ الْمُؤْتَمَنْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمْ تَشْكُ عِنْدَ ........ أَثْقَالَا', ['حَمْلِهِ', 'نَوْمِهِ', 'يَرْعَاهُ', 'مَيْسَرَةُ'], 0),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَوْلِدُهُ مِيلَادُ كُلِّ الْبُشْرَيَات', ['فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', 'بَدَتْ فِيهِ الْآيَاتُ بَلْ وَالْمُعْجِزَات', 'الْمُرْشِدَاتِ لِلْهُدَى وَالظَّاهِرَاتِ', 'بَكَاهُ أَهْلُ مَكَّةَ وَالْبَيْتُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاسْتَحْسَنَ الْأَشْيَاخُ عِنْدَ ذِكْرِهِمْ\nلِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ', ['ضَرَبَهَا وَزَوجَهَا وَبَعدَهَا', 'أَدَبًا مَعَ النَّبِيِّ وَاحْتِرَامَا', 'كَمَا أَتَى وَحْيٌ وَنَصٌّ قَطْعِيْ', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'نَرْجُو بِهِ مِنْ رَبِّنَا الْإِكْرَامَا', ['لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'أَدَبًا مَعَ النَّبِيِّ وَاحْتِرَامَا', 'أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ذِكْرِهَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الطَّيِّبُ ........ الْمَقْبُولُ', ['الِاقْتِرَابِ', 'الْخِطَابِ', 'الْمُطَيَّبُ', 'العَرَبْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَعَمَّتِ الْأَفْرَاحُ فِي الْبِلَادِ', ['لِمَا لَهُ مِن شِدَّةٍ مِثلَ الأَسَد', 'حَادِثَةُ الْفِيلِ بِذِي الْبِلَادِ', 'يَا مَرْحَبًا بِسَيِّدِ الْعِبَادِ', 'وَبِالْبَنَاتِ ثُمَّ بِالْأَحْفَادِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ أَشْرَقَ الرَّبِيعُ بِالْأَنْوَارِ\nيَا سَعْدَنَا بِمَوْلِدِ الْمُخْتَارِ', ['مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَضَاءَ بُصْرَى نَوَّرَ الْقُصُورَا', ['دَعَا لَهُ خَيرُ الوَرَى فَأَسلَمَا', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا', 'وَكَانَ ذَا عَنْ رُؤْيَا قَدْ رَآهَا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَرَجَ مِنْهَا ذَلِكَ النُّورُ ........', ['الرَّحْمَنُ', 'الجِنِّ', 'الْمُبِين', 'الْإِحْسَانِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَرْضَعَتْ ثُوَيْبَةُ وَقْتَ الصِّغَر', ['فَأَدْرَكَتْهُ رَحْمَةُ الْغَفَّارِ', 'مَنْ أَخْلَصُوا فِي خِدْمَةِ الْمُخْتَارِ', 'كانَتْ تُرى بِوُجوهِهِمْ أَنْوارُ', 'نَبِيَّنَا وَحَمْزَةَ الْعَمَّ الْأَبَر'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى\nوَبَشَّرَتْ لِعَمِّهِ قَدْ ثَبَتَا', ['فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَقَاهُ رَبُّهُ لِأَجْلِ عِتْقِهَا', ['وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا', 'وَخَصَّهَا بِأَشْرَفِ الْمَزَايَا', 'بِأَنَّ جِبْريلَ الأَمينَ أَقْبَلا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَرْضَعَتْ حَلِيمَةُ ........', ['يَذْبَحَه', 'السَّعْدِيَّة', 'الرِّسَالَةُ', 'اتِّبَاعِهِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَاشَتْ بِهِ فِي عِيشَةٍ هَنِيَّةٍ', ['أَعْتَقَهُ أَيْضًا كَذَا زَنِيرَةَ', 'سَعِيدَةٍ كَرِيمَةٍ غَنِيَّةٍ', 'فَجَلَسَ الذِّئْبُ إِلَيْهِ كَلَّمَهْ', 'وَمِنْ فُؤَادِ الْمُصْطَفَى قَرِيبَةُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ بَعْدِ ضِيقٍ فِي الْحَيَاةِ وَنَكَد\nعَمَّ السُّرُورُ أَرْضَهُمْ إِلَى الْأَبَد', ['أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى', 'أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ', 'فَإِنَّهُ كانَ حَكيماً طَيِّبا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَرْبَعَةً فَأَسْعَدِ الْأَيَّامَا', ['أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'مِنْها الَّذي رَواهُ لَمّا أَكَلا', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ذِكْرِهَا', 'وَغَيْرُهُمْ أَيْضًا كَثِيرٌ آمَنُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَرَبُّنَا الرَّحْمَنُ ........ قَدْرَهُ', ['أَعْلَى', 'الَّذي', 'النَّبِيُّ', 'يُدْعى'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَافَتْ حَلِيمَةُ عَلَيْهِ عِنْدَهَا', ['هَذَا النَّبِيَّ بِطَيْبَةَ مُبَشِّرَا', 'مِنْ الْعَبِيدِ مُعْتِقًا وَمُوقِنَا', 'فَأَنْزَلَتْ حَلِيبَهَا فِي حِينِهَا', 'وَأَسْرَعَتْ وَسَافَرَتْ فِي حِينِهَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ\nآمِنَةَ يَعِيشُ بَيْنَ قَوْمِهِ', ['قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة', 'مَنْ عَلَّمَ الْإِنْسَانَ مَا لَمْ يَعْلَمِ', 'أَخَذَهُ مَعْهُ لِأَرْضِ الشّامِ', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ابْنِي لَهُ مَكَانَةٌ عَلِيَّة', ['مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة', 'قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَا ........ أَبْشِرِي فَإِنَّه', ['يَبْنِي', 'المُصْطَفَى', 'تَخَافِي', 'الَّذِي'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسَافَرَتْ بِهِ إِلَى الْمَدِينَة', ['وَقَدْ تَسَمّى بِيَوْمِ العَرُوبَةِ', 'تَزُورُ أَخْوَالًا لَهُ أَمِينَة', 'وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'حَبِيبُهُ الْفَرْدُ الَّذِي رَآهُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَاشَتْ عَلَى تَوَاصُلِ الْأَرْحَامِ\nوَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', ['قَدِ اصْطَفَاهَا اللَّهُ مِنْ بَيْنِ الْبَشَر', 'وَازْدَادَ إِيمَانُ الصَّحَابَةِ الْكِرَامِ', 'وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَنَّ رَبَّ الْعَرْشِ أَعْلَى ذِكْرَهَا', ['فَكَانَ دَوْمًا يَشْتَرِي مَنْ آمَنَا', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا', 'لِيَعْرِفَ النَّاسُ جَمِيعًا قَدْرَهَا', 'خَافَتْ حَلِيمَةُ عَلَيْهِ عِنْدَهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَكَانَةً وَأَعْظَمَ ........', ['الْعَطَايَا', 'عَاشُوا', 'مُجِيبَا', 'قَالُوا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَمَرِضَتْ هُنَاكَ عِنْدَ أَهْلِهَا', ['كُلَّ الفَخارِ بِالنَّبِيِّ ما أَشْرَكا', 'فَإِنَّهُ بِفَضْلِ طَهَ سَعِدَا', 'وَدُفِنَتْ عَائِدَةً بِقُرْبِهَا', 'وَصَوْتُهُ نورٌ إِذا ما نَطَقا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي أَرْضِ الْأَبْوَاءِ الَّتِي تَشَرَّفَتْ\nبِأُمِّ خَيْرِ الْخَلْقِ قَدْ تَنَوَّرَتْ', ['وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا', 'خَوْفًا عَلَى إِيمَانِهِمْ مِنْ قَوْمِهِمْ', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ذِكْرِهَا', 'آمِنَةُ وَمَنْ كَمِثْلِ آمِنَة؟!'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي ذَاتِهَا كُلُّ الْمَزَايَا كَامِنَة', ['لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'قَامُوا لَهُ وَأَوْجَعُوهُ ضَرْبَا', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', 'آمِنَةُ وَمَنْ كَمِثْلِ آمِنَة؟!'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ........', ['نَبِيَّنَا', 'ذِكْرِهَا', 'عَنْهَا', 'شَرَفًا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ', ['وَجَدِّهِ الْكَرِيمِ ذِي الْمَفَاخِرِ', 'مِن جَانِبَيهِ مَعَهُمَا يَسِيرُ', 'تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', 'يَحْكِي لَنَا مِمَّا أَتَى مِنْ خَبَرِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَآلِهِ وَصَحْبِهِ الْأَطْهَارِ', ['تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', 'أُمَّتَكَ أَنْ يُؤْمِنوا كُلٌّ يُقِرّ', 'كَلَّا وَلَا هَذَا بِقَوْلِ شَاعِرٍ', 'مَنْ أَخْلَصُوا فِي خِدْمَةِ الْمُخْتَارِ'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي الْكُتُبِ الصَّحِيحَةِ الْمُسَطَّرَة', ['تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'عَبْدُ مَنَافٍ جَدُّهَا وَزُهْرَة', 'هِيَ أَصْلُ تِلْكَ الشَّجَرَةِ الْعَجِيبَةِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ وَأَحْمَدُ وَهَادِي\nوَرَحْمَةٌ لِسَائِرِ الْعِبَادِ', ['أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'لِيُؤْمِنُوا يُصَدِّقُوا بِدِينِهِ', 'مِنْها الَّذي رَواهُ لَمّا أَكَلا', 'وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَهْوَ الرَّؤُوفُ ........ وَالرَّحِيمُ', ['وَزَيْنَبُ', 'وَالْحَبِيبُ', 'وَالشِّهَابِ', 'وَالعَرَبْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَرَحْمَةٌ لِسَائِرِ الْعِبَادِ', ['أَكُنْتُمُ مُصَدِّقِينَ قَوْلِي', 'مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'فَلَمْ يَزَلْ يَدْعُو النَّبِيُّ مَنْ أَتَى', 'خَدِيجَةُ النُّورِ الَّتِي مِنْهَا أَتَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هُوَ ........ الظَّاهِرُ الْإِبْلَاج', ['النَّبِيُّ', 'المُصْطَفَى', 'الَّذي', 'أُخْرَى'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', ['ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'لَكِنْ شَفَاهُ اللهُ مِمَّا لَاقَى', 'وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى', 'الصَّادِقُ الْمَصْدُوقُ طه الْمُصْطَفَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي الْكُتُبِ الصَّحِيحَةِ ........', ['الْحَبِيبَةِ', 'يَذْبَحَه', 'الْمُسَطَّرَة', 'زَوْجَتُهُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَنِعْمَةٌ مِنْ رَبِّنَا جَمِيل', ['وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ', 'كانَ عَلى دينِ النَّبِيِّ إِسْماعيل', 'رَوى كَذاكَ صاحِبُ الدَّلائِلِ', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَذَا نَبِيُّ التَّوْبَةِ ........', ['وَفَاطِمَة', 'وَخِدْمَتِهِ', 'وَأَخْرَجُوهُ', 'وَالْمَرْحَمَة'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول\nوَنِعْمَةٌ مِنْ رَبِّنَا جَمِيل', ['قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ', 'كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة', 'وَقِيلَ بَلْ يُنَاوِلُ السِّهَامَا', 'وَبَعدَ الاولَى أَسلَمَ الفَارُوقُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هُوَ النَّبِيُّ الظَّاهِرُ الْإِبْلَاج', ['هُوَ الْمُنِيرُ وَالنَّذِيرُ وَالسِّرَاج', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'فَإِنَّ سيرَةَ الحَبيبِ فيها', 'إِذَا دَعَا الْكُفَّارَ لِلْإِيمَانِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'الصَّادِقُ الْمَصْدُوقُ طه الْمُصْطَفَى', ['نَبِيَّهُ في ذَلِكَ الزَّمانا', 'لِلْبَيْتِ مِنْ أَهْلِ الْقُرَى قَدْ ثَبَتَا', 'الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', 'حِلْفِ الْفُضُولِ قَوْمُهُ وَأَقْبَلَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَذَا نَبِيُّ الرَّحْمَةِ وَالْمَلْحَمَة', ['هَذَا أَبُو بَكْرٍ وَمَنْ كَمِثْلِهِ', 'حِينَ أَشَارَ الْمُصْطَفَى بِكَفِّهِ', 'لَوْ أَنَّ رَبَّ الْعَرْشِ عَشَرًا وَهَبَه', 'كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالْحَاشِرُ الْمَاحِي فَجَلَّ الْوَاهِبُ', ['وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ', 'أَبُو طَالِبٍ الْكَرِيمُ الطَّيِّبُ', 'وَرُوِيَ عَنْ سَمُرَةَ بْنِ جُنْدُبِ', 'وَجَدُهُ الشَّرِيفُ عَبْدُ الْمُطَّلِب'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة', ['وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'أُولُو التُّقَى وَالْبِرِّ وَالْأَمَانَةِ', 'آمِنَةَ يَعِيشُ بَيْنَ قَوْمِهِ', 'كَذَا نَبِيُّ الرَّحْمَةِ وَالْمَلْحَمَة'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الصَّادِقُ الْمَصْدُوقُ طه ........', ['النَّبِيِّ', 'الْمُصْطَفَى', 'يَضْرِبْنِي', 'اختَفَى'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'هُوَ الْمُنِيرُ وَالنَّذِيرُ وَالسِّرَاج', ['وَلا كَمِثْلِ هاشِمٍ بَني أَبِ', 'هُوَ النَّبِيُّ الظَّاهِرُ الْإِبْلَاج', 'وَشَرِبَتْ لِلنُّورِ مِنْ مَعِينِهِ', 'مِنْ خُفِّ رَاحِلَةٍ لَهُ وَانْفَجَرَتْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدٌ وَأَحْمَدُ ........', ['وَرُوِيَ', 'وَاتَّقَى', 'وَهَادِي', 'وَأَوْصَى'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ', ['وَجَاءَتِ الْوُفُودُ لِلْهَادِي الْأَحَبْ', 'وَالْحَاشِرُ الْمَاحِي فَجَلَّ الْوَاهِبُ', 'يَجْتَمِعُونَ كُلُّهُمْ أَحْبَابُ', 'بِنَعْتِهِ الْآخِذِ بِالْأَلْبَابِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول', ['وَنِعْمَةٌ مِنْ رَبِّنَا جَمِيل', 'في الحُسْنِ وَالبَهاءِ وَالجَمالِ', 'ما قالَهُ جِبْريلُ مِنْ شَمائِلِ', 'فِي حَقِّهِمْ وَغَيْرُهُمْ مُحَالُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ\nالشَّاهِدُ النُّورُ الْمُبَشِّرُ الْكَرِيمُ', ['بِأَنَّ رَبَّ العَرْشِ قَدْ أَوْحى إِلى', 'فَوَافَقُوا قَالُوا بِهِ رَضِينَا', 'هُوَ الْمُنِيرُ وَالنَّذِيرُ وَالسِّرَاج', 'فَأَجَابَهُ الصِّدِّيقُ إِنِّي إِنَّمَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'هُوَ الْمُنِيرُ وَالنَّذِيرُ وَالسِّرَاج\nهُوَ النَّبِيُّ الظَّاهِرُ الْإِبْلَاج', ['فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول', 'يَخْرُجُ فِي وَقْتِ كَذَا عَنْ وَقْتِهِ', 'عَاشُوا هُنَاكَ عِيشَةً سَعِيدَة'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة\nفِي الْكُتُبِ الصَّحِيحَةِ الْمُسَطَّرَة', ['مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'يَخْشَى عَلَيْهِمْ مِنْ عَذَابِ اللَّهِ', 'نوراً عَلى عَرْشِ الجَليلِ يَبْدو', 'كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَحْمَةٌ ........ الْعِبَادِ', ['لِسَائِرِ', 'لِلنُّورِ', 'لِلْبَدْرِ', 'لِخَيْرِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'الصَّادِقُ الْمَصْدُوقُ طه الْمُصْطَفَى\nالْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', ['وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ', 'يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ', 'وَأَخبَرُوهُ عَن مَكَانِ المُصطَفَى', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', ['فَسَأَلَ المَوْلى وَمَنْ مُحَمَّدُ', 'يَتْلُو عَلَيْهِمْ مِنْ هُدَى الْإِرْشَادِ', 'وَرَحْمَةٌ لِسَائِرِ الْعِبَادِ', 'وَالْعَوْنُ مِنْ إِلَهِنَا الْمَعْبُودِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مُدَّثِّرٌ رَسُول', ['الجَليلِ', 'جِبْريلَ', 'مُزَّمِّلٌ', 'الرَّسولُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَذَا نَبِيُّ الرَّحْمَةِ ........', ['وَرُكَانَةْ', 'وَأَدخَلُوهُ', 'وَالْمَلْحَمَة', 'وَعَذَّبُوهُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ\nوَالْحَاشِرُ الْمَاحِي فَجَلَّ الْوَاهِبُ', ['وَجَاءَهُ جِبْرِيلُ شَقَّ صَدْرَهُ', 'وَبَعْدَ ذَا فَهَذِهِ أَلْفِيَّةْ', 'مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'الصَّادِقُ الْمَصْدُوقُ طه الْمُصْطَفَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا ........', ['شَرَّفَا', 'حِينَمَا', 'مُعَادِيًا', 'يُهْلَكُوا'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِقَرَارِيطَ مَوْضِعٌ لِذِي النَّظَرْ', ['وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ', 'قَدْ أَشْرَقَ الرَّبِيعُ بِالْأَنْوَارِ', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ الصِّغَرْ', 'فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ\nلِمَا فِيهَا مِنْ رِقَّةٍ وَعَطْفِ', ['وَبَعْدَ مَا قَدْ أَكْمَلَ الْعِشْرِينَا', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فِيكُمُ', 'لِأَنَّهَا هِيَ أَصْعَبُ الْبَهَائِم', 'حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا\nذُو رَحْمَةٍ وَرَأْفَةٍ وَسَهْلَا', ['وَأَوَّلُ مَنْ آمَنَ مِنَ الرِّجَالْ', 'لِخَيْبَرَ حَيْثُ هُنَاكَ الْكَاهِنَة', 'مِنْ قَبْلِ أَنْ تَأْتِي الرِّسَالَةُ إِلَى', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكُلُّ وَصْفٍ كَانَ فِيهِمْ لَا ........', ['الشَّمْسَ', 'إِلْياسَ', 'النَّفِيسُ', 'يُقَاس'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَالصَّبْرُ فِيهَا لِلْفَتَى ........', ['الْمَنَامِ', 'الشّامِ', 'الْقِيَامَ', 'مُلَازِم'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خُلُقَ السَّكِينَةِ وَالْوَقَارِ ........', ['يَتَكَلَّمُ', 'مُلَازِم', 'مُلْتَزَمْ', 'الأَيّامِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِغَيْرِهِمْ مِنْ أَحَدٍ مِنْ بَاقِي النَّاس', ['فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', 'وَكُلُّ وَصْفٍ كَانَ فِيهِمْ لَا يُقَاس', 'مِنْ أَعْيُنِ الجِنِّ وَكُلِّ النّاسِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ عَامَيْنِ أَتَاهُ الْمَوْتُ', ['بَدَتْ فِيهِ الْآيَاتُ بَلْ وَالْمُعْجِزَات', 'مِنْ ذَلِكَ الْفِعْلِ وَلَكِنْ ذَهَبَتْ', 'مِنْ رَبِّهِ تَلَقّى لِلْكَلِماتْ', 'بَكَاهُ أَهْلُ مَكَّةَ وَالْبَيْتُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَاشِقًا مُتَيَّمًا ........', ['بِالْمُصْطَفَى', 'بِالْوَحْيِ', 'بِالْأَذَى', 'بِالنَّبِيِّ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ذُو رَحْمَةٍ وَرَأْفَةٍ وَسَهْلَا', ['فَعَجَزُوا عَنْ سُورَةٍ وَهَرَبُوا', 'خَمْسَ قُرونٍ بَعْدَها سِتّونا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا', 'مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي حَقِّهِمْ وَغَيْرُهُمْ مُحَالُ', ['وَرَعْيُهَا لِلْأَنْبِيَا كَمَالُ', 'جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ', 'وَأَوَّلُ مَنْ آمَنَ مِنَ الرِّجَالْ', 'بِمَوْتِهِ دَوْماً لِعامِ الفيلِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ الصِّغَرْ\nبِقَرَارِيطَ مَوْضِعٌ لِذِي النَّظَرْ', ['لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لِأَنَّهَا هِيَ أَصْعَبُ الْبَهَائِم\nوَالصَّبْرُ فِيهَا لِلْفَتَى مُلَازِم', ['وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك', 'وَهُوَ الَّذِي حَفَرَ زَمْزَمَ بَعْدَ أَنْ', 'وَبِهِمْ سَتَفْهَمُ مُنْزَلَ القُرْآنِ', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَا بُدَّ مِنْ تَأْدِيبِهِ تَوَقِّيَا', ['مُدَافِعًا عَنْهَا وَعَنْ وَفَائِهَا', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا', 'فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَا مِنْ نَبِيٍّ إِلَّا قَدْ رَعَى ........', ['الْغَنَمْ', 'الشَّامِ', 'تَعْظِيمِهِمْ', 'يَأْمُرُهُمْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ ........', ['اللَّطْفِ', 'الرَّؤُوفُ', 'مَنَافٍ', 'يُعْرَفُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ ........', ['يَحْفِرَ', 'الْمُدَّثِّرُ', 'الصِّغَرْ', 'دُسْتُورُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَضَى إِلَى سَبِيلِهِ كَرِيمًا\nوَسَيِّدًا وَقَائِدًا عَظِيمًا', ['قَالَ الرَّاعِي وَاعَجَبًا مِمَّا أَرَى', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ', 'وَنَجْلُهُ مِنْ بَعْدِهِ أَوْصَاهُ', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ذِكْرِهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَعْيُهَا لِلْأَنْبِيَا ........', ['كَمَالُ', 'كَمُلَتْ', 'كَمِثْلِهِ', 'كَمِثْلِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَا بَعَثَ ........ نَبِيًّا إِلَّا', ['مُدْرِكَةُ', 'اللَّهُ', 'زَكَّاهُ', 'أَعْتَقَهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مِنْ بَعْدِهِ أَوْصَاهُ', ['وَنَجْلُهُ', 'وَزَيَّنَهُ', 'وَحِزْبِهِ', 'وَفَائِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَيِّدًا وَقَائِدًا ........', ['أَحْبَابَهَا', 'عَظِيمًا', 'تَسُبّوا', 'صَدِيقَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَارَكَ اللَّهُ بِهِ فِي عَيْشِهِمْ', ['نَبِيُّنَا الْمُخْتَارُ مِنْ بَيْنِ الْأُمَمْ', 'قَدَّمَهُ عَلَى بَنِيهِ كُلِّهِمْ', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ', 'نَسَبٌ شَرِيفٌ طَاهِرٌ مُعَظَّمٌ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِمَا فِيهَا مِنْ رِقَّةٍ وَعَطْفِ', ['فَإِنَّهَا خَدِيجَةُ الْحَبِيبَةُ', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'قَالَ النَّبِيُّ إِنَّنِي لَأَعْرِفُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَارَكَ اللَّهُ بِهِ فِي ........', ['السَّلَامْ', 'عَيْشِهِمْ', 'مَقَامٌ', 'صَاحِبِكُمْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَا بُدَّ مِنْ ........ تَوَقِّيَا', ['تَأْدِيبِهِ', 'الطَّاهِرَةْ', 'خُزَيْمَةُ', 'يُبْعِدَهُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَانَ رَحِيمًا طَيِّبًا فِي رِفْقِ', ['فَعَطِشُوا بِوَسَطِ الطَّرِيقِ', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'اقْرَأْ بِإسْمِ رَبِّكَ الَّذِي خَلَقْ', 'سَمَّيْتُهَا بِرَوْضَةِ الْعُشَّاقِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ النَّبِيُّ إِنَّ فِي أَهْلِ الْغَنَمْ', ['خُلُقَ السَّكِينَةِ وَالْوَقَارِ مُلْتَزَمْ', 'عَلَيْهِمُ أَزْكَى الصَّلَاةِ وَالسَّلَامِ', 'عَلِيٌّ الْكَرَّارُ ذُو الْإِقْدَامِ', 'هُوَ دينُ إِبْراهيمَ كانَ جَدُّهُمْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِقَرَارِيطَ مَوْضِعٌ لِذِي ........', ['الْبِئْرَ', 'النَّظَرْ', 'الْمَذْكُورُ', 'الصُّخُورَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ عَامَيْنِ أَتَاهُ ........', ['ذَهَبَتْ', 'البَيْتِ', 'رَغِبَتْ', 'الْمَوْتُ'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', ['بِأَنَّ رَبَّ العَرْشِ قَدْ أَوْحى إِلى', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي', 'وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'قَالَ لَهُ اقْرَأْ أَيُّهَا النَّبِيُّ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بَلْ يُنَاوِلُ السِّهَامَا', ['وَأَوَّلُ', 'وَسُئِلَ', 'وَقِيلَ', 'وَالْكُلُّ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي', ['لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', 'بِدَعوَةِ النَّبِيِّ وَانزَاحَ العَمَى', 'كِلَابِ مُرَّةَ بْنِ كَعْبِ بْنِ لُؤَيْ', 'وَمَنْ آذَى النَّبِيَّ نَالَ الْعُسْرَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'تَعَاهَدُوا لِنُصْرَةِ ........', ['الْمَظْلُومِ', 'الإِسلَامَ', 'الْكَرِيمُ', 'أَمَرَهُم'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ضَرَبَهُ قَطَعَ لِرُكْبَتِهِ', ['وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ', 'لَوْ أَنَّ رَبَّ الْعَرْشِ عَشَرًا وَهَبَه', 'قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ', 'مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَتَى إِلَى ........ بِافْتِخَارِ', ['عُكَاظَ', 'تَحَمَّلوا', 'مُتَّبِعْ', 'النَّاسِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ\nحَرْبَ الْفِجَارِ يَرْمِي بِسِهَامِهِ', ['هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', 'هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي', 'وَقِيلَ بَلْ يُنَاوِلُ السِّهَامَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَدَعَا ........ عَمُّ الْمُصْطَفَى إِلَى', ['طَاهِرٌ', 'الزُّبَيْرُ', 'عَساكِرَ', 'الْحَجَرَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَرْبَ الْفِجَارِ يَرْمِي ........', ['بِمَوْتِهِ', 'بِالصَّحِيفَةِ', 'بِسِهَامِهِ', 'بِدِينِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ ........', ['الْقَوْمِ', 'يَجْمَعُهُمْ', 'مُكَرَّمٌ', 'دينُهُمْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ\nأَوْ غَابَ عَنْهُمُ يَكُونُ الْخُسْرُ', ['مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'قَالَ لَهُ اقْرَأْ أَيُّهَا النَّبِيُّ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنَا أَعَزُّ الْعَرَبِ ........', ['يُهْلَكُوا', 'أَفْضَالَا', 'قَرَأَهَا', 'مِنْهَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ فِيهَا الْمُصْطَفَى ........', ['الأَتَمّا', 'حِينَهَا', 'غُلَامَا', 'الْحَقَّا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', ['أَتَى إِلَى عُكَاظَ بِافْتِخَارِ', 'لَكِنَّهُ بِدِينِهِ بَصِيرُ', 'نَبِيَّنَا وَحَمْزَةَ الْعَمَّ الْأَبَر', 'أَنْ تَحْمِلَ النُّورَ الْمُتَمِّمَ الْأَبَرّ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي\nلِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', ['مَعَ أَنَّهُ ذَا صِلَةٍ وَرَحِمِ', 'قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ', 'سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَرْبَعَ عَشْرَةَ سَنَةً أَتَمَّهَا', ['وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا', 'وَرَبُّنَا قَدْ أَخَذَ الْمِيثَاقَا', 'وَقالَ البَعْضُ إِنَّها تَأْويلُها'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بْنُ رَبِيعَةَ وَالْكُلُّ رَغِبَهْ', ['يَجْمَعُهُمْ في كُلِّ يَوْمِ جُمُعَةِ', 'حَتَّى آتَاهُ اللَّهُ بَعْدَ عَشَرَةْ', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', ['لِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ', 'وَهَكَذَا قَدْ كَانَ سَيِّدَ الْأُمَمْ', 'تَعَاهَدُوا لِنُصْرَةِ الْمَظْلُومِ', 'فِي شَهْرِ شَوَّالَ الَّذِي مِنْ عَامِهِمْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَاقْتَتَلُوا أَرْبَعَةَ ........', ['أَحَداً', 'حَاكِمًا', 'مُعَظَّماً', 'أَيَّامَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', ['ذِئْبٌ فَصِيحٌ بِالْكَلَامِ عَبَّرَا', 'أَرْبَعَ عَشْرَةَ سَنَةً أَتَمَّهَا', 'وَصَوْتُهُ نورٌ إِذا ما نَطَقا', 'وَأَنَّ رَبَّ الْعَرْشِ أَعْلَى ذِكْرَهَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِيَقُمْ هُنَا ........ يَضْرِبْنِي', ['بَيْتِهِ', 'بِإِذْنِهِ', 'بِالْهِجْرَةِ', 'بِسَيْفِهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا\nأَرْبَعَ عَشْرَةَ سَنَةً أَتَمَّهَا', ['أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى', 'سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'حِينَ دَعَا لَهُ النَّبِيُّ الهَادِي', 'وَأَخبَرُوهُ عَن مَكَانِ المُصطَفَى'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَدَعَا الزُّبَيْرُ عَمُّ الْمُصْطَفَى إِلَى\nحِلْفِ الْفُضُولِ قَوْمُهُ وَأَقْبَلَا', ['كانَ جَميعاً حُنَفاءَ دينُهُمْ', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ', 'حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَعَاهَدُوا لِنُصْرَةِ الْمَظْلُومِ', ['مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'وَعِنْدَ نُقْرَةِ الْغُرَابِ الْأَعْصَمِ', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'عَاشَتْ عَلَى تَوَاصُلِ الْأَرْحَامِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ', ['حَتَّى أَتَاهُ الْإِذْنُ بِالْجَهْرِيَّة', 'مَلائِكُ الرَّحْمنِ يَحْفَظونَهُ', 'كَذَا نَبِيُّ الرَّحْمَةِ وَالْمَلْحَمَة', 'ضَرَبَهُ قَطَعَ لِرُكْبَتِهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَاقْتَتَلُوا أَرْبَعَةَ أَيَّامَا\nوَكَانَ فِيهَا الْمُصْطَفَى غُلَامَا', ['مَكَانُهُ مَا بَيْنَ فَرْثٍ وَدَمِ', 'أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'يَعِظْهُمُ فيهِ كَذا يُخْبِرُهُمْ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حِلْفِ الْفُضُولِ قَوْمُهُ وَأَقْبَلَا', ['هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى', 'مَرَّ عَلَيْهِ الْمُصْطَفَى فِي الْوَادِي', 'حِينَ دَعَا لَهُ النَّبِيُّ الهَادِي', 'وَدَعَا الزُّبَيْرُ عَمُّ الْمُصْطَفَى إِلَى'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَتَى إِلَى عُكَاظَ بِافْتِخَارِ', ['سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَوْ غَابَ عَنْهُمُ ........ الْخُسْرُ', ['الرَّحْمنِ', 'يَكُونُ', 'صَفَّينِ', 'عَدْنَانُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بَدْرٌ هُوَ الْغِفَارِي', ['سَعْدَنَا', 'سِتّونا', 'سَرِيعًا', 'سَبَبُهَا'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَيْسَتْ عَلَى رُهْبَانِهِمْ خَفِيَّةً', ['هَذَا أَبُو بَكْرٍ وَمَنْ كَمِثْلِهِ', 'رَأَى عَلَامَاتٍ بَدَتْ جَلِيَّةً', 'يُعْرَفُ فِي قَوْمِهِ بِالْمُصَارَعَة', 'وَسُمِّيَ بِذَلِكَ لِأَنَّهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدًا يُقْتَلُ لَا يَعُودُ', ['فَعَمَّتِ الْأَفْرَاحُ فِي الْبِلَادِ', 'خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ', 'ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', 'وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَدَتْ عَلَى جَبِينِهِ ........', ['النَّسَائِمُ', 'رُهْبَانِهِمْ', 'أَوَّلُهُمْ', 'مُلْتَزَمْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا', ['وَأَكْمَلُوا طَرِيقَهُمْ جَمِيعًا', 'إِلْياسَ فَاسْتَجيبوا وَأَحِبّوا', 'خَيْرِ الْأَنَامِ أَحْمَدَ الَّذِي عَلَا', 'نَسْلُ النَّبِيِّ الْمُصْطَفَى وَنَبَتَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا', ['بِهِ عِيسَى لِقَوْمِهِ وَأَخْبَرَا', 'هَذَا النَّبِيَّ بِطَيْبَةَ مُبَشِّرَا', 'سَطَعَتْ تَفُوقُ الشَّمْسَ عِنْدَ ظُهُورِهَا', 'لِلْكَعْبَةِ كِسْوَتَها وَأَلْبَسا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ', ['وَرَأَى رُكَانَة سَيِّدَ الْأَسْيَادِ', 'مُحَذِّرًا لِلْكَافِرِ الْعَنِيدِ', 'مُحَمَّدًا يُقْتَلُ لَا يَعُودُ', 'عَمَّ السُّرُورُ أَرْضَهُمْ إِلَى الْأَبَد'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'رَاهِبُ بُصْرَى عَالِمًا كَبِيرًا', ['فَوَافَقُوا قَالُوا بِهِ رَضِينَا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'بِكَفِّهِ الشَّرِيفَةِ قَدْ مَسَّهَا', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَأَى ........ بَدَتْ جَلِيَّةً', ['نَالَتْ', 'الْبُشْرَيَات', 'عَلَامَاتٍ', 'جَاءَتْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَعَ اثْنَتَيْنِ مِنْ سِنِينَ ........', ['أَنْوارُ', 'الْأَكْبَرُ', 'الطَّاهِرَ', 'الْعُمْرِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِهِ عِيسَى لِقَوْمِهِ ........', ['وَلَمّا', 'وَأَخْبَرَا', 'وَهَكَذَا', 'وَرَعْيُهَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَكْمَلُوا طَرِيقَهُمْ ........', ['مُشْرِقا', 'جَمِيعًا', 'تَقَلَّبَا', 'رَحِيمًا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'رَأَى عَلَامَاتٍ بَدَتْ جَلِيَّةً\nلَيْسَتْ عَلَى رُهْبَانِهِمْ خَفِيَّةً', ['وَكانَ يُدْعى سَيِّدَ العَشيرَةِ', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى', 'فَإِنَّهُ الْمَذْكُورُ فِي الْكِتَابِ', 'لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَافَرَ الْمُخْتَارُ لِلتِّجَارَةِ\nلِلشَّامِ ثُمَّ عَادَ بِالْبِشَارَةِ', ['وَعَنِ ابنِ عَبّاسٍ رَوَى مَرْفوعا', 'سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَافَ ........ أَنْ يَرَى الْيَهُودُ', ['بِهَذَا', 'بَشَّرُوا', 'بَحِيرَا', 'بَشَّرَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَيْسَتْ عَلَى رُهْبَانِهِمْ ........', ['مَقَالَتَهُ', 'خَدِيجَةُ', 'أُختِهِ', 'خَفِيَّةً'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَافَرَ ........ لِلتِّجَارَةِ', ['الصُّخُورَ', 'الْمُخْتَارُ', 'الْكَرَّارُ', 'الطَّاهِرَ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِهِ عِيسَى لِقَوْمِهِ وَأَخْبَرَا', ['فَرِحَ أَبوهُ وَأَطْعَمَ الطَّعامَا', 'وَجاءَ في الحَديثِ لا تَسُبّوا', 'فَكَانَ دَوْمًا يَشْتَرِي مَنْ آمَنَا', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَاهِبُ بُصْرَى عَالِمًا ........', ['كَبِيرًا', 'كانوا', 'كِسْوَتَها', 'كَرِيمًا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ\nمُحَمَّدًا يُقْتَلُ لَا يَعُودُ', ['اللهُ يا مُحَمَّدٌ يَقولُ لَكَ', 'وَقِيلَ بَلْ يُنَاوِلُ السِّهَامَا', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ ذَاكَ فِي ........ عَشْرِ', ['تَمَامِ', 'الْخَاتَمُ', 'يَعِظْهُمُ', 'الْعَظِيمِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'رَأَى عَلَامَاتٍ بَدَتْ جَلِيَّةً', ['وَشَرِبَتْ لِلنُّورِ مِنْ مَعِينِهِ', 'لِكَيْ تَكُونَ بِهِمُ فِي مَنعَةِ', 'لَيْسَتْ عَلَى رُهْبَانِهِمْ خَفِيَّةً', 'وَقَدْ تَسَمّى بِيَوْمِ العَرُوبَةِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمَّا ........ بِجَمْعِهِمْ بَحِيرَا', ['إِلَهِنَا', 'آمَنَا', 'مِنْهَا', 'أَتَوْا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا\nوَأَكْمَلُوا طَرِيقَهُمْ جَمِيعًا', ['وَكَانَ ذَاكَ فِي تَمَامِ عَشْرِ', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', 'وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِنَعْتِهِ الْآخِذِ ........', ['بِسِهَامِهِ', 'بِالْقُلُوبِ', 'بِالْأَلْبَابِ', 'بِالحَبيبِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا\nرَاهِبُ بُصْرَى عَالِمًا كَبِيرًا', ['كَانَ مِنْ قَبْلِ بَعْثَتِي يُسَلِّمُ', 'قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ', 'دَعَاهُمُ الصِّدِّيقُ لِلْإِيمَانِ', 'فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ عَمَّهُ بِأَنْ يَعُودَا', ['وَاتَّقَى', 'وَأَوْصَى', 'وَالْجَلِي', 'وَعِيسَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ عَمُّهُ بِهِ سَرِيعًا', ['فَعَادَ', 'فُؤَادِ', 'فَأَرَادَ', 'فَأَسْعَدِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا\nبِهِ عِيسَى لِقَوْمِهِ وَأَخْبَرَا', ['قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'وَلَمْ أَجِدْ كَمِثْلِهِ فِي النَّسَبِ', 'النُّورُ يَسْرِي مِنْ أَبِيهِ آدَمَا', 'رَأَى عَلَامَاتٍ بَدَتْ جَلِيَّةً'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِهِ سَرِيعًا وَلْيَكُنْ ........', ['سَعِيدًا', 'سَلَّطا', 'سَبَبُهَا', 'سَعِدَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَإِنَّهُ هُوَ الَّذِي قَدْ ........', ['بِلَالَا', 'بِرَبِّهَا', 'بَشَّرُوا', 'بَشَّرَا'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَفَائِهِ لَهَا وَمَا تَحَوَّلَا', ['وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى', 'مِنْ بَعْدِ مَوْتِ بُخْتُنَصَّرَ أَتى', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي أَنْ يَكُونَ ........ فَغَنِمَتْ', ['نوراً', 'مُتَيَّمًا', 'زَوْجَهَا', 'ذَهَبَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُدَافِعًا عَنْهَا وَعَنْ وَفَائِهَا\nهِيَ الَّتِي أَسْدَتْ لَهُ عَطَاءَهَا', ['في شَأْنِ آباءِ النَّبِيِّ نَقَلوا', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ', 'وَصَدَّقَتْهُ آمَنَتْ بِدِينِهِ', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَزَيْنَبُ رُقَيَّةُ وَفَاطِمَة', ['وَأُمُّ كُلْثُومٍ فَتِلْكَ الْخَاتِمَة', 'يَأْمُرُهُمْ حَثّاً عَلى اتِّباعِهِ', 'وَهْوَ ابْنُ عَمِّهَا أَيْضًا فَصَدَّقَهْ', 'وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي مَكَّةَ مُصَدَّقًا أَمِينًا', ['مُبَشِّرًا مَنْ صَدَّقُوا وَآمَنُوا', 'وَجاءَ أَنَّ اللهَ لَمّا سَلَّطا', 'وَبَعْدَ مَا قَدْ أَكْمَلَ الْعِشْرِينَا', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ', ['وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ', 'في قَوْمِهِ ذو عِزَّةٍ كَبيرَةِ', 'وَشَرِبَتْ لِلنُّورِ مِنْ مَعِينِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَازَتْ بِهِ بِنْتُ ........ فَمَا', ['أَوْلَادُ', 'خُوَيْلِدٍ', 'مِيلَادُ', 'الْعِبَادِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ', ['وَكُنْتُ أَسْتَظِلُّ تَحْتَ شَجَرَةٍ', 'نَبِيَّنَا فَنَالَتِ الْمَزِيَّة', 'وَلَمْ يَجِدْ مِنْ دَمْعَةٍ رَحِيمَة', 'خَمْسًا وَعِشْرِينَ أَتَتْ مِنْ أَمْرِهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأُمُّ كُلْثُومٍ ........ الْخَاتِمَة', ['فَتِلْكَ', 'فَذَاكَ', 'فَرِيدٌ', 'فَرُمَوْا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', ['أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ', 'وَشَرِبُوا مِنْهَا إِذًا وَعَادَتْ', 'فَأَيْقَنُوا بِالْمَوْتِ لَكِنْ نَبَعَتْ', 'أَخْبَرَهَا عَمَّا رَأَى فَرَغِبَتْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ وَعِشْرِينَ أَتَتْ مِنْ أَمْرِهِ', ['أَيَّامَا', 'تَقِيًّا', 'رَبَّنا', 'خَمْسًا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَخْبَرَهَا عَمَّا رَأَى فَرَغِبَتْ\nفِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', ['وَآمَنَتْ مِنَ النِّسَاءِ أَوَّلًا', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ', 'وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا', 'أَكْرَمَهُمْ فِي أَرْضِهِ إِكْرَامَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خَمْسًا وَعِشْرِينَ أَتَتْ مِنْ أَمْرِهِ', ['وَآلِهِ جَمِيعِهِمْ وَصَحْبِهِ', 'وَسَافَرَتْ بِهِ إِلَى الْمَدِينَة', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُدَافِعًا عَنْهَا وَعَنْ ........', ['وَفَائِهَا', 'وَمُخْلِصًا', 'وَقَائِدًا', 'وَهَكَذَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أُمُّ الْبَتُولِ الطَّاهِرَةْ ........', ['الْحَيَاةِ', 'الْحَبِيبَةِ', 'ذَهَبِيَّةٌ', 'يُبْعِدَهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَخْبَرَهَا عَمَّا رَأَى فَرَغِبَتْ', ['بِأُمِّ خَيْرِ الْخَلْقِ قَدْ تَنَوَّرَتْ', 'الْمُرْشِدَاتِ لِلْهُدَى وَالظَّاهِرَاتِ', 'فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', 'وَبِأَمْرِهِ مِنْ بَعْدِ ذَاكَ رَجَعَتْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا', ['لَمْ يَخْشَ فِي قَوْلِ الْهُدَى الْأَنَامَا', 'لِلْكَعْبَةِ كِسْوَتَها وَأَلْبَسا', 'لَا بُدَّ مِنْ تَأْدِيبِهِ تَوَقِّيَا', 'أَسْعَدَهَا بِأَحْمَدَ الْمُعَظَّمَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ هَذَا فِي تَمَامِ ........', ['جِوَارَهُ', 'الدَّعْوَةِ', 'جَانِبَيهِ', 'عُمُرِهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', ['أَلْقَى عَلَيْهِمْ هَذِهِ الْحِجَارَةْ', 'هِيَ أَصْلُ تِلْكَ الشَّجَرَةِ الْعَجِيبَةِ', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', 'وَحَالَ بَيْنَهُ وَبَيْنَ غَنَمِهْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَفَائِهِ لَهَا وَمَا ........', ['مُصَدَّقًا', 'تَحَوَّلَا', 'أَخْلُقْهُما', 'يَنْطِقُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِخَدِيجَةَ مُتَاجِرًا فِي الشَّامِ', ['سَارَ مَعَ مَيْسَرَةَ الْغُلَامِ', 'مَعَ أَنَّهُ ذَا صِلَةٍ وَرَحِمِ', 'لِأَنَّهَا هِيَ أَصْعَبُ الْبَهَائِم', 'كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هِيَ أَصْلُ تِلْكَ الشَّجَرَةِ ........', ['الْمُطَهَّرَة', 'الْهِجْرَةِ', 'الْكَامِنَة', 'الْعَجِيبَةِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَسْعَدَهَا بِأَحْمَدَ ........', ['قَالُوا', 'الْمُعَظَّمَا', 'ضَرَبَهَا', 'السِّهَامَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رُزِقْتُ ........ بِكُلِّ لِينٍ', ['حُبَّهَا', 'أَيُّهَا', 'تَنالوا', 'مُتَيَّمًا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَارَ مَعَ مَيْسَرَةَ الْغُلَامِ', ['عَلَيَّ دَوْمًا نَاطِقًا يَتَكَلَّمُ', 'لِخَدِيجَةَ مُتَاجِرًا فِي الشَّامِ', 'تَعَاهَدُوا لِنُصْرَةِ الْمَظْلُومِ', 'خُلُقَ السَّكِينَةِ وَالْوَقَارِ مُلْتَزَمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا\nأَحْبَابَهَا لِأَجْلِهَا مُعَظَّمَا', ['وَلَمْ يَكُنْ في نَسَبي سِفاحُ', 'يَعِظْهُمُ فيهِ كَذا يُخْبِرُهُمْ', 'وَلَمْ يَزَلْ يَقُولُ كُلَّ حِينٍ', 'عَاشَتْ عَلَى تَوَاصُلِ الْأَرْحَامِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَزَيْنَبُ رُقَيَّةُ ........', ['وَفَاطِمَة', 'وَصَحْبِهِ', 'وَالْمَلْحَمَة', 'وَرِعَايَةُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'سَارَ مَعَ ........ الْغُلَامِ', ['مَيْسَرَةَ', 'زِيادَةُ', 'جِوَارَهُ', 'السَّعْدِيَّة'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبِالْبَنَاتِ ثُمَّ بِالْأَحْفَادِ', ['فَعَمَّتِ الْأَفْرَاحُ فِي الْبِلَادِ', 'ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', 'أَكْرَمَهَا الرَّحْمَنُ بِالْأَوْلَادِ', 'مِنْ بَعْدِ ضِيقٍ فِي الْحَيَاةِ وَنَكَد'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَشَرِبَتْ لِلنُّورِ مِنْ ........', ['خَفِيَّةً', 'اللَّهُ', 'يُصَارِعَهْ', 'مَعِينِهِ'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ', ['مَنَعَ الشَّيَاطِينَ اسْتِرَاقَ السَّمْعِ', 'وَانْتَشَرَتْ فِي سَائِرِ الْبِقَاعْ', 'مِنْ طَيْبَةَ لِدِينِ طَهَ مُتَّبِعْ', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَوَافَقُوا قَالُوا بِهِ رَضِينَا', ['قَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا', 'لَا بُدَّ مِنْ تَأْدِيبِهِ تَوَقِّيَا', 'ابْنُ مَظْعُونٍ أَعْلَنُوا الْإِيمَانَا', 'مُحَمَّدًا حَبِيبَنَا الْأَمِينَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ', ['في قَوْمِهِ ذو عِزَّةٍ كَبيرَةِ', 'حَبِيبُهُ الْفَرْدُ الَّذِي رَآهُ', 'أَعْتَقَهُ أَيْضًا كَذَا زَنِيرَةَ', 'لِمَا لَهُ مِنْ شَرَفٍ يَكْفِيهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خَمْسٌ وَثَلَاثُونَ كَانَ حِينَهَا', ['حَتّى كَتَبْتُ لا إِلهَ إِلّا', 'وَجَا بِنَاءُ كَعْبَةٍ مِنْ بَعْدِهَا', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'أَمَرَ اللهُ أرْمِياءَ كانا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'تَعْلُو عَلَى الْجَبِينِ فِي ........', ['النُّورَ', 'الْغَفَّارِ', 'عَمَّارْ', 'النَّهَارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَبِيبُهُ الْفَرْدُ ........ رَآهُ', ['النَّبِيَّ', 'الَّذِي', 'الْهَادِي', 'يَنْهى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ ........', ['مَوْضِعٌ', 'الشُّروعِ', 'يَرْفَعُ', 'الرَّبِيعُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَعَمَّتِ الْأَفْرَاحُ وَالسَّلَامُ', ['وَزَالَ مِنْ بَيْنِهِمُ الْخِصَامُ', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَمْسٌ وَثَلَاثُونَ كَانَ ........', ['أَعلَنَا', 'ذِئْبًا', 'حِينَهَا', 'صَدَّقُوا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ', ['الطَّيْرُ وَالْوُحُوشُ وَالسِّبَاعْ', 'وَجَدُّهُ إِلْياسُ كانَ يَسْمَعُ', 'حَمَى لَهُ غَنَمَهُ حَتَّى رَجَعْ', 'تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَمَّدًا ........ الْأَمِينَا', ['حَبِيبَنَا', 'طَائِفًا', 'الْخَلْقَا', 'مُعَظَّماً'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَنْتَ خَيْرُ ........ يَا طَبِيبِي', ['تَفُوقُ', 'التَّوفِيقُ', 'الْخَلْقِ', 'صَادِقٌ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَاتَّفَقُوا عَلَى الَّذِي سَيَدْخُلُ', ['يَدْعو إِلى اتِّباعِهِ يَقولْ', 'لِلْبَيْتِ طَائِفًا يَكُونُ الْفَاعِلُ', 'الصّادِقِ الطّاهِرِ وَالبَرِّ النَّبيل', 'يَقْصِدُ بَيْتَ اللَّهِ بِالتَّنْكِيلِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَا ........ كَعْبَةٍ مِنْ بَعْدِهَا', ['بِمَكَّةَ', 'بُصْرَى', 'بِنَاءُ', 'بَعْدَهُمْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', ['قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ', 'فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ', 'وَبَعْدَهُمْ مُصْعَبٌ وَالزُّبَيْرُ', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي\nفَأَنْتَ خَيْرُ الْخَلْقِ يَا طَبِيبِي', ['وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ', 'أَعْظَمُهَا قَدْرًا هُوَ الْقُرْآنُ', 'مَضَى إِلَى سَبِيلِهِ كَرِيمًا', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَا بِنَاءُ كَعْبَةٍ مِنْ بَعْدِهَا', ['لِلْبَيْتِ مِنْ أَهْلِ الْقُرَى قَدْ ثَبَتَا', 'إِلْياسَ فَاسْتَجيبوا وَأَحِبّوا', 'وَكَانَ دَوْمًا لِلنَّبِيِّ مُصَدِّقَا', 'خَمْسٌ وَثَلَاثُونَ كَانَ حِينَهَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ', ['مِن جَانِبَيهِ مَعَهُمَا يَسِيرُ', 'لَكِنَّهُ بِدِينِهِ بَصِيرُ', 'تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', 'نَبِيَّنَا وَحَمْزَةَ الْعَمَّ الْأَبَر'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ عَلَى الَّذِي سَيَدْخُلُ', ['وَكامِلاً', 'وَاتَّفَقُوا', 'وَسَهْلَا', 'وَنَبَتَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ\nالْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ', ['وَاتَّفَقُوا عَلَى الَّذِي سَيَدْخُلُ', 'خَوْفًا عَلَى إِيمَانِهِمْ مِنْ قَوْمِهِمْ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', 'طَرَقَ البَابَ لَم يَقُم مِنهُم أَحَد'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْبَيْتِ طَائِفًا يَكُونُ الْفَاعِلُ', ['وَرَعْيُهَا لِلْأَنْبِيَا كَمَالُ', 'وَاتَّفَقُوا عَلَى الَّذِي سَيَدْخُلُ', 'سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ', 'بِمَوْتِهِ دَوْماً لِعامِ الفيلِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَقْبَلَ الْحَبِيبُ ........', ['بِالْأَنْوَارِ', 'بِافْتِخَارِ', 'بِالنُّورِ', 'بُخْتُنَصَّرْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَبِيبُهُ الْفَرْدُ الَّذِي رَآهُ', ['وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة', 'عَاشَتْ بِهِ فِي عِيشَةٍ هَنِيَّةٍ', 'وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَمَّدًا حَبِيبَنَا الْأَمِينَا', ['فَوَافَقُوا قَالُوا بِهِ رَضِينَا', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', 'هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', 'قَالَتْ قُرَيْشٌ إِنَّهَا مِنْ حَقِّنَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِلْبَيْتِ طَائِفًا يَكُونُ ........', ['الْمَقْبُولُ', 'جَمِيل', 'الْفَاعِلُ', 'يَقُولُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'تَنَازَعَ ........ فِيمَنْ سَيَضَعُ', ['الْفِرْدَوْسِ', 'إِفلَاسِ', 'الشَّمْسَ', 'النَّاسُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَأَنْتَ خَيْرُ الْخَلْقِ يَا طَبِيبِي', ['كَمَا أَتَى وَحْيٌ وَنَصٌّ قَطْعِيْ', 'إِنْ كَانَتِ الْأَقْدَاحُ قَدْ خَرَجَتْ عَلَى', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي', 'وَبَعْدَهُمْ عَدْنَانُ ذَاكَ يَنْتَمِي'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَنْتَ عَبْدُاللَّهِ ........', ['أَرْبَعَةَ', 'مُصْطَفَاهُ', 'الْمَرْضِيَّة', 'زِيَادَةِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَوَافَقُوا قَالُوا بِهِ رَضِينَا\nمُحَمَّدًا حَبِيبَنَا الْأَمِينَا', ['وَغَيْرُهُمْ أَيْضًا كَثِيرٌ آمَنُوا', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'أَكْرَمَهَا الرَّحْمَنُ بِالْأَوْلَادِ', 'وَزَالَ مِنْ بَيْنِهِمُ الْخِصَامُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَمَّتِ الْأَفْرَاحُ ........', ['وَالسَّلَامُ', 'وَغَيْرُهُمْ', 'وَجَيْشُهُمْ', 'وَيَشْتَرِيهِمْ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمِنْ فُؤَادِ الْمُصْطَفَى ........', ['أَمسَكَه', 'جَبِينِهِ', 'قَرِيبَةُ', 'مُدْرِكَةُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَهْوَ ابْنُ عَمِّهَا أَيْضًا فَصَدَّقَهْ', ['وَكانَ يُدْعى سَيِّدَ العَشيرَةِ', 'وَبَعْدَ ذَا فَهَذِهِ أَلْفِيَّةْ', 'وَأَرْضَعَتْ حَلِيمَةُ السَّعْدِيَّة', 'سَارَتْ بِهِ تَقْصِدُ بَيْتَ وَرَقَةْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', ['لِلَّهِ فِيهِ دَائِمًا وَشَاهِدًا', 'وَلِأَجْلِ هَذا الدّينِ ماذا عَمِلوا', 'وَدُفِنَتْ عَائِدَةً بِقُرْبِهَا', 'أُمًّا لِخَيْرِ خَلْقِهِ الْأَمِينَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقِيلَ بَلْ يَا أَيُّهَا الْمُدَّثِّرُ\nوَقِيلَ بَلْ فَاتِحَةٌ ذَا يُذْكَرُ', ['يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ', 'كَمَا أَتَى فِي آلِ عِمْرَانَ وَإِذْ', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنَ اللَّهِ الْعَظِيمِ بِالْوَحْيِ ........', ['الْمُعْتَدِين', 'الْمُبِين', 'المَكانِ', 'أَعْلَنَ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَإِنَّهَا خَدِيجَةُ الْحَبِيبَةُ', ['وَمِنْ فُؤَادِ الْمُصْطَفَى قَرِيبَةُ', 'ثَلَاثَ عَشْرَ مُنْذُ وَقْتِ الْبَعْثَة', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ حَذَّرُوهُ', 'وَالتَّابِعِينَ كُلِّهِمْ وَحِزْبِهِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنَ اللَّهِ الْعَظِيمِ بِالْوَحْيِ الْمُبِين', ['فَبِها تَكونُ زِيادَةُ الإيمانِ', 'فِي السَّنَةِ السَّادِسَةِ لِلدِّينِ', 'وَكانَ خَيْرَ أَهْلِ ذا الزَّمانِ', 'وَجَاءَهُ جِبْرِيلُ عِنْدَ الْأَرْبَعِين'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بَلْ يَا أَيُّهَا الْمُدَّثِّرُ', ['وَقِيلَ', 'وَأَوَّلُ', 'وَزَالَ', 'وَيَأْكُلُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ لَهُ اقْرَأْ أَيُّهَا النَّبِيُّ\nأَجَابَ كَلَّا إِنَّنِي أُمِّيُّ', ['كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ', 'ثَلَاثَ مَرَّاتٍ يَقُولُ مَا أَنَا', 'فَأَرْضَعَتْ ثُوَيْبَةُ وَقْتَ الصِّغَر', 'قَدْ أَشْرَقَ الرَّبِيعُ بِالْأَنْوَارِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ ........', ['الْأَطْهَارِ', 'النُّورُ', 'الْمُطَهَّرُ', 'السُّوَرْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَشَّرَ ........ أَنَّ هَذَا مَا', ['النَّبِيَّ', 'تَكْفِي', 'الْمُصْطَفَى', 'أَدْنَى'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَدْ تَمَنَّى حِينَهَا الْحُضُورَا\nلِكَيْ يَكُونَ لِلنَّبِيْ نَصِيرَا', ['يُكْرِمُ طَهَ غَايَةَ التَّكْرِيمِ', 'نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'إِذَا دَعَا الْكُفَّارَ لِلْإِيمَانِ', 'يُعْرَفُ فِي قَوْمِهِ بِالْمُصَارَعَة'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'اقْرَأْ بِإسْمِ رَبِّكَ الَّذِي خَلَقْ\nالْأَكْرَمَ كَمَا قَدْ جَاءَ فِي الْعَلَقْ', ['نَبِيُّنَا وَإسْمُهُ مُحَمَّدٌ', 'وَمَاتَ عَبْدُاللَّهِ قَبْلَ أَنْ يَرَى', 'مَنْ عَلَّمَ الْإِنْسَانَ مَا لَمْ يَعْلَمِ', 'أَبُوهُ عَبْدُاللَّهِ عَبْدُالْمُطَّلِبْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقَدْ تَمَنَّى ........ الْحُضُورَا', ['تَشَرَّفَا', 'عَادُوا', 'طَيِّبا', 'حِينَهَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا\nأَتَاهُ وَحْيُ اللَّهِ حَقًّا مُنَعِمَا', ['قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ', 'وَقَدْ تَمَنَّى حِينَهَا الْحُضُورَا', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى', 'وَحَاوَلَتْ قُرَيْشٌ أَخْذَ الْمُصْطَفَى'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ', ['وَكُنْتُ أَسْتَظِلُّ تَحْتَ شَجَرَةٍ', 'يَقُصُّ مَا رَأَى عَلَى زَوْجَتِهِ', 'أَحَدٌ الْمَوْلَى بِلَا زِيَادَةِ', 'وَجَيْشُهُمْ فِيهَا لَقِي دَمَارَهْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'سَارَتْ بِهِ تَقْصِدُ بَيْتَ ........', ['وَهَزَّهُ', 'وَرَقَةْ', 'وَخُزَيْمَةُ', 'وَجَاءَهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلَّهِ فِيهِ دَائِمًا وَشَاهِدًا', ['وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', 'فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَارَتْ بِهِ تَقْصِدُ بَيْتَ وَرَقَةْ', ['الْحَارِثُ الْأَكْبَرُ إِذْ سَيُسَاعِدُه', 'وَهْوَ ابْنُ عَمِّهَا أَيْضًا فَصَدَّقَهْ', 'وَحَدَّثَ النَّبِيَّ بِالْحِكَايَةِ', 'وَأُمُّ كُلْثُومٍ فَتِلْكَ الْخَاتِمَة'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَهُ جِبْرِيلُ عِنْدَ الْأَرْبَعِين\nمِنَ اللَّهِ الْعَظِيمِ بِالْوَحْيِ الْمُبِين', ['وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَإِنَّهَا خَدِيجَةُ ........', ['الْهِجْرَةِ', 'عَبْدُاللَّهِ', 'الْحَبِيبَةُ', 'النَّبَوِيَّةْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', ['أَتَاهُ وَحْيُ اللَّهِ حَقًّا مُنَعِمَا', 'فَاتَّبِعوهُ كَيْ تَنالوا الرَّشَدا', 'كَادَتْ بِهَذَا أَنْ تَكُونَ حَرْبَا', 'فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِذَا دَعَا ........ لِلْإِيمَانِ', ['السُّرُورُ', 'الْمَفَاخِرِ', 'الْغَفَّارِ', 'الْكُفَّارَ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِكَيْ يَكُونَ لِلنَّبِيْ نَصِيرَا', ['لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'وَلَمّا وُلِدَ نِزارُ سَطَعا', 'وَقَدْ تَمَنَّى حِينَهَا الْحُضُورَا', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ\nحَيْثُ النُّزُولُ ذَاكَ الرَّأْيُ الْمُعْتَبَرْ', ['كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ', 'وَقِيلَ بَلْ يَا أَيُّهَا الْمُدَّثِّرُ', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', ['فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'أَوَّلُهُمْ رُقَيَّةُ وَزَوْجُهَا', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا', 'ثَلَاثَ مَرَّاتٍ يَقُولُ مَا أَنَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'إِذَا دَعَا الْكُفَّارَ لِلْإِيمَانِ', ['وَأَخْرَجُوهُ مِنْ حِمَى الْأَوْطَانِ', 'مِن بَعدِ حَمزَةَ عَلَى اليَقِينِ', 'يَبْنِي بِهَا فَأَبَى الشَّرِيفُ الْمُؤْتَمَنْ', 'وَلَدٍ يُسَاعِدُهُ عَلَى عَيْشِ الزَّمَن'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ثَلَاثَ مَرَّاتٍ يَقُولُ مَا أَنَا', ['بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', 'نَسْلُ النَّبِيِّ الْمُصْطَفَى وَنَبَتَا', 'مِنْ قَبْلِ كُلِّ النّاسِ كانَ مُؤْمِنا', 'وَأَنَّ رَبَّ الْعَرْشِ أَعْلَى ذِكْرَهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَيْثُ النُّزُولُ ذَاكَ الرَّأْيُ الْمُعْتَبَرْ', ['وَلَيْسَ هَذَا مِنْ كَلَامِ الْبَشَر', 'قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ', 'وَغَيْرُهَا مِنْ قَوْمِهِ الْكَثِيرُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِقَارِئٍ لَكِنَّ ........ أَذِنَا', ['اللَّهُ', 'أَتَاهُ', 'غَنِيَّةٍ', 'أَعْتَقَهُ'], 0),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَدْعُو إِلَى التَّوْحِيدِ وَالْإِسْلَامِ', ['فِي هِمَّةٍ لِدَعْوَةِ الْأَنَامِ', 'وَبَارَكَ اللَّهُ بِهِ فِي عَيْشِهِمْ', 'الشَّاهِدُ النُّورُ الْمُبَشِّرُ الْكَرِيمُ', 'ثَلَاثَةً كَمُلَتْ عَلَى التَّمَامِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَيْضًا كَثِيرٌ آمَنُوا', ['وَخَلَقْتُهُمْ', 'وَمِنْهُمْ', 'وَغَيْرُهُمْ', 'وَزَمْزَمُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَفِي الْهِجْرَةِ وَالْغَارِ ........', ['أَعْتِقُ', 'الْخَلْقِ', 'الرَّفِيقُ', 'الطَّرِيقِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَزَيْدُ بْنُ حَارِثَةَ مَوْلَاهُ', ['آمَنَ بِالنَّبِيِّ إِذْ رَآهُ', 'وَجَيْشُهُمْ فِيهَا لَقِي دَمَارَهْ', 'وَحَدَّثَ النَّبِيَّ بِالْحِكَايَةِ', 'لِيَنْتَهِيَ عَنْ دِينِهِ وَأَمْرِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَلِيٌّ ........ ذُو الْإِقْدَامِ', ['النَّظَرْ', 'الْغَفَّارِ', 'الْكَرَّارُ', 'نِزَارِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يَدْعُو إِلَى التَّوْحِيدِ وَالْإِسْلَامِ\nفِي هِمَّةٍ لِدَعْوَةِ الْأَنَامِ', ['يَقُولُ إِنَّ لِابْنِي هَذَا شَانَا', 'وَشَاوَرَ النَّبِيَّ حَتَّى يَخرُجُوا', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'يَخْشَى عَلَيْهِمْ مِنْ عَذَابِ اللَّهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'سُمَيَّةُ وَابْنُهَا ........', ['الطّاهِرِ', 'عَمَّارْ', 'الْأَبَر', 'يُظْهِرُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَذَا ابْنُ عَوْفٍ ........ مِنْ بَعْدُ', ['أَكْمَلا', 'آمَنُوا', 'زَوْجَهَا', 'جَمِيعًا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'آمَنَ ........ إِذْ رَآهُ', ['بُصْرَى', 'بِالْمُصْطَفَى', 'بِالْوَحْيِ', 'بِالنَّبِيِّ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْهُمْ كَانَ ابْنُ مَسْعُودٍ وَأَسْلَمَا\nلَمَّا رَأَى مُعْجِزَةً وَعَلِمَا', ['لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا', 'وَكانَ جَدُّ المُصْطَفى كِنانَة', 'فَأَجَابَهُ الصِّدِّيقُ إِنِّي إِنَّمَا', 'سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَجْتَمِعُونَ كُلُّهُمْ أَحْبَابُ', ['فِي دَارِ أَرْقَمٍ كَانَ الْأَصْحَابُ', 'وَغَيْرُهُ كَانَ إِلَيْهِمْ يَذْهَبُ', 'عَنْ سائِرِ الخَلْقِ قُرَيْشاً وَالعَرَبْ', 'وَجَدُهُ الشَّرِيفُ عَبْدُ الْمُطَّلِب'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ\nوَفِي الْهِجْرَةِ وَالْغَارِ الرَّفِيقُ', ['بِسْمِ الْكَرِيمِ الْوَاهِبِ الْمَنَّانِ', 'مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'وَآمَنَتْ مِنَ النِّسَاءِ أَوَّلًا', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثَلَاثَ عَشْرَ مُنْذُ وَقْتِ الْبَعْثَة', ['وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة', 'هَذَا أَبُو بَكْرٍ وَمَنْ كَمِثْلِهِ', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ', 'عَبْدُ مَنَافٍ جَدُّهَا وَزُهْرَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمِنْ ظَلَامِ الْكُفْرِ ........', ['وَيَنْبَغي', 'وَالْبَيْهَقِيُّ', 'وَالنَّبِيُّ', 'وَالنَّوَاهِي'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَدِيجَةُ زَوْجَتُهُ إِذْ ........', ['أَعلَنَا', 'حَبِيبَنَا', 'أَقْبَلَا', 'تَوَقِّيَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ الزُّبَيْرُ طَلْحَةُ ........', ['وَلَقَدْ', 'وَعادَ', 'وَزَيْدُ', 'وَسَعْدُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَفِي الْهِجْرَةِ وَالْغَارِ الرَّفِيقُ', ['سَمَّيْتُهَا بِرَوْضَةِ الْعُشَّاقِ', 'اقْرَأْ بِإسْمِ رَبِّكَ الَّذِي خَلَقْ', 'يَدْعو إِلى البِرِّ وَلِلْأَخْلاقِ', 'هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الصِّدِّيقُ لِلْإِيمَانِ', ['يَأْمُرُهُمْ', 'دَعَاهُمُ', 'أَكْرِمْ', 'قَوْمَهُمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا', ['بِهِ عِيسَى لِقَوْمِهِ وَأَخْبَرَا', 'هَذَا النَّبِيَّ بِطَيْبَةَ مُبَشِّرَا', 'لَبَنُهَا قَالَ أَنَا أَمِينُهَا', 'وَقَدْ رَأَى مَيْسَرَةُ الْعَجَائِبَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يَخْشَى عَلَيْهِمْ مِنْ عَذَابِ اللَّهِ\nوَمِنْ ظَلَامِ الْكُفْرِ وَالنَّوَاهِي', ['وَأَوَّلُ مَنْ آمَنَ مِنَ الرِّجَالْ', 'ظَنُّوا بِأَنَّ قَوْمَهُمْ قَدْ آمَنُوا', 'بِهِ جَمِيعُ الْأَنْبِيَاءِ بَشَّرُوا', 'فَرُمَوْا بِالنُّجُومِ وَالشِّهَابِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَزَيْدُ بْنُ حَارِثَةَ مَوْلَاهُ\nآمَنَ بِالنَّبِيِّ إِذْ رَآهُ', ['ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', 'جَعَلْتُهُ الخَليلَ لكِنْ أَنْتَ يا', 'وَغَيْرُهُ أَيْضًا مِنَ الْأَصْحَابِ', 'فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَشَرِبُوا مِنْهَا إِذًا وَعَادَتْ\nبِأَمْرِهِ لِمَا عَلَيْهِ كَانَتْ', ['عَنِ الحَبيبِ سَيِّدِ المِلاحِ', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'إِنْ كَانَتِ الْأَقْدَاحُ قَدْ خَرَجَتْ عَلَى', 'يَخْرُجُ فِي وَقْتِ كَذَا عَنْ وَقْتِهِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَقْبَلُوا بِخَالِصِ ........', ['الْإِذْعَانِ', 'الرَّحْمنِ', 'اثْنَانِ', 'الصِّبْيَانِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', ['فَسَأَلَ المَوْلى وَمَنْ مُحَمَّدُ', 'لِمَا لَهُ مِن شِدَّةٍ مِثلَ الأَسَد', 'كَذَا ابْنُ عَوْفٍ آمَنُوا مِنْ بَعْدُ', 'حَادِثَةُ الْفِيلِ بِذِي الْبِلَادِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ابْنُ ........ أَعْلَنُوا الْإِيمَانَا', ['مَكانِ', 'مَظْعُونٍ', 'تَكونُ', 'الزَّمانِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْهُمْ كَانَ ابْنُ مَسْعُودٍ وَأَسْلَمَا', ['لَمْ يَخْشَ فِي قَوْلِ الْهُدَى الْأَنَامَا', 'لَمَّا رَأَى مُعْجِزَةً وَعَلِمَا', 'وَأَكْمَلُوا طَرِيقَهُمْ جَمِيعًا', 'وَعاشَ في دِيارِهِ وَثَبَتا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا\nلَبَنُهَا قَالَ أَنَا أَمِينُهَا', ['فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَغَيْرُهُمْ أَيْضًا كَثِيرٌ آمَنُوا\nعِنْدَ ابْتِدَاءِ الدَّعْوَةِ وَأَحْسَنُوا', ['وَجاءَ عَنْ سَلْمانَ الفارِسيِّ ما', 'مِنْهُمْ كَانَ ابْنُ مَسْعُودٍ وَأَسْلَمَا', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سُمَيَّةُ وَابْنُهَا عَمَّارْ', ['حَيْثُ النُّزُولُ ذَاكَ الرَّأْيُ الْمُعْتَبَرْ', 'كانَتْ تُرى بِوُجوهِهِمْ أَنْوارُ', 'وَقِيلَ بَلْ فَاتِحَةٌ ذَا يُذْكَرُ', 'وَزَوْجُهَا يَاسِرُ الْأَبْرَارْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عِنْدَ ابْتِدَاءِ الدَّعْوَةِ ........', ['وَسِيمًا', 'وَأَحْسَنُوا', 'وَابْنُهَا', 'وَهَرَبُوا'], 1),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُبَشِّرًا مَنْ ........ وَآمَنُوا', ['أَسْمَعُهَا', 'صَدَّقُوا', 'عَمِّهَا', 'يُهْلَكُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَالُوا أَخُونَا صَادِقٌ كَرِيمُ', ['مَا مِنْ نَبِيٍّ إِلَّا قَدْ رَعَى الْغَنَمْ', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فِيكُمُ', 'يَعِظْهُمُ فيهِ كَذا يُخْبِرُهُمْ', 'نَبِيُّنَا الْمُخْتَارُ مِنْ بَيْنِ الْأُمَمْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُعَادِيًا لِصَاحِبِ الْقُرْآنِ', ['وَهُوَ الَّذِي حَفَرَ زَمْزَمَ بَعْدَ أَنْ', 'وَلَمْ يَكُنْ لَهُ سِوَى الْحَارِثِ مِنْ', 'فَعَادَ لِلْكُفْرِ وَلِلْبُهْتَانِ', 'أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَدْ صَدَّقُوهُ ........ لَكِنْ', ['بِالحَبيبِ', 'بِالْأَلْبَابِ', 'بِالْقُلُوبِ', 'بِفَضْلِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ ثَلَاثٍ مِنَ ........', ['الْأَيَّامَا', 'نَاصِرًا', 'غُلَامَا', 'السِّنِينَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ ........', ['عَشْرَةَ', 'حَذَّرُوهُ', 'نَبِيَّهُ', 'جَانِبَيهِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ صَدَّقُوهُ بِالْقُلُوبِ لَكِنْ\nالشِّرْكُ وَالْعِنَادُ فِيهَا سَاكِنْ', ['هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى', 'عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', 'تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'قَالَ أَبُو الصِّدِّيقِ لِابْنِهِ أَبِي'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَمِنْهُمُ الْوَلِيدُ بْنُ ........', ['مَوْلِدُهُ', 'الْمُغِيرَة', 'عَبْدُاللَّهِ', 'أَبْرَهَةُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَالُوا ........ صَادِقٌ كَرِيمُ', ['يَذْبَحُوا', 'أَعْوَاما', 'أَخُونَا', 'رَسُولُنَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُحَذِّرًا لِلْكَافِرِ ........', ['الْعَنِيدِ', 'الْمَعْبُودِ', 'أَسْعَدَ', 'الرَّشَادِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الشِّرْكُ وَالْعِنَادُ فِيهَا سَاكِنْ', ['قَدْ صَدَّقُوهُ بِالْقُلُوبِ لَكِنْ', 'أَعْظَمُهَا قَدْرًا هُوَ الْقُرْآنُ', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ رَسُولُ اللَّهِ فِيهِ', ['الْأَكْرَمِ', 'الإِمامِ', 'تَحَدَّاهُمُ', 'الْأَتَمّ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فِيكُمُ\nقَالُوا أَخُونَا صَادِقٌ كَرِيمُ', ['يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ', 'يَعِظْهُمُ فيهِ كَذا يُخْبِرُهُمْ', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا', 'قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَكِنَّ قَوْمَهُ قَدْ أنذَرُوهُ', ['أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ حَذَّرُوهُ', 'فَهَمَّ أَنْ يُوفِي بِمَا قَدْ نَذَرَهْ', 'شَبَهُ وَزَيَّنَهُ الَّذِي أُوحِي لَهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَدْ صَدَّقُوهُ بِالْقُلُوبِ لَكِنْ', ['لَمَّا تَلَا صَحِيفَةَ القُرآنِ', 'الشِّرْكُ وَالْعِنَادُ فِيهَا سَاكِنْ', 'أَسْبابَ تَنْزيلٍ وَكُلَّ مَكانِ', 'وَأَعَادَهَا الشَّرِيفُ جَدُّ الْمُؤْتَمَن'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَلَيْسَ هَذَا مِنْ كَلَامِ الْبَشَر\nبَلْ إِنَّهُ حَقٌّ وَصِدْقُ خَبَر', ['يَتَعَرَّفونَ عَلَى الحَبيبِ وَآلِهِ', 'وَفي الشِّفاءِ لِلْقاضي عِياضْ', 'لَكِنَّ قَوْمَهُ قَدْ أنذَرُوهُ', 'وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'جَاءُوا إِلَيْكُمْ خَلْفَ هَذَا ........', ['سَائِرِين', 'سَلْمانَ', 'سَاكِنْ', 'سِنِينَ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَدْعُوكُمُ بِالْوَحْيِ لِلتَّوْحِيدِ\nمُحَذِّرًا لِلْكَافِرِ الْعَنِيدِ', ['مُبَشِّرًا مَنْ صَدَّقُوا وَآمَنُوا', 'وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ', 'وَغَيْرُهَا مِنْ قَوْمِهِ الْكَثِيرُ', 'يَدْعو إِلى البِرِّ وَلِلْأَخْلاقِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِجَنَّةِ الْخُلُودِ فِيهَا ........', ['يَنْطِقُوا', 'أَصْلًا', 'أَوَّلًا', 'يَنْعَمُوا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة', ['مَا مِنْهُمُ قَطُّ نُفُوسٌ مُشْرِكَةْ', 'مَنْظُومَةٌ فِي السِّيرَةِ النَّبَوِيَّةْ', 'لِلشَّامِ ثُمَّ عَادَ بِالْبِشَارَةِ', 'قَالَ عَنْهُ مَقَالَتَهُ الشَّهِيرَة'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ بَعْدِ ثَلَاثٍ مِنَ السِّنِينَا\nوَاللَّهُ رَبُّنَا أَعَزَّ الدِّينَا', ['وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', 'كَمَا أَتَى وَحْيٌ وَنَصٌّ قَطْعِيْ', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'وَبَعْدَهُمْ مُصْعَبٌ وَالزُّبَيْرُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَدْعُوكُمُ بِالْوَحْيِ ........', ['لِيَسْأَلُوهَا', 'لِرُكْبَتِهِ', 'لِلتَّوْحِيدِ', 'لِلْفَتَى'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَفِي كَلَامِ الْإِفْكِ عَنْهُ ........', ['عِيدُوا', 'ذَهَبُوا', 'حَكيماً', 'الْمَزَايَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', ['بِغَيْرِهِمْ مِنْ أَحَدٍ مِنْ بَاقِي النَّاس', 'نُوحٌ كَذَاكَ الطَّيِّبُ النَّفِيسُ', 'وَمِنْ أَذى الوِسْوَاسِ الخَنّاسِ', 'يُنْذِرُهُمْ بِالْوَحْيِ وَالنِّبْرَاسِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَاللَّهُ رَبُّنَا أَعَزَّ ........', ['الدِّينَا', 'الْأَعْمَامَا', 'أَخْلَصُوا', 'دَوْمًا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَعْظَمُهَا قَدْرًا هُوَ الْقُرْآنُ', ['الشِّرْكُ وَالْعِنَادُ فِيهَا سَاكِنْ', 'يُبْعِدَهُ عَنْ ذَلِكَ المَكانِ', 'رُزِقْتُ حُبَّهَا بِكُلِّ لِينٍ', 'دُسْتُورُ هَذَا الدِّينِ وَالْبَيَانُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين', ['جَاءُوا إِلَيْكُمْ خَلْفَ هَذَا سَائِرِين', 'قَدْ رُدِمَتْ لِمُدَّةٍ مِنَ الزَّمَنْ', 'لَمَّا تَلَا صَحِيفَةَ القُرآنِ', 'دُسْتُورُ هَذَا الدِّينِ وَالْبَيَانُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَكُنْتُمُ مُصَدِّقِينَ قَوْلِي\nقَالُوا نَعَمْ هَذَا الصَّحِيحُ وَالْجَلِي', ['لَكِنَّ بَعْضَ الْقَوْمِ آذَاهُ بِمَا', 'قَالَ لَهُمْ إِنِّي رَسُولُ رَبِّكُمْ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يُنْذِرُهُمْ بِالْوَحْيِ وَالنِّبْرَاسِ', ['وَأَعلَنَ الإِسلَامَ بَينَ النَّاسِ', 'وَكُلُّ وَصْفٍ كَانَ فِيهِمْ لَا يُقَاس', 'فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فِيكُمُ', ['قَالُوا أَخُونَا صَادِقٌ كَرِيمُ', 'مِنْ بَعْدِ مَا آمَنَ بِالْإِسْلَامِ', 'بَدَتْ عَلَى جَبِينِهِ النَّسَائِمُ', 'وَدَلَّهُ الذِّئْبُ عَلَى الْأَمْرِ الْأَهَمْ'], 0),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَرُكَانَةْ ظَهَرَتْ لَهُ مُعْجِزَةٌ', ['مَلائِكُ الرَّحْمنِ يَحْفَظونَهُ', 'ثَلَاثَ عَشْرَ مُنْذُ وَقْتِ الْبَعْثَة', 'كَانَتْ لَهُ شَجَاعَةٌ وَقُوَّةٌ', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ حَذَّرُوهُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُعْرَفُ فِي قَوْمِهِ بِالْمُصَارَعَة\nفَأَرَادَ مِنْ أَحْمَدَ أَنْ يُصَارِعَهْ', ['وَرَبُّنَا قَدْ أَخَذَ الْمِيثَاقَا', 'وَنَجْلُهُ مِنْ بَعْدِهِ أَوْصَاهُ', 'كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ', 'فَاقْتَتَلُوا أَرْبَعَةَ أَيَّامَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبِفَتْحِ مَكَّةَ أَعْلَنَ الْإِسْلَامْ', ['كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'قَدَّمَهُ عَلَى بَنِيهِ كُلِّهِمْ', 'مَنْ عَلَّمَ الْإِنْسَانَ مَا لَمْ يَعْلَمِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَأَى رُكَانَة سَيِّدَ ........', ['الشَّاهِدُ', 'الْبِلَادِ', 'الْمُؤَيَّدُ', 'الْأَسْيَادِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَعَ أَنَّهُ ذَا صِلَةٍ وَرَحِمِ', ['وَعادَ بَعْدَ ذاكَ بِأَعْوامِ', 'مِنْهُ وَلَكِنْ حِينَهَا لَمْ يُسْلِمِ', 'وَأَنَّ فيهِ مَبْعَثَ الهادي الكَريم', 'لِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه\nثَلَاثَ مَرَّاتٍ وَأَرْضًا أَوْقَعَه', ['رَوى كَذاكَ صاحِبُ الدَّلائِلِ', 'وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'مَضَى إِلَى سَبِيلِهِ كَرِيمًا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَأَرَادَ مُعْجِزَةْ فَنَادَى الشَّجَرَة', ['وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'فَإِنَّهَا خَدِيجَةُ الْحَبِيبَةُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبِأَمْرِهِ مِنْ بَعْدِ ذَاكَ ........', ['انْتَمَتْ', 'ظَهَرَتْ', 'رَجَعَتْ', 'عَلَامَاتٍ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ عَنْ أَبِي سَعِيدٍ الْخُدْرِيْ', ['يَحْكِي لَنَا مِمَّا أَتَى مِنْ خَبَرِ', 'تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', 'أَوْ غَابَ عَنْهُمُ يَكُونُ الْخُسْرُ', 'مَنْ أَخْلَصُوا فِي خِدْمَةِ الْمُخْتَارِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَنْ أَحَدِ الرُّعَاةِ كَانَ يَرْعَى\nشِيَاهَهُ رَأَى ذِئْبًا فَدَفَعَا', ['قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ', 'وَحَالَ بَيْنَهُ وَبَيْنَ غَنَمِهْ', 'كَفَلَهُ مِنْ بَعْدِ مَوْتِ أُمِّهِ', 'فِي دَارِ أَرْقَمٍ كَانَ الْأَصْحَابُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَجَلَسَ الذِّئْبُ إِلَيْهِ كَلَّمَهْ', ['يَجْمَعُهُمْ في كُلِّ يَوْمِ جُمُعَةِ', 'وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ', 'أَمَرَهُمْ فَأَقْبَلَ الْجَمَاعَة', 'وَحَالَ بَيْنَهُ وَبَيْنَ غَنَمِهْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ذِئْبٌ فَصِيحٌ بِالْكَلَامِ ........', ['آمَنَا', 'رَضِينَا', 'يَدْعُوا', 'عَبَّرَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُ أَعْجَبُ مِنِّي أَنْ تَرَى', ['هَذَا النَّبِيَّ بِطَيْبَةَ مُبَشِّرَا', 'وَسَيِّدًا وَقَائِدًا عَظِيمًا', 'صَاحِبِكُمْ عِيدُوا وَزِيدُوا الْإِبِلَا', 'مِنْ قَبْلِ كُلِّ النّاسِ كانَ مُؤْمِنا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ\nكَذَا بِمَا هُوَ كَائِنٌ مِنْ بَعْدِكُمْ', ['وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', 'فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'فَذَهَبَ الرَّاعِي إِلَى الْمَدِينَةِ', 'هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَحَدَّثَ النَّبِيَّ بِالْحِكَايَةِ', ['فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', 'فَذَهَبَ الرَّاعِي إِلَى الْمَدِينَةِ', 'قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَمَرَهُمْ فَأَقْبَلَ ........', ['مَكَانَةٌ', 'الْجَمَاعَة', 'دَمَارَهْ', 'مَوْلِدُهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ', ['تَكْفِي سِقَاءً لِلْحَجِيجِ الْأَعْظَمِ', 'وَدَلَّهُ الذِّئْبُ عَلَى الْأَمْرِ الْأَهَمْ', 'عَلِيٌّ الْكَرَّارُ ذُو الْإِقْدَامِ', 'لِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَمَى لَهُ غَنَمَهُ حَتَّى رَجَعْ\nمِنْ طَيْبَةَ لِدِينِ طَهَ مُتَّبِعْ', ['لَكِنَّ قَوْمَهُ قَدْ أنذَرُوهُ', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'وَسُئِلَ الصِّدِّيقُ هَلْ رَأَيْتَ', 'لَوْ أَنَّكَ أَعْتَقْتَ أَهْلَ الْقُوَّةِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ آيَةٍ مِنْ قَبْلِ مَا آمَنْتَا', ['جَاءَتْ إِلَى النَّبِيِّ ثُمَّ وَقَفَتْ', 'أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ', 'فَأَيْقَنُوا بِالْمَوْتِ لَكِنْ نَبَعَتْ', 'وَسُئِلَ الصِّدِّيقُ هَلْ رَأَيْتَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَيْرِ الْأَنَامِ ........ الَّذِي عَلَا', ['مُحَمَّدٌ', 'السَّيِّدُ', 'أَحْمَدَ', 'مَسْعُودٍ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', ['وَهْوَ ابْنُ عَمِّهَا أَيْضًا فَصَدَّقَهْ', 'لِكَيْ تَكُونَ بِهِمُ فِي مَنعَةِ', 'يَأْمُرُهُمْ حَثّاً عَلى اتِّباعِهِ', 'وَكُنْتُ أَسْتَظِلُّ تَحْتَ شَجَرَةٍ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'إِذْ بِي أَرَى عَلَيَّ مِنْ أَغْصَانِهَا\nتُدْلَى لِي عَلَى رَأْسِي أُبْصِرُهَا', ['صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه', 'قَالَ النَّبِيُّ إِنَّنِي لَأَعْرِفُ', 'أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'وَرَعْيُهَا لِلْأَنْبِيَا كَمَالُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هَذَا النَّبِيُّ يَخْرُجُ بِصَوْتِهَا', ['أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'أَمَرَ اللهُ أرْمِياءَ كانا', 'وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'فَكَانَ دَوْمًا يَشْتَرِي مَنْ آمَنَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كُنْ ........ النَّاسِ بِهِ آمِنْ بِهِ', ['الرَّشَادِ', 'مُحَمَّدٌ', 'الْعَنِيدِ', 'أَسْعَدَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كَمَا أَتَى وَحْيٌ وَنَصٌّ قَطْعِيْ', ['مِنْ طَيْبَةَ لِدِينِ طَهَ مُتَّبِعْ', 'مَنَعَ الشَّيَاطِينَ اسْتِرَاقَ السَّمْعِ', 'وَانْتَشَرَتْ فِي سَائِرِ الْبِقَاعْ', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بَيْنَ الْمَقَاعِدِ وَبَيْنَهُمْ يَحُولْ\nعِنْدَ اقْتِرَابِ بَعْثَةِ الرَّسُولْ', ['فَرُمَوْا بِالنُّجُومِ وَالشِّهَابِ', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ', 'مِنْ قَبْلِ أَنْ تَأْتِي الرِّسَالَةُ إِلَى', 'قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَعَلِمُوا بِصِدْقِ الِاقْتِرَابِ', ['فَإِنَّهُ الْمَذْكُورُ فِي الْكِتَابِ', 'فَرُمَوْا بِالنُّجُومِ وَالشِّهَابِ', 'زَكَّاهُ رَبُّ الْعَرْشِ فِي الْكِتَابِ', 'فِي دَارِ أَرْقَمٍ كَانَ الْأَصْحَابُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِيمَا رَوَى مِنْ حِفْظِهِ عَنِ ........', ['النَّبِيْ', 'مَقَالِي', 'الْيُسْرَى', 'الَّذِي'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ النَّبِيُّ إِنَّنِي لَأَعْرِفُ', ['أَسْبابَ تَنْزيلٍ وَكُلَّ مَكانِ', 'وَأَخْرَجُوهُ مِنْ حِمَى الْأَوْطَانِ', 'لِمَا فِيهَا مِنْ رِقَّةٍ وَعَطْفِ', 'حَجَرًا بِمَكَّةَ لَهُ وَيَصِفُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كَانَ مِنْ قَبْلِ بَعْثَتِي يُسَلِّمُ', ['عَلَيَّ دَوْمًا نَاطِقًا يَتَكَلَّمُ', 'مِنْهُ وَلَكِنْ حِينَهَا لَمْ يُسْلِمِ', 'عَنْ ذَلِكَ المَبْعوثِ وَيُنْبِئُهُمْ', 'عَلَيْهِمُ أَزْكَى الصَّلَاةِ وَالسَّلَامِ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ مَا آمَنَ ........', ['بِالْكَلَامِ', 'بِالْإِسْلَامِ', 'بِدِينِهِمْ', 'بِأَعْوامِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي قَدْرِهِ وَدِينِهِ وَفَضْلِهِ', ['وَسُمِّيَ بِذَلِكَ لِأَنَّهُ', 'هَذَا أَبُو بَكْرٍ وَمَنْ كَمِثْلِهِ', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة', 'وَسَافَرَ الْمُخْتَارُ لِلتِّجَارَةِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيَنْتَهِيَ عَنْ دِينِهِ وَأَمْرِهِ', ['وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'فَإِنَّهَا خَدِيجَةُ الْحَبِيبَةُ', 'وَجَاءَهُ جِبْرِيلُ شَقَّ صَدْرَهُ', 'وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَوْ أَنَّكَ ........ أَهْلَ الْقُوَّةِ', ['أَعْتَقْتَ', 'عَاشَتْ', 'مَرَّاتٍ', 'قَلَّبْتُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَأَدْرَكَتْهُ رَحْمَةُ الْغَفَّارِ', ['وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ الصِّغَرْ', 'مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ', 'وَكَانَ ذَاكَ فِي تَمَامِ عَشْرِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ أَبُو الصِّدِّيقِ لِابْنِهِ أَبِي', ['وَجَاءَتِ الْوُفُودُ لِلْهَادِي الْأَحَبْ', 'فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', 'فَإِنَّهُمْ ساداتُ أَشْرافِ العَرَب', 'بَكْرٍ أَيَا حَبِيبِيَ الْمُقَرَّبِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَجَابَهُ الصِّدِّيقُ إِنِّي ........', ['خَمْسًا', 'أَسْرَعَا', 'إِنَّمَا', 'أَخْبَرَهَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَدْعُوا جِهَارًا يُظْهِرُ الْإِسْلَامَا', ['وَكَانَ ذَاكَ الأَمرُ حِينَ ذَهَبَا', 'هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا', 'قَالُوا لَهَا هِيَ عَشَرَةٌ مِنْ إِبِلِنَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمِنْهُمْ عَامِرُ بْنُ ........', ['فَضْلُهُ', 'فَوْقِهِ', 'فَاتِحَةٌ', 'فُهَيْرَةَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَنَّ قَوْمَهُ ........', ['سَيَأْخُذُونَا', 'سَأَلُوهَا', 'سَيُسَاعِدُه', 'سَمَّيْتُهَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', ['حُبًّا لَهُمْ وَأَعْلَنَ الْإِسْلَامَا', 'صَفَّينِ لِلكَعبَةِ حَتَّى خَرَجُوا', 'يَدْعُوا جِهَارًا يُظْهِرُ الْإِسْلَامَا', 'بْنِ نِزَارِ بْنِ مَعَدِّ الْأُمَرَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ', ['وَجَدِّهِ الْكَرِيمِ ذِي الْمَفَاخِرِ', 'كانَتْ تُرى بِوُجوهِهِمْ أَنْوارُ', 'مِن جَانِبَيهِ مَعَهُمَا يَسِيرُ', 'فَأَدْرَكَتْهُ رَحْمَةُ الْغَفَّارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ يَزَلْ يَنْطِقُ ........', ['بِنَظْرَتِهِ', 'بِالشَّهَادَةِ', 'بِالْحِكَايَةِ', 'بِالْجَهْرِيَّة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يُدَافِعُ عَنْهُ مِنْ الْأَقْوَامِ', ['تَكْفِي سِقَاءً لِلْحَجِيجِ الْأَعْظَمِ', 'مِنْ بَعْدِ مَا آمَنَ بِالْإِسْلَامِ', 'عَلَيْهِمُ أَزْكَى الصَّلَاةِ وَالسَّلَامِ', 'عَلِيٌّ الْكَرَّارُ ذُو الْإِقْدَامِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَعْتَقَهُ أَيْضًا كَذَا زَنِيرَةَ', ['وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ', 'وَسُمِّيَ بِذَلِكَ لِأَنَّهُ', 'عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ', 'لَكِنَّ قَوْمَهُ قَدْ أنذَرُوهُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى\nوَكَانَ دَوْمًا لِلنَّبِيِّ مُصَدِّقَا', ['أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا', 'قَالَ النَّبِيُّ إِنَّنِي لَأَعْرِفُ', 'فَكَانَ دَوْمًا يَشْتَرِي مَنْ آمَنَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَنَّ قَوْمَهُ سَيَأْخُذُونَا', ['عُتْبَةَ مَنْ آذَاهُ يَقْتُلُونَا', 'مُحَمَّدُ الحَبيبُ حَقّاً عِنْدِيا', 'أَقْوَامَهُمْ لِيُؤْمِنُوا وَيَظْفَرُوا', 'شَمائِلَ الهادي وَذا يَكْفيها'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَذَّبُوهُ غَايَةَ التَّعْذِيبِ', ['يَجْتَمِعُونَ كُلُّهُمْ أَحْبَابُ', 'خَلَّصَهُمْ مِنْ نِقْمَةِ الْعَذَابِ', 'فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', 'فَإِنَّهُمْ ساداتُ أَشْرافِ العَرَب'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حِينَ لَقِيْ مِنْ الْأَذَى ........', ['طَائِفًا', 'إِعْجابا', 'نَكَالَا', 'رِجَالِهَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَتَّى اشْتَرَاهُ السَّيِّدُ الصِّدِّيقُ', ['الْأَكْرَمَ كَمَا قَدْ جَاءَ فِي الْعَلَقْ', 'وَجَاءَهُ مِن رَبِّنَا التَّوفِيقُ', 'أَعْتَقَهُ فَإِنَّهُ الرَّفِيقُ', 'فِي الْحَرِّ كَادُوا يُهْلَكُوا مِنْ ضِيقِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَكْرٍ أَيَا حَبِيبِيَ الْمُقَرَّبِ', ['إِنْ كَانَتِ الْأَقْدَاحُ قَدْ خَرَجَتْ عَلَى', 'قَالَ أَبُو الصِّدِّيقِ لِابْنِهِ أَبِي', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي', 'مِنْ قَبْلِ أَنْ تَأْتِي الرِّسَالَةُ إِلَى'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'نَطَقَ بِالتَّوْحِيدِ وَانْزَاحَ الْعَمَى', ['مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'وَلَمّا وُلِدَ نِزارُ سَطَعا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَسَّرَهُ اللهُ فَنَالَ ........', ['نَسَبي', 'الَّذي', 'الْيُسْرَى', 'الهادي'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا\nنَطَقَ بِالتَّوْحِيدِ وَانْزَاحَ الْعَمَى', ['وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'فَرَجَعَتْ بِالْمُصْطَفَى لِأُمِّهِ', 'وَلَمْ يَكُنْ في نَسَبي سِفاحُ', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', ['وَلَمْ أَجِدْ كَمِثْلِهِ فِي النَّسَبِ', 'وَعَذَّبُوهُ غَايَةَ التَّعْذِيبِ', 'وَرُوِيَ عَنْ سَمُرَةَ بْنِ جُنْدُبِ', 'وَبَعْدَها بِمَوْتِ عَبْدِ المُطَّلِب'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَعْتَقَهُ فَإِنَّهُ الرَّفِيقُ', ['حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'سَمَّيْتُهَا بِرَوْضَةِ الْعُشَّاقِ', 'بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ', 'حَتَّى اشْتَرَاهُ السَّيِّدُ الصِّدِّيقُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَنَّ قَوْمَهُ سَيَأْخُذُونَا\nعُتْبَةَ مَنْ آذَاهُ يَقْتُلُونَا', ['فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا', 'وَجاءَ في الحَديثِ لا تَسُبّوا', 'مُدْرِكَةُ وَخُزَيْمَةُ وَنِزارُ', 'لَكِنْ شَفَاهُ اللهُ مِمَّا لَاقَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَكَانَ مِمَّنْ أَعْتَقَ ........', ['بِلَالَا', 'بِابْنِنَا', 'بِهَذَا', 'بِرَبِّهَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ\nأَحَدٌ الْمَوْلَى بِلَا زِيَادَةِ', ['بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ', 'حَتَّى اشْتَرَاهُ السَّيِّدُ الصِّدِّيقُ', 'إِذَا دَعَا الْكُفَّارَ لِلْإِيمَانِ', 'وَأَرْضَعَتْ حَلِيمَةُ السَّعْدِيَّة'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نَطَقَ بِالتَّوْحِيدِ وَانْزَاحَ ........', ['المَغازي', 'الَّذِي', 'الْمَوْلَى', 'الْعَمَى'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَحَاوَلَتْ قُرَيْشٌ أَخْذَ ........', ['النَّبِيِّ', 'الْيُسْرَى', 'الْأَبَدَي', 'الْمُصْطَفَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَا قَدْ رَأَوْا وَخَالَفُوا ........', ['النُّورَا', 'الْحَبِيبَا', 'أُرْسِلَا', 'الْقُصُورَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَكِنَّهُ مَا خَانَ لِلْأَمَانَةْ', ['وَتَزَيَّنَتْ بِمَنِ انْتَمَتْ شَرَفًا لَهُ', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ', 'يُعْطُونَهُ وَلَدًا لَهُمُ مَكَانَهْ', 'حِينَ أَشَارَ الْمُصْطَفَى بِكَفِّهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِيَسْمَعُوا كَلَامَهُ ........', ['أَمِينُهَا', 'عَابِدًا', 'حَبِيبُنَا', 'الْعَجِيبَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَازْدَادَ إِيمَانُ الصَّحَابَةِ الْكِرَامِ\nعَلَيْهِمُ أَزْكَى الصَّلَاةِ وَالسَّلَامِ', ['رَوى كَذاكَ صاحِبُ الدَّلائِلِ', 'بَعْدَ النَّبِيِّ الْكَامِلِ الْأَمِينْ', 'فَعَادَ لِلْكُفْرِ وَلِلْبُهْتَانِ', 'خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَكِنَّهُ مَا خَانَ ........', ['لِنِصْفِهِ', 'لِلتِّجَارَةِ', 'لِلْأَمَانَةْ', 'لِلْكَاهِنَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'شَقًّا لِبَدْرٍ فِي السَّمَاءِ مُعْلِنَا', ['وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'فَأَجَابَهُ الصِّدِّيقُ إِنِّي إِنَّمَا', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا', 'حَتّى كَتَبْتُ لا إِلهَ إِلّا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حِينَ أَشَارَ الْمُصْطَفَى بِكَفِّهِ\nلِلْبَدْرِ فَانْشَقَّ لَهُمْ لِنِصْفِهِ', ['نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'قَدْ أَشْرَقَ الرَّبِيعُ بِالْأَنْوَارِ', 'مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا', 'وَقَدْ تَمَنَّى حِينَهَا الْحُضُورَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ', ['وَجَاءَتِ الْوُفُودُ لِلْهَادِي الْأَحَبْ', 'فَاقْرَأْ بِوَعْيٍ صِيغَةَ الْخِطَابِ', 'لِأَنَّ مِنْهُمُ رَسولَهُ الأَحَبّ', 'فَعَلِمُوا بِصِدْقِ الِاقْتِرَابِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَلَيْهِمُ أَزْكَى الصَّلَاةِ ........', ['وَجَيْشُهُمْ', 'وَالسَّلَامِ', 'وَمَعَهُمُ', 'وَغَيْرُهُمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يُعْطُونَهُ وَلَدًا لَهُمُ مَكَانَهْ', ['طَيِّبَةً أَيَّامُهُمْ مَجِيدَة', 'أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'تَزُورُ أَخْوَالًا لَهُ أَمِينَة', 'لَكِنَّهُ مَا خَانَ لِلْأَمَانَةْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ\nبِنَفْسِهِ وَمَالِهِ يَفْدِيهِ', ['عَاشَتْ عَلَى تَوَاصُلِ الْأَرْحَامِ', 'أَنْفُسَهُمْ لِيَنْصُرُوا الْإِسْلَامَا', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', 'فَلَمْ يَزَلْ يَدْعُو النَّبِيُّ مَنْ أَتَى'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَاوَلَتْ قُرَيْشٌ أَخْذَ الْمُصْطَفَى\nمِنْ عَمِّهِ لِيَقْتُلُوهُ فِي جَفَا', ['وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك', 'وَسَافَرَتْ بِهِ إِلَى الْمَدِينَة', 'يُعْطُونَهُ وَلَدًا لَهُمُ مَكَانَهْ', 'مِنْ بَعْدِهِ نَسَبُهُ امْتَدَّ إِلَى'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا\nوَكَمْ أَتَاهُ مِنْ فَتًى مُجِيبَا', ['وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا', 'مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَتَّى رَآهُ الْقَوْمُ يَعْلُو الْجَبَلَا', ['وَعَنِ ابنِ عَبّاسٍ رَوَى مَرْفوعا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا', 'نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَازْدَادَ إِيمَانُ الصَّحَابَةِ الْكِرَامِ', ['عَلَيْهِمُ أَزْكَى الصَّلَاةِ وَالسَّلَامِ', 'لِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ', 'وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', 'وَأَنَّ فيهِ مَبْعَثَ الهادي الكَريم'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَعْدَ النَّبِيِّ ........ الْأَمِينْ', ['العَقْلِ', 'الْكَامِلِ', 'مُنْزَلَ', 'الأَمْثالِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَلَمْ يَزَلْ يَدْعُو النَّبِيُّ مَنْ أَتَى', ['أَعْتِقُ لِلهِ لِيَرْضَى مُكْرِمَا', 'لَبَنُهَا قَالَ أَنَا أَمِينُهَا', 'لِلْبَيْتِ مِنْ أَهْلِ الْقُرَى قَدْ ثَبَتَا', 'بْنِ نِزَارِ بْنِ مَعَدِّ الْأُمَرَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', ['حِينَ لَقِيْ مِنْ الْأَذَى نَكَالَا', 'وَكَمْ أَتَاهُ مِنْ فَتًى مُجِيبَا', 'ابْنُ مَظْعُونٍ أَعْلَنُوا الْإِيمَانَا', 'بَيْنَهُمَا كانوا يُؤَرِّخُونَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِنَفْسِهِ وَمَالِهِ ........', ['عَبْدُاللَّهِ', 'مَضْنُونَةٌ', 'يَفْدِيهِ', 'آمِنَةُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَاءَتِ ........ لِلْهَادِي الْأَحَبْ', ['السَّيِّدُ', 'مُحَمَّدٌ', 'الْوُفُودُ', 'الأَسَد'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حِينَ ........ الْمُصْطَفَى بِكَفِّهِ', ['أَشَارَ', 'الْكُفَّارَ', 'الصُّخُورَ', 'الْمُطَهَّرُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ ........', ['الطَّيِّبُ', 'الْوَاهِبُ', 'أَعْجَبُ', 'الْعَرَبْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', ['فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا', 'وَالنّارَ وَالجَنَّةَ لَمْ أَخْلُقْهُما', 'رَبيعَةَ كَذا كَما قَدْ أَخْبَرَا', 'حَتَّى رَآهُ الْقَوْمُ يَعْلُو الْجَبَلَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ', ['وَالتَّابِعِينَ كُلِّهِمْ وَحِزْبِهِ', 'بِنَفْسِهِ وَمَالِهِ يَفْدِيهِ', 'يُحَكِمُوهَا فِي الْأُمُورِ الرَّاهِنَة', 'كُنْ أَسْعَدَ النَّاسِ بِهِ آمِنْ بِهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ عَمِّهِ لِيَقْتُلُوهُ فِي جَفَا', ['ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى', 'وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'وَحَاوَلَتْ قُرَيْشٌ أَخْذَ الْمُصْطَفَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ يُصَدِّقُوا بِدِينِهِ', ['لِيَعْرِفوا', 'لِيُؤْمِنُوا', 'لَكِنَّهَا', 'لامِعَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَإِنَّهُ وَصِيَّةُ ........', ['أَبِيهِ', 'دَعُوهُ', 'عِيشَةً', 'مُدْرِكَةُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَتَّى رَآهُ الْقَوْمُ يَعْلُو ........', ['مِنْهَا', 'الْجَبَلَا', 'مَاؤُهَا', 'مُبَشِّرَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَا قَدْ رَأَوْا وَخَالَفُوا الْحَبِيبَا', ['لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا', 'وَجاءَ عَنْ سَلْمانَ الفارِسيِّ ما', 'في شَأْنِ آباءِ النَّبِيِّ نَقَلوا', 'ثَلَاثَ مَرَّاتٍ يَقُولُ مَا أَنَا'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَابَلُوهُمْ بِالْأَذَى الْقَبِيحِ', ['فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ', 'عَنِ الحَبيبِ سَيِّدِ المِلاحِ', 'وَلَمْ يَكُنْ في نَسَبي سِفاحُ', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا', ['هَذَا النَّبِيُّ يَخْرُجُ بِصَوْتِهَا', 'وَبَشَّرَتْ لِعَمِّهِ قَدْ ثَبَتَا', 'شَقًّا لِبَدْرٍ فِي السَّمَاءِ مُعْلِنَا', 'تَطْلُبُهُمْ مِنَ النَّجَاشِيْ حِينَهَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', ['عَنْ غَيْرِهِ وَغَايَةَ التَّعْظِيمِ', 'قَدْ هَاجَرُوا بِدِينِهِمْ نَحْوَ السَّلَامْ', 'هُوَ دينُ إِبْراهيمَ كانَ جَدُّهُمْ', 'إِلَيْكُمُ يَنْهَاكُمُ عَنْ شِرْكِكُمْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَاشُوا هُنَاكَ عِيشَةً ........', ['سُمَيَّةُ', 'سَعِيدَة', 'سِوَاهُ', 'سَبِيلِهِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَهَا ........ إِلَى بِلَادِهِمْ', ['جَمِيعًا', 'يَهُودِيًّا', 'عَادُوا', 'ظَنُّوا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ', ['وَقَابَلُوهُمْ بِالْأَذَى الْقَبِيحِ', 'لَهُ عَسَى أَن يَهتَدِي وَيُفلِحُ', 'عَنْ عُمَرَ الفاروقِ وَالمَليحِ', 'فَكُلُّ آباءِ النَّبِي صِحاحُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَوَّلُهُمْ رُقَيَّةُ ........', ['وَنَبَتَا', 'وَهَكَذَا', 'وَزَوْجُهَا', 'وَثَبَتا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِذَاكَ عَادُوا حِينَمَا قَدْ ........', ['مِنْهَا', 'تَوَقِّيَا', 'أَحْبَابَهَا', 'أَمِنُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عُثْمَانُ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', ['فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'أَوَّلُهُمْ رُقَيَّةُ وَزَوْجُهَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِلَى النَّجَاشِيْ الطَّيِّبِ ........ الْأَمِين', ['الْعَدْلِ', 'الْخَلِيل', 'تَوَاصُلِ', 'الرَّسولْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَوْفًا عَلَى إِيمَانِهِمْ مِنْ قَوْمِهِمْ', ['بِإِذْنِهِ وَسِرِّهِ تَكَلَّمِ', 'لَمَّا طَغَوْا عَلَيْهِمُ بِبَغْيِهِمْ', 'بَلْ كُلُّ رُسْلِ اللَّهِ قَدْ أُوحِي لَهُمْ', 'ثَلَاثَةً كَمُلَتْ عَلَى التَّمَامِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَدْ هَاجَرُوا بِدِينِهِمْ نَحْوَ السَّلَامْ', ['وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ', 'وَعِنْدَ نُقْرَةِ الْغُرَابِ الْأَعْصَمِ', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ ابْنُ عَوْفٍ ثُمَّ ........ مَعَا', ['الحَبيبِ', 'حَاطِبٌ', 'أَعْجَبُ', 'الأَحَبُّ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَانَ تَقِيًّا حَاكِمًا عَلِيمَا', ['لَكِنَّهُ أَبَى لَهُمْ تَسْلِيمَا', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', 'وَكَانَ ذَا عَنْ رُؤْيَا قَدْ رَآهَا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى بِلَادٍ لَيْسَ فِيهَا ضَيْرُ', ['مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'وَبَعْدَهُمْ مُصْعَبٌ وَالزُّبَيْرُ', 'مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنَ النِّسَاءِ خَمْسَةٌ وَضِعْفُهُمْ', ['مِنْهُ وَلَكِنْ حِينَهَا لَمْ يُسْلِمِ', 'ذِكْرُكَ مَرْفوعٌ مَدى الأَيّامِ', 'مِنَ الرِّجَالِ ثُمَّ اثْنَانِ بَعْدَهُمْ', 'ثَلَاثَةً كَمُلَتْ عَلَى التَّمَامِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'تَطْلُبُهُمْ مِنَ النَّجَاشِيْ ........', ['مُحَمَّدًا', 'حِينَهَا', 'دَوْمًا', 'قَامُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى النَّجَاشِيْ الطَّيِّبِ الْعَدْلِ الْأَمِين', ['خَرَجَ مِنْهَا ذَلِكَ النُّورُ الْمُبِين', 'قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَانَ تَقِيًّا ........ عَلِيمَا', ['جَميلاً', 'مِنْهَا', 'تَقَلَّبَا', 'حَاكِمًا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', ['الحُسْنِ', 'عُثْمَانُ', 'الزَّمانِ', 'القُرْآنِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ يَكُنْ بِخَبَرٍ ........', ['صِحاحُ', 'صَحِيحِ', 'الصَّحِيحُ', 'المَسيحِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ\nقَدْ هَاجَرُوا بِدِينِهِمْ نَحْوَ السَّلَامْ', ['فَرُمَوْا بِالنُّجُومِ وَالشِّهَابِ', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا', 'فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا', 'كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي شَهْرِ شَوَّالَ الَّذِي مِنْ عَامِهِمْ', ['نَبِيُّنَا الْمُخْتَارُ مِنْ بَيْنِ الْأُمَمْ', 'يُخْبِرُكُمْ بِمَا مَضَى مِنْ قَبْلِكُمْ', 'وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَوْفًا عَلَى إِيمَانِهِمْ مِنْ ........', ['الْأَقْوَامِ', 'التَّعْظِيمِ', 'يُنْذِرُهُمْ', 'قَوْمِهِمْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَهُمْ مُصْعَبٌ وَالزُّبَيْرُ\nإِلَى بِلَادٍ لَيْسَ فِيهَا ضَيْرُ', ['كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ الصِّغَرْ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'ثُمَّ ابْنُ عَوْفٍ ثُمَّ حَاطِبٌ مَعَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا\nتَطْلُبُهُمْ مِنَ النَّجَاشِيْ حِينَهَا', ['فِي أَرْضِ الْأَبْوَاءِ الَّتِي تَشَرَّفَتْ', 'لَكِنَّهُ أَبَى لَهُمْ تَسْلِيمَا', 'وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ', 'وَأَرْضَعَتْ حَلِيمَةُ السَّعْدِيَّة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', ['إِلَى النَّجَاشِيْ الطَّيِّبِ الْعَدْلِ الْأَمِين', 'يُبْعِدَهُ عَنْ ذَلِكَ المَكانِ', 'يَبْنِي بِهَا فَأَبَى الشَّرِيفُ الْمُؤْتَمَنْ', 'مِن بَعدِ حَمزَةَ عَلَى اليَقِينِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَوَّلُهُمْ رُقَيَّةُ وَزَوْجُهَا', ['عُثْمَانُ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', 'أَقْوَامَهُمْ لِيُؤْمِنُوا وَيَظْفَرُوا', 'نَبِيَّهُ في ذَلِكَ الزَّمانا', 'قَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ابْنُ مَظْعُونٍ وَمَسْعُودٌ ........', ['أَسْرَعَا', 'عِنْدَهَا', 'يَنْعَمُوا', 'أَخْبرا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَوَّلُهُمْ رُقَيَّةُ وَزَوْجُهَا\nعُثْمَانُ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', ['حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي', 'وَأَوَّلُ مَنْ آمَنَ مِنَ الرِّجَالْ', 'وَبَعْدَهُمْ مُصْعَبٌ وَالزُّبَيْرُ', 'رَعَاهَا فِي مَكَّةَ فِي وَقْتِ الصِّغَرْ'], 2),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَخبَرُوهُ عَن مَكَانِ المُصطَفَى', ['بِدَعوَةِ النَّبِيِّ وَانزَاحَ العَمَى', 'عَنْ ابنِ عَبّاسِ الإِمامِ قَدْ أَتى', 'نَطَقَ بِالتَّوْحِيدِ وَانْزَاحَ الْعَمَى', 'مَعَ الصَّحَابَةِ الَّذِي فِيهِ اختَفَى'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَدخَلُوهُ لِلنَّبِيِّ فَاستَقبَلَه', ['وَمِن مَجَامِعِ الثِّيَابِ أَمسَكَه', 'تَزُورُ أَخْوَالًا لَهُ أَمِينَة', 'مُعَظَّماً في العِلْمِ وَالأَمانَة', 'فَهَمَّ أَنْ يُوفِي بِمَا قَدْ نَذَرَهْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حِينَ دَعَا لَهُ النَّبِيُّ الهَادِي\nأَن يَهدِيَهُ اللَّهُ إِلَى الرَّشَادِ', ['عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ', 'فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'يَخْرُجُ فِي وَقْتِ كَذَا عَنْ وَقْتِهِ', 'وَكَانَ ذَاكَ الأَمرُ حِينَ ذَهَبَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَدخَلُوهُ لِلنَّبِيِّ ........', ['فَأَدْرَكَتْهُ', 'فَاستَقبَلَه', 'فَأَجَابَهُ', 'فَاتَّبِعوهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', ['لَمَّا تَلَا صَحِيفَةَ القُرآنِ', 'وَبِها بُلوغُ مَراتِبِ الإِحْسانِ', 'وَأَخْرَجُوهُ مِنْ حِمَى الْأَوْطَانِ', 'فَأَقْبَلُوا بِخَالِصِ الْإِذْعَانِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لُقِّبَ بِالفَارُوقِ لَمَّا ........', ['أَعلَنَا', 'أَكْمَلا', 'الْمَزَايَا', 'الْفِدَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حُبًّا لَهُمْ وَأَعْلَنَ ........', ['مُتَاجِرًا', 'الأَتَمّا', 'الْإِسْلَامَا', 'الْإِبِلَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَهَدَاهُ رَبُّ العَرشِ ........', ['لِلإِيمَانِ', 'لِلدِّينِ', 'لِلْيَمَن', 'لِلْكَوْنِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي دَارِ الأَرقَمِ مَعَ أَهلِ الصَّفَا\nالسَّابِقِينَ الأَوَّلِينَ ذَوِي الوَفَا', ['وَعَنِ ابنِ عَبّاسٍ رَوَى مَرْفوعا', 'فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا', 'طَرَقَ البَابَ لَم يَقُم مِنهُم أَحَد'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فَاهتَزَّ مِن هَيبَتِهِ', ['وَأُمُّهُ', 'وَغَيْرُهُ', 'وَهَزَّهُ', 'وَمَالِهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ\nمِن جَانِبَيهِ مَعَهُمَا يَسِيرُ', ['وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا', 'وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا', 'وَأَدخَلُوهُ لِلنَّبِيِّ فَاستَقبَلَه', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَهُ عَسَى أَن ........ وَيُفلِحُ', ['الَّذِي', 'إِنَّنِي', 'يَهتَدِي', 'النَّبِيَّ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمِن مَجَامِعِ الثِّيَابِ أَمسَكَه', ['وَأَدخَلُوهُ لِلنَّبِيِّ فَاستَقبَلَه', 'عَقْدٌ فَرِيدٌ فِي العَوَالِمِ مَا لَهُ', 'يَجْمَعُهُمْ في كُلِّ يَوْمِ جُمُعَةِ', 'وَأُمُّهُ آمِنَةُ الْكَرِيمَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَمسَكَ بِالصَّحِيفَةِ ........', ['قَرَأَهَا', 'تَسُبّوا', 'أَيُّهَا', 'الْجَبَلَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'صَفَّينِ لِلكَعبَةِ حَتَّى خَرَجُوا', ['وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', 'هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', 'وَشَاوَرَ النَّبِيَّ حَتَّى يَخرُجُوا', 'وَمُضَرُ كانَ جَميلاً مُشْرِقا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَم يَخشَ مِن ضَيمٍ وَلَا ........', ['عَبّاسٍ', 'الوِسْوَاسِ', 'إِفلَاسِ', 'إِلْياسُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ وَلِلنَّبِيِّ أَذعَنَا', ['خَدِيجَةُ', 'أَمِينَة', 'إِيمَانَهُ', 'العَشيرَةِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمَّا تَلَا صَحِيفَةَ ........', ['الأَمِينَ', 'العُيونِ', 'مَكانِ', 'القُرآنِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَشَاوَرَ ........ حَتَّى يَخرُجُوا', ['النَّبِيَّ', 'أُخْرَى', 'الَّذي', 'يَسْرِي'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي السَّنَةِ السَّادِسَةِ لِلدِّينِ\nمِن بَعدِ حَمزَةَ عَلَى اليَقِينِ', ['مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا', 'حِينَ دَعَا لَهُ النَّبِيُّ الهَادِي', 'فَعَمَّتِ الْأَفْرَاحُ فِي الْبِلَادِ', 'مُزَّمِّلٌ مُدَّثِّرٌ رَسُول'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', ['مَلائِكُ الرَّحْمنِ يَحْفَظونَهُ', 'فِي قَدْرِهِ وَدِينِهِ وَفَضْلِهِ', 'سَعِيدَةٍ كَرِيمَةٍ غَنِيَّةٍ', 'إِلَى النَّجَاشِيْ بَعْدَهَا فِي مِائَةِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَ ذَاكَ الأَمرُ حِينَ ذَهَبَا', ['لِصَفْوَةِ الْأَطْهَارِ قَوْمٍ كُرَمَا', 'لِبَيتِ أُختِهِ فَاطِمَ مُغضَبَا', 'عيسَى المَسيحِ آمِراً وَمُرْسِلا', 'مِنْهُمْ عَلَى اتِّبَاعِهِ اتِّفَاقَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِن بَعدِ حَمزَةَ عَلَى اليَقِينِ', ['بَعْدَ النَّبِيِّ الْكَامِلِ الْأَمِينْ', 'فِي السَّنَةِ السَّادِسَةِ لِلدِّينِ', 'فَبِها تَكونُ زِيادَةُ الإيمانِ', 'قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَكْرَمَهُمْ فِي أَرْضِهِ ........', ['إِكْرَامَا', 'حَرْبَا', 'الأَتَمّا', 'أَقْبَلَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِن بَعدِ حَمزَةَ عَلَى ........', ['أَعْلَنَ', 'اليَقِينِ', 'الْإِنْسَانَ', 'الزَّمانِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ\nإِلَى النَّجَاشِيْ بَعْدَهَا فِي مِائَةِ', ['وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'وَالنَّضْرُ أَيْضاً مِنْ نَضارَةِ وَجْهِهِ', 'أَكْرَمَهُمْ فِي أَرْضِهِ إِكْرَامَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَشَاوَرَ النَّبِيَّ حَتَّى يَخرُجُوا\nصَفَّينِ لِلكَعبَةِ حَتَّى خَرَجُوا', ['أَدَبًا مَعَ النَّبِيِّ وَاحْتِرَامَا', 'لُقِّبَ بِالفَارُوقِ لَمَّا أَعلَنَا', 'هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'السَّابِقِينَ الأَوَّلِينَ ذَوِي الوَفَا', ['مِنْهُمْ كَانَ ابْنُ مَسْعُودٍ وَأَسْلَمَا', 'فِي دَارِ الأَرقَمِ مَعَ أَهلِ الصَّفَا', 'وَمَرِضَتْ هُنَاكَ عِنْدَ أَهْلِهَا', 'لَكِنَّ بَعْضَ الْقَوْمِ آذَاهُ بِمَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى النَّجَاشِيْ بَعْدَهَا فِي مِائَةِ', ['وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', 'صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'صَفَّينِ ........ حَتَّى خَرَجُوا', ['لِلتِّجَارَةِ', 'لِقَوْمِهِ', 'لِصَفْوَةِ', 'لِلكَعبَةِ'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَهَاجَرَ الأَصْحَابُ نَحْوَهُم لَمَّا', ['تَعْلُو عَلَى الْجَبِينِ فِي النَّهَارِ', 'فِيهَا يَعِيشُ آمِنًا مَن أَسْلَمَا', 'وَأَعْلَنُوا جَائِزَةَ الجِمَالِ', 'طَهَّرَهُمْ بِهِ كَمَا قَدْ أَخْبَرَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَالمُصْطَفَى قَد أَخَّرَ الصِّدِّيقَا\nلِكَي يَكُونَ مَعَهُ رَفِيقَا', ['كانَ جَميعاً حُنَفاءَ دينُهُمْ', 'كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ', 'سَارَتْ بِهِ تَقْصِدُ بَيْتَ وَرَقَةْ', 'حَتَّى أَتَاهُ الإِذْنُ بَعْدَ فَتْرَةِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَجَهَّزَ الرَّحْلَ بِقَصْدِ الهِجْرَةِ', ['حَتَّى أَتَاهُ الإِذْنُ بَعْدَ فَتْرَةِ', 'فِي أَرْضِ الْأَبْوَاءِ الَّتِي تَشَرَّفَتْ', 'وَقَالَتِ الأَنْصَارُ فَلْتَمْضِي بِنَا', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَهَّزَ الدَّلِيلَ ........', ['لِلسَّمَاءِ', 'لِلطَّرِيقِ', 'لِيُؤْمِنُوا', 'لِصَفْوَةِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَقَد رَعَاهُ اللهُ بِالعِنَايَةِ', ['وَالنَّصْرُ فِيهَا لِلْقُلُوبِ الخَاشِيَة', 'عَلَى المَدِينَةِ وَمَضَى الصَّحَابَةْ', 'وَاللُّطْفِ فِي المَسِيرِ وَالكِفَايَةِ', 'يَا شَافِعًا لِلخَلْقِ فِي المِيعَادِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'كَفَاهُ شَرَّ مَن بَغَى وَكَادَا\nوَعَنْهُ حَقًّا أَبْعَدَ الحُسَّادَا', ['حِينَ دَعَا لَهُ النَّبِيُّ الهَادِي', 'يَغْشَاهُمُ النُّعَاسُ تَأْمِينًا لَهُمْ', 'وَاسْتَعْمَلَ الهَادِي أَبَا لُبَابَةْ', 'وَاسْتَوْدَعَ المُخْتَارُ زَوْجَ بِنْتِهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كُلَّ الأَمَانَاتِ الَّتِي فِي بَيْتِهِ', ['وَأَصْطَلَحَ الرُّوَاةُ فِي التَّسْمِيَةْ', 'وَأَنْزَلَ اللهُ عَلَيْهِمْ مَطَرًا', 'وَاسْتَوْدَعَ المُخْتَارُ زَوْجَ بِنْتِهِ', 'لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِكَي ........ إِلَى أَصْحَابِهَا', ['يُسَلِّمُ', 'يُهْلَكُوا', 'يَرُدَّهَا', 'يَتَكَلَّمُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بَاتَ عَلِيٌّ فِي فِرَاشِ الهَادِي', ['وَكامِلاً في العَقْلِ وَالبَيانِ', 'لَم يَخْشَ مِن قَتْلٍ وَلَا إِبْعَادِ', 'مُسْتَقْبِلِينَ يَوْمَهُمْ بِالسَّعْدِ', 'فِي آلِ عِمْرَانَ عَنِ الحِكَايَةِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَخَرَجَ النَّبِيُّ مِن دِيَارِهِم\nوَلَم يَرَوْهُ أُغْشِيَت أَبْصَارُهُم', ['هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا', 'وَخُطِبَتْ فَاطِمَةُ مِنَ النَّبِيْ', 'تَلَا عَلَيْهِم حِينَهَا يَاسِينَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَرَبُّهُ قَد زَادَهُ تَمْكِينَا', ['وَأَذِنَ الرَّحْمَنُ بِالقِتَالِ', 'مِنْ بَعْدِ مَا هَمُّوا إِلَى القِتَالِ', 'تَلَا عَلَيْهِم حِينَهَا يَاسِينَا', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِيهِ ثَلَاثَ ........ قَد مَكَثَا', ['لَيَالٍ', 'لِتِلْكَ', 'لَكِنَّ', 'لِسَيِّدِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِنَفْسِهِ الصِّدِّيقُ قَد فَدَاهُ', ['هُوَ دينُ إِبْراهيمَ كانَ جَدُّهُمْ', 'فَأَرَّخوا بِالحادِثِ الجَليلِ', 'وَلَم يَزَل مُدَافِعًا يَرْعَاهُ', 'يَجْتَمِعُونَ كُلُّهُمْ أَحْبَابُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَدَغَهُ الثُّعْبَانُ فِي ذَا الغَارِ\nوَقَد بَكَى مِن شِدَّةِ الآثَارِ', ['هِيَ أَعْظَمُ الغَزَوَاتِ ذَاكَ لِأَنَّهَا', 'وَمَعَهُنَّ خَرَجَتِ النِّسَاءُ', 'ضَرَبَهَا وَزَوجَهَا وَبَعدَهَا', 'لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَهُنَا مِنَ الأَذَى عَافَاهُ', ['قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى', 'لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ', 'وَجاءَ أَنَّ اللهَ لَمّا سَلَّطا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ ........ كَذَا أَسْمَاءُ', ['عَامُ', 'عَامِرٌ', 'عَساكِرَ', 'عَمِلوا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ذَاتُ النِّطَاقَيْنِ الَّتِي قَد قَطَعَتْ', ['بِمَا حَبَاهُ هَذِهِ الْمَفَاخِرَا', 'لِلَّهِ فِيهِ دَائِمًا وَشَاهِدًا', 'وَغَطَفَانَ كَمَا فِي الْأَخْبَارِ', 'نِطَاقَهَا وَلِلطَّعَامِ وَضَعَتْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَ أَهْلُ الكُفْرِ وَالجَفَاءِ\nلِلغَارِ بِالحِقْدِ وَبِالغَبَاءِ', ['سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ', 'وَكَانَ ذَا عَنْ رُؤْيَا قَدْ رَآهَا', 'قَالَ أَنَا النَّبِيُّ حَقًّا لَا كَذِبْ', 'لَكِنْ عِنَايَةُ اللهِ تَوَلَّت أَحْمَدَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَرَجَعُوا بِالخِزْيِ عَادُوا كَمَدَا', ['وَجَاءَ أَهْلُ الكُفْرِ وَالجَفَاءِ', 'فَهَاجَرَ الأَصْحَابُ نَحْوَهُم لَمَّا', 'لَكِنْ عِنَايَةُ اللهِ تَوَلَّت أَحْمَدَا', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَد سَكَنَت ........ بُيُوتَا', ['وَمَعَهُمُ', 'وَنَسَجَت', 'وَقَتَلُوا', 'وَعَنْهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَاضَتِ الحَمَامُ فِي المَكَانِ', ['لَم يَشْهَدُوا عِنَايَةَ الرَّحْمَنِ', 'فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا', 'عَنْ غَيْرِهِ وَغَايَةَ التَّعْظِيمِ', 'لَمْ يَنْتَقِمْ مِنْهُمْ عَلَى الجِنَايَةِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَرَجَعُوا بِخَيْبَةِ الآمَالِ\nوَأَعْلَنُوا جَائِزَةَ الجِمَالِ', ['أَحَدُهُمْ بِأَنَّهُمْ قَدْ هَرَبُوا', 'وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى', 'لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَفُز بِهَا فِي وَقْتِهَا إِن أَعْلَنَا', ['لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'وَكَذَّبَ الْكُفَّارُ بِالْإِسْرَاءِ', 'وَلَمْ أَجِدْ كَمِثْلِهِ فِي النَّسَبِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ سُرَاقَةُ بنُ مَالِك', ['سَمِعَهُم', 'سَائِرِ', 'سَلُولْ', 'سَلِمَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', ['مُفَتِّشًا عَن سَيِّدِ النُّبَلَاءِ', 'لِلْبَدْرِ فَانْشَقَّ لَهُمْ لِنِصْفِهِ', 'فَتَمَّ مَا قَالُوا لَهُ فِي حِينِهِ', 'وَلَم يَزَل مُدَافِعًا يَرْعَاهُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى رَأَى مَسِيرَهُم فَأَسْرَعَا\nبِخَيْلِهِ إِلَيْهِمُ فَانْقَطَعَا', ['الخَيْلُ غَاصَ مِنْهُ بَيْنَ الرَّمْلِ', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ', 'لِيَعْرِفَ النَّاسُ جَمِيعًا قَدْرَهَا', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'دَعَا لَهُ إِمَامُ أَهْلِ الفَضْلِ', ['الخَيْلُ غَاصَ مِنْهُ بَيْنَ الرَّمْلِ', 'لَوْ أَنَّكَ أَعْتَقْتَ أَهْلَ الْقُوَّةِ', 'أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا', 'وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنَ ........ الهَاشِمِيْ مُعْتَبِرَا', ['الْيَدِ', 'النَّبِيِّ', 'الزَّوْجَةُ', 'أَلَّفَ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'صَدَّقَهُ وَأَعْلَنَ الوَفَاءَا', ['فَكَانَ حَقًّا أَهْلًا لِلْأَمَانَةْ', 'أَنْ يُطْلِقُوا تَعْرِيفَهُمْ سَرِيَّةْ', 'فِيهِ ثَلَاثَ لَيَالٍ قَد مَكَثَا', 'لَهُ فَنَالَ عِندَ ذَا عَطَاءَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بَشَّرَهُ النَّبِيُّ أَن يَنَالَا\nسِوَارَ كِسْرَى حَقًّا لَا مَحَالَا', ['وَكُلُّ وَصْفٍ كَانَ فِيهِمْ لَا يُقَاس', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', 'فَنَالَ ذَا فِي زَمَنِ الفَارُوقِ'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'آخَى الحَبِيبُ بَيْنَ كُلِّ المُسْلِمِين', ['لِلْكَعْبَةِ كِسْوَتَها وَأَلْبَسا', 'لَكِنَّهُ بِدِينِهِ بَصِيرُ', 'أَنْصَارِهِمْ جَمِيعِهِمْ وَمُهَاجِرِين', 'فِي هَذِهِ العِيرِ الَّتِي مَرَّتْ بِهِمْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَاكَ صَالَحَ اليَهُودَا\nعَلَى السَّلَامِ كَتَبُوا العُهُودَا', ['جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ', 'مُحَمَّدٌ الهَادي رَسولُ اللهِ', 'وَالأَمْرُ بِالأَذَانِ لِلصَّلَاةِ', 'أَمَرَهُمْ فَأَقْبَلَ الْجَمَاعَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي السَّنَةِ الأُولَى بِذِي الحَيَاةِ', ['وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا', 'فَعَجَزُوا عَنْ سُورَةٍ وَهَرَبُوا', 'وَقَدْ رُؤِي فِي رُؤْيَةٍ مِنْ بَعْدِهَا', 'وَالأَمْرُ بِالأَذَانِ لِلصَّلَاةِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ حِقْدًا بَعْدَهُ اليَهُودُ', ['عَادَاهُ', 'عَشْرَةَ', 'عَبْدِ', 'عَدْنَانَ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَكِنَّهُمْ حَسَدًا لَهُ أَقَامُوا', ['وَدَلَّهُ الذِّئْبُ عَلَى الْأَمْرِ الْأَهَمْ', 'وَالبَعْضُ مِنْهُمْ بِالعَدَاوَةِ أَعْلَنَا', 'عَلَى بُغْضِهِمْ فَإِنَّهُمْ لِئَامُ', 'مُنَظِّمِينَ الْجَيْشَ بِالصُّفُوفِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَدُّوا بِأَنْ يَرْتَدَّ مَنْ قَدْ آمَنَا\nوَالبَعْضُ مِنْهُمْ بِالعَدَاوَةِ أَعْلَنَا', ['لِيُؤْمِنُوا يُصَدِّقُوا بِدِينِهِ', 'مِنْهُمْ حَيِّيٌّ كَانَ مِنْ أَحْبَارِهِمْ', 'حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد', 'فَتَكَلَّمَ الأَصْحَابُ حَتَّى سَرَّهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ أَنَّهُ يَعْرِفُ مِنْ أَخْبَارِهِمْ', ['وَاسْتَحْسَنَ الْأَشْيَاخُ عِنْدَ ذِكْرِهِمْ', 'لَكِنَّهُ أَبَى لَهُمْ تَسْلِيمَا', 'وَلَمْ يَكُنْ في نَسَبي سِفاحُ', 'مِنْهُمْ حَيِّيٌّ كَانَ مِنْ أَحْبَارِهِمْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِأَنَّ طَهَ ........ لِلْأَنْبِيَا', ['خَلْقِهِ', 'خَاتَمٌ', 'خَبَر', 'خَرَجَتِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحِينَمَا أَتَاهُمُ المُخْتَارُ', ['إِذَا بِهِمْ مَعَ عِلْمِهِمْ كُفَّارُ', 'حَتَّى أَتَى الْكَرَّارُ يَخْطُبُ فَاطِمَا', 'وَبَعدَهَا الْمِعْرَاجُ لِلسَّمَاءِ', 'لِطَيْبَةَ فِي صُحْبَةِ الصِّدِّيقِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَا قَدَرُوا اللهَ كَحَقِّ قَدْرِهِ\nوَخَالَفُوا مَا عِنْدَهُمْ مِنْ أَمْرِهِ', ['وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'فَإِنَّهُ الْمَذْكُورُ فِي الْكِتَابِ', 'وَحَاوَلُوا أَنْ يُوقِعُوا الخُصُومَة', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَا بَيْنَ أَصْحَابِهِ بِالنَّمِيمَة', ['وَحَاوَلُوا أَنْ يُوقِعُوا الخُصُومَة', 'فِي السَّنَةِ الثَّالِثَةِ كَانَتْ أُحُدْ', 'قَامَ بِهِ أَمَامَهُ يَخْتَالُ', 'إِنَّ اللهَ اشْتَرَى كَمَا فِي التَّوْبَةِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِتَعُودَ أَيَّامُ القِتَالِ ........', ['بِلا', 'بِهَذَا', 'بِقَتْلِ', 'بَيْنَهُمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِ مَا هَمُّوا إِلَى القِتَالِ', ['بِقُرْبِ أُحُدٍ مَعَ الْأَعْدَادِ', 'نَسَبٌ شَريفٌ بِالحَبيبِ تَكَرَّما', 'ذَكَّرَهُمْ طَهَ بِذِي الجَلَالِ', 'وَقَالَ أَرْجُو أَنْ يَكُونَ خَيْرًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَذَّرَهُمْ مِنْ دَعْوَى الجَاهِلِيَّةْ\nوَاللهُ قَدْ أَهْدَى لَهُمْ نَبِيَّهْ', ['وَمَا حَضَرَ فِيهَا خَيْرُ الخَلْقِ', 'وَتَزَيَّنَتْ بِمَنِ انْتَمَتْ شَرَفًا لَهُ', 'نَدِمُوا عَلَى مَا كَانَ مِنْ أَفْعَالِ', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَتَوَقَّفُوا عَنْ كُلِّ ذَا فِي الحَالِ', ['مَعَ قِلَّةِ الأَعْدَادِ عِنْدَ المُسْلِمِينْ', 'وَحِينَمَا أَتَاهُمُ المُخْتَارُ', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', 'نَدِمُوا عَلَى مَا كَانَ مِنْ أَفْعَالِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الرَّحْمَنُ فِيمَنْ كَانَا', ['وَاللِّوَاءُ', 'وَصَلَهَا', 'وَعَرَضَ', 'وَأَنْزَلَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَبْغُونَهَا عِوَجًا بِتِلْكَ الآيَةِ', ['بَيْنَهُمَا كانوا يُؤَرِّخُونَا', 'فِي آلِ عِمْرَانَ عَنِ الحِكَايَةِ', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ', 'وَصَلَهَا الهَادِي البَشِيرُ مُسَلِّمَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَذَلِكَ الأَنْصَارُ جَاءَتْ فِيهِمْ\nآيَاتُ قُرْآنٍ لَهُمْ تَهْدِيهِمْ', ['مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'قَصَّتْ عَلَى العَبَّاسِ مَا رَأَتْهُ', 'قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ', 'مِنْهَا وَأَنْتُمْ مُسْلِمُونَ اعْتَصِمُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبِحَبْلِ رَبِّ العَالَمِينَ تَمَسَّكُوا', ['قَدْ أَشْرَقَ الرَّبِيعُ بِالْأَنْوَارِ', 'وَصَدَّقَتْهُ آمَنَتْ بِدِينِهِ', 'جَاءَتْ إِلَى النَّبِيِّ ثُمَّ وَقَفَتْ', 'مِنْهَا وَأَنْتُمْ مُسْلِمُونَ اعْتَصِمُوا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي هَذِهِ السُّورَةِ أَيْضًا ........', ['فَطَلَبَ', 'فَرَبُّنَا', 'فَاتْلُهَا', 'فَنَقَضُوا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَاللهُ أَلَّفَ بَيْنَكُمْ مِنْ بَعْدِ مَا', ['ذَاتِ الْكَمَالَاتِ الْعِظَامِ الْكَامِنَة', 'فَأَرَادَ مُعْجِزَةْ فَنَادَى الشَّجَرَة', 'كُنْتُمْ أَعَادِي وَأَزَالَ النَّدَمَا', 'يُقَاتِلُونَ أَصْحَابَ الرَّسُولِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَصْبَحْتُمُ بِفَضْلِهِ إِخْوَانَا\nوَقَدْ كَفَاكُمْ رَبُّنَا النِّيرَانَا', ['فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي', 'تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ', 'وَبَعْدَ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَعَنُّتًا بَغْيًا كَمَا الحُسَّادِ', ['لِخَيْبَرَ حَيْثُ هُنَاكَ الْكَاهِنَة', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا', 'وَأَخَذَ بِسَيْفِهِ وَقَالَ لَهْ', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَانَ ........ ذَاتَ يَوْمٍ مَاشِيَا', ['أَلَّفَ', 'الشَّاهِدُ', 'النَّبِيُّ', 'الْمَنَّانِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَا تَسْأَلُوهُ حَتَّى لَا يُجِيبَكُمْ', ['حَقًّا فَتَكْرَهُونَ مَا يُصِيبُكُمْ', 'أَمْوَالَهُمْ لَكِنَّهُمْ سَيُغْلَبُون', 'ابْنُ مَظْعُونٍ أَعْلَنُوا الْإِيمَانَا', 'وَلا كَمِثْلِ هاشِمٍ بَني أَبِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَكِنَّهُمْ قَامُوا لَهُ وَقَالُوا\nمَا الرُّوحُ ثُمَّ أَجَابَهُمْ فَتَعَالَوْا', ['وَعَادَ أَهْلُ الْكُفْرِ بِالْخُيُولِ', 'وَحِينَ سَنَّ مُصْطَفَانَا الشُّورَى', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ أَنَّهُمْ بِكِتَابِهِمْ يَجِدُونَهَا', ['تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا', 'يَصْرُخُ فِي مَكَّةَ عِنْدَ الوَادِي', 'أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَيْضًا يَهُودِيَّانِ', ['وَجَاءَهُ', 'وَيَصِفُ', 'وَالبَيانِ', 'وَكُلِّ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَصَدَّقَاهُ وَقَبَّلَا رِجْلَيْهِ', ['وَبَشَّرَتْ لِعَمِّهِ قَدْ ثَبَتَا', 'وَبِحَبْلِ رَبِّ العَالَمِينَ تَمَسَّكُوا', 'وَيَدَيْهِ تَصْدِيقًا بِمَا لَدَيْهِ', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَمْ يَدْخُلَا الإِسْلَامَ قَدْ خَافَا عَلَى\nأَنْفُسِهِمْ مِنْ قَوْمِهِمْ أَنْ يُقْتَلَا', ['سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ', 'يَتَعَرَّفونَ عَلَى الحَبيبِ وَآلِهِ', 'وَغَيْرُ ذَا وَقَائِعُ كَثِيرَةْ'], 3),
  ],
  <PoemQ>[
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَلَى الَّتِي سَارَ فِيهَا أَصْحَابُهْ\nبِأَمْرِهِ لَهُمْ إِلَى أَعْدَائِهْ', ['وَاسْتَأْذَنَ المُخْتَارَ فِي الإِقَامَةِ', 'وَمَا حَضَرَ فِيهَا خَيْرُ الخَلْقِ', 'بَشَّرَهُمْ خَيْرُ الوَرَى مَا وَعَدَهْ', 'فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تِلْكَ المَغَازِي فِيهَا ذِكْرُ الأَوَّلِينْ', ['انْتَشَرَ الإِسْلاَمُ بَعْدَ وُقُوعِهَا', 'جِهَادُهُمْ فِي نَصْرِ هَذَا الدِّينْ', 'قَلَّلَ جَمْعَ الكُفْرِ فِي أَعْيُنِهِمْ', 'فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَمِيعُ مَنْ حَضَرُوا بِبَدْرٍ بُشِّرُوا', ['وَسَيِّدًا وَقَائِدًا عَظِيمًا', 'بِالعَفْوِ وَالغُفْرَانِ مَهْمَا يَفْعَلُوا', 'فَأَرَّخوا بِالحادِثِ الجَليلِ', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ سُمِّيَتْ فِي مُحْكَمِ القُرْآنِ\nفِي سُورَةِ الأَنْفَالِ بِالفُرْقَانِ', ['وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ', 'حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'وَأَمَرَ النَّبِيُّ لِلرُّمَاةِ', 'يَوْمَ التَقَى الجَمْعَانِ أَهْلُ الإِيمَانِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَتَعَرَّضُونَ ........ عِنْدَ طَرِيقِهِمْ', ['إِحْدَى', 'العَقْلِ', 'أَلْفِيَّةْ', 'العِيرَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِالإِذْنِ فِي ........ حَتَّى انْتَصَرُوا', ['القِتَالِ', 'أَرْبَعَةَ', 'إِلْياسَ', 'آمَنُوا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سِرًّا لِكَيْ يَكْتُمَ مَا حَكَتْهُ', ['عَنْ أَحَدِ الرُّعَاةِ كَانَ يَرْعَى', 'وَحِينَ سَنَّ مُصْطَفَانَا الشُّورَى', 'قَصَّتْ عَلَى العَبَّاسِ مَا رَأَتْهُ', 'لَكِنَّهُ أَبَى لَهُمْ تَسْلِيمَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَصْطَلَحَ الرُّوَاةُ فِي التَّسْمِيَةْ\nأَنْ يُطْلِقُوا تَعْرِيفَهُمْ سَرِيَّةْ', ['لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ', 'عَلَى الَّتِي سَارَ فِيهَا أَصْحَابُهْ', 'دَعَا لَهُمْ بِالخَيْرِ وَالهِدَايَةِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُقَاتِلُونَ فِي سَبِيلِ اللهْ\nيُؤْتِيهِمُ الجَنَّةَ فِي رِضَاهْ', ['حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'مِنْ بَعْدِ مَا ظُلِمُوا مِنَ الكُفَّارِ', 'ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', 'بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَرَجَ النَّبِيُّ بِدِرْعِهِ ذَاتِ الفُضُول\nوَبِسَيْفِهِ العَضْبِ تَقَلَّدَهُ الرَّسُول', ['خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ', 'وَدَعَا لِمَنْ مَعَهُ مِنَ الأَصْحَابِ', 'وَنَزَلَ النَّبِيُّ عِنْدَ رَأْيِهِمْ', 'أَدْعُوكُمُ بِالْوَحْيِ لِلتَّوْحِيدِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَقَدَ اللِّوَاءَ الأَبْيَضَ لِمُصْعَبَا\nوَالرَّايَتَانِ السَّوْدَاوَانِ ذَهَبَا', ['أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'يَخْشَى عَلَيْهِمْ مِنْ عَذَابِ اللَّهِ', 'وَهَكَذَا فَعَلُوا إِلَى أَنْ بَلَغَتْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَنُو إِسْرَائِيلَ لِمُوسَى وَأَسَاءَتْ', ['لَكِنَّهُ أَبَى لَهُمْ تَسْلِيمَا', 'وَنَزَلَتْ قُرَيْشٌ بَطْنَ الْوَادِي', 'وَلاَ نَقُولُ لَكَ كَمَا قَدْ قَالَتْ', 'فِي دَارِ أَرْقَمٍ كَانَ الْأَصْحَابُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَرَاهُمُ مَصَارِعَ الأَقْوَامِ\nفَكَانَ مَا قَالَ عَلَى التَّمَامِ', ['قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ', 'وَأَنْزَلَ اللهُ عَلَيْهِمْ مَطَرًا', 'كَذَاكَ فِي الثَّانِيَةِ وَغَيْرِهَا', 'وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَعَ قِلَّةِ الأَعْدَادِ عِنْدَ المُسْلِمِينْ\nوَكَثْرَةِ الأَعْدَادِ عِنْدَ المُشْرِكِينْ', ['تِلْكَ المَغَازِي فِيهَا ذِكْرُ الأَوَّلِينْ', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', 'لَمَّا الرُّمَاةُ خَالَفُوا الْأَوَامِرَا', 'وَامْتَنَّ رَبُّ العَالَمِينَ بِنَصْرِهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقَدْ رَأَتْ مَنْ ........ بِأَمْرِ', ['جَمِيعِهِمْ', 'جَمِيلَا', 'جِبْرِيلُ', 'جَاءَهُمْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَكَّةَ ........ بِمَا قَدْ حَصَلَا', ['يَمْنَعُكَ', 'يُقِيمَ', 'يُخْبِرُهُمْ', 'يَبْكِينَ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالنَّصْرُ فِيهَا لِلْقُلُوبِ الخَاشِيَة', ['وَجَاءَ وَحْشِيٌّ مِنْ أَهْلِ الْحَبَشَةِ', 'كَانُوا بِهِ مِنْ قَبْلِ بَعْثَتِهِ عَلَى', 'لِلْمُصْطَفَى وَصَحْبِهِ الْأَبْرَارِ', 'وَبَدْرٌ الكُبْرَى أَتَتْ بِالثَّانِيَة'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَمَا ........ القُرْآنَ', ['يُصِيبُكُمْ', 'يَسْلَمُوا', 'يُعَلِّمُوهُمُ', 'يُنَاوِلُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَتَكَلَّمَ ........ حَتَّى سَرَّهُ', ['الطَّاهِرِ', 'إِبْلِيسُ', 'الأَصْحَابُ', 'الْوُفُودُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاللهُ بِالأَمْلاَكِ قَدْ أَمَدَّهُمْ\nقَلَّلَ جَمْعَ الكُفْرِ فِي أَعْيُنِهِمْ', ['بَيْنَ الْمَقَاعِدِ وَبَيْنَهُمْ يَحُولْ', 'وَالمُصْطَفَى قَد أَخَّرَ الصِّدِّيقَا', 'فَكَانَ نَصْرًا ظَاهِرًا مُبِينًا', 'مَنْ عَلَّمَ الْإِنْسَانَ مَا لَمْ يَعْلَمِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَلَى الصَّلاَةِ ........ ابْنُ أُمٍّ', ['بَكَاهُ', 'بِالنَّبِيِّ', 'بِقَارِئٍ', 'بِأَهْلِهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الغَوْثَ هَيَّا سِيرُوا بِاسْتِعْدَادِ', ['اقْرَأْ بِإسْمِ رَبِّكَ الَّذِي خَلَقْ', 'يَصْرُخُ فِي مَكَّةَ عِنْدَ الوَادِي', 'فَأَبَتْ قُرَيْشٌ وَقَفَتْ وَمَنَعَتْ', 'بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَامْتَنَّ رَبُّ العَالَمِينَ بِنَصْرِهِ', ['لِلْمُسْلِمِينَ كَمَا أَتَى فِي ذِكْرِهِ', 'تَعَنُّتًا بَغْيًا كَمَا الحُسَّادِ', 'مَا قَدْ رَأَوْا وَخَالَفُوا الْحَبِيبَا', 'بِعَهْدِهِ مَعَ النَّبِيْ لَمْ يُبَالِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ\nالمُنْذِرُ المَقْصُودُ مِنْ خَيْرِ الصِّحَابْ', ['خَرَجَ النَّبِيُّ بِدِرْعِهِ ذَاتِ الفُضُول', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا', 'إِذْ بِي أَرَى عَلَيَّ مِنْ أَغْصَانِهَا', 'لَوْ أَنَّكَ أَعْتَقْتَ أَهْلَ الْقُوَّةِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'غَزَوَاتُهُ تِسْعٌ وَعِشْرُونَ سَفَرْ\nأَعْنِي الَّتِي بِنَفْسِهِ فِيهَا حَضَرْ', ['لَكِنَّهُ دَعَا لَهُمْ رَحِيمَا', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ', 'ثُمَّ السَّرَايَا سَبْعَةٌ وَأَرْبَعُونْ', 'قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا\nعَلِيِّ الكَرَّارِ وَالأُخْرَى مَعَا', ['سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ', 'لَمَّا الرُّمَاةُ خَالَفُوا الْأَوَامِرَا', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', 'فَظَلَّ يَحْفِرُهَا مِنَ الْأَيَّامِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَدَعَا لِمَنْ مَعَهُ مِنَ الأَصْحَابِ', ['سَارَ النَّبِيُّ قَاصِدًا بِغَزْوَتِهْ', 'أَعْنِي الَّتِي بِنَفْسِهِ فِيهَا حَضَرْ', 'نَبِيَّنَا وَحَمْزَةَ الْعَمَّ الْأَبَر', 'فَأَتَاهُ نَصْرُ الوَاحِدِ الوَهَّابِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِسَلاَمَةِ ........ وَمَا فِيهَا وَمَا', ['التَقَى', 'العِيرِ', 'الرَّؤُوفُ', 'الْجُمُعَةَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَمِثْلِهِمْ أَيْضًا ........ ظَفِرُوا', ['وَسَافَرَ', 'وَجْهِهِ', 'وَفِيهَا', 'وَالزُّبَيْرُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَا شَافِعًا لِلخَلْقِ فِي المِيعَادِ', ['وَعَرَضَ النَّبِيُّ سَيْفَهُ لِمَنْ', 'وَدَعَا لِمَنْ مَعَهُ مِنَ الأَصْحَابِ', 'وَرَأَتْ قُبَيلَ وُصُولِهِ عَاتِكَةُ', 'نَفْعَلُهَا يَا سَيِّدَ الأَسْيَادِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد\nنَمْضِي بِهَا لِبَرْكِ الغِمَاد', ['انْطَفَأَتْ نَارُ الحُرُوبِ بَيْنَهُمْ', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ', 'نَفْعَلُهَا يَا سَيِّدَ الأَسْيَادِ', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِالعُدْوَةِ ........ أَتَوْا بِجُمُوعِهِمْ', ['الْأَحْوَالُ', 'الْأَنَامَا', 'الصَّفَا', 'القُصْوَى'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَى المَدِينَةِ وَمَضَى الصَّحَابَةْ', ['وَعِنْدَ نُقْرَةِ الْغُرَابِ الْأَعْصَمِ', 'وَاسْتَعْمَلَ الهَادِي أَبَا لُبَابَةْ', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي هَذِهِ العِيرِ الَّتِي مَرَّتْ بِهِمْ', ['تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'لِأَنَّهَا هِيَ أَصْعَبُ الْبَهَائِم', 'لَمْ يَقْصِدُوا الحَرْبَ وَلَكِنْ مَالُهُمْ', 'وَجَاءَ وَفْدُ طَيْبَةَ وَآمَنُوا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَوْمٌ أَعَزَّ اللهُ فِيهِ دِينَهُ', ['حَتَّى أَتَاهُ الْإِذْنُ بِالْجَهْرِيَّة', 'أَنَا جَارُكُمْ زَيَّنْ لَهُمْ أَعْمَالَهُمْ', 'بْنِ الْمُنْذِرِ الصَّاحِبِ الْأَوَّابِ', 'وَأَذَلَّ دِينَ المُشْرِكِينَ أَهَانَهُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَتَحَدَّثَ العَبَّاسُ لِلوَلِيدِ', ['بَنُو إِسْرَائِيلَ لِمُوسَى وَأَسَاءَتْ', 'وَأَعَادَهَا الشَّرِيفُ جَدُّ الْمُؤْتَمَن', 'فَشَاعَ مَا رَأَتْهُ بِالتَّرْدِيدِ', 'نَرْجُو بِهِ مِنْ رَبِّنَا الْإِكْرَامَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي هَذِهِ الرُّؤْيَا قُبَيلَ وُقُوعِهَا', ['وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة', 'وَهَزِيمَةُ الكُفَّارِ قَدْ عَرَفَتْ بِهَا', 'لِيُلْبِسُوا البَاطِلَ ثَوْبَ الحَقِّ', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَمَا رَأَتْ بِالحَادِثِ ........', ['الشَّامِ', 'الخَطِير', 'الْمَكَاسِبَا', 'أَمَرَهُم'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ خَيْرُ الوَرَى مَا وَعَدَهْ', ['بِصِدْقِ', 'بَشَّرَهُمْ', 'بِالأَذَانِ', 'بِأَوَامِرِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لَيْسَ بِكَثْرَةِ الأَعْدَادِ', ['فِيكُمُ', 'فَكانَ', 'فَالنَّصْرُ', 'فَاقْرَأْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَامٍ مِنَ الهِجْرَةِ لِلمَدِينَةْ', ['مُفَتِّشًا عَن سَيِّدِ النُّبَلَاءِ', 'أَنَا جَارُكُمْ زَيَّنْ لَهُمْ أَعْمَالَهُمْ', 'وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'وَكَانَ رَبِّي دَائِمًا مُعِينَهْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ رَبُّنَا أَعَزَّ الدِّينَا', ['وَاسْتَعْمَلَ', 'وَاللهُ', 'وَبَعْلُهَا', 'وَحْيُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالمُصْطَفَى بِسُجُودِهِ يَدْعُو لَهُمْ', ['فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا', 'لَدَغَهُ الثُّعْبَانُ فِي ذَا الغَارِ', 'وَلَمْ يَزَلْ يَقُولُ كُلَّ حِينٍ', 'يَغْشَاهُمُ النُّعَاسُ تَأْمِينًا لَهُمْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَارَ إِلَى مَكَّةَ بِالأَخْبَارِ', ['تابَ عَلَيْهِ قَدْ أَتَتْ آياتْ', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ', 'هُوَ ضَمْضَمُ بْنُ عَمْرٍو الغِفَارِي', 'وَجَاءَ عَنْ أَبِي سَعِيدٍ الْخُدْرِيْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَعُبَيْدَةُ مَعَ عُصْبَةِ الكُفَّار', ['قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ', 'وَتَبَارَزَ الحَمْزَةُ وَالكَرَّار', 'أَبَى حَيَاءً أَنْ يُقِيمَ فَوْقَهُ', 'مِنْ أَيْنَ هَذَا اللَّبَنُ الَّذِي أَرَى'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ مَا عَلَى الأَذَى قَدْ ........', ['صَدْرِهِ', 'صَرَعَه', 'صِدْقِ', 'صَبَرُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعَلَى قُبَاءَ عَاصِمَ بْنَ عَدِي\nثُمَّ مَضَى بِجَيْشِهِ المَهْدِي', ['عَقَدَ اللِّوَاءَ الأَبْيَضَ لِمُصْعَبَا', 'وَأَنْزَلَ الرَّحْمَنُ فِيمَنْ كَانَا', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة', 'كَمَا أَتَى فِي آلِ عِمْرَانَ وَإِذْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ........ الدُّخَانِ نَصًّا مُحْكَمًا', ['سُورَةِ', 'سَبَبُهَا', 'سَيْفَهُ', 'سَلْمانَ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَنَا جَارُكُمْ زَيَّنْ لَهُمْ أَعْمَالَهُمْ', ['هَذَا هُوَ الْحَبِيبُ وَالصِّدِّيقُ', 'وَكانَ جَدُّ المُصْطَفى كِنانَة', 'وَجَاءَهُمْ إِبْلِيسُ وَقَالَ لَهُمْ', 'وَاسْتَأْذَنَ المُخْتَارَ فِي الإِقَامَةِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'طَهَّرَهُمْ بِهِ كَمَا قَدْ ........', ['أَسْدَتْ', 'أَخْبَرَا', 'أَعْجَبُ', 'النَّبِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَا ........ وَفَزِعُوا وَأَسْرَعُوا', ['قَدَّمَهُ', 'قُرَيْشًا', 'قَامَا', 'قَالَهُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمَا حَضَرَ فِيهَا خَيْرُ ........', ['الخَلْقِ', 'الإِيمَانِ', 'السَّرَايَا', 'الْوَحْيُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَكْرِمْ بِرَبٍّ قَادِرٍ قَهَّارِ', ['فَفَرِحُوا وَسَارَعُوا بِالْجِدِّ', 'سَارَ مَعَ مَيْسَرَةَ الْغُلَامِ', 'مِنْ بَعْدِ مَا ظُلِمُوا مِنَ الكُفَّارِ', 'فِي شَهْرِ مِيلَادِ الحَبِيبِ الهَادِي'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَذِنَ الرَّحْمَنُ بِالقِتَالِ\nلِلمُصْطَفَى فِي صَفَرٍ مِنْ تَالِي', ['عَامٍ مِنَ الهِجْرَةِ لِلمَدِينَةْ', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ', 'صَلَّى بِهِمُ الْجُمُعَةَ وَعَظَهُمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'انْتَشَرَ الإِسْلاَمُ بَعْدَ وُقُوعِهَا', ['لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا', 'هِيَ أَعْظَمُ الغَزَوَاتِ ذَاكَ لِأَنَّهَا', 'يَبْكِينَ مَا كَانَ بِيَوْمِ بَدْرِ', 'وَقَدْ رَأَى النَّبِيُّ فِي الْمَنَامِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَمْ يَتَخَلَّفْ مِنْهُمُ إِلاَّ القَلِيل\nمَنْ يَعْتَذِرْ يُرْسِلْ إِلَى الحَرْبِ بَدِيل', ['فَكَانَ مَا رَأَى عَلَى التَّمَامِ', 'كُبَرَاءُ هَذَا الحَيِّ سَارُوا كُلُّهُمْ', 'أَضَاءَ مِنْهَا كُلُّ شَيْءٍ عِنْدَمَا', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'صَدًّا عَنِ الدِّينِ الحَنِيفِ يُنْفِقُون', ['وَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ', 'إِلَى عَلِيّ الطَّاهِرِ الْمُقَرَّبِ', 'أَمْوَالَهُمْ لَكِنَّهُمْ سَيُغْلَبُون', 'يُحَكِمُوهَا فِي الْأُمُورِ الرَّاهِنَة'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَعْدَادُهُمْ أَلْفٌ وَكَانَ المُؤْمِنُون', ['كَثُلْثِهِمْ لَكِنَّهُمْ يَتَغَلَّبُون', 'وَمَعَهُمْ خَمْسِينَ ثُمَّ أَنْبَأَهُ', 'مَنَّوْا عَلَيْهِ فِيهَا بِالْحُرِّيَّة', 'خَيْرِ الْأَنَامِ أَحْمَدَ الَّذِي عَلَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَرِيَّةٌ وَقِيلَ بَلْ هِيَ سَبْعُونْ', ['نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'مَضَى إِلَى سَبِيلِهِ كَرِيمًا', 'ثُمَّ السَّرَايَا سَبْعَةٌ وَأَرْبَعُونْ', 'لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ', ['عَنْ ذَلِكَ المَبْعوثِ وَيُنْبِئُهُمْ', 'فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', 'سِوَى القَلِيلِ عِنْدَ بَعْضِ القَوْمِ', 'فَرَضِيَ بِمَا قَالَ النَّبِيْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَادَ بَنُو زُهْرَةَ لَمْ يُقَاتِلُوا', ['فِي وَسَطِ الطَّرِيقِ حِينَ عَلِمُوا', 'وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'أَمْلَاكُهَا مَعَ آدَمَ الْجَلِيلَا', 'دُسْتُورُ هَذَا الدِّينِ وَالْبَيَانُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كُبَرَاءُ هَذَا الحَيِّ سَارُوا ........', ['كانوا', 'كَذاكَ', 'كُلُّهُمْ', 'كَانَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَقْضِي بِهَا فِي جَيْشِهِ الأُمُورَا', ['بِنَفْسِهِ الصِّدِّيقُ قَد فَدَاهُ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'وَحِينَ سَنَّ مُصْطَفَانَا الشُّورَى', 'قَامُوا لَهُ وَأَوْجَعُوهُ ضَرْبَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'امْضِ لِمَا قَدْ أَمَرَكَ الرَّحْمَن\nنَحْنُ مَعَكَ يَا صَاحِبَ القُرْآن', ['قَالَ النَّبِيُّ إِنَّ فِي أَهْلِ الْغَنَمْ', 'وَلاَ نَقُولُ لَكَ كَمَا قَدْ قَالَتْ', 'كَفَلَهُ مِنْ بَعْدِ مَوْتِ أُمِّهِ', 'قالَ لَهُ بِمُحَمَّدٍ آمِنْ وَمُرْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَرَأَتْ قُبَيلَ وُصُولِهِ عَاتِكَةُ', ['لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', 'فِي كُتْبِ الأَخْبَارِ وشَهِيرَةْ', 'لَكِنَّهُ عَنْ عَطْفِهِ مَا عَزَفَا', 'رُؤْيَا وَمَعْنَاهَا هُنَاكَ مُصِيبَةُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ جَمْعِ أَهْلِ الشِّرْكِ وَالأَوْثَانِ', ['وَانْطَلَقَ النَّبِيُّ نَحْوَ طَيْبَة', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ', 'فَذَهَبَ الرَّاعِي إِلَى الْمَدِينَةِ', 'يَوْمَ التَقَى الجَمْعَانِ أَهْلُ الإِيمَانِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَنْفُسَهُمْ كَذَا مَالَ الصَّحَابَةِ', ['إِنَّ اللهَ اشْتَرَى كَمَا فِي التَّوْبَةِ', 'أَوْحَى إِلَيْهِ اللَّهُ مَا أَوْحَاهُ', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'يُقَاتِلُونَ فِي سَبِيلِ اللهْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نَبِيَّهُ وَكُلَّ مَنْ قَدْ ........', ['آزَرَا', 'الخَليلَ', 'السَّيْفُ', 'النُّعَاسِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَالَتِ الأَنْصَارُ فَلْتَمْضِي بِنَا\nلِمَا أَمَرَكَ اللهُ يَا حَبِيبَنَا', ['حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد', 'عَاشُوا هُنَاكَ عِيشَةً سَعِيدَة', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'فَوَصَلَ الْكِتَابُ فِي قُبَاءَ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَتَبَارَزَ ........ وَالكَرَّار', ['إِنَّهَا', 'أَخْبرا', 'العِلْمِ', 'الحَمْزَةُ'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَنَزَلَتْ قُرَيْشٌ بَطْنَ ........', ['أَهْلِهَا', 'الْوَادِي', 'العَرُوبَةِ', 'التَّوفِيقُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِالنَّصْرِ إِذَا صَبَرُوا', ['الْحِمْيَرِيَّ', 'أَخْبَرَهُمْ', 'الشُّورَى', 'التَّمَامِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَقُتِلَ الْحَمْزَةُ ثُمَّ مُصْعَبُ', ['مَنْ يَعْتَذِرْ يُرْسِلْ إِلَى الحَرْبِ بَدِيل', 'وَاللهُ مِنْ أَنْوَارِهِ طَرَّزَهَا', 'ابْنُ عُمَيْرٍ وَالْجَمِيعُ يَعْجَبُ', 'وَلَدٍ يُسَاعِدُهُ عَلَى عَيْشِ الزَّمَن'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَوْقَعُوا الْعَدُوَّ فِي الْهَزِيمَةْ', ['أَسْبابَ تَنْزيلٍ وَكُلَّ مَكانِ', 'قَدْ أَضْمَرُوا النِّفَاقَ دُونَ صِدْقِ', 'في صُلْبِهِ يُلَبّي مَنْ سَيَشْفَعُ', 'وَأَقْبَلُوا لِيَجْمَعُوا الْغَنِيمَةْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'إِيَّاكُمُ أَنْ تَتْرُكُوا مَكَانَكُمْ\nإِذَا انْتَصَرْنَا إِلَّا إِنْ أَمَرْتُكُمْ', ['لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ', 'وَابْنُ سَلُولٍ عَادَ بِالْمُنَافِقِينْ', 'إِذَا قُتِلْنَا فَلَا تَنْصُرُونَا', 'مَا قَدَرُوا اللهَ كَحَقِّ قَدْرِهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَجَهَّزُوا الْجَيْشَ بِرِبْحِ الْمَالِ\nخَمْسِينَ أَلْفًا جَاءُوا بِالرِّجَالِ', ['وَمَعَهُمْ قَبَائِلُ الْحُلَفَاءِ', 'يُحَرِّضْنَ الْقَوْمَ لِلْقِتَالِ', 'وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', 'وَمَواقِفُ الأَصْحابِ كَيْفَ تَحَمَّلوا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَامَ بِهِ أَمَامَهُ يَخْتَالُ\nفَأَعْجَبَتْهُ هَذِهِ الْأَحْوَالُ', ['فِي السَّنَةِ السَّادِسَةِ لِلدِّينِ', 'إِذَا قُتِلْنَا فَلَا تَنْصُرُونَا', 'قَاتَلَ بِالسَّيْفِ بِلَا فِرَارِ', 'مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى النَّبِيْ وَالصَّحْبِ وَالْأَنْصَارِ', ['مِنْهَا وَأَنْتُمْ مُسْلِمُونَ اعْتَصِمُوا', 'وَجَاءَ بَعْدَ ثَلاَثٍ النَّذِير', 'وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'وَكَتَبَ الْعَبَّاسُ بِالْأَخْبَارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْهُمْ فَرَبِّي بِالْحَنَانِ ........', ['أَوْلَى', 'أَحَدٍ', 'الْأَيَّامِ', 'إِلَهِنَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَمَعَهُمْ قَبَائِلُ الْحُلَفَاءِ', ['بِقَرَارِيطَ مَوْضِعٌ لِذِي النَّظَرْ', 'أَتَوْا لَهُمْ مِنْ كَافَّةِ الْأَنْحَاءِ', 'بِأُمِّ خَيْرِ الْخَلْقِ قَدْ تَنَوَّرَتْ', 'إِلْياسَ فَاسْتَجيبوا وَأَحِبّوا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَمَرَ النَّبِيُّ لِلرُّمَاةِ\nحِمَايَةَ الظُّهُورِ وَالثَّبَاتِ', ['قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين', 'لَمَّا الْتَقَى الْجَمْعَانِ مَنْ تَوَلَّى', 'إِيَّاكُمُ أَنْ تَتْرُكُوا مَكَانَكُمْ', 'وَتَبَارَزَ الحَمْزَةُ وَالكَرَّار'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'هُمُ الْمُهَاجِرُونَ وَالْأَنْصَارُ', ['عَلَى بُغْضِهِمْ فَإِنَّهُمْ لِئَامُ', 'ابْنُ مَظْعُونٍ وَمَسْعُودٌ أَسْرَعَا', 'سَارَ بِهِمْ لِذَلِكَ الْمَكَانْ', 'وَثَلَاثَةُ آلَافٍ الْكُفَّارُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'رُؤْيَا وَقَصَّهَا عَلَى الْأَقْوَامِ', ['وَقَدْ رَأَى النَّبِيُّ فِي الْمَنَامِ', 'اقْرَأْ بِإسْمِ رَبِّكَ الَّذِي خَلَقْ', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ', 'إِلَى أَبِي سُفْيَانَ يَشْتَكُونَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَرَضَ النَّبِيُّ سَيْفَهُ لِمَنْ', ['وَبِالْبَنَاتِ ثُمَّ بِالْأَحْفَادِ', 'في صُلْبِهِ يُلَبّي مَنْ سَيَشْفَعُ', 'بِمَا لَهُ بِيَوْمِ بَدْرٍ قَدْ جَرَى', 'يَأْخُذُهُ بِحَقِّهِ بِلَا وَهَنْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِلَى أَبِي سُفْيَانَ ........', ['يَشْتَكُونَا', 'يَدُلُّهُم', 'يَتَغَلَّبُون', 'يَحْفِرُهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَارَ بِهِمْ لِذَلِكَ الْمَكَانْ', ['يُعْرَفُ فِي قَوْمِهِ بِالْمُصَارَعَة', 'لِأَنَّهَا هِيَ أَصْعَبُ الْبَهَائِم', 'وَكَانَ قَائِدُهُمْ أَبُو سُفْيَانْ', 'مَرَّ عَلَيْهِ الْمُصْطَفَى فِي الْوَادِي'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَتْلِهِمْ لِقَائِدِ الْكُفَّارِ\nحَامِلْ لِوَاهُمْ بِيَدِ الْكَرَّارِ', ['وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ', 'فَكَانَ مِمَّنْ أَعْتَقَ بِلَالَا', 'وَأُوِّلَ الدِّرْعُ أَيْ الْحَصِينَةُ', 'وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَلَقَدْ عَفَا عَنْكُمْ أَتَتْنَا آيَةْ\nتَرْوِي لَنَا الْقِصَّةَ وَالْحِكَايَةْ', ['خَافَتْ حَلِيمَةُ عَلَيْهِ عِنْدَهَا', 'فِي آلِ عِمْرَانَ بِقَوْلِ اللَّهِ', 'فَجَاءَ جِبْرِيلُ الْأَمِينُ رَافِعًا', 'مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ظَنُّوا بِرَبِّ الْعَرْشِ غَيْرَ الْحَقِّ', ['جَاءَ الْعَدُوُّ لِلسُّيُوفِ شَاهِرَا', 'مَعَ عَلِيٍّ أَبْيَضًا لِوَانَا', 'هِيَ الَّتِي أَسْدَتْ لَهُ عَطَاءَهَا', 'قَدْ أَضْمَرُوا النِّفَاقَ دُونَ صِدْقِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أُسَيْدَ بْنَ حُضَيْرٍ وَدَفَعَا', ['وَعَقَدَ النَّبِيْ لِوَا الْأَوْسِ مَعًا', 'وَأَصْلَحَ النَّبِيُّ بَيْنَ أَهْلِهَا', 'وَقَتَلُوا جَمْعًا مِنَ الْأَصْحَابِ', 'وَحِينَمَا أَتَاهُمُ المُخْتَارُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَمَّا الرُّمَاةُ خَالَفُوا الْأَوَامِرَا', ['وَلَدٍ يُسَاعِدُهُ عَلَى عَيْشِ الزَّمَن', 'وَرَجَعُوا مِنْ فَوْرِهِمْ وَأَيْقَنُوا', 'جَاءَ الْعَدُوُّ لِلسُّيُوفِ شَاهِرَا', 'وَعَنْهُ حَقًّا أَبْعَدَ الحُسَّادَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَأَدُّبًا مَعَ سَيِّدِ الشُّفَعَاءِ', ['لِيَعْرِفَ النَّاسُ جَمِيعًا قَدْرَهَا', 'سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ', 'عَبْدُ مَنَافٍ جَدُّهَا وَزُهْرَة', 'وَقَدْ أَجَلَّهُ عَنِ النِّسَاءِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'نَبِيُّنَا فِي النِّصْفِ مِنْ شَوَّالِ', ['خَدِيجَةُ مِنْ قَلْبِهِ قَرِيبَةُ', 'وَلَم يَرَوْهُ أُغْشِيَت أَبْصَارُهُم', 'إِذَا بِهِمْ مَعَ عِلْمِهِمْ كُفَّارُ', 'مَعَ خِيَرَةِ الْأَصْحَابِ وَالرِّجَالِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ', ['فِي أَنْ يَكُونَ زَوْجَهَا فَغَنِمَتْ', 'مِنْ مُعْجِزَاتِ سَيِّدِ الْأَنَامِ', 'فِي شَهْرِ شَوَّالٍ وَقَدْ زَادَ الْعَدَد', 'عَلَى الوَفَاءِ وَالهُدَى مُؤَكَّدَة'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعَادَ أَهْلُ الْكُفْرِ بِالْخُيُولِ\nيُقَاتِلُونَ أَصْحَابَ الرَّسُولِ', ['يَخْرُجُ فِي وَقْتِ كَذَا عَنْ وَقْتِهِ', 'فَقُتِلَ الْحَمْزَةُ ثُمَّ مُصْعَبُ', 'فِي أَرْضِ الْأَبْوَاءِ الَّتِي تَشَرَّفَتْ', 'وَعِنْدَ نُقْرَةِ الْغُرَابِ الْأَعْصَمِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أُوْلَاهَا بِقَتْلِ بَعْضِ صَحْبِهِ', ['عَلَيَّ دَوْمًا نَاطِقًا يَتَكَلَّمُ', 'وَرَجُلٍ مِنْ آلِهِ حَبِيبِهِ', 'إِلَى رُؤُوسٍ لِلْجِبَالِ ذَهَبُوا', 'الرُّعْبَ ثُمَّ خُمِّسَتْ أَمْوَالُهُمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ثُمَّ عَلِيًّا لِوَاءَ الْمُهَاجِرِينْ', ['ثُمَّ دَنَا مِنْ رَبِّهِ مُشَافِهَا', 'ثُمَّ أَعْطَاهُ لِمُصْعَبٍ مِنْ بَعْدِ حِينْ', 'وَفِي الْهِجْرَةِ وَالْغَارِ الرَّفِيقُ', 'حَجَرًا بِمَكَّةَ لَهُ وَيَصِفُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَصَحْبِهِ مِنْ ظُلْمَةِ الْفُؤَادِ', ['حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'مَا هَمَّهُمْ أَمْرُ النَّبِيِّ الْهَادِي', 'بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ', 'وَالأَمْرُ بِالأَذَانِ لِلصَّلَاةِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مَضَيْنَ مِنْ شَوَّالِ', ['لِقَتْلِهِ', 'لَاقَوْهُ', 'لِأَنَّهَا', 'لِخَمْسَةٍ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَرَأَ مَا فِيهِ لِلنَّبِيِّ', ['فَتَحَهُ أُبَيُّ بْنُ كَعْبِ', 'إِنْ جَاءَ فِي يَوْمٍ يَكُونُ النَّصْرُ', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ', 'لَوْ أَنَّ رَبَّ الْعَرْشِ عَشَرًا وَهَبَه'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بْنِ ........ الصَّاحِبِ الْأَوَّابِ', ['الْكُفَّارِ', 'الْأَجْلَّا', 'أَقْبَلا', 'الْمُنْذِرِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَلَمْ يُسَاعِدْ عُصْبَةَ الْكُفَّارِ', ['فِي مَبْرَكِ نَاقَتِهِ أُقِيمَا', 'بِمَالِهِ بَلْ جَاءَ بِالْأَخْبَارِ', 'أَرْبَعَةً فَأَسْعَدِ الْأَيَّامَا', 'مِنَ النَّبِيِّ الهَاشِمِيْ مُعْتَبِرَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَاتَلَ بِالسَّيْفِ بِلَا فِرَارِ\nكَأَسَدٍ فِي أَعْيُنِ الْكُفَّارِ', ['رَأَى عَلَامَاتٍ بَدَتْ جَلِيَّةً', 'قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة', 'وَجَدُّهُ عَدْنانُ أَوَّلُ مَنْ كَسا', 'وَقَدْ أَجَلَّهُ عَنِ النِّسَاءِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَخَذَهُ مِنْهُ أَبُو دُجَانَةْ', ['فِي الْكُتُبِ الصَّحِيحَةِ الْمُسَطَّرَة', 'فَانْقَلَبَ الْأَمْرُ بِقَتْلٍ قَدْ حَصَلْ', 'فَكَانَ حَقًّا أَهْلًا لِلْأَمَانَةْ', 'وَعَادَ زَوْجُهَا عَلَيْهِ العَجَبُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَكِنْ عَفَا اللَّهُ عَنِ الْأَحْبَابِ', ['وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'وَجَاءَهُ جِبْرِيلُ شَقَّ صَدْرَهُ', 'عَلَى الَّتِي سَارَ فِيهَا أَصْحَابُهْ', 'وَقَتَلُوا جَمْعًا مِنَ الْأَصْحَابِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِذَا قُتِلْنَا فَلَا ........', ['تَكَرَّما', 'تَنْصُرُونَا', 'تَبَلَّلَتْ', 'تَعْظِيمِهِمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَنَزَلَ النَّبِيُّ عِنْدَ رَأْيِهِمْ\nلِصِدْقِ مَا رَآهُ مِنْ وِلَائِهِمْ', ['فَأَنْصَتُوا وَسَارَعُوا لِقَوْمِهِمْ', 'فِي السَّنَةِ السَّادِسَةِ لِلدِّينِ', 'صَلَّى بِهِمُ الْجُمُعَةَ وَعَظَهُمْ', 'سَارَ إِلَيْهِمْ مَعَهُ أَرْبَعُمِائَةْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَانَ ضَارِبًا فِيهِمْ بِحَرْبَةِ', ['وَجَاءَ وَحْشِيٌّ مِنْ أَهْلِ الْحَبَشَةِ', 'فَكَانَ نَصْرًا ظَاهِرًا مُبِينًا', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', 'فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَانْتَصَرَ الْأَصْحَابُ فِي الْبِدَايَةِ\nنَصْرًا عَظِيمًا جَاءَ فِي الرِّوَايَةِ', ['قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا', 'فَأَوْقَعُوا الْعَدُوَّ فِي الْهَزِيمَةْ', 'فَهَاجَرَ الأَصْحَابُ نَحْوَهُم لَمَّا', 'يُدَافِعُ عَنْهُ مِنْ الْأَقْوَامِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَوَصَلَ ........ فِي قُبَاءَ', ['الْهَاشِمِيِّ', 'الْأُمَمْ', 'الْفَاعِلُ', 'الْكِتَابُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَنَّوْا ........ فِيهَا بِالْحُرِّيَّة', ['عَلَيْهِ', 'عَامِ', 'عَبْدِ', 'عَمِي'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَنَزَلَ الرُّمَاةُ مِنْ فَوْقِ الْجَبَلْ', ['أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'فَانْقَلَبَ الْأَمْرُ بِقَتْلٍ قَدْ حَصَلْ', 'لِلْعَالَمِينَ طَيِّبًا مُفَضَّلًا', 'كَمَا يُعَلِّمُوهُمُ القُرْآنَ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمَعَهُنَّ خَرَجَتِ النِّسَاءُ\nوَقَصْدُهُنَّ النَّوْحُ وَالْبُكَاءُ', ['لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا', 'وَقَدْ رَأَتْ مَنْ جَاءَهُمْ بِأَمْرِ', 'يَبْكِينَ مَا كَانَ بِيَوْمِ بَدْرِ', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَمْنٌ مِنَ النُّعَاسِ بَيْنَ الْقَوْمِ', ['سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا', 'فَقَتَلُوا سَبْعِينَ ثُمَّ أَسَرُوا', 'ثُمَّ أَتَاكُمْ مِنْهُ بَعْدَ الْغَمِّ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَرَفَضَ النَّبِيُّ مَنْ أَتَاهُ', ['مِنَ الْيَهُودِ حِينَهَا أَبَاهُ', 'وَبِقَوْمِهِ كَانَ الأَمِينَ مُلَقَّبَا', 'لَكِنَّهَا نَالَتْ بِهِ الْأَفْضَالَا', 'مَعَ أَنَّهُمْ بِكِتَابِهِمْ يَجِدُونَهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَتَلَهُ الْكُفَّارُ حَتَّى وَقَفَا', ['يُعْطُونَهُ وَلَدًا لَهُمُ مَكَانَهْ', 'وَظَنَّ بَعْضُ النَّاسِ أَنَّ الْمُصْطَفَى', 'وَكَانَ مَنْ عَادُوا ثَلَاثَمِائَةً', 'حَتَّى آتَاهُ اللَّهُ بَعْدَ عَشَرَةْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنْ ........ وَيُنْقِذُوا أَنْفُسَهُمْ', ['يُبَالِ', 'يَذْبَحَه', 'يَأْتِي', 'يَسْلَمُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِالِاجْتِهَادِ وَالصَّبْرِ أَمَرَهُمْ', ['وَأَجَابَهُ عَنْ قَوْمِهِ بِأَسْلَمَا', 'لِمَن يَدُلُّهُم عَلَى نَبِيِّنَا', 'صَلَّى بِهِمُ الْجُمُعَةَ وَعَظَهُمْ', 'فَذَهَبَ الرَّاعِي إِلَى الْمَدِينَةِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُنَظِّمِينَ الْجَيْشَ بِالصُّفُوفِ', ['وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ', 'وَسَارُوا بِالْقِيَانِ وَالدُّفُوفِ', 'وَعَلَى الصَّلاَةِ بِأَهْلِهَا ابْنُ أُمٍّ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'اجْتَمَعَ النَّاسُ بِدَارِ النَّدْوَةِ\nبِكُلِّ أَهْلِ الْمَالِ وَالتِّجَارَةِ', ['وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', 'وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ', 'إِلَى أَبِي سُفْيَانَ يَشْتَكُونَا', 'مِنْ بَعْدِهِ خُزَيْمَةُ وَمُدْرِكَةْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي آلِ عِمْرَانَ بِقَوْلِ اللَّهِ', ['وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', 'أَجَابَ كَلَّا إِنَّنِي أُمِّيُّ', 'كَمَا رَأَتْ بِالحَادِثِ الخَطِير', 'إِذْ تُصْعِدُونَ بِغَيْرِ مَا اشْتِبَاهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثَانِي عَشَرَ مِنْهُ بِلَا جِدَالٍ', ['فِي يَوْمِ الْأَرْبِعَاءِ مِنْ شَوَّالٍ', 'وَحِينَ سَنَّ مُصْطَفَانَا الشُّورَى', 'لَدَغَهُ الثُّعْبَانُ فِي ذَا الغَارِ', 'وَجَاءَ بَعْدَ ثَلاَثٍ النَّذِير'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَكِنَّ رَأْيَ غَالِبِ الْأَنْصَارِ', ['فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا', 'فَاتَّبِعوهُ كَيْ تَنالوا الرَّشَدا', 'أَجَابَهُ ابْنُ مَسْلَمَةْ أَنَا لَهَا', 'كَانَ الْخُرُوجَ لِلِقَا الْكُفَّارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْخُرُوجَ ثُمَّ اعْتَذَرَا', ['وَرَفَضَ', 'وَبَدْرٌ', 'وَكَذا', 'وَتَزَيَّنَتْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَعْضُهُمْ مِنْ غَيْرِ نَوْمٍ وَاقِفَةْ', ['يَغْشَى بِفَضْلِ اللَّهِ مِنْهُمْ طَائِفَةْ', 'أَمَرَهُم خَيرُ الوَرَى أَن يَفتَحُوا', 'وَكَانَ ذَاكَ الأَمرُ حِينَ ذَهَبَا', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَالَ أَرْجُو أَنْ يَكُونَ خَيْرًا', ['فَجَاءَ سَعْدُ بْنُ الرَّبِيعِ مُخْبِرًا', 'مُحَمَّدٌ الهَادي رَسولُ اللهِ', 'قَدْ صَدَّقُوهُ بِالْقُلُوبِ لَكِنْ', 'وَآمَنَتْ مِنَ النِّسَاءِ أَوَّلًا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَنَا الرَّسُولُ أَنَا عَبْدُ الْمُطَّلِبْ', ['سَأَلَهُ النَّبِيُّ عَنْ شَاةٍ بِهَا', 'قَالَ أَنَا النَّبِيُّ حَقًّا لَا كَذِبْ', 'كانَ عَلى دينِ النَّبِيِّ إِسْماعيل', 'وَجَاءَهُ جِبْرِيلُ شَقَّ صَدْرَهُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأُوِّلَ الدِّرْعُ أَيْ الْحَصِينَةُ\nبِأَنَّ هَذِهِ هِيَ الْمَدِينَةُ', ['فَكَانَ مَا رَأَى عَلَى التَّمَامِ', 'وَخُطِبَتْ فَاطِمَةُ مِنَ النَّبِيْ', 'فَسَارَ نَحْوَ الْقُدْسِ ثُمَّ صَلَّى', 'قَلَّبْتُ شَرْقَ الأَرْضِ ثُمَّ المَغْرِبا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَبْكِينَ مَا كَانَ بِيَوْمِ بَدْرِ', ['فَنَشَرَ نَبِيُّنَا ثِيَابَهْ', 'آيَاتُ قُرْآنٍ لَهُمْ تَهْدِيهِمْ', 'الشِّرْكُ وَالْعِنَادُ فِيهَا سَاكِنْ', 'مِنْ قَتْلِ أَهْلِهِنَّ أَوْ مِنْ أَسْرِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ........ الثَّالِثَةِ كَانَتْ أُحُدْ', ['السَّنَةِ', 'أَيّامُهُ', 'الْعَبَّاسُ', 'اللَّهُمَّ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَنْ بَقِيَ فِي الْجَيْشِ سَبْعَمِائَةً', ['أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'وَكَانَ مَنْ عَادُوا ثَلَاثَمِائَةً', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ غَمًّا بِغَمٍّ كَيْلَا', ['فَتَعَالَوْا', 'فَأَسْلَمَتْ', 'فُهَيْرَةَ', 'فَأَثَابَكُمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَرْسَلَ النَّبِيُّ لِإبْنِ سَلُولْ', ['وَعَادَ زَوْجُهَا عَلَيْهِ العَجَبُ', 'تَأَلُّفًا لَهُ يَرَى مَاذَا يَقُولْ', 'مِنْ رَبِّهِ تَلَقّى لِلْكَلِماتْ', 'أُمَّتَكَ أَنْ يُؤْمِنوا كُلٌّ يُقِرّ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَفَرِحُوا وَسَارَعُوا بِالْجِدِّ\nمُسْتَقْبِلِينَ يَوْمَهُمْ بِالسَّعْدِ', ['حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا', 'هِيَ أَعْظَمُ الغَزَوَاتِ ذَاكَ لِأَنَّهَا', 'وَعَقَدَ النَّبِيْ لِوَا الْأَوْسِ مَعًا', 'لَمْ يَتَخَلَّفْ مِنْهُمُ إِلاَّ القَلِيل'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'كَانَ يَرَى الْمُقَامَ فِي الْمَدِينَةْ\nفَإِنَّهَا آمِنَةٌ حَصِينَةْ', ['حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا', 'غَزَوَاتُهُ تِسْعٌ وَعِشْرُونَ سَفَرْ', 'حَتَّى أَتَى الْوَحْيُ مِنَ الرَّحْمَنِ', 'لَكِنَّ رَأْيَ غَالِبِ الْأَنْصَارِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقِيلَ بَلْ لِسَعْدِ بْنِ عُبَادَةْ\nوَكُلُّهُمْ ظَفِرَ بِالسَّعَادَةِ', ['وَابْتَدَأَ الدُّخُولُ مِنْ قُبَاءَ', 'ثُمَّ عَلِيًّا لِوَاءَ الْمُهَاجِرِينْ', 'أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِثُلُثِ الْجَيْشِ وَعَادُوا خَائِبِينَ', ['حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'وَابْنُ سَلُولٍ عَادَ بِالْمُنَافِقِينْ', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمَكَثُوا الْخَمِيسَ ثُمَّ الْجُمُعَةْ\nفَخَرَجَ إِلَيْهِمُ بِمَنْ مَعَهْ', ['وَرَفَضَ الْخُرُوجَ ثُمَّ اعْتَذَرَا', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ', 'نَبِيُّنَا فِي النِّصْفِ مِنْ شَوَّالِ', 'فَجَاءَهُمْ طَيْرٌ أَبَابِيلُ وَمَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَهُمُ الْمُنَافِقُونَ كَانَ مُرَادُهُمْ', ['المُنْذِرُ المَقْصُودُ مِنْ خَيْرِ الصِّحَابْ', 'وَشَرِبَ النَّبِيُّ طَهَ المُؤْتَمَن', 'أَنْ يَسْلَمُوا وَيُنْقِذُوا أَنْفُسَهُمْ', 'وَأَكْمَلُوا طَرِيقَهُمْ جَمِيعًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَخَذَهُ مِنْهُ أَبُو دُجَانَةْ\nفَكَانَ حَقًّا أَهْلًا لِلْأَمَانَةْ', ['في شَأْنِ آباءِ النَّبِيِّ نَقَلوا', 'قَامَ بِهِ أَمَامَهُ يَخْتَالُ', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', 'وَغَيْرُهُمْ أَيْضًا كَثِيرٌ آمَنُوا'], 1),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَكَانَ عَامُ الْحُزْنِ ........', ['وَالْبُكَاءِ', 'وَالحُجُرَاتِ', 'وَأَرْضًا', 'وَأَعَادَهَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَدْ مَاتَ عَمُّهُ إِمَامُ ........', ['الْقَوْمِ', 'الْقُدْسِ', 'الْكِرَامِ', 'اللَّبَنُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَ مَا قَالَ النَّبِيُّ حَقًّا', ['وَاللهُ مِنْ أَنْوَارِهِ طَرَّزَهَا', 'بِمَالِهِ بَلْ جَاءَ بِالْأَخْبَارِ', 'أَضَاءَ بُصْرَى نَوَّرَ الْقُصُورَا', 'فَخَرَجُوا مِنَ الْحِصَارِ صِدْقًا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنَّ ........ الَّتِي قَدْ كُتِبَتْ', ['الْمُبِين', 'الصَّحِيفَةَ', 'الْأَرْبَعِين', 'الخَلْقِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', ['بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', 'ذِكْرُكَ مَرْفوعٌ مَدى الأَيّامِ', 'مِنْ مُعْجِزَاتِ سَيِّدِ الْأَنَامِ', 'وَقَاطَعُوا لِلْأُسْرَةِ الشَّرِيفَة'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ\nثَلَاثَ سِنِينَ بِغَيْرِ ذَنْبِ', ['وَبَعْدَها بِمَوْتِ عَبْدِ المُطَّلِب', 'إِذْ أَنْتُمُ بِالعُدْوَةِ الدُّنْيَا وَهُمْ', 'حَتَّى أَتَى الْوَحْيُ مِنَ الرَّحْمَنِ', 'وَاسْتَوْدَعَ المُخْتَارُ زَوْجَ بِنْتِهِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ', ['خَدِيجَةُ مِنْ قَلْبِهِ قَرِيبَةُ', 'تِلْكَ الصَّحِيفَةَ الَّتِي قَدْ قُطِّعَتْ', 'بِنَفْسِهِ وَمَالِهِ يَفْدِيهِ', 'فَلَمْ أَجِدْ مِنْ قَلْبِ طَهَ أَطْيَبا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْمُصْطَفَى بِوَاضِحِ الْبَيَانِ', ['رَدَّ نَبِيُّنَا عَلَيْهِ سَيْفَهُ', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ', 'وَكَذَلِكَ الأَنْصَارُ جَاءَتْ فِيهِمْ', 'حَتَّى أَتَى الْوَحْيُ مِنَ الرَّحْمَنِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خَدِيجَةُ مِنْ قَلْبِهِ قَرِيبَةُ', ['لَوْ أَنَّ رَبَّ الْعَرْشِ عَشَرًا وَهَبَه', 'وَبَعْدَهُ زَوْجَتُهُ الْحَبِيبَةُ', 'أَمَرَهُم خَيرُ الوَرَى أَن يَفتَحُوا', 'وَبَاضَتِ الحَمَامُ فِي المَكَانِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ', ['سِوَى بِاسْمِكَ اللَّهُمَّ قَدْ قُطِّعَتْ', 'فَاتَّبِعوهُ كَيْ تَنالوا الرَّشَدا', 'لَكِنَّهُ الرَّحِيمُ ذُو العَطَاءِ', 'حَتَّى أَتَى الْمُخْتَارَ لِلْأَحْفَادِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ', ['ذُو رَحْمَةٍ وَرَأْفَةٍ وَسَهْلَا', 'بِجَنَّةِ الْخُلُودِ فِيهَا يَنْعَمُوا', 'ذِئْبٌ فَصِيحٌ بِالْكَلَامِ عَبَّرَا', 'قَدْ مَاتَ عَمُّهُ إِمَامُ الْقَوْمِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ\nتِلْكَ الصَّحِيفَةَ الَّتِي قَدْ قُطِّعَتْ', ['وَكَانَ كَعْبٌ أَقْصِدُ ابْنَ الْأَشْرَف', 'فَبِها تَكونُ زِيادَةُ الإيمانِ', 'وَبَعْدَ عَامَيْنِ أَتَاهُ الْمَوْتُ', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثَلَاثَ سِنِينَ بِغَيْرِ ذَنْبِ', ['وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', 'وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', 'وَقِيلَ إِنَّ تِلْكَ أَوَّلُ السُّوَرْ', 'وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِلْمُصْطَفَى بِوَاضِحِ ........', ['الْفِدَا', 'الْمَعْرُوفِ', 'الرِّوَايَةِ', 'الْبَيَانِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَانَ مَا قَالَ النَّبِيُّ حَقًّا\nفَخَرَجُوا مِنَ الْحِصَارِ صِدْقًا', ['وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ', 'إِذْ بِي أَرَى عَلَيَّ مِنْ أَغْصَانِهَا', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة\nوَقَاطَعُوا لِلْأُسْرَةِ الشَّرِيفَة', ['وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ', 'وَحَالَ بَيْنَهُ وَبَيْنَ غَنَمِهْ', 'وَرُوِيَ عَنْ سَمُرَةَ بْنِ جُنْدُبِ', 'صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي هَذِهِ الْأَرْضِ وَفِي السَّمَاءِ', ['فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ', 'فَكَانَ عَامُ الْحُزْنِ وَالْبُكَاءِ', 'مَوْلِدُهُ مِيلَادُ كُلِّ الْبُشْرَيَات', 'وَهُوَ الَّذِي حَفَرَ زَمْزَمَ بَعْدَ أَنْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ زَوْجَتُهُ الْحَبِيبَةُ', ['وَبِنْتُ', 'وَبَهائِهِ', 'وَبَعْدَهُ', 'وَبِالجَفَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ عَامُ الْحُزْنِ وَالْبُكَاءِ', ['فَقَامَ', 'فَكَانَ', 'فَرْضًا', 'فَوْقِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَاطَعُوا لِلْأُسْرَةِ الشَّرِيفَة', ['وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', 'بِصَخْرَةٍ مِنْ فَوْقِهِ عَظِيمَة', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَتَّى أَتَى الْوَحْيُ مِنَ الرَّحْمَنِ', ['لِلْمُصْطَفَى بِوَاضِحِ الْبَيَانِ', 'مَا بَيْنَ أَصْحَابِهِ بِالنَّمِيمَة', 'بَعْضَ الَّذي إِلَيْهِ عَنْهُمْ وَصَلوا', 'وَكُلُّهُمْ ظَفِرَ بِالسَّعَادَةِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَخَرَجُوا مِنَ الْحِصَارِ صِدْقًا', ['وَكَانَ مَا قَالَ النَّبِيُّ حَقًّا', 'وَقَتْلِهِمْ لِقَائِدِ الْكُفَّارِ', 'أَدْعُوكُمُ بِالْوَحْيِ لِلتَّوْحِيدِ', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ\nسِوَى بِاسْمِكَ اللَّهُمَّ قَدْ قُطِّعَتْ', ['كَفَلَهُ مِنْ بَعْدِ مَوْتِ أُمِّهِ', 'وَكَانَ مَا قَالَ النَّبِيُّ حَقًّا', 'بِكَفِّهِ الشَّرِيفَةِ قَدْ مَسَّهَا', 'جَمالُهُ هُوَ مَضْرِبُ الأَمْثالِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثَلَاثَ ........ بِغَيْرِ ذَنْبِ', ['سَاطِعٌ', 'سَعْدُ', 'سِنِينَ', 'سَقَاهُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تِلْكَ الصَّحِيفَةَ الَّتِي قَدْ قُطِّعَتْ', ['قَامُوا لَهُ وَأَوْجَعُوهُ ضَرْبَا', 'يَصْرُخُ فِي مَكَّةَ عِنْدَ الوَادِي', 'وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ\nقَدْ مَاتَ عَمُّهُ إِمَامُ الْقَوْمِ', ['لِأَنَّهُ في صُلْبِهِ الرَّسولُ', 'وَانْطَلَقَ النَّبِيُّ نَحْوَ طَيْبَة', 'وَبَعْدَهُ زَوْجَتُهُ الْحَبِيبَةُ', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهُ زَوْجَتُهُ الْحَبِيبَةُ', ['لَكِنَّهُ عَنْ عَطْفِهِ مَا عَزَفَا', 'خَدِيجَةُ مِنْ قَلْبِهِ قَرِيبَةُ', 'يَا شَافِعًا لِلخَلْقِ فِي المِيعَادِ', 'مُعَظَّماً في العِلْمِ وَالأَمانَة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ', ['وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'ثَلَاثَ سِنِينَ بِغَيْرِ ذَنْبِ', 'وَرَأَى رُكَانَة سَيِّدَ الْأَسْيَادِ', 'فَجَهَّزَ الرَّحْلَ بِقَصْدِ الهِجْرَةِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَدْ مَاتَ عَمُّهُ إِمَامُ الْقَوْمِ', ['تَنَوَّرَتْ بِنُورِهِ المَدِينَة', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ', 'فِي يَوْمِ الْأَرْبِعَاءِ مِنْ شَوَّالٍ', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَشُلَّتِ ........ الَّتِي قَدْ كَتَبَتْ', ['الْيَدُ', 'أُولَى', 'آتَاهُ', 'الكِتَابِ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَارَ ........ يَدْعُو أَهْلَهَا', ['لِلطَّائِفِ', 'لحَمْزَةَ', 'لِرُكْبَتِهِ', 'لِيَرْضَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَعَ أَنَّهُمْ لَاقَوْهُ ........', ['بِالإِيذَاءِ', 'بِالْمُصْطَفَى', 'بِالتَّنْكِيلِ', 'بِالأَخْبَارِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَنْصَتُوا وَسَارَعُوا لِقَوْمِهِمْ', ['لِيُنْذِرُوا مَنْ بَعْدَهُمْ بِدِينِهِمْ', 'مُنَظِّمِينَ الْجَيْشَ بِالصُّفُوفِ', 'يَأْتِيَانِ لَهُم بِمَا يَشَاءُوا', 'وَلَمْ يَزَلْ بِحِقْدِهِ مُعَادِيَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا\nلَكِنَّهُ عَنْ عَطْفِهِ مَا عَزَفَا', ['أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا', 'دَعَا لَهُمْ بِالخَيْرِ وَالهِدَايَةِ', 'مِنْ قَبْلِ أَنْ تَأْتِي الرِّسَالَةُ إِلَى', 'البَطْشَةُ الكُبْرَى الَّتِي ذُكِرَتْ كَمَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَدْ سَمِعُوا لِلْوَحْيِ وَالتَّنْزِيلِ', ['وَجَاءَ وَفْدُ الْجِنِّ لِلرَّسُولِ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'فَعَادَ لِلْكُفْرِ وَلِلْبُهْتَانِ', 'وَرَعْيُهَا لِلْأَنْبِيَا كَمَالُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَاءَهُ ........ مَعَهُ مَلَكُ', ['جُحُودًا', 'جَمْعًا', 'جِبْرِيلُ', 'جَمالُهُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'دَعَا لَهُمْ بِالخَيْرِ وَالهِدَايَةِ', ['مَعَ الحَبِيبِ كَانَ وَالمُهَذَّبَا', 'لَمْ يَنْتَقِمْ مِنْهُمْ عَلَى الجِنَايَةِ', 'ما قالَهُ جِبْريلُ مِنْ شَمائِلِ', 'الطَّيِّبُ الْمُطَيَّبُ الْمَقْبُولُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَكِنَّهُ دَعَا لَهُمْ رَحِيمَا', ['فَلَمْ يَزَلْ بِعَفْوِهِ كَرِيمَا', 'وَلَيْسَ ثَمَّ مِنْ حَلِيبٍ يُحْلَبُ', 'وَقَدْ أَتَوْا فِي سَيْرِهِمْ أَيَّامَا', 'وَانْكَشَفَ الْحِجَابُ دُونَ بَيْنِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَهْلَهَا جَمِيعَا', ['بِالحَبيبِ', 'بِالأَخْشَبَيْنِ', 'بِكِتَابِهِمْ', 'بِالأَخْبَارِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَكِنَّهُ عَنْ عَطْفِهِ مَا عَزَفَا', ['وَرُوِيَ عَنْ سَمُرَةَ بْنِ جُنْدُبِ', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'وَكَانَ مَنْ عَادُوا ثَلَاثَمِائَةً', 'لَكِنَّ رَأْيَ غَالِبِ الْأَنْصَارِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ وَفْدُ الْجِنِّ لِلرَّسُولِ', ['وَجَاءَ', 'وَهْوَ', 'وَنَاكِثًا', 'وَسَعْدُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِالأَخْشَبَيْنِ أَهْلَهَا جَمِيعَا', ['حَرْبَ الْفِجَارِ يَرْمِي بِسِهَامِهِ', 'إِنْ شِئْتَ يَا طَهَ يَكُنْ سَرِيعَا', 'وَأَحْمَدُ الْإِحْسَانِ ذُو النُّورِ الْأَتَمّ', 'وَهْوَ ابْنُ عَمِّهَا أَيْضًا فَصَدَّقَهْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ', ['أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'وَجَيْشُهُمْ فِيهَا لَقِي دَمَارَهْ', 'هُمُ بَنُو ثَعْلَبَةْ وَمُحَارِبِ', 'لَكِنَّهُ الرَّحِيمُ ذُو العَطَاءِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَكِنَّهُ دَعَا لَهُمْ رَحِيمَا\nفَلَمْ يَزَلْ بِعَفْوِهِ كَرِيمَا', ['وَجَاءَ وَفْدُ الْجِنِّ لِلرَّسُولِ', 'وَاللهُ زَكَّاهُ بِآيَاتِ الهُدَى', 'مِنْ بَعْدِ مَوْتِ بُخْتُنَصَّرَ أَتى', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَهُ جِبْرِيلُ مَعَهُ مَلَكُ', ['فَسَأَلَ المَوْلى وَمَنْ مُحَمَّدُ', 'هُوَ مَلَكُ الجِبَالِ حَتَّى يُهْلَكُوا', 'لَم يَشْهَدُوا عِنَايَةَ الرَّحْمَنِ', 'ابْنُ مَظْعُونٍ أَعْلَنُوا الْإِيمَانَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسَارَ لِلطَّائِفِ يَدْعُو أَهْلَهَا', ['فَلَمْ تُجِبْهُ ثُمَّ أَبْدَتْ جَهْلَهَا', 'بِالِاجْتِهَادِ وَالصَّبْرِ أَمَرَهُمْ', 'مُفَتِّشًا عَن سَيِّدِ النُّبَلَاءِ', 'أَجَابَ كَلَّا إِنَّنِي أُمِّيُّ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'دَعَا لَهُمْ بِالخَيْرِ وَالهِدَايَةِ\nلَمْ يَنْتَقِمْ مِنْهُمْ عَلَى الجِنَايَةِ', ['فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا', 'مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ', 'وَرَبُّنَا قَدْ أَخَذَ الْمِيثَاقَا', 'كَانُوا يُعَلِّمُونَهَا الغِلْمَانَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَنْصَتُوا ........ لِقَوْمِهِمْ', ['وَسَارَعُوا', 'وَهَكَذَا', 'وَأَنْجَبَتْ', 'وَأَكْمَلُوا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ وَفْدُ الْجِنِّ لِلرَّسُولِ', ['عَلَى حَبِيبِ رَبِّنَا مُحَمَّدِ', 'قَدْ سَمِعُوا لِلْوَحْيِ وَالتَّنْزِيلِ', 'فِي الطَّابِقِ الأَعْلَى بِلَا نَدَامَةِ', 'فَسَأَلَ المَوْلى وَمَنْ مُحَمَّدُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِالأَخْشَبَيْنِ أَهْلَهَا جَمِيعَا\nإِنْ شِئْتَ يَا طَهَ يَكُنْ سَرِيعَا', ['هُوَ الْمُنِيرُ وَالنَّذِيرُ وَالسِّرَاج', 'وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'لَكِنَّهُ دَعَا لَهُمْ رَحِيمَا', 'فَهَاجَرَ الأَصْحَابُ نَحْوَهُم لَمَّا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَهُ جِبْرِيلُ مَعَهُ مَلَكُ\nهُوَ مَلَكُ الجِبَالِ حَتَّى يُهْلَكُوا', ['أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي', 'بِالأَخْشَبَيْنِ أَهْلَهَا جَمِيعَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَلَمْ يَزَلْ بِعَفْوِهِ كَرِيمَا', ['لَكِنَّهُ دَعَا لَهُمْ رَحِيمَا', 'فَأَيْقَنُوا بِالْمَوْتِ لَكِنْ نَبَعَتْ', 'وَقَدْ رَوَى الحاكِمُ فِي الصَّحيحِ', 'تَنَازَعَ النَّاسُ فِيمَنْ سَيَضَعُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَكِنَّهُ عَنْ ........ مَا عَزَفَا', ['عَذَابِ', 'عَلَيْهِمْ', 'عَطْفِهِ', 'عَشْرِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَارَ لِلطَّائِفِ يَدْعُو أَهْلَهَا\nفَلَمْ تُجِبْهُ ثُمَّ أَبْدَتْ جَهْلَهَا', ['فَأَنْصَتُوا وَسَارَعُوا لِقَوْمِهِمْ', 'وَعَلَى قُبَاءَ عَاصِمَ بْنَ عَدِي', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'تَبْغُونَهَا عِوَجًا بِتِلْكَ الآيَةِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِيُنْذِرُوا مَنْ بَعْدَهُمْ بِدِينِهِمْ', ['غَزَوَاتُهُ تِسْعٌ وَعِشْرُونَ سَفَرْ', 'فَأَنْصَتُوا وَسَارَعُوا لِقَوْمِهِمْ', 'وَسُمِّيَ بِذَلِكَ لِأَنَّهُ', 'وَلَمّا وُلِدَ نِزارُ سَطَعا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَمْ يَنْتَقِمْ مِنْهُمْ عَلَى الجِنَايَةِ', ['فَسَكَتَ النَّبِيُّ لَمْ يُجِبْهُمَا', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة', 'خَيْرُ نِسَاءِ الْعَالَمِينَ فَاطِمَةْ', 'دَعَا لَهُمْ بِالخَيْرِ وَالهِدَايَةِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ\nلَكِنَّهُ الرَّحِيمُ ذُو العَطَاءِ', ['فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا', 'وَمَاتَ عَبْدُاللَّهِ قَبْلَ أَنْ يَرَى', 'وَجَاءَهُ جِبْرِيلُ مَعَهُ مَلَكُ', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَ وَفْدُ الْجِنِّ لِلرَّسُولِ\nقَدْ سَمِعُوا لِلْوَحْيِ وَالتَّنْزِيلِ', ['لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ', 'مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'فَأَنْصَتُوا وَسَارَعُوا لِقَوْمِهِمْ', 'وَقالَ البَعْضُ إِنَّها تَأْويلُها'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هُوَ مَلَكُ الجِبَالِ حَتَّى يُهْلَكُوا', ['وَقالَ البَعْضُ إِنَّها تَأْويلُها', 'وَسُئِلَ الصِّدِّيقُ هَلْ رَأَيْتَ', 'ثُمَّ ابْنُ عَوْفٍ ثُمَّ حَاطِبٌ مَعَا', 'وَجَاءَهُ جِبْرِيلُ مَعَهُ مَلَكُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ يَزَلْ ........ كَرِيمَا', ['بِالصُّفُوفِ', 'بِدِينِهِ', 'بِعَفْوِهِ', 'بِخَيْلِهِ'], 2),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَكْفِي بِأَنَّهُ كَشْفًا رَآهُ', ['أَوْحَى إِلَيْهِ اللَّهُ مَا أَوْحَاهُ', 'وَلَمْ يَزَلْ يَقُولُ كُلَّ حِينٍ', 'وَاتَّفَقُوا عَلَى الَّذِي سَيَدْخُلُ', 'وَكانَ يُدْعى سَيِّدَ العَشيرَةِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْقُدْسِ حَتَّى وَصَفَ الْبَدَائِعَا', ['فِي شَهْرِ مِيلَادِ الحَبِيبِ الهَادِي', 'إِذْ أَنْتُمُ بِالعُدْوَةِ الدُّنْيَا وَهُمْ', 'وَالْخَثْعَمِيَّةْ عَرَضَتْ عَلَيْهِ أَنْ', 'فَجَاءَ جِبْرِيلُ الْأَمِينُ رَافِعًا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'رَآهُ حَقًّا شَاهِدًا بِالْعَيْنِ\nوَانْكَشَفَ الْحِجَابُ دُونَ بَيْنِ', ['أَخْبَرَهَا عَمَّا رَأَى فَرَغِبَتْ', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا', 'مِنْهُمْ حَيِّيٌّ كَانَ مِنْ أَحْبَارِهِمْ', 'وَفَرَضَ اللَّهُ الصَّلَاةَ عِنْدَهَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ\nيَمْضِي بِهِ فِي سَائِرِ الْآفَاقِ', ['هِيَ أَصْلُ تِلْكَ الشَّجَرَةِ الْعَجِيبَةِ', 'فَسَارَ نَحْوَ الْقُدْسِ ثُمَّ صَلَّى', 'وَزَالَ مِنْ بَيْنِهِمُ الْخِصَامُ', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'كَذَاكَ فِي الثَّانِيَةِ وَغَيْرِهَا', ['وَجَدِّهِ الْكَرِيمِ ذِي الْمَفَاخِرِ', 'مُرَحَبًا مُسْتَقْبَلًا فِي كُلِّهَا', 'رُؤْيَا وَقَصَّهَا عَلَى الْأَقْوَامِ', 'أَرْبَعَةً فَأَسْعَدِ الْأَيَّامَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْكُفَّارُ بِالْإِسْرَاءِ', ['وَكَذَّبَ', 'وَنَزَلَ', 'وَمَعَهُمْ', 'وَكَانَ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَدِ الْتَقَى ........ النُّجَبَاءِ', ['بِيَوْمِ', 'بُغْضِهِمْ', 'بِصَفْوَةِ', 'بِإِسْلَامِهِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحِينَ عَادَ الْمُصْطَفَى لِلْقَوْمِ', ['أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'أَتَوْا لَهُمْ مِنْ كَافَّةِ الْأَنْحَاءِ', 'حَجَرًا بِمَكَّةَ لَهُ وَيَصِفُ', 'يُخْبِرُهُمْ عَنْ شَأْنِ هَذَا الْيَوْمِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَسَارَ نَحْوَ الْقُدْسِ ثُمَّ صَلَّى', ['بِالْأَنْبِيَاءِ السَّادَةِ الْأَجْلَّا', 'حِمَايَةَ الظُّهُورِ وَالثَّبَاتِ', 'بِأُمِّ خَيْرِ الْخَلْقِ قَدْ تَنَوَّرَتْ', 'فِي هَذِهِ العِيرِ الَّتِي مَرَّتْ بِهِمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَمْلَاكُهَا مَعَ آدَمَ الْجَلِيلَا', ['وَاسْتَقْبَلُوهُ فِي السَّمَاءِ الْأُولَى', 'وَخَصَّهَا بِأَشْرَفِ الْمَزَايَا', 'وَكَتَبَ الْعَبَّاسُ بِالْأَخْبَارِ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَنْكَرُوا تَجَاوَزُوا الْحُدُودَا', ['بِأَنَّ طَهَ خَاتَمٌ لِلْأَنْبِيَا', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ', 'أَبُو طَالِبٍ الْكَرِيمُ الطَّيِّبُ', 'فَكَذَّبُوا كَلَامَهُ جُحُودًا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَفَرَضَ اللَّهُ الصَّلَاةَ عِنْدَهَا', ['فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', 'خَمْسِينَ فَرْضًا فِي ابْتِدَاءِ فَرْضِهَا', 'بِنَفْسِهِ وَمَالِهِ يَفْدِيهِ', 'بِأَمْرِهِ لِمَا عَلَيْهِ كَانَتْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَكَذَّبَ الْكُفَّارُ مَا ........', ['حَصَلَا', 'حَلِيبٍ', 'حَكَاهُ', 'حَذَّرَهُمْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَحِينَهَا قَدْ سُمِّيَ ........', ['الْكِرَامِ', 'الصِّدِّيقَا', 'الوَهَّابِ', 'النَّوْحُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَدَائِمًا ........ عَفْوًا جَمِيلَا', ['يَعْفُو', 'يَوْمَ', 'يَجِدُوا', 'يَقْتُلْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَا حَادِثَةُ الْإِسْرَاءِ', ['إِذَا بِهِمْ مَعَ عِلْمِهِمْ كُفَّارُ', 'حِلْفِ الْفُضُولِ قَوْمُهُ وَأَقْبَلَا', 'وَمِنْ ظَلَامِ الْكُفْرِ وَالنَّوَاهِي', 'وَبَعدَهَا الْمِعْرَاجُ لِلسَّمَاءِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَلْقَى السَّلَامَ ........ فِي حَضْرَتِهِ', ['خَمْسًا', 'خَاشِعًا', 'خِيَرَةِ', 'خِصَالِهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثُمَّ دَنَا مِنْ رَبِّهِ مُشَافِهَا', ['يَغْشَى بِفَضْلِ اللَّهِ مِنْهُمْ طَائِفَةْ', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ', 'تَجَاوَزَ السَّبْعَ الطِّبَاقَ كُلَّهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَنْ أَسَا يَلْقَاهُ بِالْغُفْرَانِ', ['مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ', 'يَزِيدُ مَنْ أَحْسَنَ بِالْإِحْسَانِ', 'سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ', 'فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَتَّى أَتَى التَّخْفِيفُ خَمْسًا أَجْرُهُمْ', ['بِأَجْرِ خَمْسِينَ كَمَالًا فَضْلُهُمْ', 'وَعَادَ زَوْجُهَا عَلَيْهِ العَجَبُ', 'كَانَ يُجِلُّ الْمُصْطَفَى وَلَهُ مُحِب', 'عَنْ عُمَرَ الفاروقِ وَالمَليحِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِ ذَا عَلَا إِلَى السَّمَاءِ', ['لِكَي يَكُونَ مَعَهُ رَفِيقَا', 'قَلَّلَ جَمْعَ الكُفْرِ فِي أَعْيُنِهِمْ', 'قَدِ الْتَقَى بِصَفْوَةِ النُّجَبَاءِ', 'وَفَائِهِ لَهَا وَمَا تَحَوَّلَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَمْضِي بِهِ فِي سَائِرِ الْآفَاقِ', ['وَاسْتَقْبَلُوهُ فِي السَّمَاءِ الْأُولَى', 'قَالَ أَبُو الصِّدِّيقِ لِابْنِهِ أَبِي', 'آمِنَةُ وَمَنْ كَمِثْلِ آمِنَة؟!', 'قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَفَرَضَ اللَّهُ الصَّلَاةَ عِنْدَهَا\nخَمْسِينَ فَرْضًا فِي ابْتِدَاءِ فَرْضِهَا', ['حَتَّى أَتَى التَّخْفِيفُ خَمْسًا أَجْرُهُمْ', 'وَكَانَ مَنْ عَادُوا ثَلَاثَمِائَةً', 'مِنْهُمْ بِلَالٌ عَذَّبُوهُ لَمَّا', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَلْقَى السَّلَامَ خَاشِعًا فِي حَضْرَتِهِ', ['عَنْ ابنِ عَبّاسِ الإِمامِ قَدْ أَتى', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ', 'وَشَاهَدَتْ عَيْنَاهُ نُورَ قُدْرَتِهِ', 'الْحِمْيَرِيَّ قَدْ بَنَى إِذْ سَمِعَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَكَذَّبَ الْكُفَّارُ مَا حَكَاهُ', ['لِلَّهِ فِيهِ دَائِمًا وَشَاهِدًا', 'فِيهِ ثَلَاثَ لَيَالٍ قَد مَكَثَا', 'وَمَنْ أَسَا يَلْقَاهُ بِالْغُفْرَانِ', 'وَصَدَّقَ الصِّدِّيقُ مَا أَتَاهُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'كَذَاكَ فِي الثَّانِيَةِ وَغَيْرِهَا\nمُرَحَبًا مُسْتَقْبَلًا فِي كُلِّهَا', ['تَجَاوَزَ السَّبْعَ الطِّبَاقَ كُلَّهَا', 'غَزَوَاتُهُ تِسْعٌ وَعِشْرُونَ سَفَرْ', 'لَكِنْ شَفَاهُ اللهُ مِمَّا لَاقَى', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحِينَ عَادَ الْمُصْطَفَى لِلْقَوْمِ\nيُخْبِرُهُمْ عَنْ شَأْنِ هَذَا الْيَوْمِ', ['صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه', 'وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى', 'يُقَاتِلُونَ فِي سَبِيلِ اللهْ', 'فَكَذَّبَ الْكُفَّارُ مَا حَكَاهُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَا حَادِثَةُ الْإِسْرَاءِ\nوَبَعدَهَا الْمِعْرَاجُ لِلسَّمَاءِ', ['وَاسْتَعْمَلَ الهَادِي أَبَا لُبَابَةْ', 'قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ', 'وَبَعْدَهَا عَادُوا إِلَى بِلَادِهِمْ', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَانْكَشَفَ الْحِجَابُ دُونَ بَيْنِ', ['رَآهُ حَقًّا شَاهِدًا بِالْعَيْنِ', 'وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'وَسُمِّيَتْ بِغَزْوَةِ أَنْمَارِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى أَتَى التَّخْفِيفُ خَمْسًا أَجْرُهُمْ\nبِأَجْرِ خَمْسِينَ كَمَالًا فَضْلُهُمْ', ['سُبْحَانَ مَنْ يُعْطِي الْعَطَا الْجَزِيلَا', 'أَبُوهُ عَبْدُاللَّهِ عَبْدُالْمُطَّلِبْ', 'أَدَبًا مَعَ النَّبِيِّ وَاحْتِرَامَا', 'لَمَّا الْتَقَى الْجَمْعَانِ مَنْ تَوَلَّى'], 0),
  ],
  <PoemQ>[
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي المَرَّةِ الأُولَى قَلِيلٌ أَسْلَمُوا\nوَرَجَعُوا لِقَوْمِهِم لِيُعَلِّمُوا', ['قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ', 'قَالُوا لَهَا هِيَ عَشَرَةٌ مِنْ إِبِلِنَا', 'أَتَى مِنَ اللهِ القَدِيرِ نَاصِرا', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة\nعَلَى الوَفَاءِ وَالهُدَى مُؤَكَّدَة', ['فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا', 'بَنَى بِهَا مَسْجِدَهُ العَظِيمَا', 'وَزَادَ أَهْلُ اللهِ وَالإِسْلَامِ', 'يَخْشَى عَلَيْهِمْ مِنْ عَذَابِ اللَّهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَ وَفْدُ طَيْبَةَ وَآمَنُوا\nلَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا', ['وَهُمُ الْمُنَافِقُونَ كَانَ مُرَادُهُمْ', 'فِي المَرَّةِ الأُولَى قَلِيلٌ أَسْلَمُوا', 'حَذَّرَهُمْ مِنْ دَعْوَى الجَاهِلِيَّةْ', 'فَهَاجَرَ الأَصْحَابُ نَحْوَهُم لَمَّا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِن قَابِلٍ إِلَى النَّبِيْ وُفُودُ', ['فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', 'يُدَافِعُ عَنْهُ مِنْ الْأَقْوَامِ', 'لَمْ يَقْصِدُوا الحَرْبَ وَلَكِنْ مَالُهُمْ', 'كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي طَيْبَةَ مِن بَعْدِ هَذَا العَامِ', ['مِنْ بَعْدِ مَوْتِ بُخْتُنَصَّرَ أَتى', 'وَزَادَ أَهْلُ اللهِ وَالإِسْلَامِ', 'فَجَاءَ سَعْدُ بْنُ الرَّبِيعِ مُخْبِرًا', 'فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَى الوَفَاءِ وَالهُدَى مُؤَكَّدَة', ['لَا تَسْأَلُوهُ حَتَّى لَا يُجِيبَكُمْ', 'وَقَدْ رَأَتْ مَنْ جَاءَهُمْ بِأَمْرِ', 'رَوى كَذاكَ صاحِبُ الدَّلائِلِ', 'فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَرَجَعُوا لِقَوْمِهِم لِيُعَلِّمُوا', ['فِي المَرَّةِ الأُولَى قَلِيلٌ أَسْلَمُوا', 'ظَنُّوا بِرَبِّ الْعَرْشِ غَيْرَ الْحَقِّ', 'وَغَيْرُ ذَا وَقَائِعُ كَثِيرَةْ', 'فَإِنَّهُ وَصِيَّةُ أَبِيهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِن قَابِلٍ إِلَى ........ وُفُودُ', ['النَّبِيْ', 'الأُولَى', 'الصِّغَر', 'التُّقَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ........ مِن بَعْدِ هَذَا العَامِ', ['طَائِفًا', 'طَيْبَةَ', 'طَرَقَ', 'طَالِبٍ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا', ['مُزَّمِّلٌ مُدَّثِّرٌ رَسُول', 'جَعَلْتُهُ الخَليلَ لكِنْ أَنْتَ يا', 'فَقُتِلَ الْحَمْزَةُ ثُمَّ مُصْعَبُ', 'وَجَاءَ وَفْدُ طَيْبَةَ وَآمَنُوا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَزَادَ أَهْلُ اللهِ وَالإِسْلَامِ', ['فِي طَيْبَةَ مِن بَعْدِ هَذَا العَامِ', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ', 'يَكْفِي بِأَنَّهُ كَشْفًا رَآهُ', 'إِنْ شِئْتَ يَا طَهَ يَكُنْ سَرِيعَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', ['مِن قَابِلٍ إِلَى النَّبِيْ وُفُودُ', 'حِمَايَةَ الظُّهُورِ وَالثَّبَاتِ', 'وَزَوْجُهَا يَاسِرُ الْأَبْرَارْ', 'ابْنُ عُمَيْرٍ وَالْجَمِيعُ يَعْجَبُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي المَرَّةِ الأُولَى قَلِيلٌ ........', ['أَثْقَالَا', 'اللَّبَن', 'أَسلَمَ', 'أَسْلَمُوا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَلَى الوَفَاءِ ........ مُؤَكَّدَة', ['وَطَيبَة', 'وَمُحَارِبِ', 'وَالهُدَى', 'وُقُوعِهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَاءَ وَفْدُ طَيْبَةَ ........', ['وَآمَنُوا', 'وَبَعدَهَا', 'وَأَذَلَّ', 'وَالصَّحْبِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَهْلُ اللهِ وَالإِسْلَامِ', ['وَزَادَ', 'وَصْفًا', 'وَشَاوَرَ', 'وَجَيْشُهُمْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي المَرَّةِ الأُولَى قَلِيلٌ أَسْلَمُوا', ['مَا بَيْنَ أَصْحَابِهِ بِالنَّمِيمَة', 'بَكْرٍ أَيَا حَبِيبِيَ الْمُقَرَّبِ', 'لِلغَارِ بِالحِقْدِ وَبِالغَبَاءِ', 'وَرَجَعُوا لِقَوْمِهِم لِيُعَلِّمُوا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ وَفْدُ طَيْبَةَ وَآمَنُوا', ['آمِنَةَ يَعِيشُ بَيْنَ قَوْمِهِ', 'لَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا', 'ابْنُ مَظْعُونٍ وَمَسْعُودٌ أَسْرَعَا', 'وَبِنْتُ وَهْبٍ إِنَّهَا عَظِيمَة'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا\nمِن قَابِلٍ إِلَى النَّبِيْ وُفُودُ', ['فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة', 'هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى', 'فَتَجَهَّزَ الأَقْوَامُ لَمَّا سَمِعُوا', 'وَبَاضَتِ الحَمَامُ فِي المَكَانِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة', ['رُزِقْتُ حُبَّهَا بِكُلِّ لِينٍ', 'عَلَى الوَفَاءِ وَالهُدَى مُؤَكَّدَة', 'وَلَا يَقِلُّ وَلَيْسَ يُلْحَقُ قَعْرُهَا', 'كَانَ يُجِلُّ الْمُصْطَفَى وَلَهُ مُحِب'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي المَرَّةِ الأُولَى ........ أَسْلَمُوا', ['قَرِّبُوا', 'قُلُوبِهِمْ', 'قَلْبِهِ', 'قَلِيلٌ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي طَيْبَةَ مِن بَعْدِ هَذَا ........', ['الرُّوحُ', 'الْمُقَامَ', 'العَامِ', 'الشِّرْكِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمَّا دَعَاهُم لِلهُدَى ........', ['وَاللَّهِ', 'وَأَسْرَعُوا', 'وَأَيْقَنُوا', 'وَأَطْعَمَ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَبَايَعُوهُ ........ مُسَدَّدَة', ['بِدِرْعِهِ', 'بِصِدْقِ', 'بَيْعَةً', 'بِالخِزْيِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَسْلَمَتْ جُمُوعُهُم ........', ['وَسُئِلَ', 'وَيَصِفُ', 'وَعَادُوا', 'وَأَذْعَنُوا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَزَادَ أَهْلُ ........ وَالإِسْلَامِ', ['إِلَى', 'أَمَرَكَ', 'أَسْرَعَا', 'اللهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَجَعُوا لِقَوْمِهِم ........', ['لِيُعَلِّمُوا', 'لِلْمُصْطَفَى', 'لِقَائِدِ', 'لِيُلْبِسُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَلَى ........ وَالهُدَى مُؤَكَّدَة', ['اللَّطْفِ', 'الوَفَاءِ', 'اللَّهُمَّ', 'أَبْصَارُهُم'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمَّا ........ لِلهُدَى وَأَيْقَنُوا', ['دَعَاهُم', 'دينِ', 'دِيَارِهِمْ', 'دَعُوهُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِن قَابِلٍ إِلَى النَّبِيْ ........', ['وَالصَّحْبِ', 'وَصَحْبِهِ', 'وَخِدْمَتِهِ', 'وُفُودُ'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَلَيْسَ فِيهَا مِنْ شَرَابٍ يُطْلَبُ', ['صَفَّينِ لِلكَعبَةِ حَتَّى خَرَجُوا', 'وَلَيْسَ ثَمَّ مِنْ حَلِيبٍ يُحْلَبُ', 'لَكِنَّهُ عَنْ عَطْفِهِ مَا عَزَفَا', 'وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن', ['وَشَرِبَ النَّبِيُّ طَهَ المُؤْتَمَن', 'فِيهَا يَعِيشُ آمِنًا مَن أَسْلَمَا', 'وَلَم يَرَوْهُ أُغْشِيَت أَبْصَارُهُم', 'وَحَدَّثَ النَّبِيَّ بِالْحِكَايَةِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'دَعَا لَهَا ........ وَمَسَّهَا', ['إِيمَانُ', 'إِلَٰهَهُ', 'إِلّا', 'الدَّلِيلَ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة', ['سَقَاهُ رَبُّهُ لِأَجْلِ عِتْقِهَا', 'وَلَمْ يَزَلْ بِحِقْدِهِ مُعَادِيَا', 'إِحْدَى وَعِشْرِينَ كَمَا الْأَخْبَارِ', 'عَمَّا رَأَتْ مِنْ آيَةٍ عَظِيمَة'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِكَفِّهِ فَأَنْزَلَتْ حَلِيبَا', ['فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ', 'الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', 'وَكَانَ حَقًّا مَشْهَدًا عَجِيبَا', 'وَكَانَ دَوْمًا لِلنَّبِيِّ مُصَدِّقَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَصَلُوا لِبَيْتِ أُمِّ مَعْبَدِ', ['فَقَامَ مِنْ نَوْمِهِ وَأَتَاهَا', 'بُخْتُنَصَّرْ عَلَى العَرَبْ وَأَفْرَطا', 'مَنْ وَصَفَتْ جَمَالَ خَيْرِ سَيِّدِ', 'وَلَمْ يَزَلْ مُحَبَّبًا عَتِيقَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ضَعِيفَةٍ وَفَحْلُهَا مَا مَسَّهَا', ['بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ', 'مَا كَانَ عِنْدَهَا سِوَى شَاةٍ لَهَا', 'وَحَاوَلَتْ قُرَيْشٌ أَخْذَ الْمُصْطَفَى', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَعَادَ زَوْجُهَا عَلَيْهِ العَجَبُ', ['وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا', 'وَغَادَرُوهَا كُلُّهُمْ وَذَهَبُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ أَيْنَ هَذَا اللَّبَنُ الَّذِي أَرَى\nمُتَعَجِّبًا مُتَسَائِلًا مُسْتَبْشِرَا', ['وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر', 'فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي', 'سَلَّمَهُ الْأَجْدَادُ لِلْأَوْلَادِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَوَصْفُهَا فِي حَقِّهِ فِيهِ الشِّفَا', ['وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'وَهَا هُنَا قَدِ الْتَقَى الْأَصْلَانِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَدْ أَتَوْا فِي سَيْرِهِمْ أَيَّامَا', ['لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'وَكَانَ فِيهَا أَوَّلُ الجُمُعَاتِ', 'وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة\nعَمَّا رَأَتْ مِنْ آيَةٍ عَظِيمَة', ['مِنَ النِّسَاءِ خَمْسَةٌ وَضِعْفُهُمْ', 'وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', 'بَسَطَ فِيهَا رِجْلَهُ وَقَالَا', 'كَفَاهُ شَرَّ مَن بَغَى وَكَادَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَوَصَفَتْ لَهُ النَّبِيَّ ........', ['الْغَنِيمَةْ', 'المُصْطَفَى', 'الأَقْوَامِ', 'النّاسِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَوَصَلُوا لِبَيْتِ أُمِّ مَعْبَدِ\nمَنْ وَصَفَتْ جَمَالَ خَيْرِ سَيِّدِ', ['حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'فَهَدَاهُ رَبُّ العَرشِ لِلإِيمَانِ', 'لَمْ يَتَخَلَّفْ مِنْهُمُ إِلاَّ القَلِيل'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ وَفَحْلُهَا مَا مَسَّهَا', ['ضَارِبًا', 'ضَعِيفَةٍ', 'ضَرْبَا', 'ضِيقِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَخَذَهَا النَّبِيُّ بَعْدَ إِذْنِهَا', ['فِي شَهْرِ شَوَّالٍ وَقَدْ زَادَ الْعَدَد', 'دَعَا لَهَا إِلَٰهَهُ وَمَسَّهَا', 'مَكَّةَ يُخْبِرُهُمْ بِمَا قَدْ حَصَلَا', 'بِالعَفْوِ وَالغُفْرَانِ مَهْمَا يَفْعَلُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُتَعَجِّبًا مُتَسَائِلًا مُسْتَبْشِرَا', ['هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى', 'فَأَرْضَعَتْ ثُوَيْبَةُ وَقْتَ الصِّغَر', 'مِنْ أَيْنَ هَذَا اللَّبَنُ الَّذِي أَرَى', 'سَأَلَهُ خَيْرُ الْوَرَى عَنْ اسْمِهِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَلَيْسَ فِيهَا مِنْ شَرَابٍ يُطْلَبُ\nوَلَيْسَ ثَمَّ مِنْ حَلِيبٍ يُحْلَبُ', ['وَجاءَ في الحَديثِ لا تَسُبّوا', 'أَخَذَهَا النَّبِيُّ بَعْدَ إِذْنِهَا', 'لَكِنْ عِنَايَةُ اللهِ تَوَلَّت أَحْمَدَا', 'وَعَرَضَ النَّبِيُّ سَيْفَهُ لِمَنْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِكَفِّهِ فَأَنْزَلَتْ حَلِيبَا\nوَكَانَ حَقًّا مَشْهَدًا عَجِيبَا', ['فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن', 'وَرَوَى ابْنُ إِسْحَاقَ بِأَنَّ تُبَّعَا', 'نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'عَنِ الحَبيبِ سَيِّدِ المِلاحِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن\nوَشَرِبَ النَّبِيُّ طَهَ المُؤْتَمَن', ['بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ', 'وَغَادَرُوهَا كُلُّهُمْ وَذَهَبُوا', 'مِنْ بَعْدِ ذَا نَشْرَعُ فِي الْمَقْصُودِ', 'مَوْلِدُهُ مِيلَادُ كُلِّ الْبُشْرَيَات'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَغَادَرُوهَا ........ وَذَهَبُوا', ['كَعْبٌ', 'كُلُّهُمْ', 'كَيْفَ', 'كُبَرَاءُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقَدْ ........ فِي سَيْرِهِمْ أَيَّامَا', ['أَوْسِهَا', 'أَتَوْا', 'أُولُو', 'أَكْمَلَ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَانَ حَقًّا مَشْهَدًا عَجِيبَا', ['وَحِينَمَا أَتَاهُمُ المُخْتَارُ', 'وَقَدْ أَتَى إِلَى النَّبِيِّ قَبْلَهُ', 'عَقَدَ اللِّوَاءَ الأَبْيَضَ لِمُصْعَبَا', 'بِكَفِّهِ فَأَنْزَلَتْ حَلِيبَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', ['أَجَابَهُ ابْنُ مَسْلَمَةْ أَنَا لَهَا', 'وَوَصْفُهَا فِي حَقِّهِ فِيهِ الشِّفَا', 'مِنْ ذَلِكَ الْفِعْلِ وَلَكِنْ ذَهَبَتْ', 'فَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَمَّا رَأَتْ مِنْ آيَةٍ عَظِيمَة', ['يُعْلِمُهُمْ بِحُرْمَةِ البَيْتِ العَظيم', 'فَأَخْبَرَتْهُ الزَّوْجَةُ الحَكِيمَة', 'أَنْ يُدْرِكُوا الْجَائِزَةَ الَّتِي لِمَنْ', 'وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَغَادَرُوهَا كُلُّهُمْ وَذَهَبُوا', ['وَعَادَ زَوْجُهَا عَلَيْهِ العَجَبُ', 'عُتْبَةَ مَنْ آذَاهُ يَقْتُلُونَا', 'وَنِعْمَةٌ مِنْ رَبِّنَا جَمِيل', 'خَمْسِينَ فَرْضًا فِي ابْتِدَاءِ فَرْضِهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَنْ وَصَفَتْ جَمَالَ خَيْرِ سَيِّدِ', ['فِي السَّنَةِ الثَّالِثَةِ كَانَتْ أُحُدْ', 'وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', 'وَوَصَلُوا لِبَيْتِ أُمِّ مَعْبَدِ', 'فَنَالَ ذَا فِي زَمَنِ الفَارُوقِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَشَرِبَ النَّبِيُّ طَهَ المُؤْتَمَن', ['صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه', 'فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن', 'لِيُؤْمِنُوا يُصَدِّقُوا بِدِينِهِ', 'فَمِنْهُمُ الْوَلِيدُ بْنُ الْمُغِيرَة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', ['عَلَيْهِ نُورٌ سَاطِعٌ وَهَيْبَة', 'وَالحُجُرَاتِ لِلْحَبِيبِ الأَسْعَدِ', 'وَقَدْ أَتَوْا فِي سَيْرِهِمْ أَيَّامَا', 'مُنَظِّمِينَ الْجَيْشَ بِالصُّفُوفِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُتَعَجِّبًا ........ مُسْتَبْشِرَا', ['مُتَسَائِلًا', 'مُلْتَزَمْ', 'مُعْجِزَةْ', 'مَكْتُومٍ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ جَمِيعُهُمْ وَسَارُوا', ['وَالْمَرْحَمَة', 'وَخَلَقْتُهُمْ', 'وَمَسَّهَا', 'وَأَسْلَمُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَنْ يُدْرِكُوا الْجَائِزَةَ الَّتِي لِمَنْ\nيَأْتِي بِخَيْرِ الْخَلْقِ طَهَ الْمُؤْتَمَنْ', ['كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', 'فَأَدْرَكُوا النَّبِيَّ فِي الطَّرِيقِ', 'لَكِنَّ رَأْيَ غَالِبِ الْأَنْصَارِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبُرَيْدَةُ سَارَ مَعَ سَبْعِينَا\nمِنْ قَوْمِهِ فِي الْفَوْزِ يَرْغَبُونَا', ['أَنْ يُدْرِكُوا الْجَائِزَةَ الَّتِي لِمَنْ', 'لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'أَخَذَهَا النَّبِيُّ بَعْدَ إِذْنِهَا', 'وَكَانَ ذَاكَ فِي تَمَامِ عَشْرِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا\nبَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا', ['وَاسْتَعْمَلَ الهَادِي أَبَا لُبَابَةْ', 'وَأَجَابَهُ عَنْ قَوْمِهِ بِأَسْلَمَا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'خَرَجَ النَّبِيُّ بِدِرْعِهِ ذَاتِ الفُضُول'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا', ['وَأَجَابَهُ عَنْ قَوْمِهِ بِأَسْلَمَا', 'فَرَجَعُوا بِخَيْبَةِ الآمَالِ', 'أَلْقَى عَلَيْهِمْ هَذِهِ الْحِجَارَةْ', 'فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فِي صُحْبَةِ الصِّدِّيقِ', ['لَقِيْ', 'لَهُمُ', 'لَاقَوْهُ', 'لِطَيْبَةَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَأَلَهُ خَيْرُ الْوَرَى عَنْ اسْمِهِ', ['وَكَثْرَةِ الأَعْدَادِ عِنْدَ المُشْرِكِينْ', 'وَسَأَلَهْ عَنْ أَهْلِهِ وَقَوْمِهِ', 'أَعَدَّ لِلْحُروبِ كانَ شَهْمَا', 'ابْنُ مَظْعُونٍ وَمَسْعُودٌ أَسْرَعَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ قَوْمِهِ فِي الْفَوْزِ يَرْغَبُونَا', ['فَآمَنَ ابْنُ مَسْعُودٍ وَأَيْقَنَا', 'وَبُرَيْدَةُ سَارَ مَعَ سَبْعِينَا', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا', 'كَانَ يَرَى الْمُقَامَ فِي الْمَدِينَةْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا', ['لِطَيْبَةَ يَلْقَاهُمُ الْأَنْصَارُ', 'وَلَم يَزَل مُدَافِعًا يَرْعَاهُ', 'عَلَى كُلِّ غَيْرِ مُؤْمِنٍ بِرَبِّهَا', 'بَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَأْتِي بِخَيْرِ الْخَلْقِ طَهَ الْمُؤْتَمَنْ', ['وَابْتَدَأَ الدُّخُولُ مِنْ قُبَاءَ', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'أَنْ يُدْرِكُوا الْجَائِزَةَ الَّتِي لِمَنْ', 'وَبَعْدَ مَا قَدْ أَكْمَلَ الْعِشْرِينَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَجَابَهُ عَنْ قَوْمِهِ ........', ['بِنْتِهِ', 'بِأَسْلَمَا', 'بِمَوْتِهِ', 'بِخَبَرٍ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَدْرَكُوا النَّبِيَّ فِي الطَّرِيقِ', ['لِطَيْبَةَ فِي صُحْبَةِ الصِّدِّيقِ', 'وَرَحْمَةٌ لِسَائِرِ الْعِبَادِ', 'مُعَادِيًا لِصَاحِبِ الْقُرْآنِ', 'وَكَثْرَةِ الأَعْدَادِ عِنْدَ المُشْرِكِينْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا', ['فَجَهَّزُوا الْجَيْشَ بِرِبْحِ الْمَالِ', 'وَجَاءَ وَحْشِيٌّ مِنْ أَهْلِ الْحَبَشَةِ', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا', 'أَبَى حَيَاءً أَنْ يُقِيمَ فَوْقَهُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'سَأَلَهُ خَيْرُ الْوَرَى عَنْ اسْمِهِ\nوَسَأَلَهْ عَنْ أَهْلِهِ وَقَوْمِهِ', ['وَدُّوا بِأَنْ يَرْتَدَّ مَنْ قَدْ آمَنَا', 'مِنْهُمْ كَانَ ابْنُ مَسْعُودٍ وَأَسْلَمَا', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا', 'قالَ يا رَبَّنا بِحَقِّ أَحْمَدا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِطَيْبَةَ ........ الْأَنْصَارُ', ['يُوفِي', 'يَشْتَكُونَا', 'يُفْرَغُ', 'يَلْقَاهُمُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ قَوْمِهِ فِي الْفَوْزِ ........', ['يَرُدَّهَا', 'يَسْمَعُهُ', 'يَرْغَبُونَا', 'يُعْطُونَهُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَسَأَلَهْ عَنْ أَهْلِهِ وَقَوْمِهِ', ['سَأَلَهُ خَيْرُ الْوَرَى عَنْ اسْمِهِ', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا', 'فَكَذَّبُوا كَلَامَهُ جُحُودًا', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَجَابَهُ عَنْ قَوْمِهِ بِأَسْلَمَا', ['لِلْبَدْرِ فَانْشَقَّ لَهُمْ لِنِصْفِهِ', 'وَلا كَمِثْلِ هاشِمٍ بَني أَبِ', 'فَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَدْرَكُوا النَّبِيَّ فِي الطَّرِيقِ\nلِطَيْبَةَ فِي صُحْبَةِ الصِّدِّيقِ', ['سَأَلَهُ خَيْرُ الْوَرَى عَنْ اسْمِهِ', 'مَنْ عَلَّمَ الْإِنْسَانَ مَا لَمْ يَعْلَمِ', 'إِلَى أَبِي سُفْيَانَ يَشْتَكُونَا', 'وَعَذَّبُوهُ غَايَةَ التَّعْذِيبِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَجَابَهُ ........ فَاسْتَبْشَرَا', ['بِمَا', 'بُرَيْدَةُ', 'بِجَنَّةِ', 'بِالْوَحْيِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِخَيْرِ الْخَلْقِ طَهَ الْمُؤْتَمَنْ', ['يَقْتُلْ', 'يَفُز', 'يَأْتِي', 'يَهتَدِي'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِطَيْبَةَ فِي صُحْبَةِ الصِّدِّيقِ', ['وَأَمَرَ النَّبِيُّ لِلرُّمَاةِ', 'فَأَدْرَكُوا النَّبِيَّ فِي الطَّرِيقِ', 'أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'يَخْرُجُ فِي وَقْتِ كَذَا عَنْ وَقْتِهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِطَيْبَةَ يَلْقَاهُمُ الْأَنْصَارُ', ['لَوْ أَنَّكَ أَعْتَقْتَ أَهْلَ الْقُوَّةِ', 'كانَ جَميعاً حُنَفاءَ دينُهُمْ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَجَابَهُ عَنْ قَوْمِهِ بِأَسْلَمَا\nفَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا', ['وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ', 'وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا', ['سِوَى القَلِيلِ عِنْدَ بَعْضِ القَوْمِ', 'ثَلَاثَ سِنِينَ بِغَيْرِ ذَنْبِ', 'بَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا', 'عَمَّ السُّرُورُ أَرْضَهُمْ إِلَى الْأَبَد'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ عَنْ أَهْلِهِ وَقَوْمِهِ', ['وَسَأَلَهْ', 'وَنَبَتَا', 'وَقَصْدُهُنَّ', 'وَالْكُلُّ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَنْ يُدْرِكُوا الْجَائِزَةَ الَّتِي لِمَنْ', ['عَنْ غَيْرِهِ مَوْلَاهُ قَدْ فَضَّلَهُ', 'أَعْتَقَهُ فَإِنَّهُ الرَّفِيقُ', 'يَأْتِي بِخَيْرِ الْخَلْقِ طَهَ الْمُؤْتَمَنْ', 'ثَلَاثَ عَشْرَ مُنْذُ وَقْتِ الْبَعْثَة'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبُرَيْدَةُ سَارَ مَعَ سَبْعِينَا', ['لِلْمُصْطَفَى بِوَاضِحِ الْبَيَانِ', 'جَاءُوا إِلَيْكُمْ خَلْفَ هَذَا سَائِرِين', 'قَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا', 'مِنْ قَوْمِهِ فِي الْفَوْزِ يَرْغَبُونَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنْ ........ الْجَائِزَةَ الَّتِي لِمَنْ', ['يَأْخُذُهُ', 'يُدْرِكُوا', 'يُؤْذِي', 'يُعْطِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبُرَيْدَةُ سَارَ مَعَ ........', ['سَبْعِينَا', 'سَلَّطا', 'سَاطِعٌ', 'سَمِعُوا'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَا بَيْنَ خَزْرَجٍ ........ أَوْسِهَا', ['وَبَيْنَ', 'وَكانَ', 'وَالِدِهْ', 'وَدَمِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَاشَ فِي بَيْتِ الصَّحَابِيِّ الجَلِيل', ['وَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ', 'وَسَارَ نَحْوَ طَيْبَةَ مُمَجَّدَا', 'بِدَعوَةِ النَّبِيِّ وَانزَاحَ العَمَى', 'أَبِي أَيُّوبَ الأَنْصَارِيِّ وَالنَّبِيل'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَابْتَدَأَ الدُّخُولُ مِنْ ........', ['قَطَعَ', 'قُلُوبِهِمْ', 'قِلَّةِ', 'قُبَاءَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَنِ النَّبِيِّ بَيْتَ ابِي أَيُّوبَا', ['فَرَجَعُوا بِالخِزْيِ عَادُوا كَمَدَا', 'وَنَبَذُوا العَهْدَ الَّذِي لَهُ أَمَدْ', 'وَأَنَّ هَذا القَوْلَ في تَنْزيلِها', 'لِلْمُصْطَفَى وَكَتَبَ كِتَابَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي الطَّابِقِ الأَعْلَى بِلَا نَدَامَةِ', ['وَاسْتَأْذَنَ المُخْتَارَ فِي الإِقَامَةِ', 'مِنْ بَيْنِ أَهْلِ الشِّرْكِ وَالْكُفَّارِ', 'خَرَجَ مِنْهَا ذَلِكَ النُّورُ الْمُبِين', 'آمِنَةُ وَمَنْ كَمِثْلِ آمِنَة؟!'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَضَاءَ ........ كُلُّ شَيْءٍ عِنْدَمَا', ['مِنْهَا', 'مُبَشِّرا', 'مُعِينَهْ', 'مِنْك'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ ذَا تَمَّ بِنَاءُ ........', ['أَتَاكُمْ', 'المَسْجِدِ', 'الْمُؤْتَمَن', 'الشَّهِيرَة'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ وَأَصْبَحُوا جَمِيعَا', ['تَوَحَّدُوا', 'تَمْكِينَا', 'تُنْزَفُ', 'تَوَقِّيَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاسْتَقْبَلُوهُ بِالدُّفُوفِ وَالغِنَا\nيَا سَعْدَهُمْ بِقُدُومِهِ يَا لَلْهَنَا', ['فَبِها تَكونُ زِيادَةُ الإيمانِ', 'مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'وَأَذِنَ الرَّحْمَنُ بِالقِتَالِ', 'أَضَاءَ مِنْهَا كُلُّ شَيْءٍ عِنْدَمَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي مَبْرَكِ نَاقَتِهِ أُقِيمَا', ['بَنَى بِهَا مَسْجِدَهُ العَظِيمَا', 'وَجَاءَ عَنْ أَبِي سَعِيدٍ الْخُدْرِيْ', 'جَاءَتْ إِلَى النَّبِيِّ ثُمَّ وَقَفَتْ', 'فَاللهُ أَلَّفَ بَيْنَكُمْ مِنْ بَعْدِ مَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ هَذَا الصَّاحِبُ المُؤَدَّبَا', ['فَنِعْمَ', 'فَضْلُهُ', 'فِيهِمْ', 'فَنَادَى'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَنَى فِي قُبَاءَ هَذَا المَسْجِدَا', ['يَمْضِي بِهِ فِي سَائِرِ الْآفَاقِ', 'فَاحْفَظْ لِنَصٍّ وَاضِحِ الْمَسَالِكِ', 'وَسَارَ نَحْوَ طَيْبَةَ مُمَجَّدَا', 'دُسْتُورُ هَذَا الدِّينِ وَالْبَيَانُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَبَى حَيَاءً أَنْ يُقِيمَ فَوْقَهُ', ['بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', 'نَبِيَّهُ وَكُلَّ مَنْ قَدْ آزَرَا', 'وَبِأَمْرِهِ مِنْ بَعْدِ ذَاكَ رَجَعَتْ', 'وَالمُصْطَفَى الهَادِي يَعِيشُ تَحْتَهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الْحِمْيَرِيَّ قَدْ بَنَى إِذْ سَمِعَا', ['وَرَوَى ابْنُ إِسْحَاقَ بِأَنَّ تُبَّعَا', 'تَبْغُونَهَا عِوَجًا بِتِلْكَ الآيَةِ', 'وَكَانَ ذَاكَ فِي تَمَامِ عَشْرِ', 'فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ........ الجُمُعَةِ بِالإِثْبَاتِ', ['مِائَةِ', 'مَبْعَثَ', 'مُشْرِكَةْ', 'مَسْجِدِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَيْهِ نُورٌ سَاطِعٌ وَهَيْبَة', ['وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ', 'عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', 'وَانْطَلَقَ النَّبِيُّ نَحْوَ طَيْبَة', 'قَالَ لَهُ أَعْجَبُ مِنِّي أَنْ تَرَى'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِفَضْلِهِ مِنْ بَعْدِ مَا جَاءَ لَهُمْ', ['مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ', 'وَرَوَى ابْنُ إِسْحَاقَ بِأَنَّ تُبَّعَا', 'وَبَعدَ الاولَى أَسلَمَ الفَارُوقُ', 'انْطَفَأَتْ نَارُ الحُرُوبِ بَيْنَهُمْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَتَّى أَتَى الْمُخْتَارَ لِلْأَحْفَادِ', ['سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ', 'صَدًّا عَنِ الدِّينِ الحَنِيفِ يُنْفِقُون', 'وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا', 'سَلَّمَهُ الْأَجْدَادُ لِلْأَوْلَادِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَتِ الْأَنْصَارُ سَائِرَ الْأَيَّام', ['عَلَى الوَفَاءِ وَالهُدَى مُؤَكَّدَة', 'يَأْتُونَ لِبَيْتِ النَّبِيِّ بِالطَّعَام', 'وَقَدْ رَأَى مَيْسَرَةُ الْعَجَائِبَا', 'يَأْتِيَانِ لَهُم بِمَا يَشَاءُوا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تَنَوَّرَتْ بِنُورِهِ المَدِينَة\nوَانْتَشَرَتْ فِي أَرْضِهَا السَّكِينَة', ['وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ', 'وَبَاضَتِ الحَمَامُ فِي المَكَانِ', 'بِأَنَّ رَبَّ العَرْشِ قَدْ أَوْحى إِلى', 'وَأَصْلَحَ النَّبِيُّ بَيْنَ أَهْلِهَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي شَهْرِ مِيلَادِ الحَبِيبِ الهَادِي', ['فِي يَوْمِ الاثْنَيْنِ بِنُورٍ بَادِي', 'بَكْرٍ أَيَا حَبِيبِيَ الْمُقَرَّبِ', 'ثَلَاثَ سِنِينَ بِغَيْرِ ذَنْبِ', 'وَأَذَلَّ دِينَ المُشْرِكِينَ أَهَانَهُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَصْلَحَ النَّبِيُّ بَيْنَ أَهْلِهَا', ['وَالمُصْطَفَى بِسُجُودِهِ يَدْعُو لَهُمْ', 'مَا بَيْنَ خَزْرَجٍ وَبَيْنَ أَوْسِهَا', 'حِمَايَةَ الظُّهُورِ وَالثَّبَاتِ', 'فَأَنْتَ خَيْرُ الْخَلْقِ يَا طَبِيبِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْأَجْدَادُ لِلْأَوْلَادِ', ['سُمِّي', 'سَلَّمَهُ', 'سِيرُوا', 'سَاكِنْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَضَاءَ مِنْهَا كُلُّ شَيْءٍ عِنْدَمَا', ['يَقُصُّ مَا رَأَى عَلَى زَوْجَتِهِ', 'نِطَاقَهَا وَلِلطَّعَامِ وَضَعَتْ', 'بِأَجْرِ خَمْسِينَ كَمَالًا فَضْلُهُمْ', 'وَصَلَهَا الهَادِي البَشِيرُ مُسَلِّمَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي مَبْرَكِ نَاقَتِهِ ........', ['الْمَذْكُورُ', 'اشْتِبَاهِ', 'أُقِيمَا', 'المَهْدِي'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَانْتَشَرَتْ فِي أَرْضِهَا السَّكِينَة', ['تَنَوَّرَتْ بِنُورِهِ المَدِينَة', 'وَظَنَّ بَعْضُ النَّاسِ أَنَّ الْمُصْطَفَى', 'عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَا تَمَّ بِنَاءُ المَسْجِدِ', ['مِنْهُمْ عَلَى اتِّبَاعِهِ اتِّفَاقَا', 'مَعَ أَنَّهُمْ بِكِتَابِهِمْ يَجِدُونَهَا', 'وَعَنْهُ حَقًّا أَبْعَدَ الحُسَّادَا', 'وَالحُجُرَاتِ لِلْحَبِيبِ الأَسْعَدِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الْحِمْيَرِيَّ قَدْ بَنَى إِذْ ........', ['سَارَتْ', 'سَعِيدَةٍ', 'سَمِعَا', 'سُلَيْمٍ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مِنْ بَعْدِ مَا جَاءَ لَهُمْ', ['بِقُرْبِهَا', 'بِفَضْلِهِ', 'بِالنَّصْرِ', 'بِكُلِّ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَنَى فِي قُبَاءَ هَذَا المَسْجِدَا\nوَسَارَ نَحْوَ طَيْبَةَ مُمَجَّدَا', ['بَنَى بِهَا مَسْجِدَهُ العَظِيمَا', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا', 'اللهُ يا مُحَمَّدٌ يَقولُ لَكَ', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الرُّعْبَ ثُمَّ خُمِّسَتْ أَمْوَالُهُمْ', ['وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ', 'وَهُمُ الْمُنَافِقُونَ كَانَ مُرَادُهُمْ', 'فَإِنَّهُ كانَ حَكيماً طَيِّبا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ', ['بِأَجْرِ خَمْسِينَ كَمَالًا فَضْلُهُمْ', 'مِنْ الْعَبِيدِ مُعْتِقًا وَمُوقِنَا', 'في صُلْبِهِ يُلَبّي مَنْ سَيَشْفَعُ', 'وَنَبَذُوا العَهْدَ الَّذِي لَهُ أَمَدْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهَا لِبَنِي قَيْنُقَاعِ', ['لِنَقْضِهِمْ لِلْعَهْدِ كَالأَفَاعِي', 'عَلَى حَبِيبِ رَبِّنَا مُحَمَّدِ', 'الْبَاسِطِ الْمَعْرُوفِ ذِي الْإِحْسَانِ', 'مَضْمُونَةٌ وَزَمْزَمُ الْمُحَبَّبَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِأَرْضِ الشَّامِ فِي إِجْلَائِهِمْ', ['سَببًا', 'سِيرُوا', 'سَيْرِهِمْ', 'سَارُوا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَنَقَضُوا لِلْعَهْدِ إِذْ ........', ['الْخَاتِمَة', 'التَّعْذِيبِ', 'أَسْمَاءُ', 'أَسَاؤُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَارَ النَّبِيُّ قَاصِدًا بِغَزْوَتِهْ', ['وَحَاوَلُوا أَنْ يُوقِعُوا الخُصُومَة', 'أَنَّ الصَّحِيفَةَ الَّتِي قَدْ كُتِبَتْ', 'وَبَعْدَ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ', 'وَبَنَى فِي قُبَاءَ هَذَا المَسْجِدَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا', ['عِنْدَ اقْتِرَابِ بَعْثَةِ الرَّسُولْ', 'وَرَبُّهُ قَد زَادَهُ تَمْكِينَا', 'ثَلَاثَ مَرَّاتٍ وَأَرْضًا أَوْقَعَه', 'مَعَ عَلِيٍّ أَبْيَضًا لِوَانَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَنْ لَا يُحَارِبُوهُ أَوْ يُظَاهِرُوا', ['عَلَيْهِ لِلْأَعَادِي بَلْ يُنَاصِرُوا', 'وَأَعْلَنُوا جَائِزَةَ الجِمَالِ', 'فِي ذَاتِهَا كُلُّ الْمَزَايَا كَامِنَة', 'قَالُوا نَعَمْ هَذَا الصَّحِيحُ وَالْجَلِي'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَكِنَّهُمْ عَادُوا بِلَا قِتَالِ\nوَغَنِمُوا غَنَائِمَ الرِّجَالِ', ['مِنْ بَعْدِ مَا هَمُّوا إِلَى القِتَالِ', 'وَبَعْدَ ذَا حَادِثَةُ الْإِسْرَاءِ', 'وَبَعْدَهَا لِبَنِي قَيْنُقَاعِ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا\nمَعَ عَلِيٍّ أَبْيَضًا لِوَانَا', ['لَكِنَّهُمْ عَادُوا بِلَا قِتَالِ', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا', 'فَرَجَعُوا بِخَيْبَةِ الآمَالِ', 'هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الرُّعْبَ ثُمَّ ........ أَمْوَالُهُمْ', ['خَزْرَجٍ', 'خَرَجَتِ', 'خَيرُ', 'خُمِّسَتْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَنَقَضُوا لِلْعَهْدِ إِذْ أَسَاؤُوا', ['عَنْ ذَلِكَ المَبْعوثِ وَيُنْبِئُهُمْ', 'يُخْبِرُهُمْ عَنْ شَأْنِ هَذَا الْيَوْمِ', 'وَأَنَّ هَذا القَوْلَ في تَنْزيلِها', 'لِامْرَأَةٍ مُسْلِمَةٍ فَبَاءُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'سَارُوا لِأَرْضِ الشَّامِ فِي إِجْلَائِهِمْ', ['وَأُخْرِجُوا إِذْ ذَاكَ مِنْ دِيَارِهِمْ', 'وَقِيلَ بَلْ لِسَعْدِ بْنِ عُبَادَةْ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'أَمَرَ اللهُ أرْمِياءَ كانا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَغَنِمُوا غَنَائِمَ الرِّجَالِ', ['ثُمَّ الزُّبَيْرُ طَلْحَةُ وَسَعْدُ', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ', 'لَكِنَّهُمْ عَادُوا بِلَا قِتَالِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ', ['وَبَشَّرَتْ', 'وَقالَ', 'وَبَعْدَ', 'وَبَعدَهَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَنْ لَا يُحَارِبُوهُ أَوْ يُظَاهِرُوا\nعَلَيْهِ لِلْأَعَادِي بَلْ يُنَاصِرُوا', ['مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'حَذَّرَهُمْ مِنْ دَعْوَى الجَاهِلِيَّةْ', 'وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'فَنَقَضُوا لِلْعَهْدِ إِذْ أَسَاؤُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ\nوَنَبَذُوا العَهْدَ الَّذِي لَهُ أَمَدْ', ['مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'فَأَدْرَكُوا النَّبِيَّ فِي الطَّرِيقِ', 'وَصَدَّقَتْهُ آمَنَتْ بِدِينِهِ', 'أَنْ لَا يُحَارِبُوهُ أَوْ يُظَاهِرُوا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَهَا لِبَنِي قَيْنُقَاعِ\nلِنَقْضِهِمْ لِلْعَهْدِ كَالأَفَاعِي', ['وَمَواقِفُ الأَصْحابِ كَيْفَ تَحَمَّلوا', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ', 'وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ', 'وَمَعَهُمْ قَبَائِلُ الْحُلَفَاءِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ', ['بِدِينِهِ فَأَسْلَمُوا أَكْثَرَهُمْ', 'وَاللهُ مِنْ أَنْوَارِهِ طَرَّزَهَا', 'وَأَشْهَدَ الصَّحْبَ عَلَى تَزْوِيجِهِ', 'سَارَ النَّبِيُّ قَاصِدًا بِغَزْوَتِهْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَكِنَّهُمْ ........ بِلَا قِتَالِ', ['عَادُوا', 'عَبْدِ', 'عَطْفِهِ', 'عَزَفَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ', ['الرُّعْبَ ثُمَّ خُمِّسَتْ أَمْوَالُهُمْ', 'أَتَوْا لَهُمْ مِنْ كَافَّةِ الْأَنْحَاءِ', 'أَتَاهُ وَحْيُ اللَّهِ حَقًّا مُنَعِمَا', 'فَاتَّبِعوهُ كَيْ تَنالوا الرَّشَدا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'سَارُوا لِأَرْضِ الشَّامِ فِي ........', ['الشَّجَرَة', 'إِجْلَائِهِمْ', 'الإيمانِ', 'الْأَوَامِرَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَيْهِ لِلْأَعَادِي بَلْ يُنَاصِرُوا', ['لِأَنَّهُ في صُلْبِهِ الرَّسولُ', 'وَابْتَدَأَ الدُّخُولُ مِنْ قُبَاءَ', 'أَنْ لَا يُحَارِبُوهُ أَوْ يُظَاهِرُوا', 'وَعَنِ ابنِ عَبّاسٍ رَوَى مَرْفوعا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَنَقَضُوا لِلْعَهْدِ إِذْ أَسَاؤُوا\nلِامْرَأَةٍ مُسْلِمَةٍ فَبَاءُوا', ['فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ', 'وَجَدُّهُ مَعَدٌّ سُمِّيَ لِمَا', 'وَهُمُ الْمُنَافِقُونَ كَانَ مُرَادُهُمْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ عَلِيٍّ أَبْيَضًا لِوَانَا', ['بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا', 'صَدًّا عَنِ الدِّينِ الحَنِيفِ يُنْفِقُون', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَنَبَذُوا العَهْدَ الَّذِي لَهُ أَمَدْ', ['فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', 'وَأَظْهَرُوا الغِلَّ وَأَظْهَروا الحَسَدْ', 'وَجَاءَ أَهْلُ الكُفْرِ وَالجَفَاءِ', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِنَقْضِهِمْ لِلْعَهْدِ كَالأَفَاعِي', ['في شَأْنِ آباءِ النَّبِيِّ نَقَلوا', 'وَغَيْرُ ذَا وَقَائِعُ كَثِيرَةْ', 'وَبَعْدَهَا لِبَنِي قَيْنُقَاعِ', 'وَعَقَدَ النَّبِيْ لِوَا الْأَوْسِ مَعًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ\nسَارَ النَّبِيُّ قَاصِدًا بِغَزْوَتِهْ', ['مِنْ بَعْدِ مَا عَلَى الأَذَى قَدْ صَبَرُوا', 'وَمَرِضَتْ هُنَاكَ عِنْدَ أَهْلِهَا', 'فِي دَارِ الأَرقَمِ مَعَ أَهلِ الصَّفَا', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَلَيْهِ لِلْأَعَادِي بَلْ ........', ['يَأْمُرُهُمْ', 'يَنْتَسِبْ', 'يُنَاصِرُوا', 'يُعَلِّمُوهُمُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَظْهَرُوا ........ وَأَظْهَروا الحَسَدْ', ['الأَعْلَى', 'الغِلَّ', 'آيَةٍ', 'أَعْيُنِهِمْ'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَيْرُ نِسَاءِ الْعَالَمِينَ فَاطِمَةْ', ['مُحَالِفًا لِعُصْبَةِ الْكُفَّارِ', 'أُمَّتَكَ أَنْ يُؤْمِنوا كُلٌّ يُقِرّ', 'وَأُمُّهَا خَدِيجَةُ الْمُكَرَّمَةْ', 'لَهُ عَسَى أَن يَهتَدِي وَيُفلِحُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي السَّنَةِ الثَّانِيَةِ لِلْهِجْرَةِ\nثُمَّ الزَّوَاجُ كَانَ فِي ذِي الْحِجَّةِ', ['أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر', 'لَكِنَّهُمْ عَادُوا بِلَا قِتَالِ', 'أَبَى حَيَاءً أَنْ يُقِيمَ فَوْقَهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ كَذَا الْفَارُوقُ بَعْدَهُ', ['صِدْقِ', 'صَارَعَهُ', 'صَاحِبِكُمْ', 'صِدِّيقُهُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر', ['عَلَى المَدِينَةِ وَمَضَى الصَّحَابَةْ', 'بِجَنَّةِ الْخُلُودِ فِيهَا يَنْعَمُوا', 'شَبِيهَةٌ بِالْمُصْطَفَى الْهَادِي الْأَغَر', 'وَالنَّصْرُ فِيهَا لِلْقُلُوبِ الخَاشِيَة'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَخُطِبَتْ فَاطِمَةُ مِنَ النَّبِيْ\nإِلَى عَلِيّ الطَّاهِرِ الْمُقَرَّبِ', ['امْضِ لِمَا قَدْ أَمَرَكَ الرَّحْمَن', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', 'خَيْرُ نِسَاءِ الْعَالَمِينَ فَاطِمَةْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَتَّى أَتَى الْكَرَّارُ يَخْطُبُ فَاطِمَا', ['حَتّى كَتَبْتُ لا إِلهَ إِلّا', 'مُحَمَّدٌ خَيْرُ نَبِيٍّ أُرْسِلَا', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', 'فَسَكَتَ النَّبِيُّ لَمْ يُجِبْهُمَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِمَا حَبَاهُ هَذِهِ ........', ['الْمَفَاخِرَا', 'الشُّورَى', 'الأَسْعَدِ', 'الْمُعَظَّمَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا\nحَتَّى تُوُفِّيَتْ وَقَدْ بَكَاهَا', ['وَقَدْ أَتَى إِلَى النَّبِيِّ قَبْلَهُ', 'فَكَانَ عَبْدُ اللَّهِ وَالِدُ أَحْمَدَا', 'وَأَسْلَمُوا جَمِيعُهُمْ وَسَارُوا', 'وَبَنَى فِي قُبَاءَ هَذَا المَسْجِدَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'دَرَاهِمَ إِذَا رَضِيْ عَلِيْ\nفَرَضِيَ بِمَا قَالَ النَّبِيْ', ['مِنْ بَعْدِ مَوْتِ بُخْتُنَصَّرَ أَتى', 'مِنْ بَعْدِ مَا ظُلِمُوا مِنَ الكُفَّارِ', 'وَخَرَّ سَاجِدًا لِلَّهِ شَاكِرا', 'فَنَقَضُوا لِلْعَهْدِ إِذْ أَسَاؤُوا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَهَا عَلَى أَرْبَعِ مِئَاتِ فِضَّة', ['مِنْ بَعْدِ مَا هَمُّوا إِلَى القِتَالِ', 'بِهِ جَمِيعُ الْأَنْبِيَاءِ بَشَّرُوا', 'وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ', 'أَمَرَهُ اللَّهُ بِأَنْ يُزَوِّجَه'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَشْهَدَ الصَّحْبَ عَلَى ........', ['تَمْكِينَا', 'تَنْزيلٍ', 'تَحَمَّلوا', 'تَزْوِيجِهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ\nإِحْدَى وَعِشْرِينَ كَمَا الْأَخْبَارِ', ['مُحَمَّدٌ وَأَحْمَدُ وَهَادِي', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا', 'فَأَرْضَعَتْ ثُوَيْبَةُ وَقْتَ الصِّغَر', 'وَغَيْرُهُ كَانَ إِلَيْهِمْ يَذْهَبُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'دَعَا لَهُ النَّبِيُّ وَلِابْنَتِهِ', ['وَنِعْمَةٌ مِنْ رَبِّنَا جَمِيل', 'وَأَشْهَدَ الصَّحْبَ عَلَى تَزْوِيجِهِ', 'فِي الطَّابِقِ الأَعْلَى بِلَا نَدَامَةِ', 'كَادَتْ بِهَذَا أَنْ تَكُونَ حَرْبَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَمَرَهُ ........ بِأَنْ يُزَوِّجَه', ['الْوُفُودُ', 'الصَّحِيحُ', 'أَيَا', 'اللَّهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى عَلِيّ الطَّاهِرِ الْمُقَرَّبِ', ['دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة', 'هُوَ أَوَّلُ الْخُطَبَاءِ حِينَ قَامَا', 'وَكَذَّبَ الْكُفَّارُ بِالْإِسْرَاءِ', 'وَخُطِبَتْ فَاطِمَةُ مِنَ النَّبِيْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر\nشَبِيهَةٌ بِالْمُصْطَفَى الْهَادِي الْأَغَر', ['وَحِينَ سَنَّ مُصْطَفَانَا الشُّورَى', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'فِي أَرْضِ نَجْدٍ قَصْدُهُمْ إِغَارَةْ', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَتَّى أَتَى الْكَرَّارُ يَخْطُبُ ........', ['فَاطِمَا', 'فَعَلُوا', 'فَهَدَاهُ', 'فَكَبَّرُوا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَيْرُ نِسَاءِ الْعَالَمِينَ فَاطِمَةْ\nوَأُمُّهَا خَدِيجَةُ الْمُكَرَّمَةْ', ['وَنَزَلَ النَّبِيُّ عِنْدَ رَأْيِهِمْ', 'وَبَعْدَ سَبْعٍ مِنْ لَيَالِي عَوْدَتِهْ', 'وَفَرَضَ اللَّهُ الصَّلَاةَ عِنْدَهَا', 'فِي السَّنَةِ الثَّانِيَةِ لِلْهِجْرَةِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثُمَّ الزَّوَاجُ كَانَ فِي ذِي الْحِجَّةِ', ['وَسَارُوا بِالْقِيَانِ وَالدُّفُوفِ', 'وَنَزَلَ النَّبِيُّ عِنْدَ رَأْيِهِمْ', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'فِي السَّنَةِ الثَّانِيَةِ لِلْهِجْرَةِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَخَرَّ سَاجِدًا لِلَّهِ شَاكِرا', ['لِمَا فِيهَا مِنْ رِقَّةٍ وَعَطْفِ', 'بِمَا حَبَاهُ هَذِهِ الْمَفَاخِرَا', 'أَجَابَ كَلَّا إِنَّنِي أُمِّيُّ', 'الْمُصْطَفَى وَالصَّادِقُ الْبَرُّ الْأَمِين'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَتَّى تُوُفِّيَتْ وَقَدْ بَكَاهَا', ['دَرَاهِمَ إِذَا رَضِيْ عَلِيْ', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا', 'هُوَ ضَمْضَمُ بْنُ عَمْرٍو الغِفَارِي'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِحْدَى وَعِشْرِينَ كَمَا الْأَخْبَارِ', ['يَجْمَعُهُمْ في كُلِّ يَوْمِ جُمُعَةِ', 'مَا مِنْ نَبِيٍّ إِلَّا قَدْ رَعَى الْغَنَمْ', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَدْ أَتَى إِلَى النَّبِيِّ قَبْلَهُ', ['إِلَهُنَا مِنَ الأَذَى عَافَاهُ', 'مَا قَالَهُ وَفَزِعُوا وَأَسْرَعُوا', 'صِدِّيقُهُ كَذَا الْفَارُوقُ بَعْدَهُ', 'لِلْمُصْطَفَى وَكَتَبَ كِتَابَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَرَضِيَ بِمَا قَالَ النَّبِيْ', ['فِي دَارِ الأَرقَمِ مَعَ أَهلِ الصَّفَا', 'دَرَاهِمَ إِذَا رَضِيْ عَلِيْ', 'وَبَكَوْا عَلَى مَا كَانَ ثُمَّ تَعَانَقُوا', 'وَأُخْرِجُوا إِذْ ذَاكَ مِنْ دِيَارِهِمْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي السَّنَةِ الثَّانِيَةِ ........', ['لِلغَارِ', 'لِأُمِّهِ', 'لِلْهِجْرَةِ', 'لُبَابَةْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَمْ يَتَزَوَّجْ ........ سِوَاهَا', ['مِمَّا', 'مُحَمَّدُ', 'مُصْطَفَاهُ', 'مَعَهَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ سِنُّ ........ الْكَرَّارِ', ['زِيَادَةِ', 'زُهْرَةَ', 'زَكَّاهُ', 'زَوْجِهَا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَخَرَّ سَاجِدًا لِلَّهِ شَاكِرا\nبِمَا حَبَاهُ هَذِهِ الْمَفَاخِرَا', ['وَلَمْ يَزَلْ يَقُولُ كُلَّ حِينٍ', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا', 'دَعَا لَهُ النَّبِيُّ وَلِابْنَتِهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَقَدْ أَتَى إِلَى النَّبِيِّ قَبْلَهُ\nصِدِّيقُهُ كَذَا الْفَارُوقُ بَعْدَهُ', ['إِنْ كَانَتِ الْأَقْدَاحُ قَدْ خَرَجَتْ عَلَى', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', 'أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'فَسَكَتَ النَّبِيُّ لَمْ يُجِبْهُمَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'شَبِيهَةٌ بِالْمُصْطَفَى الْهَادِي الْأَغَر', ['تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'يَبْكِينَ مَا كَانَ بِيَوْمِ بَدْرِ', 'إِلَى أَبِي سُفْيَانَ يَشْتَكُونَا', 'وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ كَعْبٌ أَقْصِدُ ابْنَ ........', ['الْأَشْرَف', 'الْكُفَّارَ', 'المُعَظَّمُ', 'الهِجْرَةِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَتَى قُرَيْشًا حَضَّهُمْ عَلَى الْقِتَالِ', ['بِعَهْدِهِ مَعَ النَّبِيْ لَمْ يُبَالِ', 'يَتَعَرَّضُونَ العِيرَ عِنْدَ طَرِيقِهِمْ', 'وَرَأَى رُكَانَة سَيِّدَ الْأَسْيَادِ', 'وَقَاطَعُوا لِلْأُسْرَةِ الشَّرِيفَة'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ', ['رُزِقْتُ حُبَّهَا بِكُلِّ لِينٍ', 'مُتَعَجِّبًا مُتَسَائِلًا مُسْتَبْشِرَا', 'وَنَاكِثًا لِلْعَهْدِ مِنْ خِصَالِهِ', 'مَوْلاَهُ بِالنَّصْرِ إِلَى أَنْ شَهِدَهْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ\nقَتَلُوهُ فِي بُعْدِ الْأَنْظَارِ', ['فَإِنَّهُ كانَ حَكيماً طَيِّبا', 'حَتَّى اسْتَرَاحَ النَّاسُ مِنْ أَذَاهُ', 'وَتَزَيَّنَتْ بِمَنِ انْتَمَتْ شَرَفًا لَهُ', 'وَشُلَّتِ الْيَدُ الَّتِي قَدْ كَتَبَتْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَتَّى ........ النَّاسُ مِنْ أَذَاهُ', ['أَبَاهُ', 'الْأَوْطَانِ', 'اسْتَرَاحَ', 'السِّيرَةِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ', ['وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ', 'وَكَانَ ذَا مَالٍ وَذَا إِكْثَارِ', 'وَجَيْشُهُمْ فِيهَا لَقِي دَمَارَهْ', 'سَببًا لِتِلْكَ الفِتْنَةِ قُرْآنَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ ........', ['الْكُفْرِ', 'الْكِرَامْ', 'المُؤْتَمَن', 'العَرَبْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لِلْمُصْطَفَى وَصَحْبِهِ الْأَبْرَارِ\nمُحَالِفًا لِعُصْبَةِ الْكُفَّارِ', ['يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ', 'وَحِينَهَا قَدْ سُمِّيَ الصِّدِّيقَا', 'أَقُولُ مَا هَذَا وَإِذْ أَسْمَعُهَا', 'وَبَنَى فِي قُبَاءَ هَذَا المَسْجِدَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مَنْ يَنْتَدِبْ لِقَتْلِ كَعْبٍ عِنْدَهَا', ['أَجَابَهُ ابْنُ مَسْلَمَةْ أَنَا لَهَا', 'إِحْدَى وَعِشْرِينَ كَمَا الْأَخْبَارِ', 'فَأَدْرَكَتْهُ رَحْمَةُ الْغَفَّارِ', 'وَالصَّبْرُ فِيهَا لِلْفَتَى مُلَازِم'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَتَّى اسْتَرَاحَ النَّاسُ مِنْ أَذَاهُ', ['حِينَ لَقِيْ مِنْ الْأَذَى نَكَالَا', 'مَعَ الحَبِيبِ كَانَ وَالمُهَذَّبَا', 'لِخَمْسَةٍ مَضَيْنَ مِنْ شَوَّالِ', 'وَفِي الْجَحِيمِ يَلْقَ مَا أَتَاهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَتَلُوهُ فِي بُعْدِ الْأَنْظَارِ', ['ضَرَبَهَا وَزَوجَهَا وَبَعدَهَا', 'عَقْدٌ فَرِيدٌ فِي العَوَالِمِ مَا لَهُ', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَنْ يَنْتَدِبْ لِقَتْلِ كَعْبٍ عِنْدَهَا\nأَجَابَهُ ابْنُ مَسْلَمَةْ أَنَا لَهَا', ['وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ', 'وَاشْتَدَّ إِيذَاءُ الصَّحَابَةِ الْأُلِي', 'كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ', 'حَتّى كَتَبْتُ لا إِلهَ إِلّا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ\nوَنَاكِثًا لِلْعَهْدِ مِنْ خِصَالِهِ', ['وَاجْتَمَعَ قَوْمٌ مِنَ الْأَجَانِبِ', 'وَخَصَّهَا بِأَشْرَفِ الْمَزَايَا', 'وَالْبَيْهَقِيُّ قَدْ رَوى وَأَثْبَتا', 'أَتَى قُرَيْشًا حَضَّهُمْ عَلَى الْقِتَالِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَتَى قُرَيْشًا حَضَّهُمْ عَلَى الْقِتَالِ\nبِعَهْدِهِ مَعَ النَّبِيْ لَمْ يُبَالِ', ['قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي', 'وَبَعْدَها بِمَوْتِ عَبْدِ المُطَّلِب', 'وَأَصْلَحَ النَّبِيُّ بَيْنَ أَهْلِهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُحَالِفًا لِعُصْبَةِ الْكُفَّارِ', ['لِلْمُصْطَفَى وَصَحْبِهِ الْأَبْرَارِ', 'وَجَاءَ وَفْدُ طَيْبَةَ وَآمَنُوا', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَانَ كَعْبٌ أَقْصِدُ ابْنَ الْأَشْرَف', ['مِنْ خُفِّ رَاحِلَةٍ لَهُ وَانْفَجَرَتْ', 'مُعَادِيًا عَدَاوَةً لَمْ تُوصَف', 'وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'أَنَا جَارُكُمْ زَيَّنْ لَهُمْ أَعْمَالَهُمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ', ['عَنْ ابنِ عَبّاسِ الإِمامِ قَدْ أَتى', 'مُنْتَدِبًا لِقَتْلِهِ الْأَقْوَامْ', 'بْنِ الْمُنْذِرِ الصَّاحِبِ الْأَوَّابِ', 'شَقًّا لِبَدْرٍ فِي السَّمَاءِ مُعْلِنَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ\nوَكَانَ ذَا مَالٍ وَذَا إِكْثَارِ', ['وَخَرَّ سَاجِدًا لِلَّهِ شَاكِرا', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ', 'سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَنَاكِثًا لِلْعَهْدِ مِنْ خِصَالِهِ', ['مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ', 'إِنْ كَانَتِ الْأَقْدَاحُ قَدْ خَرَجَتْ عَلَى', 'يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ', 'وَخَرَّ سَاجِدًا لِلَّهِ شَاكِرا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَكَانَ كَعْبٌ أَقْصِدُ ابْنَ الْأَشْرَف\nمُعَادِيًا عَدَاوَةً لَمْ تُوصَف', ['نَدِمُوا عَلَى مَا كَانَ مِنْ أَفْعَالِ', 'لِلْمُصْطَفَى وَصَحْبِهِ الْأَبْرَارِ', 'وَعَقَدَ النَّبِيْ لِوَا الْأَوْسِ مَعًا', 'ثُمَّ السَّرَايَا سَبْعَةٌ وَأَرْبَعُونْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَجَابَهُ ابْنُ مَسْلَمَةْ أَنَا لَهَا', ['مِنْ بَعْدِ مَا هَمُّوا إِلَى القِتَالِ', 'وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ', 'مَنْ يَنْتَدِبْ لِقَتْلِ كَعْبٍ عِنْدَهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَانَ ذَا مَالٍ وَذَا إِكْثَارِ', ['لِيُلْبِسُوا البَاطِلَ ثَوْبَ الحَقِّ', 'يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا', 'فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِعَهْدِهِ مَعَ النَّبِيْ لَمْ يُبَالِ', ['أَتَى قُرَيْشًا حَضَّهُمْ عَلَى الْقِتَالِ', 'وَأُعْتِقَتْ بِفَضْلِهِ لَمَّا أَتَى', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'وَأَصْطَلَحَ الرُّوَاةُ فِي التَّسْمِيَةْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فِي بُعْدِ الْأَنْظَارِ', ['قَتَلُوهُ', 'قَطَعَ', 'قَصَّتْ', 'قَرَأَهَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ\nمُنْتَدِبًا لِقَتْلِهِ الْأَقْوَامْ', ['وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', 'وَظَنَّ بَعْضُ النَّاسِ أَنَّ الْمُصْطَفَى', 'فِي دَارِ الأَرقَمِ مَعَ أَهلِ الصَّفَا', 'مَنْ يَنْتَدِبْ لِقَتْلِ كَعْبٍ عِنْدَهَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِعُصْبَةِ الْكُفَّارِ', ['مَعَهُمَا', 'مُؤَكَّدَة', 'مُحَالِفًا', 'مَكانِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَفِي ........ يَلْقَ مَا أَتَاهُ', ['الْخَاتَمُ', 'الْبَهَائِم', 'الجِمَالِ', 'الْجَحِيمِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ', ['بِالْأَنْبِيَاءِ السَّادَةِ الْأَجْلَّا', 'كَادَتْ بِهَذَا أَنْ تَكُونَ حَرْبَا', 'هُوَ النَّبِيُّ الظَّاهِرُ الْإِبْلَاج', 'قَتَلُوهُ فِي بُعْدِ الْأَنْظَارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَتَى قُرَيْشًا حَضَّهُمْ عَلَى ........', ['الْقِتَالِ', 'أَسَفَهُ', 'الجُمُعَةِ', 'البَشِيرُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُنْتَدِبًا لِقَتْلِهِ الْأَقْوَامْ', ['وَقَدْ أَقَامَ الْمُصْطَفَى فِي مَكَّة', 'فَسَكَتَ النَّبِيُّ لَمْ يُجِبْهُمَا', 'فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'رَدَّ نَبِيُّنَا عَلَيْهِ سَيْفَهُ', ['مِنْ خُفِّ رَاحِلَةٍ لَهُ وَانْفَجَرَتْ', 'حَتَّى تُوُفِّيَتْ وَقَدْ بَكَاهَا', 'وَبَارَكَ اللَّهُ بِهِ فِي عَيْشِهِمْ', 'وَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِغَزْوَةِ أَنْمَارِ', ['وَكَمْ', 'وَسُمِّيَتْ', 'وُلِدْتُ', 'وَمَعَهُمُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ رَأْسُ الْعَدُوِّ عِنْدَهَا', ['فُؤَادِ', 'فَتَكْرَهُونَ', 'فَسَارَ', 'فَجَاءَهُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَخَذَ بِسَيْفِهِ ........ لَهْ', ['وَإِذْ', 'وَمَالِهِ', 'وَقَالَ', 'وَأَنْتَ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَحَدُهُمْ بِأَنَّهُمْ قَدْ هَرَبُوا', ['طَهَّرَهُمْ بِهِ كَمَا قَدْ أَخْبَرَا', 'إِلَى رُؤُوسٍ لِلْجِبَالِ ذَهَبُوا', 'مَوْلاَهُ بِالنَّصْرِ إِلَى أَنْ شَهِدَهْ', 'عَلَى المَدِينَةِ وَمَضَى الصَّحَابَةْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَنْ يَمْنَعُكَ مِنِّي مَا أَكْمَلَهْ', ['فَكَانَ نَصْرًا ظَاهِرًا مُبِينًا', 'وَزَيْنَبُ رُقَيَّةُ وَفَاطِمَة', 'فَجَاءَهُمْ طَيْرٌ أَبَابِيلُ وَمَا', 'أَخَذَهُ النَّبِيُّ ثُمَّ قَالَ لَهْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هُمُ بَنُو ........ وَمُحَارِبِ', ['ثِيَابَهْ', 'ثَوْبَ', 'ثَلَاثَةً', 'ثَعْلَبَةْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِدِينِهِ فَأَسْلَمُوا ........', ['إِخْوَانَا', 'الْكُفَّارِ', 'إِلَيْكُمْ', 'أَكْثَرَهُمْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَارَ مَعَهُمْ وَاسْمُهُ حِبَارٌ\nلِذِي أَمْرٍ فَنَزَلَتِ الْأَمْطَارُ', ['تَبَلَّلَتْ مَلَابِسُ الصَّحَابَةْ', 'لَمْ يَدْخُلَا الإِسْلَامَ قَدْ خَافَا عَلَى', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'عَنْ سائِرِ الخَلْقِ قُرَيْشاً وَالعَرَبْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'سَارَ إِلَيْهِمْ مَعَهُ أَرْبَعُمِائَةْ\nوَمَعَهُمْ خَمْسِينَ ثُمَّ أَنْبَأَهُ', ['فِي المَرَّةِ الأُولَى قَلِيلٌ أَسْلَمُوا', 'عَنِ النَّبِيِّ بَيْتَ ابِي أَيُّوبَا', 'أَحَدُهُمْ بِأَنَّهُمْ قَدْ هَرَبُوا', 'وَتَزَيَّنَتْ بِمَنِ انْتَمَتْ شَرَفًا لَهُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تَبَلَّلَتْ مَلَابِسُ الصَّحَابَةْ\nفَنَشَرَ نَبِيُّنَا ثِيَابَهْ', ['سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ', 'فِي فَرْعِ شَجَرَةْ وَنَامَ تَحْتَهَا', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَسَقَطَ عَنْهُ السَّيْفُ مِنَ الْيَدِ', ['وَآلِهِ وَصَحْبِهِ الْأَطْهَارِ', 'لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ', 'فَنَالَ ذَا فِي زَمَنِ الفَارُوقِ', 'قَالَ لَهُ اللَّهُ بِلَا تَرَدُّدِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي أَرْضِ نَجْدٍ قَصْدُهُمْ ........', ['إِغَارَةْ', 'الْأُمَمْ', 'إِيَّاكُمُ', 'آمِنًا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَنَطَقَ الرَّجُلُ بِالشَّهَادَةْ', ['شَمائِلَ الهادي وَذا يَكْفيها', 'فَنَالَ بِإِسْلَامِهِ السَّعَادَةْ', 'لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', 'بَكْرٍ أَيَا حَبِيبِيَ الْمُقَرَّبِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَخَذَ بِسَيْفِهِ وَقَالَ لَهْ', ['الْمُصْطَفَى وَالصَّادِقُ الْبَرُّ الْأَمِين', 'مَنْ يَمْنَعُكَ مِنِّي فَأَذْهَلَهْ', 'ابْنُ مَظْعُونٍ أَعْلَنُوا الْإِيمَانَا', 'كُنْتُمْ أَعَادِي وَأَزَالَ النَّدَمَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَسَقَطَ عَنْهُ ........ مِنَ الْيَدِ', ['السَّيْفُ', 'أَهْلًا', 'أَيَّامَا', 'الجَمْعَانِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَحَدُهُمْ بِأَنَّهُمْ قَدْ هَرَبُوا\nإِلَى رُؤُوسٍ لِلْجِبَالِ ذَهَبُوا', ['فَتَكَلَّمَ الأَصْحَابُ حَتَّى سَرَّهُ', 'زَكَّاهُ رَبُّ الْعَرْشِ فِي الْكِتَابِ', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ', 'وَسَارَ مَعَهُمْ وَاسْمُهُ حِبَارٌ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِذِي أَمْرٍ فَنَزَلَتِ الْأَمْطَارُ', ['وَسَارَ مَعَهُمْ وَاسْمُهُ حِبَارٌ', 'مِنْ بَعْدِ ثَلَاثٍ مِنَ السِّنِينَا', 'الصَّادِقُ الْمَصْدُوقُ طه الْمُصْطَفَى', 'وَمَعَهُنَّ خَرَجَتِ النِّسَاءُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَعَهُمْ خَمْسِينَ ثُمَّ أَنْبَأَهُ', ['وَاسْتَحْسَنَ الْأَشْيَاخُ عِنْدَ ذِكْرِهِمْ', 'سَارَ إِلَيْهِمْ مَعَهُ أَرْبَعُمِائَةْ', 'وَآلِهِ وَصَحْبِهِ الْأَطْهَارِ', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَنَطَقَ الرَّجُلُ بِالشَّهَادَةْ\nفَنَالَ بِإِسْلَامِهِ السَّعَادَةْ', ['رَدَّ نَبِيُّنَا عَلَيْهِ سَيْفَهُ', 'حَتَّى أَتَاهُ الإِذْنُ بَعْدَ فَتْرَةِ', 'جَاءَتْ إِلَى النَّبِيِّ ثُمَّ وَقَفَتْ', 'فَازَتْ بِهِ بِنْتُ خُوَيْلِدٍ فَمَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَاجْتَمَعَ قَوْمٌ مِنَ الْأَجَانِبِ', ['فِيهِ ثَلَاثَ لَيَالٍ قَد مَكَثَا', 'أَمْنٌ مِنَ النُّعَاسِ بَيْنَ الْقَوْمِ', 'هِيَ الَّتِي أَسْدَتْ لَهُ عَطَاءَهَا', 'هُمُ بَنُو ثَعْلَبَةْ وَمُحَارِبِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي أَرْضِ نَجْدٍ قَصْدُهُمْ إِغَارَةْ', ['بِأَنَّ هَذِهِ هِيَ الْمَدِينَةُ', 'فَجَهَّزَ نَبِيُّنَا أَنْصَارَهْ', 'كِلَابِ مُرَّةَ بْنِ كَعْبِ بْنِ لُؤَيْ', 'قَدْ سَمِعُوا لِلْوَحْيِ وَالتَّنْزِيلِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَنْ يَمْنَعُكَ مِنِّي مَا ........', ['أَكْرِمْ', 'أَكْمَلَهْ', 'إِلاَّ', 'أَخَذَهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَنَشَرَ نَبِيُّنَا ثِيَابَهْ', ['وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ', 'تَبَلَّلَتْ مَلَابِسُ الصَّحَابَةْ', 'بِأَنَّ جِبْريلَ الأَمينَ أَقْبَلا', 'يَوْمٌ أَعَزَّ اللهُ فِيهِ دِينَهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي فَرْعِ شَجَرَةْ وَنَامَ تَحْتَهَا', ['فَجَاءَهُ رَأْسُ الْعَدُوِّ عِنْدَهَا', 'ثُمَّ دَنَا مِنْ رَبِّهِ مُشَافِهَا', 'مِن بَعدِ حَمزَةَ عَلَى اليَقِينِ', 'الْمُرْشِدَاتِ لِلْهُدَى وَالظَّاهِرَاتِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسُمِّيَتْ بِغَزْوَةِ أَنْمَارِ', ['وَغَطَفَانَ كَمَا فِي الْأَخْبَارِ', 'أَقْوَامَهُمْ لِيُؤْمِنُوا وَيَظْفَرُوا', 'حَجَرًا بِمَكَّةَ لَهُ وَيَصِفُ', 'إِلَى بِلَادٍ لَيْسَ فِيهَا ضَيْرُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِدِينِهِ فَأَسْلَمُوا أَكْثَرَهُمْ', ['وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ', 'تَلَا عَلَيْهِم حِينَهَا يَاسِينَا', 'وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'ثُمَّ مَضَى لِقَوْمِهِ يُنْذِرُهُمْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'رَدَّ نَبِيُّنَا عَلَيْهِ سَيْفَهُ\nوَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ', ['كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ', 'فَكَذَّبَ الْكُفَّارُ مَا حَكَاهُ', 'فَنَالَ ذَا فِي زَمَنِ الفَارُوقِ', 'ثُمَّ مَضَى لِقَوْمِهِ يُنْذِرُهُمْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاجْتَمَعَ قَوْمٌ مِنَ الْأَجَانِبِ\nهُمُ بَنُو ثَعْلَبَةْ وَمُحَارِبِ', ['وَسُمِّيَتْ بِغَزْوَةِ أَنْمَارِ', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'وَجَهَّزَ الدَّلِيلَ لِلطَّرِيقِ', 'مَنْ قَالَ إنَّهُ أَعَزُّ مِنِّي'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَخَذَ بِسَيْفِهِ وَقَالَ لَهْ\nمَنْ يَمْنَعُكَ مِنِّي فَأَذْهَلَهْ', ['قَالَ لَهُ اللَّهُ بِلَا تَرَدُّدِ', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا', 'كَذَاكَ فِي الثَّانِيَةِ وَغَيْرِهَا', 'سُمَيَّةُ وَابْنُهَا عَمَّارْ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الطَّاهِرِ النَّدِيِّ يَأْكُلُونْ', ['فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', 'زَكَّاهُ رَبُّ الْعَرْشِ فِي الْكِتَابِ', 'مَضْنُونَةٌ لِأَنَّهَا ضُنَّ بِهَا', 'مِنْ كَفِّهِ المُبَارَكِ المَيْمُونْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يَدْعُو بِهَا النَّبِيُّ لِلصَّحَابَةْ\nفَسَارَعُوا إِذْ ذَاكَ بِالإِجَابَةْ', ['نَحْنُ الذِينَ بَايَعُوا مُحَمَّدَا', 'قَالَ الرَّاعِي وَاعَجَبًا مِمَّا أَرَى', 'ومؤتة في ثَامن الأعوامِ', 'وَحَامِلُ اللِّوَاءِ إِذْ ذَاكَ عَلِي'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَفْدِيهِ رُوحِي الصَّادِقَ الأَمِينَا', ['وَبَعْدَها بِمَوْتِ عَبْدِ المُطَّلِب', 'فَحَبَّذَا رَبًّا وَحُبَّ دِينَا', 'لَمَّا رَأَى مِنْ خُلُقِ الْحَبِيبْ', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَحْكِي لَنَا عَنْ ........ الأَحْزَابْ', ['غَيْرَ', 'غَدِيرْ', 'غَنِمُوا', 'غَزْوَةِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَثْرَةُ الطَّعَامِ عِنْدَ قِلَّتِهِ', ['بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', 'لِوَضْعِهِ الْقِيَامَ مِنْ تَعْظِيمِهِمْ', 'فَإِنَّهَا كَذَاكَ مِنْ مُعْجِزَتِهِ', 'بِغَيْرِهِمْ مِنْ أَحَدٍ مِنْ بَاقِي النَّاس'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاللهِ لَوْ لَا أَنْتَ مَا اهْتَدَيْنَا\nوَلَا تَصَدَّقْنَا وَلَا صَلَّيْنَا', ['فَأَنْزِلَنْ سَكِينَةً عَلَيْنَا', 'فَجَاءَ جِبْرِيلُ الْأَمِينُ رَافِعًا', 'فِي السَّنَةِ الثَّانِيَةِ لِلْهِجْرَةِ', 'وَغَيْرُهُ كَانَ إِلَيْهِمْ يَذْهَبُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'نَحْنُ الذِينَ بَايَعُوا مُحَمَّدَا', ['فَإِنَّهُمْ ساداتُ أَشْرافِ العَرَب', 'وَبِالْبَنَاتِ ثُمَّ بِالْأَحْفَادِ', 'أَعْنِي الَّتِي بِنَفْسِهِ فِيهَا حَضَرْ', 'عَلَى الجِهَادِ مَا بَقِينَا أَبَدَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَنِ ابْنِ عَازِبِ ........ شَاهِدَا', ['السَّمَاوَاتِ', 'أَجَابَ', 'الْحَرِّ', 'البَرَاءِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَأَصْبَحَتْ رَمْلًا يَسِيلُ عَجَبَا', ['لَكِنَّهُمْ قَامُوا لَهُ وَقَالُوا', 'بَيْنَ الْمَقَاعِدِ وَبَيْنَهُمْ يَحُولْ', 'سَمَّى بِبِسْمِ اللهِ ثُمَّ ضَرَبَا', 'أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'جَاءَتْ لَهُ ........ اليَسِيرْ', ['بِأَهْلِهَا', 'بِكَفِّهِ', 'بَرَكَتْ', 'بِتَمْرِهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَشْرَةُ آلَافٍ لِطَهَ سَارُوا', ['اِتَّحَدَ اليَهُودُ وَالكُفَّارُ', 'تَلَا عَلَيْهِم حِينَهَا يَاسِينَا', 'عَلَيْهِ آيَاتٌ بِخَتْمِ النَّحْلِ', 'ضَرَبَهَا وَزَوجَهَا وَبَعدَهَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'اِكْشِفْ لِهَمِّي رَبَّنَا وَكَرْبِي', ['فَكَانَ حَقًّا أَهْلًا لِلْأَمَانَةْ', 'يُقَاتِلُونَ أَصْحَابَ الرَّسُولِ', 'أَنْتَ تَرَى مَا حَلَّ بِي وَبِصَحْبِي', 'وَالنَّصْرُ فِيهَا لِلْقُلُوبِ الخَاشِيَة'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَدْعُو لَهُمْ وَيَحُثُّهُمْ عَلَى العَمَلْ', ['دَعَا لَهُ إِمَامُ أَهْلِ الفَضْلِ', 'يَزْرَعُ فِي قُلُوبِهِمْ نَبْتَ الأَمَلْ', 'مَنْ يَمْنَعُكَ مِنِّي مَا أَكْمَلَهْ', 'أَرْبَعَةً فَأَسْعَدِ الْأَيَّامَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'إِلَهِي يَا سَرِيعًا لِلْحِسَابْ', ['اُنْصُرْنَا رَبِّي وَاهْزِمِ الأَحْزَابْ', 'وَأَخْرَجُوهُ مِنْ حِمَى الْأَوْطَانِ', 'فِي شَهْرِ شَوَّالَ الَّذِي مِنْ عَامِهِمْ', 'فَأَرَادَ مِنْ أَحْمَدَ أَنْ يُصَارِعَهْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مَا بَيْنَ لَابَتَيِ المَدِينَةْ\nوَأُعْطِيَ المَفَاتِحَ الثَّمِينَةْ', ['الشَّامَ وَالفُرْسَ كَذَا أَرْضَ اليَمَنْ', 'قَالَ النَّبِيُّ إِنَّنِي لَأَعْرِفُ', 'لَمْ يَتَخَلَّفْ مِنْهُمُ إِلاَّ القَلِيل', 'قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحَدِيثُهُمْ لَا عَيْشَ إِلَّا الآخِرَةْ', ['أَنْصَارِهِمْ جَمِيعِهِمْ وَمُهَاجِرِين', 'فَأَكْرِمِ الأَنْصَارَ وَالمُهَاجِرَةْ', 'وَلَا تَصَدَّقْنَا وَلَا صَلَّيْنَا', 'فَإِنَّهُمْ قُلُوبُهُمْ سَقِيمَةْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُرَدِّدًا لِقَوْلِهِ أَبَيْنَا', ['طَرَقَ البَابَ لَم يَقُم مِنهُم أَحَد', 'وَجَاءَهُ جِبْرِيلُ عِنْدَ الْأَرْبَعِين', 'وَيَرْفَعُ الصَّوْتَ كَمَا رُوِينَا', 'أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَهِي يَا مُجِيبَ المُضْطَرِّينَا', ['البَطْشَةُ الكُبْرَى الَّتِي ذُكِرَتْ كَمَا', 'إِلَهِي يَا صَرِيخَ المَكْرُوبِينَا', 'وَالأَمْرُ بِالأَذَانِ لِلصَّلَاةِ', 'وَسَارَ خَيْرُ الْخَلْقِ بِالْكِرَامِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي الحَفْرِ كُدْيَةٌ لَهُمْ قَدْ عَرَضَتْ', ['وَقَبْرُهُ الكَريمُ بِالرَّوْحاءِ', 'عَنْ جَابِرٍ عَنْ ذَاكَ يَحْكِي ظَهَرَتْ', 'دُخُولَكُمْ لِلْبَلَدِ الْحَرَامِ', 'وَأَرْسَلَ النَّبِيُّ لِإبْنِ سَلُولْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَاجْتَمَعُوا عَلَيْهِ ثُمَّ أَكَلُوا\nوَكَانَ يَزْدَادُ إِلَى أَنْ شَبِعُوا', ['فَانْطَلَقُوا وَخُذُوا ذَاتَ الْيَمِينِ', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'مِنْ كَفِّهِ المُبَارَكِ المَيْمُونْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَدَعَا لَهُ أَصْحَابَهُ جَمِيعَا', ['بَلْ مِنْ كَلَامِ الصَّحْبِ فِي أَيَّامِهِ', 'هَلُمَّ نَحْوَ غَدَائِكُمْ سَرِيعَا', 'فَكَانَ مَا قَالَ عَلَى التَّمَامِ', 'مُعَادِيًا لِصَاحِبِ الْقُرْآنِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ لَهَا خَيْرُ الوَرَى هَاتِيهِ\nصَبَّتْهُ لَمْ يَمْلَأْ لَهُ كَفَّيْهِ', ['الشَّامَ وَالفُرْسَ كَذَا أَرْضَ اليَمَنْ', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ', 'وَدَعَا لَهُ أَصْحَابَهُ جَمِيعَا', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَلْ مِنْ كَلَامِ الصَّحْبِ فِي أَيَّامِهِ', ['وَتَنَازَعُوا وَذَهَبُوا لِلْكَاهِنَة', 'وَكُلُّ هَذَا لَيْسَ مِنْ كَلَامِهِ', 'رَدَّ نَبِيُّنَا عَلَيْهِ سَيْفَهُ', 'مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَخْرَجَ البَيْهَقِيْ عَنْ سَلْمَانْ\nمَا قَالَهُ حَبِيبُنَا العَدْنَانْ', ['بِسْمِ الإِلَهِ وَبِهِ بَدِينَا', 'وَنَزَلَ الرُّمَاةُ مِنْ فَوْقِ الْجَبَلْ', 'ثُمَّ مَضَى لِقَوْمِهِ يُنْذِرُهُمْ', 'وَعَادَ بَعْدَ ذَاكَ نَحْوَ بَيْتِهِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَمَرَ الحَبِيبُ صَحَابَهُ بِالجَدِّ', ['فَرَجَعُوا بِالخِزْيِ عَادُوا كَمَدَا', 'فِي حَفْرِهِ فَظَفِرُوا بِالسَّعْدِ', 'أَنْفُسَهُمْ كَذَا مَالَ الصَّحَابَةِ', 'مِن قَابِلٍ إِلَى النَّبِيْ وُفُودُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَشَارَ سَلْمَانُ ........ حِينَهَا', ['عَمُّهُ', 'عَلَّمَ', 'عَلِي', 'عَلَيْهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَزَادَ فِي ........ البَرَاءْ', ['رِوَايَةِ', 'رَاهِبُ', 'رَجَعْ', 'رَدَمَهَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ السُّرُورُ فِي وَجْهِ النَّبِي', ['فَرَجَعُوا', 'فِيكُمُ', 'فَعُرِفَ', 'فَأَتَى'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَنْزِلَنْ سَكِينَةً ........', ['عِنْدَهَا', 'عَادْ', 'عَشْرَ', 'عَلَيْنَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِأَنَّ طَهَ لَمْ يَكُنْ بِشَاعِرٍ', ['وَبِحَبْلِ رَبِّ العَالَمِينَ تَمَسَّكُوا', 'حَاشَاهُ بَلْ وَحْيٌ أَتَى بِبَشَائِرٍ', 'وَاللهُ قَدْ أَهْدَى لَهُمْ نَبِيَّهْ', 'يَكْفِي بِأَنَّهُ كَشْفًا رَآهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَشَّرَهُمْ ........ خَيْرُ مُؤْتَمَنْ', ['بِحِقْدِهِ', 'بِالأَذَى', 'بِدِينِهِ', 'بِالفَتْحِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَيْ غَزْوَةُ الخَنْدَقِ يَا أَصْحَابِي', ['أَتَى قُرَيْشًا حَضَّهُمْ عَلَى الْقِتَالِ', 'وَبَعْدَ ذَاكَ غَزْوَةُ الأَحْزَابِ', 'مِنْ بَعْدِ ضِيقٍ فِي الْحَيَاةِ وَنَكَد', 'مُحَمَّدٌ الهَادي رَسولُ اللهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قِيلَتْ لَهُ شُكْرًا فَقَدْ وَفَّيْتْ', ['سَلْمَانُ مِنَّا نَحْنُ أَهْلَ البَيْتْ', 'مِنْ بَعْدِ ثَلَاثٍ مِنَ السِّنِينَا', 'لَكِنَّ بَعْضَ الْقَوْمِ آذَاهُ بِمَا', 'فَإِنَّهُمْ لِرَبِّنَا اسْتَجَابُوا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَظَهَرَتْ فِي الحَفْرِ بَعْضُ المُعْجِزَاتْ\nكَمَا رَوَى البُخَارِيْ عَنْ بَعْضِ الرُّوَاتْ', ['عَنْ جَابِرٍ عَنْ ذَاكَ يَحْكِي ظَهَرَتْ', 'قَالَ النَّبِيُّ لِلصَّحَابَةِ الْكِرَامْ', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'بَيْنَ الْمَقَاعِدِ وَبَيْنَهُمْ يَحُولْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَدَعَا نَبِيُّنَا عَلَى الأَحْزَابْ', ['الرُّعْبَ ثُمَّ خُمِّسَتْ أَمْوَالُهُمْ', 'بَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا', 'قَالَ اللَّهُمَّ مُنْزِلَ الكِتَابْ', 'لَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِسْمِ الإِلَهِ وَبِهِ بَدِينَا', ['تَرْوِي لَنَا الْقِصَّةَ وَالْحِكَايَةْ', 'وَلَوْ عَبَدْنَا غَيْرَهُ شَقِينَا', 'لَيْسَتْ عَلَى رُهْبَانِهِمْ خَفِيَّةً', 'مُعَظَّماً في العِلْمِ وَالأَمانَة'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَإِنْ أَرَادُوا فِتْنَةً أَبَيْنَا', ['مِنْ بَعْدِهِ نَسَبُهُ امْتَدَّ إِلَى', 'خَدِيجَةُ النُّورِ الَّتِي مِنْهَا أَتَى', 'إِنَّ الأُلَى قَدْ رَعَبُوا عَلَيْنَا', 'وَدَعَاهُ لِلْإِسْلَامِ ثُمَّ خَيَّرَه'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'شَدِيدَةٌ ........ عَنْهَا المِعْوَلْ', ['يَمْلَأْ', 'يَحْدو', 'يُصْحِبُنِي', 'يَعْجِزُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ اسْتِجَابَةُ الدُّعَاءْ', ['وَبَكَوْا', 'وَقَّاصٍ', 'وَاعَجَبًا', 'وَكَانَتِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُسَاعِدًا أَصْحَابَهُ الكِرَامْ', ['وَقَدْ رَأَى مَيْسَرَةُ الْعَجَائِبَا', 'أَيْضًا فَأَشْرِكْنَا تَكُنْ لِكُلِّنَا', 'مِنْ الْعَبِيدِ مُعْتِقًا وَمُوقِنَا', 'مُسْتَشْهِدًا بِأَطْيَبِ الكَلَامْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَدِيثُهُمْ لَا عَيْشَ إِلَّا الآخِرَةْ\nفَأَكْرِمِ الأَنْصَارَ وَالمُهَاجِرَةْ', ['تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'يَدْعُو بِهَا النَّبِيُّ لِلصَّحَابَةْ', 'خَرَجَ مِنْهَا ذَلِكَ النُّورُ الْمُبِين', 'وَيَرْفَعُ الصَّوْتَ كَمَا رُوِينَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَحْكِي لَنَا عَنْ غَزْوَةِ الأَحْزَابْ', ['وَكَانَ حَقًّا مَشْهَدًا عَجِيبَا', 'وَحَمْلِ خَيْرِ الخَلْقِ لِلتُّرَابْ', 'لِذِي أَمْرٍ فَنَزَلَتِ الْأَمْطَارُ', 'وَصَلَاةَ خَوْفٍ عِنْدَ وَقْتِ الْعَصْرِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأُعْطِيَ المَفَاتِحَ الثَّمِينَةْ', ['فَقَالَ النَّاسُ خَلَأَتِ الْقَصْوَاء', 'لَوْ أَنَّهُمْ تَقَاتَلُوا أَصَابُوا', 'بِأَنَّ رَبَّ العَرْشِ قَدْ أَوْحى إِلى', 'مَا بَيْنَ لَابَتَيِ المَدِينَةْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُسَاعِدًا أَصْحَابَهُ الكِرَامْ\nمُسْتَشْهِدًا بِأَطْيَبِ الكَلَامْ', ['وَآلِهِ جَمِيعِهِمْ وَصَحْبِهِ', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي', 'وَاللهِ لَوْ لَا أَنْتَ مَا اهْتَدَيْنَا', 'لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ رَمْلًا يَسِيلُ عَجَبَا', ['فَأَصْبَحَتْ', 'فَاقْرَأْ', 'فَرَجَعَتْ', 'فَعُولَ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'اِكْشِفْ لِهَمِّي رَبَّنَا وَكَرْبِي\nأَنْتَ تَرَى مَا حَلَّ بِي وَبِصَحْبِي', ['وَقِيلَ بَلْ لِسَعْدِ بْنِ عُبَادَةْ', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'وَبَشَّرَ النَّبِيَّ أَنَّ هَذَا مَا', 'وَكَانَتِ اسْتِجَابَةُ الدُّعَاءْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَكَانَ يَزْدَادُ إِلَى أَنْ شَبِعُوا', ['فَجَاءَ سَعْدُ بْنُ الرَّبِيعِ مُخْبِرًا', 'اِكْشِفْ لِهَمِّي رَبَّنَا وَكَرْبِي', 'فَاجْتَمَعُوا عَلَيْهِ ثُمَّ أَكَلُوا', 'فَجَاءَهُمْ طَيْرٌ أَبَابِيلُ وَمَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِلَهِي يَا صَرِيخَ ........', ['الأَمَانَاتِ', 'المَكْرُوبِينَا', 'الْعَجَائِبَا', 'الْإِكْرَامَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَنْ ........ عَنْ ذَاكَ يَحْكِي ظَهَرَتْ', ['جَمْعَ', 'جَابِرٍ', 'جَمَالَ', 'جِبْريلَ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'خَيْرِ الأَنَامِ الهَاشِمِيِّ الطَّيِّبِ', ['مِنْ أَيْنَ هَذَا اللَّبَنُ الَّذِي أَرَى', 'وَحَاطِبٌ وَطَلْحَةٌ وَغَيْرُهُمْ', 'فَعُرِفَ السُّرُورُ فِي وَجْهِ النَّبِي', 'وَمَاتَ عَبْدُاللَّهِ قَبْلَ أَنْ يَرَى'], 2),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسَارَ خَيْرُ الْخَلْقِ بِالْكِرَامِ', ['لِمَا أَمَرَكَ اللهُ يَا حَبِيبَنَا', 'فَجَهَّزَ الرَّحْلَ بِقَصْدِ الهِجْرَةِ', 'أَصْحَابِهِ نَحْوَ الْبَيْتِ الْحَرَامِ', 'مِنَ الرِّجَالِ ثُمَّ اثْنَانِ بَعْدَهُمْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَقَدْ رَأَى ذَلِكَ فِي الْمَنَامِ\nفَانْطَلَقُوا لِلْبَيْتِ فِي سَلَامِ', ['وَحَاصَرُوهُمْ حِينَهَا فِي الشِّعْبِ', 'يَا أَيُّهَا النَّبِيُّ قَدْ قَالَ لَهُ', 'بَشَّرَهُمْ خَيْرُ الوَرَى مَا وَعَدَهْ', 'فِي يَوْمِ الِاثْنَيْنِ لِشَهْرِ الْقَعْدَةِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي عَامِ سِتٍّ بَعْدَ عَامِ الْهِجْرَةِ', ['فِي يَوْمِ الِاثْنَيْنِ لِشَهْرِ الْقَعْدَةِ', 'أَرْوَاحُهُمْ فِي جَوْفِ طَيْرٍ خُضْرِ', 'وَحَاطِبٌ وَطَلْحَةٌ وَغَيْرُهُمْ', 'وَحَامِلُ اللِّوَاءِ إِذْ ذَاكَ عَلِي'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَاقَ مَعْهُ الْهَدْيَ حَتَّى ........', ['يَحْفِرَ', 'يُدْرِكُوا', 'يَعْلَمَا', 'يُجِلُّ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَاصِدًا بِذَلِكَ الزِّيَارَة', ['وَقَدْ كَفَاكُمْ رَبُّنَا النِّيرَانَا', 'مِنْ قَتْلِ أَهْلِهِنَّ أَوْ مِنْ أَسْرِ', 'مَا قَصْدُهُ حَرْبٌ وَلَا إِغَارَة', 'وَقَالَ أَرْجُو أَنْ يَكُونَ خَيْرًا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَتَّى إِذَا أَتَى إِلَى غَدِيرْ\nأَشْطَاطَ جَاءَ عِنْدَهُ النَّذِيرْ', ['مُصَدِّقًا بِدِينِهِ وَمُسْلِمَا', 'وَمِنْهُمْ عَامِرُ بْنُ فُهَيْرَةَ', 'وَاللهِ لَوْ لَا أَنْتَ مَا اهْتَدَيْنَا', 'بِأَنَّ أَهْلَ مَكَّةَ قَدْ جَمَعُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'جُمُوعَهُمْ لِصَدِّكُمْ وَلِيَمْنَعُوا', ['بِأَنَّ أَهْلَ مَكَّةَ قَدْ جَمَعُوا', 'فَفَرِحُوا وَسَارَعُوا بِالْجِدِّ', 'قَضَى بِهَا عُمْرَةَ عَامٍ قَدْ مَضَى', 'إِنَّ الأُلَى قَدْ رَعَبُوا عَلَيْنَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِلْبَلَدِ الْحَرَامِ', ['دُخُولَكُمْ', 'دَعَاهُمُ', 'دَعُوهُ', 'دَعْوَتُهُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَشَاوَرَ الْحَبِيبُ طَهَ مَنْ مَعَهْ', ['فِي حَرْبِ مَنْ قَدْ جَاءَ حَتَّى يَمْنَعَهْ', 'أَسْبابَ تَنْزيلٍ وَكُلَّ مَكانِ', 'تُدْلَى لِي عَلَى رَأْسِي أُبْصِرُهَا', 'كُلَّ الفَخارِ بِالنَّبِيِّ ما أَشْرَكا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ أَبُو بَكْرٍ قَصَدْتُ الْبَيْتَ\nلِعُمْرَةٍ وَزِيَارَةٍ أَتَيْتَ', ['لَوْ أَنَّ رَبَّ الْعَرْشِ عَشَرًا وَهَبَه', 'وَأَرْسَلَتْ قُرَيْشٌ لِلْبَشِيرِ', 'بِقَصْدِ هَذَا لَمْ نُرِدْ سِوَاهُ', 'وَقَاصِدًا بِذَلِكَ الزِّيَارَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِصَحْبِهِ امْضُوا عَلَى إِسْمِ اللهِ', ['بِالْقُرْبِ مِنْ مَكَّةَ بِالْغَمِيمِ', 'هُوَ ضَمْضَمُ بْنُ عَمْرٍو الغِفَارِي', 'فَلَيْسَ فِيهَا مِنْ شَرَابٍ يُطْلَبُ', 'فَقَالَ عِنْدَ ذَا حَبِيبُ اللهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِلصَّحَابَةِ الْكِرَامِ', ['وَشَاوَرَ', 'وَإِنْ', 'وَظَنَّ', 'وَقَالَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِأَنَّ جَيْشَ خَالِدٍ وَعِكْرِمَة', ['وَكامِلاً في العَقْلِ وَالبَيانِ', 'طَلِيعَةٌ مِنْهُ عَلَى الْمُقَدِّمَة', 'وَالْحَاشِرُ الْمَاحِي فَجَلَّ الْوَاهِبُ', 'فَاقْرَأْ بِوَعْيٍ صِيغَةَ الْخِطَابِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِالْقُرْبِ مِنْ مَكَّةَ بِالْغَمِيمِ\nفِي مِائَتَيْ فَارِسٍ لِلْهُجُومِ', ['وَلَيْسَ هَذَا مِنْ كَلَامِ الْبَشَر', 'أَمَرَ اللهُ أرْمِياءَ كانا', 'كُنَّ جَمِيعًا رَاغِبَاتٍ فِيهِ', 'فَانْطَلَقُوا وَخُذُوا ذَاتَ الْيَمِينِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُعْجِزَةٌ لِلصَّادِقِ الْأَمِينِ', ['فَانْطَلَقُوا وَخُذُوا ذَاتَ الْيَمِينِ', 'وَكَانَ ذَاكَ الأَمرُ حِينَ ذَهَبَا', 'بِنَفْسِهِ الصِّدِّيقُ قَد فَدَاهُ', 'فَأَيْقَنُوا بِالْمَوْتِ لَكِنْ نَبَعَتْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ يُنْذِرُ لِلْكُفَّارِ', ['بِنُورِهِ', 'بِبَيْتِ', 'بِجَيْشِهِ', 'بَغَى'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ثُمَّ أَتَى يَنْظُرُ جَيْشَ الْمُصْطَفَى', ['بِقَارِئٍ لَكِنَّ اللَّهُ أَذِنَا', 'إِلَيْكُمُ يَنْهَاكُمُ عَنْ شِرْكِكُمْ', 'بِصَلَاتِهِمْ بِجَيْشِهِ مُتَوَقِّفًا', 'مَا الرُّوحُ ثُمَّ أَجَابَهُمْ فَتَعَالَوْا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'صَلَّى النَّبِيُّ بِهِمْ صَلَاةَ الظُّهْرِ\nوَصَلَاةَ خَوْفٍ عِنْدَ وَقْتِ الْعَصْرِ', ['آيَتُهَا مِنْ رَبِّهِ قَدْ نَزَلَتْ', 'قَالَتْ لَهَا آمِنَةُ الْمَرْضِيَّة', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'كُبَرَاءُ هَذَا الحَيِّ سَارُوا كُلُّهُمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي ذَلِكَ الْيَوْمِ لَنَا قَدْ شُرِعَتْ', ['آيَتُهَا مِنْ رَبِّهِ قَدْ نَزَلَتْ', 'عَادَ بَنُو زُهْرَةَ لَمْ يُقَاتِلُوا', 'وَأَذِنَ الرَّحْمَنُ بِالقِتَالِ', 'فَحَبَّذَا رَبًّا وَحُبَّ دِينَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَرَكَتْ بِهَا ........ مُتَأَبِّيَة', ['نَحْنُ', 'نَاقَتُهُ', 'نَقَلوا', 'نَمْضِي'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ النَّبِيُّ الْمُصْطَفَى الْجَلِيلُ', ['بِالعَفْوِ وَالغُفْرَانِ مَهْمَا يَفْعَلُوا', 'لِكَي يَكُونَ مَعَهُ رَفِيقَا', 'قالَ لَهُمْ وُلِدْتُ مِنْ نِكاحِ', 'مَا خَلَأَتْ بَلْ حَبَسَهَا كَالْفِيلِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَبَسَهَا هُنَا حَابِسُ الْفِيلِ\nعَنْ مَكَّةَ مُنِعَتْ مِنَ الدُّخُولِ', ['أَتَى مِنَ اللهِ القَدِيرِ نَاصِرا', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي', 'كَفَاهُ شَرَّ مَن بَغَى وَكَادَا', 'لِأَنَّهُمْ لَوْ دَخَلُوا تَقَاتَلُوا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَإِنَّهُمْ لِعُمْرَةٍ قَدْ أَقْبَلُوا', ['حَتَّى آتَاهُ اللَّهُ بَعْدَ عَشَرَةْ', 'لِأَنَّهُمْ لَوْ دَخَلُوا تَقَاتَلُوا', 'فَكَانَ عَامُ الْحُزْنِ وَالْبُكَاءِ', 'وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فِي مَكَّةَ قَوْمٌ مُؤْمِنُون', ['وَكَثْرَةُ', 'وَالبَرِّ', 'وَكَانَ', 'وَهُمُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', '(وَلَوْلَا رِجَالٌ مُؤْمِنُونَ وَنِسَاءُ)', ['فَرَحًا بِهَا وَاسْتَبْشَرُوا وَاعْتَبَرُوا', 'فِي سُورَةِ الْفَتْحِ بِهَا الْأَنْبَاءُ', 'أَنْ يَحْفِرَ الخَنْدَقَ فِي حُدُودِهَا', 'يُقَاتِلُونَ أَصْحَابَ الرَّسُولِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَوْ أَنَّهُمْ تَقَاتَلُوا أَصَابُوا\nبِغَيْرِ عِلْمٍ مَا بِهِ يُعَابُوا', ['في شَأْنِ آباءِ النَّبِيِّ نَقَلوا', 'بِالأَخْشَبَيْنِ أَهْلَهَا جَمِيعَا', 'وَمَا حَضَرَ فِيهَا خَيْرُ الخَلْقِ', 'مِنْ أَجْلِ ذَاكَ جَنَحُوا لِلسَّلْمِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالصُّلْحِ فِي مَا بَيْنَهُمْ وَالْحِلْمِ', ['إِنَّ اللهَ اشْتَرَى كَمَا فِي التَّوْبَةِ', 'مِنْ أَجْلِ ذَاكَ جَنَحُوا لِلسَّلْمِ', 'دُخُولَكُمْ لِلْبَلَدِ الْحَرَامِ', 'صَارَعَهُ الْمُخْتَارُ ثُمَّ صَرَعَه'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكَانَ فِيهَا ........ الرِّضْوَانِ', ['بِلَالَا', 'بَيْعَةُ', 'بِحُرْمَةِ', 'بِالنَّبِيِّ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حِينَ أَشَاعُوا أَنَّهُ قَدْ قُتِلَا', ['فِي الطَّابِقِ الأَعْلَى بِلَا نَدَامَةِ', 'لِلْمُصْطَفَى بِصِدْقِ الِاسْتِجَابَةِ', 'بِمَكَّةَ لَكِنَّ ذَا مَا حَصَلَا', 'وَجَدِّهِ الْكَرِيمِ ذِي الْمَفَاخِرِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَرْسَلَتْ قُرَيْشٌ لِلْبَشِيرِ\nسُهَيْلًا بْنَ عَمْرٍو الْعَامِرِي', ['لِلصُّلْحِ فِي مَا بَيْنَهُمْ فَتَمَّ', 'وَأَرَاهُمُ مَصَارِعَ الأَقْوَامِ', 'فَوَافَقُوا قَالُوا بِهِ رَضِينَا', 'مَا هَمَّهُمْ أَمْرُ النَّبِيِّ الْهَادِي'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَدْ دَافَعُوا عَنْ ........ الْأَمَانَةْ', ['صَلّى', 'صَاحِبِ', 'صَفَّينِ', 'صَالَحَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَكُسِرَتْ أَسْنَانُهُ ........', ['الْكِبْرُ', 'السُّفْلِيَّةْ', 'الْحَبِيبُ', 'الْأَطْهَارِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'اجْتَمَعُوا مِنْ حَوْلِهِ يَفْدُونَهُ\nوَالْمُعْتَدِي بِنِبَالِهِمْ يَرْمُونَهُ', ['وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا', 'مِنْهُمْ أَبُو طَلْحَةَ كَانَ رَامِيًا', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك', 'أَنْ يَأْخُذَ مَعَدَّ بْنَ عَدْنانِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَثَبَتَ الْكَرَّارُ وَالصِّدِّيقُ', ['لَم يَخْشَ مِن قَتْلٍ وَلَا إِبْعَادِ', 'مِنْ عَمِّهِ لِيَقْتُلُوهُ فِي جَفَا', 'يَا سَعْدَنَا بِمَوْلِدِ الْمُخْتَارِ', 'مَعَ النَّبِيْ وَثَبَتَ الْفَارُوقُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَدَعَا لَهُ اللَّهُمَّ أَجِبْ دَعْوَتَهْ', ['لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'فَدَعَا لَهُ اللَّهُمَّ سَدِّدْ رَمْيَتَهْ', 'سِلْسِلَةٌ ذَهَبِيَّةٌ أَنْوَارُهَا', 'بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَوَجْهِي عَنْ وَجْهِكَ يَا نَبِيْ وِقَاءُ', ['قَالَ لَهُ نَفْسِي لِنَفْسِكَ الْفِدَاءُ', 'لَكِنَّهُمْ قَامُوا لَهُ وَقَالُوا', 'وَانْفَجَرَ الْجُرْحُ وَسَالَ دَمُهُ', 'وَفي الشِّفاءِ لِلْقاضي عِياضْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِمَّنْ فَدَى بِنَفْسِهِ الْعَدْنَانَا', ['فَدَعَا لَهُ اللَّهُمَّ سَدِّدْ رَمْيَتَهْ', 'وَهَكَذَا فَعَلُوا إِلَى أَنْ بَلَغَتْ', 'وَابْنُ أَبِي وَقَّاصٍ سَعْدٌ كَانَا', 'بِالْوَحْيِ مِنْ رَبِّ الْوَرَى أَنْ يُسْرِعَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَالَ لَهُ ........ أُمِّي وَأَبِي', ['فَكَذَّبُوا', 'فِدَاكَ', 'فَرْضِهَا', 'فِيهِمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْهُمْ أَبُو طَلْحَةَ كَانَ رَامِيًا', ['تَأْكُلُ فِي الجَنَّةِ خَيْرَ الثَّمَرِ', 'فَأَتَاهُ نَصْرُ الوَاحِدِ الوَهَّابِ', 'وَأَنْجَبَتْ لِسَيِّدِ الْأَنَامِ', 'وَمُخْلِصًا لِلْمُصْطَفَى مُوَالِيًا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَاطِبٌ وَطَلْحَةٌ وَغَيْرُهُمْ\nقَدْ أَخْلَصُوا مَعَ النَّبِيْ جَمِيعُهُمْ', ['فِي السَّنَةِ الثَّانِيَةِ لِلْهِجْرَةِ', 'مُحَمَّدٌ الهَادي رَسولُ اللهِ', 'وَسَالَتِ الدِّمَا مِنَ الْوَجْهِ الشَّرِيفْ', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَظَهَرَتْ مَحَبَّةُ الصَّحَابَةِ', ['لِلْمُصْطَفَى بِصِدْقِ الِاسْتِجَابَةِ', 'قَتَلُوهُ فِي بُعْدِ الْأَنْظَارِ', 'يَتَعَرَّضُونَ العِيرَ عِنْدَ طَرِيقِهِمْ', 'فَأَرَادَ مِنْ أَحْمَدَ أَنْ يُصَارِعَهْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَدْ نَثَرَ الْهَادِي لَهُ كِنَانَتَهْ\nبَيْنَ يَدَيْهِ مُعْلِنًا مَحَبَّتَهْ', ['فِي أَرْضِ الْأَبْوَاءِ الَّتِي تَشَرَّفَتْ', 'فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', 'قَالَ لَهُ نَفْسِي لِنَفْسِكَ الْفِدَاءُ', 'ذَاتُ النِّطَاقَيْنِ الَّتِي قَد قَطَعَتْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَلَمْ يَزَلْ يَرْمِي بِهَا مُدَافِعًا\nعَنِ الْحَبِيبِ مَنْ أَتَانَا شَافِعًا', ['وَاجْتَمَعَ قَوْمٌ مِنَ الْأَجَانِبِ', 'وَابْنُ أَبِي وَقَّاصٍ سَعْدٌ كَانَا', 'لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَالَتِ الدِّمَا مِنَ الْوَجْهِ الشَّرِيفْ\nلَمَّا أُصِيبَ وَجْهُهُ الْحُرُّ الْعَفِيفْ', ['فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ', 'لِأَنَّهُمْ قَدْ جَمَعُوا الجُمُوعَا', 'وَرَفَضَ الْخُرُوجَ ثُمَّ اعْتَذَرَا', 'وَكُسِرَتْ أَسْنَانُهُ السُّفْلِيَّةْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَيْنَ يَدَيْهِ مُعْلِنًا مَحَبَّتَهْ', ['قَدْ نَثَرَ الْهَادِي لَهُ كِنَانَتَهْ', 'كَانَ اليَهُودُ يَسْأَلُونَ الهَادِي', 'فَتَجَهَّزَ الأَقْوَامُ لَمَّا سَمِعُوا', 'قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكُسِرَتْ أَسْنَانُهُ السُّفْلِيَّةْ', ['بَرُدَ الْأَمْرُ صَلُحَ بِلَا مِرَا', 'عَلَى كُلِّ غَيْرِ مُؤْمِنٍ بِرَبِّهَا', 'أَرْبَعَةٌ كَالدُّرِّ لُؤْلُؤِيَّةْ', 'ما قالَهُ جِبْريلُ مِنْ شَمائِلِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالْمُعْتَدِي بِنِبَالِهِمْ يَرْمُونَهُ', ['فيها المَغازي وَكَذا أَيّامُهُ', 'اجْتَمَعُوا مِنْ حَوْلِهِ يَفْدُونَهُ', 'ومؤتة في ثَامن الأعوامِ', 'إِذَا دَعَا الْكُفَّارَ لِلْإِيمَانِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَوَجْهِي عَنْ ........ يَا نَبِيْ وِقَاءُ', ['وَفِي', 'وَكَذا', 'وَجْهِكَ', 'وَيَصِفُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَظَهَرَتْ مَحَبَّةُ الصَّحَابَةِ\nلِلْمُصْطَفَى بِصِدْقِ الِاسْتِجَابَةِ', ['سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'وَكَذَّبَ الْكُفَّارُ بِالْإِسْرَاءِ', 'اجْتَمَعُوا مِنْ حَوْلِهِ يَفْدُونَهُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُ فِدَاكَ أُمِّي وَأَبِي', ['بَشَّرَهُمْ بِالفَتْحِ خَيْرُ مُؤْتَمَنْ', 'لَمَّا رَأَى مِنْ صِدْقِهِ الْمُحَبَّبِ', 'مُحَالِفًا لِعُصْبَةِ الْكُفَّارِ', 'لِيَنْتَهِيَ عَنْ دِينِهِ وَأَمْرِهِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَكَذَا الزُّبَيْرُ وَأَبُو دُجَانَةْ', ['مِنَ الرِّجَالِ وَالنِّسَا مُسْتَضْعَفُون', 'يَكْفِي بِأَنَّهُ كَشْفًا رَآهُ', 'قَدْ دَافَعُوا عَنْ صَاحِبِ الْأَمَانَةْ', 'بِأَمْرِهِ لِمَا عَلَيْهِ كَانَتْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَثَبَتَ الْكَرَّارُ وَالصِّدِّيقُ\nمَعَ النَّبِيْ وَثَبَتَ الْفَارُوقُ', ['وَحَاطِبٌ وَطَلْحَةٌ وَغَيْرُهُمْ', 'وَلَقَدْ عَفَا عَنْكُمْ أَتَتْنَا آيَةْ', 'مِنْ بَعْدِ مَا ظُلِمُوا مِنَ الكُفَّارِ', 'بِنَفْسِهِ الصِّدِّيقُ قَد فَدَاهُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِمَّنْ فَدَى ........ الْعَدْنَانَا', ['بَيْتِ', 'بَعْدَهُمْ', 'بِإسْمِ', 'بِنَفْسِهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَنِ الْحَبِيبِ مَنْ أَتَانَا شَافِعًا', ['لِيُلْبِسُوا البَاطِلَ ثَوْبَ الحَقِّ', 'وَبَعْدَ ذَاكَ غَزْوَةُ الأَحْزَابِ', 'فَلَمْ يَزَلْ يَرْمِي بِهَا مُدَافِعًا', 'حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْهُمْ أَبُو طَلْحَةَ كَانَ رَامِيًا\nوَمُخْلِصًا لِلْمُصْطَفَى مُوَالِيًا', ['قَدْ نَثَرَ الْهَادِي لَهُ كِنَانَتَهْ', 'مَا مِنْ نَبِيٍّ إِلَّا قَدْ رَعَى الْغَنَمْ', 'أَصْبَحْتُمُ بِفَضْلِهِ إِخْوَانَا', 'أَمَرَهُم خَيرُ الوَرَى أَن يَفتَحُوا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَمَّا أُصِيبَ وَجْهُهُ الْحُرُّ الْعَفِيفْ', ['مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'وَسَالَتِ الدِّمَا مِنَ الْوَجْهِ الشَّرِيفْ', 'وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'وَقَاصِدًا بِذَلِكَ الزِّيَارَة'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَدْ أَخْلَصُوا مَعَ النَّبِيْ جَمِيعُهُمْ', ['فَصَدَّقَاهُ وَقَبَّلَا رِجْلَيْهِ', 'وَحَاطِبٌ وَطَلْحَةٌ وَغَيْرُهُمْ', 'خَافَ بَحِيرَا أَنْ يَرَى الْيَهُودُ', 'وَنَزَلَتْ قُرَيْشٌ بَطْنَ الْوَادِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لَهُ اللَّهُمَّ أَجِبْ دَعْوَتَهْ', ['وَدَعَا', 'وَمَعَهُنَّ', 'وَخَرَجَ', 'وَالعَرَبْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَابْنُ أَبِي وَقَّاصٍ سَعْدٌ كَانَا', ['فَاحْفَظْ لِنَصٍّ وَاضِحِ الْمَسَالِكِ', 'قالَ لَهُمْ وُلِدْتُ مِنْ نِكاحِ', 'وَبِسَيْفِهِ العَضْبِ تَقَلَّدَهُ الرَّسُول', 'مِمَّنْ فَدَى بِنَفْسِهِ الْعَدْنَانَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مِنْ حَوْلِهِ يَفْدُونَهُ', ['الْقُصُورَا', 'إِجْلَائِهِمْ', 'العَرُوبَةِ', 'اجْتَمَعُوا'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَأْمُرُهُ اللهُ بِهَا بِالفَضْلِ', ['وَالْبَيْهَقِيُّ قَدْ رَوى وَأَثْبَتا', 'فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', 'عَلَيْهِ آيَاتٌ بِخَتْمِ النَّحْلِ', 'بَشَّرَهُ النَّبِيُّ أَن يَنَالَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُصَدِّقًا بِالحَقِّ وَالآيَاتِ', ['وَكُسِرَتْ أَسْنَانُهُ السُّفْلِيَّةْ', 'كَانَ فَعُولَ البِرِّ وَالخَيْرَاتِ', 'مُقَدَّمًا فِي قَوْمِهِ بِمَالِهِ', 'قَدِ اصْطَفَاهَا اللَّهُ مِنْ بَيْنِ الْبَشَر'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَهَذِهِ عَنْ أُحُدٍ أَبْيَاتُ', ['وَفِي الْجَحِيمِ يَلْقَ مَا أَتَاهُ', 'بِجَيْشِهِ يُنْذِرُ لِلْكُفَّارِ', 'فَذِكْرُهُمْ تَصْفُو بِهِ الأَوْقَاتُ', 'إِنّي اتَّخَذْتُ إِبْراهيمَ قَبْلَكَ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَقْسَمَ النَّبِيُّ أَنْ يُمَثِّلَا', ['فَأَنْزَلَتْ حَلِيبَهَا فِي حِينِهَا', 'مِنْهُمْ بِسَبْعِينَ إِلَى أَنْ أُنْزِلَا', 'وَالنَّصْرُ فِيهَا لِلْقُلُوبِ الخَاشِيَة', 'صَارَ مُحِبًّا لِلنَّبِيِّ خَادِمَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عِنْدَ الَّذِي خَلَقَهُمْ سُعَدَاءُ', ['لَمَّا الرُّمَاةُ خَالَفُوا الْأَوَامِرَا', 'الشَّامَ وَالفُرْسَ كَذَا أَرْضَ اليَمَنْ', 'لَيْسُوا بِأَمْوَاتٍ فَهُمْ أَحْيَاءُ', 'أَخَذَهُ مِنْهُ أَبُو دُجَانَةْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَانَ حَبِيبًا عِنْدَهُ كَبِيرَا', ['حَكَمْتَ فِيهِمُ بِحُكْمِ اللهْ', 'لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'بَكَى عَلَيْهِ المُصْطَفَى كَثِيرَا', 'وَكَثْرَةُ الطَّعَامِ عِنْدَ قِلَّتِهِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَإِنَّهُمْ لِرَبِّنَا اسْتَجَابُوا', ['أَنَا جَارُكُمْ زَيَّنْ لَهُمْ أَعْمَالَهُمْ', 'وَلِأَجْلِ هَذا الدّينِ ماذا عَمِلوا', 'وَأَخْلَصُوا لِقُرْبِهِ أَنَابُوا', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ حَذَّرُوهُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَوَاصِلًا لِلضَّيْفِ ........', ['وَحَاوَلَتْ', 'وَيَشْرَعَا', 'وَأَذْعَنُوا', 'وَالأَرْحَامِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَرْوَاحُهُمْ فِي جَوْفِ طَيْرٍ خُضْرِ\nتَأْكُلُ فِي الجَنَّةِ خَيْرَ الثَّمَرِ', ['لَيْسُوا بِأَمْوَاتٍ فَهُمْ أَحْيَاءُ', 'حَذَّرَهُمْ مِنْ دَعْوَى الجَاهِلِيَّةْ', 'نَبِيُّنَا الْمُخْتَارُ مِنْ بَيْنِ الْأُمَمْ', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يَسْتَبْشِرُونَ بِالَّذِينَ بَعْدَهُمْ\nلَا خَوْفَ بَلْ لَا حُزْنَ قَدْ يُصِيبُهُمْ', ['أَقَامَ فِي دِيَارِهِمْ أَعْوَاما', 'فَرَجَعُوا بِخَيْبَةِ الآمَالِ', 'فَإِنَّهُمْ لِرَبِّنَا اسْتَجَابُوا', 'لِغَالِبِ بْنِ فِهْرٍ بْنِ مَالِكِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَاسْتُشْهِدَ الحَمْزَةُ ثُمَّ مَثَّلُوا', ['جِهَادُهُمْ فِي نَصْرِ هَذَا الدِّينْ', 'لِكَيْ تَكُونَ بِهِمُ فِي مَنعَةِ', 'بِجِسْمِهِ وَكَبِدَهُ قَدْ أَخْرَجُوا', 'كَمَا رَأَتْ بِالحَادِثِ الخَطِير'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', '﴿وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا﴾ بِي أَنَا', ['وَكَانَ فِيهَا الْمُصْطَفَى غُلَامَا', 'المُصْطَفَى العَالِي المُعَظَّمُ فَضْلُهُ', 'لَا تَحْزَنَنْ وَلَا تَضِقْ كُنْ مُحْسِنَا', 'مُعْجِزَةٌ لِلصَّادِقِ الْأَمِينِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَسَدُ اللهِ كَذَا رَسُولِهِ', ['وَعاشَ في دِيارِهِ وَثَبَتا', 'وَبِأَمْرِهِ مِنْ بَعْدِ ذَاكَ رَجَعَتْ', 'وَمَا بَكَى سِوَاهُ كَمَثِيلِهِ', 'وَفَازَ خَيْرُ خَلْقِهِ بِالنَّصْرِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِمَنْ نَالُوا بِهَا الشَّهَادَةْ', ['طُوبَى', 'طَاهِرٌ', 'طَلْحَةَ', 'طَيِّبا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاسْتُشْهِدَ الحَمْزَةُ ثُمَّ مَثَّلُوا\nبِجِسْمِهِ وَكَبِدَهُ قَدْ أَخْرَجُوا', ['وَكَذَّبَ الْكُفَّارُ بِالْإِسْرَاءِ', 'لَكِنَّهُمْ عَادُوا بِلَا قِتَالِ', 'أَمَامَهُ إِحْدَاهُمَا كَانَتْ مَعَا', 'بَكَى عَلَيْهِ المُصْطَفَى كَثِيرَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَأْكُلُ فِي الجَنَّةِ خَيْرَ الثَّمَرِ', ['أَرْوَاحُهُمْ فِي جَوْفِ طَيْرٍ خُضْرِ', 'وَأَنْتَ عَبْدُاللَّهِ مُصْطَفَاهُ', 'اجْتَمَعَ النَّاسُ بِدَارِ النَّدْوَةِ', 'وَاسْتَوْدَعَ المُخْتَارُ زَوْجَ بِنْتِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَانَ حَبِيبًا ........ كَبِيرَا', ['عَيْشِ', 'عَبْدُ', 'عَلِيَّة', 'عِنْدَهُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'طُوبَى لِمَنْ نَالُوا بِهَا الشَّهَادَةْ', ['أَرْبَعَةٌ كَالدُّرِّ لُؤْلُؤِيَّةْ', 'أَنْ يَقْتُلُوا النَّبِيَّ ذَا الأَمَانَةْ', 'قَدْ أَدْرَكُوا وَرَبُّنَا السَّعَادَةْ', 'حَتَّى أَتَى الْمُخْتَارَ لِلْأَحْفَادِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَقْسَمَ النَّبِيُّ أَنْ يُمَثِّلَا\nمِنْهُمْ بِسَبْعِينَ إِلَى أَنْ أُنْزِلَا', ['عَلَيْهِ آيَاتٌ بِخَتْمِ النَّحْلِ', 'قَصَّتْ عَلَى العَبَّاسِ مَا رَأَتْهُ', 'قالَ يا رَبَّنا بِحَقِّ أَحْمَدا', 'بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَيْسُوا بِأَمْوَاتٍ فَهُمْ ........', ['الصّادِقِ', 'اللَّطْفِ', 'أَحْيَاءُ', 'أَهَانَهُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَاصِلًا لِلضَّيْفِ وَالأَرْحَامِ', ['بَلْ مِنْ كَلَامِ الصَّحْبِ فِي أَيَّامِهِ', 'بِجِسْمِهِ وَكَبِدَهُ قَدْ أَخْرَجُوا', 'مُقَرَّبًا مِنْ سَيِّدِ الأَنَامِ', 'وَرَبُّهُ قَد زَادَهُ تَمْكِينَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَا خَوْفَ بَلْ لَا حُزْنَ قَدْ يُصِيبُهُمْ', ['وَسَارَ خَيْرُ الْخَلْقِ بِالْكِرَامِ', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'يَسْتَبْشِرُونَ بِالَّذِينَ بَعْدَهُمْ', 'فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِالحَقِّ وَالآيَاتِ', ['مَرَّتْ', 'مَقَالِي', 'مَجِيدَة', 'مُصَدِّقًا'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', '﴿وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا﴾ بِي أَنَا\nلَا تَحْزَنَنْ وَلَا تَضِقْ كُنْ مُحْسِنَا', ['الطَّيْرُ وَالْوُحُوشُ وَالسِّبَاعْ', 'سَلَّمَهُ الْأَجْدَادُ لِلْأَوْلَادِ', 'فَهَذِهِ عَنْ أُحُدٍ أَبْيَاتُ', 'بِأَنَّهُ يَكونُ مِنْ أَبْنائِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِرَبِّنَا اسْتَجَابُوا', ['فَهَذِهِ', 'فَعَمَّتِ', 'فَإِنَّهُمْ', 'فَهَمَّ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ آيَاتٌ بِخَتْمِ النَّحْلِ', ['عَازِبِ', 'عَقَدَ', 'عِنْدَمَا', 'عَلَيْهِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَهَذِهِ عَنْ أُحُدٍ أَبْيَاتُ\nفَذِكْرُهُمْ تَصْفُو بِهِ الأَوْقَاتُ', ['وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ', 'كانَ جَميعاً حُنَفاءَ دينُهُمْ', 'طُوبَى لِمَنْ نَالُوا بِهَا الشَّهَادَةْ', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَسَدُ اللهِ كَذَا رَسُولِهِ\nوَمَا بَكَى سِوَاهُ كَمَثِيلِهِ', ['فَأَقْبَلَ الْحَبِيبُ بِالْأَنْوَارِ', 'فَهُوَ الَّذِي فِي السَّاجِدِينَ تَقَلَّبَا', 'وَأَقْسَمَ النَّبِيُّ أَنْ يُمَثِّلَا', 'مِنْها الَّذي رَواهُ لَمّا أَكَلا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِالَّذِينَ بَعْدَهُمْ', ['يَشَاءُوا', 'يَسْتَبْشِرُونَ', 'يَأْكُلُونْ', 'يَهُودِيًّا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَخْلَصُوا لِقُرْبِهِ أَنَابُوا', ['فَإِنَّهُمْ لِرَبِّنَا اسْتَجَابُوا', 'فَحَبَّذَا رَبًّا وَحُبَّ دِينَا', 'عَنِ النَّبِيِّ بَيْتَ ابِي أَيُّوبَا', 'فَلَمْ يَكُنْ هُنَاكَ مِنْ قِتَالِ'], 0),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الأَقْوَامُ لِلْعِيَالِ', ['وَصَلَهَا', 'وَمُخْلِصًا', 'وَثَبَتا', 'وَرَجَعَ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَسْكَرَ النَّبِيُّ مِنْ بَعْدِ أُحُدْ', ['فِي مَوْضِعٍ يُدْعَى بِحَمْرَاءِ الأَسَدْ', 'حِلْفِ الْفُضُولِ قَوْمُهُ وَأَقْبَلَا', 'يَحْكِي لَنَا مِمَّا أَتَى مِنْ خَبَرِ', 'حَتَّى يُلاَقُوا عِنْدَ بَدْرٍ حَتْفَهُمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَرَجَعَ الأَقْوَامُ لِلْعِيَالِ', ['يَقُولُ إِنَّ لِابْنِي هَذَا شَانَا', 'فَلَمْ يَكُنْ هُنَاكَ مِنْ قِتَالِ', 'أَبُو طَالِبٍ الْكَرِيمُ الطَّيِّبُ', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعَسْكَرَ النَّبِيُّ مِنْ بَعْدِ أُحُدْ\nفِي مَوْضِعٍ يُدْعَى بِحَمْرَاءِ الأَسَدْ', ['فَلَمْ يَكُنْ هُنَاكَ مِنْ قِتَالِ', 'وَقَدْ أَتَى إِلَى النَّبِيِّ قَبْلَهُ', 'بَاتَ عَلِيٌّ فِي فِرَاشِ الهَادِي', 'وَعَسْكَرَ النَّبِيُّ مِنْ بَعْدِ أُحُدْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَجَعَ الأَقْوَامُ ........', ['لِئَامُ', 'لِمَوْضِعِ', 'لِلْعِيَالِ', 'لَدَيْهِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي مَوْضِعٍ يُدْعَى بِحَمْرَاءِ الأَسَدْ', ['كَانَ يَهُودِيًّا وَرَاعٍ لِلْغَنَمْ', 'وَعَسْكَرَ النَّبِيُّ مِنْ بَعْدِ أُحُدْ', 'فَأَمَرَ النَّبِيُّ مَنْ يُنَادِي', 'لِأَنَّ طَهَ لَمْ يَكُنْ بِشَاعِرٍ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَلَمْ يَكُنْ هُنَاكَ مِنْ قِتَالِ', ['وَرَجَعَ الأَقْوَامُ لِلْعِيَالِ', 'عَلَى المَدِينَةِ وَمَضَى الصَّحَابَةْ', 'خَوْفًا وَمِنْ دِينِ النَّبِيِّ حَذَّرُوهُ', 'فَقَامَ مِنْ نَوْمِهِ وَأَتَاهَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي مَوْضِعٍ يُدْعَى ........ الأَسَدْ', ['بِرَبِّهَا', 'بِفَضْلِ', 'بِحَمْرَاءِ', 'بِنُورٍ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ ........ هُنَاكَ مِنْ قِتَالِ', ['يَكُنْ', 'يَدَيْهِ', 'يَقِلُّ', 'يَزِيدُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَسْكَرَ ........ مِنْ بَعْدِ أُحُدْ', ['الصّادِقِ', 'أَكْرَمَا', 'النَّبِيُّ', 'الْأَحَبْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ يَكُنْ هُنَاكَ مِنْ قِتَالِ', ['فَلَمْ', 'فَرْضًا', 'فُؤَادِ', 'فَرْثٍ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ النَّبِيُّ مِنْ بَعْدِ أُحُدْ', ['وَهَكَذَا', 'وَابْنُ', 'وَفَاطِمَة', 'وَعَسْكَرَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ يَكُنْ هُنَاكَ مِنْ ........', ['قِتَالِ', 'قُبَاءَ', 'قِلَّةِ', 'قَدَرُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي مَوْضِعٍ يُدْعَى بِحَمْرَاءِ ........', ['الصَّاحِبِ', 'التَّمَامِ', 'أَوَّلُهُمْ', 'الأَسَدْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَجَعَ ........ لِلْعِيَالِ', ['المُصْطَلِقْ', 'أَعلَنَا', 'الأُولَى', 'الأَقْوَامُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَسْكَرَ النَّبِيُّ مِنْ بَعْدِ ........', ['الظُّهْرِ', 'أُحُدْ', 'الحَرْبِ', 'آمِنْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَلَمْ يَكُنْ ........ مِنْ قِتَالِ', ['هَاجَرُوا', 'هُنَاكَ', 'هجرةِ', 'هَلُمَّ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي مَوْضِعٍ ........ بِحَمْرَاءِ الأَسَدْ', ['يُظْهِرُ', 'يُدْعَى', 'يَوْمٍ', 'يَسَّرَهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي ........ يُدْعَى بِحَمْرَاءِ الأَسَدْ', ['مَسَّهَا', 'مُصِيبَةُ', 'مَوْضِعٍ', 'مَعِينِهِ'], 2),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَخْبَرَهُ بِالخَبَرِ الجَلِيلُ', ['وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ', 'وَجَاءَ عَنْ أَبِي سَعِيدٍ الْخُدْرِيْ', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فِيكُمُ', 'بَنُو النَّضِيرِ فَأَتَى جِبْرِيلُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَإِنَّهُمْ قُلُوبُهُمْ سَقِيمَةْ', ['وَقَالَتِ الأَنْصَارُ فَلْتَمْضِي بِنَا', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا', 'نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'يُلْقُوا عَلَيْهِ صَخْرَةً عَظِيمَةْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَنْ يَقْتُلُوا النَّبِيَّ ذَا الأَمَانَةْ', ['لَمَّا أَتَوْا بِجَمْعِهِمْ بَحِيرَا', 'وَهَمَّتِ اليَهُودُ بِالخِيَانَةْ', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا', 'فَهَذِهِ عَنْ أُحُدٍ أَبْيَاتُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَعَادَ نَحْوَ بَيْتِهِ سَرِيعَا', ['مُسْتَنْفِرًا أَصْحَابَهُ جَمِيعَا', 'عَلَيَّ دَوْمًا نَاطِقًا يَتَكَلَّمُ', 'تَجِدُهَا وَسُمِّيَتْ بِزَمْزَمِ', 'أَنْ يُطْلِقُوا تَعْرِيفَهُمْ سَرِيَّةْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِأَمْرِهِ وَالمُسْلِمُونَ غَنِمُوا', ['حَاصَرَهُمْ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا', 'مِنْ بَعْدِ ذَا نَشْرَعُ فِي الْمَقْصُودِ', 'حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'هِيَ سُورَةُ الحَشْرِ بِهَا مُخْبَرَةٌ', ['وَأَذِنَ الرَّحْمَنُ بِالقِتَالِ', 'قَالَ لَهُ نَفْسِي لِنَفْسِكَ الْفِدَاءُ', 'وَأُنْزِلَتْ فِي حَقِّ هَذَا سُورَةٌ', 'قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَعْضُهُمْ لِخَيْبَرَ قَدْ يَجْرِي', ['وَأُخْرِجُوا لِلشَّامِ أَرْضِ الحَشْرِ', 'طُوبَى لِمَنْ نَالُوا بِهَا الشَّهَادَةْ', 'مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ', 'وَاللهِ لَوْ لَا أَنْتَ مَا اهْتَدَيْنَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأُنْزِلَتْ فِي حَقِّ هَذَا ........', ['سَمِعُوا', 'سُورَةٌ', 'سِوَارَ', 'سَلْمانَ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَعَادَ نَحْوَ بَيْتِهِ سَرِيعَا\nمُسْتَنْفِرًا أَصْحَابَهُ جَمِيعَا', ['وَصَدَّقَتْهُ آمَنَتْ بِدِينِهِ', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'حَاصَرَهُمْ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَنْ ........ النَّبِيَّ ذَا الأَمَانَةْ', ['يُقِيمَ', 'يَشَاءُوا', 'يَنْتَقِمْ', 'يَقْتُلُوا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَخْبَرَهُ ........ الجَلِيلُ', ['بِالَّذِينَ', 'بِالخَبَرِ', 'بِأَنَّهُمْ', 'بُشِّرُوا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا', ['حَاصَرَهُمْ', 'حَصَلَا', 'حَاكِمًا', 'حَاطِبٌ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأُخْرِجُوا لِلشَّامِ أَرْضِ ........', ['الحَشْرِ', 'الْعَدُوِّ', 'الْجَلِيلَا', 'الْإِقْدَامِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ قُلُوبُهُمْ سَقِيمَةْ', ['فَأَوْقَعُوا', 'فَعُرِفَ', 'فَتَعَالَوْا', 'فَإِنَّهُمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَاصَرَهُمْ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا', ['وَكَانَ ذَا مَالٍ وَذَا إِكْثَارِ', 'لَكِنَّهَا نَالَتْ بِهِ الْأَفْضَالَا', 'لِأَمْرِهِ وَالمُسْلِمُونَ غَنِمُوا', 'حَتَّى أَتَى الْمُخْتَارَ لِلْأَحْفَادِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَهَمَّتِ اليَهُودُ بِالخِيَانَةْ', ['فِي ذَلِكَ الْيَوْمِ لَنَا قَدْ شُرِعَتْ', 'سَطَعَتْ تَفُوقُ الشَّمْسَ عِنْدَ ظُهُورِهَا', 'أَنْ يَقْتُلُوا النَّبِيَّ ذَا الأَمَانَةْ', 'حَتَّى تُوُفِّيَتْ وَقَدْ بَكَاهَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بَنُو النَّضِيرِ فَأَتَى جِبْرِيلُ', ['مَعَ عَلِيٍّ أَبْيَضًا لِوَانَا', 'عَلَى حَبِيبِ رَبِّنَا مُحَمَّدِ', 'أَخْبَرَهُ بِالخَبَرِ الجَلِيلُ', 'بَعْضَ الَّذي إِلَيْهِ عَنْهُمْ وَصَلوا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُسْتَنْفِرًا أَصْحَابَهُ جَمِيعَا', ['صَلَّى النَّبِيُّ بِهِمْ صَلَاةَ الظُّهْرِ', 'أَسْمَاؤُهُ الشَّرِيفَةُ الْمُطَهَّرَة', 'فَعَادَ نَحْوَ بَيْتِهِ سَرِيعَا', 'قَالَ لَهُمْ إِنِّي رَسُولُ رَبِّكُمْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأُخْرِجُوا لِلشَّامِ أَرْضِ الحَشْرِ', ['وَلا كَمِثْلِ هاشِمٍ بَني أَبِ', 'وَبَعْضُهُمْ لِخَيْبَرَ قَدْ يَجْرِي', 'وَكَانَ فَتْحًا كَامِلًا وَعَمَّ', 'نَسْلُ النَّبِيِّ الْمُصْطَفَى وَنَبَتَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأُنْزِلَتْ فِي حَقِّ هَذَا سُورَةٌ', ['هِيَ سُورَةُ الحَشْرِ بِهَا مُخْبَرَةٌ', 'بِعَهْدِهِ مَعَ النَّبِيْ لَمْ يُبَالِ', 'هَذَا النَّبِيُّ يَخْرُجُ بِصَوْتِهَا', 'عِنْدَ الَّذِي خَلَقَهُمْ سُعَدَاءُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يُلْقُوا عَلَيْهِ صَخْرَةً عَظِيمَةْ', ['عُثْمَانُ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', 'فَإِنَّهُمْ قُلُوبُهُمْ سَقِيمَةْ', 'فَأَقْبَلُوا بِخَالِصِ الْإِذْعَانِ', 'تِلْكَ الصَّحِيفَةَ الَّتِي قَدْ قُطِّعَتْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَهَمَّتِ اليَهُودُ بِالخِيَانَةْ\nأَنْ يَقْتُلُوا النَّبِيَّ ذَا الأَمَانَةْ', ['مِنْهَا وَأَنْتُمْ مُسْلِمُونَ اعْتَصِمُوا', 'يُلْقُوا عَلَيْهِ صَخْرَةً عَظِيمَةْ', 'وَغَادَرُوهَا كُلُّهُمْ وَذَهَبُوا', 'أَرْوَاحُهُمْ فِي جَوْفِ طَيْرٍ خُضْرِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بَنُو النَّضِيرِ فَأَتَى جِبْرِيلُ\nأَخْبَرَهُ بِالخَبَرِ الجَلِيلُ', ['وَرَفَضَ الْخُرُوجَ ثُمَّ اعْتَذَرَا', 'وَمَعَهُمْ قَبَائِلُ الْحُلَفَاءِ', 'فَعَادَ نَحْوَ بَيْتِهِ سَرِيعَا', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْضُهُمْ لِخَيْبَرَ قَدْ ........', ['يَجْرِي', 'يَعْلَمَا', 'يُبَالِ', 'يُعَابُوا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'يُلْقُوا عَلَيْهِ صَخْرَةً عَظِيمَةْ\nفَإِنَّهُمْ قُلُوبُهُمْ سَقِيمَةْ', ['يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا', 'فَإِنَّهُ كانَ حَكيماً طَيِّبا', 'فَذَهَبُوا لِلْبَيْتِ حَتَّى يَضْرِبُوا', 'بَنُو النَّضِيرِ فَأَتَى جِبْرِيلُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَاصَرَهُمْ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا\nلِأَمْرِهِ وَالمُسْلِمُونَ غَنِمُوا', ['وَقَالَ لِلصَّحَابَةِ الْكِرَامِ', 'وَأُنْزِلَتْ فِي حَقِّ هَذَا سُورَةٌ', 'سَمَّى بِبِسْمِ اللهِ ثُمَّ ضَرَبَا', 'فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَعَادَ نَحْوَ بَيْتِهِ ........', ['سَرِيعَا', 'سَمَّيْتُهَا', 'سَلِمَا', 'سَتَفْهَمُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأُنْزِلَتْ فِي حَقِّ هَذَا سُورَةٌ\nهِيَ سُورَةُ الحَشْرِ بِهَا مُخْبَرَةٌ', ['بَسَطَ فِيهَا رِجْلَهُ وَقَالَا', 'لَمْ يَتَخَلَّفْ مِنْهُمُ إِلاَّ القَلِيل', 'وَأُخْرِجُوا لِلشَّامِ أَرْضِ الحَشْرِ', 'خَرَجَ مِنْهَا ذَلِكَ النُّورُ الْمُبِين'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَنُو ........ فَأَتَى جِبْرِيلُ', ['الْجِنِّ', 'الْأَمَانَةْ', 'النَّضِيرِ', 'الحَشْرِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هِيَ ........ الحَشْرِ بِهَا مُخْبَرَةٌ', ['سِقَاءً', 'سَعْدُ', 'سَأَلَهُ', 'سُورَةُ'], 3),
  ],
  <PoemQ>[
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'غَزَا بَنِي مُحَارِبٍ فِي نَجْدِ\nكَذَا بَنِي ثَعْلَبَةَ بْنِ سَعْدِ', ['فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى', 'لِأَنَّهُمْ قَدْ جَمَعُوا الجُمُوعَا', 'وَأَصْطَلَحَ الرُّوَاةُ فِي التَّسْمِيَةْ', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَلْ هَرَبُوا مِنْ ........ الجَلَالْ', ['سَببًا', 'سَطْوَةِ', 'سَيِّدِي', 'سُهَيْلًا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لِأَنَّهُمْ قَدْ جَمَعُوا الجُمُوعَا\nلِحَرْبِهِ فَجَاءَهُمْ سَرِيعَا', ['وَاللهُ أَلْقَى الرُّعْبَ فِي قُلُوبِهِمْ', 'نَبِيُّنَا وَإسْمُهُ مُحَمَّدٌ', 'فِي السَّنَةِ الثَّالِثَةِ كَانَتْ أُحُدْ', 'وَكَانَتِ اسْتِجَابَةُ الدُّعَاءْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَاللهُ أَلْقَى الرُّعْبَ فِي قُلُوبِهِمْ', ['مُسْتَشْهِدًا بِأَطْيَبِ الكَلَامْ', 'وَبَعْدَ ذَا تَفَرَّقَتْ جُمُوعُهُمْ', 'بِجَنَّةِ الْخُلُودِ فِيهَا يَنْعَمُوا', 'فَجَلَسَ الذِّئْبُ إِلَيْهِ كَلَّمَهْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ذَاتُ الرِّقَاعِ بَعْدَ ذَاكَ أَقْبَلَتْ\nثُمَّ صَلَاةُ الخَوْفِ فِيهَا وَقَعَتْ', ['وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا', 'فِي السَّنَةِ الثَّالِثَةِ كَانَتْ أُحُدْ', 'قَالَ بِأَنَّهُ النَّبِيُّ الْخَاتَمُ', 'غَزَا بَنِي مُحَارِبٍ فِي نَجْدِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَاللهُ أَلْقَى الرُّعْبَ فِي قُلُوبِهِمْ\nوَبَعْدَ ذَا تَفَرَّقَتْ جُمُوعُهُمْ', ['حِينَ أَشَاعُوا أَنَّهُ قَدْ قُتِلَا', 'وَلَمْ يَكُنْ بَيْنَهُمَا قِتَالْ', 'أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ', 'سُمَيَّةُ وَابْنُهَا عَمَّارْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'ثُمَّ صَلَاةُ الخَوْفِ فِيهَا وَقَعَتْ', ['بِأَنَّ مَا عِنْدَ الْإِلَهِ بَاقِ', 'وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا', 'ذَاتُ الرِّقَاعِ بَعْدَ ذَاكَ أَقْبَلَتْ', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِحَرْبِهِ فَجَاءَهُمْ سَرِيعَا', ['وَرَوَى البُخَارِيُّ فِي الصَّحِيحِ مُسْنَدَا', 'فَصَدَّقَاهُ وَقَبَّلَا رِجْلَيْهِ', 'هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'لِأَنَّهُمْ قَدْ جَمَعُوا الجُمُوعَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَلَمْ يَكُنْ بَيْنَهُمَا قِتَالْ', ['فَخَرَجُوا مِنَ الْحِصَارِ صِدْقًا', 'وَعِزِّهِ وَنُورِهِ الْعَجِيبْ', 'فَأَنْزَلَتْ حَلِيبَهَا فِي حِينِهَا', 'بَلْ هَرَبُوا مِنْ سَطْوَةِ الجَلَالْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَذَا بَنِي ثَعْلَبَةَ بْنِ سَعْدِ', ['عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', 'حَتَّى أَتَى الْوَحْيُ مِنَ الرَّحْمَنِ', 'غَزَا بَنِي مُحَارِبٍ فِي نَجْدِ', 'وَآلِهِ جَمِيعِهِمْ وَصَحْبِهِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ذَاتُ ........ بَعْدَ ذَاكَ أَقْبَلَتْ', ['الْأَذَى', 'الْأَجْلَّا', 'السَّكِينَة', 'الرِّقَاعِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَذَا بَنِي ........ بْنِ سَعْدِ', ['ثَبَتَا', 'ثَعْلَبَةَ', 'ثُوَيْبَةُ', 'ثُمَامَة'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَعْدَ ذَا تَفَرَّقَتْ جُمُوعُهُمْ', ['فَقَد رَعَاهُ اللهُ بِالعِنَايَةِ', 'وَاللهُ أَلْقَى الرُّعْبَ فِي قُلُوبِهِمْ', 'عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ', 'اِتَّحَدَ اليَهُودُ وَالكُفَّارُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَلْ ........ مِنْ سَطْوَةِ الجَلَالْ', ['هَرَبُوا', 'هُدَى', 'هَذِهِ', 'هَذَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِحَرْبِهِ ........ سَرِيعَا', ['فَتَحَدَّثَ', 'فَجَلَسَ', 'فَكَانَ', 'فَجَاءَهُمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'غَزَا بَنِي مُحَارِبٍ فِي نَجْدِ', ['لَمَّا تَلَا صَحِيفَةَ القُرآنِ', 'فَإِنَّهُ بِفَضْلِ طَهَ سَعِدَا', 'مِنْهُ وَلَكِنْ حِينَهَا لَمْ يُسْلِمِ', 'كَذَا بَنِي ثَعْلَبَةَ بْنِ سَعْدِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ذَاتُ الرِّقَاعِ بَعْدَ ذَاكَ أَقْبَلَتْ', ['بَيْنَ يَدَيْهِ مُعْلِنًا مَحَبَّتَهْ', 'أُولُو التُّقَى وَالْبِرِّ وَالْأَمَانَةِ', 'نَسائِمٌ تُشْفى بِها الأَمْراضْ', 'ثُمَّ صَلَاةُ الخَوْفِ فِيهَا وَقَعَتْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَاللهُ ........ الرُّعْبَ فِي قُلُوبِهِمْ', ['أَلْقَى', 'أَخْبَرَهُ', 'الجَلالِ', 'البَيْتِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِأَنَّهُمْ قَدْ جَمَعُوا الجُمُوعَا', ['حَكَمْتَ حُكْمَ الْمَلِكِ مَوْلَاكَا', 'لِحَرْبِهِ فَجَاءَهُمْ سَرِيعَا', 'أَحَدٌ مِنَ الْخَلْقِ وَيَأْكُلُ مِنْهَا', 'لِصَحْبِهِ امْضُوا عَلَى إِسْمِ اللهِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بَلْ هَرَبُوا مِنْ سَطْوَةِ الجَلَالْ', ['وَلَمْ يَكُنْ بَيْنَهُمَا قِتَالْ', 'حَتَّى إِذَا مَا انْتَقَلَ لِلْخَلْقِ', 'وَفي الشِّفاءِ لِلْقاضي عِياضْ', 'أَدْعُوكُمُ بِالْوَحْيِ لِلتَّوْحِيدِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَلْقَى الرُّعْبَ فِي قُلُوبِهِمْ', ['وَسَالَتِ', 'وَدَمِ', 'وَالْبِرِّ', 'وَاللهُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ قَدْ جَمَعُوا الجُمُوعَا', ['لِهَمِّي', 'لِأَنَّهُمْ', 'لِلْعِيَالِ', 'لَكِنَّهُمْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَلَمْ يَكُنْ بَيْنَهُمَا ........', ['قَوْمِهِمْ', 'قَدَّمَهُ', 'قُبَاءَ', 'قِتَالْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'غَزَا بَنِي ........ فِي نَجْدِ', ['مُحَارِبٍ', 'مَسْجِدِ', 'مُصِيبَةُ', 'مُعَظِّمَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ صَلَاةُ الخَوْفِ ........ وَقَعَتْ', ['فِيهَا', 'فَوَصَلَ', 'فَأَتَاهُ', 'فَأَسْرَعَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَلَمْ يَكُنْ ........ قِتَالْ', ['بَيْنَهُمَا', 'بِالْمُصْطَفَى', 'بَيْعَةُ', 'بَشَّرَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِأَنَّهُمْ قَدْ جَمَعُوا ........', ['اللِّوَاءِ', 'الجُمُوعَا', 'المُصطَفَى', 'العَرشِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَاللهُ أَلْقَى ........ فِي قُلُوبِهِمْ', ['الرُّعْبَ', 'أَسْلَمُوا', 'الحَبِيبُ', 'الْأَقْوَامْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ثُمَّ ........ الخَوْفِ فِيهَا وَقَعَتْ', ['صَارَعَهُ', 'صَلَاةُ', 'صِحاحُ', 'صِهْرُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَلْ هَرَبُوا مِنْ سَطْوَةِ ........', ['الجَلَالْ', 'الوَاحِدِ', 'الرَّحْمَنُ', 'المَوْلى'], 0),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَدُومَةُ الجَنْدَلِ ثُمَّ المُصْطَلِقْ', ['ثَلَاثَ عَشْرَ مُنْذُ وَقْتِ الْبَعْثَة', 'قَدْ رُدِمَتْ لِمُدَّةٍ مِنَ الزَّمَنْ', 'وَهِيَ المُرَيْسِيعُ بِوَسْمٍ مُتَّفَقْ', 'لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِمَكَّةَ خَوْفًا مِنَ ........', ['الطَّرِيقِ', 'الصَّحْبَ', 'أَجْرُهُمْ', 'المِيعَادْ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسُمِّيَتْ أَيْضًا بِبَدْرِ المَوْعِدِ\nمَعَ أَبِي سُفْيَانَ يَوْمَ أُحُدِ', ['وَانْطَلَقَ النَّبِيُّ نَحْوَ طَيْبَة', 'لَكِنَّهُ بِجَيْشِهِ قَدْ عَادْ', 'وَرِعَايَةُ الْأَغْنَامِ بَابُ اللَّطْفِ', 'بِغَارِ حِرَاءَ وَكَانَ عَابِدًا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسُمِّيَتْ بِبَدْرٍ ........', ['السَّلَامْ', 'الْإِكْرَامَا', 'الأَنْصَارُ', 'الصَّغِيرَةْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مَعَ أَبِي سُفْيَانَ يَوْمَ أُحُدِ', ['يَدْعُو بِهَا النَّبِيُّ لِلصَّحَابَةْ', 'وَسُمِّيَتْ أَيْضًا بِبَدْرِ المَوْعِدِ', 'أَكُنْتُمُ مُصَدِّقِينَ قَوْلِي', 'وَحِينَهَا قَدْ سُمِّيَ الصِّدِّيقَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَكِنَّهُ بِجَيْشِهِ قَدْ عَادْ', ['لِمَكَّةَ خَوْفًا مِنَ المِيعَادْ', 'فَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا', 'لِنَقْضِهِمْ لِلْعَهْدِ كَالأَفَاعِي', 'فِي شِدَّةِ الْحَرِّ بِلَا قَرِيبِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَهِيَ المُرَيْسِيعُ بِوَسْمٍ ........', ['مَكَانِ', 'مُتَأَبِّيَة', 'مَالٍ', 'مُتَّفَقْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَاكَ بَدْرٌ الأَخِيرَةْ', ['في الحُسْنِ وَالبَهاءِ وَالجَمالِ', 'إِلَيْكُمُ يَنْهَاكُمُ عَنْ شِرْكِكُمْ', 'وَسُمِّيَتْ بِبَدْرٍ الصَّغِيرَةْ', 'أَتَوْا لَهُمْ مِنْ كَافَّةِ الْأَنْحَاءِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لَكِنَّهُ بِجَيْشِهِ قَدْ عَادْ\nلِمَكَّةَ خَوْفًا مِنَ المِيعَادْ', ['وَدُومَةُ الجَنْدَلِ ثُمَّ المُصْطَلِقْ', 'يَتَعَرَّفونَ عَلَى الحَبيبِ وَآلِهِ', 'وَحَضَرَ النَّبِيُّ مَعَ أَعْمَامِهِ', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَاكَ بَدْرٌ الأَخِيرَةْ\nوَسُمِّيَتْ بِبَدْرٍ الصَّغِيرَةْ', ['وَسُمِّيَتْ أَيْضًا بِبَدْرِ المَوْعِدِ', 'سُبْحَانَ مَنْ يُعْطِي الْعَطَا الْجَزِيلَا', 'وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', 'حَتَّى وَبَعْدَ مَوْتِهَا قَدْ أَكْرَمَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَيْضًا بِبَدْرِ المَوْعِدِ', ['وَعَمَّ', 'وَسُمِّيَتْ', 'وَرَجَعَ', 'وَسَعِيدًا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَهِيَ المُرَيْسِيعُ بِوَسْمٍ مُتَّفَقْ', ['وَبَدْرٌ الكُبْرَى أَتَتْ بِالثَّانِيَة', 'تَحَدَّاهُمُ رَسُولُ اللَّهِ فِيهِ', 'فَدَعَا لَهُ اللَّهُمَّ سَدِّدْ رَمْيَتَهْ', 'وَدُومَةُ الجَنْدَلِ ثُمَّ المُصْطَلِقْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَسُمِّيَتْ بِبَدْرٍ الصَّغِيرَةْ', ['وَاللَّهِ مَا هَذَا بِقَوْلِ سَاحِرٍ', 'وَبَعْدَ ذَاكَ بَدْرٌ الأَخِيرَةْ', 'لِيُؤْمِنُوا يُصَدِّقُوا بِدِينِهِ', 'مَرَّ عَلَيْهِ الْمُصْطَفَى فِي الْوَادِي'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسُمِّيَتْ أَيْضًا بِبَدْرِ المَوْعِدِ', ['مِنَ النَّبِيِّ الهَاشِمِيْ مُعْتَبِرَا', 'وَإِنْ أَرَادُوا فِتْنَةً أَبَيْنَا', 'مَعَ أَبِي سُفْيَانَ يَوْمَ أُحُدِ', 'نَحْنُ مَعَكَ يَا صَاحِبَ القُرْآن'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِمَكَّةَ خَوْفًا مِنَ المِيعَادْ', ['لَكِنَّهُ بِجَيْشِهِ قَدْ عَادْ', 'لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'وَهَكَذَا الْكِبْرُ يَصُدُّ الْخَلْقَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الجَنْدَلِ ثُمَّ المُصْطَلِقْ', ['وَأَرْضًا', 'وَدُومَةُ', 'وَهَكَذَا', 'وَالسَّلَامِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسُمِّيَتْ أَيْضًا بِبَدْرِ ........', ['المَوْعِدِ', 'الخَليلَ', 'الْأَغَر', 'المَسيحِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِبَدْرٍ الصَّغِيرَةْ', ['وَمَعَهُنَّ', 'وَاسْمُهُ', 'وَدَعَا', 'وَسُمِّيَتْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَدُومَةُ الجَنْدَلِ ثُمَّ ........', ['الجَلِيلُ', 'الشَّرِيفْ', 'المُصْطَلِقْ', 'أَخَذَهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لِمَكَّةَ ........ مِنَ المِيعَادْ', ['خَيَّرَه', 'خَوْفًا', 'خَافَا', 'خُضْرِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَهِيَ ........ بِوَسْمٍ مُتَّفَقْ', ['المُرَيْسِيعُ', 'الطَّاهِرِ', 'الْفَاعِلُ', 'الْعَفِيفْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَكِنَّهُ ........ قَدْ عَادْ', ['بِهَا', 'بِمَالِهِ', 'بِجَيْشِهِ', 'بِرَبِّ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسُمِّيَتْ ........ الصَّغِيرَةْ', ['بِبَدْرٍ', 'بِنَعْتِهِ', 'بَشَّرَهُمْ', 'بِقُدُومِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَعَ أَبِي ........ يَوْمَ أُحُدِ', ['سُمَيَّةُ', 'سَيُغْلَبُون', 'سُفْيَانَ', 'سُمِّيَتْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ ذَاكَ بَدْرٌ الأَخِيرَةْ', ['وَجَاءَ', 'وَبَعْدَ', 'وَهُمْ', 'وَالْكُلُّ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ خَوْفًا مِنَ المِيعَادْ', ['لِمَكَّةَ', 'لِدِينِ', 'لِطَهَ', 'لِنَفْسِكَ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَهِيَ المُرَيْسِيعُ ........ مُتَّفَقْ', ['بِغَيْرِ', 'بِوَسْمٍ', 'بِصِدْقِ', 'بِقَصْدِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسُمِّيَتْ أَيْضًا ........ المَوْعِدِ', ['بَيْنَكُمْ', 'بَكَاهَا', 'بِبَدْرِ', 'بَسَطَ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَدُومَةُ ........ ثُمَّ المُصْطَلِقْ', ['الطَّيْرُ', 'الْأَمِينْ', 'الْأَعْظَمِ', 'الجَنْدَلِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ ذَاكَ بَدْرٌ ........', ['الأَخِيرَةْ', 'الْأَشْيَاخُ', 'النَّسَائِمُ', 'القَلِيلِ'], 0),
  ],
  <PoemQ>[
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَرَدَّ اللهُ كَيْدَ أَهْلِ الكُفْرِ\nوَفَازَ خَيْرُ خَلْقِهِ بِالنَّصْرِ', ['فَانْتَشَرَتْ دَعْوَتُهُ بَيْنَ الْعَرَبْ', 'وَعِنْدَمَا عَادُوا إِلَى الدِّيَارِ', 'ثُمَّ أَتَى يَنْظُرُ جَيْشَ الْمُصْطَفَى', 'أَمَرَ الحَبِيبُ صَحَابَهُ بِالجَدِّ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ظَنُّوا بِأَنَّ المُصْطَفَى سَيَنْهَزِمْ\nوَمَا دَرَوْا بِأَنَّهُ النُّورُ الأَتَمْ', ['وَأَنَّ رَبَّنَا مُتِمٌّ نُورَهُ', 'فَلَمْ يَزَلْ يَنْطِقُ بِالشَّهَادَةِ', 'وَمَواقِفُ الأَصْحابِ كَيْفَ تَحَمَّلوا', 'سَعْدٌ هُوَ بْنُ مُعَاذٍ وَقِيلَ الحُبَابْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُسْتَبْشِرًا يَهْتَزُّ مِنْ فَرْحَتِهِ', ['وَاهْتَزَّ عَرْشُ اللهِ عِنْدَ مَوْتِهِ', 'فَأَرْسَلَتْ قُرَيْشٌ مِنْ رِجَالِهَا', 'كَانَ شَدِيدًا رَاعِيَ الْأَغْنَامْ', 'قَامَ إِلَيْهِ رَجُلٌ بِسَيْفِهِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَنَقَضَتْ قُرَيْظَةُ العُهُودْ', ['سَارُوا لِأَرْضِ الشَّامِ فِي إِجْلَائِهِمْ', 'فِي يَوْمِ الاثْنَيْنِ بِنُورٍ بَادِي', 'لِأَنَّ ذَاكَ عَادَةُ اليَهُودْ', 'وَقَصْدُهُنَّ النَّوْحُ وَالْبُكَاءُ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَمْسًا وَعِشْرِينَ مِنَ اللَّيَالِي\nحِصَارُهُمْ كَانَ عَلَى التَّوَالِي', ['صَدًّا عَنِ الدِّينِ الحَنِيفِ يُنْفِقُون', 'وَقَذَفَ الْجَلِيلُ فِي قُلُوبِهِمْ', 'مَوْلِدُهُ مِيلَادُ كُلِّ الْبُشْرَيَات', 'فَإِنَّهُ كانَ حَكيماً طَيِّبا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَانْفَجَرَ الْجُرْحُ وَسَالَ دَمُهُ\nمَاتَ شَهِيدًا وَسَعِيدًا يَوْمُهُ', ['مِنْ بَعْدِ مَا عَلَى الأَذَى قَدْ صَبَرُوا', 'وَاهْتَزَّ عَرْشُ اللهِ عِنْدَ مَوْتِهِ', 'فَأَسْلَمَتْ جُمُوعُهُم وَعَادُوا', 'وَعَلِمُوا بِحَقِّهِ وَأَذْعَنُوا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَعِزِّهِ وَنُورِهِ الْعَجِيبْ', ['إِيَّاكُمُ أَنْ تَتْرُكُوا مَكَانَكُمْ', 'لَمَّا رَأَى مِنْ خُلُقِ الْحَبِيبْ', 'وَسُمِّيَتْ أَيْضًا بِبَدْرِ المَوْعِدِ', 'سَأَلُوهَا عَنْ دِيَةِ الرِّجَالِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِالْوَحْيِ مِنْ رَبِّ الْوَرَى أَنْ يُسْرِعَا\nإِلَى بَنِي قُرَيْظَةَ وَيَشْرَعَا', ['فَأَمَرَ النَّبِيُّ مَنْ يُنَادِي', 'وَقالَ البَعْضُ إِنَّها تَأْويلُها', 'فَقَد رَعَاهُ اللهُ بِالعِنَايَةِ', 'وَكَانَتِ الْأَنْصَارُ سَائِرَ الْأَيَّام'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَلَا يُصَلِّي الْعَصْرَ إِلَّا فِي بَنِي\nقُرَيْظَةَ وَنَحْوَهُمْ يُصْحِبُنِي', ['وَحَامِلُ اللِّوَاءِ إِذْ ذَاكَ عَلِي', 'يَبْكِي فُؤَادِي الشَّوْقُ عِنْدَ ذِكْرِهَا', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ', 'يَجْمَعُهُمْ في كُلِّ يَوْمِ جُمُعَةِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'صَارَ مُحِبًّا لِلنَّبِيِّ خَادِمَا', ['لَمَّا رَأَتْ نُورَ النُّبُوَّةِ ظَاهِرَا', 'لَوْلاهُ ما خَلَقْتُ جَدَّكَ آدَما', 'مُصَدِّقًا بِدِينِهِ وَمُسْلِمَا', 'فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَكَمْتَ فِيهِمُ بِحُكْمِ اللهْ\nفَوْقَ السَّمَاوَاتِ الْعُلَا يَرْضَاهْ', ['وَالمُصْطَفَى قَد أَخَّرَ الصِّدِّيقَا', 'وَرُكَانَةْ ظَهَرَتْ لَهُ مُعْجِزَةٌ', 'وَانْفَجَرَ الْجُرْحُ وَسَالَ دَمُهُ', 'فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمُظْهِرٌ فِي خَلْقِهِ أُمُورَهُ', ['فَبَايَعُوهُ بَيْعَةً مُسَدَّدَة', 'بِأَنَّ طَهَ خَاتَمٌ لِلْأَنْبِيَا', 'وَأَنَّ رَبَّنَا مُتِمٌّ نُورَهُ', 'وَقَدْ أَجَلَّهُ عَنِ النِّسَاءِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَطْفِهِ ........ أَنْ خَلَّاهْ', ['عَالِمًا', 'عَظِيمَة', 'عَلَيْهِ', 'عَزَفَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَمْرَهُ عَلَى الدَّوَامِ سَامِعَا', ['ظَنُّوا بِرَبِّ الْعَرْشِ غَيْرَ الْحَقِّ', 'وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'ظَنُّوا بِأَنَّ المُصْطَفَى سَيَنْهَزِمْ', 'مَنْ كَانَ لِلْحَبِيبِ طَهَ طَائِعَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَالَ لَهُ النَّبِيُّ عِنْدَ ........', ['ذَهَبُوا', 'ذِئْبًا', 'ذَاكَا', 'ذَنْبِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقَذَفَ الْجَلِيلُ فِي ........', ['قِلَّتِهِ', 'قَوْمِهِ', 'قُلُوبِهِمْ', 'قُبَيلَ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'الْفَارِسُ ........ ذُو الْقَدْرِ الْجَلِي', ['النُّورَا', 'الْكَرَّارُ', 'الرُّعْبَ', 'الصُّخُورَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ ذَاكَ قِصَّةُ ثُمَامَة', ['وَمُوقِنَا', 'وَقَبْرُهُ', 'وَفَرَضَ', 'وَبَعْدَ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَأَمَرَ النَّبِيُّ مَنْ يُنَادِي\nأَصْحَابَهُ بِلَالُ بِالْجِهَادِ', ['مَنْ كَانَ لِلْحَبِيبِ طَهَ طَائِعَا', 'وَهَكَذَا فَعَلُوا إِلَى أَنْ بَلَغَتْ', 'مُبَشِّراً بِبِعْثَةِ الرَّسولْ', 'مَا بَعَثَ اللَّهُ نَبِيًّا إِلَّا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِحُكْمِ سَعْدٍ تُقْتَلُ الرِّجَالُ\nوَتُقْسَمُ الذَّرَارِي وَالْأَمْوَالُ', ['لَكِنْ شَفَاهُ اللهُ مِمَّا لَاقَى', 'تَلَا عَلَيْهِم حِينَهَا يَاسِينَا', 'قَالَ لَهُ النَّبِيُّ عِنْدَ ذَاكَا', 'وَجَاءَ وَفْدُ الْجِنِّ لِلرَّسُولِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَتَاهُ جِبْرِيلُ بِلَا انْتِظَارِ', ['وَعِنْدَمَا عَادُوا إِلَى الدِّيَارِ', 'وَعُمْرُهَا إِذْ ذَاكَ خَمْسَةَ عَشَر', 'فَقَالَ عِنْدَ ذَا حَبِيبُ اللهِ', 'قَدْ آنَ أنْ يَخْرُجَ يُدْعى أَحْمَدا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَنْ كَانَ لِلْحَبِيبِ طَهَ ........', ['طَاهِرٌ', 'طَيْبَةَ', 'طَيْرٌ', 'طَائِعَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَفَازَ خَيْرُ خَلْقِهِ بِالنَّصْرِ', ['لَمَّا الْتَقَى الْجَمْعَانِ مَنْ تَوَلَّى', 'قَالَ أَبُو الصِّدِّيقِ لِابْنِهِ أَبِي', 'عَادَ بَنُو زُهْرَةَ لَمْ يُقَاتِلُوا', 'وَرَدَّ اللهُ كَيْدَ أَهْلِ الكُفْرِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَقَذَفَ الْجَلِيلُ فِي قُلُوبِهِمْ', ['مَعَ أَبِي سُفْيَانَ يَوْمَ أُحُدِ', 'يَقْضِي بِهَا فِي جَيْشِهِ الأُمُورَا', 'الرُّعْبَ ثُمَّ كَانَ مِنْ عِقَابِهِمْ', 'لَمَّا طَغَوْا عَلَيْهِمُ بِبَغْيِهِمْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحَامِلُ اللِّوَاءِ إِذْ ذَاكَ عَلِي', ['الْفَارِسُ الْكَرَّارُ ذُو الْقَدْرِ الْجَلِي', 'مُتَعَجِّبًا مُتَسَائِلًا مُسْتَبْشِرَا', 'يَأْتِيَانِ لَهُم بِمَا يَشَاءُوا', 'تَفْدِيهِ رُوحِي الصَّادِقَ الأَمِينَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَا دَرَوْا بِأَنَّهُ النُّورُ الأَتَمْ', ['وَازْدَادَ إِيمَانُ الصَّحَابَةِ الْكِرَامِ', 'صَدَّقَهُ وَأَعْلَنَ الوَفَاءَا', 'ظَنُّوا بِأَنَّ المُصْطَفَى سَيَنْهَزِمْ', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمُظْهِرٌ فِي خَلْقِهِ ........', ['المَبْعوثِ', 'أَشْرَاطِ', 'الأُولَى', 'أُمُورَهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَتُقْسَمُ الذَّرَارِي وَالْأَمْوَالُ', ['سُمَيَّةُ وَابْنُهَا عَمَّارْ', 'لَمْ يَدْخُلَا الإِسْلَامَ قَدْ خَافَا عَلَى', 'بِحُكْمِ سَعْدٍ تُقْتَلُ الرِّجَالُ', 'وَخَصَّهَا بِأَشْرَفِ الْمَزَايَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'صَارَ ........ لِلنَّبِيِّ خَادِمَا', ['مِائَةِ', 'مُحِبًّا', 'مُصَدِّقَا', 'مِيلَادُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَاهْتَزَّ عَرْشُ ........ عِنْدَ مَوْتِهِ', ['الشَّاهِدُ', 'اللهِ', 'أَدَبًا', 'السَّلَامَ'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَا خَيْبَرُ وَوَادِي الْقُرَى', ['بِجَيْشِهِ الْمَنْصُورِ بِالرُّعْبِ سَرَى', 'وَأَكْمَلُوا طَرِيقَهُمْ جَمِيعًا', 'قَدْ أَدْرَكُوا وَرَبُّنَا السَّعَادَةْ', 'وَأَخْلَصُوا لِقُرْبِهِ أَنَابُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'من هجرةِ ........ على التمامِ', ['الحَالِ', 'الهَادِي', 'الشَّمْسَ', 'الرُّوَاتْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَضَى بِهَا عُمْرَةَ عَامٍ قَدْ مَضَى', ['طَافُوا بِبَيْتِ اللهِ قَدْ نَالُوا الرِّضَا', 'لَم يَشْهَدُوا عِنَايَةَ الرَّحْمَنِ', 'إِنْ شِئْتَ يَا طَهَ يَكُنْ سَرِيعَا', 'لِلغَارِ بِالحِقْدِ وَبِالغَبَاءِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ ذَاكَ عُمْرَةُ ........', ['الْقَضَاءِ', 'أَعْمَامِهِ', 'اعْتَصِمُوا', 'المَسِيرِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَا خَيْبَرُ وَوَادِي الْقُرَى\nبِجَيْشِهِ الْمَنْصُورِ بِالرُّعْبِ سَرَى', ['صَلَّى النَّبِيُّ بِهِمْ صَلَاةَ الظُّهْرِ', 'وَأَخَذَ بِسَيْفِهِ وَقَالَ لَهْ', 'وَبَعْدَ ذَاكَ عُمْرَةُ الْقَضَاءِ', 'وَقَبْلَ عَامٍ بَعْدَ هَذَا الْيَوْمِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَضَى بِهَا عُمْرَةَ عَامٍ قَدْ مَضَى\nطَافُوا بِبَيْتِ اللهِ قَدْ نَالُوا الرِّضَا', ['ومؤتة في ثَامن الأعوامِ', 'ظَنُّوا بِأَنَّ المُصْطَفَى سَيَنْهَزِمْ', 'وَاللهُ بِالأَمْلاَكِ قَدْ أَمَدَّهُمْ', 'مُبَشِّراً بِبِعْثَةِ الرَّسولْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'من هجرةِ الهَادِي على التمامِ', ['سَلْمَانُ مِنَّا نَحْنُ أَهْلَ البَيْتْ', 'ومؤتة في ثَامن الأعوامِ', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'وَمَعَهُنَّ خَرَجَتِ النِّسَاءُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَاكَ عُمْرَةُ الْقَضَاءِ', ['فَاسْتَبْشَرَ النَّبِيُّ أَنْ قَدْ سَلِمَا', 'يَا سَعْدَهُمْ بِقُدُومِهِ يَا لَلْهَنَا', 'لَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا', 'وَسَارَ بِالرِّجَالِ وَالنِّسَاءِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'طَافُوا بِبَيْتِ اللهِ قَدْ نَالُوا الرِّضَا', ['قَالَ لَهُمْ لَوْ قُلْتُ إِنَّ الْمُعْتَدِين', 'وَهَكَذَا فَعَلُوا إِلَى أَنْ بَلَغَتْ', 'فَكَانَ عَبْدُ اللَّهِ وَالِدُ أَحْمَدَا', 'قَضَى بِهَا عُمْرَةَ عَامٍ قَدْ مَضَى'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَاكَ عُمْرَةُ الْقَضَاءِ\nوَسَارَ بِالرِّجَالِ وَالنِّسَاءِ', ['فَفَرِحُوا وَسَارَعُوا بِالْجِدِّ', 'قَضَى بِهَا عُمْرَةَ عَامٍ قَدْ مَضَى', 'سَبَبُهَا بَدْرٌ هُوَ الْغِفَارِي', 'لَا تَسْأَلُوهُ حَتَّى لَا يُجِيبَكُمْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِجَيْشِهِ الْمَنْصُورِ بِالرُّعْبِ سَرَى', ['وَغَيْرُهُمْ مِنَ الصَّحَابَةِ الْكِرَامْ', 'وَلَمْ يُسَاعِدْ عُصْبَةَ الْكُفَّارِ', 'قَالَتْ قُرَيْشٌ إِنَّهَا مِنْ حَقِّنَا', 'وَبَعْدَ ذَا خَيْبَرُ وَوَادِي الْقُرَى'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ في ثَامن الأعوامِ', ['وَرَبُّنَا', 'وَاللهِ', 'ومؤتة', 'وَعَلَى'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْمَنْصُورِ بِالرُّعْبِ سَرَى', ['بِجَيْشِهِ', 'بِدِينِهِ', 'بَشَّرَهُمْ', 'بِدَارِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَسَارَ بِالرِّجَالِ وَالنِّسَاءِ', ['وَبَعْدَ ذَاكَ عُمْرَةُ الْقَضَاءِ', 'فَدَعَا لَهُ اللَّهُمَّ سَدِّدْ رَمْيَتَهْ', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى', 'وَقَذَفَ الجَبَّارُ فِي قُلُوبِهِمْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ومؤتة في ثَامن الأعوامِ', ['فِي الْكُتُبِ الصَّحِيحَةِ الْمُسَطَّرَة', 'ثُمَّ أَعْطَاهُ لِمُصْعَبٍ مِنْ بَعْدِ حِينْ', 'من هجرةِ الهَادِي على التمامِ', 'مِنْ عَمِّهِ لِيَقْتُلُوهُ فِي جَفَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'طَافُوا بِبَيْتِ اللهِ قَدْ ........ الرِّضَا', ['نَقُولُ', 'نِسَاءِ', 'نَسائِمٌ', 'نَالُوا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِجَيْشِهِ الْمَنْصُورِ ........ سَرَى', ['بِالْقِيَانِ', 'بِنُورِهِ', 'بِمَوْتِهِ', 'بِالرُّعْبِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'من ........ الهَادِي على التمامِ', ['هَاتِيهِ', 'هُدَى', 'هَمَّهُمْ', 'هجرةِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَارَ ........ وَالنِّسَاءِ', ['بِالرِّجَالِ', 'بِالحَقِّ', 'بِابْنِنَا', 'بِنَعْتِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِبَيْتِ اللهِ قَدْ نَالُوا الرِّضَا', ['طَافُوا', 'طَيْرٍ', 'طَيِّبا', 'طَبِيبِي'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ ذَا خَيْبَرُ وَوَادِي الْقُرَى', ['وَبَعْدَ', 'وَالِدِهْ', 'وَأَنْتَ', 'وَفَزِعُوا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ ذَاكَ عُمْرَةُ الْقَضَاءِ', ['وَصْفًا', 'وَسَاقَ', 'وَحُبَّ', 'وَبَعْدَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'طَافُوا ........ اللهِ قَدْ نَالُوا الرِّضَا', ['بِدَارِ', 'بِنَعْتِهِ', 'بِبَيْتِ', 'بَعْدَها'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'من هجرةِ الهَادِي على ........', ['التمامِ', 'اللَّهُ', 'أَهْلًا', 'أَدَبًا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِالرِّجَالِ وَالنِّسَاءِ', ['وَلاَ', 'وَسَارَ', 'وَالْعَوْنُ', 'وَنَقَضَتْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'طَافُوا بِبَيْتِ ........ قَدْ نَالُوا الرِّضَا', ['اللهِ', 'الْيَهُودُ', 'إِغَارَةْ', 'انْتِظَارِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بِجَيْشِهِ ........ بِالرُّعْبِ سَرَى', ['المَنَّانِ', 'أَتَمَّهَا', 'الْعَدُوَّ', 'الْمَنْصُورِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ومؤتة في ........ الأعوامِ', ['ثَلَاثَ', 'ثَامن', 'ثُمَامَة', 'ثَعْلَبَةَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ ذَاكَ ........ الْقَضَاءِ', ['عَامِ', 'عَرَضَتْ', 'عِندَ', 'عُمْرَةُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَبَعْدَ ذَا خَيْبَرُ وَوَادِي ........', ['الصَّحَابَةِ', 'آمَنْتَا', 'أَهَانَهُ', 'الْقُرَى'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَأَمَّنَ الَّذِي يُغْلِقُ ........', ['بِجَنَّةِ', 'بَطْنَ', 'بِالحِقْدِ', 'بَابَهُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَنَشَرَ التَّوْحِيدَ وَالْإِسْلَامَا', ['كَذَاكَ فِي الثَّانِيَةِ وَغَيْرِهَا', 'حَتَّى آتَاهُ اللَّهُ بَعْدَ عَشَرَةْ', 'دَخَلَهَا وَحَطَّمَ الْأَصْنَامَا', 'أَخَذَهَا النَّبِيُّ بَعْدَ إِذْنِهَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'قَالَ لَهُمْ فَأَنْتُمُ الطُّلَقَاءُ', ['وَلَم يَزَل مُدَافِعًا يَرْعَاهُ', 'مِن بَعدِ حَمزَةَ عَلَى اليَقِينِ', 'فَطَبْعُهُ الْعَطَاءُ وَالسَّخَاءُ', 'صَارَ مُحِبًّا لِلنَّبِيِّ خَادِمَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَرَافِعِينَ ........ شِعَارِهِ', ['رُسْلِ', 'رَواهُ', 'رَآهَا', 'رَايَاتِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لِأَنَّ أَهْلَ مَكَّةَ قَدْ نَقَضُوا', ['أَمْلَاكُهَا مَعَ آدَمَ الْجَلِيلَا', 'عَدْنَانَ مِنْ نَسْلِ الْكِرَامِ الْفُضَلَا', 'لِلْعَهْدِ مَا عَلَيْهِ قَدْ تَعَاهَدُوا', 'عِنْدَ اقْتِرَابِ بَعْثَةِ الرَّسُولْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَدَخَلَ النَّاسُ فِي دِينِ اللهْ', ['وَلَمْ يَزَلْ بِحِقْدِهِ مُعَادِيَا', 'دَعَا لَهُ إِمَامُ أَهْلِ الفَضْلِ', 'مِنْ كُلِّ فَجٍّ عَمَّهُمْ ضِيَاهْ', 'بِقُرْبِ أُحُدٍ مَعَ الْأَعْدَادِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'يَا أَهْلَ مَكَّةَ أَجَابُوا الْمُرْسَلَا', ['دَخَلَهَا الْحَبِيبُ فِي تَوَاضُعِ', 'وَبَعْدَ ذَا سَارَ النَّبِيُّ الْمُصْطَفَى', 'قَالَ لَهُمْ مَاذَا تَرَوْنِي فَاعِلًا', 'وَكُسِرَتْ أَسْنَانُهُ السُّفْلِيَّةْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نَهَى عَنِ ........ حِفْظًا لِلرَّحِمْ', ['الشَّرِيفَةْ', 'العَظِيمَا', 'الصِّدِّيقُ', 'الْقِتَالِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَعْلَنَهَا ........ يَوْمُ الْمَرْحَمَة', ['وَإِذا', 'وَزَوْجُهَا', 'وَانْزَاحَ', 'وَقَالَ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِمَكَّةَ فِي عَدَدٍ كَبِيرِ', ['أَمسَكَهُ الحَمزَةُ وَالزُّبَيرُ', 'وَعَلَى الصَّلاَةِ بِأَهْلِهَا ابْنُ أُمٍّ', 'وَجَهَّزَ الْجُيُوشَ لِلْمَسِيرِ', 'عَاشَتْ عَلَى وِدَادِهِ وَخِدْمَتِهِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَاسْتَنْجَدَتْ خُزَاعَةُ بِالْمُصْطَفَى', ['لِحِلْفِهِمْ فَأَعْلَنَ الْهَادِي الْوَفَا', 'بَكَاهُ أَهْلُ مَكَّةَ وَالْبَيْتُ', 'وَمِنْ ظَلَامِ الْكُفْرِ وَالنَّوَاهِي', 'العِلْمُ أَنَّ اللهَ رَبّي فَضَّلا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'قَالُوا لَهُ أَخٌ ........ فِينَا', ['كَأَنَّمَا', 'كَمَدَا', 'كَرِيمٌ', 'كَثِيرٌ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'للهِ ........ النَّبِيلِ الْخَاشِعِ', ['بَيْعَةً', 'بِشَاعِرٍ', 'بِالْجَيْشِ', 'بِوَسَطِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَعَهُمْ أَلْفَانِ بِاصْطِفَافِ', ['قَالَ لَهُ اقْرَأْ أَيُّهَا النَّبِيُّ', 'يَحْدو بِصَوْتٍ يَأْخُذُ الأَلْبابا', 'سَارَ لَهُمْ فِي عَشَرَةِ آلَافِ', 'أَتَاهُمُ نَبِيُّنَا بِالْمُعْجِزَاتِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَدَتْ بَنُو بَكْرٍ عَلَى خُزَاعَة', ['وَقَتَلُوا الرِّجَالَ فِي بَشَاعَة', 'جِهَادُهُمْ فِي نَصْرِ هَذَا الدِّينْ', 'انْتَشَرَ الإِسْلاَمُ بَعْدَ وُقُوعِهَا', 'بِالْبَيْتِ إِذْ لَا تُعْبَدُ الْأَوْثَانُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِعَفْوِهِ تَكَرُّمَا', ['أَخْبرا', 'الظَّاهِرُ', 'الْحَبِيبُ', 'أَطْلَقَهُمْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ فَتْحُ مَكَّةَ الْعَظِيم', ['عَامَ ثَمَانٍ أَنْعَمَ الْكَرِيم', 'وَبَعدَهَا الْمِعْرَاجُ لِلسَّمَاءِ', 'ابْنِي لَهُ مَكَانَةٌ عَلِيَّة', 'أَنْ يُطْلِقُوا تَعْرِيفَهُمْ سَرِيَّةْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَلْفَانِ بِاصْطِفَافِ', ['وَاسْتَوْدَعَ', 'وَمَعَهُمْ', 'وَصَفَتْ', 'وَمَشْيُهُ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'دَخَلَهَا الْحَبِيبُ فِي تَوَاضُعِ', ['للهِ بِالْجَيْشِ النَّبِيلِ الْخَاشِعِ', 'اُنْصُرْنَا رَبِّي وَاهْزِمِ الأَحْزَابْ', 'قَتَلُوهُ فِي بُعْدِ الْأَنْظَارِ', 'وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَدَتْ بَنُو بَكْرٍ عَلَى خُزَاعَة\nوَقَتَلُوا الرِّجَالَ فِي بَشَاعَة', ['هِيَ بَرَّةٌ قَدْ سُمِّيَتْ وَطَيبَة', 'وَوَقَعَتْ فِي سَنَةِ الْمِيلَادِ', 'فَطَلَبَ النَّبِيُّ مِنْهُ أُخْرَى', 'فَاسْتَنْجَدَتْ خُزَاعَةُ بِالْمُصْطَفَى'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ لَهُمْ فَأَنْتُمُ الطُّلَقَاءُ\nفَطَبْعُهُ الْعَطَاءُ وَالسَّخَاءُ', ['قَدْ جَاءَهُ جِبْرِيلُ بِالْبُرَاقِ', 'وَدَخَلَ النَّاسُ فِي دِينِ اللهْ', 'خَيْرُ نِسَاءِ الْعَالَمِينَ فَاطِمَةْ', 'مُوصِيًا أُمَّتَهُ بِالْيُسْرِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَفَا رَسُولُ اللهِ عَمَّنْ ظَلَمَا', ['لِصَحْبِهِ امْضُوا عَلَى إِسْمِ اللهِ', 'وَصَلَهَا الهَادِي البَشِيرُ مُسَلِّمَا', 'أَطْلَقَهُمْ بِعَفْوِهِ تَكَرُّمَا', 'مُعْتَدِلُ الخَلْقِ سَرِيعُ المِشْيَةِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَمَّنَ الَّذِي يُغْلِقُ بَابَهُ', ['مِنْ رَبِّهِ تَلَقّى لِلْكَلِماتْ', 'عَلَيْهِ أَنْ يَتْرُكَهُ أَصْحَابُهُ', 'فَأَكْرِمِ الأَنْصَارَ وَالمُهَاجِرَةْ', 'رُؤْيَا وَمَعْنَاهَا هُنَاكَ مُصِيبَةُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَا أَهْلَ مَكَّةَ أَجَابُوا ........', ['الْمُرْسَلَا', 'الْأُلِي', 'الرِّضَا', 'أَقْوَامَهُمْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَعْلَنَهَا وَقَالَ يَوْمُ الْمَرْحَمَة', ['وَبَشَّرَتْ لِعَمِّهِ قَدْ ثَبَتَا', 'لِطَيْبَةَ يَلْقَاهُمُ الْأَنْصَارُ', 'كَمَا أَتَى فِي سُورَةٍ هِيَ الْقَمَرْ', 'وَصِلَةُ الْأَرْحَامِ لَيْسَ الْمَلْحَمَة'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَاسْتَنْجَدَتْ خُزَاعَةُ بِالْمُصْطَفَى\nلِحِلْفِهِمْ فَأَعْلَنَ الْهَادِي الْوَفَا', ['مُدَافِعًا عَنْهَا وَعَنْ وَفَائِهَا', 'وَبَعْدَ ذَاكَ صَالَحَ اليَهُودَا', 'وَجَهَّزَ الْجُيُوشَ لِلْمَسِيرِ', 'غَزَوَاتُهُ تِسْعٌ وَعِشْرُونَ سَفَرْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَهَّزَ ........ لِلْمَسِيرِ', ['النَّاسُ', 'البُخَارِيُّ', 'الْجُيُوشَ', 'الْمُصْطَفَى'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي عِزَّةِ الْإِسْلَامِ وَانْتِصَارِهِ', ['أَبِي أَيُّوبَ الأَنْصَارِيِّ وَالنَّبِيل', 'وَرَافِعِينَ رَايَاتِ شِعَارِهِ', 'يُخْبِرُهُمْ عَنْ شَأْنِ هَذَا الْيَوْمِ', 'أَكْرِمْ بِهَذَا النَّسَبِ الْإِيمَانِي'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'لِأَنَّ أَهْلَ مَكَّةَ قَدْ نَقَضُوا\nلِلْعَهْدِ مَا عَلَيْهِ قَدْ تَعَاهَدُوا', ['وَدُّوا بِأَنْ يَرْتَدَّ مَنْ قَدْ آمَنَا', 'ذَاتُ النِّطَاقَيْنِ الَّتِي قَد قَطَعَتْ', 'أَعْظَمُهَا قَدْرًا هُوَ الْقُرْآنُ', 'عَدَتْ بَنُو بَكْرٍ عَلَى خُزَاعَة'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'نَهَى عَنِ الْقِتَالِ حِفْظًا لِلرَّحِمْ', ['فِي سُورَةِ الأَنْفَالِ بِالفُرْقَانِ', 'إِلَّا عَلَى مَنِ اعْتَدَى لَهُمْ قَدِمْ', 'وَقَدْ تَسَمّى بِيَوْمِ العَرُوبَةِ', 'لِكَيْ يَكُونَ لِلنَّبِيْ نَصِيرَا'], 1),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أُعْجُوبَةً فَاقْرَأْ أَخِي الْقُرْآنَا', ['الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ', 'سَارُوا لَهُ بِالْمَالِ وَالْأَبْنَاءِ', 'نَصَرَهُمُ اللهُ نَصْرًا كَانَا', 'وَتَرَكُوهَا لَا يُصَدُّ عَنْهَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَ ذَا سَارَ النَّبِيُّ الْمُصْطَفَى', ['بِجَيْشِهِ مُجَاهِدًا مُسْتَأْنَفَا', 'عَمَّ السُّرُورُ أَرْضَهُمْ إِلَى الْأَبَد', 'مُنْتَدِبًا لِقَتْلِهِ الْأَقْوَامْ', 'يَمْضِي بِهِ فِي سَائِرِ الْآفَاقِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَعَ ........ دُونَمَا إِبْطَاءِ', ['الْهَادِي', 'الْغَمِّ', 'الْجُيُوشِ', 'الْعَصْرَ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقُسِّمَتْ بِقِسْمَةٍ حَكِيمَة', ['عَيْنٌ مِنَ الْمَاءِ لَهُمْ فَكَبَّرُوا', 'وَغَنِمُوا غَنَائِمَ عَظِيمَة', 'ضَخْمُ الكَرَادِيسِ طَوِيلُ المَسْرُبَةْ', 'يُحَرِّضْنَ الْقَوْمَ لِلْقِتَالِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'جَمْعٌ عَظِيمٌ عِنْدَ هَذَا ........', ['القَلِيل', 'الْعَامِ', 'الرَّحْمَنِ', 'النُّبُوءَةْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنْ أَكْثَرِ الْأَعْرَابِ مَنْ يُعِينُهُمْ', ['كَانُوا ثَلَاثِينَ أُلُوفًا مَعَهُمْ', 'لَوْ أَنَّهُمْ تَقَاتَلُوا أَصَابُوا', 'وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا', 'أَقَامَ فِي دِيَارِهِمْ أَعْوَاما'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَفَرَّ جَيْشُ الْمُصْطَفَى سِوَاهُ', ['ثَلَاثَ مَرَّاتٍ وَأَرْضًا أَوْقَعَه', 'ثَبَّتَهُ الرَّحْمَنُ مِنْ عُلَاهُ', 'كَذَا ابْنُ عَوْفٍ آمَنُوا مِنْ بَعْدُ', 'وَالْمُعْتَدِي بِنِبَالِهِمْ يَرْمُونَهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَأَنْزَلَ السَّكِينَةَ ........ السَّلَامْ', ['الْمَوْلَى', 'الْأَسْيَادِ', 'الرَّحْمَنِ', 'انْتَقَلَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَخَرَجَ ........ فِي اثْنَيْ عَشَرَا', ['الْأَنْظَارِ', 'النَّبِيُّ', 'أَبْرَهَةُ', 'الْجُمُعَةْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَعَادَ جَيْشُ الْمُصْطَفَى إِلَيْهِ', ['جَمِيعُهُمْ وَأَقْبَلُوا عَلَيْهِ', 'يَا سَعْدَهُمْ بِقُدُومِهِ يَا لَلْهَنَا', 'بِهِ عِيسَى لِقَوْمِهِ وَأَخْبَرَا', 'فَلَمْ أَجِدْ مِنْ قَلْبِ طَهَ أَطْيَبا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَلْقَى عَلَيْهِمُ الْحَصَى ........', ['فَذَهَبَ', 'فَنَادَى', 'فَوْقِ', 'فَشَاهَتْ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مِنَ الْجُمُوعِ عَدَدٌ غَفِيرُ', ['وَمَعَهَا ثَقِيفُ وَالْكَثِيرُ', 'بَسَطَ فِيهَا رِجْلَهُ وَقَالَا', 'لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ', 'فَكَانَ مَا رَأَى عَلَى التَّمَامِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ أَنَا النَّبِيُّ حَقًّا لَا كَذِبْ\nالْمُصْطَفَى أَنَا ابْنُ عَبْدِ الْمُطَّلِبْ', ['أَلْقَى عَلَيْهِمُ الْحَصَى فَشَاهَتْ', 'أَوْصَاهُمُ بِصِلَةِ الْأَرْحَامِ', 'فَمَضَى إِلَى بَيْتِ الْكَرِيمَةِ آمِنَة', 'فِي أَرْضِ نَجْدٍ قَصْدُهُمْ إِغَارَةْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَعَذَّبَ الْكُفَّارَ مِنْ ........', ['لِلنَّبِيِّ', 'لَدُنْهُ', 'لِأَنَّهَا', 'لِبَيْتِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'إِلَى حُنَيْنٍ لِهَوَازِنَ الَّتِي\nتَجَمَّعَتْ لِلْغَزْوِ وَالْإِغَارَة', ['وَأَرْسَلَ الْكُتُبَ لِلْمُلُوكِ', 'لُقِّبَ بِالفَارُوقِ لَمَّا أَعلَنَا', 'وَلَمْ أَجِدْ كَمِثْلِهِ فِي النَّسَبِ', 'وَمَعَهَا ثَقِيفُ وَالْكَثِيرُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَنْزَلَ اللهُ جُنُودًا مِنْهُ', ['وَعَذَّبَ الْكُفَّارَ مِنْ لَدُنْهُ', 'وَمَعَهُمْ خَمْسِينَ ثُمَّ أَنْبَأَهُ', 'إِحْدَى وَعِشْرِينَ كَمَا الْأَخْبَارِ', 'الْحِمْيَرِيَّ قَدْ بَنَى إِذْ سَمِعَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحَوْلَهُ جَمْعٌ مِنَ الصَّحْبِ الْكِرَامْ', ['فَأَنْزَلَ السَّكِينَةَ الْمَوْلَى السَّلَامْ', 'بَلْ هَرَبُوا مِنْ سَطْوَةِ الجَلَالْ', 'وَتُقْسَمُ الذَّرَارِي وَالْأَمْوَالُ', 'يَدْعو إِلى اتِّباعِهِ يَقولْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تَجَمَّعَتْ لِلْغَزْوِ وَالْإِغَارَة', ['بِالْقُرْبِ مِنْ مَكَّةَ بِالْغَمِيمِ', 'وَالنَّضْرِ بَعْدَ ذَلِكَ كِنَانَةُ', 'إِلَى حُنَيْنٍ لِهَوَازِنَ الَّتِي', 'هَذَا عَلَى الأَغْلَبِ وَالعُمُومِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَانُوا ثَلَاثِينَ ........ مَعَهُمْ', ['أَيَّامَا', 'الْأَنْصَارِ', 'الْيَوْمِ', 'أُلُوفًا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ اللهُ نَصْرًا كَانَا', ['نَعَمْ', 'نَجْرَانَ', 'نَدِمُوا', 'نَصَرَهُمُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقُسِّمَتْ ........ حَكِيمَة', ['بَيْعَةُ', 'بَعْثَةِ', 'بِقِسْمَةٍ', 'بَابَهُ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهَا دَخَلَ فِي الْإِسْلَامِ', ['فَشَاعَ مَا رَأَتْهُ بِالتَّرْدِيدِ', 'أُعْجُوبَةً فَاقْرَأْ أَخِي الْقُرْآنَا', 'فَأَصْبَحَتْ رَمْلًا يَسِيلُ عَجَبَا', 'جَمْعٌ عَظِيمٌ عِنْدَ هَذَا الْعَامِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَ ذَا سَارَ النَّبِيُّ الْمُصْطَفَى\nبِجَيْشِهِ مُجَاهِدًا مُسْتَأْنَفَا', ['قَالَ لَهُمْ مِنْ أَمْرِ رَبِّي إِنَّهَا', 'لَوْ أَنَّهُمْ تَقَاتَلُوا أَصَابُوا', 'إِلَى حُنَيْنٍ لِهَوَازِنَ الَّتِي', 'غَزَا بَنِي مُحَارِبٍ فِي نَجْدِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَفَرَّ جَيْشُ الْمُصْطَفَى سِوَاهُ\nثَبَّتَهُ الرَّحْمَنُ مِنْ عُلَاهُ', ['ثُمَّ أَتَى يَنْظُرُ جَيْشَ الْمُصْطَفَى', 'وَحَوْلَهُ جَمْعٌ مِنَ الصَّحْبِ الْكِرَامْ', 'يَحْدو بِصَوْتٍ يَأْخُذُ الأَلْبابا', 'وَما خَلَقْتُ أَحَداً أَكْرَمَ مِنْك'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'سَارُوا لَهُ بِالْمَالِ وَالْأَبْنَاءِ', ['مَعَ الْجُيُوشِ دُونَمَا إِبْطَاءِ', 'لَكِنْ عَفَا اللَّهُ عَنِ الْأَحْبَابِ', 'مُسْتَبْشِرًا يَهْتَزُّ مِنْ فَرْحَتِهِ', 'كَانَ يُجِلُّ الْمُصْطَفَى وَلَهُ مُحِب'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'الْمُصْطَفَى أَنَا ابْنُ عَبْدِ الْمُطَّلِبْ', ['وَجَمِيعُ مَنْ حَضَرُوا بِبَدْرٍ بُشِّرُوا', 'وَأَرْسَلَ الصَّدِيقَ عَامَ التَّاسِعِ', 'قَالَ أَنَا النَّبِيُّ حَقًّا لَا كَذِبْ', 'فَتَحَدَّثَ العَبَّاسُ لِلوَلِيدِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَلْقَى عَلَيْهِمُ الْحَصَى فَشَاهَتْ', ['وُجُوهُ مَنْ عَادَى النَّبِيْ وَخَابَتْ', 'العِلْمُ أَنَّ اللهَ رَبّي فَضَّلا', 'وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'فَإِنَّهَا آمِنَةٌ حَصِينَةْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَمَعَهَا ........ وَالْكَثِيرُ', ['ثَلَاثٍ', 'ثَانِي', 'ثَمَانٍ', 'ثَقِيفُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَعَادَ جَيْشُ الْمُصْطَفَى إِلَيْهِ\nجَمِيعُهُمْ وَأَقْبَلُوا عَلَيْهِ', ['اجْتَمَعُوا مِنْ حَوْلِهِ يَفْدُونَهُ', 'فَنَقَضُوا لِلْعَهْدِ إِذْ أَسَاؤُوا', 'نَصَرَهُمُ اللهُ نَصْرًا كَانَا', 'لِلْمُصْطَفَى وَصَحْبِهِ الْأَبْرَارِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَخَرَجَ النَّبِيُّ فِي اثْنَيْ عَشَرَا', ['مِنْ رَبِّنَا المَنَّانِ فَهْوَ مُكَرَّمٌ', 'أَلْفًا إِلَيْهِمْ قَائِدًا مُنْتَصِرَا', 'مَعَ الْجُيُوشِ دُونَمَا إِبْطَاءِ', 'حَبِيبُنَا مُكَرَّمًا مُفَضَّلًا'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'فِي سُورَةِ التَّوْبَةِ فَاقْرَأْ وَاعِيَا', ['وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'مُعْتَدِلُ الخَلْقِ سَرِيعُ المِشْيَةِ', 'شَبَهُ وَزَيَّنَهُ الَّذِي أُوحِي لَهُ', 'مَا أَنْزَلَ اللهُ وَكُنْ مُرَاعِيَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَاللَّهُ قَدْ أَرْسَلَهُ رَحِيمًا', ['الْحَقُّ مَنْ لِلْكَوْنِ حَقًّا شَرَّفَا', 'وَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ', 'وَمُحْسِنًا لِخَلْقِهِ كَرِيمًا', 'ثَلَاثَ مَرَّاتٍ وَأَرْضًا أَوْقَعَه'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِقَوْمِهِ وَمُشْفِقًا رَءُوفًا', ['صَلَّى عَلَيْهِ الْمُصْطَفَى مُؤَلِّفًا', 'وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا', 'وَاتَّفَقُوا عَلَى الَّذِي سَيَدْخُلُ', 'بِمَوْتِهِ دَوْماً لِعامِ الفيلِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَسْبَابَ تَنْزِيلٍ وَفِيمَنْ نَزَلَتْ', ['وَمَا عَنِ الْمُنَافِقِينَ قَدْ أَتَتْ', 'لِمَكَّةَ فِي عَدَدٍ كَبِيرِ', 'حِصَارُهُمْ كَانَ عَلَى التَّوَالِي', 'وَبِفَتْحِ مَكَّةَ أَعْلَنَ الْإِسْلَامْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَحُجُّ ........ لِخَيْرِ جَامِعِ', ['بِالنَّاسِ', 'بِبَدْرٍ', 'بِثُلُثِ', 'بِالْأَنْبِيَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهَا الطَّائِفُ ثُمَّ بَعْدَهَا', ['بِالعَفْوِ وَالغُفْرَانِ مَهْمَا يَفْعَلُوا', 'وَقَالَ أَرْجُو أَنْ يَكُونَ خَيْرًا', 'رَواهُ ابنُ عَساكِرَ مُعَلِّما', 'تَبُوكُ وَالْآيَاتُ تَحْكِي مَا بِهَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'قَمِيصَهُ يُلْبِسُهُ لِأَبِيه', ['لِيَسْمَعُوا كَلَامَهُ الْعَجِيبَا', 'يَسَّرَهُ اللهُ فَنَالَ الْيُسْرَى', 'فَلَيْسَ فِيهَا مِنْ شَرَابٍ يُطْلَبُ', 'فَسَأَلَ النَّبِيَّ أَنْ يُعْطِيه'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'قَالَ لَهُ بَلْ أَنْتَ عَبْدُاللَّهْ\nحُبَابُ لِلشَّيْطَانِ لَا نَرْضَاهْ', ['فَسَأَلَ النَّبِيَّ أَنْ يُعْطِيه', 'خَمْسًا وَعِشْرِينَ مِنَ اللَّيَالِي', 'يَوْمَ التَقَى الجَمْعَانِ أَهْلُ الإِيمَانِ', 'أَتَاهُ آتٍ فِي الْمَنَامِ قَالَ لَهْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ نَجْلُ عَبْدِاللَّهِ بْنِ أَبَيْ', ['أَيْضًا بِهَذَا الْعَامِ لِلنَّبِيْ', 'فِي الْكُتُبِ الصَّحِيحَةِ الْمُسَطَّرَة', 'أُمُّ الْبَتُولِ الطَّاهِرَةْ الْحَبِيبَةِ', 'شَقًّا لِبَدْرٍ فِي السَّمَاءِ مُعْلِنَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِالْبَيْتِ إِذْ لَا تُعْبَدُ الْأَوْثَانُ', ['يَدْعو إِلى البِرِّ وَلِلْأَخْلاقِ', 'لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'رَدَمَهَا عَمْرٌو وَفَرَّ لِلْيَمَن', 'أَلَّا يَطُوفَ بَعْدَ ذَا عُرْيَانُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَهُ فَجَاءَتِ الْآيَاتُ مُخْبِرَة', ['وَغَيْرُهُ كَانَ إِلَيْهِمْ يَذْهَبُ', 'أَلْقَى عَلَيْهِمْ هَذِهِ الْحِجَارَةْ', 'وَزَادَ عَنْ سَبْعِينَ يَرْجُو الْمَغْفِرَة', 'وَهَزِيمَةُ الكُفَّارِ قَدْ عَرَفَتْ بِهَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'سَأَلَهُ عَنْ اسْمِهِ أَجَابَ\nبِأَنَّهُ قَدْ سُمِّيَ الْحُبَابَ', ['فَنَالَ ذَا فِي زَمَنِ الفَارُوقِ', 'لِخَيْبَرَ حَيْثُ هُنَاكَ الْكَاهِنَة', 'قَالَ لَهُ بَلْ أَنْتَ عَبْدُاللَّهْ', 'لَمَّا رَأَى مِنْ خُلُقِ الْحَبِيبْ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَتْلُو عَلَيْهِمْ ........ الْبَرَاءِ', ['سُورَةَ', 'سَقَاهُ', 'سَيِّدُ', 'سُفْيَانْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فِي سُورَةِ التَّوْبَةِ فَاقْرَأْ وَاعِيَا\nمَا أَنْزَلَ اللهُ وَكُنْ مُرَاعِيَا', ['أَسْبَابَ تَنْزِيلٍ وَفِيمَنْ نَزَلَتْ', 'لَمْ يَجِدُوا فِي بَيْتِهَا طَعَامَا', 'فَإِنَّهُ هُوَ الَّذِي قَدْ بَشَّرَا', 'أَلْقَى عَلَيْهِمُ الْحَصَى فَشَاهَتْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'لَهُ فَجَاءَتِ ........ مُخْبِرَة', ['الأَسْعَدِ', 'الْجُمُعَةَ', 'الْآيَاتُ', 'الْأَذَى'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حُبَابُ لِلشَّيْطَانِ لَا نَرْضَاهْ', ['قَالَ لَهُ بَلْ أَنْتَ عَبْدُاللَّهْ', 'فَاقْتَتَلُوا أَرْبَعَةَ أَيَّامَا', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'لَمْ يَتَزَوَّجْ مَعَهَا سِوَاهَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَبِعَهُ الْكَرَّارُ بِالْقَصْوَاءِ', ['يَتْلُو عَلَيْهِمْ سُورَةَ الْبَرَاءِ', 'لَهَا عَلَى أَرْبَعِ مِئَاتِ فِضَّة', 'وَبِفَتْحِ مَكَّةَ أَعْلَنَ الْإِسْلَامْ', 'وَقَاطَعُوا لِلْأُسْرَةِ الشَّرِيفَة'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِأَنَّهُ قَدْ سُمِّيَ الْحُبَابَ', ['وَوَاصِلًا لِلضَّيْفِ وَالأَرْحَامِ', 'وَبَعْدَها بِمَوْتِ عَبْدِ المُطَّلِب', 'وَنَبَعَ الْمَا مِنْ بَيْنِ الْأَصَابِعِ', 'سَأَلَهُ عَنْ اسْمِهِ أَجَابَ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ يُلْبِسُهُ لِأَبِيه', ['قالَهُ', 'قَمِيصَهُ', 'قَلْبِ', 'قائِلا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَاللَّهُ قَدْ أَرْسَلَهُ ........', ['رَأَتْ', 'رَسُولُ', 'رَحِيمًا', 'رَحِيمَة'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَهَا الطَّائِفُ ثُمَّ بَعْدَهَا\nتَبُوكُ وَالْآيَاتُ تَحْكِي مَا بِهَا', ['فَأَجَابَهُ بُرَيْدَةُ فَاسْتَبْشَرَا', 'مِنْ صَبَبٍ كَمَا رَوَى الرِّجَالُ', 'فِي سُورَةِ التَّوْبَةِ فَاقْرَأْ وَاعِيَا', 'صَلّى عَلَيْهِمْ ذو الجَلالِ وَسَلَّما'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَسْبَابَ تَنْزِيلٍ وَفِيمَنْ نَزَلَتْ\nوَمَا عَنِ الْمُنَافِقِينَ قَدْ أَتَتْ', ['فَاجْتَمَعُوا عَلَيْهِ ثُمَّ أَكَلُوا', 'قَصَّتْ عَلَى العَبَّاسِ مَا رَأَتْهُ', 'وَأَرْسَلَ الصَّدِيقَ عَامَ التَّاسِعِ', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'صَلَّى عَلَيْهِ الْمُصْطَفَى ........', ['مَرَّاتٍ', 'مُؤَلِّفًا', 'مُنْزَلَ', 'مَكَانَكُمْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَرْسَلَ الصَّدِيقَ عَامَ التَّاسِعِ', ['نَبِيَّنَا فَنَالَتِ الْمَزِيَّة', 'دِينَكُمُ) فَأَصْلِحُوا مَا بَيْنَكُمْ', 'يَحُجُّ بِالنَّاسِ لِخَيْرِ جَامِعِ', 'وَبِسَيْفِهِ العَضْبِ تَقَلَّدَهُ الرَّسُول'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَلَّا يَطُوفَ بَعْدَ ذَا ........', ['عَادَ', 'عَمَّارْ', 'عَلَّمَ', 'عُرْيَانُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَ نَجْلُ عَبْدِاللَّهِ بْنِ أَبَيْ\nأَيْضًا بِهَذَا الْعَامِ لِلنَّبِيْ', ['وَأَرَاهُمُ مَصَارِعَ الأَقْوَامِ', 'سَأَلَهُ عَنْ اسْمِهِ أَجَابَ', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'وَانْطَلَقَ النَّبِيُّ نَحْوَ طَيْبَة'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَزَادَ عَنْ سَبْعِينَ يَرْجُو الْمَغْفِرَة', ['لِصِدْقِ مَا رَآهُ مِنْ وِلَائِهِمْ', 'لَهُ فَجَاءَتِ الْآيَاتُ مُخْبِرَة', 'عُتْبَةَ مَنْ آذَاهُ يَقْتُلُونَا', 'ثُمَّ الزَّوَاجُ كَانَ فِي ذِي الْحِجَّةِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَسَأَلَ النَّبِيَّ أَنْ يُعْطِيه', ['خَدِيجَةُ مِنْ قَلْبِهِ قَرِيبَةُ', 'فِي سُورَةِ الأَنْفَالِ بِالفُرْقَانِ', 'إِذَا بِهِمْ مَعَ عِلْمِهِمْ كُفَّارُ', 'قَمِيصَهُ يُلْبِسُهُ لِأَبِيه'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حُبَابُ لِلشَّيْطَانِ لَا ........', ['نَاصِرًا', 'نَرْضَاهْ', 'نِقْمَةِ', 'نَدَاهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَا عَنِ الْمُنَافِقِينَ قَدْ أَتَتْ', ['مَعَ أَنَّهُمْ لَاقَوْهُ بِالإِيذَاءِ', 'أَسْبَابَ تَنْزِيلٍ وَفِيمَنْ نَزَلَتْ', 'وَغَيْرُ ذَا وَقَائِعُ كَثِيرَةْ', 'فيها المَغازي وَكَذا أَيّامُهُ'], 1),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'دَعَاهُمُ النَّبِيُّ لِلْمُبَاهَلَةْ', ['وَقَدْ أَتَوْا فِي سَيْرِهِمْ أَيَّامَا', 'لَكِنَّهُمْ عَادُوا إِلَى الْمُصَالَحَةْ', 'وَلَا يَقِلُّ وَلَيْسَ يُلْحَقُ قَعْرُهَا', 'لَمَّا طَغَوْا عَلَيْهِمُ بِبَغْيِهِمْ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَتِ الْوُفُودُ لِلْمَدِينَةْ\nكَوَفْدِ نَجْرَانَ يُجَادِلُونَهْ', ['وَلَمْ يَكُنْ بِالبَادِنِ المُطَهَّمْ', 'نَبِيُّنَا وَإسْمُهُ مُحَمَّدٌ', 'هَيْئَتُهُ فِي الْحُسْنِ وَالْبَهَاءِ', 'عَنِ الْمَسِيحِ عِيسَى إِذْ يَقُولُ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ دَعْوَةِ النَّبِيِّ قَدْ خَافُوا عَلَى', ['لَمَّا دَعَاهُم لِلهُدَى وَأَيْقَنُوا', 'أَقْوَامِهِمْ وَالْأَرْضِ أَنْ تُسْتَأْصَلَا', 'عَنْ غَيْرِهِ مَوْلَاهُ قَدْ فَضَّلَهُ', 'مَعَ أَنَّهُمْ بِكِتَابِهِمْ يَجِدُونَهَا'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', '(كَمَثَلِ آدَمَ) إِذْ أَشَارَتْ', ['وَاللهِ لَوْ لَا أَنْتَ مَا اهْتَدَيْنَا', '(مَثَلُ عِيسَى عِنْدَ اللَّهِ) جَاءَتْ', 'يُؤْذِي رَسُولَ اللَّهِ بِالْأَشْعَارِ', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْكُتُبَ لِلْمُلُوكِ', ['وَغَيْرُهَا', 'وَشَافِعٌ', 'وَأَرْسَلَ', 'وَكُلُّ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَابْنُ ........ كَعْبُ بِالْأَشْعَارِ', ['زَوْجَ', 'زَوْجَهَا', 'زِيَادَةِ', 'زُهَيْرٍ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَكَيْفَ يُحْيِي الْمَوْتَى ثُمَّ يُبْرِأُ الْـ\nأَكْمَهَ وَالْأَبْرَصَ ذَا فِعْلٌ أَجَلْ', ['فَهَلْ رَأَيْتَ مِثْلَهُ مِنْ أَحَدٍ', 'فَشَرِبُوا جَمِيعُهُمْ مِنَ اللَّبَن', 'فَعَادَ عَمُّهُ بِهِ سَرِيعًا', 'وَبَعْدَ ذَاكَ بَدْرٌ الأَخِيرَةْ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'عَنِ الْمَسِيحِ عِيسَى إِذْ يَقُولُ\nبِأَنَّهُ عَبْدٌ فَهَلْ دَلِيلُ', ['فَأَجَابَهُ الصِّدِّيقُ إِنِّي إِنَّمَا', 'فَكَيْفَ يُحْيِي الْمَوْتَى ثُمَّ يُبْرِأُ الْـ', 'هُوَ ضَمْضَمُ بْنُ عَمْرٍو الغِفَارِي', 'لِلصُّلْحِ فِي مَا بَيْنَهُمْ فَتَمَّ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَلَقَهُ الرَّحْمَنُ مِنْ ........', ['تَزُورُ', 'تُرَابِ', 'تُشْفى', 'تَطْلُبُهُمْ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَجَاءَهُ الْوَحْيُ بِقَوْلِ الْوَاحِدِ', ['سَارَ لَهُمْ فِي عَشَرَةِ آلَافِ', 'فَهَلْ رَأَيْتَ مِثْلَهُ مِنْ أَحَدٍ', 'يُعْطُونَهُ وَلَدًا لَهُمُ مَكَانَهْ', 'وَيَنْبَغي قَبْلَ الشُّروعِ أوَّلاً'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ دَعْوَةِ النَّبِيِّ قَدْ خَافُوا عَلَى\nأَقْوَامِهِمْ وَالْأَرْضِ أَنْ تُسْتَأْصَلَا', ['عَقَدَ اللِّوَاءَ الأَبْيَضَ لِمُصْعَبَا', 'وَظَهَرَتْ مَحَبَّةُ الصَّحَابَةِ', 'مِنْ بَعْدِ تِلْكَ الْحَرْبِ كُلُّ الْقَوْمِ', 'وَبَعْدَهُمْ وَفْدُ تَمِيمٍ الدَّارِي'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَلَقَهُ الرَّحْمَنُ مِنْ تُرَابِ', ['بِقَوْلِ كُنْ كَانَ بِلَا ارْتِيَابِ', 'قَالُوا أَخُونَا صَادِقٌ كَرِيمُ', 'فَانْطَلَقُوا لِلْبَيْتِ فِي سَلَامِ', 'لِلْبَدْرِ فَانْشَقَّ لَهُمْ لِنِصْفِهِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَجَاءَهُ الْوَحْيُ ........ الْوَاحِدِ', ['بِالحَقِّ', 'بِأَحْمَدَ', 'بِقَوْلِ', 'بِرَبِّ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'بِأَنَّهُ عَبْدٌ فَهَلْ دَلِيلُ', ['عَنِ الْمَسِيحِ عِيسَى إِذْ يَقُولُ', 'وَكَانَ كَعْبٌ أَقْصِدُ ابْنَ الْأَشْرَف', 'وَكَتَبَتْ قُرَيْشٌ الصَّحِيفَة', 'وَكَانَ هَذَا فِي تَمَامِ عُمُرِهِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَكْمَهَ وَالْأَبْرَصَ ذَا فِعْلٌ أَجَلْ', ['لَكِنْ شَفَاهُ اللهُ مِمَّا لَاقَى', 'مَوْلِدُهُ مِيلَادُ كُلِّ الْبُشْرَيَات', 'فَكَيْفَ يُحْيِي الْمَوْتَى ثُمَّ يُبْرِأُ الْـ', 'نَصَرَهُمُ اللهُ نَصْرًا كَانَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'دَعَاهُمُ النَّبِيُّ لِلْمُبَاهَلَةْ\nلَكِنَّهُمْ عَادُوا إِلَى الْمُصَالَحَةْ', ['وَمَعَهُنَّ خَرَجَتِ النِّسَاءُ', 'مِنْ دَعْوَةِ النَّبِيِّ قَدْ خَافُوا عَلَى', 'وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا', 'فِي آلِ عِمْرَانَ بِقَوْلِ اللَّهِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَأَرْسَلَ الْكُتُبَ لِلْمُلُوكِ', ['صِدِّيقُهُ كَذَا الْفَارُوقُ بَعْدَهُ', 'وَمِنْ فُؤَادِ الْمُصْطَفَى قَرِيبَةُ', 'وَاللهُ مِنْ أَنْوَارِهِ طَرَّزَهَا', 'مَخْتُومَةً بِالْخَاتَمِ الْمَبْرُوكِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '(مَثَلُ ........ عِنْدَ اللَّهِ) جَاءَتْ', ['عِمْرَانَ', 'عَظِيمًا', 'عِيدُوا', 'عِيسَى'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَبَعْدَهُمْ وَفْدُ تَمِيمٍ الدَّارِي', ['وَابْنُ زُهَيْرٍ كَعْبُ بِالْأَشْعَارِ', 'وَالْبِرِّ وَالْمَعْرُوفِ وَالْإِسْلَامِ', 'لِصَحْبِهِ امْضُوا عَلَى إِسْمِ اللهِ', 'مَا قَالَهُ حَبِيبُنَا العَدْنَانْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَوَفْدِ نَجْرَانَ يُجَادِلُونَهْ', ['فَرِحَ أَبوهُ وَأَطْعَمَ الطَّعامَا', 'وَوَضَعُوا الصُّخُورَ فَوْقَ صَدْرِهِ', 'وَجَاءَتِ الْوُفُودُ لِلْمَدِينَةْ', 'أَخَذَهُ مَعْهُ لِأَرْضِ الشّامِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَبَعْدَهُمْ وَفْدُ تَمِيمٍ الدَّارِي\nوَابْنُ زُهَيْرٍ كَعْبُ بِالْأَشْعَارِ', ['وَقَبْرُهُ الكَريمُ بِالرَّوْحاءِ', 'وَأَرْسَلَ الْكُتُبَ لِلْمُلُوكِ', 'مَكَانُهُ مَا بَيْنَ فَرْثٍ وَدَمِ', 'دَعَاهُمُ لِلصُّلْحِ فِيهَا عُتْبَة'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَنِ الْمَسِيحِ ........ إِذْ يَقُولُ', ['عَزَفَا', 'عِيسَى', 'عَلَا', 'عَشَرَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَكَيْفَ ........ الْمَوْتَى ثُمَّ يُبْرِأُ الْـ', ['يُلَبّي', 'يُحْيِي', 'يُلْقُوا', 'يُهْلَكُوا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَلَقَهُ الرَّحْمَنُ مِنْ تُرَابِ\nبِقَوْلِ كُنْ كَانَ بِلَا ارْتِيَابِ', ['كَانُوا ثَلَاثِينَ أُلُوفًا مَعَهُمْ', 'دَعَاهُمُ النَّبِيُّ لِلْمُبَاهَلَةْ', 'بَشَّرَهُمْ خَيْرُ الوَرَى مَا وَعَدَهْ', 'مِنْ بَعْدِ ذَا نَشْرَعُ فِي الْمَقْصُودِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'كَوَفْدِ نَجْرَانَ ........', ['يَشْتَكُونَا', 'يُلاَقُوا', 'يَقْتُلُونَا', 'يُجَادِلُونَهْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَهَلْ رَأَيْتَ مِثْلَهُ مِنْ أَحَدٍ', ['فَجَاءَهُ الْوَحْيُ بِقَوْلِ الْوَاحِدِ', 'فَإِنَّهُ الْمُطَهَّرُ الْمَقْبُولُ', 'كَانَ أَبُو بَكْرٍ بِلَا أَدْنَى جِدَالْ', 'لِأَنَّ مِنْهُمُ رَسولَهُ الأَحَبّ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَقْوَامِهِمْ وَالْأَرْضِ أَنْ تُسْتَأْصَلَا', ['مِنْ دَعْوَةِ النَّبِيِّ قَدْ خَافُوا عَلَى', 'وَابْنُ سَلُولٍ عَادَ بِالْمُنَافِقِينْ', 'فَجَدُّهُ شِيثٌ كَذَا إِدْرِيسُ', 'ثَلَاثَ مَرَّاتٍ يَقُولُ مَا أَنَا'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لَكِنَّهُمْ عَادُوا إِلَى الْمُصَالَحَةْ', ['دَعَاهُمُ النَّبِيُّ لِلْمُبَاهَلَةْ', 'حِينَ أَشَاعُوا أَنَّهُ قَدْ قُتِلَا', 'لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'وَكُلُّ هَذَا لَيْسَ مِنْ كَلَامِهِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', '(مَثَلُ عِيسَى عِنْدَ اللَّهِ) جَاءَتْ', ['(كَمَثَلِ آدَمَ) إِذْ أَشَارَتْ', 'وَيَدَيْهِ تَصْدِيقًا بِمَا لَدَيْهِ', 'يَا سَعْدَنَا بِمَوْلِدِ الْمُخْتَارِ', 'بَدَتْ فِيهِ الْآيَاتُ بَلْ وَالْمُعْجِزَات'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مَخْتُومَةً بِالْخَاتَمِ ........', ['الْمُخْتَارِ', 'الحُسْنِ', 'الوَفَاءِ', 'الْمَبْرُوكِ'], 3),
  ],
  <PoemQ>[
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فَاشْهَدْ أَنَّنِي بَلَّغْتُ', ['يَارَبِّ', 'يَوْمٍ', 'يُجْلِسُهُ', 'يُجِيبَكُمْ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحِجَّةُ الْوَدَاعِ عَامَ عَشْرِ', ['أَكْرِمْ بِهَذَا النَّسَبِ الْإِيمَانِي', 'حَجَّ الْحَبِيبُ مُكَمِّلًا لِلْأَمْرِ', 'وَفِي الْجَحِيمِ يَلْقَ مَا أَتَاهُ', 'لَبَنُهَا قَالَ أَنَا أَمِينُهَا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَنَزَلَتْ (الْيَوْمَ أَكْمَلْتُ لَكُمْ', ['لِأَنَّ ذَاكَ عَادَةُ اليَهُودْ', 'في قَوْمِهِ ذو عِزَّةٍ كَبيرَةِ', 'دِينَكُمُ) فَأَصْلِحُوا مَا بَيْنَكُمْ', 'فِي عَامِ سِتٍّ بَعْدَ عَامِ الْهِجْرَةِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالْبِرِّ وَالْمَعْرُوفِ وَالْإِسْلَامِ', ['أَوْصَاهُمُ بِصِلَةِ الْأَرْحَامِ', 'وَجَاءَهُ جِبْرِيلُ شَقَّ صَدْرَهُ', 'خَرَجَ النَّبِيُّ بِدِرْعِهِ ذَاتِ الفُضُول', 'وَاسْتَقْبَلُوهُ فِي السَّمَاءِ الْأُولَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَذَّرَهُمْ مِنَ ........ وَالظُّلْمِ', ['الدِّرْعُ', 'الأَمْثالِ', 'الهادي', 'الرِّبَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ بِالْحَقِّ وَالْيَقِينِ', ['جِبْريلَ', 'جَمالُهُ', 'جَمِيعُهُمْ', 'جَهْلَهَا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'إِلَّا بِحَقِّ اللَّهِ ........', ['فَذِكْرُهُمْ', 'فَهَدَاهُ', 'فَالْجَزَاءْ', 'فُؤَادِي'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُوصِيًا أُمَّتَهُ بِالْيُسْرِ', ['وَابْنُ زُهَيْرٍ كَعْبُ بِالْأَشْعَارِ', 'وَتُقْسَمُ الذَّرَارِي وَالْأَمْوَالُ', 'نورُ النَّبِيِّ في العُيونِ لامِعَا', 'مُوَدِّعًا مُحَذِّرًا مِنْ كُفْرِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'أَوْصَاهُمُ بِصِلَةِ ........', ['أَخْبَارِهِمْ', 'الْأَرْحَامِ', 'الخَلْقِ', 'البَرَاءِ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحِجَّةُ الْوَدَاعِ عَامَ عَشْرِ\nحَجَّ الْحَبِيبُ مُكَمِّلًا لِلْأَمْرِ', ['قَالَ أَبُو بَكْرٍ قَصَدْتُ الْبَيْتَ', 'مُوصِيًا أُمَّتَهُ بِالْيُسْرِ', 'وَأَسَدُ اللهِ كَذَا رَسُولِهِ', 'الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'حَذَّرَهُمْ مِنَ الرِّبَا وَالظُّلْمِ', ['وَبِها بُلوغُ مَراتِبِ الإِحْسانِ', 'وَجَاءَتِ الْوُفُودُ لِلْهَادِي الْأَحَبْ', 'وَبَثَّ فِيهِمْ نُورَهُ بِالْعِلْمِ', 'عَلَيْهِ نُورٌ سَاطِعٌ وَهَيْبَة'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُوصِيًا أُمَّتَهُ بِالْيُسْرِ\nمُوَدِّعًا مُحَذِّرًا مِنْ كُفْرِ', ['وَأَزْهَرُ اللَّوْنِ جَمِيلٌ سَاطِعُ', 'وَنَزَلَتْ (الْيَوْمَ أَكْمَلْتُ لَكُمْ', 'تَجَاوَزَ السَّبْعَ الطِّبَاقَ كُلَّهَا', 'أَوَّلُهُمْ رُقَيَّةُ وَزَوْجُهَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَنَزَلَتْ (الْيَوْمَ أَكْمَلْتُ لَكُمْ\nدِينَكُمُ) فَأَصْلِحُوا مَا بَيْنَكُمْ', ['وَقَدْ رَأَى النَّبِيُّ فِي الْمَنَامِ', 'وَامْتَنَّ رَبُّ العَالَمِينَ بِنَصْرِهِ', 'الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ', 'هِيَ نورُ خَيْرِ الخَلْقِ طَهَ المُصْطَفى'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَحَرَّمَ الْحُقُوقَ وَالدِّمَاءْ', ['إِلَّا بِحَقِّ اللَّهِ فَالْجَزَاءْ', 'وَأَعَادَهَا الشَّرِيفُ جَدُّ الْمُؤْتَمَن', 'وَمُشْرِقٌ كَالشَّمْسِ فِي النَّهَارْ', 'لِذِي أَمْرٍ فَنَزَلَتِ الْأَمْطَارُ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ', ['وَالْحَاشِرُ الْمَاحِي فَجَلَّ الْوَاهِبُ', 'يُحَكِمُوهَا فِي الْأُمُورِ الرَّاهِنَة', 'جَمِيعُهُمْ بِالْحَقِّ وَالْيَقِينِ', 'شِيَاهَهُ رَأَى ذِئْبًا فَدَفَعَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'يَارَبِّ فَاشْهَدْ أَنَّنِي بَلَّغْتُ', ['وَلَوْ عَبَدْنَا غَيْرَهُ شَقِينَا', 'وَكَمْ تَكُونُ بِقِيمَةِ الْأَمْوَالِ', 'وَبِها بُلوغُ مَراتِبِ الإِحْسانِ', 'وَبِالْهُدَى وَالْحَقِّ قَدْ وَصَّيْتُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'حَذَّرَهُمْ مِنَ الرِّبَا وَالظُّلْمِ\nوَبَثَّ فِيهِمْ نُورَهُ بِالْعِلْمِ', ['يَدْعُو إِلَى التَّوْحِيدِ وَالْإِسْلَامِ', 'وَوَصَفَتْ لَهُ النَّبِيَّ المُصْطَفَى', 'بَاتَ عَلِيٌّ فِي فِرَاشِ الهَادِي', 'وَحَرَّمَ الْحُقُوقَ وَالدِّمَاءْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَوْصَاهُمُ بِصِلَةِ الْأَرْحَامِ', ['لَا تَحْزَنَنْ وَلَا تَضِقْ كُنْ مُحْسِنَا', 'مِنَ الْيَهُودِ حِينَهَا أَبَاهُ', 'وَالْبِرِّ وَالْمَعْرُوفِ وَالْإِسْلَامِ', 'عَنْ آدَمَ رَأى اسْمَهُ مُنَوَّرا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَحَرَّمَ الْحُقُوقَ وَالدِّمَاءْ\nإِلَّا بِحَقِّ اللَّهِ فَالْجَزَاءْ', ['دَخَلَهَا الْحَبِيبُ فِي تَوَاضُعِ', 'يَارَبِّ فَاشْهَدْ أَنَّنِي بَلَّغْتُ', 'وَجَاءَهُمْ إِبْلِيسُ وَقَالَ لَهُمْ', 'وَرَدَّ اللهُ كَيْدَ أَهْلِ الكُفْرِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'دِينَكُمُ) فَأَصْلِحُوا مَا بَيْنَكُمْ', ['مَعَ النَّبِيِّ وَأَبِيهِ الطَّاهِرِ', 'وَنَزَلَتْ (الْيَوْمَ أَكْمَلْتُ لَكُمْ', 'سَارَ بِخَيْلِهِ إِلَى الصَّحْرَاءِ', 'وَبَعدَ الاولَى أَسلَمَ الفَارُوقُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'يَارَبِّ فَاشْهَدْ أَنَّنِي ........', ['بَكَى', 'بِذَلِكَ', 'بَلَّغْتُ', 'بِآيَاتِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُوَدِّعًا مُحَذِّرًا مِنْ كُفْرِ', ['مُوصِيًا أُمَّتَهُ بِالْيُسْرِ', 'كَمَا أَتَتْ فِي كُتُبِ الشَّمَائِلْ', 'اجْتَمَعَ النَّاسُ بِدَارِ النَّدْوَةِ', 'حَبَسَهَا هُنَا حَابِسُ الْفِيلِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَجَّ الْحَبِيبُ مُكَمِّلًا لِلْأَمْرِ', ['فِي يَوْمِ الْأَرْبِعَاءِ مِنْ شَوَّالٍ', 'أَنَّ النَّبِيَّ المُصْطَفى قَدْ أَخْبرا', 'أَمَرَهُ اللَّهُ بِأَنْ يُزَوِّجَه', 'وَحِجَّةُ الْوَدَاعِ عَامَ عَشْرِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ\nجَمِيعُهُمْ بِالْحَقِّ وَالْيَقِينِ', ['بِأَنَّ جَيْشَ خَالِدٍ وَعِكْرِمَة', 'سَارَ إِلَيْهِمْ مَعَهُ أَرْبَعُمِائَةْ', 'فَتَكَلَّمَ الأَصْحَابُ حَتَّى سَرَّهُ', 'أَوْصَاهُمُ بِصِلَةِ الْأَرْحَامِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَنَزَلَتْ (الْيَوْمَ ........ لَكُمْ', ['أَكْمَلْتُ', 'الْعَامِرِي', 'الإِقَامَةِ', 'آمِنَة'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أُمَّتَهُ بِالْيُسْرِ', ['مَكَّةَ', 'مِرَا', 'مُوصِيًا', 'مُتَّفَقْ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَوْصَاهُمُ بِصِلَةِ الْأَرْحَامِ\nوَالْبِرِّ وَالْمَعْرُوفِ وَالْإِسْلَامِ', ['نِصْفٌ عَلَا وَنِصْفٌ مِنْهُ نَزَلَا', 'حَذَّرَهُمْ مِنَ الرِّبَا وَالظُّلْمِ', 'لَكِنْ بِرِيقِ المُصْطَفَى شَفَاهُ', 'صَلَّى عَلَيْكَ اللَّهُ يَا حَبِيبِي'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَحِجَّةُ ........ عَامَ عَشْرِ', ['الْوَدَاعِ', 'إِيمَانَهُ', 'أَعْلَى', 'أَتَاهُمُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَثَّ فِيهِمْ نُورَهُ بِالْعِلْمِ', ['وَأَلَّفَ اللَّهُ بِهِ الْقُلُوبَا', 'وَكانَ خَيْرَ أَهْلِ ذا الزَّمانِ', 'إِلَى حُنَيْنٍ لِهَوَازِنَ الَّتِي', 'حَذَّرَهُمْ مِنَ الرِّبَا وَالظُّلْمِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'جَمِيعُهُمْ بِالْحَقِّ وَالْيَقِينِ', ['كَمَا أَتَى فِي آلِ عِمْرَانَ وَإِذْ', 'الْمُسْلِمُونَ إِخْوَةٌ فِي الدِّينِ', 'وَلَمْ يَزَلْ يَقُولُ كُلَّ حِينٍ', 'صَدًّا عَنِ الدِّينِ الحَنِيفِ يُنْفِقُون'], 1),
  ],
  <PoemQ>[
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'فَاخْتَارَ أَنْ يَكُونَ فِي جِوَارِ\nرَفِيقِهِ الْأَعْلَى بِلَا انْتِظَارِ', ['مِنْ بَعْدِ حَجَّةِ الْوَدَاعِ انْتَقَلَا', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا', 'مُدْرِكَةُ سُمِّي بِذا إِذْ أَدْرَكا', 'سَمَّى بِبِسْمِ اللهِ ثُمَّ ضَرَبَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَخُيِّرَ الْحَبِيبُ مَا بَيْنَ ........', ['الأُلَى', 'الْكَثِيرُ', 'أُنْزِلَا', 'الْبَقَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مِنْ بَعْدِ حَجَّةِ الْوَدَاعِ انْتَقَلَا', ['بِإِذْنِهِ وَسِرِّهِ تَكَلَّمِ', 'وَقَدْ كَفَاكُمْ رَبُّنَا النِّيرَانَا', 'حَبِيبُنَا مُكَرَّمًا مُفَضَّلًا', 'وَمِنْ أَذى الوِسْوَاسِ الخَنّاسِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَخُيِّرَ الْحَبِيبُ مَا بَيْنَ الْبَقَا', ['مَنْ وَصَفَتْ جَمَالَ خَيْرِ سَيِّدِ', 'أَتَوْا لَهُمْ مِنْ كَافَّةِ الْأَنْحَاءِ', 'خَمْسِينَ فَرْضًا فِي ابْتِدَاءِ فَرْضِهَا', 'فِي هَذِهِ الدُّنْيَا وَمَا بَيْنَ اللِّقَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَبِيبُنَا مُكَرَّمًا ........', ['مِئَاتِ', 'مِنْهُ', 'مَدَى', 'مُفَضَّلًا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'رَفِيقِهِ الْأَعْلَى بِلَا انْتِظَارِ', ['وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ', 'لَا تُنْزَفُ أَيْ لَيْسَ يُفْرَغُ مَاؤُهَا', 'فَاخْتَارَ أَنْ يَكُونَ فِي جِوَارِ', 'بَسَطَ فِيهَا رِجْلَهُ وَقَالَا'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَخُيِّرَ الْحَبِيبُ مَا بَيْنَ الْبَقَا\nفِي هَذِهِ الدُّنْيَا وَمَا بَيْنَ اللِّقَا', ['وَانْفَجَرَ الْجُرْحُ وَسَالَ دَمُهُ', 'حَاصَرَهُمْ فِي الدَّارِ حَتَّى اسْتَسْلَمُوا', 'وَأَنْزَلَ اللهُ عَلَيْهِمْ مَطَرًا', 'فَاخْتَارَ أَنْ يَكُونَ فِي جِوَارِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَبِيبُنَا مُكَرَّمًا مُفَضَّلًا', ['وَخَافِضُ الطَّرْفِ نَظَرُهُ إِلَى', 'أَنْتَ الأَحَبُّ لي مِنَ الأَنامِ', 'وَكَانَ فِيهَا أَوَّلُ الجُمُعَاتِ', 'مِنْ بَعْدِ حَجَّةِ الْوَدَاعِ انْتَقَلَا'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَاخْتَارَ أَنْ ........ فِي جِوَارِ', ['يَكُونَ', 'يَدُلُّهُم', 'يَرْجُو', 'يُؤْتِيهِمُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ حَجَّةِ ........ انْتَقَلَا', ['الْوَدَاعِ', 'أَضْمَرُوا', 'اعْتَدَى', 'الحَالِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فِي هَذِهِ الدُّنْيَا وَمَا بَيْنَ اللِّقَا', ['أَخَذَهَا النَّبِيُّ بَعْدَ إِذْنِهَا', 'لَا تَسْأَلُوهُ حَتَّى لَا يُجِيبَكُمْ', 'مُسَاعِدًا أَصْحَابَهُ الكِرَامْ', 'وَخُيِّرَ الْحَبِيبُ مَا بَيْنَ الْبَقَا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'فَاخْتَارَ أَنْ يَكُونَ فِي جِوَارِ', ['إِذَا انْتَصَرْنَا إِلَّا إِنْ أَمَرْتُكُمْ', 'رَفِيقِهِ الْأَعْلَى بِلَا انْتِظَارِ', 'مَعَ أَنَّهُ يَعْرِفُ مِنْ أَخْبَارِهِمْ', 'فَأَقْبَلُوا بِخَالِصِ الْإِذْعَانِ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ ........ الْوَدَاعِ انْتَقَلَا', ['حَيْثُ', 'حَسَدًا', 'حَبِيبًا', 'حَجَّةِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي هَذِهِ ........ وَمَا بَيْنَ اللِّقَا', ['الْقِصَّةَ', 'امْتَدَّ', 'الدُّنْيَا', 'أَسْمَاؤُهُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَفِيقِهِ الْأَعْلَى بِلَا ........', ['اعْتَصِمُوا', 'انْتِظَارِ', 'الْبَيْتِ', 'النُّورَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مِنْ بَعْدِ حَجَّةِ الْوَدَاعِ ........', ['النَّبِي', 'انْتَقَلَا', 'الرَّفِيقُ', 'الْأَجْدَادُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ أَنْ يَكُونَ فِي جِوَارِ', ['فَاخْتَارَ', 'فَإِنَّهَا', 'فَصَدَّقَهْ', 'فَجَهَّزَ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْحَبِيبُ مَا بَيْنَ الْبَقَا', ['وَالشُّكْرُ', 'وَابْتَدَأَ', 'وَخُيِّرَ', 'وَذا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ الْأَعْلَى بِلَا انْتِظَارِ', ['رَحْمَةُ', 'رَبَّنا', 'رَفِيقِهِ', 'رُسْلِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ مُكَرَّمًا مُفَضَّلًا', ['حَبِيبُنَا', 'حَلَقَاتُهُ', 'حِصَارُهُمْ', 'حِينَمَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي هَذِهِ الدُّنْيَا وَمَا بَيْنَ ........', ['اللِّقَا', 'الْأَقْدَاحُ', 'الرِّسَالَةُ', 'الصِّبْيَانِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'حَبِيبُنَا ........ مُفَضَّلًا', ['مُعْجِزَةْ', 'مُكَرَّمًا', 'مَلائِكُ', 'مَعْهُ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَفِيقِهِ ........ بِلَا انْتِظَارِ', ['الْأَعْلَى', 'الشِّرْكُ', 'الرُّعْبَ', 'الْكَرَّارُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَخُيِّرَ الْحَبِيبُ مَا ........ الْبَقَا', ['بِمَنِ', 'بَلَّغْتُ', 'بَيْنَ', 'بِصِدْقِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَاخْتَارَ أَنْ يَكُونَ فِي ........', ['جَهْلَهَا', 'جَمِيعًا', 'جُمُوعُهُمْ', 'جِوَارِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَخُيِّرَ ........ مَا بَيْنَ الْبَقَا', ['أَحْمَدا', 'الْجَزِيلَا', 'الْحَبِيبُ', 'السَّكِينَةَ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'رَفِيقِهِ الْأَعْلَى ........ انْتِظَارِ', ['بِقَتْلٍ', 'بِرِبْحِ', 'بِلَا', 'بِصَخْرَةٍ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي هَذِهِ الدُّنْيَا وَمَا ........ اللِّقَا', ['بَيْنَ', 'بِنْتُ', 'بَادِي', 'بِسْمِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فِي هَذِهِ الدُّنْيَا ........ بَيْنَ اللِّقَا', ['وَبِهِ', 'وَلَمّا', 'وَسَعْدُ', 'وَمَا'], 3),
  ],
  <PoemQ>[
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَنَبَعَ الْمَا مِنْ بَيْنِ الْأَصَابِعِ', ['كَانَ الْخُرُوجَ لِلِقَا الْكُفَّارِ', 'مِنْ رَبِّهِ تَلَقّى لِلْكَلِماتْ', 'أَكْرِمْ بِخَيْرِ مُرْسَلٍ وَشَافِعِ', 'يَا أَهْلَ مَكَّةَ أَجَابُوا الْمُرْسَلَا'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَنَزَلَتْ لَمَّا دَعَا الْأَمْطَارُ', ['فَتَكَلَّمَ الأَصْحَابُ حَتَّى سَرَّهُ', 'لِيُلْبِسُوا البَاطِلَ ثَوْبَ الحَقِّ', 'وَسَلَّمَتْ عَلَى النَّبِيْ الْأَحْجَارُ', 'مِنْ بَعْدِهِ نَسَبُهُ امْتَدَّ إِلَى'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'نَبِيُّنَا الْهَادِي لَهُ شُقَّ الْقَمَرْ', ['وَقَوْلُهُ وَحْيٌ أَتَى وَصِدْقًا', 'وَلَدٍ يُسَاعِدُهُ عَلَى عَيْشِ الزَّمَن', 'كَمَا أَتَى فِي سُورَةٍ هِيَ الْقَمَرْ', 'قَدْ هَاجَرُوا بِدِينِهِمْ نَحْوَ السَّلَامْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'عَجَزَ الْخَلْقُ أَنْ يَأْتُوا بِمِثْلِهِ', ['لِمَا لَهُ مِن شِدَّةٍ مِثلَ الأَسَد', 'بِأَنَّ هَذِهِ هِيَ الْمَدِينَةُ', 'حَيْثُ النُّزُولُ ذَاكَ الرَّأْيُ الْمُعْتَبَرْ', 'وَأَذْعَنُوا بِحُسْنِهِ وَفَضْلِهِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَجَاءَ خَيْرُ الْخَلْقِ بِالْآيَاتِ', ['لِلْبَيْتِ طَائِفًا يَكُونُ الْفَاعِلُ', 'يَا أَهْلَ مَكَّةَ أَجَابُوا الْمُرْسَلَا', 'وَصِفاتُهُ وَوَفاؤُهُ إِقْدامُهُ', 'وَسُمِّيَتْ عَنْهُ بِالْمُعْجِزَاتِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'خَوَارِقَ لِسَائِرِ الْعَادَاتِ\nأَتَى بِهَا لَهُ مُصَدِّقَاتِ', ['لِمَوْضِعِ الْأَقْدَاحِ ثُمَّ قَرِّبُوا', 'نَبِيُّنَا الْهَادِي لَهُ شُقَّ الْقَمَرْ', 'عَفَا رَسُولُ اللهِ عَمَّنْ ظَلَمَا', 'يَغْشَى بِفَضْلِ اللَّهِ مِنْهُمْ طَائِفَةْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَقَوْلُهُ وَحْيٌ أَتَى ........', ['وَالْكُفَّارِ', 'وَالصَّحْبِ', 'وَالْبَهَاءِ', 'وَصِدْقًا'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'أَتَى لَنَا بِالنُّورِ وَالْقُرْآنِ', ['أَشْطَاطَ جَاءَ عِنْدَهُ النَّذِيرْ', 'عَلَيَّ دَوْمًا نَاطِقًا يَتَكَلَّمُ', 'يَمْضِي بِهِ فِي سَائِرِ الْآفَاقِ', 'مُعْجِزَةً عَلَى مَدَى الْأَزْمَانِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَنَبَعَ الْمَا مِنْ بَيْنِ الْأَصَابِعِ\nأَكْرِمْ بِخَيْرِ مُرْسَلٍ وَشَافِعِ', ['دَرَاهِمَ إِذَا رَضِيْ عَلِيْ', 'فَحَبَّذَا رَبًّا وَحُبَّ دِينَا', 'وَكَانَ ذَاكَ فِي تَمَامِ عَشْرِ', 'وَسَلَّمَتْ عَلَى النَّبِيْ الْأَحْجَارُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'نَبِيُّنَا الْهَادِي لَهُ شُقَّ الْقَمَرْ\nكَمَا أَتَى فِي سُورَةٍ هِيَ الْقَمَرْ', ['وَنَبَعَ الْمَا مِنْ بَيْنِ الْأَصَابِعِ', 'يُجْلِسُهُ جِوَارَهُ إِنْ قَعَدَا', 'مَنِ اصْطَفَاهَا اللهُ كَيْ تَكُونَا', 'كَانَ مِنْ قَبْلِ بَعْثَتِي يُسَلِّمُ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَجَاءَ خَيْرُ الْخَلْقِ بِالْآيَاتِ\nوَسُمِّيَتْ عَنْهُ بِالْمُعْجِزَاتِ', ['عَقْدٌ فَرِيدٌ فِي العَوَالِمِ مَا لَهُ', 'تَنَوَّرَتْ بِنُورِهِ المَدِينَة', 'فَمَنْ يُقَارِنُ نَفْسَهُ بِالْأَنْبِيَا', 'خَوَارِقَ لِسَائِرِ الْعَادَاتِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَنَزَلَتْ لَمَّا دَعَا ........', ['الْأَمْطَارُ', 'الْإِبِلَا', 'الجَنْدَلِ', 'الرَّحِيمُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَتَى بِهَا لَهُ مُصَدِّقَاتِ', ['أَلَّا يَطُوفَ بَعْدَ ذَا عُرْيَانُ', 'وَأَنَّ رَبَّنَا مُتِمٌّ نُورَهُ', 'خَوَارِقَ لِسَائِرِ الْعَادَاتِ', 'يَبْدَأُ مَنْ لَقِيَهُ بِالسَّلَامِ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بِوَجْهِهِ يُسْقَى الْغَمَامُ حَقًّا', ['وَقَوْلُهُ وَحْيٌ أَتَى وَصِدْقًا', 'خَلَّصَهُمْ مِنْ نِقْمَةِ الْعَذَابِ', 'فَجَلَسَ الذِّئْبُ إِلَيْهِ كَلَّمَهْ', 'وَقَبِلَ مِنْ بَعْدِ ذَا أَسَفَهُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَجَزَ الْخَلْقُ أَنْ يَأْتُوا ........', ['بَغَى', 'بَسَطَ', 'بِمِثْلِهِ', 'بَيْنِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'أَتَى لَنَا بِالنُّورِ وَالْقُرْآنِ\nمُعْجِزَةً عَلَى مَدَى الْأَزْمَانِ', ['حَذَّرَهُمْ مِنْ دَعْوَى الجَاهِلِيَّةْ', 'سَارَ إِلَيْهِمْ مَعَهُ أَرْبَعُمِائَةْ', 'اِتَّحَدَ اليَهُودُ وَالكُفَّارُ', 'عَجَزَ الْخَلْقُ أَنْ يَأْتُوا بِمِثْلِهِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَذْعَنُوا بِحُسْنِهِ وَفَضْلِهِ', ['وَجاءَ أَيْضاً لا تَسُبّوا مُضَرا', 'عَجَزَ الْخَلْقُ أَنْ يَأْتُوا بِمِثْلِهِ', '﴿وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا﴾ بِي أَنَا', 'بِالْوَحْيِ مِنْ رَبِّ الْوَرَى أَنْ يُسْرِعَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بِوَجْهِهِ يُسْقَى الْغَمَامُ حَقًّا\nوَقَوْلُهُ وَحْيٌ أَتَى وَصِدْقًا', ['قَالَ لَهَا خَيْرُ الوَرَى هَاتِيهِ', 'فِي آلِ عِمْرَانَ بِقَوْلِ اللَّهِ', 'وَكَانَ عُمْرُ الْمُصْطَفَى فِي وَقْتِهَا', 'أَتَى لَنَا بِالنُّورِ وَالْقُرْآنِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَسُمِّيَتْ عَنْهُ بِالْمُعْجِزَاتِ', ['وَهْوَ الْمُقَفَّى وَالنَّبِيُّ الْعَاقِبُ', 'وَجَاءَ خَيْرُ الْخَلْقِ بِالْآيَاتِ', 'وَكُسِرَتْ أَسْنَانُهُ السُّفْلِيَّةْ', 'وَأَمَرَ النَّبِيُّ لِلرُّمَاةِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'كَمَا أَتَى فِي سُورَةٍ هِيَ الْقَمَرْ', ['وَالأَمْرُ بِالأَذَانِ لِلصَّلَاةِ', 'حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد', 'كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة', 'نَبِيُّنَا الْهَادِي لَهُ شُقَّ الْقَمَرْ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'خَوَارِقَ ........ الْعَادَاتِ', ['لِأَجْلِهَا', 'لِبَيْتِ', 'لِهَمِّي', 'لِسَائِرِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'أَكْرِمْ بِخَيْرِ مُرْسَلٍ وَشَافِعِ', ['وَأُوِّلَ الدِّرْعُ أَيْ الْحَصِينَةُ', 'فَأَسْرَعُوا بِالْهِجْرَةِ الثَّانِيَةِ', 'وَنَبَعَ الْمَا مِنْ بَيْنِ الْأَصَابِعِ', 'لِيَعْرِفَ النَّاسُ جَمِيعًا قَدْرَهَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَسَلَّمَتْ عَلَى النَّبِيْ الْأَحْجَارُ', ['وَنَزَلَتْ لَمَّا دَعَا الْأَمْطَارُ', 'أَصْحَابِهِ نَحْوَ الْبَيْتِ الْحَرَامِ', 'وَسَيِّدًا وَقَائِدًا عَظِيمًا', 'بِفَضْلِهِ مِنْ بَعْدِ مَا جَاءَ لَهُمْ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُعْجِزَةً عَلَى مَدَى الْأَزْمَانِ', ['وَطَلَبَتْ قُرَيْشٌ مِنْ نَبِيِّنَا', 'بَنِي سُلَيْمٍ وَاللِّوَاءُ كَانَا', 'أَتَى لَنَا بِالنُّورِ وَالْقُرْآنِ', 'قَصَّتْ عَلَى العَبَّاسِ مَا رَأَتْهُ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَجَاءَ خَيْرُ الْخَلْقِ ........', ['بِالحِقْدِ', 'بِالْآيَاتِ', 'بِالْجَهْرِيَّة', 'بِالخِيَانَةْ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'عَجَزَ الْخَلْقُ أَنْ ........ بِمِثْلِهِ', ['يَنْتَمِي', 'يَوْمِ', 'يَأْتُوا', 'يَعُودُ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَقَوْلُهُ وَحْيٌ أَتَى وَصِدْقًا', ['أَدْعُوكُمُ بِالْوَحْيِ لِلتَّوْحِيدِ', 'بِوَجْهِهِ يُسْقَى الْغَمَامُ حَقًّا', 'وَسَارَ خَيْرُ الْخَلْقِ بِالْكِرَامِ', 'ومؤتة في ثَامن الأعوامِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'خَوَارِقَ لِسَائِرِ الْعَادَاتِ', ['مُحَمَّدُ الحَبيبُ حَقّاً عِنْدِيا', 'وَلَمْ تَزَلْ فَائِزَةً بِنَظْرَتِهِ', 'وَمَا عَنِ الْمُنَافِقِينَ قَدْ أَتَتْ', 'أَتَى بِهَا لَهُ مُصَدِّقَاتِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'نَبِيُّنَا ........ لَهُ شُقَّ الْقَمَرْ', ['الكِتَابْ', 'البُخَارِيْ', 'الْهَادِي', 'الْكَرِيمَة'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَسَلَّمَتْ عَلَى النَّبِيْ الْأَحْجَارُ\nوَنَزَلَتْ لَمَّا دَعَا الْأَمْطَارُ', ['مِنَ النِّسَاءِ خَمْسَةٌ وَضِعْفُهُمْ', 'وَكَانَ سِنُّ زَوْجِهَا الْكَرَّارِ', 'بِوَجْهِهِ يُسْقَى الْغَمَامُ حَقًّا', 'وَقَدْ رَأَى النَّبِيُّ فِي الْمَنَامِ'], 2),
  ],
  <PoemQ>[
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمُنْتَهَى الجَمَالِ وَالجَلَالِ', ['وَمَعَهُ بَعْضٌ مِنَ الْأَنْصَارِ', 'حَوْلَ النَّبِيِّ الْهَاشِمِيِّ الْهَادِي', 'أَوْصَافُهُ فِي غَايَةِ الكَمَالِ', 'وَجَاءَ نَجْلُ عَبْدِاللَّهِ بْنِ أَبَيْ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'حَبِيبُنَا وَأَدْعَجُ العَيْنَيْنْ', ['شَثْنُ الكَفَّيْنِ وَكَذَا القَدَمَيْنْ', 'نَالَتْ بِهِ خَدِيجَةُ الْمَكَاسِبَا', 'وَأَصْلَحَ النَّبِيُّ بَيْنَ أَهْلِهَا', 'وَالْبَيْهَقِيُّ قَدْ رَوى وَأَثْبَتا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مِنْ صَبَبٍ كَمَا رَوَى الرِّجَالُ\nإِلَى نَدَاهُ تَنْتَهِي الآمَالُ', ['وَدُومَةُ الجَنْدَلِ ثُمَّ المُصْطَلِقْ', 'بَشَّرَهُ النَّبِيُّ أَن يَنَالَا', 'ضَخْمُ الكَرَادِيسِ طَوِيلُ المَسْرُبَةْ', 'فَكانَ كَعْبٌ جَدُّهُ مُذَكِّرا'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَيْنَ ........ خَاتَمُ النُّبُوءَةْ', ['كَفِّهِ', 'كَتِفَيْهِ', 'كَالْفِيلِ', 'كُتْبِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'فَمَا لَهُ فِي الخَلْقِ مِنْ مُمَاثِلْ', ['كَمَا أَتَتْ فِي كُتُبِ الشَّمَائِلْ', 'فَوَصَلَ الْكِتَابُ فِي قُبَاءَ', 'مُوسَى وَعِيسَى وَالْخَلِيلُ قَبْلَهُمْ', 'حَتَّى وَلَوْ أَنْ نَضْرِبَ الأَكْبَاد'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَالبِشْرِ وَالتَّرْحِيبِ وَالإِكْرَامِ', ['وَخُزَيْمَةُ سُمِّي بِذاكَ لَمَّا', 'وَكانَ جَدُّ المُصْطَفى كِنانَة', 'وَيَنْبَغي قَبْلَ الشُّروعِ أوَّلاً', 'يَبْدَأُ مَنْ لَقِيَهُ بِالسَّلَامِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ضَخْمُ الكَرَادِيسِ عَرِيضُ ........', ['إِذْنِهَا', 'الصَّدْرِ', 'إِيمَانِهِمْ', 'أَمْرِ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَآلِهِ وَصَحْبِهِ وَكَرَّمَا', ['صَلَّى عَلَيْهِ رَبُّنَا وَسَلَّمَا', 'فَأَجَابَهُ الصِّدِّيقُ إِنِّي إِنَّمَا', 'وَأَرْسَلَ الصَّدِيقَ عَامَ التَّاسِعِ', 'دَخَلَهَا الْحَبِيبُ فِي تَوَاضُعِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَبَاسِطُ الكَفَّيْنِ دَوْمًا بِالكَرَمْ', ['وَعَلَى قُبَاءَ عَاصِمَ بْنَ عَدِي', 'وَهُوَ الَّذِي حَفَرَ زَمْزَمَ بَعْدَ أَنْ', 'مُفَلَّجُ الأَسْنَانِ وَضَلِيعُ الفَمْ', 'وَجَهَّزَ الْجُيُوشَ لِلْمَسِيرِ'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'ذُو طَلْعَةٍ ........ مُحَبَّبَةْ', ['بِالجَدِّ', 'بِأُمِّ', 'بِأَمْوَاتٍ', 'بَهِيَّةٍ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'بَيْنَهُمَا عِرْقٌ يَدُرُّهُ الغَضَبْ\nوَمَنْ رَآهُ فَجْأَةً لَهُ يَهَبْ', ['مُكَحَّلٌ وَأَهْدَبُ الأَشْفَارْ', 'وَهْوَ الرَّؤُوفُ وَالْحَبِيبُ وَالرَّحِيمُ', 'فَعُرِفَ السُّرُورُ فِي وَجْهِ النَّبِي', 'سَمَّيْتُهَا بِرَوْضَةِ الْعُشَّاقِ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'بَلْ رَبْعَةً بِحُسْنِهِ ........ يَطِيرْ', ['الهَاشِمِيِّ', 'أَعْظَمُ', 'أَيَّامِهِ', 'العَقْلُ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَخَافِضُ ........ نَظَرُهُ إِلَى', ['الطَّرْفِ', 'إِلَّا', 'إِنَّهَا', 'الْمَغْفِرَة'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَمَشْيُهُ هَوْنًا مَسِيحُ القَدَمَيْنْ', ['شَبِيهَةٌ بِالْمُصْطَفَى الْهَادِي الْأَغَر', 'يُنْذِرُهُمْ بِالْوَحْيِ وَالنِّبْرَاسِ', 'يَنْبُو عَنْهُمَا المَا خُمْصَانُ الأَخْمَصَيْنْ', 'الرُّعْبَ ثُمَّ خُمِّسَتْ أَمْوَالُهُمْ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'الْمُصْطَفَى الْهَادِي إِلَى الرَّشَادِ', ['ثَبَّتَهُ الرَّحْمَنُ مِنْ عُلَاهُ', 'وَكَانَ يَزْدَادُ إِلَى أَنْ شَبِعُوا', 'الطَّاهِرِ الْآبَاءِ وَالْأَجْدَادِ', 'فَأَقْبَلُوا بِخَالِصِ الْإِذْعَانِ'], 2),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'مُعْتَدِلُ الخَلْقِ سَرِيعُ المِشْيَةِ', ['مُفَلَّجُ الأَسْنَانِ كَثُّ اللِّحْيَةِ', 'وَبَكَوْا عَلَى مَا كَانَ ثُمَّ تَعَانَقُوا', 'فَلَيْسَ فِيهَا مِنْ شَرَابٍ يُطْلَبُ', 'سَارَ مَعَ مَيْسَرَةَ الْغُلَامِ'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'مُكَحَّلٌ وَأَهْدَبُ الأَشْفَارْ', ['فَجَاءَهُ رَأْسُ الْعَدُوِّ عِنْدَهَا', 'الْمُرْشِدَاتِ لِلْهُدَى وَالظَّاهِرَاتِ', 'وَمُشْرِقٌ كَالشَّمْسِ فِي النَّهَارْ', 'قَالَتْ لَهُمْ عُودُوا وَجِيئُوا بِابْنِنَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَحْكِي لَنَا سِيرَتَهُ الشَّرِيفَةْ', ['لِيَقُمْ هُنَا بِسَيْفِهِ يَضْرِبْنِي', 'مُيَسُورَةً أَلْفَاظُهَا لَطِيفَةْ', 'وَكَثْرَةِ الأَعْدَادِ عِنْدَ المُشْرِكِينْ', 'فَانْقَلَبَ الْأَمْرُ بِقَتْلٍ قَدْ حَصَلْ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَوَجْهُهُ مُدَوَّرٌ مُشَرَّبُ', ['فَرَضِيَ بِمَا قَالَ النَّبِيْ', 'وَالصُّلْحِ فِي مَا بَيْنَهُمْ وَالْحِلْمِ', 'يَأْتِي بِخَيْرِ الْخَلْقِ طَهَ الْمُؤْتَمَنْ', 'بِحُمْرَةٍ وَلِلشَّقَاءِ يُذْهِبُ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'تُنَبِّئُ عَنْ أَخْلَاقِهِ الْعَلْيَاءِ', ['كَذَا نَبِيُّ التَّوْبَةِ وَالْمَرْحَمَة', 'هَيْئَتُهُ فِي الْحُسْنِ وَالْبَهَاءِ', 'وَانْتَقَلَ النُّورُ لَهَا مِنْ وَالِدِهْ', 'فَاللَّهُ قَدْ أَرْسَلَهُ رَحِيمًا'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'صَلَّى عَلَيْكَ اللَّهُ يَا ضَمِينِي', ['وَالْآلِ وَالْأَصْحَابِ كُلَّ حِينِ', 'تُدْلَى لِي عَلَى رَأْسِي أُبْصِرُهَا', 'مُعْجِزَةً عَلَى مَدَى الْأَزْمَانِ', 'وَصَلَهَا الهَادِي البَشِيرُ مُسَلِّمَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لِلرَّحْمَنِ فِي الْخِتَامِ', ['وَالشُّكْرُ', 'وَكَذا', 'وَلَمّا', 'وَغَيْرُهُ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'تَمَّتْ بِفَضْلِ ........ الْوَهَّابِ', ['الْوَاحِدِ', 'الْحَمْزَةُ', 'الهَادِي', 'الْبُشْرَيَات'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَلَمْ يَكُنْ بِالبَادِنِ المُطَهَّمْ', ['بَلْ إِنَّهُ حَقٌّ وَصِدْقُ خَبَر', 'وَلَمْ يَكُنْ فِي الوَجْهِ بِالمُكَلْثَمْ', 'لِلْمُصْطَفَى وَكَتَبَ كِتَابَا', 'مِنْ عَمِّهِ لِيَقْتُلُوهُ فِي جَفَا'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'ثُمَّ السَّلَامُ عَدَدَ الرِّمَالِ\nلِلْمُصْطَفَى ذِي النُّورِ وَالْكَمَالِ', ['زَكَّاهُ رَبُّ الْعَرْشِ فِي الْكِتَابِ', 'فَإِنَّهُمْ لِرَبِّنَا اسْتَجَابُوا', 'وَقَدْ رَأَتْ أُمُّ النَّبِيِّ النُّورَا', 'أَوْصَافُهُ فِي غَايَةِ الكَمَالِ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَأَلَّفَ اللَّهُ بِهِ الْقُلُوبَا\nوَأَصْلَحَ اللَّهُ بِهِ الشُّعُوبَا', ['وَأَعْتَقَ الصِّدِّيقُ أَعْطَى وَاتَّقَى', 'تِلْكَ المَغَازِي فِيهَا ذِكْرُ الأَوَّلِينْ', 'وَجَاءَهُ جِبْرِيلُ عِنْدَ الْأَرْبَعِين', 'صَلَّى عَلَيْكَ اللَّهُ يَا ضَمِينِي'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَسَائِلُ الأَطْرَافِ ذُو ........', ['فَصَاحَةْ', 'فُؤَادِي', 'فَعَلِمُوا', 'فَاطِمَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُحَمَّدٌ هُوَ سَيِّدُ الْأَنَامِ\nوَشَافِعٌ لَنَا يَوْمَ الزِّحَامِ', ['حَتَّى أَتَاهُ الإِذْنُ بَعْدَ فَتْرَةِ', 'وَغَيْرُ ذَا وَقَائِعُ كَثِيرَةْ', 'وَأَرْضَعَتْ حَلِيمَةُ السَّعْدِيَّة', 'هَيْئَتُهُ فِي الْحُسْنِ وَالْبَهَاءِ'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'عَلَيْهِ نُورٌ وَالجَبِينُ وَاسِعُ', ['وَأَزْهَرُ اللَّوْنِ جَمِيلٌ سَاطِعُ', 'وَجَاءَ أَهْلُ الكُفْرِ وَالجَفَاءِ', 'مُسَاعِدًا أَصْحَابَهُ الكِرَامْ', 'أَحَبَّهَا الْمُخْتَارُ لَمْ يَزَلْ عَلَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ لَيْسَ بِجَعْدٍ أَوْ بِسَبْطْ', ['وَقَصَّهَا', 'وَقَامَ', 'وَأَحْسَنُوا', 'وَشَعْرُهُ'], 3),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'تَحْكِي لَنَا سِيرَتَهُ الشَّرِيفَةْ\nمُيَسُورَةً أَلْفَاظُهَا لَطِيفَةْ', ['فَصَدَّقَاهُ وَقَبَّلَا رِجْلَيْهِ', 'وَرَفَضَ النَّبِيُّ مَنْ أَتَاهُ', 'وَالْحَمْدُ لِلَّهِ عَلَى الدَّوَامِ', 'وَأَدخَلُوهُ لِلنَّبِيِّ فَاستَقبَلَه'], 2),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'وَالبِشْرِ وَالتَّرْحِيبِ ........', ['وَالإِكْرَامِ', 'وَالجَلَالِ', 'وَالْجَلِي', 'وَالزُّبَيرُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَمَنْ رَآهُ فَجْأَةً لَهُ يَهَبْ', ['وَحَاوَلَتْ قُرَيْشٌ أَخْذَ الْمُصْطَفَى', 'بَيْنَهُمَا عِرْقٌ يَدُرُّهُ الغَضَبْ', 'قالَ يا رَبَّنا بِحَقِّ أَحْمَدا', 'وَابْنُ أَبِي وَقَّاصٍ سَعْدٌ كَانَا'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ فِي غَايَةِ الكَمَالِ', ['الصَّدِيقَ', 'الْبَدَائِعَا', 'أَوْصَافُهُ', 'الْقِيَامَ'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'طَوِيلُ الزَّنْدَيْنِ وَرَحْبُ الرَّاحَةْ', ['وَسَائِلُ الأَطْرَافِ ذُو فَصَاحَةْ', 'وَبَثَّ فِيهِمْ نُورَهُ بِالْعِلْمِ', 'فَانْطَلَقُوا لِلْبَيْتِ فِي سَلَامِ', 'خُلُقَ السَّكِينَةِ وَالْوَقَارِ مُلْتَزَمْ'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'فَمَا لَهُ فِي ........ مِنْ مُمَاثِلْ', ['آمِراً', 'الخَلْقِ', 'أَقْصِدُ', 'إِلَيْهِمُ'], 1),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَوَجْهُهُ مُدَوَّرٌ مُشَرَّبُ\nبِحُمْرَةٍ وَلِلشَّقَاءِ يُذْهِبُ', ['وَأَزْهَرُ اللَّوْنِ جَمِيلٌ سَاطِعُ', 'يَحْدو بِصَوْتٍ يَأْخُذُ الأَلْبابا', 'وَهَاجَرَ الْأَصْحَابُ أُولَى الْهِجْرَتَيْنِ', 'وَغَيْرُهَا يَا أَيُّهَا الرَّسُولُ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'لِلْمُصْطَفَى ذِي النُّورِ وَالْكَمَالِ', ['ثُمَّ السَّلَامُ عَدَدَ الرِّمَالِ', 'مِنْ دَعْوَةِ النَّبِيِّ قَدْ خَافُوا عَلَى', 'حَلَقَاتُهُ يَتَلَألَأُ النُّورُ بِهَا', 'فَلَمْ يَكُنْ بِخَبَرٍ صَحِيحِ'], 0),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَأَصْلَحَ اللَّهُ بِهِ الشُّعُوبَا', ['وَقَابَلُوهُ بِالأَذَى وَبِالجَفَا', 'وَسَافَرَ الْمُخْتَارُ لِلتِّجَارَةِ', 'وَأَلَّفَ اللَّهُ بِهِ الْقُلُوبَا', 'وَقَامَ خَيْرُ الْخَلْقِ بَيْنَ النَّاسِ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'الْمُصْطَفَى الْهَادِي إِلَى الرَّشَادِ\nالطَّاهِرِ الْآبَاءِ وَالْأَجْدَادِ', ['وَأَلَّفَ اللَّهُ بِهِ الْقُلُوبَا', 'وَشَعْرُهُ لَيْسَ بِجَعْدٍ أَوْ بِسَبْطْ', 'صَلَّى عَلَيْهِ رَبُّنَا وَسَلَّمَا', 'نَسَبٌ شَرِيفٌ طَاهِرٌ مُعَظَّمٌ'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'صَلَّى عَلَيْكَ اللَّهُ يَا ضَمِينِي\nوَالْآلِ وَالْأَصْحَابِ كُلَّ حِينِ', ['عَاشَتْ بِهِ فِي عِيشَةٍ هَنِيَّةٍ', 'قَالُوا لَهُ أَخٌ كَرِيمٌ فِينَا', 'وَقِيلَ بَلْ يُنَاوِلُ السِّهَامَا', 'ثُمَّ السَّلَامُ عَدَدَ الرِّمَالِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'بَيْنَ كَتِفَيْهِ خَاتَمُ النُّبُوءَةْ', ['فِي وَسَطِ الطَّرِيقِ حِينَ عَلِمُوا', 'لِلْكَعْبَةِ كِسْوَتَها وَأَلْبَسا', 'وَقَدْ أَتَى بِالنُّورِ وَالمُرُوءَةْ', 'وَلَمْ يَزَلْ مُحَبَّبًا عَتِيقَا'], 2),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ضَخْمُ الكَرَادِيسِ طَوِيلُ المَسْرُبَةْ', ['خَمْسِينَ أَلْفًا جَاءُوا بِالرِّجَالِ', 'مِنْ مُعْجِزَاتِ سَيِّدِ الْأَنَامِ', 'وَالبَعْضُ مِنْهُمْ بِالعَدَاوَةِ أَعْلَنَا', 'ذُو طَلْعَةٍ بَهِيَّةٍ مُحَبَّبَةْ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَالْحَمْدُ لِلَّهِ عَلَى الدَّوَامِ', ['وَالشُّكْرُ لِلرَّحْمَنِ فِي الْخِتَامِ', 'مِنْهُمْ بِسَبْعِينَ إِلَى أَنْ أُنْزِلَا', 'أَنْفُسِهِمْ مِنْ قَوْمِهِمْ أَنْ يُقْتَلَا', 'لَمَّا تَلَا صَحِيفَةَ القُرآنِ'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'مُكَحَّلٌ وَأَهْدَبُ الأَشْفَارْ\nوَمُشْرِقٌ كَالشَّمْسِ فِي النَّهَارْ', ['فَإِنَّهُ الْمَذْكُورُ فِي الْكِتَابِ', 'مَا قَدَرُوا اللهَ كَحَقِّ قَدْرِهِ', 'وَوَجْهُهُ مُدَوَّرٌ مُشَرَّبُ', 'ثُمَّ الصَّلَاةُ وَالسَّلَامُ الْأَبَدَي'], 2),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَلَمْ يَكُنْ بِالبَادِنِ المُطَهَّمْ\nوَلَمْ يَكُنْ فِي الوَجْهِ بِالمُكَلْثَمْ', ['وَامْتَنَّ رَبُّ العَالَمِينَ بِنَصْرِهِ', 'شَثْنُ الكَفَّيْنِ وَكَذَا القَدَمَيْنْ', 'عَنْ أَحَدِ الرُّعَاةِ كَانَ يَرْعَى', 'عَبْدُ مَنَافٍ جَدُّهَا وَزُهْرَة'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', '........ نُورٌ وَالجَبِينُ وَاسِعُ', ['عَسَى', 'عَظِيمٌ', 'عَلَيْنَا', 'عَلَيْهِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'شَثْنُ الكَفَّيْنِ ........ القَدَمَيْنْ', ['وَفَرَّ', 'وَكَذَا', 'وَأَنَّ', 'وَتَبَارَزَ'], 1),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُفَلَّجُ ........ وَضَلِيعُ الفَمْ', ['العُهُودْ', 'اسْتَجَابُوا', 'الْأَمِينْ', 'الأَسْنَانِ'], 3),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'مُفَلَّجُ ........ كَثُّ اللِّحْيَةِ', ['الأَسْنَانِ', 'الْقُرْآنُ', 'الْجُمُعَةَ', 'السَّرَايَا'], 0),
    PoemQ('ما الشطر الذي يبدأ به البيت التالي؟', 'وَمَشْيُهُ هَوْنًا مَسِيحُ القَدَمَيْنْ\nيَنْبُو عَنْهُمَا المَا خُمْصَانُ الأَخْمَصَيْنْ', ['وَخَافِضُ الطَّرْفِ نَظَرُهُ إِلَى', 'وَثَبَتَ الْكَرَّارُ وَالصِّدِّيقُ', 'فِي آلِ عِمْرَانَ بِقَوْلِ اللَّهِ', 'كَانُوا بِهِ مِنْ قَبْلِ بَعْثَتِهِ عَلَى'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'هَيْئَتُهُ فِي الْحُسْنِ ........', ['وَأَقْبَلُوا', 'وَالْبَهَاءِ', 'وَأُمُّهَا', 'وَأَخبَرُوهُ'], 1),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'إِلَى نَدَاهُ تَنْتَهِي الآمَالُ', ['مِنْ صَبَبٍ كَمَا رَوَى الرِّجَالُ', 'قَالَ نَعَمْ رَأَيْتُ ذَاتَ مَرَّةٍ', 'أَمَرَ الحَبِيبُ صَحَابَهُ بِالجَدِّ', 'لَكِنَّهُمْ قَدْ كَذَّبُوا تَكْذِيبَا'], 0),
    PoemQ('اختر الكلمة الناقصة في الشطر:', 'صَلَّى ........ رَبُّنَا وَسَلَّمَا', ['عُكَاظَ', 'عَلَيْهِ', 'عِزَّةٍ', 'عَبّاسِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَخَافِضُ الطَّرْفِ نَظَرُهُ إِلَى', ['إِلَّا عَلَى مَنِ اعْتَدَى لَهُمْ قَدِمْ', 'عُثْمَانُ صِهْرُ الْمُصْطَفَى وَبَعْلُهَا', 'وَالشُّكْرُ لِلرَّحْمَنِ فِي الْخِتَامِ', 'أَرْضٍ مِنَ السَّمَاءِ دَوْمًا أَطْوَلَا'], 3),
    PoemQ('اختر الشطر الأول الذي يسبق هذا الشطر:', 'وَشَافِعٌ لَنَا يَوْمَ الزِّحَامِ', ['مِنَ النِّسَاءِ خَمْسَةٌ وَضِعْفُهُمْ', 'مُحَمَّدٌ هُوَ سَيِّدُ الْأَنَامِ', 'كَمَا أَتَى وَحْيٌ وَنَصٌّ قَطْعِيْ', 'وَجَاءَهُ جِبْرِيلُ عِنْدَ الْأَرْبَعِين'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'ضَخْمُ الكَرَادِيسِ عَرِيضُ الصَّدْرِ', ['وَقَالَ تِلْكَ مِنْ أَشْرَاطِ السَّاعَة', 'وَأَنَّ فيهِ مَبْعَثَ الهادي الكَريم', 'انْتَشَرَ الإِسْلاَمُ بَعْدَ وُقُوعِهَا', 'عَلَيْهِ خَطٌّ وَاضِحٌ مِنْ شَعْرِ'], 3),
    PoemQ('أكمل الشطر الثاني من البيت:', 'تَمَّتْ بِفَضْلِ الْوَاحِدِ الْوَهَّابِ', ['أَلْفِيَّةً عَنْ سَيِّدِ الْأَحْبَابِ', 'أَحْبَابَهَا لِأَجْلِهَا مُعَظَّمَا', 'خَيْرِ الأَنَامِ الهَاشِمِيِّ الطَّيِّبِ', 'وَبَشَّرَتْ لِعَمِّهِ قَدْ ثَبَتَا'], 0),
    PoemQ('أكمل الشطر الثاني من البيت:', 'لَيْسَ طَوِيلًا بَائِنًا وَلَا قَصِيرْ', ['عِنْدَ الَّذِي خَلَقَهُمْ سُعَدَاءُ', 'بَلْ رَبْعَةً بِحُسْنِهِ العَقْلُ يَطِيرْ', 'الْحَجَرَ الْأَسْوَدَ ثُمَّ يَرْفَعُ', 'وَبَعدَهَا الْمِعْرَاجُ لِلسَّمَاءِ'], 1),
    PoemQ('أكمل الشطر الثاني من البيت:', 'وَشَعْرُهُ لَيْسَ بِجَعْدٍ أَوْ بِسَبْطْ', ['بَلْ رَبْعَةً بِحُسْنِهِ العَقْلُ يَطِيرْ', 'يَمْشِي تَكَفُّؤًا كَأَنَّمَا يَنْحَطْ', 'عَمَّ السُّرُورُ أَرْضَهُمْ إِلَى الْأَبَد', 'بَيْنَهُمَا كانوا يُؤَرِّخُونَا'], 1),
  ],
];

class PoemQuizScreen extends StatefulWidget {
  final String title, bestKey;
  final List<PoemQ> questions;
  const PoemQuizScreen({super.key, required this.title, required this.questions, required this.bestKey});
  @override
  State<PoemQuizScreen> createState() => _PoemQuizScreenState();
}

class _PoemQuizScreenState extends State<PoemQuizScreen> {
  int idx = 0, score = 0, best = 0;
  int? picked;
  bool done = false, newBest = false;

  @override
  void initState() {
    super.initState();
    best = Repo.prefs.getInt(widget.bestKey) ?? 0;
  }

  void pick(int k) {
    if (picked != null) return;
    final q = widget.questions[idx];
    setState(() {
      picked = k;
      if (k == q.answer) score++;
    });
    HapticFeedback.selectionClick();
  }

  void next() {
    if (idx + 1 >= widget.questions.length) {
      newBest = score > best;
      if (newBest) {
        best = score;
        Repo.prefs.setInt(widget.bestKey, score);
      }
      setState(() => done = true);
    } else {
      setState(() {
        idx++;
        picked = null;
      });
    }
  }

  void restart() => setState(() {
        idx = 0;
        score = 0;
        picked = null;
        done = false;
        newBest = false;
      });

  Widget option(BuildContext context, PoemQ q, int k) {
    final answered = picked != null;
    final isRight = k == q.answer;
    final isPicked = picked == k;
    Color border = accent(context).withOpacity(.3);
    Color fill = Theme.of(context).cardColor;
    IconData? mark;
    if (answered && isRight) {
      border = Colors.green;
      fill = Colors.green.withOpacity(.16);
      mark = Icons.check_circle;
    } else if (answered && isPicked) {
      border = Colors.red;
      fill = Colors.red.withOpacity(.14);
      mark = Icons.cancel;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: answered ? null : () => pick(k),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: answered && (isRight || isPicked) ? 2 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Text(q.options[k],
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9, fontWeight: FontWeight.w600)),
            ),
            if (mark != null) Icon(mark, color: isRight ? Colors.green : Colors.red),
          ]),
        ),
      ),
    );
  }

  Widget buildQuestion(BuildContext context) {
    final q = widget.questions[idx];
    final n = widget.questions.length;
    final ac = accent(context);
    final hint = Theme.of(context).hintColor;
    final answered = picked != null;
    return Column(children: [
      LinearProgressIndicator(
        value: (idx + (answered ? 1 : 0)) / n,
        minHeight: 5,
        color: ac,
        backgroundColor: ac.withOpacity(.15),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('السؤال ${idx + 1} / $n', style: TextStyle(color: hint)),
              Text('الدرجة: $score', style: TextStyle(color: hint)),
            ]),
            const SizedBox(height: 10),
            Text(q.prompt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ac)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: ac.withOpacity(.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ac.withOpacity(.4)),
              ),
              child: Text(q.stem, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, height: 2.0, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            for (var k = 0; k < q.options.length; k++) option(context, q, k),
          ],
        ),
      ),
      if (answered)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: next,
              child: Text(idx + 1 >= n ? 'عرض النتيجة' : 'السؤال التالي', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
    ]);
  }

  Widget buildResult(BuildContext context) {
    final n = widget.questions.length;
    final ac = accent(context);
    final pct = (score * 100 / n).round();
    final msg = pct >= 90
        ? 'ما شاء الله، حفظ متقن'
        : pct >= 70
            ? 'جيد جدًا، راجع المواضع التي أخطأت فيها'
            : pct >= 50
                ? 'جيد، تحتاج إلى مراجعة أكثر'
                : 'واصل مراجعة المنظومة ثم أعد المحاولة';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.emoji_events, size: 72, color: ac),
          const SizedBox(height: 12),
          Text('انتهى الاختبار', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ac)),
          const SizedBox(height: 10),
          Text('$score / $n', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
          Text('$pct%', style: TextStyle(fontSize: 18, color: Theme.of(context).hintColor)),
          const SizedBox(height: 10),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.6)),
          const SizedBox(height: 6),
          Text(newBest ? 'نتيجة جديدة هي الأفضل لك' : 'أفضل نتيجة: $best / $n',
              style: TextStyle(color: newBest ? Colors.green : Theme.of(context).hintColor)),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: restart,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة الاختبار'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.pop(context),
              child: const Text('رجوع'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 16))),
        body: SafeArea(child: done ? buildResult(context) : buildQuestion(context)),
      ),
    );
  }
}

// ---------- منهج الصلاة ----------
class PrayerTab extends StatefulWidget {
  const PrayerTab({super.key});
  @override
  State<PrayerTab> createState() => _PrayerTabState();
}

class _PrayerTabState extends State<PrayerTab> {
  bool auto = true;
  late int sy, sm, sd;
  int myLevel = 0; // المستوى اللي اختارته المستخدمة بنفسها (0 = لسه ما اختارتش)
  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    sy = n.year; sm = n.month; sd = n.day;
    final l = Repo.prefs.getInt('wird_level') ?? 0;
    myLevel = (l >= 1 && l <= 5) ? l : 0;
  }

  // العلامة دي هي الوحيدة اللي بتغيّر مستواك، وفتح أي مستوى للفرجة مش بيغيّره
  Future<void> setMyLevel(int l) async {
    if (myLevel == l) return;
    recordGradeLevel(); // نثبّت الأيام اللي فاتت على المستوى القديم قبل التغيير
    setState(() => myLevel = l);
    await Repo.prefs.setInt('wird_level', l);
    recordGradeLevel();
    wirdTick.value++;
    unawaited(scheduleWirdReminders());
    if (!mounted) return;
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('تم اختيار المستوى ${levelNames[l - 1]} كمستواك',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: pri(context),
        duration: const Duration(seconds: 2),
      ));
  }

  void open(int level) {
    final n = DateTime.now();
    final y = auto ? n.year : sy, m = auto ? n.month : sm, d = auto ? n.day : sd;
    Navigator.push(context, MaterialPageRoute(builder: (_) => LevelScreen(level, y, m, d)));
  }

  // بطاقة المستوى: تدرّج لوني من لون الثيم يزداد درجةً مع المستوى + نجوم تبيّن رقم المستوى
  Widget _levelCard(BuildContext context, int l) {
    final p = pri(context), sd = Color.lerp(sec(context), Colors.black, .35)!;
    final tt = Color.lerp(tri(context), Colors.black, .25)!;
    // المستويات الخمسة بتمشي بين ألوان الثيم التلاتة
    final stops = [p, Color.lerp(p, tt, .5)!, tt, Color.lerp(tt, sd, .5)!, sd];
    final c1 = stops[(l - 1).clamp(0, 4).toInt()];
    final c2 = Color.lerp(c1, Colors.black, .3)!;
    final mine = myLevel == l;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: mine ? Colors.white : Colors.transparent, width: 2.5),
        boxShadow: [BoxShadow(color: c1.withOpacity(.35), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => open(l),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.2),
                  border: Border.all(color: Colors.white.withOpacity(.6), width: 1.5),
                ),
                child: Text('$l', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('المستوى ${levelNames[l - 1]}',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${l * 2000} صلاة يومياً', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(.85))),
                  const SizedBox(height: 6),
                  Row(children: [
                    for (var i = 0; i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Icon(i < l ? Icons.star : Icons.star_border,
                            size: 15, color: Colors.white.withOpacity(i < l ? 1 : .45)),
                      ),
                  ]),
                ]),
              ),
              Tooltip(
                message: mine ? 'هذا مستواك' : 'اختيار هذا المستوى كمستواي',
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setMyLevel(l),
                  child: SizedBox(
                    width: 60,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(mine ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 32, color: Colors.white.withOpacity(mine ? 1 : .75)),
                        Text(mine ? 'مستواي' : 'اختيار',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: mine ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white.withOpacity(mine ? 1 : .8))),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget dd(String label, int v, List<int> items, String Function(int) txt, void Function(int) on) => Expanded(
        child: DropdownButtonFormField<int>(
          value: v,
          isExpanded: true,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(txt(e)))).toList(),
          onChanged: auto ? null : (x) => setState(() => on(x!)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final n = DateTime.now();
    final y = auto ? n.year : sy, m = auto ? n.month : sm;
    final days = DateTime(y, m + 1, 0).day;
    if (sd > days) sd = days;
    final d = auto ? n.day : sd;
    return ListView(padding: const EdgeInsets.all(14), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            SwitchListTile(
              title: const Text('التاريخ تلقائي'),
              subtitle: auto ? Text('اليوم: ${n.day} ${months[n.month - 1]} ${n.year}') : null,
              value: auto,
              onChanged: (v) => setState(() => auto = v),
            ),
            Row(children: [
              dd('اليوم', d, List.generate(days, (i) => i + 1), (e) => '$e', (e) => sd = e),
              const SizedBox(width: 8),
              dd('الشهر', m, List.generate(12, (i) => i + 1), (e) => months[e - 1], (e) => sm = e),
              const SizedBox(width: 8),
              dd('السنة', y, List.generate(12, (i) => n.year - 2 + i), (e) => '$e', (e) => sy = e),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16), side: BorderSide(color: sec(context), width: 1.8)),
          onPressed: () => openPdf(context, manhajBook, 1),
          icon: Icon(Icons.menu_book, color: accent(context)),
          label: Text('تعرف على منهج الصلاة',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: accent(context))),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Text('علّم على مستواك بالعلامة ✓ على الجانب، ولن يتغيّر إلا إذا اخترت مستوى آخر بنفسك. وفتح أي مستوى للاطلاع لا يغيّر مستواك.',
            style: TextStyle(fontSize: 12.5, height: 1.6, color: Theme.of(context).hintColor)),
      ),
      for (var l = 1; l <= 5; l++) _levelCard(context, l),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16), side: BorderSide(color: sec(context), width: 1.8)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SebhaScreen())),
          icon: Icon(Icons.auto_awesome, color: accent(context)),
          label: Text('سبحة الصلاة على الحبيب ﷺ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: accent(context))),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          icon: Icon(Icons.bar_chart, color: accent(context)),
          label: Text('إحصائياتي وسجل الشهور',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: accent(context))),
        ),
      ),
    ]);
  }
}

// ---------- منهج الصلاة: الورد اليومي ----------
String latinDigits(String s) {
  const ar = '٠١٢٣٤٥٦٧٨٩';
  var out = s;
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(ar[i], '$i');
  }
  return out;
}

// هل اتعلّم اليوم ده "تم" في أي مستوى؟
bool wirdDayDone(DateTime t, Map<String, Set<int>> cache) {
  for (var l = 1; l <= 5; l++) {
    final k = 'p${l}_${t.year}_${t.month}';
    final set = cache.putIfAbsent(k, () => (Repo.prefs.getStringList(k) ?? []).map(int.parse).toSet());
    if (set.contains(t.day)) return true;
  }
  return false;
}

// عدد الأيام المتتالية اللي اتم فيها الورد (لحد النهارده)، ونحفظ أفضل سلسلة
int wirdStreak() {
  final cache = <String, Set<int>>{};
  final now = DateTime.now();
  var t = DateTime(now.year, now.month, now.day);
  if (!wirdDayDone(t, cache)) t = DateTime(t.year, t.month, t.day - 1);
  var n = 0;
  while (n < 1000 && wirdDayDone(t, cache)) {
    n++;
    t = DateTime(t.year, t.month, t.day - 1);
  }
  final best = Repo.prefs.getInt('wird_best') ?? 0;
  if (n > best) Repo.prefs.setInt('wird_best', n);
  return n;
}

class LevelScreen extends StatefulWidget {
  final int level, y, m, hl;
  const LevelScreen(this.level, this.y, this.m, this.hl, {super.key});
  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late int y, m;
  late Set<int> done;
  final ItemScrollController _sc = ItemScrollController();
  String get key => 'p${widget.level}_${y}_$m';
  int get goal => widget.level * 2000;
  int get days => DateTime(y, m + 1, 0).day;
  bool get isCurrent {
    final n = DateTime.now();
    return y == n.year && m == n.month;
  }

  @override
  void initState() {
    super.initState();
    y = widget.y;
    m = widget.m;
    done = loadDone();
    WidgetsBinding.instance.addPostFrameCallback((_) => wirdTick.value++);
  }

  Set<int> loadDone() => (Repo.prefs.getStringList(key) ?? []).map(int.parse).toSet();

  // الشهر السابق (-1) أو التالي (+1)، ومفيش تخطّي للشهر الحالي
  void go(int delta) {
    final t = DateTime(y, m + delta, 1);
    final n = DateTime.now();
    if (t.isAfter(DateTime(n.year, n.month, 1))) return;
    setState(() {
      y = t.year;
      m = t.month;
      done = loadDone();
    });
  }

  // اللي اتعدّ في اليوم ده (مجموع الدفعات)
  int dayCount(int d) {
    final raw = Repo.prefs.getString('pw${widget.level}_${y}_${m}_$d');
    if (raw == null) return 0;
    var s = 0;
    for (final x in raw.split(',')) {
      s += int.tryParse(x) ?? 0;
    }
    return s;
  }

  void snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white)),
      backgroundColor: pri(context),
      duration: const Duration(seconds: 2),
    ));

  void tick(int d, bool v) {
    HapticFeedback.selectionClick();
    setState(() => v ? done.add(d) : done.remove(d));
    Repo.prefs.setStringList(key, done.map((e) => '$e').toList());
    wirdTick.value++;
    if (v) {
      showHearts(context);
      checkMonth();
    }
  }

  // لو الشهر كله اتم: رسالة تهنئة (مرة واحدة)
  void checkMonth() {
    final flag = 'mc_$key';
    if (done.length >= days && !(Repo.prefs.getBool(flag) ?? false)) {
      Repo.prefs.setBool(flag, true);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ما شاء الله، أتممتَ الشهر كاملاً',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          content: Text('أتممتَ ورد المستوى ${levelNames[widget.level - 1]} لمدة $days يوماً\nهنيئاً لك يا حبيب رسول الله ﷺ',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.8)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تم', style: TextStyle(fontSize: 17)))],
        ),
      );
      showHearts(context);
    }
  }

  Future<void> openDay(int d) async {
    final now = DateTime.now();
    if (DateTime(y, m, d).isAfter(DateTime(now.year, now.month, now.day))) {
      snack('هذا اليوم لم يأتِ بعد');
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => WirdDayScreen(widget.level, y, m, d)));
    if (!mounted) return;
    setState(() => done = loadDone());
    checkMonth();
  }

  static const _wd = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

  // التاريخ الهجري بدون السنة (مثال: 9 شعبان)
  String _hijriShort(DateTime t) {
    final p = hijriNow(t).split(' ');
    return p.length > 2 ? p.sublist(0, p.length - 2).join(' ') : p.join(' ');
  }

  // زر دائري للتنقّل بين الشهور
  Widget _navBtn(BuildContext context, IconData ic, VoidCallback? on, String tip) {
    final ac = accent(context);
    final hint = Theme.of(context).hintColor;
    return Tooltip(
      message: tip,
      child: Material(
        color: on == null ? Colors.transparent : ac.withOpacity(.12),
        shape: CircleBorder(side: BorderSide(color: ac.withOpacity(on == null ? .2 : .6), width: 1.4)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: on,
          child: SizedBox(width: 44, height: 44, child: Icon(ic, color: on == null ? hint.withOpacity(.5) : ac)),
        ),
      ),
    );
  }

  Widget _monthBar(BuildContext context) {
    final ac = accent(context);
    final hint = Theme.of(context).hintColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: Row(children: [
        _navBtn(context, Icons.chevron_right, () => go(-1), 'الشهر السابق'),
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(months[m - 1], style: TextStyle(fontSize: 26, height: 1.25, fontWeight: FontWeight.bold, color: ac)),
            Text('$y', style: TextStyle(fontSize: 14, color: hint)),
          ]),
        ),
        _navBtn(context, Icons.chevron_left, isCurrent ? null : () => go(1), 'الشهر التالي'),
      ]),
    );
  }

  Widget _kv(IconData ic, String label, String value, Color gold) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: Row(children: [
          Icon(ic, size: 17, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(.85))),
          ),
          Text(value, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      );

  // بطاقة ملخّص الشهر: حلقة خرز بعدد الأيام المنجزة + أرقام مفيدة
  Widget _summary(BuildContext context, int monthTotal, int streak, int best) {
    final pc = pri(context), tc = tri(context), sc = sec(context);
    final gold = Color.lerp(sc, Colors.white, .2)!;
    final edge = Color.lerp(sc, Colors.white, .25)!;
    final c1 = Color.lerp(Color.lerp(pc, Colors.white, .06)!, tc, .15)!;
    final c2 = Color.lerp(Color.lerp(pc, tc, .3)!, Colors.black, .5)!;
    final prog = days == 0 ? 0.0 : done.length / days;
    final pct = (prog * 100).round();
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2]),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: edge, width: 1.8),
        boxShadow: [BoxShadow(color: pc.withOpacity(.45), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), border: Border.all(color: edge.withOpacity(.5), width: 1)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(children: [
              Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(edge)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('المستوى ${levelNames[widget.level - 1]}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('$goal صلاة يومياً', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.82))),
                      ]),
                    ),
                    for (var i = 0; i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Icon(i < widget.level ? Icons.star : Icons.star_border,
                            size: 17, color: gold.withOpacity(i < widget.level ? 1 : .45)),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  const OrnamentDivider(),
                  const SizedBox(height: 12),
                  Row(children: [
                    SizedBox(
                      width: 116,
                      height: 116,
                      child: Stack(alignment: Alignment.center, children: [
                        CustomPaint(size: const Size(116, 116), painter: _BeadRingPainter(prog, gold)),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('${done.length}',
                              style: const TextStyle(fontSize: 32, height: 1.1, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('من $days يوم', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.8))),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(children: [
                        _kv(Icons.local_fire_department, 'أيام متتالية', '$streak', gold),
                        Divider(height: 1, color: gold.withOpacity(.25)),
                        _kv(Icons.emoji_events, 'أفضل سلسلة', '$best', gold),
                        Divider(height: 1, color: gold.withOpacity(.25)),
                        _kv(Icons.favorite, 'صلوات الشهر', fmtNum(monthTotal), gold),
                        Divider(height: 1, color: gold.withOpacity(.25)),
                        _kv(Icons.trending_up, 'الإنجاز', '$pct٪', gold),
                      ]),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, IconData ic, String t) {
    final gold = Color.lerp(sec(context), Colors.white, .1)!;
    final ac = accent(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(children: [
        Icon(ic, size: 19, color: ac),
        const SizedBox(width: 8),
        Text(t, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ac)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [gold.withOpacity(.8), gold.withOpacity(0)],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // بطاقة اليوم: شارة التاريخ + اليوم والتاريخ الهجري + الحالة والتقدّم + دائرة التعليم ✓
  Widget _dayCard(BuildContext context, int d, int cnt, DateTime today, {bool isToday = false}) {
    final pc = pri(context), tc = tri(context), sc = sec(context);
    final ac = accent(context);
    final gold = Color.lerp(sc, Colors.white, .15)!;
    final hint = Theme.of(context).hintColor;
    final card = Theme.of(context).cardColor;
    final dark = isDark(context);
    final date = DateTime(y, m, d);
    final isDone = done.contains(d);
    final future = date.isAfter(today);
    final friday = date.weekday == DateTime.friday;
    final shown = isDone ? (cnt > goal ? cnt : goal) : cnt;
    final frac = goal == 0 ? 0.0 : (shown / goal).clamp(0.0, 1.0).toDouble();
    final String status;
    final Color statusColor;
    if (isDone) {
      status = 'تم بحمد الله';
      statusColor = ac;
    } else if (future) {
      status = 'لم يأتِ بعد';
      statusColor = hint;
    } else if (cnt > 0) {
      status = 'متبقي ${goal - cnt}';
      statusColor = ac;
    } else if (isToday) {
      status = 'ابدأ ورد اليوم';
      statusColor = ac;
    } else {
      status = 'لم يكتمل';
      statusColor = Theme.of(context).colorScheme.error.withOpacity(.85);
    }
    final fridayColor = dark ? gold : Color.lerp(sc, Colors.black, .3)!;
    return Opacity(
      opacity: future && !isDone ? .72 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isDone ? Color.alphaBlend(gold.withOpacity(dark ? .10 : .16), card) : card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isToday ? gold : (isDone ? gold.withOpacity(.6) : Colors.grey.withOpacity(.28)),
            width: isToday ? 2.2 : 1.2,
          ),
          boxShadow: [BoxShadow(color: (isToday ? gold : pc).withOpacity(isToday ? .28 : .10), blurRadius: isToday ? 14 : 8, offset: const Offset(0, 3))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => openDay(d),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(children: [
                // شارة رقم اليوم
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color.lerp(pc, tc, .35)!, Color.lerp(pc, Colors.black, .4)!],
                    ),
                    border: Border.all(color: isToday ? gold : gold.withOpacity(.35), width: isToday ? 2.4 : 1),
                  ),
                  child: Text('$d', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Flexible(
                        child: Text(_wd[date.weekday - 1],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: friday ? fridayColor : null)),
                      ),
                      if (friday) ...[const SizedBox(width: 4), Icon(Icons.auto_awesome, size: 13, color: fridayColor)],
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(10)),
                          child: Text('اليوم', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color.lerp(pc, Colors.black, .5))),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 1),
                    Text(_hijriShort(date), style: TextStyle(fontSize: 12, color: hint)),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                        child: Text(status,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: statusColor)),
                      ),
                      Text('$shown / $goal', style: TextStyle(fontSize: 12, color: hint)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 6,
                        backgroundColor: ac.withOpacity(.12),
                        valueColor: AlwaysStoppedAnimation<Color>(isDone ? gold : ac),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 6),
                // دائرة التعليم ✓
                Tooltip(
                  message: isDone ? 'إلغاء التعليم' : 'تعليم اليوم كمنجز',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => tick(d, !isDone),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? gold : Colors.transparent,
                            border: Border.all(color: isDone ? gold : ac.withOpacity(.45), width: 2),
                            boxShadow: [BoxShadow(color: gold.withOpacity(isDone ? .5 : 0), blurRadius: isDone ? 12 : 0)],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.check_rounded,
                                key: ValueKey(isDone),
                                size: 28,
                                color: isDone ? Color.lerp(pc, Colors.black, .45) : ac.withOpacity(.32)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    final streak = wirdStreak();
    final best = Repo.prefs.getInt('wird_best') ?? streak;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = [for (var d = 1; d <= days; d++) dayCount(d)];
    var monthTotal = 0;
    for (var d = 1; d <= days; d++) {
      final c = counts[d - 1];
      monthTotal += done.contains(d) ? (c > goal ? c : goal) : c;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى ${levelNames[widget.level - 1]}', style: const TextStyle(fontSize: 17)),
        actions: [
          if (isCurrent)
            IconButton(
              tooltip: 'الذهاب إلى اليوم',
              icon: const Icon(Icons.today),
              onPressed: () => _sc.scrollTo(index: now.day, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic),
            ),
          IconButton(
            tooltip: 'الإحصائيات',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      body: PageBackdrop(
        child: SafeArea(
          child: Column(children: [
            _monthBar(context),
            Expanded(
              child: ScrollablePositionedList.builder(
                key: ValueKey('$y-$m'),
                itemScrollController: _sc,
                itemCount: days + 1,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Column(children: [
                      _summary(context, monthTotal, streak, best),
                      if (isCurrent) ...[
                        _label(context, Icons.wb_sunny_outlined, 'ورد اليوم'),
                        _dayCard(context, now.day, counts[now.day - 1], today, isToday: true),
                      ],
                      _label(context, Icons.calendar_month, 'أيام الشهر'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('اضغط على اليوم لفتح ورده وعدّه، وعلى الدائرة لتعليمه ✓',
                              style: TextStyle(fontSize: 12.5, color: hint)),
                        ),
                      ),
                    ]);
                  }
                  return _dayCard(context, i, counts[i - 1], today, isToday: isCurrent && i == now.day);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// شاشة ورد اليوم: الورد مقسوم على 4 دفعات، وعدّاد بيحفظ كل حاجة
class WirdDayScreen extends StatefulWidget {
  final int level, y, m, d;
  const WirdDayScreen(this.level, this.y, this.m, this.d, {super.key});
  @override
  State<WirdDayScreen> createState() => _WirdDayScreenState();
}

class _WirdDayScreenState extends State<WirdDayScreen> {
  static const names = ['بعد الفجر', 'بعد الظهر', 'بعد العصر', 'بعد المغرب'];
  late List<int> parts;
  late int sel;

  int get goal => widget.level * 2000;
  int get pg => goal ~/ 4;
  String get pkey => 'pw${widget.level}_${widget.y}_${widget.m}_${widget.d}';
  String get dkey => 'p${widget.level}_${widget.y}_${widget.m}';
  int get total => parts.fold<int>(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    parts = [0, 0, 0, 0];
    final raw = Repo.prefs.getString(pkey);
    if (raw != null) {
      final xs = raw.split(',');
      for (var i = 0; i < 4 && i < xs.length; i++) {
        parts[i] = int.tryParse(xs[i]) ?? 0;
      }
    }
    final o = nextOpen(0);
    sel = o == -1 ? 3 : o;
  }

  // أول دفعة لسه ما خلصتش (بدءاً من مكان معيّن)
  int nextOpen(int from) {
    for (var k = 0; k < 4; k++) {
      final i = (from + k) % 4;
      if (parts[i] < pg) return i;
    }
    return -1;
  }

  void save() {
    Repo.prefs.setString(pkey, parts.join(','));
    wirdTick.value++;
  }

  void markDone(bool v) {
    final p = Repo.prefs;
    final set = (p.getStringList(dkey) ?? []).map(int.parse).toSet();
    if (v) {
      set.add(widget.d);
    } else {
      set.remove(widget.d);
    }
    p.setStringList(dkey, set.map((e) => '$e').toList());
    wirdTick.value++;
  }

  void add(int n) {
    if (n <= 0) return;
    final wasDone = total >= goal;
    final before = List<int>.from(parts);
    var left = n;
    var i = parts[sel] < pg ? sel : nextOpen(sel);
    while (left > 0 && i != -1) {
      final room = pg - parts[i];
      final take = left < room ? left : room;
      parts[i] += take;
      left -= take;
      if (parts[i] >= pg) i = nextOpen(i);
    }
    if (left > 0) parts[3] += left; // كل الدفعات خلصت: الزيادة تتحسب إضافية
    int? finished;
    for (var k = 0; k < 4; k++) {
      if (before[k] < pg && parts[k] >= pg) finished = k;
    }
    setState(() {
      if (i != -1) sel = i;
    });
    save();
    if (!wasDone && total >= goal) {
      markDone(true);
      final s = wirdStreak();
      HapticFeedback.heavyImpact();
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('هنيئاً لك يا حبيب رسول الله ﷺ',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          content: Text('أتممتَ ورد اليوم: $goal صلاة\nأيام متتالية: $s',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.8)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تم', style: TextStyle(fontSize: 17)))],
        ),
      );
      showHearts(context);
    } else if (finished != null) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('أتممت دفعة ${names[finished]}',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white)),
          backgroundColor: pri(context),
          duration: const Duration(seconds: 2),
        ));
    }
  }

  void undo() {
    if (parts[sel] <= 0) return;
    final wasDone = total >= goal;
    setState(() => parts[sel]--);
    save();
    if (wasDone && total < goal) markDone(false);
  }

  Future<void> askNumber() async {
    final c = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عدد'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'مثال: 100'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, int.tryParse(latinDigits(c.text.trim()))), child: const Text('إضافة')),
        ],
      ),
    );
    if (n != null && n > 0) add(n);
  }

  Widget tile(int i, Color a) {
    final full = parts[i] >= pg;
    final isSel = i == sel;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => sel = i),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? a : Colors.grey.withOpacity(.4), width: isSel ? 2.5 : 1),
            color: full ? a.withOpacity(.12) : null,
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (full) Icon(Icons.check_circle, size: 18, color: a),
              if (full) const SizedBox(width: 4),
              Text(names[i], style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Text('${parts[i]} / $pg', style: TextStyle(color: Theme.of(context).hintColor)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = accent(context);
    final hint = Theme.of(context).hintColor;
    final cur = parts[sel];
    final prog = cur >= pg ? 1.0 : cur / pg;
    final totalProg = total >= goal ? 1.0 : total / goal;
    return Scaffold(
      appBar: AppBar(
        title: Text('ورد يوم ${widget.d} ${months[widget.m - 1]} — المستوى ${levelNames[widget.level - 1]}',
            style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Column(children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text('$total / $goal صلاة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: a)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: totalProg, minHeight: 10),
                  ),
                ]),
              ),
            ),
            Row(children: [tile(0, a), tile(1, a)]),
            Row(children: [tile(2, a), tile(3, a)]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(onPressed: undo, icon: const Icon(Icons.undo), label: const Text('تراجع')),
              TextButton.icon(onPressed: askNumber, icon: const Icon(Icons.add_circle_outline), label: const Text('إضافة عدد')),
            ]),
            Expanded(
              child: LayoutBuilder(builder: (_, bc) {
                final room = bc.maxHeight - 8;
                final dd = room < 270 ? (room < 120 ? 120.0 : room) : 270.0;
                return Center(
                  child: BeadCounter(
                    size: dd,
                    count: cur,
                    progress: prog,
                    sub: 'من $pg',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      add(1);
                    },
                  ),
                );
              }),
            ),
            Text('اضغط على الدائرة للعدّ، أو أضف عدداً دفعة واحدة', style: TextStyle(fontSize: 13, color: hint)),
          ]),
        ),
      ),
    );
  }
}

// ---------- المزيد ----------
class MoreTab extends StatelessWidget {
  const MoreTab({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: double.infinity,
            color: pri(context),
            padding: const EdgeInsets.all(14),
            child: const Text('المزيد', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20))),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(14), children: [
            Card(
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeMode,
                builder: (_, m, __) => SwitchListTile(
                  secondary: Icon(Icons.dark_mode, color: accent(context)),
                  title: const Text('الوضع الليلي', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  value: m == ThemeMode.dark,
                  onChanged: (_) => toggleDark(),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: mixIcon(context, 0)),
                title: const Text('تعديل التقويم الهجري', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: ValueListenableBuilder<int>(
                  valueListenable: hijriOffset,
                  builder: (_, __, ___) => Text(hijriNow(DateTime.now())),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriScreen())),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.palette, color: mixIcon(context, 1)),
                title: const Text('الألوان', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: ValueListenableBuilder<int>(
                  valueListenable: paletteIndex,
                  builder: (_, i, __) => Text(palettes[i].name),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorsScreen())),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.bookmarks, color: mixIcon(context, 2)),
                title: const Text('علاماتي المرجعية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications_active, color: mixIcon(context, 3)),
                title: const Text('إعدادات الإشعارات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifSettingsScreen())),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.support_agent, color: mixIcon(context, 4)),
                title: const Text('أبلغ عن مشكلة أو اقتراح', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: const Text('تواصل معنا مباشرة على الواتساب'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => openLink(
                    context, 'https://wa.me/20${ContactCard.numbers.first.substring(1)}?text=${Uri.encodeComponent(reportMessage)}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: mixIcon(context, 5)),
                title: const Text('من نحن', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ),
            const SizedBox(height: 22),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: OrnamentDivider()),
            const SizedBox(height: 12),
            Center(
              child: Text('تحت إشراف فضيلة الشيخ عبدالرحمن مصطفى الأزهري',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w600, color: accent(context))),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ]);
}

class HijriScreen extends StatelessWidget {
  const HijriScreen({super.key});

  void change(int v) {
    if (v < -3 || v > 3) return;
    hijriOffset.value = v;
    Repo.prefs.setInt('hijri_off', v);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('تعديل التقويم الهجري')),
        body: ValueListenableBuilder<int>(
          valueListenable: hijriOffset,
          builder: (_, off, __) => ListView(padding: const EdgeInsets.all(20), children: [
            const Text(
              'قد يختلف التاريخ الهجري من بلد لآخر بسبب رؤية الهلال. زِد أو انقص يوماً ليطابق تاريخ بلدك، وسيتغير في الشاشة الرئيسية أيضاً.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.8),
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(hijriNow(DateTime.now()),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accent(context))),
            ),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filledTonal(
                  iconSize: 32, onPressed: off < 3 ? () => change(off + 1) : null, icon: const Icon(Icons.add)),
              SizedBox(
                width: 140,
                child: Text(
                  off == 0 ? 'بدون تعديل' : (off > 0 ? 'زيادة $off يوم' : 'نقص ${-off} يوم'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton.filledTonal(
                  iconSize: 32, onPressed: off > -3 ? () => change(off - 1) : null, icon: const Icon(Icons.remove)),
            ]),
            const SizedBox(height: 18),
            if (off != 0) Center(child: TextButton(onPressed: () => change(0), child: const Text('إلغاء التعديل'))),
          ]),
        ),
      );
}

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  // بطاقة ثيم: شريط بثلاثة ألوان + معاينة صغيرة + الاسم
  Widget swatch(AppPalette p, bool sel, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? p.primary : Colors.black12, width: sel ? 3 : 1),
            boxShadow: [BoxShadow(color: p.primary.withOpacity(sel ? .35 : .12), blurRadius: sel ? 12 : 6, offset: const Offset(0, 3))],
          ),
          child: Column(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: p.primary,
                      alignment: Alignment.center,
                      child: sel
                          ? const Icon(Icons.check_circle, color: Colors.white, size: 28)
                          : Container(
                              width: 30,
                              height: 6,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(.55), borderRadius: BorderRadius.circular(3)),
                            ),
                    ),
                  ),
                  Expanded(flex: 3, child: Container(color: p.accent)),
                  Expanded(flex: 3, child: Container(color: p.third)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Text(p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, height: 1.3, fontWeight: sel ? FontWeight.bold : FontWeight.w600, color: Colors.black87)),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الألوان')),
        body: ValueListenableBuilder<int>(
          valueListenable: paletteIndex,
          builder: (_, sel, __) => GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: palettes.length,
            itemBuilder: (_, k) => swatch(palettes[k], k == sel, () {
              paletteIndex.value = k;
              Repo.prefs.setInt('palette', k);
            }),
          ),
        ),
      );
}

// ---------- سبحة الصلاة على الحبيب ﷺ ----------
const _sebhaBase = [
  'اللهم صل وسلم وبارك على سيدنا محمد وعلى آله عدد كمال الله وكما يليق بكماله',
  'اللهم صل على سيدنا محمد النبي الأمي الحبيب العالي القدر العظيم الجاه وعلى آله وصحبه وسلم',
  'اللهم صل وسلم وبارك على سيدنا محمد كريم الآباء والأمهات وعلى آله',
  'اللهم صل على سيدنا محمد وعلى آله عدد ما في علم الله صلاة دائمة بدوام ملك الله',
  'اللهم صل على سيدنا محمد الحامد المحمود وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد النعيم المقيم وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد وعلى آل سيدنا محمد كما صليت على سيدنا إبراهيم وعلى آل سيدنا إبراهيم وبارك على سيدنا محمد وعلى آل سيدنا محمد كما باركت على سيدنا إبراهيم وعلى آل سيدنا إبراهيم في العالمين إنك حميد مجيد',
  'اللهم صل على سيدنا محمد الفاتح لما أغلق والخاتم لما سبق، ناصر الحق بالحق والهادي إلى صراطك المستقيم وعلى آله وصحبه حق قدره ومقداره العظيم',
  'اللهم صل على سيدنا محمد طب القلوب ودوائها وعافية الأبدان وشفائها ونور الأبصار وضيائها وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد النور الذاتي والسر الساري في سائر الأسماء والصفات وعلى آله وصحبه وسلم',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً فِيهَا الفَرَجُ القَرِيبُ وَالسِّرُّ العَجِيبُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةَ طَيٍّ لِأَوْصَافِ النَّفْسِ، صَلَاةً نَدْخُلُ بِهَا حَضْرَةَ القُدْسِ، وَتَنْعَمُ أَرْوَاحُنَا بِالأُنْسِ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً تَكُونُ كَشْفًا لِلْحِجَابِ، وَنُورًا لِلْكِتَابِ، وَنَجَاةً مِنَ العَذَابِ، وَاجْعَلْنَا مِنْ أَهْلِ الفِرْدَوْسِ الأَعْلَى بِلَا حِسَابٍ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً يُشْرِقُ بِهَا قَلْبِي، وَيَصْفُو بِهَا حُبِّي، وَيُغْفَرُ بِهَا ذَنْبِي، وَيَرْضَى بِهَا رَبِّي، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةَ نُورٍ وَفَرَجٍ، صَلَاةً تَرْفَعُ الحَرَجَ، وَتَعْلُو بِنَا أَعْلَى الدَّرَجِ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً تُمحَقُ بِهَا الأَغْيَارُ، وَتُغْفَرُ بِهَا الأَوْزَارُ، وَتُقْبَلُ بِهَا الأَعْذَارُ، وَتُرْفَعُ بِهَا الأَقْدَارُ، وَتُشْرِقُ بِهَا الأَنْوَارُ، وَتَطْهُرُ بِهَا الأَسْرَارُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ نُورِ الهُدَى، صَلَاةً تَجْلُو عَنِ القَلْبِ الصَّدَا، وَتَنْصُرُنَا بِنُورِهَا عَلَى العِدَا، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ طَبِيبِي وَحَبِيبِي، صَلَاةً تَجْعَلُنِي بِهَا مِنْ أَهْلِ الوَصْلِ وَالتَّقْرِيبِ، وَتَمْنَحُنِي بِهَا كُلَّ سِرٍّ عَجِيبٍ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ قَصْدِي وَمَطْلُوبِي، صَلَاةً أَصِلُ بِهَا إِلَى خَيْرِ مَحْبُوبٍ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ سَاكِنِ المَدِينَةِ، وَبِسِرِّهِ تُدَاوِي رُوحِيَ الحَزِينَةَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ فَاتِحِ الأَبْوَابِ، صَلَاةً تَسْتَغْرِقُ صُحُفَ الكِتَابِ، وَلَا يُحْصِيهَا الكُتَّابُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ هَدِيَّةِ اللَّهِ لِلْمُؤْمِنِينَ، وَرَحْمَةِ اللَّهِ لِلْعَالَمِينَ، شَمْسِ قُلُوبِ المُوَحِّدِينَ، وَبَدْرِ إِشْرَاقِ المُقَرَّبِينَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةَ الفَتْحِ الأَعْظَمِ، وَالنُّورِ الأَتَمِّ، وَالفَيْضِ الأَعَمِّ، صَلَاةً تَكُونُ لِلرُّوحِ بَلْسَم، وَلِقَائِلِهَا مَغْنَم، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحمَّدٍ الدَّاعِي إِلَى مَرْضَاتِكَ، صَلَاةَ فَتْحٍ لِنُورِ مُوَاصَلَاتِكَ، وَعَطْفٍ مِنْ فَيْضِ هِبَاتِكَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ عَدَدَ الحَصَى وَالرِّمَالِ، صَلَاةً تُحَقِّقُ بِهَا آمَالِي، وَأَنَالُ بِهَا مِنْكَ دَوَامَ الإِقْبَالِ، وَالفَتْحَ المُتَوَالِي فِي كُلِّ الأَيَّامِ وَاللَّيَالِي، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ الحَبِيبِ الشَّفِيعِ، صَلَاةً تُنْزِلُ الرَّحْمَةَ وَالبَرَكَةَ وَالفَرَجَ السَّرِيعَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ الرَّحْمَةِ المُهْدَاةِ، صَلَاةَ وَصْلٍ إِلَى مَوْلَاهُ، وَنُورٍ بِهِ نَلْقَاهُ، وَقُرْبٍ لَهُ وَرِضَاهُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً تُفِيضُ بِهَا لَنَا العُلُومَ اللَّدُنِّيَّةَ، وَتَمْنَحُنَا بِهَا أَسْرَارَكَ القُدْسِيَّةَ، وَتَحْفَظُنَا بِهَا مِنْ كُلِّ شَهْوَةٍ دَنِيَّةٍ، وَآفَةٍ جَلِيَّةٍ وَخَفِيَّةٍ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً لَا يُحْصِيهَا الكَاتِبُونَ، وَلَا يُدْرِكُ قَدْرَهَا العَارِفُونَ، بِسِرِّ كُنْ فَيَكُونُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلَاةً تَمْحُو بِهَا وِزْرِي، وَتَقْبَلُ بِهَا عُذْرِي، وَتُيَسِّرُ بِهَا أَمْرِي، وَأَكُونُ بِهَا مَعَهُ فِي حَشْرِي، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ عَدَدَ مَا كَتَبَ الكُتَّابُ الحَافِظُونَ، وَعَدَدَ مَا كَانَ وَمَا سيَكُونُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ بِقَدْرِ مَكَانَتِهِ عِنْدَكَ، صَلَاةً نَنَالُ بِهَا أَرْقَى مَعَانِي حُبِّكَ، وَتَنْهَلُّ بِهَا عَلَيْنَا أَعْظَمُ فُيُوضَاتِ قُرْبِكَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ نَصِيرِ المُسْتَضْعَفِينَ، وَإِمَامِ المُتَوَاضِعِينَ، وَحَبِيبِ رَبِّ العَالَمِينَ، صَلَاةً تَجْعَلُنَا بِهَا مِنَ الشَّاكِرِينَ، وَالذَّاكِرِينَ، وَالوَاصِلِينَ، وَالمُوصِلِينَ إِلَى مَعْرِفَتِكَ فِي كُلِّ وَقْتٍ وَحِينٍ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ تَعْدَادَ كَلِمَاتِ اللَّهِ، صَلَاةً لَا تُحْصِيهَا الأَقْلَامُ وَالأَفْوَاهُ، صَلَاةً نَنَالُ بِهَا النَّجَاةَ، وَتُسْعِدُنَا بِرِضَاهُ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
  'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَأُمِّهِ آمِنَةَ الأَمِينَةَ، صَلَاةً تَنْزِلُ بِهَا عَلَيْنَا السَّكِينَةَ، وَنَسْكُنُ بِهَا المَدِينَةَ، وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.',
];
const sebhaTargets = [33, 100, 300, 500, 1000];

// الصيغ الجاهزة + ما يضيفه المستخدم من أذكار خاصة (الصيغة المحذوفة تبقى فارغة للحفاظ على ترتيب الإحصائيات)
final List<String> sebhaFormulas = List<String>.of(_sebhaBase);

void loadCustomSebha() {
  sebhaFormulas
    ..clear()
    ..addAll(_sebhaBase)
    ..addAll(Repo.prefs.getStringList('sebha_custom') ?? const <String>[]);
}

void saveCustomSebha() => Repo.prefs.setStringList('sebha_custom', sebhaFormulas.sublist(_sebhaBase.length));


// ---------- سجل السبحة اليومي (بالتاريخ والصيغة) ----------
String sebhaDayKey(DateTime t) => 'sd_${t.year}_${t.month}_${t.day}';

List<int> sebhaDay(DateTime t) {
  final out = List<int>.filled(sebhaFormulas.length, 0);
  final raw = Repo.prefs.getString(sebhaDayKey(t));
  if (raw != null) {
    final xs = raw.split(',');
    for (var i = 0; i < out.length && i < xs.length; i++) {
      out[i] = int.tryParse(xs[i]) ?? 0;
    }
  }
  return out;
}

void logSebha(int formula, [int n = 1]) {
  final now = DateTime.now();
  final l = sebhaDay(now);
  if (formula < 0 || formula >= l.length) return;
  l[formula] += n;
  Repo.prefs.setString(sebhaDayKey(now), l.join(','));
}

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});
  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen> {
  late int sel, target, done, goals;
  late List<int> counts;

  @override
  void initState() {
    super.initState();
    final p = Repo.prefs;
    sel = p.getInt('sebha_sel') ?? 0;
    if (sel < 0 || sel >= sebhaFormulas.length || sebhaFormulas[sel].isEmpty) sel = 0;
    target = p.getInt('sebha_target') ?? 100;
    if (target < 1) target = 100;
    done = p.getInt('sebha_done') ?? 0;
    goals = p.getInt('sebha_goals') ?? 0;
    counts = List.generate(sebhaFormulas.length, (i) => p.getInt('sebha_c$i') ?? 0);
  }

  int get count => counts[sel];

  void save() {
    final p = Repo.prefs;
    p.setInt('sebha_c$sel', counts[sel]);
    p.setInt('sebha_done', done);
    p.setInt('sebha_goals', goals);
  }

  void tap() {
    HapticFeedback.lightImpact();
    var finished = false;
    logSebha(sel);
    setState(() {
      counts[sel]++;
      if (counts[sel] >= target) {
        // اكتمل الهدف: نحفظ عدده في مجموع الأهداف ونبدأ هدفاً جديداً من الصفر
        done += counts[sel];
        goals += 1;
        counts[sel] = 0;
        finished = true;
      }
    });
    save();
    if (finished) {
      HapticFeedback.heavyImpact();
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('هنيئاً لك يا حبيب رسول الله ﷺ',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تم', style: TextStyle(fontSize: 17)))],
        ),
      );
      showHearts(context);
    }
  }

  Future<void> confirmReset() => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('البداية من جديد؟'),
          content: const Text('سيعود عدّاد هذه الصيغة إلى الصفر.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                setState(() => counts[sel] = 0);
                save();
                Navigator.pop(ctx);
              },
              child: const Text('نعم'),
            ),
          ],
        ),
      );

  Future<void> confirmClearGoals() => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('حذف الأهداف السابقة؟'),
          content: const Text('سيُمسح مجموع الأهداف المكتملة، ويبدأ التجميع من جديد.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                setState(() {
                  done = 0;
                  goals = 0;
                });
                save();
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      );

  // ---------- العدد المستهدف ----------
  void setTarget(int t) {
    setState(() => target = t);
    Repo.prefs.setInt('sebha_target', t);
  }

  Future<void> customTarget() async {
    final v = await showDialog<String>(
      context: context,
      builder: (_) => const _InputDialog(
        title: 'اكتب العدد الذي تريده',
        hint: 'مثال: 700',
        okLabel: 'تعيين',
        number: true,
      ),
    );
    final n = v == null ? null : int.tryParse(v);
    if (n != null && mounted) setTarget(n);
  }

  // ---------- ذكر من عندك ----------
  Future<void> addCustom() async {
    final t = await showDialog<String>(
      context: context,
      builder: (_) => const _InputDialog(
        title: 'اكتب الذكر الذي تريده',
        hint: 'اكتب الصيغة أو الذكر هنا',
        okLabel: 'إضافة',
      ),
    );
    if (t == null || !mounted) return;
    sebhaFormulas.add(t);
    counts.add(0);
    saveCustomSebha();
    setState(() => sel = sebhaFormulas.length - 1);
    Repo.prefs.setInt('sebha_sel', sel);
  }

  Future<void> removeCustom(int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف هذا الذكر؟'),
        content: const Text('سيُحذف الذكر من قائمة الصيغ، ويبقى ما عددته منه محسوباً في الإحصائيات.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    sebhaFormulas[i] = '';
    saveCustomSebha();
    setState(() {
      if (sel == i) {
        sel = 0;
        Repo.prefs.setInt('sebha_sel', 0);
      }
    });
  }

  Future<void> pick() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
          final idxs = [for (var i = 0; i < sebhaFormulas.length; i++) if (sebhaFormulas[i].isNotEmpty) i];
          return SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(children: [
                    const Expanded(child: Text('اختر الصيغة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await addCustom();
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('ذكر من عندك'),
                    ),
                  ]),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: idxs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, k) {
                      final i = idxs[k];
                      final custom = i >= _sebhaBase.length;
                      return ListTile(
                        leading: CircleAvatar(radius: 15, child: Text('${k + 1}', style: const TextStyle(fontSize: 14))),
                        title: Text(sebhaFormulas[i], style: const TextStyle(fontSize: 17, height: 1.7, fontWeight: FontWeight.bold)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          i == sel ? Icon(Icons.check_circle, color: accent(ctx)) : Text('${counts[i]}'),
                          if (custom)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'حذف الذكر',
                              onPressed: () async {
                                await removeCustom(i);
                                setS(() {});
                              },
                            ),
                        ]),
                        onTap: () {
                          setState(() => sel = i);
                          Repo.prefs.setInt('sebha_sel', i);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          );
        }),
      );

  Widget stat(String label, String value, Color a) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: a)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
      ]);

  // ---------- كل الإعدادات في زر واحد ----------
  void openSettings() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
          final a = accent(ctx);
          final hint = Theme.of(ctx).hintColor;
          return SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    stat('الأهداف المكتملة', '$goals', a),
                    stat('مجموع الأهداف', '$done', a),
                    stat('عدّ هذه الصيغة', '$count', a),
                  ]),
                  const Divider(height: 24),
                  Text('الصيغة', style: TextStyle(color: hint)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await pick();
                          setS(() {});
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('اختيار صيغة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await addCustom();
                          setS(() {});
                        },
                        icon: const Icon(Icons.edit_note),
                        label: const Text('ذكر من عندك'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text('العدد المستهدف', style: TextStyle(color: hint)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in sebhaTargets)
                      ChoiceChip(
                        label: Text('$t', style: const TextStyle(fontSize: 16)),
                        selected: target == t,
                        onSelected: (_) {
                          setTarget(t);
                          setS(() {});
                        },
                      ),
                    if (!sebhaTargets.contains(target))
                      ChoiceChip(label: Text('$target', style: const TextStyle(fontSize: 16)), selected: true, onSelected: (_) {}),
                    ActionChip(
                      avatar: const Icon(Icons.edit, size: 18),
                      label: const Text('عدد آخر', style: TextStyle(fontSize: 16)),
                      onPressed: () async {
                        await customTarget();
                        setS(() {});
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await confirmReset();
                          setS(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('البداية من جديد'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          save();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                                content: Text('تم حفظ العدد', textAlign: TextAlign.center), duration: Duration(seconds: 1)));
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ العدد'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () async {
                      await confirmClearGoals();
                      setS(() {});
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('حذف الأهداف السابقة'),
                  ),
                ]),
              ),
            ),
          );
        }),
      );

  Widget _corner(Color gold, {double? top, double? bottom, double? left, double? right}) => Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Icon(Icons.auto_awesome, size: 15, color: gold.withOpacity(.85)),
      );

  // بطاقة الصيغة: خلفية متدرجة بألوان الثيم + إطار ذهبي مزدوج + نقش نجوم + زخارف الزوايا
  Widget _formulaBox(BuildContext context, Color pc, Color tc, Color gold) {
    final text = sebhaFormulas[sel];
    final textColor = Color.lerp(Colors.white, gold, .12)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(pc, Colors.black, .2)!, Color.lerp(Color.lerp(pc, tc, .4)!, Colors.black, .55)!],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: pc.withOpacity(.45), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold.withOpacity(.55), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(fit: StackFit.expand, children: [
            RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(gold))),
            LayoutBuilder(builder: (ctx, bc) {
              final w = bc.maxWidth - 40;
              final avail = bc.maxHeight - 76;
              final scaler = MediaQuery.textScalerOf(ctx);
              final dts = DefaultTextStyle.of(ctx).style;
              double heightAt(double f) {
                final tp = TextPainter(
                  text: TextSpan(text: text, style: dts.merge(TextStyle(fontSize: f, height: 1.8, fontWeight: FontWeight.bold))),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  textScaler: scaler,
                )..layout(maxWidth: w);
                final h = tp.height;
                tp.dispose();
                return h;
              }

              var fs = 32.0;
              while (fs > 14 && heightAt(fs) > avail) {
                fs -= 1;
              }
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(width: w * .5, child: const OrnamentDivider()),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: w,
                      child: Text(text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: fs, height: 1.8, fontWeight: FontWeight.bold, color: textColor)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: w * .5, child: const OrnamentDivider()),
                  ]),
                ),
              );
            }),
            _corner(gold, top: 8, right: 8),
            _corner(gold, top: 8, left: 8),
            _corner(gold, bottom: 8, right: 8),
            _corner(gold, bottom: 8, left: 8),
          ]),
        ),
      ),
    );
  }

  Widget _counter(double d, double prog) => BeadCounter(size: d, count: count, progress: prog, sub: 'من $target', onTap: tap);

  @override
  Widget build(BuildContext context) {
    final pc = pri(context), tc = tri(context);
    final gold = Color.lerp(sec(context), Colors.white, .2)!;
    final prog = count >= target ? 1.0 : count / target;
    final pct = (prog * 100).round();
    final hint = Theme.of(context).hintColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('سبحة الصلاة على الحبيب ﷺ', style: TextStyle(fontSize: 18)),
        actions: [IconButton(icon: const Icon(Icons.tune), tooltip: 'الإعدادات', onPressed: openSettings)],
      ),
      body: PageBackdrop(
        child: SafeArea(
          child: LayoutBuilder(builder: (ctx, bc) {
            final d = dmath.min(bc.maxWidth * .82, bc.maxHeight * .46).clamp(170.0, 350.0).toDouble();
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Column(children: [
                Expanded(child: _formulaBox(context, pc, tc, gold)),
                const SizedBox(height: 12),
                _counter(d, prog),
                const SizedBox(height: 6),
                Text('$pct٪ من الهدف  •  اضغط على الدائرة للعدّ',
                    style: TextStyle(fontSize: 12.5, color: hint)),
              ]),
            );
          }),
        ),
      ),
    );
  }
}

// نافذة إدخال رقم أو نص (للعدد المستهدف أو الذكر الخاص)
class _InputDialog extends StatefulWidget {
  final String title, hint, okLabel;
  final bool number;
  const _InputDialog({required this.title, required this.hint, required this.okLabel, this.number = false});
  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final c = TextEditingController();
  String? err;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void submit() {
    var v = c.text.trim();
    if (widget.number) {
      const ar = '٠١٢٣٤٥٦٧٨٩';
      for (var i = 0; i < 10; i++) {
        v = v.replaceAll(ar[i], '$i');
      }
      final n = int.tryParse(v);
      if (n == null || n < 1 || n > 1000000) {
        setState(() => err = 'أدخل عدداً صحيحاً بين 1 و 1000000');
        return;
      }
    } else if (v.isEmpty) {
      setState(() => err = 'اكتب الذكر أولاً');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(widget.title),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: widget.number ? TextInputType.number : TextInputType.multiline,
            inputFormatters: widget.number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))] : null,
            minLines: widget.number ? 1 : 3,
            maxLines: widget.number ? 1 : 6,
            textAlign: widget.number ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: widget.number ? 22 : 18),
            decoration: InputDecoration(hintText: widget.hint, errorText: err, border: const OutlineInputBorder()),
            onSubmitted: widget.number ? (_) => submit() : null,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            TextButton(onPressed: submit, child: Text(widget.okLabel)),
          ],
        ),
      );
}


// ---------- عدّاد دائري موحّد: حلقة خرز بلون الثيم + لوح داخلي بنقش نجوم + نبضة عند الضغط ----------
class BeadCounter extends StatefulWidget {
  final double size, progress;
  final int count;
  final String? sub;
  final VoidCallback onTap;
  const BeadCounter({super.key, required this.size, required this.count, required this.progress, required this.onTap, this.sub});
  @override
  State<BeadCounter> createState() => _BeadCounterState();
}

class _BeadCounterState extends State<BeadCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.size;
    final inner = d * .78;
    final pc = pri(context), tc = tri(context);
    final gold = Color.lerp(sec(context), Colors.white, .2)!;
    final bead = accent(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _pulse.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final v = _pulse.value;
          final t = Curves.easeOut.transform(v);
          final press = dmath.sin(dmath.pi * v);
          return SizedBox(
            width: d,
            height: d,
            child: Stack(alignment: Alignment.center, children: [
              // هالة ناعمة بلون الثيم خلف الدائرة
              Container(
                width: d * .94,
                height: d * .94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: bead.withOpacity(.16 + .26 * press), blurRadius: 30 + 14 * press, spreadRadius: 2)],
                ),
              ),
              // حلقة الخرز (التقدّم)
              CustomPaint(size: Size(d, d), painter: _BeadRingPainter(widget.progress, bead)),
              // موجة تتسع وتخفت عند الضغط
              if (v > 0 && v < 1)
                Transform.scale(
                  scale: 1 + .16 * t,
                  child: Container(
                    width: inner,
                    height: inner,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold.withOpacity((1 - t) * .75), width: 3),
                    ),
                  ),
                ),
              // اللوح الداخلي
              Transform.scale(
                scale: 1 - .035 * press,
                child: Container(
                  width: inner,
                  height: inner,
                  padding: EdgeInsets.all(inner * .045),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-.3, -.35),
                      radius: 1.0,
                      colors: [Color.lerp(pc, tc, .45)!, Color.lerp(pc, Colors.black, .55)!],
                    ),
                    border: Border.all(color: gold, width: 2.2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold.withOpacity(.5), width: 1)),
                    child: ClipOval(
                      child: Stack(alignment: Alignment.center, children: [
                        Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(gold)))),
                        // لمعة زجاجية في الأعلى
                        Positioned(
                          top: inner * .06,
                          child: Container(
                            width: inner * .52,
                            height: inner * .22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.elliptical(inner * .26, inner * .11)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white.withOpacity(.18), Colors.white.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(
                            width: inner * .68,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('${widget.count}',
                                  style: TextStyle(
                                    fontSize: inner * .36,
                                    height: 1.1,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(color: gold.withOpacity(.55), blurRadius: 12)],
                                  )),
                            ),
                          ),
                          SizedBox(width: inner * .42, child: const OrnamentDivider()),
                          if (widget.sub != null) ...[
                            const SizedBox(height: 4),
                            Text(widget.sub!, style: TextStyle(fontSize: inner * .085, fontWeight: FontWeight.bold, color: gold)),
                          ],
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// حلقة الخرز: خرزات بلون الثيم، المضاءة منها بقدر التقدّم
class _BeadRingPainter extends CustomPainter {
  final double value;
  final Color color;
  _BeadRingPainter(this.value, this.color);
  static const n = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - size.width * .04;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = color.withOpacity(.35),
    );
    final v = value.clamp(0.0, 1.0) * n;
    final lit = v.floor();
    final frac = v - lit;
    final hi = Color.lerp(color, Colors.white, .75)!;
    final lo = Color.lerp(color, Colors.black, .35)!;
    for (var i = 0; i < n; i++) {
      final ang = -dmath.pi / 2 + 2 * dmath.pi * i / n;
      final p = c + Offset(dmath.cos(ang), dmath.sin(ang)) * r;
      final major = i % 10 == 0;
      final br = size.width * (major ? .03 : .021);
      final on = i < lit;
      final part = i == lit && frac > 0;
      if (on || part) {
        final k = on ? 1.0 : frac;
        final o = .4 + .6 * k;
        canvas.drawCircle(
          p,
          br * 1.7,
          Paint()
            ..color = color.withOpacity(.5 * k)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawCircle(
          p,
          br,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-.4, -.4),
              colors: [hi.withOpacity(o), color.withOpacity(o), lo.withOpacity(o)],
              stops: const [0, .5, 1],
            ).createShader(Rect.fromCircle(center: p, radius: br)),
        );
      } else {
        canvas.drawCircle(p, br, Paint()..color = color.withOpacity(.2));
        canvas.drawCircle(
          p,
          br,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = color.withOpacity(.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BeadRingPainter o) => o.value != value || o.color != color;
}

// ---------- مؤشر تقدم مربع (بديل الدائرة) ----------
class SquareProgress extends StatelessWidget {
  final double size, value;
  final Color color;
  const SquareProgress({super.key, required this.size, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _SquareProgressPainter(value.clamp(0.0, 1.0), color),
      );
}

class _SquareProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  _SquareProgressPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    const w = 10.0;
    final rect = Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w);
    final r = size.width * .2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = color.withOpacity(.15);
    final bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = color;
    // يبدأ من منتصف الحافة العلوية ويلف مع عقارب الساعة
    final path = Path()
      ..moveTo(rect.center.dx, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r))
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: Radius.circular(r))
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: Radius.circular(r))
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r))
      ..close();
    canvas.drawPath(path, track);
    if (value <= 0) return;
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * value), bar);
    }
  }

  @override
  bool shouldRepaint(_SquareProgressPainter o) => o.value != value || o.color != color;
}

// ---------- الإحصائيات وسجل الشهور ----------
String fmtNum(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

int wirdYm(String k) {
  final p = k.split('_');
  return int.parse(p[0]) * 100 + int.parse(p[1]);
}

class WirdData {
  int total = 0; // مجموع صلوات المنهج من أول يوم
  int daysDone = 0; // عدد الأيام المكتملة
  final Map<String, int> perDay = {}; // 'سنة_شهر_يوم' -> صلوات اليوم (كل المستويات)
  final Map<String, int> monthTotal = {}; // 'سنة_شهر' -> صلوات الشهر
  final Map<String, Set<int>> monthDone = {}; // 'سنة_شهر' -> الأيام المكتملة
}

WirdData loadWirdData() {
  final p = Repo.prefs;
  final counts = <String, int>{}; // 'مستوى_سنة_شهر_يوم' -> المعدود
  final doneSet = <String>{};
  final re1 = RegExp(r'^pw(\d)_(\d+)_(\d+)_(\d+)$');
  final re2 = RegExp(r'^p(\d)_(\d+)_(\d+)$');
  for (final k in p.getKeys()) {
    final m1 = re1.firstMatch(k);
    if (m1 != null) {
      var sum = 0;
      for (final x in (p.getString(k) ?? '').split(',')) {
        sum += int.tryParse(x) ?? 0;
      }
      counts['${m1[1]}_${m1[2]}_${m1[3]}_${m1[4]}'] = sum;
      continue;
    }
    final m2 = re2.firstMatch(k);
    if (m2 != null) {
      for (final d in p.getStringList(k) ?? <String>[]) {
        doneSet.add('${m2[1]}_${m2[2]}_${m2[3]}_$d');
      }
    }
  }
  final data = WirdData();
  final all = <String>{...counts.keys, ...doneSet};
  for (final k in all) {
    final parts = k.split('_');
    final l = int.parse(parts[0]);
    final goal = l * 2000;
    final c = counts[k] ?? 0;
    final isDone = doneSet.contains(k);
    final v = isDone ? (c > goal ? c : goal) : c;
    final mk = '${parts[1]}_${parts[2]}';
    final dk = '$mk' '_${parts[3]}';
    data.total += v;
    data.perDay[dk] = (data.perDay[dk] ?? 0) + v;
    data.monthTotal[mk] = (data.monthTotal[mk] ?? 0) + v;
    if (isDone) data.monthDone.putIfAbsent(mk, () => <int>{}).add(int.parse(parts[3]));
  }
  for (final e in data.monthDone.values) {
    data.daysDone += e.length;
  }
  return data;
}


// ---------- الإحصاء التفصيلي: يوم / أسبوع / شهر ----------
const wirdSlotNames = ['بعد الفجر', 'بعد الظهر', 'بعد العصر', 'بعد المغرب'];
const weekDayNames = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

class DayStat {
  final List<int> slots, levels, sebha;
  final bool done;
  DayStat(this.slots, this.levels, this.sebha, this.done);
  int get wird => levels.fold<int>(0, (a, b) => a + b);
  int get sebhaTotal => sebha.fold<int>(0, (a, b) => a + b);
  int get total => wird + sebhaTotal;
}

DayStat dayStat(DateTime t) {
  final p = Repo.prefs;
  final slots = [0, 0, 0, 0];
  final levels = List<int>.filled(5, 0);
  var done = false;
  for (var l = 1; l <= 5; l++) {
    var c = 0;
    final raw = p.getString('pw${l}_${t.year}_${t.month}_${t.day}');
    if (raw != null) {
      final xs = raw.split(',');
      for (var i = 0; i < xs.length; i++) {
        final v = int.tryParse(xs[i]) ?? 0;
        c += v;
        if (i < 4) slots[i] += v;
      }
    }
    final isDone = (p.getStringList('p${l}_${t.year}_${t.month}') ?? const <String>[]).contains('${t.day}');
    if (isDone) done = true;
    final goal = l * 2000;
    levels[l - 1] = isDone ? (c > goal ? c : goal) : c;
  }
  return DayStat(slots, levels, sebhaDay(t), done);
}

class PeriodStat {
  int wird = 0, sebha = 0, doneDays = 0, activeDays = 0, elapsed = 0, bestTotal = 0;
  DateTime? bestDay;
  final slots = [0, 0, 0, 0];
  final levels = List<int>.filled(5, 0);
  final formulas = List<int>.filled(sebhaFormulas.length, 0);
  final days = <DayStat>[];
  final dates = <DateTime>[];
  int get total => wird + sebha;
  int get avg => elapsed == 0 ? 0 : (total / elapsed).round();
}

PeriodStat periodStat(DateTime from, int count) {
  final s = PeriodStat();
  final n = DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  for (var i = 0; i < count; i++) {
    final t = DateTime(from.year, from.month, from.day + i);
    final d = dayStat(t);
    s.days.add(d);
    s.dates.add(t);
    s.wird += d.wird;
    s.sebha += d.sebhaTotal;
    if (d.done) s.doneDays++;
    if (d.total > 0) s.activeDays++;
    if (!t.isAfter(today)) s.elapsed++;
    if (d.total > s.bestTotal) {
      s.bestTotal = d.total;
      s.bestDay = t;
    }
    for (var k = 0; k < 4; k++) {
      s.slots[k] += d.slots[k];
    }
    for (var k = 0; k < 5; k++) {
      s.levels[k] += d.levels[k];
    }
    for (var k = 0; k < s.formulas.length; k++) {
      s.formulas[k] += d.sebha[k];
    }
  }
  return s;
}

// ---------- تسجيل إتمام صلوات الأنوار / الصلوات المباركات / مناجاة الأشواق ----------
const anwarStatItems = [
  ['anwar', 'صلوات الأنوار على سيد الأبرار'],
  ['mub', 'الصلوات المباركات على سيد السادات'],
  ['munajat', 'مناجاة الأشواق'],
];

String _anwarDayKey(String k, DateTime t) => '${k}_dd_${t.year}_${t.month}_${t.day}';

int anwarTimes(String k) => Repo.prefs.getInt('${k}_done') ?? 0;

int anwarTimesIn(String k, DateTime start, int days) {
  var n = 0;
  for (var i = 0; i < days; i++) {
    n += Repo.prefs.getInt(_anwarDayKey(k, DateTime(start.year, start.month, start.day + i))) ?? 0;
  }
  return n;
}

DateTime? anwarLast(String k) {
  final ms = Repo.prefs.getInt('${k}_lastms');
  return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
}

void logAnwarDone(String k) {
  final p = Repo.prefs;
  final n = DateTime.now();
  p.setInt('${k}_done', anwarTimes(k) + 1);
  final dk = _anwarDayKey(k, n);
  p.setInt(dk, (p.getInt(dk) ?? 0) + 1);
  p.setInt('${k}_lastms', n.millisecondsSinceEpoch);
}

String timesText(int n) {
  if (n == 0) return 'لم تُقرأ بعد';
  if (n == 1) return 'مرة واحدة';
  if (n == 2) return 'مرتان';
  if (n <= 10) return '$n مرات';
  return '$n مرة';
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late int sy, sm;
  final sc = ScrollController();
  int mode = 0; // 0 يوم، 1 أسبوع، 2 شهر
  late DateTime anchor;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    sy = n.year;
    sm = n.month;
    anchor = DateTime(n.year, n.month, n.day);
  }

  DateTime periodStart(DateTime a) {
    if (mode == 0) return a;
    if (mode == 1) return DateTime(a.year, a.month, a.day - ((a.weekday + 1) % 7)); // الأسبوع بيبدأ السبت
    return DateTime(a.year, a.month, 1);
  }

  int periodDays(DateTime start) => mode == 0 ? 1 : (mode == 1 ? 7 : DateTime(start.year, start.month + 1, 0).day);

  DateTime shifted(int dir) {
    if (mode == 0) return DateTime(anchor.year, anchor.month, anchor.day + dir);
    if (mode == 1) return DateTime(anchor.year, anchor.month, anchor.day + 7 * dir);
    return DateTime(anchor.year, anchor.month + dir, 1);
  }

  bool canMove(int dir) {
    final n = DateTime.now();
    return !periodStart(shifted(dir)).isAfter(DateTime(n.year, n.month, n.day));
  }

  void move(int dir) {
    if (!canMove(dir)) return;
    setState(() => anchor = shifted(dir));
  }

  String fmtDate(DateTime t) => '${t.day} ${months[t.month - 1]}';

  String periodTitle(DateTime start, int count) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    if (mode == 0) {
      final pre = start == today ? 'اليوم — ' : (start == DateTime(today.year, today.month, today.day - 1) ? 'أمس — ' : '');
      return '$pre${fmtDate(start)} ${start.year}';
    }
    if (mode == 1) {
      final end = DateTime(start.year, start.month, start.day + 6);
      final cur = !today.isBefore(start) && !today.isAfter(end);
      return '${cur ? 'هذا الأسبوع\n' : ''}${fmtDate(start)} ← ${fmtDate(end)}';
    }
    return '${months[start.month - 1]} ${start.year}';
  }

  Widget kv(String label, String v, Color a, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5))),
          const SizedBox(width: 8),
          Text(v, style: TextStyle(fontSize: 15.5, fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: a)),
        ]),
      );

  Widget section(String title, Color a) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 2),
        child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: a)),
      );

  Widget weekBars(PeriodStat s, Color a, Color p) {
    var mx = 1;
    for (final d in s.days) {
      if (d.total > mx) mx = d.total;
    }
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return SizedBox(
      height: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < s.days.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(children: [
                SizedBox(
                  height: 12,
                  child: Text(s.days[i].total == 0 ? '' : fmtNum(s.days[i].total),
                      softWrap: false, overflow: TextOverflow.visible, style: const TextStyle(fontSize: 9)),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: s.days[i].total == 0 ? 0.0 : (s.days[i].total / mx < 0.04 ? 0.04 : s.days[i].total / mx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: s.days[i].done ? p : a.withOpacity(.55),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 14,
                  child: Text(weekDayNames[i],
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 9.5, fontWeight: s.dates[i] == today ? FontWeight.bold : FontWeight.normal)),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  // قسم التقديرات في الإحصاء التفصيلي (يوم: تقدير اليوم • أسبوع/شهر: عدد الأيام لكل تقدير)
  List<Widget> gradeWidgets(PeriodStat s, Color a) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final rows = <MapEntry<DateTime, DayGrade>>[];
    for (final t in s.dates) {
      if (t.isAfter(today)) continue;
      final g = dayGrade(t);
      if (g != null) rows.add(MapEntry(t, g));
    }
    if (rows.isEmpty) return const [];
    if (mode == 0) {
      final t = rows.first.key, g = rows.first.value;
      return [
        section('تقدير الورد', a),
        kv(t == today ? 'التقدير حتى الآن' : 'تقدير اليوم', '${g.name} • ${g.shown}٪', gradeColor(g.name), bold: true),
        kv('المستوى', levelNames[g.level - 1], a),
      ];
    }
    final done = rows.where((e) => e.key != today).toList();
    final w = <Widget>[section('تقدير الورد', a)];
    if (done.isEmpty) {
      w.add(kv('لا توجد أيام منتهية بعد', '—', a));
      return w;
    }
    for (final name in gradeOrder) {
      final c = done.where((e) => e.value.name == name).length;
      if (c > 0) w.add(kv(name, '$c يوم', gradeColor(name), bold: true));
    }
    final avg = (done.fold<double>(0, (x, e) => x + (e.value.pct > 100 ? 100 : e.value.pct)) / done.length).round();
    w.add(kv('متوسط النسبة', '$avg٪', a));
    if (mode == 1) {
      for (final e in done) {
        final i = s.dates.indexOf(e.key);
        w.add(kv('${weekDayNames[i]} ${fmtDate(e.key)}', '${e.value.name} • ${e.value.shown}٪', gradeColor(e.value.name)));
      }
    }
    return w;
  }

  List<Widget> anwarPeriodWidgets(DateTime start, int count, Color a) {
    final rows = <Widget>[];
    for (final it in anwarStatItems) {
      final c = anwarTimesIn(it[0], start, count);
      if (c > 0) rows.add(kv(it[1], timesText(c), a, bold: true));
    }
    if (rows.isEmpty) return const [];
    return [section('قراءة الصلوات والمناجاة', a), ...rows];
  }

  // بطاقة الإنجاز: كم مرة تمت قراءة كل واحدة
  Widget anwarCard(Color a, Color hint) {
    var total = 0;
    for (final it in anwarStatItems) {
      total += anwarTimes(it[0]);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.emoji_events, color: sec(context), size: 24),
            const SizedBox(width: 8),
            Text('إنجازات القراءة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
          ]),
          const SizedBox(height: 4),
          Center(child: Text('عدد مرات إتمام كل صيغة', style: TextStyle(fontSize: 12.5, color: hint))),
          const SizedBox(height: 6),
          for (final it in anwarStatItems)
            Builder(builder: (_) {
              final n = anwarTimes(it[0]);
              final last = anwarLast(it[0]);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(it[1], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 2),
                      Text(last == null ? 'لم تُتمّها بعد' : 'آخر مرة: ${last.day} ${months[last.month - 1]} ${last.year}',
                          style: TextStyle(fontSize: 12, color: hint)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: n > 0 ? a.withOpacity(.14) : hint.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: n > 0 ? a.withOpacity(.5) : hint.withOpacity(.3)),
                    ),
                    child: Text(n == 0 ? '—' : timesText(n),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: n > 0 ? a : hint)),
                  ),
                ]),
              );
            }),
          const Divider(height: 18),
          Row(children: [
            const Expanded(child: Text('إجمالي مرات الإتمام', style: TextStyle(fontSize: 14.5))),
            Text('$total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: a)),
          ]),
        ]),
      ),
    );
  }

  Widget detailCard(Color a, Color hint) {
    final start = periodStart(anchor);
    final count = periodDays(start);
    final s = periodStat(start, count);
    final single = mode == 0;
    final slotSum = s.slots.fold<int>(0, (x, y) => x + y);
    final aw = anwarPeriodWidgets(start, count, a);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('إحصاء تفصيلي', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 0, label: Text('اليوم')),
              ButtonSegment(value: 1, label: Text('الأسبوع')),
              ButtonSegment(value: 2, label: Text('الشهر')),
            ],
            selected: {mode},
            onSelectionChanged: (v) => setState(() {
              mode = v.first;
              final n = DateTime.now();
              anchor = DateTime(n.year, n.month, n.day);
            }),
          ),
          const SizedBox(height: 8),
          Row(children: [
            TextButton(
              onPressed: canMove(-1) ? () => move(-1) : null,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chevron_left), Text('السابق')]),
            ),
            Expanded(
              child: Text(periodTitle(start, count),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.5)),
            ),
            TextButton(
              onPressed: canMove(1) ? () => move(1) : null,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('التالي'), Icon(Icons.chevron_right)]),
            ),
          ]),
          const SizedBox(height: 4),
          Center(child: Text(fmtNum(s.total), style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: a))),
          Center(child: Text('صلاة على الحبيب ﷺ', style: TextStyle(color: hint))),
          if (mode == 1) ...[
            const SizedBox(height: 12),
            weekBars(s, a, pri(context)),
            const SizedBox(height: 4),
            Center(child: Text('العمود الغامق يعني أن اليوم قد اكتمل', style: TextStyle(fontSize: 12, color: hint))),
          ],
          section('الملخص', a),
          kv('منهج الصلاة', fmtNum(s.wird), a),
          kv('السبحة', fmtNum(s.sebha), a),
          if (single)
            kv('حالة ورد اليوم', s.doneDays > 0 ? 'تم ✓' : 'لم يكتمل', a)
          else ...[
            kv('أيام الورد المكتملة', '${s.doneDays} من $count', a),
            kv('أيام فيها صلاة', '${s.activeDays}', a),
            kv('المتوسط اليومي', fmtNum(s.avg), a),
            kv('أفضل يوم', s.bestDay == null ? '—' : '${fmtDate(s.bestDay!)}  •  ${fmtNum(s.bestTotal)}', a),
          ],
          ...aw,
          ...gradeWidgets(s, a),
          if (s.levels.any((v) => v > 0)) ...[
            section('منهج الصلاة حسب المستوى', a),
            for (var l = 0; l < 5; l++)
              if (s.levels[l] > 0) kv('المستوى ${levelNames[l]}', fmtNum(s.levels[l]), a),
          ],
          if (slotSum > 0) ...[
            section('منهج الصلاة حسب الدفعة', a),
            for (var k = 0; k < 4; k++)
              if (s.slots[k] > 0) kv(wirdSlotNames[k], fmtNum(s.slots[k]), a),
          ],
          if (s.formulas.any((v) => v > 0)) ...[
            section('السبحة حسب الصيغة', a),
            for (var k = 0; k < s.formulas.length; k++)
              if (s.formulas[k] > 0) kv(sebhaFormulas[k].isEmpty ? 'ذكر محذوف' : sebhaFormulas[k], fmtNum(s.formulas[k]), a),
          ],
          if (s.total == 0 && aw.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(child: Text('لا توجد صلاة مسجّلة في هذه الفترة', style: TextStyle(color: hint))),
            ),
          const SizedBox(height: 10),
          Text('ملحوظة: تُسجَّل السبحة بالتاريخ ابتداءً من هذا التحديث، لذا يظهر ما قبله في المجموع الكلي فقط، وتبدأ التقديرات أيضاً من هذا التحديث.',
              style: TextStyle(fontSize: 11.5, height: 1.5, color: hint)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  void go(int delta) {
    final t = DateTime(sy, sm + delta, 1);
    final n = DateTime.now();
    if (t.isAfter(DateTime(n.year, n.month, 1))) return;
    setState(() {
      sy = t.year;
      sm = t.month;
    });
  }

  Widget stat(String label, String v, Color a, Color hint) => Column(children: [
        Text(label, style: TextStyle(fontSize: 13, color: hint)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: a)),
      ]);

  Widget chart(List<int> vals, Set<int> doneDays, Color a, Color p) {
    var mx = 1;
    for (final v in vals) {
      if (v > mx) mx = v;
    }
    return SizedBox(
      height: 170,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < vals.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: vals[i] == 0 ? 0.0 : (vals[i] / mx < 0.03 ? 0.03 : vals[i] / mx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: doneDays.contains(i + 1) ? p : a.withOpacity(.55),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 12,
                  child: Text((i == 0 || (i + 1) % 5 == 0) ? '${i + 1}' : '',
                      softWrap: false, overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = loadWirdData();
    final pr = Repo.prefs;
    var sebha = pr.getInt('sebha_done') ?? 0;
    for (var i = 0; i < sebhaFormulas.length; i++) {
      sebha += pr.getInt('sebha_c$i') ?? 0;
    }
    final streak = wirdStreak();
    final best = pr.getInt('wird_best') ?? streak;
    final a = accent(context);
    final hint = Theme.of(context).hintColor;
    final mk = '${sy}_$sm';
    final days = DateTime(sy, sm + 1, 0).day;
    final vals = List<int>.generate(days, (i) => data.perDay['${mk}_${i + 1}'] ?? 0);
    final dset = data.monthDone[mk] ?? <int>{};
    final mTotal = data.monthTotal[mk] ?? 0;
    final n = DateTime.now();
    final isCur = sy == n.year && sm == n.month;
    final keys = <String>{...data.monthTotal.keys, ...data.monthDone.keys}.toList();
    keys.sort((x, y) => wirdYm(y).compareTo(wirdYm(x)));
    return Scaffold(
      appBar: AppBar(title: const Text('إحصائياتي', style: TextStyle(fontSize: 18))),
      body: ListView(controller: sc, padding: const EdgeInsets.all(14), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text('مجموع صلاتك على الحبيب ﷺ', style: TextStyle(color: hint)),
              const SizedBox(height: 4),
              Text(fmtNum(data.total + sebha), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: a)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                stat('منهج الصلاة', fmtNum(data.total), a, hint),
                stat('السبحة', fmtNum(sebha), a, hint),
              ]),
              const Divider(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                stat('أيام الورد', '${data.daysDone}', a, hint),
                stat('السلسلة الحالية', '$streak', a, hint),
                stat('أفضل سلسلة', '$best', a, hint),
              ]),
            ]),
          ),
        ),
        anwarCard(a, hint),
        detailCard(a, hint),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
            child: Column(children: [
              Row(children: [
                TextButton(
                  onPressed: () => go(-1),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chevron_left), Text('السابق')]),
                ),
                Expanded(
                  child: Text('${months[sm - 1]} $sy',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: isCur ? null : () => go(1),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('التالي'), Icon(Icons.chevron_right)]),
                ),
              ]),
              Text('${fmtNum(mTotal)} صلاة  •  ${dset.length} يوم مكتمل', style: TextStyle(color: a, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: chart(vals, dset, a, pri(context))),
              const SizedBox(height: 6),
              Text('كل عمود هو يوم، والعمود الغامق يعني أن اليوم قد اكتمل', style: TextStyle(fontSize: 12, color: hint)),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Text('سجل الشهور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
        ),
        if (keys.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('لا يوجد ورد مسجّل بعد. ابدأ من منهج الصلاة', style: TextStyle(color: hint))))
        else
          for (final k in keys)
            Card(
              child: ListTile(
                title: Text('${months[int.parse(k.split('_')[1]) - 1]} ${k.split('_')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${(data.monthDone[k] ?? <int>{}).length} يوم  •  ${fmtNum(data.monthTotal[k] ?? 0)} صلاة'),
                trailing: const Icon(Icons.bar_chart),
                selected: k == mk,
                onTap: () {
                  final pp = k.split('_');
                  setState(() {
                    sy = int.parse(pp[0]);
                    sm = int.parse(pp[1]);
                  });
                  sc.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                },
              ),
            ),
      ]),
    );
  }
}

// دايرة "ورد اليوم" في الشاشة الرئيسية
class TodayWirdCard extends StatelessWidget {
  const TodayWirdCard({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: wirdTick,
        builder: (context, _, __) {
          final p = Repo.prefs;
          final l = p.getInt('wird_level') ?? 0;
          final n = DateTime.now();
          var cnt = 0;
          var goal = 0;
          if (l >= 1 && l <= 5) {
            goal = l * 2000;
            final raw = p.getString('pw${l}_${n.year}_${n.month}_${n.day}');
            for (final x in (raw ?? '').split(',')) {
              cnt += int.tryParse(x) ?? 0;
            }
            final dn = (p.getStringList('p${l}_${n.year}_${n.month}') ?? <String>[]).contains('${n.day}');
            if (dn && cnt < goal) cnt = goal;
          }
          final prog = goal == 0 ? 0.0 : (cnt >= goal ? 1.0 : cnt / goal);
          final a = accent(context);
          final hint = Theme.of(context).hintColor;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (goal > 0) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WirdDayScreen(l, n.year, n.month, n.day)));
                } else {
                  shellIndex.value = 2;
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: CircularProgressIndicator(value: prog, strokeWidth: 8, color: a, backgroundColor: a.withOpacity(.15)),
                      ),
                      Text('${(prog * 100).round()}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
                    ]),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('ورد اليوم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        goal == 0
                            ? 'اختر مستواك من منهج الصلاة لتبدأ ورد اليوم'
                            : 'المستوى ${levelNames[l - 1]}  •  ${fmtNum(cnt)} / ${fmtNum(goal)}',
                        style: TextStyle(color: hint),
                      ),
                      if (goal > 0 && cnt >= goal)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('أتممت ورد اليوم، تقبّل الله', style: TextStyle(color: a, fontWeight: FontWeight.w600)),
                        ),
                      if (goal > 0 && cnt > 0)
                        Builder(builder: (_) {
                          final gn = gradeName(cnt * 100 / goal);
                          final gc = gradeColor(gn);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: gc.withOpacity(.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: gc.withOpacity(.6)),
                              ),
                              child: Text('التقدير حتى الآن: $gn',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: gc)),
                            ),
                          );
                        }),
                      if (goal > 0)
                        Builder(builder: (_) {
                          final yg = dayGrade(DateTime(n.year, n.month, n.day - 1));
                          if (yg == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text('تقدير أمس: ${yg.name} • ${yg.shown}٪', style: TextStyle(fontSize: 12.5, color: hint)),
                          );
                        }),
                    ]),
                  ),
                  const Icon(Icons.chevron_left),
                ]),
              ),
            ),
          );
        },
      );
}


// ---------- كمّل القراءة ----------
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: readTick,
        builder: (context, _, __) {
          final id = Repo.prefs.getString('last_book');
          if (id == null) return const SizedBox.shrink();
          final found = Repo.books.where((x) => x.id == id);
          if (found.isEmpty) return const SizedBox.shrink();
          final b = found.first;
          final page = Repo.lastPage(id) ?? 1;
          final total = pageCounts[id] ?? 1;
          final prog = page >= total ? 1.0 : page / total;
          final a = accent(context);
          final hint = Theme.of(context).hintColor;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openPdf(context, b, page),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(b.cover, width: 54, height: 76, fit: BoxFit.cover, cacheWidth: 160),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('كمّل القراءة', style: TextStyle(fontSize: 13, color: hint)),
                      Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: prog, minHeight: 6)),
                      const SizedBox(height: 4),
                      Text('صفحة $page من $total', style: TextStyle(fontSize: 12, color: hint)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.play_circle_fill, color: a, size: 36),
                ]),
              ),
            ),
          );
        },
      );
}

// ---------- الإبلاغ عن مشكلة ----------
const reportMessage = 'السلام عليكم، عندي ملاحظة على تطبيق مكتبة الأنوار المحمدية:\n';

// بيفتح رابط، ولو فشل بينسخ النص (لو اتحدد) ويقول للمستخدم
Future<void> openLink(BuildContext context, String url, {String? copy}) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && copy != null) {
    await Clipboard.setData(ClipboardData(text: copy));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم نسخ الرسالة، الصقها وأرسلها', textAlign: TextAlign.center)));
    }
  }
}

// ---------- التذكيرات (إشعارات) ----------
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

final FlutterLocalNotificationsPlugin _notifPlugin = FlutterLocalNotificationsPlugin();

NotificationDetails reminderDetails(String msg) => NotificationDetails(
      android: AndroidNotificationDetails(
        'anwar_reminders',
        'تذكيرات الأنوار',
        channelDescription: 'تذكير بالصلاة على الحبيب ﷺ',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(msg),
      ),
    );

Future<void> askNotifPermission() async {
  try {
    await _notifPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  } catch (_) {}
}

Future<void> initReminders() async {
  try {
    tzdata.initializeTimeZones();
    await _notifPlugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    if (Repo.prefs.getBool('notif_on') ?? true) await askNotifPermission();
    wirdTick.addListener(wirdChanged);
    await scheduleReminders();
  } catch (e) {
    debugPrint('reminders error: $e');
  }
}

// هل الساعة h داخل ساعات الراحة (من from لحد to، ممكن تعدّي نص الليل)
bool inQuietHours(int h, int from, int to) {
  if (from == to) return false;
  return from < to ? (h >= from && h < to) : (h >= from || h < to);
}

// بنجدول إشعارات الأسبوع الجاي دفعة واحدة، وكل ما التطبيق يتفتح أو الإعدادات تتغير بنعيد الجدولة
Future<void> scheduleReminders() async {
  try {
    await _notifPlugin.cancelAllPendingNotifications();
  } catch (_) {}
  try {
    await scheduleGeneric();
  } catch (e) {
    debugPrint('schedule error: $e');
  }
  await scheduleWirdReminders(cancelFirst: false);
}

// التذكيرات العامة (كل كام ساعة)
Future<void> scheduleGeneric() async {
  final p = Repo.prefs;
  if (!(p.getBool('notif_on') ?? true)) return;
  final hours = p.getInt('notif_hours') ?? 2;
  final quietOn = p.getBool('notif_quiet_on') ?? false;
  final qFrom = p.getInt('notif_qfrom') ?? 23;
  final qTo = p.getInt('notif_qto') ?? 7;
  final rnd = dmath.Random();
  var last = -1;
  var id = 1;
  final slots = (7 * 24) ~/ hours;
  for (var k = 1; k <= slots; k++) {
    final t = DateTime.now().add(Duration(hours: hours * k));
    if (quietOn && inQuietHours(t.hour, qFrom, qTo)) continue;
    var i = rnd.nextInt(reminderMessages.length);
    if (i == last) i = (i + 1) % reminderMessages.length;
    last = i;
    final msg = reminderMessages[i];
    await _notifPlugin.zonedSchedule(
      id: id++,
      title: 'مكتبة الأنوار المحمدية',
      body: msg,
      scheduledDate: tz.TZDateTime.from(t, tz.UTC),
      notificationDetails: reminderDetails(msg),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

// عدد صلوات يوم معيّن في مستوى معيّن (لو اليوم متعلّم "تم" يتحسب الهدف كامل)
int wirdCountFor(int l, DateTime t) {
  final p = Repo.prefs;
  var c = 0;
  for (final x in (p.getString('pw${l}_${t.year}_${t.month}_${t.day}') ?? '').split(',')) {
    c += int.tryParse(x) ?? 0;
  }
  final done = (p.getStringList('p${l}_${t.year}_${t.month}') ?? <String>[]).contains('${t.day}');
  final goal = l * 2000;
  return done ? (c > goal ? c : goal) : c;
}

// مجموع صلوات اليوم في كل المستويات
int wirdDayTotal(DateTime t) {
  var s = 0;
  for (var l = 1; l <= 5; l++) {
    s += wirdCountFor(l, t);
  }
  return s;
}

String timeLabel(int h, int m) {
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'ص' : 'م'}';
}

// ---------- تقديرات الورد اليومي ----------
const gradeOrder = ['امتياز', 'جيد جداً', 'جيد', 'مقبول', 'رسب'];

String gradeName(double pct) =>
    pct < 50 ? 'رسب' : (pct < 65 ? 'مقبول' : (pct < 75 ? 'جيد' : (pct < 85 ? 'جيد جداً' : 'امتياز')));

Color gradeColor(String g) {
  switch (g) {
    case 'امتياز':
      return const Color(0xFF2E7D32);
    case 'جيد جداً':
      return const Color(0xFF00897B);
    case 'جيد':
      return const Color(0xFF1565C0);
    case 'مقبول':
      return const Color(0xFFEF6C00);
    default:
      return const Color(0xFFC62828);
  }
}

class DayGrade {
  final int level, count;
  final double pct;
  final String name;
  const DayGrade(this.level, this.count, this.pct, this.name);
  int get shown => pct >= 100 ? 100 : pct.floor();
}

String _glKey(DateTime t) => 'gl_${t.year}_${t.month}_${t.day}';

// بنسجّل مستوى كل يوم، عشان التقدير يتحسب على مستوى اليوم نفسه حتى لو غيّرتي المستوى بعد كده
void recordGradeLevel() {
  final p = Repo.prefs;
  final l = p.getInt('wird_level') ?? 0;
  if (l < 1 || l > 5) return;
  final n = DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  DateTime? first;
  final x = (p.getString('gl_first') ?? '').split('_');
  if (x.length == 3) {
    final y = int.tryParse(x[0]), m = int.tryParse(x[1]), d = int.tryParse(x[2]);
    if (y != null && m != null && d != null) first = DateTime(y, m, d);
  }
  if (first == null) {
    first = today;
    p.setString('gl_first', '${today.year}_${today.month}_${today.day}');
  }
  // الأيام اللي فاتت من غير فتح التطبيق بتتسجّل بنفس المستوى (وتتقدّر بما اتسجّل فيها)
  for (var i = 1; i <= 30; i++) {
    final d = DateTime(today.year, today.month, today.day - i);
    if (d.isBefore(first)) break;
    if (!p.containsKey(_glKey(d))) p.setInt(_glKey(d), l);
  }
  p.setInt(_glKey(today), l);
}

// تقدير يوم معيّن (null لو اليوم ده ما اتسجّلش له مستوى)
DayGrade? dayGrade(DateTime t) {
  final l = Repo.prefs.getInt(_glKey(t));
  if (l == null || l < 1 || l > 5) return null;
  final c = wirdCountFor(l, t);
  final pct = c * 100 / (l * 2000);
  return DayGrade(l, c, pct, gradeName(pct));
}

// تقدير اليوم حسب نسبة ما تم من هدف المستوى:
// أقل من 50٪ رسب • 50–64٪ مقبول • 65–74٪ جيد • 75–84٪ جيد جداً • 85٪ فأكثر امتياز
String wirdGradeMessage(int l, int count) {
  final goal = l * 2000;
  final pct = count * 100 / goal;
  final shown = pct >= 100 ? 100 : pct.floor();
  final String head, tail;
  if (pct < 50) {
    head = 'لقد رسبت في الصلاة على النبي ﷺ هذا اليوم';
    tail = 'لا تيأس، غداً فرصة جديدة فسارع بالصلاة على الحبيب ﷺ';
  } else {
    final g = gradeName(pct);
    head = 'لقد حصلت على تقدير ($g) في الصلاة على النبي ﷺ هذا اليوم';
    tail = 'تقبل الله منك، وجعلها نوراً لك';
  }
  return '$head\nأتممت $shown٪ من ورد المستوى ${levelNames[l - 1]} (${fmtNum(count)} من ${fmtNum(goal)} صلاة)\n$tail';
}

// تذكير ورد اليوم (في الوقت اللي المستخدم يحدده) + ملخص الأسبوع يوم الجمعة
Future<void> scheduleWirdReminders({bool cancelFirst = true}) async {
  try {
    final p = Repo.prefs;
    recordGradeLevel();
    if (cancelFirst) {
      for (var i = 0; i < 8; i++) {
        await _notifPlugin.cancel(id: 5000 + i);
      }
      for (var i = 0; i < 4; i++) {
        await _notifPlugin.cancel(id: 6000 + i);
      }
      for (var i = 0; i < 8; i++) {
        await _notifPlugin.cancel(id: 7000 + i);
      }
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1) تذكير ورد اليوم: بيختفي لو الورد خلص
    final l = p.getInt('wird_level') ?? 0;
    if ((p.getBool('wird_rem_on') ?? true) && l >= 1 && l <= 5) {
      final goal = l * 2000;
      final h = p.getInt('wird_rem_h') ?? 20;
      final mi = p.getInt('wird_rem_m') ?? 0;
      for (var i = 0; i < 8; i++) {
        final at = DateTime(today.year, today.month, today.day + i, h, mi);
        if (!at.isAfter(now)) continue;
        String msg;
        if (i == 0) {
          final remaining = goal - wirdCountFor(l, today);
          if (remaining <= 0) continue;
          msg = 'متبقي لك ${fmtNum(remaining)} صلاة من ورد اليوم (المستوى ${levelNames[l - 1]})';
        } else {
          msg = 'ورد اليوم ${fmtNum(goal)} صلاة على الحبيب ﷺ، ابدأ ورد المستوى ${levelNames[l - 1]}';
        }
        await _notifPlugin.zonedSchedule(
          id: 5000 + i,
          title: 'ورد اليوم',
          body: msg,
          scheduledDate: tz.TZDateTime.from(at, tz.UTC),
          notificationDetails: reminderDetails(msg),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    // 1.5) تقدير ورد اليوم في آخر اليوم (النص بيتحسب من عدد النهارده، ويتحدّث مع كل تغيير في الورد)
    if ((p.getBool('grade_on') ?? true) && l >= 1 && l <= 5) {
      final gh = p.getInt('grade_h') ?? 23;
      final gm = p.getInt('grade_m') ?? 30;
      for (var i = 0; i < 8; i++) {
        final day = DateTime(today.year, today.month, today.day + i);
        final at = DateTime(day.year, day.month, day.day, gh, gm);
        if (!at.isAfter(now)) continue;
        final msg = wirdGradeMessage(l, wirdCountFor(l, day));
        await _notifPlugin.zonedSchedule(
          id: 7000 + i,
          title: 'تقدير ورد اليوم',
          body: msg,
          scheduledDate: tz.TZDateTime.from(at, tz.UTC),
          notificationDetails: reminderDetails(msg),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    // 2) ملخص الأسبوع كل جمعة الساعة 10 صباحاً
    if (p.getBool('week_rem_on') ?? true) {
      var f = DateTime(now.year, now.month, now.day, 10);
      while (f.weekday != DateTime.friday || !f.isAfter(now)) {
        f = DateTime(f.year, f.month, f.day + 1, 10);
      }
      for (var i = 0; i < 4; i++) {
        final target = DateTime(f.year, f.month, f.day + 7 * i, 10);
        var msg = 'اليوم الجمعة، أكثِر من الصلاة على النبي ﷺ';
        if (i == 0) {
          var sum = 0;
          for (var k = 6; k >= 0; k--) {
            final d = DateTime(target.year, target.month, target.day - k);
            if (d.isAfter(today)) break;
            sum += wirdDayTotal(d);
          }
          if (sum > 0) {
            msg = 'مجموع ورد أسبوعك: ${fmtNum(sum)} صلاة على النبي ﷺ، تقبل الله. وأكثِر من الصلاة عليه يوم الجمعة';
          }
        }
        await _notifPlugin.zonedSchedule(
          id: 6000 + i,
          title: 'ملخص الأسبوع',
          body: msg,
          scheduledDate: tz.TZDateTime.from(target, tz.UTC),
          notificationDetails: reminderDetails(msg),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  } catch (e) {
    debugPrint('wird reminders error: $e');
  }
}

// لما الورد يتغيّر نحدّث نص تذكير النهارده (بعد ثانيتين من آخر تغيير)
Timer? _wirdTimer;
void wirdChanged() {
  _wirdTimer?.cancel();
  _wirdTimer = Timer(const Duration(seconds: 2), () => scheduleWirdReminders());
}

Future<void> testReminder() async {
  try {
    await askNotifPermission();
    await _notifPlugin.show(
      id: 0,
      title: 'مكتبة الأنوار المحمدية',
      body: reminderMessages[0],
      notificationDetails: reminderDetails(reminderMessages[0]),
    );
  } catch (e) {
    debugPrint('test notif error: $e');
  }
}

String hourLabel(int h) {
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12 ${h < 12 ? 'ص' : 'م'}';
}

class NotifSettingsScreen extends StatefulWidget {
  const NotifSettingsScreen({super.key});
  @override
  State<NotifSettingsScreen> createState() => _NotifSettingsScreenState();
}

class _NotifSettingsScreenState extends State<NotifSettingsScreen> {
  late bool on, quietOn, wirdOn, weekOn, gradeOn;
  late int hours, qFrom, qTo, wH, wM, gH, gM;

  @override
  void initState() {
    super.initState();
    final p = Repo.prefs;
    on = p.getBool('notif_on') ?? true;
    hours = p.getInt('notif_hours') ?? 2;
    quietOn = p.getBool('notif_quiet_on') ?? false;
    qFrom = p.getInt('notif_qfrom') ?? 23;
    qTo = p.getInt('notif_qto') ?? 7;
    wirdOn = p.getBool('wird_rem_on') ?? true;
    weekOn = p.getBool('week_rem_on') ?? true;
    wH = p.getInt('wird_rem_h') ?? 20;
    wM = p.getInt('wird_rem_m') ?? 0;
    gradeOn = p.getBool('grade_on') ?? true;
    gH = p.getInt('grade_h') ?? 23;
    gM = p.getInt('grade_m') ?? 30;
  }

  // نحفظ الإعدادات ونعيد جدولة الإشعارات
  Future<void> apply() async {
    final p = Repo.prefs;
    await p.setBool('notif_on', on);
    await p.setInt('notif_hours', hours);
    await p.setBool('notif_quiet_on', quietOn);
    await p.setInt('notif_qfrom', qFrom);
    await p.setInt('notif_qto', qTo);
    await p.setBool('wird_rem_on', wirdOn);
    await p.setBool('week_rem_on', weekOn);
    await p.setInt('wird_rem_h', wH);
    await p.setInt('wird_rem_m', wM);
    await p.setBool('grade_on', gradeOn);
    await p.setInt('grade_h', gH);
    await p.setInt('grade_m', gM);
    if (on || wirdOn || weekOn || gradeOn) await askNotifPermission();
    await scheduleReminders();
  }

  Widget hourPicker(String label, int v, void Function(int) onSel) => Expanded(
        child: DropdownButtonFormField<int>(
          value: v,
          isExpanded: true,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
          items: [for (var h = 0; h < 24; h++) DropdownMenuItem(value: h, child: Text(hourLabel(h)))],
          onChanged: (x) {
            if (x != null) onSel(x);
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإشعارات', style: TextStyle(fontSize: 18))),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        Card(
          child: SwitchListTile(
            title: const Text('تفعيل التذكيرات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            subtitle: const Text('إشعار برسالة تذكّرك بالصلاة على النبي ﷺ'),
            value: on,
            onChanged: (v) {
              setState(() => on = v);
              apply();
            },
          ),
        ),
        if (on) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('تكرار الإشعار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  for (final h in const [1, 2, 3, 4, 6])
                    ChoiceChip(
                      label: Text(h == 1 ? 'كل ساعة' : (h == 2 ? 'كل ساعتين' : 'كل $h ساعات')),
                      selected: hours == h,
                      onSelected: (_) {
                        setState(() => hours = h);
                        apply();
                      },
                    ),
                ]),
              ]),
            ),
          ),
          Card(
            child: Column(children: [
              SwitchListTile(
                title: const Text('ساعات راحة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('بدون إشعارات في هذه الفترة'),
                value: quietOn,
                onChanged: (v) {
                  setState(() => quietOn = v);
                  apply();
                },
              ),
              if (quietOn)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(children: [
                    hourPicker('من', qFrom, (x) {
                      setState(() => qFrom = x);
                      apply();
                    }),
                    const SizedBox(width: 10),
                    hourPicker('إلى', qTo, (x) {
                      setState(() => qTo = x);
                      apply();
                    }),
                  ]),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14)),
              onPressed: testReminder,
              icon: const Icon(Icons.notifications_active),
              label: const Text('تجربة إشعار الآن', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
        Card(
          child: Column(children: [
            SwitchListTile(
              title: const Text('تذكير ورد اليوم', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              subtitle: const Text('إشعار في الوقت الذي تحدده: «متبقي لك كذا من ورد اليوم»، ويختفي لو أتممت الورد'),
              value: wirdOn,
              onChanged: (v) {
                setState(() => wirdOn = v);
                apply();
              },
            ),
            if (wirdOn)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('وقت التذكير'),
                trailing: Text(timeLabel(wH, wM), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: wH, minute: wM));
                  if (t != null && mounted) {
                    setState(() {
                      wH = t.hour;
                      wM = t.minute;
                    });
                    apply();
                  }
                },
              ),
          ]),
        ),
        Card(
          child: Column(children: [
            SwitchListTile(
              title: const Text('تقدير ورد اليوم', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'في آخر اليوم يصلك إشعار بتقديرك حسب نسبة ما أتممته من ورد مستواك: رسب (أقل من 50٪)، مقبول (50–64٪)، جيد (65–74٪)، جيد جداً (75–84٪)، امتياز (85٪ فأكثر)'),
              value: gradeOn,
              onChanged: (v) {
                setState(() => gradeOn = v);
                apply();
              },
            ),
            if (gradeOn)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('وقت إشعار التقدير'),
                trailing: Text(timeLabel(gH, gM), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: gH, minute: gM));
                  if (t == null || !mounted) return;
                  if (t.hour < 18) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                          content: Text('اختر وقتاً في آخر اليوم، بين 6 م و 11:59 م', textAlign: TextAlign.center)));
                    return;
                  }
                  setState(() {
                    gH = t.hour;
                    gM = t.minute;
                  });
                  apply();
                },
              ),
          ]),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('ملخص الأسبوع (الجمعة)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            subtitle: const Text('كل جمعة الساعة 10 صباحاً: مجموع ورد أسبوعك، وتذكير بالإكثار من الصلاة على النبي ﷺ'),
            value: weekOn,
            onChanged: (v) {
              setState(() => weekOn = v);
              apply();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'تتجدّد الإشعارات كلما فتحت التطبيق، وتُجهَّز للأسبوع القادم. وإن كان هاتفك يوقف التطبيق في الخلفية، فاسمح له من إعدادات البطارية.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: hint, height: 1.6),
          ),
        ),
      ]),
    );
  }
}


// ---------- العلامات المرجعية ----------
class Bm {
  final int page;
  final String note;
  const Bm(this.page, this.note);
}

List<Bm> loadBookmarks(String id) {
  final raw = Repo.prefs.getStringList('bm_$id') ?? <String>[];
  final out = <Bm>[];
  for (final s in raw) {
    final i = s.indexOf('|');
    final p = int.tryParse(i < 0 ? s : s.substring(0, i));
    if (p == null) continue;
    out.add(Bm(p, i < 0 ? '' : s.substring(i + 1)));
  }
  out.sort((a, b) => a.page.compareTo(b.page));
  return out;
}

void saveBookmarks(String id, List<Bm> list) {
  Repo.prefs.setStringList('bm_$id', list.map((b) => '${b.page}|${b.note.replaceAll('|', '/')}').toList());
}

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    final a = accent(context);
    final items = <Widget>[];
    for (final b in Repo.books) {
      final list = loadBookmarks(b.id);
      if (list.isEmpty) continue;
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
        child: Text(b.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: a)),
      ));
      for (final m in list) {
        items.add(Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${m.page}', style: const TextStyle(fontSize: 13))),
            title: Text(m.note.isEmpty ? 'صفحة ${m.page}' : m.note),
            subtitle: m.note.isEmpty ? null : Text('صفحة ${m.page}'),
            onTap: () async {
              await openPdf(context, b, m.page);
              if (mounted) setState(() {});
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final l = loadBookmarks(b.id)..removeWhere((x) => x.page == m.page);
                saveBookmarks(b.id, l);
                setState(() {});
              },
            ),
          ),
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('علاماتي المرجعية', style: TextStyle(fontSize: 18))),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('لا توجد علامات بعد.\nافتح أي كتاب واضغط على أيقونة العلامة في الأعلى لتحفظ صفحة.',
                    textAlign: TextAlign.center, style: TextStyle(color: hint, height: 1.8)),
              ),
            )
          : ListView(padding: const EdgeInsets.all(12), children: items),
    );
  }
}


// ---------- ربط السبحة بورد اليوم ----------


// ---------- شاشة الترحيب ----------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const Shell(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? const Color(0xFF0B5D3B),
        body: SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              builder: (_, v, child) => Opacity(opacity: v, child: child),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                        colors: [Color(0xFFC9A227), Color(0xFFF1DC8A), Color(0xFFC9A227), Color(0xFFFFF3C4), Color(0xFFC9A227)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFC9A227).withOpacity(.5), blurRadius: 30, spreadRadius: 3)],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: ClipOval(
                        child: Image.asset('assets/images/author.png', width: 230, height: 230, fit: BoxFit.cover, cacheWidth: 500)),
                  ),
                ),
                const SizedBox(height: 34),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'أهلاً بك يا حبيب رسول الله ﷺ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ArefRuqaa',
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      height: 1.8,
                      color: Color(0xFFFFF3C4),
                      shadows: [Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}


// ---------- صلوات الأنوار على سيد الأبرار (كتاب نصوص) ----------
const anwarFiles = [
  'assets/texts/anwar_1.txt',
  'assets/texts/anwar_2.txt',
  'assets/texts/anwar_3.txt',
];

class AnwarItem {
  final String? title;
  final String text;
  final List<String> parts; // لو فيها أكتر من صيغة بتتعرض كلها في نفس الصندوق
  const AnwarItem(this.title, this.text, [this.parts = const []]);
}

List<AnwarItem>? _anwarCache;

// السطر ((عنوان)) = عنوان للصيغة اللي بعده، والسطر {رقم} نص = صيغة
Future<List<AnwarItem>> loadAnwar() async {
  if (_anwarCache != null) return _anwarCache!;
  final items = <AnwarItem>[];
  final titleRe = RegExp(r'^\(\((.+?)\)\)$');
  final numRe = RegExp(r'^\{\d+\}\s*');
  for (final f in anwarFiles) {
    String raw;
    try {
      raw = await rootBundle.loadString(f);
    } catch (_) {
      continue;
    }
    String? pending;
    for (final line in raw.replaceAll('\uFEFF', '').split(RegExp(r'\r?\n'))) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final m = titleRe.firstMatch(t);
      if (m != null) {
        pending = m.group(1)!.trim();
        continue;
      }
      final body = t.replaceFirst(numRe, '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (body.isEmpty) continue;
      items.add(AnwarItem(pending, body));
      pending = null;
    }
  }
  if (items.isNotEmpty) _anwarCache = items;
  return items;
}

// ---------- الصلوات المباركات على سيد السادات (3 صيغ في الصندوق) ----------
const mubarakatFile = 'assets/texts/mubarakat.txt';
const _mubPerBox = 3;
List<AnwarItem>? _mubCache;

// كل سطر = صيغة. سطر "حرف ..." = عنوان القسم. كل مقطع بيبدأ بـ "اللهم" بيتقسم مجموعات من 3 صيغ
Future<List<AnwarItem>> loadMubarakat() async {
  if (_mubCache != null) return _mubCache!;
  String raw;
  try {
    raw = await rootBundle.loadString(mubarakatFile);
  } catch (_) {
    return const [];
  }
  final items = <AnwarItem>[];
  String? title;
  var stanza = <String>[];
  void flush() {
    for (var i = 0; i < stanza.length; i += _mubPerBox) {
      final part = stanza.sublist(i, dmath.min(i + _mubPerBox, stanza.length));
      items.add(AnwarItem(title, part.first, part));
    }
    stanza = <String>[];
  }

  for (final line in raw.replaceAll('\uFEFF', '').split(RegExp(r'\r?\n'))) {
    final t = line.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.isEmpty || t.startsWith('((')) continue;
    final n = norm(t);
    if (n.startsWith('حرف ') || n.startsWith('صيغه الحروف')) {
      flush();
      title = t;
      continue;
    }
    if (n.startsWith('اللهم')) flush();
    stanza.add(t);
  }
  flush();
  if (items.isNotEmpty) _mubCache = items;
  return items;
}

// ---------- مناجاة الأشواق (4 صيغ في الصندوق) ----------
const munajatFile = 'assets/texts/munajat.txt';
const _munPerBox = 4;
List<AnwarItem>? _munCache;

// السطر الأول عنوان (بيتخطّى). فقرة الافتتاح (اللهم...) وفقرة الختام (صلى الله عليك...) كل واحدة في صندوق لوحدها،
// وباقي الأسطر كل سطر صيغة وبيتقسّموا مجموعات من 4 صيغ في الصندوق
Future<List<AnwarItem>> loadMunajat() async {
  if (_munCache != null) return _munCache!;
  String raw;
  try {
    raw = await rootBundle.loadString(munajatFile);
  } catch (_) {
    return const [];
  }
  final items = <AnwarItem>[];
  var group = <String>[];
  void flush() {
    for (var i = 0; i < group.length; i += _munPerBox) {
      final part = group.sublist(i, dmath.min(i + _munPerBox, group.length));
      items.add(AnwarItem(null, part.first, part));
    }
    group = <String>[];
  }

  for (final line in raw.replaceAll('\uFEFF', '').split(RegExp(r'\r?\n'))) {
    final t = line.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.isEmpty || t.startsWith('((')) continue;
    final n = norm(t);
    if (n.startsWith('مناجاه')) continue;
    if (n.startsWith('اللهم') || n.startsWith('صلي الله عليك')) {
      flush();
      items.add(AnwarItem(null, t, [t]));
      continue;
    }
    group.add(t);
  }
  flush();
  if (items.isNotEmpty) _munCache = items;
  return items;
}

// ----- مدّ الحروف (كشيدة) بدل فراغات بين الكلمات -----
const _kDual = 'بتثجحخسشصضطظعغفقكلمنهيئ';
bool _isMark(int c) => (c >= 0x064B && c <= 0x065F) || c == 0x0670;
bool _isArLetter(int c) => c >= 0x0621 && c <= 0x064A;

List<int> _kashidaSpots(String w) {
  final plain = w.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  if (plain.length < 3 || plain.contains('لله')) return const [];
  final spots = <int>[];
  final u = w.codeUnits;
  var i = 0;
  while (i < u.length) {
    final c = u[i];
    if (!_isArLetter(c)) {
      i++;
      continue;
    }
    var j = i + 1;
    while (j < u.length && _isMark(u[j])) {
      j++;
    }
    if (i > 0 && j < u.length && _isArLetter(u[j]) && _kDual.contains(String.fromCharCode(c))) {
      final next = String.fromCharCode(u[j]);
      final lamAlef = c == 0x0644 && 'اأإآ'.contains(next);
      if (!lamAlef) spots.add(j);
    }
    i = j;
  }
  return spots;
}

String _stretchLine(String line, int n) {
  if (n <= 0) return line;
  final words = line.split(' ');
  final spots = [for (final w in words) _kashidaSpots(w)];
  final total = spots.fold<int>(0, (a, s) => a + s.length);
  if (total == 0) return line;
  if (n > total * 4) n = total * 4;
  final add = [for (final s in spots) List<int>.filled(s.length, 0)];
  var left = n;
  var pass = 0;
  while (left > 0 && pass < 400) {
    for (var w = 0; w < words.length && left > 0; w++) {
      final s = spots[w];
      if (s.isEmpty) continue;
      add[w][(pass + w) % s.length]++;
      left--;
    }
    pass++;
  }
  final out = <String>[];
  for (var w = 0; w < words.length; w++) {
    final word = words[w];
    final sb = StringBuffer();
    var last = 0;
    for (var k = 0; k < spots[w].length; k++) {
      sb.write(word.substring(last, spots[w][k]));
      sb.write('\u0640' * add[w][k]);
      last = spots[w][k];
    }
    sb.write(word.substring(last));
    out.add(sb.toString());
  }
  return out.join(' ');
}

double _textW(String s, TextStyle st, TextScaler sc) {
  final p = TextPainter(text: TextSpan(text: s, style: st), textDirection: TextDirection.rtl, textScaler: sc)..layout();
  final w = p.width;
  p.dispose();
  return w;
}

int _lineCount(String s, TextStyle st, TextScaler sc, double w) {
  final p = TextPainter(text: TextSpan(text: s, style: st), textDirection: TextDirection.rtl, textScaler: sc)..layout(maxWidth: w);
  final n = p.computeLineMetrics().length;
  p.dispose();
  return n;
}

// بيرجّع نفس النص مع مدّ بعض الحروف عشان كل سطر يملأ العرض من أوله لآخره
String kashidaJustify(String text, TextStyle st, double width, TextScaler sc) {
  if (width < 50) return text;
  final tp = TextPainter(text: TextSpan(text: text, style: st), textDirection: TextDirection.rtl, textScaler: sc)..layout(maxWidth: width);
  final count = tp.computeLineMetrics().length;
  final lines = <String>[];
  var pos = 0;
  while (pos < text.length && lines.length < count) {
    final b = tp.getLineBoundary(TextPosition(offset: pos));
    if (b.end <= pos) break;
    lines.add(text.substring(pos, b.end));
    pos = b.end;
  }
  tp.dispose();
  if (count < 2 || lines.length != count || pos != text.length) return text;
  final tat = _textW('\u0640', st, sc);
  if (tat <= 0) return text;
  final widths = [for (final l in lines) _textW(l.trimRight(), st, sc)];
  for (final f in const [1.0, 0.9, 0.8, 0.65, 0.5]) {
    final out = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final t = lines[i].trimRight();
      if (i == lines.length - 1) {
        out.add(t);
        continue;
      }
      final n = ((width - widths[i]) * f / tat).floor();
      out.add(_stretchLine(t, n));
    }
    final res = out.join('\n');
    if (_lineCount(res, st, sc, width) == count) return res;
  }
  return text;
}

// ---------- القصائد: شعر عمودي (صدر فوق وعجز تحته) بمدّ الحروف ----------
// زي _stretchLine بس بحدّ أعلى أكبر لمدّ الحروف، عشان الأشطر القصيرة تملا العرض
String _stretchCap(String line, int n, int cap) {
  if (n <= 0) return line;
  final words = line.split(' ');
  final spots = [for (final w in words) _kashidaSpots(w)];
  final total = spots.fold<int>(0, (a, s) => a + s.length);
  if (total == 0) return line;
  if (n > total * cap) n = total * cap;
  final add = [for (final s in spots) List<int>.filled(s.length, 0)];
  var left = n;
  var pass = 0;
  while (left > 0 && pass < 1000) {
    for (var w = 0; w < words.length && left > 0; w++) {
      final s = spots[w];
      if (s.isEmpty) continue;
      add[w][(pass + w) % s.length]++;
      left--;
    }
    pass++;
  }
  final out = <String>[];
  for (var w = 0; w < words.length; w++) {
    final word = words[w];
    final sb = StringBuffer();
    var last = 0;
    for (var k = 0; k < spots[w].length; k++) {
      sb.write(word.substring(last, spots[w][k]));
      sb.write('\u0640' * add[w][k]);
      last = spots[w][k];
    }
    sb.write(word.substring(last));
    out.add(sb.toString());
  }
  return out.join(' ');
}

// بيمدّ الشطر بالكشيدة لحد ما عرضه يبقى أقرب ما يمكن للعرض المطلوب
String _fitLine(String line, TextStyle st, TextScaler sc, double width) {
  final base = _textW(line, st, sc);
  final tat = _textW('\u0640', st, sc);
  if (tat <= 0 || base >= width) return line;
  var n = ((width - base) / tat).floor();
  var best = line;
  var bestDiff = width - base;
  for (var it = 0; it < 6; it++) {
    final s = _stretchCap(line, n, 12);
    final diff = width - _textW(s, st, sc);
    if (diff.abs() < bestDiff.abs()) {
      bestDiff = diff;
      best = s;
    }
    if (diff.abs() <= tat * 0.5) break;
    final step = (diff / tat).round();
    if (step == 0) break;
    n += step;
    if (n < 0) n = 0;
  }
  return best;
}

class _PoemLayout {
  final double fs, hw;
  final List<String> sadr, ajz;
  _PoemLayout(this.fs, this.hw, this.sadr, this.ajz);
}

// صفحة قصيدة: فاضية من العداد وأي أزرار، كل بيت سطرين (الصدر من اليمين والعجز تحته مزاح 8 مسافات لليسار)
class PoemScreen extends StatefulWidget {
  final String title, file;
  const PoemScreen({super.key, required this.title, required this.file});
  @override
  State<PoemScreen> createState() => _PoemScreenState();
}

class _PoemScreenState extends State<PoemScreen> {
  List<String> lines = const [];
  bool loading = true;
  _PoemLayout? _lay;
  String _layKey = '';

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.file).then((raw) {
      final l = <String>[];
      for (final x in raw.replaceAll('\uFEFF', '').split(RegExp(r'\r?\n'))) {
        final t = x.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (t.isEmpty || t.startsWith('((')) continue;
        l.add(t);
      }
      if (mounted) {
        setState(() {
          lines = l;
          loading = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => loading = false);
    });
  }

  _PoemLayout layoutFor(BuildContext ctx, double w) {
    final sc = MediaQuery.textScalerOf(ctx);
    final key = '${w.round()}|${sc.scale(10)}|${lines.length}';
    if (_lay != null && _layKey == key) return _lay!;
    final base = DefaultTextStyle.of(ctx).style.merge(const TextStyle(fontWeight: FontWeight.bold, height: 1.9));
    TextStyle st(double f) => base.copyWith(fontSize: f);
    final sadr = <String>[], ajz = <String>[];
    for (var i = 0; i < lines.length; i += 2) {
      sadr.add(lines[i]);
      if (i + 1 < lines.length) ajz.add(lines[i + 1]);
    }
    // حجم الخط: أكبر حجم يخلّي أطول شطر يتّسع في سطر واحد مع مسافة الـ 8 مسافات
    final probe = st(20);
    var m = 0.0;
    for (final h in lines) {
      final x = _textW(h, probe, sc);
      if (x > m) m = x;
    }
    final sp = _textW('د د', probe, sc) - _textW('دد', probe, sc);
    var fs = 20 * (w * 0.985) / (m + 8 * sp);
    fs = fs.clamp(12.0, 26.0).toDouble();
    final s = st(fs);
    final indent = 8 * (_textW('د د', s, sc) - _textW('دد', s, sc));
    final hw = w - indent;
    _lay = _PoemLayout(
      fs,
      hw,
      [for (final h in sadr) _fitLine(h, s, sc, hw)],
      [for (final h in ajz) _fitLine(h, s, sc, hw)],
    );
    _layKey = key;
    return _lay!;
  }

  Widget hemi(String t, TextStyle st, double hw) => SizedBox(
        width: hw,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(t, textDirection: TextDirection.rtl, softWrap: false, maxLines: 1, style: st),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 17))),
        body: PageBackdrop(
          child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : lines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('لم يتم العثور على ملف النص (${widget.file})', textAlign: TextAlign.center),
                      ),
                    )
                  : LayoutBuilder(builder: (ctx, bc) {
                      final lay = layoutFor(ctx, bc.maxWidth - 48);
                      final st = DefaultTextStyle.of(ctx).style.merge(const TextStyle(fontWeight: FontWeight.bold, height: 1.9)).copyWith(fontSize: lay.fs);
                      final dark = isDark(ctx);
                      return Container(
                        margin: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                        decoration: BoxDecoration(
                          color: dark ? Colors.black.withOpacity(.30) : Colors.white.withOpacity(.85),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: sec(ctx).withOpacity(.75), width: 1.4),
                          boxShadow: [BoxShadow(color: accent(ctx).withOpacity(.14), blurRadius: 14, offset: const Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                            itemCount: lay.sadr.length,
                            itemBuilder: (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: lay.fs * .6),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                Align(alignment: AlignmentDirectional.centerStart, child: hemi(lay.sadr[i], st, lay.hw)),
                                if (i < lay.ajz.length)
                                  Align(alignment: AlignmentDirectional.centerEnd, child: hemi(lay.ajz[i], st, lay.hw)),
                                SizedBox(height: lay.fs * .8),
                                const Center(child: SizedBox(width: 130, child: OrnamentDivider())),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }),
        ),
        ),
      ),
    );
  }
}

// ----- بطاقة الكتاب داخل قسم الصلاة والسلام -----
class AnwarTile extends StatelessWidget {
  const AnwarTile({super.key});
  @override
  Widget build(BuildContext context) => _ShelfCard(
        cover: const TasbihCover(width: 100, height: 140),
        title: 'صلوات الأنوار على سيد الأبرار',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnwarMenuScreen())),
        info: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _shelfPill(context, Icons.auto_awesome, 'صلوات ومناجاة'),
        ),
      );
}

// ----- غلاف «صلوات الأنوار»: سبحة بخرز لؤلؤي وذهبي بألوان الثيم -----
class TasbihCover extends StatelessWidget {
  final double width, height;
  const TasbihCover({super.key, this.width = 80, this.height = 112});

  @override
  Widget build(BuildContext context) {
    final p = pri(context), s = sec(context);
    final gold = Color.lerp(s, Colors.white, .2)!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(p, Colors.black, .3)!, p, Color.lerp(p, tri(context), .45)!],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.28), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _TasbihPainter(gold))),
        Positioned(
          top: height * .075,
          left: 0,
          right: 0,
          child: Text('صلوات الأنوار',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: width * .115, fontWeight: FontWeight.bold, color: gold, height: 1)),
        ),
      ]),
    );
  }
}

class _TasbihPainter extends CustomPainter {
  final Color gold;
  const _TasbihPainter(this.gold);

  static const pearl = Color(0xFFF3EEE2);

  void bead(Canvas c, Offset o, double r, Color base) {
    final rect = Rect.fromCircle(center: o, radius: r);
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.45),
          radius: 1.0,
          colors: [Color.lerp(base, Colors.white, .75)!, base, Color.lerp(base, Colors.black, .35)!],
          stops: const [0, .5, 1],
        ).createShader(rect),
    );
    c.drawCircle(o, r, Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = Colors.black.withOpacity(.2));
  }

  void star(Canvas c, Offset o, double r) {
    final path = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
      ..close();
    c.drawPath(path, Paint()..color = Colors.white.withOpacity(.7));
  }

  @override
  void paint(Canvas c, Size sz) {
    final w = sz.width, h = sz.height;

    // إطار ذهبي رفيع
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * .05, h * .036, w * .9, h * .928), Radius.circular(w * .05)),
      Paint()..style = PaintingStyle.stroke..strokeWidth = w * .012..color = gold.withOpacity(.85),
    );

    // نجوم صغيرة
    for (final o in [Offset(.14, .26), Offset(.86, .24), Offset(.12, .6), Offset(.88, .64), Offset(.5, .94)]) {
      star(c, Offset(w * o.dx, h * o.dy), w * .028);
    }

    final ctr = Offset(w / 2, h * .43);
    final R = w * .30;

    // هالة خلف السبحة
    c.drawCircle(
      ctr,
      R * 1.4,
      Paint()
        ..shader = RadialGradient(colors: [Colors.white.withOpacity(.24), Colors.white.withOpacity(0)])
            .createShader(Rect.fromCircle(center: ctr, radius: R * 1.4)),
    );

    // خيط السبحة + الخيط النازل للشرّابة
    final cord = Paint()..style = PaintingStyle.stroke..strokeWidth = w * .009..color = gold.withOpacity(.9);
    c.drawCircle(ctr, R, cord);
    final imamR = w * .068;
    final imam = Offset(w / 2, ctr.dy + R);
    c.drawLine(Offset(w / 2, imam.dy + imamR), Offset(w / 2, h * .82), cord);

    // خرز الحلقة (24 حبة، وكل 6 حبات حبة ذهبية)
    const n = 24;
    final r = w * .039;
    for (var i = 1; i < n; i++) {
      final ang = dmath.pi / 2 + 2 * dmath.pi * i / n;
      final pos = ctr + Offset(dmath.cos(ang), dmath.sin(ang)) * R;
      final marker = i % 6 == 0;
      bead(c, pos, marker ? r * 1.2 : r, marker ? gold : pearl);
    }

    // الإمام (الحبة الكبيرة) + حبتان على الخيط
    bead(c, imam, imamR, gold);
    bead(c, Offset(w / 2, h * .73), w * .03, pearl);
    bead(c, Offset(w / 2, h * .775), w * .03, pearl);

    // الشرّابة
    final tx = w / 2;
    final t0 = h * .84, t1 = h * .935;
    bead(c, Offset(tx, h * .82), w * .03, gold);
    c.drawPath(
      Path()
        ..moveTo(tx - w * .025, t0)
        ..lineTo(tx + w * .025, t0)
        ..lineTo(tx + w * .065, t1)
        ..lineTo(tx - w * .065, t1)
        ..close(),
      Paint()..color = gold.withOpacity(.55),
    );
    final thread = Paint()..strokeWidth = .8..color = gold;
    for (var k = -2; k <= 2; k++) {
      c.drawLine(Offset(tx + k * w * .012, t0), Offset(tx + k * w * .03, t1), thread);
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihPainter old) => old.gold != gold;
}

// ----- صفحة الخانات الخمس -----
class AnwarMenuScreen extends StatelessWidget {
  const AnwarMenuScreen({super.key});
  static const titles = [
    'صلوات الأنوار على سيد الأبرار',
    'الصلوات المباركات على سيد السادات',
    'مناجاة الأشواق',
    'قصيدة قل الحمدلله',
    'قصيدة أزكى الصلاة عليك',
  ];

  @override
  Widget build(BuildContext context) {
    final a = accent(context);
    return Scaffold(
      appBar: AppBar(title: const Text('صلوات الأنوار على سيد الأبرار', style: TextStyle(fontSize: 17))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: titles.length,
        itemBuilder: (_, k) => Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: a.withOpacity(.35))),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (k == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnwarScreen()));
              } else if (k == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnwarScreen(
                      title: titles[1],
                      prefsKey: 'mub',
                      loader: loadMubarakat,
                      emptyMsg: 'لم يتم العثور على ملف النص (mubarakat.txt داخل assets/texts)',
                    ),
                  ),
                );
              } else if (k == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnwarScreen(
                      title: titles[2],
                      prefsKey: 'munajat',
                      loader: loadMunajat,
                      emptyMsg: 'لم يتم العثور على ملف النص (munajat.txt داخل assets/texts)',
                    ),
                  ),
                );
              } else if (k == 3 || k == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PoemScreen(title: titles[k], file: k == 3 ? 'assets/texts/poem1.txt' : 'assets/texts/poem2.txt'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('هذا القسم سيُضاف قريباً', textAlign: TextAlign.center)));
              }
            },
            child: Container(
              height: 96,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: a.withOpacity(.15),
                  child: Text('${k + 1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(titles[k], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
                const Icon(Icons.chevron_left),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- احتفال الإتمام: قلوب خضراء كتيرة طالعة لفوق ----------
Path _heartPath(double s) {
  final p = Path();
  p.moveTo(0, s * .35);
  p.cubicTo(-s * .55, -s * .05, -s * .35, -s * .55, 0, -s * .22);
  p.cubicTo(s * .35, -s * .55, s * .55, -s * .05, 0, s * .35);
  p.close();
  return p;
}

class _GreenHeart {
  final double x, size, phase, amp, freq, rot;
  final int speed;
  final Color color;
  const _GreenHeart(this.x, this.size, this.phase, this.amp, this.freq, this.rot, this.speed, this.color);
}

class _HeartsPainter extends CustomPainter {
  final Animation<double> t;
  final List<_GreenHeart> hs;
  _HeartsPainter(this.t, this.hs) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in hs) {
      final p = (t.value * h.speed + h.phase) % 1.0;
      final y = size.height * (1.08 - p * 1.2);
      final x = size.width * h.x + dmath.sin(p * 2 * dmath.pi * h.freq + h.phase * 6) * h.amp;
      final fade = p < .08 ? p / .08 : (p > .85 ? (1 - p) / .15 : 1.0);
      final paint = Paint()..color = h.color.withOpacity((0.92 * fade).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(h.rot * dmath.sin(p * 2 * dmath.pi));
      canvas.drawPath(_heartPath(h.size), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HeartsPainter old) => false;
}

class _HeartsRain extends StatefulWidget {
  const _HeartsRain();
  @override
  State<_HeartsRain> createState() => _HeartsRainState();
}

class _HeartsRainState extends State<_HeartsRain> with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;
  late final List<_GreenHeart> hearts;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    final r = dmath.Random(11);
    const greens = [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A), Color(0xFF81C784), Color(0xFF00C853)];
    hearts = [
      for (var i = 0; i < 46; i++)
        _GreenHeart(
          r.nextDouble(),
          16 + r.nextDouble() * 24,
          r.nextDouble(),
          6 + r.nextDouble() * 16,
          1 + r.nextInt(2).toDouble(),
          .15 + r.nextDouble() * .3,
          r.nextInt(3) == 0 ? 2 : 1,
          greens[r.nextInt(greens.length)],
        ),
    ];
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(child: CustomPaint(painter: _HeartsPainter(ctrl, hearts), size: Size.infinite)),
      );
}

// ----- صفحة صلوات الأنوار: صيغة واحدة + عداد سبحة -----
class AnwarScreen extends StatefulWidget {
  final String title, prefsKey, emptyMsg;
  final Future<List<AnwarItem>> Function() loader;
  const AnwarScreen({
    super.key,
    this.title = 'صلوات الأنوار على سيد الأبرار',
    this.prefsKey = 'anwar',
    this.emptyMsg = 'لم يتم العثور على ملفات النصوص (anwar_1.txt و anwar_2.txt و anwar_3.txt داخل assets/texts)',
    this.loader = loadAnwar,
  });
  @override
  State<AnwarScreen> createState() => _AnwarScreenState();
}

class _AnwarScreenState extends State<AnwarScreen> {
  List<AnwarItem> items = const [];
  bool loading = true;
  int idx = 0, count = 0;
  final Map<String, String> _cache = {};

  @override
  void initState() {
    super.initState();
    idx = Repo.prefs.getInt('${widget.prefsKey}_idx') ?? 0;
    count = Repo.prefs.getInt('${widget.prefsKey}_count') ?? 0;
    widget.loader().then((l) {
      if (!mounted) return;
      setState(() {
        items = l;
        if (idx < 0 || idx >= l.length) idx = 0;
        loading = false;
      });
    });
  }

  void save() {
    Repo.prefs.setInt('${widget.prefsKey}_idx', idx);
    Repo.prefs.setInt('${widget.prefsKey}_count', count);
  }

  void go(int d) {
    if (items.isEmpty) return;
    setState(() => idx = (idx + d + items.length) % items.length);
    save();
  }

  bool _askingDone = false;

  void tap() {
    if (items.isEmpty || _askingDone) return;
    HapticFeedback.lightImpact();
    final last = idx == items.length - 1;
    setState(() {
      count++;
      if (!last) idx++;
    });
    save();
    if (last) showDone();
  }

  // بعد الانتهاء من كل الصيغ: رسالة إتمام + سؤال هل تبدأ من جديد
  Future<void> showDone() async {
    _askingDone = true;
    HapticFeedback.heavyImpact();
    logAnwarDone(widget.prefsKey);
    final times = anwarTimes(widget.prefsKey);
    const green = Color(0xFF2E7D32);
    final again = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => Stack(fit: StackFit.expand, children: [
        AlertDialog(
          icon: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: const Icon(Icons.favorite, size: 60, color: green),
          ),
          title: const Text('ألف مبروك!', textAlign: TextAlign.center, style: TextStyle(color: green, fontWeight: FontWeight.bold)),
          content: Text(
            'ما شاء الله، أتممت «${widget.title}»\nتقبّل الله منك وبارك فيك ورزقك شفاعة الحبيب ﷺ\n\nأتممتها: ${timesText(times)}\nعدّادك: $count\nهل تريد البدء من جديد؟',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.8),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لا')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('نعم، ابدأ من جديد')),
          ],
        ),
        const Positioned.fill(child: _HeartsRain()),
      ]),
    );
    _askingDone = false;
    if (again == true && mounted) {
      setState(() {
        idx = 0;
        count = 0;
      });
      save();
    }
  }

  Future<void> confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('البداية من جديد؟'),
        content: const Text('سيرجع العداد إلى صفر وتبدأ من الصيغة الأولى.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('نعم')),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        idx = 0;
        count = 0;
      });
      save();
    }
  }

  Widget buildBox(BuildContext context, Color a) {
    final it = items[idx];
    const style = TextStyle(fontSize: 21, height: 2.0, fontWeight: FontWeight.bold);
    // صندوق عميق بألوان الثيم: خلفية داكنة متدرجة + إطار ذهبي مزدوج + نقش نجوم، والنص كريمي
    final pc = pri(context), sc = sec(context);
    final gold = Color.lerp(sc, Colors.white, .2)!;
    final textStyle = style.copyWith(color: Color.lerp(Colors.white, gold, .12));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(pc, Colors.black, .2)!, Color.lerp(Color.lerp(pc, tri(context), .4)!, Colors.black, .55)!],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: pc.withOpacity(.45), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(.55), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(fit: StackFit.expand, children: [
            RepaintBoundary(child: CustomPaint(painter: _StarPatternPainter(gold))),
            LayoutBuilder(builder: (ctx, bc) {
              final w = bc.maxWidth - 36;
              final base = DefaultTextStyle.of(ctx).style.merge(style);
              final scaler = MediaQuery.textScalerOf(ctx);
              final parts = it.parts.isEmpty ? [it.text] : it.parts;
              String shownFor(int p) => _cache.putIfAbsent(
                  '$idx|$p|${w.round()}|${scaler.scale(10)}', () => kashidaJustify(parts[p], base, w, scaler));
              return SingleChildScrollView(
                key: ValueKey(idx),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: dmath.max(0.0, bc.maxHeight - 32)),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: w * .5, child: const OrnamentDivider()),
                      const SizedBox(height: 10),
                      if (it.title != null) ...[
                        SizedBox(
                          width: w,
                          child: Text(it.title!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.8, color: gold)),
                        ),
                        const SizedBox(height: 8),
                      ],
                      for (var p = 0; p < parts.length; p++) ...[
                        if (p > 0) const SizedBox(height: 10),
                        SizedBox(
                          width: w,
                          child: Text(shownFor(p), textAlign: TextAlign.justify, textDirection: TextDirection.rtl, style: textStyle),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(width: w * .5, child: const OrnamentDivider()),
                    ]),
                  ),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = accent(context);
    final cs = (MediaQuery.of(context).size.width * .38).clamp(124.0, 150.0).toDouble();
    final btn = FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 17)),
          actions: [IconButton(icon: const Icon(Icons.refresh), tooltip: 'البداية من جديد', onPressed: confirmReset)],
        ),
        body: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(widget.emptyMsg, textAlign: TextAlign.center),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: Column(children: [
                        Expanded(child: buildBox(context, a)),
                        const SizedBox(height: 10),
                        Text('${idx + 1} / ${items.length}', style: TextStyle(color: Theme.of(context).hintColor)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              style: btn,
                              onPressed: () => go(-1),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text('السابق'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          BeadCounter(size: cs, count: count, progress: (idx + 1) / items.length, onTap: tap),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              style: btn,
                              onPressed: () => go(1),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('التالي'),
                            ),
                          ),
                        ]),
                      ]),
                    ),
        ),
      ),
    );
  }
}
