---
name: data-vault-design
description: >
  Design Data Vault 2.0 schemas including hubs, links, satellites, business
  vault, and information marts. Use when designing ERDs, data warehouse
  models, or discussing hubs/links/satellites, hash keys, load dates, or
  record sources. Enforces strict column placement rules — descriptive
  attributes NEVER go in Hubs or Links.
license: MIT
compatibility: opencode
metadata:
  domain: data-engineering
  methodology: data-vault-2.0
---

# Data Vault 2.0 Design Skill

## Core Philosophy

Data Vault 2.0 separates data into three distinct concerns:

- **Identity** → Hubs (what business entities exist?)
- **Relationships** → Links (how are those entities related?)
- **Description** → Satellites (what do those entities look like, and how have they changed?)

This separation is the entire point of Data Vault. Violating it (e.g. putting
descriptive attributes in a Hub) defeats the architecture. Every design
decision flows from this principle.

---

## When to Invoke This Skill

- Designing or reviewing a data warehouse or lakehouse schema
- The user mentions hubs, links, satellites, hash keys, or load dates
- Choosing between Data Vault, star schema, 3NF, or wide tables
- Designing for audit trail, compliance, or multi-source ingestion
- Creating ERD diagrams for an analytical platform
- A user puts descriptive data (names, text, amounts, statuses) in a Hub — correct them

---

## Table Types: Strict Column Rules

### HUB — Identity Only

**Purpose:** A unique, deduplicated list of business keys for one business
concept. Answers "what entities exist?"

**The Hub IS NOT a dimension.** It has no descriptive attributes. No name,
no status, no content, no amounts. Just the key and metadata.

**Allowed columns — exactly these, nothing more:**

| Column | Type | Purpose |
|---|---|---|
| `{entity}_hash_key` | CHAR(32) / BYTES | PK — MD5/SHA-256 hash of the business key |
| `{entity}_bk` | VARCHAR | The natural/business key from the source system |
| `load_date` | TIMESTAMP NOT NULL | When this key was FIRST seen — never updated |
| `record_source` | VARCHAR NOT NULL | Which source system first provided this key |

**Hard rules for Hubs:**
- EXACTLY 4 columns (or more if composite business key requires extra BK columns)
- Append-only and immutable — once inserted, a row NEVER changes
- One row per unique business key, ever
- The business key must have a UNIQUE constraint
- Business key must be meaningful to the business (not a DB surrogate)
- NEVER add: names, descriptions, statuses, amounts, text content, timestamps of events, or any descriptive attribute

**What is a business key?** The natural identifier the business uses:
customer number, product SKU, order reference, comment ID (the ID, NOT the
comment text). If two source systems use the same ID space with different
meanings, use a composite key: `(source_system, entity_id)`.

**Real example — a comment hub:**
```sql
-- CORRECT: hub_comment stores only the comment's identity
CREATE TABLE hub_comment (
    comment_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    comment_id        VARCHAR(50)  NOT NULL UNIQUE,  -- business key
    load_date         TIMESTAMP    NOT NULL,
    record_source     VARCHAR(100) NOT NULL
);

-- WRONG — never do this:
-- Adding comment_text, author_name, created_at, status to a hub
-- is the single most common Data Vault mistake.
```

**More hub examples:**
```sql
-- hub_customer: just the customer ID
CREATE TABLE hub_customer (
    customer_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    customer_id        VARCHAR(50)  NOT NULL UNIQUE,
    load_date          TIMESTAMP    NOT NULL,
    record_source      VARCHAR(100) NOT NULL
);

-- hub_product: just the SKU
CREATE TABLE hub_product (
    product_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    product_sku       VARCHAR(100) NOT NULL UNIQUE,
    load_date         TIMESTAMP    NOT NULL,
    record_source     VARCHAR(100) NOT NULL
);

-- hub_order: just the order reference
CREATE TABLE hub_order (
    order_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    order_ref       VARCHAR(50)  NOT NULL UNIQUE,
    load_date       TIMESTAMP    NOT NULL,
    record_source   VARCHAR(100) NOT NULL
);
```

---

### LINK — Relationships Only

**Purpose:** Records that a relationship between two or more Hubs was
observed. Answers "how are these entities connected?"

**The Link IS NOT a fact table** and contains NO descriptive data.
No amounts, no statuses, no attributes about the relationship.
Those go in a Satellite attached to the Link.

**Allowed columns — exactly these:**

| Column | Type | Purpose |
|---|---|---|
| `{link_name}_hash_key` | CHAR(32) | PK — hash of all participating business keys combined |
| `{hub1}_hash_key` | CHAR(32) | FK to first Hub |
| `{hub2}_hash_key` | CHAR(32) | FK to second Hub |
| `{hubN}_hash_key` | CHAR(32) | FK to Nth Hub (for multi-way links) |
| `load_date` | TIMESTAMP NOT NULL | When this relationship was FIRST observed |
| `record_source` | VARCHAR NOT NULL | Which source system first reported this relationship |

