import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<CategoryItem> expenseCategories = [
  CategoryItem(name: 'Food', icon: Icons.restaurant, color: Color(0xFFE57373)),
  CategoryItem(name: 'Transport', icon: Icons.directions_car, color: Color(0xFF64B5F6)),
  CategoryItem(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFFBA68C8)),
  CategoryItem(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFFFFB74D)),
  CategoryItem(name: 'Entertainment', icon: Icons.movie, color: Color(0xFF4DB6AC)),
  CategoryItem(name: 'Health', icon: Icons.local_hospital, color: Color(0xFFEF5350)),
  CategoryItem(name: 'Education', icon: Icons.school, color: Color(0xFF42A5F5)),
  CategoryItem(name: 'Other', icon: Icons.more_horiz, color: Color(0xFF90A4AE)),
];

const List<CategoryItem> incomeCategories = [
  CategoryItem(name: 'Salary', icon: Icons.work, color: Color(0xFF66BB6A)),
  CategoryItem(name: 'Freelance', icon: Icons.laptop_mac, color: Color(0xFF26A69A)),
  CategoryItem(name: 'Investment', icon: Icons.trending_up, color: Color(0xFF42A5F5)),
  CategoryItem(name: 'Gift', icon: Icons.card_giftcard, color: Color(0xFFAB47BC)),
  CategoryItem(name: 'Other', icon: Icons.more_horiz, color: Color(0xFF90A4AE)),
];

CategoryItem getCategoryItem(String name, bool isExpense) {
  final list = isExpense ? expenseCategories : incomeCategories;
  return list.firstWhere(
    (c) => c.name == name,
    orElse: () => list.last,
  );
}
