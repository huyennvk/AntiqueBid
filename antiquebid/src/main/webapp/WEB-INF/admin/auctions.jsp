<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "auctions");
    List<Auction> auctions = (List<Auction>) request.getAttribute("auctions");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý phiên đấu giá | Admin" />
    <jsp:param name="extraCss" value="admin_auctions.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-page-header">
                <div>
                    <h1 class="admin-header-title">⚡ Quản Lý Phiên Đấu Giá</h1>
                    <p class="admin-header-desc">Khởi tạo, cấu hình quy tắc bước giá và điều hành các phiên đấu giá trực tuyến</p>
                </div>
                <div>
                    <a href="<%= ctx %>/admin/auction-form" class="btn btn-gold">+ Tạo Phiên Đấu Giá Mới</a>
                </div>
            </div>

            <% if ("auction_created".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã tạo và lên lịch mở phiên đấu giá thành công!</div>
            <% } else if ("auction_cancelled".equals(msg)) { %>
                <div class="alert alert-info">✓ Đã hủy phiên đấu giá và hoàn trả cổ vật về trạng thái sẵn sàng.</div>
            <% } %>

            <!-- Filter Status Bar -->
            <div class="admin-filter-pills">
                <a href="<%= ctx %>/admin/auctions" class="filter-pill <%= statusFilter == null ? "active" : "" %>">Tất cả</a>
                <a href="<%= ctx %>/admin/auctions?status=ACTIVE" class="filter-pill <%= "ACTIVE".equals(statusFilter) ? "active" : "" %>">Đang trực tiếp</a>
                <a href="<%= ctx %>/admin/auctions?status=SCHEDULED" class="filter-pill <%= "SCHEDULED".equals(statusFilter) ? "active" : "" %>">Sắp diễn ra</a>
                <a href="<%= ctx %>/admin/auctions?status=CLOSED" class="filter-pill <%= "CLOSED".equals(statusFilter) ? "active" : "" %>">Đã kết thúc</a>
                <a href="<%= ctx %>/admin/auctions?status=CANCELLED" class="filter-pill <%= "CANCELLED".equals(statusFilter) ? "active" : "" %>">Đã hủy</a>
            </div>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã phiên</th>
                                <th>Hiện vật lên sàn</th>
                                <th>Thời gian phiên</th>
                                <th>Giá khởi điểm</th>
                                <th>Giá sàn (Reserve)</th>
                                <th>Giá cao nhất</th>
                                <th>Trạng thái</th>
                                <th class="text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (auctions != null && !auctions.isEmpty()) { 
                                for (Auction a : auctions) { %>
                                <tr>
                                    <td><strong>#AUC-<%= a.getAuctionId() %></strong></td>
                                    <td>
                                        <div class="d-flex align-center gap-2">
                                            <img src="<%= ctx %>/<%= a.getPrimaryImageUrl() %>" alt="" class="admin-table-thumb">
                                            <div>
                                                <div class="item-code text-xs"><%= a.getItemCode() %></div>
                                                <strong class="text-primary"><%= a.getItemName() %></strong>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-xs color-muted">
                                        Từ: <%= FormatUtil.formatDateTime(a.getStartTime()) %><br>
                                        Đến: <%= FormatUtil.formatDateTime(a.getEndTime()) %>
                                    </td>
                                    <td><%= FormatUtil.formatVND(a.getStartingPrice()) %></td>
                                    <td class="text-sm color-muted">
                                        <%= a.getReservePrice() != null ? FormatUtil.formatVND(a.getReservePrice()) : "Không đặt" %>
                                    </td>
                                    <td class="price-value text-base color-danger">
                                        <%= FormatUtil.formatVND(a.getCurrentHighestBid()) %>
                                    </td>
                                    <td>
                                        <span class="badge <%= a.getStatusBadgeClass() %>">
                                            <%= a.getStatusDisplay() %>
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <div class="table-action-group">
                                            <a href="<%= ctx %>/auction-room?id=<%= a.getAuctionId() %>" class="btn btn-sm btn-gold" target="_blank" title="Xem phòng đấu giá">
                                                Phòng
                                            </a>
                                            <% if ("DRAFT".equalsIgnoreCase(a.getStatus()) || "SCHEDULED".equalsIgnoreCase(a.getStatus())) { %>
                                                <a href="<%= ctx %>/admin/auction-form?id=<%= a.getAuctionId() %>" class="btn btn-sm btn-outline-gold" title="Sửa thông tin phiên">
                                                    Sửa
                                                </a>
                                            <% } %>
                                            <% if (!"CLOSED".equalsIgnoreCase(a.getStatus()) && !"CANCELLED".equalsIgnoreCase(a.getStatus())) { %>
                                                <form action="<%= ctx %>/admin/auction-cancel" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn hủy phiên đấu giá này?');" class="d-inline">
                                                    <input type="hidden" name="auctionId" value="<%= a.getAuctionId() %>">
                                                    <input type="hidden" name="reason" value="Hủy bởi ban quản trị">
                                                    <button type="submit" class="btn btn-sm btn-danger" title="Hủy phiên">Hủy</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="8" class="admin-empty-cell">
                                        Không tìm thấy phiên đấu giá nào.
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
