import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/themedata.dart';
import 'widget/navbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Frontend',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const Navbar(),
    );
  }
}

///currently used for debugging navbar