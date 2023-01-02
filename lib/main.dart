import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_chat_parser/views/splash_view.dart';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter WhatsApp Chat Parser',
      theme: ThemeData(
        primaryColor: Color(0xFF00C263),
      ),
      home: SplashView(),
    );
  }
}
