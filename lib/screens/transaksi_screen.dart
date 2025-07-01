import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../models/kategori.dart';
import '../providers/transaksi_provider.dart';
import '../providers/kategori_provider.dart';
import 'transaksi_form_screen.dart';

class TransaksiScreen extends ConsumerWidget {
  const TransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksiList = ref.watch(transaksiProvider);
    final kategoriList = ref.watch(kategoriProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Transaksi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: transaksiList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transaksiList.length,
              itemBuilder: (context, index) {
                final transaksi = transaksiList[index];
                final kategori = kategoriList.firstWhere(
                  (k) => k.id == transaksi.kategoriId,
                  orElse: () => Kategori(
                    id: 0,
                    namaKategori: 'Kategori Tidak Ditemukan',
                    deskripsi: '',
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaksi.jenis == 'Pemasukan'
                          ? Colors.green
                          : Colors.red,
                      child: Icon(
                        transaksi.jenis == 'Pemasukan'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      transaksi.namaTransaksi,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${kategori.namaKategori}'),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(transaksi.tanggal),
                          ),
                        ),
                        if (transaksi.keterangan.isNotEmpty)
                          Text(
                            transaksi.keterangan,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(transaksi.nominal),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaksi.jenis == 'Pemasukan'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTransaksi(context, transaksi);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, ref, transaksi);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaksi(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _addTransaksi(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransaksiFormScreen(),
      ),
    );
  }

  void _editTransaksi(BuildContext context, Transaksi transaksi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransaksiFormScreen(transaksi: transaksi),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Transaksi transaksi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus transaksi "${transaksi.namaTransaksi}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(transaksiProvider.notifier).deleteTransaksi(transaksi.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaksi berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}