import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../viewmodels/library_view_model.dart';

class LibraryScreen extends StatefulWidget {
  final LibraryViewModel viewModel;

  const LibraryScreen({super.key, required this.viewModel});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late TextEditingController _searchController;
  late TextEditingController _studentIdController; 

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _studentIdController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final booksToDisplay = widget.viewModel.filteredBooks;
        final activeLoansToDisplay = widget.viewModel.activeLoans;

        return Scaffold(
          appBar: AppBar(
            title: const Text('University Library System'),
            actions: [
      PopupMenuButton<String>(
        icon: const Icon(Icons.access_time),
        tooltip: 'Simulasi Waktu Terlambat',
        onSelected: (mode) => widget.viewModel.setSimulationState(mode),
        itemBuilder: (context) => [
          const PopupMenuItem(value: '1_week', child: Text('Terlambat 1 Minggu (Rp5.000)')),
          const PopupMenuItem(value: '2_weeks', child: Text('Terlambat 2 Minggu (Rp10.000)')),
          const PopupMenuItem(value: '3_weeks', child: Text('Terlambat 3 Minggu (Rp15.000)')),
          const PopupMenuItem(value: '6_months', child: Text('Terlambat 6 Bulan (Missing + Replacement)')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'reset', child: Text('Reset ke Hari Peminjaman')),
        ],
      ),
              PopupMenuButton<BookFilter>(
                icon: const Icon(Icons.filter_list),
                onSelected: (filter) => widget.viewModel.setFilter(filter),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: BookFilter.all, child: Text('All Books')),
                  const PopupMenuItem(value: BookFilter.available, child: Text('Available')),
                  const PopupMenuItem(value: BookFilter.borrowed, child: Text('Borrowed')),
                  const PopupMenuItem(value: BookFilter.missing, child: Text('Missing')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'University Library System',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Katalog buku, status peminjaman, dan perhitungan denda.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _studentIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'ID Mahasiswa (NIM)',
                    hintText: 'Masukkan angka NIM',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Cari buku',
                    hintText: 'Masukkan judul atau penulis',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => widget.viewModel.setSearchQuery(value),
                ),
              ),
              Expanded(
                flex: 1,
                child: booksToDisplay.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text(
                              'Buku tidak ditemukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.viewModel.setSearchQuery('');
                              },
                              child: const Text('Hapus Pencarian'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: booksToDisplay.length,
                        itemBuilder: (context, index) {
                          final book = booksToDisplay[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${book.author} | Harga Ganti: Rp ${book.replacementPrice.toStringAsFixed(0)} | Status: ${book.status.name}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: book.status == BookStatus.available
                                        ? () {
                                            // Ambil input dari controller alih-alih hardcoded 'STUDENT-01'
                                            final studentId = _studentIdController.text;
                                            final success = widget.viewModel.borrowBook(book.id, studentId);

                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Buku berhasil dipinjam oleh $studentId!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Peminjaman gagal! ID Mahasiswa tidak boleh kosong.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    child: const Text('Pinjam'),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Expanded(
                flex: 1,
                child: activeLoansToDisplay.isEmpty
                    ? const Center(
                        child: Text('Belum ada peminjaman aktif', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: activeLoansToDisplay.length,
                        itemBuilder: (context, index) {
                          final loan = activeLoansToDisplay[index];
                          final overdueFine = widget.viewModel.getOverdueFine(loan);
                          final replacementCost = widget.viewModel.getReplacementCost(loan);
                          final totalFine = widget.viewModel.calculateFine(loan);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Pinjaman ID: ${loan.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('Jatuh Tempo: ${loan.dueDate.toString().split(' ')[0]}', style: const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 4),
                                        // RINCIAN PEMBEDA DENDA & GANTI RUGI
                                        Text(
                                          'Denda Overdue: Rp ${overdueFine.toStringAsFixed(0)}'
                                          '${replacementCost > 0 ? '\nBiaya Ganti Buku (Missing): Rp ${replacementCost.toStringAsFixed(0)}' : ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: replacementCost > 0 ? Colors.red : Colors.orange.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Total: Rp ${totalFine.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => widget.viewModel.returnBook(loan.id),
                                    child: const Text('Kembalikan'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Denda Aktif:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rp ${widget.viewModel.totalActiveFines.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}