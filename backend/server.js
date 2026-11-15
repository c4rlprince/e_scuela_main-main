require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bcrypt = require('bcryptjs');
const pool = require('./config/db');
const enrollmentRoutes = require('./routes/enrollmentRoutes');
const studentRoutes = require('./routes/studentRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Security and Utility Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

app.use('/api/enrollments', enrollmentRoutes);
app.use('/api/students', studentRoutes);

// POST /api/login - Verify faculty credentials against MySQL
app.post('/api/login', async (req, res) => {
    const username = typeof req.body.username === 'string' ? req.body.username.trim() : '';
    const password = typeof req.body.password === 'string' ? req.body.password : '';

    if (!username || !password) {
        return res.status(400).json({ message: 'Please enter your username and password.' });
    }

    try {
        const [users] = await pool.execute(`
            SELECT u.id AS userId, u.username, u.password_hash AS passwordHash,
                   u.account_status AS accountStatus, f.faculty_id AS id,
                   f.full_name AS name, f.department, f.email,
                   f.contact_number AS contact, f.office, f.status
            FROM users u
            JOIN faculty f ON f.user_id = u.id
            WHERE u.username = ? AND u.role = 'faculty'
            LIMIT 1
        `, [username]);

        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid username or password.' });
        }

        const user = users[0];
        const storedPassword = String(user.passwordHash);
        const isBcryptHash = /^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$/.test(storedPassword);
        const passwordMatches = isBcryptHash
            ? await bcrypt.compare(password, storedPassword)
            : password === storedPassword;

        if (!passwordMatches) {
            return res.status(401).json({ message: 'Invalid username or password.' });
        }

        const status = user.status || user.accountStatus;
        if (user.accountStatus !== 'Active' || status !== 'Active') {
            const inactiveStatus = user.accountStatus !== 'Active' ? user.accountStatus : status;
            return res.status(403).json({
                message: `This faculty account is currently ${inactiveStatus.toLowerCase()}. Please contact the administrator.`
            });
        }

        if (!isBcryptHash) {
            const passwordHash = await bcrypt.hash(password, 10);
            await pool.execute(
                'UPDATE users SET password_hash = ? WHERE id = ?',
                [passwordHash, user.userId]
            );
        }

        const [subjectRows] = await pool.execute(`
            SELECT s.subject_name AS name
            FROM faculty_subjects fs
            JOIN subjects s ON s.subject_id = fs.subject_id
            WHERE fs.faculty_id = ?
        `, [user.id]);

        delete user.userId;
        delete user.passwordHash;
        delete user.accountStatus;
        res.status(200).json({
            faculty: {
                ...user,
                subjects: subjectRows.map(subject => subject.name)
            }
        });
    } catch (error) {
        console.error('Faculty login error:', error);
        res.status(500).json({ message: 'Unable to verify your account right now.' });
    }
});

