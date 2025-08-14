import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:spor_salonu/data/models/facility_model.dart';
import 'package:spor_salonu/presentation/blocs/reservation/reservation_bloc.dart';

class ReservationCalendarPage extends StatefulWidget {
  final FacilityModel facility;

  const ReservationCalendarPage({
    super.key,
    required this.facility,
  });

  @override
  State<ReservationCalendarPage> createState() => _ReservationCalendarPageState();
}

class _ReservationCalendarPageState extends State<ReservationCalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // Load reservations for today
    _loadReservationsForDate(_selectedDay);
  }

  void _loadReservationsForDate(DateTime date) {
    context.read<ReservationBloc>().add(
      LoadDailyReservationCounts(
        facilityId: widget.facility.id,
        date: date,
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _loadReservationsForDate(selectedDay);
  }

  void _makeReservation(int hourSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Reservation'),
        content: Text(
          'Are you sure you want to make a reservation for the fitness center at ${hourSlot.toString().padLeft(2, '0')}:00?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReservationBloc>().add(
                CreateReservation(
                  facilityId: widget.facility.id,
                  date: _selectedDay,
                  hourSlot: hourSlot,
                ),
              );
            },
            child: const Text('Reserve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Center Reservation'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: BlocConsumer<ReservationBloc, ReservationState>(
              listener: (context, state) {
                if (state is ReservationCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation created successfully')),
                  );
                  _loadReservationsForDate(_selectedDay);
                } else if (state is ReservationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is ReservationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DailyReservationCountsLoaded) {
                  return _buildHourlyAvailability(state);
                } else {
                  return const Center(child: Text('Select a day to see availability'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyAvailability(DailyReservationCountsLoaded state) {
    // Only show hours between 6 AM and 10 PM for the fitness center
    const int startHour = 6;
    const int endHour = 22;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: endHour - startHour,
      itemBuilder: (context, index) {
        final hour = startHour + index;
        final count = state.hourlyCounts[hour] ?? 0;
        final availability = state.maxCapacity - count;
        final isAvailable = availability > 0;

        final startTimeStr = '${hour.toString().padLeft(2, '0')}:00';
        final endTimeStr = '${(hour + 1).toString().padLeft(2, '0')}:00';

        // Calculate occupancy percentage
        final occupancyPercent = (count / state.maxCapacity * 100).toInt();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isAvailable ? Colors.white : Colors.grey.shade200,
          child: ListTile(
            title: Text('$startTimeStr - $endTimeStr'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Occupancy: $occupancyPercent% ($count/${state.maxCapacity})'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: count / state.maxCapacity,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    occupancyPercent > 80 ? Colors.red :
                    occupancyPercent > 50 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            trailing: isAvailable
                ? ElevatedButton(
              onPressed: () => _makeReservation(hour),
              child: const Text('Reserve'),
            )
                : const Text('Full', style: TextStyle(color: Colors.red)),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}