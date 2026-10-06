import 'category.dart';

class Book {
  String title;
  String author;
  BookCategory? category;

  Book({required this.title, required this.author, this.category});
}
