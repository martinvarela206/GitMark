import 'package:flutter/material.dart';
import '../pages/home_page.dart';

/// Diccionario asociativo centralizado de rutas nombradas de la aplicación.
/// 
/// ¿Por qué se separa en un archivo independiente y no se escribe dentro de app.dart?
/// Por escalabilidad limpia: si mañana la aplicación crece y agregamos pantallas de
/// configuración, favoritos o perfil, solo se añaden aquí sin ensuciar la configuración
/// general de MaterialApp.
/// 
/// ¿Qué es un WidgetBuilder?
/// Es una función que recibe el contexto (BuildContext) y sabe cómo construir e instanciar
/// la pantalla correspondiente cuando Navigator.pushNamed(context, '/ruta') es invocado.
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => const HomePage(),
  };
}
