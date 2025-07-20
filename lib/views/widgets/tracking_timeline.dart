import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/parcel_model.dart';
import '../../../utils/theme.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingUpdate> trackingUpdates;
  final ParcelStatus currentStatus;

  const TrackingTimeline({
    super.key,
    required this.trackingUpdates,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final allStatuses = _getAllStatuses();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Timeline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...allStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final statusInfo = entry.value;
            final isLast = index == allStatuses.length - 1;
            
            return TimelineItem(
              statusInfo: statusInfo,
              isCompleted: statusInfo.isCompleted,
              isCurrent: statusInfo.isCurrent,
              isLast: isLast,
              index: index,
            );
          }),
        ],
      ),
    );
  }

  List<StatusInfo> _getAllStatuses() {
    final statuses = [
      ParcelStatus.pending,
      ParcelStatus.confirmed,
      ParcelStatus.collected,
      ParcelStatus.inTransit,
      ParcelStatus.outForDelivery,
      ParcelStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(currentStatus);
    
    return statuses.asMap().entries.map((entry) {
      final index = entry.key;
      final status = entry.value;
      
      // Find corresponding tracking update
      final update = trackingUpdates.where((u) => u.status == status).lastOrNull;
      
      return StatusInfo(
        status: status,
        update: update,
        isCompleted: index <= currentIndex,
        isCurrent: index == currentIndex,
      );
    }).toList();
  }
}

class StatusInfo {
  final ParcelStatus status;
  final TrackingUpdate? update;
  final bool isCompleted;
  final bool isCurrent;

  StatusInfo({
    required this.status,
    this.update,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class TimelineItem extends StatelessWidget {
  final StatusInfo statusInfo;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final int index;

  const TimelineItem({
    super.key,
    required this.statusInfo,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                _buildTimelineNode(),
                if (!isLast) _buildTimelineConnector(),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 200))
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.3, end: 0);
  }

  Widget _buildTimelineNode() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getNodeColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(),
          width: 3,
        ),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: _getNodeColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Icon(
        _getStatusIcon(),
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTimelineConnector() {
    return Expanded(
      child: Container(
        width: 2,
        color: isCompleted ? AppTheme.primaryColor : AppTheme.dividerColor,
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _getStatusTitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ),
            if (statusInfo.update != null)
              Text(
                _formatTime(statusInfo.update!.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        
        if (statusInfo.update != null) ...[
          const SizedBox(height: 4),
          Text(
            statusInfo.update!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          
          if (statusInfo.update!.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    statusInfo.update!.location!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ] else if (!isCompleted) ...[
          const SizedBox(height: 4),
          Text(
            'Pending',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        if (isCurrent) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 1000.ms)
                  .fadeOut(duration: 1000.ms),
                const SizedBox(width: 8),
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getNodeColor() {
    if (isCurrent) {
      return AppTheme.primaryColor;
    } else if (isCompleted) {
      return AppTheme.successColor;
    } else {
      return AppTheme.dividerColor;
    }
  }

  Color _getBorderColor() {
    if (isCurrent) {
      return AppTheme.primaryColor.withOpacity(0.3);
    } else if (isCompleted) {
      return AppTheme.successColor.withOpacity(0.3);
    } else {
      return AppTheme.dividerColor;
    }
  }

  IconData _getStatusIcon() {
    if (isCompleted) {
      return Icons.check;
    } else if (isCurrent) {
      return _getStatusSpecificIcon();
    } else {
      return Icons.radio_button_unchecked;
    }
  }

  IconData _getStatusSpecificIcon() {
    switch (statusInfo.status) {
      case ParcelStatus.pending:
        return Icons.pending;
      case ParcelStatus.confirmed:
        return Icons.check_circle;
      case ParcelStatus.collected:
        return Icons.inventory_2;
      case ParcelStatus.inTransit:
        return Icons.local_shipping;
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining;
      case ParcelStatus.delivered:
        return Icons.task_alt;
      case ParcelStatus.cancelled:
        return Icons.cancel;
      case ParcelStatus.returned:
        return Icons.keyboard_return;
    }
  }

  String _getStatusTitle() {
    switch (statusInfo.status) {
      case ParcelStatus.pending:
        return 'Order Placed';
      case ParcelStatus.confirmed:
        return 'Order Confirmed';
      case ParcelStatus.collected:
        return 'Parcel Collected';
      case ParcelStatus.inTransit:
        return 'In Transit';
      case ParcelStatus.outForDelivery:
        return 'Out for Delivery';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.cancelled:
        return 'Cancelled';
      case ParcelStatus.returned:
        return 'Returned';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Today
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } else {
      // Older
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }
}

// Enhanced timeline with animations
class AnimatedTrackingTimeline extends StatefulWidget {
  final List<TrackingUpdate> trackingUpdates;
  final ParcelStatus currentStatus;

  const AnimatedTrackingTimeline({
    super.key,
    required this.trackingUpdates,
    required this.currentStatus,
  });

  @override
  State<AnimatedTrackingTimeline> createState() => _AnimatedTrackingTimelineState();
}

class _AnimatedTrackingTimelineState extends State<AnimatedTrackingTimeline>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return TrackingTimeline(
          trackingUpdates: widget.trackingUpdates,
          currentStatus: widget.currentStatus,
        );
      },
    );
  }
}