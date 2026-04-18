import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OdontogramaPage extends StatefulWidget {
  final String clienteId;

  const OdontogramaPage({super.key, required this.clienteId});

  @override
  State<OdontogramaPage> createState() => _OdontogramaPageState();
}

class _OdontogramaPageState extends State<OdontogramaPage> {
  Map<int, String> dentes = {};
  late TextEditingController observacaoController;

  @override
  void initState() {
    super.initState();
    observacaoController = TextEditingController();
    carregarOdontograma();
  }

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> carregarOdontograma() async {
    final doc = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('odontograma')
        .doc('atual')
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        if (data['dentes'] != null) {
          dentes = Map<int, String>.from(
            (data['dentes'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(int.parse(k), v),
            ),
          );
        }

        observacaoController.text = data['observacao'] ?? "";
      });
    }
  }

  Future<void> salvarTudo() async {
    await FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('odontograma')
        .doc('atual')
        .set({
          'dentes': dentes.map((k, v) => MapEntry(k.toString(), v)),
          'observacao': observacaoController.text,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Salvo com sucesso")));
  }

  Color corDente(String status) {
    switch (status) {
      case 'cariado':
        return Colors.red;
      case 'restaurado':
        return Colors.blue;
      case 'extraido':
        return Colors.black;
      default:
        return Colors.grey.shade300;
    }
  }

  void alterarDente(int numero) async {
    String? escolha = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Dente $numero"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Saudável"),
              onTap: () => Navigator.pop(context, 'normal'),
            ),
            ListTile(
              title: const Text("Cariado"),
              onTap: () => Navigator.pop(context, 'cariado'),
            ),
            ListTile(
              title: const Text("Restaurado"),
              onTap: () => Navigator.pop(context, 'restaurado'),
            ),
            ListTile(
              title: const Text("Extraído"),
              onTap: () => Navigator.pop(context, 'extraido'),
            ),
          ],
        ),
      ),
    );

    if (escolha != null) {
      setState(() {
        dentes[numero] = escolha;
      });
    }
  }

  Widget dente(int numero) {
    return GestureDetector(
      onTap: () => alterarDente(numero),
      child: Column(
        children: [
          Icon(
            Icons.masks,
            size: 32,
            color: corDente(dentes[numero] ?? 'normal'),
          ),
          Text(numero.toString(), style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget legendaItem(String texto, Color cor) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8, bottom: 6),
          color: cor,
        ),
        Text(texto),
      ],
    );
  }

  List<int> superiores = [
    18,
    17,
    16,
    15,
    14,
    13,
    12,
    11,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
  ];

  List<int> inferiores = [
    48,
    47,
    46,
    45,
    44,
    43,
    42,
    41,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Odontograma")),

      body: Row(
        children: [
          // 🦷 ODONTOGRAMA
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: superiores.map(dente).toList(),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: inferiores.map(dente).toList(),
                ),
              ],
            ),
          ),

          // 📋 LATERAL
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Legenda",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  legendaItem("Saudável", Colors.grey.shade300),
                  legendaItem("Cariado", Colors.red),
                  legendaItem("Restaurado", Colors.blue),
                  legendaItem("Extraído", Colors.black),

                  const SizedBox(height: 20),

                  const Text(
                    "Observações",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: observacaoController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ex: aparelho, limpeza, gengiva...",
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: salvarTudo,
                    child: const Text("Salvar"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
