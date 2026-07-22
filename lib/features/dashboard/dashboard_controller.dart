import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/infrastructure_providers.dart';
import '../../domain/entities/doctor_visit.dart';
import '../../domain/entities/health_insight.dart';
import '../../domain/entities/health_profile.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/vital_reading.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.profile,
    required this.vitals,
    required this.medications,
    required this.visits,
    required this.insights,
  });

  final HealthProfile profile;
  final List<VitalReading> vitals;
  final List<Medication> medications;
  final List<DoctorVisit> visits;
  final List<HealthInsight> insights;
}

final dashboardProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  final profile = await repo.getProfile();
  final vitals = await repo.getVitals();
  final medications = await repo.getMedications();
  final visits = await repo.getDoctorVisits();
  final insights = await repo.getInsights();
  return DashboardSnapshot(
    profile: profile,
    vitals: vitals,
    medications: medications,
    visits: visits,
    insights: insights,
  );
});