-- ============================================================================
-- E-SCUELA Normalized Relational Database Schema (3NF)
-- Escuela de Nuestra Senora de la Salette
-- ============================================================================

DROP DATABASE IF EXISTS e_scuela_db;
CREATE DATABASE e_scuela_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE e_scuela_db;

-- 1. USERS TABLE (Authentication & Role-Based Access)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'faculty', 'student') NOT NULL DEFAULT 'student',
    account_status ENUM('Active', 'On Leave', 'Inactive', 'Resigned') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. STUDENTS TABLE
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    grade_level VARCHAR(20) NOT NULL DEFAULT 'Pending',
    section VARCHAR(50) NOT NULL DEFAULT 'Pending Enrollment',
    academic_status ENUM('Regular', 'Irregular', 'Transferee', 'Enrolled', 'Pending', 'Dropped') NOT NULL DEFAULT 'Enrolled',
    contact_number VARCHAR(20) DEFAULT 'N/A',
    guardian_name VARCHAR(100) DEFAULT 'N/A',
    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. FACULTY TABLE
CREATE TABLE faculty (
    faculty_id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    department ENUM('Elementary', 'Junior High School', 'Senior High School') NOT NULL,
    email VARCHAR(120) NOT NULL,
    contact_number VARCHAR(20) DEFAULT 'N/A',
    office VARCHAR(100) DEFAULT 'Faculty Room',
    status ENUM('Active', 'On Leave', 'Inactive', 'Resigned') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_faculty_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. SUBJECTS TABLE
CREATE TABLE subjects (
    subject_id VARCHAR(20) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 5. SUBJECT ASSIGNMENTS (Normalizes Grade Levels, Strands & Semesters)
CREATE TABLE subject_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id VARCHAR(20) NOT NULL,
    grade_level VARCHAR(20) NOT NULL,
    strand ENUM('N/A', 'ABM', 'HUMSS') NOT NULL DEFAULT 'N/A',
    semester ENUM('N/A', '1st Sem', '2nd Sem') NOT NULL DEFAULT 'N/A',
    CONSTRAINT fk_sub_assign_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_subject_curriculum (subject_id, grade_level, strand, semester)
) ENGINE=InnoDB;

-- 6. FACULTY SUBJECTS (Resolves Many-to-Many Faculty <-> Subject Load)
CREATE TABLE faculty_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(20) NOT NULL,
    subject_id VARCHAR(20) NOT NULL,
    CONSTRAINT fk_fac_sub_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fac_sub_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_faculty_subject (faculty_id, subject_id)
) ENGINE=InnoDB;

-- 7. ENROLLMENTS TABLE
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    school_year VARCHAR(20) NOT NULL,
    grade_level VARCHAR(20) NOT NULL,
    strand ENUM('N/A', 'ABM', 'HUMSS') NOT NULL DEFAULT 'N/A',
    semester ENUM('N/A', '1st Sem', '2nd Sem') NOT NULL DEFAULT 'N/A',
    section VARCHAR(50) NOT NULL,
    enrollment_date DATE NOT NULL,
    enrollment_status ENUM('Enrolled', 'Pending', 'Dropped') NOT NULL DEFAULT 'Enrolled',
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_student_sy_sem (student_id, school_year, semester)
) ENGINE=InnoDB;

-- 8. CLASS SCHEDULES TABLE (3NF Atomic Timetable)
CREATE TABLE class_schedules (
    schedule_id VARCHAR(20) PRIMARY KEY,
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
    CONSTRAINT fk_sched_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sched_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sched_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (end_time > start_time)
) ENGINE=InnoDB;

-- 9. GRADES TABLE
CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    subject_id VARCHAR(20) NOT NULL,
    school_year VARCHAR(20) NOT NULL DEFAULT '2026-2027',
    q1 DECIMAL(5,2) DEFAULT NULL,
    q2 DECIMAL(5,2) DEFAULT NULL,
    q3 DECIMAL(5,2) DEFAULT NULL,
    q4 DECIMAL(5,2) DEFAULT NULL,
    CONSTRAINT fk_grades_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_grades_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_student_subject_sy (student_id, subject_id, school_year)
) ENGINE=InnoDB;

-- 10. ANNOUNCEMENTS TABLE
CREATE TABLE announcements (
    announcement_id VARCHAR(20) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    target VARCHAR(80) NOT NULL DEFAULT 'All Classes',
    author_name VARCHAR(100) NOT NULL,
    posted_date DATE NOT NULL,
    content TEXT NOT NULL
) ENGINE=InnoDB;

-- 11. ATTENDANCE TABLE (Faculty Portal Attendance Logging)
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id VARCHAR(20) NOT NULL,
    student_id VARCHAR(20) NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Late', 'Absent', 'Excused') NOT NULL DEFAULT 'Present',
    CONSTRAINT fk_att_schedule
        FOREIGN KEY (schedule_id) REFERENCES class_schedules(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_att_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_date_schedule_student (attendance_date, schedule_id, student_id)
) ENGINE=InnoDB;
