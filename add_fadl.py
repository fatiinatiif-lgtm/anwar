import re, sys

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

open(path, 'w', encoding='utf-8').write(s)
