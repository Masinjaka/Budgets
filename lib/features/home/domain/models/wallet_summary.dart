class WalletSummary {
  const WalletSummary({
    required this.id,
    required this.name,
    required this.balance,
    required this.currencyCode,
    required this.iconKey,
    required this.isDefault,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toInt(),
      currencyCode: (json['currency_code'] as String?) ?? 'MGA',
      iconKey: (json['icon_key'] as String?) ?? 'wallet',
      isDefault: (json['is_default'] as bool?) ?? false,
    );
  }

  final String id;
  final String name;
  final int balance;
  final String currencyCode;
  final String iconKey;
  final bool isDefault;
}
