import 'package:flutter/material.dart';
import 'sos_breathe.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SupportItem(icon: Icons.call, title: 'Helpline', onTap: () {}),
          const SizedBox(height: 12),
          _SupportItem(icon: Icons.article, title: 'Articles', onTap: () {}),
          const SizedBox(height: 12),
          _SupportItem(icon: Icons.groups, title: 'Community', onTap: () {}),
          const SizedBox(height: 12),
          _SupportItem(
            icon: Icons.self_improvement,
            title: 'SOS Breathing (4-7-8)',
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SosBreatheScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _SupportItem({required this.icon, required this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Theme.of(context).cardColor, child: Icon(icon)),
      title: Text(title),
      tileColor: Theme.of(context).colorScheme.surface,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outline)),
    );
  }
}


