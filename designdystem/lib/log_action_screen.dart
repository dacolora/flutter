import 'package:flutter/material.dart';
import '../../models/action_entry.dart';
import '../../models/area.dart';
import '../../state/game_controller.dart';

class LogActionScreen extends StatefulWidget {
  const LogActionScreen({super.key});

  @override
  State<LogActionScreen> createState() => _LogActionScreenState();
}

class _LogActionScreenState extends State<LogActionScreen> {
  ActionType _type = ActionType.goodHabit;
  LifeArea? _area = LifeArea.health;

  final _title = TextEditingController();
  final _notes = TextEditingController();

  int _hp = 0;
  int _varos = 0;
  int _xp = 0;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameControllerScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar acción')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TypePicker(
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej: Entrené Muay Thai / Caí en paja / Deep work 90 min',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LifeArea?>(
            value: (_type == ActionType.goodHabit || _type == ActionType.badHabit) ? _area : null,
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin área')),
              ...LifeArea.values.map((a) => DropdownMenuItem(value: a, child: Text(a.label))),
            ],
            onChanged: (_type == ActionType.goodHabit || _type == ActionType.badHabit)
                ? (v) => setState(() => _area = v)
                : null,
            decoration: const InputDecoration(labelText: 'Área (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _DeltaEditor(
            hp: _hp,
            varos: _varos,
            xp: _xp,
            onHp: (v) => setState(() => _hp = v),
            onVaros: (v) => setState(() => _varos = v),
            onXp: (v) => setState(() => _xp = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              final title = _title.text.trim();
              if (title.isEmpty) return;

              final entry = ActionEntry.create(
                title: title,
                type: _type,
                area: _area,
                hpDelta: _hp,
                varosDelta: _varos,
                xpDelta: _xp,
                notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              );

              await controller.addAction(entry);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Guardar'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _fillPreset(),
            child: const Text('Usar presets rápidos'),
          ),
        ],
      ),
    );
  }

  void _fillPreset() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final presets = <_Preset>[
          _Preset('Gimnasio', ActionType.goodHabit, LifeArea.health, hp: +10, varos: +40, xp: +25),
          _Preset('Muay Thai / Boxeo', ActionType.goodHabit, LifeArea.health, hp: +15, varos: +50, xp: +30),
          _Preset('Meditación 10 min', ActionType.goodHabit, LifeArea.mind, hp: +5, varos: +20, xp: +15),
          _Preset('Deep Work 90 min', ActionType.goodHabit, LifeArea.projects, hp: +5, varos: +60, xp: +35),
          _Preset('Procrastiné 2h', ActionType.badHabit, LifeArea.mind, hp: -25, varos: -30, xp: 0),
          _Preset('Paja', ActionType.badHabit, LifeArea.mind, hp: -50, varos: -80, xp: 0),
          _Preset('Dormí tarde', ActionType.badHabit, LifeArea.health, hp: -20, varos: 0, xp: 0),
        ];

        return ListView(
          children: [
            const ListTile(title: Text('Presets')),
            ...presets.map((p) => ListTile(
                  title: Text(p.title),
                  subtitle: Text('HP ${p.hp}, Varos ${p.varos}, XP ${p.xp} • ${p.area.label}'),
                  onTap: () {
                    setState(() {
                      _title.text = p.title;
                      _type = p.type;
                      _area = p.area;
                      _hp = p.hp;
                      _varos = p.varos;
                      _xp = p.xp;
                    });
                    Navigator.pop(ctx);
                  },
                )),
          ],
        );
      },
    );
  }
}

class _Preset {
  _Preset(this.title, this.type, this.area, {required this.hp, required this.varos, required this.xp});
  final String title;
  final ActionType type;
  final LifeArea area;
  final int hp;
  final int varos;
  final int xp;
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.value, required this.onChanged});

  final ActionType value;
  final ValueChanged<ActionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ActionType>(
      segments: const [
        ButtonSegment(value: ActionType.goodHabit, label: Text('Bueno'), icon: Icon(Icons.trending_up)),
        ButtonSegment(value: ActionType.badHabit, label: Text('Malo'), icon: Icon(Icons.trending_down)),
        ButtonSegment(value: ActionType.system, label: Text('Sistema'), icon: Icon(Icons.settings_suggest)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _DeltaEditor extends StatelessWidget {
  const _DeltaEditor({
    required this.hp,
    required this.varos,
    required this.xp,
    required this.onHp,
    required this.onVaros,
    required this.onXp,
  });

  final int hp;
  final int varos;
  final int xp;
  final ValueChanged<int> onHp;
  final ValueChanged<int> onVaros;
  final ValueChanged<int> onXp;

  @override
  Widget build(BuildContext context) {
    Widget field(String label, int value, ValueChanged<int> onChanged) {
      return TextFormField(
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (t) => onChanged(int.tryParse(t) ?? 0),
      );
    }

    return Row(
      children: [
        Expanded(child: field('HP Δ', hp, onHp)),
        const SizedBox(width: 10),
        Expanded(child: field('Varos Δ', varos, onVaros)),
        const SizedBox(width: 10),
        Expanded(child: field('XP Δ', xp, onXp)),
      ],
    );
  }
}