import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormProcedimentoPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? dados;

  const FormProcedimentoPage({super.key, this.id, this.dados});

  @override
  State<FormProcedimentoPage> createState() => _FormProcedimentoPageState();
}

class _FormProcedimentoPageState extends State<FormProcedimentoPage> {
  final nomeController = TextEditingController();
  final valorController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.dados != null) {
      nomeController.text = widget.dados!['nome'] ?? '';
      valorController.text = widget.dados!['valor']?.toString() ?? '';
    }
  }

  Future<void> salvar() async {
    if (nomeController.text.isEmpty || valorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha todos os campos")));
      return;
    }

    final valor = double.tryParse(valorController.text.replaceAll(',', '.'));

    if (valor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Valor inválido")));
      return;
    }

    final data = {'nome': nomeController.text, 'valor': valor};

    if (widget.id == null) {
      await FirebaseFirestore.instance.collection('procedimentos').add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('procedimentos')
          .doc(widget.id)
          .update(data);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nomeController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Procedimento")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Valor",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvar,
                child: const Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
