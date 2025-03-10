/* 
DATA CLEANNING
*/

-- 1. Hiểu dữ liệu
SELECT TOP 10 * FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies;
EXEC sp_help 'dbo.Sales_Analysis_OfficeSupplies';

-- 2. Xử lý dữ liệu bị thiếu

-- Tìm và xem cột có dữ liệu bị thiếu:
SELECT *
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
WHERE [Doanh Thu] IS NULL 
-- note: [Tên sản phẩm_7]; [Nhóm SP - Cấp 1]&[Tên Nhóm SP - Cấp 1] _7; [Tên Nhóm SP - Cấp 2]_7; [Tên Nhóm SP - Cấp 3]_35; [Tên Nhóm SP - Cấp 4]_14; [fg]_28; [Nhóm bán hàng]_7; [Tên Nhóm bán hàng]_7; [Số lượng]_42; [Doanh thu]_21; [Giá vốn]_28; [Chi phí]_21
-- note: đồng thời cả [số lượng]&[Doanh Thu]&[Giá vốn]&[Chi phí]_7

-- Xóa dòng có dữ liệu bị thiếu
DELETE FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
WHERE [Số lượng] IS NULL 
    AND [Doanh thu] IS NULL 
    AND [Giá vốn] IS NULL 
    AND [Chi phí] IS NULL;

