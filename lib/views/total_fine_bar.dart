import 'package:flutter/material.dart';
import 'price_chip.dart';

class TotalFineBar extends StatelessWidget {
  final double totalFine;

  const TotalFineBar({super.key, required this.totalFine});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          PriceChip(amount: totalFine),
        ],
      ),
    );
  }
}