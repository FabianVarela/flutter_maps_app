import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/ui/map_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MapScreen(),
    );
  }
}
