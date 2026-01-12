# Supabase History Architecture

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         LabelSafe AI App                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐         ┌──────────────────┐                │
│  │  History Screen  │◄────────┤  UI Providers    │                │
│  └──────────────────┘         └──────────────────┘                │
│           △                             △                         │
│           │                             │                         │
│  ┌────────┴────────────────────────────┴────────┐                │
│  │                                               │                │
│  │   ref.watch(scanHistoryProvider)             │                │
│  │   - Uses AnalysisRepository                  │                │
│  │   - Auto-selects Supabase or Local           │                │
│  │                                               │                │
│  └────────┬─────────────────────────────────────┘                │
│           │                                                       │
│  ┌────────▼────────────────────────────────────┐                │
│  │      AnalysisRepository                      │                │
│  ├───────────────────────────────────────────────┤               │
│  │                                               │               │
│  │  getHistory()                                 │               │
│  │  ├─ Check: User logged in?                   │               │
│  │  ├─ Yes: Fetch from Supabase                 │               │
│  │  ├─ Sync local-only scans to cloud           │               │
│  │  └─ No: Use local storage                    │               │
│  │                                               │               │
│  │  saveAnalysis(ProductAnalysis)               │               │
│  │  ├─ Save to LocalStorage (SharedPrefs)       │               │
│  │  └─ If user logged in: Sync to Supabase      │               │
│  │                                               │               │
│  │  clearHistory()                              │               │
│  │  ├─ Clear LocalStorage                       │               │
│  │  └─ If user logged in: Clear Supabase        │               │
│  │                                               │               │
│  └────────┬──────────────────────────┬──────────┘               │
│           │                          │                          │
│  ┌────────▼──────┐         ┌─────────▼───────┐                 │
│  │ SharedPrefs   │         │ SupabaseService │                 │
│  │ (Local Store) │         │                 │                 │
│  │               │         │ - Auth methods  │                 │
│  │ 50 scans max  │         │ - Save history  │                 │
│  │ Backup cache  │         │ - Get history   │                 │
│  │ Offline mode  │         │ - Delete scans  │                 │
│  └───────────────┘         └─────────┬───────┘                 │
│                                       │                         │
│                                       │ Network                 │
│                                       ▼                         │
└───────────────────────────────────────┼─────────────────────────┘
                                        │
                           ┌────────────▼────────────┐
                           │   Supabase Cloud        │
                           ├─────────────────────────┤
                           │                         │
                           │  PostgreSQL Database    │
                           │  ┌───────────────────┐  │
                           │  │  scan_history     │  │
                           │  ├───────────────────┤  │
                           │  │ - id              │  │
                           │  │ - user_id (FK)    │  │
                           │  │ - product_name    │  │
                           │  │ - brand           │  │
                           │  │ - score           │  │
                           │  │ - ingredients     │  │
                           │  │ - created_at      │  │
                           │  │ - ...             │  │
                           │  └───────────────────┘  │
                           │                         │
                           │  Row-Level Security     │
                           │  ├─ SELECT own data     │
                           │  ├─ INSERT own data     │
                           │  ├─ DELETE own data     │
                           │  └─ UPDATE own data     │
                           │                         │
                           └─────────────────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────┐
│         Riverpod Providers State Flow               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  currentUserProvider                                │
│  ├─ Watches: SupabaseService.currentUser           │
│  └─ Returns: User? (logged-in user or null)        │
│                                                     │
│  authStateStreamProvider                            │
│  ├─ Watches: Auth state changes                    │
│  └─ Returns: Stream<AuthState>                     │
│                                                     │
│  scanHistoryProvider (Main Provider)               │
│  ├─ Watches: AnalysisRepository                    │
│  ├─ Calls: repo.getHistory()                       │
│  └─ Returns: FutureProvider<List<ProductAnalysis>> │
│                                                     │
│  supabaseScanHistoryProvider (Optional Direct)     │
│  ├─ Watches: currentUserProvider                   │
│  ├─ If user: Fetch from Supabase                   │
│  └─ Returns: FutureProvider<List<ProductAnalysis>> │
│                                                     │
│  deleteScanProvider                                │
│  ├─ Accepts: scanId parameter                      │
│  ├─ Calls: SupabaseService.deleteScanHistory()     │
│  └─ Invalidates: scanHistoryProvider (refresh)     │
│                                                     │
│  clearAllScansProvider                             │
│  ├─ Calls: SupabaseService.clearAllScanHistory()   │
│  └─ Invalidates: scanHistoryProvider (refresh)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Sync Strategy

