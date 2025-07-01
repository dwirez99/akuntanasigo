import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/kategori.dart';
import '../../models/transaksi.dart';

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
}
