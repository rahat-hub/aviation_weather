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


class AirportLocationCodeInfo {
  final String? id;
  final String? icaoId;
  final String? iataId;
  final String? faaId;
  final String? wmoId;
  final String? site;
  final double? lat;
  final double? lon;
  final int? elev;
  final String? state;
  final String? country;
  final int? priority;
  final List<String>? siteType;

  AirportLocationCodeInfo({
    this.id,
    this.icaoId,
    this.iataId,
    this.faaId,
    this.wmoId,
    this.site,
    this.lat,
    this.lon,
    this.elev,
    this.state,
    this.country,
    this.priority,
    this.siteType,
  });

  factory AirportLocationCodeInfo.fromJson(Map<String, dynamic> json) {
    return AirportLocationCodeInfo(
      id: json['id'],
      icaoId: json['icaoId'],
      iataId: json['iataId'],
      faaId: json['faaId'],
      wmoId: json['wmoId'],
      site: json['site'],
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      elev: json['elev'],
      state: json['state'],
      country: json['country'],
      priority: json['priority'],
      siteType: (json['siteType'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icaoId': icaoId,
      'iataId': iataId,
      'faaId': faaId,
      'wmoId': wmoId,
      'site': site,
      'lat': lat,
      'lon': lon,
      'elev': elev,
      'state': state,
      'country': country,
      'priority': priority,
      'siteType': siteType,
    };
  }
}
