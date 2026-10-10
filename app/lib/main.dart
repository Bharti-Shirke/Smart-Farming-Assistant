import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

final String baseUrl = kIsWeb
    ? 'http://127.0.0.1:8000'
    : 'http://10.0.2.2:8000';

String? token;
Map<String, String> get hdr => {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
Future<dynamic> api(String m, String path, [Object? body]) async {
  try {
    final u = Uri.parse('$baseUrl$path');
    final r = m == 'GET' ? await http.get(u, headers: hdr) : await http.post(u, headers: hdr, body: jsonEncode(body));
    final d = jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 400) throw d['detail'] ?? 'Something went wrong';
    return d;
  } on http.ClientException { throw 'No internet / server not reachable'; }
}

final localeN = ValueNotifier<Locale>(const Locale('en'));
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final p = await SharedPreferences.getInstance();
  localeN.value = Locale(p.getString('lang') ?? 'en');
  runApp(const App());
}
class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<Locale>(valueListenable: localeN, builder: (_, l, __) => MaterialApp(
    locale: l, debugShowCheckedModeBanner: false,
    localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF2E7D32), useMaterial3: true, textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 17))),
    home: const Login()));
}
void msg(BuildContext c, Object e) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('$e')));

class Login extends StatefulWidget { const Login({super.key}); @override State<Login> createState() => _L(); }
class _L extends State<Login> {
  final e = TextEditingController(), p = TextEditingController();
  Future<void> go(String path) async {
    try {
      final r = await api('POST', path, {'email': e.text, 'password': p.text, 'profile': {'crop': 'rice', 'soil': 'loamy', 'lat': 18.52, 'lon': 73.85}});
      token = r['token'];
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
    } catch (x) { if (mounted) msg(context, x); }
  }
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
    const Icon(Icons.agriculture, size: 90, color: Color(0xFF2E7D32)),
    Text(t.appName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    Wrap(spacing: 8, alignment: WrapAlignment.center, children: [for (final l in {'en': 'English', 'hi': 'हिन्दी', 'mr': 'मराठी'}.entries)
      ChoiceChip(label: Text(l.value), selected: localeN.value.languageCode == l.key, onSelected: (_) async {
        localeN.value = Locale(l.key); (await SharedPreferences.getInstance()).setString('lang', l.key); })]),
    TextField(controller: e, decoration: InputDecoration(labelText: t.email)),
    TextField(controller: p, obscureText: true, decoration: InputDecoration(labelText: t.password)),
    const SizedBox(height: 16),
    FilledButton(onPressed: () => go('/auth/login'), child: Text(t.login)),
    OutlinedButton(onPressed: () => go('/auth/register'), child: Text(t.register)),
  ]))); }
}

class Shell extends StatefulWidget { const Shell({super.key}); @override State<Shell> createState() => _S(); }
class _S extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return Scaffold(
    body: [const Home(), const Chat()][i],
    bottomNavigationBar: NavigationBar(selectedIndex: i, onDestinationSelected: (v) => setState(() => i = v), destinations: [
      NavigationDestination(icon: const Icon(Icons.home), label: t.home), NavigationDestination(icon: const Icon(Icons.chat), label: t.assistant)])); }
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _H(); }
class _H extends State<Home> {
  Map? w; String? err;
  @override void initState() { super.initState(); api('GET', '/weather?lat=18.52&lon=73.85').then((v) => setState(() => w = v)).catchError((x) => setState(() => err = '$x')); }
  Widget tile(IconData i, String s, Widget Function() page) => Card(child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page())),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 48, color: const Color(0xFF2E7D32)), Text(s, textAlign: TextAlign.center)])));
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return SafeArea(child: Column(children: [
    Card(color: Colors.green.shade50, child: ListTile(leading: const Icon(Icons.wb_sunny, size: 40),
      title: Text(w == null ? (err ?? '...') : '${w!['temp']}°C  ·  ${w!['humidity']}%  ·  ${w!['wind']} km/h'),
      subtitle: Text(w == null ? '' : '${(w!['tips'] as List).first}${w!['demo'] == true ? ' (demo data)' : ''}'))),
    Expanded(child: GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(12), children: [
      tile(Icons.grass, t.cropRec, () => const CropPage()),
      tile(Icons.bug_report, t.disease, () => const DiseasePage())]))])); }
}

