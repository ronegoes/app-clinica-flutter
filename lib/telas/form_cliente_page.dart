import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'historico_service.dart';

class FormClientePage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? dados;

  const FormClientePage({super.key, this.id, this.dados});

  @override
  State<FormClientePage> createState() => _FormClientePageState();
}

class _FormClientePageState extends State<FormClientePage> {
  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final rgController = TextEditingController();
  final enderecoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.dados != null) {
      nomeController.text = widget.dados!['nome'] ?? '';
      telefoneController.text = widget.dados!['telefone'] ?? '';
      rgController.text = widget.dados!['rg'] ?? '';
      enderecoController.text = widget.dados!['endereco'] ?? '';
    }
  }

  Future<void> salvarCliente() async {
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite o nome")));
      return;
    }

    final data = {
      'nome': nomeController.text,
      'telefone': telefoneController.text,
      'rg': rgController.text,
      'endereco': enderecoController.text,
    };

    // 🔥 NOVO CLIENTE
    if (widget.id == null) {
      final docRef = await FirebaseFirestore.instance
          .collection('clientes')
          .add(data);

      // 🔥 HISTÓRICO CADASTRO
      await salvarHistorico(
        tipo: 'Cliente',
        descricao: 'Cliente cadastrado: ${nomeController.text}',
        clienteId: docRef.id,
      );
    } else {
      // 🔥 ATUALIZA CLIENTE
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.id)
          .update(data);

      // 🔥 HISTÓRICO EDIÇÃO
      await salvarHistorico(
        tipo: 'Cliente',
        descricao: 'Cliente atualizado: ${nomeController.text}',
        clienteId: widget.id,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Cliente")),

      body: SingleChildScrollView(
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
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telefone",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: rgController,
              decoration: const InputDecoration(
                labelText: "RG",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(
                labelText: "Endereço",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvarCliente,
                child: const Text("Salvar Cliente"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
