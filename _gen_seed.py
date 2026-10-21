# -*- coding: utf-8 -*-
"""Generate realistic seed_data.sql for AntiqueBidDB.

Requirements:
- Ít danh mục (5 danh mục cổ vật cốt lõi, tinh gọn)
- Đúng 30 phiên đấu giá tổng cộng:
    + 20 phiên Sắp và Đang diễn ra:
        * 12 phiên ACTIVE (Đang diễn ra): kết thúc trong vòng 24 giờ, mốc thời gian khác biệt hoàn toàn
        * 8 phiên SCHEDULED (Sắp diễn ra): mốc bắt đầu rải rác từ 45 phút đến 3 ngày
    + 10 phiên đã kết thúc/hủy:
        * 6 phiên ENDED_SOLD (tạo 6 đơn hàng đầy đủ quy trình thanh toán, vận chuyển, khiếu nại)
        * 2 phiên ENDED_NO_BIDS
        * 1 phiên ENDED_RESERVE_NOT_MET
        * 1 phiên CANCELLED
- Dữ liệu hình ảnh trỏ trực tiếp vào assets/images sẵn có của dự án.
"""
from pathlib import Path
from datetime import datetime

OUT = Path(__file__).with_name("seed_data.sql")

ADMIN_HASH = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9"
BIDDER_HASH = "482c811da5d5b4bc6d497ffa98491e38"

FIRST = [
    "An", "Bình", "Cường", "Dũng", "Phương", "Giang", "Hoa", "Khánh", "Lan", "Minh",
    "Nga", "Phúc", "Quỳnh", "Sơn", "Thảo", "Việt", "Hùng", "Linh", "Nam", "Trang",
    "Tuấn", "Hạnh", "Đạt", "Mai", "Long", "Hương", "Khoa", "Quang", "Bảo", "Ngọc",
]
LAST = [
    "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Võ", "Đặng",
    "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý", "Đinh", "Cao", "Trịnh", "Mai",
]
CITIES = [
    "Quận 1, TP. Hồ Chí Minh", "Hoàn Kiếm, Hà Nội", "Hải Châu, Đà Nẵng",
    "Ninh Kiều, Cần Thơ", "Hồng Bàng, Hải Phòng", "TP. Huế", "Nha Trang",
    "Biên Hòa", "Vũng Tàu", "Đà Lạt", "Vinh", "Thủ Dầu Một",
]
STREETS = [
    "Nguyễn Trãi", "Lê Lợi", "Trần Phú", "Pasteur", "Hai Bà Trưng",
    "Lý Thường Kiệt", "Nguyễn Huệ", "Trần Hưng Đạo", "Phan Chu Trinh",
    "Võ Thị Sáu", "Cách Mạng Tháng 8", "Điện Biên Phủ",
]

# 5 Danh mục cổ vật chuẩn, tinh gọn
CATEGORIES = [
    ("Gốm sứ cổ", "Bình, đĩa, bát men ngọc, men lam, gốm Chu Đậu, Bát Tràng cổ"),
    ("Đồ đồng & Tượng cổ", "Tượng Phật, đỉnh đồng tam khí, chuông đồng, lư hương nghi lễ cổ"),
    ("Tranh cổ & Thư pháp", "Tranh thủy mặc, tranh sơn mài, cuốn thư, câu đối Hán Nôm cổ"),
    ("Đồ gỗ mỹ nghệ", "Bàn trà, tủ trắc khảm ốc, bình phong gỗ gụ quý cổ"),
    ("Ngọc bích & Trang sức cổ", "Vòng ngọc cẩm thạch, nhẫn vàng chạm, trâm cài hoàng gia cổ"),
]

# Mẫu hiện vật ánh xạ vào 5 danh mục
ITEM_TEMPLATES = [
    # Cat 1: Gốm sứ cổ
    (1, "Bình gốm men lam {era}", "Gốm sứ", "Cao {h}cm, Ø{d}cm", 1400, 1600),
    (1, "Đĩa gốm Chu Đậu {era}", "Gốm sứ", "Ø{d}cm, cao {h}cm", 1450, 1650),
    (1, "Bát men ngọc Celadon {era}", "Gốm celadon", "Ø{d}cm", 1400, 1600),
    (1, "Lọ hoa Bát Tràng {era}", "Gốm sứ", "Cao {h}cm", 1600, 1800),
    # Cat 2: Đồ đồng & Tượng cổ
    (2, "Tượng Phật đồng {era}", "Đồng nguyên chất", "Cao {h}cm", 1600, 1850),
    (2, "Đỉnh đồng tam khí {era}", "Đồng", "Cao {h}cm", 1700, 1900),
    (2, "Lư hương đồng {era}", "Đồng", "Cao {h}cm, Ø{d}cm", 1650, 1850),
    (2, "Tượng Lân đồng phong thủy {era}", "Đồng", "Cao {h}cm", 1700, 1850),
    # Cat 3: Tranh cổ & Thư pháp
    (3, "Tranh thủy mặc Tùng Hạc {era}", "Giấy xuyến chỉ", "{h}x{d}cm", 1800, 1920),
    (3, "Tranh sơn mài cổ {era}", "Sơn mài trên gỗ", "{h}x{d}cm", 1820, 1910),
    (3, "Cuốn thư Hán Nôm {era}", "Giấy dó cổ", "{h}x{d}cm", 1750, 1890),
    (3, "Bộ câu đối gỗ mun {era}", "Gỗ mun", "{h}x{d}cm", 1800, 1920),
    # Cat 4: Đồ gỗ mỹ nghệ
    (4, "Tủ chè gỗ trắc khảm ốc {era}", "Gỗ trắc", "{h}x{d}x50cm", 1780, 1900),
    (4, "Bàn trà gỗ hương {era}", "Gỗ hương", "{h}x{d}x40cm", 1800, 1920),
    (4, "Bình phong gỗ gụ {era}", "Gỗ gụ", "Mỗi cánh {h}x{d}cm", 1720, 1860),
    # Cat 5: Ngọc bích & Trang sức cổ
    (5, "Vòng ngọc bích {era}", "Ngọc cẩm thạch", "Ø{d}cm", 1800, 1950),
    (5, "Nhẫn vàng chạm hoa văn {era}", "Vàng cổ", "Ø1.9cm", 1820, 1900),
    (5, "Trâm bạc đính ngọc {era}", "Bạc và ngọc", "Dài {h}cm", 1850, 1920),
]

