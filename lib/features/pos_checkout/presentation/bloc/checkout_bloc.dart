import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/repositories/orders_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

/// BLoC handling checkout transaction requests and response states.
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final OrdersRepository ordersRepository;

  CheckoutBloc({required this.ordersRepository})
      : super(const CheckoutInitial()) {
    on<CheckoutSubmitted>(_onCheckoutSubmitted);
    on<CheckoutReset>(_onCheckoutReset);
  }

  Future<void> _onCheckoutSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.items.isEmpty) {
      emit(const CheckoutFailure('Корзина пуста. Добавьте товары для продажи.'));
      return;
    }

    emit(const CheckoutLoading());

    try {
      final order = await ordersRepository.checkout(
        items: event.items,
        paymentMethod: event.paymentMethod,
      );
      emit(CheckoutSuccess(order));
    } on Failure catch (failure) {
      emit(CheckoutFailure(failure.message, code: failure.code));
    } catch (e) {
      emit(CheckoutFailure(e.toString()));
    }
  }

  void _onCheckoutReset(CheckoutReset event, Emitter<CheckoutState> emit) {
    emit(const CheckoutInitial());
  }
}
