import 'package:flutter/material.dart';
import 'package:tionova/features/start/presentation/view/screens/TioNovaspalsh.dart';

class TioNovaSplashScreen extends StatelessWidget {
  const TioNovaSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.white, body: SplashScreen()),
    );
  }
}
