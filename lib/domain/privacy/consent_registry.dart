import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../records/consent_grant.dart';

/// Versioned consent registry. Bumping [currentVersion] requires re-prompt.
abstract final class ConsentVersions {
  static const current = 'p3-1';
}

class ConsentRegistry {
  ConsentRegistry(this._prefs, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final SharedPreferences _prefs;
  final Uuid _uuid;

  static const _key = 'super_health.consent.grants';

  List<ConsentGrant> listFor(String ownerUserId) {
    return _load()
        .where((g) => g.ownerUserId == ownerUserId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  ConsentGrant? latest({
    required String ownerUserId,
    required ConsentPurpose purpose,
  }) {
    final matches = listFor(ownerUserId).where((g) => g.purpose == purpose);
    return matches.isEmpty ? null : matches.first;
  }

  bool isGrantedCurrent({
    required String ownerUserId,
    required ConsentPurpose purpose,
  }) {
    final g = latest(ownerUserId: ownerUserId, purpose: purpose);
    return g != null && g.granted && g.version == ConsentVersions.current;
  }

  Future<ConsentGrant> record({
    required String ownerUserId,
    required ConsentPurpose purpose,
    required bool granted,
    String scopeNotes = '',
  }) async {
    final grant = ConsentGrant(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      purpose: purpose,
      granted: granted,
      version: ConsentVersions.current,
      recordedAt: DateTime.now().toUtc(),
      scopeNotes: scopeNotes,
    );
    final all = _load()..add(grant);
    await _prefs.setString(
      _key,
      jsonEncode(
        all
            .map(
              (g) => {
                'id': g.id,
                'ownerUserId': g.ownerUserId,
                'purpose': g.purpose.name,
                'granted': g.granted,
                'version': g.version,
                'recordedAt': g.recordedAt.toIso8601String(),
                'scopeNotes': g.scopeNotes,
              },
            )
            .toList(),
      ),
    );
    return grant;
  }

  List<ConsentGrant> _load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) {
      final m = Map<String, Object?>.from(e as Map);
      return ConsentGrant(
        id: m['id']! as String,
        ownerUserId: m['ownerUserId']! as String,
        purpose: ConsentPurpose.values.byName(m['purpose']! as String),
        granted: m['granted']! as bool,
        version: m['version']! as String,
        recordedAt: DateTime.parse(m['recordedAt']! as String).toUtc(),
        scopeNotes: m['scopeNotes'] as String? ?? '',
      );
    }).toList();
  }
}
