import 'package:equatable/equatable.dart';

import 'habit_schedule.dart';

export 'habit_schedule.dart';

/// Тип привычки — определяет, как её отмечать и как называть значения.
enum HabitKind {
  /// Полезное действие: ✔ — выполнил, ✘ — не выполнил.
  positive,

  /// Отказ от вредного (зависимость): ✔ — удержался, ✘ — сорвался.
  quit,

  /// Числовая: повторения, минуты, страницы. Число > 0 — выполнено.
  numeric,
}

/// Набор иконок, которые можно выбрать для привычки.
/// Модель не зависит от Flutter, поэтому храним только ключ,
/// а саму `IconData` подбираем в слое UI (см. `widgets/habit_visuals.dart`).
enum HabitIcon {
  check,
  water,
  run,
  book,
  code,
  language,
  math,
  meditation,
  sleep,
  music,
  science,
  art,
  gym,
  walk,
  food,
  noSmoking,
  phone,
  money,
}

/// Привычка — сущность доменного слоя (только настройки, без истории).
///
/// История отметок хранится отдельно — записями `HabitEntry`
/// (см. `habit_entry.dart`), а считается в `HabitHistory`.
///
/// Неизменяемый (immutable) класс: любое изменение создаёт копию через
/// [copyWith]. `Equatable` сравнивает объекты по значению полей,
/// это нужно BLoC, чтобы понять, изменилось ли состояние.
class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.categoryId,
    this.kind = HabitKind.positive,
    this.icon = HabitIcon.check,
    this.colorValue = 0xFF00897B,
    this.unit,
    this.target,
    this.schedule = const HabitSchedule.daily(),
    this.reminderMinutes,
    this.archived = false,
    this.placeId,
  });

  final String id;
  final String title;
  final String description;

  /// Категория (`null` — «Без категории»).
  final String? categoryId;
  final HabitKind kind;
  final HabitIcon icon;

  /// Цвет в формате ARGB (например, 0xFF00897B).
  final int colorValue;

  /// Единица измерения для числовой привычки («мин», «стр.», «раз»).
  final String? unit;

  /// Необязательная цель на день для числовой привычки (например, 30 минут).
  final double? target;

  final HabitSchedule schedule;

  /// Время напоминания в минутах от начала суток (например, 9:30 → 570).
  final int? reminderMinutes;

  /// Архивная привычка не показывается на «Сегодня», но история сохраняется.
  final bool archived;

  /// Место, к которому привязана привычка (неделя 9).
  final String? placeId;

  final DateTime createdAt;

  bool get isNumeric => kind == HabitKind.numeric;

  bool isScheduledOn(DateTime day) => schedule.isScheduledOn(day);

  Habit copyWith({
    String? title,
    String? description,
    String? Function()? categoryId,
    HabitKind? kind,
    HabitIcon? icon,
    int? colorValue,
    String? Function()? unit,
    double? Function()? target,
    HabitSchedule? schedule,
    int? Function()? reminderMinutes,
    bool? archived,
    String? Function()? placeId,
  }) {
    // Для nullable-полей используется функция: так можно отличить
    // «не менять» (параметр не передан) от «сбросить в null» (() => null).
    return Habit(
      id: id,
      createdAt: createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      unit: unit != null ? unit() : this.unit,
      target: target != null ? target() : this.target,
      schedule: schedule ?? this.schedule,
      reminderMinutes: reminderMinutes != null
          ? reminderMinutes()
          : this.reminderMinutes,
      archived: archived ?? this.archived,
      placeId: placeId != null ? placeId() : this.placeId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categoryId,
    kind,
    icon,
    colorValue,
    unit,
    target,
    schedule,
    reminderMinutes,
    archived,
    placeId,
    createdAt,
  ];
}
