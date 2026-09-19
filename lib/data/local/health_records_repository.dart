import 'package:uuid/uuid.dart';

import '../../domain/records/audit_event.dart';
import '../../domain/records/care_appointment.dart';
import '../../domain/records/care_circle_member.dart';
import '../../domain/records/emergency_card_record.dart';
import '../../domain/records/habit_record.dart';
import '../../domain/records/health_document.dart';
import '../../domain/records/health_profile_record.dart';
import '../../domain/records/medication_record.dart';
import '../../domain/records/observation.dart';
import '../../domain/records/share_grant.dart';
import '../../domain/records/symptom_entry.dart';
import '../../domain/sharing/share_export_builder.dart';
import 'prefs_health_local_database.dart';

/// Domain-facing local repository over Drift-shaped storage.
class HealthRecordsRepository {
  HealthRecordsRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final PrefsHealthLocalDatabase _db;
  final Uuid _uuid;

  static const profiles = 'health_profiles';
  static const observations = 'observations';
  static const symptoms = 'symptom_entries';
  static const habits = 'habit_goals';
  static const habitLogs = 'habit_logs';
  static const medications = 'medication_records';
  static const adherence = 'medication_adherence_events';
  static const appointments = 'care_appointments';
  static const documents = 'health_documents';
  static const emergency = 'emergency_cards';
  static const shares = 'share_grants';
  static const careCircle = 'care_circle_members';
  static const audit = 'audit_events';

  // —— Profile ——
  Future<void> saveProfile(HealthProfile profile) => _db.upsert(
        table: profiles,
        ownerUserId: profile.ownerUserId,
        id: profile.id,
        row: profile.toJson(),
      );

  HealthProfile? profileFor(String ownerUserId) {
    final rows = _db.list(table: profiles, ownerUserId: ownerUserId);
    if (rows.isEmpty) return null;
    return HealthProfile.fromJson(rows.first);
  }

  // —— Observations ——
  Future<void> upsertObservation(Observation o) => _db.upsert(
        table: observations,
        ownerUserId: o.ownerUserId,
        id: o.id,
        row: o.toJson(),
      );

  Future<void> deleteObservation({
    required String ownerUserId,
    required String id,
  }) =>
      _db.delete(table: observations, ownerUserId: ownerUserId, id: id);

  List<Observation> listObservations(String ownerUserId) {
    return _db
        .list(table: observations, ownerUserId: ownerUserId)
        .map(Observation.fromJson)
        .toList()
      ..sort((a, b) => b.measuredAtUtc.compareTo(a.measuredAtUtc));
  }

  // —— Symptoms ——
  Future<void> upsertSymptom(SymptomEntry e) => _db.upsert(
        table: symptoms,
        ownerUserId: e.ownerUserId,
        id: e.id,
        row: e.toJson(),
      );

  List<SymptomEntry> listSymptoms(String ownerUserId) => _db
      .list(table: symptoms, ownerUserId: ownerUserId)
      .map(SymptomEntry.fromJson)
      .toList()
    ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  // —— Habits ——
  Future<void> upsertHabit(HabitGoal g) => _db.upsert(
        table: habits,
        ownerUserId: g.ownerUserId,
        id: g.id,
        row: g.toJson(),
      );

  List<HabitGoal> listHabits(String ownerUserId) => _db
      .list(table: habits, ownerUserId: ownerUserId)
      .map(HabitGoal.fromJson)
      .where((g) => g.active)
      .toList();

  Future<void> logHabit(HabitLog log) => _db.upsert(
        table: habitLogs,
        ownerUserId: log.ownerUserId,
        id: log.id,
        row: log.toJson(),
      );

  List<HabitLog> habitLogsForDay(String ownerUserId, String dayKey) => _db
      .list(table: habitLogs, ownerUserId: ownerUserId)
      .map(HabitLog.fromJson)
      .where((l) => l.dayKey == dayKey)
      .toList();

  // —— Medications ——
  Future<void> upsertMedication(MedicationRecord m) => _db.upsert(
        table: medications,
        ownerUserId: m.ownerUserId,
        id: m.id,
        row: m.toJson(),
      );

  List<MedicationRecord> listMedications(String ownerUserId) => _db
      .list(table: medications, ownerUserId: ownerUserId)
      .map(MedicationRecord.fromJson)
      .where((m) => m.active)
      .toList();

