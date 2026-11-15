-- E-SCUELA database import for TiDB Cloud.
-- Import into a new, empty database. This script does not drop existing data.
-- The schema matches database/schema.sql and retains the records from the
-- previous MariaDB dump where their columns map to the current schema.

CREATE DATABASE IF NOT EXISTS e_scuela_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE e_scuela_db;

CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'faculty', 'student') NOT NULL DEFAULT 'student',
    account_status ENUM('Active', 'On Leave', 'Inactive', 'Resigned') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY unique_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE students (
    student_id VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    grade_level VARCHAR(20) NOT NULL DEFAULT 'Pending',
    section VARCHAR(50) NOT NULL DEFAULT 'Pending Enrollment',
    academic_status ENUM('Regular', 'Irregular', 'Transferee', 'Enrolled', 'Pending', 'Dropped') NOT NULL DEFAULT 'Enrolled',
    contact_number VARCHAR(20) DEFAULT 'N/A',
    guardian_name VARCHAR(100) DEFAULT 'N/A',
    PRIMARY KEY (student_id),
    UNIQUE KEY unique_student_user (user_id),
    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE faculty (
    faculty_id VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    department ENUM('Elementary', 'Junior High School', 'Senior High School') NOT NULL,
    email VARCHAR(120) NOT NULL,
    contact_number VARCHAR(20) DEFAULT 'N/A',
    office VARCHAR(100) DEFAULT 'Faculty Room',
    status ENUM('Active', 'On Leave', 'Inactive', 'Resigned') NOT NULL DEFAULT 'Active',
    PRIMARY KEY (faculty_id),
    UNIQUE KEY unique_faculty_user (user_id),
    CONSTRAINT fk_faculty_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE subjects (
    subject_id VARCHAR(20) NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (subject_id),
    UNIQUE KEY unique_subject_name (subject_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE subject_assignments (
    id INT NOT NULL AUTO_INCREMENT,
    subject_id VARCHAR(20) NOT NULL,
    grade_level VARCHAR(20) NOT NULL,
    strand ENUM('N/A', 'ABM', 'HUMSS') NOT NULL DEFAULT 'N/A',
    semester ENUM('N/A', '1st Sem', '2nd Sem') NOT NULL DEFAULT 'N/A',
    PRIMARY KEY (id),
    UNIQUE KEY unique_subject_curriculum (subject_id, grade_level, strand, semester),
    CONSTRAINT fk_sub_assign_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE faculty_subjects (
    id INT NOT NULL AUTO_INCREMENT,
    faculty_id VARCHAR(20) NOT NULL,
    subject_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY unique_faculty_subject (faculty_id, subject_id),
    CONSTRAINT fk_fac_sub_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fac_sub_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE enrollments (
    id INT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(20) NOT NULL,
    school_year VARCHAR(20) NOT NULL,
    grade_level VARCHAR(20) NOT NULL,
    strand ENUM('N/A', 'ABM', 'HUMSS') NOT NULL DEFAULT 'N/A',
    semester ENUM('N/A', '1st Sem', '2nd Sem') NOT NULL DEFAULT 'N/A',
    section VARCHAR(50) NOT NULL,
    enrollment_date DATE NOT NULL,
    enrollment_status ENUM('Enrolled', 'Pending', 'Dropped') NOT NULL DEFAULT 'Enrolled',
    PRIMARY KEY (id),
    UNIQUE KEY unique_student_sy_sem (student_id, school_year, semester),
    KEY idx_enrollments_student (student_id),
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE class_schedules (
    schedule_id VARCHAR(20) NOT NULL,
    faculty_id VARCHAR(20) NOT NULL,
    subject_id VARCHAR(20) NOT NULL,
    target_type ENUM('section', 'student') NOT NULL DEFAULT 'section',
    student_id VARCHAR(20) DEFAULT NULL,
    grade_level VARCHAR(20) NOT NULL,
    strand ENUM('N/A', 'ABM', 'HUMSS') NOT NULL DEFAULT 'N/A',
    semester ENUM('N/A', '1st Sem', '2nd Sem') NOT NULL DEFAULT 'N/A',
    section VARCHAR(50) NOT NULL,
    day_of_week VARCHAR(30) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(60) NOT NULL,
    PRIMARY KEY (schedule_id),
    KEY idx_schedules_faculty (faculty_id),
    KEY idx_schedules_subject (subject_id),
    KEY idx_schedules_student (student_id),
    CONSTRAINT fk_sched_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sched_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sched_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE grades (
    id INT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(20) NOT NULL,
    subject_id VARCHAR(20) NOT NULL,
    school_year VARCHAR(20) NOT NULL DEFAULT '2026-2027',
    q1 DECIMAL(5,2) DEFAULT NULL,
    q2 DECIMAL(5,2) DEFAULT NULL,
    q3 DECIMAL(5,2) DEFAULT NULL,
    q4 DECIMAL(5,2) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY unique_student_subject_sy (student_id, subject_id, school_year),
    KEY idx_grades_subject (subject_id),
    CONSTRAINT fk_grades_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_grades_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE announcements (
    announcement_id VARCHAR(20) NOT NULL,
    title VARCHAR(150) NOT NULL,
    target VARCHAR(80) NOT NULL DEFAULT 'All Classes',
    author_name VARCHAR(100) NOT NULL,
    posted_date DATE NOT NULL,
    content TEXT NOT NULL,
    PRIMARY KEY (announcement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE attendance (
    id INT NOT NULL AUTO_INCREMENT,
    schedule_id VARCHAR(20) NOT NULL,
    student_id VARCHAR(20) NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Late', 'Absent', 'Excused') NOT NULL DEFAULT 'Present',
    PRIMARY KEY (id),
    UNIQUE KEY unique_date_schedule_student (attendance_date, schedule_id, student_id),
    KEY idx_attendance_student (student_id),
    CONSTRAINT fk_att_schedule
        FOREIGN KEY (schedule_id) REFERENCES class_schedules(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_att_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Existing accounts are kept for migration. Replace demo passwords before
-- making this database publicly accessible.
INSERT INTO users (id, username, password_hash, role, created_at, updated_at) VALUES
(1, 'admin', 'admin123', 'admin', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(2, 'faculty', 'faculty123', 'faculty', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(3, 'catherine', 'cath123', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(4, 'achilles', 'ach123', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(5, '2026-003', '2026-003', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(6, '2026-004', '2026-004', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(7, '2026-005', '2026-005', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(8, '2026-006', '2026-006', 'student', '2026-10-13 16:40:36', '2026-10-13 16:40:36'),
(13, '2026-045', '$2a$10$pEWkeJkopmphIx82Uqb4ve.j.512VhM0.AWysezrcm6oVcj5Ut1qK', 'student', '2026-10-26 14:58:32', '2026-10-26 14:58:32'),
(14, '2026-020', '$2a$10$ETEkLDcrvqiTCuoJR3pIR.qTLtP90XwpyaXUyJpEEPRdppWJQIMMm', 'student', '2026-10-26 15:12:16', '2026-10-26 15:12:16');

INSERT INTO students (student_id, user_id, full_name, grade_level, section, academic_status, contact_number, guardian_name) VALUES
('2026-001', 3, 'CATHERINE A. ROSARIO', 'Grade 12', 'STEM-A', 'Regular', 'N/A', 'N/A'),
('2026-002', 4, 'ACHILLES NERO C. AGUILA', 'Grade 11', 'STEM-A', 'Regular', 'N/A', 'N/A'),
('2026-003', 5, 'PRINCE CARL B. BARTOLOME', 'Grade 12', 'STEM-A', 'Regular', 'N/A', 'N/A'),
('2026-004', 6, 'BLUE BARRON B. BAMBILLA', 'Grade 11', 'HUMSS-A', 'Regular', 'N/A', 'N/A'),
('2026-005', 7, 'JAYSON J. ESQUEJO', 'Grade 12', 'STEM-A', 'Regular', 'N/A', 'N/A'),
('2026-006', 8, 'CARL ANTHONY V. DE VERA', 'Grade 12', 'STEM-A', 'Regular', 'N/A', 'N/A'),
('2026-020', 14, 'Prince Carl B. Bartolome', 'Grade 12', 'ABM-A', 'Regular', '09472585383', 'Stephen Curry'),
('2026-045', 13, 'Pwins', 'Grade 1', 'Section C', 'Regular', '09101234567', 'wwww');

-- Subject IDs are stored as strings in the current schema, preserving the
-- numeric IDs used by the legacy grades table.
INSERT INTO subjects (subject_id, subject_name) VALUES
('1', 'Mathematics'),
('2', 'English'),
('3', 'Science'),
('4', 'Filipino'),
('5', 'History'),
('6', 'PE'),
('7', 'ICT'),
('8', 'Research');

INSERT INTO enrollments (id, student_id, school_year, grade_level, strand, semester, section, enrollment_date, enrollment_status) VALUES
(1, '2026-001', '2026-2027', 'Grade 12', 'STEM', 'N/A', 'STEM-A', '2026-06-14', 'Enrolled'),
(2, '2026-002', '2026-2027', 'Grade 11', 'STEM', 'N/A', 'STEM-A', '2026-06-14', 'Enrolled'),
(3, '2026-003', '2026-2027', 'Grade 12', 'STEM', 'N/A', 'STEM-A', '2026-06-14', 'Enrolled'),
(4, '2026-004', '2026-2027', 'Grade 11', 'HUMSS', 'N/A', 'HUMSS-A', '2026-06-14', 'Enrolled'),
(5, '2026-005', '2026-2027', 'Grade 12', 'STEM', 'N/A', 'STEM-A', '2026-06-14', 'Enrolled'),
(6, '2026-006', '2026-2027', 'Grade 12', 'STEM', 'N/A', 'STEM-A', '2026-06-14', 'Enrolled'),
(7, '2026-045', '2026-2027', 'Grade 1', 'N/A', 'N/A', 'Section C', '2026-10-25', 'Enrolled'),
(8, '2026-020', '2026-2027', 'Grade 12', 'ABM', 'N/A', 'ABM-A', '2026-10-25', 'Enrolled');

INSERT INTO grades (id, student_id, subject_id, school_year, q1, q2, q3, q4) VALUES
(1, '2026-001', '1', '2026-2027', 88.00, 90.00, 89.00, 91.00),
(2, '2026-001', '2', '2026-2027', 91.00, 90.00, 92.00, 93.00),
(3, '2026-001', '3', '2026-2027', 90.00, 91.00, 89.00, 92.00),
(4, '2026-001', '4', '2026-2027', 92.00, 91.00, 90.00, 93.00),
(5, '2026-001', '6', '2026-2027', 95.00, 94.00, 96.00, 95.00),
(6, '2026-001', '7', '2026-2027', 89.00, 90.00, 91.00, 90.00),
(7, '2026-001', '8', '2026-2027', 90.00, 92.00, 91.00, 93.00),
(8, '2026-001', '5', '2026-2027', 78.00, 80.00, 79.00, 81.00),
(9, '2026-002', '1', '2026-2027', 85.00, 87.00, 88.00, 86.00),
(10, '2026-002', '2', '2026-2027', 90.00, 91.00, 92.00, 91.00),
(11, '2026-002', '3', '2026-2027', 88.00, 89.00, 90.00, 91.00),
(12, '2026-002', '4', '2026-2027', 91.00, 90.00, 92.00, 93.00),
(13, '2026-002', '6', '2026-2027', 94.00, 95.00, 94.00, 96.00),
(14, '2026-002', '7', '2026-2027', 89.00, 88.00, 90.00, 91.00),
(15, '2026-002', '5', '2026-2027', 86.00, 87.00, 88.00, 89.00),
(16, '2026-045', '1', '2026-2027', NULL, NULL, NULL, NULL),
(17, '2026-045', '2', '2026-2027', NULL, NULL, NULL, NULL),
(18, '2026-045', '3', '2026-2027', NULL, NULL, NULL, NULL),
(19, '2026-045', '4', '2026-2027', NULL, NULL, NULL, NULL),
(20, '2026-045', '5', '2026-2027', NULL, NULL, NULL, NULL),
(21, '2026-045', '6', '2026-2027', NULL, NULL, NULL, NULL),
(22, '2026-045', '7', '2026-2027', NULL, NULL, NULL, NULL),
(23, '2026-045', '8', '2026-2027', NULL, NULL, NULL, NULL),
(24, '2026-020', '1', '2026-2027', NULL, NULL, NULL, NULL),
(25, '2026-020', '2', '2026-2027', NULL, NULL, NULL, NULL),
(26, '2026-020', '3', '2026-2027', NULL, NULL, NULL, NULL),
(27, '2026-020', '4', '2026-2027', NULL, NULL, NULL, NULL),
(28, '2026-020', '5', '2026-2027', NULL, NULL, NULL, NULL),
(29, '2026-020', '6', '2026-2027', NULL, NULL, NULL, NULL),
(30, '2026-020', '7', '2026-2027', NULL, NULL, NULL, NULL),
(31, '2026-020', '8', '2026-2027', NULL, NULL, NULL, NULL);
