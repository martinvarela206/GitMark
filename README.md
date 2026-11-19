# GitMark

GitMark es un cliente ágil enfocado en la exploración, lectura formateada y edición directa de archivos `.md` en repositorios remotos de GitHub mediante la API REST v3, sin necesidad de clonar historiales pesados.	

## Funcionalidades

- Exploración de repositorios públicos, privados o con acceso de colaborador.
- Previsualización estilada de Markdowns.
- Modo Anónimo o logeado.
- Edición de Markdown WYSIWYG y pusheo al repositorio.
- Almacenamiento de recientes en BBDD SQLite en el dispositivo, para reducir el consumo de peticiones a la API de Github y modificar markdowns sin conexión.

## Aplicaciones similares

- GitHub mobile: Edición limitada, sin prioridad hacia la lectura fluida de los markdowns.
- GitJournal: No permite explorar repositorios de terceros.
- Markor: Requiere otras herramientas para sincronización con GitHub.

## Implementado

- Creado el proyecto vacío y refactorizado para separar responsabilidades entre `main.dart` y `app.dart` (`MainApp`).
- Añadir el widget RepoCard que muestra información base de los repositorios encontrados o guardados.
- Widget RepoCard añadido, mostrando información de un repositorio hardcodeado inicialmente.
- Añadir el AppBar con pestañas, branding e Indicador de uso de API, y drawer.
- Añadir la SearchBar, RecentRepoBanner, SectionTitle y ListView para Repos.
- Dejar de utilizar datos hardcodeados y utilizar archivos JSON locales con `LocalDataService` y `FutureBuilder`.
- Visor de archivos Markdown con estilos y resaltado de código mediante `flutter_markdown`.

## Cómo funciona

- **Modelos (`models/`):** Contienen todo el código para poder parsear desde JSON local mediante constructores `factory fromJson` y, a futuro, desde la API de GitHub v3. Además disponen de `toMap()` para persistencia en base de datos.
- **Servicios (`services/`):** En `services/` está el código para cargar actualmente los archivos físicos locales (`local_data_service.dart`). A futuro se añadirá `github_service.dart` para interactuar con la API de GitHub y `database_service.dart` para persistir los repositorios recientes en SQLite (`sqflite`).
- **En `local_data_service.dart`:**
  - En la parte de `json.decode(resp)` es donde se leen y parsean los archivos físicos locales cargados con `rootBundle.loadString()`.
  - En `loadLocalMarkdown(fileName)` es donde se carga por defecto el `README.md` como mecanismo de respaldo seguro (fallback) cualquiera sea el archivo seleccionado si este no existe físicamente en los assets.
- **En `document_view_page.dart`:** Es la vista que muestra el Markdown; utiliza el widget `Markdown()` de la librería **flutter_markdown**, que es el encargado de parsear y estilizar los textos con jerarquía, bloques de código en verde (`codigoVerde`) y reglas visuales.
- **Uso de `AsyncSnapshot` en las páginas (`FutureBuilder`):** Permite gestionar reactivamente los tres estados de una operación asíncrona:
  1. Si está cargando (`ConnectionState.waiting`), muestra el círculo de progreso (`CircularProgressIndicator`).
  2. Si ocurre un fallo (`snapshot.hasError`), muestra el mensaje de error.
  3. Si la respuesta está lista (`snapshot.data`), devuelve los datos procesados (el contenido Markdown estilizado o la lista de `RepoCard`).

## Para la presentación prefinal

Para más adelante hay que cargar los repos públicos de GitHub en tiempo real y efectivamente leer los archivos Markdown de esos repos remotos. Hay que contemplar la resolución de imágenes relativas enlazadas en los markdowns (`MarkdownImageResolver`). Guardar en local los repositorios recientes con SQLite (`sqflite`) para evitar consumir peticiones a la API innecesariamente y mostrar en tiempo real el consumo de la cuota con un semáforo reactivo.
