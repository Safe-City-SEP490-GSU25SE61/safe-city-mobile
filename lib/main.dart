import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:safe_city_mobile/utils/handlers/app_link_handler.dart';
import 'app.dart';
import 'data/repositories/authentication/authentication_repository.dart';

Future<void> main() async {
  ///Environment variable initialize
  await dotenv.load(fileName: ".env");

  ///Widgets Binding
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  ///GetX Local Storage
  await GetStorage.init();

  AppLinkHandler().init();

  ///Await Splash until other items load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Get.put(AuthenticationRepository());

  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_DOWNLOADS_TOKEN']!);

  runApp(const App());
}
