import os, re, sys

path = sys.argv[1]
s = open(path, encoding='utf-8').read()

# ---------- 1) زرار "فضل الصلاة والسلام" تحت زرار التعريف بالكاتب ----------
if 'fadl_salah.txt' not in s:
    pat = re.compile(r"label:\s*const Text\('التعريف بالكاتب'\),\s*\),\s*\),")
    m = pat.search(s)
    if not m:
        sys.exit('ERROR: could not find the author button in main.dart')
    block = """
                const SizedBox(height: 10),
                Center(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TextScreen('فضل الصلاة والسلام على الحبيب ﷺ', 'assets/texts/fadl_salah.txt'))),
                    icon: const Icon(Icons.favorite),
                    label: const Text('فضل الصلاة والسلام على الحبيب ﷺ'),
                  ),
                ),"""
    s = s[:m.end()] + block + s[m.end():]
    print('button added')

# ---------- 2) النصوص تملأ عرض الشاشة (ضبط من اليمين للشمال) ----------
if 'TextAlign.justify' not in s:
    p1 = re.compile(r"padding: const EdgeInsets\.all\(18\),(\s*child: SelectableText)")
    p2 = re.compile(r"SelectableText\((\s*s\.data\?\.replaceAll\('\\uFEFF', ''\) \?\? ''),\s*style: const TextStyle\(fontSize: 18, height: 1\.9\)\s*\)")
    if not (p1.search(s) and p2.search(s)):
        sys.exit('ERROR: could not find TextView in main.dart')
    s = p1.sub(lambda m: "padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16)," + m.group(1), s, count=1)
    s = p2.sub(lambda m: "SelectableText(" + m.group(1) + ", textAlign: TextAlign.justify, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 18, height: 1.9))", s, count=1)
    print('text layout fixed')


# ---------- 3) شاشة الترحيب (7 ثواني) قبل الشاشة الرئيسية ----------
if 'class SplashScreen' not in s:
    if not re.search(r"home:\s*const Shell\(\)", s):
        sys.exit('ERROR: could not find home: const Shell() in main.dart')
    s = re.sub(r"home:\s*const Shell\(\)", "home: const SplashScreen()", s, count=1)
    s += """

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
    Future.delayed(const Duration(seconds: 7), () {
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
"""
    print('splash screen added')

# الخط المزخرف: لو اتحمّل وقت البناء نسجله في pubspec.yaml
if os.path.exists('assets/fonts/ArefRuqaa-Bold.ttf') and os.path.exists('pubspec.yaml'):
    p = open('pubspec.yaml', encoding='utf-8').read()
    if 'ArefRuqaa' not in p and '\nflutter:\n' in p:
        p = p.replace('\nflutter:\n', '\nflutter:\n  fonts:\n    - family: ArefRuqaa\n      fonts:\n        - asset: assets/fonts/ArefRuqaa-Bold.ttf\n          weight: 700\n', 1)
        open('pubspec.yaml', 'w', encoding='utf-8').write(p)
        print('font registered')

open(path, 'w', encoding='utf-8').write(s)
