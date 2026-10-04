import 'package:activity/core/theme.dart';
import 'package:activity/feature/auth/login_page.dart';
import 'package:activity/feature/shell/main_shell.dart';
import 'package:activity/firebase_options.dart';
import 'package:activity/providers/auth_provider.dart';
import 'package:activity/providers/cart_provider.dart';
import 'package:activity/providers/catalog_providers.dart';
import 'package:activity/providers/nav_provider.dart';
import 'package:activity/providers/notification_provider.dart';
import 'package:activity/providers/order_provider.dart';
import 'package:activity/providers/ticket_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        // Provider ທີ່ຂຶ້ນກັບຜູ້ໃຊ້: ເມື່ອ login/logout ຈະ bindUser(uid) ໃໝ່ອັດຕະໂນມັດ
        ChangeNotifierProxyProvider<AppAuthProvider, CategoryProvider>(
          lazy: false,
          create: (_) => CategoryProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, ProductProvider>(
          lazy: false,
          create: (_) => ProductProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, CartProvider>(
          lazy: false,
          create: (_) => CartProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, OrderProvider>(
          lazy: false,
          create: (_) => OrderProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, TicketProvider>(
          lazy: false,
          create: (_) => TicketProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, NotificationProvider>(
          lazy: false,
          create: (_) => NotificationProvider(),
          update: (_, auth, p) => p!..bindUser(auth.uid),
        ),
      ],
      child: MaterialApp(
        title: 'Activity',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

/// ສະແດງໜ້າ Login ຖ້າຍັງບໍ່ເຂົ້າລະບົບ, ບໍ່ດັ່ງນັ້ນສະແດງແອັບຫຼັກ
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    Widget child;
    if (auth.initializing) {
      child = const Scaffold(
        key: ValueKey('splash'),
        backgroundColor: kPrimary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    } else if (auth.isLoggedIn) {
      child = const MainShell(key: ValueKey('app'));
    } else {
      child = const LoginPage(key: ValueKey('login'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}
