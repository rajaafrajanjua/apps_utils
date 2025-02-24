import 'dart:async';

import 'package:apps_utils/apps_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<AppInfo> _allApps = [];
  List<AppInfo> _systemApps = [];
  List<AppInfo> _userApps = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    loadAppsInfo();
  }

  Future<void> initPlatformState() async {
    String? platformVersion;
    try {
      platformVersion = await AppsUtils.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion ?? 'Unknown';
    });
  }

  Future<void> loadAppsInfo() async {
    try {
      final allApps = await AppsUtils.getInstalledApps(appType: AppType.all);
      final systemApps = await AppsUtils.getInstalledApps(
        appType: AppType.system,
      );
      final userApps = await AppsUtils.getInstalledApps(appType: AppType.user);

      if (!mounted) return;

      setState(() {
        _allApps = allApps;
        _systemApps = systemApps;
        _userApps = userApps;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading apps info: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Apps Utils Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Platform Version: $_platformVersion'),
              const SizedBox(height: 16),
              Text('Total Apps: ${_allApps.length}'),
              Text('System Apps: ${_systemApps.length}'),
              Text('User Apps: ${_userApps.length}'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => AppsUtils.openSystemApp(SystemApps.clock),
                    child: const Text('Open Clock'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppsUtils.openSystemApp(SystemApps.calendar),
                    child: const Text('Open Calendar'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppsUtils.openSystemApp(SystemApps.phone),
                    child: const Text('Open Phone'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
