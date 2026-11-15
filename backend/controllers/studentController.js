const bcrypt = require('bcryptjs');
const pool = require('../config/db');

// @desc    Get all students
// @route   GET /api/students
exports.getAllStudents = async (req, res) => {
    try {
        const [students] = await pool.query('SELECT * FROM students');
        res.status(200).json(students);
    } catch (error) {
        console.error('Error fetching students:', error);
        res.status(500).json({ message: 'Server error while fetching students.' });
    }
};

// @desc    Get a single student by ID
// @route   GET /api/students/:id
exports.getStudentById = async (req, res) => {
    try {
        const studentId = req.params.id;
        const [student] = await pool.query('SELECT * FROM students WHERE student_id = ?', [studentId]);
        
        if (student.length === 0) {
            return res.status(404).json({ message: 'Student not found.' });
        }
        
        res.status(200).json(student[0]);
    } catch (error) {
        console.error('Error fetching student:', error);
        res.status(500).json({ message: 'Server error while fetching student.' });
    }
};

// @desc    Create or update a student profile
// @route   POST /api/students
exports.saveStudent = async (req, res) => {
    const { id, name, grade, section, status, contact, guardian, isEdit } = req.body;

    if (!id || !name || !grade) {
        return res.status(400).json({ message: 'Student ID, Full Name, and Grade Level are required.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        if (isEdit) {
            await connection.execute(
                `UPDATE students
                 SET full_name = ?, grade_level = ?, section = ?, academic_status = ?,
                     contact_number = ?, guardian_name = ?
                 WHERE student_id = ?`,
                [name, grade, section || 'Pending Enrollment', status || 'Enrolled', contact || 'N/A', guardian || 'N/A', id]
            );
        } else {
            const [dup] = await connection.execute('SELECT student_id FROM students WHERE student_id = ?', [id]);
            if (dup.length > 0) {
                await connection.rollback();
                return res.status(409).json({ message: 'Student ID already exists.' });
            }

            const passwordHash = await bcrypt.hash(id, 10);
            const [userRes] = await connection.execute(
                'INSERT INTO users (username, password_hash, role, account_status) VALUES (?, ?, ?, ?)',
                [id, passwordHash, 'student', 'Active']
            );

            await connection.execute(
                `INSERT INTO students (student_id, user_id, full_name, grade_level, section, academic_status, contact_number, guardian_name)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [id, userRes.insertId, name, grade, section || 'Pending Enrollment', status || 'Pending', contact || 'N/A', guardian || 'N/A']
            );
        }

        await connection.commit();
        return res.status(200).json({ message: isEdit ? 'Student updated.' : 'Student registered.' });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error saving student:', error);
        return res.status(500).json({ message: 'Could not save student to the database.' });
    } finally {
        if (connection) connection.release();
    }
};

// @desc    Delete a student, related records, and its unshared user account
// @route   DELETE /api/students/:id
exports.deleteStudent = async (req, res) => {
    let connection;

    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        const [students] = await connection.execute(
            'SELECT user_id FROM students WHERE student_id = ? FOR UPDATE',
            [req.params.id]
        );

        if (students.length === 0) {
            await connection.rollback();
            return res.status(404).json({ message: 'Student not found in the database.' });
        }

        await connection.execute(
            'DELETE FROM students WHERE student_id = ?',
            [req.params.id]
        );
        await connection.execute(
            `DELETE FROM users
             WHERE id = ?
               AND NOT EXISTS (SELECT 1 FROM students WHERE user_id = ?)`,
            [students[0].user_id, students[0].user_id]
        );

        await connection.commit();
        return res.status(200).json({ message: 'Student and related records deleted.' });
    } catch (error) {
        if (connection) {
            try {
                await connection.rollback();
            } catch (rollbackError) {
                console.error('Error rolling back student deletion:', rollbackError);
            }
        }
        console.error('Error deleting student:', error);
        return res.status(500).json({ message: 'Could not delete student from the database.' });
    } finally {
        if (connection) connection.release();
    }
};
