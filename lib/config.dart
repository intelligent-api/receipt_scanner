class Config {
  static const apiEndpoint = String.fromEnvironment(
    'API_ENDPOINT',
    defaultValue: 'https://api.intelligent-api.com/v1/document/expenses',
  );

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key',
  );
}
