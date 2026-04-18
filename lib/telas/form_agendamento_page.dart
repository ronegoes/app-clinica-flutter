import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'historico_service.dart';

class FormAgendamentoPage extends StatefulWidget {
  const FormAgendamentoPage({super.key});

  @override
  State<FormAgendamentoPage> createState() => _FormAgendamentoPageState();
}

class _FormAgendamentoPageState extends State<FormAgendamentoPage> {
  String? clienteId;
  String? procedimentoId;

  final cidController = TextEditingController();
  final convalescencaController = TextEditingController();
  final medicoController = TextEditingController();
  final dataController = TextEditingController();

  bool salvando = false;

  Future<void> salvar() async {
    if (clienteId == null || procedimentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione cliente e procedimento")),
      );
      return;
    }

    if (cidController.text.isEmpty ||
        medicoController.text.isEmpty ||
        dataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios")),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final procDoc = await FirebaseFirestore.instance
          .collection('procedimentos')
          .doc(procedimentoId)
          .get();

      final proc = procDoc.data();

      if (proc == null) {
        throw Exception("Procedimento não encontrado");
      }

      await FirebaseFirestore.instance.collection('agendamentos').add({
        'clienteId': clienteId,

        // 🔥 AGORA É LISTA
        'procedimentos': [
          {
            'id': procedimentoId,
            'nome': proc['nome'] ?? '',
            'valor': proc['valor'] ?? 0,
          },
        ],

        'valorTotal': proc['valor'] ?? 0,

        'cid': cidController.text,
        'convalescenca': convalescencaController.text,
        'medico': medicoController.text,

        'dataHora': Timestamp.now(),
        'status': 'Pendente',
      });
      // 🔥 HISTÓRICO AQUI
      await salvarHistorico(
        tipo: 'Agendamento',
        descricao: 'Agendamento criado - ${proc['nome']}',
        clienteId: clienteId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento salvo com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendamento")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // CLIENTE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clientes')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: clienteId,
                  decoration: const InputDecoration(labelText: "Cliente"),
                  items: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text(data['nome'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => clienteId = v),
                );
              },
            ),

            const SizedBox(height: 10),

            // PROCEDIMENTO
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('procedimentos')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: procedimentoId,
                  decoration: const InputDecoration(labelText: "Procedimento"),
                  items: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;

                    return DropdownMenuItem(
                      value: d.id,
                      child: Text("${data['nome']} - R\$ ${data['valor']}"),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => procedimentoId = v),
                );
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: cidController,
              decoration: const InputDecoration(labelText: "CID"),
            ),

            TextField(
              controller: convalescencaController,
              decoration: const InputDecoration(labelText: "Convalescença"),
            ),

            TextField(
              controller: medicoController,
              decoration: const InputDecoration(labelText: "Médico"),
            ),

            TextField(
              controller: dataController,
              decoration: const InputDecoration(labelText: "Data"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvando ? null : salvar,
              child: salvando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
