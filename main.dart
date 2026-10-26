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
      28,
      (i) => _Heart(
        r.nextDouble(),
        18 + r.nextDouble() * 28,
        r.nextDouble() * 0.45,
        0.6 + r.nextDouble() * 0.4,
        r.nextDouble() * 6.28,
        8 + r.nextDouble() * 18,
        colors[r.nextInt(colors.length)],
      ),
    );
    c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))
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
          child: IndexedStack(index: i, children: const [HomeTab(), BooksTab(), PrayerTab(), FavsTab(), MoreTab()]),
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

class _HomeTabState extends State<HomeTab> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final res = Repo.search(q);
    return Column(children: [
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
            ? ListView(children: [
                const Clock(),
                const SizedBox(height: 14),
                const AuthorPhoto(),
                const SizedBox(height: 12),
                Center(child: Text('شاعر رسول الله ﷺ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent(context)))),
                const SizedBox(height: 4),
                Center(
                  child: Text('الشيخ عبدالرحمن مصطفى الأزهري',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                ),
                const SizedBox(height: 14),
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
                const TodayWirdCard(),
                const SizedBox(height: 10),
                const ContinueReadingCard(),
                const SizedBox(height: 24),
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
  @override
  Widget build(BuildContext context) {
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    return Column(children: [
      Text('${two(h)}:${two(now.minute)}:${two(now.second)} ${now.hour < 12 ? 'ص' : 'م'}',
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: accent(context))),
      Text('${now.day} ${months[now.month - 1]} ${now.year}', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
      const SizedBox(height: 4),
      Text(hijriNow(now), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: accent(context))),
    ]);
  }
}

class AuthorPhoto extends StatelessWidget {
  const AuthorPhoto({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: sec(context).withOpacity(.15)),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [sec(context), tri(context), pri(context), Color.lerp(sec(context), Colors.white, .5)!, sec(context)]),
              boxShadow: [BoxShadow(color: sec(context).withOpacity(.5), blurRadius: 22, spreadRadius: 2)],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(child: Image.asset('assets/images/author.png', width: 215, height: 215, fit: BoxFit.cover, cacheWidth: 640)),
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

const sectionSalat = BookSection('الصلاة والسلام على رسول الله ﷺ', Icons.favorite, ['salawat', 'zad']);
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
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(12),
        children: [for (final sec in bookSections) SectionCard(sec)],
      );
}

class SectionCard extends StatelessWidget {
  final BookSection sec;
  const SectionCard(this.sec, {super.key});
  @override
  Widget build(BuildContext context) {
    final list = sectionBooks(sec);
    final a = accent(context);
    final hint = Theme.of(context).hintColor;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectionScreen(sec))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: a.withOpacity(.15), child: Icon(sec.icon, color: a)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sec.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  Text(booksCountText(list.length + (sec.title == sectionSalat.title ? 1 : 0)), style: TextStyle(color: hint)),
                ]),
              ),
              const Icon(Icons.chevron_left),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (sec.title == sectionSalat.title)
                Container(
                  width: 46,
                  height: 64,
                  decoration: BoxDecoration(color: a.withOpacity(.15), borderRadius: BorderRadius.circular(5)),
                  child: Icon(Icons.auto_awesome, color: a),
                ),
              for (final b in list.take(5))
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(b.cover, width: 46, height: 64, fit: BoxFit.cover, cacheWidth: 140),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class SectionScreen extends StatelessWidget {
  final BookSection sec;
  const SectionScreen(this.sec, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(sec.title, style: const TextStyle(fontSize: 17))),
        body: ValueListenableBuilder<int>(
          valueListenable: readTick,
          builder: (context, _, __) {
            final list = sectionBooks(sec);
            final extra = sec.title == sectionSalat.title ? 1 : 0;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: list.length + extra,
              itemBuilder: (_, k) => k < extra ? const AnwarTile() : BookTile(list[k - extra]),
            );
          },
        ),
      );
}

