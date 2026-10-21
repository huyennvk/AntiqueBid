<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "orders");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý đơn hàng & Vận đơn | Admin" />
    <jsp:param name="extraCss" value="admin_orders.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-page-header">
                <div>
                    <h1 class="admin-header-title">📦 Quản Lý Đơn Hàng & Vận Đơn</h1>
                    <p class="admin-header-desc">Theo dõi thanh toán, tạo vận đơn bảo hiểm và giao nhận cổ vật trúng đấu giá</p>
                </div>
            </div>

            <% if ("shipment_created".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã tạo vận đơn bảo hiểm thành công! Đơn hàng chuyển sang trạng thái Đang vận chuyển.</div>
            <% } else if ("delivered_success".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã xác nhận giao nhận thành công cổ vật và bàn giao chứng thư gốc!</div>
            <% } %>

            <!-- Filter Status Bar -->
            <div class="admin-filter-pills">
                <a href="<%= ctx %>/admin/orders" class="filter-pill <%= statusFilter == null ? "active" : "" %>">Tất cả</a>
                <a href="<%= ctx %>/admin/orders?status=PENDING_PAYMENT" class="filter-pill <%= "PENDING_PAYMENT".equals(statusFilter) ? "active" : "" %>">Chờ thanh toán</a>
                <a href="<%= ctx %>/admin/orders?status=PAID" class="filter-pill <%= "PAID".equals(statusFilter) ? "active" : "" %>">Đã thanh toán (Cần đóng gói)</a>
                <a href="<%= ctx %>/admin/orders?status=SHIPPING" class="filter-pill <%= "SHIPPING".equals(statusFilter) ? "active" : "" %>">Đang vận chuyển</a>
                <a href="<%= ctx %>/admin/orders?status=DELIVERED" class="filter-pill <%= "DELIVERED".equals(statusFilter) ? "active" : "" %>">Đã giao hàng</a>
            </div>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Khách trúng đấu giá</th>
                                <th>Cổ vật trúng phiên</th>
                                <th>Giá gõ búa</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái đơn</th>
                                <th class="text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (orders != null && !orders.isEmpty()) { 
                                for (Order o : orders) { %>
                                <tr>
                                    <td><strong>#ORD-<%= o.getOrderId() %></strong></td>
                                    <td>
                                        <div><strong><%= o.getBidderName() %></strong></div>
                                        <div class="text-xs color-muted"><%= o.getBidderPhone() %></div>
                                    </td>
                                    <td>
                                        <div class="d-flex align-center gap-2">
                                            <img src="<%= ctx %>/<%= o.getPrimaryImageUrl() %>" alt="" class="admin-table-thumb">
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
                                        <% if ("PAID".equalsIgnoreCase(o.getStatus()) || "SHIPPING".equalsIgnoreCase(o.getStatus()) || "DELIVERED".equalsIgnoreCase(o.getStatus())) { %>
                                            <span class="color-success font-semibold">✓ Đã thanh toán</span>
                                            <div class="text-xs color-muted"><%= o.getPaymentMethod() != null ? o.getPaymentMethod() : "MockPay" %></div>
                                        <% } else { %>
                                            <span class="color-danger font-semibold">Chờ thanh toán</span>
                                            <div class="text-xs color-muted">Hạn: <%= FormatUtil.formatDateTime(o.getPaymentDeadline()) %></div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge <%= o.getStatusBadgeClass() %>">
                                            <%= o.getStatusDisplay() %>
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <div class="table-action-group">
                                            <% if ("PAID".equalsIgnoreCase(o.getStatus())) { %>
                                                <a href="<%= ctx %>/admin/shipment-form?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-gold" title="Tạo vận đơn xuất kho">
                                                    🚚 Tạo vận đơn
                                                </a>
                                            <% } else if ("SHIPPING".equalsIgnoreCase(o.getStatus())) { %>
                                                <form action="<%= ctx %>/admin/order-deliver" method="POST" onsubmit="return confirm('Xác nhận đã giao hàng thành công đến tay người mua?');" class="d-inline">
                                                    <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                                    <button type="submit" class="btn btn-sm btn-success">✓ Đã giao</button>
                                                </form>
                                                <a href="<%= ctx %>/shipment-tracking?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-dark" target="_blank">
                                                    Hành trình
                                                </a>
                                            <% } else { %>
                                                <a href="<%= ctx %>/shipment-tracking?orderId=<%= o.getOrderId() %>" class="btn btn-sm btn-outline-gold" target="_blank">
                                                    Chi tiết
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="7" class="admin-empty-cell">
                                        Không tìm thấy đơn hàng nào.
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
