import '../../../domain/entities/health_feature.dart';

class HealthAiRouteHit {
  const HealthAiRouteHit({
    required this.routeId,
    required this.featureId,
    required this.message,
  });

  final String routeId;
  final HealthFeatureId featureId;
  final String message;
}

/// Garage-style: resolve known intents to in-app screens before any LLM call.
abstract final class HealthAiInAppRouteCatalog {
  static HealthAiRouteHit? resolve(String userMessage) {
    final lower = userMessage.toLowerCase().trim();
    if (lower.isEmpty) return null;

    for (final route in _routes) {
      if (route.keywords.any(lower.contains)) {
        return HealthAiRouteHit(
          routeId: route.id,
          featureId: route.featureId,
          message: route.message,
        );
      }
    }
    return null;
  }

  static const _routes = <_Route>[
    _Route(
      id: 'timeline',
      featureId: HealthFeatureId.timeline,
      keywords: ['timeline', 'history', 'zaman çizelgesi', 'geçmiş'],
      message:
          'Open Timeline to browse your notes and measurements. [NAV:timeline]',
    ),
    _Route(
      id: 'observations',
      featureId: HealthFeatureId.observations,
      keywords: ['measurement', 'vital', 'ölçüm', 'weight', 'kilo', 'glucose'],
      message:
          'Open Measurements to add or review values with unit, time, and source. [NAV:observations]',
    ),
    _Route(
      id: 'medication',
      featureId: HealthFeatureId.medication,
      keywords: ['medication', 'medicine', 'ilaç', 'pill', 'reminder'],
      message:
          'Open Medications to log taken / snoozed / skipped. The app never changes dose. [NAV:medication]',
    ),
    _Route(
      id: 'appointments',
      featureId: HealthFeatureId.appointments,
      keywords: ['appointment', 'visit', 'randevu', 'doctor'],
      message:
          'Open Appointments for place, clinician, and question list. [NAV:appointments]',
    ),
    _Route(
      id: 'documents',
      featureId: HealthFeatureId.documents,
      keywords: ['document', 'lab', 'pdf', 'belge', 'tahlil'],
      message:
          'Open the Document vault for labs and reports stored on device. [NAV:documents]',
    ),
    _Route(
      id: 'trends',
      featureId: HealthFeatureId.trends,
      keywords: ['trend', 'chart', 'graph', 'grafik'],
      message:
          'Open Trends to see measurements with gaps left empty (not filled). [NAV:trends]',
    ),
    _Route(
      id: 'sharing',
      featureId: HealthFeatureId.sharing,
      keywords: ['share', 'export', 'pdf', 'csv', 'paylaş'],
      message:
          'Open Sharing to export selected categories with expiry and revoke. [NAV:sharing]',
    ),
  ];
}

class _Route {
  const _Route({
    required this.id,
    required this.featureId,
    required this.keywords,
    required this.message,
  });

  final String id;
  final HealthFeatureId featureId;
  final List<String> keywords;
  final String message;
}
