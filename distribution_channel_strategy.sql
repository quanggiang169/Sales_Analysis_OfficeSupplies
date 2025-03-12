/*
ANALYSIS & FINDING INSIGHTS
*/

-- III. Chiến lược Kênh Phân Phối

-- Kênh phân phối nào (General Trade vs. Traditional Trade) đang hoạt động hiệu quả hơn xét theo doanh thu và lợi nhuận?
SELECT 
    fg AS [Kênh phân phối], 
    SUM([Doanh thu]) AS [Tổng doanh thu], 
    SUM([Doanh thu] - [Giá vốn]) AS [Lợi nhuận gộp], 
    SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS [Lợi nhuận ròng],
    (SUM([Doanh thu] - [Giá vốn]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) AS [Biên lợi nhuận gộp (%)],
    (SUM([Doanh thu] - [Giá vốn] - [Chi phí]) * 100.0 / NULLIF(SUM([Doanh thu]), 0)) AS [Biên lợi nhuận ròng (%)]
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY fg
ORDER BY [Lợi nhuận ròng] DESC;

-- Chi phí trung bình trên mỗi sản phẩm giữa các kênh có chênh lệch đáng kể không?
SELECT 
    fg AS [Kênh phân phối], 
    SUM([Chi phí]) / NULLIF(SUM([Số lượng]), 0) AS [Chi phí trung bình trên mỗi sản phẩm]
FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
GROUP BY fg
ORDER BY [Chi phí trung bình trên mỗi sản phẩm] DESC;

-- Kênh nào có xu hướng tăng trưởng mạnh nhất trong thời gian qua?
WITH DoanhThuLoiNhuanTheoKy AS (
    SELECT 
        fg AS [Kênh phân phối], 
        YEAR(TRY_CONVERT(DATE, [Kỳ], 112)) AS [Năm],
        DATEPART(QUARTER, TRY_CONVERT(DATE, [Kỳ], 112)) AS [Quý], 
        SUM([Doanh thu]) AS [Tổng doanh thu],
        SUM([Doanh thu] - [Giá vốn] - [Chi phí]) AS [Tổng lợi nhuận]
    FROM OfficeSupplies.dbo.Sales_Analysis_OfficeSupplies
    WHERE ISDATE([Kỳ]) = 1 
    GROUP BY fg, YEAR(TRY_CONVERT(DATE, [Kỳ], 112)), DATEPART(QUARTER, TRY_CONVERT(DATE, [Kỳ], 112))
),
TangTruong AS (
    SELECT 
        a.[Kênh phân phối], 
        CONCAT(a.[Năm], '-Q', a.[Quý]) AS [Quý hiện tại], 
        a.[Tổng doanh thu] AS [Doanh thu hiện tại],
        COALESCE(b.[Tổng doanh thu], 0) AS [Doanh thu quý trước],  
        a.[Tổng lợi nhuận] AS [Lợi nhuận hiện tại],
        COALESCE(b.[Tổng lợi nhuận], 0) AS [Lợi nhuận quý trước],  
        CASE 
            WHEN b.[Tổng doanh thu] IS NULL OR b.[Tổng doanh thu] = 0 THEN NULL
            ELSE (a.[Tổng doanh thu] - b.[Tổng doanh thu]) / NULLIF(b.[Tổng doanh thu], 0) * 100
        END AS [Tăng trưởng doanh thu (%)],
        CASE 
            WHEN b.[Tổng lợi nhuận] IS NULL OR b.[Tổng lợi nhuận] = 0 THEN NULL
            ELSE (a.[Tổng lợi nhuận] - b.[Tổng lợi nhuận]) / NULLIF(b.[Tổng lợi nhuận], 0) * 100
        END AS [Tăng trưởng lợi nhuận (%)]
    FROM DoanhThuLoiNhuanTheoKy a
    LEFT JOIN DoanhThuLoiNhuanTheoKy b 
        ON a.[Kênh phân phối] = b.[Kênh phân phối] 
        AND (
            (a.[Quý] = 2 AND b.[Quý] = 1 AND a.[Năm] = b.[Năm]) OR
            (a.[Quý] = 3 AND b.[Quý] = 2 AND a.[Năm] = b.[Năm]) OR
            (a.[Quý] = 4 AND b.[Quý] = 3 AND a.[Năm] = b.[Năm]) OR
            (a.[Quý] = 1 AND b.[Quý] = 4 AND a.[Năm] = b.[Năm] + 1)  -- Chuyển sang năm trước
        )
)
SELECT 
    [Kênh phân phối], 
    AVG([Tăng trưởng doanh thu (%)]) AS [Tỷ lệ tăng trưởng doanh thu trung bình (%)],
    AVG([Tăng trưởng lợi nhuận (%)]) AS [Tỷ lệ tăng trưởng lợi nhuận trung bình (%)]
FROM TangTruong
WHERE [Tăng trưởng doanh thu (%)] IS NOT NULL OR [Tăng trưởng lợi nhuận (%)] IS NOT NULL
GROUP BY [Kênh phân phối]
ORDER BY [Tỷ lệ tăng trưởng doanh thu trung bình (%)] DESC, 
         [Tỷ lệ tăng trưởng lợi nhuận trung bình (%)] DESC;



