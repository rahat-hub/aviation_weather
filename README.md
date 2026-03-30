# ✈️ Aviation Weather Map

A beautiful Flutter aviation weather app inspired by professional METAR/weather map apps. Built with **GetX**, **flutter_map**, **MapTiler**, and **Open-Meteo**.

![Screenshot showing airport weather map with gauges](screenshot_placeholder.png)

---

## 🚀 Features

- 🗺️ **MapTiler Satellite + Weather Overlay** — Radar, Wind, Temperature layers
- 📡 **Real METAR Data** — Live aviation weather reports (via AVWX)
- 🌡️ **Weather Gauges** — Animated arc gauges for Humidity, Temp, UV Index
- 🧭 **Wind Rose** — Visual wind direction compass
- 📊 **24H Hourly Forecast** — Chart + scrollable strip
- 🔍 **Airport Search** — Search by ICAO code or city
- 🛫 **Nearby Airports** — Quick tap to load nearby airports
- 🌐 **Free APIs** — Open-Meteo (no key needed), MapTiler free tier

---

## ⚙️ Setup

### 1. Get a FREE MapTiler API Key
1. Go to [cloud.maptiler.com](https://cloud.maptiler.com)
2. Sign up for free (100K map loads/month free)
3. Copy your API key

### 2. Set Your API Key
Open `lib/services/weather_service.dart` and replace:
```dart
static const String mapTilerApiKey = 'YOUR_MAPTILER_API_KEY';
```

### 3. (Optional) AVWX Token for Real METAR
1. Sign up at [avwx.rest](https://avwx.rest) (free tier available)
2. Get your token
3. In `weather_service.dart`, replace:
```dart
queryParameters: {'token': 'YOUR_AVWX_TOKEN'},
```

### 4. Install & Run
```bash
flutter pub get
flutter run
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `get` ^4.6.6 | State management + routing |
| `dio` ^5.4.0 | HTTP client |
| `flutter_map` ^6.1.0 | Interactive maps |
| `latlong2` ^0.9.0 | Lat/lon utilities |
| `fl_chart` ^0.68.0 | Hourly forecast charts |
| `flutter_animate` ^4.5.0 | Animations |
| `google_fonts` ^6.2.1 | JetBrains Mono + Space Grotesk |
| `shimmer` ^3.0.0 | Loading skeleton |
| `geolocator` ^11.0.0 | Device location |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Dark theme + colors
├── models/
│   └── weather_model.dart       # Data models
├── services/
│   └── weather_service.dart     # API calls (MapTiler, Open-Meteo, AVWX)
├── controllers/
│   └── weather_controller.dart  # GetX controller (all app logic)
├── views/
│   └── weather_screen.dart      # Main single-page UI
└── widgets/
    ├── arc_gauge.dart           # Custom arc gauges + wind rose
    └── hourly_chart.dart        # FL Chart hourly forecast
```

---

## 🌐 APIs Used

| API | Cost | Purpose |
|-----|------|---------|
| [MapTiler](https://cloud.maptiler.com) | Free (100K/mo) | Satellite maps + Weather tiles |
| [Open-Meteo](https://open-meteo.com) | Completely Free | Weather data + forecasts |
| [AVWX](https://avwx.rest) | Free tier | Raw METAR strings |

---

## 📱 Supported Platforms
- ✅ Android
- ✅ iOS

---

## 🎨 Design
Dark aviation-inspired UI with:
- JetBrains Mono for technical data readability
- Space Grotesk for headings
- Custom arc gauges with gradient arcs
- Animated wind rose compass
- MapTiler satellite + weather overlay tiles
