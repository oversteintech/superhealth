# SuperHealth core features

Domain: **Health Management**

| Feature | Path | Mock data |
|---------|------|-----------|
| Medication | `features/medications/` | Doses, schedules, taken-today |
| Medical Records | `features/medical_records/` | Clinical summaries, imaging |
| Doctor Visits | `features/doctor_visits/` | Upcoming + past visits |
| Lab Results | `features/lab_results/` | Panels with normal/high/low |
| Vaccinations | `features/vaccinations/` | Doses, lots, next due |
| Heart Rate | `features/heart_rate/` | Samples + sparkline |
| Weight | `features/weight/` | Entries + delta |
| Sleep | `features/sleep/` | Sessions, deep/REM |
| Nutrition | `features/nutrition/` | Meals + macros |
| Health AI | `features/assistant/` | SuperHealth Mate |
| Emergency Card | `features/emergency_card/` | Blood type, allergies, contact |

Dashboard exposes all eleven as a tappable **Core features** grid via `HealthFeatureCatalog` + `HealthFeatureNavigator`.