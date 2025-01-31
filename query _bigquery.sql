CREATE OR REPLACE TABLE `rakamin-kf-analytics-448814.kimia_farma.kf_dasboard 1` AS
WITH transaksi_cte AS (
    SELECT 
        t.transaction_id,
        t.product_id, 
        t.branch_id,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,  -- Menghitung jumlah transaksi per cabang
        t.price AS actual_price,  -- Menggunakan price sebagai actual_price
        t.price * (1 - (t.discount_percentage / 100)) AS nett_sales,  -- Nett Sales setelah diskon
        -- Menghitung persentase laba berdasarkan harga
        CASE 
            WHEN t.price <= 50000 THEN 0.10
            WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15
            WHEN t.price > 100000 AND t.price <= 300000 THEN 0.20
            WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25
            ELSE 0.30
        END AS persentase_gross_laba,
        -- Menghitung nett_profit berdasarkan persentase gross laba dan harga
        (t.price * (1 - (t.discount_percentage / 100)) * 
            CASE 
                WHEN t.price <= 50000 THEN 0.10
                WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15
                WHEN t.price > 100000 AND t.price <= 300000 THEN 0.20
                WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25
                ELSE 0.30
            END) AS nett_profit,
        t.date,   -- Pastikan nama kolomnya sesuai
        t.customer_name,
        t.discount_percentage,  -- Menambahkan diskon ke CTE
        EXTRACT(YEAR FROM t.date) AS transaction_year  -- Mengambil tahun dari tanggal transaksi
    FROM `rakamin-kf-analytics-448814.kimia_farma.kf_final_transaction` t
    WHERE EXTRACT(YEAR FROM t.date) BETWEEN 2020 AND 2023  -- Memfilter transaksi antara tahun 2020-2023
    GROUP BY t.branch_id, t.product_id, t.transaction_id, t.price, t.discount_percentage, t.date, t.customer_name
)
SELECT 
    t.transaction_id,  -- ID transaksi
    t.date,  -- Tanggal transaksi
    t.transaction_year,  -- Tahun transaksi
    t.branch_id,  -- ID cabang
    c.branch_name,  -- Nama cabang
    c.kota,  -- Kota cabang
    c.provinsi,  -- Provinsi cabang
    c.rating AS rating_transaction,  -- Rating cabang
    t.product_id,  -- ID produk
    p.product_name,  -- Nama produk
    t.actual_price,  -- Harga obat
    t.discount_percentage,  -- Persentase diskon
    t.persentase_gross_laba * 100 AS persentase_gross_laba_pct,  -- Persentase gross laba
    t.nett_sales,  -- Nett sales setelah diskon
    t.nett_profit,  -- Nett profit
    t.total_transactions,  -- Jumlah transaksi per cabang
    -- Menambahkan total profit dan total sales per tahun 2020-2023
    SUM(t.nett_profit) OVER (PARTITION BY t.branch_id, t.product_id) AS total_profit,  -- Total profit per cabang dan produk
    SUM(t.nett_sales) OVER (PARTITION BY t.branch_id, t.product_id) AS total_sales  -- Total sales per cabang dan produk
FROM transaksi_cte t
JOIN `rakamin-kf-analytics-448814.kimia_farma.kf_kantor_cabang` c
    ON t.branch_id = c.branch_id  -- Menggabungkan dengan tabel cabang
JOIN `rakamin-kf-analytics-448814.kimia_farma.kf_product` p
    ON t.product_id = p.product_id  -- Menggabungkan dengan tabel produk;

