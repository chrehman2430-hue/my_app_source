import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../providers/budget_provider.dart';
import '../providers/user_provider.dart';
import '../utils/icon_utils.dart';
import '../utils/currency_utils.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Removed duplicate add button - using FAB instead
        ],
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
        child: Consumer2<BudgetProvider, UserProvider>(
          builder: (context, budgetProvider, userProvider, child) {
            if (budgetProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<BudgetProvider>().loadBudgets();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget Summary Card
                    _buildBudgetSummary(budgetProvider),

                    const SizedBox(height: 24),

                    // Budget List
                    if (budgetProvider.budgets.isEmpty)
                      _buildEmptyState()
                    else
                      ...budgetProvider.budgets.map((budget) => _buildBudgetCard(budget, budgetProvider)),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetSummary(BudgetProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Budget Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Total Budget',
                  provider.totalMonthlyBudget,
                  const Color(0xFF2196F3),
                  context.read<UserProvider>(),
                ),
                _buildSummaryItem(
                  'Spent',
                  provider.totalCurrentSpent,
                  provider.totalCurrentSpent > provider.totalMonthlyBudget
                      ? const Color(0xFFF44336)
                      : const Color(0xFFFF9800),
                  context.read<UserProvider>(),
                ),
                _buildSummaryItem(
                  'Remaining',
                  provider.totalRemaining,
                  provider.totalRemaining >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  context.read<UserProvider>(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: provider.totalMonthlyBudget > 0
                  ? (provider.totalCurrentSpent / provider.totalMonthlyBudget).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                provider.totalMonthlyBudget > 0 && provider.totalCurrentSpent > provider.totalMonthlyBudget
                    ? const Color(0xFFF44336)
                    : const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) => Text(
                provider.totalMonthlyBudget == 0
                    ? 'No budget set'
                    : provider.totalCurrentSpent > provider.totalMonthlyBudget
                        ? 'Over budget by ${CurrencyUtils.formatCurrency(provider.totalCurrentSpent - provider.totalMonthlyBudget, userProvider.user.currencySymbol ?? '\$')}'
                        : '${((provider.totalCurrentSpent / provider.totalMonthlyBudget) * 100).toStringAsFixed(1)}% of budget used',
                style: TextStyle(
                  fontSize: 12,
                  color: provider.totalMonthlyBudget == 0
                      ? Colors.grey.shade600
                      : provider.totalCurrentSpent > provider.totalMonthlyBudget
                          ? const Color(0xFFF44336)
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, UserProvider userProvider) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${userProvider.user.currencySymbol}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set up yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start tracking expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget, BudgetProvider provider) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) => Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: budget.categoryColor ?? Colors.blue,
                        radius: 16,
                        child: Icon(
                          IconUtils.getIconData(budget.categoryName.toLowerCase()),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        budget.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditBudgetDialog(context, budget);
                          break;
                        case 'delete':
                          _showDeleteBudgetDialog(context, budget, provider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyUtils.formatCurrency(budget.currentSpent, userProvider.user.currencySymbol ?? '\$')} / ${CurrencyUtils.formatCurrency(budget.monthlyLimit, userProvider.user.currencySymbol ?? '\$')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: budget.isOverBudget ? const Color(0xFFF44336) : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    budget.isOverBudget
                        ? 'Over by ${CurrencyUtils.formatCurrency(budget.currentSpent - budget.monthlyLimit, userProvider.user.currencySymbol ?? '\$')}'
                        : '${CurrencyUtils.formatCurrency(budget.remainingAmount, userProvider.user.currencySymbol ?? '\$')} left',
                    style: TextStyle(
                      fontSize: 12,
                      color: budget.isOverBudget ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: budget.progressPercentage.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  budget.isOverBudget ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(budget.progressPercentage * 100).toStringAsFixed(1)}% used',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (budget.progressPercentage > 0.8 && !budget.isOverBudget)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFFF9800), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Approaching budget limit',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFFF9800),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (budget.isOverBudget)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF44336)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Color(0xFFF44336), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Budget exceeded!',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF44336),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => EditBudgetDialog(budget: budget),
    );
  }

  void _showDeleteBudgetDialog(BuildContext context, Budget budget, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for ${budget.categoryName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await provider.deleteBudget(budget.id ?? '');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting budget: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  String? _selectedCategoryName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial value to first category
    _selectedCategoryName = Category.defaultCategories.first.name;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Find the selected category by name
      final selectedCategory = Category.defaultCategories.firstWhere(
        (category) => category.name == _selectedCategoryName,
      );

      final budget = Budget(
        categoryId: (selectedCategory.id ?? 0).toString(),
        monthlyLimit: double.parse(_limitController.text),
        period: DateTime.now(),
        categoryName: selectedCategory.name,
        categoryColor: selectedCategory.color,
      );

      await context.read<BudgetProvider>().addBudget(budget);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding budget: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) => AlertDialog(
        title: const Text('Add Budget'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCategoryName,
                items: Category.defaultCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(
                          IconUtils.getIconData(category.icon),
                          color: category.color,
                        ),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryName = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixText: userProvider.user.currencySymbol ?? '\$',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a limit';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class EditBudgetDialog extends StatefulWidget {
  final Budget budget;

  const EditBudgetDialog({super.key, required this.budget});

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(text: widget.budget.monthlyLimit.toString());
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) => AlertDialog(
        title: const Text('Edit Budget'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${widget.budget.categoryName}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixText: userProvider.user.currencySymbol ?? '\$',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a limit';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBudget = widget.budget.copyWith(
        monthlyLimit: double.parse(_limitController.text),
      );

      await context.read<BudgetProvider>().updateBudget(updatedBudget);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating budget: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
