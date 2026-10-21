<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    request.setAttribute("activePage", "orders");
    Order order = (Order) request.getAttribute("order");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= "Tạo vận đơn xuất kho #ORD-" + order.getOrderId() + " | Admin" %>' />
    <jsp:param name="extraCss" value="admin_forms.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-form-container narrow">
                <div class="user-page-header">
                    <div>
                        <a href="<%= ctx %>/admin/orders" class="back-link">&larr; Quay lại danh sách đơn hàng</a>
                    </div>
                    <h1 class="admin-header-title">🚚 Tạo Vận Đơn Bảo Hiểm Xuất Kho</h1>
                    <p class="admin-header-desc">
                        Chỉ tạo vận đơn khi đơn hàng đã thanh toán thành công (PAID). Hiện vật được đóng thùng chống sốc và bàn giao đơn vị vận chuyển bảo an.
                    </p>
                </div>

                <div class="admin-form-card">
                    <!-- Order summary box -->
                    <div class="admin-summary-box">
                        <div class="d-flex gap-3 align-center mb-3">
                            <img src="<%= ctx %>/<%= order.getPrimaryImageUrl() %>" alt="" class="admin-table-thumb thumb-md">
                            <div>
                                <div class="item-code text-xs"><%= order.getItemCode() %> • Đơn #ORD-<%= order.getOrderId() %></div>
                                <h3 class="card-title text-base my-1"><%= order.getItemName() %></h3>
                                <div class="text-sm color-success font-semibold">
                                    ✓ Đã thanh toán: <%= FormatUtil.formatVND(order.getFinalPrice()) %>
                                </div>
                            </div>
                        </div>

                        <div class="text-sm line-relaxed color-muted border-top border-dashed pt-2">
                            <div>Người nhận: <strong><%= order.getBidderName() %></strong> (SĐT: <%= order.getBidderPhone() %>)</div>
                            <div>Địa chỉ nhận: <strong><%= order.getShippingAddress() %></strong></div>
                        </div>
                    </div>

                    <!-- Shipment form -->
                    <form action="<%= ctx %>/admin/shipment-form" method="POST">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">

                        <div class="form-group">
                            <label class="form-label">Đơn vị vận chuyển di sản chuyên dụng (*)</label>
                            <select name="carrierName" class="form-control" required>
                                <option value="Hỏa tốc Bảo an Di sản Cổ vật">Hỏa tốc Bảo an Di sản Cổ vật (Có bảo vệ áp tải)</option>
                                <option value="Viettel Post Chuyên Biệt Di Sản">Viettel Post Chuyên Biệt Di Sản (Bảo hiểm 100%)</option>
                                <option value="VNPost Hỏa Tốc Hiện Vật Quý">VNPost Hỏa Tốc Hiện Vật Quý</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mã vận đơn bưu phẩm (Tracking Number) (*)</label>
                            <input type="text" name="trackingNumber" class="form-control" 
                                   value="VN-POST-ANTQ-<%= order.getOrderId() %><%= System.currentTimeMillis() % 1000 %>" required>
                        </div>

                        <div class="admin-info-note">
                            🔒 Sau khi xác nhận tạo vận đơn, trạng thái đơn hàng sẽ tự động chuyển thành <strong>Đang vận chuyển (SHIPPING)</strong> và kích hoạt nhật ký hành trình theo dõi cho khách hàng.
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-gold btn-lg flex-1 font-bold">
                                🚀 Xuất Kho & Bàn Giao Vận Chuyển
                            </button>
                            <a href="<%= ctx %>/admin/orders" class="btn btn-dark btn-lg">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
<jsp:include page="/WEB-INF/footer.jsp" />