// GET /api/bootstrap - Fetch full 10-table normalized database formatted for e-scuela frontend
app.get('/api/bootstrap', async (req, res) => {
    try {
        const [
            [studentsRows],
            [facultyRows],
            [facSubRows],
            [subjectRows],
            [subAssignRows],
            [enrollmentRows],
            [scheduleRows],
            [gradeRows],
            [announcementRows],
            [attendanceRows]
        ] = await Promise.all([
            pool.query(`
                SELECT s.student_id AS id, s.full_name AS name, u.username,
                       s.grade_level AS grade, s.section, s.academic_status AS status,
                       s.contact_number AS contact, s.guardian_name AS guardian
                FROM students s
                JOIN users u ON s.user_id = u.id
                ORDER BY s.student_id ASC
            `),
            pool.query(`
                SELECT f.faculty_id AS id, u.username, f.full_name AS name,
                       f.department, f.email, f.contact_number AS contact,
                       f.office, f.status
                FROM faculty f
                JOIN users u ON f.user_id = u.id
                ORDER BY f.faculty_id ASC
            `),
            pool.query(`
                SELECT fs.faculty_id, sub.subject_name
                FROM faculty_subjects fs
                JOIN subjects sub ON fs.subject_id = sub.subject_id
            `),
            pool.query(`SELECT subject_id AS id, subject_name AS name FROM subjects ORDER BY subject_id ASC`),
            pool.query(`SELECT subject_id, grade_level, strand, semester FROM subject_assignments`),
            pool.query(`
                SELECT student_id AS student, school_year AS schoolYear, grade_level AS grade,
                       strand, semester, section, DATE_FORMAT(enrollment_date, '%Y-%m-%d') AS date,
                       enrollment_status AS status, enrollment_status AS enrollmentStatus
                FROM enrollments
                ORDER BY id ASC
            `),
            pool.query(`
                SELECT cs.schedule_id AS id, cs.faculty_id AS facultyId, f.full_name AS facultyName,
                       cs.target_type AS targetType, COALESCE(cs.student_id, '') AS studentId,
                       cs.grade_level AS grade, cs.strand, cs.semester, cs.section,
                       sub.subject_name AS subject, cs.day_of_week AS day,
                       CONCAT(TIME_FORMAT(cs.start_time, '%l:%i %p'), ' - ', TIME_FORMAT(cs.end_time, '%l:%i %p')) AS time,
                       cs.room
                FROM class_schedules cs
                JOIN faculty f ON cs.faculty_id = f.faculty_id
                JOIN subjects sub ON cs.subject_id = sub.subject_id
                ORDER BY cs.schedule_id ASC
            `),
            pool.query(`
                SELECT g.student_id, sub.subject_name, g.q1, g.q2, g.q3, g.q4
                FROM grades g
                JOIN subjects sub ON g.subject_id = sub.subject_id
                ORDER BY g.id ASC
            `),
            pool.query(`
                SELECT announcement_id AS id, title, target, author_name AS author,
                       DATE_FORMAT(posted_date, '%Y-%m-%d') AS date, content
                FROM announcements
                ORDER BY posted_date DESC
            `),
            pool.query(`
                SELECT schedule_id, student_id, DATE_FORMAT(attendance_date, '%Y-%m-%d') AS att_date, status
                FROM attendance
            `)
        ]);

        const subjects = subjectRows.map(sub => {
            const assigns = subAssignRows.filter(a => a.subject_id === sub.id);
            const gradeLevels = [...new Set(assigns.map(a => a.grade_level))];
            const strands = [...new Set(assigns.map(a => a.strand).filter(st => st && st !== 'N/A'))];
            const sem = assigns.find(a => a.semester && a.semester !== 'N/A')?.semester || 'N/A';
            return { id: sub.id, name: sub.name, gradeLevels, strands, semester: sem };
        });

        const facultyList = facultyRows.map(fac => ({
            ...fac,
            subjects: facSubRows
                .filter(fs => fs.faculty_id === fac.id)
                .map(fs => fs.subject_name)
        }));

        const grades = {};
        for (const row of gradeRows) {
            if (!grades[row.student_id]) grades[row.student_id] = [];
            grades[row.student_id].push([
                row.subject_name,
                row.q1 !== null ? Number(row.q1) : '',
                row.q2 !== null ? Number(row.q2) : '',
                row.q3 !== null ? Number(row.q3) : '',
                row.q4 !== null ? Number(row.q4) : ''
            ]);
        }

        const attendance = {};
        for (const row of attendanceRows) {
            const key = `${row.att_date}_${row.schedule_id}`;
            if (!attendance[key]) attendance[key] = {};
            attendance[key][row.student_id] = row.status;
        }

        res.status(200).json({
            students: studentsRows,
            facultyList,
            subjects,
            enrollments: enrollmentRows,
            schedules: scheduleRows,
            grades,
            announcements: announcementRows,
            attendance
        });
    } catch (error) {
        console.error('Bootstrap fetch error:', error);
        res.status(500).json({ message: 'Failed to load database records.' });
    }
});

