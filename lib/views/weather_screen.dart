import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/weather_controller.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/hourly_chart.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final WeatherController c = Get.find<WeatherController>();
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Full-screen map
          _buildMap(),

          // Top bar
          _buildTopBar(),

          // Search overlay
          Obx(() => c.isSearching.value ? _buildSearchOverlay() : const SizedBox.shrink()),

          // Bottom weather panel
          _buildBottomPanel(),

          // Layer toggle FAB
          _buildLayerToggle(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final airport = c.currentAirport.value;
      final center = c.mapCenter.value;

      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: c.mapZoom.value,
          minZoom: 4 ,
          maxZoom: 7,
          onMapReady: () {},
        ),
        children: [
          // Base satellite layer from MapTiler
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key=${WeatherService.mapTilerApiKey}',
            fallbackUrl:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.aviation_weather',
            subdomains: const ['a', 'b', 'c'],
          ),

          Opacity(
            opacity: 0.8,
            child: TileLayer(
              urlTemplate:
              // 'https://tilecache.rainviewer.com/v2/radar/latest/256/{z}/{x}/{y}/2/1_1.png',
              'https://tilecache.rainviewer.com/v2/radar/latest/{z}/{x}/{y}/256/2/1_1.png',
              // opacity: 0.6,
              userAgentPackageName: 'com.example.aviation_weather',
              minZoom: 4,
              maxZoom: 7,
            ),
          ),



          // Weather overlay based on selected layer
          /*if (c.activeLayer.value == MapLayer.radar)
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/tiles/radar/{z}/{x}/{y}.webp?key=${WeatherService.mapTilerApiKey}',
              //opacity: 0.6,
              userAgentPackageName: 'com.example.aviation_weather',
              errorTileCallback: (tile, error, stackTrace) {},
            ),

          if (c.activeLayer.value == MapLayer.wind)
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/tiles/wind/{z}/{x}/{y}.png?key=${WeatherService.mapTilerApiKey}',
              // opacity: 0.65,
              userAgentPackageName: 'com.example.aviation_weather',
              errorTileCallback: (tile, error, stackTrace) {},
            ),

          if (c.activeLayer.value == MapLayer.temp)
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/tiles/temperature-at-2m/{z}/{x}/{y}.png?key=${WeatherService.mapTilerApiKey}',
              // opacity: 0.55,
              userAgentPackageName: 'com.example.aviation_weather',
              errorTileCallback: (tile, error, stackTrace) {},
            ),*/

          // Nearby airport markers
          MarkerLayer(
            markers: [
              ...c.nearbyAirports.map((a) => Marker(
                    point: LatLng(a.lat, a.lon),
                    width: 80,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => c.loadAirport(
                        icao: a.icao,
                        name: a.name,
                        city: a.name,
                        country: '',
                        lat: a.lat,
                        lon: a.lon,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle_outline,
                              color: AppTheme.textSecondary, size: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppTheme.border, width: 0.5),
                            ),
                            child: Text(
                              a.icao,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              // Main airport marker
              if (airport != null)
                Marker(
                  point: LatLng(airport.lat, airport.lon),
                  width: 140,
                  height: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40 + _pulseController.value * 10,
                              height: 40 + _pulseController.value * 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentGold
                                      .withValues(alpha: 0.3 - _pulseController.value * 0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.flight,
                                color: AppTheme.accentGold, size: 22),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppTheme.accentGold.withValues(alpha: 0.4),
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              airport.icao,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              airport.city,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search bar
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: c.searchController,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ICAO / Airport / City...',
                          hintStyle: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: c.onSearchChanged,
                      ),
                    ),
                    Obx(() => c.searchQuery.value.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              c.searchController.clear();
                              c.onSearchChanged('');
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.close,
                                  color: AppTheme.textMuted, size: 16),
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

              const SizedBox(height: 10),

              // Layer tabs
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: MapLayer.values.map((layer) {
                      final active = c.activeLayer.value == layer;
                      final labels = {
                        MapLayer.radar: 'Radar',
                        MapLayer.wind: 'Wind',
                        MapLayer.temp: 'Temp',
                      };
                      final colors = {
                        MapLayer.radar: AppTheme.radarBlue,
                        MapLayer.wind: AppTheme.windCyan,
                        MapLayer.temp: AppTheme.tempOrange,
                      };
                      return GestureDetector(
                        onTap: () => c.setMapLayer(layer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: active
                                ? colors[layer]!.withValues(alpha: 0.2)
                                : AppTheme.bgCard.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? colors[layer]!
                                  : AppTheme.border,
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            labels[layer]!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: active
                                  ? colors[layer]
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 110,
      left: 12,
      right: 12,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(() {
          if (c.searchResults.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Searching...',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: c.searchResults.length,
            itemBuilder: (_, i) {
              final r = c.searchResults[i];
              return ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(
                    child: Text(
                      r['icao']?.toString().substring(0, 2) ?? '??',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  r['icao'] ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  r['name'] ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                trailing: const Icon(
                  Icons.flight,
                  color: AppTheme.textMuted,
                  size: 14,
                ),
                onTap: () => c.selectSearchResult(r),
              );
            },
          );
        }),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildBottomPanel() {
    return Obx(() {
      final weather = c.weatherData.value;
      final airport = c.currentAirport.value;
      final expanded = c.panelExpanded.value;

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.97),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: const Border(
                top: BorderSide(color: AppTheme.borderLight, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              GestureDetector(
                onTap: c.togglePanelExpanded,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              if (c.isLoading.value)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                    strokeWidth: 2,
                  ),
                )
              else if (airport != null && weather != null) ...[
                // Airport header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ICAO + name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  airport.icao,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  airport.name,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 10, color: AppTheme.textMuted),
                                const SizedBox(width: 3),
                                Text(
                                  '${airport.city}, ${airport.country}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Temp + condition
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _weatherIcon(weather.condition, size: 24),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${weather.temperature.toInt()}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '°C',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            weather.condition,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // METAR strip
                if (airport.metar.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.border.withValues(alpha: 0.5),
                          width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'METAR: ',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            airport.metar,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: AppTheme.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Gauge row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _gaugeCard(
                        title: 'WIND',
                        child: WindRoseWidget(
                          windDeg: weather.windDeg,
                          windSpeed: weather.windSpeed,
                          direction: weather.windDirection,
                        ),
                        sub: weather.windDirection,
                      ),
                      const SizedBox(width: 8),
                      _gaugeCard(
                        title: 'HUMIDITY',
                        child: ArcGauge(
                          value: weather.humidity,
                          min: 0,
                          max: 100,
                          label: '',
                          unit: '%',
                          gradientColors: const [
                            Color(0xFF22D3EE),
                            AppTheme.humidYellow,
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _gaugeCard(
                        title: 'TEMP',
                        child: ArcGauge(
                          value: weather.temperature,
                          min: -20,
                          max: 45,
                          label: '',
                          unit: '°C',
                          gradientColors: const [
                            Color(0xFF3B82F6),
                            AppTheme.tempOrange,
                            AppTheme.accentRed,
                          ],
                        ),
                        sub:
                            '${weather.tempMin.toInt()}° / ${weather.tempMax.toInt()}°',
                      ),
                      const SizedBox(width: 8),
                      _gaugeCard(
                        title: 'UV INDEX',
                        child: ArcGauge(
                          value: weather.uvIndex.toDouble(),
                          min: 0,
                          max: 11,
                          label: '',
                          unit: '',
                          subLabel: c.uvLabel,
                          gradientColors: const [
                            AppTheme.accentGreen,
                            AppTheme.accentGold,
                            AppTheme.accentRed,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Extra stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _statChip(
                          Icons.visibility,
                          '${weather.visibility.toStringAsFixed(0)} km',
                          'Visibility'),
                      const SizedBox(width: 6),
                      _statChip(Icons.compress, c.pressureHpa, 'Pressure'),
                      const SizedBox(width: 6),
                      _statChip(Icons.thermostat,
                          '${weather.feelsLike.toInt()}°C', 'Feels Like'),
                      const SizedBox(width: 6),
                      _statChip(Icons.cloud,
                          '${weather.cloudCover.toInt()}%', 'Cloud'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Expanded: hourly forecast
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppTheme.border, height: 16),
                        Text(
                          '24H FORECAST',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HourlyScrollStrip(
                            forecasts: c.hourlyForecast),
                        const SizedBox(height: 8),
                        HourlyForecastChart(
                          forecasts: c.hourlyForecast,
                          type: 'temp',
                        ),
                        const SizedBox(height: 8),
                        // Quick access airports
                        Text(
                          'NEARBY AIRPORTS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: c.nearbyAirports.map((a) {
                              return GestureDetector(
                                onTap: () => c.loadAirport(
                                  icao: a.icao,
                                  name: a.name,
                                  city: a.name,
                                  country: '',
                                  lat: a.lat,
                                  lon: a.lon,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgCardLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppTheme.border, width: 0.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        a.icao,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${a.distanceKm.toInt()} km',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 8,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox(height: 4),
                ),

                // Popular airports quick access
                if (!expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: c.popularAirports.map((a) {
                          final isActive =
                              a['icao'] == c.currentAirport.value?.icao;
                          return GestureDetector(
                            onTap: () => c.loadAirport(
                              icao: a['icao'] as String,
                              name: '${a['name']} Airport',
                              city: a['name'] as String,
                              country: '',
                              lat: a['lat'] as double,
                              lon: a['lon'] as double,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.accent.withValues(alpha: 0.15)
                                    : AppTheme.bgCardLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.accent.withValues(alpha: 0.5)
                                      : AppTheme.border,
                                  width: isActive ? 1 : 0.5,
                                ),
                              ),
                              child: Text(
                                a['icao'] as String,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppTheme.accent
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ).animate().slideY(
              begin: 0.15,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
      );
    });
  }

  Widget _buildLayerToggle() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.52,
      child: Column(
        children: [
          _mapButton(Icons.my_location, () {
            final a = c.currentAirport.value;
            if (a != null) {
              _mapController.move(LatLng(a.lat, a.lon), 9.0);
            }
          }),
          const SizedBox(height: 6),
          _mapButton(Icons.add, () {
            _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(4, 14));
          }),
          const SizedBox(height: 6),
          _mapButton(Icons.remove, () {
            _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(4, 14));
          }),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.bgCard.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 16),
      ),
    );
  }

  Widget _gaugeCard(
      {required String title,
      required Widget child,
      String sub = ''}) {
    return Container(
      width: 118,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Center(child: child),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Center(
              child: Text(
                sub,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.textMuted),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherIcon(String condition, {double size = 20}) {
    IconData icon;
    Color color;
    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny;
        color = AppTheme.accentGold;
        break;
      case 'partly cloudy':
        icon = Icons.cloud;
        color = AppTheme.textSecondary;
        break;
      case 'rain':
      case 'rain showers':
        icon = Icons.grain;
        color = AppTheme.accent;
        break;
      case 'snow':
        icon = Icons.ac_unit;
        color = Colors.lightBlue;
        break;
      case 'thunderstorm':
        icon = Icons.flash_on;
        color = AppTheme.accentGold;
        break;
      case 'fog':
        icon = Icons.blur_on;
        color = AppTheme.textSecondary;
        break;
      default:
        icon = Icons.cloud;
        color = AppTheme.textSecondary;
    }
    return Icon(icon, size: size, color: color);
  }
}
