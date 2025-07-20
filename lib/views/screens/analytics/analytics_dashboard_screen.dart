import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/analytics_controller.dart';
import '../../../models/analytics_model.dart';
import '../../../utils/theme.dart';
import '../../widgets/analytics_card.dart';
import '../../widgets/chart_container.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsController _analyticsController = Get.put(AnalyticsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _analyticsController.loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _analyticsController.refreshAnalytics(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _analyticsController.exportAnalytics();
                  break;
                case 'settings':
                  _showAnalyticsSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Revenue'),
            Tab(text: 'Parcels'),
            Tab(text: 'Customers'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: Obx(() {
        if (_analyticsController.isLoading.value) {
          return _buildLoadingView();
        }

        if (_analyticsController.analytics.value == null) {
          return _buildEmptyView();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildRevenueTab(),
            _buildParcelsTab(),
            _buildCustomersTab(),
            _buildPerformanceTab(),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingView() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            5,
            (index) => Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Analytics Data Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Analytics data will appear here once you start processing orders',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _analyticsController.refreshAnalytics(),
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final analytics = _analyticsController.analytics.value!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKPISection(analytics),
          
          const SizedBox(height: 30),
          
          // Revenue Trend Chart
          _buildRevenueOverviewChart(analytics),
          
          const SizedBox(height: 30),
          
          // Quick Stats Grid
          _buildQuickStatsGrid(analytics),
          
          const SizedBox(height: 30),
          
          // Performance Summary
          _buildPerformanceSummary(analytics),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildKPISection(AnalyticsModel analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Indicators',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Total Revenue',
                value: '\$${analytics.revenue.totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppTheme.successColor,
                growth: _calculateGrowth(
                  analytics.revenue.monthlyRevenue,
                  analytics.revenue.totalRevenue - analytics.revenue.monthlyRevenue,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnalyticsCard(
                title: 'Total Parcels',
                value: analytics.parcels.totalParcels.toString(),
                icon: Icons.local_shipping,
                color: AppTheme.primaryColor,
                growth: _calculateGrowth(
                  analytics.parcels.monthlyParcels.toDouble(),
                  (analytics.parcels.totalParcels - analytics.parcels.monthlyParcels).toDouble(),
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Active Customers',
                value: analytics.customers.activeCustomers.toString(),
                icon: Icons.people,
                color: AppTheme.warningColor,
                growth: _calculateGrowth(
                  analytics.customers.newCustomers.toDouble(),
                  (analytics.customers.activeCustomers - analytics.customers.newCustomers).toDouble(),
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnalyticsCard(
                title: 'On-Time Delivery',
                value: '${(analytics.delivery.onTimeDeliveryRate * 100).toStringAsFixed(1)}%',
                icon: Icons.timer,
                color: AppTheme.secondaryColor,
                growth: analytics.delivery.onTimeDeliveryRate > 0.9 ? 5.2 : -2.1,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueOverviewChart(AnalyticsModel analytics) {
    return ChartContainer(
      title: 'Revenue Trend (Last 30 Days)',
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1000,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          minX: 0,
          maxX: 30,
          minY: 0,
          maxY: analytics.revenue.revenueHistory.isNotEmpty
              ? analytics.revenue.revenueHistory.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2
              : 10000,
          lineBarsData: [
            LineChartBarData(
              spots: _generateRevenueSpots(analytics.revenue.revenueHistory),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.3),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.primaryColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickStatsGrid(AnalyticsModel analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Avg. Delivery Time',
              '${analytics.delivery.averageDeliveryTime.toStringAsFixed(1)} hrs',
              Icons.timer_outlined,
              AppTheme.warningColor,
            ),
            _buildStatCard(
              'Customer Satisfaction',
              '${(analytics.customers.customerSatisfactionScore * 100).toStringAsFixed(1)}%',
              Icons.star_outline,
              AppTheme.successColor,
            ),
            _buildStatCard(
              'Monthly Growth',
              '+${_calculateGrowth(analytics.revenue.monthlyRevenue, analytics.revenue.totalRevenue - analytics.revenue.monthlyRevenue).toStringAsFixed(1)}%',
              Icons.trending_up,
              AppTheme.primaryColor,
            ),
            _buildStatCard(
              'System Uptime',
              '${(analytics.performance.systemUptime * 100).toStringAsFixed(2)}%',
              Icons.cloud_done_outlined,
              AppTheme.secondaryColor,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(AnalyticsModel analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 50,
                      percentage: analytics.delivery.onTimeDeliveryRate,
                      color: AppTheme.successColor,
                      text: '${(analytics.delivery.onTimeDeliveryRate * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 8),
                    const Text('On-Time Delivery'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 50,
                      percentage: analytics.customers.customerSatisfactionScore,
                      color: AppTheme.warningColor,
                      text: '${(analytics.customers.customerSatisfactionScore * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 8),
                    const Text('Customer Satisfaction'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 50,
                      percentage: analytics.performance.systemUptime,
                      color: AppTheme.primaryColor,
                      text: '${(analytics.performance.systemUptime * 100).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 8),
                    const Text('System Uptime'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildRevenueTab() {
    return const Center(
      child: Text('Revenue Analytics Tab - To be implemented'),
    );
  }

  Widget _buildParcelsTab() {
    return const Center(
      child: Text('Parcels Analytics Tab - To be implemented'),
    );
  }

  Widget _buildCustomersTab() {
    return const Center(
      child: Text('Customers Analytics Tab - To be implemented'),
    );
  }

  Widget _buildPerformanceTab() {
    return const Center(
      child: Text('Performance Analytics Tab - To be implemented'),
    );
  }

  List<FlSpot> _generateRevenueSpots(List<RevenueDataPoint> data) {
    if (data.isEmpty) {
      // Generate sample data for demonstration
      return List.generate(30, (index) {
        return FlSpot(
          index.toDouble(),
          (index * 100 + (index % 7) * 200).toDouble(),
        );
      });
    }
    
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  double _calculateGrowth(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  void _showAnalyticsSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Settings'),
        content: const Text('Analytics settings will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Custom CircularPercentIndicator widget
class CircularPercentIndicator extends StatelessWidget {
  final double radius;
  final double percentage;
  final Color color;
  final String text;

  const CircularPercentIndicator({
    super.key,
    required this.radius,
    required this.percentage,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}