-- Thay thế giá trị Null thành giá trị đúng
	-- [Tên sản phẩm] với 7 giá trị Null
	UPDATE OS
	SET OS.[Tên sản phẩm] = (
		SELECT TOP 1 OS2.[Tên sản phẩm]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Mã sản phẩm] = OS.[Mã sản phẩm]
			AND OS2.[Tên sản phẩm] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Tên sản phẩm] IS NULL;

	-- [Nhóm SP - Cấp 1],[Tên Nhóm SP - Cấp 1] với 7 giá trị Null
	UPDATE OS
	SET OS.[Nhóm SP - Cấp 1] = (
		SELECT TOP 1 OS2.[Nhóm SP - Cấp 1]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm SP - Cấp 2] = OS.[Nhóm SP - Cấp 2]
			AND OS2.[Nhóm SP - Cấp 1] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	),
	OS.[Tên Nhóm SP - Cấp 1] = (
		SELECT TOP 1 OS2.[Tên Nhóm SP - Cấp 1]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm SP - Cấp 2] = OS.[Nhóm SP - Cấp 2]
			AND OS2.[Tên Nhóm SP - Cấp 1] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Nhóm SP - Cấp 1] IS NULL OR OS.[Tên Nhóm SP - Cấp 1] IS NULL;

	-- [Tên Nhóm SP - Cấp 2] với 7 giá trị Null
	UPDATE OS
	SET OS.[Tên Nhóm SP - Cấp 2] = (
		SELECT TOP 1 OS2.[Tên Nhóm SP - Cấp 2]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm SP - Cấp 2] = OS.[Nhóm SP - Cấp 2]
			AND OS2.[Tên Nhóm SP - Cấp 2] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Tên Nhóm SP - Cấp 2] IS NULL;

	-- [Tên Nhóm SP - Cấp 3] với 35 giá trị Null
	UPDATE OS
	SET OS.[Tên Nhóm SP - Cấp 3] = (
		SELECT TOP 1 OS2.[Tên Nhóm SP - Cấp 3]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm SP - Cấp 3] = OS.[Nhóm SP - Cấp 3]
			AND OS2.[Tên Nhóm SP - Cấp 3] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Tên Nhóm SP - Cấp 3] IS NULL;

	-- [Tên Nhóm SP - Cấp 4] với 14 giá trị Null
	UPDATE OS
	SET OS.[Tên Nhóm SP - Cấp 4] = (
		SELECT TOP 1 OS2.[Tên Nhóm SP - Cấp 4]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm SP - Cấp 4] = OS.[Nhóm SP - Cấp 4]
			AND OS2.[Tên Nhóm SP - Cấp 4] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Tên Nhóm SP - Cấp 4] IS NULL;

	-- [fg] với 28 giá trị Null
	UPDATE OS
	SET OS.[fg] = (
		SELECT TOP 1 OS2.[fg]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Kênh phân phối] = OS.[Kênh phân phối]
			AND OS2.[fg] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[fg] IS NULL;
	
	-- [Nhóm bán hàng] với 7 giá trị Null
	UPDATE OS
	SET OS.[Nhóm bán hàng] = (
		SELECT TOP 1 OS2.[Nhóm bán hàng]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Vùng bán hàng] = OS.[Vùng bán hàng]
			AND OS2.[Nhóm bán hàng] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Nhóm bán hàng] IS NULL;

	-- [Tên Nhóm bán hàng] với 7 giá trị Null
	UPDATE OS
	SET OS.[Tên Nhóm bán hàng] = (
		SELECT TOP 1 OS2.[Tên Nhóm bán hàng]
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS2
		WHERE OS2.[Nhóm bán hàng] = OS.[Nhóm bán hàng]
			AND OS2.[Tên Nhóm bán hàng] IS NOT NULL
		ORDER BY OS2.[Kỳ] DESC
	)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies AS OS
	WHERE OS.[Tên Nhóm bán hàng] IS NULL;

	-- [Số lượng] với 35 giá trị Null
	WITH PricePerUnit AS (
		SELECT 
			[Mã sản phẩm],
			[Vùng bán hàng],
			[Kênh phân phối],
			AVG([Doanh thu] * 1.0 / NULLIF([Số lượng], 0)) AS Avg_Price
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		WHERE [Số lượng] IS NOT NULL
		GROUP BY [Mã sản phẩm], [Vùng bán hàng], [Kênh phân phối]
	)

	UPDATE S
	SET [Số lượng] = ROUND(S.[Doanh thu] / P.Avg_Price, 0)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies S
	JOIN PricePerUnit P 
		ON S.[Mã sản phẩm] = P.[Mã sản phẩm]
		AND S.[Vùng bán hàng] = P.[Vùng bán hàng]
		AND S.[Kênh phân phối] = P.[Kênh phân phối]
	WHERE S.[Số lượng] IS NULL;

	-- [Doanh thu] với 14 giá trị Null
	WITH PricePerUnit AS (
		SELECT 
			[Mã sản phẩm],
			[Vùng bán hàng],
			[Kênh phân phối],
			AVG([Doanh thu] * 1.0 / NULLIF([Số lượng], 0)) AS Avg_Price
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		WHERE [Doanh thu] IS NOT NULL AND [Số lượng] IS NOT NULL
		GROUP BY [Mã sản phẩm], [Vùng bán hàng], [Kênh phân phối]
	)

	UPDATE S
	SET [Doanh thu] = ROUND(S.[Số lượng] * P.Avg_Price, 0)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies S
	JOIN PricePerUnit P 
		ON S.[Mã sản phẩm] = P.[Mã sản phẩm]
		AND S.[Vùng bán hàng] = P.[Vùng bán hàng]
		AND S.[Kênh phân phối] = P.[Kênh phân phối]
	WHERE S.[Doanh thu] IS NULL;

	-- [Giá vốn] với 21 giá trị Null
	WITH CostPerUnit AS (
		SELECT 
			[Mã sản phẩm],
			[Vùng bán hàng],
			[Kênh phân phối],
			AVG([Giá vốn] * 1.0 / NULLIF([Số lượng], 0)) AS Avg_Cost
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		WHERE [Giá vốn] IS NOT NULL AND [Số lượng] IS NOT NULL
		GROUP BY [Mã sản phẩm], [Vùng bán hàng], [Kênh phân phối]
	)

	UPDATE S
	SET [Giá vốn] = ROUND(S.[Số lượng] * P.Avg_Cost, 0)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies S
	JOIN CostPerUnit P 
		ON S.[Mã sản phẩm] = P.[Mã sản phẩm]
		AND S.[Vùng bán hàng] = P.[Vùng bán hàng]
		AND S.[Kênh phân phối] = P.[Kênh phân phối]
	WHERE S.[Giá vốn] IS NULL;

	-- [Chi phí] với 14 giá trị Null
	WITH CostPerUnit AS (
		SELECT 
			[Mã sản phẩm],
			[Vùng bán hàng],
			[Kênh phân phối],
			AVG([Chi phí] * 1.0 / NULLIF([Số lượng], 0)) AS Avg_CostPerUnit
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		WHERE [Chi phí] IS NOT NULL AND [Số lượng] IS NOT NULL
		GROUP BY [Mã sản phẩm], [Vùng bán hàng], [Kênh phân phối]
	)

	UPDATE S
	SET [Chi phí] = ROUND(S.[Số lượng] * P.Avg_CostPerUnit, 0)
	FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies S
	JOIN CostPerUnit P 
		ON S.[Mã sản phẩm] = P.[Mã sản phẩm]
		AND S.[Vùng bán hàng] = P.[Vùng bán hàng]
		AND S.[Kênh phân phối] = P.[Kênh phân phối]
	WHERE S.[Chi phí] IS NULL;

