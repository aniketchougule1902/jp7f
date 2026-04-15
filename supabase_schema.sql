-- ============================================================
-- JeevanPatra Healthcare App - Supabase PostgreSQL Schema
-- ============================================================

-- =========================
-- 1. Custom ENUM Types
-- =========================

CREATE TYPE user_type AS ENUM ('patient', 'doctor', 'pharmacist', 'superuser', 'verifier', 'data_entry_admin');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE appointment_status AS ENUM ('scheduled', 'completed', 'cancelled', 'rescheduled');
CREATE TYPE record_type AS ENUM ('report', 'prescription', 'lab_report', 'imaging', 'other');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- =========================
-- 2. Helper Functions
-- =========================

-- Auto-generate user_id in format JPXXXXXXXX (8 random digits)
CREATE OR REPLACE FUNCTION generate_user_id() RETURNS text AS $$
DECLARE
  new_id text;
  exists_already boolean;
BEGIN
  LOOP
    new_id := 'JP' || lpad(floor(random() * 100000000)::bigint::text, 8, '0');
    SELECT EXISTS(SELECT 1 FROM users WHERE user_id = new_id) INTO exists_already;
    EXIT WHEN NOT exists_already;
  END LOOP;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Auto-generate prescription_id in format JP-RX-XXXXX (5 random digits)
CREATE OR REPLACE FUNCTION generate_prescription_id() RETURNS text AS $$
DECLARE
  new_id text;
  exists_already boolean;
BEGIN
  LOOP
    new_id := 'JP-RX-' || lpad(floor(random() * 100000)::bigint::text, 5, '0');
    SELECT EXISTS(SELECT 1 FROM prescriptions WHERE prescription_id = new_id) INTO exists_already;
    EXIT WHEN NOT exists_already;
  END LOOP;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-set updated_at on row update
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- 3. Tables
-- =========================

