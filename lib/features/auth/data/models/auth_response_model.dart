import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Data model representing usecase.TokenPair from backend OpenAPI schema.
class TokenPairModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const TokenPairModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) {
    return TokenPairModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresIn];
}

/// Data model representing http.AuthResponse from backend OpenAPI schema.
class AuthResponseModel extends Equatable {
  final TokenPairModel tokens;
  final UserModel user;

  const AuthResponseModel({
    required this.tokens,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final tokensJson = json['tokens'] as Map<String, dynamic>? ?? {};
    final userJson = json['user'] as Map<String, dynamic>? ?? {};

    return AuthResponseModel(
      tokens: TokenPairModel.fromJson(tokensJson),
      user: UserModel.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'tokens': tokens.toJson(),
        'user': user.toJson(),
      };

  @override
  List<Object?> get props => [tokens, user];
}
