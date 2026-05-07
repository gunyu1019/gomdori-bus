import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:gomdori_bus/presentation/page/map_page.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

  runApp(const GomdoriApp());
}

final route = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, widget) => Scaffold(body: widget),
      routes: [
        GoRoute(path: "/", builder: (_, _) => MapPage()),
      ],
    ),
  ],
);

class GomdoriApp extends StatelessWidget {
  const GomdoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: route);
  }
}