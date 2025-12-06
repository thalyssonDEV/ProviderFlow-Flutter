import 'package:flutter/material.dart';
import '../../shared/utils/app_routes.dart';
import '../../shared/utils/session_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = SessionManager().loggedProviderName ?? 'Parceiro';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () {
              SessionManager().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá,',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              nomeUsuario,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Acesso Rápido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _HomeMenuCard(
                    title: 'Novo Cliente',
                    icon: Icons.person_add_alt_1,
                    color: Colors.blueAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addClient),
                  ),
                  _HomeMenuCard(
                    title: 'Meus Clientes',
                    icon: Icons.list_alt,
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.listClients),
                  ),
                  _HomeMenuCard(
                    title: 'Mapa Geral',
                    icon: Icons.map_outlined,
                    color: Colors.pinkAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                  ),
                  _HomeMenuCard(
                    title: 'Relatórios',
                    icon: Icons.bar_chart,
                    color: Colors.tealAccent,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Em breve!')),
                      );
                    },
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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeMenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2D2D44),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}