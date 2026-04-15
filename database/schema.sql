-- ============================================================================
-- NEXIICHAT DATABASE SCHEMA
-- Created: April 11, 2026
-- Version: 5.9
-- Description: Complete database schema for WhatsApp CRM System
-- ============================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS nexiichat;
USE nexiichat;

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Users Table
CREATE TABLE IF NOT EXISTS user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  phone VARCHAR(20),
  mobile_with_country_code VARCHAR(25),
  avatar VARCHAR(255),
  bio TEXT,
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  plan_id INT,
  subscription_status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_email (email),
  INDEX idx_status (status)
);

-- Admin Table
CREATE TABLE IF NOT EXISTS admin (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50),
  permissions JSON,
  status ENUM('active', 'inactive') DEFAULT 'active',
  last_login TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid),
  INDEX idx_email (email)
);

-- ============================================================================
-- PLANS & BILLING
-- ============================================================================

-- Plans Table
CREATE TABLE IF NOT EXISTS plan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  price DECIMAL(10, 2),
  currency VARCHAR(10) DEFAULT 'USD',
  billing_cycle ENUM('monthly', 'yearly') DEFAULT 'monthly',
  features JSON,
  contact_limit INT DEFAULT 1000,
  message_limit INT DEFAULT 10000,
  active BOOLEAN DEFAULT TRUE,
  trial_days INT DEFAULT 7,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_slug (slug)
);

-- Orders/Payments Table
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  plan_id INT NOT NULL,
  order_id VARCHAR(255) UNIQUE,
  gateway VARCHAR(50), -- 'stripe', 'mercadopago'
  transaction_id VARCHAR(255),
  amount DECIMAL(10, 2),
  currency VARCHAR(10),
  status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  payment_method VARCHAR(50),
  billing_date DATETIME DEFAULT NULL,
  expiry_date DATETIME DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (plan_id) REFERENCES plan(id),
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_order_id (order_id)
);

-- ============================================================================
-- CONTACTS & COMMUNICATION
-- ============================================================================

-- Contacts Table
CREATE TABLE IF NOT EXISTS contact (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  name VARCHAR(255),
  email VARCHAR(255),
  source VARCHAR(50), -- 'manual', 'import', 'api', 'wa', 'telegram'
  tags JSON,
  avatar VARCHAR(255),
  custom_fields JSON,
  status ENUM('active', 'inactive', 'blocked') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  UNIQUE KEY unique_contact (uid, phone),
  INDEX idx_uid (uid),
  INDEX idx_phone (phone),
  INDEX idx_email (email)
);

-- Contact Tags
CREATE TABLE IF NOT EXISTS chat_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  contact_id INT NOT NULL,
  tag_name VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE,
  INDEX idx_uid (uid),
  INDEX idx_contact_id (contact_id)
);

-- Phonebook Table
CREATE TABLE IF NOT EXISTS phonebook (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  contact_count INT DEFAULT 0,
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid)
);

-- ============================================================================
-- CHAT & MESSAGE SYSTEM
-- ============================================================================

-- Legacy Chats Table
CREATE TABLE IF NOT EXISTS chats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  contact_id INT,
  phone VARCHAR(20),
  message TEXT,
  direction ENUM('incoming', 'outgoing') DEFAULT 'incoming',
  status ENUM('sent', 'delivered', 'read', 'failed') DEFAULT 'sent',
  message_type VARCHAR(50), -- 'text', 'image', 'video', 'audio', 'document'
  media_url VARCHAR(255),
  media_type VARCHAR(50),
  template_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (contact_id) REFERENCES contact(id),
  INDEX idx_uid (uid),
  INDEX idx_phone (phone),
  INDEX idx_created_at (created_at)
);

-- Beta Chats Table (New System)
CREATE TABLE IF NOT EXISTS beta_chats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  contact_id INT NOT NULL,
  instance_id INT,
  last_message TEXT,
  message_count INT DEFAULT 0,
  unread_count INT DEFAULT 0,
  status ENUM('active', 'archived', 'deleted') DEFAULT 'active',
  last_message_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (contact_id) REFERENCES contact(id) ON DELETE CASCADE,
  INDEX idx_uid (uid),
  INDEX idx_status (status),
  INDEX idx_last_message_at (last_message_at)
);

