<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Đơn hàng trúng đấu giá của tôi | Cổ Vật Đường" />
    <jsp:param name="extraCss" value="orders.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-header">
            <h1 class="user-page-title">📦 Đơn Hàng Trúng Đấu Giá Của Tôi</h1>
            <p class="user-page-subtitle">
                Quản lý các cổ vật thắng phiên, thực hiện thanh toán và theo dõi hành trình giao nhận
            </p>
        </div>

        <% if ("payment_success".equals(msg)) { %>
            <div class="alert alert-success">
                ✓ <strong>Thanh toán thành công qua MockPay!</strong> Đơn hàng đã được chuyển sang trạng thái chờ xuất kho vận chuyển bảo hiểm.
            </div>
        <% } else if ("dispute_submitted".equals(msg)) { %>
            <div class="alert alert-info">
                ✓ <strong>Đã gửi khiếu nại thành công!</strong> Ban quản trị sẽ đối soát và giải quyết trong vòng 24h làm việc.
            </div>
        <% } %>

        <% if (orders == null || orders.isEmpty()) { %>
            <div class="user-card user-empty-state">
                <div class="user-empty-icon">📦</div>
                <h3 class="user-empty-title">Bạn chưa có đơn hàng trúng phiên nào</h3>
                <p class="user-empty-desc">Khi bạn là người trả giá cao nhất khi phiên kết thúc, đơn hàng sẽ tự động hiển thị tại đây.</p>
                <a href="<%= ctx %>/catalogue" class="btn btn-gold">
                    Tham Gia Đấu Giá Trực Tiếp
                </a>
            </div>
        <% } else { %>
            <div class="user-card">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Cổ vật trúng phiên</th>
                                <th>Giá gõ búa thắng</th>
                                <th>Hạn thanh toán (48h)</th>
                                <th>Trạng thái</th>
                                <th class="text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Order o : orders) { %>
                                <tr>
                                    <td><strong>#ORD-<%= o.getOrderId() %></strong></td>
                                    <td>
                                        <div class="user-item-cell">
                                            <img src="<%= ctx %>/<%= o.getPrimaryImageUrl() %>" alt="<%= o.getItemName() %>" class="user-thumb thumb-sm">
                                            <div>
                                                <div class="item-code text-xs"><%= o.getItemCode() %></div>
                                                <span class="font-semibold"><%= o.getItemName() %></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="price-value text-base">
                                        <%= FormatUtil.formatVND(o.getFinalPrice()) %>
                                    </td>
                                    <td class="text-sm">
                                        <% if ("PENDING_PAYMENT".equalsIgnoreCase(o.getStatus())) { %>
                                            <strong class="color-danger">
                                                <%= FormatUtil.formatDateTime(o.getPaymentDeadline()) %>
                                            </strong>
                                            <div class="text-xs color-muted">(Hạn tất toán trong 48h)</div>
                                        <% } else { %>
                                            <span class="color-muted">Đã thanh toán</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge <%= o.getStatusBadgeClass() %>">
                                            <%= o.getStatusDisplay() %>
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <div class="table-action-group">
                                            <% if (o.isPayable()) { %>
                                                <a href="<%= ctx %>/checkout?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-gold">
                                                    💳 Thanh Toán
                                                </a>
                                            <% } %>
                                            <% if ("SHIPPING".equalsIgnoreCase(o.getStatus()) || "DELIVERED".equalsIgnoreCase(o.getStatus())) { %>
                                                <a href="<%= ctx %>/shipment-tracking?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-dark">
                                                    🚚 Theo dõi
                                                </a>
                                            <% } %>
                                            <a href="<%= ctx %>/dispute?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-outline-gold" title="Khiếu nại">
                                                ⚖️ Khiếu nại
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
