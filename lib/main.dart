import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/audio_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const CrystalPopperz());
}

class CrystalPopperz extends StatefulWidget {
  const CrystalPopperz({super.key});

  @override
  State<CrystalPopperz> createState() => _CrystalPopperZState();
}

class _CrystalPopperZState extends State<CrystalPopperz> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onPause: () => AudioManager.instance.stopImmediately(),
      onDetach: () => AudioManager.instance.stopImmediately(),
      onHide: () => AudioManager.instance.stopImmediately(),
      onResume: () => AudioManager.instance.resumeMusic(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioManager>.value(
      value: AudioManager.instance,
      child: MaterialApp(
        title: 'CrystalPopperz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}