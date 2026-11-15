USE e_scuela_db;
START TRANSACTION;

-- 1. USERS (Admin, 6 Faculty, 6 Students)
INSERT INTO users (id, username, password_hash, role, account_status) VALUES
(1, 'admin', 'admin123', 'admin', 'Active'),
(2, 'salette.maria', 'maria123', 'faculty', 'Active'),
(3, 'juan.reyes', 'reyes123', 'faculty', 'Active'),
(4, 'elena.cruz', 'cruz123', 'faculty', 'Active'),
(5, 'ricardo.dalisay', 'dalisay123', 'faculty', 'Active'),
(6, 'angelica.mendoza', 'mendoza123', 'faculty', 'Active'),
(7, 'gabriel.perez', 'perez123', 'faculty', 'Active'),
(8, '2026-001', '2026-001', 'student', 'Active'),
(9, '2026-002', '2026-002', 'student', 'Active'),
(10, '2026-003', '2026-003', 'student', 'Active'),
(11, '2026-004', '2026-004', 'student', 'Active'),
(12, '2026-005', '2026-005', 'student', 'Active'),
(13, '2026-006', '2026-006', 'student', 'Active');

-- 2. FACULTY PROFILES
INSERT INTO faculty (faculty_id, user_id, full_name, department, email, contact_number, office, status) VALUES
('FAC-2026-01', 2, 'Prof. Maria Santos', 'Senior High School', 'm.santos@salette.edu.ph', '0917-555-0199', 'Faculty Room 204, St. Joseph Hall', 'Active'),
('FAC-2026-02', 3, 'Mr. Juan Reyes', 'Senior High School', 'j.reyes@salette.edu.ph', '0917-555-0142', 'Faculty Room 201', 'Active'),
('FAC-2026-03', 4, 'Ms. Elena Cruz', 'Junior High School', 'e.cruz@salette.edu.ph', '0917-555-0188', 'Science Faculty Room', 'Active'),
('FAC-2026-04', 5, 'Mr. Ricardo Dalisay', 'Senior High School', 'r.dalisay@salette.edu.ph', '0917-555-0164', 'Faculty Room 203, St. Joseph Hall', 'Active'),
('FAC-2026-05', 6, 'Ms. Angelica Mendoza', 'Senior High School', 'a.mendoza@salette.edu.ph', '0917-555-0175', 'Faculty Room 202', 'Active'),
('FAC-2026-06', 7, 'Coach Gabriel Perez', 'Elementary', 'g.perez@salette.edu.ph', '0917-555-0153', 'Gymnasium Faculty Office', 'Active');

-- 3. STUDENT PROFILES
INSERT INTO students (student_id, user_id, full_name, grade_level, section, academic_status) VALUES
('2026-001', 8, 'CATHERINE A. ROSARIO', 'Grade 12', 'ABM-A', 'Enrolled'),
('2026-002', 9, 'ACHILLES NERO C. AGUILA', 'Grade 11', 'ABM-A', 'Enrolled'),
('2026-003', 10, 'PRINCE CARL B. BARTOLOME', 'Grade 12', 'ABM-A', 'Enrolled'),
('2026-004', 11, 'BLUE BARRON B. BAMBILLA', 'Grade 11', 'HUMSS-A', 'Enrolled'),
('2026-005', 12, 'JAYSON J. ESQUEJO', 'Grade 12', 'ABM-A', 'Enrolled'),
('2026-006', 13, 'CARL ANTHONY V. DE VERA', 'Grade 12', 'ABM-A', 'Enrolled');

-- 4. SUBJECTS CATALOG (SUB-01 to SUB-35)
INSERT INTO subjects (subject_id, subject_name) VALUES
('SUB-01', 'English'),
('SUB-02', 'Filipino'),
('SUB-03', 'Math'),
('SUB-04', 'Mathematics'),
('SUB-05', 'Science'),
('SUB-06', 'Makabansa'),
('SUB-07', 'GMRC'),
('SUB-08', 'Araling Panlipunan'),
('SUB-09', 'EPP'),
('SUB-10', 'MAPEH'),
('SUB-11', 'TLE'),
('SUB-12', 'Oral Communication'),
('SUB-13', 'General Mathematics'),
('SUB-14', 'Business Mathematics'),
('SUB-15', 'Organization and Management'),
('SUB-16', 'FABM 1'),
('SUB-17', 'Principles of Marketing'),
('SUB-18', 'Disciplines and Ideas in the Social Sciences'),
('SUB-19', 'Creative Writing'),
('SUB-20', 'World Religions'),
('SUB-21', 'Philippine Politics'),
('SUB-22', '21st Century Literature'),
('SUB-23', 'Media and Information Literacy'),
('SUB-24', 'Research 2'),
('SUB-25', '3Is'),
('SUB-26', 'Entrepreneurship'),
('SUB-27', 'Work Immersion'),
('SUB-28', 'FABM 2'),
('SUB-29', 'Business Finance'),
('SUB-30', 'Applied Economics'),
('SUB-31', 'Business Ethics'),
('SUB-32', 'DIASS'),
('SUB-33', 'Creative Nonfiction'),
('SUB-34', 'Trends and Networks'),
('SUB-35', 'CESC');

