import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/app_notification.dart';
import '../../../models/booking.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/status_badge.dart';
import 'rate_review_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.booking});
  final Booking booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Booking _booking = widget.booking;
  bool _busy = false;

  bool get _canModify =>
      _booking.status == BookingStatus.pending || _booking.status == BookingStatus.accepted;

  Future<void> _notifyProvider(String title, String body) async {
    await DbService.notifications(_booking.providerId).push().set(
          AppNotification(id: '', title: title, body: body, createdAt: DateTime.now().millisecondsSinceEpoch)
              .toMap(),
        );
  }

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This will cancel your request with the provider.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep booking')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel booking')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await DbService.bookings.child(_booking.id).update({'status': BookingStatus.cancelled.storageValue});
      await _notifyProvider('Booking cancelled', '${_booking.customerName} cancelled the ${_booking.date} booking');
      if (!mounted) return;
      setState(() {
        _booking = Booking.fromMap(_booking.id, {..._booking.toMap(), 'status': BookingStatus.cancelled.storageValue});
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reschedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null || !mounted) return;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(date);
    final timeStr = time.format(context);

    setState(() => _busy = true);
    try {
      await DbService.bookings.child(_booking.id).update({'date': dateStr, 'time': timeStr});
      await _notifyProvider(
        'Booking rescheduled',
        '${_booking.customerName} moved the booking to $dateStr at $timeStr',
      );
      if (!mounted) return;
      setState(() {
        _booking = Booking.fromMap(_booking.id, {..._booking.toMap(), 'date': dateStr, 'time': timeStr});
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b.categoryName, style: Theme.of(context).textTheme.headlineSmall),
              StatusBadge(status: b.status),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(icon: Icons.engineering_outlined, label: 'Provider', value: b.providerName),
          _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: b.date),
          _DetailRow(icon: Icons.access_time_outlined, label: 'Time', value: b.time),
          _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: b.address),
          _DetailRow(icon: Icons.payments_outlined, label: 'Charge', value: 'Rs ${b.price.toStringAsFixed(0)}'),
          const SizedBox(height: 28),
          if (_canModify) ...[
            PrimaryButton(label: 'Reschedule', isLoading: _busy, onPressed: _reschedule),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _cancelBooking,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Cancel Booking'),
            ),
          ],
          if (b.status == BookingStatus.completed && !b.reviewed)
            PrimaryButton(
              label: 'Rate & Review',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RateReviewScreen(booking: b)),
                );
                if (mounted) {
                  setState(() {
                    _booking = Booking.fromMap(b.id, {...b.toMap(), 'reviewed': true});
                  });
                }
              },
            ),
          if (b.status == BookingStatus.completed && b.reviewed)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Thanks for your review!', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