class BookTile extends StatelessWidget {
  final Book b;
  const BookTile(this.b, {super.key});
  @override
  Widget build(BuildContext context) {
    final last = Repo.lastPage(b.id);
    final total = pageCounts[b.id] ?? 1;
    final prog = last == null ? 0.0 : (last >= total ? 1.0 : last / total);
    return Card(
      child: InkWell(
        onTap: () {
          if (Repo.index[b.id]!.isEmpty) {
            openPdf(context, b, Repo.lastPage(b.id) ?? 1);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(b)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(b.cover, width: 80, height: 112, fit: BoxFit.cover, cacheWidth: 240),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                if (last != null && last > 1) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: prog, minHeight: 6),
                  ),
                  const SizedBox(height: 4),
                  Text('وصلت لصفحة $last من $total  •  ${(prog * 100).round()}%',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                ],
              ]),
            ),
            const Icon(Icons.chevron_left),
          ]),
        ),
      ),
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
        child: Text('علّم على مستواك بالعلامة ✓ على الجنب، ومش هيتغيّر إلا لما تختار مستوى تاني بنفسك. فتح أي مستوى للفرجة مش بيغيّر مستواك.',
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
    setState(() => v ? done.add(d) : done.remove(d));
    Repo.prefs.setStringList(key, done.map((e) => '$e').toList());
    wirdTick.value++;
    if (v) {
      snack('زد يا حبيب رسول الله');
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
          title: const Text('ما شاء الله، أتممتم الشهر كاملاً',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          content: Text('أتممتم ورد المستوى ${levelNames[widget.level - 1]} لمدة $days يوماً\nهنيئا لكم يا أحباب رسول الله ﷺ',
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

  @override
  Widget build(BuildContext context) {
    const hs = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
    final hint = Theme.of(context).hintColor;
    final streak = wirdStreak();
    final best = Repo.prefs.getInt('wird_best') ?? streak;
    final pct = done.length * 100 ~/ days;
    final today = DateTime.now().day;
    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى ${levelNames[widget.level - 1]}', style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'الإحصائيات',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Row(children: [
            TextButton(
              onPressed: () => go(-1),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chevron_left), Text('السابق')]),
            ),
            Expanded(
              child: Text('${months[m - 1]} $y',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: isCurrent ? null : () => go(1),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('التالي'), Icon(Icons.chevron_right)]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          child: Column(children: [
            Text('أنجزت ${done.length} من $days يوم  •  ${done.length * goal} صلاة',
                style: TextStyle(fontSize: 16, color: accent(context))),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: done.length / days, minHeight: 10),
            ),
            const SizedBox(height: 4),
            Text('$pct% من الشهر', style: TextStyle(color: hint)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.local_fire_department, color: sec(context)),
                const SizedBox(width: 4),
                Text('أيام متتالية: $streak', style: const TextStyle(fontSize: 15)),
              ]),
              Text('أفضل سلسلة: $best', style: const TextStyle(fontSize: 15)),
            ]),
            const SizedBox(height: 4),
            Text('اضغط على اليوم لفتح ورده وعدّه', style: TextStyle(fontSize: 13, color: hint)),
          ]),
        ),
        Container(
          color: pri(context),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: const Row(children: [
            Expanded(child: Text('اليوم', style: hs)),
            Expanded(flex: 2, child: Text('ورد اليوم', style: hs)),
            SizedBox(width: 48, child: Text('تم', style: hs)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: days,
            itemBuilder: (_, k) {
              final d = k + 1;
              final isDone = done.contains(d);
              final cnt = dayCount(d);
              final shown = isDone ? (cnt > goal ? cnt : goal) : cnt;
              final bg = (isCurrent && d == today)
                  ? sec(context).withOpacity(.25)
                  : (k.isEven ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor);
              return Material(
                color: bg,
                child: InkWell(
                  onTap: () => openDay(d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(children: [
                      Expanded(child: Text('$d', style: const TextStyle(fontSize: 16))),
                      Expanded(flex: 2, child: Text('$shown / $goal', style: const TextStyle(fontSize: 16))),
                      SizedBox(
                        width: 48,
                        child: Checkbox(value: isDone, activeColor: pri(context), onChanged: (v) => tick(d, v ?? false)),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
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
          title: const Text('هنيئا لكم يا أحباب رسول الله ﷺ',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          content: Text('أتممتم ورد اليوم: $goal صلاة\nأيام متتالية: $s',
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
                final dd = room < 230 ? (room < 120 ? 120.0 : room) : 230.0;
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      add(1);
                    },
                    child: SizedBox(
                      width: dd,
                      height: dd,
                      child: Stack(alignment: Alignment.center, children: [
                        SquareProgress(size: dd, value: prog, color: a),
                        Container(
                          width: dd * .83,
                          height: dd * .83,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(dd * .15),
                            color: pri(context),
                            boxShadow: [BoxShadow(color: a.withOpacity(.4), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('$cur', style: TextStyle(fontSize: dd * .22, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('من $pg', style: TextStyle(fontSize: dd * .07, color: Colors.white70)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
            Text('اضغط على المربع للعدّ، أو أضف عدداً دفعة واحدة', style: TextStyle(fontSize: 13, color: hint)),
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
const sebhaFormulas = [
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
  final chipsCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final p = Repo.prefs;
    sel = p.getInt('sebha_sel') ?? 0;
    if (sel < 0 || sel >= sebhaFormulas.length) sel = 0;
    target = p.getInt('sebha_target') ?? 100;
    done = p.getInt('sebha_done') ?? 0;
    goals = p.getInt('sebha_goals') ?? 0;
    counts = List.generate(sebhaFormulas.length, (i) => p.getInt('sebha_c$i') ?? 0);
    // نوصّل صف الأرقام للعدد المختار عشان يبان من أول ما الشاشة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !chipsCtrl.hasClients) return;
      final i = sebhaTargets.indexOf(target);
      if (i < 0) return;
      chipsCtrl.jumpTo((i * 84.0 - 60).clamp(0.0, chipsCtrl.position.maxScrollExtent).toDouble());
    });
  }

  @override
  void dispose() {
    chipsCtrl.dispose();
    super.dispose();
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
        // الهدف خلص: نحفظ عدده في مجموع الأهداف ونبدأ هدف جديد من الصفر
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
          title: const Text('هنيئا لكم يا أحباب رسول الله ﷺ',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.7)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تم', style: TextStyle(fontSize: 17)))],
        ),
      );
      showHearts(context);
    }
  }

  void confirmReset() => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('البداية من جديد؟'),
          content: const Text('سيعود عداد هذه الصيغة إلى الصفر.'),
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

  void confirmClearGoals() => showDialog<void>(
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

  void pick() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sebhaFormulas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(radius: 15, child: Text('${i + 1}', style: const TextStyle(fontSize: 14))),
              title: Text(sebhaFormulas[i],
                  style: TextStyle(fontSize: 17, height: 1.7, fontWeight: FontWeight.bold)),
              trailing: i == sel ? Icon(Icons.check_circle, color: accent(ctx)) : Text('${counts[i]}'),
              onTap: () {
                setState(() => sel = i);
                Repo.prefs.setInt('sebha_sel', i);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      );

  Widget stat(String label, String value, Color a) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: a)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
      ]);

  @override
  Widget build(BuildContext context) {
    final a = accent(context);
    final fill = Theme.of(context).appBarTheme.backgroundColor ?? a;
    final prog = count >= target ? 1.0 : count / target;
    return Scaffold(
      appBar: AppBar(title: const Text('سبحة الصلاة على الحبيب ﷺ', style: TextStyle(fontSize: 18))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(children: [
            // المحتوى فوق مش بيتسحب، والعدّاد تحت ثابت دايماً
            Expanded(
              child: Column(children: [
            Flexible(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // الصيغة كلها باينة من غير سحب: لو طويلة الخط بيصغّر تلقائي على قد المساحة المتاحة
                    Flexible(
                      child: LayoutBuilder(builder: (ctx, bc) {
                        final scaler = MediaQuery.textScalerOf(ctx);
                        final text = sebhaFormulas[sel];
                        final dts = DefaultTextStyle.of(ctx).style;
                        double heightAt(double f) {
                          final tp = TextPainter(
                            text: TextSpan(text: text, style: dts.merge(TextStyle(fontSize: f, height: 1.7, fontWeight: FontWeight.bold))),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            textScaler: scaler,
                          )..layout(maxWidth: bc.maxWidth);
                          return tp.height;
                        }

                        var fs = 18.0;
                        while (fs > 10 && heightAt(fs) > bc.maxHeight) {
                          fs -= 0.5;
                        }
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: bc.maxWidth,
                            child: Text(text,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fs, height: 1.7, fontWeight: FontWeight.bold, color: a)),
                          ),
                        );
                      }),
                    ),
                    TextButton.icon(onPressed: pick, icon: const Icon(Icons.list), label: const Text('اختيار صيغة أخرى')),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              stat('الأهداف المكتملة', '$goals', a),
              stat('مجموع الأهداف', '$done', a),
            ]),
            const SizedBox(height: 10),
            Text('العدد المستهدف', style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 4),
            // الأرقام كلها في صف واحد، وبتسحبيه بإيدك يمين وشمال عشان تختاري العدد
            SizedBox(
              height: 48,
              child: ListView(
                controller: chipsCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  for (final t in sebhaTargets)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: ChoiceChip(
                          label: Text('$t', style: const TextStyle(fontSize: 16)),
                          selected: target == t,
                          onSelected: (_) {
                            setState(() => target = t);
                            Repo.prefs.setInt('sebha_target', t);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: confirmReset, icon: const Icon(Icons.refresh), label: const Text('البداية من جديد'))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    save();
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
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: confirmClearGoals,
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف الأهداف السابقة'),
              ),
            ),
              ]),
            ),
            LayoutBuilder(builder: (ctx, _) {
              final d = (MediaQuery.of(ctx).size.height * 0.21).clamp(135.0, 200.0).toDouble();
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Center(
                  child: GestureDetector(
                    onTap: tap,
                    child: SizedBox(
                      width: d,
                      height: d,
                      child: Stack(alignment: Alignment.center, children: [
                        SquareProgress(size: d, value: prog, color: a),
                        Container(
                          width: d * .83,
                          height: d * .83,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(d * .15),
                            color: fill,
                            boxShadow: [BoxShadow(color: a.withOpacity(.4), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: Text('$count', style: TextStyle(fontSize: d * .24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }
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

  Widget detailCard(Color a, Color hint) {
    final start = periodStart(anchor);
    final count = periodDays(start);
    final s = periodStat(start, count);
    final single = mode == 0;
    final slotSum = s.slots.fold<int>(0, (x, y) => x + y);
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
            Center(child: Text('العمود الغامق يعني اليوم اتم', style: TextStyle(fontSize: 12, color: hint))),
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
              if (s.formulas[k] > 0) kv(sebhaFormulas[k], fmtNum(s.formulas[k]), a),
          ],
          if (s.total == 0)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(child: Text('ما فيش صلاة متسجّلة في الفترة دي', style: TextStyle(color: hint))),
            ),
          const SizedBox(height: 10),
          Text('ملحوظة: السبحة بتتسجّل بالتاريخ من هذا التحديث، فاللي قبله بيظهر في المجموع الكلي بس. والتقديرات كمان بتبدأ من هذا التحديث.',
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
              Text('كل عمود هو يوم، والعمود الغامق يعني اليوم اتم', style: TextStyle(fontSize: 12, color: hint)),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Text('سجل الشهور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: a)),
        ),
        if (keys.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('لسه ما فيش ورد متسجّل. ابدأ من منهج الصلاة', style: TextStyle(color: hint))))
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
        var msg = 'اليوم الجمعة، أكثروا من الصلاة على النبي ﷺ';
        if (i == 0) {
          var sum = 0;
          for (var k = 6; k >= 0; k--) {
            final d = DateTime(target.year, target.month, target.day - k);
            if (d.isAfter(today)) break;
            sum += wirdDayTotal(d);
          }
          if (sum > 0) {
            msg = 'مجموع ورد أسبوعك: ${fmtNum(sum)} صلاة على النبي ﷺ، تقبل الله. وأكثروا من الصلاة عليه يوم الجمعة';
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
              subtitle: const Text('إشعار في الوقت اللي تحدده: «متبقي لك كذا من ورد اليوم»، ويختفي لو أتممت الورد'),
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
            'الإشعارات بتتجدّد كل ما تفتح التطبيق، وبتتجهز للأسبوع الجاي. لو الموبايل بيوقف التطبيق في الخلفية، اسمح له من إعدادات البطارية.',
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
                child: Text('لسه ما فيش علامات.\nافتح أي كتاب واضغط على أيقونة العلامة فوق لتحفظ صفحة.',
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
                    'أهلاً بكم أحباب رسول الله ﷺ',
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
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnwarMenuScreen())),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            const TasbihCover(),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('صلوات الأنوار على سيد الأبرار', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_left),
          ]),
        ),
      ),
    );
  }
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
            'ما شاء الله، أتممت «${widget.title}»\nتقبّل الله منك وبارك فيك ورزقك شفاعة الحبيب ﷺ\n\nعدّادك: $count\nهل تريد البدء من جديد؟',
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
    final fill = Theme.of(context).appBarTheme.backgroundColor ?? a;
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
                          SizedBox(
                            width: 124,
                            height: 124,
                            child: Material(
                              color: fill,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(22),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: tap,
                                child: Center(
                                  child: Text('$count',
                                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
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
