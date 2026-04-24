const router = require("express").Router();
const { query } = require("../database/dbpromise.js");
const validateUser = require("../middlewares/user.js");
const { checkWebhook } = require("../helper/addon/webhook/index.js");

// Get webhooks (instances with webhook enabled)
router.get("/get_webhooks", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const webhooks = await query(
      `SELECT id, instance_name, webhook_status, webhook_url, message_webhook, created_at
       FROM instance
       WHERE uid = ? AND webhook_status = true`,
      [req.decode.uid]
    );

    res.json({ success: true, data: webhooks });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Add webhook to instance
router.post("/add_webhook", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { instance_id, webhook_url, message_webhook } = req.body;

    if (!instance_id || !webhook_url) {
      return res.json({ success: false, msg: "Instance ID and webhook URL are required" });
    }

    // Verify instance belongs to user
    const instance = await query(
      `SELECT id FROM instance WHERE id = ? AND uid = ?`,
      [instance_id, req.decode.uid]
    );

    if (instance.length === 0) {
      return res.json({ success: false, msg: "Instance not found" });
    }

    // Update webhook settings
    await query(
      `UPDATE instance SET webhook_status = true, webhook_url = ?, message_webhook = ? WHERE id = ?`,
      [webhook_url, message_webhook || '', instance_id]
    );

    res.json({ success: true, msg: "Webhook added successfully" });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Update webhook
router.post("/update_webhook", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { instance_id, webhook_url, message_webhook } = req.body;

    if (!instance_id) {
      return res.json({ success: false, msg: "Instance ID is required" });
    }

    // Verify instance belongs to user
    const instance = await query(
      `SELECT id FROM instance WHERE id = ? AND uid = ?`,
      [instance_id, req.decode.uid]
    );

    if (instance.length === 0) {
      return res.json({ success: false, msg: "Instance not found" });
    }

    // Update webhook settings
    await query(
      `UPDATE instance SET webhook_url = ?, message_webhook = ? WHERE id = ?`,
      [webhook_url || '', message_webhook || '', instance_id]
    );

    res.json({ success: true, msg: "Webhook updated successfully" });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Delete webhook (disable)
router.post("/delete_webhook", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { instance_id } = req.body;

    if (!instance_id) {
      return res.json({ success: false, msg: "Instance ID is required" });
    }

    // Verify instance belongs to user
    const instance = await query(
      `SELECT id FROM instance WHERE id = ? AND uid = ?`,
      [instance_id, req.decode.uid]
    );

    if (instance.length === 0) {
      return res.json({ success: false, msg: "Instance not found" });
    }

    // Disable webhook
    await query(
      `UPDATE instance SET webhook_status = false, webhook_url = '', message_webhook = '' WHERE id = ?`,
      [instance_id]
    );

    res.json({ success: true, msg: "Webhook disabled successfully" });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Test webhook endpoint
router.post("/webhook/:webhook_id", async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { webhook_id } = req.params;
    const payload = req.body;

    // Find instance with this webhook
    const instance = await query(
      `SELECT * FROM instance WHERE id = ? AND webhook_status = true`,
      [webhook_id]
    );

    if (instance.length === 0) {
      return res.json({ success: false, msg: "Webhook not found" });
    }

    // Log webhook call (you might want to create a webhook_logs table)
    console.log(`Webhook ${webhook_id} received:`, payload);

    res.json({ success: true, msg: "Webhook received" });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Get webhook details
router.get("/webhook/:webhook_id", async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { webhook_id } = req.params;

    const instance = await query(
      `SELECT id, instance_name, webhook_status, webhook_url, message_webhook
       FROM instance WHERE id = ? AND webhook_status = true`,
      [webhook_id]
    );

    if (instance.length === 0) {
      return res.json({ success: false, msg: "Webhook not found" });
    }

    res.json({ success: true, data: instance[0] });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Get webhook logs (placeholder - would need webhook_logs table)
router.get("/get_webhook_logs", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    // Placeholder - in a real implementation, you'd have a webhook_logs table
    const logs = [];

    res.json({ success: true, data: logs });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

// Delete webhook logs (placeholder)
router.post("/delete_webhook_logs", validateUser, async (req, res) => {
  try {
    if (!checkWebhook()) {
      return res.json({ msg: "plugin required", success: false });
    }

    const { log_ids } = req.body;

    // Placeholder - in a real implementation, you'd delete from webhook_logs table
    res.json({ success: true, msg: "Logs deleted successfully" });
  } catch (err) {
    console.log(err);
    res.json({ success: false, msg: "Server error" });
  }
});

module.exports = router;
