import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sellers_repository.dart';
import 'sellers_event.dart';
import 'sellers_state.dart';

/// BLoC managing staff cashiers, registrations, and commission updates.
class SellersBloc extends Bloc<SellersEvent, SellersState> {
  final SellersRepository sellersRepository;

  SellersBloc({required this.sellersRepository})
      : super(const SellersInitial()) {
    on<SellersFetchRequested>(_onFetchRequested);
    on<SellerCreateSubmitted>(_onCreateSubmitted);
    on<SellerCommissionUpdateSubmitted>(_onCommissionUpdateSubmitted);
  }

  Future<void> _onFetchRequested(
    SellersFetchRequested event,
    Emitter<SellersState> emit,
  ) async {
    final currentState = state;
    if (!event.refresh && currentState is! SellersLoaded) {
      emit(const SellersLoading());
    }

    try {
      final sellers = await sellersRepository.getSellers();
      emit(SellersLoaded(sellers));
    } catch (e) {
      emit(SellersFailure('Не удалось загрузить список продавцов: $e'));
    }
  }

  Future<void> _onCreateSubmitted(
    SellerCreateSubmitted event,
    Emitter<SellersState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellersLoaded) {
      emit(currentState.copyWith(clearSuccess: true));
    }

    try {
      final newSeller = await sellersRepository.createSeller(event.params);

      if (currentState is SellersLoaded) {
        final updatedList = List.of(currentState.sellers)..add(newSeller);
        emit(
          SellersLoaded(
            updatedList,
            successMessage: 'Сотрудник ${newSeller.name} успешно зарегистрирован',
          ),
        );
      } else {
        add(const SellersFetchRequested(refresh: true));
      }
    } catch (e) {
      emit(SellersFailure('Не удалось создать продавца: $e'));
    }
  }

  Future<void> _onCommissionUpdateSubmitted(
    SellerCommissionUpdateSubmitted event,
    Emitter<SellersState> emit,
  ) async {
    final currentState = state;
    try {
      await sellersRepository.updateCommission(
        event.sellerId,
        event.newCommissionRate,
      );

      if (currentState is SellersLoaded) {
        final updatedList = currentState.sellers.map((s) {
          if (s.id == event.sellerId) {
            return s.copyWith(commissionRate: event.newCommissionRate);
          }
          return s;
        }).toList();

        emit(
          SellersLoaded(
            updatedList,
            successMessage: 'Ставка комиссии обновлена: ${event.newCommissionRate.toStringAsFixed(2)}%',
          ),
        );
      } else {
        add(const SellersFetchRequested(refresh: true));
      }
    } catch (e) {
      emit(SellersFailure('Не удалось обновить комиссию: $e'));
    }
  }
}
