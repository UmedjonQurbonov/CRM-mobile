import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/expenses/domain/entities/create_expense_params.dart';
import 'package:crm_mobile/features/expenses/domain/entities/expense_entity.dart';
import 'package:crm_mobile/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_event.dart';
import 'package:crm_mobile/features/expenses/presentation/bloc/expenses_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpensesRepository extends Mock implements ExpensesRepository {}

class FakeCreateExpenseParams extends Fake implements CreateExpenseParams {}

void main() {
  late MockExpensesRepository mockExpensesRepository;
  late ExpensesBloc expensesBloc;

  final sampleExpense = ExpenseEntity(
    id: 'exp-1',
    amount: Decimal.parse('400.00'),
    category: 'utilities',
    comment: 'Electricity',
    expenseDate: DateTime(2026, 9, 20),
  );

  final sampleExpense2 = ExpenseEntity(
    id: 'exp-2',
    amount: Decimal.parse('600.00'),
    category: 'rent',
    comment: 'Office rent',
    expenseDate: DateTime(2026, 9, 21),
  );

  final sampleListEntity = ExpenseListEntity(
    items: [sampleExpense, sampleExpense2],
    total: 2,
    limit: 20,
    offset: 0,
    hasMore: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateExpenseParams());
  });

  setUp(() {
    mockExpensesRepository = MockExpensesRepository();
    expensesBloc = ExpensesBloc(expensesRepository: mockExpensesRepository);
  });

  tearDown(() {
    expensesBloc.close();
  });

  group('ExpensesBloc Fetching & State Lifecycle', () {
    test('initial state is ExpensesInitial', () {
      expect(expensesBloc.state, const ExpensesInitial());
    });

    blocTest<ExpensesBloc, ExpensesState>(
      'emits [ExpensesLoading, ExpensesLoaded] with exact Decimal period sum on ExpensesFetchRequested',
      build: () {
        when(
          () => mockExpensesRepository.getExpenses(
            category: any(named: 'category'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleListEntity);
        return expensesBloc;
      },
      act: (bloc) => bloc.add(const ExpensesFetchRequested()),
      expect: () => [
        const ExpensesLoading(isFirstFetch: true),
        isA<ExpensesLoaded>()
            .having((s) => s.expenses.length, 'expenses length', 2)
            .having(
              (s) => s.totalAmountForPeriod,
              'period total sum (400 + 600)',
              Decimal.parse('1000.00'),
            ),
      ],
    );

    blocTest<ExpensesBloc, ExpensesState>(
      'emits [ExpensesLoading, ExpensesFailure] when getExpenses fails',
      build: () {
        when(
          () => mockExpensesRepository.getExpenses(
            category: any(named: 'category'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const ServerFailure('Network error'));
        return expensesBloc;
      },
      act: (bloc) => bloc.add(const ExpensesFetchRequested()),
      expect: () => [
        const ExpensesLoading(isFirstFetch: true),
        isA<ExpensesFailure>(),
      ],
    );
  });

  group('ExpensesBloc Mutations (Create & Delete)', () {
    final createParams = CreateExpenseParams(
      amount: Decimal.parse('250.00'),
      category: 'supplies',
      comment: 'Paper and pens',
      expenseDate: DateTime(2026, 9, 22),
    );

    blocTest<ExpensesBloc, ExpensesState>(
      'creates expense and re-fetches list on ExpenseCreateSubmitted',
      build: () {
        when(() => mockExpensesRepository.createExpense(any()))
            .thenAnswer((_) async => sampleExpense);
        when(
          () => mockExpensesRepository.getExpenses(
            category: any(named: 'category'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleListEntity);
        return expensesBloc;
      },
      act: (bloc) => bloc.add(ExpenseCreateSubmitted(createParams)),
      verify: (_) {
        verify(() => mockExpensesRepository.createExpense(createParams)).called(1);
        verify(
          () => mockExpensesRepository.getExpenses(
            category: any(named: 'category'),
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
      },
    );

    blocTest<ExpensesBloc, ExpensesState>(
      'deletes expense and emits updated ExpensesLoaded with actionFeedback on ExpenseDeleteSubmitted',
      build: () {
        when(() => mockExpensesRepository.deleteExpense('exp-1'))
            .thenAnswer((_) async {});
        return expensesBloc;
      },
      seed: () => ExpensesLoaded(
        expenses: [sampleExpense, sampleExpense2],
        total: 2,
        offset: 0,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const ExpenseDeleteSubmitted('exp-1')),
      expect: () => [
        isA<ExpensesLoaded>()
            .having((s) => s.expenses.length, 'remaining count', 1)
            .having((s) => s.expenses.first.id, 'remaining id', 'exp-2')
            .having(
              (s) => s.totalAmountForPeriod,
              'new total amount',
              Decimal.parse('600.00'),
            )
            .having((s) => s.actionFeedback, 'feedback', 'Расход успешно удален'),
      ],
      verify: (_) {
        verify(() => mockExpensesRepository.deleteExpense('exp-1')).called(1);
      },
    );
  });
}
