# ERP Enterprise Remaining Features Roadmap

> Execute **one phase at a time**. Do not start the next phase until the
> current one is completed and verified. Reuse the existing Design
> System, API architecture, database schema, authentication,
> permissions, and routing.

------------------------------------------------------------------------

# PHASE 15 --- Global Search

## Goal

Implement a global search across: - Customers - Investors - Contracts -
Payments - Staff

Requirements: - Arabic RTL UI - Instant search - Filters by entity
type - Navigate to selected record - No database redesign

------------------------------------------------------------------------

# PHASE 16 --- Activity Timeline

## Goal

Display a chronological timeline for each contract.

Events include: - Contract Created - Approved - Funded - Payment
Received - Payment Reversed - Contract Closed

Use existing Domain Events.

------------------------------------------------------------------------

# PHASE 17 --- File Management

## Goal

Support attachments.

Allowed files: - National ID - Contracts - PDFs - Images - Guarantees -
Checks

Features: - Upload - Preview - Download - Replace - Soft Delete

------------------------------------------------------------------------

# PHASE 18 --- Reports Center

Create reports for: - Revenue - Profit - Investors - Contracts -
Collections - Overdue Installments - Cash Flow

Filters: - Date Range - Investor - Customer - Status

------------------------------------------------------------------------

# PHASE 19 --- Export Center

Every data table should support: - PDF - Excel - CSV

Options: - Export Current Page - Export All

------------------------------------------------------------------------

# PHASE 20 --- Company Settings

Manage: - Company Name - Logo - Address - Phone - Email - Currency -
Company Profit Ratio - SMTP - Tax Settings - Payment Methods

------------------------------------------------------------------------

# PHASE 21 --- User Management

Features: - Create Staff - Edit Staff - Disable Account - Reactivate
Account - Reset Password - Change Roles - Search - Filters

------------------------------------------------------------------------

# PHASE 22 --- Audit Logs Viewer

Create an Audit Logs page.

Search by: - User - Date - Action - Table - Record ID

Display full details.

------------------------------------------------------------------------

# PHASE 23 --- Background Jobs

Manage: - Email Queue - Scheduled Jobs - Failed Jobs - Retry Jobs

Statuses: - Pending - Running - Failed - Completed

-----------------------------------------------------------------------

# PHASE 24 --- Help Center

Include: - FAQ - User Guide - Contact Support - Version Information -
Changelog

------------------------------------------------------------------------

# Rules

-   Do not modify financial engine.
-   Do not redesign database unless required.
-   Do not break existing APIs.
-   Keep Arabic RTL.
-   Keep responsive design.
-   Complete and verify each phase before starting the next.
