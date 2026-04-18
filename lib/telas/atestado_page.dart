import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> gerarAtestadoModelo({
  required String nome,
  required String rg,
  required String endereco,
  required String data,
  required String horaInicio,
  required String horaFim,
  required String cidade,
  required String cid,
  required String convalescenca,
  required String medico,
}) async {
  final pdf = pw.Document();

  // 📌 LOGO
  final logoBytes = (await rootBundle.load(
    'assets/logo.png',
  )).buffer.asUint8List();

  // 📌 FONTE
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  final estilo = pw.TextStyle(font: ttf, fontSize: 14);
  final titulo = pw.TextStyle(
    font: ttf,
    fontSize: 22,
    fontWeight: pw.FontWeight.bold,
  );

  final subTitulo = pw.TextStyle(
    font: ttf,
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );

  // 📌 DATA ATUAL
  final agora = DateTime.now();
  final dataFormatada =
      "${agora.day.toString().padLeft(2, '0')}/"
      "${agora.month.toString().padLeft(2, '0')}/"
      "${agora.year}";

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🔥 LOGO
              pw.Center(child: pw.Image(pw.MemoryImage(logoBytes), width: 100)),

              pw.SizedBox(height: 10),

              // 🔥 TÍTULO
              pw.Center(child: pw.Text("ATESTADO MÉDICO", style: titulo)),

              pw.Divider(),
              pw.SizedBox(height: 15),

              // 🔥 TEXTO INICIAL
              pw.Text("Atesto para fins que:", style: subTitulo),
              pw.SizedBox(height: 12),

              pw.Text("Nome: $nome", style: estilo),
              pw.SizedBox(height: 6),

              pw.Text("RG: $rg", style: estilo),
              pw.SizedBox(height: 6),

              pw.Text("Endereço: $endereco", style: estilo),
              pw.SizedBox(height: 10),

              pw.Text(
                "O paciente esteve sob atendimento odontológico neste período.",
                style: estilo,
              ),

              pw.SizedBox(height: 10),

              pw.Text("CID: $cid", style: estilo),
              pw.Text("Convalescença: $convalescenca", style: estilo),

              pw.SizedBox(height: 10),

              pw.Text("Data: $dataFormatada", style: estilo),

              pw.SizedBox(height: 25),

              // 🔥 MÉDICO
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Médico: $medico", style: estilo),
              ),

              pw.SizedBox(height: 40),

              // 🔥 ASSINATURAS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 150, child: pw.Divider()),
                      pw.SizedBox(height: 5),
                      pw.Text("Assinatura do Paciente"),
                    ],
                  ),

                  pw.Column(
                    children: [
                      pw.Container(width: 150, child: pw.Divider()),
                      pw.SizedBox(height: 5),
                      pw.Text("Carimbo Médico"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // 🔥 DATA FINAL
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("$cidade, $dataFormatada", style: estilo),
              ),

              pw.SizedBox(height: 10),

              // 🔥 RODAPÉ CLÍNICA
              pw.Center(
                child: pw.Text(
                  "Clínica Odontológica - Adélia Pacheco | Rua Senador Felinto Müller, 159 - Cuiabá/MT",
                  style: pw.TextStyle(fontSize: 11),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
