import 'package:equatable/equatable.dart';

/// Учебная цель с дедлайном, например «Прочитать 300 страниц до 01.12».
///
/// Прогресс считается автоматически по привязанным привычкам
/// (см. `services/goal_progress.dart`) плюс ручная поправка [manualProgress].
class StudyGoal extends Equatable {
  const StudyGoal({
    required this.id,
    required this.title,
    required this.target,
    required this.deadline,
    required this.createdAt,
    this.description = '',
    this.unit = '',
    this.linkedHabitIds = const {},
    this.manualProgress = 0,
    this.archived = false,
    this.bookTitle,
    this.bookCoverId,
  });

  final String id;
  final String title;
  final String description;

  /// Сколько нужно сделать (например, 300).
  final double target;

  /// Единица измерения («стр.», «мин», «задач»).
  final String unit;
  final DateTime deadline;

  /// Привычки, из которых автоматически складывается прогресс.
  final Set<String> linkedHabitIds;

  /// Прогресс, добавленный вручную (например, прочитано до начала учёта).
  final double manualProgress;
  final bool archived;

  /// Книга из Open Library, если цель — прочитать книгу (неделя 5).
  final String? bookTitle;
  final int? bookCoverId;

  /// Прогресс учитывается с этой даты.
  final DateTime createdAt;

  StudyGoal copyWith({
    String? title,
    String? description,
    double? target,
    String? unit,
    DateTime? deadline,
    Set<String>? linkedHabitIds,
    double? manualProgress,
    bool? archived,
    String? Function()? bookTitle,
    int? Function()? bookCoverId,
  }) => StudyGoal(
    id: id,
    createdAt: createdAt,
    title: title ?? this.title,
    description: description ?? this.description,
    target: target ?? this.target,
    unit: unit ?? this.unit,
    deadline: deadline ?? this.deadline,
    linkedHabitIds: linkedHabitIds ?? this.linkedHabitIds,
    manualProgress: manualProgress ?? this.manualProgress,
    archived: archived ?? this.archived,
    bookTitle: bookTitle != null ? bookTitle() : this.bookTitle,
    bookCoverId: bookCoverId != null ? bookCoverId() : this.bookCoverId,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    target,
    unit,
    deadline,
    linkedHabitIds,
    manualProgress,
    archived,
    bookTitle,
    bookCoverId,
    createdAt,
  ];
}