  Future<MedicationAdherenceEvent> markAdherence({
    required String ownerUserId,
    required String medicationId,
    required DateTime scheduledFor,
    required AdherenceStatus status,
    Duration snoozeFor = const Duration(minutes: 15),
  }) async {
    final event = MedicationAdherenceEvent(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      medicationId: medicationId,
      scheduledFor: scheduledFor.toUtc(),
      status: status,
      recordedAt: DateTime.now().toUtc(),
      snoozeUntil: status == AdherenceStatus.snoozed
          ? DateTime.now().toUtc().add(snoozeFor)
          : null,
    );
    await _db.upsert(
      table: adherence,
      ownerUserId: ownerUserId,
      id: event.id,
      row: event.toJson(),
    );
    return event;
  }

  List<MedicationAdherenceEvent> listAdherence(String ownerUserId) => _db
      .list(table: adherence, ownerUserId: ownerUserId)
      .map(MedicationAdherenceEvent.fromJson)
      .toList()
    ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

  MedicationAdherenceEvent? latestAdherenceFor(
    String ownerUserId,
    String medicationId,
  ) {
    final events = listAdherence(ownerUserId)
        .where((e) => e.medicationId == medicationId)
        .toList();
    return events.isEmpty ? null : events.first;
  }

  // —— Appointments ——
  Future<void> upsertAppointment(CareAppointment a) => _db.upsert(
        table: appointments,
        ownerUserId: a.ownerUserId,
        id: a.id,
        row: a.toJson(),
      );

  List<CareAppointment> listAppointments(String ownerUserId) => _db
      .list(table: appointments, ownerUserId: ownerUserId)
      .map(CareAppointment.fromJson)
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  // —— Documents ——
  Future<void> upsertDocument(HealthDocument d) => _db.upsert(
        table: documents,
        ownerUserId: d.ownerUserId,
        id: d.id,
        row: d.toJson(),
      );

  Future<void> deleteDocument({
    required String ownerUserId,
    required String id,
  }) =>
      _db.delete(table: documents, ownerUserId: ownerUserId, id: id);

  List<HealthDocument> listDocuments(String ownerUserId) => _db
      .list(table: documents, ownerUserId: ownerUserId)
      .map(HealthDocument.fromJson)
      .toList()
    ..sort((a, b) => b.documentDate.compareTo(a.documentDate));

  bool isDocumentTombstoned({
    required String ownerUserId,
    required String id,
  }) =>
      _db.isTombstoned(
        table: documents,
        ownerUserId: ownerUserId,
        id: id,
      );

  Future<void> applyRemoteDocument(HealthDocument d) => _db.applyRemote(
        table: documents,
        ownerUserId: d.ownerUserId,
        id: d.id,
        row: d.toJson(),
      );

  // —— Emergency ——
  Future<void> saveEmergencyCard(EmergencyCardRecord card) => _db.upsert(
        table: emergency,
        ownerUserId: card.ownerUserId,
        id: card.id,
        row: card.toJson(),
      );

  EmergencyCardRecord? emergencyCardFor(String ownerUserId) {
    final rows = _db.list(table: emergency, ownerUserId: ownerUserId);
    if (rows.isEmpty) return null;
    return EmergencyCardRecord.fromJson(rows.first);
  }

  // —— Audit ——
  Future<void> appendAudit(AuditEvent event) async {
    if (AuditEvent.metadataLooksSensitive(event.metadata)) {
      throw StateError('Audit metadata must not contain clinical values');
    }
    await _db.upsert(
      table: audit,
      ownerUserId: event.ownerUserId,
      id: event.id,
      row: event.toJson(),
    );
  }

