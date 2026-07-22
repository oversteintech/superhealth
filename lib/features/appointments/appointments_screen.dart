import 'package:flutter/material.dart';

import '../doctor_visits/doctor_visits_screen.dart';

/// Compatibility alias — Doctor Visits is the canonical feature.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) => const DoctorVisitsScreen();
}