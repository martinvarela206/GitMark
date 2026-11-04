# GitMark — Lector Móvil de Markdown

¡Bienvenido a **GitMark**! Una aplicación móvil desarrollada en Flutter para explorar repositorios y leer documentación en formato Markdown de manera fluida y adaptada a dispositivos móviles.

---

## 🚀 Características Principales

- **Exploración Rápida:** Navegación por repositorios simulados y remotos.
- **Renderizado Nativo:** Soporte tipográfico completo con `flutter_markdown`.
- **Tema Oscuro Oficial:** Paleta inspirada en el diseño moderno de GitHub.
- **Bloques de Código:** Sintaxis monoespaciada de alto contraste.

---

## 💻 Ejemplo de Código

A continuación se muestra el punto de entrada principal del aplicativo:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}
```

---

> [!NOTE]
> Este archivo `README.md` se carga localmente desde la carpeta `assets/data/` para simular la lectura de archivos Markdown antes de conectarse a la API oficial de GitHub.

### 📋 Checklist de Pruebas
- [x] Títulos H1, H2 y H3 con jerarquía visual
- [x] Párrafos con interlineado óptimo
- [x] Bloques de código con resaltado verde
- [x] Citas en bloque con borde cyan