-- Beta Conversation (Messages)
CREATE TABLE IF NOT EXISTS beta_conversation (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  chat_id INT NOT NULL,
  contact_id INT,
  message TEXT,
  direction ENUM('incoming', 'outgoing') DEFAULT 'incoming',
  status ENUM('sent', 'delivered', 'read', 'failed') DEFAULT 'sent',
  message_type VARCHAR(50), -- 'text', 'image', 'video', 'audio', 'document', 'interactive'
  media_url VARCHAR(500),
  media_type VARCHAR(50),
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (chat_id) REFERENCES beta_chats(id) ON DELETE CASCADE,
  FOREIGN KEY (contact_id) REFERENCES contact(id),
  INDEX idx_uid (uid),
  INDEX idx_chat_id (chat_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- AGENTS & ASSIGNMENTS
-- ============================================================================

-- Agents Table
CREATE TABLE IF NOT EXISTS agents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  avatar VARCHAR(255),
  status ENUM('online', 'offline', 'busy', 'away') DEFAULT 'offline',
  role VARCHAR(50),
  assigned_chats INT DEFAULT 0,
  max_chats INT DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_email (email),
  INDEX idx_status (status)
);

-- Agent Chat Assignments
CREATE TABLE IF NOT EXISTS agent_chats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  agent_id INT NOT NULL,
  chat_id INT NOT NULL,
  uid VARCHAR(255) NOT NULL,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,
  status ENUM('assigned', 'active', 'resolved', 'unassigned') DEFAULT 'assigned',
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  FOREIGN KEY (chat_id) REFERENCES beta_chats(id) ON DELETE CASCADE,
  INDEX idx_agent_id (agent_id),
  INDEX idx_chat_id (chat_id),
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Agent Tasks
CREATE TABLE IF NOT EXISTS agent_task (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  agent_id INT,
  chat_id INT,
  title VARCHAR(255),
  description TEXT,
  status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high') DEFAULT 'Medium',
  due_date TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status),
  INDEX idx_priority (priority)
);

-- ============================================================================
-- WHATSAPP INTEGRATION
-- ============================================================================

-- WhatsApp Instances
CREATE TABLE IF NOT EXISTS instance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  instance_name VARCHAR(255),
  instance_key VARCHAR(255) UNIQUE,
  phone_number VARCHAR(20),
  owner_name VARCHAR(255),
  bot_number VARCHAR(20),
  session_status ENUM('connected', 'disconnected', 'qr', 'connecting') DEFAULT 'disconnected',
  webhook_status BOOLEAN DEFAULT FALSE,
  webhook_url VARCHAR(500),
  qr_code TEXT,
  message_webhook VARCHAR(500),
  connection_data JSON,
  settings JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_instance_key (instance_key),
  INDEX idx_status (session_status)
);

-- Meta API (Facebook/Instagram)
CREATE TABLE IF NOT EXISTS meta_api (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  api_type VARCHAR(50), -- 'whatsapp', 'facebook', 'instagram'
  business_account_id VARCHAR(255),
  phone_number_id VARCHAR(255),
  waba_id VARCHAR(255),
  access_token TEXT,
  token_expiry TIMESTAMP NULL,
  webhook_verify_token VARCHAR(255),
  webhook_url VARCHAR(500),
  is_configured BOOLEAN DEFAULT FALSE,
  status ENUM('active', 'inactive', 'need_refresh') DEFAULT 'inactive',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  UNIQUE KEY unique_meta (uid, api_type, phone_number_id),
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Generated Links (WhatsApp Share Links)
CREATE TABLE IF NOT EXISTS gen_links (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  link_id VARCHAR(255) UNIQUE,
  short_url VARCHAR(500),
  full_url VARCHAR(1000),
  message TEXT,
  click_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_link_id (link_id)
);

-- ============================================================================
-- TEMPLATES & MESSAGING
-- ============================================================================

-- Message Templates
CREATE TABLE IF NOT EXISTS templets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50),
  body TEXT NOT NULL,
  footer TEXT,
  header_type VARCHAR(50), -- 'text', 'image', 'video', 'document'
  header_url VARCHAR(500),
  variables JSON,
  buttons JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_name (name)
);

-- Meta Template Media
CREATE TABLE IF NOT EXISTS meta_templet_media (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  meta_template_id VARCHAR(255),
  media_type VARCHAR(50),
  media_url VARCHAR(500),
  is_template_media BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_uid (uid)
);

-- Quick Reply Templates
CREATE TABLE IF NOT EXISTS quick_reply (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  emoji VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid)
);

-- ============================================================================
-- CHATBOT & FLOWS
-- ============================================================================

