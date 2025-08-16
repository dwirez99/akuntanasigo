import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database_helper.dart';
import '../models/transaksi.dart';
import 'summary_provider.dart';

final transaksiProvider =
    StateNotifierProvider<TransaksiNotifier, List<Transaksi>>((ref) {
  return TransaksiNotifier(ref);
});

class TransaksiNotifier extends StateNotifier<List<Transaksi>> {
  final Ref ref;
  
  TransaksiNotifier(this.ref) : super([]) {
    loadTransaksi();
  }

  Future<void> loadTransaksi() async {
    final data = await DatabaseHelper.instance.getAllTransaksi();
    state = data;
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    await DatabaseHelper.instance.insertTransaksi(transaksi);
    await loadTransaksi();
    // Refresh summary provider
    ref.invalidate(summaryProvider);
    ref.invalidate(recentTransaksiProvider);
  }

  Future<void> updateTransaksi(Transaksi transaksi) async {
    await DatabaseHelper.instance.updateTransaksi(transaksi);
    await loadTransaksi();
    // Refresh summary provider
    ref.invalidate(summaryProvider);
    ref.invalidate(recentTransaksiProvider);
  }

  Future<void> deleteTransaksi(int id) async {
    await DatabaseHelper.instance.deleteTransaksi(id);
    await loadTransaksi();
    // Refresh summary provider
    ref.invalidate(summaryProvider);
    ref.invalidate(recentTransaksiProvider);
  }
}
