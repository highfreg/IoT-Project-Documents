import 'package:intl/intl.dart';
import 'package:sdp_1/main_page_socket.dart';
import 'package:sdp_1/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

StateProvider<int> timePeriodIndex = StateProvider<int>((ref) {
  return 0;
});

StateProvider<List<DataModel>> timePeriodDataList =
    StateProvider<List<DataModel>>((ref) {
  DateTime now = DateTime.now();
  switch (ref.watch(timePeriodIndex)) {
    case 0:
      return ref.watch(dataList);
    case 1:
      return ref
          .watch(dataList)
          .where((item) =>
              item.timestamp.isAfter(now.subtract(const Duration(days: 30))))
          .toList();
    case 2:
      return ref
          .watch(dataList)
          .where((item) =>
              item.timestamp.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    case 3:
      return ref
          .watch(dataList)
          .where((item) =>
              item.timestamp.isAfter(now.subtract(const Duration(days: 1))))
          .toList();
    case 4:
      return ref
          .watch(dataList)
          .where((item) =>
              item.timestamp.isAfter(now.subtract(const Duration(hours: 1))))
          .toList();
    default:
      return ref.watch(dataList);
  }
});

class CurrentChart extends ConsumerStatefulWidget {
  const CurrentChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CurrentChartState();
}

class _CurrentChartState extends ConsumerState<CurrentChart> {
  final Duration animDuration = const Duration(milliseconds: 250);

  ButtonStyle dynamicButtonStyle(int buttonIndex) {
    return ElevatedButton.styleFrom(
      // Eğer buttonIndex mevcut timePeriodIndex'e eşitse beyaz bir outline ekleriz
      side: BorderSide(
        color: buttonIndex == ref.watch(timePeriodIndex)
            ? Colors.white
            : Colors.transparent,
        width: 2.0,
      ),
      backgroundColor:
          AppColors.chartButtonBackground, // Varsayılan arkaplan rengi
      foregroundColor: AppColors.chartButtonForeground, // Yazı rengi
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        SfCartesianChart(
          legend: const Legend(
            isVisible: true,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          trackballBehavior: TrackballBehavior(
            enable: true, // Enable trackball interaction
            tooltipSettings: const InteractiveTooltip(
              enable: true, // Enable tooltips for the trackball
              // format: 'ID: point.x\n point.y', // Customize tooltip format
            ),
          ),

          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Allow panning
            enablePinching: true, // Enable pinch-to-zoom
            enableDoubleTapZooming: true, // Enable double-tap zooming
          ),

          // Initialize category axis
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.auto,
            majorGridLines: const MajorGridLines(width: 0),
            desiredIntervals: 3,
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              // Epoch time'ı DateTime'a dönüştürme
              DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(details.value.toInt());
              String formattedDate = DateFormat('MM/dd/yy').format(date);
              String formattedTime = DateFormat('HH:mm').format(date);
              return ChartAxisLabel(
                '$formattedDate\n$formattedTime', // Tarih ve saat alt alta
                const TextStyle(
                    color: Colors.white,
                    fontSize: 9), // İsteğe bağlı: Yazı rengi veya stili
              );
            },
          ),

          series: <CartesianSeries>[
            LineSeries<DataModel, DateTime>(
              dataSource: ref.watch(timePeriodDataList),
              // timeperiod ayarlandığında grafikte verielrin 0 dan gözükmesi için 0.index id'si çıkartılır
              xValueMapper: (DataModel data, _) => data.timestamp,
              yValueMapper: (DataModel data, _) => data.device1Current,
              color: AppColors.device1,
              legendItemText: "d-1 A",
              animationDuration: 0,
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
            LineSeries<DataModel, DateTime>(
              dataSource: ref.watch(timePeriodDataList),
              xValueMapper: (DataModel data, _) => data.timestamp,
              yValueMapper: (DataModel data, _) => data.device1Power,
              dashArray: const [5, 3],
              color: AppColors.device1,
              legendItemText: "d-1 W",
              animationDuration: 0,
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
            LineSeries<DataModel, DateTime>(
              dataSource: ref.watch(timePeriodDataList),
              // timeperiod ayarlandığında grafikte verielrin 0 dan gözükmesi için 0.index id'si çıkartılır
              xValueMapper: (DataModel data, _) => data.timestamp,
              yValueMapper: (DataModel data, _) => data.device2Current,
              color: AppColors.device2,
              legendItemText: "d-2 A",
              animationDuration: 0,
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
            LineSeries<DataModel, DateTime>(
              dataSource: ref.watch(timePeriodDataList),
              xValueMapper: (DataModel data, _) => data.timestamp,
              yValueMapper: (DataModel data, _) => data.device2Power,
              dashArray: const [5, 3],
              color: AppColors.device2,
              legendItemText: "d-2 W",
              animationDuration: 0,
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
          ],
        ),
        Container(
          width: 100.w,
          height: 5.h,
          margin: EdgeInsets.only(top: 1.w, bottom: 1.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    ref.watch(timePeriodIndex.notifier).state = 4;
                  },
                  style: dynamicButtonStyle(4),
                  child: const Text("Hour")),
              ElevatedButton(
                  onPressed: () {
                    ref.watch(timePeriodIndex.notifier).state = 3;
                  },
                  style: dynamicButtonStyle(3),
                  child: const Text("Day")),
              ElevatedButton(
                  onPressed: () {
                    ref.watch(timePeriodIndex.notifier).state = 2;
                  },
                  style: dynamicButtonStyle(2),
                  child: const Text("Week")),
              ElevatedButton(
                  onPressed: () {
                    ref.watch(timePeriodIndex.notifier).state = 1;
                  },
                  style: dynamicButtonStyle(1),
                  child: const Text("Month")),
              ElevatedButton(
                  onPressed: () {
                    ref.watch(timePeriodIndex.notifier).state = 0;
                  },
                  style: dynamicButtonStyle(0),
                  child: const Text("All"))
            ],
          ),
        )
      ],
    ));
  }
}
