import 'package:flutter/material.dart';
import 'widgets/latestfeature_card.dart';
import '../../../../../lib/utils/theme.dart';

class SpayHomeDemoScreen extends StatelessWidget {
  const SpayHomeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sheba Pay - Latest Features'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover New Features',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore the latest updates and enhancements to make your payment experience even better.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Single feature card example
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Featured Update',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            LatestFeatureCard(
              title: 'Enhanced Security',
              description: 'We\'ve upgraded our security system with biometric authentication and advanced encryption to keep your transactions safer than ever.',
              icon: Icons.security,
              iconColor: AppTheme.successColor,
              badgeText: 'Security',
              badgeColor: AppTheme.successColor,
              isNew: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Security feature tapped!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Feature cards list
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'All Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            LatestFeatureCardList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              features: PredefinedFeatureCards.paymentFeatures,
            ),
            
            const SizedBox(height: 24),
            
            // Grid layout example
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            LatestFeatureCardGrid(
              features: [
                const LatestFeatureCardData(
                  title: 'QR Payments',
                  description: 'Scan and pay instantly',
                  icon: Icons.qr_code_scanner,
                  iconColor: AppTheme.primaryColor,
                ),
                const LatestFeatureCardData(
                  title: 'Voice Pay',
                  description: 'Pay with voice commands',
                  icon: Icons.mic,
                  iconColor: AppTheme.accentColor,
                  isNew: true,
                ),
                const LatestFeatureCardData(
                  title: 'Smart Savings',
                  description: 'Automated saving plans',
                  icon: Icons.savings,
                  iconColor: AppTheme.warningColor,
                ),
                const LatestFeatureCardData(
                  title: 'Cashback Rewards',
                  description: 'Earn rewards on every transaction',
                  icon: Icons.card_giftcard,
                  iconColor: AppTheme.successColor,
                  badgeText: 'Rewards',
                  badgeColor: AppTheme.successColor,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}