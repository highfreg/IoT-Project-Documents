import 'package:sdp_1/chart.dart';
import 'package:sdp_1/main_page_socket.dart';
import 'package:sdp_1/pages/data.dart';
import 'package:sdp_1/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';




class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {



  @override
  Widget build(BuildContext context) {
    var list = ref.watch(timePeriodDataList);

    double device1CostTotal = 0;
  double device2CostTotal = 0;
  double totalCostSum = 0;

  for (DataModel data in list) {
    device1CostTotal += data.device1Cost;
    device2CostTotal += data.device2Cost;
    totalCostSum += data.total;
  }


    
    return Padding(
      padding: EdgeInsets.all(1.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*  ElevatedButton(onPressed: (){
              _initializeSocketConnection();
            }, child: Icon(Icons.abc))*/
          const CurrentChart(),
          Container(
              padding: EdgeInsets.only(left:3.w,right: 3.w,bottom: 3.w,top:4.h),
              height: 35.h,
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: AppColors.listViewContainerBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.containerBorder),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  
                  children: [
                    const Text(
                      "Device 1",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${device1CostTotal.toStringAsFixed(2)} ₺", // Device 1 Cost
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Device 2",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${device2CostTotal.toStringAsFixed(2)} ₺", // Device 2 Cost
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                        color: Colors.blueAccent,
                        thickness: 1), // Line to separate total cost
                    const SizedBox(height: 8),
                    Text(
                      "Total Cost: ${totalCostSum.toStringAsFixed(2)} ₺", // Total Cost
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ])),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Data()), // TargetPage yerine gitmek istediğiniz sayfayı koyun
              );
            },
            child: const Text('Go to Target Page'),
          )
        ],
      ),
    );
  }
}