-- Chatbot Settings
CREATE TABLE IF NOT EXISTS chatbot (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  description TEXT,
  greeting_message TEXT,
  fallback_message TEXT,
  status ENUM('active', 'inactive') DEFAULT 'inactive',
  trigger_keywords JSON,
  ai_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Beta Chatbot
CREATE TABLE IF NOT EXISTS beta_chatbot (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  description TEXT,
  greeting_message TEXT,
  fallback_message TEXT,
  status ENUM('active', 'inactive') DEFAULT 'inactive',
  ai_model VARCHAR(50),
  ai_prompt TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid)
);

-- Chat Flows
CREATE TABLE IF NOT EXISTS flow (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  flow_type VARCHAR(50), -- 'trigger', 'automation', 'schedule'
  trigger_type VARCHAR(50),
  trigger_keywords JSON,
  status ENUM('active', 'inactive') DEFAULT 'inactive',
  flow_data JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Beta Flows
CREATE TABLE IF NOT EXISTS beta_flows (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  trigger_type VARCHAR(50),
  trigger_data JSON,
  steps JSON,
  status ENUM('draft', 'active', 'inactive') DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Flow Data (Variables & States)
CREATE TABLE IF NOT EXISTS flow_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  flow_id INT NOT NULL,
  step_id VARCHAR(255),
  variable_name VARCHAR(255),
  variable_value TEXT,
  data_type VARCHAR(50),
  FOREIGN KEY (flow_id) REFERENCES flow(id) ON DELETE CASCADE,
  INDEX idx_flow_id (flow_id)
);

-- Flow Sessions (Active Conversations)
CREATE TABLE IF NOT EXISTS flow_session (
  id INT AUTO_INCREMENT PRIMARY KEY,
  flow_id INT NOT NULL,
  contact_id INT,
  contact_phone VARCHAR(20),
  current_step VARCHAR(255),
  session_data JSON,
  status ENUM('active', 'completed', 'failed') DEFAULT 'active',
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  FOREIGN KEY (flow_id) REFERENCES flow(id) ON DELETE CASCADE,
  FOREIGN KEY (contact_id) REFERENCES contact(id),
  INDEX idx_flow_id (flow_id),
  INDEX idx_contact_id (contact_id),
  INDEX idx_status (status)
);

-- Flow Templates
CREATE TABLE IF NOT EXISTS flow_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  template_data JSON,
  preview_image VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

-- ============================================================================
-- BROADCAST & CAMPAIGNS
-- ============================================================================

-- Broadcast Campaigns
CREATE TABLE IF NOT EXISTS broadcast (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  campaign_name VARCHAR(255),
  message TEXT,
  media_url VARCHAR(500),
  media_type VARCHAR(50),
  recipient_type ENUM('all', 'tagged', 'phonebook', 'selected') DEFAULT 'all',
  recipient_data JSON,
  status ENUM('draft', 'scheduled', 'active', 'completed', 'cancelled') DEFAULT 'draft',
  scheduled_at TIMESTAMP NULL,
  started_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  total_contacts INT DEFAULT 0,
  sent_count INT DEFAULT 0,
  failed_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Broadcast Logs
CREATE TABLE IF NOT EXISTS broadcast_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  broadcast_id INT NOT NULL,
  contact_id INT,
  phone VARCHAR(20),
  message_status ENUM('sent', 'delivered', 'read', 'failed') DEFAULT 'sent',
  failure_reason VARCHAR(255),
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  delivered_at TIMESTAMP NULL,
  FOREIGN KEY (broadcast_id) REFERENCES broadcast(id) ON DELETE CASCADE,
  FOREIGN KEY (contact_id) REFERENCES contact(id),
  INDEX idx_broadcast_id (broadcast_id),
  INDEX idx_message_status (message_status)
);

-- Beta Campaigns
CREATE TABLE IF NOT EXISTS beta_campaign (
  campaign_id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  template_id INT,
  template_name VARCHAR(255),
  template_language VARCHAR(10),
  phonebook_id INT,
  recipient_segment VARCHAR(50),
  recipient_data JSON,
  schedule_type ENUM('now', 'scheduled', 'recurring') DEFAULT 'now',
  schedule TIMESTAMP NULL,
  status ENUM('draft', 'PENDING', 'IN_PROGRESS', 'paused', 'completed', 'COMPLETED') DEFAULT 'draft',
  total_contacts INT DEFAULT 0,
  sent_count INT DEFAULT 0,
  delivered_count INT DEFAULT 0,
  read_count INT DEFAULT 0,
  failed_count INT DEFAULT 0,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Beta Campaign Logs
CREATE TABLE IF NOT EXISTS beta_campaign_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  campaign_id INT NOT NULL,
  contact_id INT,
  phone VARCHAR(20),
  status ENUM('sent', 'delivered', 'read', 'failed') DEFAULT 'sent',
  error_message VARCHAR(500),
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES beta_campaign(campaign_id) ON DELETE CASCADE,
  INDEX idx_campaign_id (campaign_id),
  INDEX idx_status (status)
);

-- ============================================================================
-- API & ANALYTICS
-- ============================================================================

-- API Messages Tracking
CREATE TABLE IF NOT EXISTS beta_api_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  message_id VARCHAR(255) UNIQUE,
  contact_phone VARCHAR(20),
  message_content TEXT,
  api_response JSON,
  status ENUM('sent', 'failed', 'pending') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid),
  INDEX idx_message_id (message_id),
  INDEX idx_status (status)
);

