import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database_helper.dart';
import '../models/kategori.dart';

final kategoriProvider =
    StateNotifierProvider<KategoriNotifier, List<Kategori>>((ref) {
  return KategoriNotifier();
});

class KategoriNotifier extends StateNotifier<List<Kategori>> {
  KategoriNotifier() : super([]) {
    loadKategori(); // langsung load saat provider diinisialisasi
  }

  Future<void> loadKategori() async {
    final data = await DatabaseHelper.instance.getAllKategori();
    state = data;
  }

  Future<void> addKategori(Kategori kategori) async {
    await DatabaseHelper.instance.insertKategori(kategori);
    await loadKategori();
  }

  Future<void> updateKategori(Kategori kategori) async {
    await DatabaseHelper.instance.updateKategori(kategori);
    await loadKategori();
  }

  Future<void> deleteKategori(int id) async {
    await DatabaseHelper.instance.deleteKategori(id);
    await loadKategori();
  }
}
