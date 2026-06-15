class FeePayment {
  final String date;
  final String type;
  final double amount;
  final bool isPaid;

  const FeePayment({
    required this.date,
    required this.type,
    required this.amount,
    required this.isPaid,
  });
}
