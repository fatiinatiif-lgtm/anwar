import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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
  final Color primary, accent, bg;
  const AppPalette(this.name, this.primary, this.accent, this.bg);
}

const palettes = [
  AppPalette('الأخضر والذهبي', Color(0xFF0B5D3B), Color(0xFFC9A227), Color(0xFFFBF7EC)),
  AppPalette('الأزرق', Color(0xFF1565C0), Color(0xFFE0A100), Color(0xFFF2F7FD)),
  AppPalette('الفيروزي', Color(0xFF00796B), Color(0xFFE0A100), Color(0xFFF0F8F7)),
  AppPalette('البنفسجي', Color(0xFF5E35B1), Color(0xFFD4A017), Color(0xFFF6F2FB)),
  AppPalette('العنابي', Color(0xFF8E1B2D), Color(0xFFC9A227), Color(0xFFFCF4F5)),
  AppPalette('الوردي', Color(0xFFAD1457), Color(0xFFC9A227), Color(0xFFFDF2F6)),
  AppPalette('البني', Color(0xFF6D4C41), Color(0xFFC9A227), Color(0xFFFAF5F0)),
];

final paletteIndex = ValueNotifier<int>(0);
final hijriOffset = ValueNotifier<int>(0);

class PaletteExt extends ThemeExtension<PaletteExt> {
  final Color primary, accent;
  const PaletteExt(this.primary, this.accent);
  @override
  PaletteExt copyWith({Color? primary, Color? accent}) => PaletteExt(primary ?? this.primary, accent ?? this.accent);
  @override
  PaletteExt lerp(ThemeExtension<PaletteExt>? other, double t) {
    if (other is! PaletteExt) return this;
    return PaletteExt(Color.lerp(primary, other.primary, t)!, Color.lerp(accent, other.accent, t)!);
  }
}

Color pri(BuildContext c) => Theme.of(c).extension<PaletteExt>()?.primary ?? const Color(0xFF0B5D3B);
Color sec(BuildContext c) => Theme.of(c).extension<PaletteExt>()?.accent ?? const Color(0xFFC9A227);
Color accent(BuildContext c) => isDark(c) ? sec(c) : pri(c);
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
  ];
  static final Map<String, List<Entry>> index = {};
  static late SharedPreferences prefs;
  static final favs = ValueNotifier<List<Entry>>([]);

  static Book byId(String id) => books.firstWhere((b) => b.id == id);

  // آخر صفحة وقف عندها القارئ في كل كتاب
  static int? lastPage(String id) => prefs.getInt('last_$id');
  static void saveLast(String id, int p) => prefs.setInt('last_$id', p);

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

const pageCounts = {'borda': 32, 'diaa': 216, 'elhama': 28, 'elmaw': 50, 'hekma': 177, 'menhatu': 135, 'mesk': 185, 'nabd': 11, 'raheeq': 240, 'salawat': 110, 'sera': 40, 'tagaliyat': 280, 'tohfa': 217};

Future<void> openPdf(BuildContext c, Book b, int page) {
  final max = pageCounts[b.id] ?? 1;
  return Navigator.push(c, MaterialPageRoute(builder: (_) => PdfScreen(b, page.clamp(1, max))));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Repo.init();
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
            final ext = PaletteExt(p.primary, p.accent);
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
                colorScheme: ColorScheme.fromSeed(seedColor: p.primary, primary: p.primary, secondary: p.accent),
                scaffoldBackgroundColor: p.bg,
                appBarTheme: AppBarTheme(backgroundColor: p.primary, foregroundColor: Colors.white),
                useMaterial3: true,
                extensions: [ext],
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(seedColor: p.primary, brightness: Brightness.dark),
                scaffoldBackgroundColor: Color.lerp(const Color(0xFF121212), p.primary, .12),
                cardColor: Color.lerp(const Color(0xFF1E1E1E), p.primary, .15),
                appBarTheme: AppBarTheme(backgroundColor: Color.lerp(p.primary, Colors.black, .35), foregroundColor: Colors.white),
                useMaterial3: true,
                extensions: [ext],
              ),
              home: const Shell(),
            );
          },
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
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(index: i, children: const [HomeTab(), BooksTab(), PrayerTab(), FavsTab(), AboutTab(), MoreTab()]),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: i,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: accent(context),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (v) => setState(() => i = v),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'الكتب'),
            BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'منهج الصلاة'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'المفضلة'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'من نحن'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
          ],
        ),
      );
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
                const SizedBox(height: 16),
                const AuthorPhoto(),
                const SizedBox(height: 12),
                Center(child: Text('شاعر رسول الله ﷺ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent(context)))),
                const SizedBox(height: 14),
                Center(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TextScreen('التعريف بالكاتب', 'assets/texts/author.txt'))),
                    icon: const Icon(Icons.person),
                    label: const Text('التعريف بالكاتب'),
                  ),
                ),
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
              gradient: SweepGradient(colors: [sec(context), pri(context), sec(context), Color.lerp(sec(context), Colors.white, .5)!, sec(context)]),
              boxShadow: [BoxShadow(color: sec(context).withOpacity(.5), blurRadius: 22, spreadRadius: 2)],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(child: Image.asset('assets/images/author.png', width: 170, height: 170, fit: BoxFit.cover, cacheWidth: 400)),
            ),
          ),
        ),
      );
}

