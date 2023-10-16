USE [UFDATA_888_2022]
GO
/****** Object:  StoredProcedure [dbo].[GetProductData]    Script Date: 2023-10-09 23:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER   PROCEDURE [dbo].[GetProductData] @inputDate DATE
AS
BEGIN
	-- 计算每天的销售现金收款数据的存储过程
	-- 调用格式如下 
	-- exec GetProductData @inputDate
  with day_s as (
    -- 日期
    select * from fr_calendar t where t.dDate = @inputDate
	),
  detail_d as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.dDate = ds.dDate 
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    WHERE 1=1-- RD10.CSOURCE = '生产订单' 
    -- AND LEFT(CONVERT(NVARCHAR, RD10.cdefine4,120),10) >= LEFT(CONVERT(NVARCHAR, @DBDATE,120),10) AND LEFT(CONVERT(NVARCHAR, RD10.cdefine4,120),10) <= LEFT(CONVERT(NVARCHAR, @DEDATE,120),10)
    -- AND WH1.CWHNAME = '原酒库'
    -- AND RDS10.cdefine23 is not NULL
    -- AND bzjh2.[入池窖池号] IS NOT NULL
    group by m.DIM_PRODUCT
  ),
  detail_d_0 as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.dDate = ds.fr_day_0 
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    group by m.DIM_PRODUCT
  ),
  detail_m as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Month = ds.fr_Month and t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    group by m.DIM_PRODUCT
  ),
  detail_m_0 as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Month = ds.fr_Month_0 and t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    group by m.DIM_PRODUCT
  ),
  detail_y as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Year = ds.fr_Year and t.fr_day <= ds.fr_day
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    group by m.DIM_PRODUCT
  ),
  detail_y_0 as (
    SELECT m.DIM_PRODUCT,SUM(COALESCE(RDS10.IQUANTITY, 0))  as 数量
    FROM  fr_calendar T
    inner join day_s ds on t.fr_Year = ds.fr_Year_0 and t.fr_day <= ds.fr_day_0
    LEFT JOIN RDRECORD10 AS RD10 ON t.dDate =  RD10.dDate 
    inner join RDRECORDS10 AS RDS10 ON RDS10.ID = RD10.ID
    inner join Inventory m on RDS10.CINVCODE = m.cInvCode
    group by m.DIM_PRODUCT
  )	
  SELECT X.DIM_PRODUCT, COALESCE(detail_D.数量, 0) 当日产量,COALESCE(detail_M.数量, 0) 月度累计产量,COALESCE(detail_M_0.数量, 0)月度同期产量,COALESCE(detail_y.数量,0) 年度累计产量,COALESCE(detail_y_0.数量, 0) 年度同期产量
  FROM (SELECT DISTINCT I.DIM_PRODUCT FROM Inventory I) X
  LEFT JOIN detail_y ON X.DIM_PRODUCT = detail_y.DIM_PRODUCT
  LEFT JOIN detail_y_0 ON X.DIM_PRODUCT = detail_y_0.DIM_PRODUCT
  LEFT JOIN detail_M ON X.DIM_PRODUCT = detail_M.DIM_PRODUCT
  LEFT JOIN detail_M_0 ON X.DIM_PRODUCT = detail_M_0.DIM_PRODUCT
  LEFT JOIN detail_D ON X.DIM_PRODUCT = detail_D.DIM_PRODUCT
  LEFT JOIN detail_D_0 ON X.DIM_PRODUCT = detail_D_0.DIM_PRODUCT
  where X.DIM_PRODUCT <> '其他'
	
END
