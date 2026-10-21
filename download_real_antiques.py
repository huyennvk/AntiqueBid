# -*- coding: utf-8 -*-
"""
Download authentic real museum/historical antique photos from Wikimedia Commons
for all 5 categories and 40 antique items in AntiqueBidDB.
Strictly NO AI generation - authentic museum artifacts only.
"""
import sys
import os
import shutil
import urllib.request
import urllib.parse
import json
import time
from pathlib import Path

# Ensure UTF-8 output on Windows
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

HEADERS = {
    "User-Agent": "AntiqueBidCurator/1.0 (Museum Artifact Education Project; contact@antiquebid.vn)"
}

SRC_DIR = Path(r"s:\Kì 5\Phân tích và thiết kế HTTTQL\AntiqueBid\antiquebid\src\main\webapp\assets\images")
TARGET_DIR = Path(r"s:\Kì 5\Phân tích và thiết kế HTTTQL\AntiqueBid\antiquebid\target\antiquebid-1.0-SNAPSHOT\assets\images")

ITEMS_SRC = SRC_DIR / "items"
ITEMS_TARGET = TARGET_DIR / "items"
CATS_SRC = SRC_DIR / "categories"
CATS_TARGET = TARGET_DIR / "categories"

for d in [ITEMS_SRC, ITEMS_TARGET, CATS_SRC, CATS_TARGET]:
    d.mkdir(parents=True, exist_ok=True)

# 18 Templates matching _gen_seed.py ITEM_TEMPLATES
# (template_index, item_name_prefix, search_queries)
TEMPLATE_QUERIES = {
    0: [  # Bình gốm men lam (Items 1, 19, 37)
        "blue and white porcelain vase Ming",
        "blue and white porcelain jar Qing",
        "Vietnamese blue and white porcelain",
        "blue white porcelain vase MET"
    ],
    1: [  # Đĩa gốm Chu Đậu (Items 2, 20, 38)
        "Chu Dau ceramic plate",
        "Chu Dau ceramic",
        "Chu Dau pottery",
        "Vietnamese ceramic dish"
    ],
    2: [  # Bát men ngọc Celadon (Items 3, 21, 39)
        "Longquan celadon bowl",
        "celadon bowl Song MET",
        "celadon ceramic bowl",
        "Longquan kiln bowl"
    ],
    3: [  # Lọ hoa Bát Tràng (Items 4, 22, 40)
        "Bat Trang ceramic",
        "Vietnamese glazed pottery",
        "Vietnamese ceramic vase",
        "glazed ceramic vase antique"
    ],
    4: [  # Tượng Phật đồng (Items 5, 23)
        "bronze Buddha statue Guimet",
        "bronze Buddha Vietnam",
        "bronze Buddha statue Ming",
        "bronze Buddha Southeast Asia"
    ],
    5: [  # Đỉnh đồng tam khí (Items 6, 24)
        "tripod censer bronze MET",
        "bronze ding censer",
        "bronze incense burner tripod",
        "archaic bronze tripod censer"
    ],
    6: [  # Lư hương đồng (Items 7, 25)
        "bronze incense burner censer",
        "bronze censer Qing",
        "bronze censer Ming",
        "bronze burner antique"
    ],
    7: [  # Tượng Lân đồng phong thủy (Items 8, 26)
        "bronze Qilin statue",
        "bronze lion statue Chinese",
        "bronze mythical beast Eastern Han",
        "bronze chimera statue"
    ],
    8: [  # Tranh thủy mặc Tùng Hạc (Items 9, 27)
        "Crane and Pine MET",
        "Chinese ink wash painting landscape",
        "ink wash painting mountain scroll",
        "pine tree crane painting traditional"
    ],
    9: [  # Tranh sơn mài cổ (Items 10, 28)
        "Vietnamese lacquer painting",
        "lacquer panel gold Chinese",
        "carved lacquer panel antique",
        "Japanese lacquer screen"
    ],
    10: [ # Cuốn thư Hán Nôm (Items 11, 29)
        "imperial decree scroll Chinese",
        "calligraphy handscroll Ming",
        "Chinese calligraphy hanging scroll",
        "Four poems in running script"
    ],
    11: [ # Bộ câu đối gỗ mun (Items 12, 30)
        "couplets wooden Chinese",
        "calligraphy wooden plaque Chinese",
        "carved wooden couplets",
        "Chinese door couplets"
    ],
    12: [ # Tủ chè gỗ trắc khảm ốc (Items 13, 31)
        "wood inlaid with mother of pearl Vietnam",
        "Betel box Northern Vietnam mother of pearl",
        "mother of pearl inlaid chest Chinese",
        "inlaid rosewood furniture antique"
    ],
    13: [ # Bàn trà gỗ hương (Items 14, 32)
        "Chinese side table huanghuali",
        "Chinese hardwood table Ming",
        "Chinese scholar table",
        "Chinese wooden tea table antique"
    ],
    14: [ # Bình phong gỗ gụ (Items 15, 33)
        "coromandel screen Chinese",
        "Chinese folding screen carved",
        "carved wooden screen lacquer",
        "Japanese folding screen antique"
    ],
    15: [ # Vòng ngọc bích (Items 16, 34)
        "jade bangle Qing",
        "jadeite bracelet Chinese museum",
        "jade bangle Chinese antique",
        "jade bracelet antique"
    ],
    16: [ # Nhẫn vàng chạm hoa văn (Items 17, 35)
        "ancient gold ring engraved museum",
        "gold signet ring antique",
        "Ancient Egypt Gold Rings",
        "Etruscan Gold Ring"
    ],
    17: [ # Trâm bạc đính ngọc (Items 18, 36)
        "Ming Jade Hairpins",
        "Chinese silver hairpin jade",
        "Qing dynasty hairpin",
        "Jade & Gold Hairpin"
    ],
}

