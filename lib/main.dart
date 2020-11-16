import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/Screens/add_product_screen.dart';
import 'package:store_app/model/app_database.dart';

import 'Screens/homeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AppDatabase().productDao,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent[700],
          canvasColor: Colors.blueGrey[50],
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.blueGrey[700],
          canvasColor: Colors.blueGrey[100],
          visualDensity: VisualDensity.comfortable,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}