**Hard rules for Links:**
- Append-only and immutable — once a relationship is recorded it stays forever
- One row per unique combination of participating hub keys
- Minimum two Hub FKs; no upper limit (3-way, 4-way links are valid)
- NEVER add: amounts, statuses, names, descriptions, or any attribute about
  the relationship — those go in a Link Satellite
- Links do NOT contain begin/end dates
- If a relationship ends (e.g. order cancelled), that fact goes in a
  Satellite on the Link, not on the Link itself

**Examples:**
```sql
-- link between a comment and the post it belongs to
CREATE TABLE lnk_post_comment (
    post_comment_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    post_hash_key          CHAR(32)     NOT NULL REFERENCES hub_post,
    comment_hash_key       CHAR(32)     NOT NULL REFERENCES hub_comment,
    load_date              TIMESTAMP    NOT NULL,
    record_source          VARCHAR(100) NOT NULL,
    UNIQUE (post_hash_key, comment_hash_key)
);

-- link between a comment and the user who wrote it
CREATE TABLE lnk_user_comment (
    user_comment_hash_key  CHAR(32)     NOT NULL PRIMARY KEY,
    user_hash_key          CHAR(32)     NOT NULL REFERENCES hub_user,
    comment_hash_key       CHAR(32)     NOT NULL REFERENCES hub_comment,
    load_date              TIMESTAMP    NOT NULL,
    record_source          VARCHAR(100) NOT NULL
);

-- 3-way link: order placed by customer for a product
CREATE TABLE lnk_order_customer_product (
    link_hash_key      CHAR(32)     NOT NULL PRIMARY KEY,
    order_hash_key     CHAR(32)     NOT NULL REFERENCES hub_order,
    customer_hash_key  CHAR(32)     NOT NULL REFERENCES hub_customer,
    product_hash_key   CHAR(32)     NOT NULL REFERENCES hub_product,
    load_date          TIMESTAMP    NOT NULL,
    record_source      VARCHAR(100) NOT NULL
);
```

---

### SATELLITE — All Descriptive Attributes

**Purpose:** Stores the descriptive attributes of a Hub or Link, with full
change history. Every attribute that is NOT a key lives here. Answers
"what does this entity look like, and how has it changed over time?"

**This is where ALL content lives:**
- For a comment: the comment text, edit history, status, sentiment score
- For a customer: name, email, address, preferences
- For an order: total amount, status, shipping address
- For a relationship/link: the attributes of that relationship (e.g. quantity
  on an order-product link, role on a user-team link)

**Allowed columns:**

| Column | Type | Purpose |
|---|---|---|
| `{parent}_hash_key` | CHAR(32) | PK part 1 — FK to parent Hub or Link |
| `load_date` | TIMESTAMP | PK part 2 — when this version was loaded |
| `load_end_date` | TIMESTAMP NULL | When this version was superseded (NULL = current) |
| `record_source` | VARCHAR NOT NULL | Which source system provided this data |
| `hash_diff` | CHAR(32) NOT NULL | Hash of ALL descriptive columns — used for change detection |
| `effective_from` | TIMESTAMP | (Optional) Business effective date — when it happened, not when loaded |
| `attribute_1..N` | any | The actual descriptive data for this entity |

**Hard rules for Satellites:**
- Primary key is `(parent_hash_key, load_date)` — one row per entity per load
- Append-only: NEVER update rows, insert a new row when data changes
- One Satellite per source system — if Customer data comes from both Salesforce
  and SAP, create `sat_customer_crm` and `sat_customer_erp` separately
- Split Satellites by rate of change: fast-changing columns (e.g. last_login,
  balance) should be in a separate Satellite from slow-changing ones
  (e.g. name, date_of_birth) to avoid excessive row proliferation
- `hash_diff` is computed from all descriptive columns — compare incoming
  `hash_diff` to latest stored value to detect changes (skip insert if same)
- NEVER connect a Satellite directly to another Satellite — always through a Hub or Link
- No business logic in a Raw Vault Satellite — raw values only

