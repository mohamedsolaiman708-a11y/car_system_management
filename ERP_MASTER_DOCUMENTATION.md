# ERP Master Documentation

## Enterprise Financing ERP System

Version: 1.0


# 1. Project Overview

Enterprise ERP for investment and financing companies.

## Core Modules
- Authentication
- CRM
- Investors
- Customers
- Contracts
- Funding
- Installments
- Payments
- Accounting
- Reports
- Settings
- Audit Logs

# 2. Business Flow
Investor → Approval → Contract Funding → Customer Payments → FIFO Allocation → Investor Distribution → Accounting → Contract Closure

# 3. User Roles
- Super Admin
- Admin
- Accountant
- Operations
- Investor

# 4. Authentication
Two portals:
- Staff Portal
- Investor Portal (Register → Pending → Approve → Login)

# 5. Architecture
Flutter → REST/RPC → PostgreSQL Functions → PostgreSQL

Business logic exists only in PostgreSQL.

# 6. Database Principles
- Single Source of Truth
- No financial logic in Flutter
- RPC for financial operations
- Immutable financial records

# 7. Financial Engine
process_contract_payment():
- FIFO allocation
- Profit split
- Investor distribution
- Journal posting
- Domain events
- Contract closing

# 8. Reversal Engine
reverse_contract_payment():
- Reverse journals
- Reverse allocations
- Reverse investor transactions
- Reopen contracts
- Prevent double reversal

# 9. Accounting Rules
- Double Entry
- Debit = Credit
- No negative values
- Active accounts only
- Immutable ledger

# 10. Security
- Supabase Auth
- JWT
- RBAC
- RLS
- SECURITY DEFINER
- Audit Logs
- Idempotency

# 11. API Standards
- REST
- RPC
- Versioned APIs
- JSON
- Pagination
- Filtering

# 12. Flutter
- Riverpod
- GoRouter
- Material 3
- Arabic RTL
- Responsive

# 13. Main Screens
Splash, Portal Selection, Staff Login, Investor Login, Register, Pending, Dashboard, CRM, Customers, Investors, Contracts, Funding, Payments, Accounting, Reports, Settings, Audit Logs.

# 14. Development Rules
- Never move business logic to Flutter.
- Never bypass RPC.
- Never delete financial records.
- Always use accounting entries.
- Always emit domain events.

# 15. Deployment
- Production Supabase
- SMTP
- SSL
- Backups
- Monitoring
- CI/CD

# 16. Goal
Production-grade banking-level ERP system.
