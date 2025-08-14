import 'package:flutter/material.dart';
import 'package:spor_salonu/data/models/reservation_model.dart';
import 'package:spor_salonu/data/models/facility_model.dart';

class UpcomingReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final FacilityModel facility;
  final VoidCallback onTap;

  const UpcomingReservationCard({
    super.key,
    required this.reservation,
    required this.facility,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${reservation.startTime} - ${reservation.endTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}