import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/theme.dart';
import '../../widgets/enhanced_stat_card.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/hero_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _mainAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  Future<void> _loadDashboardData() async {
    // Simulate loading data
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      bottomNavigationBar: _buildEnhancedBottomNavigationBar(),
      floatingActionButton: _buildAnimatedFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildShimmerCards(),
                const SizedBox(height: 24),
                _buildShimmerChart(),
                const SizedBox(height: 24),
                _buildShimmerGrid(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildAnimatedAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Welcome Message with Animation
              _buildWelcomeMessage(),
              
              const SizedBox(height: 24),
              
              // Key Metrics Cards
              _buildEnhancedStatsSection(),
              
              const SizedBox(height: 32),
              
              // Quick Actions Grid
              _buildQuickActionsGrid(),
              
              const SizedBox(height: 32),
              
              // Recent Activities with Hero Animation
              _buildRecentActivitiesSection(),
              
              const SizedBox(height: 32),
              
              // Performance Overview
              _buildPerformanceOverview(),
              
              const SizedBox(height: 100), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Obx(() => Text(
                  'Welcome, ${_authController.currentUser?.name?.split(' ').first ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
              ),
            );
          },
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: IconButton(
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                onPressed: () => Get.toNamed(AppRoutes.analytics),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => Get.toNamed(AppRoutes.notifications),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.profile),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your shipping operations efficiently',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0);
  }

  Widget _buildEnhancedStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        AnimationLimiter(
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: List.generate(4, (index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 600),
                columnCount: 2,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildStatCard(index),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(int index) {
    final stats = [
      {
        'title': 'Total Parcels',
        'value': '1,234',
        'icon': Icons.local_shipping_outlined,
        'color': AppTheme.primaryColor,
        'growth': '+12.5%',
        'isPositive': true,
      },
      {
        'title': 'In Transit',
        'value': '89',
        'icon': Icons.route_outlined,
        'color': AppTheme.warningColor,
        'growth': '+8.2%',
        'isPositive': true,
      },
      {
        'title': 'Delivered',
        'value': '1,089',
        'icon': Icons.check_circle_outline,
        'color': AppTheme.successColor,
        'growth': '+15.1%',
        'isPositive': true,
      },
      {
        'title': 'Revenue',
        'value': '\$12.5K',
        'icon': Icons.attach_money,
        'color': AppTheme.accentColor,
        'growth': '+23.4%',
        'isPositive': true,
      },
    ];

    final stat = stats[index];
    
    return HeroCard(
      tag: 'stat_card_$index',
      child: EnhancedStatCard(
        title: stat['title'] as String,
        value: stat['value'] as String,
        icon: stat['icon'] as IconData,
        color: stat['color'] as Color,
        growth: stat['growth'] as String,
        isPositive: stat['isPositive'] as bool,
        onTap: () => _navigateToDetails(index),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Obx(() {
          final isDeliveryMan = _authController.currentUser?.role == UserRole.deliveryMan;
          
          return AnimationLimiter(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: List.generate(
                isDeliveryMan ? 4 : 4,
                (index) => AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: SlideAnimation(
                    horizontalOffset: index.isEven ? -50.0 : 50.0,
                    child: FadeInAnimation(
                      delay: Duration(milliseconds: 100 * index),
                      child: isDeliveryMan 
                          ? _buildDeliveryManActionCard(index)
                          : _buildCustomerActionCard(index),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomerActionCard(int index) {
    final actions = [
      {
        'title': 'Create Parcel',
        'icon': Icons.add_box_outlined,
        'color': AppTheme.primaryColor,
        'gradient': AppTheme.primaryGradient,
        'route': AppRoutes.createParcel,
      },
      {
        'title': 'Track Parcel',
        'icon': Icons.search,
        'color': AppTheme.successColor,
        'gradient': AppTheme.successGradient,
        'route': AppRoutes.parcelList,
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'color': AppTheme.secondaryColor,
        'gradient': const LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.accentColor],
        ),
        'route': AppRoutes.analytics,
      },
      {
        'title': 'Sheba Pay Demo',
        'icon': Icons.payment,
        'color': AppTheme.accentColor,
        'gradient': const LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.primaryColor],
        ),
        'route': AppRoutes.spayDemo,
      },
    ];

    final action = actions[index];
    
    return HeroCard(
      tag: 'action_card_$index',
      child: _buildActionCard(
        action['title'] as String,
        action['icon'] as IconData,
        action['color'] as Color,
        action['gradient'] as LinearGradient,
        () => action['route'] != null 
            ? Get.toNamed(action['route'] as String)
            : {},
      ),
    );
  }

  Widget _buildDeliveryManActionCard(int index) {
    final actions = [
      {
        'title': 'My Deliveries',
        'icon': Icons.assignment_outlined,
        'color': AppTheme.primaryColor,
        'gradient': AppTheme.primaryGradient,
        'route': AppRoutes.delivery,
      },
      {
        'title': 'Update Status',
        'icon': Icons.update,
        'color': AppTheme.successColor,
        'gradient': AppTheme.successGradient,
        'route': AppRoutes.delivery,
      },
      {
        'title': 'Route Map',
        'icon': Icons.map_outlined,
        'color': AppTheme.accentColor,
        'gradient': LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.secondaryColor],
        ),
        'route': null,
      },
      {
        'title': 'Earnings',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppTheme.warningColor,
        'gradient': AppTheme.warningGradient,
        'route': AppRoutes.analytics,
      },
    ];

    final action = actions[index];
    
    return HeroCard(
      tag: 'delivery_action_card_$index',
      child: _buildActionCard(
        action['title'] as String,
        action['icon'] as IconData,
        action['color'] as Color,
        action['gradient'] as LinearGradient,
        () => action['route'] != null 
            ? Get.toNamed(action['route'] as String)
            : _showComingSoonDialog(),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.history),
              child: const Text('View All'),
            ),
          ],
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        HeroCard(
          tag: 'recent_activities',
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recent shipping activities will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPerformanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.03),
                AppTheme.accentColor.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric('On-Time Delivery', '94.5%', AppTheme.successColor),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.dividerColor,
              ),
              Expanded(
                child: _buildPerformanceMetric('Customer Satisfaction', '4.8★', AppTheme.warningColor),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.dividerColor,
              ),
              Expanded(
                child: _buildPerformanceMetric('Growth Rate', '+23.4%', AppTheme.accentColor),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPerformanceMetric(String title, String value, Color color) {
    return Column(
      children: [
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
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_floatingAnimationController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.createParcel),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add),
            label: const Text(
              'Create Parcel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.elevatedShadow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomAppBar(
          height: 70,
          color: Colors.white,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: [
              _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
              _buildNavItem(Icons.local_shipping_outlined, 'Parcels', 1),
              const SizedBox(width: 80), // Space for FAB
              _buildNavItem(Icons.history, 'History', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Get.toNamed(AppRoutes.parcelList);
        break;
      case 2:
        Get.toNamed(AppRoutes.history);
        break;
      case 3:
        Get.toNamed(AppRoutes.profile);
        break;
    }
  }

  void _navigateToDetails(int index) {
    // Navigate to specific stat details
    switch (index) {
      case 0:
      case 1:
        Get.toNamed(AppRoutes.parcelList);
        break;
      case 2:
        Get.toNamed(AppRoutes.history);
        break;
      case 3:
        Get.toNamed(AppRoutes.analytics);
        break;
    }
  }

  void _showSupportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Support'),
        content: const Text('Contact support for assistance with your shipping needs.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              // TODO: Implement support contact
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is coming soon. Stay tuned for updates!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Shimmer loading widgets
  Widget _buildShimmerCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.mediumRadius,
          ),
        );
      }),
    );
  }

  Widget _buildShimmerChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.mediumRadius,
          ),
        );
      }),
    );
  }
}