import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_coffee_roaster/src/views/screens/new_gadget_page.dart';

// Import the pages
import 'src/views/screens/main_menu_page.dart';
import 'src/views/screens/start_roasting_page.dart';
import 'src/views/screens/roasting_profile_page.dart';
import 'src/views/screens/roasting_gadgets_page.dart';
import 'src/views/screens/edit_gadget_page.dart'; // Import EditGadgetPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Coffee Roaster',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        focusColor: Colors.deepOrangeAccent,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.orangeAccent, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      initialRoute: '/',
 routes: {
        '/': (context) => const MainMenuPage(),
        '/startRoasting': (context) => const StartRoastingPage(),
        '/roastingProfile': (context) => const RoastingProfilePage(),
        '/roastingGadgets': (context) => const RoastingGadgetsPage(),
        '/newGadget': (context) => const NewGadgetPage(), // Ensure this route is defined
        '/editGadget': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as File;
          return EditGadgetPage(gadgetFile: args);
        },
      },
    );

    
  }
}
