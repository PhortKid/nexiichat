#!/usr/bin/env node

/**
 * Create Plans Script
 * Creates Free and Paid plans
 */

require('dotenv').config();
const mysql = require("mysql2");

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

async function createPlans() {
  try {
    console.log("🔄 Creating plans...\n");

    // 1. Create Free Plan
    console.log("📝 Creating Free Plan...");
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
    console.log(`   Trial Days: ${freePlanData.trial_days}\n`);

    // 2. Create Paid Plan
    console.log("📝 Creating Paid Plan...");
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
    console.log(`   Trial Days: ${paidPlanData.trial_days}\n`);

    // Summary
    console.log("=".repeat(60));
    console.log("✨ Plans setup completed successfully!");
    console.log("=".repeat(60));
    console.log("\n📊 Summary:");
    console.log("✓ Free Plan created");
    console.log("✓ Paid Plan created");
    console.log("\n💡 Plans are now available for users to subscribe!");
    console.log("=".repeat(60) + "\n");

    con.end();
  } catch (err) {
    console.error("\n❌ Error during setup:", err.message);
    con.end();
    process.exit(1);
  }
}

// Run setup
createPlans();
