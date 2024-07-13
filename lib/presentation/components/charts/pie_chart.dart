// import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class CustomPieChart extends StatefulWidget {
//   const CustomPieChart({super.key});

//   @override
//   State<CustomPieChart> createState() => _CustomPieChartState();
// }

// class _CustomPieChartState extends State<CustomPieChart> {
//   int touchedIndex = 0;
//   // final List<ChartData> chartData = [
//   //   ChartData('David', 25),
//   //   ChartData('Steve', 38),
//   //   ChartData('Jack', 34),
//   //   ChartData('Others', 52)
//   // ];

//   @override
//   Widget build(BuildContext context) {
//     // return SfCircularChart(series: <CircularSeries>[
//     //   // Render pie chart
//     //   PieSeries<ChartData, String>(
//     //       dataSource: chartData,
//     //       pointColorMapper: (ChartData data, _) => data.color,
//     //       xValueMapper: (ChartData data, _) => data.x,
//     //       yValueMapper: (ChartData data, _) => data.y)
//     // ]);
//     return PieChart(
//       PieChartData(
//         pieTouchData: PieTouchData(
//           touchCallback: (FlTouchEvent event, pieTouchResponse) {
//             setState(() {
//               if (!event.isInterestedForInteractions ||
//                   pieTouchResponse == null ||
//                   pieTouchResponse.touchedSection == null) {
//                 touchedIndex = -1;
//                 return;
//               }
//               touchedIndex =
//                   pieTouchResponse.touchedSection!.touchedSectionIndex;
//             });
//           },
//         ),
//         borderData: FlBorderData(
//           show: false,
//         ),
//         sectionsSpace: 0,
//         centerSpaceRadius: 0,
//         sections: showingSections(),
//       ),
//     );
//   }

//   List<PieChartSectionData> showingSections() {
//     return List.generate(4, (i) {
//       final isTouched = i == touchedIndex;
//       final fontSize = isTouched ? 20.0 : 16.0;
//       final radius = isTouched ? 110.0 : 100.0;
//       final widgetSize = isTouched ? 55.0 : 40.0;
//       const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

//       switch (i) {
//         case 0:
//           return PieChartSectionData(
//             color: colorStyle.red,
//             value: 40,
//             title: '40%',
//             radius: radius,
//             titleStyle: TextStyle(
//               fontSize: fontSize,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xffffffff),
//               shadows: shadows,
//             ),
//             badgeWidget: _Badge(
//               'assets/icons/ophthalmology-svgrepo-com.svg',
//               size: widgetSize,
//               borderColor: colorStyle.black,
//             ),
//             badgePositionPercentageOffset: .98,
//           );
//         case 1:
//           return PieChartSectionData(
//             color: colorStyle.yellow,
//             value: 30,
//             title: '30%',
//             radius: radius,
//             titleStyle: TextStyle(
//               fontSize: fontSize,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xffffffff),
//               shadows: shadows,
//             ),
//             badgeWidget: _Badge(
//               'assets/icons/librarian-svgrepo-com.svg',
//               size: widgetSize,
//               borderColor: colorStyle.black,
//             ),
//             badgePositionPercentageOffset: .98,
//           );
//         case 2:
//           return PieChartSectionData(
//             color: colorStyle.blue,
//             value: 16,
//             title: '16%',
//             radius: radius,
//             titleStyle: TextStyle(
//               fontSize: fontSize,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xffffffff),
//               shadows: shadows,
//             ),
//             badgeWidget: _Badge(
//               'assets/icons/fitness-svgrepo-com.svg',
//               size: widgetSize,
//               borderColor: colorStyle.black,
//             ),
//             badgePositionPercentageOffset: .98,
//           );
//         case 3:
//           return PieChartSectionData(
//             color: colorStyle.green,
//             value: 15,
//             title: '15%',
//             radius: radius,
//             titleStyle: TextStyle(
//               fontSize: fontSize,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xffffffff),
//               shadows: shadows,
//             ),
//             badgeWidget: _Badge('assets/icons/worker-svgrepo-com.svg',
//                 size: widgetSize, borderColor: colorStyle.black),
//             badgePositionPercentageOffset: .98,
//           );
//         default:
//           throw Exception('Oh no');
//       }
//     });
//   }
// }

// class _Badge extends StatelessWidget {
//   const _Badge(
//     this.svgAsset, {
//     required this.size,
//     required this.borderColor,
//   });
//   final String svgAsset;
//   final double size;
//   final Color borderColor;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: PieChart.defaultDuration,
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: borderColor,
//           width: 2,
//         ),
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: Colors.black.withOpacity(.5),
//             offset: const Offset(3, 3),
//             blurRadius: 3,
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(size * .15),
//       child: Center(
//           // child: SvgPicture.asset(
//           //   svgAsset,
//           // ),
//           ),
//     );
//   }
// }

// class ChartData {
//   ChartData(this.x, this.y, [this.color]);
//   final String x;
//   final double y;
//   final Color? color;
// }
