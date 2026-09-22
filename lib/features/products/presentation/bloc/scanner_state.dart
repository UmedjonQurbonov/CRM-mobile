import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

/// Base state for QR camera scanner.
abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Scanner view is active and ready to read barcodes.
class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

/// Looking up scanned barcode in backend.
class ScannerLoading extends ScannerState {
  final String code;

  const ScannerLoading(this.code);

  @override
  List<Object?> get props => [code];
}

/// Product successfully found by QR code.
class ScannerSuccess extends ScannerState {
  final ProductEntity product;

  const ScannerSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

/// Product with given QR code not found (404).
class ScannerNotFound extends ScannerState {
  final String code;
  final String message;

  const ScannerNotFound(this.code, this.message);

  @override
  List<Object?> get props => [code, message];
}

/// Scanner hardware or network error.
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
