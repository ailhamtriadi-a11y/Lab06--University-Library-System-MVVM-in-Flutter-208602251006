import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';

enum BookFilter { all, available, borrowed, missing }

class LibraryViewModel extends ChangeNotifier {
  final List<Book> _books = [
    Book(id: 'b1', title: 'Star Rail Simulation, But Fate is a Madman', author: 'Tian Qi Zhen Hao', replacementPrice: 150000),
    Book(id: 'b2', title: 'Sanjia Lane ', author: '欧阳山 著', replacementPrice: 200000),
    Book(id: 'b3', title: ' Android Developer Tools Essentials', author: 'Mike Wolfson', replacementPrice: 125000),
    Book(id: 'b4', title: 'Northern Grave Robbers Chronicles', author: 'Yun Feng', replacementPrice: 180000),
    Book(id: 'b5', title: 'Design Pattern', author: 'Dayo', replacementPrice: 300000),
  ];

  final List<Loan> _loans = [];
  static const double weeklyFineRate = 5000;

  String _searchQuery = '';
  BookFilter _selectedFilter = BookFilter.all;

  late DateTime _simulatedDate;

  LibraryViewModel() {
    final now = DateTime.now();
    _simulatedDate = DateTime(now.year, now.month, now.day);
  }

  String get searchQuery => _searchQuery;
  BookFilter get selectedFilter => _selectedFilter;

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get activeLoans => _loans.where((loan) => !loan.isReturned).toList();

  List<Book> get filteredBooks {
    return _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      if (_selectedFilter == BookFilter.available) {
        matchesFilter = book.status == BookStatus.available;
      } else if (_selectedFilter == BookFilter.borrowed) {
        matchesFilter = book.status == BookStatus.borrowed;
      } else if (_selectedFilter == BookFilter.missing) {
        matchesFilter = book.status == BookStatus.missing;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(BookFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSimulationState(String mode) {
    final now = DateTime.now();
    final baseDate = DateTime(now.year, now.month, now.day);

    if (_loans.isNotEmpty && !_loans.first.isReturned) {

      final dueDate = _loans.first.dueDate;
      if (mode == '1_week') {
        _simulatedDate = dueDate.add(const Duration(days: 7));
      } else if (mode == '2_weeks') {
        _simulatedDate = dueDate.add(const Duration(days: 14));
      } else if (mode == '3_weeks') {
        _simulatedDate = dueDate.add(const Duration(days: 21));
      } else if (mode == '6_months') {
        _simulatedDate = DateTime(dueDate.year, dueDate.month + 6, dueDate.day);
      } else {
        _simulatedDate = baseDate;
      }
    } else {
      _simulatedDate = baseDate;
    }
    notifyListeners();
  }

  bool borrowBook(String bookId, String studentId) {
    if (studentId.trim().isEmpty) {
    return false;
  }

    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex == -1) return false;

    final book = _books[bookIndex];
    if (book.status != BookStatus.available) return false;

    book.status = BookStatus.borrowed;

    final now = DateTime.now();
    final borrowDateOnly = DateTime(now.year, now.month, now.day);
    final dueDateOnly = borrowDateOnly.add(const Duration(days: 14));

    final loan = Loan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      studentId: studentId,
      borrowDate: borrowDateOnly,
      dueDate: dueDateOnly,
    );

    _loans.add(loan);
    _simulatedDate = borrowDateOnly;
    notifyListeners();
    return true;
  }

  void returnBook(String loanId) {
    final loanIndex = _loans.indexWhere((l) => l.id == loanId);
    if (loanIndex == -1) return;

    final loan = _loans[loanIndex];
    loan.returnDate = _simulatedDate;

    final bookIndex = _books.indexWhere((b) => b.id == loan.bookId);
    if (bookIndex != -1) {
      _books[bookIndex].status = BookStatus.available;
    }

    notifyListeners();
  }

  double getOverdueFine(Loan loan, {DateTime? checkDate}) {
    final current = checkDate ?? _simulatedDate;
    final currentDateOnly = DateTime(current.year, current.month, current.day);
    final dueDateOnly = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);

    if (currentDateOnly.isBefore(dueDateOnly) || currentDateOnly.isAtSameMomentAs(dueDateOnly)) {
      return 0.0;
    }

    final differenceInDays = currentDateOnly.difference(dueDateOnly).inDays;
    final completedWeeks = differenceInDays ~/ 7;

    return completedWeeks * weeklyFineRate;
  }

  double getReplacementCost(Loan loan, {DateTime? checkDate}) {
    final current = checkDate ?? _simulatedDate;
    final currentDateOnly = DateTime(current.year, current.month, current.day);
    final dueDateOnly = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);

    final sixMonthsAfterDue = DateTime(dueDateOnly.year, dueDateOnly.month + 6, dueDateOnly.day);

    if (currentDateOnly.isAfter(sixMonthsAfterDue) || currentDateOnly.isAtSameMomentAs(sixMonthsAfterDue)) {
      final bookIndex = _books.indexWhere((b) => b.id == loan.bookId);
      if (bookIndex != -1) {
        _books[bookIndex].status = BookStatus.missing;
        return _books[bookIndex].replacementPrice;
      }
    }
    return 0.0;
  }

  double calculateFine(Loan loan, {DateTime? checkDate}) {
    return getOverdueFine(loan, checkDate: checkDate) + getReplacementCost(loan, checkDate: checkDate);
  }

  double get totalActiveFines {
    return activeLoans.fold(0.0, (sum, loan) => sum + calculateFine(loan));
  }
}