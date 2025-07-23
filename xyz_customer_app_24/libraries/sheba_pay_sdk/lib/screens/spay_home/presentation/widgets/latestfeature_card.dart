import 'package:flutter/material.dart';
import '../../../../../../../lib/utils/theme.dart';

class LatestFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final bool isNew;
  final String? imageUrl;

  const LatestFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.badgeText,
    this.badgeColor,
    this.onTap,
    this.isNew = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // Dynamic width with 16px margins on each side
    final iconSize = screenWidth * 0.12; // 12% of screen width
    final titleFontSize = screenWidth * 0.045; // 4.5% of screen width
    final descriptionFontSize = screenWidth * 0.035; // 3.5% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        decoration: AppTheme.cardDecoration(
          color: AppTheme.cardColor,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and badge
                Row(
                  children: [
                    // Icon container
                    Container(
                      width: iconSize,
                      height: iconSize,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(iconSize * 0.25),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? AppTheme.primaryColor,
                        size: iconSize * 0.6,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Badge if provided
                    if (badgeText != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.025,
                          vertical: screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: screenWidth * 0.04),
                
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: screenWidth * 0.02),
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: screenWidth * 0.04),
                
                // Action row
                Row(
                  children: [
                    Text(
                      'Learn More',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: screenWidth * 0.03,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            
            // New badge indicator
            if (isNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LatestFeatureCardGrid extends StatelessWidget {
  final List<LatestFeatureCardData> features;
  final int crossAxisCount;
  final double childAspectRatio;

  const LatestFeatureCardGrid({
    super.key,
    required this.features,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return LatestFeatureCard(
          title: feature.title,
          description: feature.description,
          icon: feature.icon,
          iconColor: feature.iconColor,
          badgeText: feature.badgeText,
          badgeColor: feature.badgeColor,
          onTap: feature.onTap,
          isNew: feature.isNew,
          imageUrl: feature.imageUrl,
        );
      },
    );
  }
}

class LatestFeatureCardList extends StatelessWidget {
  final List<LatestFeatureCardData> features;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const LatestFeatureCardList({
    super.key,
    required this.features,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return LatestFeatureCard(
          title: feature.title,
          description: feature.description,
          icon: feature.icon,
          iconColor: feature.iconColor,
          badgeText: feature.badgeText,
          badgeColor: feature.badgeColor,
          onTap: feature.onTap,
          isNew: feature.isNew,
          imageUrl: feature.imageUrl,
        );
      },
    );
  }
}

// Data model for the latest feature card
class LatestFeatureCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final bool isNew;
  final String? imageUrl;

  const LatestFeatureCardData({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.badgeText,
    this.badgeColor,
    this.onTap,
    this.isNew = false,
    this.imageUrl,
  });
}

// Predefined feature cards for common use cases
class PredefinedFeatureCards {
  static const List<LatestFeatureCardData> paymentFeatures = [
    LatestFeatureCardData(
      title: 'Quick Pay',
      description: 'Make instant payments with just a few taps using our enhanced payment system.',
      icon: Icons.flash_on,
      iconColor: AppTheme.warningColor,
      badgeText: 'Fast',
      badgeColor: AppTheme.warningColor,
      isNew: true,
    ),
    LatestFeatureCardData(
      title: 'Secure Wallet',
      description: 'Keep your money safe with bank-grade security and encryption.',
      icon: Icons.account_balance_wallet,
      iconColor: AppTheme.successColor,
      badgeText: 'Safe',
      badgeColor: AppTheme.successColor,
    ),
    LatestFeatureCardData(
      title: 'Bill Payments',
      description: 'Pay all your utility bills in one place with automated scheduling.',
      icon: Icons.receipt_long,
      iconColor: AppTheme.primaryColor,
      badgeText: 'Auto',
      badgeColor: AppTheme.primaryColor,
    ),
    LatestFeatureCardData(
      title: 'Money Transfer',
      description: 'Send money to friends and family instantly with zero fees.',
      icon: Icons.send,
      iconColor: AppTheme.accentColor,
      badgeText: 'Free',
      badgeColor: AppTheme.accentColor,
      isNew: true,
    ),
  ];
}