class AnalisisData {
  final int totalPemasukan;
  final int totalPengeluaran;
  final int selisih;
  final List<KategoriAnalisis> kategoriPemasukan;
  final List<KategoriAnalisis> kategoriPengeluaran;
  final List<BulananData> dataBulanan;
  final DateTime? startDate;
  final DateTime? endDate;

  // Insight text (optional)
  final String? sumberUtama;
  final String? posTerbesar;
  final List<RiwayatBulanan>? riwayatBulanan; // detail per bulan per kategori

  AnalisisData({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.selisih,
    required this.kategoriPemasukan,
    required this.kategoriPengeluaran,
    required this.dataBulanan,
    this.startDate,
    this.endDate,
    this.sumberUtama,
    this.posTerbesar,
  this.riwayatBulanan,
  });
}

class KategoriAnalisis {
  final String namaKategori;
  final int total;
  final double persentase;

  KategoriAnalisis({
    required this.namaKategori,
    required this.total,
    required this.persentase,
  });
}

class BulananData {
  final String bulan;
  final int pemasukan;
  final int pengeluaran;

  BulananData({
    required this.bulan,
    required this.pemasukan,
    required this.pengeluaran,
  });
}

class RiwayatBulanan {
  final String bulan; // YYYY-MM
  final String jenis; // Pemasukan / Pengeluaran
  final List<RiwayatItem> items;
  final int total;
  RiwayatBulanan({required this.bulan, required this.jenis, required this.items, required this.total});
}

class RiwayatItem {
  final String kategori;
  final int total;
  final double persentaseDariJenis;
  RiwayatItem({required this.kategori, required this.total, required this.persentaseDariJenis});
}
