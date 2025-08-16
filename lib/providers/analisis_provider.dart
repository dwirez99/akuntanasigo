import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/db/database_helper.dart';
import '../models/analisis_data.dart';

class AnalisisFilter {
  final DateTime? start;
  final DateTime? end;
  const AnalisisFilter({this.start, this.end});

  String? get label {
    if (start == null || end == null) return null;
    final f = DateFormat('d MMM yyyy', 'id_ID');
    return '${f.format(start!)} - ${f.format(end!)}';
  }
}

final analisisFilterProvider = StateProvider<AnalisisFilter>((ref) => const AnalisisFilter());

final analisisProvider = FutureProvider<AnalisisData>((ref) async {
  final db = DatabaseHelper.instance;
  final filter = ref.watch(analisisFilterProvider);

  final String? startStr = filter.start != null ? DateFormat('yyyy-MM-dd').format(filter.start!) : null;
  final String? endStr = filter.end != null ? DateFormat('yyyy-MM-dd').format(filter.end!) : null;

  Future<int> getTotal(String jenis) async {
    if (startStr != null && endStr != null) {
      return db.getTotalNominalByRange(jenis: jenis, startDate: startStr, endDate: endStr);
    }
    return db.getTotalNominal(jenis: jenis);
  }

  Future<List<Map<String, dynamic>>> getKategori(String jenis) async {
    if (startStr != null && endStr != null) {
      return db.getKategoriAnalisisByRange(jenis, startStr, endStr);
    }
    return db.getKategoriAnalisis(jenis);
  }

  Future<List<Map<String, dynamic>>> getBulanan() async {
    if (startStr != null && endStr != null) {
      return db.getBulananDataByRange(startStr, endStr);
    }
    return db.getBulananData();
  }

  final totalPemasukan = await getTotal('Pemasukan');
  final totalPengeluaran = await getTotal('Pengeluaran');
  final selisih = totalPemasukan - totalPengeluaran;

  final kategoriPemasukanRaw = await getKategori('Pemasukan');
  final kategoriPengeluaranRaw = await getKategori('Pengeluaran');

  final kategoriPemasukan = kategoriPemasukanRaw.map((item) {
    final total = item['total'] as int; 
    final persentase = totalPemasukan > 0 ? (total / totalPemasukan) * 100 : 0.0;
    return KategoriAnalisis(
      namaKategori: item['nama_kategori'] as String,
      total: total,
      persentase: persentase,
    );
  }).toList();

  final kategoriPengeluaran = kategoriPengeluaranRaw.map((item) {
    final total = item['total'] as int;
    final persentase = totalPengeluaran > 0 ? (total / totalPengeluaran) * 100 : 0.0;
    return KategoriAnalisis(
      namaKategori: item['nama_kategori'] as String,
      total: total,
      persentase: persentase,
    );
  }).toList();

  final dataBulananRaw = await getBulanan();
  final Map<String, BulananData> bulananMap = {};
  for (final item in dataBulananRaw) {
    final bulan = item['bulan'] as String; // format YYYY-MM
    final jenis = item['jenis'] as String;
    final total = item['total'] as int;
    bulananMap.putIfAbsent(bulan, () => BulananData(bulan: bulan, pemasukan: 0, pengeluaran: 0));
    if (jenis == 'Pemasukan') {
      bulananMap[bulan] = BulananData(
        bulan: bulan,
        pemasukan: total,
        pengeluaran: bulananMap[bulan]!.pengeluaran,
      );
    } else {
      bulananMap[bulan] = BulananData(
        bulan: bulan,
        pemasukan: bulananMap[bulan]!.pemasukan,
        pengeluaran: total,
      );
    }
  }
  final dataBulanan = bulananMap.values.toList()..sort((a, b) => a.bulan.compareTo(b.bulan));

  // Riwayat Bulanan detail per kategori per jenis jika ada periode (untuk laporan rinci)
  List<RiwayatBulanan>? riwayatBulanan;
  if (startStr != null && endStr != null) {
    final monthlyDetail = await db.getMonthlyTransaksiDetail(startStr, endStr);
    // Group by bulan + jenis
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in monthlyDetail) {
      final key = '${row['bulan']}_${row['jenis']}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(row);
    }
    riwayatBulanan = [];
    for (final entry in grouped.entries) {
      final parts = entry.key.split('_');
      final bulan = parts.first;
      final jenis = parts.last;
      final rows = entry.value;
      final totalJenis = rows.fold<int>(0, (p, e) => p + (e['total'] as int));
      final items = rows.map((e) => RiwayatItem(
        kategori: e['nama_kategori'] as String,
        total: e['total'] as int,
        persentaseDariJenis: totalJenis > 0 ? ((e['total'] as int) / totalJenis) * 100 : 0,
      )).toList();
      riwayatBulanan.add(RiwayatBulanan(
        bulan: bulan,
        jenis: jenis,
        items: items,
        total: totalJenis,
      ));
    }
    // Sort by bulan & jenis (pemasukan dulu)
    riwayatBulanan.sort((a, b) {
      final c = a.bulan.compareTo(b.bulan);
      if (c != 0) return c;
      if (a.jenis == b.jenis) return 0;
      return a.jenis == 'Pemasukan' ? -1 : 1;
    });
  }

  String? sumberUtama;
  if (kategoriPemasukan.isNotEmpty) {
    final top = kategoriPemasukan.first;
    sumberUtama = '${top.namaKategori} menyumbang ${top.persentase.toStringAsFixed(1)}% dari total pemasukan';
  }
  String? posTerbesar;
  if (kategoriPengeluaran.isNotEmpty) {
    final top = kategoriPengeluaran.first;
    posTerbesar = '${top.namaKategori} menyumbang ${top.persentase.toStringAsFixed(1)}% dari total pengeluaran';
  }

  return AnalisisData(
    totalPemasukan: totalPemasukan,
    totalPengeluaran: totalPengeluaran,
    selisih: selisih,
    kategoriPemasukan: kategoriPemasukan,
    kategoriPengeluaran: kategoriPengeluaran,
    dataBulanan: dataBulanan,
    startDate: filter.start,
    endDate: filter.end,
    sumberUtama: sumberUtama,
    posTerbesar: posTerbesar,
  riwayatBulanan: riwayatBulanan,
  );
});
