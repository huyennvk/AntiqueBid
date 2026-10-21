-- =========================================================================
-- KỊCH BẢN NHẬP DỮ LIỆU MẪU CHUẨN - AntiqueBidDB
-- Sinh tự động: 2026-10-21 15:15
-- Quy mô: 32 users, 5 categories, 40 items, 30 auctions
-- Cấu trúc phiên: 12 ACTIVE (end < 24h), 8 SCHEDULED, 6 ENDED_SOLD, 2 ENDED_NO_BIDS, 1 ENDED_RESERVE, 1 CANCELLED
-- =========================================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE AntiqueBidDB;
GO

-- Tạm tắt trigger BR29 để cho phép xóa audit_logs khi seed lại
IF OBJECT_ID(N'dbo.trg_audit_logs_immutable', N'TR') IS NOT NULL
    DISABLE TRIGGER dbo.trg_audit_logs_immutable ON dbo.audit_logs;
GO

DELETE FROM dbo.audit_logs;
DELETE FROM dbo.notifications;
DELETE FROM dbo.disputes;
DELETE FROM dbo.shipments;
DELETE FROM dbo.payments;
DELETE FROM dbo.orders;
DELETE FROM dbo.watchlist_items;
DELETE FROM dbo.watchlists;
DELETE FROM dbo.bids;
DELETE FROM dbo.auctions;
DELETE FROM dbo.appraisal_certificates;
DELETE FROM dbo.provenance_records;
DELETE FROM dbo.item_images;
DELETE FROM dbo.antique_items;
DELETE FROM dbo.categories;
DELETE FROM dbo.verification_documents;
DELETE FROM dbo.bidder_profiles;
DELETE FROM dbo.users;
GO

-- Bật lại trigger bất biến sau khi dọn dữ liệu
IF OBJECT_ID(N'dbo.trg_audit_logs_immutable', N'TR') IS NOT NULL
    ENABLE TRIGGER dbo.trg_audit_logs_immutable ON dbo.audit_logs;
GO

DBCC CHECKIDENT ('dbo.users', RESEED, 0);
DBCC CHECKIDENT ('dbo.verification_documents', RESEED, 0);
DBCC CHECKIDENT ('dbo.categories', RESEED, 0);
DBCC CHECKIDENT ('dbo.antique_items', RESEED, 0);
DBCC CHECKIDENT ('dbo.item_images', RESEED, 0);
DBCC CHECKIDENT ('dbo.provenance_records', RESEED, 0);
DBCC CHECKIDENT ('dbo.appraisal_certificates', RESEED, 0);
DBCC CHECKIDENT ('dbo.auctions', RESEED, 0);
DBCC CHECKIDENT ('dbo.bids', RESEED, 0);
DBCC CHECKIDENT ('dbo.watchlists', RESEED, 0);
DBCC CHECKIDENT ('dbo.watchlist_items', RESEED, 0);
DBCC CHECKIDENT ('dbo.orders', RESEED, 0);
DBCC CHECKIDENT ('dbo.payments', RESEED, 0);
DBCC CHECKIDENT ('dbo.shipments', RESEED, 0);
DBCC CHECKIDENT ('dbo.disputes', RESEED, 0);
DBCC CHECKIDENT ('dbo.notifications', RESEED, 0);
DBCC CHECKIDENT ('dbo.audit_logs', RESEED, 0);
GO

-- 1. users (2 Quản trị viên + 30 Khách đấu giá)
INSERT INTO dbo.users (email, password_hash, full_name, phone, role, is_locked, created_at) VALUES
('admin@antiquebid.vn', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'Nguyễn Thị Quản Trị', '0900000001', 'ADMIN', 0, '2026-06-01 09:00:00'),
('admin2@antiquebid.vn', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'Trần Văn Điều Hành', '0900000002', 'ADMIN', 0, '2026-06-02 09:00:00'),
('bidder01@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Nguyễn Văn An', '0911000001', 'BIDDER', 0, '2026-06-05 09:00:00'),
('bidder02@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Trần Thị Bình', '0911000002', 'BIDDER', 0, '2026-06-06 10:00:00'),
('bidder03@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Lê Văn Cường', '0911000003', 'BIDDER', 0, '2026-06-07 11:00:00'),
('bidder04@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Phạm Thị Dũng', '0911000004', 'BIDDER', 0, '2026-06-08 12:00:00'),
('bidder05@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Hoàng Văn Phương', '0911000005', 'BIDDER', 0, '2026-06-09 13:00:00'),
('bidder06@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Huỳnh Thị Giang', '0911000006', 'BIDDER', 0, '2026-06-10 14:00:00'),
('bidder07@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Phan Văn Hoa', '0911000007', 'BIDDER', 0, '2026-06-11 15:00:00'),
('bidder08@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Vũ Thị Khánh', '0911000008', 'BIDDER', 0, '2026-06-12 16:00:00'),
('bidder09@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Võ Văn Lan', '0911000009', 'BIDDER', 0, '2026-06-13 09:00:00'),
('bidder10@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Đặng Thị Minh', '0911000010', 'BIDDER', 0, '2026-06-14 10:00:00'),
('bidder11@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Bùi Văn Nga', '0911000011', 'BIDDER', 0, '2026-06-15 11:00:00'),
('bidder12@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Đỗ Thị Phúc', '0911000012', 'BIDDER', 0, '2026-06-16 12:00:00'),
('bidder13@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Hồ Văn Quỳnh', '0911000013', 'BIDDER', 0, '2026-06-17 13:00:00'),
('bidder14@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Ngô Thị Sơn', '0911000014', 'BIDDER', 1, '2026-06-18 14:00:00'),
('bidder15@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Dương Văn Thảo', '0911000015', 'BIDDER', 0, '2026-06-19 15:00:00'),
('bidder16@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Lý Thị Việt', '0911000016', 'BIDDER', 0, '2026-06-20 16:00:00'),
('bidder17@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Đinh Văn Hùng', '0911000017', 'BIDDER', 0, '2026-06-21 09:00:00'),
('bidder18@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Cao Thị Linh', '0911000018', 'BIDDER', 0, '2026-06-22 10:00:00'),
('bidder19@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Trịnh Văn Nam', '0911000019', 'BIDDER', 0, '2026-06-23 11:00:00'),
('bidder20@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Mai Thị Trang', '0911000020', 'BIDDER', 0, '2026-06-24 12:00:00'),
('bidder21@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Nguyễn Văn Tuấn', '0911000021', 'BIDDER', 0, '2026-06-25 13:00:00'),
('bidder22@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Trần Thị Hạnh', '0911000022', 'BIDDER', 0, '2026-06-26 14:00:00'),
('bidder23@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Lê Văn Đạt', '0911000023', 'BIDDER', 0, '2026-06-05 15:00:00'),
('bidder24@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Phạm Thị Mai', '0911000024', 'BIDDER', 0, '2026-06-06 16:00:00'),
('bidder25@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Hoàng Văn Long', '0911000025', 'BIDDER', 0, '2026-06-07 09:00:00'),
('bidder26@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Huỳnh Thị Hương', '0911000026', 'BIDDER', 0, '2026-06-08 10:00:00'),
('bidder27@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Phan Văn Khoa', '0911000027', 'BIDDER', 0, '2026-06-09 11:00:00'),
('bidder28@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Vũ Thị Quang', '0911000028', 'BIDDER', 1, '2026-06-10 12:00:00'),
('bidder29@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Võ Văn Bảo', '0911000029', 'BIDDER', 0, '2026-06-11 13:00:00'),
('bidder30@email.vn', '482c811da5d5b4bc6d497ffa98491e38', N'Đặng Thị Ngọc', '0911000030', 'BIDDER', 0, '2026-06-12 14:00:00');
GO

-- 2. bidder_profiles
INSERT INTO dbo.bidder_profiles (user_id, citizen_id, kyc_status, violation_count, shipping_address) VALUES
(3, '001082000003', 'VERIFIED', 0, N'12 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh'),
(4, '079183000004', 'VERIFIED', 0, N'14 Lê Lợi, Hoàn Kiếm, Hà Nội'),
(5, '048084000005', 'VERIFIED', 0, N'16 Trần Phú, Hải Châu, Đà Nẵng'),
(6, '092185000006', 'PENDING', 0, N'18 Pasteur, Ninh Kiều, Cần Thơ'),
(7, '031086000007', 'VERIFIED', 0, N'20 Hai Bà Trưng, Hồng Bàng, Hải Phòng'),
(8, NULL, 'NOT_SUBMITTED', 0, N'22 Lý Thường Kiệt, TP. Huế'),
(9, '056088000009', 'VERIFIED', 0, N'24 Nguyễn Huệ, Nha Trang'),
(10, NULL, 'REJECTED', 3, N'26 Trần Hưng Đạo, Biên Hòa'),
(11, '077090000011', 'VERIFIED', 0, N'28 Phan Chu Trinh, Vũng Tàu'),
(12, '068191000012', 'VERIFIED', 0, N'30 Võ Thị Sáu, Đà Lạt'),
(13, '040092000013', 'VERIFIED', 0, N'32 Cách Mạng Tháng 8, Vinh'),
(14, '074193000014', 'PENDING', 0, N'34 Điện Biên Phủ, Thủ Dầu Một'),
(15, '001094000015', 'VERIFIED', 0, N'36 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh'),
(16, NULL, 'REJECTED', 3, N'38 Lê Lợi, Hoàn Kiếm, Hà Nội'),
(17, '048096000017', 'VERIFIED', 0, N'40 Trần Phú, Hải Châu, Đà Nẵng'),
(18, NULL, 'REJECTED', 3, N'42 Pasteur, Ninh Kiều, Cần Thơ'),
(19, '031082000019', 'VERIFIED', 0, N'44 Hai Bà Trưng, Hồng Bàng, Hải Phòng'),
(20, '046183000020', 'VERIFIED', 0, N'46 Lý Thường Kiệt, TP. Huế'),
(21, '056084000021', 'VERIFIED', 0, N'48 Nguyễn Huệ, Nha Trang'),
(22, '075185000022', 'PENDING', 0, N'50 Trần Hưng Đạo, Biên Hòa'),
(23, '077086000023', 'VERIFIED', 0, N'52 Phan Chu Trinh, Vũng Tàu'),
(24, NULL, 'NOT_SUBMITTED', 0, N'54 Võ Thị Sáu, Đà Lạt'),
(25, '040088000025', 'VERIFIED', 0, N'56 Cách Mạng Tháng 8, Vinh'),
(26, NULL, 'REJECTED', 3, N'58 Điện Biên Phủ, Thủ Dầu Một'),
(27, '001090000027', 'VERIFIED', 0, N'60 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh'),
(28, '079191000028', 'VERIFIED', 0, N'62 Lê Lợi, Hoàn Kiếm, Hà Nội'),
(29, '048092000029', 'VERIFIED', 0, N'64 Trần Phú, Hải Châu, Đà Nẵng'),
(30, NULL, 'REJECTED', 3, N'66 Pasteur, Ninh Kiều, Cần Thơ'),
(31, '031094000031', 'VERIFIED', 0, N'68 Hai Bà Trưng, Hồng Bàng, Hải Phòng'),
(32, NULL, 'NOT_SUBMITTED', 0, N'70 Lý Thường Kiệt, TP. Huế');
GO

