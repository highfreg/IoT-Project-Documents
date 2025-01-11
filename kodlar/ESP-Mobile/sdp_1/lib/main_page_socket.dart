import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;
import 'package:sdp_1/pages/ai_page.dart';
import 'package:sdp_1/pages/database_control_page.dart';
import 'package:sdp_1/pages/home_page.dart';
import 'package:sdp_1/theme/colors.dart';

StateProvider<List<DataModel>> dataList = StateProvider<List<DataModel>>((ref) {
  return [];
});

StateProvider<int> index = StateProvider<int>((ref) {
  return 0;
});

class MainPageSocket extends ConsumerStatefulWidget {
  const MainPageSocket({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageSocketState();
}

class _MainPageSocketState extends ConsumerState<MainPageSocket> {
  late socket_io_client.Socket socket;

  @override
  void initState() {
    super.initState();
    _initializeSocketConnection();
  }

  // Node Socket.io bağlantısı yapma
  // içeride try catch yapmaya gerek yok çünkü socket server açılana kadar
  // bağlanmaya çalışır
  void _initializeSocketConnection() {
    // Sunucuya bağlanıyoruz
    socket = socket_io_client.io('https://officially-polished-ray.ngrok-free.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // sunucuya bağlantıyı başlatır.
    socket.connect();

    // Bu olay, sunucudan initial_data olayı ile tüm verileri alır
    socket.on('initial_data', (data) {
      print('Initial data received: $data');

      // Map the JSON list to a list of DataModel objects
      ref.read(dataList.notifier).state = (data as List)
          .map((jsonItem) => DataModel.fromJson(jsonItem))
          .toList();
    });

    // Sunucudan yeni bir veri geldiğinde (örneğin yeni bir veri veritabanına eklendiğinde), bu olay tetiklenir
    socket.on('new_data', (newData) {
      print('New data received: $newData');

      // state değişmesi lazım ki UI değişikliği olsun(add çalışmaz ui için)
      ref.read(dataList.notifier).state = [
        ...ref.watch(dataList),
        DataModel.fromJson(newData)
      ];
    });
  }

  @override
  void dispose() {
    // Disconnect the socket when the widget is disposed
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //reversed property in Dart returns an Iterable and not a List.
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldAppBarBackground,
          iconTheme: const IconThemeData(
            color: AppColors.scaffoldAppBarIcon
          ),
          title: const Text(
            'Real-time Data',
            style: TextStyle(color: AppColors.scaffoldIconTitle),
          ),
        ),
        drawer: Drawer(
          width: 50.w,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.scaffoldDrawerHeader,
                ),
                child: Text(
                  'ESP-Interface',
                  style: TextStyle(
                    color: AppColors.scaffoldDrawerHeaderText,
                    fontSize: 24,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(index.notifier).state = 0;
                  
                },
              ),

              ListTile(
                leading: const Icon(Icons.computer),
                title: const Text('AI Help'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(index.notifier).state = 1;
                  
                },
              ),

              ListTile(
                leading: const Icon(Icons.data_object_sharp),
                title: const Text('Database'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(index.notifier).state = 2; 
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: switch (ref.watch(index)) {
            0 => const HomePage(),
            1 => const AiPage(),
            2 => const DatabaseControlPage(),
            _ => const Text('Unknown widget')
          },
        ));
  }
}

// DataModel class
class DataModel {
  final int id;
  final String device1DeviceId;
  final double device1Current;
  final double device1Power;
  final double device1Cost;
  final String device2DeviceId;
  final double device2Current;
  final double device2Power;
  final double device2Cost;
  final double total;
  final DateTime timestamp;

  DataModel({
    required this.id,
    required this.device1DeviceId,
    required this.device1Current,
    required this.device1Power,
    required this.device1Cost,
    required this.device2DeviceId,
    required this.device2Current,
    required this.device2Power,
    required this.device2Cost,
    required this.total,
    required this.timestamp,
  });

  // JSON'dan bir instance oluşturmak için factory method
  factory DataModel.fromJson(Map<String, dynamic> json) {
    var cost1 = double.parse(json['device1_power'])* 0.00070486111;
    var cost2 = double.parse(json['device2_power'])* 0.00845833332;

    return DataModel(
      id: json['id'],
      device1DeviceId: json['device1_deviceid'],
      device1Current: double.parse(json['device1_current']),
      device1Power: double.parse(json['device1_power']),
      device1Cost: cost1,
      device2DeviceId: json['device2_deviceid'],
      device2Current: double.parse(json['device2_current']),
      device2Power: double.parse(json['device2_power']),
      device2Cost: cost2,
      total: cost1 + cost2,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
