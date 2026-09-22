import 'package:antinote_api/antinote_api.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> fetchPosition() async {
  var perm = await Geolocator.checkPermission();

  if (perm == .denied) {
    perm = await Geolocator.requestPermission();
  }

  if (perm == .deniedForever || perm == .denied) {
    logger.warning('Geolocation perm denied');
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 5),
        accuracy: .lowest,
      ),
    );
  } catch (_) {
    logger.severe('Failed to get current position');
    return null;
  }
}
