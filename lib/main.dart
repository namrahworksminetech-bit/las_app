import 'package:flutter/material.dart';
import 'package:las_app/core/injection_container.dart'; // dependency setup file
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize dependencies (GetIt, ApiClient, AppStateProvider)
  await initDependencies();

  runApp(const SliqApp());
}
