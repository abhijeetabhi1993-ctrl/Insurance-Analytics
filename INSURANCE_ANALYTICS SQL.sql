-- Individual Budget Table

-- create database insurance_analytics;

 use insurance_analytics;

CREATE TABLE individual_budget (
    branch VARCHAR(100),
    sales_person_id INT,
    employee_name VARCHAR(150),
    new_role2 VARCHAR(100),
    new_budget DECIMAL(15,2),
    cross_sell_budget DECIMAL(15,2),
    renewal_budget DECIMAL(15,2),
    PRIMARY KEY (sales_person_id)
);

CREATE TABLE individual_budget11 (
    branch VARCHAR(100),
    sales_person_id INT,
    employee_name VARCHAR(150),
    new_role2 VARCHAR(100),
    new_budget DECIMAL(15,2),
    cross_sell_budget DECIMAL(15,2),
    renewal_budget DECIMAL(15,2),
    PRIMARY KEY (sales_person_id)
);

select * from individual_budget11;

select * from individual_budget;

-- Invoice Table
CREATE TABLE invoice (
    invoice_number VARCHAR(50),
    invoice_date DATE,
    revenue_transaction_type VARCHAR(100),
    branch_name VARCHAR(100),
    solution_group VARCHAR(100),
    account_exe_id varchar(100) null,
    account_executive VARCHAR(150),
    income_class VARCHAR(100),
    client_name VARCHAR(150),
    policy_number VARCHAR(50),
    amount DECIMAL(15,2),
    income_due_date DATE
);

-- Brokerage Table
CREATE TABLE brokerage (
    client_name VARCHAR(150),
    policy_number VARCHAR(50),
    policy_status VARCHAR(50),
    policy_start_date DATE,
    policy_end_date DATE,
    product_group VARCHAR(100),
    account_id INT,
    account_exe_id varchar(100),
    branch_name VARCHAR(100),
    solution_group VARCHAR(100),
    income_class VARCHAR(100),
    amount decimal(15,2) null,
    income_due_date DATE null,
    revenue_transaction_type VARCHAR(100),
    renewal_status VARCHAR(50),
    lapse_reason VARCHAR(255) null,
    last_updated_date DATE
);


CREATE TABLE brokerage11 (
    client_name VARCHAR(150),
    policy_number VARCHAR(50),
    policy_status VARCHAR(50),
    policy_start_date DATE,
    policy_end_date DATE,
    product_group VARCHAR(100),
    account_id INT,
    account_exe_id varchar(100),
    branch_name VARCHAR(100),
    solution_group VARCHAR(100),
    income_class VARCHAR(100),
    amount decimal(15,2) null,
    income_due_date DATE null,
    revenue_transaction_type VARCHAR(100),
    renewal_status VARCHAR(50),
    lapse_reason VARCHAR(255) null,
    last_updated_date DATE
);

select * from brokerage11;


desc brokerage;

-- Fees Table
CREATE TABLE fees (
    client_name VARCHAR(150),
    branch_name VARCHAR(100),
    solution_group VARCHAR(100),
    salesperson_id INT,
    account_executive VARCHAR(150),
    income_class VARCHAR(100),
    amount DECIMAL(15,2),
    income_due_date DATE,
    revenue_transaction_type VARCHAR(100),
    FOREIGN KEY (salesperson_id) REFERENCES individual_budget(sales_person_id)
);

-- Opportunity Table
CREATE TABLE opportunity (
    opportunity_id VARCHAR(50) PRIMARY KEY,
    opportunity_name VARCHAR(255),
    account_exe_id INT NULL,
    account_executive VARCHAR(255),
    premium_amount DECIMAL(15,2) NULL,
    revenue_amount DECIMAL(15,2) NULL,
    closing_date DATE NULL,
    stage VARCHAR(100),
    branch VARCHAR(100),
    specialty VARCHAR(100),
    product_group VARCHAR(100),
    product_sub_group VARCHAR(100),
    risk_details TEXT
);

