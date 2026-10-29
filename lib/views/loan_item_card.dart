import 'package:flutter/material.dart';
import '../../models/loan.dart';
import 'price_chip.dart';

class LoanItemCard extends StatelessWidget {
  final Loan loan;
  final double fine;
  final VoidCallback onReturn;

  const LoanItemCard({
    super.key,
    required this.loan,
    required this.fine,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
            PriceChip(amount: fine),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onReturn,
              child: const Text('Kembalikan'),
            ),
          ],
        ),
      ),
    );
  }
}