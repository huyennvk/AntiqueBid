<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    request.setAttribute("activePage", "dashboard");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Auction> liveAuctions = (List<Auction>) request.getAttribute("liveAuctions");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Bảng điều khiển quản trị | Cổ Vật Đường" />
    <jsp:param name="extraCss" value="admin_dashboard.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <!-- Header Bảng Điều Khiển -->
            <div class="admin-header">
                <div>
                    <h1 class="admin-header-title">📊 Báo Cáo & Thống Kê Toàn Sàn</h1>
                    <p class="admin-header-desc">Tổng quan số liệu giao dịch, người dùng và doanh thu sàn đấu giá</p>
                </div>
                <div class="admin-toolbar">
                    <a href="<%= ctx %>/admin/item-form" class="btn btn-sm btn-outline-gold">+ Thêm Cổ Vật</a>
                    <a href="<%= ctx %>/admin/auction-form" class="btn btn-sm btn-gold">+ Mở Phiên Đấu Giá</a>
                </div>
            </div>

            <!-- Lưới Thẻ Thống Kê KPI -->
            <div class="grid-4 mb-4">
                <div class="stat-card stat-card-gold">
                    <div class="stat-title">Doanh Thu Đã Thu</div>
                    <div class="stat-value text-danger">
                        <%= FormatUtil.formatVND((BigDecimal) stats.get("totalRevenue")) %>
                    </div>
                    <div class="stat-desc text-success">✓ Qua cổng bảo lãnh MockPay</div>
                </div>

                <div class="stat-card stat-card-red">
                    <div class="stat-title">Phiên Đang Trực Tiếp</div>
                    <div class="stat-value text-danger">
                        <%= stats.get("activeAuctions") != null ? stats.get("activeAuctions") : 0 %>
                    </div>
                    <div class="stat-desc">Khách đang đặt giá realtime</div>
                </div>

                <div class="stat-card stat-card-blue">
                    <div class="stat-title">Kho Cổ Vật Độc Bản</div>
                    <div class="stat-value">
                        <%= stats.get("totalItems") != null ? stats.get("totalItems") : 0 %>
                    </div>
                    <div class="stat-desc">Hiện vật đã đăng ký sàn</div>
                </div>

                <div class="stat-card stat-card-green">
                    <div class="stat-title">Khách Đấu Giá KYC</div>
                    <div class="stat-value text-success">
                        <%= stats.get("verifiedBidders") != null ? stats.get("verifiedBidders") : 0 %> / <%= stats.get("totalBidders") != null ? stats.get("totalBidders") : 0 %>
                    </div>
                    <div class="stat-desc <%= ((Integer)stats.get("pendingKyc")) > 0 ? "text-danger" : "" %>">
                        <%= stats.get("pendingKyc") %> hồ sơ đang chờ duyệt
                    </div>
                </div>
            </div>

            <!-- Băng Cảnh Báo Hành Động Cần Xử Lý Ngay -->
            <div class="grid-2 mb-4">
                <div class="alert-card alert-card-warning">
                    <div class="alert-card-inner">
                        <div>
                            <div class="alert-card-title-warning">⚠️ Đơn hàng chờ thanh toán: <%= stats.get("pendingOrders") %></div>
                            <div class="alert-card-meta">Các đơn hàng đang trong thời hạn 48 giờ thanh toán</div>
                        </div>
                        <a href="<%= ctx %>/admin/orders?status=PENDING_PAYMENT" class="btn btn-sm btn-dark">Xem đơn</a>
                    </div>
                </div>

                <div class="alert-card alert-card-danger">
                    <div class="alert-card-inner">
                        <div>
                            <div class="alert-card-title-danger">⚖️ Khiếu nại mở cần xử lý: <%= stats.get("openDisputes") %></div>
                            <div class="alert-card-meta">Yêu cầu đối soát và hoàn tiền từ người mua</div>
                        </div>
                        <a href="<%= ctx %>/admin/disputes?status=OPEN" class="btn btn-sm btn-danger">Xử lý ngay</a>
                    </div>
                </div>
            </div>

            <!-- Bảng Giám Sát Phiên Đang Mở Realtime -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <h3 class="admin-table-title">🔴 Giám Sát Phiên Đang Mở Realtime</h3>
                </div>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Cổ vật</th>
                                <th>Giá khởi điểm</th>
                                <th>Giá cao nhất hiện tại</th>
                                <th>Người dẫn đầu</th>
                                <th>Thời gian còn</th>
                                <th class="text-right">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (liveAuctions != null && !liveAuctions.isEmpty()) { 
                                for (Auction a : liveAuctions) { %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-center gap-2">
                                            <img src="<%= ctx %>/<%= a.getPrimaryImageUrl() %>" alt="" class="avatar-sm">
                                            <div>
                                                <strong><%= a.getItemName() %></strong>
                                                <div class="item-code text-xs"><%= a.getItemCode() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= FormatUtil.formatVND(a.getStartingPrice()) %></td>
                                    <td class="price-value text-sm text-danger">
                                        <%= FormatUtil.formatVND(a.getCurrentHighestBid()) %>
                                    </td>
                                    <td><strong><%= a.getHighestBidderName() %></strong></td>
                                    <td class="text-danger font-bold" data-countdown-end="<%= a.getEndTime() != null ? a.getEndTime().getTime() : 0 %>"><%= FormatUtil.formatRemainingTime(a.getEndTime()) %></td>
                                    <td class="text-right">
                                        <a href="<%= ctx %>/auction-room?id=<%= a.getAuctionId() %>" class="btn btn-sm btn-gold" target="_blank">
                                            Vào phòng
                                        </a>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted p-4">
                                        Không có phiên đấu giá nào đang trực tiếp lúc này.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

<jsp:include page="/WEB-INF/footer.jsp" />