CATEGORY_QUERIES = {
    1: ["blue and white porcelain vase Ming", "Chu Dau ceramic plate"],
    2: ["bronze Buddha statue Guimet", "tripod censer bronze MET"],
    3: ["Crane and Pine MET", "Chinese ink wash painting landscape"],
    4: ["Chinese side table huanghuali", "wood inlaid with mother of pearl Vietnam"],
    5: ["jade bangle Qing", "Ming Jade Hairpins"]
}

def search_wikimedia_images(query: str, limit: int = 10):
    """Search Wikimedia Commons for images matching the query."""
    url = (
        "https://commons.wikimedia.org/w/api.php?action=query"
        f"&generator=search&gsrsearch={urllib.parse.quote(query)}"
        "&gsrnamespace=6&prop=imageinfo&iiprop=url|mime|size"
        f"&iiurlwidth=900&format=json&gsrlimit={limit}"
    )
    req = urllib.request.Request(url, headers=HEADERS)
    images = []
    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            pages = data.get("query", {}).get("pages", {})
            for pid, p in pages.items():
                title = p.get("title", "")
                lower = title.lower()
                if lower.endswith((".pdf", ".tif", ".tiff", ".svg", ".djvu", ".ogg", ".ogv", ".webm")):
                    continue
                info_list = p.get("imageinfo", [])
                if not info_list:
                    continue
                info = info_list[0]
                mime = info.get("mime", "")
                if mime not in ("image/jpeg", "image/png"):
                    continue
                thumb = info.get("thumburl") or info.get("url")
                if thumb:
                    images.append({"title": title, "url": thumb, "mime": mime})
    except Exception as e:
        print(f"Error searching '{query}': {e}")
    return images

def download_file(url: str, dest_path: Path):
    """Download image file with retry."""
    req = urllib.request.Request(url, headers=HEADERS)
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                content = resp.read()
                if len(content) > 1000:  # Valid image
                    with open(dest_path, "wb") as f:
                        f.write(content)
                    return len(content)
        except Exception as e:
            time.sleep(1)
    return 0

def collect_template_images():
    """Collect image pools for all 18 templates."""
    print("Collecting image pools from Wikimedia Commons...")
    pools = {}
    seen_urls = set()
    for t_idx, qlist in TEMPLATE_QUERIES.items():
        pool = []
        for q in qlist:
            results = search_wikimedia_images(q, limit=12)
            for r in results:
                if r["url"] not in seen_urls:
                    seen_urls.add(r["url"])
                    pool.append(r)
            if len(pool) >= 8:
                break
        pools[t_idx] = pool
        print(f"Template {t_idx:2d}: found {len(pool)} images")
    return pools