```
SCENARIO 1: Online User Scans Product
────────────────────────────────────────────────────
1. User scans product in app
2. ProductAnalysis created
3. AnalysisRepository.saveAnalysis() called
   ├─ Save to SharedPreferences (local)
   ├─ Check: User logged in?
   ├─ Yes: Call SupabaseService.saveScanHistory()
   │   └─ Save to Supabase database
   └─ No: Skip Supabase save
4. UI updates (history visible immediately)


SCENARIO 2: Offline User Scans Product
────────────────────────────────────────────────────
1. User scans product (no internet)
2. AnalysisRepository.saveAnalysis() called
   ├─ Save to SharedPreferences ✓
   ├─ Try SupabaseService.saveScanHistory()
   └─ Network error → Skip (don't crash)
3. UI updates (history visible)
4. When online + logged in → Auto-sync happens


SCENARIO 3: User Logs In (First Time or New Device)
────────────────────────────────────────────────────
1. User authentication completes
2. App calls: AnalysisRepository.getHistory()
3. Repository detects: currentUserProvider != null
4. Fetches from Supabase (cloud source of truth)
5. Calls: _syncLocalToSupabase()
   ├─ Loads local scans from SharedPreferences
   ├─ Compares with Supabase scans
   └─ Uploads new local-only scans
6. UI updates with complete history


SCENARIO 4: User Logs Out
──────────────────────────
1. User logs out
2. AnalysisRepository.getHistory() called
3. Repository detects: currentUserProvider == null
4. Falls back to local storage
5. Shows only local scans (privacy safe)
6. Supabase data inaccessible until re-login


SCENARIO 5: Clear History
──────────────────────────
1. User triggers clear history
2. AnalysisRepository.clearHistory() called
   ├─ Remove from SharedPreferences (local)
   ├─ Check: User logged in?
   ├─ Yes: Call SupabaseService.clearAllScanHistory()
   │   └─ Delete from Supabase
   └─ No: Just local clear
3. All providers invalidated
4. UI refreshes to show empty state
```

## Data Model Mapping

```
Frontend (Dart)          ↔          Backend (PostgreSQL)
═══════════════════════════════════════════════════════

ProductAnalysis
├─ productName           ↔     product_name
├─ brand                 ↔     brand
├─ rating (enum)         ↔     rating (text)
├─ category              ↔     category
├─ overview              ↔     overview
├─ score                 ↔     score
├─ ingredients (list)    ↔     ingredients (jsonb)
│  └─ IngredientDetail
│     ├─ name           ↔     name
│     ├─ technicalName  ↔     technical_name
│     ├─ rating (enum)  ↔     rating (text)
│     ├─ explanation    ↔     explanation
│     └─ function       ↔     function
├─ highlights (list)     ↔     highlights (text[])
├─ fatPercentage         ↔     fat_percentage
├─ sugarPercentage       ↔     sugar_percentage
├─ sodiumPercentage      ↔     sodium_percentage
├─ recommendation        ↔     recommendation
├─ isIngredientsComplete ↔     is_ingredients_list_complete
└─ date                  ↔     created_at (auto)
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────┐
│              Error Handling Strategy                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Supabase Connection Error                         │
│  ├─ Log error to console                           │
│  ├─ Continue with local storage                    │
│  └─ User unaffected (seamless fallback)            │
│                                                     │
│  RLS Policy Error                                  │
│  ├─ Indicates: Policy misconfiguration            │
│  ├─ Action: Review SUPABASE_SETUP.md              │
│  └─ Solution: Re-run RLS policy creation          │
│                                                     │
│  User Not Authenticated                            │
│  ├─ Supabase: Returns empty list                   │
│  ├─ Repository: Falls back to local               │
│  └─ UI: Shows local history or empty state        │
│                                                     │
│  Network Timeout                                   │
│  ├─ Supabase: Request times out                   │
│  ├─ Repository: Catches exception                 │
│  └─ App: Uses local storage (offline mode)        │
│                                                     │
│  Invalid Credentials                               │
│  ├─ Supabase: Rejects request                     │
│  ├─ Check: .env variables                         │
│  └─ Fix: Update SUPABASE_URL and ANON_KEY        │
│                                                     │
│  Database Constraints Violated                     │
│  ├─ Supabase: Returns constraint error            │
│  ├─ Likely: Duplicate or missing required field   │
│  └─ Action: Check data before insert              │
│                                                     │
│  User Deleted                                      │
│  ├─ Cascading delete: All scans removed           │
│  ├─ Foreign key constraint: user_id → auth.users  │
│  └─ Result: Clean data removal                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────┐
│           Row-Level Security (RLS)                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  scan_history table policies                       │
│                                                     │
│  SELECT Policy: "Users can view own data"         │
│  ├─ Condition: auth.uid() = user_id              │
│  └─ Effect: Only see own scans                    │
│                                                     │
│  INSERT Policy: "Users can insert own data"       │
│  ├─ Condition: auth.uid() = user_id              │
│  └─ Effect: Can only add to own user_id          │
│                                                     │
│  UPDATE Policy: "Users can update own data"       │
│  ├─ Condition: auth.uid() = user_id              │
│  └─ Effect: Can only modify own records          │
│                                                     │
│  DELETE Policy: "Users can delete own data"       │
│  ├─ Condition: auth.uid() = user_id              │
│  └─ Effect: Can only remove own records          │
│                                                     │
│  Result: User X cannot access User Y's scans      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

**Key Benefits:**
- ✅ Automatic sync to cloud
- ✅ Seamless fallback to local storage
- ✅ Works offline with auto catch-up
- ✅ Multi-device synchronization
- ✅ Secure with RLS policies
- ✅ No data loss
- ✅ Unlimited cloud storage
