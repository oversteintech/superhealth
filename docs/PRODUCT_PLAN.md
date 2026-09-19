# Super Health — ürün planı (Prompt 0)

**Ürün rolü:** Kişisel sağlık kayıtlarını, alışkanlıkları, ölçümleri, randevuları ve bakım planlarını kullanıcının kontrolünde toplayan günlük/kayıt düzenleyici.

**Açık sınır:** İlk sürüm tanı, tedavi, doz önerisi, acil durum triyajı veya tıbbi cihaz iddiası üretmez. Klinik entegrasyon ve cihaz verisi ayrı doğrulama ister. Referans aralıkları kişiye özel tıbbi eşik değildir. Sağlık puanı üretilmez.

**Referanslar:** SuperGarage (`../supergarage`) After Framework + AAPS; SuperCore (`../supercore`) portları. `AGENTS.md` yok; mevcut iskelet, Family kit ve `docs/COMPLIANCE_REPORT.md` korunur.

---

## 1. Garage eşlemesi

| Garage | Super Health | İlk dilimde durum |
|--------|----------------|-------------------|
| `vehicle_hub/tabs/vehicle_health_tab.dart` → gömülü bakım zaman çizelgesi | Kişisel sağlık zaman çizelgesi (alan modeli yeniden) | **Uygulandı** (timeline + `Observation`) |
| Bakım takvimi / hatırlatma | İlaç alma kaydı, randevu, kontrol, rutin hatırlatması (karar değil) | **P0 uygulandı** |
| `features/documents` | Laboratuvar, reçete, aşı kartı, rapor kasası + gizlilik | **P0 belge kasası** |
| Live data | Ölçüm/giyilebilir görünüm; kaynak, zaman, doğruluk uyarısı | **P1 Demo import adapter** |
| `emergency_profile` (rıza, ICE, güncelleme) | Kullanıcının seçtiği acil bilgi kartı; kilit ekranı alanları açık rızayla | **Varsayılan kapalı + rıza bayrağı** |
| `assistant/orchestrator` (önce uygulama içi rota) | Seçilmiş kayıtlarda gezinme/özet; güvenlik filtresi | **P1 in-app catalog + selected explainer** |
| `app/notifications` (payload’da gövde yok) | Hassas gövde gizli; derin link/id | **Redaksiyon yardımcısı** |
| `core/sync` + tombstone / kullanıcı kapsamı | Drift + sync P0; iskelet: kullanıcı scoped store | **P0: PrefsHealthLocalDatabase (Drift şema sözleşmesi) + tombstone + sync queue** |

### Doğrulanmış ortak API’ler (SuperCore / After)

Kullanılabilir ve kullanılacak:

- `after_core`: `AppPlatformManifest`, `AfterStandardOverrides`, locale prefs, feature flags, remote config, analytics/logger portları, HTTPS Dio.
- `after_design_system`: `AfterAppBar`, `AfterCard`, `AfterLoading`, `AfterButton`, `AfterSectionHeader`, `AfterInlineBanner`, `AfterNavigationBar`, `AfterScaffoldBody`.
- `after_consumer`: AuthGate/Family shell, membership, Family CRUD stores, `FamilyAiChatScreen`, dashboard section sort.
- `after_firebase`: Auth + blob sync; placeholder options — gerçek klinik bulut yok.
- `after_ai`: `AfterAiPlatform.chat`, `AfterAiProfile` yetenekleri. **Health’te `recommendation` / `prediction` / `decisionSupport` kapalı.** Kayıt payload’ı varsayılan gitmez.

Garage-only (kopyalanmaz, örüntü alınır): Drift entity sync, `AiOrchestrator` in-app route catalog, maintenance reminder listener, emergency consent sheet.

---

## 2. P0 / P1 / P2

### P0 — güvenilir kişisel kayıt (Prompt 1)

