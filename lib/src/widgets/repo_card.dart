import 'package:flutter/material.dart';
import '../models/repository_model.dart';
import '../services/github_service.dart';
import '../theme/app_theme.dart';
import 'repo_avatar.dart';
import 'repo_description.dart';
import 'repo_info.dart';

/// Tarjeta visual que presenta un repositorio en las listas de la aplicación.
/// 
/// Puntos de diseño y arquitectura:
/// 1. Encapsulación por modelo: En lugar de recibir 8 parámetros sueltos (nombre, estrellas, avatar, etc.),
///    recibe directamente la instancia inmutable RepositoryModel, manteniendo el código limpio y seguro.
/// 2. Efecto táctil (InkWell): Envuelve el contenido en un InkWell para proporcionar la animación de
///    onda táctil (ripple effect) típica de Material Design respetando las esquinas redondeadas.
/// 3. Composición modular: Compuesta en una fila (Row) con sub-widgets especializados:
///    - RepoAvatar: Muestra el avatar o icono por defecto.
///    - Expanded + Column: Ocupa todo el espacio horizontal restante con título, descripción y métricas.
///    - Icon: Flecha indicadora (chevron_right) que sugiere navegación al usuario.
///    - Botón de sincronización reactiva: Icono de nube que indica si el repositorio ya fue
///      persistido en SQLite (cloud_done en cyan) o si está pendiente (cloud_download_outlined).
///      Al presionarlo, sincroniza la estructura y el README remoto sin recargar la pantalla.
/// 
/// ¿Por qué evoluciona a un StatefulWidget?
/// Para gestionar de forma reactiva e independiente el estado visual de carga (_isSyncing)
/// al pulsar el icono de la nube sin requerir reconstruir toda la lista ni la pantalla padre.
class RepoCard extends StatefulWidget {
  final RepositoryModel repository;
  final VoidCallback? onTap;
  final VoidCallback? onSyncCompleted;

  const RepoCard({
    super.key,
    required this.repository,
    this.onTap,
    this.onSyncCompleted,
  });

  @override
  State<RepoCard> createState() => _RepoCardState();
}

class _RepoCardState extends State<RepoCard> {
  bool _isSyncing = false;

  Future<void> _ejecutarSincronizacion() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      final huboCambios = await GitHubService.instance.sincronizarRepositorio(widget.repository);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            huboCambios
                ? '¡Sincronizado! Repositorio guardado para uso offline.'
                : 'El repositorio ya está al día. No hubo cambios remotos.',
          ),
          backgroundColor: huboCambios ? AppTheme.fondoTarjeta : Colors.grey[850],
          duration: const Duration(seconds: 3),
        ),
      );

      widget.onSyncCompleted?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;

    return Card(
      elevation: 0,
      color: AppTheme.fondoTarjeta,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: repo.isSynced
              ? AppTheme.acentoCyan.withValues(alpha: 0.3)
              : AppTheme.bordeSutil,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepoAvatar(avatarUrl: repo.avatarUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RepoDescription(
                      fullName: repo.fullName,
                      description: repo.description,
                    ),
                    const SizedBox(height: 10),
                    RepoInfo(
                      starsCount: repo.starsCount,
                      language: repo.language,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón de sincronización con estado reactivo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: repo.isSynced
                        ? 'Sincronizado offline (Tocar para verificar cambios)'
                        : 'Sincronizar para uso offline',
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.acentoCyan,
                            ),
                          )
                        : Icon(
                            repo.isSynced
                                ? Icons.cloud_done
                                : Icons.cloud_download_outlined,
                            color: repo.isSynced
                                ? AppTheme.acentoCyan
                                : AppTheme.iconoMuted,
                          ),
                    onPressed: _ejecutarSincronizacion,
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.iconoMuted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
