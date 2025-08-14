import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_bloc.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_event.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_state.dart';
import 'package:spor_salonu/presentation/blocs/reservation/reservation_bloc.dart';
import 'package:spor_salonu/presentation/pages/profile/profile_page.dart';
import 'package:spor_salonu/presentation/pages/reservation/my_reservations_page.dart';
import 'package:spor_salonu/presentation/widgets/custom_app_bar.dart';
import 'package:spor_salonu/presentation/widgets/facility_card.dart';
import 'package:spor_salonu/presentation/widgets/loading_indicator.dart';
import 'package:spor_salonu/presentation/widgets/upcoming_reservation_card.dart';
import 'package:spor_salonu/presentation/pages/reservation/reservation_calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Load facilities when the page is initialized
    context.read<FacilityBloc>().add(const LoadFacilities());
    // Load user's upcoming reservations
    if (context.read<AuthBloc>().state is Authenticated) {
      final User user = (context.read<AuthBloc>().state as Authenticated).user;
      context.read<ReservationBloc>().add(LoadUserReservations(userId: user.uid));
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 
          ? CustomAppBar(
              title: 'Fitness Center',
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications page
                  },
                ),
              ],
            )
          : null,
      body: _getBodyWidget(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Rezervasyonlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MyReservationsPage();
      case 2:
        return const ProfilePage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    // Extract the name part from email (before @)
                    String emailName = state.user.email?.split('@')[0] ?? 'Kullanıcı';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, $emailName!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bugün ne yapmak istersin?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming reservations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Yaklaşan Rezervasyonlarım',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BlocBuilder<ReservationBloc, ReservationState>(
                builder: (context, state) {
                  if (state is ReservationLoading) {
                    return const Center(child: LoadingIndicator());
                  } else if (state is UserReservationsLoaded && state.upcomingReservations.isNotEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.upcomingReservations.length,
                      itemBuilder: (context, index) {
                        final reservation = state.upcomingReservations[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: UpcomingReservationCard(
                            reservation: reservation,
                            facility: state.facilities[reservation.facilityId]!,
                            onTap: () {
                              // TODO: Navigate to reservation details
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Yaklaşan rezervasyonun yok',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Facilities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Fitness Center',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<FacilityBloc, FacilityState>(
              builder: (context, state) {
                if (state is FacilityLoading) {
                  return const Center(child: LoadingIndicator());
                } else if (state is FacilitiesLoaded) {
                  if (state.facilities.isEmpty) {
                    return const Center(
                      child: Text('Fitness center information not available'),
                    );
                  }
                  
                  // Show only the fitness center (first facility)
                  final facility = state.facilities.first;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FacilityCard(
                      facility: facility,
                      assetImage: 'assets/images/gym.jpg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReservationCalendarPage(facility: facility),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is FacilityError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}