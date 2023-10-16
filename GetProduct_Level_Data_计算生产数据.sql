USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetProduct_Level_Data]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER   PROCEDURE [dbo].[GetProduct_Level_Data] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售现金收款数据的存储过程
	-- 调用格式如下 
	-- exec GetProduct_Level_Data @inputDate
  with day_s as (
    -- 日期
    select * from fr_calendar t where t.dDate = @inputDate
	),
  -- detail_d as (
  --   SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.dDate = ds.dDate 
  --   LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   where m.DIM_LEVELS <> '其他'
  --   group by m.DIM_LEVELS
  -- ),
  -- detail_d_0 as (
  --   SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.dDate = ds.fr_day_0 
  --   LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   where m.DIM_LEVELS <> '其他'
  --   group by m.DIM_LEVELS
  -- ),
  detail_m as (
    SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    where m.DIM_LEVELS <> '其他'
    group by m.DIM_LEVELS
  ),
  -- detail_m_0 as (
  --   SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
  --   LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   where m.DIM_LEVELS <> '其他'
  --   group by m.DIM_LEVELS
  -- ),
  detail_y as (
    SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    where m.DIM_LEVELS <> '其他'
    group by m.DIM_LEVELS
  )-- ,
  -- detail_y_0 as (
  --   SELECT m.DIM_LEVELS,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
  --   FROM  fr_calendar T
  --   inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
  --   LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
  --   inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
  --   inner join Inventory m on RDS10.CINVCODE = m.cInvCode
  --   where m.DIM_LEVELS <> '其他'
  --   group by m.DIM_LEVELS
  -- )	
  SELECT X.DIM_LEVELS, -- COALESCE(detail_D.数量, 0) 当日产量,
    COALESCE(detail_M.数量, 0) 月度累计产量,-- COALESCE(detail_M_0.数量, 0)月度同期产量,
    COALESCE(detail_y.数量,0) 年度累计产量-- ,COALESCE(detail_y_0.数量, 0) 年度同期产量
  FROM (SELECT DISTINCT I.DIM_LEVELS FROM Inventory I) X
  LEFT JOIN detail_y ON X.DIM_LEVELS = detail_y.DIM_LEVELS
  -- LEFT JOIN detail_y_0 ON X.DIM_LEVELS = detail_y_0.DIM_LEVELS
  LEFT JOIN detail_M ON X.DIM_LEVELS = detail_M.DIM_LEVELS
  -- LEFT JOIN detail_M_0 ON X.DIM_LEVELS = detail_M_0.DIM_LEVELS
  -- LEFT JOIN detail_D ON X.DIM_LEVELS = detail_D.DIM_LEVELS
  -- LEFT JOIN detail_D_0 ON X.DIM_LEVELS = detail_D_0.DIM_LEVELS
  where X.DIM_LEVELS <> '其他'
	
END
