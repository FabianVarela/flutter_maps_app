import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps_app/core/utils/maps_loader/maps_loader.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  const mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  if (mapsApiKey.isNotEmpty) {
    try {
      await MapsLoader.loadGoogleMapsScript(mapsApiKey);
    } catch (e) {
      debugPrint('Error loading Google Maps: $e');
    }
  } else {
    debugPrint('Warning: MAPS_API_KEY is not defined');
  }

  runApp(await builder());
}
