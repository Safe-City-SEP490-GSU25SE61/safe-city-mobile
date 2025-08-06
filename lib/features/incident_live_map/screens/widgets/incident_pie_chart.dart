import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';

class IncidentPieChart extends StatefulWidget {
  final int traffic;
  final int security;
  final int infrastructure;
  final int environment;
  final int other;

  const IncidentPieChart({
    super.key,
    required this.traffic,
    required this.security,
    required this.infrastructure,
    required this.environment,
    required this.other,
  });

  @override
  State<IncidentPieChart> createState() => _IncidentPieChartState();
}

class _IncidentPieChartState extends State<IncidentPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total =
        widget.traffic +
        widget.security +
        widget.infrastructure +
        widget.environment +
        widget.other;

    final labels = ['Giao thông', 'An ninh', 'Hạ tầng', 'Môi trường', 'Khác'];
    final values = [
      widget.traffic,
      widget.security,
      widget.infrastructure,
      widget.environment,
      widget.other,
    ];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.grey,
    ];

    return Center(
      child: SizedBox(
        height: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📊 Pie Chart
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        startDegreeOffset: 270,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: List.generate(5, (i) {
                          final isTouched = i == touchedIndex;
                          final double value = values[i].toDouble();
                          final double percent = total > 0
                              ? (value / total * 100)
                              : 0;

                          return PieChartSectionData(
                            color: colors[i],
                            value: value,
                            title: percent % 1 == 0
                                ? '${percent.toInt()}%'
                                : '${percent.toStringAsFixed(1)}%',
                            radius: isTouched ? 60 : 50,
                            titleStyle: TextStyle(
                              fontSize: isTouched ? 18 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tổng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: TSizes.xl),
            // 📋 Legend List
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[i],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${labels[i]}: ${values[i]}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