// POST /api/faculty - Add or Update Faculty Member in MySQL
app.post('/api/faculty', async (req, res) => {
    const { id, name, username, password, department, email, contact, office, status, subjects, isEdit } = req.body;

    if (!name || !username || !Array.isArray(subjects) || subjects.length === 0) {
        return res.status(400).json({ message: 'Missing required faculty fields.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        let facultyId = id;

        if (isEdit) {
            const [facRows] = await connection.execute(
                'SELECT user_id FROM faculty WHERE faculty_id = ? FOR UPDATE',
                [facultyId]
            );
            if (facRows.length === 0) {
                await connection.rollback();
                return res.status(404).json({ message: 'Faculty member not found.' });
            }

            const userId = facRows[0].user_id;
            if (password) {
                const passwordHash = password.startsWith('$2') ? password : await bcrypt.hash(password, 10);
                await connection.execute(
                    'UPDATE users SET username = ?, password_hash = ?, account_status = ? WHERE id = ?',
                    [username, passwordHash, status || 'Active', userId]
                );
            } else {
                await connection.execute(
                    'UPDATE users SET username = ?, account_status = ? WHERE id = ?',
                    [username, status || 'Active', userId]
                );
            }

            await connection.execute(
                `UPDATE faculty 
                 SET full_name = ?, department = ?, email = ?, contact_number = ?, office = ?, status = ?
                 WHERE faculty_id = ?`,
                [name, department || 'Elementary', email, contact || 'N/A', office || 'Faculty Room', status || 'Active', facultyId]
            );

            await connection.execute('DELETE FROM faculty_subjects WHERE faculty_id = ?', [facultyId]);
        } else {
            if (!password) {
                await connection.rollback();
                return res.status(400).json({ message: 'Password is required for new faculty.' });
            }

            const [dupUser] = await connection.execute('SELECT id FROM users WHERE username = ?', [username]);
            if (dupUser.length > 0) {
                await connection.rollback();
                return res.status(409).json({ message: 'Login username is already taken.' });
            }

            // Ensure unique faculty_id in MySQL
            const [dupFac] = await connection.execute('SELECT faculty_id FROM faculty WHERE faculty_id = ?', [facultyId || '']);
            if (!facultyId || dupFac.length > 0) {
                const [maxFac] = await connection.query(
                    `SELECT COALESCE(MAX(CAST(SUBSTRING(faculty_id, 10) AS UNSIGNED)), 0) + 1 AS nextNum
                     FROM faculty WHERE faculty_id LIKE 'FAC-2026-%'`
                );
                facultyId = `FAC-2026-${String(maxFac[0].nextNum).padStart(2, '0')}`;
            }

            const passwordHash = await bcrypt.hash(password, 10);
            const [userRes] = await connection.execute(
                'INSERT INTO users (username, password_hash, role, account_status) VALUES (?, ?, ?, ?)',
                [username, passwordHash, 'faculty', 'Active']
            );

            await connection.execute(
                `INSERT INTO faculty (faculty_id, user_id, full_name, department, email, contact_number, office, status)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [facultyId, userRes.insertId, name, department || 'Elementary', email, contact || 'N/A', office || 'Faculty Room', 'Active']
            );
        }

        for (const subName of subjects) {
            const [subRows] = await connection.execute(
                'SELECT subject_id FROM subjects WHERE subject_name = ? LIMIT 1',
                [subName]
            );
            if (subRows.length > 0) {
                await connection.execute(
                    'INSERT IGNORE INTO faculty_subjects (faculty_id, subject_id) VALUES (?, ?)',
                    [facultyId, subRows[0].subject_id]
                );
            }
        }

        await connection.commit();
        return res.status(200).json({ message: isEdit ? 'Faculty updated in database.' : 'Faculty added to database.', facultyId });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error saving faculty:', error);
        return res.status(500).json({ message: error.sqlMessage || 'Database error while saving faculty member.' });
    } finally {
        if (connection) connection.release();
    }
});

// POST /api/subjects - Add or Update Subject & Curriculum Assignments
app.post('/api/subjects', async (req, res) => {
    const { id, name, gradeLevels, strands, semester, isEdit } = req.body;
    if (!name || !Array.isArray(gradeLevels) || gradeLevels.length === 0) {
        return res.status(400).json({ message: 'Subject name and grade levels are required.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        let subjectId = id || `SUB-${Date.now().toString().slice(-4)}`;
        if (isEdit && id) {
            await connection.execute('UPDATE subjects SET subject_name = ? WHERE subject_id = ?', [name, id]);
            await connection.execute('DELETE FROM subject_assignments WHERE subject_id = ?', [id]);
        } else {
            const [existing] = await connection.execute('SELECT subject_id FROM subjects WHERE subject_name = ?', [name]);
            if (existing.length > 0) {
                subjectId = existing[0].subject_id;
            } else {
                await connection.execute('INSERT INTO subjects (subject_id, subject_name) VALUES (?, ?)', [subjectId, name]);
            }
        }

        for (const g of gradeLevels) {
            const isSHS = g === 'Grade 11' || g === 'Grade 12';
            if (isSHS) {
                const activeStrands = Array.isArray(strands) && strands.length ? strands : ['ABM', 'HUMSS'];
                const sem = semester && semester !== 'N/A' ? semester : '1st Sem';
                for (const st of activeStrands) {
                    await connection.execute(
                        'INSERT IGNORE INTO subject_assignments (subject_id, grade_level, strand, semester) VALUES (?, ?, ?, ?)',
                        [subjectId, g, st, sem]
                    );
                }
            } else {
                await connection.execute(
                    'INSERT IGNORE INTO subject_assignments (subject_id, grade_level, strand, semester) VALUES (?, ?, ?, ?)',
                    [subjectId, g, 'N/A', 'N/A']
                );
            }
        }

        await connection.commit();
        return res.status(200).json({ message: 'Subject saved to database.' });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error saving subject:', error);
        return res.status(500).json({ message: 'Database error while saving subject.' });
    } finally {
        if (connection) connection.release();
    }
});

// DELETE /api/subjects/:id
app.delete('/api/subjects/:id', async (req, res) => {
    try {
        await pool.execute('DELETE FROM subjects WHERE subject_id = ?', [req.params.id]);
        return res.status(200).json({ message: 'Subject removed.' });
    } catch (error) {
        console.error('Error deleting subject:', error);
        return res.status(500).json({ message: 'Could not delete subject.' });
    }
});

// POST /api/schedules - Add Class Schedule to MySQL
app.post('/api/schedules', async (req, res) => {
    const { facultyId, subject, targetType, studentId, grade, strand, semester, section, day, startTime, endTime, room } = req.body;

    if (!facultyId || !subject || !grade || !section || !day || !startTime || !endTime) {
        return res.status(400).json({ message: 'Please fill out all required schedule fields.' });
    }

    try {
        const [facRows] = await pool.execute(
            'SELECT faculty_id FROM faculty WHERE faculty_id = ? LIMIT 1',
            [facultyId]
        );
        if (facRows.length === 0) {
            return res.status(404).json({ message: `Faculty ${facultyId} not found in MySQL.` });
        }

        const [subRows] = await pool.execute(
            'SELECT subject_id FROM subjects WHERE subject_name = ? LIMIT 1',
            [subject]
        );
        if (subRows.length === 0) {
            return res.status(404).json({ message: `Subject "${subject}" not found in MySQL.` });
        }

        if (targetType === 'student' && studentId) {
            const [stuRows] = await pool.execute(
                'SELECT student_id FROM students WHERE student_id = ? LIMIT 1',
                [studentId]
            );
            if (stuRows.length === 0) {
                return res.status(404).json({ message: `Student ${studentId} not found in MySQL.` });
            }
        }

        const [maxRows] = await pool.query(
            `SELECT COALESCE(MAX(CAST(SUBSTRING(schedule_id, 5) AS UNSIGNED)), 0) + 1 AS nextNum
             FROM class_schedules
             WHERE schedule_id LIKE 'SCH-%'`
        );
        const scheduleId = `SCH-${String(maxRows[0].nextNum).padStart(3, '0')}`;

        const formattedStart = startTime.length === 5 ? `${startTime}:00` : startTime;
        const formattedEnd = endTime.length === 5 ? `${endTime}:00` : endTime;

        await pool.execute(
            `INSERT INTO class_schedules
                (schedule_id, faculty_id, subject_id, target_type, student_id, grade_level, strand, semester, section, day_of_week, start_time, end_time, room)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                scheduleId,
                facultyId,
                subRows[0].subject_id,
                targetType || 'section',
                targetType === 'student' && studentId ? studentId : null,
                grade,
                strand || 'N/A',
                semester || 'N/A',
                section,
                day,
                formattedStart,
                formattedEnd,
                room || 'Room 101'
            ]
        );

        return res.status(200).json({ message: 'Schedule added to database.', scheduleId });
    } catch (error) {
        console.error('Error saving schedule:', error);
        return res.status(500).json({ message: error.sqlMessage || 'Could not save schedule to MySQL.' });
    }
});

// DELETE /api/schedules/:id
app.delete('/api/schedules/:id', async (req, res) => {
    try {
        const [result] = await pool.execute('DELETE FROM class_schedules WHERE schedule_id = ?', [req.params.id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Schedule not found in MySQL.' });
        }
        return res.status(200).json({ message: 'Schedule removed.' });
    } catch (error) {
        console.error('Error deleting schedule:', error);
        return res.status(500).json({ message: 'Could not delete schedule.' });
    }
});

// POST /api/grades - Save Student Quarter Grades
app.post('/api/grades', async (req, res) => {
    const { entries } = req.body; // [{ studentId, subjectName, q1, q2, q3, q4 }]
    if (!Array.isArray(entries)) {
        return res.status(400).json({ message: 'Invalid grade entries.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        for (const item of entries) {
            const [subRows] = await connection.execute(
                'SELECT subject_id FROM subjects WHERE subject_name = ? LIMIT 1',
                [item.subjectName]
            );
            if (subRows.length === 0) continue;

            const toVal = v => (v === '' || v === null || v === undefined) ? null : Number(v);
            await connection.execute(
                `INSERT INTO grades (student_id, subject_id, school_year, q1, q2, q3, q4)
                 VALUES (?, ?, '2026-2027', ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE q1 = VALUES(q1), q2 = VALUES(q2), q3 = VALUES(q3), q4 = VALUES(q4)`,
                [item.studentId, subRows[0].subject_id, toVal(item.q1), toVal(item.q2), toVal(item.q3), toVal(item.q4)]
            );
        }

        await connection.commit();
        return res.status(200).json({ message: 'Grades saved to database.' });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error saving grades:', error);
        return res.status(500).json({ message: 'Could not save grades.' });
    } finally {
        if (connection) connection.release();
    }
});

// POST /api/announcements - Create or Update Announcement
app.post('/api/announcements', async (req, res) => {
    const { id, title, target, author, date, content, isEdit } = req.body;
    if (!title || !content) {
        return res.status(400).json({ message: 'Title and content are required.' });
    }

    try {
        if (isEdit && id) {
            await pool.execute(
                'UPDATE announcements SET title = ?, target = ?, content = ? WHERE announcement_id = ?',
                [title, target || 'All Classes', content, id]
            );
        } else {
            const annId = id || `ANN-${Date.now().toString().slice(-4)}`;
            await pool.execute(
                'INSERT INTO announcements (announcement_id, title, target, author_name, posted_date, content) VALUES (?, ?, ?, ?, ?, ?)',
                [annId, title, target || 'All Classes', author || 'Administrator', date || new Date().toISOString().slice(0, 10), content]
            );
        }
        return res.status(200).json({ message: 'Announcement saved.' });
    } catch (error) {
        console.error('Error saving announcement:', error);
        return res.status(500).json({ message: 'Could not save announcement.' });
    }
});

// DELETE /api/announcements/:id
app.delete('/api/announcements/:id', async (req, res) => {
    try {
        await pool.execute('DELETE FROM announcements WHERE announcement_id = ?', [req.params.id]);
        return res.status(200).json({ message: 'Announcement deleted.' });
    } catch (error) {
        console.error('Error deleting announcement:', error);
        return res.status(500).json({ message: 'Could not delete announcement.' });
    }
});

// Root test & database connectivity check route
app.get('/api/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.status(200).json({
            status: 'success',
            database: 'connected',
            message: 'E-SCUELA Backend and cloud database are running.'
        });
    } catch (error) {
        res.status(500).json({
            status: 'error',
            database: 'disconnected',
            message: error.message
        });
    }
});