CONDITIONS = ["INTACT", "SLIGHTLY_DAMAGED", "RESTORED"]
ERAS = ["thế kỷ 15", "thế kỷ 16", "thế kỷ 17", "thế kỷ 18", "thời Nguyễn", "thời Lê", "thế kỷ 19"]
ORIGINS = ["Hà Nội", "Huế", "Bát Tràng", "Chu Đậu", "Trung Hoa", "Nam Định", "Pháp"]
APPRAISER_INFO = [
    ("GS. Nguyễn Văn Thắng", "Chuyên gia Giám định Cổ vật Cấp Quốc gia - Thẻ GĐ-018/VCH"),
    ("TS. Trần Thị Mai", "Viện Khảo Cổ Học - Chuyên viên Giám định Di sản Cấp I (Số 029/GĐ)"),
    ("GS. Lê Văn Hùng", "Ủy viên Hội đồng Giám định Di vật Cổ vật Quốc gia - Mã số GĐ-005/VCH"),
    ("TS. Phạm Quốc Bảo", "Chuyên gia Cổ ngọc & Kim khí - Chứng chỉ Giám định Di sản số 042/GĐ"),
    ("TS. Hoàng Minh Tuấn", "Nhà nghiên cứu Di sản Văn hóa - Giám định viên Hội Di sản Cổ vật (Số 056/GĐ)"),
]

CATEGORY_APPRAISAL_DATA = {
    1: {  # Gốm sứ
        "cultural": "Hiện vật tiêu biểu cho kỹ nghệ chế tác men gốm và tạo hình đỉnh cao, mang giá trị lịch sử và mỹ thuật thời kỳ hoàng kim.",
        "method": "Phân tích quang phổ huỳnh quang tia X (XRF) cốt gốm; soi kính hiển vi quang học kiểm tra mạng rạn men và bọt khí tầng sâu.",
        "ref": "Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu gốm Chu Đậu - Bát Tràng thế kỷ 15-18.",
    },
    2: {  # Đồ đồng
        "cultural": "Minh chứng tiêu biểu cho nghệ thuật đúc đồng truyền thống, hoa văn chạm khắc tinh xảo mang ý nghĩa phong thủy và quyền quý.",
        "method": "Kiểm tra quang phổ kim loại (EDX) xác định tỷ lệ đồng-thiếc cổ truyền; phân tích độ suy biến của lớp patina gỉ đồng tự nhiên.",
        "ref": "Tư liệu di sản kim khí Cố đô Huế & Tuyển tập Cổ vật Hoàng gia triều Nguyễn.",
    },
    3: {  # Hội họa thư pháp
        "cultural": "Tác phẩm thư họa độc bản thể hiện triết lý mỹ học phương Đông và bút pháp bậc thầy của nghệ nhân xưa.",
        "method": "Phân tích huỳnh quang UV kiểm tra tính đồng nhất của chất liệu giấy dó/lụa; giám định độ lão hóa mực nho và dấu triện cổ.",
        "ref": "Kho thư tịch Hán Nôm & Bản thảo thư họa cổ lưu trữ tại Viện Nghiên cứu Hán Nôm.",
    },
    4: {  # Đồ gỗ
        "cultural": "Nghệ thuật khảm cẩn xà cừ và mộc thủ công truyền thống, phản ánh đời sống văn hóa quý tộc và giá trị di sản đặc sắc.",
        "method": "Giám định cấu trúc thớ gỗ dưới kính phóng đại; phân tích lớp sơn ta và độ co ngót tự nhiên của kết cấu mộng truyền thống.",
        "ref": "Tài liệu nghiên cứu đồ gỗ mỹ nghệ truyền thống Bắc Bộ & Cổ vật cung đình Huế.",
    },
    5: {  # Ngọc bích & Trang sức
        "cultural": "Chế tác cung đình tinh mỹ, chất ngọc tự nhiên thấu quang hoàn hảo, mang giá trị thẩm mỹ và di sản quý hiếm.",
        "method": "Đo độ cứng Mohs, chỉ số khúc xạ ánh sáng (RI); phân tích phổ Raman xác định cấu trúc ngọc bích tự nhiên không qua xử lý.",
        "ref": "Bộ sưu tập ngọc khí Bảo tàng Cung đình Huế & Giám định ngọc học Châu Á.",
    },
}

N_BIDDERS = 30
N_ITEMS = 40
N_AUCTIONS = 30  # Chuẩn 30 phiên đấu giá


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def sql_n(s: str) -> str:
    return "N'" + s.replace("'", "''") + "'"


def dt(y, m, d, hh=9, mm=0, ss=0):
    return f"'{y:04d}-{m:02d}-{d:02d} {hh:02d}:{mm:02d}:{ss:02d}'"


