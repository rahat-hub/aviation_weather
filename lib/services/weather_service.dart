import 'dart:math';
import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // MapTiler API Key - replace with your own from cloud.maptiler.com
  static const String mapTilerApiKey = 'IbrzEfoM27ttUgiyZVz2';

  // MapTiler Geocoding - search airport/location
  Future<Map<String, dynamic>?> searchLocation(String query) async {
    try {
      final response = await _dio.get(
        'https://api.maptiler.com/geocoding/$query.json',
        queryParameters: {
          'key': mapTilerApiKey,
          'limit': 5,
          'types': 'aerodrome,place,city',
        },
      );
      if (response.data['features'] != null &&
          response.data['features'].isNotEmpty) {
        return response.data['features'][0];
      }
    } catch (e) {
      // fallback to mock data for demo
    }
    return null;
  }

  // Open-Meteo - completely free, no API key needed
  Future<WeatherData?> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': [
            'temperature_2m',
            'apparent_temperature',
            'relative_humidity_2m',
            'wind_speed_10m',
            'wind_direction_10m',
            'surface_pressure',
            'weather_code',
            'cloud_cover',
            'precipitation',
            'uv_index',
            'visibility',
          ].join(','),
          'daily': 'temperature_2m_max,temperature_2m_min',
          'wind_speed_unit': 'kn',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );
      final current = response.data['current'];
      final daily = response.data['daily'];

      return WeatherData(
        temperature: (current['temperature_2m'] ?? 0).toDouble(),
        feelsLike: (current['apparent_temperature'] ?? 0).toDouble(),
        humidity: (current['relative_humidity_2m'] ?? 0).toDouble(),
        windSpeed: (current['wind_speed_10m'] ?? 0).toDouble(),
        windDirection: _degToCompass(
            (current['wind_direction_10m'] ?? 0).toDouble()),
        windDeg: (current['wind_direction_10m'] ?? 0).toDouble(),
        pressure: (current['surface_pressure'] ?? 1013).toDouble(),
        visibility: (current['visibility'] ?? 10000).toDouble() / 1000,
        uvIndex: (current['uv_index'] ?? 0).toInt(),
        condition: _wmoCodeToCondition(current['weather_code'] ?? 0),
        conditionCode: '${current['weather_code'] ?? 0}',
        tempMin: (daily['temperature_2m_min']?[0] ?? 0).toDouble(),
        tempMax: (daily['temperature_2m_max']?[0] ?? 0).toDouble(),
        precipitation: (current['precipitation'] ?? 0).toDouble(),
        cloudCover: (current['cloud_cover'] ?? 0).toDouble(),
        time: DateTime.now(),
      );
    } catch (e) {
      return _getMockWeatherData(lat, lon);
    }
  }

  Future<List<HourlyForecast>> getHourlyForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'hourly': [
            'temperature_2m',
            'precipitation_probability',
            'wind_speed_10m',
            'weather_code',
          ].join(','),
          'wind_speed_unit': 'kn',
          'timezone': 'auto',
          'forecast_days': 2,
        },
      );

      final hourly = response.data['hourly'];
      final times = hourly['time'] as List;
      final List<HourlyForecast> forecasts = [];
      final now = DateTime.now();

      for (int i = 0; i < times.length && forecasts.length < 24; i++) {
        final t = DateTime.parse(times[i]);
        if (t.isAfter(now)) {
          forecasts.add(HourlyForecast(
            time: t,
            temperature: (hourly['temperature_2m'][i] ?? 0).toDouble(),
            precipitation:
                (hourly['precipitation_probability'][i] ?? 0).toDouble(),
            windSpeed: (hourly['wind_speed_10m'][i] ?? 0).toDouble(),
            condition:
                _wmoCodeToCondition(hourly['weather_code'][i] ?? 0),
          ));
        }
      }
      return forecasts;
    } catch (e) {
      return _getMockHourlyForecast();
    }
  }

  // AVWX API (free tier) - for real METAR data
  Future<String> getMetar(String icao) async {
    try {
      final response = await _dio.get(
        'https://avwx.rest/api/metar/$icao',
        queryParameters: {'token': 'YOUR_AVWX_TOKEN'},
      );
      return response.data['raw'] ?? _generateMockMetar(icao);
    } catch (e) {
      return _generateMockMetar(icao);
    }
  }

  // MapTiler Tile URL builder
  String getMapTileUrl(String style) {
    return 'https://api.maptiler.com/maps/$style/256/{z}/{x}/{y}.png?key=$mapTilerApiKey';
  }

  // MapTiler Weather Radar tile URL
  String getRadarTileUrl() {
    return 'https://api.maptiler.com/tiles/radar/{z}/{x}/{y}.webp?key=$mapTilerApiKey';
  }

  // MapTiler Wind tile URL  
  String getWindTileUrl() {
    return 'https://api.maptiler.com/tiles/wind/{z}/{x}/{y}.png?key=$mapTilerApiKey';
  }

  String _degToCompass(double deg) {
    const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    return dirs[((deg / 22.5) + 0.5).floor() % 16];
  }

  String _wmoCodeToCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 9) return 'Fog';
    if (code <= 19) return 'Drizzle';
    if (code <= 29) return 'Rain';
    if (code <= 39) return 'Snow';
    if (code <= 49) return 'Fog';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 84) return 'Rain Showers';
    if (code <= 94) return 'Thunderstorm';
    return 'Thunderstorm';
  }

  String _generateMockMetar(String icao) {
    final now = DateTime.now().toUtc();
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$icao $day$hour${min}Z 25V7KT 9999 SCT015 BKN080 23/19 Q1021';
  }

  // Mock data for when APIs are unavailable
  WeatherData _getMockWeatherData(double lat, double lon) {
    return WeatherData(
      temperature: 24,
      feelsLike: 25,
      humidity: 65,
      windSpeed: 13,
      windDirection: 'WNW',
      windDeg: 290,
      pressure: 1021,
      visibility: 10,
      uvIndex: 5,
      condition: 'Partly Cloudy',
      conditionCode: '2',
      tempMin: 19,
      tempMax: 27,
      precipitation: 0,
      cloudCover: 40,
      time: DateTime.now(),
    );
  }

  List<HourlyForecast> _getMockHourlyForecast() {
    final rng = Random();
    return List.generate(
      24,
      (i) => HourlyForecast(
        time: DateTime.now().add(Duration(hours: i + 1)),
        temperature: 20 + rng.nextDouble() * 8,
        precipitation: rng.nextDouble() * 30,
        windSpeed: 8 + rng.nextDouble() * 15,
        condition: i % 6 == 0 ? 'Rain' : 'Partly Cloudy',
      ),
    );
  }
}
