import 'package:equatable/equatable.dart';

/// Значение отметки привычки за один день.
///
/// `sealed`-класс: у него фиксированный набор наследников, и компилятор
/// проверяет, что `switch` по значению разобрал все варианты.
///
/// | Значение | Смысл | Серия |
/// |---|---|---|
/// | [EntryDone] ✔ | выполнил / удержался | +1 |
/// | [EntryFailed] ✘ | не выполнил / сорвался | обрывает |
/// | [EntrySkipped] 0 | пропуск (болел, выходной) | не влияет |
/// | [EntryAmount] число | для числовых привычек; > 0 — выполнено | +1, если > 0 |
/// | нет записи (пусто) | день не отмечен | не влияет |
sealed class EntryValue extends Equatable {
  const EntryValue();

  /// Разбирает значение из строки хранилища (см. [encode]).
  /// Неизвестная строка → `null` (запись игнорируется).
  static EntryValue? decode(String raw) {
    switch (raw) {
      case 'done':
        return const EntryDone();
      case 'failed':
        return const EntryFailed();
      case 'skip':
        return const EntrySkipped();
    }
    if (raw.startsWith('n:')) {
      final amount = double.tryParse(raw.substring(2));
      if (amount != null) return EntryAmount(amount);
    }
    return null;
  }

  /// Компактная строка для Hive/Firestore: `done`, `failed`, `skip`, `n:12.5`.
  String encode() => switch (this) {
    EntryDone() => 'done',
    EntryFailed() => 'failed',
    EntrySkipped() => 'skip',
    EntryAmount(:final amount) => 'n:$amount',
  };

  /// День засчитан как выполненный (✔ или число > 0).
  bool get isSuccess => switch (this) {
    EntryDone() => true,
    EntryAmount(:final amount) => amount > 0,
    _ => false,
  };

  /// День провален (✘) — только он обрывает серию.
  bool get isFailure => this is EntryFailed;

  /// Нейтральное значение: пропуск или число 0.
  bool get isNeutral => !isSuccess && !isFailure;

  /// Числовое значение для подсчёта суммы (✔ и ✘ дают 0).
  double get amount => switch (this) {
    EntryAmount(:final amount) => amount,
    _ => 0,
  };

  @override
  List<Object?> get props => [];
}

final class EntryDone extends EntryValue {
  const EntryDone();
}

final class EntryFailed extends EntryValue {
  const EntryFailed();
}

final class EntrySkipped extends EntryValue {
  const EntrySkipped();
}

final class EntryAmount extends EntryValue {
  const EntryAmount(this.amount);

  @override
  final double amount;

  @override
  List<Object?> get props => [amount];
}
