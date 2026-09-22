import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/pos_checkout/presentation/bloc/cart_bloc.dart';
import 'features/pos_checkout/presentation/bloc/checkout_bloc.dart';

/// Main application widget configuring router and global providers.
class CrmApp extends StatelessWidget {
  const CrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<CartBloc>.value(
          value: sl<CartBloc>(),
        ),
        BlocProvider<CheckoutBloc>(
          create: (_) => sl<CheckoutBloc>(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => sl<OrdersBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Retail POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
        ),
        routerConfig: sl<AppRouter>().router,
      ),
    );
  }
}
