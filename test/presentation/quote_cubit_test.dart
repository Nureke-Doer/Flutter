import 'package:bloc_test/bloc_test.dart';
import 'package:habit_study_tracker/domain/entities/quote.dart';
import 'package:habit_study_tracker/presentation/blocs/quote/quote_cubit.dart';

import '../helpers/fakes.dart';

void main() {
  const quote = Quote(text: 'T', author: 'A');

  blocTest<QuoteCubit, QuoteState>(
    'load: loading → success',
    build: () => QuoteCubit(repository: FakeMaterialsRepository(quote: quote)),
    act: (cubit) => cubit.load(),
    expect: () => [
      const QuoteState(status: QuoteStatus.loading),
      const QuoteState(status: QuoteStatus.success, quote: quote),
    ],
  );

  blocTest<QuoteCubit, QuoteState>(
    'load: ошибка сети → failure',
    build: () =>
        QuoteCubit(repository: FakeMaterialsRepository()..quote = null),
    act: (cubit) => cubit.load(),
    expect: () => [
      const QuoteState(status: QuoteStatus.loading),
      const QuoteState(status: QuoteStatus.failure),
    ],
  );
}
