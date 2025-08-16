import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/analisis_data.dart';

class BulananLineChart extends StatelessWidget {
  final List<BulananData> data;

  const BulananLineChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada data'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Pemasukan vs Pengeluaran Bulanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _getMaxValue() / 5,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: _bottomTitleWidgets,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getMaxValue() / 5,
                        getTitlesWidget: _leftTitleWidgets,
                        reservedSize: 72,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 0,
                  maxX: data.length.toDouble() - 1,
                  minY: 0,
                  maxY: _getMaxValue(),
                  lineBarsData: [
                    _createPemasukanLine(),
                    _createPengeluaranLine(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createPemasukanLine() {
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.pemasukan.toDouble(),
        );
      }).toList(),
      isCurved: true,
      color: Colors.green,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.green.withOpacity(0.1),
      ),
    );
  }

  LineChartBarData _createPengeluaranLine() {
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.pengeluaran.toDouble(),
        );
      }).toList(),
      isCurved: true,
      color: Colors.red,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.red.withOpacity(0.1),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return Container();
    
    final bulan = data[index].bulan;
    final date = DateTime.parse('$bulan-01');
    final monthName = DateFormat('MMM').format(date);
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        monthName,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        _formatCurrency(value.toInt()),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  double _getMaxValue() {
    double maxValue = 0;
    for (final item in data) {
      if (item.pemasukan > maxValue) maxValue = item.pemasukan.toDouble();
      if (item.pengeluaran > maxValue) maxValue = item.pengeluaran.toDouble();
    }
    return maxValue * 1.1; // Add 10% padding
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 3,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            const Text('Pemasukan'),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            Container(
              width: 16,
              height: 3,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Pengeluaran'),
          ],
        ),
      ],
    );
  }
}
