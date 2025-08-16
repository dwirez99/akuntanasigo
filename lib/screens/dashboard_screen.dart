import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/summary_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaksi_list_item.dart';
import '../models/kategori.dart';
import 'transaksi_screen.dart';
import 'transaksi_form_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);
    final recentTransaksiAsync = ref.watch(recentTransaksiProvider);
    final kategoriList = ref.watch(kategoriProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ref.invalidate(summaryProvider);
              ref.invalidate(recentTransaksiProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(summaryProvider);
          ref.invalidate(recentTransaksiProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Keuangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    summaryAsync.when(
                      data: (summary) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'Pemasukan',
                                  amount: summary.totalPemasukan,
                                  icon: Icons.arrow_upward,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Pengeluaran',
                                  amount: summary.totalPengeluaran,
                                  icon: Icons.arrow_downward,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SummaryCard(
                            title: 'Selisih',
                            amount: summary.selisih,
                            icon: summary.selisih >= 0 
                                ? Icons.trending_up 
                                : Icons.trending_down,
                            color: summary.selisih >= 0 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Transactions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransaksiScreen(),
                          ),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),

              recentTransaksiAsync.when(
                data: (transaksiList) {
                  if (transaksiList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
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
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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

                      return TransaksiListItem(
                        transaksi: transaksi,
                        kategori: kategori,
                        onTap: () {
                          // Navigate to detail or edit
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransaksiFormScreen(
                                transaksi: transaksi,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransaksiFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