1. Başlangıç: ülke, dil, birim, saat dilimi, gizlilik kilidi, bildirim izni, kategori bazlı rıza.
2. Profil: doğum yılı veya yaş aralığı, boy, birim; TCKN/pasaport zorunlu değil.
3. Zaman çizelgesi: belirti, not, randevu, ölçüm, belge, tamamlanan rutin; tarih/kaynak filtresi.
4. Ölçümler: tür, değer, birim, `measuredAt`, kaynak (manuel vs cihaz), not, güvenilirlik; tıbbi eşik varsayımı yok.
5. Alışkanlıklar: kullanıcı hedefleri; suçlayıcı streak dili yok.
6. İlaç listesi: ad + kullanıcının/klinisyenin talimatı aynen; hatırlatma; alındı/atlandı. Doz hesabı yok.
7. Randevu/kontrol: yer, uzman, not, soru listesi, hatırlatma; isteğe bağlı takvim.
8. Belge kasası: foto/PDF, tür, tarih, etiket; erişim ve export açık.
9. Dashboard: bugünkü rutin, yaklaşan randevu, son ölçüm, eksik veri uyarısı; **tek sağlık puanı yok**.
10. Gizlilik: PIN/biyometri, hassas bildirim gövdesi gizli, ekran görüntüsü tercihi, oturum kapanınca görünüm temizliği, silme/export.
11. Acil kart: varsayılan kapalı; kilit ekranı alanları ayrı rıza; düzenleme geçmişi + `updatedAt`.

**Teknik:** domain/data/features, Drift, kullanıcı erişimi, offline sync, tombstone, TR/EN, büyük yazı, screen reader, boş/hata/offline.

### P1 — öz izlem ve kontrollü paylaşım (Prompt 2)

Trend grafikleri (eksik aralığı çizgiyle doldurma), semptom günlüğü (teşhis yok), bakım planı (AI plansız değiştirmez), PDF/CSV özet + iptal + audit, bakım veren rolü (varsayılan tüm veri yok), giyilebilir import adapter (bağlantı yoksa **Demo** etiketi), AI yalnız seçili kayıt + kaynak/belirsizlik.

### P2 — klinik ve kurumsal (Prompt 3 sonrası)

Sağlayıcı/FHIR ancak sözleşme + provenance; telehealth/lab anlaşmalı hizmet; Business bakım ekibi + RBAC. Tıbbi cihaz / EHR işletmeciliği **iddia edilmez**.

---

## 3. Ekran haritası

```
Cold start → Overstein splash → AuthGate → (onboarding rıza) → MainShell
  Home: selamlama, offline, bugün rutin, yaklaşan randevu, son ölçüm, eksik veri, özellik ızgarası
  Live: ölçüm görünümü + “cihaz doğrulanmadı / mock” uyarısı
  AI: önce uygulama içi rota; kayıt yok; seçim olmadan özet yok
  Features: katalog
  Settings: birim, dil, kilit, bildirim, rıza, export/silme, üyelik
Pushed:
  Timeline, Ölçüm ekle, Rutinler, İlaçlar, Randevular, Belgeler, Acil kart (kilitli),
  Bildirim kutusu (gövdesiz), Profil
P1+: Trend, Paylaşım, Bakım veren, Import
```

Navigasyon: `go_router` yok; AuthGate → MainShell; `HealthFeatureCatalog` + navigator.

---

## 4. Veri sınıflandırması

| Sınıf | Örnek | Telemetri | Crash | AI | Bildirim gövdesi |
|-------|--------|-----------|-------|-----|------------------|
| C0 genel | dil, tema, plan | evet | evet | hayır gerekir | evet |
| C1 sağlık kaydı | Observation, semptom, ilaç talimatı | hayır | hayır | yalnız açık seçim | hayır |
| C2 belge | PDF/foto laboratuvar | hayır | hayır | hayır (P1 seçili meta) | hayır |
| C3 acil kart | alerji, kişi | hayır | hayır | hayır | hayır |
| C4 kimlik | ad, iletişim | hayır | hayır | hayır | hayır |
| C5 rıza/audit | ConsentGrant, AuditEvent | event adı (içerik yok) | hayır | hayır | hayır |

Cihaz vs manuel: `DataSourceKind.manual` | `wearable` | `import` | `clinicianEntered` ayrı `sourceId`.

Tombstone: silinen id kullanıcı kapsamında tutulur; sync çekiminde dirilmez. Erişim iptali (`ShareGrant` / `CareCircleMember`) tombstone ile aynı kullanıcı kuyruğunda.

Hedef varlıklar: `HealthProfile`, `Observation`, `SymptomEntry`, `HabitGoal`, `HabitLog`, `MedicationRecord`, `MedicationSchedule`, `MedicationAdherenceEvent`, `Appointment`, `HealthDocument`, `EmergencyCard`, `ConsentGrant`, `CareCircleMember`, `ShareGrant`, `AuditEvent`.

