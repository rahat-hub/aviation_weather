import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class HourlyForecastChart extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final String type; // 'temp', 'wind', 'rain'

  const HourlyForecastChart({
    super.key,
    required this.forecasts,
    this.type = 'temp',
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final spots = forecasts.asMap().entries.map((e) {
      double val;
      switch (type) {
        case 'wind':
          val = e.value.windSpeed;
          break;
        case 'rain':
          val = e.value.precipitation;
          break;
        default:
          val = e.value.temperature;
      }
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    Color lineColor;
    List<Color> gradColors;
    switch (type) {
      case 'wind':
        lineColor = AppTheme.windCyan;
        gradColors = [AppTheme.windCyan.withValues(alpha: 0.3), Colors.transparent];
        break;
      case 'rain':
        lineColor = AppTheme.accent;
        gradColors = [AppTheme.accent.withValues(alpha: 0.3), Colors.transparent];
        break;
      default:
        lineColor = AppTheme.tempOrange;
        gradColors = [AppTheme.tempOrange.withValues(alpha: 0.3), Colors.transparent];
    }

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.border,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (val, meta) => Text(
                  val.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textMuted,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 3,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= forecasts.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('HH').format(forecasts[idx].time),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.textMuted,
                      fontFamily: 'JetBrainsMono',
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }
}

class HourlyScrollStrip extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const HourlyScrollStrip({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.length,
        itemBuilder: (_, i) {
          final f = forecasts[i];
          return Container(
            width: 56,
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgCardLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateFormat('HH:mm').format(f.time),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textMuted,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
                _conditionIcon(f.condition),
                Text(
                  '${f.temperature.toInt()}°',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop,
                        size: 7, color: AppTheme.accent),
                    const SizedBox(width: 1),
                    Text(
                      '${f.precipitation.toInt()}%',
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.textMuted,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _conditionIcon(String condition) {
    IconData icon;
    Color color;
    switch (condition.toLowerCase()) {
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
      case 'clear':
        icon = Icons.wb_sunny;
        color = AppTheme.accentGold;
        break;
      default:
        icon = Icons.cloud;
        color = AppTheme.textSecondary;
    }
    return Icon(icon, size: 14, color: color);
  }
}
