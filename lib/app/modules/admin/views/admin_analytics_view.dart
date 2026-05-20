import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/themes/app_themes.dart';
import '../controllers/admin_controller.dart';

class AdminAnalyticsView extends GetView<AdminController> {
  const AdminAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return RefreshIndicator(
      onRefresh: controller.fetchAnalytics,
      child: Obx(() {
        if (controller.isLoadingAnalytics.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats row
            _buildStatsGrid(ext),
            const SizedBox(height: 20),

            // Revenue chart
            _buildSectionHeader('Monthly Revenue', ext),
            const SizedBox(height: 12),
            _buildRevenueChart(context, ext),
            const SizedBox(height: 20),

            // Users distribution
            _buildSectionHeader('User Distribution', ext),
            const SizedBox(height: 12),
            _buildPieChart(context, ext),
          ],
        );
      }),
    );
  }

  Widget _buildStatsGrid(AppColorExtension ext) {
    final stats = [
      {
        'label': 'Total Users',
        'value': '${controller.totalUsers.value}',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'label': 'Active',
        'value': '${controller.activeUsers.value}',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'label': 'Monthly Revenue',
        'value': '\$${controller.monthlyRevenue.value.toStringAsFixed(0)}',
        'icon': Icons.attach_money,
        'color': const Color(0xFFD4AF37),
      },
      {
        'label': 'Total Revenue',
        'value': '\$${controller.totalRevenue.value.toStringAsFixed(0)}',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: stats
          .map((s) => _StatCard(
                label: s['label'] as String,
                value: s['value'] as String,
                icon: s['icon'] as IconData,
                color: s['color'] as Color,
                ext: ext,
              ))
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title, AppColorExtension ext) {
    return Text(
      title,
      style: TextStyle(
        color: ext.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context, AppColorExtension ext) {
    final data = controller.revenueData;
    if (data.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('No revenue data yet',
            style: TextStyle(color: ext.textSecondary)),
      );
    }

    final bars = data.asMap().entries.map((e) {
      final revenue = (e.value['revenue'] as double);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: revenue,
            gradient: LinearGradient(
              colors: [ext.primary, ext.secondary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: ext.border,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  '\$${v.toInt()}',
                  style: TextStyle(color: ext.textSecondary, fontSize: 10),
                ),
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  final month = data[idx]['month'] as String;
                  final parts = month.split('-');
                  return Text(
                    parts.length == 2 ? '${parts[1]}/${parts[0].substring(2)}' : month,
                    style: TextStyle(color: ext.textSecondary, fontSize: 9),
                  );
                },
                reservedSize: 24,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, AppColorExtension ext) {
    final total = controller.totalUsers.value;
    if (total == 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('No data', style: TextStyle(color: ext.textSecondary)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: controller.activeUsers.value.toDouble(),
                      color: Colors.green,
                      title: 'Active',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                    PieChartSectionData(
                      value: controller.expiredUsers.value.toDouble(),
                      color: Colors.orange,
                      title: 'Expired',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                    PieChartSectionData(
                      value: controller.freeUsers.value.toDouble(),
                      color: Colors.grey,
                      title: 'Free',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(color: Colors.green, label: 'Active', value: '${controller.activeUsers.value}', ext: ext),
              const SizedBox(height: 8),
              _Legend(color: Colors.orange, label: 'Expired', value: '${controller.expiredUsers.value}', ext: ext),
              const SizedBox(height: 8),
              _Legend(color: Colors.grey, label: 'Free', value: '${controller.freeUsers.value}', ext: ext),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AppColorExtension ext;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style:
                      TextStyle(color: ext.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final AppColorExtension ext;

  const _Legend(
      {required this.color,
      required this.label,
      required this.value,
      required this.ext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(color: ext.textSecondary, fontSize: 13)),
        const SizedBox(width: 6),
        Text(value,
            style: TextStyle(
                color: ext.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }
}
