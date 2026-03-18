import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static const String _boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(_boxName);
  }

  static Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(_boxName);

  static List<TransactionModel> getAllTransactions() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<TransactionModel> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return getAllTransactions()
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  static List<TransactionModel> getTransactionsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    return getTransactionsByDateRange(start, end);
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  static double getTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getTotalExpense(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getBalance(List<TransactionModel> transactions) {
    return getTotalIncome(transactions) - getTotalExpense(transactions);
  }

  static Map<String, double> getCategoryTotals(
      List<TransactionModel> transactions, TransactionType type) {
    final filtered = transactions.where((t) => t.type == type);
    final Map<String, double> totals = {};
    for (final t in filtered) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  static List<double> getDailyTotals(
      DateTime month, TransactionType type) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dailyTotals = List<double>.filled(daysInMonth, 0);
    final transactions = getTransactionsForMonth(month);
    for (final t in transactions) {
      if (t.type == type) {
        dailyTotals[t.date.day - 1] += t.amount;
      }
    }
    return dailyTotals;
  }
}
