# SQL Table Reference Quick Guide
**nexiichat Project**

---

## Quick Stats

| Metric | Count |
|--------|-------|
| **Total Unique Tables** | 51 |
| **Files Scanned** | 18 routes + 4 functions + helpers + loops |
| **Most Referenced Table** | `user` (50+ references) |
| **Tables by Operation** | INSERT: 30+ tables, UPDATE: 25+ tables, SELECT: 45+ tables, DELETE: 20+ tables |

---

## By Functional Area

### 1. User & Authentication (5 tables)
```
admin          - Admin user accounts
user           - Regular user accounts  
agents         - Agent/support team accounts
agent_chats    - Chat assignments to agents
agent_task     - Tasks assigned to agents
```
**Primary Files:** `routes/admin.js`, `routes/user.js`, `routes/agent.js`

### 2. Chat & Messaging (6 tables)
```
chats                  - Traditional chat conversations
beta_chats             - New chat system
beta_conversation      - Message conversations
rooms                  - Socket.io real-time rooms
chat_tags              - Chat categorization
chat_widget            - Embedded chat widget
```
**Primary Files:** `routes/inbox.js`, `functions/function.js`, `helper/socket/`

### 3. Contact Management (2 tables)
```
contact       - Individual contacts
phonebook     - Contact groups/books
```
**Primary Files:** `routes/phonebook.js`, `routes/user.js`

### 4. Chatbot & Templates (7 tables)
```
chatbot              - Chatbot configurations
beta_chatbot         - New chatbot system
templets             - Message templates
flow                 - Chat flow definitions
beta_flows           - New flow system
flow_data            - Flow step data
flow_session         - Active flow sessions
```
**Primary Files:** `routes/chatbot.js`, `routes/chatFlow.js`, `functions/`

### 5. Broadcasts & Campaigns (6 tables)
```
broadcast                - Traditional broadcast campaigns
broadcast_log            - Broadcast execution logs
beta_campaign            - New campaign system
beta_campaign_logs       - Campaign execution logs
wa_call_broadcasts       - WhatsApp call broadcasts
wa_call_bot              - WA call bot configs
```
**Primary Files:** `routes/broadcast.js`, `loops/campaignBeta.js`

### 6. Meta/WhatsApp Integration (3 tables)
```
meta_api              - Meta API credentials (Facebook/Instagram)
meta_templet_media    - Message template media
wa_call_flows         - WA call flow configs
```
**Primary Files:** `routes/user.js`, `helper/chatbot/meta/`

### 7. Account Warming (2 tables)
```
warmers         - Account warmer configurations
warmer_script   - Warming scripts
```
**Primary Files:** `routes/user.js`, `helper/addon/qr/warmer/`

### 8. API & Logging (3 tables)
```
beta_api_logs       - API request logs
beta_api_messages   - API message tracking
beta_api_analytics  - API analytics data
```
**Primary Files:** `routes/apiv2.js`, `functions/apiMessages.js`

### 9. Orders & Plans (2 tables)
```
orders    - Payment orders
plan      - Subscription plans
```
**Primary Files:** `routes/user.js`, `routes/admin.js`

### 10. Configuration & Settings (8 tables)
```
web_public        - Public website configuration
web_private       - Private website settings
mobile_app        - Mobile app configuration
instance          - WhatsApp instances
page              - Website pages
partners          - Partner information
faq               - FAQ entries
testimonial       - Customer testimonials
```
**Primary Files:** `routes/admin.js`, `routes/web.js`

### 11. Other (2 tables)
```
contact_form      - Website contact submissions
quick_reply       - Quick reply templates
flow_templates    - Pre-built flow templates
smtp              - Email SMTP configuration
fcm_tokens        - Firebase Cloud Messaging
g_auth            - Google Authentication
gen_links         - Generated shareable links
```

---

## Table Access Patterns

### Very High Usage (10+ references)
- `user` - 50+ references (authentication, profile, settings)
- `meta_api` - 20+ references (WA Business Platform)
- `chats`/`beta_chats` - 15+ references (messaging)
- `agent_chats` - 12+ references (support routing)
- `beta_conversation` - 12+ references (messages)

### High Usage (5-9 references)
- `broadcast`/`beta_campaign` - 8+ references
- `agents` - 8+ references  
- `contact` - 10+ references
- `orders` - 10+ references
- `flow`/`flow_data` - 8+ references
- `instance` - 8+ references
- `plan` - 6+ references
- `web_public`/`web_private` - 8+ references

