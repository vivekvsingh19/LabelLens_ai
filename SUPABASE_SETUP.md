# Supabase Database Setup for Scan History

## Overview
This guide provides the SQL schema and setup instructions to configure Supabase for storing product scan history.

## Database Schema

### 1. Create the `scan_history` Table

Run this SQL in the Supabase SQL Editor:

```sql
-- Create scan_history table
CREATE TABLE public.scan_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  brand TEXT NOT NULL,
  category TEXT NOT NULL,
  rating TEXT NOT NULL,
  score FLOAT NOT NULL,
  overview TEXT NOT NULL,
  ingredients JSONB NOT NULL DEFAULT '[]',
  highlights TEXT[] NOT NULL DEFAULT '{}',
  fat_percentage FLOAT NOT NULL DEFAULT 0,
  sugar_percentage FLOAT NOT NULL DEFAULT 0,
  sodium_percentage FLOAT NOT NULL DEFAULT 0,
  recommendation TEXT NOT NULL DEFAULT 'No recommendation available',
  is_ingredients_list_complete BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX idx_scan_history_user_id ON public.scan_history(user_id);
CREATE INDEX idx_scan_history_created_at ON public.scan_history(created_at DESC);
CREATE INDEX idx_scan_history_user_created ON public.scan_history(user_id, created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.scan_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policy to allow users to see only their own data
CREATE POLICY "Users can view their own scan history"
  ON public.scan_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create RLS policy to allow users to insert their own data
CREATE POLICY "Users can insert their own scan history"
  ON public.scan_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create RLS policy to allow users to delete their own data
CREATE POLICY "Users can delete their own scan history"
  ON public.scan_history
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create RLS policy to allow users to update their own data
CREATE POLICY "Users can update their own scan history"
  ON public.scan_history
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### 2. Create the `ingredient_analysis` Table (Optional - for detailed ingredient tracking)

```sql
CREATE TABLE public.ingredient_analysis (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scan_id UUID NOT NULL REFERENCES public.scan_history(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  technical_name TEXT NOT NULL,
  rating TEXT NOT NULL,
  explanation TEXT NOT NULL,
  function TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create index
CREATE INDEX idx_ingredient_analysis_scan_id ON public.ingredient_analysis(scan_id);

-- Enable RLS
ALTER TABLE public.ingredient_analysis ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to view ingredients from their scans
CREATE POLICY "Users can view ingredients from their scans"
  ON public.ingredient_analysis
  FOR SELECT
  USING (
    scan_id IN (
      SELECT id FROM public.scan_history WHERE user_id = auth.uid()
    )
  );
```

### 3. Create the `scan_statistics` Table (Optional - for analytics)

```sql
CREATE TABLE public.scan_statistics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_scans INT NOT NULL DEFAULT 0,
  average_score FLOAT NOT NULL DEFAULT 0,
  most_scanned_category TEXT,
  last_scan_date TIMESTAMP WITH TIME ZONE,
  streak_count INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create index
CREATE INDEX idx_scan_statistics_user_id ON public.scan_statistics(user_id);

-- Enable RLS
ALTER TABLE public.scan_statistics ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view their own statistics"
  ON public.scan_statistics
  FOR SELECT
  USING (auth.uid() = user_id);
```

## Setup Steps

1. **Go to Supabase Dashboard**
   - Navigate to https://supabase.com
   - Log in to your project

2. **Access SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Copy and Paste Schema**
   - Copy the entire SQL schema above
   - Paste it into the SQL editor
   - Click "Run" to execute

4. **Verify Tables**
   - Navigate to "Table Editor" in the left sidebar
   - You should see `scan_history`, `ingredient_analysis`, and `scan_statistics` tables

## Configuration in Flutter App

### 1. Ensure Environment Variables
Make sure your `.env` file has:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. The App Automatically:
- ✅ Syncs new scans to Supabase when user is logged in
- ✅ Falls back to local storage if offline
- ✅ Syncs local history to Supabase on next login
- ✅ Maintains both local and cloud copies for reliability
- ✅ Enforces row-level security (users can only see their data)

## Features Implemented

### Data Persistence
- Local storage with SharedPreferences (up to 50 scans)
- Cloud storage in Supabase (unlimited scans per user)
- Automatic synchronization between local and cloud

### Data Retrieval
- Fetches from Supabase when user is logged in
- Falls back to local storage if offline
- Syncs old local scans when user logs in

### Data Management
- Delete individual scans from Supabase
- Clear all user history
- Automatic cleanup on user deletion (via foreign key cascade)

## API Methods

### SupabaseService
```dart
// Save scan to Supabase
await supabase.saveScanHistory(
  userId: userId,
  productName: 'Product',
  brand: 'Brand',
  // ... other fields
);

// Get scan history
final history = await supabase.getScanHistory(
  userId: userId,
  limit: 50,
);

// Delete specific scan
await supabase.deleteScanHistory(scanId: scanId);

// Clear all scans for user
await supabase.clearAllScanHistory(userId: userId);
```

### Flutter Providers (supabase_providers.dart)
```dart
// Get current user
final user = ref.watch(currentUserProvider);

// Get scan history from Supabase
final history = ref.watch(supabaseScanHistoryProvider);

// Delete a scan
ref.read(deleteScanProvider(scanId));

// Clear all scans
ref.read(clearAllScansProvider);
```

## Security

✅ **Row Level Security (RLS) Enabled**
- Users can only see their own data
- Users can only insert/update/delete their own records
- All policies are linked to `auth.uid()`

✅ **Data Integrity**
- Foreign keys enforce referential integrity
- Cascading deletes prevent orphaned records
- Timestamp tracking for audit trails

## Troubleshooting

### No data showing up?
1. Check if user is logged in: `ref.watch(currentUserProvider)`
2. Verify Supabase credentials in `.env`
3. Check RLS policies are enabled
4. Look at Supabase logs for errors

### Sync not working?
1. Check internet connection
2. Verify user authentication
3. Check SharedPreferences has local data
4. Review console logs for error messages

### Performance issues?
- The table has indexes on `user_id`, `created_at`, and combined queries
- Limit queries to last 100 scans (adjustable)
- Consider archiving old data if table grows too large

## Future Enhancements

- [ ] Backup and export scan history as CSV/PDF
- [ ] Sharing scan results with other users
- [ ] Collaborative product reviews
- [ ] Advanced analytics and insights
- [ ] Offline queue for batch syncing
- [ ] Data encryption at rest
