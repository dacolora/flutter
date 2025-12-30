import 'package:flutter/material.dart';
import 'package:mylifegame/domain/entities/habit_shedule.dart';
import 'package:mylifegame/ui/ui_token.dart';


/// Pantalla Frequency (como tu referencia)
/// Devuelve un HabitSchedule al hacer "pop(schedule)".
class HabitFrequencyScreen extends StatefulWidget {
  const HabitFrequencyScreen({super.key, required this.initial});

  final HabitSchedule initial;

  @override
  State<HabitFrequencyScreen> createState() => _HabitFrequencyScreenState();
}

class _HabitFrequencyScreenState extends State<HabitFrequencyScreen> {
  late HabitFrequency _freq;
  late List<int> _days; // ISO 1..7
  int _targetCount = 3; // para per week/per month

  @override
  void initState() {
    super.initState();
    _freq = widget.initial.frequency;
    _days = List.of(widget.initial.daysOfWeek);
    _targetCount = widget.initial.targetCount ?? 3;

    if (_freq == HabitFrequency.specificDays && _days.isEmpty) {
      _days = [1, 3, 5]; // por defecto Mo/We/Fr
    }
  }

  void _save() {
    final schedule = HabitSchedule(
      frequency: _freq,
      daysOfWeek: _freq == HabitFrequency.specificDays ? _days : const [],
      targetCount: (_freq == HabitFrequency.timesPerWeek || _freq == HabitFrequency.timesPerMonth)
          ? _targetCount
          : null,
    );
    Navigator.pop(context, schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frecuencia'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: UiTokens.neonGreen, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: ListView(
        children: [
          _tile(
            title: 'Daily',
            subtitle: 'Todos los días',
            selected: _freq == HabitFrequency.daily,
            onTap: () => setState(() => _freq = HabitFrequency.daily),
          ),
          const Divider(height: 1),

          _tile(
            title: 'Specific Days',
            subtitle: 'Elegir días específicos',
            selected: _freq == HabitFrequency.specificDays,
            onTap: () => setState(() => _freq = HabitFrequency.specificDays),
          ),
          if (_freq == HabitFrequency.specificDays) _specificDaysPicker(),

          const Divider(height: 1),
          _tile(
            title: '# Per Week',
            subtitle: 'Meta semanal (ej: 3 veces/semana)',
            selected: _freq == HabitFrequency.timesPerWeek,
            onTap: () => setState(() => _freq = HabitFrequency.timesPerWeek),
          ),
          if (_freq == HabitFrequency.timesPerWeek) _targetPicker(label: 'Veces por semana'),

          const Divider(height: 1),
          _tile(
            title: '# Per Month',
            subtitle: 'Meta mensual (ej: 12 veces/mes)',
            selected: _freq == HabitFrequency.timesPerMonth,
            onTap: () => setState(() => _freq = HabitFrequency.timesPerMonth),
          ),
          if (_freq == HabitFrequency.timesPerMonth) _targetPicker(label: 'Veces por mes'),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle, style: const TextStyle(color: UiTokens.textSoft)),
      trailing: selected ? const Icon(Icons.check, color: UiTokens.neonGreen) : null,
    );
  }

  Widget _specificDaysPicker() {
    const labels = <int, String>{1: 'Mo', 2: 'Tu', 3: 'We', 4: 'Th', 5: 'Fr', 6: 'Sa', 7: 'Su'};

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(7, (i) {
          final iso = i + 1;
          final selected = _days.contains(iso);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _days.remove(iso);
                  if (_days.isEmpty) _days.add(iso); // evita lista vacía
                } else {
                  _days.add(iso);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? UiTokens.neonBlue.withOpacity(0.16) : UiTokens.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? UiTokens.neonBlue : UiTokens.borderSoft),
              ),
              child: Text(
                labels[iso]!,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: selected ? UiTokens.neonBlue : UiTokens.textSoft,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _targetPicker({required String label}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        decoration: UiTokens.neonCard(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: UiTokens.textSoft, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _targetCount = (_targetCount - 1).clamp(1, 31)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                const SizedBox(width: 10),
                Text('$_targetCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => setState(() => _targetCount = (_targetCount + 1).clamp(1, 31)),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tip: “Per Week/Month” se mide por conteo. El calendario sigue mostrando estados por día.',
              style: TextStyle(color: UiTokens.textSoft, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}