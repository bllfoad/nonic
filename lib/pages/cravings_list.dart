import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../storage.dart';
import 'log_craving.dart';

class CravingsListScreen extends StatefulWidget {
  final StorageService storage;
  const CravingsListScreen({super.key, required this.storage});
  @override
  State<CravingsListScreen> createState() => _CravingsListScreenState();
}

class _CravingsListScreenState extends State<CravingsListScreen> {
  List<CravingEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.storage.getCravings();
    setState(() => entries = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cravings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => LogCravingScreen(storage: widget.storage),
          ));
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          return Dismissible(
            key: ValueKey(e.id),
            background: Container(color: Colors.redAccent),
            onDismissed: (_) async {
              await widget.storage.removeCraving(e.id);
              await _load();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat.yMMMd().add_jm().format(e.createdAt),
                          style: const TextStyle(color: Color(0xFF9CB3A8))),
                      Row(children: [const Icon(Icons.whatshot, color: Colors.orange), Text(' ${e.intensity}')]),
                    ],
                  ),
                  if (e.triggers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Triggers', style: Theme.of(context).textTheme.titleMedium),
                    Text(e.triggers),
                  ],
                  if (e.strategies.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Strategies', style: Theme.of(context).textTheme.titleMedium),
                    Text(e.strategies),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


