import 'package:flutter/material.dart';
import '../../domain/entities/life_area.dart';

class LifeAreaSettingsScreen extends StatefulWidget {
  @override
  _LifeAreaSettingsScreenState createState() => _LifeAreaSettingsScreenState();
}

class _LifeAreaSettingsScreenState extends State<LifeAreaSettingsScreen> {
  final LifeAreaRepository _repository = LifeAreaRepository();
  List<LifeArea> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final areas = await _repository.getLifeAreas();
    setState(() {
      _areas = areas;
    });
  }

Future<void> _addArea() async {
  final controller = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Agregar área'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Nombre del área'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                // Mostrar un mensaje de error si el campo está vacío
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El nombre del área no puede estar vacío')),
                );
                return;
              }

              final newArea = LifeArea(id: DateTime.now().toString(), label: text);
              setState(() {
                _areas.add(newArea);
              });
              _repository.saveLifeAreas(_areas);
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      );
    },
  );
}

  Future<void> _deleteArea(LifeArea area) async {
    setState(() {
      _areas.remove(area);
    });
    await _repository.saveLifeAreas(_areas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Áreas de la Vida')),
      body: ListView.builder(
        itemCount: _areas.length,
        itemBuilder: (context, index) {
          final area = _areas[index];
          return ListTile(
            title: Text(area.label),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteArea(area),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addArea,
        child: Icon(Icons.add),
      ),
    );
  }
}