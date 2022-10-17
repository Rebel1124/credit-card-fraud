/* First create view to combine and analize the credit card transactions data*/ 
DROP VIEW IF EXISTS group_transactions;

CREATE VIEW group_transactions AS
SELECT ch.name, t.date, t.amount, t.card AS "Credit Card", t.id_merchant, m.name AS "merchant", mc.name AS "merchant_category" 
FROM transaction AS t 
JOIN credit_card AS cc ON (t.card = cc.card) 
JOIN card_holder AS ch ON (cc.id_card_holder = ch.id) 
JOIN merchant AS m ON (t.id_merchant = m.id) 
JOIN merchant_category AS mc ON (m.id_merchant_category = mc.id) 
GROUP BY (ch.name, t.date, t.amount, t.card, t.id_merchant, m.name, mc.name)
ORDER BY ch.name ASC;

/* Here I count the number of credit card transactions I have in my database */
Select COUNT(name) from group_transactions

/* Next we can write query to isolate the transactions of each card holder using the WHERE function */ 
Select * from group_transactions as gt
WHERE gt.name = 'Austin Johnson';

/* Here we create a view for all the transactions that are less than $2 */ 
DROP VIEW IF EXISTS less_than_2;

CREATE VIEW less_than_2 AS
select * from group_transactions as gt
WHERE gt.amount < 2;

/* Then we count the number of transactions that are less than $2 */ 
Select COUNT(name) from less_than_2;

/* From the above we see that we have 3500 credit card transactions in our database of which 350 are below $2.
   That represents 10% of the data and suggests that there may be evidence of credit card fraud in the system.*/


/* Taking our analysis a step further, we filter on the top 100 possible fraudulant transactions
   (i.e. transactions less than $2) for the time period 7am to 9am.*/
/*select *, date::timestamp::time from less_than_2*/
DROP VIEW IF EXISTS fraud_time;

CREATE VIEW fraud_time AS
Select * from less_than_2
WHERE date::timestamp::time BETWEEN '07:00:00' AND '09:00:00'
ORDER BY amount DESC;

Select * from fraud_time
limit 100;

/* The results from the above query shows that there are only 30 potential fraudulant transaction between 7am-9am.
   This means than less than 10% of our total possible fraudulant transactions (350) occurs between these timesABORT
   meaning that most of the possible frauulant transactions (greaten than 90%) occurs durin the rest of the day.*/
DROP VIEW IF EXISTS merchant_fraud;

CREATE VIEW merchant_fraud AS
Select merchant, COUNT(merchant) as "count", SUM(amount) as "total" from less_than_2
GROUP BY merchant
ORDER BY total DESC;

Select * from merchant_fraud
limit 5;

/* From the above query we see the top 5 merchants prone to hacking are:
	Wood-Ramirez, Hood-Phillip, Jarvis-Turner, Walker Deleon and Wolf and Atkinson Ltd.*/
