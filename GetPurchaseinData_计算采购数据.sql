USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetPurchaseinData]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER   PROCEDURE [dbo].[GetPurchaseinData] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售现金收款数据的存储过程
	-- 调用格式如下 
	-- exec GetPurchaseinData @inputDate
  with day_s as (
    -- 日期
    select * from fr_calendar t where t.dDate = @inputDate
	),
  -- detail_d as (
  --   SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.dDate = ds.dDate 
  --   LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   group by m.DIM_PURCHASEIN
  -- ),
  -- detail_d_0 as (
  --   SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.dDate = ds.fr_day_0 
  --   LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   group by m.DIM_PURCHASEIN
  -- ),
  detail_m as (
    SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode 
    group by m.DIM_PURCHASEIN
  ),
  detail_m_0 as (
    SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
    LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode 
    group by m.DIM_PURCHASEIN
  ),
  detail_y as (
    SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode 
    group by m.DIM_PURCHASEIN
  ),
  detail_y_0 as (
    SELECT m.DIM_PURCHASEIN,SUM(COALESCE(RDS10.iPrice , 0))  as 金额
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
    LEFT JOIN RDRECORD01 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDs01 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode    
    group by m.DIM_PURCHASEIN
  )	
  SELECT X.DIM_PURCHASEIN, -- COALESCE(detail_D.金额, 0) 当日金额,
    COALESCE(detail_M.金额, 0) 月度累计金额, COALESCE(detail_M_0.金额, 0)月度同期金额,
    COALESCE(detail_y.金额,0) 年度累计金额 ,COALESCE(detail_y_0.金额, 0) 年度同期金额
  FROM (SELECT DISTINCT I.DIM_PURCHASEIN FROM Inventory I) X
  LEFT JOIN detail_y ON X.DIM_PURCHASEIN = detail_y.DIM_PURCHASEIN
  LEFT JOIN detail_y_0 ON X.DIM_PURCHASEIN = detail_y_0.DIM_PURCHASEIN
  LEFT JOIN detail_M ON X.DIM_PURCHASEIN = detail_M.DIM_PURCHASEIN
  LEFT JOIN detail_M_0 ON X.DIM_PURCHASEIN = detail_M_0.DIM_PURCHASEIN
  -- LEFT JOIN detail_D ON X.DIM_PURCHASEIN = detail_D.DIM_PURCHASEIN
  -- LEFT JOIN detail_D_0 ON X.DIM_PURCHASEIN = detail_D_0.DIM_PURCHASEIN
	
END
