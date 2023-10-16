USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetSalesData]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER   PROCEDURE [dbo].[GetSalesData] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售开单数据的存储过程
	-- 调用格式如下 
	-- exec GetSalesData @inputDate
    with day_s as (
	-- 日期
	select * from fr_calendar t where t.dDate = @inputDate
	),
	salesdetail_d as (
		-- 销售开单数据
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当日销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当日销售数量
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
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当日销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当日销售数量
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
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当月销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当月销售数量
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
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当月销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当月销售数量
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
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当年销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当年销售数量
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
		SELECT H.CCUSCODE,SUM(COALESCE(B.INATSUM, 0)) AS 当年销售开单,SUM(COALESCE(b.iQuantity, 0)) AS 当年销售数量
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
	select /*dDate,fr_day, cCusCode, cCusName,*/ SUM(COALESCE(kdsj.sales_d, 0)) as  当日开单, SUM(COALESCE(kdsj.sales_m, 0)) 开单月度累计, SUM(COALESCE(kdsj.sales_m_0, 0)) 开单月度同期, SUM(COALESCE(kdsj.sales_y, 0)) 开单年度累计,SUM(COALESCE(kdsj.sales_y_0, 0)) 开单年度同期,
	SUM(COALESCE(kdsj.nnum_d, 0)) as  当日数量, SUM(COALESCE(kdsj.nnum_m, 0)) 数量月度累计, SUM(COALESCE(kdsj.nnum_m_0, 0)) 数量月度同期, SUM(COALESCE(kdsj.nnum_y, 0)) 数量年度累计,SUM(COALESCE(kdsj.nnum_y_0, 0)) 数量年度同期
	from
		(SELECT t.dDate,t.fr_day, c.cCusCode, c.cCusName, d.当日销售开单 as sales_d, d0.当日销售开单 AS sales_d_0, m.当月销售开单 sales_m, m0.当月销售开单 AS sales_m_0, y.当年销售开单 sales_y,y0.当年销售开单 AS sales_y_0
		, d.当日销售数量 as nnum_d, d0.当日销售数量 AS nnum_d_0, m.当月销售数量 nnum_m, m0.当月销售数量 AS nnum_m_0, y.当年销售数量 nnum_y,y0.当年销售数量 AS nnum_y_0
    FROM fr_calendar t
    JOIN Customer c ON 1 = 1
    LEFT JOIN salesdetail_d d ON c.cCusCode = d.cCusCode
    LEFT JOIN salesdetail_d_0 d0 ON c.cCusCode = d0.cCusCode
    LEFT JOIN salesdetail_m m ON c.cCusCode = m.cCusCode
    LEFT JOIN salesdetail_m_0 m0 ON c.cCusCode = m0.cCusCode
    LEFT JOIN salesdetail_y y ON c.cCusCode = y.cCusCode
    LEFT JOIN salesdetail_y_0 y0 ON c.cCusCode = y0.cCusCode
    WHERE t.fr_day = @inputDate ) as kdsj
	-- -- 使用游标遍历结果集
	-- -- to do 没有写完，明天继续
	-- -- 声明变量，用于存储结果集的行数和当前处理的行数
  -- DECLARE @RowCount INT, @CurrentRow INT;
	-- DECLARE @dDate,@fr_day, @cCusCode, @cCusName, @sales_d, @sales_d_0, @sales_m, @sales_m_0, @sales_y,@sales_y_0 
	-- -- 声明游标，用于遍历结果集
	-- DECLARE TestDataCursor CURSOR FOR
  --       SELECT dDate,fr_day, cCusCode, cCusName, sales_d, sales_d_0, sales_m, sales_m_0, sales_y,sales_y_0  FROM kdsj;
	-- -- 打开游标
	-- OPEN TestDataCursor;
	-- -- 获取结果集的行数和初始处理行数
  -- FETCH NEXT FROM TestDataCursor INTO @CurrentRow, @RowCount;
	-- -- 遍历结果集的每一行
	-- -- 获取下一行数据，并更新当前处理行数
	-- -- 关闭游标并释放资源
	-- CLOSE TestDataCursor;
	-- DEALLOCATE TestDataCursor;
	
END
