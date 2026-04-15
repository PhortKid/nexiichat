# SQL Table Names - Comprehensive Analysis
**nexiichat Project**  
**Generated:** April 11, 2026

---

## Executive Summary
- **Total Unique Tables:** 51
- **Routes Files Scanned:** 18 files
- **Functions Files Scanned:** 4 files
- **Helper Files Scanned:** Multiple (socket, addon, inbox, chatbot)
- **Loops Files Scanned:** 2 files

---

## Complete Alphabetical List of All Tables

1. **admin** - Administrative users
2. **agent_chats** - Chat assignments to agents
3. **agent_task** - Tasks assigned to agents
4. **agents** - Agent accounts
5. **beta_api_analytics** - Analytics for API messages
6. **beta_api_logs** - Logs for API messages
7. **beta_api_messages** - API messages tracking
8. **beta_campaign** - Campaign management (beta)
9. **beta_campaign_logs** - Campaign execution logs
10. **beta_chats** - Chat conversations (beta)
11. **beta_chatbot** - Chatbot configurations (beta)
12. **beta_conversation** - Message conversations (beta)
13. **beta_flows** - Chat flows (beta)
14. **broadcast** - Broadcast campaigns
15. **broadcast_log** - Broadcast execution logs
16. **chat_tags** - Tags for categorizing chats
17. **chat_widget** - Chat widget configurations
18. **chatbot** - Chatbot settings
19. **chats** - Chat conversations
20. **contact** - Contact information
21. **contact_form** - Website contact form submissions
22. **fcm_tokens** - Firebase Cloud Messaging tokens
23. **faq** - Frequently asked questions
24. **flow** - Chat flow definitions
25. **flow_data** - Flow step data and variables
26. **flow_session** - Active flow sessions
27. **flow_templates** - Pre-built flow templates
28. **g_auth** - Google authentication records
29. **gen_links** - Generated WhatsApp links
30. **instance** - WhatsApp instances
31. **meta_api** - Meta (Facebook/Instagram) API credentials
32. **meta_templet_media** - Meta message templates media
33. **mobile_app** - Mobile app configuration
34. **orders** - Payment orders
35. **page** - Website pages
36. **partners** - Partner information
37. **phonebook** - Contact phonebooks
38. **plan** - Subscription plans
39. **quick_reply** - Quick reply templates
40. **rooms** - Socket.io rooms for real-time communication
41. **smtp** - SMTP email configuration
42. **templets** - Message templates
43. **testimonial** - Customer testimonials
44. **user** - User accounts
45. **wa_call_bot** - WhatsApp call bots
46. **wa_call_broadcasts** - WhatsApp call broadcasts
47. **wa_call_flows** - WhatsApp call flows
48. **warmers** - WhatsApp account warmers
49. **warmer_script** - Scripts for account warming
50. **web_private** - Private website configuration
51. **web_public** - Public website configuration

---

## Tables by File Reference

### ROUTES DIRECTORY

#### routes/admin.js
Tables: `admin`, `plan`, `web_public`, `user`, `web_private`, `partners`, `faq`, `page`, `testimonial`, `orders`, `contact_form`, `smtp`, `mobile_app`, `flow_templates`, `beta_chats`, `beta_conversation`, `agents`, `agent_task`, `instance`, `beta_flows`, `gen_links`

#### routes/agent.js
Tables: `agents`, `agent_chats`, `chats`, `contact`, `quick_reply`, `beta_conversation`

#### routes/ai.js
(Need to check for SQL queries)

#### routes/apiv2.js
Tables: `user`, `meta_api`, `beta_api_logs`

#### routes/broadcast.js
Tables: `meta_api`, `contact`, `user`, `broadcast`, `broadcast_log`, `phonebook`, `beta_campaign`, `beta_campaign_logs`

#### routes/chatbot.js
Tables: `chatbot`, `beta_flows`, `beta_chatbot`

#### routes/chatFlow.js
Tables: `flow`, `beta_flows`, `flow_session`

#### routes/inbox.js
Tables: `admin`, `meta_api`, `chats`, `contact`, `user`, `rooms`, `wa_call_broadcasts`, `beta_chats`, `beta_conversation`, `beta_api_logs`, `beta_campaign_logs`

#### routes/phonebook.js
Tables: `phonebook`, `contact`

#### routes/qr.js
Tables: `user`, `instance`

#### routes/telegram.js
Tables: `web_private`

#### routes/templet.js
Tables: `templets`

#### routes/theme.js
(Theme configuration from files, not SQL database)

