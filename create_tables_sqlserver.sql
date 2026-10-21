-- =========================================================================
-- KỊCH BẢN TẠO CƠ SỞ DỮ LIỆU VÀ 18 BẢNG CHO SÀN ĐẤU GIÁ ĐỒ CỔ TRỰC TUYẾN
-- HỆ THỐNG: AntiqueBid (Môn học: Phân tích & Thiết kế HTTTQL - Phương án 2)
-- DBMS: Microsoft SQL Server
-- =========================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AntiqueBidDB')
BEGIN
    CREATE DATABASE AntiqueBidDB;
END;
GO

USE AntiqueBidDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =========================================================================
-- CỤM 1: NGƯỜI DÙNG & XÁC MINH DANH TÍNH (P1)
-- =========================================================================

-- 1. BẢNG users (Tài khoản người dùng toàn hệ thống)
IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        user_id BIGINT IDENTITY(1,1) NOT NULL,
        email VARCHAR(255) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name NVARCHAR(150) NOT NULL,
        phone VARCHAR(20) NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'BIDDER',
        is_locked BIT NOT NULL DEFAULT 0,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_users PRIMARY KEY CLUSTERED (user_id),
        CONSTRAINT uq_users_email UNIQUE (email),
        CONSTRAINT ck_users_role CHECK (role IN ('BIDDER', 'ADMIN'))
    );
END;
GO

