import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  String _priority = "Moyenne";

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Créer un projet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Titre du projet")),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description")),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date de début: ${_startDate.toLocal()}"),
                Text("Date de fin: ${_endDate.toLocal()}"),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _priority,
              onChanged: (value) => setState(() => _priority = value!),
              items: ["Basse", "Moyenne", "Haute", "Urgente"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                projectProvider.addProject(ProjectModel(
                  id: "",
                  title: _titleController.text,
                  description: _descriptionController.text,
                  priority: _priority,
                  status: "En attente",
                  startDate: _startDate,
                  endDate: _endDate,
                ));
                Navigator.pop(context);
              },
              child: Text("Créer le projet"),
            ),
          ],
        ),
      ),
    );
  }
}