-- 3. verification_documents
INSERT INTO dbo.verification_documents (bidder_id, doc_type, citizen_id, issue_date, issue_place, file_url, file_url_back, submitted_at, review_note) VALUES
(3, 'CITIZEN_ID', '001082000003', '2021-05-10', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u3_cccd_front.png', '/uploads/kyc/u3_cccd_back.png', '2026-06-06 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(4, 'CITIZEN_ID', '079183000004', '2021-06-11', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u4_cccd_front.png', '/uploads/kyc/u4_cccd_back.png', '2026-06-07 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(5, 'CITIZEN_ID', '048084000005', '2021-07-12', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u5_cccd_front.png', '/uploads/kyc/u5_cccd_back.png', '2026-06-08 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(6, 'CITIZEN_ID', '092185000006', '2021-08-13', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u6_cccd_front.png', '/uploads/kyc/u6_cccd_back.png', '2026-06-09 10:00:00', NULL),
(7, 'CITIZEN_ID', '031086000007', '2021-09-14', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u7_cccd_front.png', '/uploads/kyc/u7_cccd_back.png', '2026-06-10 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(9, 'CITIZEN_ID', '056088000009', '2021-11-16', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u9_cccd_front.png', '/uploads/kyc/u9_cccd_back.png', '2026-06-12 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(10, 'CITIZEN_ID', '075189000010', '2021-05-17', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u10_cccd_front.png', '/uploads/kyc/u10_cccd_back.png', '2026-06-13 10:00:00', N'Ảnh CCCD mờ, từ chối duyệt'),
(11, 'CITIZEN_ID', '077090000011', '2021-06-18', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u11_cccd_front.png', '/uploads/kyc/u11_cccd_back.png', '2026-06-14 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(12, 'CITIZEN_ID', '068191000012', '2021-07-19', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u12_cccd_front.png', '/uploads/kyc/u12_cccd_back.png', '2026-06-15 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(13, 'CITIZEN_ID', '040092000013', '2021-08-20', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u13_cccd_front.png', '/uploads/kyc/u13_cccd_back.png', '2026-06-16 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(14, 'CITIZEN_ID', '074193000014', '2021-09-21', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u14_cccd_front.png', '/uploads/kyc/u14_cccd_back.png', '2026-06-17 10:00:00', NULL),
(15, 'CITIZEN_ID', '001094000015', '2021-10-22', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u15_cccd_front.png', '/uploads/kyc/u15_cccd_back.png', '2026-06-18 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(16, 'CITIZEN_ID', '079195000016', '2021-11-23', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u16_cccd_front.png', '/uploads/kyc/u16_cccd_back.png', '2026-06-19 10:00:00', N'Ảnh CCCD mờ, từ chối duyệt'),
(17, 'CITIZEN_ID', '048096000017', '2021-05-24', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u17_cccd_front.png', '/uploads/kyc/u17_cccd_back.png', '2026-06-20 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(18, 'CITIZEN_ID', '092197000018', '2021-06-10', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u18_cccd_front.png', '/uploads/kyc/u18_cccd_back.png', '2026-06-21 10:00:00', N'Ảnh CCCD mờ, từ chối duyệt'),
(19, 'CITIZEN_ID', '031082000019', '2021-07-11', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u19_cccd_front.png', '/uploads/kyc/u19_cccd_back.png', '2026-06-22 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(20, 'CITIZEN_ID', '046183000020', '2021-08-12', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u20_cccd_front.png', '/uploads/kyc/u20_cccd_back.png', '2026-06-23 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(21, 'CITIZEN_ID', '056084000021', '2021-09-13', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u21_cccd_front.png', '/uploads/kyc/u21_cccd_back.png', '2026-06-24 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(22, 'CITIZEN_ID', '075185000022', '2021-10-14', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u22_cccd_front.png', '/uploads/kyc/u22_cccd_back.png', '2026-06-25 10:00:00', NULL),
(23, 'CITIZEN_ID', '077086000023', '2021-11-15', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u23_cccd_front.png', '/uploads/kyc/u23_cccd_back.png', '2026-06-06 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(25, 'CITIZEN_ID', '040088000025', '2021-06-17', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u25_cccd_front.png', '/uploads/kyc/u25_cccd_back.png', '2026-06-08 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(26, 'CITIZEN_ID', '074189000026', '2021-07-18', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u26_cccd_front.png', '/uploads/kyc/u26_cccd_back.png', '2026-06-09 10:00:00', N'Ảnh CCCD mờ, từ chối duyệt'),
(27, 'CITIZEN_ID', '001090000027', '2021-08-19', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u27_cccd_front.png', '/uploads/kyc/u27_cccd_back.png', '2026-06-10 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(28, 'CITIZEN_ID', '079191000028', '2021-09-20', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u28_cccd_front.png', '/uploads/kyc/u28_cccd_back.png', '2026-06-11 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(29, 'CITIZEN_ID', '048092000029', '2021-10-21', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u29_cccd_front.png', '/uploads/kyc/u29_cccd_back.png', '2026-06-12 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip'),
(30, 'CITIZEN_ID', '092193000030', '2021-11-22', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u30_cccd_front.png', '/uploads/kyc/u30_cccd_back.png', '2026-06-13 10:00:00', N'Ảnh CCCD mờ, từ chối duyệt'),
(31, 'CITIZEN_ID', '031094000031', '2021-05-23', N'Cục Cảnh sát QLHC về TTXH', '/uploads/kyc/u31_cccd_front.png', '/uploads/kyc/u31_cccd_back.png', '2026-06-14 10:00:00', N'Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip');
GO

-- 4. categories (5 danh mục tinh gọn)
INSERT INTO dbo.categories (name, description, is_active, created_at, updated_at) VALUES
(N'Gốm sứ cổ', N'Bình, đĩa, bát men ngọc, men lam, gốm Chu Đậu, Bát Tràng cổ', 1, '2026-06-01 08:30:00', '2026-06-01 08:30:00'),
(N'Đồ đồng & Tượng cổ', N'Tượng Phật, đỉnh đồng tam khí, chuông đồng, lư hương nghi lễ cổ', 1, '2026-06-01 08:30:00', '2026-06-01 08:30:00'),
(N'Tranh cổ & Thư pháp', N'Tranh thủy mặc, tranh sơn mài, cuốn thư, câu đối Hán Nôm cổ', 1, '2026-06-01 08:30:00', '2026-06-01 08:30:00'),
(N'Đồ gỗ mỹ nghệ', N'Bàn trà, tủ trắc khảm ốc, bình phong gỗ gụ quý cổ', 1, '2026-06-01 08:30:00', '2026-06-01 08:30:00'),
(N'Ngọc bích & Trang sức cổ', N'Vòng ngọc cẩm thạch, nhẫn vàng chạm, trâm cài hoàng gia cổ', 1, '2026-06-01 08:30:00', '2026-06-01 08:30:00');
GO

-- 5. antique_items (40 hiện vật độc bản)
INSERT INTO dbo.antique_items (item_code, name, description, era_from, era_to, material, dimensions,
 item_condition, status, is_archived, version, category_id, created_by, created_at, updated_at) VALUES
(N'HV-0001', N'Bình gốm men lam thế kỷ 15', N'Bình gốm men lam thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0001.', 1401, 1599, N'Gốm sứ', N'Cao 21cm, Ø14cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 2, '2026-07-02 09:00:00', '2026-08-02 09:00:00'),
(N'HV-0002', N'Đĩa gốm Chu Đậu thế kỷ 16', N'Đĩa gốm Chu Đậu thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0002.', 1452, 1648, N'Gốm sứ', N'Ø16cm, cao 24cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 1, 1, '2026-07-03 09:00:00', '2026-08-03 09:00:00'),
(N'HV-0003', N'Bát men ngọc Celadon thế kỷ 17', N'Bát men ngọc Celadon thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0003.', 1403, 1597, N'Gốm celadon', N'Ø18cm', 'RESTORED', 'AVAILABLE', 0, 0, 1, 2, '2026-07-04 09:00:00', '2026-08-04 09:00:00'),
(N'HV-0004', N'Lọ hoa Bát Tràng thế kỷ 18', N'Lọ hoa Bát Tràng thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0004.', 1604, 1796, N'Gốm sứ', N'Cao 30cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 1, '2026-07-05 09:00:00', '2026-08-05 09:00:00'),
(N'HV-0005', N'Tượng Phật đồng thời Nguyễn', N'Tượng Phật đồng thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0005.', 1605, 1845, N'Đồng nguyên chất', N'Cao 33cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 2, 2, '2026-07-06 09:00:00', '2026-08-06 09:00:00'),
(N'HV-0006', N'Đỉnh đồng tam khí thời Lê', N'Đỉnh đồng tam khí thời Lê. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0006.', 1706, 1894, N'Đồng', N'Cao 36cm', 'RESTORED', 'AVAILABLE', 0, 0, 2, 1, '2026-07-07 09:00:00', '2026-08-07 09:00:00'),
(N'HV-0007', N'Lư hương đồng thế kỷ 19', N'Lư hương đồng thế kỷ 19. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0007.', 1657, 1843, N'Đồng', N'Cao 39cm, Ø26cm', 'INTACT', 'AVAILABLE', 0, 0, 2, 2, '2026-07-08 09:00:00', '2026-08-08 09:00:00'),
(N'HV-0008', N'Tượng Lân đồng phong thủy thế kỷ 15', N'Tượng Lân đồng phong thủy thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0008.', 1708, 1842, N'Đồng', N'Cao 42cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 2, 1, '2026-07-09 09:00:00', '2026-08-09 09:00:00'),
(N'HV-0009', N'Tranh thủy mặc Tùng Hạc thế kỷ 16', N'Tranh thủy mặc Tùng Hạc thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0009.', 1809, 1911, N'Giấy xuyến chỉ', N'45x30cm', 'RESTORED', 'AVAILABLE', 0, 0, 3, 2, '2026-07-10 09:00:00', '2026-08-10 09:00:00'),
(N'HV-0010', N'Tranh sơn mài cổ thế kỷ 17', N'Tranh sơn mài cổ thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0010.', 1830, 1900, N'Sơn mài trên gỗ', N'48x32cm', 'INTACT', 'AVAILABLE', 0, 0, 3, 1, '2026-07-11 09:00:00', '2026-08-11 09:00:00'),
(N'HV-0011', N'Cuốn thư Hán Nôm thế kỷ 18', N'Cuốn thư Hán Nôm thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0011.', 1761, 1879, N'Giấy dó cổ', N'51x34cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 3, 2, '2026-07-12 09:00:00', '2026-08-12 09:00:00'),
(N'HV-0012', N'Bộ câu đối gỗ mun thời Nguyễn', N'Bộ câu đối gỗ mun thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0012.', 1812, 1908, N'Gỗ mun', N'54x36cm', 'RESTORED', 'AVAILABLE', 0, 0, 3, 1, '2026-07-13 09:00:00', '2026-08-13 09:00:00'),
(N'HV-0013', N'Tủ chè gỗ trắc khảm ốc thời Lê', N'Tủ chè gỗ trắc khảm ốc thời Lê. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0013.', 1793, 1887, N'Gỗ trắc', N'57x38x50cm', 'INTACT', 'AVAILABLE', 0, 0, 4, 2, '2026-07-14 09:00:00', '2026-08-14 09:00:00'),
(N'HV-0014', N'Bàn trà gỗ hương thế kỷ 19', N'Bàn trà gỗ hương thế kỷ 19. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0014.', 1814, 1906, N'Gỗ hương', N'60x40x40cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 4, 1, '2026-07-15 09:00:00', '2026-08-15 09:00:00'),
(N'HV-0015', N'Bình phong gỗ gụ thế kỷ 15', N'Bình phong gỗ gụ thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0015.', 1735, 1845, N'Gỗ gụ', N'Mỗi cánh 18x12cm', 'RESTORED', 'AVAILABLE', 0, 0, 4, 2, '2026-07-16 09:00:00', '2026-08-16 09:00:00'),
(N'HV-0016', N'Vòng ngọc bích thế kỷ 16', N'Vòng ngọc bích thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0016.', 1816, 1934, N'Ngọc cẩm thạch', N'Ø14cm', 'INTACT', 'AVAILABLE', 0, 0, 5, 1, '2026-07-17 09:00:00', '2026-08-17 09:00:00'),
(N'HV-0017', N'Nhẫn vàng chạm hoa văn thế kỷ 17', N'Nhẫn vàng chạm hoa văn thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0017.', 1837, 1883, N'Vàng cổ', N'Ø1.9cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 5, 2, '2026-07-18 09:00:00', '2026-08-18 09:00:00'),
(N'HV-0018', N'Trâm bạc đính ngọc thế kỷ 18', N'Trâm bạc đính ngọc thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0018.', 1868, 1902, N'Bạc và ngọc', N'Dài 27cm', 'RESTORED', 'AVAILABLE', 0, 0, 5, 1, '2026-07-19 09:00:00', '2026-08-19 09:00:00'),
(N'HV-0019', N'Bình gốm men lam thời Nguyễn', N'Bình gốm men lam thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0019.', 1419, 1581, N'Gốm sứ', N'Cao 30cm, Ø20cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 2, '2026-07-20 09:00:00', '2026-08-20 09:00:00'),
(N'HV-0020', N'Đĩa gốm Chu Đậu thời Lê', N'Đĩa gốm Chu Đậu thời Lê. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0020.', 1450, 1650, N'Gốm sứ', N'Ø22cm, cao 33cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 1, 1, '2026-07-21 09:00:00', '2026-08-21 09:00:00'),
(N'HV-0021', N'Bát men ngọc Celadon thế kỷ 19', N'Bát men ngọc Celadon thế kỷ 19. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0021.', 1401, 1599, N'Gốm celadon', N'Ø24cm', 'RESTORED', 'AVAILABLE', 0, 0, 1, 2, '2026-07-22 09:00:00', '2026-08-22 09:00:00'),
(N'HV-0022', N'Lọ hoa Bát Tràng thế kỷ 15', N'Lọ hoa Bát Tràng thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0022.', 1602, 1798, N'Gốm sứ', N'Cao 39cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 1, '2026-07-23 09:00:00', '2026-08-23 09:00:00'),
(N'HV-0023', N'Tượng Phật đồng thế kỷ 16', N'Tượng Phật đồng thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0023.', 1603, 1847, N'Đồng nguyên chất', N'Cao 42cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 2, 2, '2026-07-24 09:00:00', '2026-08-24 09:00:00'),
(N'HV-0024', N'Đỉnh đồng tam khí thế kỷ 17', N'Đỉnh đồng tam khí thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0024.', 1704, 1896, N'Đồng', N'Cao 45cm', 'RESTORED', 'AVAILABLE', 0, 0, 2, 1, '2026-07-25 09:00:00', '2026-08-25 09:00:00'),
(N'HV-0025', N'Lư hương đồng thế kỷ 18', N'Lư hương đồng thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0025.', 1655, 1845, N'Đồng', N'Cao 48cm, Ø32cm', 'INTACT', 'AVAILABLE', 0, 0, 2, 2, '2026-07-01 09:00:00', '2026-08-01 09:00:00'),
(N'HV-0026', N'Tượng Lân đồng phong thủy thời Nguyễn', N'Tượng Lân đồng phong thủy thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0026.', 1706, 1844, N'Đồng', N'Cao 51cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 2, 1, '2026-07-02 09:00:00', '2026-08-02 09:00:00'),
(N'HV-0027', N'Tranh thủy mặc Tùng Hạc thời Lê', N'Tranh thủy mặc Tùng Hạc thời Lê. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0027.', 1807, 1913, N'Giấy xuyến chỉ', N'54x36cm', 'RESTORED', 'AVAILABLE', 0, 0, 3, 2, '2026-07-03 09:00:00', '2026-08-03 09:00:00'),
(N'HV-0028', N'Tranh sơn mài cổ thế kỷ 19', N'Tranh sơn mài cổ thế kỷ 19. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0028.', 1828, 1902, N'Sơn mài trên gỗ', N'57x38cm', 'INTACT', 'AVAILABLE', 0, 0, 3, 1, '2026-07-04 09:00:00', '2026-08-04 09:00:00'),
(N'HV-0029', N'Cuốn thư Hán Nôm thế kỷ 15', N'Cuốn thư Hán Nôm thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0029.', 1759, 1881, N'Giấy dó cổ', N'60x40cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 3, 2, '2026-07-05 09:00:00', '2026-08-05 09:00:00'),
(N'HV-0030', N'Bộ câu đối gỗ mun thế kỷ 16', N'Bộ câu đối gỗ mun thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0030.', 1810, 1910, N'Gỗ mun', N'18x12cm', 'RESTORED', 'AVAILABLE', 0, 0, 3, 1, '2026-07-06 09:00:00', '2026-08-06 09:00:00'),
(N'HV-0031', N'Tủ chè gỗ trắc khảm ốc thế kỷ 17', N'Tủ chè gỗ trắc khảm ốc thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0031.', 1791, 1889, N'Gỗ trắc', N'21x14x50cm', 'INTACT', 'AVAILABLE', 0, 0, 4, 2, '2026-07-07 09:00:00', '2026-08-07 09:00:00'),
(N'HV-0032', N'Bàn trà gỗ hương thế kỷ 18', N'Bàn trà gỗ hương thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0032.', 1812, 1908, N'Gỗ hương', N'24x16x40cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 4, 1, '2026-07-08 09:00:00', '2026-08-08 09:00:00'),
(N'HV-0033', N'Bình phong gỗ gụ thời Nguyễn', N'Bình phong gỗ gụ thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0033.', 1733, 1847, N'Gỗ gụ', N'Mỗi cánh 27x18cm', 'RESTORED', 'AVAILABLE', 0, 0, 4, 2, '2026-07-09 09:00:00', '2026-08-09 09:00:00'),
(N'HV-0034', N'Vòng ngọc bích thời Lê', N'Vòng ngọc bích thời Lê. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0034.', 1814, 1936, N'Ngọc cẩm thạch', N'Ø20cm', 'INTACT', 'AVAILABLE', 0, 0, 5, 1, '2026-07-10 09:00:00', '2026-08-10 09:00:00'),
(N'HV-0035', N'Nhẫn vàng chạm hoa văn thế kỷ 19', N'Nhẫn vàng chạm hoa văn thế kỷ 19. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0035.', 1835, 1885, N'Vàng cổ', N'Ø1.9cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 5, 2, '2026-07-11 09:00:00', '2026-08-11 09:00:00'),
(N'HV-0036', N'Trâm bạc đính ngọc thế kỷ 15', N'Trâm bạc đính ngọc thế kỷ 15. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0036.', 1866, 1904, N'Bạc và ngọc', N'Dài 36cm', 'RESTORED', 'AVAILABLE', 0, 0, 5, 1, '2026-07-12 09:00:00', '2026-08-12 09:00:00'),
(N'HV-0037', N'Bình gốm men lam thế kỷ 16', N'Bình gốm men lam thế kỷ 16. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0037.', 1417, 1583, N'Gốm sứ', N'Cao 39cm, Ø26cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 2, '2026-07-13 09:00:00', '2026-08-13 09:00:00'),
(N'HV-0038', N'Đĩa gốm Chu Đậu thế kỷ 17', N'Đĩa gốm Chu Đậu thế kỷ 17. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0038.', 1468, 1632, N'Gốm sứ', N'Ø28cm, cao 42cm', 'SLIGHTLY_DAMAGED', 'AVAILABLE', 0, 0, 1, 1, '2026-07-14 09:00:00', '2026-08-14 09:00:00'),
(N'HV-0039', N'Bát men ngọc Celadon thế kỷ 18', N'Bát men ngọc Celadon thế kỷ 18. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0039.', 1419, 1581, N'Gốm celadon', N'Ø30cm', 'RESTORED', 'AVAILABLE', 0, 0, 1, 2, '2026-07-15 09:00:00', '2026-08-15 09:00:00'),
(N'HV-0040', N'Lọ hoa Bát Tràng thời Nguyễn', N'Lọ hoa Bát Tràng thời Nguyễn. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã 0040.', 1600, 1800, N'Gốm sứ', N'Cao 48cm', 'INTACT', 'AVAILABLE', 0, 0, 1, 1, '2026-07-16 09:00:00', '2026-08-16 09:00:00');
GO

-- 6. item_images (Trỏ ảnh chuẩn trong assets/images)
INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) VALUES
(1, 'assets/images/items/real_item_1.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-02 09:00:00'),
(1, 'assets/images/items/real_item_1_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-02 09:05:00'),
(2, 'assets/images/items/real_item_2.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-03 09:00:00'),
(2, 'assets/images/items/real_item_2_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-03 09:05:00'),
(3, 'assets/images/items/real_item_3.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-04 09:00:00'),
(3, 'assets/images/items/real_item_3_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-04 09:05:00'),
(4, 'assets/images/items/real_item_4.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-05 09:00:00'),
(4, 'assets/images/items/real_item_4_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-05 09:05:00'),
(5, 'assets/images/items/real_item_5.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-06 09:00:00'),
(5, 'assets/images/items/real_item_5_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-06 09:05:00'),
(6, 'assets/images/items/real_item_6.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-07 09:00:00'),
(6, 'assets/images/items/real_item_6_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-07 09:05:00'),
(7, 'assets/images/items/real_item_7.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-08 09:00:00'),
(7, 'assets/images/items/real_item_7_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-08 09:05:00'),
(8, 'assets/images/items/real_item_8.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-09 09:00:00'),
(8, 'assets/images/items/real_item_8_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-09 09:05:00'),
(9, 'assets/images/items/real_item_9.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-10 09:00:00'),
(9, 'assets/images/items/real_item_9_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-10 09:05:00'),
(10, 'assets/images/items/real_item_10.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-11 09:00:00'),
(10, 'assets/images/items/real_item_10_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-11 09:05:00'),
(11, 'assets/images/items/real_item_11.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-12 09:00:00'),
(11, 'assets/images/items/real_item_11_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-12 09:05:00'),
(12, 'assets/images/items/real_item_12.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-13 09:00:00'),
(12, 'assets/images/items/real_item_12_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-13 09:05:00'),
(13, 'assets/images/items/real_item_13.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-14 09:00:00'),
(13, 'assets/images/items/real_item_13_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-14 09:05:00'),
(14, 'assets/images/items/real_item_14.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-15 09:00:00'),
(14, 'assets/images/items/real_item_14_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-15 09:05:00'),
(15, 'assets/images/items/real_item_15.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-16 09:00:00'),
(15, 'assets/images/items/real_item_15_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-16 09:05:00'),
(16, 'assets/images/items/real_item_16.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-17 09:00:00'),
(16, 'assets/images/items/real_item_16_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-17 09:05:00'),
(17, 'assets/images/items/real_item_17.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-18 09:00:00'),
(17, 'assets/images/items/real_item_17_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-18 09:05:00'),
(18, 'assets/images/items/real_item_18.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-19 09:00:00'),
(18, 'assets/images/items/real_item_18_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-19 09:05:00'),
(19, 'assets/images/items/real_item_19.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-20 09:00:00'),
(19, 'assets/images/items/real_item_19_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-20 09:05:00'),
(20, 'assets/images/items/real_item_20.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-21 09:00:00'),
(20, 'assets/images/items/real_item_20_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-21 09:05:00'),
(21, 'assets/images/items/real_item_21.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-22 09:00:00'),
(21, 'assets/images/items/real_item_21_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-22 09:05:00'),
(22, 'assets/images/items/real_item_22.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-23 09:00:00'),
(22, 'assets/images/items/real_item_22_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-23 09:05:00'),
(23, 'assets/images/items/real_item_23.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-24 09:00:00'),
(23, 'assets/images/items/real_item_23_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-24 09:05:00'),
(24, 'assets/images/items/real_item_24.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-25 09:00:00'),
(24, 'assets/images/items/real_item_24_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-25 09:05:00'),
(25, 'assets/images/items/real_item_25.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-01 09:00:00'),
(25, 'assets/images/items/real_item_25_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-01 09:05:00'),
(26, 'assets/images/items/real_item_26.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-02 09:00:00'),
(26, 'assets/images/items/real_item_26_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-02 09:05:00'),
(27, 'assets/images/items/real_item_27.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-03 09:00:00'),
(27, 'assets/images/items/real_item_27_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-03 09:05:00'),
(28, 'assets/images/items/real_item_28.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-04 09:00:00'),
(28, 'assets/images/items/real_item_28_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-04 09:05:00'),
(29, 'assets/images/items/real_item_29.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-05 09:00:00'),
(29, 'assets/images/items/real_item_29_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-05 09:05:00'),
(30, 'assets/images/items/real_item_30.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-06 09:00:00'),
(30, 'assets/images/items/real_item_30_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-06 09:05:00'),
(31, 'assets/images/items/real_item_31.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-07 09:00:00'),
(31, 'assets/images/items/real_item_31_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-07 09:05:00'),
(32, 'assets/images/items/real_item_32.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-08 09:00:00'),
(32, 'assets/images/items/real_item_32_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-08 09:05:00'),
(33, 'assets/images/items/real_item_33.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-09 09:00:00'),
(33, 'assets/images/items/real_item_33_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-09 09:05:00'),
(34, 'assets/images/items/real_item_34.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-10 09:00:00'),
(34, 'assets/images/items/real_item_34_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-10 09:05:00'),
(35, 'assets/images/items/real_item_35.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-11 09:00:00'),
(35, 'assets/images/items/real_item_35_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-11 09:05:00'),
(36, 'assets/images/items/real_item_36.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-12 09:00:00'),
(36, 'assets/images/items/real_item_36_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-12 09:05:00'),
(37, 'assets/images/items/real_item_37.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-13 09:00:00'),
(37, 'assets/images/items/real_item_37_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-13 09:05:00'),
(38, 'assets/images/items/real_item_38.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-14 09:00:00'),
(38, 'assets/images/items/real_item_38_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-14 09:05:00'),
(39, 'assets/images/items/real_item_39.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-15 09:00:00'),
(39, 'assets/images/items/real_item_39_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-15 09:05:00'),
(40, 'assets/images/items/real_item_40.jpg', 'image/jpeg', 280000, 1, 1, '2026-07-16 09:00:00'),
(40, 'assets/images/items/real_item_40_detail.jpg', 'image/jpeg', 220000, 0, 2, '2026-07-16 09:05:00');
GO

-- 7. provenance_records
INSERT INTO dbo.provenance_records (item_id, origin, acquisition_source, ownership_history, supporting_documents) VALUES
(1, N'Hà Nội', N'Sưu tập từ gia tộc Nguyễn (năm 2013)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0001.pdf'),
(2, N'Huế', N'Sưu tập từ gia tộc Trần (năm 2014)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0002.pdf'),
(3, N'Bát Tràng', N'Sưu tập từ gia tộc Lê (năm 2015)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0003.pdf'),
(4, N'Chu Đậu', N'Sưu tập từ gia tộc Phạm (năm 2016)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0004.pdf'),
(5, N'Trung Hoa', N'Sưu tập từ gia tộc Hoàng (năm 2017)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0005.pdf'),
(6, N'Nam Định', N'Sưu tập từ gia tộc Huỳnh (năm 2018)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0006.pdf'),
(7, N'Pháp', N'Sưu tập từ gia tộc Phan (năm 2019)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0007.pdf'),
(8, N'Hà Nội', N'Sưu tập từ gia tộc Vũ (năm 2020)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0008.pdf'),
(9, N'Huế', N'Sưu tập từ gia tộc Võ (năm 2021)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0009.pdf'),
(10, N'Bát Tràng', N'Sưu tập từ gia tộc Đặng (năm 2022)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0010.pdf'),
(11, N'Chu Đậu', N'Sưu tập từ gia tộc Bùi (năm 2023)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0011.pdf'),
(12, N'Trung Hoa', N'Sưu tập từ gia tộc Đỗ (năm 2012)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0012.pdf'),
(13, N'Nam Định', N'Sưu tập từ gia tộc Hồ (năm 2013)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0013.pdf'),
(14, N'Pháp', N'Sưu tập từ gia tộc Ngô (năm 2014)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0014.pdf'),
(15, N'Hà Nội', N'Sưu tập từ gia tộc Dương (năm 2015)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0015.pdf'),
(16, N'Huế', N'Sưu tập từ gia tộc Lý (năm 2016)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0016.pdf'),
(17, N'Bát Tràng', N'Sưu tập từ gia tộc Đinh (năm 2017)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0017.pdf'),
(18, N'Chu Đậu', N'Sưu tập từ gia tộc Cao (năm 2018)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0018.pdf'),
(19, N'Trung Hoa', N'Sưu tập từ gia tộc Trịnh (năm 2019)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0019.pdf'),
(20, N'Nam Định', N'Sưu tập từ gia tộc Mai (năm 2020)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0020.pdf'),
(21, N'Pháp', N'Sưu tập từ gia tộc Nguyễn (năm 2021)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0021.pdf'),
(22, N'Hà Nội', N'Sưu tập từ gia tộc Trần (năm 2022)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0022.pdf'),
(23, N'Huế', N'Sưu tập từ gia tộc Lê (năm 2023)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0023.pdf'),
(24, N'Bát Tràng', N'Sưu tập từ gia tộc Phạm (năm 2012)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0024.pdf'),
(25, N'Chu Đậu', N'Sưu tập từ gia tộc Hoàng (năm 2013)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0025.pdf'),
(26, N'Trung Hoa', N'Sưu tập từ gia tộc Huỳnh (năm 2014)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0026.pdf'),
(27, N'Nam Định', N'Sưu tập từ gia tộc Phan (năm 2015)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0027.pdf'),
(28, N'Pháp', N'Sưu tập từ gia tộc Vũ (năm 2016)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0028.pdf'),
(29, N'Hà Nội', N'Sưu tập từ gia tộc Võ (năm 2017)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0029.pdf'),
(30, N'Huế', N'Sưu tập từ gia tộc Đặng (năm 2018)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0030.pdf'),
(31, N'Bát Tràng', N'Sưu tập từ gia tộc Bùi (năm 2019)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0031.pdf'),
(32, N'Chu Đậu', N'Sưu tập từ gia tộc Đỗ (năm 2020)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0032.pdf'),
(33, N'Trung Hoa', N'Sưu tập từ gia tộc Hồ (năm 2021)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0033.pdf'),
(34, N'Nam Định', N'Sưu tập từ gia tộc Ngô (năm 2022)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0034.pdf'),
(35, N'Pháp', N'Sưu tập từ gia tộc Dương (năm 2023)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0035.pdf'),
(36, N'Hà Nội', N'Sưu tập từ gia tộc Lý (năm 2012)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0036.pdf'),
(37, N'Huế', N'Sưu tập từ gia tộc Đinh (năm 2013)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0037.pdf'),
(38, N'Bát Tràng', N'Sưu tập từ gia tộc Cao (năm 2014)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0038.pdf'),
(39, N'Chu Đậu', N'Sưu tập từ gia tộc Trịnh (năm 2015)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0039.pdf'),
(40, N'Trung Hoa', N'Sưu tập từ gia tộc Mai (năm 2016)', N'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường', '/docs/prov/hv0040.pdf');
GO

-- 8. appraisal_certificates (Chuẩn 18 bảng ERD, tích hợp kết luận & phương pháp vào note)
INSERT INTO dbo.appraisal_certificates (item_id, result, appraiser_name, appraisal_date, note,
 estimate_low, estimate_high, recorded_by, recorded_at, certificate_no, certificate_status, issued_at, revoked_at) VALUES
(1, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-02', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 19000000, 25000000, 2, '2026-08-02 14:00:00', N'CT-2026-001', 'VALID', '2026-08-02 15:00:00', NULL),
(2, 'PASSED', N'TS. Trần Thị Mai', '2026-08-03', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 26000000, 33000000, 1, '2026-08-03 14:00:00', N'CT-2026-002', 'VALID', '2026-08-03 15:00:00', NULL),
(3, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-04', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 33000000, 41000000, 2, '2026-08-04 14:00:00', N'CT-2026-003', 'VALID', '2026-08-04 15:00:00', NULL),
(4, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-05', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 40000000, 49000000, 1, '2026-08-05 14:00:00', N'CT-2026-004', 'VALID', '2026-08-05 15:00:00', NULL),
(5, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-06', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 47000000, 57000000, 2, '2026-08-06 14:00:00', N'CT-2026-005', 'VALID', '2026-08-06 15:00:00', NULL),
(6, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-07', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 54000000, 65000000, 1, '2026-08-07 14:00:00', N'CT-2026-006', 'VALID', '2026-08-07 15:00:00', NULL),
(7, 'PASSED', N'TS. Trần Thị Mai', '2026-08-08', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 61000000, 73000000, 2, '2026-08-08 14:00:00', N'CT-2026-007', 'VALID', '2026-08-08 15:00:00', NULL),
(8, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-09', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 68000000, 81000000, 1, '2026-08-09 14:00:00', N'CT-2026-008', 'VALID', '2026-08-09 15:00:00', NULL),
(9, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-10', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 15000000, 29000000, 2, '2026-08-10 14:00:00', N'CT-2026-009', 'VALID', '2026-08-10 15:00:00', NULL),
(10, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-11', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 22000000, 27000000, 1, '2026-08-11 14:00:00', N'CT-2026-010', 'VALID', '2026-08-11 15:00:00', NULL),
(11, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-12', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 29000000, 35000000, 2, '2026-08-12 14:00:00', N'CT-2026-011', 'VALID', '2026-08-12 15:00:00', NULL),
(12, 'PASSED', N'TS. Trần Thị Mai', '2026-08-13', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 36000000, 43000000, 1, '2026-08-13 14:00:00', N'CT-2026-012', 'VALID', '2026-08-13 15:00:00', NULL),
(13, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-14', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 43000000, 51000000, 2, '2026-08-14 14:00:00', N'CT-2026-013', 'VALID', '2026-08-14 15:00:00', NULL),
(14, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-15', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 50000000, 59000000, 1, '2026-08-15 14:00:00', N'CT-2026-014', 'VALID', '2026-08-15 15:00:00', NULL),
(15, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-16', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 57000000, 67000000, 2, '2026-08-16 14:00:00', N'CT-2026-015', 'VALID', '2026-08-16 15:00:00', NULL),
(16, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-17', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 64000000, 75000000, 1, '2026-08-17 14:00:00', N'CT-2026-016', 'VALID', '2026-08-17 15:00:00', NULL),
(17, 'PASSED', N'TS. Trần Thị Mai', '2026-08-18', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 71000000, 83000000, 2, '2026-08-18 14:00:00', N'CT-2026-017', 'VALID', '2026-08-18 15:00:00', NULL),
(18, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-19', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 18000000, 31000000, 1, '2026-08-19 14:00:00', N'CT-2026-018', 'VALID', '2026-08-19 15:00:00', NULL),
(19, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-20', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 25000000, 39000000, 2, '2026-08-20 14:00:00', N'CT-2026-019', 'VALID', '2026-08-20 15:00:00', NULL),
(20, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-21', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 32000000, 37000000, 1, '2026-08-21 14:00:00', N'CT-2026-020', 'VALID', '2026-08-21 15:00:00', NULL),
(21, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-22', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 39000000, 45000000, 2, '2026-08-22 14:00:00', N'CT-2026-021', 'VALID', '2026-08-22 15:00:00', NULL),
(22, 'PASSED', N'TS. Trần Thị Mai', '2026-08-23', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu. Giá trị di sản: Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim. Đối chiếu: Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 46000000, 53000000, 1, '2026-08-23 14:00:00', N'CT-2026-022', 'VALID', '2026-08-23 15:00:00', NULL),
(23, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-24', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 53000000, 61000000, 2, '2026-08-24 14:00:00', N'CT-2026-023', 'VALID', '2026-08-24 15:00:00', NULL),
(24, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-25', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 60000000, 69000000, 1, '2026-08-25 14:00:00', N'CT-2026-024', 'VALID', '2026-08-25 15:00:00', NULL),
(25, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-01', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 67000000, 77000000, 2, '2026-08-01 14:00:00', N'CT-2026-025', 'VALID', '2026-08-01 15:00:00', NULL),
(26, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-02', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên. Giá trị di sản: Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý. Đối chiếu: Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 14000000, 25000000, 1, '2026-08-02 14:00:00', N'CT-2026-026', 'VALID', '2026-08-02 15:00:00', NULL),
(27, 'PASSED', N'TS. Trần Thị Mai', '2026-08-03', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 21000000, 33000000, 2, '2026-08-03 14:00:00', N'CT-2026-027', 'VALID', '2026-08-03 15:00:00', NULL),
(28, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-04', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 28000000, 41000000, 1, '2026-08-04 14:00:00', N'CT-2026-028', 'VALID', '2026-08-04 15:00:00', NULL),
(29, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-05', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 35000000, 49000000, 2, '2026-08-05 14:00:00', N'CT-2026-029', 'VALID', '2026-08-05 15:00:00', NULL),
(30, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-06', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ. Giá trị di sản: Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa. Đối chiếu: Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 42000000, 47000000, 1, '2026-08-06 14:00:00', N'CT-2026-030', 'VALID', '2026-08-06 15:00:00', NULL),
(31, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-07', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 49000000, 55000000, 2, '2026-08-07 14:00:00', N'CT-2026-031', 'VALID', '2026-08-07 15:00:00', NULL),
(32, 'PASSED', N'TS. Trần Thị Mai', '2026-08-08', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 56000000, 63000000, 1, '2026-08-08 14:00:00', N'CT-2026-032', 'VALID', '2026-08-08 15:00:00', NULL),
(33, 'PASSED', N'GS. Lê Văn Hùng', '2026-08-09', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống. Giá trị di sản: Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc. Đối chiếu: Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 63000000, 71000000, 2, '2026-08-09 14:00:00', N'CT-2026-033', 'VALID', '2026-08-09 15:00:00', NULL),
(34, 'PASSED', N'TS. Phạm Quốc Bảo', '2026-08-10', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (INTACT), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 70000000, 79000000, 1, '2026-08-10 14:00:00', N'CT-2026-034', 'VALID', '2026-08-10 15:00:00', NULL),
(35, 'PASSED', N'TS. Hoàng Minh Tuấn', '2026-08-11', N'Xác thực: Cổ vật thật nguyên bản (Authentic Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (SLIGHTLY_DAMAGED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 17000000, 27000000, 2, '2026-08-11 14:00:00', N'CT-2026-035', 'VALID', '2026-08-11 15:00:00', NULL),
(36, 'PASSED', N'GS. Nguyễn Văn Thắng', '2026-08-12', N'Xác thực: Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique). Phương pháp kiểm định: Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý. Giá trị di sản: Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm. Đối chiếu: Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á. Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt (RESTORED), đủ điều kiện cấp chứng thư bảo chứng độc bản.', 24000000, 35000000, 1, '2026-08-12 14:00:00', N'CT-2026-036', 'VALID', '2026-08-12 15:00:00', NULL),
(39, 'REJECTED', N'TS. Phạm Quốc Bảo', '2026-08-15', N'Biên bản giám định số BB-2026-039 (Giám định viên: TS. Phạm Quốc Bảo - Chuyên gia Cổ ngọc & Kim khí - Chứng chỉ Giám định Di sản số 042/GĐ): KẾT QUẢ KHÔNG ĐẠT. Cốt vật liệu và hoa văn có dấu hiệu can thiệp nhân tạo, không đồng nhất niên đại công bố. Tài liệu lai lịch chưa đủ căn cứ xác minh. Từ chối cấp chứng thư.', 0, 0, 2, '2026-08-15 14:00:00', NULL, NULL, NULL, NULL),
(40, 'REJECTED', N'TS. Hoàng Minh Tuấn', '2026-08-16', N'Biên bản giám định số BB-2026-040 (Giám định viên: TS. Hoàng Minh Tuấn - Nhà nghiên cứu Di sản Văn hóa - Giám định viên Hội Di sản Cổ vật (Số 056/GĐ)): KẾT QUẢ KHÔNG ĐẠT. Cốt vật liệu và hoa văn có dấu hiệu can thiệp nhân tạo, không đồng nhất niên đại công bố. Tài liệu lai lịch chưa đủ căn cứ xác minh. Từ chối cấp chứng thư.', 0, 0, 1, '2026-08-16 14:00:00', NULL, NULL, NULL, NULL);
GO

-- 9. auctions (Đúng 30 phiên đấu giá: 12 Active end < 24h, 8 Scheduled, 10 Ended/Cancelled)
INSERT INTO dbo.auctions (item_id, created_by, start_time, end_time, starting_price, reserve_price,
 min_bid_increment, current_highest_bid, highest_bidder_id, hammer_price, status, cancel_reason,
 closed_at, version, created_at) VALUES
(1, 1, DATEADD(HOUR, -2, GETDATE()), DATEADD(MINUTE, 25, GETDATE()), 19000000, 20900000, 500000, 21000000, 11, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(2, 2, DATEADD(HOUR, -4, GETDATE()), DATEADD(MINUTE, 45, GETDATE()), 26000000, 28600000, 600000, 29000000, 5, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(3, 1, DATEADD(HOUR, -6, GETDATE()), DATEADD(MINUTE, 80, GETDATE()), 33000000, 36300000, 800000, 37800000, 9, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(4, 2, DATEADD(HOUR, -8, GETDATE()), DATEADD(MINUTE, 135, GETDATE()), 40000000, 44000000, 1000000, 43000000, 13, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(5, 1, DATEADD(HOUR, -10, GETDATE()), DATEADD(MINUTE, 210, GETDATE()), 47000000, 51700000, 1100000, 51400000, 17, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(6, 2, DATEADD(HOUR, -12, GETDATE()), DATEADD(MINUTE, 315, GETDATE()), 54000000, 59400000, 1300000, 60500000, 12, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(7, 1, DATEADD(HOUR, -14, GETDATE()), DATEADD(MINUTE, 440, GETDATE()), 61000000, 67100000, 1500000, 70000000, 15, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(8, 2, DATEADD(HOUR, -16, GETDATE()), DATEADD(MINUTE, 590, GETDATE()), 68000000, 74800000, 1700000, 73100000, 20, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(9, 1, DATEADD(HOUR, -18, GETDATE()), DATEADD(MINUTE, 770, GETDATE()), 15000000, 16500000, 500000, 17000000, 23, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(10, 2, DATEADD(HOUR, -20, GETDATE()), DATEADD(MINUTE, 980, GETDATE()), 22000000, 24200000, 500000, 24500000, 19, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(11, 1, DATEADD(HOUR, -21, GETDATE()), DATEADD(MINUTE, 1190, GETDATE()), 29000000, 31900000, 700000, 33200000, 21, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(12, 2, DATEADD(HOUR, -22, GETDATE()), DATEADD(MINUTE, 1390, GETDATE()), 36000000, 39600000, 900000, 38700000, 27, NULL, 'ACTIVE', NULL, NULL, 0, DATEADD(DAY, -2, GETDATE())),
(13, 1, DATEADD(MINUTE, 45, GETDATE()), DATEADD(DAY, 1, DATEADD(MINUTE, 45, GETDATE())), 43000000, 47300000, 1000000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(14, 2, DATEADD(HOUR, 2, GETDATE()), DATEADD(DAY, 1, DATEADD(HOUR, 2, GETDATE())), 50000000, 55000000, 1200000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(15, 1, DATEADD(HOUR, 5, GETDATE()), DATEADD(DAY, 1, DATEADD(HOUR, 5, GETDATE())), 57000000, 62700000, 1400000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(16, 2, DATEADD(HOUR, 9, GETDATE()), DATEADD(DAY, 1, DATEADD(HOUR, 9, GETDATE())), 64000000, 70400000, 1600000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(17, 1, DATEADD(HOUR, 16, GETDATE()), DATEADD(DAY, 2, DATEADD(HOUR, 16, GETDATE())), 71000000, 78100000, 1700000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(18, 2, DATEADD(HOUR, 23, GETDATE()), DATEADD(DAY, 2, DATEADD(HOUR, 23, GETDATE())), 18000000, 19800000, 500000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(19, 1, DATEADD(DAY, 2, GETDATE()), DATEADD(DAY, 4, GETDATE()), 25000000, 27500000, 600000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(20, 2, DATEADD(DAY, 3, GETDATE()), DATEADD(DAY, 5, GETDATE()), 32000000, 35200000, 800000, 0, NULL, NULL, 'SCHEDULED', NULL, NULL, 0, DATEADD(DAY, -3, GETDATE())),
(21, 1, DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, -5, GETDATE()), 39000000, 42900000, 900000, 42600000, 12, 42600000, 'ENDED_SOLD', NULL, DATEADD(DAY, -5, GETDATE()), 1, DATEADD(DAY, -11, GETDATE())),
(22, 2, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, -8, GETDATE()), 46000000, 50600000, 1100000, 50400000, 13, 50400000, 'ENDED_SOLD', NULL, DATEADD(DAY, -8, GETDATE()), 1, DATEADD(DAY, -14, GETDATE())),
(23, 1, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, -11, GETDATE()), 53000000, 58300000, 1300000, 58200000, 15, 58200000, 'ENDED_SOLD', NULL, DATEADD(DAY, -11, GETDATE()), 1, DATEADD(DAY, -17, GETDATE())),
(24, 2, DATEADD(DAY, -17, GETDATE()), DATEADD(DAY, -14, GETDATE()), 60000000, 66000000, 1500000, 66000000, 17, 66000000, 'ENDED_SOLD', NULL, DATEADD(DAY, -14, GETDATE()), 1, DATEADD(DAY, -20, GETDATE())),
(25, 1, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -17, GETDATE()), 67000000, 73700000, 1600000, 73400000, 19, 73400000, 'ENDED_SOLD', NULL, DATEADD(DAY, -17, GETDATE()), 1, DATEADD(DAY, -23, GETDATE())),
(26, 2, DATEADD(DAY, -23, GETDATE()), DATEADD(DAY, -20, GETDATE()), 14000000, 15400000, 500000, 16000000, 20, 16000000, 'ENDED_SOLD', NULL, DATEADD(DAY, -20, GETDATE()), 1, DATEADD(DAY, -26, GETDATE())),
(27, 1, DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, -15, GETDATE()), 21000000, 23100000, 500000, 0, NULL, NULL, 'ENDED_NO_BIDS', NULL, DATEADD(DAY, -15, GETDATE()), 1, DATEADD(DAY, -22, GETDATE())),
(28, 2, DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, -15, GETDATE()), 28000000, 30800000, 700000, 0, NULL, NULL, 'ENDED_NO_BIDS', NULL, DATEADD(DAY, -15, GETDATE()), 1, DATEADD(DAY, -22, GETDATE())),
(29, 1, DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -13, GETDATE()), 35000000, 38500000, 800000, 35800000, 19, NULL, 'ENDED_RESERVE_NOT_MET', NULL, DATEADD(DAY, -13, GETDATE()), 1, DATEADD(DAY, -20, GETDATE())),
(30, 2, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, -11, GETDATE()), 42000000, 46200000, 1000000, 0, NULL, NULL, 'CANCELLED', N'Hủy theo yêu cầu của hội đồng giám định', DATEADD(DAY, -12, GETDATE()), 1, DATEADD(DAY, -18, GETDATE()));
GO

-- 10. bids
INSERT INTO dbo.bids (auction_id, bidder_id, bid_amount, bid_time, status) VALUES
(1, 4, 19500000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(1, 5, 20000000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(1, 7, 20500000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(1, 9, 21000000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(2, 5, 26600000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(2, 7, 27200000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(2, 9, 27800000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(2, 11, 28400000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(2, 12, 29000000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(3, 7, 33800000, DATEADD(HOUR, -4, GETDATE()), 'VALID'),
(3, 9, 34600000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(3, 11, 35400000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(3, 12, 36200000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(3, 13, 37000000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(3, 7, 37800000, DATEADD(HOUR, -1, GETDATE()), 'VALID'),
(4, 9, 41000000, DATEADD(HOUR, -6, GETDATE()), 'VALID'),
(4, 11, 42000000, DATEADD(HOUR, -4, GETDATE()), 'VALID'),
(4, 12, 43000000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(5, 11, 48100000, DATEADD(HOUR, -8, GETDATE()), 'VALID'),
(5, 12, 49200000, DATEADD(HOUR, -6, GETDATE()), 'VALID'),
(5, 13, 50300000, DATEADD(HOUR, -4, GETDATE()), 'VALID'),
(5, 15, 51400000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(6, 12, 55300000, DATEADD(HOUR, -10, GETDATE()), 'VALID'),
(6, 13, 56600000, DATEADD(HOUR, -8, GETDATE()), 'VALID'),
(6, 15, 57900000, DATEADD(HOUR, -6, GETDATE()), 'VALID'),
(6, 17, 59200000, DATEADD(HOUR, -4, GETDATE()), 'VALID'),
(6, 19, 60500000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(7, 13, 62500000, DATEADD(HOUR, -12, GETDATE()), 'VALID'),
(7, 15, 64000000, DATEADD(HOUR, -10, GETDATE()), 'VALID'),
(7, 17, 65500000, DATEADD(HOUR, -8, GETDATE()), 'VALID'),
(7, 19, 67000000, DATEADD(HOUR, -6, GETDATE()), 'VALID'),
(7, 20, 68500000, DATEADD(HOUR, -4, GETDATE()), 'VALID'),
(7, 13, 70000000, DATEADD(HOUR, -2, GETDATE()), 'VALID'),
(8, 15, 69700000, DATEADD(HOUR, -14, GETDATE()), 'VALID'),
(8, 17, 71400000, DATEADD(HOUR, -12, GETDATE()), 'VALID'),
(8, 19, 73100000, DATEADD(HOUR, -10, GETDATE()), 'VALID'),
(9, 17, 15500000, DATEADD(HOUR, -16, GETDATE()), 'VALID'),
(9, 19, 16000000, DATEADD(HOUR, -14, GETDATE()), 'VALID'),
(9, 20, 16500000, DATEADD(HOUR, -12, GETDATE()), 'VALID'),
(9, 21, 17000000, DATEADD(HOUR, -10, GETDATE()), 'VALID'),
(10, 19, 22500000, DATEADD(HOUR, -18, GETDATE()), 'VALID'),
(10, 20, 23000000, DATEADD(HOUR, -16, GETDATE()), 'VALID'),
(10, 21, 23500000, DATEADD(HOUR, -14, GETDATE()), 'VALID'),
(10, 23, 24000000, DATEADD(HOUR, -12, GETDATE()), 'VALID'),
(10, 25, 24500000, DATEADD(HOUR, -10, GETDATE()), 'VALID'),
(11, 20, 29700000, DATEADD(HOUR, -19, GETDATE()), 'VALID'),
(11, 21, 30400000, DATEADD(HOUR, -17, GETDATE()), 'VALID'),
(11, 23, 31100000, DATEADD(HOUR, -15, GETDATE()), 'VALID'),
(11, 25, 31800000, DATEADD(HOUR, -13, GETDATE()), 'VALID'),
(11, 27, 32500000, DATEADD(HOUR, -11, GETDATE()), 'VALID'),
(11, 20, 33200000, DATEADD(HOUR, -9, GETDATE()), 'VALID'),
(12, 21, 36900000, DATEADD(HOUR, -20, GETDATE()), 'VALID'),
(12, 23, 37800000, DATEADD(HOUR, -18, GETDATE()), 'VALID'),
(12, 25, 38700000, DATEADD(HOUR, -16, GETDATE()), 'VALID'),
(21, 5, 39900000, DATEADD(DAY, -7, GETDATE()), 'VALID'),
(21, 7, 40800000, DATEADD(DAY, -7, GETDATE()), 'VALID'),
(21, 9, 41700000, DATEADD(DAY, -6, GETDATE()), 'VALID'),
(21, 11, 42600000, DATEADD(DAY, -6, GETDATE()), 'VALID'),
(22, 7, 47100000, DATEADD(DAY, -10, GETDATE()), 'VALID'),
(22, 9, 48200000, DATEADD(DAY, -10, GETDATE()), 'VALID'),
(22, 11, 49300000, DATEADD(DAY, -9, GETDATE()), 'VALID'),
(22, 12, 50400000, DATEADD(DAY, -9, GETDATE()), 'VALID'),
(23, 9, 54300000, DATEADD(DAY, -13, GETDATE()), 'VALID'),
(23, 11, 55600000, DATEADD(DAY, -13, GETDATE()), 'VALID'),
(23, 12, 56900000, DATEADD(DAY, -12, GETDATE()), 'VALID'),
(23, 13, 58200000, DATEADD(DAY, -12, GETDATE()), 'VALID'),
(24, 11, 61500000, DATEADD(DAY, -16, GETDATE()), 'VALID'),
(24, 12, 63000000, DATEADD(DAY, -16, GETDATE()), 'VALID'),
(24, 13, 64500000, DATEADD(DAY, -15, GETDATE()), 'VALID'),
(24, 15, 66000000, DATEADD(DAY, -15, GETDATE()), 'VALID'),
(25, 12, 68600000, DATEADD(DAY, -19, GETDATE()), 'VALID'),
(25, 13, 70200000, DATEADD(DAY, -19, GETDATE()), 'VALID'),
(25, 15, 71800000, DATEADD(DAY, -18, GETDATE()), 'VALID'),
(25, 17, 73400000, DATEADD(DAY, -18, GETDATE()), 'VALID'),
(26, 13, 14500000, DATEADD(DAY, -22, GETDATE()), 'VALID'),
(26, 15, 15000000, DATEADD(DAY, -22, GETDATE()), 'VALID'),
(26, 17, 15500000, DATEADD(DAY, -21, GETDATE()), 'VALID'),
(26, 19, 16000000, DATEADD(DAY, -21, GETDATE()), 'VALID'),
(29, 19, 35800000, DATEADD(DAY, -14, GETDATE()), 'VALID');
GO

-- 11. watchlists
INSERT INTO dbo.watchlists (bidder_id, total_items, updated_at) VALUES
(3, 2, GETDATE()),
(4, 3, GETDATE()),
(5, 4, GETDATE()),
(7, 2, GETDATE()),
(9, 3, GETDATE()),
(11, 4, GETDATE()),
(12, 2, GETDATE()),
(13, 3, GETDATE()),
(15, 4, GETDATE()),
(17, 2, GETDATE()),
(19, 3, GETDATE()),
(20, 4, GETDATE()),
(21, 2, GETDATE()),
(23, 3, GETDATE()),
(25, 4, GETDATE());
GO

-- 12. watchlist_items
INSERT INTO dbo.watchlist_items (watchlist_id, auction_id, added_at) VALUES
(1, 1, DATEADD(HOUR, -2, GETDATE())),
(1, 2, DATEADD(HOUR, -2, GETDATE())),
(2, 2, DATEADD(HOUR, -4, GETDATE())),
(2, 3, DATEADD(HOUR, -4, GETDATE())),
(2, 4, DATEADD(HOUR, -4, GETDATE())),
(3, 3, DATEADD(HOUR, -6, GETDATE())),
(3, 4, DATEADD(HOUR, -6, GETDATE())),
(3, 5, DATEADD(HOUR, -6, GETDATE())),
(3, 6, DATEADD(HOUR, -6, GETDATE())),
(4, 4, DATEADD(HOUR, -8, GETDATE())),
(4, 5, DATEADD(HOUR, -8, GETDATE())),
(5, 5, DATEADD(HOUR, -10, GETDATE())),
(5, 6, DATEADD(HOUR, -10, GETDATE())),
(5, 7, DATEADD(HOUR, -10, GETDATE())),
(6, 6, DATEADD(HOUR, -12, GETDATE())),
(6, 7, DATEADD(HOUR, -12, GETDATE())),
(6, 8, DATEADD(HOUR, -12, GETDATE())),
(6, 9, DATEADD(HOUR, -12, GETDATE())),
(7, 7, DATEADD(HOUR, -14, GETDATE())),
(7, 8, DATEADD(HOUR, -14, GETDATE())),
(8, 8, DATEADD(HOUR, -16, GETDATE())),
(8, 9, DATEADD(HOUR, -16, GETDATE())),
(8, 10, DATEADD(HOUR, -16, GETDATE())),
(9, 9, DATEADD(HOUR, -18, GETDATE())),
(9, 10, DATEADD(HOUR, -18, GETDATE())),
(9, 11, DATEADD(HOUR, -18, GETDATE())),
(9, 12, DATEADD(HOUR, -18, GETDATE())),
(10, 10, DATEADD(HOUR, -20, GETDATE())),
(10, 11, DATEADD(HOUR, -20, GETDATE())),
(11, 11, DATEADD(HOUR, -22, GETDATE())),
(11, 12, DATEADD(HOUR, -22, GETDATE())),
(11, 13, DATEADD(HOUR, -22, GETDATE())),
(12, 12, DATEADD(HOUR, -24, GETDATE())),
(12, 13, DATEADD(HOUR, -24, GETDATE())),
(12, 14, DATEADD(HOUR, -24, GETDATE())),
(12, 15, DATEADD(HOUR, -24, GETDATE())),
(13, 13, DATEADD(HOUR, -26, GETDATE())),
(13, 14, DATEADD(HOUR, -26, GETDATE())),
(14, 14, DATEADD(HOUR, -28, GETDATE())),
(14, 15, DATEADD(HOUR, -28, GETDATE())),
(14, 16, DATEADD(HOUR, -28, GETDATE())),
(15, 15, DATEADD(HOUR, -30, GETDATE())),
(15, 16, DATEADD(HOUR, -30, GETDATE())),
(15, 17, DATEADD(HOUR, -30, GETDATE())),
(15, 18, DATEADD(HOUR, -30, GETDATE()));
GO

-- 13. orders (6 đơn hàng đa dạng trạng thái để kiểm thử nghiệp vụ)
INSERT INTO dbo.orders (auction_id, buyer_id, hammer_price, buyers_premium, shipping_fee, total_amount,
 payment_deadline, status, delivered_at, completed_at, created_at) VALUES
(21, 12, 42600000, 4260000, 350000, 47210000, DATEADD(DAY, -10, GETDATE()), 'COMPLETED', DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -14, GETDATE())),
(22, 13, 50400000, 5040000, 400000, 55840000, DATEADD(DAY, -9, GETDATE()), 'DELIVERED', DATEADD(DAY, -7, GETDATE()), NULL, DATEADD(DAY, -13, GETDATE())),
(23, 15, 58200000, 5820000, 450000, 64470000, DATEADD(DAY, -8, GETDATE()), 'SHIPPING', NULL, NULL, DATEADD(DAY, -12, GETDATE())),
(24, 17, 66000000, 6600000, 500000, 73100000, DATEADD(DAY, -7, GETDATE()), 'PAID', NULL, NULL, DATEADD(DAY, -11, GETDATE())),
(25, 19, 73400000, 7340000, 550000, 81290000, DATEADD(DAY, -6, GETDATE()), 'PENDING_PAYMENT', NULL, NULL, DATEADD(DAY, -10, GETDATE())),
(26, 20, 16000000, 1600000, 350000, 17950000, DATEADD(DAY, -5, GETDATE()), 'DISPUTED', DATEADD(DAY, -3, GETDATE()), NULL, DATEADD(DAY, -9, GETDATE()));
GO

-- Cập nhật status hiện vật tương ứng sau khi mở phiên và tạo đơn
UPDATE dbo.antique_items SET status = 'IN_AUCTION' WHERE item_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20);
UPDATE dbo.antique_items SET status = 'SOLD_DELIVERED' WHERE item_id IN (21);
UPDATE dbo.antique_items SET status = 'SOLD_DELIVERING' WHERE item_id IN (22,23,24);
UPDATE dbo.antique_items SET status = 'RESERVED_PENDING_PAYMENT' WHERE item_id IN (25);
UPDATE dbo.antique_items SET status = 'AVAILABLE' WHERE item_id IN (26,27,28,29,30);
UPDATE dbo.antique_items SET status = 'APPRAISED_PASSED' WHERE item_id IN (31,32,33,34,35,36);
UPDATE dbo.antique_items SET status = 'DRAFT' WHERE item_id IN (37,38);
UPDATE dbo.antique_items SET status = 'APPRAISED_REJECTED' WHERE item_id IN (39,40);
GO

-- 14. payments
INSERT INTO dbo.payments (order_id, original_payment_id, type, amount, status, gateway_txn_id, created_at) VALUES
(1, NULL, 'CHARGE', 47210000, 'SUCCESS', 'GW-TXN-P001-01', DATEADD(DAY, -11, GETDATE())),
(2, NULL, 'CHARGE', 55840000, 'SUCCESS', 'GW-TXN-P002-01', DATEADD(DAY, -10, GETDATE())),
(3, NULL, 'CHARGE', 64470000, 'SUCCESS', 'GW-TXN-P003-01', DATEADD(DAY, -9, GETDATE())),
(4, NULL, 'CHARGE', 73100000, 'SUCCESS', 'GW-TXN-P004-01', DATEADD(DAY, -8, GETDATE())),
(5, NULL, 'CHARGE', 81290000, 'PENDING', 'GW-TXN-P005-01', DATEADD(DAY, -3, GETDATE())),
(6, NULL, 'CHARGE', 17950000, 'SUCCESS', 'GW-TXN-P006-01', DATEADD(DAY, -6, GETDATE()));
GO

INSERT INTO dbo.payments (order_id, original_payment_id, type, amount, status, gateway_txn_id, created_at) VALUES
(6, 6, 'REFUND', 17950000, 'PENDING', 'GW-TXN-P006-REF', GETDATE());
GO

-- 15. shipments
INSERT INTO dbo.shipments (order_id, tracking_code, packaging_info, insured_value, status, shipped_at, delivered_at, created_at) VALUES
(1, N'AB-SHIP-0001', N'Hòm chuyên dụng có niêm phong', 42600000, 'DELIVERED', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -8, GETDATE())),
(2, N'AB-SHIP-0002', N'Hòm chuyên dụng có niêm phong', 50400000, 'DELIVERED', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -8, GETDATE())),
(3, N'AB-SHIP-0003', N'Thùng gỗ chuyên dụng chống sốc', 58200000, 'IN_TRANSIT', DATEADD(DAY, -2, GETDATE()), NULL, DATEADD(DAY, -3, GETDATE())),
(4, N'AB-SHIP-0004', N'Đang chuẩn bị hộp bảo vệ & xốp định hình', 66000000, 'PREPARING', NULL, NULL, DATEADD(DAY, -3, GETDATE())),
(6, N'AB-SHIP-0006', N'Hòm chuyên dụng có niêm phong', 16000000, 'DELIVERED', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -8, GETDATE()));
GO

-- 16. disputes
INSERT INTO dbo.disputes (order_id, bidder_id, reason, evidence_url, status, resolution, filed_at, resolved_at) VALUES
(6, 20, N'Hiện vật khi nhận có vết nứt nhỏ ở chân đế', '/uploads/disputes/order6.jpg', 'PENDING', NULL, DATEADD(DAY, -2, GETDATE()), NULL);
GO

-- 17. notifications
INSERT INTO dbo.notifications (recipient_id, title, content, type, is_read, created_at) VALUES
(3, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(4, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(5, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(7, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(9, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(10, N'Yêu cầu bổ sung KYC', N'Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.', 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE())),
(11, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(12, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(13, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(15, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(16, N'Yêu cầu bổ sung KYC', N'Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.', 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE())),
(17, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(18, N'Yêu cầu bổ sung KYC', N'Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.', 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE())),
(19, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(20, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(21, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(23, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(25, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(26, N'Yêu cầu bổ sung KYC', N'Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.', 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE())),
(27, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(28, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(29, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(30, N'Yêu cầu bổ sung KYC', N'Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.', 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE())),
(31, N'KYC được phê duyệt', N'Hồ sơ định danh của bạn đã được xác minh thành công.', 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE())),
(12, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #21. Vui lòng thanh toán đơn #1.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(13, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #22. Vui lòng thanh toán đơn #2.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(15, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #23. Vui lòng thanh toán đơn #3.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(17, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #24. Vui lòng thanh toán đơn #4.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(19, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #25. Vui lòng thanh toán đơn #5.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(20, N'Chúc mừng thắng phiên!', N'Bạn đã đấu giá thành công phiên #26. Vui lòng thanh toán đơn #6.', 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE())),
(4, N'Phiên đang diễn ra', N'Phiên #1 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(5, N'Phiên đang diễn ra', N'Phiên #2 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(7, N'Phiên đang diễn ra', N'Phiên #3 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(9, N'Phiên đang diễn ra', N'Phiên #4 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(11, N'Phiên đang diễn ra', N'Phiên #5 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(12, N'Phiên đang diễn ra', N'Phiên #6 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(13, N'Phiên đang diễn ra', N'Phiên #7 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(15, N'Phiên đang diễn ra', N'Phiên #8 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(17, N'Phiên đang diễn ra', N'Phiên #9 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(19, N'Phiên đang diễn ra', N'Phiên #10 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(20, N'Phiên đang diễn ra', N'Phiên #11 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE())),
(21, N'Phiên đang diễn ra', N'Phiên #12 sắp kết thúc trong hôm nay. Đừng bỏ lỡ!', 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE()));
GO

-- 18. audit_logs
INSERT INTO dbo.audit_logs (actor_id, action, entity_type, entity_id, detail, created_at) VALUES
(1, 'USER_CREATE', 'USER', 1, N'Khởi tạo hệ thống quản trị', DATEADD(DAY, -30, GETDATE())),
(1, 'CATEGORY_CREATE', 'CATEGORY', 1, N'Khởi tạo 5 danh mục cổ vật chuẩn', DATEADD(DAY, -28, GETDATE())),
(1, 'APPRAISAL_PASS', 'ITEM', 1, N'Cấp chứng thư giám định cho cổ vật', DATEADD(DAY, -25, GETDATE())),
(1, 'AUCTION_CREATE', 'AUCTION', 1, N'Mở phiên đấu giá mới', DATEADD(DAY, -15, GETDATE())),
(1, 'ORDER_COMPLETE', 'ORDER', 1, N'Hoàn tất đơn hàng #1', DATEADD(DAY, -6, GETDATE())),
(NULL, 'SYSTEM_SEED', 'SYSTEM', 0, N'Nạp dữ liệu mẫu chuẩn: 30 phiên đấu giá, 5 danh mục', GETDATE());
GO

-- =========================================================================
-- KIỂM TRA SỐ LƯỢNG BẢNG DỮ LIỆU
-- =========================================================================
SELECT N'users' AS bang, COUNT(*) AS so_dong FROM dbo.users
UNION ALL SELECT N'bidder_profiles', COUNT(*) FROM dbo.bidder_profiles
UNION ALL SELECT N'verification_documents', COUNT(*) FROM dbo.verification_documents
UNION ALL SELECT N'categories', COUNT(*) FROM dbo.categories
UNION ALL SELECT N'antique_items', COUNT(*) FROM dbo.antique_items
UNION ALL SELECT N'item_images', COUNT(*) FROM dbo.item_images
UNION ALL SELECT N'provenance_records', COUNT(*) FROM dbo.provenance_records
UNION ALL SELECT N'appraisal_certificates', COUNT(*) FROM dbo.appraisal_certificates
UNION ALL SELECT N'auctions', COUNT(*) FROM dbo.auctions
UNION ALL SELECT N'bids', COUNT(*) FROM dbo.bids
UNION ALL SELECT N'watchlists', COUNT(*) FROM dbo.watchlists
UNION ALL SELECT N'watchlist_items', COUNT(*) FROM dbo.watchlist_items
UNION ALL SELECT N'orders', COUNT(*) FROM dbo.orders
UNION ALL SELECT N'payments', COUNT(*) FROM dbo.payments
UNION ALL SELECT N'shipments', COUNT(*) FROM dbo.shipments
UNION ALL SELECT N'disputes', COUNT(*) FROM dbo.disputes
UNION ALL SELECT N'notifications', COUNT(*) FROM dbo.notifications
UNION ALL SELECT N'audit_logs', COUNT(*) FROM dbo.audit_logs
ORDER BY bang;
GO