**Comment example (the one that triggered this correction):**
```sql
-- The hub stores only the comment ID
-- hub_comment: comment_hash_key, comment_id, load_date, record_source

-- The satellite stores everything descriptive about the comment
CREATE TABLE sat_comment_details (
    comment_hash_key  CHAR(32)      NOT NULL REFERENCES hub_comment,
    load_date         TIMESTAMP     NOT NULL,
    load_end_date     TIMESTAMP     NULL,         -- NULL = current record
    record_source     VARCHAR(100)  NOT NULL,
    hash_diff         CHAR(32)      NOT NULL,
    -- All the actual comment data lives here:
    comment_text      TEXT,
    status            VARCHAR(50),  -- draft, published, deleted
    edited_at         TIMESTAMP,
    is_pinned         BOOLEAN,
    PRIMARY KEY (comment_hash_key, load_date)
);

-- If comment metadata changes at a different rate, split it:
CREATE TABLE sat_comment_moderation (
    comment_hash_key   CHAR(32)      NOT NULL REFERENCES hub_comment,
    load_date          TIMESTAMP     NOT NULL,
    load_end_date      TIMESTAMP     NULL,
    record_source      VARCHAR(100)  NOT NULL,
    hash_diff          CHAR(32)      NOT NULL,
    -- Moderation-specific attributes (may change independently):
    is_flagged         BOOLEAN,
    moderation_status  VARCHAR(50),
    flagged_reason     VARCHAR(200),
    PRIMARY KEY (comment_hash_key, load_date)
);
```

**Customer example with two source systems:**
```sql
-- Salesforce CRM data
CREATE TABLE sat_customer_crm (
    customer_hash_key  CHAR(32)      NOT NULL REFERENCES hub_customer,
    load_date          TIMESTAMP     NOT NULL,
    load_end_date      TIMESTAMP     NULL,
    record_source      VARCHAR(100)  NOT NULL,
    hash_diff          CHAR(32)      NOT NULL,
    full_name          VARCHAR(200),
    email              VARCHAR(200),
    phone              VARCHAR(50),
    segment            VARCHAR(100),
    PRIMARY KEY (customer_hash_key, load_date)
);

-- SAP ERP data (separate satellite — changing Salesforce's schema
-- doesn't affect this one)
CREATE TABLE sat_customer_erp (
    customer_hash_key  CHAR(32)      NOT NULL REFERENCES hub_customer,
    load_date          TIMESTAMP     NOT NULL,
    load_end_date      TIMESTAMP     NULL,
    record_source      VARCHAR(100)  NOT NULL,
    hash_diff          CHAR(32)      NOT NULL,
    credit_limit       DECIMAL(18,2),
    payment_terms      VARCHAR(50),
    account_status     VARCHAR(50),
    PRIMARY KEY (customer_hash_key, load_date)
);
```

**Link Satellite example — attributes of a relationship:**
```sql
-- The order-product link says "this product appeared on this order"
-- But quantity, unit price, discount — those are attributes OF the
-- relationship, so they go in a Satellite on the Link:
CREATE TABLE sat_order_product_details (
    order_product_hash_key  CHAR(32)      NOT NULL REFERENCES lnk_order_product,
    load_date               TIMESTAMP     NOT NULL,
    load_end_date           TIMESTAMP     NULL,
    record_source           VARCHAR(100)  NOT NULL,
    hash_diff               CHAR(32)      NOT NULL,
    quantity                INT,
    unit_price              DECIMAL(18,2),
    discount_pct            DECIMAL(5,2),
    PRIMARY KEY (order_product_hash_key, load_date)
);
```

---

## Satellite Splitting: When and How

Satellites can and should be split when:

| Reason | Example |
|---|---|
| **Different source systems** | `sat_customer_crm` vs `sat_customer_erp` |
| **Rate of change** | `sat_customer_profile` (stable: name, DOB) vs `sat_customer_activity` (volatile: last_login, balance) |
| **Domain / subject area** | `sat_customer_contact` (email, phone) vs `sat_customer_address` (street, city, postcode) |
| **PII separation** | `sat_customer_pii` (restricted access) vs `sat_customer_commercial` (open) |

A single wide Satellite with 50 columns is an anti-pattern. Every attribute
change creates a new row for ALL columns, causing unnecessary data duplication
in the slower-changing attributes.

---

## Business Vault (BV)

Built on top of the Raw Data Vault. Contains soft business rules and derived
structures. Is **fully rebuildable** from the Raw Vault.

**What lives in the Business Vault:**

- **Point-in-Time (PIT) tables** — pre-joined snapshots across all Satellites
  for a Hub at specific timestamps. Eliminates complex temporal joins at query time.
- **Bridge tables** — flatten many-to-many Link relationships for easier consumption
- **Computed/derived Satellites** — business rule outputs (e.g. `bv_sat_customer_risk_score`,
  `bv_sat_order_classification`)
- **Same-as Links** — identify when two different business keys from different
  source systems actually represent the same entity

**Hard rule:** No business logic in the Raw Vault. Business logic only in BV.