-- API Logs
CREATE TABLE IF NOT EXISTS beta_api_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  endpoint VARCHAR(500),
  method VARCHAR(10),
  request_body JSON,
  response_code INT,
  response_body JSON,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_uid (uid),
  INDEX idx_endpoint (endpoint(100))
);

-- API Analytics
CREATE TABLE IF NOT EXISTS beta_api_analytics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  total_messages INT DEFAULT 0,
  total_sent INT DEFAULT 0,
  total_failed INT DEFAULT 0,
  success_rate DECIMAL(5, 2) DEFAULT 0,
  analytics_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_analytics (uid, analytics_date),
  INDEX idx_uid (uid),
  INDEX idx_date (analytics_date)
);

-- ============================================================================
-- AUTHENTICATIONS
-- ============================================================================

-- Google Authentication
CREATE TABLE IF NOT EXISTS g_auth (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  google_id VARCHAR(255),
  email VARCHAR(255),
  name VARCHAR(255),
  avatar VARCHAR(500),
  access_token TEXT,
  refresh_token TEXT,
  token_expiry TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_g_auth (uid, google_id),
  INDEX idx_uid (uid)
);

-- Firebase Cloud Messaging Tokens
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  token TEXT NOT NULL,
  device_type VARCHAR(50), -- 'web', 'mobile'
  device_name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid),
  INDEX idx_token (token(100))
);

-- ============================================================================
-- WHATSAPP CALL SYSTEM
-- ============================================================================

-- WhatsApp Call Flows
CREATE TABLE IF NOT EXISTS wa_call_flows (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  description TEXT,
  ivr_steps JSON,
  status ENUM('active', 'inactive') DEFAULT 'inactive',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid)
);

-- WhatsApp Call Bot
CREATE TABLE IF NOT EXISTS wa_call_bot (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  phone_number VARCHAR(20),
  greeting_message TEXT,
  timeout_seconds INT DEFAULT 30,
  status ENUM('active', 'inactive') DEFAULT 'inactive',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid)
);

-- WhatsApp Call Broadcasts
CREATE TABLE IF NOT EXISTS wa_call_broadcasts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  campaign_name VARCHAR(255),
  audio_url VARCHAR(500),
  recipient_list JSON,
  status ENUM('draft', 'active', 'completed') DEFAULT 'draft',
  total_calls INT DEFAULT 0,
  completed_calls INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_uid (uid)
);

-- ============================================================================
-- ACCOUNT WARMING
-- ============================================================================

-- Warmers (Dummy Accounts for Warming)
CREATE TABLE IF NOT EXISTS warmers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  instance_id INT,
  type VARCHAR(50), -- 'message_warmer', 'call_warmer'
  status ENUM('active', 'paused', 'completed') DEFAULT 'active',
  message_count INT DEFAULT 0,
  max_messages INT DEFAULT 100,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instance_id) REFERENCES instance(id) ON DELETE SET NULL,
  INDEX idx_uid (uid),
  INDEX idx_status (status)
);

-- Warmer Scripts
CREATE TABLE IF NOT EXISTS warmer_script (
  id INT AUTO_INCREMENT PRIMARY KEY,
  warmer_id INT NOT NULL,
  script_content TEXT,
  message_template TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (warmer_id) REFERENCES warmers(id) ON DELETE CASCADE,
  INDEX idx_warmer_id (warmer_id)
);

-- ============================================================================
-- WEB & CONFIGURATION
-- ============================================================================

