class User {
  final String? id;
  final String? name;
  final String? email;
  final bool isPremium;
  final double totalIncome;
  final String currency;
  final String themeMode;
  final Map<String, dynamic> preferences;
  final bool pushNotificationsEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final int? customPrimaryColor; // Store color as int value

  User({
    this.id,
    this.name,
    this.email,
    this.isPremium = false,
    this.totalIncome = 0.0,
    this.currency = 'USD',
    this.themeMode = 'system',
    this.preferences = const {},
    this.pushNotificationsEnabled = true,
    this.budgetAlertsEnabled = false,
    this.goalRemindersEnabled = false,
    this.customPrimaryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isPremium': isPremium ? 1 : 0,
      'totalIncome': totalIncome,
      'currency': currency,
      'themeMode': themeMode,
      'preferences': preferences,
      'pushNotificationsEnabled': pushNotificationsEnabled ? 1 : 0,
      'budgetAlertsEnabled': budgetAlertsEnabled ? 1 : 0,
      'goalRemindersEnabled': goalRemindersEnabled ? 1 : 0,
      'customPrimaryColor': customPrimaryColor,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      isPremium: map['isPremium'] == 1,
      totalIncome: map['totalIncome'] ?? 0.0,
      currency: map['currency'] ?? 'USD',
      themeMode: map['themeMode'] ?? 'system',
      preferences: map['preferences'] ?? {},
      pushNotificationsEnabled: map['pushNotificationsEnabled'] == 1,
      budgetAlertsEnabled: map['budgetAlertsEnabled'] == 1,
      goalRemindersEnabled: map['goalRemindersEnabled'] == 1,
      customPrimaryColor: map['customPrimaryColor'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isPremium,
    double? totalIncome,
    String? currency,
    String? themeMode,
    Map<String, dynamic>? preferences,
    bool? pushNotificationsEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    int? customPrimaryColor,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      totalIncome: totalIncome ?? this.totalIncome,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      preferences: preferences ?? this.preferences,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
    );
  }

  // Currency symbol mapping
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'INR': '₹',
    'RUB': '₽',
    'CAD': 'C\$',
    'MXN': 'MX\$',
    'PKR': '₨',
  };

  String get currencySymbol => _currencySymbols[currency] ?? '\$';

  // Premium features check
  bool get canExportData => isPremium;
  bool get canSyncBankAccounts => isPremium;
  bool get hasAdvancedReports => isPremium;
}