### Medium Usage (2-4 references)
- `rooms`, `templets`, `phonebook`, `admin`, `chatbot`

### Low Usage (1 reference)
- `faq`, `page`, `partners`, `testimonial`, `contact_form`

---

## Table Relationships

```
User Core
├── user
├── admin
├── agents
└── agent_task

Chat System
├── chats/beta_chats
├── beta_conversation (messages)
├── rooms (real-time)
└── agent_chats (agent assignment)

Contact Management
├── contact
└── phonebook

Automation
├── chatbot/beta_chatbot
├── flow/beta_flows
├── flow_data
├── flow_session
└── templets

Broadcasting
├── broadcast/beta_campaign
├── broadcast_log/beta_campaign_logs
├── wa_call_broadcasts
└── wa_call_flows

Meta Integration
├── meta_api
└── meta_templet_media

Orders & Plans
├── orders
└── plan

Settings & Config
├── web_public/web_private
├── mobile_app
├── instance
└── smtp
```

---

## Query Type Distribution

### SELECT Queries (Most Common)
- Used in 45+ tables
- For fetching user data, configurations, and chat history
- Most frequent: `user`, `meta_api`, `chats`, `contact`

### INSERT Queries  
- Used in 30+ tables
- For creating new records (users, chats, messages, orders)
- High volume: `beta_conversation`, `chats`, `orders`, `flow_data`

### UPDATE Queries
- Used in 25+ tables
- For status changes, field updates, delivery confirmations
- Frequent: `chats`, `instance`, `orders`, `user`, `meta_api`

### DELETE Queries
- Used in 20+ tables
- For removing conversations, campaigns, contacts
- Frequent: `agent_chats`, `chats`, `broadcast`, `contact`

---

## Database Design Patterns

### New vs Legacy Systems
- **Legacy:** `chats`, `broadcast`, `chatbot`, `flow`
- **Beta (New):** `beta_chats`, `beta_campaign`, `beta_chatbot`, `beta_flows`

### User Scope Pattern
- Most tables have `uid` (user ID) field for isolation
- Enables secure multi-tenancy

### Shadow Tables
- `beta_conversation` (messages)
- `beta_campaign_logs` (campaign tracking)
- `beta_api_logs` (API tracking)

### Configuration Tables (Singleton-like)
- `web_public`, `web_private`, `mobile_app`, `smtp`
- Usually have single or few records

---

## File Organization by Tables

### High-Touch Files (Use 15+ tables)
- `routes/user.js` - ~25 tables
- `routes/admin.js` - ~20 tables
- `functions/function.js` - ~12 tables
- `routes/broadcast.js` - ~8 tables

### Specialized Files
- `routes/qr.js` - Instance management
- `routes/waCall.js` - WhatsApp calling
- `routes/templet.js` - Message templates
- `loops/campaignBeta.js` - Campaign automation
- `helper/socket/index.js` - Real-time chat updates

---

## Common Operations by Table

| Table | Most Common Op | Use Case |
|-------|---|---|
| `user` | SELECT | Authentication, profile lookup |
| `chats` | INSERT/UPDATE | New messages, status updates |
| `meta_api` | SELECT | Get WA credentials |
| `contact` | INSERT | Bulk import, create contacts |
| `orders` | INSERT | Create payment orders |
| `instance` | UPDATE | Status changes (ACTIVE/INACTIVE) |
| `flow_data` | UPDATE | Save flow variable states |
| `beta_campaign` | SELECT | List campaigns |

---

## Notes for Developers

1. **Always include UID**: Most queries filter by `uid` for security
2. **Batch operations**: `contact`, `beta_conversation` support bulk inserts
3. **Real-time updates**: Changes to `chats`, `rooms` trigger Socket.io events
4. **Campaign metrics**: Counter updates in `beta_campaign_logs` use `INSERT...ON DUPLICATE KEY UPDATE`
5. **Media handling**: `meta_templet_media` stores template assets
6. **Socket rooms**: `rooms` table tracks active user sockets for real-time updates

---

## Migration Considerations

**Legacy → New Systems:**
- `chats` → `beta_chats`
- `broadcast` → `beta_campaign`  
- `chatbot` → `beta_chatbot`
- `flow` → `beta_flows`

Both old and new systems coexist during transition period.