class CropPage extends StatefulWidget { const CropPage({super.key}); @override State<CropPage> createState() => _C(); }
class _C extends State<CropPage> {
  final f = {for (final k in ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']) k: TextEditingController()};
  List res = [];
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return Scaffold(appBar: AppBar(title: Text(t.cropRec)), body: ListView(padding: const EdgeInsets.all(16), children: [
    for (final e in f.entries) TextField(controller: e.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: e.key)),
    FilledButton(onPressed: () async { try { final r = await api('POST', '/crop/recommend', {for (final e in f.entries) e.key: double.tryParse(e.value.text) ?? 0});
      setState(() => res = r); } catch (x) { if (mounted) msg(context, x); } }, child: Text(t.recommend)),
    for (final r in res) Card(child: ListTile(title: Text('${r['crop']}  (${(r['score'] * 100).round()}%)'), subtitle: Text(r['why'])))])); }
}

class DiseasePage extends StatefulWidget { const DiseasePage({super.key}); @override State<DiseasePage> createState() => _D(); }
class _D extends State<DiseasePage> {
  Map? r;
  Future<void> pick(ImageSource s) async {
    final x = await ImagePicker().pickImage(source: s, maxWidth: 800); if (x == null) return;
    try {
      final q = http.MultipartRequest('POST', Uri.parse('$baseUrl/disease/predict'))..headers['Authorization'] = 'Bearer $token'..files.add(await http.MultipartFile.fromPath('file', x.path));
      final resp = await http.Response.fromStream(await q.send()); final d = jsonDecode(resp.body);
      if (resp.statusCode >= 400) throw d['detail']; setState(() => r = d);
    } catch (e) { if (mounted) msg(context, e); }
  }
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return Scaffold(appBar: AppBar(title: Text(t.disease)), body: ListView(padding: const EdgeInsets.all(16), children: [
    FilledButton.icon(onPressed: () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: Text(t.takePhoto)),
    OutlinedButton(onPressed: () => pick(ImageSource.gallery), child: const Text('Gallery')),
    if (r != null) Card(child: ListTile(title: Text('${r!['label']} — ${(r!['confidence'] * 100).round()}%'), subtitle: Text(r!['advice'])))])); }
}

class Chat extends StatefulWidget { const Chat({super.key}); @override State<Chat> createState() => _Ch(); }
class _Ch extends State<Chat> {
  final q = TextEditingController(); final List<Map<String, dynamic>> m = []; bool busy = false;
  Future<void> send(String text) async {
    if (text.trim().isEmpty) return; q.clear();
    setState(() { m.add({'role': 'user', 'text': text, 'time': TimeOfDay.now().format(context)}); busy = true; });
    try { final r = await api('POST', '/assistant/chat', {'question': text, 'history': m.map((e) => {'role': e['role'], 'text': e['text']}).toList()});
      setState(() => m.add({'role': 'model', 'text': r['answer'], 'time': TimeOfDay.now().format(context)}));
    } catch (e) { if (mounted) msg(context, e); }
    setState(() => busy = false);
  }
  @override
  Widget build(BuildContext c) { final t = AppLocalizations.of(c)!; return SafeArea(child: Column(children: [
    Row(children: [Expanded(child: Text(t.assistant, style: const TextStyle(fontSize: 22))), TextButton(onPressed: () => setState(m.clear), child: Text(t.newChat))]),
    Expanded(child: m.isEmpty ? ListView(children: [for (final s in [t.suggest1, t.suggest2, t.suggest3]) ListTile(title: Text(s), onTap: () => send(s))])
      : ListView(children: [for (final e in m) Align(alignment: e['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
          child: Card(color: e['role'] == 'user' ? Colors.green.shade100 : null, child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['text']), Text(e['time'], style: const TextStyle(fontSize: 11))]))))])),
    if (busy) const LinearProgressIndicator(),
    Row(children: [Expanded(child: TextField(controller: q, decoration: InputDecoration(hintText: t.ask), onSubmitted: send)), IconButton(icon: const Icon(Icons.send), tooltip: t.send, onPressed: () => send(q.text))])])); }
}