```sql
-- PIT table example: snapshot of all sat versions for a customer
-- at specific dates, so downstream queries don't need complex joins
CREATE TABLE pit_customer (
    customer_hash_key       CHAR(32)   NOT NULL,
    snapshot_date           DATE       NOT NULL,
    sat_customer_crm_ldts   TIMESTAMP, -- load_date of latest CRM sat row at snapshot
    sat_customer_erp_ldts   TIMESTAMP, -- load_date of latest ERP sat row at snapshot
    PRIMARY KEY (customer_hash_key, snapshot_date)
);
```

---

## Information Marts

The consumer-facing layer. Built on top of the Business Vault (or directly
from the Raw Vault for simple cases). These are standard dimensional models
(star schema: facts + dimensions) optimised for BI tools and reporting.

Business users and BI tools NEVER query the Raw Vault directly.

---

## Loading Order (always follow this sequence)

1. **Stage** — Load raw source data into staging tables. Compute hash keys
   and hash_diffs in staging (not in the vault load itself)
2. **Load Hubs** — Insert new business keys (idempotent: safe to run twice)
3. **Load Links** — Insert new relationship combinations (idempotent)
4. **Load Satellites** — Compare hash_diffs; insert only where data changed

Steps 2-4 can be parallelised across independent entities.

---

## Hash Key Rules

- Hash the **business key** columns only — never surrogates
- Normalise before hashing: `UPPER(TRIM(value))`
- For composite keys, concatenate with a consistent delimiter: `key1 || '||' || key2`
- For Link hash keys, hash the concatenation of ALL participating business keys
- Use SHA-256 for collision resistance (MD5 is acceptable for non-critical systems)
- `hash_diff` in Satellites: hash ALL descriptive columns concatenated (use
  `COALESCE(col, '')` to handle NULLs consistently)

---

## Naming Conventions

| Prefix | Table Type |
|---|---|
| `hub_` | Hub |
| `lnk_` | Link |
| `sat_` | Satellite (Raw Vault) |
| `pit_` | Point-in-Time (Business Vault) |
| `br_` | Bridge (Business Vault) |
| `bv_sat_` | Business Vault Satellite (derived/computed) |
| `dim_` / `fct_` | Information Mart (dimensional layer) |

---

## The "Where Does This Column Go?" Decision Tree

When a user presents a source column, ask:

1. **Is it how the business identifies this entity?** (an ID, a code, a key)
   → Goes in the **Hub** as the business key
2. **Does it describe a relationship between two entities?** (e.g. quantity on
   an order line, a role on a team membership)
   → Goes in a **Satellite on the Link**
3. **Does it describe the entity itself?** (name, text, amount, status, flag,
   timestamp of a business event, any other attribute)
   → Goes in a **Satellite on the Hub**
4. **Is it derived from other data / a business rule output?**
   → Goes in a **Business Vault Satellite**
5. **Is it a metadata field generated by the ETL pipeline?**
   → Goes in the mandatory metadata columns (`load_date`, `record_source`,
   `hash_diff`) present on every table

---

## Common Mistakes — Explicit Corrections

| Mistake | Correction |
|---|---|
| Putting entity name/description/text in Hub | Hub = keys only. Name/text → Satellite |
| Putting relationship attributes in a Link | Quantities, statuses, amounts on a relationship → Link Satellite |
| One giant Satellite per Hub | Split by source system AND by rate of change |
| Updating existing rows | Data Vault is append-only. Always insert new rows |
| Using DB surrogate keys as business keys | Use meaningful natural keys the business recognises |
| Putting business logic in Raw Vault | Raw = raw. Logic → Business Vault |
| Connecting Satellites to Satellites | Satellites only connect to Hubs or Links |
| Skipping `hash_diff` | Essential for change detection — never omit it |
| Including `record_source` in the `hash_diff` input | Metadata should not be in hash_diff — only descriptive columns |
| Hubs with parent/child relationships | Hubs are flat — hierarchy belongs in Links |

---

## When NOT to Use Data Vault 2.0

- Single source system with a stable schema → use star schema (Kimball)
- Small team / rapid PoC / < 5 source systems → dimensional model is faster
- BI tools querying the warehouse directly → Data Vault always needs a
  presentation layer on top; if you can't build that layer, use dimensional
- Speed-to-value sprint projects → up-front DV design work slows delivery

---

## dbt Integration (automate-dv)

For dbt-based implementations, use the `automate-dv` package which provides
macros for all DV 2.0 patterns — hubs, links, satellites, PITs, bridges.

Reference: https://automate-dv.readthedocs.io

```yaml
# Example sat model metadata
source_model: "v_stg_comments"
src_pk: "COMMENT_HK"
src_hashdiff:
  source_column: "COMMENT_HASHDIFF"
  alias: "HASHDIFF"
src_payload:
  - "COMMENT_TEXT"
  - "STATUS"
  - "EDITED_AT"
  - "IS_PINNED"
src_ldts: "LOAD_DATETIME"
src_source: "RECORD_SOURCE"
```
