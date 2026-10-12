// Неделя 1. Задача 2 — Классы, наследование, абстракции, enum.
// Запуск: dart run dart_tasks/task2_classes.dart

enum Frequency { daily, weekly }

/// Абстрактная цель: у любой цели есть название и способ посчитать прогресс.
abstract class Goal {
  Goal(this.title);

  final String title;

  /// Прогресс от 0.0 до 1.0.
  double get progress;

  @override
  String toString() => '$title: ${(progress * 100).toStringAsFixed(0)}%';
}

/// Привычка: нужно отметить выполнение N раз.
class HabitGoal extends Goal {
  HabitGoal(
    super.title, {
    required this.target,
    this.frequency = Frequency.daily,
  });

  final int target;
  final Frequency frequency;
  int _done = 0;

  int get done => _done;

  void markDone() {
    if (_done < target) _done++;
  }

  @override
  double get progress => target == 0 ? 0 : _done / target;
}

/// Учебная цель: нужно набрать N минут учёбы.
class StudyGoal extends Goal {
  StudyGoal(super.title, {required this.targetMinutes});

  final int targetMinutes;
  int minutesSpent = 0;

  void addMinutes(int minutes) {
    if (minutes <= 0) throw ArgumentError.value(minutes, 'minutes');
    minutesSpent += minutes;
  }

  @override
  double get progress => (minutesSpent / targetMinutes).clamp(0, 1).toDouble();
}

/// Миксин — переиспользуемое поведение без наследования.
mixin Describable on Goal {
  String describe() => 'Цель «$title», выполнено ${(progress * 100).round()}%';
}

class DescribedHabit extends HabitGoal with Describable {
  DescribedHabit(super.title, {required super.target});
}

void main() {
  final water = HabitGoal('Пить воду', target: 8);
  for (var i = 0; i < 5; i++) {
    water.markDone();
  }

  final dart = StudyGoal('Изучить Dart', targetMinutes: 120)..addMinutes(90);

  final goals = <Goal>[water, dart];
  goals.forEach(print);

  final reading = DescribedHabit('Читать 20 страниц', target: 1)..markDone();
  print(reading.describe());
}