// ---------- الكتب ----------
class BooksTab extends StatelessWidget {
  const BooksTab({super.key});
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: Repo.books.length,
        itemBuilder: (_, k) {
          final b = Repo.books[k];
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
                  Expanded(child: Text(b.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                  const Icon(Icons.chevron_left),
                ]),
              ),
            ),
          );
        },
      );
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
    positions.itemPositions.addListener(onPositions);
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
class TextView extends StatelessWidget {
  final String asset;
  const TextView(this.asset, {super.key});
  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: rootBundle.loadString(asset),
        builder: (_, s) => SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SelectableText(s.data?.replaceAll('\uFEFF', '') ?? '', style: const TextStyle(fontSize: 18, height: 1.9)),
        ),
      );
}

class TextScreen extends StatelessWidget {
  final String title, asset;
  const TextScreen(this.title, this.asset, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: TextView(asset));
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(width: double.infinity, color: pri(context), padding: const EdgeInsets.all(14),
            child: const Text('من نحن', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20))),
        const Expanded(child: TextView('assets/texts/about_us.txt')),
        const ContactCard(),
      ]);
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
  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    sy = n.year; sm = n.month; sd = n.day;
  }

  void open(int level) {
    final n = DateTime.now();
    final y = auto ? n.year : sy, m = auto ? n.month : sm, d = auto ? n.day : sd;
    Navigator.push(context, MaterialPageRoute(builder: (_) => LevelScreen(level, y, m, d)));
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
      for (var l = 1; l <= 5; l++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: l.isOdd ? pri(context) : Color.lerp(sec(context), Colors.black, .3)),
            onPressed: () => open(l),
            child: Text('المستوى ${levelNames[l - 1]}  •  ${l * 2000} صلاة يومياً', style: const TextStyle(fontSize: 17)),
          ),
        ),
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
    ]);
  }
}

class LevelScreen extends StatefulWidget {
  final int level, y, m, hl;
  const LevelScreen(this.level, this.y, this.m, this.hl, {super.key});
  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late Set<int> done;
  String get key => 'p${widget.level}_${widget.y}_${widget.m}';
  int get goal => widget.level * 2000;
  @override
  void initState() {
    super.initState();
    done = (Repo.prefs.getStringList(key) ?? []).map(int.parse).toSet();
  }

