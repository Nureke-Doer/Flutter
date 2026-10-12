# Неделя 3. Управление состоянием: setState → InheritedWidget → Provider

**Ключевая функция:** отметка выполнения цели за день, создание,
редактирование и удаление целей. Она меняет данные сразу на нескольких экранах:
«Сегодня» (прогресс дня), «Детали» (серия, календарь), «Статистика».

Функция реализована три раза, каждый шаг — отдельный коммит:

| Шаг | Коммит | Где хранится состояние |
|---|---|---|
| 1. `setState` | `0e10ac5` | `_HomeShellState` + локальная копия в `_HabitDetailScreenState` |
| 2. `InheritedWidget` | `3f36df5` | `HabitsScopeState` над `MaterialApp` |
| 3. `Provider` | коммит «Неделя 3 (шаг 3)» | `HabitsNotifier extends ChangeNotifier` |

Посмотреть код любого шага: `git show 0e10ac5:lib/screens/home_shell.dart`.

---

## Шаг 1. setState

```dart
class _HomeShellState extends State<HomeShell> {
  List<Habit> _habits = buildMockHabits();

  void _toggle(Habit habit, DateTime day) {
    setState(() {
      _habits = [for (final h in _habits) h.id == habit.id ? h.toggleDay(day) : h];
    });
  }
  // ...
  TodayScreen(habits: _habits, onToggle: _toggle, onSave: _save, onDelete: _delete)
}
```

Экран «Сегодня» сам эти колбэки не использует целиком — он передаёт их
дальше в `HabitDetailScreen`. А экран деталей вынужден держать **копию**
цели и обновлять её вручную, иначе после отметки он покажет старые данные:

```dart
class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit = widget.habit;

  void _toggleToday() {
    widget.onToggle(_habit, today);                     // меняем «главный» список
    setState(() => _habit = _habit.toggleDay(today));   // и свою копию
  }
}
```

## Шаг 2. InheritedWidget

```dart
class HabitsScope extends StatefulWidget {
  static HabitsScopeState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HabitsInherited>()!.state;
  static HabitsScopeState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HabitsInherited>()!.state;
}

class _HabitsInherited extends InheritedWidget {
  @override
  bool updateShouldNotify(_HabitsInherited old) => !identical(habits, old.habits);
}
```

Экран деталей теперь получает только `habitId`:

```dart
final scope = HabitsScope.of(context);
final habit = scope.byId(habitId);
```

## Шаг 3. Provider

```dart
class HabitsNotifier extends ChangeNotifier {
  void toggle(String id, DateTime day) {
    _habits = [for (final h in _habits) h.id == id ? h.toggleDay(day) : h];
    notifyListeners();
  }
}

// app.dart
ChangeNotifierProvider(create: (_) => HabitsNotifier(), child: MaterialApp(...));

// экраны
final notifier = context.watch<HabitsNotifier>();                    // подписка
context.read<HabitsNotifier>().save(habit);                           // без подписки
final habit = context.select<HabitsNotifier, Habit?>((n) => n.byId(id)); // подписка на часть
```

---

## Сравнение

| | setState | InheritedWidget | Provider |
|---|---|---|---|
| **Сколько кода** | Минимум | Много шаблонного кода (2 класса, `of`, `updateShouldNotify`) | Мало: один `ChangeNotifier` + `ChangeNotifierProvider` |
| **Доступ из глубины дерева** | Только через параметры конструкторов (prop drilling) | `X.of(context)` из любого места | `context.watch/read/select` из любого места |
| **Перестроение** | Весь `State` и его поддерево | Все зависимые виджеты | Все слушатели; `select` — только при изменении нужной части |
| **Тестирование логики** | Логика внутри виджета — только widget-тесты | Логика внутри `State` — только widget-тесты | `ChangeNotifier` — обычный класс, unit-тесты без UI |
| **Отделение логики от UI** | Нет | Частично | Да |
| **Зависимости** | Нет | Нет (встроено во Flutter) | Пакет `provider` |
| **Типичные ошибки** | Забыть синхронизировать копии данных | Вызвать `of` в `initState`, забыть `updateShouldNotify` | `watch` внутри обработчика нажатия, забыть `notifyListeners()` |

### Когда что применять

- **setState** — локальное состояние одного виджета, которое не нужно другим
  экранам: открытая вкладка, состояние формы, анимация, выбранный чип.
  В приложении так и осталось: `HomeShell` (индекс вкладки), `HabitEditScreen` (форма).
- **InheritedWidget** — когда нужно раздать неизменяемые или редко меняющиеся
  данные без сторонних пакетов (так устроены `Theme.of`, `MediaQuery.of`).
  Для изменяемого состояния приложения писать его вручную неудобно.
- **Provider** — простое общее состояние нескольких экранов: настройки, тема,
  корзина, список избранного. Это обёртка над InheritedWidget, которая
  убирает шаблонный код.

**Вывод:** для ключевой функции выбран Provider. На неделе 4 основная логика
переедет на BLoC (сложные сценарии: загрузка, ошибки, события), а Provider
останется для простых вещей — настроек и темы.
