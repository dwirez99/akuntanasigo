import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/kategori.dart';
import '../../models/transaksi.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keuangan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_kategori TEXT NOT NULL,
        deskripsi TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_transaksi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        jenis TEXT NOT NULL,
        kategori_id INTEGER NOT NULL,
        nominal INTEGER NOT NULL,
        keterangan TEXT,
        FOREIGN KEY (kategori_id) REFERENCES kategori(id) ON DELETE CASCADE
      );
    ''');
  }

  // ========== KATEGORI ==========

  Future<int> insertKategori(Kategori kategori) async {
    final db = await instance.database;
    return await db.insert('kategori', kategori.toMap());
  }

  Future<List<Kategori>> getAllKategori() async {
    final db = await instance.database;
    final result = await db.query('kategori');
    return result.map((e) => Kategori.fromMap(e)).toList();
  }

  Future<int> updateKategori(Kategori kategori) async {
    final db = await instance.database;
    return await db.update(
      'kategori',
      kategori.toMap(),
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  Future<int> deleteKategori(int id) async {
    final db = await instance.database;
    return await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
  }

  // ========== TRANSAKSI ==========

  Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await instance.database;
    return await db.insert('transaksi', transaksi.toMap());
  }

  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await instance.database;
    final result = await db.query('transaksi', orderBy: 'tanggal DESC');
    return result.map((e) => Transaksi.fromMap(e)).toList();
  }

  Future<int> updateTransaksi(Transaksi transaksi) async {
    final db = await instance.database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  Future<int> deleteTransaksi(int id) async {
    final db = await instance.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }

  // ========== ANALISIS (opsional tambahan) ==========

  Future<int> getTotalNominal({required String jenis}) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(nominal) as total FROM transaksi WHERE jenis = ?',
      [jenis],
    );
    return result.first['total'] == null ? 0 : result.first['total'] as int;
  }

  Future<int> getTotalNominalByRange({required String jenis, required String startDate, required String endDate}) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(nominal) as total FROM transaksi WHERE jenis = ? AND tanggal BETWEEN ? AND ?',
      [jenis, startDate, endDate],
    );
    return result.first['total'] == null ? 0 : result.first['total'] as int;
  }

  // ========== ANALISIS TAMBAHAN ==========

  Future<List<Map<String, dynamic>>> getKategoriAnalisis(String jenis) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT k.nama_kategori, SUM(t.nominal) as total 
      FROM transaksi t 
      JOIN kategori k ON t.kategori_id = k.id 
      WHERE t.jenis = ? 
      GROUP BY k.id, k.nama_kategori 
      ORDER BY total DESC
    ''', [jenis]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getKategoriAnalisisByRange(String jenis, String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT k.nama_kategori, SUM(t.nominal) as total 
      FROM transaksi t 
      JOIN kategori k ON t.kategori_id = k.id 
      WHERE t.jenis = ? AND t.tanggal BETWEEN ? AND ?
      GROUP BY k.id, k.nama_kategori 
      ORDER BY total DESC
    ''', [jenis, startDate, endDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getBulananData() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', tanggal) as bulan,
        jenis,
        SUM(nominal) as total
      FROM transaksi 
      GROUP BY strftime('%Y-%m', tanggal), jenis
      ORDER BY bulan DESC
      LIMIT 12
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getBulananDataByRange(String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', tanggal) as bulan,
        jenis,
        SUM(nominal) as total
      FROM transaksi 
      WHERE tanggal BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m', tanggal), jenis
      ORDER BY bulan ASC
    ''', [startDate, endDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTransaksiByDateRange(
    String startDate, 
    String endDate, 
    {int? kategoriId}
  ) async {
    final db = await instance.database;
    String query = '''
      SELECT t.*, k.nama_kategori 
      FROM transaksi t 
      JOIN kategori k ON t.kategori_id = k.id 
      WHERE t.tanggal BETWEEN ? AND ?
    ''';
    List<dynamic> params = [startDate, endDate];
    
    if (kategoriId != null) {
      query += ' AND t.kategori_id = ?';
      params.add(kategoriId);
    }
    
    query += ' ORDER BY t.tanggal DESC';
    
    final result = await db.rawQuery(query, params);
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransaksiDetail(String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT strftime('%Y-%m', t.tanggal) as bulan,
             t.jenis,
             k.nama_kategori,
             SUM(t.nominal) as total
      FROM transaksi t
      JOIN kategori k ON t.kategori_id = k.id
      WHERE t.tanggal BETWEEN ? AND ?
      GROUP BY bulan, t.jenis, k.id
      ORDER BY bulan ASC, t.jenis ASC, total DESC
    ''', [startDate, endDate]);
    return result;
  }

  // ====== DUMMY DATA SEEDER (untuk pengujian / demo) ======
  Future<void> seedDummyData({int monthsBack = 6, int maxTransaksiPerBulan = 20}) async {
    final db = await instance.database;
    // Cek apakah sudah ada transaksi; jika ada > 0, jangan seed dua kali (bisa diubah sesuai kebutuhan)
    final countRes = await db.rawQuery('SELECT COUNT(*) as c FROM transaksi');
    final existing = (countRes.first['c'] as int); 
    if (existing > 0) {
      return; // Sudah ada data, skip agar tidak dobel
    }

    // Masukkan kategori dasar jika kosong
    final kategoriCountRes = await db.rawQuery('SELECT COUNT(*) as c FROM kategori');
    final kategoriExisting = (kategoriCountRes.first['c'] as int);
    List<int> kategoriIds = [];
    if (kategoriExisting == 0) {
      final baseKategori = [
        'SPP Siswa',
        'Uang Pangkal',
        'Dana BOS',
        'Donasi',
        'Gaji & Tunjangan',
        'Sarana & Prasarana',
        'KBM',
        'Operasional Rutin',
        'Administrasi',
      ];
      for (final nama in baseKategori) {
        final id = await db.insert('kategori', {
          'nama_kategori': nama,
          'deskripsi': 'Dummy',
        });
        kategoriIds.add(id);
      }
    } else {
      final all = await db.query('kategori');
      kategoriIds = all.map((e) => e['id'] as int).toList();
    }

    final now = DateTime.now();
    final rand = Random();
    final pemasukanKategori = ['SPP Siswa','Uang Pangkal','Dana BOS','Donasi'];
    final pengeluaranKategori = ['Gaji & Tunjangan','Sarana & Prasarana','KBM','Operasional Rutin','Administrasi'];

    Map<String,int> kategoriNameToId = {};
    final kategoriRows = await db.query('kategori');
    for (final row in kategoriRows) {
      kategoriNameToId[row['nama_kategori'] as String] = row['id'] as int;
    }

    for (int m = monthsBack - 1; m >= 0; m--) {
      final dateBase = DateTime(now.year, now.month - m, 1);
      final lastDay = DateTime(dateBase.year, dateBase.month + 1, 0).day;
      final transaksiCountBulan = rand.nextInt(maxTransaksiPerBulan ~/ 2) + (maxTransaksiPerBulan ~/ 2);
      for (int i = 0; i < transaksiCountBulan; i++) {
        final isIncome = rand.nextBool();
        final namaKategori = isIncome
            ? pemasukanKategori[rand.nextInt(pemasukanKategori.length)]
            : pengeluaranKategori[rand.nextInt(pengeluaranKategori.length)];
        final kategoriId = kategoriNameToId[namaKategori]!;
        final day = rand.nextInt(lastDay) + 1;
        final tanggal = DateTime(dateBase.year, dateBase.month, day);
        final nominalBase = isIncome ? 5000000 : 2000000; // baseline
        final nominal = (nominalBase + rand.nextInt(nominalBase)) ~/ 1000 * 1000; // bulat ribuan
        await db.insert('transaksi', {
          'nama_transaksi': '${isIncome ? 'Pemasukan' : 'Pengeluaran'} ${i + 1}',
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'jenis': isIncome ? 'Pemasukan' : 'Pengeluaran',
          'kategori_id': kategoriId,
          'nominal': nominal,
          'keterangan': 'Dummy auto generated',
        });
      }
    }
  }
}
