import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/preferences.dart';
import 'package:flutter_maps_bloc/common/utils.dart';
import 'package:rxdart/rxdart.dart';

class SingleBloc with Preferences implements BaseBloc {
  /// Subjects or StreamControllers
  final BehaviorSubject<String> _mapMode = BehaviorSubject<String>();

  /// Observables
  Observable<String> get mapMode => _mapMode.stream;

  /// Functions
  void init() async {
    final String mapMode = await getMapMode();

    try {
      final String mapFileData =
          await Utils.getFileData('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

  void changeMapMode(String mode) async {
    await saveMapMode(mode);
    init();
  }

  @override
  void dispose() {
    _mapMode.close();
  }
}

final SingleBloc singleBloc = SingleBloc();
