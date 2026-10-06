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


# ---------- 4) شاشة كاملة في كل التطبيق (بدون شريط الحالة) ----------
s = s.replace('SystemUiMode.edgeToEdge', 'SystemUiMode.immersiveSticky')
if 'fullscreen_all' not in s:
    m = re.search(r"WidgetsFlutterBinding\.ensureInitialized\(\);", s)
    if not m:
        sys.exit('ERROR: could not find ensureInitialized() in main.dart')
    s = s[:m.end()] + "\n  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // fullscreen_all" + s[m.end():]
    print('fullscreen enabled')

# ---------- 5) صيغ السبحة (10 صيغ) + تجميع الأهداف ----------
NEW_FORMULAS = """const sebhaFormulas = [
  'اللهم صل وسلم وبارك على سيدنا محمد وعلى آله عدد كمال الله وكما يليق بكماله',
  'اللهم صل على سيدنا محمد النبي الأمي الحبيب العالي القدر العظيم الجاه وعلى آله وصحبه وسلم',
  'اللهم صل وسلم وبارك على سيدنا محمد كريم الآباء والأمهات وعلى آله',
  'اللهم صل على سيدنا محمد وعلى آله عدد ما في علم الله صلاة دائمة بدوام ملك الله',
  'اللهم صل على سيدنا محمد الحامد المحمود وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد النعيم المقيم وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد وعلى آل سيدنا محمد كما صليت على سيدنا إبراهيم وعلى آل سيدنا إبراهيم وبارك على سيدنا محمد وعلى آل سيدنا محمد كما باركت على سيدنا إبراهيم وعلى آل سيدنا إبراهيم في العالمين إنك حميد مجيد',
  'اللهم صل على سيدنا محمد الفاتح لما أغلق والخاتم لما سبق والناصر الحق بالحق والهادي إلى صراطك المستقيم وعلى آله وأصحابه حق قدره ومقداره العظيم',
  'اللهم صل على سيدنا محمد طب القلوب ودوائها وعافية الأبدان وشفائها ونور الأبصار وضيائها وعلى آله وصحبه وسلم',
  'اللهم صل على سيدنا محمد النور الذاتي والسر الساري في سائر الأسماء والصفات وعلى آله وصحبه وسلم',
];"""

NEW_SEBHA = """class SebhaScreen extends StatefulWidget {
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
    if (sel < 0 || sel >= sebhaFormulas.length) sel = 0;
    target = p.getInt('sebha_target') ?? 100;
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
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
                child: Column(children: [
                  Text(sebhaFormulas[sel],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, height: 1.8, fontWeight: FontWeight.w600, color: a)),
                  TextButton.icon(onPressed: pick, icon: const Icon(Icons.list), label: const Text('اختيار صيغة أخرى')),
                ]),
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
            Expanded(
              child: LayoutBuilder(builder: (_, bc) {
                final room = bc.maxHeight - 8;
                final d = room < 230 ? (room < 120 ? 120.0 : room) : 230.0;
                return Center(
                  child: GestureDetector(
                    onTap: tap,
                    child: SizedBox(
                      width: d,
                      height: d,
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox(
                          width: d,
                          height: d,
                          child: CircularProgressIndicator(value: prog, strokeWidth: 10, color: a, backgroundColor: a.withOpacity(.15)),
                        ),
                        Container(
                          width: d * .83,
                          height: d * .83,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: fill,
                            boxShadow: [BoxShadow(color: a.withOpacity(.4), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: Text('$count', style: TextStyle(fontSize: d * .24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}"""

if 'sebha_goals' not in s:
    fm = re.search(r"const sebhaFormulas = \[.*?\n\];", s, re.S)
    st = s.find('class SebhaScreen extends StatefulWidget {')
    st2 = s.find('class _SebhaScreenState extends State<SebhaScreen> {')
    if not fm or st < 0 or st2 < 0:
        sys.exit('ERROR: could not find the sebha (counter) code in main.dart')
    # نلاقي نهاية كلاس _SebhaScreenState بعدّ الأقواس
    i = s.index('{', st2)
    depth = 0
    end = None
    for j in range(i, len(s)):
        c = s[j]
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                end = j + 1
                break
    if end is None:
        sys.exit('ERROR: could not find the end of the sebha code')
    # نبدّل الكلاسين الأول (من الآخر للأول عشان الأماكن ما تتغيرش)
    s = s[:st] + NEW_SEBHA + s[end:]
    fm = re.search(r"const sebhaFormulas = \[.*?\n\];", s, re.S)
    s = s[:fm.start()] + NEW_FORMULAS + s[fm.end():]
    print('sebha updated (10 formulas + goals)')


open(path, 'w', encoding='utf-8').write(s)
