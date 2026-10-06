import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Book> _books = [];
  final List<BookCategory> _categories = [];

  List<Book> get books => _books;
  List<BookCategory> get categories => _categories;

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void editBook(
    Book book,
    String title,
    String author,
    BookCategory? category,
  ) {
    book.title = title;
    book.author = author;
    book.category = category;
    notifyListeners();
  }

  void removeBook(Book book) {
    _books.remove(book);
    notifyListeners();
  }

  void addCategory(BookCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  void editCategory(BookCategory category, String name) {
    category.name = name;
    notifyListeners();
  }

  void removeCategory(BookCategory category) {
    _categories.remove(category);
    for (final book in _books) {
      if (book.category == category) {
        book.category = null;
      }
    }
    notifyListeners();
  }
}
