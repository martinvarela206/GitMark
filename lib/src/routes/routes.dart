import "../../src/pages/home_page.dart";
import "package:flutter/material.dart";

Map<String, WidgetBuilder> getApplicationRoutes(){
  return <String, WidgetBuilder>{
    "/": (BuildContext context) => const HomePage(),
  };
}