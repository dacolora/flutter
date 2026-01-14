import 'package:flutter/material.dart';
import 'package:mylifegame/domain/entities/habit.dart';
import 'package:mylifegame/domain/entities/habit_shedule.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'package:mylifegame/ui/ui_token.dart';

class CreateHabitScreen extends StatefulWidget {
  final LifeAreaModel area;

  const CreateHabitScreen({super.key, required this.area});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _title = TextEditingController();
  HabitDifficulty _difficulty = HabitDifficulty.normal;

  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) {
      return;
    }

    setState(() => _saving = true);

    final habit = Habit.create(
      title: t,
      area: widget.area.id,
      schedule: HabitSchedule(frequency: HabitFrequency.daily),
      difficulty: _difficulty,
    );

    await AppScope.of(context).habitController.createHabit(habit);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glow = Color(widget.area.accentColor);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Crear hábito'),
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
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF0B1224),
            border: Border.all(color: glow.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: glow.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.area.iconGlyph}  Área seleccionada: ${widget.area.title}',
                style: const TextStyle(
                  fontSize: 16.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: _title,

                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  helperStyle: TextStyle(color: Colors.white),
                  prefixStyle: TextStyle(color: Colors.white),
                  hintText: 'Titulo',
                  prefixIcon: Icon(Icons.flag_rounded, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                title: const Text(
                  'Dificultad',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                trailing: DropdownButton<HabitDifficulty>(
                  value: _difficulty,
                  dropdownColor: UiTokens.card,

                  underline: const SizedBox.shrink(),
                  items: HabitDifficulty.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            difficultyLabel(d),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _difficulty = v ?? HabitDifficulty.normal),
                ),
              ),
              const SizedBox(height: 60),

              _previewRewardsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewRewardsCard() {
    // Reusamos defaults del modelo (por dificultad)
    final tmp = Habit.create(
      title: 'tmp',
      schedule: HabitSchedule(frequency: HabitFrequency.daily),
      difficulty: _difficulty,
    );
    final r = tmp.rewards;
    final p = tmp.penalties;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recursos obtenidos por cumplimiento',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('+${r.xp} XP', UiTokens.neonBlue),
              _pill('+${r.varos} Varos', UiTokens.neonGreen),
              if (r.hp > 0) _pill('+${r.hp} HP', UiTokens.neonGreen),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recursos que perderias por dia',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('-${p.xpLoss} XP', UiTokens.danger),
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
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 16,
        color: Colors.white,
      ),
    );
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