---

## 5. Rıza / erişim matrisi

| İşlem | Gerekli rıza | Varsayılan | Kim |
|--------|----------------|------------|-----|
| Yerel kayıt (ölçüm/rutin) | `local_health_store` | onboarding’de ayrı onay | hesap sahibi |
| Bildirim (ilaç/randevu) | OS izni + `reminders` | kapalı gövde | hesap sahibi |
| Acil kartı uygulama içi | kart `enabled` | **kapalı** | hesap sahibi |
| Kilit ekranı alanları | `lock_screen_emergency` alan listesi | **kapalı** | hesap sahibi |
| Bulut blob | After sync + sağlık bulut rızası | iskelette prefs; klinik bulut yok | hesap sahibi |
| AI özet | kayıt çoklu seçim + `ai_explain` | **hiç kayıt yok** | hesap sahibi |
| Bakım veren (P1) | davet + görünür alanlar | tüm veri yok | davet eden |
| Klinik import (P2) | kapsamlı rıza + sözleşme | yok | hukuk/ürün |

Çocuk verisi: P1 aile rolünde ayrı rıza; P0 tek kullanıcı yetişkin varsayımı. Yayın checklist’inde hukuk onayı şart.

---

## 6. AI güvenlik sınırı

1. Varsayılan istek: yalnızca kullanıcı metni + uygulama içi rota kataloğu (Garage: önce in-app).
2. Kayıt eklemek için UI’da açık seçim; aksi halde boş bağlam.
3. Yasak çıktı: tanı, ayırıcı tanı, tedavi/ilaç değişikliği, doz hesabı, acil triyaj, “sağlık skoru”.
4. Zorunlu: belirsizlik, kaynak yoksa “kaynak yok”, klinisyene yönlendirme, acil durumda 112/acil servis (uygulama değerlendirmez).
5. `AfterAiCapability.recommendation` / `prediction` / `decisionSupport` kapalı.
6. Log/analytics: prompt’tan C1+ alanları strip; event adları (`ai_refused_diagnosis`).

---

## 7. Test planı (iskelet + P0)

| ID | Senaryo | Dilim |
|----|---------|-------|
| T1 | İlaç hatırlatma ertele / alındı; gövde gizli | P0 |
| T2 | DST: `measuredAt` UTC saklanır, yerel gösterim kaymaz | **İlk dilim** |
| T3 | kg↔lb, °C↔°F, glikoz mg/dL↔mmol/L kayıpsız dönüşüm | **İlk dilim** |
| T4 | Kullanıcı değişince Observation izolasyonu | **İlk dilim** |
| T5 | Belge/kayıt silme tombstone | **İlk dilim** |
| T6 | Yeniden açılışta prefs kalıcılığı | **İlk dilim** |
| T7 | AI varsayılan kayıt göndermez; tanı isteği reddedilir | **İlk dilim** |
| T8 | Eksik ölçümden skor üretilmez | **İlk dilim** |
| T9 | Paylaşım iptali, sızıntı, mükerrer giyilebilir, grafik gap | P1 |
| T10 | Analytics/AI payload’da C1 yok | P3 |

---

## 8. İlk güvenli çalışan dilim (bu teslimat)

Yapılanlar:

- Domain: `Observation`, `ConsentGrant`, `TimelineEvent`, kaynak kimliği, birim dönüşümü, tombstone store.
- Güvenlik: `AiSafetyPolicy`, hassas bildirim redaksiyonu, acil kart varsayılan kapalı.
- UI: Zaman çizelgesi; Live sekmesinde mock/doğruluk uyarısı; Mate sohbeti güvenlik kapısı.
- Drift/FHIR/cihaz/klinik **yok** ve varmış gibi gösterilmez.

Ertelemeler: tam P0 CRUD, Drift sync, 20 dil çevirisi, IAP, gerçek HealthKit/Google Fit, Mate tam orchestrator.

---

## 9. Yayın / hukuk (Prompt 3 önizleme)

Yerel bölgelerde sağlık verisi, tıbbi yazılım ve çocuk verisi yükümlülükleri hukuk/ürün onayına bağlı açık checklist olacaktır. Bu iskelet **tıbbi cihaz, tanı yazılımı veya sertifikalı EHR değildir**.
