import 'package:sdp_1/excel.dart';
import 'package:sdp_1/main_page_socket.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


Dio dio = Dio();

class DatabaseControlPage extends ConsumerWidget {
  const DatabaseControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 30.w,
                      margin: EdgeInsets.only(
                        right: 2.w,
                      ),
                      child: ElevatedButton(
                          onPressed: () async {
                            String result = await ExcelExporter.exportToExcel(
                                ref.watch(dataList));
                            if(context.mounted){
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  duration: const Duration(seconds: 5),
                                  content: Text(result)),
                            );
                            }
                            print(
                                result); // Print the result to see where the file was saved or if there was an error
                          },
                          child: const Text("Export"))),
                  ElevatedButton(
                    onPressed: () async {
                      var directory = await getExternalStorageDirectory();
                      if(context.mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            duration: const Duration(seconds: 5),
                            content:
                                Text('Export Location: ${directory!.path}')),
                      );
                      }
                    }, // Call the openDirectory function when pressed
                    child: const Text('Export Location'),
                  ),
                ],
              ),
            ),
            SizedBox(
                width: 37.w,
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        String url = 'https://officially-polished-ray.ngrok-free.app/reset';

                        Response response = await dio.post(url);

                        if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response.data)));
                        }
                      } catch (e) {
                        if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mobile Error: $e')),
                        );
                        }
                      }
                    },
                    child: const Text("Reset database")))
          ],
        ),
      ),
    );
  }
}
