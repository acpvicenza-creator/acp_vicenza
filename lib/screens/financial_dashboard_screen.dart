import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialDashboardScreen extends StatelessWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, memberSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
            builder: (context, expenseSnapshot) {
              if (!memberSnapshot.hasData || !expenseSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final memberDocs = memberSnapshot.data!.docs;
              final expenseDocs = expenseSnapshot.data!.docs;

              double totalIncome = 0.0;
              for (var doc in memberDocs) {
                final data = doc.data() as Map<String, dynamic>;
                if ((data['paymentStatus'] ?? '') == 'Paid') {
                  totalIncome += (data['totalFee'] as num?)?.toDouble() ?? 0.0;
                }
              }

              double totalExpense = 0.0;
              Map<String, double> categoryExpense = {};
              for (var doc in expenseDocs) {
                final data = doc.data() as Map<String, dynamic>;
                final double amt = (data['amount'] as num?)?.toDouble() ?? 0.0;
                final String cat = data['category'] ?? 'General';
                totalExpense += amt;
                categoryExpense[cat] = (categoryExpense[cat] ?? 0) + amt;
              }

              final double netBalance = totalIncome - totalExpense;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FINANCIAL METRICS OVERVIEW
                    Row(
                      children: [
                        _buildStatBox('Total Income', '€${totalIncome.toStringAsFixed(0)}', Colors.green, Icons.arrow_upward),
                        const SizedBox(width: 8),
                        _buildStatBox('Total Spent', '€${totalExpense.toStringAsFixed(0)}', Colors.red, Icons.arrow_downward),
                        const SizedBox(width: 8),
                        _buildStatBox('Net Reserve', '€${netBalance.toStringAsFixed(0)}', netBalance >= 0 ? darkGreen : Colors.red.shade900, Icons.account_balance_wallet),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // EXPENSE BREAKDOWN PIE CHART
                    const Text(
                      'Expense Breakdown by Category',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkGreen),
                    ),
                    const SizedBox(height: 12),

                    if (totalExpense > 0)
                      Container(
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
                          children: [
                            SizedBox(
                              height: 190,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 38,
                                  sections: categoryExpense.entries.map((entry) {
                                    final double pct = (entry.value / totalExpense) * 100;
                                    return PieChartSectionData(
                                      color: _getCategoryColor(entry.key),
                                      value: entry.value,
                                      title: '${pct.toStringAsFixed(0)}%',
                                      radius: 48,
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: categoryExpense.keys.map((cat) {
                                return _buildLegendItem(cat, _getCategoryColor(cat));
                              }).toList(),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No expenses logged yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String title, String amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Funeral Repatriation':
        return Colors.red.shade800;
      case 'Consulate & Legal Fees':
        return Colors.blue.shade800;
      case 'Community Welfare / Charity':
        return Colors.green.shade800;
      case 'Office & Administrative':
        return Colors.orange.shade800;
      case 'Event / Hall Booking':
        return Colors.purple.shade800;
      default:
        return Colors.teal.shade800;
    }
  }
}