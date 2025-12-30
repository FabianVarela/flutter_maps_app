import 'package:flutter/material.dart';
import 'package:flutter_maps_app/bloc/single_bloc.dart';
import 'package:flutter_maps_app/ui/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSingleBloc();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}
