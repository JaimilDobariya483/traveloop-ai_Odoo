import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:traveloop/models/activity.dart';
import 'package:traveloop/models/stop.dart';
import 'package:traveloop/providers/itinerary_provider.dart';
import 'package:traveloop/providers/trip_provider.dart';

class ItineraryBuilderScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ItineraryBuilderScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryBuilderScreen> createState() =>
      _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState
    extends ConsumerState<ItineraryBuilderScreen> {
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onReorder(int oldIndex, int newIndex, List<Stop> stops) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final stop = stops[oldIndex];
    await ref.read(itineraryServiceProvider).updateStopOrder(stop.id, newIndex);
    ref.invalidate(tripStopsProvider(widget.tripId));
  }

  void _addStop() {
    _showAddStopDialog(context);
  }

  Future<void> _showAddStopDialog(BuildContext context) async {
    final locationController = TextEditingController();
    DateTime? arrivalDate;
    DateTime? departureDate;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  arrivalDate = picked.start;
                  departureDate = picked.end;
                }
              },
              child: const Text('Select Dates'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (locationController.text.isNotEmpty &&
                  arrivalDate != null &&
                  departureDate != null) {
                final stop = Stop(
                  id: '',
                  tripId: widget.tripId,
                  locationName: locationController.text,
                  arrivalDate: arrivalDate!,
                  departureDate: departureDate!,
                  orderIndex: 0,
                );
                await ref.read(itineraryServiceProvider).createStop(stop);
                ref.invalidate(tripStopsProvider(widget.tripId));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stopsAsync = ref.watch(tripStopsProvider(widget.tripId));
    final tripAsync = ref.watch(tripByIdProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Itinerary Builder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            tooltip: 'Toggle View',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolsRow(context, theme),
          Expanded(
            child: tripAsync.when(
              data: (trip) => stopsAsync.when(
                data: (stops) => _isCalendarView
                    ? _buildCalendarView(theme, trip, stops)
                    : _buildListView(theme, stops),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error loading stops: $err')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading trip: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStop,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Stop'),
      ),
    );
  }

  Widget _buildToolsRow(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolButton(
            context,
            Icons.account_balance_wallet,
            'Budget',
            '/budget/${widget.tripId}',
            theme,
          ),
          _buildToolButton(
            context,
            Icons.backpack,
            'Packing',
            '/packing/${widget.tripId}',
            theme,
          ),
          _buildToolButton(
            context,
            Icons.menu_book,
            'Journal',
            '/notes/${widget.tripId}',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(ThemeData theme, List<Stop> stops) {
    if (stops.isEmpty) {
      return const Center(
        child: Text('No stops planned yet. Add your first destination!'),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Drag and drop to reorder your destinations.'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stops.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(oldIndex, newIndex, stops),
            itemBuilder: (context, index) {
              final stop = stops[index];
              return StopCard(
                key: ValueKey(stop.id),
                stop: stop,
                index: index,
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(ThemeData theme, dynamic trip, List<Stop> stops) {
    return Column(
      children: [
        TableCalendar(
          firstDay: trip.startDate,
          lastDay: trip.endDate,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const Divider(),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('Select a day to see activities'))
              : _buildDayActivities(theme, _selectedDay!, stops),
        ),
      ],
    );
  }

  Widget _buildDayActivities(ThemeData theme, DateTime day, List<Stop> stops) {
    // Find stops that include this day
    final stopsOnDay = stops
        .where(
          (s) =>
              (s.arrivalDate.isBefore(day) || isSameDay(s.arrivalDate, day)) &&
              (s.departureDate.isAfter(day) || isSameDay(s.departureDate, day)),
        )
        .toList();

    if (stopsOnDay.isEmpty) {
      return const Center(child: Text('No stops scheduled for this day.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stopsOnDay.length,
      itemBuilder: (context, index) {
        final stop = stopsOnDay[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'At ${stop.locationName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // We'd need to filter activities by this day too if they had dates
            // For now, just showing all activities for the stop on that day
            _ActivityDayList(stopId: stop.id, day: day, theme: theme),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ActivityDayList extends ConsumerWidget {
  final String stopId;
  final DateTime day;
  final ThemeData theme;

  const _ActivityDayList({
    required this.stopId,
    required this.day,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(stopActivitiesProvider(stopId));

    return activitiesAsync.when(
      data: (activities) {
        // Filter activities for this day if they have a date
        final dailyActivities = activities
            .where(
              (a) => a.activityDate == null || isSameDay(a.activityDate, day),
            )
            .toList();

        if (dailyActivities.isEmpty) {
          return const Text(
            'No activities for this day.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        return Column(
          children: dailyActivities
              .map(
                (activity) => _ActivityItem(activity: activity, theme: theme),
              )
              .toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class StopCard extends ConsumerWidget {
  final Stop stop;
  final int index;
  final ThemeData theme;

  const StopCard({
    super.key,
    required this.stop,
    required this.index,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(stopActivitiesProvider(stop.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(
          stop.locationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM d').format(stop.arrivalDate)} - ${DateFormat('MMM d').format(stop.departureDate)}',
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                activitiesAsync.when(
                  data: (activities) => _buildDayWiseActivities(activities),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading activities: $err'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddActivityDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Activity'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Stop'),
                            content: const Text(
                              'Are you sure you want to delete this destination and all its activities?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(itineraryServiceProvider)
                              .deleteStop(stop.id);
                          ref.invalidate(tripStopsProvider(stop.tripId));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayWiseActivities(List<TripActivity> activities) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No activities added yet.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    // Calculate days
    final daysCount =
        stop.departureDate.difference(stop.arrivalDate).inDays + 1;
    final List<Widget> dayWidgets = [];

    for (int i = 0; i < daysCount; i++) {
      final currentDay = stop.arrivalDate.add(Duration(days: i));
      final dayActivities = activities
          .where(
            (a) =>
                a.activityDate == null || isSameDay(a.activityDate, currentDay),
          )
          .toList();

      if (dayActivities.isNotEmpty) {
        dayWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${i + 1} - ${DateFormat('MMM d').format(currentDay)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                ...dayActivities.map(
                  (a) => _ActivityItem(activity: a, theme: theme),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Handle activities with no date if any weren't matched (though logic above matches all if date is null)
    return Column(children: dayWidgets);
  }

  void _showAddActivityDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    DateTime? selectedDate = stop.arrivalDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Activity Title'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM d, y').format(selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate!,
                    firstDate: stop.arrivalDate,
                    lastDate: stop.departureDate,
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final activity = TripActivity(
                    id: '',
                    stopId: stop.id,
                    title: titleController.text,
                    activityDate: selectedDate,
                  );
                  await ref
                      .read(itineraryServiceProvider)
                      .createActivity(activity);
                  ref.invalidate(stopActivitiesProvider(stop.id));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends ConsumerWidget {
  final TripActivity activity;
  final ThemeData theme;

  const _ActivityItem({required this.activity, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Activity'),
              content: Text('Delete "${activity.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref
                .read(itineraryServiceProvider)
                .deleteActivity(activity.id);
            ref.invalidate(stopActivitiesProvider(activity.stopId));
          }
        },
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(activity.title, style: const TextStyle(fontSize: 14)),
            ),
            if (activity.cost != null)
              Text(
                '\$${activity.cost!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
