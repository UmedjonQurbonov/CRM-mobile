import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/sellers/domain/entities/seller_entity.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_bloc.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_event.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_state.dart';
import 'package:crm_mobile/features/sellers/presentation/screens/sellers_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSellersBloc extends MockBloc<SellersEvent, SellersState>
    implements SellersBloc {}

void main() {
  late MockSellersBloc mockSellersBloc;

  final sampleSeller = SellerEntity(
    id: 's-10',
    name: 'Alisher Qodirov',
    phone: '+992901234567',
    role: 'seller',
    commissionRate: Decimal.parse('7.50'),
  );

  setUp(() {
    mockSellersBloc = MockSellersBloc();
  });

  Widget buildTestWidget({SellersState? state}) {
    when(() => mockSellersBloc.state).thenReturn(
      state ?? SellersLoaded([sampleSeller]),
    );

    return MaterialApp(
      home: BlocProvider<SellersBloc>.value(
        value: mockSellersBloc,
        child: const SellersScreen(),
      ),
    );
  }

  group('SellersScreen Widget Tests', () {
    testWidgets('renders seller list with name, phone, and commission badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Управление Продавцами'), findsOneWidget);
      expect(find.text('Alisher Qodirov'), findsOneWidget);
      expect(find.text('+992901234567'), findsOneWidget);
      expect(find.text('7.50%'), findsOneWidget);
      expect(find.text('Изменить'), findsOneWidget);
      expect(find.text('Новый продавец'), findsOneWidget);
    });

    testWidgets('tapping "Изменить" opens UpdateCommissionSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final editBtn = find.text('Изменить');
      expect(editBtn, findsOneWidget);

      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ставка комиссии продавца'), findsOneWidget);
      expect(find.text('Alisher Qodirov'), findsWidgets);
      expect(find.text('Сохранить ставку'), findsOneWidget);
    });

    testWidgets('tapping FAB opens CreateSellerSheet with phone validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final fab = find.text('Новый продавец');
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('ФИО сотрудника *'), findsOneWidget);
      expect(find.text('Номер телефона (+992...) *'), findsOneWidget);
      expect(find.text('Пароль для входа *'), findsOneWidget);
      expect(find.text('Стартовая комиссия:'), findsOneWidget);
      expect(find.text('Зарегистрировать продавца'), findsOneWidget);

      // Tap submit with empty name -> trigger validation
      await tester.tap(find.text('Зарегистрировать продавца'));
      await tester.pump();

      expect(find.text('Введите имя сотрудника'), findsOneWidget);
    });
  });
}