-- Web Public Configuration
CREATE TABLE IF NOT EXISTS web_public (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(255) UNIQUE NOT NULL,
  setting_value LONGTEXT,
  description TEXT,
  value_type VARCHAR(50),
  fb_login_app_id VARCHAR(255),
  fb_login_app_sec VARCHAR(255),
  privacy_policy TEXT,
  terms_of_service TEXT,
  footer_text TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_setting_key (setting_key)
);

-- Web Private Configuration
CREATE TABLE IF NOT EXISTS web_private (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(255) UNIQUE NOT NULL,
  setting_value LONGTEXT,
  description TEXT,
  value_type VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_setting_key (setting_key)
);

-- Pages
CREATE TABLE IF NOT EXISTS page (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255),
  slug VARCHAR(255) UNIQUE,
  content LONGTEXT,
  meta_description TEXT,
  meta_keywords TEXT,
  is_published BOOLEAN DEFAULT FALSE,
  permanent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_slug (slug)
);

-- SMTP Configuration
CREATE TABLE IF NOT EXISTS smtp (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  smtp_host VARCHAR(255),
  smtp_port INT,
  smtp_user VARCHAR(255),
  smtp_password VARCHAR(255),
  from_email VARCHAR(255),
  from_name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_smtp (uid),
  INDEX idx_uid (uid)
);

-- Chat Widget Configuration
CREATE TABLE IF NOT EXISTS chat_widget (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  widget_id VARCHAR(255) UNIQUE,
  title VARCHAR(255),
  welcome_message TEXT,
  position VARCHAR(50), -- 'bottom_right', 'bottom_left'
  color VARCHAR(10),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_widget (uid),
  INDEX idx_uid (uid)
);

-- Mobile App Configuration
CREATE TABLE IF NOT EXISTS mobile_app (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(255) UNIQUE NOT NULL,
  app_name VARCHAR(255),
  app_version VARCHAR(50),
  ios_url VARCHAR(500),
  android_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_uid (uid)
);

-- ============================================================================
-- CONTACT & FORMS
-- ============================================================================

-- Contact Form Submissions
CREATE TABLE IF NOT EXISTS contact_form (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(20),
  subject VARCHAR(255),
  message TEXT,
  status ENUM('new', 'read', 'responded') DEFAULT 'new',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_status (status)
);

-- FAQ
CREATE TABLE IF NOT EXISTS faq (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question TEXT NOT NULL,
  answer LONGTEXT NOT NULL,
  category VARCHAR(100),
  order_number INT DEFAULT 0,
  is_published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_category (category),
  INDEX idx_published (is_published)
);

-- Testimonials
CREATE TABLE IF NOT EXISTS testimonial (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_name VARCHAR(255),
  client_email VARCHAR(255),
  company VARCHAR(255),
  message TEXT,
  rating INT,
  image_url VARCHAR(500),
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_published (is_published)
);

-- ============================================================================
-- PARTNERS & MISC
-- ============================================================================

-- Partners
CREATE TABLE IF NOT EXISTS partners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  logo_url VARCHAR(500),
  website_url VARCHAR(500),
  contact_email VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_name (name)
);

-- Socket.IO Rooms (Real-time Communication)
CREATE TABLE IF NOT EXISTS rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_id VARCHAR(255) UNIQUE,
  uid VARCHAR(255),
  user_id INT,
  socket_id VARCHAR(255),
  room_type VARCHAR(50), -- 'chat', 'notification', 'presence'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
  INDEX idx_uid (uid),
  INDEX idx_room_id (room_id),
  INDEX idx_socket_id (socket_id)
);

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Composite indexes for common query patterns
ALTER TABLE user ADD INDEX idx_uid_status (uid, status);
ALTER TABLE contact ADD INDEX idx_uid_status (uid, status);
ALTER TABLE beta_chats ADD INDEX idx_uid_contact (uid, contact_id);
ALTER TABLE beta_conversation ADD INDEX idx_chat_status (chat_id, status);
ALTER TABLE broadcast ADD INDEX idx_uid_status (uid, status);
ALTER TABLE flow ADD INDEX idx_uid_status (uid, status);
ALTER TABLE instance ADD INDEX idx_uid_status (uid, session_status);

-- ============================================================================
-- VERSION & SETUP INFO
-- ============================================================================

-- Insert default settings
INSERT IGNORE INTO web_public (setting_key, setting_value, value_type) VALUES
  ('app_name', 'nexiichat', 'string'),
  ('app_version', '5.9', 'string'),
  ('support_email', 'support@nexiichat.com', 'string'),
  ('timezone', 'UTC', 'string');

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
