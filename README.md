**tugas membuat tabel analisa menggunakan bigquery untuk mengevaluasi performa analisa kimia farma tahun 2020- 2023**
1.	Membuat atau mengganti tabel
2.	Membuat CTE (transaksi_cte) untuk transaksi
3.	Menghitung nilai penting seperti nett sales & nett profit
4.	Menggabungkan data dengan tabel cabang & produk
5.	Menghitung total profit & total sales per cabang dan produk
   
**-- Membuat atau Mengganti Tabel**
CREATE OR REPLACE TABLE `rakamin-kf-analytics-448814.kimia_farma.kf_Dasboard_1` AS
•	Jika tabel sudah ada, akan diganti dengan data baru.
•	Disimpan dalam dataset kimia_farma pada project rakamin-kf-analytics-448814.

**--Membuat CTE (transaksi_cte)**
WITH transaksi_cte AS (
    SELECT transaction_id, product_id, branch_id,
           COUNT(DISTINCT transaction_id) AS total_transactions,
           price AS actual_price,
           price * (1 - (discount_percentage / 100)) AS nett_sales
    FROM kf_final_transaction
    WHERE EXTRACT(YEAR FROM date) BETWEEN 2020 AND 2023
    GROUP BY branch_id, product_id, transaction_id, price, discount_percentage, date
)
•	CTE digunakan untuk menyimpan hasil query sementara.
•	Nett sales dihitung setelah diskon 
•	Memfilter transaksi dari tahun 2020-2023.

--Menghitung Persentase Gross Laba
CASE 
    WHEN price <= 50000 THEN 0.10
    WHEN price > 50000 AND price <= 100000 THEN 0.15
    WHEN price > 100000 AND price <= 300000 THEN 0.20
    WHEN price > 300000 AND price <= 500000 THEN 0.25
    ELSE 0.30
END AS persentase_gross_laba
•	Menggunakan CASE WHEN untuk menentukan persentase laba berdasarkan harga.

--Menghitung Nett Profit
(price * (1 - (discount_percentage / 100)) * 
    CASE 
        WHEN price <= 50000 THEN 0.10
        WHEN price > 50000 AND price <= 100000 THEN 0.15
        WHEN price > 100000 AND price <= 300000 THEN 0.20
        WHEN price > 300000 AND price <= 500000 THEN 0.25
        ELSE 0.30
    END) AS nett_profit,
•	Nett profit dihitung dari nett sales × persentase gross laba.

--Menghitung Total Profit dan Sales
SUM(nett_profit) OVER (PARTITION BY branch_id, product_id) AS total_profit,
SUM(nett_sales) OVER (PARTITION BY branch_id, product_id) AS total_sales
•	Menggunakan Window Function untuk menghitung total profit dan sales per cabang & produk.

--Menggabungkan dengan Data Cabang & Produk
JOIN kf_kantor_cabang c ON t.branch_id = c.branch_id
JOIN kf_product p ON t.product_id = p.product_id;
•	Menghubungkan transaksi dengan nama cabang, kota, provinsi, dan rating.
•	Menghubungkan transaksi dengan nama produk.

--Penjelasan Hasil Dashboard:
1.	Total Transaksi
o	Menampilkan jumlah transaksi per cabang dan produk selama periode 2020-2023.
o	Memberikan gambaran tentang volume penjualan di berbagai lokasi.
2.	Total Sales & Profit
o	Menghitung total pendapatan setelah diskon (nett sales).
o	Menampilkan total keuntungan (nett profit) berdasarkan margin laba yang sudah ditentukan.
3.	Distribusi Transaksi
o	Menunjukkan tren transaksi dari tahun ke tahun dalam bentuk grafik.
o	Membantu melihat pola pertumbuhan atau penurunan transaksi di periode tertentu.
4.	Performa Cabang
o	Mengidentifikasi cabang dengan performa terbaik berdasarkan penjualan dan keuntungan.
o	Bisa digunakan untuk analisis strategi bisnis di masing-masing cabang.
5.	Analisis Produk
o	Menampilkan produk dengan kontribusi terbesar terhadap total penjualan.
o	Membantu memahami preferensi pelanggan dan strategi stok produk.


