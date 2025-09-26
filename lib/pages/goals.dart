import 'package:flutter/material.dart';
import '../models.dart';
import '../storage.dart';

class GoalsScreen extends StatefulWidget {
  final StorageService storage;
  const GoalsScreen({super.key, required this.storage});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<SavingsGoal> goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.storage.getGoals();
    setState(() => goals = data);
  }

  Future<void> _addGoalDialog() async {
    final nameCtrl = TextEditingController();
    double amount = 50;
    DateTime target = DateTime.now().add(const Duration(days: 30));
    final result = await showDialog<SavingsGoal>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Goal'),
          content: StatefulBuilder(builder: (context, setSt) {
            return SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('Amount'), Text(amount.toStringAsFixed(0))],
                  ),
                  Slider(value: amount, min: 10, max: 1000, divisions: 99, onChanged: (v) => setSt(() => amount = v)),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Target date'),
                    subtitle: Text(target.toString().split(' ').first),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: target, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                      if (picked != null) setSt(() => target = picked);
                    },
                  ),
                ],
              ),
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  SavingsGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    targetAmount: amount,
                    targetDate: target,
                    createdAt: DateTime.now(),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      await widget.storage.addGoal(result);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      floatingActionButton: FloatingActionButton(onPressed: _addGoalDialog, child: const Icon(Icons.add)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: goals.length,
        itemBuilder: (context, i) {
          final g = goals[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(g.name), Text('Target: ${g.targetAmount.toStringAsFixed(0)} by ${g.targetDate.toString().split(' ').first}', style: const TextStyle(color: Color(0xFF9CB3A8)))])),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await widget.storage.removeGoal(g.id);
                    await _load();
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}