-- -------------------------------------------------------
-- 3.1 Users
-- -------------------------------------------------------
CREATE TABLE users (
  id            uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  user_id       text UNIQUE NOT NULL DEFAULT generate_user_id(),
  full_name     text,
  mobile_number text,
  email         text,
  user_type     user_type NOT NULL DEFAULT 'patient',
  encrypted_aadhar text,
  password_hash text,
  two_fa_enabled boolean NOT NULL DEFAULT false,
  two_fa_method  text,
  profile_completed boolean NOT NULL DEFAULT false,
  is_verified   boolean NOT NULL DEFAULT false,
  avatar_url    text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.2 Patient Profiles
-- -------------------------------------------------------
CREATE TABLE patient_profiles (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                     uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gender                      text,
  age                         integer,
  date_of_birth               date,
  blood_group                 text,
  height_cm                   numeric,
  weight_kg                   numeric,
  bp_systolic                 integer,
  bp_diastolic                integer,
  heart_rate                  integer,
  current_health_status       text,
  chronic_diseases            text,
  recent_surgeries            text,
  allergies                   text[],
  family_history_diabetes     boolean,
  family_history_hypertension boolean,
  family_history_other        text,
  food_allergies              text[],
  medicine_allergies          text[],
  environment_allergies       text[],
  long_term_medications       text[],
  health_score                integer NOT NULL DEFAULT 0,
  profile_completion_percentage integer NOT NULL DEFAULT 0,
  abha_id                     text,
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_patient_profiles_updated_at
  BEFORE UPDATE ON patient_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.3 Doctor Profiles
-- -------------------------------------------------------
CREATE TABLE doctor_profiles (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gender                text,
  age                   integer,
  license_number        text,
  license_doc_url       text,
  qualification         text,
  qualification_doc_url text,
  specialization        text,
  clinic_name           text,
  clinic_address        text,
  clinic_city           text,
  clinic_state          text,
  clinic_pincode        text,
  consultation_fee      numeric(10, 2),
  verification_status   verification_status NOT NULL DEFAULT 'pending',
  verification_reason   text,
  verified_by           uuid REFERENCES users(id) ON DELETE SET NULL,
  verified_at           timestamptz,
  schedule              jsonb,
  rating                numeric(3, 2) NOT NULL DEFAULT 0,
  total_ratings         integer NOT NULL DEFAULT 0,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_doctor_profiles_updated_at
  BEFORE UPDATE ON doctor_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.4 Pharmacist Profiles
-- -------------------------------------------------------
CREATE TABLE pharmacist_profiles (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gender                text,
  age                   integer,
  drug_license_number   text,
  drug_license_doc_url  text,
  qualification         text,
  qualification_doc_url text,
  pharmacy_name         text,
  pharmacy_address      text,
  pharmacy_city         text,
  pharmacy_state        text,
  pharmacy_pincode      text,
  verification_status   verification_status NOT NULL DEFAULT 'pending',
  verification_reason   text,
  verified_by           uuid REFERENCES users(id) ON DELETE SET NULL,
  verified_at           timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_pharmacist_profiles_updated_at
  BEFORE UPDATE ON pharmacist_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.5 Appointments
-- -------------------------------------------------------
CREATE TABLE appointments (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id        uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  doctor_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  appointment_date  date NOT NULL,
  appointment_time  time NOT NULL,
  status            appointment_status NOT NULL DEFAULT 'scheduled',
  notes             text,
  rating            numeric(2, 1),
  rating_comment    text,
  rescheduled_from  uuid REFERENCES appointments(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.6 Prescriptions
-- -------------------------------------------------------
CREATE TABLE prescriptions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prescription_id text UNIQUE NOT NULL DEFAULT generate_prescription_id(),
  doctor_id       uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  appointment_id  uuid REFERENCES appointments(id) ON DELETE SET NULL,
  diagnosis       text,
  notes           text,
  medicines       jsonb,
  is_active       boolean NOT NULL DEFAULT true,
  editable_until  timestamptz NOT NULL DEFAULT (now() + interval '15 minutes'),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_prescriptions_updated_at
  BEFORE UPDATE ON prescriptions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.7 Health Records
-- -------------------------------------------------------
CREATE TABLE health_records (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  uploaded_by   uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  record_type   record_type NOT NULL DEFAULT 'other',
  title         text,
  description   text,
  file_url      text,
  ai_category   text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.8 Medicines Catalog
-- -------------------------------------------------------
CREATE TABLE medicines (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category          text,
  product_name      text NOT NULL,
  composition       text,
  description       text,
  side_effects      text,
  drug_interactions text[],
  added_by          uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_medicines_updated_at
  BEFORE UPDATE ON medicines
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.9 Pharmacy Inventory
-- -------------------------------------------------------
CREATE TABLE pharmacy_inventory (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pharmacist_id       uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  medicine_id         uuid NOT NULL REFERENCES medicines(id) ON DELETE CASCADE,
  medicine_name       text,
  batch_number        text,
  quantity            integer NOT NULL DEFAULT 0,
  price_per_unit      numeric(10, 2),
  manufacturing_date  date,
  expiry_date         date,
  supplier_name       text,
  is_low_stock        boolean NOT NULL DEFAULT false,
  low_stock_threshold integer NOT NULL DEFAULT 10,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_pharmacy_inventory_updated_at
  BEFORE UPDATE ON pharmacy_inventory
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------------------------------------
-- 3.10 Medicine Dispensals
-- -------------------------------------------------------
CREATE TABLE medicine_dispensals (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pharmacist_id   uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  prescription_id uuid NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
  medicine_id     uuid REFERENCES medicines(id) ON DELETE SET NULL,
  medicine_name   text,
  quantity        integer NOT NULL DEFAULT 0,
  price_per_unit  numeric(10, 2),
  total_price     numeric(10, 2),
  batch_number    text,
  is_returned     boolean NOT NULL DEFAULT false,
  returned_at     timestamptz,
  dispensed_at    timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.11 Messages
-- -------------------------------------------------------
CREATE TABLE messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id  uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message_text text,
  is_read      boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.12 Notifications
-- -------------------------------------------------------
CREATE TABLE notifications (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      text,
  body       text,
  type       text,
  data       jsonb,
  is_read    boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.13 User Sessions
-- -------------------------------------------------------
CREATE TABLE user_sessions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_name     text,
  device_type     text,
  ip_address      text,
  is_active       boolean NOT NULL DEFAULT true,
  last_active_at  timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.14 System Logs
-- -------------------------------------------------------
CREATE TABLE system_logs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action          text NOT NULL,
  performed_by    uuid REFERENCES users(id) ON DELETE SET NULL,
  target_user_id  uuid REFERENCES users(id) ON DELETE SET NULL,
  details         jsonb,
  log_level       text NOT NULL DEFAULT 'info',
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- -------------------------------------------------------
-- 3.15 Verification Queue
-- -------------------------------------------------------
CREATE TABLE verification_queue (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_type        user_type NOT NULL,
  license_number   text,
  submitted_at     timestamptz NOT NULL DEFAULT now(),
  status           verification_status NOT NULL DEFAULT 'pending',
  reviewed_by      uuid REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at      timestamptz,
  rejection_reason text
);

-- -------------------------------------------------------
-- 3.16 Payments
-- -------------------------------------------------------
CREATE TABLE payments (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pharmacist_id   uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  prescription_id uuid NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
  amount          numeric(10, 2) NOT NULL DEFAULT 0,
  payment_method  text,
  status          payment_status NOT NULL DEFAULT 'pending',
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- =========================
-- 4. Indexes
-- =========================

-- Users
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_mobile_number ON users(mobile_number);
CREATE INDEX idx_users_email ON users(email);

-- Patient Profiles
CREATE INDEX idx_patient_profiles_user_id ON patient_profiles(user_id);

-- Doctor Profiles
CREATE INDEX idx_doctor_profiles_user_id ON doctor_profiles(user_id);
CREATE INDEX idx_doctor_profiles_specialization ON doctor_profiles(specialization);
CREATE INDEX idx_doctor_profiles_verification_status ON doctor_profiles(verification_status);
CREATE INDEX idx_doctor_profiles_clinic_city ON doctor_profiles(clinic_city);

-- Pharmacist Profiles
CREATE INDEX idx_pharmacist_profiles_user_id ON pharmacist_profiles(user_id);
CREATE INDEX idx_pharmacist_profiles_verification_status ON pharmacist_profiles(verification_status);
CREATE INDEX idx_pharmacist_profiles_pharmacy_city ON pharmacist_profiles(pharmacy_city);

-- Appointments
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON appointments(doctor_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);

-- Prescriptions
CREATE INDEX idx_prescriptions_doctor_id ON prescriptions(doctor_id);
CREATE INDEX idx_prescriptions_patient_id ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_appointment_id ON prescriptions(appointment_id);

-- Health Records
CREATE INDEX idx_health_records_patient_id ON health_records(patient_id);
CREATE INDEX idx_health_records_record_type ON health_records(record_type);

-- Medicines
CREATE INDEX idx_medicines_category ON medicines(category);
CREATE INDEX idx_medicines_product_name ON medicines(product_name);

-- Pharmacy Inventory
CREATE INDEX idx_pharmacy_inventory_pharmacist_id ON pharmacy_inventory(pharmacist_id);
CREATE INDEX idx_pharmacy_inventory_medicine_id ON pharmacy_inventory(medicine_id);
CREATE INDEX idx_pharmacy_inventory_expiry_date ON pharmacy_inventory(expiry_date);

-- Medicine Dispensals
CREATE INDEX idx_medicine_dispensals_pharmacist_id ON medicine_dispensals(pharmacist_id);
CREATE INDEX idx_medicine_dispensals_patient_id ON medicine_dispensals(patient_id);
CREATE INDEX idx_medicine_dispensals_prescription_id ON medicine_dispensals(prescription_id);

-- Messages
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- User Sessions
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);

-- System Logs
CREATE INDEX idx_system_logs_performed_by ON system_logs(performed_by);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at);
CREATE INDEX idx_system_logs_log_level ON system_logs(log_level);

-- Verification Queue
CREATE INDEX idx_verification_queue_user_id ON verification_queue(user_id);
CREATE INDEX idx_verification_queue_status ON verification_queue(status);

-- Payments
CREATE INDEX idx_payments_patient_id ON payments(patient_id);
CREATE INDEX idx_payments_pharmacist_id ON payments(pharmacist_id);
CREATE INDEX idx_payments_prescription_id ON payments(prescription_id);
CREATE INDEX idx_payments_status ON payments(status);

-- =========================
-- 5. Row Level Security
-- =========================

-- Enable RLS on every table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pharmacist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE pharmacy_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicine_dispensals ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------
-- Helper: check if the authenticated user is a superuser
-- -------------------------------------------------------
CREATE OR REPLACE FUNCTION is_superuser() RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND user_type = 'superuser'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- -------------------------------------------------------
-- Helper: get the user_type for the authenticated user
-- -------------------------------------------------------
CREATE OR REPLACE FUNCTION current_user_type() RETURNS user_type AS $$
  SELECT user_type FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- -------------------------------------------------------
-- 5.1 Users policies
-- -------------------------------------------------------
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (id = auth.uid());

CREATE POLICY "Superusers can view all users"
  ON users FOR SELECT
  USING (is_superuser());

CREATE POLICY "Superusers can update any user"
  ON users FOR UPDATE
  USING (is_superuser());

CREATE POLICY "Allow insert for authenticated users"
  ON users FOR INSERT
  WITH CHECK (id = auth.uid());

-- -------------------------------------------------------
-- 5.2 Patient Profiles policies
-- -------------------------------------------------------
CREATE POLICY "Patients can view own profile"
  ON patient_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Patients can update own profile"
  ON patient_profiles FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Patients can insert own profile"
  ON patient_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Doctors can view patient profiles for their appointments"
  ON patient_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM appointments a
      WHERE a.patient_id = patient_profiles.user_id
        AND a.doctor_id = auth.uid()
    )
  );

CREATE POLICY "Superusers can view all patient profiles"
  ON patient_profiles FOR SELECT
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.3 Doctor Profiles policies
-- -------------------------------------------------------
CREATE POLICY "Doctors can view own profile"
  ON doctor_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Doctors can update own profile"
  ON doctor_profiles FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Doctors can insert own profile"
  ON doctor_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Patients can view approved doctor profiles"
  ON doctor_profiles FOR SELECT
  USING (verification_status = 'approved');

CREATE POLICY "Superusers can manage all doctor profiles"
  ON doctor_profiles FOR ALL
  USING (is_superuser());

CREATE POLICY "Verifiers can view doctor profiles"
  ON doctor_profiles FOR SELECT
  USING (current_user_type() = 'verifier');

CREATE POLICY "Verifiers can update doctor profiles"
  ON doctor_profiles FOR UPDATE
  USING (current_user_type() = 'verifier');

-- -------------------------------------------------------
-- 5.4 Pharmacist Profiles policies
-- -------------------------------------------------------
CREATE POLICY "Pharmacists can view own profile"
  ON pharmacist_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Pharmacists can update own profile"
  ON pharmacist_profiles FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Pharmacists can insert own profile"
  ON pharmacist_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Superusers can manage all pharmacist profiles"
  ON pharmacist_profiles FOR ALL
  USING (is_superuser());

CREATE POLICY "Verifiers can view pharmacist profiles"
  ON pharmacist_profiles FOR SELECT
  USING (current_user_type() = 'verifier');

CREATE POLICY "Verifiers can update pharmacist profiles"
  ON pharmacist_profiles FOR UPDATE
  USING (current_user_type() = 'verifier');

-- -------------------------------------------------------
-- 5.5 Appointments policies
-- -------------------------------------------------------
CREATE POLICY "Patients can view own appointments"
  ON appointments FOR SELECT
  USING (patient_id = auth.uid());

CREATE POLICY "Doctors can view own appointments"
  ON appointments FOR SELECT
  USING (doctor_id = auth.uid());

CREATE POLICY "Patients can create appointments"
  ON appointments FOR INSERT
  WITH CHECK (patient_id = auth.uid());

CREATE POLICY "Participants can update own appointments"
  ON appointments FOR UPDATE
  USING (patient_id = auth.uid() OR doctor_id = auth.uid());

CREATE POLICY "Superusers can manage all appointments"
  ON appointments FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.6 Prescriptions policies
-- -------------------------------------------------------
CREATE POLICY "Doctors can create prescriptions"
  ON prescriptions FOR INSERT
  WITH CHECK (doctor_id = auth.uid());

CREATE POLICY "Doctors can view own prescriptions"
  ON prescriptions FOR SELECT
  USING (doctor_id = auth.uid());

CREATE POLICY "Doctors can update own prescriptions within edit window"
  ON prescriptions FOR UPDATE
  USING (doctor_id = auth.uid() AND now() <= editable_until);

CREATE POLICY "Patients can view own prescriptions"
  ON prescriptions FOR SELECT
  USING (patient_id = auth.uid());

CREATE POLICY "Pharmacists can view prescriptions for dispensal"
  ON prescriptions FOR SELECT
  USING (current_user_type() = 'pharmacist');

CREATE POLICY "Superusers can manage all prescriptions"
  ON prescriptions FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.7 Health Records policies
-- -------------------------------------------------------
CREATE POLICY "Patients can view own health records"
  ON health_records FOR SELECT
  USING (patient_id = auth.uid());

CREATE POLICY "Patients can insert own health records"
  ON health_records FOR INSERT
  WITH CHECK (patient_id = auth.uid());

CREATE POLICY "Doctors can view patient records via appointment"
  ON health_records FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM appointments a
      WHERE a.patient_id = health_records.patient_id
        AND a.doctor_id = auth.uid()
    )
  );

CREATE POLICY "Data entry admins can insert health records"
  ON health_records FOR INSERT
  WITH CHECK (current_user_type() = 'data_entry_admin');

CREATE POLICY "Superusers can manage all health records"
  ON health_records FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.8 Medicines policies
-- -------------------------------------------------------
CREATE POLICY "Anyone authenticated can view medicines"
  ON medicines FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Data entry admins can manage medicines"
  ON medicines FOR ALL
  USING (current_user_type() = 'data_entry_admin');

CREATE POLICY "Superusers can manage all medicines"
  ON medicines FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.9 Pharmacy Inventory policies
-- -------------------------------------------------------
CREATE POLICY "Pharmacists can view own inventory"
  ON pharmacy_inventory FOR SELECT
  USING (pharmacist_id = auth.uid());

CREATE POLICY "Pharmacists can manage own inventory"
  ON pharmacy_inventory FOR ALL
  USING (pharmacist_id = auth.uid());

CREATE POLICY "Superusers can manage all inventory"
  ON pharmacy_inventory FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.10 Medicine Dispensals policies
-- -------------------------------------------------------
CREATE POLICY "Pharmacists can manage own dispensals"
  ON medicine_dispensals FOR ALL
  USING (pharmacist_id = auth.uid());

CREATE POLICY "Patients can view own dispensals"
  ON medicine_dispensals FOR SELECT
  USING (patient_id = auth.uid());

CREATE POLICY "Superusers can manage all dispensals"
  ON medicine_dispensals FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.11 Messages policies
-- -------------------------------------------------------
CREATE POLICY "Users can view own messages"
  ON messages FOR SELECT
  USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Receiver can mark messages as read"
  ON messages FOR UPDATE
  USING (receiver_id = auth.uid());

-- -------------------------------------------------------
-- 5.12 Notifications policies
-- -------------------------------------------------------
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- -------------------------------------------------------
-- 5.13 User Sessions policies
-- -------------------------------------------------------
CREATE POLICY "Users can view own sessions"
  ON user_sessions FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own sessions"
  ON user_sessions FOR ALL
  USING (user_id = auth.uid());

CREATE POLICY "Superusers can view all sessions"
  ON user_sessions FOR SELECT
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.14 System Logs policies
-- -------------------------------------------------------
CREATE POLICY "Superusers can view all system logs"
  ON system_logs FOR SELECT
  USING (is_superuser());

CREATE POLICY "System can insert logs"
  ON system_logs FOR INSERT
  WITH CHECK (true);

-- -------------------------------------------------------
-- 5.15 Verification Queue policies
-- -------------------------------------------------------
CREATE POLICY "Users can view own verification status"
  ON verification_queue FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can submit verification requests"
  ON verification_queue FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Verifiers can view queue"
  ON verification_queue FOR SELECT
  USING (current_user_type() = 'verifier');

CREATE POLICY "Verifiers can update queue"
  ON verification_queue FOR UPDATE
  USING (current_user_type() = 'verifier');

CREATE POLICY "Superusers can manage verification queue"
  ON verification_queue FOR ALL
  USING (is_superuser());

-- -------------------------------------------------------
-- 5.16 Payments policies
-- -------------------------------------------------------
CREATE POLICY "Patients can view own payments"
  ON payments FOR SELECT
  USING (patient_id = auth.uid());

CREATE POLICY "Pharmacists can view own payments"
  ON payments FOR SELECT
  USING (pharmacist_id = auth.uid());

CREATE POLICY "Pharmacists can create payments"
  ON payments FOR INSERT
  WITH CHECK (pharmacist_id = auth.uid());

CREATE POLICY "Superusers can manage all payments"
  ON payments FOR ALL
  USING (is_superuser());

-- =========================
-- 6. Superuser Seed
-- =========================
-- Replace the UUID below with the actual auth.users id of the superuser account
-- after creating the user through Supabase Auth.
--
-- INSERT INTO users (id, full_name, email, mobile_number, user_type, is_verified, profile_completed)
-- VALUES (
--   '00000000-0000-0000-0000-000000000000',  -- replace with real auth.users id
--   'JeevanPatra Admin',
--   'admin@jeevanpatra.com',
--   '+919999999999',
--   'superuser',
--   true,
--   true
-- );
