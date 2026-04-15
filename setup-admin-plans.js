#!/usr/bin/env node

/**
 * Setup Script for Admin Account and Plans
 * This script creates:
 * 1. Admin account
 * 2. Free plan
 * 3. Paid plan
 */

require('dotenv').config();
const mysql = require("mysql2");
const bcrypt = require("bcrypt");
const randomstring = require("randomstring");

// Database connection
const con = mysql.createConnection({
  host: process.env.DBHOST || "localhost",
  port: process.env.DBPORT || 3306,
  user: process.env.DBUSER,
  password: process.env.DBPASS,
  database: process.env.DBNAME,
  charset: "utf8mb4",
});

function query(sql, arr) {
  return new Promise((resolve, reject) => {
    if (!sql) {
      return reject(new Error("No SQL query provided"));
    }
    const params = arr || [];
    con.query(sql, params, (err, result) => {
      if (err) {
        console.error("Query error:", err);
        return reject(err);
      }
      return resolve(result);
    });
  });
}

async function setupAdminAndPlans() {
  try {
    console.log("🔄 Starting setup...");

    // 1. Create Admin Account
    console.log("\n📝 Creating admin account...");
    const adminUid = randomstring.generate(20);
    const adminPassword = await bcrypt.hash("admin@123", 10);
    
    const adminData = {
      uid: adminUid,
      email: "admin@nexiichat.com",
      password: adminPassword,
      name: "Admin User",
      role: "super_admin",
      permissions: JSON.stringify({
        manage_users: true,
        manage_plans: true,
        manage_billing: true,
        view_analytics: true,
        manage_support: true,
      }),
      status: "active",
    };

    await query(
      `INSERT INTO admin (uid, email, password, name, role, permissions, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        adminData.uid,
        adminData.email,
        adminData.password,
        adminData.name,
        adminData.role,
        adminData.permissions,
        adminData.status,
      ]
    );

    console.log("✅ Admin account created successfully!");
    console.log(`   Email: ${adminData.email}`);
    console.log(`   Password: admin@123`);
    console.log(`   UID: ${adminData.uid}`);

    // 2. Create Free Plan
    console.log("\n📝 Creating Free Plan...");
    const freePlanData = {
      name: "Free Plan",
      slug: "free-plan",
      description: "Perfect for getting started with basic features",
      price: 0,
      currency: "USD",
      billing_cycle: "monthly",
      features: JSON.stringify({
        tags: true,
        notes: true,
        chatbot: false,
        api: false,
        wa_warmer: false,
        qr_accounts: 1,
      }),
      contact_limit: 100,
      message_limit: 1000,
      active: 1,
      trial_days: 7,
    };

    await query(
      `INSERT INTO plan (name, slug, description, price, currency, billing_cycle, features, contact_limit, message_limit, active, trial_days) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        freePlanData.name,
        freePlanData.slug,
        freePlanData.description,
        freePlanData.price,
        freePlanData.currency,
        freePlanData.billing_cycle,
        freePlanData.features,
        freePlanData.contact_limit,
        freePlanData.message_limit,
        freePlanData.active,
        freePlanData.trial_days,
      ]
    );

    console.log("✅ Free Plan created successfully!");
    console.log(`   Name: ${freePlanData.name}`);
    console.log(`   Price: $${freePlanData.price}/${freePlanData.billing_cycle}`);
    console.log(`   Contact Limit: ${freePlanData.contact_limit}`);
    console.log(`   Message Limit: ${freePlanData.message_limit}`);

    // 3. Create Paid Plan
    console.log("\n📝 Creating Paid Plan...");
    const paidPlanData = {
      name: "Paid Plan",
      slug: "paid-plan",
      description: "Advanced features for growing businesses and teams",
      price: 99,
      currency: "USD",
      billing_cycle: "monthly",
      features: JSON.stringify({
        tags: true,
        notes: true,
        chatbot: true,
        api: true,
        wa_warmer: true,
        qr_accounts: 5,
      }),
      contact_limit: 10000,
      message_limit: 100000,
      active: 1,
      trial_days: 7,
    };

    await query(
      `INSERT INTO plan (name, slug, description, price, currency, billing_cycle, features, contact_limit, message_limit, active, trial_days) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        paidPlanData.name,
        paidPlanData.slug,
        paidPlanData.description,
        paidPlanData.price,
        paidPlanData.currency,
        paidPlanData.billing_cycle,
        paidPlanData.features,
        paidPlanData.contact_limit,
        paidPlanData.message_limit,
        paidPlanData.active,
        paidPlanData.trial_days,
      ]
    );

    console.log("✅ Paid Plan created successfully!");
    console.log(`   Name: ${paidPlanData.name}`);
    console.log(`   Price: $${paidPlanData.price}/${paidPlanData.billing_cycle}`);
    console.log(`   Contact Limit: ${paidPlanData.contact_limit}`);
    console.log(`   Message Limit: ${paidPlanData.message_limit}`);

    // Summary
    console.log("\n" + "=".repeat(50));
    console.log("✨ Setup completed successfully!");
    console.log("=".repeat(50));
    console.log("\n📊 Summary:");
    console.log("✓ Admin account created");
    console.log("✓ Free Plan created");
    console.log("✓ Paid Plan created");
    console.log("\n🔐 Admin Login Credentials:");
    console.log(`   Email: admin@nexiichat.com`);
    console.log(`   Password: admin@123`);
    console.log("\n💡 Change the admin password after first login!");
    console.log("=".repeat(50) + "\n");

    con.end();
  } catch (err) {
    console.error("\n❌ Error during setup:", err.message);
    con.end();
    process.exit(1);
  }
}

// Run setup
setupAdminAndPlans();
