import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/presentacion/screens/welcome_screen.dart';
import 'package:flutter_application_1/presentacion/screens/course_screen.dart';
import 'package:flutter_application_1/presentacion/screens/signature_screen.dart';
import 'package:flutter_application_1/presentacion/screens/content_screen.dart';
// import 'package:flutter_application_1/presentacion/screens/counternumber_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => WelcomeScreen(),
      ),
      GoRoute(
        path: '/course',
        builder: (context, state) => const CourseScreen(),
      ),
      GoRoute(
        path: '/signature',
        builder: (context, state) {
          final courseId = state.extra as int;
          return SignatureScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/content',
        builder: (context, state) => const ContentScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routerConfig: _router, // Aquí usamos routerConfig en lugar de home
    );
  }
}
