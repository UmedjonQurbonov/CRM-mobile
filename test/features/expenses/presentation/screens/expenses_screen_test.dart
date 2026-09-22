import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/expenses/domain/entities/expense_entity.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:crm_mobile/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpensesBloc extends MockBloc<ExpensesEvent, ExpensesState>
    implements ExpensesBloc {}

void main() {
  late MockExpensesBloc mockExpensesBloc;

  final testExpense = ExpenseEntity(
    id: 'exp-101',
    amount: Decimal.parse('750.00'),
    category: 'utilities',
    comment: 'Electricity and heating',
    expenseDate: DateTime(2026, 9, 22),
  );

  setUp(() {
    mockExpensesBloc = MockExpensesBloc();
  });

  Widget buildTestWidget({ExpensesState? state}) {
    when(() => mockExpensesBloc.state).thenReturn(
      state ??
          ExpensesLoaded(
            expenses: [testExpense],
            total: 1,
            offset: 0,
            hasMore: false,
          ),
    );

    return MaterialApp(
      home: BlocProvider<ExpensesBloc>.value(
        value: mockExpensesBloc,
        child: const ExpensesScreen(),
      ),
    );
  }

  group('ExpensesScreen Widget Tests', () {
    testWidgets('renders summary banner with total sum and entries count', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Операционные расходы'), findsOneWidget);
      expect(find.text('Суммарные расходы'), findsOneWidget);
      expect(find.text('750 TJS'), findsOneWidget);
      expect(find.text('1 записей'), findsOneWidget);

      // Card contents
      expect(find.text('Коммунальные услуги'), findsOneWidget);
      expect(find.text('Electricity and heating'), findsOneWidget);
      expect(find.text('-750.00 TJS'), findsOneWidget);
    });

    testWidgets('tapping delete button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pump();

      expect(find.text('Удалить расход?'), findsOneWidget);
      expect(
        find.textContaining('удалить расход на сумму 750.00 TJS'),
        findsOneWidget,
      );
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('tapping FAB opens ExpenseFormSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final fab = find.text('Новый расход');
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Сумма расхода (TJS) *'), findsOneWidget);
      expect(find.text('Записать расход'), findsOneWidget);
    });
  });
}