-- Meeting Table
CREATE TABLE meeting (
    account_exe_id INT NULL,
    account_executive VARCHAR(255),
    branch_name VARCHAR(100),
    global_attendees VARCHAR(100) NULL,
    meeting_date DATE NULL
);




-- Target
create view Target as
select 	
	sum(new_budget) as new_budget,
    sum(cross_sell_budget) as cross_sell_budget,
    sum(renewal_budget) as renewal_budget
from individual_budget;

-- invoice
create view invoice_value as
select 
	income_class,
    sum(amount) as total
from invoice
group by income_class;

-- brokerage
create view brokerage_value as
select income_class, sum(amount) as total_brokerage
from brokerage group by income_class;

select * from brokerage_value ;

-- fees
create view fees_value as
select income_class, sum(amount) as total_fees
from fees group by 1;

-- achivement
create view achivement as
select b.income_class, total_brokerage+total_fees as total
from brokerage_value as b
join fees_value as f on b.income_class = f.income_class;


select * from Target;
select * from invoice_value;
select * from brokerage_value;
select * from fees_value;
select * from achivement;

-- crosssell
create view Cross_sell as
select "Target" as cross_sell, concat(round(Cross_Sell_budget/1000000,2) ," ", "M")as Value
from Target
union 
select "invoice", concat(round(total/1000000,2)," ", "M")
from invoice_value
where income_class = "Cross Sell"
union
select "achivement", concat(round(total/1000000,2)," ","M")
from achivement
where income_class = "Cross Sell";

select * from Cross_sell ;

-- output
-- cross sell   value
-- Target	      20.08
-- invoice	       2.85
-- achivement 	 12.99
-- ------------------------------------------------------------------------------------------

-- New
create view new as
select "Target" as new, concat(round(new_budget/1000000,2)," ", "M") as Value
from Target
union 
select "invoice", concat(round(total/1000000,2)," ", "M")
from invoice_value
where income_class = "new"
union
select "achivement", concat(round(total/1000000,2)," ", "M")
from achivement
where income_class = "new";

select * from New ;

-- output
-- new      value
-- Target	19.67
-- invoice	0.57
-- achivement	3.53
-- -----------------------------------------------------------------------------------------------

-- renewal

create view renewal as
select "Target" as Renewal, concat(round(Renewal_budget/1000000,2)," ", "M") as Value
from Target
union 
select "invoice", concat(round(total/1000000,2), " ", "M")
from invoice_value
where income_class = "renewal"
union
select "achivement", concat(round(total/1000000,2), " ", "M")
from achivement
where income_class = "renewal";

select * from renewal;

-- output
-- renewal  value
-- Target	12.32
-- invoice	8.24
-- achivement	18.51
-- -------------------------------------------------------------------------------------------------
-- KPI

-- cross sell placed achived %
SELECT
    round((SUM(CASE WHEN cross_sell = 'achivement' THEN value ELSE 0 END) /
    SUM(CASE WHEN cross_sell = 'Target' THEN value ELSE 0 END))*100 ,2) AS "cross_sell_placed_ach_%"
FROM cross_sell;

-- output -> 64.69    

-- cross sell invoice achived %
SELECT
    round((SUM(CASE WHEN cross_sell = 'invoice' THEN value ELSE 0 END) /
    SUM(CASE WHEN cross_sell = 'Target' THEN value ELSE 0 END))*100 ,2) AS "cross_sell_invoice_ach_%"
FROM cross_sell;

-- output -> 14.19  
-- -----------------------------------------------------------------------------------------------------------------------

-- New placed ach %
SELECT
    round((SUM(CASE WHEN New = 'achivement' THEN value ELSE 0 END) /
    SUM(CASE WHEN New = 'Target' THEN value ELSE 0 END))*100 ,2) AS "New_placed_ach_%"
FROM New ;
-- output -> 17.95

-- New invoice ach %
SELECT
    round((SUM(CASE WHEN New = 'invoice' THEN value ELSE 0 END) /
    SUM(CASE WHEN New = 'Target' THEN value ELSE 0 END))*100 ,2) AS "New_invoice_ach_%"
FROM New ;
-- output -> 2.90   
-- -------------------------------------------------------------------------------------------------------

