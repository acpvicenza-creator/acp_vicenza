import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/excel_export_service.dart';
import '../services/audit_log_service.dart';

class AdminFinancialLedgerScreen extends StatefulWidget {
  const AdminFinancialLedgerScreen({super.key});

  @override
  State<AdminFinancialLedgerScreen> createState() => _AdminFinancialLedgerScreenState();
}

class _AdminFinancialLedgerScreenState extends State<AdminFinancialLedgerScreen> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'Funeral Repatriation';

  final List<String> _expenseCategories = [
    'Funeral Repatriation',
    'Consulate & Legal Fees',
    'Community Welfare / Charity',
    'Office & Administrative',
    'Event / Hall Booking',
    'Miscellaneous',
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Expense', style: TextStyle(color: Color(0xFF043927))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Expense Description *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (€) *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => _category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF043927), foregroundColor: Colors.white),
              onPressed: () async {
                final desc = _descCtrl.text.trim();
                final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

                if (desc.isNotEmpty && amount > 0) {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(dialogCtx);

                  await FirebaseFirestore.instance.collection('expenses').add({
                    'description': desc,
                    'amount': amount,
                    'category': _category,
                    'date': FieldValue.serverTimestamp(),
                  });

                  await AuditLogService.logAction(
                    actionTitle: 'Expense Logged',
                    details: 'Logged expense €$amount for "$desc" under category $_category',
                  );

                  _descCtrl.clear();
                  _amountCtrl.clear();
                  nav.pop();

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Expense of €${amount.toStringAsFixed(2)} added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Financial Transparency Ledger'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Export Financial Ledger to Excel (.xlsx)',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              final membersSnap = await FirebaseFirestore.instance.collection('members').get();
              final expensesSnap = await FirebaseFirestore.instance.collection('expenses').get();

              final membersList = membersSnap.docs.map((d) => d.data()).toList();
              final expensesList = expensesSnap.docs.map((d) => d.data()).toList();

              await ExcelExportService.exportFinancialLedgerToExcel(
                membersList: membersList,
                expensesList: expensesList,
              );

              messenger.showSnackBar(
                const SnackBar(content: Text('Financial Ledger exported to Excel successfully! ✅')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, memberSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('expenses').orderBy('date', descending: true).snapshots(),
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
                final String cat = data['category'] ?? 'Miscellaneous';
                totalExpense += amt;
                categoryExpense[cat] = (categoryExpense[cat] ?? 0) + amt;
              }

              final double netBalance = totalIncome - totalExpense;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FINANCIAL SUMMARY CARDS
                    Row(
                      children: [
                        _buildSummaryCard('Total Collected\n(Paid Fees)', '€${totalIncome.toStringAsFixed(0)}', Colors.green),
                        const SizedBox(width: 8),
                        _buildSummaryCard('Total Spent\n(Repatriations)', '€${totalExpense.toStringAsFixed(0)}', Colors.red),
                        const SizedBox(width: 8),
                        _buildSummaryCard('Net Reserve\nBalance', '€${netBalance.toStringAsFixed(0)}', netBalance >= 0 ? darkGreen : Colors.red.shade900),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // EXPENSE BREAKDOWN PIE CHART
                    if (totalExpense > 0) ...[
                      const Text('Expense Distribution by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Container(
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                            sections: categoryExpense.entries.map((entry) {
                              final double pct = (entry.value / totalExpense) * 100;
                              return PieChartSectionData(
                                color: _getCategoryColor(entry.key),
                                value: entry.value,
                                title: '${pct.toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // RECENT EXPENSE TRANSACTIONS LIST
                    const Text('Recent Committee Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),

                    if (expenseDocs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No expenses recorded yet.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...expenseDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final double amt = (data['amount'] as num?)?.toDouble() ?? 0.0;
                        final String desc = data['description'] ?? 'Expense';
                        final String cat = data['category'] ?? 'General';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                            ),
                            title: Text(desc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Category: $cat', style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              '-€${amt.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
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

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              amount,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}