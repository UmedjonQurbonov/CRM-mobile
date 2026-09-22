import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/product_repository.dart';
import 'scanner_state.dart';

/// Cubit managing camera QR scanning lifecycle and fast product lookup.
class ScannerCubit extends Cubit<ScannerState> {
  final ProductRepository productRepository;
  String? _lastScannedCode;

  ScannerCubit({required this.productRepository})
      : super(const ScannerScanning());

  /// Handles incoming barcode from MobileScanner.
  Future<void> onBarcodeDetected(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return;

    // Prevent duplicate triggers while processing
    if (state is ScannerLoading || (state is ScannerSuccess && _lastScannedCode == code)) {
      return;
    }

    _lastScannedCode = code;
    emit(ScannerLoading(code));

    try {
      final product = await productRepository.getProductByQr(code);
      emit(ScannerSuccess(product));
    } on Failure catch (failure) {
      if (failure.code == 'NOT_FOUND' ||
          failure.code == 'HTTP_404' ||
          failure.message.toLowerCase().contains('not found')) {
        emit(
          ScannerNotFound(
            code,
            'Товар со штрихкодом "$code" не найден в номенклатуре.',
          ),
        );
      } else {
        emit(ScannerError(failure.message));
      }
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  /// Resets the scanner to resume viewfinder scanning.
  void resetScanner() {
    _lastScannedCode = null;
    emit(const ScannerScanning());
  }
}
