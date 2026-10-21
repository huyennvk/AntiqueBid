<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Watchlist" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    List<Watchlist> watchlists = (List<Watchlist>) request.getAttribute("watchlists");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Đấu giá của tôi | Cổ Vật Đường" />
    <jsp:param name="extraCss" value="watchlist.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-header">
            <h1 class="user-page-title">⭐ Danh Sách Theo Dõi & Đấu Giá Của Tôi</h1>
            <p class="user-page-subtitle">Theo dõi cập nhật giá theo thời gian thực của các phiên bạn quan tâm</p>
        </div>

        <% if (watchlists == null || watchlists.isEmpty()) { %>
            <div class="user-card user-empty-state">
                <div class="user-empty-icon">☆</div>
                <h3 class="user-empty-title">Bạn chưa theo dõi phiên đấu giá nào</h3>
                <p class="user-empty-desc">Hãy khám phá các cổ vật trên sàn và nhấn "Theo dõi" để không bỏ lỡ.</p>
                <a href="<%= ctx %>/catalogue" class="btn btn-gold">
                    Xem Danh Mục Cổ Vật
                </a>
            </div>
        <% } else { %>
            <div class="user-card">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Cổ vật</th>
                                <th>Chất liệu</th>
                                <th>Giá cao nhất hiện tại</th>
                                <th>Thời gian còn lại</th>
                                <th>Trạng thái</th>
                                <th class="text-right">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Watchlist w : watchlists) { %>
                                <tr>
                                    <td>
                                        <div class="user-item-cell">
                                            <img src="<%= ctx %>/<%= w.getPrimaryImageUrl() %>" alt="<%= w.getItemName() %>" class="user-thumb">
                                            <div>
                                                <div class="item-code"><%= w.getItemCode() %></div>
                                                <a href="<%= ctx %>/auction-room?id=<%= w.getAuctionId() %>" class="user-item-title">
                                                    <%= w.getItemName() %>
                                                </a>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= w.getItemMaterial() %></td>
                                    <td class="price-value text-base">
                                        <%= FormatUtil.formatVND(w.getCurrentHighestBid()) %>
                                    </td>
                                    <td class="text-danger-semibold" data-countdown-end="<%= w.getEndTime() != null ? w.getEndTime().getTime() : 0 %>">
                                        <%= FormatUtil.formatRemainingTime(w.getEndTime()) %>
                                    </td>
                                    <td>
                                        <% if ("ACTIVE".equalsIgnoreCase(w.getAuctionStatus())) { %>
                                            <span class="badge badge-live"><span class="badge-pulse"></span> TRỰC TIẾP</span>
                                        <% } else if ("SCHEDULED".equalsIgnoreCase(w.getAuctionStatus())) { %>
                                            <span class="badge badge-upcoming">SẮP DIỄN RA</span>
                                        <% } else { %>
                                            <span class="badge badge-closed">ĐÃ KẾT THÚC</span>
                                        <% } %>
                                    </td>
                                    <td class="text-right">
                                        <div class="table-action-group">
                                            <a href="<%= ctx %>/auction-room?id=<%= w.getAuctionId() %>" class="btn btn-sm btn-gold">
                                                Vào phòng
                                            </a>
                                            <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= w.getAuctionId() %>&redirect=/watchlist" class="btn btn-sm btn-outline-gold" title="Bỏ theo dõi">
                                                ✕
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
