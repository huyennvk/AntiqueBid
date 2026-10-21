<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Category" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Auction> liveAuctions = (List<Auction>) request.getAttribute("liveAuctions");
    List<Auction> upcomingAuctions = (List<Auction>) request.getAttribute("upcomingAuctions");
    List<Auction> endedAuctions = (List<Auction>) request.getAttribute("endedAuctions");
    Set<Long> watchedAuctionIds = (Set<Long>) request.getAttribute("watchedAuctionIds");

    Long selectedCategory = (Long) request.getAttribute("selectedCategory");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String currentTab = (String) request.getAttribute("currentTab");
    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    String ctx = request.getContextPath();

    boolean hasSearchParam = request.getParameter("search") != null;
    boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
    boolean hasCategory = selectedCategory != null;
    boolean hasDates = (fromDate != null && !fromDate.trim().isEmpty()) || (toDate != null && !toDate.trim().isEmpty());
    boolean hasStatusFilter = selectedStatus != null && !"all".equalsIgnoreCase(selectedStatus);

    boolean isSearching = hasSearchParam || hasKeyword || hasCategory || hasDates || hasStatusFilter;
    int perPageVal = isSearching ? 6 : 8;
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Danh mục cổ vật & Phiên đấu giá | AntiqueBid" />
    <jsp:param name="extraCss" value="catalogue.css?v=radius_fix2" />
