const mysql = require('mysql2/promise');
require('dotenv').config();

const isCloudHost = Boolean(
    process.env.DB_HOST &&
    !['localhost', '127.0.0.1'].includes(process.env.DB_HOST)
);

// Create a connection pool using environment variables (supports TiDB Cloud SSL)
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || (isCloudHost ? 4000 : 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'e_scuela_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    ssl: isCloudHost
        ? { minVersion: 'TLSv1.2', rejectUnauthorized: true }
        : undefined
});

// Log initial connection status without crashing serverless cold starts
pool.getConnection()
    .then(connection => {
        console.log('✅ MySQL / TiDB Database successfully connected.');
        connection.release();
    })
    .catch(error => {
        console.error('❌ MySQL Connection Error:', error.message);
    });

module.exports = pool;
