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

            // Chapter Overview Section
            pw.Header(
              level: 1,
              child: pw.Text(
                'Chapter Overview',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                summaryData.chapterOverview.summary,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
              ),
            ),
            pw.SizedBox(height: 24),

            // Key Takeaways Section
            if (summaryData.keyTakeaways.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Key Takeaways',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.keyTakeaways.asMap().entries.map(
                (entry) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 20,
                        height: 20,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.blue200,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '${entry.key + 1}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          entry.value,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Key Points Section
            if (summaryData.keyPoints.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Key Points',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.keyPoints.map(
                (keyPoint) => pw.Container(
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
                              keyPoint.title,
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
                              color: _getTypeColor(keyPoint.type),
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              keyPoint.type.toUpperCase(),
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
                        keyPoint.content,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Definitions Section
            if (summaryData.definitions.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Definitions',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.definitions.map(
                (definition) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        definition.term,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        definition.definition,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Flashcards Section
            if (summaryData.flashcards.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Flashcards',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ...summaryData.flashcards.asMap().entries.map(
                (entry) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Q${entry.key + 1}: ${entry.value.question}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'A: ${entry.value.answer}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
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

  static PdfColor _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'important':
        return PdfColors.orange;
      case 'concept':
        return PdfColors.blue;
      case 'example':
        return PdfColors.green;
      default:
        return PdfColors.grey;
    }
  }
}
