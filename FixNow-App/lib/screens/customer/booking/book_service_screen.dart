import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/app_notification.dart';
import '../../../models/booking.dart';
import '../../../models/service_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/primary_button.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key, required this.provider});
  final ServiceProviderProfile provider;

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _addressController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _confirmBooking() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    if (_date == null || _time == null || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a date, time and enter your address')),
      );
      return;
    }

    setState(() => _submitting = true);

    final dateStr = DateFormat('EEE, d MMM yyyy').format(_date!);
    final timeStr = _time!.format(context);

    try {
      final booking = Booking(
        id: '',
        customerId: user.uid,
        customerName: user.name,
        providerId: widget.provider.uid,
        providerName: widget.provider.name,
        categoryName: widget.provider.categoryName,
        date: dateStr,
        time: timeStr,
        address: _addressController.text.trim(),
        price: widget.provider.price,
        status: BookingStatus.pending,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final ref = DbService.bookings.push();
      await ref.set(booking.toMap());

      await DbService.notifications(widget.provider.uid).push().set(
            AppNotification(
              id: '',
              title: 'New booking request',
              body: '${user.name} requested $dateStr at $timeStr',
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ).toMap(),
          );
      await DbService.notifications(user.uid).push().set(
            AppNotification(
              id: '',
              title: 'Booking requested',
              body: 'Your request with ${widget.provider.name} is pending confirmation',
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ).toMap(),
          );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking requested! Track it under Bookings.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.provider.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(widget.provider.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Text(
                    'Rs ${widget.provider.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Preferred date', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            _PickerTile(
              icon: Icons.calendar_month_outlined,
              label: _date == null ? 'Choose a date' : DateFormat('EEE, d MMM yyyy').format(_date!),
              onTap: _pickDate,
            ),
            const SizedBox(height: 18),
            Text('Preferred time', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            _PickerTile(
              icon: Icons.access_time_outlined,
              label: _time == null ? 'Choose a time' : _time!.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Service address',
              hint: 'House #, street, area, city',
              controller: _addressController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Confirm Booking',
              isLoading: _submitting,
              onPressed: _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14.5)),
          ],
        ),
      ),
    );
  }
}
