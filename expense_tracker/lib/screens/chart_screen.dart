import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/categories.dart';
import '../utils/theme.dart';

class ChartScreen extends StatelessWidget {
  final DateTime month;

  const ChartScreen({super.key, required this.month});

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionService.getTransactionsForMonth(month);
    final expenseTotals = TransactionService.getCategoryTotals(
        transactions, TransactionType.expense);
    final incomeTotals = TransactionService.getCategoryTotals(
        transactions, TransactionType.income);
    final dailyExpenses =
        TransactionService.getDailyTotals(month, TransactionType.expense);
    final dailyIncome =
        TransactionService.getDailyTotals(month, TransactionType.income);
    final totalExpense = TransactionService.getTotalExpense(transactions);
    final totalIncome = TransactionService.getTotalIncome(transactions);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics - $_monthLabel'),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No data for this month',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Spending Line Chart
                  _buildSectionTitle('Daily Overview'),
                  const SizedBox(height: 12),
                  _buildLineChart(dailyExpenses, dailyIncome),
                  const SizedBox(height: 32),

                  // Expense Breakdown Pie Chart
                  if (expenseTotals.isNotEmpty) ...[
                    _buildSectionTitle('Expense Breakdown'),
                    const SizedBox(height: 12),
                    _buildPieChart(expenseTotals, totalExpense, true),
                    const SizedBox(height: 8),
                    _buildCategoryLegend(expenseTotals, totalExpense, true),
                    const SizedBox(height: 32),
                  ],

                  // Income Breakdown Pie Chart
                  if (incomeTotals.isNotEmpty) ...[
                    _buildSectionTitle('Income Breakdown'),
                    const SizedBox(height: 12),
                    _buildPieChart(incomeTotals, totalIncome, false),
                    const SizedBox(height: 8),
                    _buildCategoryLegend(incomeTotals, totalIncome, false),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildLineChart(List<double> expenses, List<double> income) {
    final maxY = [...expenses, ...income]
        .fold<double>(0, (max, val) => val > max ? val : max);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(
                  _formatAmount(value),
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (expenses.length / 6).ceilToDouble(),
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${value.toInt() + 1}',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (expenses.length - 1).toDouble(),
          minY: 0,
          maxY: maxY > 0 ? maxY * 1.2 : 10,
          lineBarsData: [
            _buildLineBarData(expenses, AppTheme.expenseColor),
            _buildLineBarData(income, AppTheme.incomeColor),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]),
      ),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildPieChart(
      Map<String, double> totals, double total, bool isExpense) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: entries.map((entry) {
            final category = getCategoryItem(entry.key, isExpense);
            final percentage = (entry.value / total * 100);
            return PieChartSectionData(
              color: category.color,
              value: entry.value,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 35,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(
      Map<String, double> totals, double total, bool isExpense) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: entries.map((entry) {
          final category = getCategoryItem(entry.key, isExpense);
          final percentage = (entry.value / total * 100);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(category.icon, size: 18, color: category.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}
