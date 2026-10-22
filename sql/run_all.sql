-- Runs every script in dependency order.
-- Run it from the project root in the mysql client:
--     source sql/run_all.sql;
-- The numbers in the file names are the run order. The order is not the same
-- as the phase order, because the sample order in phase 2 needs the discount
-- function (phase 3) and the automation triggers (phase 4).

-- Phase 1: schema
source sql/phase1_schema/01_database_schema.sql;

-- Phase 2: inventory log triggers and sample data
source sql/phase2_orders_inventory/02_create_triggers.sql;
source sql/phase2_orders_inventory/03_sample_data.sql;

-- Phase 3: discount function (used by the automation triggers)
source sql/phase3_reporting/04_bulk_discounts.sql;

-- Phase 4: automation triggers
source sql/phase4_replenishment_automation/05_automation.sql;

-- Phase 2: sample order (needs the discount function and the triggers above)
source sql/phase2_orders_inventory/06_place_order_transaction.sql;

-- Phase 3: reports
source sql/phase3_reporting/07_order_summaries_per_customer.sql;
source sql/phase3_reporting/08_low_stock_report.sql;
source sql/phase3_reporting/09_customer_tiers_and_spending.sql;

-- Phase 4: replenishment procedures
source sql/phase4_replenishment_automation/10_stock_replenishment.sql;

-- Phase 5: views and indexes
source sql/phase5_views_performance/11_view_summary.sql;
source sql/phase5_views_performance/12_performance_optimization.sql;
