import 'package:equatable/equatable.dart';

/// Мотивационная цитата.
class Quote extends Equatable {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;

  @override
  List<Object?> get props => [text, author];
}
