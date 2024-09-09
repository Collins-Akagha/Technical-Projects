
--OPTIMIZING ONLINE SPORTS RETAIL REVENUE PROJECT BY COLLINS AKAGHA

-------------------------------------------------------------------------------------------------------------------
--Looking at individual dataset
-- For Finance Dataset
Select *
From [Portfolio Projects]..finance

--For Brands
Select *
From [Portfolio Projects]..brands

--For Info
Select *
From info_v2

--For Reviews
Select*
From reviews_v2

--For Traffic
Select *
From [Portfolio Projects]..traffic_v3

-----------------------------------------------------------------------------------------------------------

--Looking at the total count of rows for each dataset to figure out the completeness of the data
Select count(*) total_rows, count(fin.listing_price) count_listed_price, count(info.description) count_description, 
count(last_visited) count_last_visted
From [Portfolio Projects]..info_v2 info
Join [Portfolio Projects]..finance fin
ON info.product_id = fin.product_id
Join [Portfolio Projects]..traffic_v3 traf
ON traf.product_id = info.product_id


--Looking at the total sum of listed_prices per brand
Select distinct(brand), Sum(listing_price) over (partition by brand) sum_listed_price
From [Portfolio Projects]..brands br
Join [Portfolio Projects]..finance fin
ON br.product_id = fin.product_id
WHERE brand is not null


--Looking at how much the price points of Adidas products differ from Nike products
Select brand, CAST(listing_price as int) price_listing, count(*) AS count
From Finance
JOIN brands
	ON finance.product_id = brands.product_id
WHERE listing_price > 0
Group By brand, listing_price
Order By 2 desc

--Labeling price ranges
Select brand, count(*) listing_price, sum(revenue) total_revenue,
CASE
	When count(listing_price) < 42 Then 'Budget'
	When count(listing_price) >= 42 AND count(listing_price) < 74 Then 'Average'
	When count(listing_price) >= 74 AND count(listing_price) < 129 Then 'Expensive'
	Else 'Elite' 
END price_category
From finance fin
JOIN brands br
	ON fin.product_id = br.product_id
Where brand is not null 
Group By brand, listing_price
Order By 2 desc


--Looking at the average discount by brand 
--METHOD 1
SELECT distinct(brand), avg(discount*100) over(partition by brand) avg_discount
FROM finance fin
JOIN brands br
	ON fin.product_id=br.product_id
Where brand is not null


--METHOD 2
Select brand, AVG(discount *100) average_discount
from finance fi
join brands br
on fi.product_id = br.product_id
Group by brand
Having brand is not null


--Looking at the correlation between revenue and reviews
Select (avg(reviews * revenue)- (avg(reviews)*avg(revenue))) / (STDEVP(reviews) * STDEVP(revenue)) revenue_review_correlation
From finance fin
Join reviews_v2 rev
	On fin.product_id = rev.product_id



--looking at ratings and reviews by product description length
Select SUBSTRING(description, 1, len(description)) description_length, Round(AVG(rating), 2) average_rating
From info_v2 inf
Join reviews_v2 rev
	ON inf.product_id = rev.product_id
	Where description is not null
	Group by description
	Order by 1

--Looking at reviews by month and brand 
Select brand, DATEPART(MM,last_visited) as Month , count(reviews) review_count
From reviews_v2 rev
Join brands br
ON rev.product_id = br.product_id
JOIN traffic_v3 tr
ON rev.product_id = tr.product_id
Group by brand, last_visited
Having brand is not null and last_visited is not null
Order By 1, 2


--Looking at the performance for footwear products
with Footwear AS(
Select inf.description, fin.revenue
From info_v2 inf
Join finance fin
	ON inf.product_id = fin.product_id
WHERE description like '%Shoe' OR description like '%trainer%' OR description like '$foot%'
Group By description, revenue
Having description is not null
)

Select count(description) num_footwear_products, PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) OVER () AS median_footwear_revenue  
From Footwear
Group By description, revenue



--Looking at the performance for clothing products
with footwear2 as(
Select inf.description, fin.revenue
From info_v2 inf
Join finance fin
	ON inf.product_id = fin.product_id
WHERE description like '%Shoe' OR description like '%trainer%' OR description like '$foot%' AND description is not null
Group By revenue, description
)

Select count(*) num_clothing_products, PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) OVER () AS median_clothing_revenue  
From info_v2 inf 
JOIN finance fin
	ON inf.product_id = fin.product_id
WHERE description not in (Select description 
							from footwear2)
Group By description, revenue
							




