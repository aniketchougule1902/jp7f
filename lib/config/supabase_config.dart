import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // These will be replaced with actual values
  static const String supabaseUrl = 'https://wpepadirurnrshdxfmuq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwZXBhZGlydXJucnNoZHhmbXVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNTE0MjAsImV4cCI6MjA5MTgyNzQyMH0.wXTBPQeP1Nt5CrGi4X-lrIuQxw6SNVC8e2eDV0z8Lr4';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
