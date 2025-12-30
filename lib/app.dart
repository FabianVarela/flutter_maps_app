import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/core/bloc/settings_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/client/preferences.dart';
import 'package:flutter_maps_app/features/home/presentation/view/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapsApp extends StatelessWidget {
  const MapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (_) => Preferences(preferences: snapshot.data!),
            ),
            RepositoryProvider(create: (_) => MapsClient()),
          ],
          child: BlocProvider(
            create: (context) => SingleBloc(
              preferences: context.read<Preferences>(),
            ),
            child: MaterialApp(
              theme: ThemeData(primarySwatch: Colors.blue),
              home: const MapScreen(),
            ),
          ),
        );
      },
    );
  }
}
