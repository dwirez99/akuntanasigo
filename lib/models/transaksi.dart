class Transaksi {
  final int? id;
  final String namaTransaksi;
  final String tanggal;
  final String jenis; // "Pemasukan" atau "Pengeluaran"
  final int kategoriId;
  final int nominal;
  final String keterangan;

  Transaksi({
    this.id,
    required this.namaTransaksi,
    required this.tanggal,
    required this.jenis,
    required this.kategoriId,
    required this.nominal,
    required this.keterangan,
  });

  // Konversi dari Map (dari SQLite) ke objek Transaksi
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      namaTransaksi: map['nama_transaksi'],
      tanggal: map['tanggal'],
      jenis: map['jenis'],
      kategoriId: map['kategori_id'],
      nominal: map['nominal'],
      keterangan: map['keterangan'],
    );
  }

  // Konversi dari objek Transaksi ke Map (untuk disimpan di SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_transaksi': namaTransaksi,
      'tanggal': tanggal,
      'jenis': jenis,
      'kategori_id': kategoriId,
      'nominal': nominal,
      'keterangan': keterangan,
    };
  }
}
