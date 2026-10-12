import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/quote.dart';
import '../../../domain/repositories/materials_repository.dart';

enum QuoteStatus { initial, loading, success, failure }

final class QuoteState extends Equatable {
  const QuoteState({this.status = QuoteStatus.initial, this.quote});

  final QuoteStatus status;
  final Quote? quote;

  @override
  List<Object?> get props => [status, quote];
}

/// Cubit — упрощённый BLoC без событий: UI вызывает методы напрямую.
/// Подходит для простой логики «загрузить цитату дня».
class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit({required MaterialsRepository repository})
    : _repository = repository,
      super(const QuoteState());

  final MaterialsRepository _repository;

  Future<void> load() async {
    emit(QuoteState(status: QuoteStatus.loading, quote: state.quote));
    try {
      final quote = await _repository.getRandomQuote();
      emit(QuoteState(status: QuoteStatus.success, quote: quote));
    } on Failure {
      emit(QuoteState(status: QuoteStatus.failure, quote: state.quote));
    }
  }
}
