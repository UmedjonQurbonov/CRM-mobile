import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/scanner_cubit.dart';
import '../bloc/scanner_state.dart';
import '../widgets/product_form_sheet.dart';

/// Full-screen camera scanner for QR and barcodes using MobileScanner.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        context.read<ScannerCubit>().onBarcodeDetected(code.trim());
        break;
      }
    }
  }

  void _toggleTorch() async {
    await _scannerController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isOwner = authState is Authenticated && authState.user.isOwner;

    return BlocConsumer<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          _showProductFoundSheet(context, state.product, isOwner);
        } else if (state is ScannerNotFound) {
          _showProductNotFoundDialog(context, state.code, state.message, isOwner);
        } else if (state is ScannerError) {
          _showErrorDialog(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera View
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),

              // 2. Viewfinder Overlay
              CustomPaint(
                painter: _ScannerOverlayPainter(
                  borderColor: theme.colorScheme.primary,
                  borderRadius: 16,
                  borderLength: 32,
                  borderWidth: 4,
                  cutOutSize: 260,
                ),
              ),

              // 3. Top Controls Bar
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Назад',
                        ),
                        const Text(
                          'Сканер QR / Штрихкодов',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: _isTorchOn ? Colors.amber : Colors.white,
                          ),
                          onPressed: _toggleTorch,
                          tooltip: 'Фонарик',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Instructions / Hint at bottom
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        state is ScannerLoading
                            ? 'Поиск товара в каталоге...'
                            : 'Наведите камеру на QR или штрихкод',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Loading overlay when searching
              if (state is ScannerLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Поиск кода: ${state.code}...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showProductFoundSheet(
    BuildContext parentContext,
    ProductEntity product,
    bool isOwner,
  ) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${product.sku}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        if (product.qrCode.isNotEmpty)
                          Text(
                            'Штрихкод: ${product.qrCode}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Pricing & Stock details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Selling Price (ALWAYS visible for both owner and seller)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Цена продажи',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.sellingPrice.toStringAsFixed(2)} TJS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Cost Price (CRITICAL: Strictly ONLY for Owner! Never shown for Seller)
                  if (isOwner)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Себестоимость',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${product.costPrice.toStringAsFixed(2)} TJS',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withAlpha(200),
                          ),
                        ),
                      ],
                    ),

                  // Stock Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Остаток',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: product.isLowStock
                              ? Colors.red.withAlpha(30)
                              : Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.stockQuantity} шт.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: product.isLowStock
                                ? Colors.red
                                : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        parentContext.read<ScannerCubit>().resetScanner();
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Сканировать еще'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        Navigator.of(parentContext).pop(product);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Выбрать'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        context.read<ScannerCubit>().resetScanner();
      }
    });
  }

  void _showProductNotFoundDialog(
    BuildContext parentContext,
    String code,
    String message,
    bool isOwner,
  ) {
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          icon: const Icon(
            Icons.search_off_rounded,
            color: Colors.orange,
            size: 44,
          ),
          title: const Text('Товар не найден'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Код: $code',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                parentContext.read<ScannerCubit>().resetScanner();
              },
              child: const Text('Сканировать снова'),
            ),
            if (isOwner)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  parentContext.read<ScannerCubit>().resetScanner();
                  showModalBottomSheet<void>(
                    context: parentContext,
                    isScrollControlled: true,
                    builder: (sheetContext) => ProductFormSheet(
                      initialQrCode: code,
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Создать товар'),
              ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext parentContext, String message) {
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 44,
        ),
        title: const Text('Ошибка сканирования'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              parentContext.read<ScannerCubit>().resetScanner();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering a viewfinder overlay with transparent cutout and corner borders.
class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withAlpha(140)
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw background mask with cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corners
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = cutOutRect.left;
    final top = cutOutRect.top;
    final right = cutOutRect.right;
    final bottom = cutOutRect.bottom;

    // Top-left
    canvas.drawLine(
      Offset(left, top + borderLength),
      Offset(left, top + borderRadius),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left, top, borderRadius * 2, borderRadius * 2),
      3.14159,
      1.57079,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, top),
      Offset(left + borderLength, top),
      borderPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(right - borderLength, top),
      Offset(right - borderRadius, top),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        right - borderRadius * 2,
        top,
        borderRadius * 2,
        borderRadius * 2,
      ),
      -1.57079,
      1.57079,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(right, top + borderRadius),
      Offset(right, top + borderLength),
      borderPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, bottom - borderLength),
      Offset(left, bottom - borderRadius),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        left,
        bottom - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      1.57079,
      1.57079,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, bottom),
      Offset(left + borderLength, bottom),
      borderPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(right - borderLength, bottom),
      Offset(right - borderRadius, bottom),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        right - borderRadius * 2,
        bottom - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      0,
      1.57079,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(right, bottom - borderRadius),
      Offset(right, bottom - borderLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
