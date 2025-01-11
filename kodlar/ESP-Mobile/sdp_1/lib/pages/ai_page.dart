import 'dart:convert';
import 'package:sdp_1/pages/database_control_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

StateProvider<String> aiResponse = StateProvider<String>((ref) {
  return "";
});

StateProvider<bool> progressChecker = StateProvider<bool>((ref) {
  return false;
});

StateProvider<bool> visibilityChecker = StateProvider<bool>((ref) {
  return false;
});

StateProvider<TextEditingController> controller =
    StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

TextEditingController textController = TextEditingController();

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  Future<String> sendMessage() async {
    var text = ref.watch(controller).text;
    ref.watch(controller).clear();
    try {
      String url = 'https://officially-polished-ray.ngrok-free.app/ai';

      Response response = await dio.post(
        url,
        // encode olmasa da olur
        data: jsonEncode({'message': text}),
      );

      return response.data['response'];
    } catch (e) {
      return 'Mobile Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ref.watch(progressChecker)
                ? Center(
                    child: SizedBox(
                      width: 30.w,
                      child: LinearProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Custom color
                        backgroundColor: Colors.grey[200], // Background color
                      ),
                    ),
                  )
                : Flexible(
                    child: Visibility(
                      visible: ref.watch(visibilityChecker),
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: EdgeInsets.all(1.w),
                          constraints: BoxConstraints(
                            maxHeight: 60.h, // Maximum height of the container
                          ),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 33, 33, 33),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blueAccent)),
                          child: SingleChildScrollView(
                            child: Text(
                              ref.watch(aiResponse),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: 30.h // Set a maximum height for the TextField
                    ),
                child: TextField(
                  onSubmitted: (text) async {
                    ref.read(visibilityChecker.notifier).state = false;
                    ref.read(progressChecker.notifier).state = true;
                    String res = await sendMessage();
                    ref.read(progressChecker.notifier).state = false;
                    ref.read(aiResponse.notifier).state = res;
                    ref.read(visibilityChecker.notifier).state = true;
                    print('User pressed enter with text: $text');
                  },
                  textInputAction: TextInputAction.send,
                  controller: ref.watch(controller),
                  style: const TextStyle(color: Colors.white),
                  maxLines: null, // Allows dynamic line height
                  keyboardType:
                      TextInputType.multiline, // Enable multiline input
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: 'Enter your text here',
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  scrollPhysics:
                      const BouncingScrollPhysics(), // Enable internal scrolling
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
