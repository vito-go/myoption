import 'package:flutter/material.dart';
import 'package:myoption/pages/home.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/prefs/prefs.dart';
import 'package:myoption/widgets/restart_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Global.init().then((value) {
    runApp(const RestartApp(
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Global.appName,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: prefs.themeMode,
      home: const MyHomePage(),
    );
  }
}
