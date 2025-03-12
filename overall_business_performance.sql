/*
ANALYSIS & FINDING INSIGHTS
*/

-- I. Đánh giá hiệu quả kinh doanh tổng thể

-- Tổng doanh thu, tổng lợi nhuận gộp và tổng lợi nhuận ròng của công ty trong từng kỳ
SELECT 
    CONCAT('Q', DATEPART(QUARTER, [Kỳ]), '-', YEAR([Kỳ])) AS Quy,
    SUM([Doanh thu]) AS Tong_Doanh_Thu,
    SUM([Doanh thu] - [Giá vốn]) AS Tong_Loi_Nhuan_Gop,
    SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS Tong_Loi_Nhuan_Rong
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
ORDER BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ]);

-- Biến động của doanh thu và lợi nhuận qua các quý cùng kỳ năm trước
WITH RevenueGrowth AS (
    SELECT 
        CONCAT('Q', DATEPART(QUARTER, [Kỳ]), '-', YEAR([Kỳ])) AS Quy,
        SUM([Doanh thu]) AS Doanh_Thu,
        SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS Loi_Nhuan_Rong,
        LAG(SUM([Doanh thu]), 4) OVER (ORDER BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])) AS Doanh_Thu_Truoc,
        LAG(SUM([Doanh thu] - [Giá vốn] - [Chi phí]), 4) OVER (ORDER BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])) AS Loi_Nhuan_Truoc
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
)
SELECT 
    Quy,
    Doanh_Thu,
    Loi_Nhuan_Rong,
    CASE 
        WHEN Doanh_Thu_Truoc IS NULL THEN NULL 
        ELSE (Doanh_Thu - Doanh_Thu_Truoc) / NULLIF(Doanh_Thu_Truoc, 0) * 100 
    END AS Ty_Le_Tang_Doanh_Thu,
    CASE 
        WHEN Loi_Nhuan_Truoc IS NULL THEN NULL 
        ELSE (Loi_Nhuan_Rong - Loi_Nhuan_Truoc) / NULLIF(Loi_Nhuan_Truoc, 0) * 100 
    END AS Ty_Le_Tang_Loi_Nhuan
FROM RevenueGrowth
ORDER BY Quy;

-- Biên lợi nhuận có ổn định không? Có giai đoạn nào bị giảm mạnh không?
WITH ProfitMargin AS (
    SELECT 
        YEAR([Kỳ]) AS Nam,
        DATEPART(QUARTER, [Kỳ]) AS QuySo,
        CONCAT('Q', DATEPART(QUARTER, [Kỳ]), '-', YEAR([Kỳ])) AS Quy,
        SUM([Doanh thu]) AS Doanh_Thu,
        SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS Loi_Nhuan_Rong,
        SUM([Doanh thu] - [Giá vốn] - [Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0) AS Bien_Loi_Nhuan,
        LAG(SUM([Doanh thu] - [Giá vốn] - [Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) 
        OVER (ORDER BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])) AS Bien_Loi_Nhuan_Truoc
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
)
SELECT 
    Quy,
    Doanh_Thu,
    Loi_Nhuan_Rong,
    Bien_Loi_Nhuan,
    Bien_Loi_Nhuan - Bien_Loi_Nhuan_Truoc AS Bien_Loi_Nhuan_Thay_Doi
FROM ProfitMargin
ORDER BY Nam, QuySo;

-- Tỷ lệ chi phí so với doanh thu có xu hướng tăng hay giảm?
WITH CostTrend AS (
    SELECT 
        YEAR([Kỳ]) AS Nam,
        DATEPART(QUARTER, [Kỳ]) AS QuySo,
        CONCAT('Q', DATEPART(QUARTER, [Kỳ]), '-', YEAR([Kỳ])) AS Quy,
        SUM([Doanh thu]) AS Doanh_Thu,
        SUM([Chi phí]) AS Tong_Chi_Phi,
        SUM([Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0) AS Ty_Le_Chi_Phi,
        LAG(SUM([Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) 
        OVER (ORDER BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])) AS Ty_Le_Chi_Phi_Truoc
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    GROUP BY YEAR([Kỳ]), DATEPART(QUARTER, [Kỳ])
)
SELECT 
    Quy,
    Doanh_Thu,
    Tong_Chi_Phi,
    Ty_Le_Chi_Phi,
    Ty_Le_Chi_Phi - Ty_Le_Chi_Phi_Truoc AS Bien_Dong_Chi_Phi
FROM CostTrend
ORDER BY Nam, QuySo;