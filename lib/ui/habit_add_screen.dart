import 'package:flutter/material.dart';
import 'package:mylifegame/domain/entities/habit_shedule.dart';
import 'package:mylifegame/ui/habit_freuency_screen.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/life_area.dart';
import '../infraestructure/service/app_scope.dart';

/// Add Habit (como tu referencia, pero estilo My Life Game)
class HabitAddScreen extends StatefulWidget {
  const HabitAddScreen({super.key});

  @override
  State<HabitAddScreen> createState() => _HabitAddScreenState();
}

class _HabitAddScreenState extends State<HabitAddScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  LifeArea? _area;
  HabitDifficulty _difficulty = HabitDifficulty.normal;
  HabitSchedule _schedule = const HabitSchedule(
    frequency: HabitFrequency.daily,
  );

  bool _saving = false;
  List<LifeArea> _lifeAreas = [];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLifeAreas();
  }

  Future<void> _loadLifeAreas() async {
    final areas =  defaultLifeAreas();
    setState(() {
      _lifeAreas = areas;
    });
  }

  Future<void> _pickFrequency() async {
    final res = await Navigator.push<HabitSchedule>(
      context,
      MaterialPageRoute(
        builder: (_) => HabitFrequencyScreen(initial: _schedule),
      ),
    );
    if (res != null) setState(() => _schedule = res);
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) {
      _snack('Ponle nombre al hábito.');
      return;
    }

    setState(() => _saving = true);

    final habit = Habit.create(
      title: t,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      area: _area,
      schedule: _schedule,
      difficulty: _difficulty,
    );

    await AppScope.of(context).habitController.createHabit(habit);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final freqLabel = _scheduleLabel(_schedule);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text('Agregar Habito', style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Saving...' : 'Save',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Quest Info'),
          const SizedBox(height: 10),

          TextField(
            style: TextStyle(color: Colors.white),
            controller: _title,
            
            decoration: const InputDecoration(
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white),
              helperStyle: TextStyle(color: Colors.white),
              prefixStyle: TextStyle(color: Colors.white),
              hintText: 'Title',
              prefixIcon: Icon(Icons.flag_rounded,color: Colors.white,),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _desc,
            decoration: const InputDecoration(
                 labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white),
              helperStyle: TextStyle(color: Colors.white),
              prefixStyle: TextStyle(color: Colors.white),
              hintText: 'Description (Optional)',
              prefixIcon: Icon(Icons.notes_rounded,color: Colors.white  ,),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 50),

          _sectionTitle('Configuracion'),
          const SizedBox(height: 10),

          Container(
            decoration: UiTokens.neonCard(),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Frecuencia',
                    style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),
                  ),
                  subtitle: Text(
                    freqLabel,
                    style: const TextStyle(color: UiTokens.textSoft,),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickFrequency,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Area',
                    style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),
                  ),
                  subtitle: Text(
                    _area?.label ?? 'Sin área (opcional)',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  trailing: DropdownButton<LifeArea?>(
                    value: _area,
                    dropdownColor: UiTokens.card,
                    underline: const SizedBox.shrink(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin área'),
                      ),
                      ..._lifeAreas.map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.label,style: TextStyle(color: Colors.white),)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _area = v),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Dificultad',
                    style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),
                  ),
                  subtitle: Text(
                    difficultyLabel(_difficulty),
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  trailing: DropdownButton<HabitDifficulty>(
                    value: _difficulty,
                    dropdownColor: UiTokens.card,
                    
                    underline: const SizedBox.shrink(),
                    items: HabitDifficulty.values
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(difficultyLabel(d),style: TextStyle(color: Colors.white),),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(
                      () => _difficulty = v ?? HabitDifficulty.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _previewRewardsCard(),

          const SizedBox(height: 28),
          const Text(
            'Regla del juego: completar da XP + Varos (+HP opcional). Fallar baja XP + HP, pero Varos nunca bajan.',
            style: TextStyle(color: UiTokens.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _previewRewardsCard() {
    // Reusamos defaults del modelo (por dificultad)
    final tmp = Habit.create(
      title: 'tmp',
      schedule: _schedule,
      difficulty: _difficulty,
    );
    final r = tmp.rewards;
    final p = tmp.penalties;

    return Container(
      decoration: UiTokens.neonCard(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview (Rewards & Penalties)',
            style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill('+${r.xp} XP', UiTokens.neonBlue),
              _pill('+${r.varos} Varos', UiTokens.neonGreen),
              if (r.hp > 0) _pill('+${r.hp} HP', UiTokens.neonGreen),
              _pill('-${p.xpLoss} XP (fallar)', UiTokens.danger),
              _pill('-${p.hpLoss} HP (fallar)', UiTokens.danger),
              _pill('Varos NO bajan', UiTokens.textSoft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: UiTokens.borderSoft),
        color: UiTokens.card,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
    );
  }



  String _scheduleLabel(HabitSchedule s) {
    switch (s.frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.specificDays:
        return 'Specific Days (${_daysShort(s.daysOfWeek)})';
      case HabitFrequency.timesPerWeek:
        return '${s.targetCount ?? 3} per week';
      case HabitFrequency.timesPerMonth:
        return '${s.targetCount ?? 12} per month';
    }
  }

  List<DateTime> getDaysInMonth(int year, int month) {
  final firstDay = DateTime(year, month, 1);
  final lastDay = DateTime(year, month + 1, 0); // Último día del mes
  return List.generate(
    lastDay.day,
    (index) => DateTime(year, month, index + 1),
  );
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _daysFull(List<DateTime> days) {
  return days.map((d) => formatDate(d)).join(', ');
}

  String _daysShort(List<int> days) {
    const map = {1: 'Mo', 2: 'Tu', 3: 'We', 4: 'Th', 5: 'Fr', 6: 'Sa', 7: 'Su'};
    final list = days.map((d) => map[d] ?? '?').toList();
    return list.join(', ');
  }

  
}



  String difficultyLabel(HabitDifficulty d) {
    switch (d) {
      case HabitDifficulty.easy:
        return 'Facil';
      case HabitDifficulty.normal:
        return 'Normal';
      case HabitDifficulty.hard:
        return 'Dificil';
      case HabitDifficulty.legendary:
        return 'Legendario';
    }
  }