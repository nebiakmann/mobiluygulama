import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spor_salonu/presentation/blocs/reservation/reservation_bloc.dart';
import 'package:spor_salonu/presentation/widgets/loading_indicator.dart';
import 'package:spor_salonu/services/reservation_cleanup_service.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif Rezervasyonlar'),
            Tab(text: 'Geçmiş Rezervasyonlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveReservations(),
          _buildPastReservations(),
        ],
      ),
    );
  }

  // Rezervasyonun saatinin geçip geçmediğini kontrol eden yardımcı method
  bool _isReservationPast(dynamic reservation) {
    try {
      final now = DateTime.now();
      final reservationDate = reservation.date;

      // Eğer rezervasyon tarihi bugünden önceyse, kesinlikle geçmiştir
      if (reservationDate.isBefore(DateTime(now.year, now.month, now.day))) {
        return true;
      }

      // Eğer rezervasyon tarihi bugünse, saati kontrol et
      if (reservationDate.year == now.year &&
          reservationDate.month == now.month &&
          reservationDate.day == now.day) {

        // endTime formatını parse et (örn: "14:30")
        final endTimeParts = reservation.endTime.split(':');
        if (endTimeParts.length == 2) {
          final endHour = int.tryParse(endTimeParts[0]) ?? 0;
          final endMinute = int.tryParse(endTimeParts[1]) ?? 0;

          final reservationEndTime = DateTime(
            reservationDate.year,
            reservationDate.month,
            reservationDate.day,
            endHour,
            endMinute,
          );

          // Eğer rezervasyonun bitiş saati geçmişse, geçmiş rezervasyon olarak say
          return now.isAfter(reservationEndTime);
        }
      }

      // Gelecek tarihli rezervasyonlar aktif
      return false;
    } catch (e) {
      // Hata durumunda güvenli tarafta kal, aktif olarak kabul et
      return false;
    }
  }

  Widget _buildActiveReservations() {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        if (state is ReservationLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is UserReservationsLoaded && state.upcomingReservations.isNotEmpty) {
          // Saati geçmemiş rezervasyonları filtrele
          final activeReservations = ReservationCleanupService.filterActiveReservations(state.upcomingReservations);

          if (activeReservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aktif rezervasyonunuz bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: activeReservations.length,
            itemBuilder: (context, index) {
              final reservation = activeReservations[index];
              final facility = state.facilities[reservation.facilityId];

              if (facility == null) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    facility.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(reservation.date),
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
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getStatusText(reservation.status),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: reservation.status == 'pending' || reservation.status == 'approved'
                      ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'cancel') {
                        _showCancelDialog(context, reservation.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('İptal Et'),
                      ),
                    ],
                  )
                      : null,
                  onTap: () {
                    // TODO: Navigate to reservation details
                  },
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Aktif rezervasyonunuz bulunmamaktadır',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildPastReservations() {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        if (state is ReservationLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is UserReservationsLoaded) {
          // Geçmiş rezervasyonları ve saati geçen rezervasyonları birleştir
          final allPastReservations = ReservationCleanupService.getAllPastReservations(
              state.pastReservations,
              state.upcomingReservations
          );

          if (allPastReservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Geçmiş rezervasyonunuz bulunmamaktadır',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: allPastReservations.length,
            itemBuilder: (context, index) {
              final reservation = allPastReservations[index];
              final facility = state.facilities[reservation.facilityId];

              if (facility == null) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.grey.shade50, // Geçmiş rezervasyonlar için farklı renk
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    facility.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(reservation.date),
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
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getStatusText(reservation.status),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to reservation details
                  },
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Geçmiş rezervasyonunuz bulunmamaktadır',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _showCancelDialog(BuildContext context, String reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu İptal Et'),
        content: const Text('Bu rezervasyonu iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReservationBloc>().add(
                CancelReservation(reservationId: reservationId),
              );
            },
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Onay Bekliyor';
      case 'approved':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      case 'cancelled':
        return 'İptal Edildi';
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }
}