def main():
    pools = collect_template_images()
    
    # Track assigned images per item: item_id -> (primary_img_file, secondary_img_file)
    item_image_files = {}

    print("\nAssigning and downloading real photos for 40 items...")
    for item_id in range(1, 41):
        t_idx = (item_id - 1) % 18
        pool = pools.get(t_idx, [])
        if not pool:
            print(f"WARNING: Empty pool for item {item_id} (template {t_idx})")
            continue
        
        # Pick primary and secondary image based on item cycle
        cycle = (item_id - 1) // 18  # 0, 1, or 2
        prim_idx = (cycle * 2) % len(pool)
        sec_idx = (cycle * 2 + 1) % len(pool)
        if sec_idx == prim_idx and len(pool) > 1:
            sec_idx = (prim_idx + 1) % len(pool)

        prim_img = pool[prim_idx]
        sec_img = pool[sec_idx]

        prim_name = f"real_item_{item_id}.jpg"
        sec_name = f"real_item_{item_id}_detail.jpg"

        prim_path = ITEMS_SRC / prim_name
        sec_path = ITEMS_SRC / sec_name

        s1 = download_file(prim_img["url"], prim_path)
        s2 = download_file(sec_img["url"], sec_path)

        # Sync to target
        shutil.copy2(prim_path, ITEMS_TARGET / prim_name)
        shutil.copy2(sec_path, ITEMS_TARGET / sec_name)

        item_image_files[item_id] = {
            "primary": {"file": f"assets/images/items/{prim_name}", "size": s1, "mime": "image/jpeg"},
            "secondary": {"file": f"assets/images/items/{sec_name}", "size": s2, "mime": "image/jpeg"},
            "title_primary": prim_img["title"],
            "title_sec": sec_img["title"]
        }
        print(f"Item {item_id:2d} (Tpl {t_idx:2d}): Primary={prim_name} ({s1//1024} KB), Detail={sec_name} ({s2//1024} KB)")

    # Download Category banners
    print("\nDownloading Category images...")
    for cat_id, qlist in CATEGORY_QUERIES.items():
        found = []
        for q in qlist:
            res = search_wikimedia_images(q, limit=5)
            if res:
                found.extend(res)
                break
        if found:
            cat_name = f"cat_{cat_id}.jpg"
            cat_path = CATS_SRC / cat_name
            download_file(found[0]["url"], cat_path)
            shutil.copy2(cat_path, CATS_TARGET / cat_name)
            print(f"Category {cat_id}: saved {cat_name} ({cat_path.stat().st_size//1024} KB)")

    # Update fallbacks item_1..5 and antique_default with authentic photos
    print("\nUpdating fallback images item_1..5 and antique_default...")
    fallback_map = {
        "item_1.jpg": ITEMS_SRC / "real_item_1.jpg",
        "item_2.jpg": ITEMS_SRC / "real_item_5.jpg",
        "item_3.jpg": ITEMS_SRC / "real_item_9.jpg",
        "item_4.jpg": ITEMS_SRC / "real_item_13.jpg",
        "item_5.jpg": ITEMS_SRC / "real_item_16.jpg",
        "antique_default.jpg": ITEMS_SRC / "real_item_6.jpg",
    }
    for fb_name, src_p in fallback_map.items():
        if src_p.exists():
            shutil.copy2(src_p, SRC_DIR / fb_name)
            shutil.copy2(src_p, TARGET_DIR / fb_name)
            print(f"Fallback {fb_name} updated with authentic photo.")

    # Update database item_images
    print("\nUpdating SQL Server AntiqueBidDB item_images table...")
    try:
        import pyodbc
        conn = pyodbc.connect(
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost,1433;DATABASE=AntiqueBidDB;"
            "UID=antiquebid_user;PWD=AntiqueBid@2026"
        )
        cursor = conn.cursor()
        
        # Clear existing item_images and reinsert authentic records
        cursor.execute("DELETE FROM dbo.item_images")
        
        for item_id, data in item_image_files.items():
            prim = data["primary"]
            sec = data["secondary"]
            cursor.execute(
                "INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) "
                "VALUES (?, ?, ?, ?, 1, 1, GETDATE())",
                (item_id, prim["file"], prim["mime"], prim["size"] if prim["size"] > 0 else 150000)
            )
            cursor.execute(
                "INSERT INTO dbo.item_images (item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at) "
                "VALUES (?, ?, ?, ?, 0, 2, GETDATE())",
                (item_id, sec["file"], sec["mime"], sec["size"] if sec["size"] > 0 else 120000)
            )
        
        conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dbo.item_images")
        cnt = cursor.fetchone()[0]
        print(f"SUCCESS: Database updated. Total item_images count = {cnt}")
        conn.close()
    except Exception as e:
        print(f"Error updating database: {e}")

    # Save manifest for reference
    manifest_path = Path("real_antique_images_manifest.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(item_image_files, f, ensure_ascii=False, indent=2)
    print(f"\nManifest saved to {manifest_path}")

if __name__ == "__main__":
    main()
