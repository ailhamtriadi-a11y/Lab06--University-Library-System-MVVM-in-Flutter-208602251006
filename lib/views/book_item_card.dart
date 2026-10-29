import 'package:flutter/material.dart';
import '../../models/book.dart';

class BookItemCard extends StatelessWidget {
  final Book book;
  final VoidCallback onBorrow;

  const BookItemCard({
    super.key,
    required this.book,
    required this.onBorrow,
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
                  Text(
                    book.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.author} | Status: ${book.status.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: book.status == BookStatus.available ? onBorrow : null,
              child: const Text('Pinjam'),
            ),
          ],
        ),
      ),
    );
  }
}