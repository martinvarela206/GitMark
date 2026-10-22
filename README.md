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