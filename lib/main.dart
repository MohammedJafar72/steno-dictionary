import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:steno_dictionary/screens/home.dart';
import 'package:steno_dictionary/screens/add_outline.dart';
import 'package:steno_dictionary/screens/take_picture.dart';
import 'package:steno_dictionary/screens/view_outline.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Hive.initFlutter();
  await Hive.openBox('sdData');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steno Dictionary',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/addOutline': (context) => const AddOutline(),
        '/viewOutline': (context) => const ViewOutline(),
        '/takePicture': (context) => const TakePicture(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white60),
          bodyMedium: TextStyle(color: Colors.white60),
          bodySmall: TextStyle(color: Colors.white60),
        ),
      ),
    );
  }
}
