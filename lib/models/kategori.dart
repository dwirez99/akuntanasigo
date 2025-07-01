class Kategori {
  final int? id;
  final String namaKategori;
  final String deskripsi;

  Kategori({
    this.id,
    required this.namaKategori,
    required this.deskripsi,
  });

  // Konversi dari Map (dari SQLite) ke objek Kategori
  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'],
      namaKategori: map['nama_kategori'],
      deskripsi: map['deskripsi'],
    );
  }

  // Konversi dari objek Kategori ke Map (untuk disimpan di SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_kategori': namaKategori,
      'deskripsi': deskripsi,
    };
  }
}
