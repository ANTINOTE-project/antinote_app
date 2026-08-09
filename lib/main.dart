import 'package:antinote_app/data/data.dart';
import 'package:antinote_app/ui/entrypoints/login.dart';
import 'package:antinote_app/ui/entrypoints/main.dart';

@pragma('vm:entry-point')
void main() => mainEntrypoint();

@pragma('vm:entry-point')
void loginMain() => loginEntrypoint();

@pragma('vm:entry-point')
Future<void> syncMain() => syncEntrypoint();
