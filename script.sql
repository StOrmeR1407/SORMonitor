USE [SORMonitor]
GO
/****** Object:  Table [dbo].[App]    Script Date: 5/26/2024 5:07:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[App](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](500) NOT NULL,
	[id_type] [int] NOT NULL,
 CONSTRAINT [PK_App] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DescriptionType]    Script Date: 5/26/2024 5:07:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescriptionType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_type] [int] NULL,
	[description] [nvarchar](500) NULL,
 CONSTRAINT [PK_DescriptionType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[History]    Script Date: 5/26/2024 5:07:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[History](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_app] [int] NULL,
	[time] [datetime] NULL,
 CONSTRAINT [PK_History] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Type_Of_App]    Script Date: 5/26/2024 5:07:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Type_Of_App](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
 CONSTRAINT [PK_Type_Of_App] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[App]  WITH CHECK ADD  CONSTRAINT [FK_App_Type_Of_App] FOREIGN KEY([id_type])
REFERENCES [dbo].[Type_Of_App] ([id])
GO
ALTER TABLE [dbo].[App] CHECK CONSTRAINT [FK_App_Type_Of_App]
GO
ALTER TABLE [dbo].[DescriptionType]  WITH CHECK ADD  CONSTRAINT [FK_DescriptionType_Type_Of_App] FOREIGN KEY([id_type])
REFERENCES [dbo].[Type_Of_App] ([id])
GO
ALTER TABLE [dbo].[DescriptionType] CHECK CONSTRAINT [FK_DescriptionType_Type_Of_App]
GO
ALTER TABLE [dbo].[History]  WITH CHECK ADD  CONSTRAINT [FK_History_App] FOREIGN KEY([id_app])
REFERENCES [dbo].[App] ([id])
GO
ALTER TABLE [dbo].[History] CHECK CONSTRAINT [FK_History_App]
GO
/****** Object:  StoredProcedure [dbo].[SP_SORMonitor]    Script Date: 5/26/2024 5:07:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thái Học
-- Create date: 17-05-2024
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SORMonitor]
@action nvarchar(50),
@name nvarchar(500) = null,
@time datetime = null

AS
BEGIN
	declare @json nvarchar(max) = ''
	declare @monday date
	declare @sunday date
	if(@action = 'getinfo')
	begin
		declare @temp_id int
		if exists (select * from App where [name] like '%' + @name + '%' and LEN([name]) >= 0.9 * LEN(@name))
		begin
			select @temp_id = id from App where [name] = @name
			insert into History (id_app, [time])
			values (@temp_id, @time)
			-- Đúng ra đoạn này sẽ truyền tham số @time vào, nhưng vì lỗi múi giờ nên mình sẽ để hàm getdate()
			-- Các bạn nếu tham khảo có thể thay bằng getdate() bằng @time
		end
		else
		begin
			DECLARE @id_type INT;
			SELECT @id_type = id_type
			FROM DescriptionType
			WHERE @name LIKE '%' + [description] + '%';

			IF @id_type IS NULL
				SET @id_type = 4;

			INSERT INTO App ([name], id_type)
			VALUES (@name, @id_type);

			select @temp_id = id from App where [name] = @name

			INSERT INTO History (id_app, [time])
			VALUES (@temp_id, @time);

			-- Đúng ra đoạn này sẽ truyền tham số @time vào, nhưng vì lỗi múi giờ nên mình sẽ để hàm getdate()
			-- Các bạn nếu tham khảo có thể thay bằng getdate() bằng @time
		end
		set @json = FORMATMESSAGE('{"ok":true,"msg": "Thành công"}') 
		select @json as json
	end
	else if(@action = 'piechart')
	begin
		set @monday = DATEADD(DAY, - datediff(day,0, @time) % 7, @time)
		set @sunday = DATEADD(DAY, 6 - datediff(day,0, @time) % 7, @time)
		select @json += FORMATMESSAGE(N'{"name": "%s", "time": %d},', t.[name], ROUND(COUNT(*) / 60, 0))
		FROM History h
		JOIN App a ON h.id_app = a.id
		JOIN Type_Of_App t ON a.id_type = t.id
		WHERE h.time BETWEEN @monday AND @sunday
		GROUP BY t.name;
		if((@json is null)or(@json=''))
			select N'{"ok":false,"msg":"không có dữ liệu","datas":[]}' as json;
		else
		begin
			select @json=REPLACE(@json,'(null)','null')
			select N'{"ok":true,"msg":"ok","datas":['+left(@json,len(@json)-1)+']}' as json;
		end
	end
	else if(@action = 'linechart_top5')
	begin
		set @monday = DATEADD(DAY, - datediff(day,0, @time) % 7, @time)
		set @sunday = DATEADD(DAY, 6 - datediff(day,0, @time) % 7, @time)
		select top 5 @json += FORMATMESSAGE(N'{"id": %d, "name": "%s", "time": %d},',h.id_app, a.[name], ROUND(COUNT(*) / 60, 0))
		FROM History h
		JOIN App a ON h.id_app = a.id
		WHERE h.time BETWEEN @monday AND @sunday
		GROUP BY h.id_app, a.name order by COUNT(*) desc;
		if((@json is null)or(@json=''))
			select N'{"ok":false,"msg":"không có dữ liệu","datas":[]}' as json;
		else
		begin
			select @json=REPLACE(@json,'(null)','null')
			select N'{"ok":true,"msg":"ok","datas":['+left(@json,len(@json)-1)+']}' as json;
		end
	end
	else if (@action = 'linechart_usedtime')
	begin
		set @monday = DATEADD(DAY, - datediff(day,0, @time) % 7, @time)
		set @sunday = DATEADD(DAY, 6 - datediff(day,0, @time) % 7, @time)
		select @json += FORMATMESSAGE(N'{"name": "%s", "time": %d},', CAST(CAST(h.time AS DATE) AS varchar), ROUND(COUNT(*) / 60, 0))
		FROM History h
		WHERE h.time BETWEEN @monday AND @sunday
		GROUP BY CAST(h.time AS DATE)
		ORDER BY CONVERT(DATE, h.time) ASC;
		if((@json is null)or(@json=''))
			select N'{"ok":false,"msg":"không có dữ liệu","datas":[]}' as json;
		else
		begin
			select @json=REPLACE(@json,'(null)','null')
			select N'{"ok":true,"msg":"ok","datas":['+left(@json,len(@json)-1)+']}' as json;
		end
	end
END
GO
