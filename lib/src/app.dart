import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // para gestionar soporte español, requiere añadir flutter_localization a pubspec.yaml y ejecutar flutter pub get
import 'routes/routes.dart'; // para importar rutas
import 'theme/app_theme.dart'; // para importar temas

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitMark',
      debugShowCheckedModeBanner: false, // quitar el banner de debug
      theme: AppTheme.darkTheme,// importar themes
      initialRoute: '/',
      routes: getApplicationRoutes(), // import rutas
      
      // configuración para el soporte español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es')
      ]
    );
  }
}