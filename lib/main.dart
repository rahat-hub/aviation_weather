import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/weather_controller.dart';
import 'theme/app_theme.dart';
import 'views/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AviationWeatherApp());
}

class AviationWeatherApp extends StatelessWidget {
  const AviationWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aviation Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialBinding: BindingsBuilder(() {
        Get.put(WeatherController());
      }),
      home: const WeatherScreen(),
    );
  }
}
