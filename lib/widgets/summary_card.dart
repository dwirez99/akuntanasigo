import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (title == 'Selisih')
                  Icon(
                    amount >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: amount >= 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: title == 'Selisih' 
                    ? (amount >= 0 ? Colors.green : Colors.red)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final absAmount = amount.abs();
    final formatter = NumberFormat('#,###');
    return 'Rp ${formatter.format(absAmount)}';
  }
}
