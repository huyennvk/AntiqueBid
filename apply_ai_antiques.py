# -*- coding: utf-8 -*-
"""
Apply AI generated antique images across all 40 items, 5 categories, and fallbacks.
Creates ultra-sharp primary images and high-detail macro close-ups for detail galleries.
"""
import sys
import os
import shutil
import urllib.request
import json
from pathlib import Path
from PIL import Image, ImageEnhance

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

BRAIN_DIR = Path(r"C:\Users\Khanh Huyen\.gemini\antigravity-ide\brain\dab91d90-63c0-4cfe-ac0d-f3b3ffe1b7c6")
SRC_DIR = Path(r"s:\Kì 5\Phân tích và thiết kế HTTTQL\AntiqueBid\antiquebid\src\main\webapp\assets\images")
TARGET_DIR = Path(r"s:\Kì 5\Phân tích và thiết kế HTTTQL\AntiqueBid\antiquebid\target\antiquebid-1.0-SNAPSHOT\assets\images")

ITEMS_SRC = SRC_DIR / "items"
ITEMS_TARGET = TARGET_DIR / "items"
CATS_SRC = SRC_DIR / "categories"
CATS_TARGET = TARGET_DIR / "categories"

for d in [ITEMS_SRC, ITEMS_TARGET, CATS_SRC, CATS_TARGET]:
    d.mkdir(parents=True, exist_ok=True)

# 13 Pure AI generated images
AI_IMAGES = {
    0: BRAIN_DIR / "ai_porcelain_vase_1792569496626.jpg",   # Bình gốm hoa lam
    1: BRAIN_DIR / "ai_chudau_plate_1792569534658.jpg",     # Đĩa gốm Chu Đậu
    2: BRAIN_DIR / "ai_celadon_bowl_1792569565117.jpg",     # Bát men ngọc Celadon
    3: BRAIN_DIR / "ai_battrang_vase_1792569596103.jpg",    # Lọ hoa Bát Tràng
    4: BRAIN_DIR / "ai_bronze_buddha_1792569627689.jpg",    # Tượng Phật đồng
    5: BRAIN_DIR / "ai_bronze_ding_1792569662382.jpg",      # Đỉnh đồng tam khí
    6: BRAIN_DIR / "ai_bronze_burner_1792569696545.jpg",    # Lư hương đồng
    7: BRAIN_DIR / "ai_bronze_qilin_1792569736515.jpg",     # Tượng Lân đồng
    8: BRAIN_DIR / "ai_ink_painting_1792569770071.jpg",     # Tranh thủy mặc Tùng Hạc
    9: BRAIN_DIR / "ai_lacquer_painting_1792569805318.jpg", # Tranh sơn mài cổ
    10: BRAIN_DIR / "ai_hannom_scroll_1792569848209.jpg",   # Cuốn thư Hán Nôm
    11: BRAIN_DIR / "ai_ebony_couplets_1792569887155.jpg",  # Bộ câu đối gỗ mun
    12: BRAIN_DIR / "ai_inlaid_cabinet_1792569932245.jpg",  # Tủ chè gỗ trắc khảm ốc
}

# Matching museum studio URLs for 5 remaining templates
STUDIO_URLS = {
    13: "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/91/%E6%98%8E%E6%9C%AB%E6%B8%85%E5%88%9D_%E9%BB%83%E8%8A%B1%E6%A2%A8%E7%BF%B9%E9%A0%AD%E6%A1%88-Side_Table_MET_DP260285.jpg/1280px-%E6%98%8E%E6%9C%AB%E6%B8%85%E5%88%9D_%E9%BB%83%E8%8A%B1%E6%A2%A8%E7%BF%B9%E9%A0%AD%E6%A1%88-Side_Table_MET_DP260285.jpg", # Bàn trà huanghuali
    14: "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c2/Folding_screen%2C_c._1650%2C_Coromandel_lacquer_panels%2C_brass_hinges_-_Ham_House_-_London%2C_UK_-_DSC07886.jpg/1280px-Folding_screen%2C_c._1650%2C_Coromandel_lacquer_panels%2C_brass_hinges_-_Ham_House_-_London%2C_UK_-_DSC07886.jpg", # Bình phong Coromandel
    15: "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a0/MET_184061.jpg/1280px-MET_184061.jpg", # Vòng ngọc bích
    16: "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f7/Finger_ring_with_ancient_intaglio_MET_DP30557.jpg/1280px-Finger_ring_with_ancient_intaglio_MET_DP30557.jpg", # Nhẫn vàng chạm
    17: "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c8/Ming_Jade_Hairpin_%2810093447116%29.jpg/1280px-Ming_Jade_Hairpin_%2810093447116%29.jpg", # Trâm bạc đính ngọc
}

HEADERS = {"User-Agent": "AntiqueBid/1.0 (contact@antiquebid.vn)"}

def download_and_prepare_template(t_idx: int) -> Image.Image:
    """Load or download template image, ensuring 1024x1024 RGB."""
    if t_idx in AI_IMAGES and AI_IMAGES[t_idx].exists():
        im = Image.open(AI_IMAGES[t_idx]).convert("RGB")
        return im.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    url = STUDIO_URLS.get(t_idx)
    if not url:
        # Fallback to porcelain vase
        return Image.open(AI_IMAGES[0]).convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    
    tmp_path = BRAIN_DIR / f"temp_tpl_{t_idx}.jpg"
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=12) as resp:
        with open(tmp_path, "wb") as f:
            f.write(resp.read())
    
    im = Image.open(tmp_path).convert("RGB")
    # Center crop square
    w, h = im.size
    min_dim = min(w, h)
    left = (w - min_dim) // 2
    top = (h - min_dim) // 2
    im_cropped = im.crop((left, top, left + min_dim, top + min_dim))
    # Enhance slightly to match AI vibrancy
    enhancer = ImageEnhance.Contrast(im_cropped)
    im_enhanced = enhancer.enhance(1.15)
    return im_enhanced.resize((1024, 1024), Image.Resampling.LANCZOS)

