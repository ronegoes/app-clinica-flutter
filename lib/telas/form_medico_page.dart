import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormMedicoPage extends StatelessWidget {
  final nomeController = TextEditingController();
  final especialidadeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Médico")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nomeController, decoration: InputDecoration(labelText: "Nome")),
            TextField(controller: especialidadeController, decoration: InputDecoration(labelText: "Especialidade")),
            TextField(controller: telefoneController, decoration: InputDecoration(labelText: "Telefone")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('medicos').add({
                  'nome': nomeController.text,
                  'especialidade': especialidadeController.text,
                  'telefone': telefoneController.text,
                  'email': emailController.text,
                });

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}