-- 5. SUBJECT CURRICULUM ASSIGNMENTS (Grades 1-12, Strands, Semesters)
INSERT INTO subject_assignments (subject_id, grade_level, strand, semester) VALUES
-- English & Filipino (Grade 1 - 10)
('SUB-01', 'Grade 1', 'N/A', 'N/A'), ('SUB-01', 'Grade 2', 'N/A', 'N/A'), ('SUB-01', 'Grade 3', 'N/A', 'N/A'),
('SUB-01', 'Grade 4', 'N/A', 'N/A'), ('SUB-01', 'Grade 5', 'N/A', 'N/A'), ('SUB-01', 'Grade 6', 'N/A', 'N/A'),
('SUB-01', 'Grade 7', 'N/A', 'N/A'), ('SUB-01', 'Grade 8', 'N/A', 'N/A'), ('SUB-01', 'Grade 9', 'N/A', 'N/A'), ('SUB-01', 'Grade 10', 'N/A', 'N/A'),
('SUB-02', 'Grade 1', 'N/A', 'N/A'), ('SUB-02', 'Grade 2', 'N/A', 'N/A'), ('SUB-02', 'Grade 3', 'N/A', 'N/A'),
('SUB-02', 'Grade 4', 'N/A', 'N/A'), ('SUB-02', 'Grade 5', 'N/A', 'N/A'), ('SUB-02', 'Grade 6', 'N/A', 'N/A'),
('SUB-02', 'Grade 7', 'N/A', 'N/A'), ('SUB-02', 'Grade 8', 'N/A', 'N/A'), ('SUB-02', 'Grade 9', 'N/A', 'N/A'), ('SUB-02', 'Grade 10', 'N/A', 'N/A'),
-- Math (Grade 1 - 6) & Mathematics (Grade 7 - 10)
('SUB-03', 'Grade 1', 'N/A', 'N/A'), ('SUB-03', 'Grade 2', 'N/A', 'N/A'), ('SUB-03', 'Grade 3', 'N/A', 'N/A'),
('SUB-03', 'Grade 4', 'N/A', 'N/A'), ('SUB-03', 'Grade 5', 'N/A', 'N/A'), ('SUB-03', 'Grade 6', 'N/A', 'N/A'),
('SUB-04', 'Grade 7', 'N/A', 'N/A'), ('SUB-04', 'Grade 8', 'N/A', 'N/A'), ('SUB-04', 'Grade 9', 'N/A', 'N/A'), ('SUB-04', 'Grade 10', 'N/A', 'N/A'),
-- Science (Grade 1 - 10)
('SUB-05', 'Grade 1', 'N/A', 'N/A'), ('SUB-05', 'Grade 2', 'N/A', 'N/A'), ('SUB-05', 'Grade 3', 'N/A', 'N/A'),
('SUB-05', 'Grade 4', 'N/A', 'N/A'), ('SUB-05', 'Grade 5', 'N/A', 'N/A'), ('SUB-05', 'Grade 6', 'N/A', 'N/A'),
('SUB-05', 'Grade 7', 'N/A', 'N/A'), ('SUB-05', 'Grade 8', 'N/A', 'N/A'), ('SUB-05', 'Grade 9', 'N/A', 'N/A'), ('SUB-05', 'Grade 10', 'N/A', 'N/A'),
-- Makabansa (Grade 1 - 3), GMRC (Grade 1 - 6), AP (Grade 4 - 10), EPP (Grade 4 - 6), MAPEH (Grade 4 - 10), TLE (Grade 7 - 10)
('SUB-06', 'Grade 1', 'N/A', 'N/A'), ('SUB-06', 'Grade 2', 'N/A', 'N/A'), ('SUB-06', 'Grade 3', 'N/A', 'N/A'),
('SUB-07', 'Grade 1', 'N/A', 'N/A'), ('SUB-07', 'Grade 2', 'N/A', 'N/A'), ('SUB-07', 'Grade 3', 'N/A', 'N/A'),
('SUB-07', 'Grade 4', 'N/A', 'N/A'), ('SUB-07', 'Grade 5', 'N/A', 'N/A'), ('SUB-07', 'Grade 6', 'N/A', 'N/A'),
('SUB-08', 'Grade 4', 'N/A', 'N/A'), ('SUB-08', 'Grade 5', 'N/A', 'N/A'), ('SUB-08', 'Grade 6', 'N/A', 'N/A'),
('SUB-08', 'Grade 7', 'N/A', 'N/A'), ('SUB-08', 'Grade 8', 'N/A', 'N/A'), ('SUB-08', 'Grade 9', 'N/A', 'N/A'), ('SUB-08', 'Grade 10', 'N/A', 'N/A'),
('SUB-09', 'Grade 4', 'N/A', 'N/A'), ('SUB-09', 'Grade 5', 'N/A', 'N/A'), ('SUB-09', 'Grade 6', 'N/A', 'N/A'),
('SUB-10', 'Grade 4', 'N/A', 'N/A'), ('SUB-10', 'Grade 5', 'N/A', 'N/A'), ('SUB-10', 'Grade 6', 'N/A', 'N/A'),
('SUB-10', 'Grade 7', 'N/A', 'N/A'), ('SUB-10', 'Grade 8', 'N/A', 'N/A'), ('SUB-10', 'Grade 9', 'N/A', 'N/A'), ('SUB-10', 'Grade 10', 'N/A', 'N/A'),
('SUB-11', 'Grade 7', 'N/A', 'N/A'), ('SUB-11', 'Grade 8', 'N/A', 'N/A'), ('SUB-11', 'Grade 9', 'N/A', 'N/A'), ('SUB-11', 'Grade 10', 'N/A', 'N/A'),
-- Grade 11 (ABM & HUMSS)
('SUB-12', 'Grade 11', 'ABM', '1st Sem'), ('SUB-12', 'Grade 11', 'HUMSS', '1st Sem'),
('SUB-13', 'Grade 11', 'ABM', '1st Sem'), ('SUB-13', 'Grade 11', 'HUMSS', '1st Sem'),
('SUB-14', 'Grade 11', 'ABM', '1st Sem'), ('SUB-15', 'Grade 11', 'ABM', '1st Sem'),
('SUB-16', 'Grade 11', 'ABM', '2nd Sem'), ('SUB-17', 'Grade 11', 'ABM', '2nd Sem'),
('SUB-18', 'Grade 11', 'HUMSS', '1st Sem'), ('SUB-19', 'Grade 11', 'HUMSS', '1st Sem'),
('SUB-20', 'Grade 11', 'HUMSS', '2nd Sem'), ('SUB-21', 'Grade 11', 'HUMSS', '2nd Sem'),
-- Grade 12 (ABM & HUMSS)
('SUB-22', 'Grade 12', 'ABM', '1st Sem'), ('SUB-22', 'Grade 12', 'HUMSS', '1st Sem'),
('SUB-23', 'Grade 12', 'ABM', '1st Sem'), ('SUB-23', 'Grade 12', 'HUMSS', '1st Sem'),
('SUB-24', 'Grade 12', 'ABM', '2nd Sem'), ('SUB-24', 'Grade 12', 'HUMSS', '2nd Sem'),
('SUB-25', 'Grade 12', 'ABM', '2nd Sem'), ('SUB-25', 'Grade 12', 'HUMSS', '2nd Sem'),
('SUB-26', 'Grade 12', 'ABM', '2nd Sem'), ('SUB-26', 'Grade 12', 'HUMSS', '2nd Sem'),
('SUB-27', 'Grade 12', 'ABM', '2nd Sem'), ('SUB-27', 'Grade 12', 'HUMSS', '2nd Sem'),
('SUB-28', 'Grade 12', 'ABM', '1st Sem'), ('SUB-29', 'Grade 12', 'ABM', '1st Sem'),
('SUB-30', 'Grade 12', 'ABM', '2nd Sem'), ('SUB-31', 'Grade 12', 'ABM', '2nd Sem'),
('SUB-32', 'Grade 12', 'HUMSS', '1st Sem'), ('SUB-33', 'Grade 12', 'HUMSS', '1st Sem'),
('SUB-34', 'Grade 12', 'HUMSS', '2nd Sem'), ('SUB-35', 'Grade 12', 'HUMSS', '2nd Sem');

