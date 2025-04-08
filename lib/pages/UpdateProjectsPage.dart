import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProjectsPage extends StatelessWidget {
  const UpdateProjectsPage({Key? key}) : super(key: key);

  void updateExistingProjects() async {
    final firestore = FirebaseFirestore.instance;

    // Récupérer tous les projets
    final projectsSnapshot = await firestore.collection('projects').get();

    for (var doc in projectsSnapshot.docs) {
      // Vérifiez si le champ 'progress' existe
      if (!doc.data().containsKey('progress')) {
        // Ajoutez le champ 'progress' avec une valeur par défaut
        await firestore.collection('projects').doc(doc.id).update({
          'progress': 0.0, // Valeur par défaut
        });
        print("Mise à jour du projet ${doc.id} avec le champ 'progress'.");
      }
    }

    print("Mise à jour terminée pour tous les projets existants.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mise à jour des projets"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: updateExistingProjects,
          child: const Text("Mettre à jour les projets"),
        ),
      ),
    );
  }
}
