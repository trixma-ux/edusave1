import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/project.dart';
import '../providers/app_providers.dart';

final reportExportServiceProvider = Provider<ReportExportService>((ref) => ReportExportService());

class ReportExportService {
  Future<File> exportProjectPdf(Project project, WidgetRef ref) async {
    final pdf = pw.Document();
    final beneficiaries = await ref.read(beneficiaryRepositoryProvider).forProject(project.id!);
    final partners = await ref.read(partnerRepositoryProvider).forProject(project.id!);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Rapport Projet', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Titre: ${project.title}'),
            pw.Text('Programme: ${project.program}'),
            pw.Text('Statut: ${project.status}'),
            if (project.description != null) pw.Text('Description: ${project.description}'),
            pw.SizedBox(height: 12),
            pw.Text('Bénéficiaires (${beneficiaries.length})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: beneficiaries.map((b) => b.fullName).join(', ')),
            pw.SizedBox(height: 8),
            pw.Text('Partenaires (${partners.length})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: partners.map((p) => p.name).join(', ')),
          ],
        ),
      ),
    );

    final file = await _createOutputFile('${_safe(project.title)}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> exportProjectExcel(Project project, WidgetRef ref) async {
    final excel = xls.Excel.createExcel();
    final sheet = excel['Projet'];
    sheet.appendRow(['Titre', project.title]);
    sheet.appendRow(['Programme', project.program]);
    sheet.appendRow(['Statut', project.status]);

    final beneficiaries = await ref.read(beneficiaryRepositoryProvider).forProject(project.id!);
    final partners = await ref.read(partnerRepositoryProvider).forProject(project.id!);

    final sh2 = excel['Bénéficiaires'];
    sh2.appendRow(['Nom', 'Segment', 'Genre']);
    for (final b in beneficiaries) {
      sh2.appendRow([b.fullName, b.segment ?? '', b.gender ?? '']);
    }

    final sh3 = excel['Partenaires'];
    sh3.appendRow(['Nom', 'Type']);
    for (final ptn in partners) {
      sh3.appendRow([ptn.name, ptn.type ?? '']);
    }

    final file = await _createOutputFile('${_safe(project.title)}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> _createOutputFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final out = File(p.join(dir.path, filename));
    return out.create(recursive: true);
  }

  String _safe(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}
