#!/usr/bin/env node

require('dotenv').config();
const mysql = require("mysql2");

const con = mysql.createConnection({
  host: process.env.DBHOST || "localhost",
  port: process.env.DBPORT || 3306,
  user: process.env.DBUSER,
  password: process.env.DBPASS,
  database: process.env.DBNAME,
});

// Check Admin
con.query('SELECT id, email, name, role, status FROM admin WHERE email = ?', ['admin@nexiichat.com'], (err, result) => {
  if (err) console.error(err);
  else {
    console.log('\n✅ Admin Account:');
    console.table(result);
  }

  // Check Plans
  con.query('SELECT id, name, slug, price, contact_limit, message_limit, active FROM plan ORDER BY id', (err2, result2) => {
    if (err2) console.error(err2);
    else {
      console.log('\n✅ Plans:');
      console.table(result2);
    }
    con.end();
  });
});
