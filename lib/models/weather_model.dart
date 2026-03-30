class WeatherData {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double windDeg;
  final double pressure;
  final double visibility;
  final int uvIndex;
  final String condition;
  final String conditionCode;
  final double tempMin;
  final double tempMax;
  final double precipitation;
  final double cloudCover;
  final DateTime time;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.condition,
    required this.conditionCode,
    required this.tempMin,
    required this.tempMax,
    required this.precipitation,
    required this.cloudCover,
    required this.time,
  });
}

class AirportInfo {
  final String icao;
  final String name;
  final String city;
  final String country;
  final double lat;
  final double lon;
  final int elevation;
  final String metar;

  AirportInfo({
    required this.icao,
    required this.name,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    required this.elevation,
    required this.metar,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      icao: json['icao'] ?? '',
      name: json['name'] ?? '',
      city: json['municipality'] ?? json['city'] ?? '',
      country: json['iso_country'] ?? '',
      lat: (json['latitude_deg'] ?? 0.0).toDouble(),
      lon: (json['longitude_deg'] ?? 0.0).toDouble(),
      elevation: (json['elevation_ft'] ?? 0).toInt(),
      metar: json['metar'] ?? '',
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double precipitation;
  final double windSpeed;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitation,
    required this.windSpeed,
    required this.condition,
  });
}

class NearbyAirport {
  final String icao;
  final String name;
  final double lat;
  final double lon;
  final double distanceKm;

  NearbyAirport({
    required this.icao,
    required this.name,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });
}
