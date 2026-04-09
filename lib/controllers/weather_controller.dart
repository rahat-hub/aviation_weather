import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:latlong2/latlong.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum MapLayer { radar, wind, temp }

class WeatherController extends GetxController {
  final WeatherService _service = WeatherService();

  // Observables
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  final activeLayer = MapLayer.radar.obs;

  final currentAirport = Rxn<AirportInfo>();
  final weatherData = Rxn<WeatherData>();
  final hourlyForecast = <HourlyForecast>[].obs;
  final nearbyAirports = <NearbyAirport>[].obs;

  final mapCenter = const LatLng(0, 0).obs;
  final mapZoom = 9.0.obs;
  final showWeatherPanel = true.obs;
  final panelExpanded = false.obs;

  // Popular airports for quick access

  final List<String> usaPopularAirports = ['KATL','KLAX','KORD','KDFW','KDEN','KJFK','KSFO','KSEA','KLAS','KMCO'];

  List<AirportLocationCodeInfo> airportLocationCodes = [];


  // final popularAirports = [
  //   {'icao': 'EPWA', 'name': 'Warsaw', 'lat': 52.1657, 'lon': 20.9671},
  //   {'icao': 'EGLL', 'name': 'London', 'lat': 51.4775, 'lon': -0.4614},
  //   {'icao': 'LFPG', 'name': 'Paris', 'lat': 49.0097, 'lon': 2.5479},
  //   {'icao': 'EDDF', 'name': 'Frankfurt', 'lat': 50.0379, 'lon': 8.5622},
  //   {'icao': 'LIRF', 'name': 'Rome', 'lat': 41.8003, 'lon': 12.2389},
  //   {'icao': 'LEMD', 'name': 'Madrid', 'lat': 40.4936, 'lon': -3.5668},
  //   {'icao': 'EHAM', 'name': 'Amsterdam', 'lat': 52.3105, 'lon': 4.7683},
  //   {'icao': 'LSZH', 'name': 'Zurich', 'lat': 47.4647, 'lon': 8.5492},
  // ];

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();

    await _loadAirportLocationCodesApiCall();