def main():
    lines = []
    a = lines.append

    a("-- =========================================================================")
    a("-- KỊCH BẢN NHẬP DỮ LIỆU MẪU CHUẨN - AntiqueBidDB")
    a(f"-- Sinh tự động: {datetime.now():%Y-%m-%d %H:%M}")
    a(f"-- Quy mô: {2+N_BIDDERS} users, {len(CATEGORIES)} categories, {N_ITEMS} items, {N_AUCTIONS} auctions")
    a("-- Cấu trúc phiên: 12 ACTIVE (end < 24h), 8 SCHEDULED, 6 ENDED_SOLD, 2 ENDED_NO_BIDS, 1 ENDED_RESERVE, 1 CANCELLED")
    a("-- =========================================================================")
    a("SET QUOTED_IDENTIFIER ON;")
    a("SET ANSI_NULLS ON;")
    a("GO")
    a("USE AntiqueBidDB;")
    a("GO")
    a("")
    a("-- Tạm tắt trigger BR29 để cho phép xóa audit_logs khi seed lại")
    a("IF OBJECT_ID(N'dbo.trg_audit_logs_immutable', N'TR') IS NOT NULL")
    a("    DISABLE TRIGGER dbo.trg_audit_logs_immutable ON dbo.audit_logs;")
    a("GO")
    a("")
    a("DELETE FROM dbo.audit_logs;")
    a("DELETE FROM dbo.notifications;")
    a("DELETE FROM dbo.disputes;")
    a("DELETE FROM dbo.shipments;")
    a("DELETE FROM dbo.payments;")
    a("DELETE FROM dbo.orders;")
    a("DELETE FROM dbo.watchlist_items;")
    a("DELETE FROM dbo.watchlists;")
    a("DELETE FROM dbo.bids;")
    a("DELETE FROM dbo.auctions;")
    a("DELETE FROM dbo.appraisal_certificates;")
    a("DELETE FROM dbo.provenance_records;")
    a("DELETE FROM dbo.item_images;")
    a("DELETE FROM dbo.antique_items;")
    a("DELETE FROM dbo.categories;")
    a("DELETE FROM dbo.verification_documents;")
    a("DELETE FROM dbo.bidder_profiles;")
    a("DELETE FROM dbo.users;")
    a("GO")
    a("")
    a("-- Bật lại trigger bất biến sau khi dọn dữ liệu")
    a("IF OBJECT_ID(N'dbo.trg_audit_logs_immutable', N'TR') IS NOT NULL")
    a("    ENABLE TRIGGER dbo.trg_audit_logs_immutable ON dbo.audit_logs;")
    a("GO")
    a("")
    for t in [
        "users", "verification_documents", "categories", "antique_items", "item_images",
        "provenance_records", "appraisal_certificates", "auctions", "bids", "watchlists",
        "watchlist_items", "orders", "payments", "shipments", "disputes", "notifications", "audit_logs",
    ]:
        a(f"DBCC CHECKIDENT ('dbo.{t}', RESEED, 0);")
    a("GO")
    a("")

    # ----- 1. USERS -----
    a("-- 1. users (2 Quản trị viên + 30 Khách đấu giá)")
    a("INSERT INTO dbo.users (email, password_hash, full_name, phone, role, is_locked, created_at) VALUES")
    user_rows = [
        f"('admin@antiquebid.vn', '{ADMIN_HASH}', N'Nguyễn Thị Quản Trị', '0900000001', 'ADMIN', 0, {dt(2026,6,1)})",
        f"('admin2@antiquebid.vn', '{ADMIN_HASH}', N'Trần Văn Điều Hành', '0900000002', 'ADMIN', 0, {dt(2026,6,2)})",
    ]
    for i in range(N_BIDDERS):
        uid = i + 3
        fn = FIRST[i % len(FIRST)]
        ln = LAST[i % len(LAST)]
        email = f"bidder{i+1:02d}@email.vn"
        phone = f"0911{i+1:06d}"
        locked = 1 if i in (13, 27) else 0
        day = 5 + (i % 22)
        user_rows.append(
            f"({sql_str(email)}, '{BIDDER_HASH}', {sql_n(ln + ' ' + ('Văn ' if i % 2 == 0 else 'Thị ') + fn)}, "
            f"'{phone}', 'BIDDER', {locked}, {dt(2026, 6, min(day, 28), 9 + i % 8)})"
        )
    a(",\n".join(user_rows) + ";")
    a("GO")
    a("")

    # ----- 2. BIDDER PROFILES -----
    a("-- 2. bidder_profiles")
    a("INSERT INTO dbo.bidder_profiles (user_id, citizen_id, kyc_status, violation_count, shipping_address) VALUES")
    kyc_cycle = ["VERIFIED", "VERIFIED", "VERIFIED", "PENDING", "VERIFIED", "NOT_SUBMITTED", "VERIFIED", "REJECTED"]
    PROVINCES = ["001", "079", "048", "092", "031", "046", "056", "075", "077", "068", "040", "074"]
    profile_rows = []
    verified_ids = []
    for i in range(N_BIDDERS):
        uid = i + 3
        kyc = kyc_cycle[i % len(kyc_cycle)]
        if i in (13, 27):
            kyc = "REJECTED"
        viol = 3 if kyc == "REJECTED" else 0
        street = STREETS[i % len(STREETS)]
        city = CITIES[i % len(CITIES)]
        addr = f"{12 + i * 2} {street}, {city}"
        
        # 12-digit Vietnamese CCCD (Province + Gender/Century + Birth Year + Sequence)
        prov = PROVINCES[i % len(PROVINCES)]
        gender = "0" if (i % 2 == 0) else "1"
        byear = f"{82 + (i % 16):02d}"
        cccd_num = f"{prov}{gender}{byear}{uid:06d}"
        
        cccd_sql = f"'{cccd_num}'" if kyc in ("VERIFIED", "PENDING") else "NULL"
        profile_rows.append(f"({uid}, {cccd_sql}, '{kyc}', {viol}, {sql_n(addr)})")
        if kyc == "VERIFIED":
            verified_ids.append(uid)
    a(",\n".join(profile_rows) + ";")
    a("GO")
    a("")

    # ----- 3. VERIFICATION DOCS (Chỉ xác thực qua Căn cước công dân gắn chip) -----
    a("-- 3. verification_documents")
    a("INSERT INTO dbo.verification_documents (bidder_id, doc_type, citizen_id, issue_date, issue_place, file_url, file_url_back, submitted_at, review_note) VALUES")
    doc_rows = []
    for i in range(N_BIDDERS):
        uid = i + 3
        kyc = kyc_cycle[i % len(kyc_cycle)]
        if i in (13, 27):
            kyc = "REJECTED"
        if kyc == "NOT_SUBMITTED":
            continue
        
        prov = PROVINCES[i % len(PROVINCES)]
        gender = "0" if (i % 2 == 0) else "1"
        byear = f"{82 + (i % 16):02d}"
        cccd_num = f"{prov}{gender}{byear}{uid:06d}"
        issue_d = f"'2021-{5 + (i % 7):02d}-{10 + (i % 15):02d}'"
        issue_p = sql_n("Cục Cảnh sát QLHC về TTXH")
        
        note = "NULL"
        if kyc == "VERIFIED":
            note = sql_n("Hồ sơ hợp lệ, đã duyệt định danh CCCD gắn chip")
        elif kyc == "REJECTED":
            note = sql_n("Ảnh CCCD mờ, từ chối duyệt")
        elif kyc == "PENDING":
            note = "NULL"
        day = 6 + (i % 20)
        doc_rows.append(
            f"({uid}, 'CITIZEN_ID', '{cccd_num}', {issue_d}, {issue_p}, "
            f"'/uploads/kyc/u{uid}_cccd_front.png', '/uploads/kyc/u{uid}_cccd_back.png', "
            f"{dt(2026, 6, min(day, 28), 10)}, {note})"
        )
    a(",\n".join(doc_rows) + ";")
    a("GO")
    a("")

    # ----- 4. CATEGORIES -----
    a(f"-- 4. categories ({len(CATEGORIES)} danh mục tinh gọn)")
    a("INSERT INTO dbo.categories (name, description, is_active, created_at, updated_at) VALUES")
    cat_rows = []
    for name, desc in CATEGORIES:
        cat_rows.append(
            f"({sql_n(name)}, {sql_n(desc)}, 1, {dt(2026, 6, 1, 8, 30)}, {dt(2026, 6, 1, 8, 30)})"
        )
    a(",\n".join(cat_rows) + ";")
    a("GO")
    a("")

    # ----- 5. ANTIQUE ITEMS -----
    a(f"-- 5. antique_items ({N_ITEMS} hiện vật độc bản)")
    a("INSERT INTO dbo.antique_items (item_code, name, description, era_from, era_to, material, dimensions,")
    a(" item_condition, status, is_archived, version, category_id, created_by, created_at, updated_at) VALUES")

    item_meta = []
    item_rows = []
    for i in range(1, N_ITEMS + 1):
        tpl = ITEM_TEMPLATES[(i - 1) % len(ITEM_TEMPLATES)]
        cat_id, name_tpl, material, dim_tpl, era_lo, era_hi = tpl
        era_label = ERAS[(i - 1) % len(ERAS)]
        h = 18 + (i * 3) % 45
        d = 12 + (i * 2) % 30
        name = name_tpl.format(era=era_label)
        dims = dim_tpl.format(h=h, d=d)
        desc = f"{name}. Hiện vật quý hiếm độc bản, bảo quản tại kho sàn đấu giá Cổ Vật Đường, mã {i:04d}."
        era_from = era_lo + (i % 20)
        era_to = max(era_from, era_hi - (i % 20))
        cond = CONDITIONS[(i - 1) % len(CONDITIONS)]
        code = f"HV-{i:04d}"
        created_by = 1 if i % 2 == 0 else 2
        day = 1 + (i % 25)
        status = "AVAILABLE"
        low = (12 + (i * 7) % 60) * 1_000_000
        item_meta.append({
            "id": i, "cat": cat_id, "cond": cond, "era_from": era_from, "era_to": era_to,
            "status": status, "estimate_low": low,
        })
        item_rows.append(
            f"({sql_n(code)}, {sql_n(name)}, {sql_n(desc)}, {era_from}, {era_to}, "
            f"{sql_n(material)}, {sql_n(dims)}, '{cond}', '{status}', 0, 0, {cat_id}, {created_by}, "
            f"{dt(2026, 7, day)}, {dt(2026, 8, day)})"
        )
    a(",\n".join(item_rows) + ";")
    a("GO")
    a("")

    # ----- 6. ITEM IMAGES -----
    a("-- 6. item_images (Trỏ ảnh chuẩn trong assets/images)")
    a("INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) VALUES")
    img_rows = []
    for i in range(1, N_ITEMS + 1):
        # Ảnh hiện vật cổ chụp thực tế từ các bảo tàng (Wikimedia Commons/Museum Archives)
        primary_img = f"assets/images/items/real_item_{i}.jpg"
        secondary_img = f"assets/images/items/real_item_{i}_detail.jpg"
        img_rows.append(
            f"({i}, '{primary_img}', 'image/jpeg', 280000, 1, 1, {dt(2026, 7, 1 + (i % 25), 9, 0)})"
        )
        img_rows.append(
            f"({i}, '{secondary_img}', 'image/jpeg', 220000, 0, 2, {dt(2026, 7, 1 + (i % 25), 9, 5)})"
        )
    a(",\n".join(img_rows) + ";")
    a("GO")
    a("")

    # ----- 7. PROVENANCE RECORDS -----
    a("-- 7. provenance_records")
    a("INSERT INTO dbo.provenance_records (item_id, origin, acquisition_source, ownership_history, supporting_documents) VALUES")
    prov_rows = []
    for i in range(1, N_ITEMS + 1):
        origin = ORIGINS[(i - 1) % len(ORIGINS)]
        prov_rows.append(
            f"({i}, {sql_n(origin)}, {sql_n(f'Sưu tập từ gia tộc {LAST[(i-1) % len(LAST)]} (năm {2012 + i % 12})')}, "
            f"{sql_n(f'Sở hữu tư nhân đời trước → Nhượng quyền sàn Cổ Vật Đường')}, "
            f"'/docs/prov/hv{i:04d}.pdf')"
        )
    a(",\n".join(prov_rows) + ";")
    a("GO")
    a("")

    # ----- 8. APPRAISAL CERTIFICATES -----
    # 2 hiện vật bị reject, 2 hiện vật draft (chưa giám định) ở cuối danh sách (item 37, 38, 39, 40)
    reject_ids = {39, 40}
    draft_skip = {37, 38}

    a("-- 8. appraisal_certificates (Chuẩn 18 bảng ERD, tích hợp kết luận & phương pháp vào note)")
    a("INSERT INTO dbo.appraisal_certificates (item_id, result, appraiser_name, appraisal_date, note,")
    a(" estimate_low, estimate_high, recorded_by, recorded_at, certificate_no, certificate_status, issued_at, revoked_at) VALUES")
    app_rows = []
    cert_n = 0
    for i in range(1, N_ITEMS + 1):
        if i in draft_skip:
            item_meta[i - 1]["status"] = "DRAFT"
            continue
        appraiser_name, appraiser_title = APPRAISER_INFO[(i - 1) % len(APPRAISER_INFO)]
        cat_id = item_meta[i - 1]["cat"]
        cond = item_meta[i - 1]["cond"]
        cat_data = CATEGORY_APPRAISAL_DATA.get(cat_id, CATEGORY_APPRAISAL_DATA[1])
        low = item_meta[i - 1]["estimate_low"]
        high = low + 5_000_000 + (i % 10) * 1_000_000
        recorded_by = 1 if i % 2 == 0 else 2
        day = 1 + (i % 25)
        if i in reject_ids:
            item_meta[i - 1]["status"] = "APPRAISED_REJECTED"
            note_rej = (
                f"Biên bản giám định số BB-2026-{i:03d} (Giám định viên: {appraiser_name} - {appraiser_title}): "
                f"KẾT QUẢ KHÔNG ĐẠT. Cốt vật liệu và hoa văn có dấu hiệu can thiệp nhân tạo, không đồng nhất niên đại công bố. "
                f"Tài liệu lai lịch chưa đủ căn cứ xác minh. Từ chối cấp chứng thư."
            )
            app_rows.append(
                f"({i}, 'REJECTED', {sql_n(appraiser_name)}, '2026-08-{day:02d}', "
                f"{sql_n(note_rej)}, 0, 0, {recorded_by}, "
                f"{dt(2026, 8, day, 14)}, NULL, NULL, NULL, NULL)"
            )
        else:
            cert_n += 1
            item_meta[i - 1]["status"] = "APPRAISED_PASSED"
            item_meta[i - 1]["low"] = low
            item_meta[i - 1]["high"] = high
            if cond == "RESTORED":
                auth_concl = "Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique)"
            else:
                auth_concl = "Cổ vật thật nguyên bản (Authentic Antique)"
            note_pass = (
                f"Xác thực: {auth_concl}. "
                f"Phương pháp kiểm định: {cat_data['method']} "
                f"Giá trị di sản: {cat_data['cultural']} "
                f"Đối chiếu: {cat_data['ref']} "
                f"Kết luận: Hiện vật chính phẩm, chất lượng bảo tồn tốt ({cond}), đủ điều kiện cấp chứng thư bảo chứng độc bản."
            )
            app_rows.append(
                f"({i}, 'PASSED', {sql_n(appraiser_name)}, '2026-08-{day:02d}', "
                f"{sql_n(note_pass)}, {low}, {high}, {recorded_by}, "
                f"{dt(2026, 8, day, 14)}, {sql_n(f'CT-2026-{cert_n:03d}')}, 'VALID', "
                f"{dt(2026, 8, day, 15)}, NULL)"
            )
    a(",\n".join(app_rows) + ";")
    a("GO")
    a("")

    # ----- 9. AUCTIONS (ĐÚNG 30 PHIÊN) -----
    # 12 ACTIVE, 8 SCHEDULED, 6 ENDED_SOLD, 2 ENDED_NO_BIDS, 1 ENDED_RESERVE_NOT_MET, 1 CANCELLED = 30 phiên
    statuses_plan = (
        ["ACTIVE"] * 12
        + ["SCHEDULED"] * 8
        + ["ENDED_SOLD"] * 6
        + ["ENDED_NO_BIDS"] * 2
        + ["ENDED_RESERVE_NOT_MET"] * 1
        + ["CANCELLED"] * 1
    )

    # Thời gian kết thúc trong vòng 24h của 12 phiên ACTIVE (tính bằng PHÚT từ thời điểm hiện tại GETDATE())
    # Mỗi phiên cách nhau rõ rệt, kết thúc từ 25 phút đến 23 giờ 20 phút!
    ACTIVE_END_MINUTES = [25, 45, 80, 135, 210, 315, 440, 590, 770, 980, 1190, 1390]
    ACTIVE_START_HOURS = [-2, -4, -6, -8, -10, -12, -14, -16, -18, -20, -21, -22]

    # Thời gian bắt đầu của 8 phiên SCHEDULED (rải rác từ 45 phút tới 3 ngày)
    SCHEDULED_START = [
        "DATEADD(MINUTE, 45, GETDATE())",
        "DATEADD(HOUR, 2, GETDATE())",
        "DATEADD(HOUR, 5, GETDATE())",
        "DATEADD(HOUR, 9, GETDATE())",
        "DATEADD(HOUR, 16, GETDATE())",
        "DATEADD(HOUR, 23, GETDATE())",
        "DATEADD(DAY, 2, GETDATE())",
        "DATEADD(DAY, 3, GETDATE())",
    ]
    SCHEDULED_END = [
        "DATEADD(DAY, 1, DATEADD(MINUTE, 45, GETDATE()))",
        "DATEADD(DAY, 1, DATEADD(HOUR, 2, GETDATE()))",
        "DATEADD(DAY, 1, DATEADD(HOUR, 5, GETDATE()))",
        "DATEADD(DAY, 1, DATEADD(HOUR, 9, GETDATE()))",
        "DATEADD(DAY, 2, DATEADD(HOUR, 16, GETDATE()))",
        "DATEADD(DAY, 2, DATEADD(HOUR, 23, GETDATE()))",
        "DATEADD(DAY, 4, GETDATE())",
        "DATEADD(DAY, 5, GETDATE())",
    ]

    auction_defs = []
    for idx in range(N_AUCTIONS):
        aid = idx + 1
        item_id = aid  # item 1..30
        st = statuses_plan[idx]
        low = item_meta[item_id - 1].get("low", 25_000_000)
        start_price = low
        reserve = int(low * 1.1)
        incr = max(500_000, ((low // 40) // 100_000) * 100_000)
        created_by = 1 if idx % 2 == 0 else 2

        meta = {
            "aid": aid, "item_id": item_id, "status": st, "start": start_price,
            "reserve": reserve, "incr": incr, "created_by": created_by,
            "highest": 0, "highest_bidder": "NULL", "hammer": "NULL",
            "cancel": "NULL", "closed": "NULL"
        }
        auction_defs.append(meta)

    a("-- 9. auctions (Đúng 30 phiên đấu giá: 12 Active end < 24h, 8 Scheduled, 10 Ended/Cancelled)")
    a("INSERT INTO dbo.auctions (item_id, created_by, start_time, end_time, starting_price, reserve_price,")
    a(" min_bid_increment, current_highest_bid, highest_bidder_id, hammer_price, status, cancel_reason,")
    a(" closed_at, version, created_at) VALUES")

    auc_rows = []
    bid_plan = []  # (auction_id, bidder_id, amount, time_sql, status)
    active_idx = 0
    sched_idx = 0
    sold_idx = 0

    for meta in auction_defs:
        aid = meta["aid"]
        st = meta["status"]
        start_p = meta["start"]
        incr = meta["incr"]
        bidders = [verified_ids[(aid + k) % len(verified_ids)] for k in range(5)]

        if st == "ACTIVE":
            # 12 phiên đang diễn ra: kết thúc trong 24h, thời gian lệch nhau hoàn toàn
            end_min = ACTIVE_END_MINUTES[active_idx]
            start_hr = ACTIVE_START_HOURS[active_idx]
            active_idx += 1

            start_sql = f"DATEADD(HOUR, {start_hr}, GETDATE())"
            end_sql = f"DATEADD(MINUTE, {end_min}, GETDATE())"

            # Tạo 3 - 6 lượt trả giá tăng dần
            n_bids = 3 + (aid % 4)
            amounts = [start_p + incr * (k + 1) for k in range(n_bids)]
            winner = bidders[n_bids % len(bidders)]
            meta["highest"] = amounts[-1]
            meta["highest_bidder"] = str(winner)

            for k, amt in enumerate(amounts):
                bid_hr = start_hr + (k + 1) * 2
                bid_plan.append((aid, bidders[k % len(bidders)], amt,
                                 f"DATEADD(HOUR, {min(bid_hr, -1)}, GETDATE())", "VALID"))

            item_meta[meta["item_id"] - 1]["status"] = "IN_AUCTION"
            closed = cancel = hammer = "NULL"
            created = f"DATEADD(DAY, -2, GETDATE())"

        elif st == "SCHEDULED":
            start_sql = SCHEDULED_START[sched_idx]
            end_sql = SCHEDULED_END[sched_idx]
            sched_idx += 1

            item_meta[meta["item_id"] - 1]["status"] = "IN_AUCTION"
            closed = cancel = hammer = "NULL"
            created = f"DATEADD(DAY, -3, GETDATE())"

        elif st == "ENDED_SOLD":
            sold_idx += 1
            amounts = [start_p + incr * (k + 1) for k in range(4)]
            winner = bidders[-1]
            meta["highest"] = amounts[-1]
            meta["highest_bidder"] = str(winner)
            meta["winner"] = winner
            meta["hammer_val"] = amounts[-1]
            hammer = str(amounts[-1])

            day_ago = 2 + sold_idx * 3
            start_sql = f"DATEADD(DAY, -{day_ago + 3}, GETDATE())"
            end_sql = f"DATEADD(DAY, -{day_ago}, GETDATE())"
            closed = end_sql
            cancel = "NULL"

            for k, amt in enumerate(amounts):
                bid_plan.append((aid, bidders[k % len(bidders)], amt,
                                 f"DATEADD(DAY, -{day_ago + 2 - k // 2}, GETDATE())", "VALID"))

            item_meta[meta["item_id"] - 1]["status"] = "SOLD_DELIVERED"
            created = f"DATEADD(DAY, -{day_ago + 6}, GETDATE())"

        elif st == "ENDED_NO_BIDS":
            start_sql = f"DATEADD(DAY, -18, GETDATE())"
            end_sql = f"DATEADD(DAY, -15, GETDATE())"
            closed = end_sql
            cancel = hammer = "NULL"
            item_meta[meta["item_id"] - 1]["status"] = "AVAILABLE"
            created = f"DATEADD(DAY, -22, GETDATE())"

        elif st == "ENDED_RESERVE_NOT_MET":
            # Có trả giá nhưng chưa đạt giá sàn
            amounts = [start_p + incr]
            meta["highest"] = amounts[0]
            meta["highest_bidder"] = str(bidders[0])
            start_sql = f"DATEADD(DAY, -16, GETDATE())"
            end_sql = f"DATEADD(DAY, -13, GETDATE())"
            closed = end_sql
            cancel = hammer = "NULL"
            bid_plan.append((aid, bidders[0], amounts[0], f"DATEADD(DAY, -14, GETDATE())", "VALID"))
            item_meta[meta["item_id"] - 1]["status"] = "AVAILABLE"
            created = f"DATEADD(DAY, -20, GETDATE())"

        else:  # CANCELLED
            start_sql = f"DATEADD(DAY, -14, GETDATE())"
            end_sql = f"DATEADD(DAY, -11, GETDATE())"
            closed = f"DATEADD(DAY, -12, GETDATE())"
            cancel = sql_n("Hủy theo yêu cầu của hội đồng giám định")
            hammer = "NULL"
            item_meta[meta["item_id"] - 1]["status"] = "AVAILABLE"
            created = f"DATEADD(DAY, -18, GETDATE())"

        hb = meta["highest_bidder"]
        hv = meta["highest"]
        auc_rows.append(
            f"({meta['item_id']}, {meta['created_by']}, {start_sql}, {end_sql}, "
            f"{meta['start']}, {meta['reserve']}, {meta['incr']}, {hv}, {hb}, {hammer}, "
            f"'{st}', {cancel}, {closed}, {1 if st.startswith('ENDED') or st == 'CANCELLED' else 0}, {created})"
        )

    a(",\n".join(auc_rows) + ";")
    a("GO")
    a("")

    # ----- 10. BIDS -----
    a("-- 10. bids")
    seen = set()
    unique_bids = []
    for b in bid_plan:
        key = (b[0], b[2])
        if key in seen:
            continue
        seen.add(key)
        unique_bids.append(b)

    a("INSERT INTO dbo.bids (auction_id, bidder_id, bid_amount, bid_time, status) VALUES")
    bid_rows = [
        f"({aid}, {bid}, {amt}, {ts}, '{st}')" for aid, bid, amt, ts, st in unique_bids
    ]
    a(",\n".join(bid_rows) + ";")
    a("GO")
    a("")

    # ----- 11. WATCHLISTS -----
    a("-- 11. watchlists")
    watch_bidders = verified_ids[:15]
    live_aids = [m["aid"] for m in auction_defs if m["status"] in ("ACTIVE", "SCHEDULED")]
    wl_items_plan = []
    wl_counts = []
    for wi, bidder in enumerate(watch_bidders):
        n = 2 + (wi % 3)
        chosen = [live_aids[(wi + j) % len(live_aids)] for j in range(n)] if live_aids else []
        chosen = list(dict.fromkeys(chosen))
        wl_counts.append(len(chosen))
        for aid in chosen:
            wl_items_plan.append((wi + 1, aid))

    a("INSERT INTO dbo.watchlists (bidder_id, total_items, updated_at) VALUES")
    wl_rows = [
        f"({b}, {wl_counts[i]}, GETDATE())" for i, b in enumerate(watch_bidders)
    ]
    a(",\n".join(wl_rows) + ";")
    a("GO")
    a("")

    # ----- 12. WATCHLIST ITEMS -----
    a("-- 12. watchlist_items")
    a("INSERT INTO dbo.watchlist_items (watchlist_id, auction_id, added_at) VALUES")
    seen_wi = set()
    wi_rows = []
    for wl_id, aid in wl_items_plan:
        if (wl_id, aid) in seen_wi:
            continue
        seen_wi.add((wl_id, aid))
        wi_rows.append(f"({wl_id}, {aid}, DATEADD(HOUR, -{wl_id * 2}, GETDATE()))")
    a(",\n".join(wi_rows) + ";")
    a("GO")
    a("")

    # ----- 13. ORDERS (6 đơn hàng từ 6 phiên ENDED_SOLD) -----
    sold = [m for m in auction_defs if m["status"] == "ENDED_SOLD" and "winner" in m]
    order_statuses = ["COMPLETED", "DELIVERED", "SHIPPING", "PAID", "PENDING_PAYMENT", "DISPUTED"]

    a("-- 13. orders (6 đơn hàng đa dạng trạng thái để kiểm thử nghiệp vụ)")
    a("INSERT INTO dbo.orders (auction_id, buyer_id, hammer_price, buyers_premium, shipping_fee, total_amount,")
    a(" payment_deadline, status, delivered_at, completed_at, created_at) VALUES")
    order_defs = []
    order_rows = []
    for i, meta in enumerate(sold):
        ost = order_statuses[i % len(order_statuses)]
        hammer = meta["hammer_val"]
        premium = hammer // 10
        ship = 350_000 + (i % 5) * 50_000
        total = hammer + premium + ship
        buyer = meta["winner"]

        deadline = f"DATEADD(DAY, -{10 - i}, GETDATE())"
        delivered = "NULL"
        completed = "NULL"
        if ost in ("COMPLETED", "DELIVERED", "DISPUTED"):
            delivered = f"DATEADD(DAY, -{8 - i}, GETDATE())"
        if ost == "COMPLETED":
            completed = f"DATEADD(DAY, -{6 - i}, GETDATE())"
        created = f"DATEADD(DAY, -{14 - i}, GETDATE())"

        order_defs.append({
            "oid": i + 1, "aid": meta["aid"], "buyer": buyer, "hammer": hammer,
            "premium": premium, "ship": ship, "total": total, "status": ost,
            "item_id": meta["item_id"],
        })
        order_rows.append(
            f"({meta['aid']}, {buyer}, {hammer}, {premium}, {ship}, {total}, "
            f"{deadline}, '{ost}', {delivered}, {completed}, {created})"
        )

        if ost == "COMPLETED":
            item_meta[meta["item_id"] - 1]["status"] = "SOLD_DELIVERED"
        elif ost in ("SHIPPING", "PAID", "DELIVERED"):
            item_meta[meta["item_id"] - 1]["status"] = "SOLD_DELIVERING"
        elif ost == "PENDING_PAYMENT":
            item_meta[meta["item_id"] - 1]["status"] = "RESERVED_PENDING_PAYMENT"
        elif ost == "DISPUTED":
            item_meta[meta["item_id"] - 1]["status"] = "AVAILABLE"

    a(",\n".join(order_rows) + ";")
    a("GO")
    a("")

    # Cập nhật status hiện vật
    a("-- Cập nhật status hiện vật tương ứng sau khi mở phiên và tạo đơn")
    by_status = {}
    for m in item_meta:
        by_status.setdefault(m["status"], []).append(m["id"])
    for st, ids in by_status.items():
        a(f"UPDATE dbo.antique_items SET status = '{st}' WHERE item_id IN ({','.join(map(str, ids))});")
    a("GO")
    a("")

    # ----- 14. PAYMENTS -----
    a("-- 14. payments")
    pay_rows = []
    pid = 0
    charge_id_by_order = {}
    for o in order_defs:
        oid, ost, total = o["oid"], o["status"], o["total"]
        if ost == "PENDING_PAYMENT":
            pid += 1
            pay_rows.append((oid, "CHARGE", total, "PENDING", f"GW-TXN-P{oid:03d}-01", f"DATEADD(DAY, -3, GETDATE())"))
            charge_id_by_order[oid] = pid
        else:
            pid += 1
            pay_rows.append((oid, "CHARGE", total, "SUCCESS", f"GW-TXN-P{oid:03d}-01", f"DATEADD(DAY, -{12 - oid}, GETDATE())"))
            charge_id_by_order[oid] = pid

    a("INSERT INTO dbo.payments (order_id, original_payment_id, type, amount, status, gateway_txn_id, created_at) VALUES")
    a(",\n".join(
        f"({oid}, NULL, '{typ}', {amt}, '{st}', '{gw}', {ts})"
        for oid, typ, amt, st, gw, ts in pay_rows
    ) + ";")
    a("GO")
    a("")

    # Refund cho đơn DISPUTED
    refund_rows = []
    for o in order_defs:
        if o["status"] == "DISPUTED":
            orig = charge_id_by_order[o["oid"]]
            refund_rows.append(
                f"({o['oid']}, {orig}, 'REFUND', {o['total']}, 'PENDING', 'GW-TXN-P{o['oid']:03d}-REF', GETDATE())"
            )
    if refund_rows:
        a("INSERT INTO dbo.payments (order_id, original_payment_id, type, amount, status, gateway_txn_id, created_at) VALUES")
        a(",\n".join(refund_rows) + ";")
        a("GO")
        a("")

    # ----- 15. SHIPMENTS -----
    a("-- 15. shipments")
    ship_rows = []
    for o in order_defs:
        track = sql_n(f"AB-SHIP-{o['oid']:04d}")
        if o["status"] == "PENDING_PAYMENT":
            continue
        if o["status"] == "PAID":
            ship_rows.append(
                f"({o['oid']}, {track}, {sql_n('Đang chuẩn bị hộp bảo vệ & xốp định hình')}, "
                f"{o['hammer']}, 'PREPARING', NULL, NULL, DATEADD(DAY, -3, GETDATE()))"
            )
        elif o["status"] == "SHIPPING":
            ship_rows.append(
                f"({o['oid']}, {track}, {sql_n('Thùng gỗ chuyên dụng chống sốc')}, "
                f"{o['hammer']}, 'IN_TRANSIT', DATEADD(DAY, -2, GETDATE()), NULL, DATEADD(DAY, -3, GETDATE()))"
            )
        else:
            ship_rows.append(
                f"({o['oid']}, {track}, {sql_n('Hòm chuyên dụng có niêm phong')}, "
                f"{o['hammer']}, 'DELIVERED', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -8, GETDATE()))"
            )

    a("INSERT INTO dbo.shipments (order_id, tracking_code, packaging_info, insured_value, status, shipped_at, delivered_at, created_at) VALUES")
    a(",\n".join(ship_rows) + ";")
    a("GO")
    a("")

    # ----- 16. DISPUTES -----
    a("-- 16. disputes")
    disp_rows = []
    for o in order_defs:
        if o["status"] == "DISPUTED":
            disp_rows.append(
                f"({o['oid']}, {o['buyer']}, {sql_n('Hiện vật khi nhận có vết nứt nhỏ ở chân đế')}, "
                f"'/uploads/disputes/order{o['oid']}.jpg', 'PENDING', NULL, DATEADD(DAY, -2, GETDATE()), NULL)"
            )
    if disp_rows:
        a("INSERT INTO dbo.disputes (order_id, bidder_id, reason, evidence_url, status, resolution, filed_at, resolved_at) VALUES")
        a(",\n".join(disp_rows) + ";")
        a("GO")
        a("")

    # ----- 17. NOTIFICATIONS -----
    a("-- 17. notifications")
    notif_rows = []
    # KYC notifications
    for i in range(N_BIDDERS):
        uid = i + 3
        kyc = kyc_cycle[i % len(kyc_cycle)]
        if i in (13, 27):
            kyc = "REJECTED"
        if kyc == "VERIFIED":
            notif_rows.append(
                f"({uid}, {sql_n('KYC được phê duyệt')}, {sql_n('Hồ sơ định danh của bạn đã được xác minh thành công.')}, 'KYC_APPROVED', 1, DATEADD(DAY, -20, GETDATE()))"
            )
        elif kyc == "REJECTED":
            notif_rows.append(
                f"({uid}, {sql_n('Yêu cầu bổ sung KYC')}, {sql_n('Ảnh giấy tờ chưa rõ nét, vui lòng cập nhật lại.')}, 'KYC_REJECTED', 0, DATEADD(DAY, -10, GETDATE()))"
            )

    # Auction notifications
    for o in order_defs:
        notif_rows.append(
            f"({o['buyer']}, {sql_n('Chúc mừng thắng phiên!')}, {sql_n(f'Bạn đã đấu giá thành công phiên #{o['aid']}. Vui lòng thanh toán đơn #{o['oid']}.')}, 'AUCTION_WON', 1, DATEADD(DAY, -14, GETDATE()))"
        )

    for meta in auction_defs:
        if meta["status"] == "ACTIVE":
            b = verified_ids[(meta["aid"]) % len(verified_ids)]
            notif_rows.append(
                f"({b}, {sql_n('Phiên đang diễn ra')}, {sql_n(f'Phiên #{meta['aid']} sắp kết thúc trong hôm nay. Đừng bỏ lỡ!')}, 'OUTBID', 0, DATEADD(MINUTE, -30, GETDATE()))"
            )

    a("INSERT INTO dbo.notifications (recipient_id, title, content, type, is_read, created_at) VALUES")
    a(",\n".join(notif_rows) + ";")
    a("GO")
    a("")

    # ----- 18. AUDIT LOGS -----
    a("-- 18. audit_logs")
    audit_rows = [
        f"(1, 'USER_CREATE', 'USER', 1, {sql_n('Khởi tạo hệ thống quản trị')}, DATEADD(DAY, -30, GETDATE()))",
        f"(1, 'CATEGORY_CREATE', 'CATEGORY', 1, {sql_n('Khởi tạo 5 danh mục cổ vật chuẩn')}, DATEADD(DAY, -28, GETDATE()))",
        f"(1, 'APPRAISAL_PASS', 'ITEM', 1, {sql_n('Cấp chứng thư giám định cho cổ vật')}, DATEADD(DAY, -25, GETDATE()))",
        f"(1, 'AUCTION_CREATE', 'AUCTION', 1, {sql_n('Mở phiên đấu giá mới')}, DATEADD(DAY, -15, GETDATE()))",
        f"(1, 'ORDER_COMPLETE', 'ORDER', 1, {sql_n('Hoàn tất đơn hàng #1')}, DATEADD(DAY, -6, GETDATE()))",
        f"(NULL, 'SYSTEM_SEED', 'SYSTEM', 0, {sql_n('Nạp dữ liệu mẫu chuẩn: 30 phiên đấu giá, 5 danh mục')}, GETDATE())",
    ]
    a("INSERT INTO dbo.audit_logs (actor_id, action, entity_type, entity_id, detail, created_at) VALUES")
    a(",\n".join(audit_rows) + ";")
    a("GO")
    a("")

    # ----- COUNT CHECK -----
    a("-- =========================================================================")
    a("-- KIỂM TRA SỐ LƯỢNG BẢNG DỮ LIỆU")
    a("-- =========================================================================")
    a("SELECT N'users' AS bang, COUNT(*) AS so_dong FROM dbo.users")
    for t in [
        "bidder_profiles", "verification_documents", "categories", "antique_items", "item_images",
        "provenance_records", "appraisal_certificates", "auctions", "bids", "watchlists",
        "watchlist_items", "orders", "payments", "shipments", "disputes", "notifications", "audit_logs",
    ]:
        a(f"UNION ALL SELECT N'{t}', COUNT(*) FROM dbo.{t}")
    a("ORDER BY bang;")
    a("GO")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print("Successfully generated seed_data.sql")
    print("Users: %d" % (2 + N_BIDDERS))
    print("Categories: %d" % len(CATEGORIES))
    print("Items: %d" % N_ITEMS)
    print("Auctions: %d (Active: 12, Scheduled: 8, Ended/Cancelled: 10)" % N_AUCTIONS)
    print("Orders: %d, Bids: %d" % (len(order_defs), len(unique_bids)))


if __name__ == "__main__":
    main()
