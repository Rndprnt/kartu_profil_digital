import 'package:flutter/material.dart';

import 'data/project_repository.dart';
import 'models/project.dart';
import 'pages/profile_page.dart';
import 'services/pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib sebelum await di main
  final prefs = await PrefService.init();
  debugPrint('Isi prefs: ${prefs.debugKeys}');
  await prefs.increaseOpenCount();

  // ⚠️ KODE UJI SEMENTARA — hapus setelah dicoba
  final repo = ProjectRepository();
  await repo.insert(
    Project(
      title: 'Kartu Profil Digital',
      description: 'Aplikasi kartu profil dengan penyimpanan lokal.',
      techStack: 'Flutter, Dart',
      createdAt: DateTime.now(),
    ),
  );
  final all = await repo.getAll();
  debugPrint('Total proyek: ${all.length}');
  for (final p in all) {
    debugPrint('#${p.id} ${p.title} (${p.techStack})');
  }

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.prefs});
  final PrefService prefs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Nilai awal dibaca dari penyimpanan, bukan hard-coded.
  late final ValueNotifier<bool> _isDark = ValueNotifier(
    widget.prefs.isDarkMode,
  );

  void _changeTheme(bool value) {
    _isDark.value = value; // 1. ubah tampilan sekarang
    widget.prefs.setDarkMode(value); // 2. simpan untuk nanti
  }

  @override
  void dispose() {
    _isDark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDark,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Kartu Profil Digital',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: ProfilePage(
            prefs: widget.prefs,
            isDark: isDark,
            onThemeChanged: _changeTheme,
          ),
        );
      },
    );
  }
}
