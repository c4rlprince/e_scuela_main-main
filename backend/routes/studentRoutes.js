const express = require('express');
const router = express.Router();
const { getAllStudents, getStudentById, saveStudent, deleteStudent } = require('../controllers/studentController');

router.get('/', getAllStudents);
router.get('/:id', getStudentById);
router.post('/', saveStudent);
router.delete('/:id', deleteStudent);

module.exports = router;
