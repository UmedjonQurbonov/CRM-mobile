import 'package:decimal/decimal.dart';

/// Request body mapping to `http.UpdateCommissionRequest`.
class UpdateCommissionRequestModel {
  final double commissionRate;

  const UpdateCommissionRequestModel({required this.commissionRate});

  factory UpdateCommissionRequestModel.fromDecimal(Decimal rate) {
    return UpdateCommissionRequestModel(
      commissionRate: rate.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commission_rate': commissionRate,
    };
  }
}
