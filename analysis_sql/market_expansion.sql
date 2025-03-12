/*
ANALYSIS & FINDING INSIGHTS
*/

-- IV. Phân tích Khu vực Bán hàng & Mở rộng Thị trường

-- Khu vực nào mang lại doanh thu, lợi nhuận, biên lợi nhuận cao nhất?
WITH SalesData AS (
    SELECT 
		fg AS KenhPhanPhoi,
		[Nhóm bán hàng] AS MaVungBanHang,
        [Tên Vùng bán hàng] AS VungBanHang,
        SUM([Doanh thu]) AS TongDoanhThu,
        SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS LoiNhuanRong,
        CASE 
            WHEN SUM([Doanh thu]) = 0 THEN 0 
            ELSE ROUND((SUM([Doanh thu] - [Giá vốn] - [Chi phí]) / SUM([Doanh thu])) * 100, 2) 
        END AS BienLoiNhuan
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY [Tên Vùng bán hàng], [Nhóm bán hàng], fg
)

SELECT 
	KenhPhanPhoi,
	MaVungBanHang,
    VungBanHang,
    TongDoanhThu,
    LoiNhuanRong,
    BienLoiNhuan,
    RANK() OVER (ORDER BY TongDoanhThu DESC) AS XepHangDoanhThu,
    RANK() OVER (ORDER BY LoiNhuanRong DESC) AS XepHangLoiNhuan,
    RANK() OVER (ORDER BY BienLoiNhuan DESC) AS XepHangBienLoiNhuan
FROM SalesData;

-- Xu hướng tăng trưởng doanh số của từng khu vực theo thời gian như thế nào?
WITH SalesByRegion AS (
    -- Tính tổng doanh thu theo từng khu vực và từng quý
    SELECT 
        [Tên Vùng bán hàng], 
        CONCAT(YEAR([Kỳ]), ' Q', DATEPART(QUARTER, [Kỳ])) AS [Quý], 
        SUM([Doanh thu]) AS [Tổng Doanh Thu]
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY [Tên Vùng bán hàng], YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
),
RankedSales AS (
    -- Gán số thứ tự theo thời gian cho từng vùng bán hàng
    SELECT 
        [Tên Vùng bán hàng], 
        [Quý], 
        [Tổng Doanh Thu],
        ROW_NUMBER() OVER (PARTITION BY [Tên Vùng bán hàng] ORDER BY [Quý]) AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY [Tên Vùng bán hàng] ORDER BY [Quý] DESC) AS rn_desc
    FROM SalesByRegion
),
FirstLastSales AS (
    -- Lấy doanh thu của quý đầu tiên và quý mới nhất
    SELECT 
        f.[Tên Vùng bán hàng],
        f.[Tổng Doanh Thu] AS [Doanh Thu Quý Đầu],
        l.[Tổng Doanh Thu] AS [Doanh Thu Quý Mới Nhất]
    FROM RankedSales f
    JOIN RankedSales l ON f.[Tên Vùng bán hàng] = l.[Tên Vùng bán hàng]
    WHERE f.rn_asc = 1 AND l.rn_desc = 1
)
SELECT 
    [Tên Vùng bán hàng], 
    [Doanh Thu Quý Đầu], 
    [Doanh Thu Quý Mới Nhất], 
    ([Doanh Thu Quý Mới Nhất] - [Doanh Thu Quý Đầu]) AS [Tăng Trưởng Tuyệt Đối],
    CASE 
        WHEN [Doanh Thu Quý Đầu] > 0 THEN 
            ([Doanh Thu Quý Mới Nhất] - [Doanh Thu Quý Đầu]) * 100.0 / [Doanh Thu Quý Đầu] 
        ELSE NULL 
    END AS [Tăng Trưởng Tỷ Lệ (%)],
    CASE 
        WHEN [Doanh Thu Quý Mới Nhất] > [Doanh Thu Quý Đầu] THEN 'Tăng'
        WHEN [Doanh Thu Quý Mới Nhất] < [Doanh Thu Quý Đầu] THEN 'Giảm'
        ELSE 'Không đổi'
    END AS [Xu Hướng]
FROM FirstLastSales
ORDER BY [Tăng Trưởng Tỷ Lệ (%)] DESC;