  void tick(int d, bool v) {
    setState(() => v ? done.add(d) : done.remove(d));
    Repo.prefs.setStringList(key, done.map((e) => '$e').toList());
    if (v) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('زد يا حبيب رسول الله', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white)),
          backgroundColor: pri(context),
          duration: const Duration(seconds: 2),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime(widget.y, widget.m + 1, 0).day;
    const hs = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
    return Scaffold(
      appBar: AppBar(title: Text('المستوى ${levelNames[widget.level - 1]} — ${months[widget.m - 1]} ${widget.y}', style: const TextStyle(fontSize: 16))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text('أنجزت ${done.length} من $days يوم  •  ${done.length * goal} صلاة', style: TextStyle(fontSize: 16, color: accent(context))),
        ),
        Container(
          color: pri(context),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: const Row(children: [
            Expanded(child: Text('اليوم', style: hs)),
            Expanded(flex: 2, child: Text('الهدف اليومي', style: hs)),
            SizedBox(width: 48, child: Text('تم', style: hs)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: days,
            itemBuilder: (_, k) {
              final d = k + 1;
              return Container(
                color: d == widget.hl ? sec(context).withOpacity(.25) : (k.isEven ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Expanded(child: Text('$d', style: const TextStyle(fontSize: 16))),
                  Expanded(flex: 2, child: Text('$goal صلاة', style: const TextStyle(fontSize: 16))),
                  SizedBox(width: 48, child: Checkbox(value: done.contains(d), activeColor: pri(context), onChanged: (v) => tick(d, v ?? false))),
                ]),
              );
            },
          ),
        ),
      ]),
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
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: accent(context)),
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
                leading: Icon(Icons.palette, color: accent(context)),
                title: const Text('الألوان', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: ValueListenableBuilder<int>(
                  valueListenable: paletteIndex,
                  builder: (_, i, __) => Text(palettes[i].name),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorsScreen())),
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

  Widget dot(Color c) => Container(width: 26, height: 26, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الألوان')),
        body: ValueListenableBuilder<int>(
          valueListenable: paletteIndex,
          builder: (_, sel, __) => ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: palettes.length,
            itemBuilder: (_, k) {
              final p = palettes[k];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: k == sel ? p.accent : Colors.transparent, width: 2.5),
                ),
                child: ListTile(
                  leading: Row(mainAxisSize: MainAxisSize.min, children: [dot(p.primary), const SizedBox(width: 4), dot(p.accent)]),
                  title: Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  trailing: k == sel ? Icon(Icons.check_circle, color: p.primary) : null,
                  onTap: () {
                    paletteIndex.value = k;
                    Repo.prefs.setInt('palette', k);
                  },
                ),
              );
            },
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
];
const sebhaTargets = [33, 100, 300, 500, 1000];

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});
  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen> {
  late int sel, target;
  late List<int> counts;

  @override
  void initState() {
    super.initState();
    final p = Repo.prefs;
    sel = p.getInt('sebha_sel') ?? 0;
    if (sel < 0 || sel >= sebhaFormulas.length) sel = 0;
    target = p.getInt('sebha_target') ?? 100;
    counts = List.generate(sebhaFormulas.length, (i) => p.getInt('sebha_c$i') ?? 0);
  }

  int get count => counts[sel];

  void save() => Repo.prefs.setInt('sebha_c$sel', counts[sel]);

  void tap() {
    HapticFeedback.lightImpact();
    setState(() => counts[sel]++);
    save();
    if (counts[sel] == target) {
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
                  style: TextStyle(fontSize: 17, height: 1.7, fontWeight: i == sel ? FontWeight.bold : FontWeight.normal)),
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

  @override
  Widget build(BuildContext context) {
    final a = accent(context);
    final prog = count >= target ? 1.0 : count / target;
    return Scaffold(
      appBar: AppBar(title: const Text('سبحة الصلاة على الحبيب ﷺ', style: TextStyle(fontSize: 18))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                child: Column(children: [
                  Text(sebhaFormulas[sel],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19, height: 1.9, fontWeight: FontWeight.w600, color: a)),
                  TextButton.icon(onPressed: pick, icon: const Icon(Icons.list), label: const Text('اختيار صيغة أخرى')),
                ]),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: tap,
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CircularProgressIndicator(value: prog, strokeWidth: 10, color: a, backgroundColor: a.withOpacity(.15)),
                      ),
                      Container(
                        width: 190,
                        height: 190,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pri(context),
                          boxShadow: [BoxShadow(color: sec(context).withOpacity(.45), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: Text('$count', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            Text('العدد المستهدف', style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 6),
            Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
              for (final t in sebhaTargets)
                ChoiceChip(
                  label: Text('$t'),
                  selected: target == t,
                  onSelected: (_) {
                    setState(() => target = t);
                    Repo.prefs.setInt('sebha_target', t);
                  },
                ),
            ]),
            const SizedBox(height: 14),
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
          ]),
        ),
      ),
    );
  }
}