-- 6. FACULTY-SUBJECT ASSIGNMENTS
INSERT INTO faculty_subjects (faculty_id, subject_id) VALUES
('FAC-2026-01', 'SUB-23'), ('FAC-2026-01', 'SUB-24'), ('FAC-2026-01', 'SUB-25'), ('FAC-2026-01', 'SUB-27'),
('FAC-2026-02', 'SUB-01'), ('FAC-2026-02', 'SUB-02'), ('FAC-2026-02', 'SUB-12'), ('FAC-2026-02', 'SUB-19'), ('FAC-2026-02', 'SUB-22'), ('FAC-2026-02', 'SUB-33'),
('FAC-2026-03', 'SUB-03'), ('FAC-2026-03', 'SUB-04'), ('FAC-2026-03', 'SUB-05'), ('FAC-2026-03', 'SUB-13'), ('FAC-2026-03', 'SUB-14'),
('FAC-2026-04', 'SUB-15'), ('FAC-2026-04', 'SUB-16'), ('FAC-2026-04', 'SUB-17'), ('FAC-2026-04', 'SUB-26'), ('FAC-2026-04', 'SUB-28'), ('FAC-2026-04', 'SUB-29'), ('FAC-2026-04', 'SUB-30'), ('FAC-2026-04', 'SUB-31'),
('FAC-2026-05', 'SUB-06'), ('FAC-2026-05', 'SUB-07'), ('FAC-2026-05', 'SUB-08'), ('FAC-2026-05', 'SUB-18'), ('FAC-2026-05', 'SUB-20'), ('FAC-2026-05', 'SUB-21'), ('FAC-2026-05', 'SUB-32'), ('FAC-2026-05', 'SUB-34'), ('FAC-2026-05', 'SUB-35'),
('FAC-2026-06', 'SUB-09'), ('FAC-2026-06', 'SUB-10'), ('FAC-2026-06', 'SUB-11');

