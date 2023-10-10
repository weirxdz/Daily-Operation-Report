USE [UFDATA_888_2022]
GO

/****** Object:  StoredProcedure [dbo].[WriteCalendar2fr_calendar]    Script Date: 2023-10-08 12:54:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[WriteCalendar2fr_calendar]
    @StartDate DATE,
    @EndDate DATE
AS
  -- 生成日历的存储过程，把@StartDate到@EndDate之间的日期写入fr_calendar表，转换成合适的日期和期间使用，目标表fr_calendar，表名以参数的形式传入@CalendarTable；@StartDate、@EndDate 为开始日期和结束日期
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE;
    declare @fr_day VARCHAR(10);
    declare @fr_Month int;
		declare @fr_Year int;
    declare @fr_day_0 VARCHAR(10);
    declare @fr_Month_0 int;
		declare @fr_Year_0 int;
    declare @iperiod int;
		declare @iday int;
    
    SET @CurrentDate = @StartDate;

    -- 逐天生成日历数据并写入临时表
    WHILE @CurrentDate <= @EndDate
      BEGIN
          set @fr_day = CONVERT(varchar(100),@CurrentDate, 23);
          SET @fr_day_0 = CONVERT(varchar(100), DATEADD(year, -1, @CurrentDate), 23);        
          set @iperiod = month( @CurrentDate )
          set @iday = DAY( @CurrentDate )
          if @iperiod = 11  and @iday >25
            begin
              set @fr_Month = (month( @CurrentDate ) + 1)%12;
              set @fr_Year = year( @CurrentDate ) + 1;
              set @fr_Month_0 = (month( @CurrentDate ) + 1)%12;
              set @fr_Year_0 = year( @CurrentDate ) ;
            end
          else if @iperiod = 12
            begin
              set @fr_Month = (month( @CurrentDate ) )%12;
              set @fr_Year = year( @CurrentDate ) + 1;
              set @fr_Month_0 = (month( @CurrentDate ) )%12;
              set @fr_Year_0 = year( @CurrentDate ) ;
            end
          else if @iperiod = 1 and @iday <= 25
            begin
              set @fr_Month = (month( @CurrentDate ) )%12;
              set @fr_Year = year( @CurrentDate ) ;
              set @fr_Month_0 = (month( @CurrentDate ) )%12;
              set @fr_Year_0 = year( @CurrentDate ) -1;
            end
          else if @iperiod >= 1 and @iperiod <= 11
            begin
              if @iday <= 25 and @iperiod <> 1
                begin
                  set @fr_Month = (month( @CurrentDate ) )%12;
                  set @fr_Year = year( @CurrentDate ) ;
                  set @fr_Month_0 = (month( @CurrentDate ) )%12;
                  set @fr_Year_0 = year( @CurrentDate ) -1;
                end
              else if @iday >25 and @iperiod <> 11
                begin
                  set @fr_Month = (month( @CurrentDate ) )%12 + 1;
                  set @fr_Year = year( @CurrentDate ) ;
                  set @fr_Month_0 = (month( @CurrentDate ) )%12 + 1;
                  set @fr_Year_0 = year( @CurrentDate ) -1;
                end
            end
          IF NOT EXISTS (SELECT * FROM fr_calendar WHERE dDate = @CurrentDate )
            BEGIN
              INSERT INTO fr_calendar (dDate ,fr_day,fr_Month,fr_Year ,fr_day_0,fr_Month_0,fr_Year_0 ) values(@CurrentDate ,@fr_day,@fr_Month,@fr_Year ,@fr_day_0,@fr_Month_0,@fr_Year_0);
            END
          ELSE 
            BEGIN
              update fr_calendar set fr_day = @fr_day,fr_Month = @fr_Month,fr_Year = @fr_Year,fr_day_0 = @fr_day_0,fr_Month_0 = @fr_Month_0,fr_Year_0 = @fr_Year_0 where dDate = @CurrentDate;
            END
          SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
      END
END;
GO


