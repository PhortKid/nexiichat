const jwt = require("jsonwebtoken");
const { query } = require("../database/dbpromise");
const { getNumberOfDaysFromTimestamp } = require("../functions/function");

const checkPlan = async (req, res, next) => {
  try {
    if (req.owner) {
      req.decode.uid = req.owner.uid;
    }

    const getUser = await query(`SELECT * FROM user WHERE uid = ?`, [
      req.decode.uid,
    ]);

    if (!getUser[0]?.plan_id) {
      return res.json({
        success: false,
        msg: "Please subscribe a plan to proceed this.",
      });
    }

    // Get plan details
    const getPlan = await query(`SELECT * FROM plan WHERE id = ?`, [
      getUser[0].plan_id,
    ]);

    if (getPlan.length < 1) {
      return res.json({
        success: false,
        msg: "Plan not found. Please contact support.",
      });
    }

    // Check for active subscription
    const activeOrder = await query(`
      SELECT * FROM orders
      WHERE user_id = ? AND plan_id = ? AND status = 'completed'
      AND expiry_date > NOW()
      ORDER BY expiry_date DESC LIMIT 1
    `, [getUser[0].id, getUser[0].plan_id]);

    if (activeOrder.length < 1) {
      return res.json({
        success: false,
        msg: "Your plan was expired. Please buy a plan",
      });
    }

    // Parse plan features
    const planFeatures = getPlan[0].features ? JSON.parse(getPlan[0].features) : {};

    // Create plan object with features
    req.plan = {
      ...planFeatures,
      contact_limit: getPlan[0].contact_limit,
      message_limit: getPlan[0].message_limit,
      qr_account: planFeatures.qr_account || 0,
      allow_note: planFeatures.allow_note || 0,
      allow_tag: planFeatures.allow_tag || 0,
      wa_warmer: planFeatures.wa_warmer || 0,
    };

    next();
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

const checkContactLimit = async (req, res, next) => {
  try {
    const contact_limit = req.plan?.contact_limit;

    const getContacts = await query(`SELECT * FROM contact WHERE uid = ?`, [
      req.decode.uid,
    ]);

    if (getContacts.length >= contact_limit) {
      return res.json({
        success: false,
        msg: `Your plan allowd you to add only ${contact_limit} contacts. Delete some to add new`,
      });
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

const checkNote = async (req, res, next) => {
  try {
    if (req.plan?.allow_note > 0) {
      next();
    } else {
      return res.json({
        msg: "Your plan does not allow you to add or edit chat notes",
      });
    }
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

const checkTags = async (req, res, next) => {
  try {
    if (req.plan?.allow_tag > 0) {
      next();
    } else {
      return res.json({
        msg: "Your plan does not allow you to add or edit chat notes",
      });
    }
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

const checkWaWArmer = async (req, res, next) => {
  try {
    if (req.plan?.wa_warmer > 0) {
      next();
    } else {
      return res.json({
        msg: "Your plan does not allow you this feature",
      });
    }
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

const checkQrScan = async (req, res, next) => {
  try {
    if (req.plan?.qr_account > 0) {
      const accounts = parseInt(req?.plan?.qr_account) || 0;
      const instances = await query(`SELECT * FROM instance WHERE uid = ?`, [
        req.decode.uid,
      ]);

      if (instances?.length >= accounts) {
        return res.json({
          msg: `Your plan allows you to add ${accounts} instances only`,
        });
      }

      next();
    } else {
      return res.json({
        msg: "Your plan does not allow you this feature",
      });
    }
  } catch (err) {
    console.log(err);
    res.json({ msg: "server error", err });
  }
};

module.exports = {
  checkPlan,
  checkContactLimit,
  checkNote,
  checkTags,
  checkWaWArmer,
  checkQrScan,
};
