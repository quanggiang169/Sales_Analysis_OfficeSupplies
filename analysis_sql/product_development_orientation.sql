/*
ANALYSIS & FINDING INSIGHTS
*/

-- II. Định hướng Phát triển Sản phẩm

-- Sản phẩm nào có doanh thu cao nhất nhưng lợi nhuận ròng thấp? 
WITH AvgMargin AS (
    SELECT 
        AVG(SUM([Doanh thu] - [Giá vốn] - [Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) 
        OVER () AS Bien_Loi_Nhuan_Trung_Binh
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
)
SELECT TOP 10 
    s.[Mã sản phẩm], 
    s.[Tên sản phẩm], 
    SUM(s.[Doanh thu]) AS Tong_Doanh_Thu, 
    SUM(s.[Doanh thu] - s.[Giá vốn] - s.[Chi phí]) AS Loi_Nhuan_Rong,
    (SUM(s.[Doanh thu] - s.[Giá vốn] - s.[Chi phí]) * 100.0 / NULLIF(SUM(s.[Doanh thu]), 0)) AS Bien_Loi_Nhuan,
    a.Bien_Loi_Nhuan_Trung_Binh
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies s
CROSS JOIN AvgMargin a
GROUP BY s.[Mã sản phẩm], s.[Tên sản phẩm], a.Bien_Loi_Nhuan_Trung_Binh
HAVING (SUM(s.[Doanh thu] - s.[Giá vốn] - s.[Chi phí]) * 100.0 / NULLIF(SUM(s.[Doanh thu]), 0)) < a.Bien_Loi_Nhuan_Trung_Binh
ORDER BY Tong_Doanh_Thu DESC, Loi_Nhuan_Rong ASC;

-- Sản phẩm nào có biên lợi nhuận tốt nhất? 
SELECT TOP 10 
    [Mã sản phẩm], 
    [Tên sản phẩm], 
    SUM([Doanh thu]) AS Tong_Doanh_Thu, 
    SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS Loi_Nhuan_Rong,
    (SUM([Doanh thu] - [Giá vốn] - [Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) AS Bien_Loi_Nhuan
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY [Mã sản phẩm], [Tên sản phẩm]
ORDER BY Bien_Loi_Nhuan DESC;

-- Nhóm sản phẩm nào đang có xu hướng tăng trưởng mạnh nhất?
	-- Nhóm SP - Cấp 1
	WITH DoanhThuTheoQuy AS (
		SELECT 
			[Tên Nhóm SP - Cấp 1] AS NhomSanPham,
			DATEFROMPARTS(YEAR([Kỳ]), (DATEPART(QUARTER, [Kỳ]) - 1) * 3 + 1, 1) AS NgayQuy, 
			SUM([Doanh thu]) AS TongDoanhThu
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		GROUP BY [Tên Nhóm SP - Cấp 1], YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
	),
	TangTruong AS (
		SELECT 
			a.NhomSanPham,
			a.NgayQuy AS QuyHienTai,
			b.NgayQuy AS QuyTruoc,
			a.TongDoanhThu AS DoanhThuHienTai,
			b.TongDoanhThu AS DoanhThuTruoc,
			CASE 
				WHEN b.TongDoanhThu = 0 OR b.TongDoanhThu IS NULL THEN NULL 
				ELSE (a.TongDoanhThu - b.TongDoanhThu) / b.TongDoanhThu * 100 
			END AS TyLeTangTruong
		FROM DoanhThuTheoQuy a
		LEFT JOIN DoanhThuTheoQuy b 
			ON a.NhomSanPham = b.NhomSanPham 
			AND a.NgayQuy = DATEADD(QUARTER, 1, b.NgayQuy)
	)
	SELECT
		NhomSanPham, 
		AVG(TyLeTangTruong) AS TyLeTangTruongTB
	FROM TangTruong
	WHERE TyLeTangTruong IS NOT NULL
	GROUP BY NhomSanPham
	ORDER BY TyLeTangTruongTB DESC;

	-- Nhóm SP - Chi tiết
	WITH DoanhThuTheoQuy AS (
		SELECT 
			[Tên Nhóm SP - Cấp 1] AS NhomCap1,
			[Tên Nhóm SP - Cấp 2] AS NhomCap2,
			[Tên Nhóm SP - Cấp 3] AS NhomCap3,
			[Tên Nhóm SP - Cấp 4] AS NhomCap4,
			DATEFROMPARTS(YEAR([Kỳ]), (DATEPART(QUARTER, [Kỳ]) - 1) * 3 + 1, 1) AS NgayQuy, 
			SUM([Doanh thu]) AS TongDoanhThu
		FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
		GROUP BY 
			[Tên Nhóm SP - Cấp 1], 
			[Tên Nhóm SP - Cấp 2], 
			[Tên Nhóm SP - Cấp 3], 
			[Tên Nhóm SP - Cấp 4], 
			YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
	),
	TangTruong AS (
		SELECT 
			a.NhomCap1,
			a.NhomCap2,
			a.NhomCap3,
			a.NhomCap4,
			a.NgayQuy AS QuyHienTai,
			b.NgayQuy AS QuyTruoc,
			a.TongDoanhThu AS DoanhThuHienTai,
			b.TongDoanhThu AS DoanhThuTruoc,
			CASE 
				WHEN b.TongDoanhThu = 0 OR b.TongDoanhThu IS NULL THEN NULL 
				ELSE (a.TongDoanhThu - b.TongDoanhThu) / b.TongDoanhThu * 100 
			END AS TyLeTangTruong
		FROM DoanhThuTheoQuy a
		LEFT JOIN DoanhThuTheoQuy b 
			ON a.NhomCap1 = b.NhomCap1 
			AND a.NhomCap2 = b.NhomCap2
			AND a.NhomCap3 = b.NhomCap3
			AND a.NhomCap4 = b.NhomCap4
			AND a.NgayQuy = DATEADD(QUARTER, 1, b.NgayQuy)
	)
	SELECT TOP 10 
		NhomCap1 AS [Nhóm SP - Cấp 1],
		NhomCap2 AS [Nhóm SP - Cấp 2],
		NhomCap3 AS [Nhóm SP - Cấp 3],
		NhomCap4 AS [Nhóm SP - Cấp 4],
		AVG(TyLeTangTruong) AS TyLeTangTruongTB
	FROM TangTruong
	WHERE TyLeTangTruong IS NOT NULL
	GROUP BY NhomCap1, NhomCap2, NhomCap3, NhomCap4
	ORDER BY TyLeTangTruongTB DESC;

-- Có sản phẩm nào đang suy giảm doanh số qua các kỳ không?
WITH DoanhThuTheoKy AS (
    SELECT 
        [Mã sản phẩm] AS MaSP,
        [Tên sản phẩm] AS TenSP,
        [Tên Nhóm SP - Cấp 1] AS NhomSP,
        DATEFROMPARTS(YEAR([Kỳ]), (DATEPART(QUARTER, [Kỳ]) - 1) * 3 + 1, 1) AS Quy, 
        SUM([Doanh thu]) AS TongDoanhThu
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY [Mã sản phẩm], [Tên sản phẩm], [Tên Nhóm SP - Cấp 1],
             DATEFROMPARTS(YEAR([Kỳ]), (DATEPART(QUARTER, [Kỳ]) - 1) * 3 + 1, 1)
),
SuyGiam AS (
    SELECT 
        a.MaSP,
        a.TenSP,
        a.NhomSP,
        a.Quy AS QuyHienTai,
        b.Quy AS QuyTruoc,
        a.TongDoanhThu AS DoanhThuHienTai,
        b.TongDoanhThu AS DoanhThuTruoc,
        CASE 
            WHEN b.TongDoanhThu = 0 OR b.TongDoanhThu IS NULL THEN NULL 
            ELSE (a.TongDoanhThu - b.TongDoanhThu) / b.TongDoanhThu * 100 
        END AS TyLeGiam
    FROM DoanhThuTheoKy a
    LEFT JOIN DoanhThuTheoKy b 
        ON a.MaSP = b.MaSP 
        AND DATEADD(QUARTER, -1, a.Quy) = b.Quy
    WHERE a.TongDoanhThu < b.TongDoanhThu  
)
SELECT TOP 10
    MaSP AS [Mã sản phẩm],
    TenSP AS [Tên sản phẩm],
    NhomSP AS [Tên Nhóm SP - Cấp 1],
    COUNT(*) AS SoKyGiamLienTuc,
    AVG(TyLeGiam) AS TyLeGiamTB
FROM SuyGiam
WHERE TyLeGiam IS NOT NULL
GROUP BY MaSP, TenSP, NhomSP
HAVING COUNT(*) >= 2  
ORDER BY TyLeGiamTB ASC;

-- Sản phẩm nào có chi phí quá cao so với lợi nhuận mang lại?
WITH PhanTichChiPhi AS (
    SELECT 
        [Mã sản phẩm] AS MaSP,
        [Tên sản phẩm] AS TenSP,
        [Tên Nhóm SP - Cấp 1] AS NhomSP,
        SUM([Doanh thu]) AS TongDoanhThu,
        SUM([Giá vốn]) AS TongGiaVon,
        SUM([Chi phí]) AS TongChiPhi,
        SUM([Doanh thu]) - SUM([Giá vốn]) AS LoiNhuanGop,
        SUM([Doanh thu]) - SUM([Giá vốn]) - SUM([Chi phí]) AS LoiNhuanRong
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY [Mã sản phẩm], [Tên sản phẩm], [Tên Nhóm SP - Cấp 1]
)
SELECT TOP 10
    MaSP AS [Mã sản phẩm],
    TenSP AS [Tên sản phẩm],
    NhomSP AS [Tên Nhóm SP - Cấp 1],
    TongDoanhThu AS [Tổng doanh thu],
    TongGiaVon AS [Tổng giá vốn],
    TongChiPhi AS [Tổng chi phí],
    LoiNhuanGop AS [Lợi nhuận gộp],
    LoiNhuanRong AS [Lợi nhuận ròng],
    CASE 
        WHEN LoiNhuanRong <= 0 THEN NULL  
        ELSE (TongChiPhi / LoiNhuanRong) * 100 
    END AS TyLeChiPhi
FROM PhanTichChiPhi
WHERE (LoiNhuanRong <= 0 OR (TongChiPhi / NULLIF(LoiNhuanRong, 0)) > 0.8)
ORDER BY TyLeChiPhi DESC, LoiNhuanRong ASC;