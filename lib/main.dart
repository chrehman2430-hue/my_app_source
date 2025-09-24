import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/savings_goal_provider.dart';
import 'screens/dashboard.dart';
import 'screens/transactions.dart';
import 'screens/add_transaction.dart';
import 'screens/categories.dart';
import 'screens/budget_planner.dart';
import 'screens/savings_goals.dart';
import 'screens/reports.dart';
import 'screens/settings.dart';
import 'screens/backup_data.dart';
import 'screens/upgrade_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => SavingsGoalProvider()),
        ChangeNotifierProxyProvider<BudgetProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, budgetProvider, transactionProvider) {
            transactionProvider!.setBudgetProvider(budgetProvider);
            return transactionProvider;
          },
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Get system brightness
          final systemBrightness = MediaQuery.platformBrightnessOf(context);
          
          // Get custom primary color if set
          final customColor = userProvider.user.customPrimaryColor != null
              ? Color(userProvider.user.customPrimaryColor!)
              : null;

          // Get theme based on user preferences
          final themeData = AppTheme.getTheme(
            themeMode: userProvider.user.themeMode ?? 'system',
            systemBrightness: systemBrightness,
            customPrimaryColor: customColor,
          );

          return MaterialApp.router(
            title: 'Personal Finance & Budgeting App',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/budget-planner',
      builder: (context, state) => const BudgetPlannerScreen(),
    ),
    GoRoute(
      path: '/savings-goals',
      builder: (context, state) => const SavingsGoalsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/backup-data',
      builder: (context, state) => const BackupDataScreen(),
    ),
    GoRoute(
      path: '/upgrade',
      builder: (context, state) => const UpgradeScreen(),
    ),
  ],
);