-- 7. ENROLLMENTS
INSERT INTO enrollments (student_id, school_year, grade_level, strand, semester, section, enrollment_date, enrollment_status) VALUES
('2026-001', '2026-2027', 'Grade 12', 'ABM', '1st Sem', 'ABM-A', '2026-06-15', 'Enrolled'),
('2026-002', '2026-2027', 'Grade 11', 'ABM', '1st Sem', 'ABM-A', '2026-06-15', 'Enrolled'),
('2026-003', '2026-2027', 'Grade 12', 'ABM', '1st Sem', 'ABM-A', '2026-06-15', 'Enrolled'),
('2026-004', '2026-2027', 'Grade 11', 'HUMSS', '1st Sem', 'HUMSS-A', '2026-06-15', 'Enrolled'),
('2026-005', '2026-2027', 'Grade 12', 'ABM', '1st Sem', 'ABM-A', '2026-06-15', 'Enrolled'),
('2026-006', '2026-2027', 'Grade 12', 'ABM', '1st Sem', 'ABM-A', '2026-06-15', 'Enrolled');

-- 8. CLASS SCHEDULES (All 39 schedules from store.js)
INSERT INTO class_schedules (schedule_id, faculty_id, subject_id, target_type, student_id, grade_level, strand, semester, section, day_of_week, start_time, end_time, room) VALUES
-- Grade 12 ABM-A
('SCH-001', 'FAC-2026-02', 'SUB-22', 'section', NULL, 'Grade 12', 'ABM', '1st Sem', 'ABM-A', 'Monday', '08:00:00', '09:00:00', 'Room 301'),
('SCH-002', 'FAC-2026-01', 'SUB-23', 'section', NULL, 'Grade 12', 'ABM', '1st Sem', 'ABM-A', 'Monday', '09:00:00', '10:00:00', 'Computer Lab 1'),
('SCH-003', 'FAC-2026-04', 'SUB-28', 'section', NULL, 'Grade 12', 'ABM', '1st Sem', 'ABM-A', 'Monday', '10:30:00', '11:30:00', 'Room 301'),
('SCH-004', 'FAC-2026-04', 'SUB-29', 'section', NULL, 'Grade 12', 'ABM', '1st Sem', 'ABM-A', 'Tuesday', '08:00:00', '09:00:00', 'Room 301'),
('SCH-005', 'FAC-2026-04', 'SUB-26', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Tuesday', '09:00:00', '10:00:00', 'Room 301'),
('SCH-006', 'FAC-2026-01', 'SUB-25', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Tuesday', '10:30:00', '11:30:00', 'Computer Lab 2'),
('SCH-007', 'FAC-2026-04', 'SUB-30', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Wednesday', '08:00:00', '09:00:00', 'Room 301'),
('SCH-008', 'FAC-2026-04', 'SUB-31', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Wednesday', '09:00:00', '10:00:00', 'Room 301'),
('SCH-009', 'FAC-2026-01', 'SUB-24', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Wednesday', '13:00:00', '14:00:00', 'Computer Lab 2'),
('SCH-010', 'FAC-2026-01', 'SUB-27', 'section', NULL, 'Grade 12', 'ABM', '2nd Sem', 'ABM-A', 'Friday', '13:00:00', '15:00:00', 'SHS Immersion Room'),
-- Grade 11 ABM-A
('SCH-011', 'FAC-2026-03', 'SUB-13', 'section', NULL, 'Grade 11', 'ABM', '1st Sem', 'ABM-A', 'Monday', '08:00:00', '09:00:00', 'Room 201'),
('SCH-012', 'FAC-2026-02', 'SUB-12', 'section', NULL, 'Grade 11', 'ABM', '1st Sem', 'ABM-A', 'Monday', '09:00:00', '10:00:00', 'Room 201'),
('SCH-013', 'FAC-2026-03', 'SUB-14', 'section', NULL, 'Grade 11', 'ABM', '1st Sem', 'ABM-A', 'Tuesday', '08:00:00', '09:00:00', 'Room 201'),
('SCH-014', 'FAC-2026-04', 'SUB-15', 'section', NULL, 'Grade 11', 'ABM', '1st Sem', 'ABM-A', 'Thursday', '08:00:00', '09:00:00', 'Room 201'),
('SCH-015', 'FAC-2026-04', 'SUB-16', 'section', NULL, 'Grade 11', 'ABM', '2nd Sem', 'ABM-A', 'Thursday', '09:00:00', '10:00:00', 'Room 201'),
('SCH-016', 'FAC-2026-04', 'SUB-17', 'section', NULL, 'Grade 11', 'ABM', '2nd Sem', 'ABM-A', 'Friday', '08:00:00', '09:00:00', 'Room 201'),
-- Grade 11 HUMSS-A
('SCH-017', 'FAC-2026-05', 'SUB-18', 'section', NULL, 'Grade 11', 'HUMSS', '1st Sem', 'HUMSS-A', 'Monday', '08:00:00', '09:00:00', 'Room 205'),
('SCH-018', 'FAC-2026-05', 'SUB-20', 'section', NULL, 'Grade 11', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Monday', '09:00:00', '10:00:00', 'Room 205'),
('SCH-019', 'FAC-2026-03', 'SUB-13', 'section', NULL, 'Grade 11', 'HUMSS', '1st Sem', 'HUMSS-A', 'Tuesday', '09:00:00', '10:00:00', 'Room 205'),
('SCH-020', 'FAC-2026-02', 'SUB-12', 'section', NULL, 'Grade 11', 'HUMSS', '1st Sem', 'HUMSS-A', 'Wednesday', '08:00:00', '09:00:00', 'Room 205'),
('SCH-021', 'FAC-2026-05', 'SUB-21', 'section', NULL, 'Grade 11', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Thursday', '08:00:00', '09:00:00', 'Room 205'),
('SCH-022', 'FAC-2026-02', 'SUB-19', 'section', NULL, 'Grade 11', 'HUMSS', '1st Sem', 'HUMSS-A', 'Friday', '10:00:00', '11:00:00', 'Room 205'),
-- Grade 12 HUMSS-A
('SCH-023', 'FAC-2026-05', 'SUB-32', 'section', NULL, 'Grade 12', 'HUMSS', '1st Sem', 'HUMSS-A', 'Tuesday', '08:00:00', '09:00:00', 'Room 304'),
('SCH-024', 'FAC-2026-02', 'SUB-33', 'section', NULL, 'Grade 12', 'HUMSS', '1st Sem', 'HUMSS-A', 'Tuesday', '10:30:00', '11:30:00', 'Room 304'),
('SCH-025', 'FAC-2026-05', 'SUB-34', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Wednesday', '09:00:00', '10:00:00', 'Room 304'),
('SCH-026', 'FAC-2026-05', 'SUB-35', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Wednesday', '10:30:00', '11:30:00', 'Room 304'),
('SCH-027', 'FAC-2026-02', 'SUB-22', 'section', NULL, 'Grade 12', 'HUMSS', '1st Sem', 'HUMSS-A', 'Thursday', '08:00:00', '09:00:00', 'Room 304'),
('SCH-028', 'FAC-2026-01', 'SUB-23', 'section', NULL, 'Grade 12', 'HUMSS', '1st Sem', 'HUMSS-A', 'Thursday', '09:00:00', '10:00:00', 'Computer Lab 1'),
('SCH-029', 'FAC-2026-01', 'SUB-24', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Thursday', '13:00:00', '14:00:00', 'Computer Lab 2'),
('SCH-030', 'FAC-2026-01', 'SUB-25', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Friday', '08:00:00', '09:00:00', 'Computer Lab 2'),
('SCH-031', 'FAC-2026-04', 'SUB-26', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Friday', '09:00:00', '10:00:00', 'Room 304'),
('SCH-032', 'FAC-2026-05', 'SUB-27', 'section', NULL, 'Grade 12', 'HUMSS', '2nd Sem', 'HUMSS-A', 'Friday', '13:00:00', '15:00:00', 'Community Immersion Site'),
-- Elementary & Junior High
('SCH-033', 'FAC-2026-05', 'SUB-06', 'section', NULL, 'Grade 1', 'N/A', 'N/A', 'Section A', 'Mon / Wed / Fri', '08:00:00', '08:45:00', 'Room 101'),
('SCH-034', 'FAC-2026-03', 'SUB-03', 'section', NULL, 'Grade 1', 'N/A', 'N/A', 'Section A', 'Mon / Wed / Fri', '09:00:00', '09:45:00', 'Room 101'),
('SCH-035', 'FAC-2026-02', 'SUB-01', 'section', NULL, 'Grade 1', 'N/A', 'N/A', 'Section A', 'Tue / Thu', '08:00:00', '08:45:00', 'Room 101'),
('SCH-036', 'FAC-2026-06', 'SUB-09', 'section', NULL, 'Grade 4', 'N/A', 'N/A', 'Section A', 'Mon / Wed', '13:00:00', '14:00:00', 'HE / ICT Lab'),
('SCH-037', 'FAC-2026-06', 'SUB-10', 'section', NULL, 'Grade 7', 'N/A', 'N/A', 'Section A', 'Tue / Thu', '14:00:00', '15:00:00', 'Gymnasium'),
('SCH-038', 'FAC-2026-06', 'SUB-11', 'section', NULL, 'Grade 10', 'N/A', 'N/A', 'Section A', 'Mon / Wed', '14:00:00', '15:00:00', 'TLE Workshop'),
('SCH-039', 'FAC-2026-03', 'SUB-04', 'section', NULL, 'Grade 10', 'N/A', 'N/A', 'Section A', 'Mon / Wed / Fri', '10:30:00', '11:30:00', 'Room 108');

-- 9. SAMPLE GRADES (All 6 Demo Students)
INSERT INTO grades (student_id, subject_id, school_year, q1, q2, q3, q4) VALUES
-- 2026-001 (Catherine)
('2026-001', 'SUB-22', '2026-2027', 88, 90, 89, 91),
('2026-001', 'SUB-23', '2026-2027', 91, 90, 92, 93),
('2026-001', 'SUB-24', '2026-2027', 90, 91, 89, 92),
('2026-001', 'SUB-25', '2026-2027', 92, 91, 90, 93),
('2026-001', 'SUB-26', '2026-2027', 95, 94, 96, 95),
('2026-001', 'SUB-27', '2026-2027', 93, 94, 95, 95),
('2026-001', 'SUB-28', '2026-2027', 89, 90, 91, 90),
('2026-001', 'SUB-29', '2026-2027', 90, 92, 91, 93),
('2026-001', 'SUB-30', '2026-2027', 85, 86, 87, 88),
('2026-001', 'SUB-31', '2026-2027', 91, 92, 91, 93),
-- 2026-002 (Achilles)
('2026-002', 'SUB-12', '2026-2027', 85, 87, 88, 86),
('2026-002', 'SUB-13', '2026-2027', 90, 91, 92, 91),
('2026-002', 'SUB-14', '2026-2027', 91, 90, 92, 93),
('2026-002', 'SUB-15', '2026-2027', 94, 95, 94, 96),
('2026-002', 'SUB-16', '2026-2027', 89, 88, 90, 91),
('2026-002', 'SUB-17', '2026-2027', 86, 87, 88, 89),
-- 2026-003 (Prince Carl)
('2026-003', 'SUB-22', '2026-2027', 93, 94, 94, 95),
('2026-003', 'SUB-23', '2026-2027', 92, 93, 93, 94),
('2026-003', 'SUB-24', '2026-2027', 94, 95, 94, 95),
('2026-003', 'SUB-25', '2026-2027', 91, 92, 93, 93),
('2026-003', 'SUB-26', '2026-2027', 95, 96, 96, 96),
('2026-003', 'SUB-27', '2026-2027', 94, 95, 95, 96),
('2026-003', 'SUB-28', '2026-2027', 92, 93, 94, 94),
('2026-003', 'SUB-29', '2026-2027', 91, 92, 93, 94),
('2026-003', 'SUB-30', '2026-2027', 90, 91, 92, 92),
('2026-003', 'SUB-31', '2026-2027', 93, 93, 94, 95),
-- 2026-004 (Blue Barron)
('2026-004', 'SUB-12', '2026-2027', 84, 85, 86, 87),
('2026-004', 'SUB-13', '2026-2027', 88, 89, 90, 89),
('2026-004', 'SUB-18', '2026-2027', 90, 91, 90, 92),
('2026-004', 'SUB-19', '2026-2027', 94, 95, 94, 95),
('2026-004', 'SUB-20', '2026-2027', 87, 88, 89, 90),
('2026-004', 'SUB-21', '2026-2027', 88, 89, 89, 90),
-- 2026-005 (Jayson)
('2026-005', 'SUB-22', '2026-2027', 92, 93, 93, 94),
('2026-005', 'SUB-23', '2026-2027', 91, 92, 93, 93),
('2026-005', 'SUB-24', '2026-2027', 93, 94, 93, 94),
('2026-005', 'SUB-25', '2026-2027', 92, 93, 93, 94),
('2026-005', 'SUB-26', '2026-2027', 95, 96, 95, 96),
('2026-005', 'SUB-27', '2026-2027', 94, 94, 95, 96),
('2026-005', 'SUB-28', '2026-2027', 90, 91, 92, 92),
('2026-005', 'SUB-29', '2026-2027', 91, 92, 92, 93),
('2026-005', 'SUB-30', '2026-2027', 89, 90, 91, 91),
('2026-005', 'SUB-31', '2026-2027', 92, 93, 93, 94),
-- 2026-006 (Carl Anthony)
('2026-006', 'SUB-22', '2026-2027', 90, 91, 91, 92),
('2026-006', 'SUB-23', '2026-2027', 91, 92, 92, 93),
('2026-006', 'SUB-24', '2026-2027', 91, 92, 92, 93),
('2026-006', 'SUB-25', '2026-2027', 90, 91, 91, 92),
('2026-006', 'SUB-26', '2026-2027', 94, 95, 95, 95),
('2026-006', 'SUB-27', '2026-2027', 93, 94, 94, 95),
('2026-006', 'SUB-28', '2026-2027', 89, 90, 91, 92),
('2026-006', 'SUB-29', '2026-2027', 90, 91, 92, 92),
('2026-006', 'SUB-30', '2026-2027', 90, 91, 91, 92),
('2026-006', 'SUB-31', '2026-2027', 91, 92, 92, 93);

-- 10. ANNOUNCEMENTS
INSERT INTO announcements (announcement_id, title, target, author_name, posted_date, content) VALUES
('ANN-001', '2nd Quarter Examination Guidelines', 'All Classes', 'Prof. Maria Santos', '2026-11-05', 'Please be reminded that the 2nd Quarter Examination schedules have been posted. Prepare all draft papers and research folios prior to Friday.'),
('ANN-002', 'ABM-A Research 2 Consultation', 'Grade 12 - ABM-A', 'Prof. Maria Santos', '2026-11-08', 'Research 2 capstone draft consultations will take place this Wednesday at Computer Lab 2. Attendance is mandatory.');

COMMIT;
