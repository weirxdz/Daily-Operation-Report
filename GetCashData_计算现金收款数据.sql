USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetCashData]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER   PROCEDURE [dbo].[GetCashData] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售现金收款数据的存储过程
	-- 调用格式如下 
	-- exec GetSalesData @inputDate
  with day_s as (
    -- 日期
    select * from fr_calendar t where t.dDate = @inputDate
	),
  Cashdetail_d as (
    select X.cCusCode,SUM(X.当日现金收款) as 当日现金收款 from (
      SELECT B.CCUSVEN as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当日现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.dDate = ds.dDate 
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当日现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.dDate = ds.dDate 
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当日现金收款
      from fr_calendar T
		  inner join day_s ds on t.dDate = ds.dDate 
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  ),
  Cashdetail_d_0 as (
    select X.cCusCode,SUM(X.当日现金收款) as 当日现金收款 from (
      SELECT B.CCUSVEN as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当日现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.dDate = ds.fr_day_0 
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当日现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.dDate = ds.fr_day_0 
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当日现金收款
      from fr_calendar T
		  inner join day_s ds on t.dDate = ds.fr_day_0 
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  ),
  Cashdetail_m as (
    select X.cCusCode,SUM(X.当月现金收款) as 当月现金收款 from (
      SELECT B.CCUSVEN  as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当月现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当月现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当月现金收款
      from fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  ),
  Cashdetail_m_0 as (
    select X.cCusCode,SUM(X.当月现金收款) as 当月现金收款 from (
      SELECT B.CCUSVEN  as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当月现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当月现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当月现金收款
      from fr_calendar T
		  inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  ),
  Cashdetail_y as (
    select X.cCusCode,SUM(X.当年现金收款) as 当年现金收款 from (
      SELECT B.CCUSVEN as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当年现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当年现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当年现金收款
      from fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  ),
  Cashdetail_y_0 as (
    select X.cCusCode,SUM(X.当年现金收款) as 当年现金收款 from (
      SELECT B.CCUSVEN as cCusCode,SUM(COALESCE(CASE WHEN sbvb.iNatSum is NULL THEN B.IAMT ELSE ad.icamount END, 0)) AS 当年现金收款
			FROM fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
			LEFT JOIN AP_CLOSEBILL AS H ON t.dDate =  H.DVOUCHDATE  
      LEFT JOIN AP_CLOSEBILLS AS B on  B.IID = H.IID
			left join ar_detail ad on H.cVouchID = ad.cvouchid and ad.ccode is null AND isnull(ad.ibvid,0) <> 0
			LEFT JOIN SaleBillVouchs sbvb ON ad.ibvid = sbvb.autoid
			WHERE ISNULL(H.CDEFINE9,'') <> '押金' -- 只取非押金类的记录
				AND LEFT(H.CSSCODE,1) IN (1,2)-- 结算方式，只取现金结算和银行结算的
				-- 非现结收款单制单人为 '张超','宋现涛','李洪波'，或者现结收款单
        AND (h.cCancelNo is NULL and H.COPERATOR in ('张超','宋现涛','李洪波') or h.cCancelNo is not NULL)
				AND left(ISNULL(sbvb.cInvCode, '5'),1) = '5'-- 如果关联发票，只取存货编码以5开头的记录
				AND B.CCUSVEN not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
				AND (h.vt_id = '8055' and h.cvouchtype = 49 or h.vt_id = '8052' and h.cvouchtype = 48)
				AND H.cVouchID <> '0000000744'
        AND isnull(H.cDefine2,'N') <> 'Y' -- 20230726 增加排除统计的收款单标识
			GROUP BY B.CCUSVEN
      union ALL
      -- 20230427 增加指定为现金收款的凭证记录
      SELECT g.ccus_id as cCusCode,SUM(COALESCE(g.mc - g.md, 0)) AS 当年现金收款
      FROM fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
      left join gl_accvouch AS g on t.dDate =  g.dbill_date
      WHERE g.ccus_id not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
        and g.cDefine1 = 'Y'
      GROUP BY g.ccus_id
      union ALL
      -- 手工录入的收款信息 20230525
      select fc.customercode as cCusCode,SUM(COALESCE(fc.nmny , 0)) AS 当年现金收款
      from fr_calendar T
		  inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
      left join FR_CASH_SALESIN_ALTERLIST as fc on  t.dDate = fc.ddate
      WHERE fc.customercode not in( '010124004'-- 市场部（古）
                            , '040000717'-- 四川圆明园
                            )
      GROUP BY fc.customercode
    )X
    GROUP BY X.cCusCode
  )
	select SUM(COALESCE(cashdetails.Cash_d, 0)) as  当日现金收款, SUM(COALESCE(cashdetails.Cash_m, 0)) 现金收款月度累计, SUM(COALESCE(cashdetails.Cash_m_0, 0)) 现金收款月度同期, SUM(COALESCE(cashdetails.Cash_y, 0)) 现金收款年度累计,SUM(COALESCE(cashdetails.Cash_y_0, 0)) 现金收款年度同期
	from
		(
    SELECT t.dDate,t.fr_day, c.cCusCode, c.cCusName, d.当日现金收款 as Cash_d, d0.当日现金收款 AS Cash_d_0, m.当月现金收款 Cash_m, m0.当月现金收款 AS Cash_m_0, y.当年现金收款 Cash_y,y0.当年现金收款 AS Cash_y_0
    FROM fr_calendar t
    JOIN Customer c ON 1 = 1
    LEFT JOIN Cashdetail_d d ON c.cCusCode = d.cCusCode
    LEFT JOIN Cashdetail_d_0 d0 ON c.cCusCode = d0.cCusCode
    LEFT JOIN Cashdetail_m m ON c.cCusCode = m.cCusCode
    LEFT JOIN Cashdetail_m_0 m0 ON c.cCusCode = m0.cCusCode
    LEFT JOIN Cashdetail_y y ON c.cCusCode = y.cCusCode
    LEFT JOIN Cashdetail_y_0 y0 ON c.cCusCode = y0.cCusCode
    WHERE t.fr_day = @inputDate ) as cashdetails
	
END
