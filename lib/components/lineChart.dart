import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartGraphWidget extends StatelessWidget {
  const LineChartGraphWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(.9),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${value.toInt()}k', style: style),
                  );
                },
                reservedSize: 35,
                interval: 10,
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 50,
              interval: 1,
            )),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('MAR', style: style);
                        break;
                      case 1:
                        text = const Text('JUN', style: style);
                        break;
                      case 2:
                        text = const Text('SEP', style: style);
                        break;
                      case 3:
                        text = const Text('OCT', style: style);
                        break;

                      default:
                        text = const Text('', style: style);
                        break;
                    }
                    return SideTitleWidget(
                      space: 20,
                      axisSide: meta.axisSide,
                      child: text,
                    );
                  },
                  reservedSize: 40,
                  interval: 1),
            ),
          ),
          borderData: FlBorderData(
            show: false, // Remove the border
          ),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 50,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 15),
                FlSpot(1, 10),
                FlSpot(2, 40),
                FlSpot(3, 10),
              ],
              isCurved: true,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              color: Colors.pink,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.pink.withOpacity(
                    0.2), // Set the color of the layer below the line
              ),
            ),
          ],
        ),
      ),
    );
  }
}
