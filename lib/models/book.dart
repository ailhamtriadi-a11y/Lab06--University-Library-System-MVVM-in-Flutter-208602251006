enum BookStatus { available, borrowed, missing }

class Book {
  final String id;
  final String title;
  final String author;
  final double replacementPrice;
  BookStatus status;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.status = BookStatus.available,
  });
}