const mysql = require('mysql2/promise');
require('dotenv').config();

const isLocalHost = !process.env.DB_HOST || ['localhost', '127.0.0.1'].includes(process.env.DB_HOST);
const useSSL = process.env.DB_SSL === 'true' || (!isLocalHost && process.env.DB_SSL !== 'false');

// Create a connection pool using environment variables (supports both local XAMPP and TiDB Cloud)
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'e_scuela_db',
    ssl: useSSL ? { minVersion: 'TLSv1.2', rejectUnauthorized: true } : undefined,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Verify database connection on startup without crashing serverless runtimes
pool.getConnection()
    .then(connection => {
        console.log(`✅ MySQL Database successfully connected (${process.env.DB_HOST || 'localhost'}).`);
        connection.release();
    })
    .catch(error => {
        console.error('❌ MySQL Connection Error:', error.message);
    });

module.exports = pool;
