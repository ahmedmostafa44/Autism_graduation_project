import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:autism_app/features/progress/presentation/bloc/progress_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ReportService — generates a professional weekly PDF report
//  NOTE: PDF package does not support emoji — all emojis replaced with text/icons
// ─────────────────────────────────────────────────────────────────────────────

class ReportService {
  ReportService._();
  static final instance = ReportService._();

  Future<void> shareReport({
    required ProgressLoaded data,
    required String childName,
  }) async {
    final pdf = await _buildPdf(data: data, childName: childName);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'BuddyApp_Report_${childName}_${_dateLabel()}.pdf',
    );
  }

  Future<void> printReport({
    required ProgressLoaded data,
    required String childName,
  }) async {
    final pdf = await _buildPdf(data: data, childName: childName);
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  Future<pw.Document> _buildPdf({
    required ProgressLoaded data,
    required String childName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Load a font that supports Arabic/Latin (Helvetica fallback for PDF)
    // We avoid emojis entirely — replace with bracketed text labels
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontExtraBold = await PdfGoogleFonts.nunitoExtraBold();

    const purple = PdfColor.fromInt(0xFF7C3AED);
    const blue = PdfColor.fromInt(0xFF3B82F6);
    const green = PdfColor.fromInt(0xFF10B981);
    const gold = PdfColor.fromInt(0xFFF59E0B);
    const red = PdfColor.fromInt(0xFFEF4444);
    const bgGray = PdfColor.fromInt(0xFFF8F7FF);
    const darkBg = PdfColor.fromInt(0xFF1E1B4B);
    const white = PdfColors.white;
    const dark = PdfColor.fromInt(0xFF1F2937);
    const grey = PdfColor.fromInt(0xFF6B7280);

    final avgAccuracy = data.gameStats.isEmpty
        ? 0.0
        : data.gameStats.values
                .map((g) => g.avgAccuracy)
                .reduce((a, b) => a + b) /
            data.gameStats.length;

    final performanceLabel = avgAccuracy >= 0.8
        ? 'EXCELLENT'
        : avgAccuracy >= 0.6
            ? 'GOOD'
            : avgAccuracy >= 0.4
                ? 'DEVELOPING'
                : 'NEEDS SUPPORT';

    final performanceColor = avgAccuracy >= 0.8
        ? green
        : avgAccuracy >= 0.6
            ? blue
            : avgAccuracy >= 0.4
                ? gold
                : red;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // ── Header ──────────────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [darkBg, purple],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BuddyApp',
                            style: pw.TextStyle(
                                font: fontExtraBold,
                                fontSize: 26,
                                color: white)),
                        pw.Text('Weekly Progress Report',
                            style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                                color: PdfColor.fromInt(0xFFBBB8FF))),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(performanceColor.red,
                            performanceColor.green, performanceColor.blue, 0.2),
                        borderRadius: pw.BorderRadius.circular(20),
                        border:
                            pw.Border.all(color: performanceColor, width: 1.5),
                      ),
                      child: pw.Text(performanceLabel,
                          style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: performanceColor)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                pw.Row(children: [
                  _chip('Child: $childName', white, font),
                  pw.SizedBox(width: 10),
                  _chip('Week: ${_weekLabel(now)}', white, font),
                  pw.SizedBox(width: 10),
                  _chip('Streak: ${data.streakDays} days', white, font),
                ]),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          pw.Padding(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Summary stat row
                pw.Row(children: [
                  _statCard('Sessions', '${data.sessions}', purple, font,
                      fontBold, fontExtraBold),
                  pw.SizedBox(width: 10),
                  _statCard('Accuracy', '${(avgAccuracy * 100).round()}%',
                      green, font, fontBold, fontExtraBold),
                  pw.SizedBox(width: 10),
                  _statCard('Points', '${data.totalScore}', gold, font,
                      fontBold, fontExtraBold),
                  pw.SizedBox(width: 10),
                  _statCard('Awards', '${data.awards}', blue, font, fontBold,
                      fontExtraBold),
                ]),

                pw.SizedBox(height: 24),

                // Weekly chart
                _sectionTitle('Weekly Activity', dark, fontBold),
                pw.SizedBox(height: 10),
                _weeklyChart(data.weeklyData, purple, bgGray, font, fontBold),

                pw.SizedBox(height: 24),

                // Game performance
                _sectionTitle('Game Performance', dark, fontBold),
                pw.SizedBox(height: 10),
                if (data.gameStats.isEmpty)
                  pw.Text('No game data yet.',
                      style:
                          pw.TextStyle(font: font, color: grey, fontSize: 12))
                else
                  ...data.gameStats.values.map((g) => _gameRow(g, purple, green,
                      gold, red, bgGray, dark, grey, font, fontBold)),

                pw.SizedBox(height: 24),

                // Recent sessions table
                _sectionTitle('Recent Sessions (Last 7)', dark, fontBold),
                pw.SizedBox(height: 10),
                _logsTable(data.dailyLogs.take(7).toList(), dark, grey, bgGray,
                    green, gold, red, font, fontBold),

                pw.SizedBox(height: 24),

                // Therapist notes box
                _sectionTitle('Therapist Notes', dark, fontBold),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 80,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: bgGray,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                        color: PdfColor.fromInt(0xFFE5E7EB), width: 1),
                  ),
                  child: pw.Text('Write notes here...',
                      style: pw.TextStyle(
                          font: font,
                          color: PdfColor.fromInt(0xFFD1D5DB),
                          fontSize: 12)),
                ),

                pw.SizedBox(height: 24),

                // Footer
                pw.Divider(color: PdfColor.fromInt(0xFFE5E7EB)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated by BuddyApp  |  ${_fullDate(now)}',
                        style:
                            pw.TextStyle(font: font, color: grey, fontSize: 9)),
                    pw.Text('Confidential - For parent/therapist use only',
                        style:
                            pw.TextStyle(font: font, color: grey, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  pw.Widget _chip(String text, PdfColor color, pw.Font font) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: pw.BoxDecoration(
          color: PdfColor(1, 1, 1, 0.12),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: 10, color: color)),
      );

  pw.Widget _statCard(String label, String value, PdfColor color, pw.Font font,
          pw.Font fontBold, pw.Font fontExtraBold) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColor(color.red, color.green, color.blue, 0.08),
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(
                color: PdfColor(color.red, color.green, color.blue, 0.3),
                width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(value,
                  style: pw.TextStyle(
                      font: fontExtraBold, fontSize: 20, color: color)),
              pw.SizedBox(height: 2),
              pw.Text(label,
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColor.fromInt(0xFF6B7280))),
            ],
          ),
        ),
      );

  pw.Widget _sectionTitle(String title, PdfColor color, pw.Font fontBold) =>
      pw.Text(title,
          style: pw.TextStyle(font: fontBold, fontSize: 14, color: color));

  pw.Widget _weeklyChart(List<WeeklyData> weekly, PdfColor barColor,
      PdfColor bg, pw.Font font, pw.Font fontBold) {
    if (weekly.isEmpty) return pw.SizedBox();
    const chartH = 70.0;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
          color: bg, borderRadius: pw.BorderRadius.circular(10)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: weekly.map((d) {
          final barH = (d.value * chartH).clamp(4.0, chartH);
          final pct = '${(d.value * 100).round()}%';
          final active = d.value >= 0.7;
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(pct,
                  style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 8,
                      color: active ? barColor : PdfColor.fromInt(0xFF9CA3AF))),
              pw.SizedBox(height: 3),
              pw.Container(
                width: 26,
                height: barH,
                decoration: pw.BoxDecoration(
                  color: active
                      ? barColor
                      : PdfColor(
                          barColor.red, barColor.green, barColor.blue, 0.35),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(d.day,
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromInt(0xFF6B7280))),
            ],
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _gameRow(
    GameStatSummary g,
    PdfColor purple,
    PdfColor green,
    PdfColor gold,
    PdfColor red,
    PdfColor bg,
    PdfColor dark,
    PdfColor grey,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final color = g.avgAccuracy >= 0.8
        ? green
        : g.avgAccuracy >= 0.5
            ? gold
            : red;
    final pct = '${(g.avgAccuracy * 100).round()}%';
    // Replace game emoji with short text label
    final gameLabel = '[${g.gameName}]';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
            color: bg, borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.Expanded(
                child: pw.Text(gameLabel,
                    style: pw.TextStyle(font: fontBold, fontSize: 11, color: dark)),
              ),
              pw.Text('${g.plays} plays  |  Best: ${g.bestScore}',
                  style: pw.TextStyle(font: font, fontSize: 10, color: grey)),
              pw.SizedBox(width: 12),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColor(color.red, color.green, color.blue, 0.15),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(pct,
                    style:
                        pw.TextStyle(font: fontBold, fontSize: 11, color: color)),
              ),
            ]),
            pw.SizedBox(height: 6),
            pw.Text(
              'Benefit: ${_getGameBenefit(g.gameId)}',
              style: pw.TextStyle(font: font, fontSize: 9, color: grey),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _logsTable(
    List<DailyLog> logs,
    PdfColor dark,
    PdfColor grey,
    PdfColor bg,
    PdfColor green,
    PdfColor gold,
    PdfColor red,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (logs.isEmpty) {
      return pw.Text('No sessions recorded yet.',
          style: pw.TextStyle(font: font, color: grey, fontSize: 12));
    }

    return pw.Table(
      border:
          pw.TableBorder.all(color: PdfColor.fromInt(0xFFE5E7EB), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: bg),
          children: ['Game', 'Note', 'Score', 'Date']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: fontBold, fontSize: 10, color: dark)),
                  ))
              .toList(),
        ),
        ...logs.map((log) {
          final scoreColor = log.score >= 8
              ? green
              : log.score >= 5
                  ? gold
                  : red;
          return pw.TableRow(children: [
            _tcell(
                log.gameName.isNotEmpty ? log.gameName : log.label, grey, font),
            _tcell(log.note, grey, font),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('${log.score}/10',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 10, color: scoreColor)),
            ),
            _tcell(_shortDate(log.playedAt), grey, font),
          ]);
        }),
      ],
    );
  }

  pw.Widget _tcell(String text, PdfColor color, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: 10, color: color)),
      );

  String _getGameBenefit(String gameId) {
    switch (gameId) {
      case 'emotion_match':
        return 'Enhances emotional recognition by linking facial expressions to feelings.';
      case 'word_builder':
        return 'Improves vocabulary, spelling, and language comprehension.';
      case 'color_match':
        return 'Develops visual discrimination and cognitive association skills.';
      case 'number_fun':
        return 'Strengthens foundational math and numerical reasoning capabilities.';
      case 'sequencing':
        return 'Fosters logical thinking, order recognition, and sequential planning.';
      case 'color_sorting':
        return 'Boosts categorization skills and fine motor coordination.';
      default:
        return 'Supports cognitive development and interactive learning.';
    }
  }

  // ── Date helpers ──────────────────────────────────────────────────────────
  String _dateLabel() {
    final n = DateTime.now();
    return '${n.year}-${_p(n.month)}-${_p(n.day)}';
  }

  String _weekLabel(DateTime d) {
    final start = d.subtract(Duration(days: d.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${_mon(start.month)} ${start.day} - ${_mon(end.month)} ${end.day}, ${d.year}';
  }

  String _fullDate(DateTime d) =>
      '${_mon(d.month)} ${d.day}, ${d.year}  ${_p(d.hour)}:${_p(d.minute)}';

  String _shortDate(DateTime d) => '${_mon(d.month)} ${d.day}';

  String _p(int n) => n.toString().padLeft(2, '0');

  String _mon(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}