#### routes/user.js
Tables: `web_public`, `user`, `contact`, `beta_conversation`, `chats`, `chatbot`, `chatbot`, `contact`, `phonebook`, `flow`, `broadcast`, `templets`, `plan`, `web_private`, `meta_api`, `orders`, `meta_templet_media`, `agent_task`, `agents`, `beta_chats`, `quick_reply`, `warmers`, `warmer_script`, `g_auth`, `fcm_tokens`, `chat_widget`

#### routes/waCall.js
Tables: `wa_call_flows`, `wa_call_bot`, `wa_call_broadcasts`

#### routes/web.js
Tables: `admin`, `web_public`, `web_private`, `contact_form`, `gen_links`

#### routes/webhook.js
(Need to check for SQL queries)

#### routes/webhookNo.js
(Need to check for SQL queries)

---

### FUNCTIONS DIRECTORY

#### functions/function.js
Tables: `beta_chats`, `user`, `chatbot`, `chats`, `rooms`, `agent_chats`, `meta_api`, `beta_conversation`, `mobile_app`, `beta_campaign_logs`, `meta_templet_media`, `agents`

#### functions/chatbot.js
Tables: `agent_chats`, `flow_data`, `flow`

#### functions/apiMessages.js
Tables: `beta_api_messages`, `beta_api_analytics`

#### functions/ai.js
(Need to check for SQL queries)

---

### HELPER DIRECTORY

#### helper/socket/index.js
Tables: `contact`, `agents`, `beta_chats`, `beta_conversation`, `chat_tags`, `phonebook`, `beta_chatbot`, `user`

#### helper/socket/function.js
Tables: `instance`, `meta_api`, `beta_conversation`

#### helper/chatbot/meta/index.js
Tables: `flow_data`, `user`, `chatbot`

#### helper/addon/qr/warmer/index.js
Tables: `instance`

#### helper/addon/qr/warmer/functions.js
Tables: `warmers`, `warmer_script`, `user`

#### helper/addon/qr/processThings.js
Tables: `beta_chats`, `beta_conversation`

#### helper/addon/qr/mongoSession.js
(Session management, not SQL)

#### helper/inbox/inbox.js
Tables: `agents`, `user`

#### helper/inbox/meta/index.js
Tables: `beta_chats`, `meta_api`

#### helper/chatbot/meta/function.js
Tables: `meta_api`, `user`

---

### LOOPS DIRECTORY

#### loops/campaignLoop.js
Tables: `meta_api`, `broadcast_log`, `broadcast`

#### loops/campaignBeta.js
Tables: `beta_campaign`, `beta_campaign_logs`, `meta_api`, `contact`

---

## Table Usage Frequency

**Most Referenced Tables (by file count):**
1. `user` - 11+ files
2. `meta_api` - 9+ files
3. `chats` / `beta_chats` - 8+ files
4. `agents` / `agent_chats` - 7+ files
5. `beta_conversation` - 7+ files
6. `contact` - 6+ files
7. `broadcast` / `broadcast_log` - 5+ files
8. `plan` - 5+ files
9. `orders` - 5+ files
10. `instance` - 5+ files

---

## Table Categories

### User Management
- `user`
- `admin`
- `agents`
- `agent_chats`
- `agent_task`

### Chat & Messaging
- `chats`
- `beta_chats`
- `beta_conversation`
- `rooms`
- `chat_tags`
- `chat_widget`

### Contact Management
- `contact`
- `phonebook`
- `contact_form`

### Templates & Flows
- `chatbot`
- `beta_chatbot`
- `templets`
- `flow`
- `beta_flows`
- `flow_data`
- `flow_session`
- `flow_templates`
- `meta_templet_media`

### Campaigns & Broadcasting
- `broadcast`
- `broadcast_log`
- `beta_campaign`
- `beta_campaign_logs`
- `wa_call_broadcasts`
- `wa_call_bot`
- `wa_call_flows`

### Warming/Automation
- `warmers`
- `warmer_script`

### Authentication & Integrations
- `meta_api`
- `g_auth`
- `smtp`
- `fcm_tokens`

### API & Analytics
- `beta_api_logs`
- `beta_api_messages`
- `beta_api_analytics`

### Orders & Plans
- `orders`
- `plan`

### Configuration
- `web_public`
- `web_private`
- `mobile_app`
- `instance`
- `page`
- `partners`
- `faq`
- `testimonial`
- `quick_reply`
- `gen_links`

---

## Notes

1. **Deprecated/Legacy Tables**: Some tables like `chats` may coexist with newer `beta_chats` implementation
2. **Integration Tables**: `meta_api` is heavily used for WhatsApp Business Platform integration
3. **Real-time Communication**: `rooms` table is critical for Socket.io based real-time updates
4. **Campaign System**: Dual implementation exists (old `broadcast` and new `beta_campaign`)
5. **Flow System**: New `beta_flows` implementation with `flow_data` for detailed step information

