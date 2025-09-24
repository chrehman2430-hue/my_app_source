import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction.dart' as finance_transaction;
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../utils/icon_utils.dart';
import '../widgets/bottom_navigation_bar.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      // Listen for route changes to refresh data when returning from add transaction
      final router = GoRouter.of(context);
      router.routerDelegate.addListener(_onRouteChanged);
    });
  }

  @override
  void dispose() {
    final router = GoRouter.of(context);
    router.routerDelegate.removeListener(_onRouteChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    final currentLocation = GoRouterState.of(context).uri.toString();
    // Refresh data when returning to transactions from add transaction
    if (currentLocation == '/transactions' || currentLocation.startsWith('/transactions?')) {
      context.read<TransactionProvider>().loadTransactions();
    }
  }



  List<finance_transaction.Transaction> _getFilteredTransactions(
      List<finance_transaction.Transaction> transactions) {
    // Filter transactions
    var filtered = transactions.where((transaction) {
      final matchesSearch = transaction.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          transaction.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Income' &&
              transaction.type == finance_transaction.TransactionType.income) ||
          (_selectedFilter == 'Expense' &&
              transaction.type == finance_transaction.TransactionType.expense);

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort by date (most recent first) as default
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  double _calculateRunningBalance(
      List<finance_transaction.Transaction> transactions, int index) {
    double balance = 0;
    for (int i = 0; i <= index; i++) {
      if (transactions[i].type == finance_transaction.TransactionType.income) {
        balance += transactions[i].amount;
      } else {
        balance -= transactions[i].amount;
      }
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        actions: [],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF2196F3)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Income'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Expense'),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredTransactions =
                      _getFilteredTransactions(provider.transactions);

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final runningBalance = _calculateRunningBalance(
                          filteredTransactions, index);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.color ?? Colors.blue,
                            child: Icon(
                              transaction.icon != null
                                  ? IconUtils.getIconData(transaction.icon!)
                                  : transaction.type ==
                                          finance_transaction.TransactionType.income
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.category,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(transaction.date),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) => Text(
                                  '${transaction.type == finance_transaction.TransactionType.income ? '+' : '-'}${userProvider.user.currencySymbol ?? '\$'}${transaction.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: transaction.type ==
                                            finance_transaction.TransactionType.income
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFF44336),
                                  ),
                                ),
                              ),
                              Text(
                                'Balance: \$${runningBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: runningBalance >= 0
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFF44336),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showTransactionDetails(transaction),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'All';
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
      checkmarkColor: const Color(0xFF4CAF50),
    );
  }





  void _showTransactionDetails(finance_transaction.Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${transaction.category}'),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) => Text('Amount: ${userProvider.user.currencySymbol ?? '\$'}${transaction.amount.toStringAsFixed(2)}'),
            ),
            Text('Date: ${DateFormat('MMM dd, yyyy').format(transaction.date)}'),
            Text('Type: ${transaction.type == finance_transaction.TransactionType.income ? 'Income' : 'Expense'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement edit functionality
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
