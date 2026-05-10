import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traveloop/models/trip.dart';
import 'package:traveloop/providers/auth_provider.dart';
import 'package:traveloop/providers/itinerary_provider.dart';
import 'package:traveloop/providers/trip_provider.dart';

class PublicItineraryScreen extends ConsumerWidget {
  final String tripId;
  const PublicItineraryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripAsync = ref.watch(tripByIdProvider(tripId));
    final stopsAsync = ref.watch(tripStopsProvider(tripId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Public Itinerary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: tripAsync.when(
        data: (trip) {
          if (!trip.isPublic && trip.userId != currentUser?.id) {
            return const Center(child: Text('This itinerary is private.'));
          }

          return Column(
            children: [
              _buildTripHeader(theme, trip),
              if (currentUser != null && currentUser.id != trip.userId)
                _buildCloneAction(context, ref, trip),
              Expanded(
                child: stopsAsync.when(
                  data: (stops) => _buildStopsList(theme, stops),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('Error loading stops: $err')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading trip: $err')),
      ),
    );
  }

  Widget _buildTripHeader(ThemeData theme, Trip trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, y').format(trip.endDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          if (trip.description != null && trip.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(trip.description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildCloneAction(BuildContext context, WidgetRef ref, Trip trip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clone Itinerary'),
              content: const Text(
                'Copy this trip and all its destinations into your "My Trips"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Clone'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await ref.read(tripNotifierProvider.notifier).cloneTrip(trip.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Trip cloned successfully! View it in My Trips.',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to clone trip: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        icon: const Icon(Icons.copy),
        label: const Text('Save to My Trips'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStopsList(ThemeData theme, List<dynamic> stops) {
    if (stops.isEmpty) {
      return const Center(child: Text('No destinations in this itinerary.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 12,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    stop.locationName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36.0),
                child: Text(
                  '${DateFormat('MMM d').format(stop.arrivalDate)} - ${DateFormat('MMM d').format(stop.departureDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              _PublicActivityList(stopId: stop.id, theme: theme),
            ],
          ),
        );
      },
    );
  }
}

class _PublicActivityList extends ConsumerWidget {
  final String stopId;
  final ThemeData theme;
  const _PublicActivityList({required this.stopId, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(stopActivitiesProvider(stopId));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Column(
            children: activities
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            a.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
