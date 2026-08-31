// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/auth_form_screen.dart';
import '../../features/auth/change_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/experiences/experience_detail_screen.dart';

import '../../features/discounts/discounts_info_screen.dart';
import '../../features/catalogue/product_detail_screen.dart';
import '../../features/catalogue/data/sample_products.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/favourites/favourites_screen.dart';
import '../../features/catalogue/food_menu_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/orders/recent_orders_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/services/service_booking_screen.dart';
import '../../features/address/saved_addresses_screen.dart';
import '../../features/address/add_address_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({super.key, required this.child, required this.currentIndex});

  static const _routes = ['/home', '/cart', '/orders', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_routes[i]),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ── Auth & Special Screens (no bottom shell) ─────────────────
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const AuthFormScreen(
        title: 'Forgot Password',
        subtitle: 'Enter your email or phone to receive a verification code.',
        fields: [
          AuthField(key: 'email', label: 'Email or Phone Number', placeholder: 'name@example.com or phone'),
        ],
        buttonLabel: 'Send Verification Code',
        backRoute: '/login',
        nextRoute: '/login',
      ),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const AuthFormScreen(
        title: 'Reset Password',
        subtitle: 'Enter the code and your new password.',
        fields: [
          AuthField(key: 'code', label: 'Verification Code', placeholder: '123456'),
          AuthField(key: 'pw', label: 'New Password', placeholder: '-------', isPassword: true),
          AuthField(key: 'pw2', label: 'Confirm New Password', placeholder: '-------', isPassword: true),
        ],
        buttonLabel: 'Reset Password',
        backRoute: '/login',
        nextRoute: '/login',
      ),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (_, __) => const AuthFormScreen(
        title: 'Verify Email',
        subtitle: 'Check your inbox and enter the code.',
        fields: [
          AuthField(key: 'email', label: 'Email Address', placeholder: 'name@example.com'),
          AuthField(key: 'code', label: 'Verification Code', placeholder: '123456'),
        ],
        buttonLabel: 'Verify Account',
        backRoute: '/login',
        nextRoute: '/login',
      ),
    ),
    GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
    GoRoute(path: '/order-success', builder: (_, __) => const OrderSuccessScreen()),
    GoRoute(path: '/orders', builder: (_, __) => const RecentOrdersScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/addresses', builder: (_, __) => const SavedAddressesScreen()),
    GoRoute(path: '/add-address', builder: (_, __) => const AddAddressScreen()),

    // ── Experience & Services Routes ──────────────────────────────
    GoRoute(
      path: '/experience/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExperienceDetailScreen(experienceId: id);
      },
    ),
    GoRoute(path: '/service-booking', builder: (_, __) => const ServiceBookingScreen()),
    GoRoute(path: '/discounts', builder: (_, __) => const DiscountsInfoScreen()),
    GoRoute(path: '/food-menu', builder: (_, __) => const FoodMenuScreen()),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/favourites', builder: (_, __) => const FavouritesScreen()),

    // ── Product Detail ────────────────────────────────────────────
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final product = kSampleProducts.firstWhere(
          (p) => p.id == id,
          orElse: () => kSampleProducts.first,
        );
        return ProductDetailScreen(product: product);
      },
    ),

    // ── Shell (bottom nav) ────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        final routes = ['/home', '/cart', '/orders', '/profile'];
        final idx = routes.indexWhere((r) => state.fullPath?.startsWith(r) ?? false);
        return AppShell(child: child, currentIndex: idx < 0 ? 0 : idx);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const RecentOrdersScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);