-- 3. Xử lý dữ liệu trùng lặp

-- Tìm và xem dòng dữ liệu bị trùng lặp
SELECT *, COUNT(*) AS DuplicateCount
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY 
    [Kỳ], [Mã sản phẩm], [Tên sản phẩm], [Nhóm SP - Cấp 1], [Tên Nhóm SP - Cấp 1], 
    [Nhóm SP - Cấp 2], [Tên Nhóm SP - Cấp 2], [Nhóm SP - Cấp 3], [Tên Nhóm SP - Cấp 3], 
    [Nhóm SP - Cấp 4], [Tên Nhóm SP - Cấp 4], [Kênh phân phối], [fg], 
    [Nhóm bán hàng], [Tên Nhóm bán hàng], [Vùng bán hàng], [Tên Vùng bán hàng], 
    [Số lượng], [Doanh thu], [Giá vốn], [Chi phí]
HAVING COUNT(*) > 1;

-- 4. Chuẩn hóa dữ liệu

-- Xử lý khoảng trắng đầu/cuối dư thừa
SELECT *
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
WHERE 
    [Mã sản phẩm] LIKE ' %' OR [Mã sản phẩm] LIKE '% ' 
    OR [Tên sản phẩm] LIKE ' %' OR [Tên sản phẩm] LIKE '% ' 
    OR [Kênh phân phối] LIKE ' %' OR [Kênh phân phối] LIKE '% ' 
    OR [Vùng bán hàng] LIKE ' %' OR [Vùng bán hàng] LIKE '% ';

UPDATE OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
SET 
    [Mã sản phẩm] = TRIM([Mã sản phẩm]),
    [Tên sản phẩm] = TRIM([Tên sản phẩm]),
    [Kênh phân phối] = TRIM([Kênh phân phối]),
    [Vùng bán hàng] = TRIM([Vùng bán hàng]);

-- 5. Chuẩn Hóa Giá Trị Danh Mục và Mã

-- Kiểm tra dữ liệu bị lỗi chính tả
SELECT [Tên Nhóm SP - Cấp 4], COUNT(*) AS So_lan_xuat_hien
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY [Tên Nhóm SP - Cấp 4]
ORDER BY So_lan_xuat_hien DESC;

-- Kiểm tra dữ liệu có số ký tự bất thường
SELECT [Nhóm bán hàng], LEN(CAST([Nhóm bán hàng] AS VARCHAR)) AS Do_dai_ky_tu
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
ORDER BY Do_dai_ky_tu DESC;