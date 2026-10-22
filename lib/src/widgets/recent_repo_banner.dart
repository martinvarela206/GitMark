import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecentRepoBanner extends StatelessWidget {
  final String repoName;
  final VoidCallback? onOpen;

  const RecentRepoBanner({
    super.key,
    this.repoName = 'LeCoupa/awesome-cheatsheets',
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.fondoTarjeta,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: AppTheme.acentoCyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppTheme.acentoCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÚLTIMO REPOSITORIO VISITADO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.acentoCyan),
                ),
                Text(
                  repoName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textoPrincipal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onOpen ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.acentoCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Abrir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}