</jsp:include>
<% if (isSearching) { %>
<link rel="stylesheet" href="<%= ctx %>/assets/css/sidebar.css?v=20">
<% } %>

    <!-- 1. Hero Banner Triển Lãm Hoàng Gia (Rút gọn) -->
    <section class="hero-banner" id="intro-banner">
        <div class="container">
            <h1 class="hero-title">
                Sàn Đấu Giá Cổ Vật Trực Tuyến
            </h1>
            <p class="hero-desc">
                Khám phá kho tàng di sản gốm sứ, đồ đồng, tranh thủy mặc và tiền cổ các triều đại.
            </p>
        </div>
    </section>

    <!-- 2. Danh mục chính & Lưới hiện vật -->
    <main class="container catalogue-main">
        <div class="catalogue-layout <%= isSearching ? "has-sidebar" : "no-sidebar" %>">
            <% if (isSearching) { %>
            <!-- CỘT TRÁI: SIDEBAR LỌC (Chỉ hiển thị khi đang trong chế độ tìm kiếm/lọc) -->
            <aside class="catalogue-sidebar">
                <jsp:include page="/WEB-INF/sidebar_filter.jsp" />
            </aside>
            <% } %>

            <!-- CỘT PHẢI: NỘI DUNG DANH MỤC & PHIÊN ĐẤU GIÁ -->
            <div class="catalogue-content">


                <!-- 1. PHIÊN ĐẤU GIÁ TRỰC TIẾP -->
                <div class="catalogue-section-bar" id="live-auctions">
                    <div class="catalogue-section-title-wrap">
                        <span class="section-dot-live"></span>
                        <h2 class="catalogue-section-title">Phiên Đấu Giá Đang Trực Tiếp</h2>
                        <span class="catalogue-count-tag">
                            <%= (liveAuctions != null ? liveAuctions.size() : 0) %> phiên đang lên sàn
                        </span>
                    </div>
                    <div class="catalogue-actions-wrap">
                        <% if (!isSearching) { %>
                            <a href="<%= ctx %>/catalogue?search=1" class="btn-toggle-search-bar" title="Mở bộ lọc & tìm kiếm chi tiết">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8"></circle>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                </svg>
                                <span>Bộ lọc & Tìm kiếm</span>
                            </a>
                        <% } else { %>
                            <a href="<%= ctx %>/catalogue" class="btn-clear-category" title="Bỏ lọc danh mục">
                                ✕ Bỏ lọc
                            </a>
                        <% } %>
                    </div>
                </div>
                <% if (liveAuctions == null || liveAuctions.isEmpty()) { %>
                    <% if (!"upcoming".equalsIgnoreCase(selectedStatus) && !"ended".equalsIgnoreCase(selectedStatus)) { %>
                        <div class="empty-state-card">
                            <div class="empty-state-icon">🏛️</div>
                            <h3 class="empty-state-title">Hiện tại không có phiên đấu giá nào đang trực tiếp</h3>
                            <p class="empty-state-desc">Vui lòng xem các phiên sắp diễn ra hoặc điều chỉnh tiêu chí lọc.</p>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="catalogue-grid" id="live-auctions-grid">
                        <% for (Auction a : liveAuctions) { 
                            long itemId = a.getItemId();
                            long imgNum = ((itemId - 1) % 5) + 1;
                            String fallbackImg = ctx + "/assets/images/item_" + imgNum + ".jpg";
                        %>
                        <div class="card auction-card">
                            <div class="auction-card-img-wrapper">
                                <img src="<%= (a.getPrimaryImageUrl() != null && !a.getPrimaryImageUrl().trim().isEmpty()) ? (ctx + (a.getPrimaryImageUrl().startsWith("/") ? "" : "/") + a.getPrimaryImageUrl() + "?v=ai") : fallbackImg %>" 
                                     alt="<%= a.getItemName() %>" 
                                     class="auction-card-img"
                                     onerror="this.onerror=null; this.src='<%= fallbackImg %>';">
                                <span class="badge badge-live auction-card-badge">
                                    <span class="badge-pulse"></span> TRỰC TIẾP
                                </span>
                                <span class="auction-card-category"><%= a.getCategoryName() %></span>
                            </div>
                            <div class="auction-card-body">
                                <div class="item-code"><%= a.getItemCode() %> • <%= a.getItemMaterial() %></div>
                                <h3 class="auction-card-title"><%= a.getItemName() %></h3>

                                <div class="auction-card-timer">
                                    <span>⏱️ Còn lại:</span>
                                    <strong class="auction-card-timer-time" data-countdown-end="<%= a.getEndTime() != null ? a.getEndTime().getTime() : 0 %>"><%= FormatUtil.formatRemainingTime(a.getEndTime()) %></strong>
                                </div>

                                <div class="auction-card-price-box">
                                    <div class="price-label">Giá trả cao nhất hiện tại:</div>
                                    <div class="price-value"><%= FormatUtil.formatVND(a.getCurrentHighestBid()) %></div>
                                    <div class="price-meta">
                                        <%= a.getTotalBids() %> lượt trả giá • Bước giá: <%= FormatUtil.formatVND(a.getMinBidIncrement()) %>
                                    </div>
                                </div>

                                <div class="card-actions-row">
                                    <a href="<%= ctx %>/auction-room?id=<%= a.getAuctionId() %>" class="btn btn-gold flex-1">
                                        ⚡ Vào Đấu Giá
                                    </a>
                                    <% boolean isLiveWatched = (watchedAuctionIds != null && watchedAuctionIds.contains(a.getAuctionId())); %>
                                    <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= a.getAuctionId() %>&redirect=/catalogue" 
                                       class="btn <%= isLiveWatched ? "btn-outline-gold active" : "btn-dark" %> btn-watchlist-toggle" 
                                       title="<%= isLiveWatched ? "Bỏ theo dõi phiên này" : "Theo dõi phiên này" %>">
                                        <%= isLiveWatched ? "★ Đã theo dõi" : "⭐ Theo dõi" %>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- THANH ĐIỀU HƯỚNG PHÂN TRANG (ĐANG DIỄN RA: Tối đa 2 hàng = 6 hoặc 8 thẻ) -->
                <div class="catalogue-pagination-bar" data-target="live-auctions-grid" data-per-page="<%= perPageVal %>">
                    <button type="button" class="pagi-btn-view-all">Xem Tất Cả</button>
                    <div class="pagi-divider-line"></div>
                    <div class="pagi-dots-wrap"></div>
                    <div class="pagi-divider-line"></div>
                    <div class="pagi-nav-arrows">
                        <button type="button" class="pagi-arrow-btn pagi-btn-prev" aria-label="Trang trước">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="19" y1="12" x2="5" y2="12"></line>
                                <polyline points="12 19 5 12 12 5"></polyline>
                            </svg>
                        </button>
                        <button type="button" class="pagi-arrow-btn pagi-btn-next" aria-label="Trang sau">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                <polyline points="12 5 19 12 12 19"></polyline>
                            </svg>
                        </button>
                    </div>
                </div>
            <% } %>

        <!-- 2. PHIÊN ĐẤU GIÁ SẮP DIỄN RA -->
        <div class="catalogue-section-bar" id="upcoming-auctions" style="margin-top: 54px;">
            <div class="catalogue-section-title-wrap">
                <span class="section-dot-upcoming"></span>
                <h2 class="catalogue-section-title">Phiên Đấu Giá Sắp Diễn Ra</h2>
                <span class="catalogue-count-tag">
                    <%= (upcomingAuctions != null ? upcomingAuctions.size() : 0) %> phiên sắp diễn ra
                </span>
            </div>
        </div>

        <% if (upcomingAuctions == null || upcomingAuctions.isEmpty()) { %>
            <% if (!"live".equalsIgnoreCase(selectedStatus) && !"ended".equalsIgnoreCase(selectedStatus)) { %>
                <div class="empty-state-card">
                    <div class="empty-state-icon">⏳</div>
                    <h3 class="empty-state-title">Chưa có phiên đấu giá nào được lên lịch tiếp theo</h3>
                    <p class="empty-state-desc">Hãy quay lại sau hoặc điều chỉnh bộ lọc để xem các hiện vật khác.</p>
                </div>
            <% } %>
        <% } else { %>
                <div class="catalogue-grid" id="upcoming-auctions-grid">
                    <% for (Auction a : upcomingAuctions) { 
                        long itemId = a.getItemId();
                        long imgNum = ((itemId - 1) % 5) + 1;
                        String fallbackImg = ctx + "/assets/images/item_" + imgNum + ".jpg";
                    %>
                        <div class="card auction-card">
                            <div class="auction-card-img-wrapper">
                                <img src="<%= (a.getPrimaryImageUrl() != null && !a.getPrimaryImageUrl().trim().isEmpty()) ? (ctx + (a.getPrimaryImageUrl().startsWith("/") ? "" : "/") + a.getPrimaryImageUrl() + "?v=ai") : fallbackImg %>" 
                                     alt="<%= a.getItemName() %>" 
                                     class="auction-card-img"
                                     onerror="this.onerror=null; this.src='<%= fallbackImg %>';">
                                <span class="badge badge-upcoming auction-card-badge">SẮP DIỄN RA</span>
                                <span class="auction-card-category"><%= a.getCategoryName() %></span>
                            </div>
                            <div class="auction-card-body">
                                <div class="item-code"><%= a.getItemCode() %> • <%= a.getItemMaterial() %></div>
                                <h3 class="auction-card-title"><%= a.getItemName() %></h3>

                                <div class="auction-card-timer">
                                    <span>Bắt đầu lúc:</span>
                                    <strong><%= FormatUtil.formatDateTime(a.getStartTime()) %></strong>
                                </div>

                                <div class="auction-card-price-box">
                                    <div class="price-label">Giá khởi điểm:</div>
                                    <div class="price-value text-primary"><%= FormatUtil.formatVND(a.getStartingPrice()) %></div>
                                    <div class="price-meta">
                                        Bước giá tối thiểu: <%= FormatUtil.formatVND(a.getMinBidIncrement()) %>
                                    </div>
                                </div>

                                <div class="card-actions-row">
                                    <a href="<%= ctx %>/auction-room?id=<%= a.getAuctionId() %>" class="btn btn-outline-gold flex-1">
                                        Xem chi tiết
                                    </a>
                                    <% boolean isUpcomingWatched = (watchedAuctionIds != null && watchedAuctionIds.contains(a.getAuctionId())); %>
                                    <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= a.getAuctionId() %>&redirect=/catalogue" 
                                       class="btn <%= isUpcomingWatched ? "btn-outline-gold active" : "btn-dark" %> btn-watchlist-toggle" 
                                       title="<%= isUpcomingWatched ? "Bỏ theo dõi phiên này" : "Theo dõi phiên này" %>">
                                        <%= isUpcomingWatched ? "★ Đã theo dõi" : "⭐ Theo dõi" %>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- THANH ĐIỀU HƯỚNG PHÂN TRANG (SẮP DIỄN RA: Tối đa 2 hàng = 6 hoặc 8 thẻ) -->
                <div class="catalogue-pagination-bar" data-target="upcoming-auctions-grid" data-per-page="<%= perPageVal %>">
                    <button type="button" class="pagi-btn-view-all">Xem Tất Cả</button>
                    <div class="pagi-divider-line"></div>
                    <div class="pagi-dots-wrap"></div>
                    <div class="pagi-divider-line"></div>
                    <div class="pagi-nav-arrows">
                        <button type="button" class="pagi-arrow-btn pagi-btn-prev" aria-label="Trang trước">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="19" y1="12" x2="5" y2="12"></line>
                                <polyline points="12 19 5 12 12 5"></polyline>
                            </svg>
                        </button>
                        <button type="button" class="pagi-arrow-btn pagi-btn-next" aria-label="Trang sau">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                <polyline points="12 5 19 12 12 19"></polyline>
                            </svg>
                        </button>
                    </div>
                </div>
            <% } %>

        <!-- 3. PHIÊN ĐẤU GIÁ ĐÃ KẾT THÚC (Nếu có hoặc khi chọn lọc Đã kết thúc) -->
        <% if (endedAuctions != null && !endedAuctions.isEmpty()) { %>
            <div class="catalogue-section-bar" id="ended-auctions" style="margin-top: 54px;">
                <div class="catalogue-section-title-wrap">
                    <span class="section-dot-upcoming" style="background: #64748b; box-shadow: none;"></span>
                    <h2 class="catalogue-section-title">Phiên Đấu Giá Đã Kết Thúc</h2>
                    <span class="catalogue-count-tag"><%= endedAuctions.size() %> phiên</span>
                </div>
            </div>
            <div class="catalogue-grid" id="ended-auctions-grid">
                <% for (Auction a : endedAuctions) { 
                    long itemId = a.getItemId();
                    long imgNum = ((itemId - 1) % 5) + 1;
                    String fallbackImg = ctx + "/assets/images/item_" + imgNum + ".jpg";
                %>
                    <div class="card auction-card auction-card-closed">
                        <div class="auction-card-img-wrapper">
                            <img src="<%= (a.getPrimaryImageUrl() != null && !a.getPrimaryImageUrl().trim().isEmpty()) ? (ctx + (a.getPrimaryImageUrl().startsWith("/") ? "" : "/") + a.getPrimaryImageUrl() + "?v=ai") : fallbackImg %>" 
                                 alt="<%= a.getItemName() %>" 
                                 class="auction-card-img"
                                 onerror="this.onerror=null; this.src='<%= fallbackImg %>';">
                            <span class="badge badge-closed auction-card-badge">ĐÃ KẾT THÚC</span>
                            <span class="auction-card-category"><%= a.getCategoryName() %></span>
                        </div>
                        <div class="auction-card-body">
                            <div class="item-code"><%= a.getItemCode() %> • <%= a.getItemMaterial() %></div>
                            <h3 class="auction-card-title"><%= a.getItemName() %></h3>

                            <div class="auction-card-timer">
                                <span>Kết thúc lúc:</span>
                                <strong><%= FormatUtil.formatDateTime(a.getEndTime()) %></strong>
                            </div>

                            <div class="auction-card-price-box">
                                <div class="price-label">Giá gõ búa cuối cùng:</div>
                                <div class="price-value text-muted"><%= FormatUtil.formatVND(a.getCurrentHighestBid()) %></div>
                            </div>

                            <div class="card-actions-row">
                                <a href="<%= ctx %>/item-detail?id=<%= a.getItemId() %>" class="btn btn-dark btn-block">
                                    Xem lại hiện vật
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>

            <!-- THANH ĐIỀU HƯỚNG PHÂN TRANG (ĐÃ KẾT THÚC: Tối đa 2 hàng = 6 hoặc 8 thẻ) -->
            <div class="catalogue-pagination-bar" data-target="ended-auctions-grid" data-per-page="<%= perPageVal %>">
                <button type="button" class="pagi-btn-view-all">Xem Tất Cả</button>
                <div class="pagi-divider-line"></div>
                <div class="pagi-dots-wrap"></div>
                <div class="pagi-divider-line"></div>
                <div class="pagi-nav-arrows">
                    <button type="button" class="pagi-arrow-btn pagi-btn-prev" aria-label="Trang trước">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="19" y1="12" x2="5" y2="12"></line>
                            <polyline points="12 19 5 12 12 5"></polyline>
                        </svg>
                    </button>
                    <button type="button" class="pagi-arrow-btn pagi-btn-next" aria-label="Trang sau">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                    </button>
                </div>
            </div>
        <% } %>



        <script>
        document.addEventListener('DOMContentLoaded', function() {
            function setupSectionPagination(bar) {
                var targetId = bar.getAttribute('data-target');
                var perPage = parseInt(bar.getAttribute('data-per-page') || '6', 10);
                var grid = document.getElementById(targetId);
                if (!grid) return;
                
                var cards = Array.from(grid.querySelectorAll('.auction-card'));
                var totalCards = cards.length;
                if (totalCards === 0) {
                    bar.style.display = 'none';
                    return;
                }
                
                var totalPages = Math.ceil(totalCards / perPage);
                var currentPage = 1;
                var isShowingAll = false;
                
                var btnViewAll = bar.querySelector('.pagi-btn-view-all');
                var dotsWrap = bar.querySelector('.pagi-dots-wrap');
                var btnPrev = bar.querySelector('.pagi-btn-prev');
                var btnNext = bar.querySelector('.pagi-btn-next');
                
                function scrollToSectionTop() {
                    var sectionBar = document.getElementById(targetId.replace('-grid', '')) || grid.previousElementSibling || grid;
                    if (sectionBar) {
                        var headerOffset = 85;
                        var elementPosition = sectionBar.getBoundingClientRect().top;
                        var offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                        window.scrollTo({
                            top: Math.max(0, offsetPosition),
                            behavior: 'smooth'
                        });
                    }
                }

                // Khởi tạo các chấm chỉ báo
                dotsWrap.innerHTML = '';
                var numDots = Math.max(1, totalPages);
                for (var i = 1; i <= numDots; i++) {
                    var dot = document.createElement('span');
                    dot.className = 'pagi-dot' + (i === 1 ? ' active' : '');
                    dot.setAttribute('data-page', i);
                    dot.title = 'Trang ' + i;
                    (function(pageIdx) {
                        dot.addEventListener('click', function() {
                            if (isShowingAll) {
                                isShowingAll = false;
                                if (btnViewAll) btnViewAll.textContent = 'Xem Tất Cả';
                            }
                            goToPage(pageIdx, true);
                        });
                    })(i);
                    dotsWrap.appendChild(dot);
                }
                
                function goToPage(page, shouldScroll) {
                    currentPage = page;
                    var start = (page - 1) * perPage;
                    var end = start + perPage;
                    
                    cards.forEach(function(card, index) {
                        if (index >= start && index < end) {
                            card.style.display = '';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                    
                    var dots = dotsWrap.querySelectorAll('.pagi-dot');
                    dots.forEach(function(dot, idx) {
                        if (idx + 1 === page) {
                            dot.classList.add('active');
                        } else {
                            dot.classList.remove('active');
                        }
                    });
                    
                    if (btnPrev) {
                        if (page <= 1) btnPrev.classList.add('disabled');
                        else btnPrev.classList.remove('disabled');
                    }
                    if (btnNext) {
                        if (page >= totalPages) btnNext.classList.add('disabled');
                        else btnNext.classList.remove('disabled');
                    }

                    if (shouldScroll) {
                        scrollToSectionTop();
                    }
                }
                
                if (btnPrev) {
                    btnPrev.addEventListener('click', function(e) {
                        e.preventDefault();
                        if (currentPage > 1) {
                            if (isShowingAll) {
                                isShowingAll = false;
                                if (btnViewAll) btnViewAll.textContent = 'Xem Tất Cả';
                            }
                            goToPage(currentPage - 1, true);
                        }
                    });
                }
                
                if (btnNext) {
                    btnNext.addEventListener('click', function(e) {
                        e.preventDefault();
                        if (currentPage < totalPages) {
                            if (isShowingAll) {
                                isShowingAll = false;
                                if (btnViewAll) btnViewAll.textContent = 'Xem Tất Cả';
                            }
                            goToPage(currentPage + 1, true);
                        }
                    });
                }
                
                if (btnViewAll) {
                    btnViewAll.addEventListener('click', function(e) {
                        e.preventDefault();
                        if (!isShowingAll) {
                            isShowingAll = true;
                            cards.forEach(function(card) {
                                card.style.display = '';
                            });
                            btnViewAll.textContent = 'Thu Gọn';
                            if (btnPrev) btnPrev.classList.add('disabled');
                            if (btnNext) btnNext.classList.add('disabled');
                        } else {
                            isShowingAll = false;
                            btnViewAll.textContent = 'Xem Tất Cả';
                            goToPage(currentPage, true);
                        }
                    });
                }
                
                // Mặc định ban đầu chỉ hiển thị 2 hàng (không cuộn trang khi khởi tạo)
                goToPage(1, false);
            }
            
            document.querySelectorAll('.catalogue-pagination-bar').forEach(setupSectionPagination);
        });
        </script>

            </div> <!-- Kết thúc .catalogue-content -->
        </div> <!-- Kết thúc .catalogue-layout -->
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
