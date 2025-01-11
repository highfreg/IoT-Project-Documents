import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sdp_1/chart.dart';
import 'package:sdp_1/theme/colors.dart';

class Data extends ConsumerStatefulWidget {
  const Data({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DataState();
}

class _DataState extends ConsumerState<Data> {
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
    var list = ref.watch(timePeriodDataList).reversed.toList();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
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
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ref.watch(timePeriodDataList).length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  return Container(
                    width: 100.w,
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.listViewContainerBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.containerBorder),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device 1 - Current: ${data.device1Current} A, Power: ${data.device1Power} W',
                            style:
                                const TextStyle(color: AppColors.containerText,fontSize: 14 ),
                          ),
                          Text(
                            'Device 2 - Current: ${data.device2Current} A, Power: ${data.device2Power} W',
                            style:
                                const TextStyle(color: AppColors.containerText,fontSize: 14),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Timestamp: ${data.timestamp.toLocal()}',
                        style: const TextStyle(color: AppColors.containerText),
                      ),
                      trailing: Text(
                        'ID: ${data.id - ref.watch(timePeriodDataList)[0].id}',
                        style: const TextStyle(color: AppColors.containerText),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
