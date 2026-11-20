# GitMark

GitMark es un cliente móvil ágil enfocado en la exploración, lectura formateada y edición directa de archivos `.md` en repositorios remotos de GitHub mediante la API REST v3, sin necesidad de clonar historiales pesados.

## Funcionalidades

### Implementadas
- **Arquitectura y UI modular:** Separación limpia entre `main.dart` y `app.dart`, AppBar con branding, Drawer lateral, `RecentRepoBanner`, `RepoCard` interactivo y scroll infinito con `ListView.builder`.
- **Integración con API REST v3 de GitHub:** Consulta de metadatos, árbol de carpetas y descarga de contenido Markdown crudo en tiempo real mediante `GitHubService`.
- **Caché y Persistencia Offline (SQLite):** `DatabaseService` relacional con estrategia *Cache-First* para metadatos (`repositories`), estructura de directorios (`repo_tree`) y contenido de documentos (`markdown_cache`).
- **Sincronización Selectiva:** Detección de cambios remotos contrastando `updated_at` con icono de nube interactivo (`cloud_done` / `cloud_download_outlined`) y alertas contextuales.
- **Monitor Reactivo de Cuota:** Semáforo en vivo (`RateLimitService` y `CuotaApiInfo`) alimentado por los encabezados `x-ratelimit-*`.
- **Visor de Markdown Estilizado:** Renderizado en modo oscuro con `flutter_markdown` en `DocumentViewPage`, bloques de código tematizados y selección nativa de texto.
- **Fallback Local Seguro:** Carga de repositorios empaquetados mediante `LocalDataService` para contingencias o demostraciones.

### Planificadas (Para la versión final)
- **Reestructuración de Pestañas Principales:**
  - **Recomendados:** Muestra en primer lugar el acceso rápido al último repositorio visitado, seguido por el repositorio oficial de GitMark (`martinvarela206/GitMark`), el perfil personalizado del autor (`martinvarela206`) y `LeCoupa/awesome-cheatsheets`.
  - **Recientes:** Repositorios almacenados localmente en SQLite, limitados a un cupo máximo estricto de 20 elementos para cuidar la memoria del móvil (política de reemplazo por inactividad: al alcanzar el límite, se depura automáticamente el que lleve más tiempo sin ser accedido).
  - **Buscados:** Pestaña exclusiva donde reside la barra de búsqueda; retiene en memoria los metadatos de las búsquedas recientes para su consulta ágil sin persistirlos en SQLite.
  - **Privados:** Sección dedicada a los repositorios propios del usuario autenticado.
- **Edición de Texto y Flujo de Confirmación:**
  - Editor en texto plano mediante campo desplazable con scroll (sin componentes WYSIWYG ni barras de estilo).
  - Pantalla secundaria de confirmación para redactar el mensaje de commit y ejecutar el push remoto.
  - Guardado temporal de borradores en SQLite para múltiples documentos simultáneos, permitiendo trabajo offline y depurando automáticamente el registro temporal tras completar el push exitosamente.
- **Autenticación con GitHub (Login / Token):** Identificación de usuario para elevar la cuota a 5.000 req/h y acceder a repositorios privados o de colaborador.
- **Resolución de Imágenes Relativas (`MarkdownImageResolver`):** Conversión automática de rutas relativas locales a URLs crudas absolutas de GitHub para cargar correctamente imágenes dentro de los Markdown.

## Aplicaciones Similares

- **GitHub Mobile:** Edición limitada y sin prioridad hacia la lectura fluida de archivos Markdown.
- **GitJournal:** No permite explorar repositorios de terceros.
- **Markor:** Requiere herramientas externas para sincronizar con repositorios de GitHub.

## Cómo Funciona (Resumen Sintético)

- **Modelos (`models/`):** Clases inmutables con constructores `factory fromJson` para deserialización segura de API o SQLite, `toMap()` para almacenamiento relacional y `copyWith()` para derivación de estados reactivos.
- **Servicios (`services/`):**
  - `GitHubService`: Singleton cliente de red con cabeceras requeridas (`User-Agent`, `Accept: v3`) y resolución jerárquica de contenidos.
  - `DatabaseService`: Singleton SQLite para transacciones, consultas de historial reciente y almacenamiento de árboles y documentos.
  - `RateLimitService`: Singleton reactivo que transmite el estado de consumo de cuota al AppBar.
  - `LocalDataService`: Soporte de contingencia y lectura de activos locales.
- **Vistas y Navegación (`pages/`):**
  - `HomePage`: Orquestador de pestañas, banner dinámico y recarga mediante `RefreshIndicator`.
  - `RepoExplorerPage`: Exploración recursiva de directorios con navegación por pila (`PopScope`) y resolución *Cache-First*.
  - `DocumentViewPage`: Vista de lectura desacoplada con gestión de estados asíncronos mediante `FutureBuilder`.