def make_macro_crop(im: Image.Image) -> Image.Image:
    """Create a close-up macro detail crop of the central 55% area."""
    w, h = im.size
    crop_w, crop_h = int(w * 0.55), int(h * 0.55)
    left = (w - crop_w) // 2
    top = int(h * 0.28)  # slightly higher than vertical center to catch dragon/face/inlay
    crop = im.crop((left, top, left + crop_w, top + crop_h))
    return crop.resize((1024, 1024), Image.Resampling.LANCZOS)

def main():
    print("Preparing 18 Master Archetype Images...")
    master_templates = {}
    master_details = {}

    for t_idx in range(18):
        print(f"Loading template {t_idx}...")
        base_im = download_and_prepare_template(t_idx)
        macro_im = make_macro_crop(base_im)
        master_templates[t_idx] = base_im
        master_details[t_idx] = macro_im

    # Generate 40 items
    print("\nGenerating 40 Item Images and Detail Close-ups...")
    item_image_files = {}
    for item_id in range(1, 41):
        t_idx = (item_id - 1) % 18
        prim_im = master_templates[t_idx]
        detail_im = master_details[t_idx]

        prim_name = f"real_item_{item_id}.jpg"
        sec_name = f"real_item_{item_id}_detail.jpg"

        p_prim = ITEMS_SRC / prim_name
        p_sec = ITEMS_SRC / sec_name

        prim_im.save(p_prim, "JPEG", quality=92)
        detail_im.save(p_sec, "JPEG", quality=90)

        # Copy to target runtime
        shutil.copy2(p_prim, ITEMS_TARGET / prim_name)
        shutil.copy2(p_sec, ITEMS_TARGET / sec_name)

        s1 = p_prim.stat().st_size
        s2 = p_sec.stat().st_size

        item_image_files[item_id] = {
            "primary": {"file": f"assets/images/items/{prim_name}", "size": s1, "mime": "image/jpeg"},
            "secondary": {"file": f"assets/images/items/{sec_name}", "size": s2, "mime": "image/jpeg"}
        }
        print(f"Item {item_id:2d}: saved {prim_name} ({s1//1024} KB), detail ({s2//1024} KB)")

    # Generate 5 Category Images
    print("\nUpdating Category Images...")
    cat_mapping = {
        1: 0,   # Gốm sứ cổ -> Imperial blue & white vase
        2: 5,   # Đồ đồng & Tượng cổ -> Bronze ding tripod censer
        3: 9,   # Tranh cổ & Thư pháp -> Lacquer palace painting
        4: 12,  # Đồ gỗ mỹ nghệ -> Mother of pearl rosewood cabinet
        5: 15,  # Ngọc bích & Trang sức -> Imperial jade
    }
    for cat_id, t_idx in cat_mapping.items():
        cat_name = f"cat_{cat_id}.jpg"
        cat_p = CATS_SRC / cat_name
        master_templates[t_idx].save(cat_p, "JPEG", quality=92)
        shutil.copy2(cat_p, CATS_TARGET / cat_name)
        print(f"Category {cat_id}: saved {cat_name}")

    # Update fallbacks item_1..5 and antique_default
    print("\nUpdating fallbacks...")
    fb_mapping = {
        "item_1.jpg": master_templates[0],   # Blue white vase
        "item_2.jpg": master_templates[4],   # Bronze Buddha
        "item_3.jpg": master_templates[8],   # Pine & Crane painting
        "item_4.jpg": master_templates[12],  # Inlaid cabinet
        "item_5.jpg": master_templates[1],   # Chu Dau plate
        "antique_default.jpg": master_templates[5], # Bronze ding
    }
    for fb_name, im in fb_mapping.items():
        src_p = SRC_DIR / fb_name
        tgt_p = TARGET_DIR / fb_name
        im.save(src_p, "JPEG", quality=92)
        shutil.copy2(src_p, tgt_p)
        print(f"Fallback {fb_name} updated.")

    # Update database
    print("\nUpdating SQL Server AntiqueBidDB...")
    import pyodbc
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost,1433;DATABASE=AntiqueBidDB;"
        "UID=antiquebid_user;PWD=AntiqueBid@2026"
    )
    cursor = conn.cursor()
    cursor.execute("DELETE FROM dbo.item_images")
    for item_id, data in item_image_files.items():
        prim = data["primary"]
        sec = data["secondary"]
        cursor.execute(
            "INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) "
            "VALUES (?, ?, ?, ?, 1, 1, GETDATE())",
            (item_id, prim["file"], prim["mime"], prim["size"])
        )
        cursor.execute(
            "INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) "
            "VALUES (?, ?, ?, ?, 0, 2, GETDATE())",
            (item_id, sec["file"], sec["mime"], sec["size"])
        )
    conn.commit()
    cursor.execute("SELECT COUNT(*) FROM dbo.item_images")
    cnt = cursor.fetchone()[0]
    print(f"SUCCESS: Database updated. Total item_images count = {cnt}")
    conn.close()

if __name__ == "__main__":
    main()
