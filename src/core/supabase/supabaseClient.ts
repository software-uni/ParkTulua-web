import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env';
import type { Database } from '../types/database'; // generar tipos

export const supabase = createClient(
  env.supabaseUrl,
  env.supabaseAnonKey
);
