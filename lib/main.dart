import 'package:flutter/material.dart';
import 'package:las_app/core/injection_container.dart'; // dependency setup file
import 'package:upgrader/upgrader.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();

  // ✅ Initialize dependencies (GetIt, ApiClient, AppStateProvider)
  await initDependencies();



  runApp(const SliqApp());
}
