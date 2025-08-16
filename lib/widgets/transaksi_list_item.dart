import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../models/kategori.dart';

class TransaksiListItem extends StatelessWidget {
  final Transaksi transaksi;
  final Kategori kategori;
  final VoidCallback? onTap;

  const TransaksiListItem({
    super.key,
    required this.transaksi,
    required this.kategori,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: transaksi.jenis == 'Pemasukan'
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            transaksi.jenis == 'Pemasukan'
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: transaksi.jenis == 'Pemasukan'
                ? Colors.green
                : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaksi.namaTransaksi,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kategori.namaKategori,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              DateFormat('dd MMM yyyy').format(
                DateTime.parse(transaksi.tanggal),
              ),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
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
                fontSize: 13,
                color: transaksi.jenis == 'Pemasukan'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: transaksi.jenis == 'Pemasukan'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaksi.jenis,
                style: TextStyle(
                  fontSize: 9,
                  color: transaksi.jenis == 'Pemasukan'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return 'Rp ${formatter.format(amount)}';
  }
}