    _loadDefaultAirport();
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 400),
    );
  }


  Future<void> _loadAirportLocationCodesApiCall() async {
    final response = await WeatherService().getAirportLocationCode(airportCode: usaPopularAirports.join(','));
    if(response != null && response is List) {
      airportLocationCodes = response.map((e) => AirportLocationCodeInfo.fromJson(e)).toList();
    }

    mapCenter.value = LatLng(airportLocationCodes[0].lat ?? 0, airportLocationCodes[0].lon ?? 0);

    print('************************************');
    print(airportLocationCodes.length);
    print('******************FULL DATA******************');
    print(airportLocationCodes);

  }

  void _loadDefaultAirport() {
    loadAirport(
      // icao: 'EPWA',
      // name: 'Warsaw Chopin Airport',
      // city: 'Warsaw',
      // country: 'Poland',
      // lat: 52.1657,
      // lon: 20.9671,

      icao: airportLocationCodes[0].faaId ?? '',
      name: airportLocationCodes[0].site ?? '',
      city: airportLocationCodes[0].state ?? '',
      country: airportLocationCodes[0].country ?? '',
      lat: airportLocationCodes[0].lat ?? 0.0,
      lon: airportLocationCodes[0].lon ?? 0.0,

    );
  }

  Future<void> loadAirport({
    required String icao,
    required String name,
    required String city,
    required String country,
    required double lat,
    required double lon,
  }) async {
    isLoading.value = true;
    isSearching.value = false;
    searchResults.clear();
    searchController.clear();

    try {
      currentAirport.value = AirportInfo(
        icao: icao,
        name: name,
        city: city,
        country: country,
        lat: lat,
        lon: lon,
        elevation: 0,
        metar: '',
      );

      mapCenter.value = LatLng(lat, lon);
      mapZoom.value = 9.0;

      // Load in parallel
      final results = await Future.wait([
        _service.getCurrentWeather(lat, lon),
        _service.getHourlyForecast(lat, lon),
        _service.getMetar(icao),
      ]);

      weatherData.value = results[0] as WeatherData?;
      hourlyForecast.value = results[1] as List<HourlyForecast>;

      final metar = results[2] as String;
      currentAirport.value = AirportInfo(
        icao: icao,
        name: name,
        city: city,
        country: country,
        lat: lat,
        lon: lon,
        elevation: 0,
        metar: metar,
      );

      _generateNearbyAirports(lat, lon);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load weather data',
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFE2E8F0));
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (value.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
    } else {
      isSearching.value = true;
    }
  }

  Future<void> _performSearch() async {
    if (searchQuery.value.length < 2) return;

    // Filter popular airports first
    final query = searchQuery.value.toUpperCase();
    final localResults = airportLocationCodes
        .where((a) =>
            a.faaId.toString().contains(query) ||
            a.site.toString().toUpperCase().contains(query))
        .map((a) => {
              // 'icao': a['icao'],
              // 'name': '${a['name']} Airport',
              // 'city': a['name'],
              // 'country': '',
              // 'lat': a['lat'],
              // 'lon': a['lon'],
            })
        .toList();

    searchResults.value = localResults.cast<Map<String, dynamic>>();

    // Also try MapTiler geocoding
    final geoResult = await _service.searchLocation(searchQuery.value);
    if (geoResult != null) {
      final coords = geoResult['geometry']?['coordinates'];
      if (coords != null) {
        searchResults.insert(0, {
          'icao': searchQuery.value.toUpperCase(),
          'name': geoResult['place_name'] ?? searchQuery.value,
          'city': geoResult['text'] ?? searchQuery.value,
          'country': '',
          'lat': coords[1]?.toDouble() ?? 0.0,
          'lon': coords[0]?.toDouble() ?? 0.0,
        });
      }
    }
  }

  void selectSearchResult(Map<String, dynamic> result) {
    loadAirport(
      icao: result['icao'] ?? '',
      name: result['name'] ?? '',
      city: result['city'] ?? '',
      country: result['country'] ?? '',
      lat: (result['lat'] as num).toDouble(),
      lon: (result['lon'] as num).toDouble(),
    );
  }

  void setMapLayer(MapLayer layer) {
    activeLayer.value = layer;
  }

  void togglePanel() {
    showWeatherPanel.value = !showWeatherPanel.value;
  }

  void togglePanelExpanded() {
    panelExpanded.value = !panelExpanded.value;
  }

  void _generateNearbyAirports(double lat, double lon) {
    final airports = airportLocationCodes
        .where((a) => a.faaId != currentAirport.value?.icao)
        .map((a) {
      final aLat = a.lat as double;
      final aLon = a.lon as double;
      final dist = _haversine(lat, lon, aLat, aLon);
      return NearbyAirport(
        icao: a.faaId as String,
        name: a.site as String,
        lat: aLat,
        lon: aLon,
        distanceKm: dist,
      );
    }).toList();

    airports.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    nearbyAirports.value = airports.take(7).toList();
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (dLat / 2) * (dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * (dLon / 2) * (dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * (3.14159265359 / 180);
  double sqrt(double x) => x < 0 ? 0 : x >= 1 ? x : x * 0.5 + 0.25;
  double cos(double x) => 1 - (x * x / 2) + (x * x * x * x / 24);
  double atan2(double y, double x) {
    if (x > 0) return y / x;
    if (x < 0 && y >= 0) return y / x + 3.14159;
    if (x < 0 && y < 0) return y / x - 3.14159;
    if (x == 0 && y > 0) return 1.5708;
    if (x == 0 && y < 0) return -1.5708;
    return 0;
  }

  String get windDescription {
    final w = weatherData.value;
    if (w == null) return '--';
    return '${w.windSpeed.toInt()} kt ${w.windDirection}';
  }

  String get uvLabel {
    final uv = weatherData.value?.uvIndex ?? 0;
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  String get pressureHpa {
    final p = weatherData.value?.pressure ?? 1013;
    return '${p.toInt()} hPa';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
