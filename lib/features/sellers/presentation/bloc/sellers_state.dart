import 'package:equatable/equatable.dart';
import '../../domain/entities/seller_entity.dart';

abstract class SellersState extends Equatable {
  const SellersState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class SellersInitial extends SellersState {
  const SellersInitial();
}

/// Loading indicator state.
class SellersLoading extends SellersState {
  final bool isSubmitting;

  const SellersLoading({this.isSubmitting = false});

  @override
  List<Object?> get props => [isSubmitting];
}

/// Loaded staff list with optional action success notification.
class SellersLoaded extends SellersState {
  final List<SellerEntity> sellers;
  final String? successMessage;

  const SellersLoaded(this.sellers, {this.successMessage});

  SellersLoaded copyWith({
    List<SellerEntity>? sellers,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SellersLoaded(
      sellers ?? this.sellers,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [sellers, successMessage];
}

/// Failure state with an error message.
class SellersFailure extends SellersState {
  final String message;

  const SellersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
