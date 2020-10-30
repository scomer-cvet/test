Select 
  Date
, Category
, Product_Category
, case when month(DATE) between 3 and 6 then 1 else 0 end as FleaTick_Flag
, SUM(Core_Net_Revenue + Compounding_Net_Revenue) as Sales
, SUM(Core_orders + compounding_orders) as Orders

from(
select			
	a.order_date as Date,
    sum(case when (a.platform_id = 1 or a.platform_id = 4) and a.compound = 0 then a.item_revenue + a.item_shipping else 0 end) as Core_Net_Revenue,
	sum(case when a.compound = 1 then item_revenue + item_shipping else 0 end) as Compounding_Net_Revenue,

	case when (a.platform_id = 1 or a.platform_id = 4) and a.compound = 0 then 'CORE' 
		 when  a.compound = 1 then 'Compound' end as Product_Category,
    'GPM' as Category,
    
    count(distinct case when (a.platform_id = 1 or a.platform_id = 4) and a.compound = 0 then a.order_id end) as Core_orders,
    count(distinct case when a.compound = 1 then a.order_id end) as compounding_orders
from
    edw.gpm.fact_GPM_ORDER_LINE_DETAIL a
    inner join edw.gpm.dim_GPM_PRACTICE b on a.PRACTICE_SID = b.PRACTICE_SID
where
    a.order_date >= convert(DATE,(DATEADD(m, -36, GetDate())))
    and a.reship = 0
    and a.skip_flow_of_funds = 0
    and a.order_state = 'shipped') as t