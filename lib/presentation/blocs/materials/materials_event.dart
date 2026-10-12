part of 'materials_bloc.dart';

sealed class MaterialsEvent extends Equatable {
  const MaterialsEvent();

  @override
  List<Object?> get props => [];
}

/// Пользователь изменил текст поиска (обрабатывается с debounce).
final class MaterialsQueryChanged extends MaterialsEvent {
  const MaterialsQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Пользователь долистал до конца списка — загрузить следующую страницу.
final class MaterialsNextPageRequested extends MaterialsEvent {
  const MaterialsNextPageRequested();
}

/// Pull-to-refresh или кнопка «Повторить».
final class MaterialsRefreshed extends MaterialsEvent {
  const MaterialsRefreshed();
}
