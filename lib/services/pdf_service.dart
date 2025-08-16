import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/analisis_data.dart';

class PDFService {
  static String _formatCurrency(int amount) {
    final absAmount = amount.abs();
    final formatter = NumberFormat('#,###');
    return 'Rp ${formatter.format(absAmount)}';
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static Future<void> generateAnalisisReport(AnalisisData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Text('Laporan Keuangan - Instansi Sekolah', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            if (data.startDate != null && data.endDate != null)
              pw.Text('Periode Laporan: ${_formatDate(data.startDate!)} - ${_formatDate(data.endDate!)}', style: const pw.TextStyle(fontSize: 12))
            else
              pw.Text('Tanggal Cetak: ${_formatDate(DateTime.now())}', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),

            // Ringkasan
            pw.Text('1. Ringkasan Keuangan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Laporan ini menyajikan posisi keuangan selama periode yang dipilih.'),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pemasukan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_formatCurrency(data.totalPemasukan), style: const pw.TextStyle(color: PdfColors.green)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pengeluaran:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_formatCurrency(data.totalPengeluaran), style: const pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Selisih:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        _formatCurrency(data.selisih),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: data.selisih >= 0 ? PdfColors.green : PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Analisis Kategori Pemasukan
            if (data.kategoriPemasukan.isNotEmpty) ...[
              pw.Text('2. Rincian Pemasukan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Berikut adalah sumber-sumber utama pemasukan selama periode ini.'),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Sumber Pemasukan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Jumlah (Rp)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...List.generate(data.kategoriPemasukan.length, (i) {
                    final kategori = data.kategoriPemasukan[i];
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${i + 1}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(kategori.namaKategori)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(kategori.total))),
                      ],
                    );
                  }),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')), 
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('TOTAL PEMASUKAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(data.totalPemasukan), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Analisis Kategori Pengeluaran
            if (data.kategoriPengeluaran.isNotEmpty) ...[
              pw.Text('3. Rincian Pengeluaran', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Berikut adalah alokasi pengeluaran berdasarkan kategori utama.'),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Kategori Pengeluaran', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Jumlah (Rp)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...List.generate(data.kategoriPengeluaran.length, (i) {
                    final kategori = data.kategoriPengeluaran[i];
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${i + 1}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(kategori.namaKategori)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(kategori.total))),
                      ],
                    );
                  }),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('TOTAL PENGELUARAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(data.totalPengeluaran), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Poin Kunci
            if (data.sumberUtama != null || data.posTerbesar != null) ...[
              pw.Text('4. Poin Kunci Keuangan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Bullet(text: 'Posisi Kas: ${data.selisih >= 0 ? 'Surplus' : 'Defisit'} ${_formatCurrency(data.selisih)}'),
              if (data.sumberUtama != null) pw.Bullet(text: 'Sumber Pemasukan Utama: ${data.sumberUtama}'),
              if (data.posTerbesar != null) pw.Bullet(text: 'Pos Pengeluaran Terbesar: ${data.posTerbesar}'),
              pw.SizedBox(height: 20),
            ],

            // Data Bulanan (opsional)
            if (data.dataBulanan.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'DATA BULANAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Bulan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Pemasukan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Pengeluaran', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Selisih', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...data.dataBulanan.map((bulanan) {
                    final selisih = bulanan.pemasukan - bulanan.pengeluaran;
                    final date = DateTime.parse('${bulanan.bulan}-01');
                    final months = [
                      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                    ];
                    final monthName = '${months[date.month - 1]} ${date.year}';
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(monthName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(bulanan.pemasukan)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(bulanan.pengeluaran)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            _formatCurrency(selisih),
                            style: pw.TextStyle(
                              color: selisih >= 0 ? PdfColors.green : PdfColors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],

            pw.SizedBox(height: 30),
            pw.Text(
              'Laporan ini dibuat secara otomatis oleh sistem Akuntansi Go',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