  List<AuditEvent> listAudit(String ownerUserId) => _db
      .list(table: audit, ownerUserId: ownerUserId)
      .map(AuditEvent.fromJson)
      .toList()
    ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  // —— Sharing ——
  Future<ShareGrant> createShare({
    required String ownerUserId,
    required String recipientLabel,
    required List<ShareCategory> categories,
    required ShareFormat format,
    Duration ttl = const Duration(days: 7),
    List<String> recordIds = const [],
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final now = DateTime.now().toUtc();
    final grant = ShareGrant(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      recipientLabel: recipientLabel,
      categories: categories,
      createdAt: now,
      expiresAt: now.add(ttl),
      format: format,
      recordIds: recordIds,
      fromDate: fromDate,
      toDate: toDate,
    );
    await _db.upsert(
      table: shares,
      ownerUserId: ownerUserId,
      id: grant.id,
      row: grant.toJson(),
    );
    await appendAudit(
      AuditEvent(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        action: 'share.create',
        occurredAt: now,
        entityType: shares,
        entityId: grant.id,
        metadata: {
          'recipient': recipientLabel,
          'format': format.name,
          'categories': categories.map((e) => e.name).join('|'),
        },
      ),
    );
    return grant;
  }

  Future<ShareGrant> revokeShare({
    required String ownerUserId,
    required String grantId,
  }) async {
    final row = _db.getById(
      table: shares,
      ownerUserId: ownerUserId,
      id: grantId,
    );
    if (row == null) {
      throw StateError('Share grant not found');
    }
    final grant = ShareGrant.fromJson(row).copyWith(
      revokedAt: DateTime.now().toUtc(),
    );
    await _db.upsert(
      table: shares,
      ownerUserId: ownerUserId,
      id: grant.id,
      row: grant.toJson(),
    );
    await appendAudit(
      AuditEvent(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        action: 'share.revoke',
        occurredAt: DateTime.now().toUtc(),
        entityType: shares,
        entityId: grantId,
      ),
    );
    return grant;
  }

  List<ShareGrant> listShares(String ownerUserId) => _db
      .list(table: shares, ownerUserId: ownerUserId)
      .map(ShareGrant.fromJson)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  ShareExportResult? exportActiveShare({
    required String ownerUserId,
    required String grantId,
  }) {
    final row = _db.getById(
      table: shares,
      ownerUserId: ownerUserId,
      id: grantId,
    );
    if (row == null) return null;
    final grant = ShareGrant.fromJson(row);
    if (!grant.isActive) return null;
    if (!grant.categories.contains(ShareCategory.observations)) {
      return ShareExportBuilder.build(
        grant: grant,
        observations: const [],
      );
    }
    return ShareExportBuilder.build(
      grant: grant,
      observations: listObservations(ownerUserId),
    );
  }

  // —— Care circle ——
  Future<CareCircleMember> inviteCareMember({
    required String ownerUserId,
    required String memberLabel,
    required CareMemberRole role,
    List<CareFieldVisibility> visibleFields = const [],
  }) async {
    final member = CareCircleMember(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      memberLabel: memberLabel,
      role: role,
      visibleFields: visibleFields,
      invitedAt: DateTime.now().toUtc(),
    );
    await _db.upsert(
      table: careCircle,
      ownerUserId: ownerUserId,
      id: member.id,
      row: member.toJson(),
    );
    await appendAudit(
      AuditEvent(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        action: 'care.invite',
        occurredAt: DateTime.now().toUtc(),
        entityType: careCircle,
        entityId: member.id,
        metadata: {
          'role': role.name,
          'fields': visibleFields.map((e) => e.name).join('|'),
        },
      ),
    );
    return member;
  }

  Future<CareCircleMember> revokeCareMember({
    required String ownerUserId,
    required String memberId,
  }) async {
    final row = _db.getById(
      table: careCircle,
      ownerUserId: ownerUserId,
      id: memberId,
    );
    if (row == null) throw StateError('Care member not found');
    final member = CareCircleMember.fromJson(row).copyWith(
      revokedAt: DateTime.now().toUtc(),
    );
    await _db.upsert(
      table: careCircle,
      ownerUserId: ownerUserId,
      id: member.id,
      row: member.toJson(),
    );
    await appendAudit(
      AuditEvent(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        action: 'care.revoke',
        occurredAt: DateTime.now().toUtc(),
        entityType: careCircle,
        entityId: memberId,
      ),
    );
    return member;
  }

  List<CareCircleMember> listCareMembers(String ownerUserId) => _db
      .list(table: careCircle, ownerUserId: ownerUserId)
      .map(CareCircleMember.fromJson)
      .where((m) => m.isActive)
      .toList();

  /// Caregiver may only see fields explicitly granted.
  bool caregiverCanSee({
    required CareCircleMember member,
    required CareFieldVisibility field,
  }) {
    if (!member.isActive) return false;
    return member.visibleFields.contains(field);
  }

  PrefsHealthLocalDatabase get database => _db;
}
