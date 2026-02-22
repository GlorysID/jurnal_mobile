import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PerformanceTrendChart extends StatelessWidget {
  final List<double> equityCurve;

  const PerformanceTrendChart({super.key, required this.equityCurve});

  @override
  Widget build(BuildContext context) {
    if (equityCurve.length < 2) {
      return Container(
        height: 180,
        decoration: AppTheme.getCardDecoration(),
        child: const Center(
          child: Text(
            'Not enough data to show trend',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < equityCurve.length; i++) {
      spots.add(FlSpot(i.toDouble(), equityCurve[i]));
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: AppTheme.getCardDecoration(),
      padding: const EdgeInsets.fromLTRB(8, 24, 20, 12),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.borderColor.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 1000,
                getTitlesWidget: leftTitleWidgets,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (equityCurve.length - 1).toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: AppTheme.accentGradient,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.2),
                    AppTheme.accentColor.withValues(alpha: 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppTheme.textSecondary,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value <= -1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }
}
