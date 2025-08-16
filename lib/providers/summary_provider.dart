import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database_helper.dart';
import '../models/transaksi.dart';

// Model untuk summary
class KeuanganSummary {
  final int totalPemasukan;
  final int totalPengeluaran;
  final int selisih;

  KeuanganSummary({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.selisih,
  });
}

// Provider untuk mendapatkan summary keuangan
final summaryProvider = FutureProvider<KeuanganSummary>((ref) async {
  final totalPemasukan = await DatabaseHelper.instance.getTotalNominal(jenis: 'Pemasukan');
  final totalPengeluaran = await DatabaseHelper.instance.getTotalNominal(jenis: 'Pengeluaran');
  final selisih = totalPemasukan - totalPengeluaran;

  return KeuanganSummary(
    totalPemasukan: totalPemasukan,
    totalPengeluaran: totalPengeluaran,
    selisih: selisih,
  );
});

// Provider untuk mendapatkan transaksi terbaru (limit 10)
final recentTransaksiProvider = FutureProvider<List<Transaksi>>((ref) async {
  final allTransaksi = await DatabaseHelper.instance.getAllTransaksi();
  return allTransaksi.take(10).toList(); // Ambil 10 transaksi terbaru
});
