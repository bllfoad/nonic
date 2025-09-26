import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SupportItem(icon: Icons.call, title: 'Helpline'),
          SizedBox(height: 12),
          _SupportItem(icon: Icons.article, title: 'Articles'),
          SizedBox(height: 12),
          _SupportItem(icon: Icons.groups, title: 'Community'),
        ],
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SupportItem({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Theme.of(context).cardColor, child: Icon(icon)),
      title: Text(title),
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.outline)),
    );
  }
}