-- renewal placed ach %
SELECT
    round((SUM(CASE WHEN renewal = 'achivement' THEN value ELSE 0 END) /
    SUM(CASE WHEN renewal = 'Target' THEN value ELSE 0 END))*100 ,2) AS "renewal_placed_ach_%"
FROM renewal ;
-- output -> 150.24  

-- renewal invoice ach %
SELECT
    round((SUM(CASE WHEN renewal = 'invoice' THEN value ELSE 0 END) /
    SUM(CASE WHEN renewal = 'Target' THEN value ELSE 0 END))*100 ,2) AS "renewal_invoice_ach_%"
FROM renewal ;
-- output ->  66.88 
-- ---------------------------------------------------------------------------------------------------------------------
 
-- yearly meeting count
select
	year(meeting_date) as year,
    count(*) as No_of_meeting
from meeting
group by year;

-- output
-- year    no of meeting
-- 2019  	3
-- 2020	    31

-- No. of Meeting by Account Executive
select
	account_executive,
    count(*) as No_of_meeting
from meeting
group by account_executive
order by No_of_meeting desc;

-- output
-- account exect    no of meeting
-- Abhinav Shivam	7
-- Vinay	5
-- Animesh Rawat	4
-- Ketan Jain	4
-- Shivani Sharma	4
-- Gilbert	3
-- Manish Sharma	3
-- Raju Kumar	2
-- Mark	2

-- --------------------------------------------------------------------------------------------------

-- No. of Invoice by Account Executive
select
	account_executive,
    count(*) as No_of_invoice
from invoice
group by account_executive
order by No_of_invoice desc;

-- output
-- account exect   no of meeting
-- Divya Dhingra	63
-- Ankita Shah	36
-- Vidit Shah	27
-- Animesh Rawat	20
-- Vinay	19
-- Shobhit Agarwal	12
-- Shloka Shelat	10
-- Abhinav Shivam	10
-- Gautam Murkunde	4
-- Mark	2
-- Neel Jain	1
-- ---------------------------------------------------------------------------------------------

-- total opportunity
select
	count(*) as total_opportunity
from opportunity;

-- total_opportunity - 49

-- total open opportunity
select
	count(*) as total_open_opportunity
from opportunity
where stage = "Qualify Opportunity" or stage = "Propose Solution";

-- total_open_opportunity - 44

-- Top 5 opportunity by Revenue
select
	opportunity_name,
    revenue_amount
from opportunity
order by revenue_amount desc
limit 5;

-- output
-- opportunity_name  revenue_amount
-- Fire	500000.00
-- EL-Group Mediclaim	400000.00
-- DB -Mega Policy	400000.00
-- CVP GMC	350000.00
-- FM-Group Mediclaim	300000.00
-- ---------------------------------------------------------------------------------------------------------------------

-- stage by Revenue
select
	stage,
    sum(revenue_amount) as total_revenue
from opportunity
group by 1;

-- output
-- stage                total_revenue 
-- Qualify Opportunity	5919500.00
-- Negotiate	899000.00
-- Propose Solution	60000.00
-- ---------------------------------------------------------------------------------------------

-- opportunity - Product Group
select
	product_group,
    count(*) as total_opportunity
from opportunity
group by product_group
order by total_opportunity desc;

-- output
-- product_group     total_opportunity
-- Employee Benefits	15
-- Fire	13
-- Marine	7
-- Engineering	6
-- Liability	5
-- Miscellaneous	2
-- Terrorism	1
-- -------------------------------------------------------------------------------------------------------

-- Open opportunity - Top 5
select
	opportunity_name,
	sum(revenue_amount) as total_revenue
from opportunity
where stage = "Qualify Opportunity" or stage = "Propose Solution"
group by opportunity_name
order by total_revenue desc
limit 5;

-- output
-- opportunity_name     total_revenue
-- EL-Group Mediclaim	400000.00
-- DB -Mega Policy	400000.00
-- CVP GMC	350000.00
-- FM-Group Mediclaim	300000.00
-- DS- Employees GMC	300000.00
