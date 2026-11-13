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
- Markor: Requiere otras herramientas para sincronización con GitHub."			Creado el proyecto vacío y refactorizado para separar el MainApp.

## Implementado

- Añadir el widget RepoCard que mostrara información base de los repositorios encontrados o guardados.
- Widget RepoCard añadido, mostrando información de un repositorio hardcodeado.
- Añadir el AppBar con pestañas, branding e Indicador de uso de API, y drawer.
- Añadir la SearchBar, RecentRepoBanner, SectionTitle y ListView para Repos.
- Dejar de utilizar datos hardcodeados y utilizar un JSON.

## Como funciona

Los models contienen todo el código para poder parsear desde JSON y a futuro desde API de github.

En services esta de el código para cargar actualmente los archivos locales, falta añadir el service para github, y para sqflite cuando se carguen los repos recientes.

En `local_data_service.dart`:
- En la parte de json.decode() es donde lee los archivos físicos.
- En el loadLocalMarkdown() es donde se carga por defecto el README.md cualquiera sea el archivo seleccionado.

`document_view_page.dart` es la vista que muestra el markdown, utiliza el widget `markdown()` que es el encargado de mostrar los textos markdown con estilos, que se incluye con **flutter_markdown**.

## Para la presentación prefinal

Para mas adelante hay que cargar los repos públicos de github y efectivamente leer los archivos markdown de esos repos. Hay que ver que sucede con las imágenes que estén en esos repos y enlazados por los markdown. Guardar en local los recientes para evitar consumir peticiones, y mostrar el uso de consumo de peticiones.
