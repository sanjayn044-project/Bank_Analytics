create database bank_analytic;
use bank_analytic;
CREATE TABLE Finance_merged (
    id INT,
    member_id INT,
    loan_amnt INT,
    funded_amnt INT,
    funded_amnt_inv DECIMAL(15,8),
    term VARCHAR(20),
    int_rate DECIMAL(6,4),
    installment DECIMAL(10,2),
    grade CHAR(1),
    sub_grade VARCHAR(3),
    emp_title VARCHAR(255),
    emp_length VARCHAR(20),
    home_ownership VARCHAR(50),
    annual_inc BIGINT,
    verification_status VARCHAR(50),
    issue_d VARCHAR(20),
    loan_status VARCHAR(50),
    pymnt_plan VARCHAR(5),
    `desc` TEXT,
    purpose VARCHAR(100),
    title VARCHAR(255),
    zip_code VARCHAR(20),
    addr_state CHAR(2),
    dti DECIMAL(6,2),
    id2 INT,
    delinq_2yrs INT,
    earliest_cr_line VARCHAR(20),
    inq_last_6mths INT,
    mths_since_last_delinq INT,
    mths_since_last_record INT,
    open_acc INT,
    pub_rec INT,
    revol_bal BIGINT,
    revol_util DECIMAL(8,4),
    total_acc INT,
    initial_list_status CHAR(1),
    out_prncp BIGINT,
    out_prncp_inv BIGINT,
    total_pymnt DECIMAL(15,2),
    total_pymnt_inv DECIMAL(15,2),
    total_rec_prncp DECIMAL(15,2),
    total_rec_int DECIMAL(15,2),
    total_rec_late_fee DECIMAL(15,2),
    recoveries DECIMAL(15,2),
    collection_recovery_fee DECIMAL(15,2),
    last_pymnt_d VARCHAR(20),
    last_pymnt_amnt DECIMAL(15,2),
    next_pymnt_d VARCHAR(20),
    last_credit_pull_d VARCHAR(20),
    Year_issue_d INT,
    Month_issue_d VARCHAR(20),
    last_payment_year INT
);


SHOW VARIABLES LIKE 'secure_file_priv';

SET GLOBAL local_infile = 1;
SET sql_mode = '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Finance_merged.csv'
INTO TABLE Finance_merged
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * FROM finance_merged;


-- kpi-1
create table KPI_1 as Select year_issue_d as Year,sum(loan_amnt) as Loan_amount from finance_merged
group by year_issue_d order by year_issue_d;
SELECT * FROM kpi_1;

-- kpi-2
create table KPI_2 as SELECT 
    grade,
    sub_grade,
    SUM(revol_bal) AS total_revolving_balance
FROM finance_merged
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;
SELECT * FROM kpi_2;

-- kpi-3
 create table KPI_3 as select verification_status,sum(total_pymnt) as Total_payment
 from finance_merged group by verification_status;
 SELECT * FROM kpi_3;
 
 -- kpi-4
-- State wise loan status 
 create table KPI_4_statewise as SELECT 
    addr_state as State,
    loan_status,
    COUNT(*) AS loan_status_count
FROM Finance_merged
GROUP BY loan_status, State
ORDER BY State;
SELECT * FROM kpi_4_statewise;

-- month wise loan status
create table KPI_4_monthwise as SELECT 
    month_issue_d as month,
    loan_status,
    COUNT(*) AS loan_status_count
FROM Finance_merged
GROUP BY loan_status, month_issue_d
ORDER BY month_issue_d ;
SELECT * FROM kpi_4_monthwise;

-- kpi-5
create table KPI_5 as SELECT 
    home_ownership,
    count(id) as number_of_loan,
    max(last_pymnt_d) AS most_recent_date
FROM Finance_merged
GROUP BY home_ownership; 
SELECT * FROM kpi_5;

-- kpi-6
create table KPI_6 as select purpose,sum(loan_amnt) as Total_loan_amount 
from finance_merged
group by purpose order by Total_loan_amount desc;
SELECT * FROM kpi_6;

-- kpi-7
create table KPI_7 as select grade,sum(loan_amnt) as Total_loan_amount,ROUND((SUM(recoveries) / SUM(loan_amnt)) * 100, 2) AS Recovery_Rate from finance_merged where loan_status="charged off"
group by grade order by grade;
SELECT * FROM kpi_7;

-- kpi-8
create table KPI_8 as select grade,avg(annual_inc) as average_income,avg(loan_amnt) as average_loan_amount
from finance_merged
group by grade order by grade;
SELECT * FROM kpi_8;


CREATE TABLE nuberofcustomer AS
SELECT COUNT(DISTINCT member_id) AS number_of_customers
FROM Finance_merged;
CREATE TABLE bank_analytic.totalloanamt AS
SELECT SUM(loan_amnt) AS total_loan_amount
FROM Finance_merged;

CREATE TABLE bank_analytic.intrate AS
SELECT AVG(int_rate) * 100 AS avg_interest_rate_percent
FROM Finance_merged;

CREATE TABLE bank_analytic.dti AS
SELECT AVG(dti) AS avg_dti
FROM Finance_merged;

CREATE TABLE bank_analytic.revolving AS
SELECT SUM(revol_bal) AS total_revolving_balance
FROM Finance_merged;

create table total_recoveries as 
select sum(recoveries) from finance_merged;
select * from total_recoveries;

create table total_charged_off as 
select sum(loan_amnt) as total_charged_off from finance_merged where loan_status="Charged Off";
select * from total_charged_off;

create table fully_paid as 
select sum(total_pymnt) from finance_merged;
select * from fully_paid;