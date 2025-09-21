import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tionova/features/folder/data/models/SummaryModel.dart';

class SummaryPdfService {
  static Future<Uint8List> generateSummaryPdf({
    required SummaryModel summaryData,
    required String chapterTitle,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'AI-Generated Summary',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Chapter: $chapterTitle',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.normal,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 24),

            // Key Concepts Section
            if (summaryData.keyConcepts.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Key Concepts',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.keyConcepts.map(
                (concept) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              concept.title,
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              color: _getDifficultyColor(
                                concept.difficultyLevel,
                              ),
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              concept.difficultyLevel.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        concept.text,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                      if (concept.tags.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: concept.tags
                              .map(
                                (tag) => pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                    borderRadius: pw.BorderRadius.circular(8),
                                  ),
                                  child: pw.Text(
                                    tag,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey800,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Examples Section
            if (summaryData.examples.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Examples',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.examples.map(
                (example) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green200),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Concept: ${example.concept}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        example.example,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                      if (example.notes.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Note: ${example.notes}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Professional Implications Section
            if (summaryData.professionalImplications.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Professional Implications',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.professionalImplications.map(
                (implication) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple50,
                    border: pw.Border.all(color: PdfColors.purple200),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        implication.title,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        implication.text,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Footer
            pw.SizedBox(height: 32),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated by TioNova AI • ${DateTime.now().toString().substring(0, 19)}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static PdfColor _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return PdfColors.green;
      case 'medium':
        return PdfColors.orange;
      case 'hard':
        return PdfColors.red;
      default:
        return PdfColors.blue;
    }
  }
}
