import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traveloop/models/trip.dart';
import 'package:traveloop/providers/auth_provider.dart';
import 'package:traveloop/providers/trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final Trip? trip;
  final String? initialTitle;
  const CreateTripScreen({super.key, this.trip, this.initialTitle});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _budgetController;

  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isPublic;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.trip?.title ?? widget.initialTitle ?? '',
    );
    _descController = TextEditingController(
      text: widget.trip?.description ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.trip?.budget.toString() ?? '0.0',
    );
    _startDate = widget.trip?.startDate;
    _endDate = widget.trip?.endDate;
    _isPublic = widget.trip?.isPublic ?? false;
  }

  void _saveTrip() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      setState(() => _isLoading = true);

      final user = ref.read(currentUserProvider);
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final tripData = Trip(
        id: widget.trip?.id ?? '',
        userId: user.id,
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        isPublic: _isPublic,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        createdAt: widget.trip?.createdAt ?? DateTime.now(),
      );

      if (widget.trip == null) {
        await ref.read(tripNotifierProvider.notifier).createTrip(tripData);
      } else {
        await ref.read(tripNotifierProvider.notifier).updateTrip(tripData);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        final state = ref.read(tripNotifierProvider);
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          context.pop(); // Go back to previous screen
        }
      }
    } else if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select travel dates')),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoadingState = ref.watch(tripNotifierProvider).isLoading;
    final isSaving = _isLoading || isLoadingState;
    final isEditing = widget.trip != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Trip Info' : 'Plan a New Trip',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _saveTrip,
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo Placeholder
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing ? 'Change Cover Photo' : 'Add Cover Photo',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'e.g. Summer in Paris',
                  prefixIcon: const Icon(Icons.flight_takeoff),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'What is this trip about?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Budget (USD)',
                  hintText: 'e.g. 3000.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Travel Dates',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (_startDate != null && _endDate != null)
                                  ? '${DateFormat("MMM d").format(_startDate!)} - ${DateFormat("MMM d, y").format(_endDate!)}'
                                  : 'Select Dates',
                              style: TextStyle(
                                fontSize: 16,
                                color: (_startDate != null)
                                    ? theme.colorScheme.onSurface
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Public Toggle
              SwitchListTile(
                title: const Text('Make Trip Public'),
                subtitle: const Text(
                  'Allow others to view and clone this itinerary',
                ),
                value: _isPublic,
                activeTrackColor: theme.colorScheme.primary.withValues(
                  alpha: 0.5,
                ),
                activeThumbColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
