<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.User" %>
<%
    String ctx = request.getContextPath();
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

    // Lấy tiêu đề trang từ parameter hoặc request attribute
    String pageTitle = request.getParameter("pageTitle");
    if (pageTitle == null || pageTitle.trim().isEmpty()) {
        pageTitle = (String) request.getAttribute("pageTitle");
    }
    if (pageTitle == null || pageTitle.trim().isEmpty()) {
        pageTitle = "AntiqueBid | Sàn Đấu Giá Cổ Vật Hoàng Gia";
    }

    // Lấy tên file CSS bổ sung theo từng trang (nếu có)
    String extraCss = request.getParameter("extraCss");
    if (extraCss == null || extraCss.trim().isEmpty()) {
        extraCss = (String) request.getAttribute("extraCss");
    }

    // Lớp CSS cho body (nếu có, ví dụ mockpay-wrapper)
    String bodyClass = request.getParameter("bodyClass");
    if (bodyClass == null || bodyClass.trim().isEmpty()) {
        bodyClass = (String) request.getAttribute("bodyClass");
    }
    if (bodyClass == null) {
        bodyClass = "";
    }

    // Ẩn thanh điều hướng (ví dụ màn hình thanh toán MockPay sandbox độc lập)
    String hideNav = request.getParameter("hideNav");
    if (hideNav == null || hideNav.trim().isEmpty()) {
        hideNav = (String) request.getAttribute("hideNav");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <link rel="icon" type="image/svg+xml" href="<%= ctx %>/assets/images/logo.svg">

    <!-- Phông chữ Google Fonts Lora & Plus Jakarta Sans chuẩn dấu tiếng Việt -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,500;0,600;0,700;1,500&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- CSS Hệ thống chung (Base: Biến màu, Reset, Typography, Buttons, Badges, Utilities) -->
    <link rel="stylesheet" href="<%= ctx %>/assets/css/style.css?v=20">
    <link rel="stylesheet" href="<%= ctx %>/assets/css/header.css?v=20">
    <link rel="stylesheet" href="<%= ctx %>/assets/css/footer.css?v=20">

    <!-- CSS Module chuyên biệt cho từng trang -->
    <% if (extraCss != null && !extraCss.trim().isEmpty()) { %>
        <link rel="stylesheet" href="<%= ctx %>/assets/css/<%= extraCss %>?v=20">
    <% } %>
    <!-- Khởi tạo mốc thời gian máy chủ để đồng bộ đồng hồ toàn sàn -->
    <script>
        window.__SERVER_TIME__ = <%= System.currentTimeMillis() %>;
        window.__CLIENT_LOAD_TIME__ = Date.now();
    </script>
</head>
<body <%= !bodyClass.isEmpty() ? "class=\"" + bodyClass + "\"" : "" %>>
    <% if (!"true".equalsIgnoreCase(hideNav)) { 
        String reqUri = request.getRequestURI();
        boolean isCatActive = reqUri != null && (reqUri.contains("/catalogue") || reqUri.endsWith("/") || reqUri.contains("/item-detail") || reqUri.contains("/auction-room"));
    %>
    <header>
        <!-- Navbar: Logo, Menu Điều Hướng Dropdown, Quốc Kỳ, Đồng Hồ 2 Dòng (Giờ + Ngày Tháng), Nút Tìm Kiếm & Đăng Nhập/Tài Khoản -->
        <nav class="navbar">
            <div class="container nav-content">
                <!-- 1. THƯƠNG HIỆU & LOGO SEAL -->
                <a href="<%= ctx %>/catalogue" class="nav-brand">
                    <img src="<%= ctx %>/assets/images/logo.svg" alt="AntiqueBid" class="brand-logo-img">
                    <div class="brand-text-wrap">
                        <div class="brand-title">AntiqueBid</div>
                        <div class="brand-subtitle">ANTIQUE AUCTION HOUSE</div>
                    </div>
                </a>

                <!-- 2. THANH TÌM KIẾM DÀI BÊN TRÁI (Thay thế vòng tròn tìm kiếm cũ) -->
                <div class="nav-search-bar-wrap">
                    <form action="<%= ctx %>/catalogue" method="GET" class="nav-search-bar-form">
                        <input type="text" name="keyword" 
                               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>" 
                               class="nav-search-bar-input" 
                               placeholder="Tìm kiếm cổ vật, triều đại, chất liệu...">
                        <button type="submit" class="nav-search-bar-btn" title="Tìm kiếm" aria-label="Tìm kiếm">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                        </button>
                    </form>
                </div>

                <%
                    java.text.SimpleDateFormat sdfClock = new java.text.SimpleDateFormat("HH:mm:ss");
                    sdfClock.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
                    String currentServerClockStr = sdfClock.format(new java.util.Date());

                    java.util.Calendar cal = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
                    String[] dayNames = {"Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"};
                    int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);
                    String dayName = dayNames[dayOfWeek - 1];
                    java.text.SimpleDateFormat sdfDate = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    sdfDate.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
                    String currentServerDateStr = dayName + ", " + sdfDate.format(cal.getTime());
                %>
                <!-- 3. KHU VỰC TIỆN ÍCH BÊN PHẢI (HAI MỤC GỌN VỀ CẠNH GIỜ, ĐỒNG HỒ, USER/AUTH) -->
                <div class="nav-right-actions">
                    <!-- HAI MỤC ĐIỀU HƯỚNG BÊN TRÁI ĐƯỢC GỌN VỀ CẠNH GIỜ -->
                    <ul class="nav-links">
                        <!-- Dropdown: Tài sản đấu giá -->
                        <li class="nav-item-dropdown" id="navItemAssets">
                            <a href="<%= ctx %>/catalogue" class="nav-link-item nav-link-dropdown <%= isCatActive ? "active" : "" %>">
                                <span>Tài sản đấu giá</span>
                                <svg class="nav-chevron" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="6 9 12 15 18 9"></polyline>
                                </svg>
                            </a>
                            <div class="nav-menu-sub">
                                <a href="<%= ctx %>/catalogue?category=1" class="dropdown-item">
                                    <span class="dropdown-item-icon">🏺</span>
                                    <span>Gốm sứ cổ</span>
                                </a>
                                <a href="<%= ctx %>/catalogue?category=2" class="dropdown-item">
                                    <span class="dropdown-item-icon">🪔</span>
                                    <span>Đồ đồng & Tượng cổ</span>
                                </a>
                                <a href="<%= ctx %>/catalogue?category=3" class="dropdown-item">
                                    <span class="dropdown-item-icon">🪵</span>
                                    <span>Đồ gỗ mỹ nghệ</span>
                                </a>
                                <a href="<%= ctx %>/catalogue?category=4" class="dropdown-item">
                                    <span class="dropdown-item-icon">📜</span>
                                    <span>Tranh cổ & Thư pháp</span>
                                </a>
                                <a href="<%= ctx %>/catalogue?category=5" class="dropdown-item">
                                    <span class="dropdown-item-icon">📿</span>
                                    <span>Ngọc bích & Trang sức cổ</span>
                                </a>
                                <div class="dropdown-divider"></div>
                                <a href="<%= ctx %>/catalogue" class="dropdown-item font-bold text-gold">
                                    <span class="dropdown-item-icon">🏛️</span>
                                    <span>Tất cả tài sản đấu giá</span>
                                </a>
                            </div>
                        </li>

                        <!-- Dropdown: Phiên đấu giá -->
                        <li class="nav-item-dropdown" id="navItemAuctions">
                            <a href="<%= ctx %>/catalogue#live-auctions" class="nav-link-item nav-link-dropdown">
                                <span>Phiên đấu giá</span>
                                <svg class="nav-chevron" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="6 9 12 15 18 9"></polyline>
                                </svg>
                            </a>
                            <div class="nav-menu-sub">
                                <a href="<%= ctx %>/catalogue#upcoming-auctions" class="dropdown-item">
                                    <span class="dropdown-item-icon">⏳</span>
                                    <span>Phiên đấu giá sắp đấu giá</span>
                                </a>
                                <a href="<%= ctx %>/catalogue#live-auctions" class="dropdown-item">
                                    <span class="dropdown-item-icon"><span class="nav-live-dot"></span></span>
                                    <span>Phiên đấu giá đang diễn ra</span>
                                </a>
                                <a href="<%= ctx %>/catalogue#ended-auctions" class="dropdown-item">
                                    <span class="dropdown-item-icon">🏁</span>
                                    <span>Phiên đấu giá đã kết thúc</span>
                                </a>
                            </div>
                        </li>

                        <% if (currentUser != null && !currentUser.isAdmin()) { %>
                            <li><a href="<%= ctx %>/watchlist" class="nav-link-item">Đấu giá của tôi</a></li>
                            <li><a href="<%= ctx %>/orders" class="nav-link-item">Đơn hàng</a></li>
                        <% } %>
                        <% if (currentUser != null && currentUser.isAdmin()) { %>
                            <li><a href="<%= ctx %>/admin/dashboard" class="nav-link-item text-gold font-bold">⚙️ Quản trị</a></li>
                        <% } %>
                    </ul>

                    <!-- Đồng Hồ Sàn Đấu Giá (2 dòng: Giờ:Phút:Giây & Thứ, Ngày Tháng Năm) -->
                    <div class="nav-clock" id="system-clock-widget" title="Đồng hồ chuẩn máy chủ sàn AntiqueBid (UTC+7)">
                        <div class="nav-clock-time" id="system-live-clock"><%= currentServerClockStr %></div>
                        <div class="nav-clock-date" id="system-live-date"><%= currentServerDateStr %></div>
                    </div>

                    <!-- Khu vực Người Dùng / Đăng Nhập -->
                    <div class="nav-user">
                        <% if (currentUser != null) { %>
                            <div class="nav-user-dropdown" id="userMenuDropdown">
                                <button type="button" class="nav-user-trigger" id="userMenuTrigger" aria-haspopup="true" aria-expanded="false" onclick="toggleUserDropdown(event)">
                                    <span class="nav-user-greeting">Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                                    <% if (currentUser.isAdmin()) { %>
                                        <span class="badge badge-warning">Admin</span>
                                    <% } else { %>
                                        <% if ("VERIFIED".equalsIgnoreCase(currentUser.getKycStatus())) { %>
                                            <span class="badge badge-verified">✓ CCCD</span>
                                        <% } else if ("PENDING".equalsIgnoreCase(currentUser.getKycStatus())) { %>
                                            <span class="badge badge-pending">⏳ Chờ CCCD</span>
                                        <% } else { %>
                                            <span class="badge badge-warning">⚠️ Nộp CCCD</span>
                                        <% } %>
                                    <% } %>
                                    <svg class="dropdown-chevron" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                        <polyline points="6 9 12 15 18 9"></polyline>
                                    </svg>
                                </button>

                                <div class="nav-dropdown-menu" id="userDropdownMenu">
                                    <div class="dropdown-user-header">
                                        <div class="dropdown-user-name"><%= currentUser.getFullName() %></div>
                                        <div class="dropdown-user-email"><%= currentUser.getEmail() %></div>
                                    </div>
                                    <div class="dropdown-divider"></div>
                                    <a href="<%= ctx %>/account" class="dropdown-item">
                                        <span class="dropdown-item-icon">👤</span>
                                        <span>Hồ sơ & Tài khoản</span>
                                    </a>
                                    <% if (!currentUser.isAdmin()) { %>
                                        <a href="<%= ctx %>/watchlist" class="dropdown-item">
                                            <span class="dropdown-item-icon">⭐</span>
                                            <span>Đấu giá của tôi</span>
                                        </a>
                                        <a href="<%= ctx %>/orders" class="dropdown-item">
                                            <span class="dropdown-item-icon">📦</span>
                                            <span>Đơn hàng của tôi</span>
                                        </a>
                                        <% if (!"VERIFIED".equalsIgnoreCase(currentUser.getKycStatus())) { %>
                                            <a href="<%= ctx %>/kyc" class="dropdown-item color-warning">
                                                <span class="dropdown-item-icon">🪪</span>
                                                <span>Xác minh CCCD gắn chip</span>
                                            </a>
                                        <% } %>
                                    <% } %>
                                    <% if (currentUser.isAdmin()) { %>
                                        <a href="<%= ctx %>/admin/dashboard" class="dropdown-item dropdown-item-admin">
                                            <span class="dropdown-item-icon">⚙️</span>
                                            <span>Bảng Quản Trị Hệ Thống</span>
                                        </a>
                                    <% } %>
                                    <div class="dropdown-divider"></div>
                                    <a href="<%= ctx %>/logout" class="dropdown-item dropdown-item-logout">
                                        <span class="dropdown-item-icon">🚪</span>
                                        <span>Đăng xuất</span>
                                    </a>
                                </div>
                            </div>
                        <% } else { %>
                            <a href="<%= ctx %>/login" class="btn btn-gold btn-header-login">Đăng Nhập</a>
                            <a href="<%= ctx %>/register" class="btn btn-outline-gold btn-header-reg">Đăng ký</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </nav>
    </header>
    <% } %>
