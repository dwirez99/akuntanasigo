import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analisis_data.dart';

class KategoriPieChart extends StatelessWidget {
  final List<KategoriAnalisis> data;
  final String title;
  final Color primaryColor;

  const KategoriPieChart({
    super.key,
    required this.data,
    required this.title,
    required this.primaryColor,
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
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _createSections(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegend(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
      primaryColor.withOpacity(0.2),
    ];

    return data.take(5).map((item) {
      final index = data.indexOf(item);
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        color: color,
        value: item.persentase,
        title: '${item.persentase.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
      primaryColor.withOpacity(0.2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.take(5).map((item) {
        final index = data.indexOf(item);
        final color = colors[index % colors.length];
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.namaKategori,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
