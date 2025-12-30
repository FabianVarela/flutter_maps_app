import 'package:flutter_maps_app/app.dart';
import 'package:flutter_maps_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const MapsApp());
}
