/*---------------------------------------------------------------------*/
--Question 01
--What is the total amount each customer spent at the restaurant?
SELECT --count(*), m.product_name,m.price
s.customer_id,sum(m.price) as spendings
FROM dannys_diner.sales as s
inner join dannys_diner.menu as m
on m.product_id=s.product_id
group by s.customer_id;


/*---------------------------------------------------------------------*/

--Question 02
--How many days has each customer visited the restaurant?

--Normal count
select s.customer_id,count((s.order_date)) as Total_visited_Days
FROM dannys_diner.sales as s
group by s.customer_id

--Total Count

select s.customer_id,count(DISTINCT (s.order_date)) as Total_visited_Days
FROM dannys_diner.sales as s
group by s.customer_id


/*---------------------------------------------------------------------*/

-- 3. What was the first item from the menu purchased by each customer?

with CTE as(
select 
*,
 ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date,s.product_id
   ) row_num        
  from dannys_diner.sales as s
  )
  
  select c.customer_id,m.product_name from CTE as c
  inner join dannys_diner.menu as m
on m.product_id=c.product_id
  where c.row_num=1
order by c.customer_id

/*---------------------------------------------------------------------*/

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with CTE as
(
select s.product_id as product_id,count(s.product_id) as count_item
from dannys_diner.sales as s
group by s.product_id
order by count_item DESC
  )
  
  select cte.product_id,m.product_name,cte.count_item from CTE as cte
  inner join dannys_diner.menu as m
  on m.product_id=cte.product_id
  order by cte.count_item DESC
 limit 1;
 


select s.product_id as product_id,m.product_name,count(s.product_id) as count_item
from dannys_diner.sales as s
inner join dannys_diner.menu as m
on m.product_id=s.product_id
group by s.product_id,m.product_name
order by count_item DESC
limit 1;

/*---------------------------------------------------------------------*/


-- 5. Which item was the most popular for each customer?
with CTE as
(select 
s.product_id,
count(s.product_id) as counts,
s.customer_id,
 ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY count(s.product_id) DESC
   ) row_num 
  from dannys_diner.sales as s
  group by s.customer_id,s.product_id
  order by s.customer_id,counts DESC
  )

  select * from CTE
  where row_num=1
  
/*---------------------------------------------------------------------*/  

-- 6. Which item was purchased first by the customer after they became a member?
with CTE as(

select s.customer_id,s.order_date,s.product_id,m.join_date,
ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date 
   ) row_num 
from dannys_diner.sales as s
inner join dannys_diner.members as m
on s.customer_id=m.customer_id
where  s.order_date>= m.join_date
group by s.customer_id,s.order_date,s.product_id,m.join_date
order by s.customer_id,s.order_date DESC
  )
  
  select me.product_name,* from CTE
  inner join  dannys_diner.menu as me
  on me.product_id=CTE.product_id
  where row_num=1;
  
/*---------------------------------------------------------------------*/  
-- 7. Which item was purchased just before the customer became a member?  
  
  with CTE as(

select s.customer_id,s.order_date,s.product_id,m.join_date,
ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date DESC
   ) row_num 
from dannys_diner.sales as s
inner join dannys_diner.members as m
on s.customer_id=m.customer_id
where  s.order_date< m.join_date
group by s.customer_id,s.order_date,s.product_id,m.join_date
order by s.customer_id,s.order_date DESC
  )
  
  select me.product_name,* from CTE
  inner join  dannys_diner.menu as me
  on me.product_id=CTE.product_id
  where row_num=1;
  
/*---------------------------------------------------------------------*/  


-- 8. What is the total items and amount spent for each member before they became a member?


  with CTE as(

select s.customer_id,s.order_date,s.product_id,m.join_date,
ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date DESC
   ) row_num 
from dannys_diner.sales as s
inner join dannys_diner.members as m
on s.customer_id=m.customer_id
where  s.order_date< m.join_date
group by s.customer_id,s.order_date,s.product_id,m.join_date
order by s.customer_id,s.order_date DESC
  )
  
  --select * from CTE;
 -- select CTE.customer_id,count(CTE.customer_id) from CTE
 -- group by CTE.customer_id;
 
 
 select CTE.customer_id,sum(me.price),count(CTE.customer_id) from CTE
 inner join dannys_diner.menu as me
 on CTE.product_id=me.product_id
 group by CTE.customer_id;
/*---------------------------------------------------------------------*/  
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  with CTE1 as(

select s.customer_id,
CASE
    When s.product_id in(2,3) then sum( m.price)*10  
    when s.product_id in(1) then  sum( m.price)*10*2
    end as Points
from dannys_diner.sales as s
inner join dannys_diner.menu  as m
on s.product_id=m.product_id
  --  where s.product_id in(2,3)
    group by s.customer_id,s.product_id
 )
  
  select CTE1.customer_id,sum(CTE1.points) from CTE1

  group by CTE1.customer_id;
/*---------------------------------------------------------------------*/  

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

  with CTE1 as(

select s.customer_id,s.order_date,m.join_date,me.price,
CASE
    when s.order_date<m.join_date then  me.price*10
    when s.order_date>=m.join_date  then   me.price*10*2
END as Points
from dannys_diner.sales as s
inner join dannys_diner.members  as m
on s.customer_id=m.customer_id
 inner join dannys_diner.menu  as me
on s.product_id=me.product_id
    group by s.customer_id,s.order_date,m.join_date,me.price
 )
  
  select CTE1.customer_id, sum(CTE1.points) from CTE1
   where CTE1.order_date<='2021-01-31' 
  group by CTE1.customer_id;
 
 

  
  