// DELETE /api/faculty/:id - Delete faculty member
app.delete('/api/faculty/:id', async (req, res) => {
    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        const [facRows] = await connection.execute('SELECT user_id FROM faculty WHERE faculty_id = ? FOR UPDATE', [req.params.id]);
        if (facRows.length === 0) {
            await connection.rollback();
            return res.status(404).json({ message: 'Faculty member not found.' });
        }

        await connection.execute('DELETE FROM faculty WHERE faculty_id = ?', [req.params.id]);
        await connection.execute('DELETE FROM users WHERE id = ?', [facRows[0].user_id]);

        await connection.commit();
        return res.status(200).json({ message: 'Faculty member deleted.' });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error deleting faculty:', error);
        return res.status(500).json({ message: 'Could not delete faculty.' });
    } finally {
        if (connection) connection.release();
    }
});

// POST /api/attendance - Save class attendance
app.post('/api/attendance', async (req, res) => {
    const { date, classId, records } = req.body; // records: { studentId: 'Present'/'Late'/'Absent'/'Excused' }
    if (!date || !classId || !records || typeof records !== 'object') {
        return res.status(400).json({ message: 'Invalid attendance details.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        for (const [studentId, status] of Object.entries(records)) {
            await connection.execute(
                `INSERT INTO attendance (schedule_id, student_id, attendance_date, status)
                 VALUES (?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE status = VALUES(status)`,
                [classId, studentId, date, status]
            );
        }

        await connection.commit();
        return res.status(200).json({ message: 'Attendance saved.' });
    } catch (error) {
        if (connection) await connection.rollback();
        console.error('Error saving attendance:', error);
        return res.status(500).json({ message: 'Could not save attendance.' });
    }
});

// Centralized 404 Error Handling for unknown routes
app.use((req, res) => {
    res.status(404).json({ message: 'API Endpoint not found.' });
});

if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`🚀 Server initialized on port ${PORT}`);
    });
}

module.exports = app;
