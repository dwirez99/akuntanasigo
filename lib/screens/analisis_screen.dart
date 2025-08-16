import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../providers/analisis_provider.dart';
import '../widgets/kategori_pie_chart.dart';
import '../widgets/bulanan_line_chart.dart';
import '../widgets/summary_card.dart';
import '../services/pdf_service.dart';
import '../core/db/database_helper.dart';

class AnalisisScreen extends ConsumerWidget {
  const AnalisisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analisisAsync = ref.watch(analisisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Keuangan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!kReleaseMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Generate Dummy Data',
              onPressed: () => _generateDummy(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Pilih Periode',
            onPressed: () => _selectRange(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(analisisProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analisisProvider);
        },
        child: analisisAsync.when(
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Periode
                if (data.startDate != null && data.endDate != null) ...[
                  Text(
                    'Periode: ${DateFormat('d MMM yyyy', 'id_ID').format(data.startDate!)} - ${DateFormat('d MMM yyyy', 'id_ID').format(data.endDate!)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                ],
                // Summary Cards & Ringkasan
                const Text(
                  'Ringkasan Keuangan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Pemasukan',
                        amount: data.totalPemasukan,
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Pengeluaran',
                        amount: data.totalPengeluaran,
                        icon: Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SummaryCard(
                  title: 'Selisih',
                  amount: data.selisih,
                  icon: data.selisih >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: data.selisih >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 12),
                if (data.sumberUtama != null || data.posTerbesar != null) Card(
                  elevation: 0,
                  color: Colors.blueGrey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Poin Kunci Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Posisi Kas: ${data.selisih >= 0 ? 'Surplus' : 'Defisit'} ${_formatCurrency(data.selisih)}'),
                        if (data.sumberUtama != null) Text('Sumber Pemasukan Utama: ${data.sumberUtama}'),
                        if (data.posTerbesar != null) Text('Pos Pengeluaran Terbesar: ${data.posTerbesar}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Grafik Bulanan
                if (data.dataBulanan.isNotEmpty) ...[
                  const Text(
                    'Trend Bulanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BulananLineChart(data: data.dataBulanan),
                  const SizedBox(height: 32),
                ],

                // Analisis Kategori
                if (data.kategoriPemasukan.isNotEmpty || data.kategoriPengeluaran.isNotEmpty) ...[
                  const Text(
                    'Rincian Kategori',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (data.kategoriPemasukan.isNotEmpty) ...[
                    KategoriPieChart(
                      data: data.kategoriPemasukan,
                      title: 'Rincian Pemasukan',
                      primaryColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.kategoriPengeluaran.isNotEmpty) ...[
                    KategoriPieChart(
                      data: data.kategoriPengeluaran,
                      title: 'Rincian Pengeluaran',
                      primaryColor: Colors.red,
                    ),
                    const SizedBox(height: 32),
                  ],
                ],

                // Detail List Kategori
                if (data.kategoriPemasukan.isNotEmpty) ...[
                  const Text(
                    'Detail Kategori Pemasukan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildKategoriList(data.kategoriPemasukan, Colors.green),
                  const SizedBox(height: 24),
                ],

                if (data.kategoriPengeluaran.isNotEmpty) ...[
                  const Text(
                    'Detail Kategori Pengeluaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildKategoriList(data.kategoriPengeluaran, Colors.red),
                  const SizedBox(height: 24),
                ],

                // Data Bulanan Ringkas
                if (data.dataBulanan.isNotEmpty) ...[
                  const Text(
                    'Ringkasan Bulanan (Aggregat)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulananTable(data.dataBulanan),
                  const SizedBox(height: 32),
                ],

                // Riwayat Bulanan Detail Per Kategori
                if (data.riwayatBulanan != null && data.riwayatBulanan!.isNotEmpty) ...[
                  const Text(
                    'Riwayat Transaksi Per Bulan (Per Kategori)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._buildRiwayatBulananSections(data.riwayatBulanan!),
                ],

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(analisisProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: analisisAsync.when(
        data: (data) => FloatingActionButton.extended(
          onPressed: () => _downloadPDF(context, data),
          label: const Text('Download PDF'),
          icon: const Icon(Icons.download),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildKategoriList(List<dynamic> kategoriList, Color color) {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kategoriList.length,
        itemBuilder: (context, index) {
          final kategori = kategoriList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(kategori.namaKategori),
            subtitle: Text('${kategori.persentase.toStringAsFixed(1)}%'),
            trailing: Text(
              _formatCurrency(kategori.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulananTable(List<dynamic> dataBulanan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Bulan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Pemasukan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Pengeluaran',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Selisih',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...dataBulanan.map((bulanan) {
                  final selisih = bulanan.pemasukan - bulanan.pengeluaran;
                  final date = DateTime.parse('${bulanan.bulan}-01');
                  final monthName = DateFormat('MMM yyyy').format(date);
                  
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(monthName, textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _formatCurrency(bulanan.pemasukan),
                          style: const TextStyle(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _formatCurrency(bulanan.pengeluaran),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _formatCurrency(selisih),
                          style: TextStyle(
                            color: selisih >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return 'Rp ${formatter.format(amount.abs())}';
  }

  Future<void> _selectRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initialFirst = DateTime(now.year, now.month, 1);
    final initialLast = DateTime(now.year, now.month + 1, 0);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialFirst, end: initialLast),
      helpText: 'Pilih Periode Analisis',
      saveText: 'Terapkan',
    );
    if (picked != null) {
      ref.read(analisisFilterProvider.notifier).state = AnalisisFilter(start: picked.start, end: picked.end);
      ref.invalidate(analisisProvider);
    }
  }

  Future<void> _downloadPDF(BuildContext context, dynamic data) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Membuat laporan PDF...'),
            ],
          ),
        ),
      );

      await PDFService.generateAnalisisReport(data);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan PDF berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateDummy(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Dummy Data'),
        content: const Text('Generate data dummy untuk beberapa bulan ke belakang? (Abaikan jika sudah ada data).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lanjut')),
        ],
      ),
    );
    if (confirm != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyiapkan dummy data...')));
    try {
      await DatabaseHelper.instance.seedDummyData(monthsBack: 6, maxTransaksiPerBulan: 28);
      if (context.mounted) {
        ref.invalidate(analisisProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dummy data selesai'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
      }
    }
  }

  List<Widget> _buildRiwayatBulananSections(List<dynamic> riwayat) {
    // riwayat: List<RiwayatBulanan>
    final Map<String, List<dynamic>> perBulan = {};
    for (final r in riwayat) {
      perBulan.putIfAbsent(r.bulan, () => []);
      perBulan[r.bulan]!.add(r);
    }
    final entries = perBulan.entries.toList()..sort((a,b)=>a.key.compareTo(b.key));
    return entries.map((entry) {
      final bulanKey = entry.key; // YYYY-MM
      final date = DateTime.parse('$bulanKey-01');
      final monthName = DateFormat('MMMM yyyy', 'id_ID').format(date);
  final pemasukan = entry.value.where((e)=>e.jenis=='Pemasukan').fold<int>(0,(p,e)=>p + (e.total as int));
  final pengeluaran = entry.value.where((e)=>e.jenis=='Pengeluaran').fold<int>(0,(p,e)=>p + (e.total as int));
      final selisih = pemasukan - pengeluaran;
      return ExpansionTile(
        title: Text(monthName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Pemasukan ${_formatCurrency(pemasukan)} · Pengeluaran ${_formatCurrency(pengeluaran)} · Selisih ${_formatCurrency(selisih)}',
          style: TextStyle(color: selisih>=0?Colors.green:Colors.red, fontSize: 12)),
        children: [
          ...entry.value.map((rb) => _buildJenisSection(rb)),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  Widget _buildJenisSection(dynamic rb) {
    // rb: RiwayatBulanan
    final color = rb.jenis == 'Pemasukan' ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rb.jenis, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              ...rb.items.map<Widget>((item) => Row(
                children: [
                  Expanded(child: Text(item.kategori)),
                  Text('${item.persentaseDariJenis.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Text(_formatCurrency(item.total), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              )),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total ${rb.jenis}: ${_formatCurrency(rb.total)}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
