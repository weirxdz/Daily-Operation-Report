USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetSalesData]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[GetSalesData] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售开单数据的存储过程
	-- 调用格式如下 
	-- exec GetSalesData @inputDate
	-- select * from (exec GetSalesData '2023-01-31') as a
    with day_s as (
	-- 日期
	select * from fr_calendar t where t.dDate = @inputDate
	),
	salesdetail_d as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当日销售开单
		FROM fr_calendar T
		inner join day_s ds on t.dDate = ds.dDate
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	),
	salesdetail_d_0 as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当日销售开单
		FROM fr_calendar T
		inner join day_s ds on t.fr_day = ds.fr_day_0
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	),
	salesdetail_m as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当月销售开单
		FROM fr_calendar T
		inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	),
	salesdetail_m_0 as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当月销售开单
		FROM fr_calendar T
		inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	),
	salesdetail_y as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当年销售开单
		FROM fr_calendar T
		inner join day_s ds on  t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	),
	salesdetail_y_0 as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(B.INATSUM) AS 当年销售开单
		FROM fr_calendar T
		inner join day_s ds on  t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
		LEFT  JOIN SALEBILLVOUCH H ON t.dDate =  H.DDATE 
		left join SALEBILLVOUCHS B on B.SBVID = H.SBVID
		WHERE left(B.CINVCODE,1)='5'
			AND H.CCUSCODE not in( '010124004'-- 市场部（古）
				, '040000717'--四川圆明园
				)
			AND h.cSBVCode <> '202303270002'-- 20230331 单独排除调账的一张现结发票

		GROUP BY H.CCUSCODE
	)
	SELECT t.*, c.cCusCode, c.cCusName, d.当日销售开单, d0.当日销售开单 AS 去年同日开单, m.当月销售开单, m0.当月销售开单 AS 去年同期开单, y.当年销售开单,y0.当年销售开单 AS 去年累计开单
    FROM fr_calendar t
    JOIN Customer c ON 1 = 1
    LEFT JOIN salesdetail_d d ON c.cCusCode = d.cCusCode
    LEFT JOIN salesdetail_d_0 d0 ON c.cCusCode = d0.cCusCode
    LEFT JOIN salesdetail_m m ON c.cCusCode = m.cCusCode
    LEFT JOIN salesdetail_m_0 m0 ON c.cCusCode = m0.cCusCode
    LEFT JOIN salesdetail_y y ON c.cCusCode = y.cCusCode
    LEFT JOIN salesdetail_y_0 y0 ON c.cCusCode = y0.cCusCode
    WHERE t.fr_day = @inputDate
	
END
