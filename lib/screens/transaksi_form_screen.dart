import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../models/kategori.dart';
import '../providers/transaksi_provider.dart';
import '../providers/kategori_provider.dart';

class TransaksiFormScreen extends ConsumerStatefulWidget {
  final Transaksi? transaksi;

  const TransaksiFormScreen({super.key, this.transaksi});

  @override
  ConsumerState<TransaksiFormScreen> createState() => _TransaksiFormScreenState();
}

class _TransaksiFormScreenState extends ConsumerState<TransaksiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedJenis = 'Pemasukan';
  int? _selectedKategoriId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaksi != null) {
      final transaksi = widget.transaksi!;
      _namaController.text = transaksi.namaTransaksi;
      _nominalController.text = transaksi.nominal.toString();
      _keteranganController.text = transaksi.keterangan;
      _selectedDate = DateTime.parse(transaksi.tanggal);
      _selectedJenis = transaksi.jenis;
      _selectedKategoriId = transaksi.kategoriId;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kategoriList = ref.watch(kategoriProvider);
    final isEditing = widget.transaksi != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: kategoriList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada kategori tersedia.\nTambahkan kategori terlebih dahulu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Jenis Transaksi
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jenis Transaksi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Pemasukan'),
                                    value: 'Pemasukan',
                                    groupValue: _selectedJenis,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedJenis = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Pengeluaran'),
                                    value: 'Pengeluaran',
                                    groupValue: _selectedJenis,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedJenis = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form Data
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _namaController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Transaksi',
                                hintText: 'Masukkan nama transaksi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.receipt),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama transaksi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Tanggal
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Tanggal',
                                hintText: 'Pilih tanggal',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.date_range),
                                  onPressed: _selectDate,
                                ),
                              ),
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Kategori
                            DropdownButtonFormField<int>(
                              value: _selectedKategoriId,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: kategoriList.map((kategori) {
                                return DropdownMenuItem<int>(
                                  value: kategori.id,
                                  child: Text(kategori.namaKategori),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKategoriId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Pilih kategori';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Nominal
                            TextFormField(
                              controller: _nominalController,
                              decoration: const InputDecoration(
                                labelText: 'Nominal',
                                hintText: 'Masukkan nominal',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                                prefixText: 'Rp ',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nominal tidak boleh kosong';
                                }
                                final nominal = int.tryParse(value);
                                if (nominal == null || nominal <= 0) {
                                  return 'Nominal harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Keterangan
                            TextFormField(
                              controller: _keteranganController,
                              decoration: const InputDecoration(
                                labelText: 'Keterangan',
                                hintText: 'Masukkan keterangan (opsional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveTransaksi,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? 'Update Transaksi' : 'Simpan Transaksi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaksi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transaksi = Transaksi(
        id: widget.transaksi?.id,
        namaTransaksi: _namaController.text.trim(),
        tanggal: _selectedDate.toIso8601String().split('T')[0],
        jenis: _selectedJenis,
        kategoriId: _selectedKategoriId!,
        nominal: int.parse(_nominalController.text),
        keterangan: _keteranganController.text.trim(),
      );

      if (widget.transaksi != null) {
        await ref.read(transaksiProvider.notifier).updateTransaksi(transaksi);
      } else {
        await ref.read(transaksiProvider.notifier).addTransaksi(transaksi);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaksi != null
                  ? 'Transaksi berhasil diupdate'
                  : 'Transaksi berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}