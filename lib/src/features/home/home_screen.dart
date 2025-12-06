import 'package:flutter/material.dart';
import '../../shared/utils/app_routes.dart';
import '../../shared/utils/session_manager.dart';
import '../../shared/utils/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = SessionManager().loggedProviderName ?? 'Parceiro';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Controle'),
        actions: [
          IconButton(
            tooltip: 'Alternar Tema',
            icon: Icon(
              ThemeController.instance.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeController.instance.toggleTheme();
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              SessionManager().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo de volta,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nomeUsuario,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie seus clientes e redes de forma simples.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Icon(Icons.grid_view_rounded, size: 20, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Menu Rápido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _HomeMenuCard(
                    title: 'Novo Cliente',
                    subtitle: 'Cadastrar',
                    icon: Icons.person_add_alt_1,
                    color: Colors.blueAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addClient),
                  ),
                  _HomeMenuCard(
                    title: 'Meus Clientes',
                    subtitle: 'Listar todos',
                    icon: Icons.people_alt,
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.listClients),
                  ),
                  _HomeMenuCard(
                    title: 'Mapa Geral',
                    subtitle: 'Geolocalização',
                    icon: Icons.map_outlined,
                    color: Colors.pinkAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                  ),
                  _HomeMenuCard(
                    title: 'Relatórios',
                    subtitle: 'Estatísticas',
                    icon: Icons.bar_chart,
                    color: Colors.tealAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(24),
      elevation: Theme.of(context).cardTheme.elevation ?? 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}