-- 2. BẢNG bidder_profiles (Hồ sơ khách đấu giá - Kế thừa 1:1 từ users)
IF OBJECT_ID(N'dbo.bidder_profiles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bidder_profiles (
        user_id BIGINT NOT NULL,
        citizen_id VARCHAR(20) NULL,
        kyc_status VARCHAR(20) NOT NULL DEFAULT 'NOT_SUBMITTED',
        violation_count INT NOT NULL DEFAULT 0,
        shipping_address NVARCHAR(500) NULL,
        CONSTRAINT pk_bidder_profiles PRIMARY KEY CLUSTERED (user_id),
        CONSTRAINT fk_bidder_profiles_users FOREIGN KEY (user_id) 
            REFERENCES dbo.users(user_id) ON DELETE CASCADE,
        CONSTRAINT ck_bidder_profiles_kyc CHECK (kyc_status IN ('NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'REJECTED')),
        CONSTRAINT ck_bidder_profiles_violation CHECK (violation_count >= 0)
    );
END;
GO

-- 3. BẢNG verification_documents (Giấy tờ xác minh danh tính KYC của Bidder qua CCCD gắn chip)
IF OBJECT_ID(N'dbo.verification_documents', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.verification_documents (
        doc_id BIGINT IDENTITY(1,1) NOT NULL,
        bidder_id BIGINT NOT NULL,
        doc_type VARCHAR(30) NOT NULL DEFAULT 'CITIZEN_ID',
        citizen_id VARCHAR(20) NULL,
        issue_date DATE NULL,
        issue_place NVARCHAR(255) NULL,
        file_url VARCHAR(500) NOT NULL,
        file_url_back VARCHAR(500) NULL,
        submitted_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        review_note NVARCHAR(500) NULL,
        CONSTRAINT pk_verification_documents PRIMARY KEY CLUSTERED (doc_id),
        CONSTRAINT fk_verif_docs_bidder FOREIGN KEY (bidder_id) 
            REFERENCES dbo.bidder_profiles(user_id) ON DELETE CASCADE,
        CONSTRAINT ck_verif_docs_type CHECK (doc_type IN ('CITIZEN_ID'))
    );
END;
GO

-- =========================================================================
-- CỤM 2: HIỆN VẬT & GIÁM ĐỊNH CHỨNG THƯ (P2)
-- =========================================================================

-- 4. BẢNG categories (Danh mục hiện vật đồ cổ)
IF OBJECT_ID(N'dbo.categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.categories (
        category_id BIGINT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        description NVARCHAR(500) NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_categories PRIMARY KEY CLUSTERED (category_id),
        CONSTRAINT uq_categories_name UNIQUE (name)
    );
END;
GO

-- 5. BẢNG antique_items (Hiện vật đồ cổ độc bản thuộc sở hữu của sàn)
IF OBJECT_ID(N'dbo.antique_items', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.antique_items (
        item_id BIGINT IDENTITY(1,1) NOT NULL,
        item_code VARCHAR(30) NOT NULL,
        name NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NULL,
        era_from INT NOT NULL,
        era_to INT NOT NULL,
        material NVARCHAR(100) NOT NULL,
        dimensions NVARCHAR(200) NOT NULL,
        item_condition VARCHAR(30) NOT NULL,
        status VARCHAR(35) NOT NULL DEFAULT 'DRAFT',
        is_archived BIT NOT NULL DEFAULT 0,
        version BIGINT NOT NULL DEFAULT 0,
        category_id BIGINT NOT NULL,
        created_by BIGINT NOT NULL,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_antique_items PRIMARY KEY CLUSTERED (item_id),
        CONSTRAINT uq_antique_items_code UNIQUE (item_code),
        CONSTRAINT ck_antique_items_era CHECK (era_from <= era_to),
        CONSTRAINT ck_antique_items_condition CHECK (item_condition IN ('INTACT', 'SLIGHTLY_DAMAGED', 'RESTORED', 'DAMAGED')),
        CONSTRAINT ck_antique_items_status CHECK (status IN (
            'DRAFT', 'APPRAISED_PASSED', 'APPRAISED_REJECTED', 
            'AVAILABLE', 'IN_AUCTION', 'RESERVED_PENDING_PAYMENT', 
            'SOLD_DELIVERING', 'SOLD_DELIVERED'
        )),
        CONSTRAINT fk_antique_items_category FOREIGN KEY (category_id) 
            REFERENCES dbo.categories(category_id),
        CONSTRAINT fk_antique_items_created_by FOREIGN KEY (created_by) 
            REFERENCES dbo.users(user_id)
    );
END;
GO

-- 6. BẢNG item_images (Tệp hình ảnh hiện vật: 1 - 5 ảnh)
IF OBJECT_ID(N'dbo.item_images', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.item_images (
        image_id BIGINT IDENTITY(1,1) NOT NULL,
        item_id BIGINT NOT NULL,
        file_path VARCHAR(500) NOT NULL,
        mime_type VARCHAR(30) NOT NULL,
        file_size BIGINT NOT NULL,
        is_primary BIT NOT NULL DEFAULT 0,
        display_order TINYINT NOT NULL,
        uploaded_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_item_images PRIMARY KEY CLUSTERED (image_id),
        CONSTRAINT fk_item_images_item FOREIGN KEY (item_id) 
            REFERENCES dbo.antique_items(item_id) ON DELETE CASCADE,
        CONSTRAINT ck_item_images_mime CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp')),
        CONSTRAINT ck_item_images_size CHECK (file_size > 0 AND file_size <= 5242880),
        CONSTRAINT ck_item_images_order CHECK (display_order BETWEEN 1 AND 5),
        CONSTRAINT uq_item_images_order UNIQUE (item_id, display_order)
    );
END;
GO

-- Ràng buộc BR05: Mỗi hiện vật chỉ có đúng 1 ảnh đại diện (is_primary = 1)
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'uq_item_images_primary')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX uq_item_images_primary 
    ON dbo.item_images(item_id) 
    WHERE is_primary = 1;
END;
GO

-- 7. BẢNG provenance_records (Hồ sơ nguồn gốc xuất xứ - Quan hệ 1:1 với hiện vật)
IF OBJECT_ID(N'dbo.provenance_records', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.provenance_records (
        provenance_id BIGINT IDENTITY(1,1) NOT NULL,
        item_id BIGINT NOT NULL,
        origin NVARCHAR(300) NOT NULL,
        acquisition_source NVARCHAR(300) NOT NULL,
        ownership_history NVARCHAR(MAX) NULL,
        supporting_documents NVARCHAR(MAX) NULL,
        CONSTRAINT pk_provenance_records PRIMARY KEY CLUSTERED (provenance_id),
        CONSTRAINT uq_provenance_records_item UNIQUE (item_id),
        CONSTRAINT fk_provenance_records_item FOREIGN KEY (item_id) 
            REFERENCES dbo.antique_items(item_id) ON DELETE CASCADE
    );
END;
GO

-- 8. BẢNG appraisal_certificates (Bản ghi giám định và Chứng thư cổ vật - BR06, UC09)
IF OBJECT_ID(N'dbo.appraisal_certificates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.appraisal_certificates (
        appraisal_id BIGINT IDENTITY(1,1) NOT NULL,
        item_id BIGINT NOT NULL,
        result VARCHAR(20) NOT NULL,
        appraiser_name NVARCHAR(150) NOT NULL,
        appraisal_date DATE NOT NULL,
        note NVARCHAR(1000) NULL,
        estimate_low DECIMAL(18,2) NOT NULL,
        estimate_high DECIMAL(18,2) NOT NULL,
        recorded_by BIGINT NOT NULL,
        recorded_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        certificate_no VARCHAR(50) NULL,
        certificate_status VARCHAR(20) NULL,
        issued_at DATETIME2(3) NULL,
        revoked_at DATETIME2(3) NULL,
        CONSTRAINT pk_appraisal_certificates PRIMARY KEY CLUSTERED (appraisal_id),
        CONSTRAINT fk_appraisal_item FOREIGN KEY (item_id) 
            REFERENCES dbo.antique_items(item_id),
        CONSTRAINT fk_appraisal_recorded_by FOREIGN KEY (recorded_by) 
            REFERENCES dbo.users(user_id),
        CONSTRAINT ck_appraisal_result CHECK (result IN ('PASSED', 'REJECTED')),
        CONSTRAINT ck_appraisal_estimate CHECK (estimate_low >= 0 AND estimate_high >= estimate_low),
        CONSTRAINT ck_appraisal_cert_status CHECK (certificate_status IN ('VALID', 'REVOKED')),
        CONSTRAINT uq_appraisal_cert_no UNIQUE (certificate_no)
    );
END;
GO

-- Ràng buộc BR06d: Mỗi hiện vật chỉ có tối đa 1 chứng thư hợp lệ (VALID)
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'uq_appraisal_cert_valid')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX uq_appraisal_cert_valid 
    ON dbo.appraisal_certificates(item_id) 
    WHERE certificate_status = 'VALID';
END;
GO

-- =========================================================================
-- CỤM 3: ĐẤU GIÁ, ĐẶT GIÁ & THEO DÕI (P3, P4)
-- =========================================================================

-- 9. BẢNG auctions (Phiên đấu giá cổ vật kiểu Anh)
IF OBJECT_ID(N'dbo.auctions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.auctions (
        auction_id BIGINT IDENTITY(1,1) NOT NULL,
        item_id BIGINT NOT NULL,
        created_by BIGINT NOT NULL,
        start_time DATETIME2(3) NOT NULL,
        end_time DATETIME2(3) NOT NULL,
        starting_price DECIMAL(18,2) NOT NULL,
        reserve_price DECIMAL(18,2) NOT NULL,
        min_bid_increment DECIMAL(18,2) NOT NULL,
        current_highest_bid DECIMAL(18,2) NOT NULL DEFAULT 0,
        highest_bidder_id BIGINT NULL,
        hammer_price DECIMAL(18,2) NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
        cancel_reason NVARCHAR(500) NULL,
        closed_at DATETIME2(3) NULL,
        version INT NOT NULL DEFAULT 0,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_auctions PRIMARY KEY CLUSTERED (auction_id),
        CONSTRAINT fk_auctions_item FOREIGN KEY (item_id) 
            REFERENCES dbo.antique_items(item_id),
        CONSTRAINT fk_auctions_created_by FOREIGN KEY (created_by) 
            REFERENCES dbo.users(user_id),
        CONSTRAINT fk_auctions_highest_bidder FOREIGN KEY (highest_bidder_id) 
            REFERENCES dbo.bidder_profiles(user_id),
        CONSTRAINT ck_auctions_time CHECK (end_time > start_time),
        CONSTRAINT ck_auctions_price CHECK (starting_price > 0 AND reserve_price >= starting_price AND min_bid_increment > 0),
        CONSTRAINT ck_auctions_status CHECK (status IN (
            'DRAFT', 'SCHEDULED', 'ACTIVE', 
            'ENDED_SOLD', 'ENDED_RESERVE_NOT_MET', 'ENDED_NO_BIDS', 'CANCELLED'
        ))
    );
END;
GO

-- Ràng buộc BR12: Mỗi hiện vật chỉ có tối đa một phiên đấu giá sống (chưa kết thúc)
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'uq_auctions_item_live')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX uq_auctions_item_live 
    ON dbo.auctions(item_id) 
    WHERE status IN ('DRAFT', 'SCHEDULED', 'ACTIVE');
END;
GO

-- 10. BẢNG bids (Lịch sử các lượt đặt giá)
IF OBJECT_ID(N'dbo.bids', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bids (
        bid_id BIGINT IDENTITY(1,1) NOT NULL,
        auction_id BIGINT NOT NULL,
        bidder_id BIGINT NOT NULL,
        bid_amount DECIMAL(18,2) NOT NULL,
        bid_time DATETIME2(6) NOT NULL DEFAULT SYSUTCDATETIME(),
        status VARCHAR(20) NOT NULL DEFAULT 'VALID',
        CONSTRAINT pk_bids PRIMARY KEY CLUSTERED (bid_id),
        CONSTRAINT fk_bids_auction FOREIGN KEY (auction_id) 
            REFERENCES dbo.auctions(auction_id),
        CONSTRAINT fk_bids_bidder FOREIGN KEY (bidder_id) 
            REFERENCES dbo.bidder_profiles(user_id),
        CONSTRAINT ck_bids_amount CHECK (bid_amount > 0),
        CONSTRAINT ck_bids_status CHECK (status IN ('VALID', 'REJECTED')),
        CONSTRAINT uq_bids_auction_amount UNIQUE (auction_id, bid_amount)
    );
END;
GO

-- Index hỗ trợ lấy lượt trả giá cao nhất nhanh nhất (P4, UC13, UC15)
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'ix_bids_leader')
BEGIN
    CREATE NONCLUSTERED INDEX ix_bids_leader 
    ON dbo.bids(auction_id, bid_amount DESC, bid_time ASC);
END;
GO

-- 11. BẢNG watchlists (Danh sách theo dõi cá nhân của Bidder - Quan hệ 1:1 theo PA2)
IF OBJECT_ID(N'dbo.watchlists', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.watchlists (
        watchlist_id BIGINT IDENTITY(1,1) NOT NULL,
        bidder_id BIGINT NOT NULL,
        total_items INT NOT NULL DEFAULT 0,
        updated_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_watchlists PRIMARY KEY CLUSTERED (watchlist_id),
        CONSTRAINT uq_watchlists_bidder UNIQUE (bidder_id),
        CONSTRAINT fk_watchlists_bidder FOREIGN KEY (bidder_id) 
            REFERENCES dbo.bidder_profiles(user_id) ON DELETE CASCADE,
        CONSTRAINT ck_watchlists_total CHECK (total_items >= 0)
    );
END;
GO

-- 12. BẢNG watchlist_items (Các mục phiên đấu giá trong danh sách theo dõi)
IF OBJECT_ID(N'dbo.watchlist_items', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.watchlist_items (
        watchlist_item_id BIGINT IDENTITY(1,1) NOT NULL,
        watchlist_id BIGINT NOT NULL,
        auction_id BIGINT NOT NULL,
        added_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_watchlist_items PRIMARY KEY CLUSTERED (watchlist_item_id),
        CONSTRAINT fk_watchlist_items_watchlist FOREIGN KEY (watchlist_id) 
            REFERENCES dbo.watchlists(watchlist_id) ON DELETE CASCADE,
        CONSTRAINT fk_watchlist_items_auction FOREIGN KEY (auction_id) 
            REFERENCES dbo.auctions(auction_id),
        CONSTRAINT uq_watchlist_auction UNIQUE (watchlist_id, auction_id)
    );
END;
GO

-- =========================================================================
-- CỤM 4: ĐƠN HÀNG, THANH TOÁN & VẬN CHUYỂN (P5)
-- =========================================================================

-- 13. BẢNG orders (Đơn hàng sinh tự động khi phiên kết thúc có người thắng - BR16, BR18)
IF OBJECT_ID(N'dbo.orders', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.orders (
        order_id BIGINT IDENTITY(1,1) NOT NULL,
        auction_id BIGINT NOT NULL,
        buyer_id BIGINT NOT NULL,
        hammer_price DECIMAL(18,2) NOT NULL,
        buyers_premium DECIMAL(18,2) NOT NULL DEFAULT 0,
        shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0,
        total_amount DECIMAL(18,2) NOT NULL,
        payment_deadline DATETIME2(3) NOT NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'PENDING_PAYMENT',
        delivered_at DATETIME2(3) NULL,
        completed_at DATETIME2(3) NULL,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_orders PRIMARY KEY CLUSTERED (order_id),
        CONSTRAINT uq_orders_auction UNIQUE (auction_id),
        CONSTRAINT fk_orders_auction FOREIGN KEY (auction_id) 
            REFERENCES dbo.auctions(auction_id),
        CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id) 
            REFERENCES dbo.bidder_profiles(user_id),
        CONSTRAINT ck_orders_hammer CHECK (hammer_price > 0),
        CONSTRAINT ck_orders_premium CHECK (buyers_premium >= 0),
        CONSTRAINT ck_orders_shipping CHECK (shipping_fee >= 0),
        CONSTRAINT ck_orders_total CHECK (total_amount = hammer_price + buyers_premium + shipping_fee),
        CONSTRAINT ck_orders_status CHECK (status IN (
            'PENDING_PAYMENT', 'PAID', 'SHIPPING', 'DELIVERED', 
            'COMPLETED', 'CANCELLED_OVERDUE', 'DISPUTED', 'REFUNDED'
        ))
    );
END;
GO

-- 14. BẢNG payments (Giao dịch thanh toán thu tiền CHARGE và hoàn tiền REFUND)
IF OBJECT_ID(N'dbo.payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.payments (
        payment_id BIGINT IDENTITY(1,1) NOT NULL,
        order_id BIGINT NOT NULL,
        original_payment_id BIGINT NULL,
        type VARCHAR(15) NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        gateway_txn_id VARCHAR(100) NULL,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_payments PRIMARY KEY CLUSTERED (payment_id),
        CONSTRAINT fk_payments_order FOREIGN KEY (order_id) 
            REFERENCES dbo.orders(order_id),
        CONSTRAINT fk_payments_original FOREIGN KEY (original_payment_id) 
            REFERENCES dbo.payments(payment_id),
        CONSTRAINT ck_payments_type CHECK (type IN ('CHARGE', 'REFUND')),
        CONSTRAINT ck_payments_amount CHECK (amount > 0),
        CONSTRAINT ck_payments_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
        CONSTRAINT uq_payments_gateway_txn UNIQUE (gateway_txn_id)
    );
END;
GO

-- 15. BẢNG shipments (Vận đơn giao nhận cổ vật)
IF OBJECT_ID(N'dbo.shipments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.shipments (
        shipment_id BIGINT IDENTITY(1,1) NOT NULL,
        order_id BIGINT NOT NULL,
        tracking_code VARCHAR(50) NOT NULL,
        packaging_info NVARCHAR(500) NULL,
        insured_value DECIMAL(18,2) NULL,
        status VARCHAR(25) NOT NULL DEFAULT 'PREPARING',
        shipped_at DATETIME2(3) NULL,
        delivered_at DATETIME2(3) NULL,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_shipments PRIMARY KEY CLUSTERED (shipment_id),
        CONSTRAINT uq_shipments_order UNIQUE (order_id),
        CONSTRAINT uq_shipments_tracking UNIQUE (tracking_code),
        CONSTRAINT fk_shipments_order FOREIGN KEY (order_id) 
            REFERENCES dbo.orders(order_id),
        CONSTRAINT ck_shipments_insured CHECK (insured_value IS NULL OR insured_value >= 0),
        CONSTRAINT ck_shipments_status CHECK (status IN (
            'PREPARING', 'SHIPPED', 'IN_TRANSIT', 'DELIVERED', 'FAILED', 'RETURNED'
        ))
    );
END;
GO

-- =========================================================================
-- CỤM 5: KHIẾU NẠI, THÔNG BÁO & NHẬT KÝ HỆ THỐNG
-- =========================================================================

-- 16. BẢNG disputes (Hồ sơ khiếu nại của người mua)
IF OBJECT_ID(N'dbo.disputes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.disputes (
        dispute_id BIGINT IDENTITY(1,1) NOT NULL,
        order_id BIGINT NOT NULL,
        bidder_id BIGINT NOT NULL,
        reason NVARCHAR(1000) NOT NULL,
        evidence_url VARCHAR(500) NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        resolution NVARCHAR(1000) NULL,
        filed_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        resolved_at DATETIME2(3) NULL,
        CONSTRAINT pk_disputes PRIMARY KEY CLUSTERED (dispute_id),
        CONSTRAINT uq_disputes_order UNIQUE (order_id),
        CONSTRAINT fk_disputes_order FOREIGN KEY (order_id) 
            REFERENCES dbo.orders(order_id),
        CONSTRAINT fk_disputes_bidder FOREIGN KEY (bidder_id) 
            REFERENCES dbo.bidder_profiles(user_id),
        CONSTRAINT ck_disputes_status CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED'))
    );
END;
GO

-- 17. BẢNG notifications (Thông báo tự động gửi tới người dùng)
IF OBJECT_ID(N'dbo.notifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.notifications (
        notification_id BIGINT IDENTITY(1,1) NOT NULL,
        recipient_id BIGINT NOT NULL,
        title NVARCHAR(200) NOT NULL,
        content NVARCHAR(1000) NOT NULL,
        type VARCHAR(30) NOT NULL,
        is_read BIT NOT NULL DEFAULT 0,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_notifications PRIMARY KEY CLUSTERED (notification_id),
        CONSTRAINT fk_notifications_recipient FOREIGN KEY (recipient_id) 
            REFERENCES dbo.users(user_id) ON DELETE CASCADE,
        CONSTRAINT ck_notifications_type CHECK (type IN (
            'OUTBID', 'AUCTION_STARTED', 'AUCTION_ENDED', 'AUCTION_WON', 
            'AUCTION_CANCELLED', 'ORDER_CREATED', 'ORDER_REMINDER', 
            'ORDER_OVERDUE', 'PAYMENT_SUCCESS', 'SHIPMENT_UPDATE', 
            'DISPUTE_UPDATE', 'KYC_APPROVED', 'KYC_REJECTED', 'SYSTEM'
        ))
    );
END;
GO

-- 18. BẢNG audit_logs (Nhật ký truy vết mọi thao tác nhạy cảm - BR28, BR29)
IF OBJECT_ID(N'dbo.audit_logs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs (
        log_id BIGINT IDENTITY(1,1) NOT NULL,
        actor_id BIGINT NULL,
        action VARCHAR(60) NOT NULL,
        entity_type VARCHAR(30) NOT NULL,
        entity_id BIGINT NOT NULL,
        detail NVARCHAR(MAX) NULL,
        created_at DATETIME2(3) NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_audit_logs PRIMARY KEY CLUSTERED (log_id),
        CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_id) 
            REFERENCES dbo.users(user_id)
    );
END;
GO

-- TRIGGER THỰC THI BR29: BẢNG audit_logs BẤT BIẾN, CHẶN SỬA (UPDATE) VÀ XÓA (DELETE)
IF OBJECT_ID(N'dbo.trg_audit_logs_immutable', N'TR') IS NOT NULL
BEGIN
    DROP TRIGGER dbo.trg_audit_logs_immutable;
END;
GO

CREATE TRIGGER dbo.trg_audit_logs_immutable
ON dbo.audit_logs
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR(N'Bảng audit_logs là nhật ký hệ thống bất biến (Quy tắc BR29), tuyệt đối không cho phép sửa (UPDATE) hoặc xóa (DELETE)!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO
