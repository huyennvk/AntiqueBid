<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    String ctx = request.getContextPath();
    String trackingTitle = "Theo dõi vận chuyển #ORD-" + (order != null ? order.getOrderId() : "") + " | Cổ Vật Đường";
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= trackingTitle %>' />
    <jsp:param name="extraCss" value="shipment_tracking.css" />
</jsp:include>

    <main class="container tracking-container">
        <div class="mb-4">
            <div class="mb-2">
                <a href="<%= ctx %>/orders" class="text-gold font-bold text-sm">&larr; Quay lại danh sách đơn hàng</a>
            </div>
            <h1 class="font-bold text-2xl mb-1">🚚 Theo Dõi Vận Chuyển Cổ Vật</h1>
            <p class="text-sm text-muted">
                Hành trình giao nhận đặc biệt có bảo hiểm di sản cho đơn #ORD-<%= order.getOrderId() %>
            </p>
        </div>

        <div class="card p-4 mb-4">
            <div class="d-flex gap-3 align-center pb-3 mb-3 border-bottom">
                <img src="<%= ctx %>/<%= order.getPrimaryImageUrl() %>" alt="<%= order.getItemName() %>"
                     class="avatar-md">
                <div class="flex-1">
                    <div class="item-code"><%= order.getItemCode() %></div>
                    <h3 class="font-bold text-lg mb-1"><%= order.getItemName() %></h3>
                    <div class="text-sm text-secondary">
                        Giá trị bảo hiểm: <strong class="text-danger"><%= FormatUtil.formatVND(order.getFinalPrice()) %></strong>
                    </div>
                </div>
                <div>
                    <span class="badge <%= order.getStatusBadgeClass() %> badge-lg">
                        <%= order.getStatusDisplay() %>
                    </span>
                </div>
            </div>

            <div class="grid-2 gap-3 text-sm mb-4">
                <div>
                    <span class="text-muted">Đơn vị vận chuyển chuyên dụng:</span><br>
                    <strong><%= order.getCarrierName() != null ? order.getCarrierName() : "Hỏa tốc Bảo an Di sản Cổ vật" %></strong>
                </div>
                <div>
                    <span class="text-muted">Mã vận đơn bưu phẩm:</span><br>
                    <strong class="text-primary"><%= order.getTrackingNumber() != null ? order.getTrackingNumber() : "VN-POST-ANTQ-" + order.getOrderId() + "89" %></strong>
                </div>
                <div class="grid-col-full">
                    <span class="text-muted">Địa chỉ giao hàng nhận hiện vật:</span><br>
                    <strong><%= order.getShippingAddress() %></strong>
                </div>
            </div>

            <!-- Shipment Timeline (Hình 2.11) -->
            <h3 class="text-base font-bold mb-3 pb-2 border-bottom">
                Nhật Ký Hành Trình Giao Nhận
            </h3>

            <div class="timeline">
                <!-- Bước 1 -->
                <div class="timeline-step active">
                    <div class="timeline-dot"></div>
                    <div class="timeline-title">Đã xác nhận đơn & Tiếp nhận thanh toán</div>
                    <div class="timeline-time"><%= FormatUtil.formatDateTime(order.getCreatedAt()) %></div>
                    <div class="timeline-desc">Hiện vật được rút khỏi kho trưng bày, niêm phong thùng chuyên dụng chống sốc.</div>
                </div>

                <!-- Bước 2 -->
                <div class="timeline-step <%= ("SHIPPING".equalsIgnoreCase(order.getStatus()) || "DELIVERED".equalsIgnoreCase(order.getStatus())) ? "active" : "current" %>">
                    <div class="timeline-dot"></div>
                    <div class="timeline-title">Bàn giao cho đơn vị vận chuyển bảo hiểm</div>
                    <div class="timeline-time">Kèm biên bản kiểm định hiện trạng và chứng thư gốc</div>
                </div>

                <!-- Bước 3 -->
                <div class="timeline-step <%= "DELIVERED".equalsIgnoreCase(order.getStatus()) ? "active" : ("SHIPPING".equalsIgnoreCase(order.getStatus()) ? "current" : "") %>">
                    <div class="timeline-dot"></div>
                    <div class="timeline-title">Đang trên lộ trình chuyển phát an toàn</div>
                    <div class="timeline-desc">Xe chuyên dụng có bảo vệ đi kèm, giám sát GPS 24/7.</div>
                </div>

                <!-- Bước 4 -->
                <div class="timeline-step <%= "DELIVERED".equalsIgnoreCase(order.getStatus()) ? "active" : "" %>">
                    <div class="timeline-dot"></div>
                    <div class="timeline-title">Giao hàng thành công & Đồng kiểm tra cổ vật</div>
                    <div class="timeline-desc">Khách hàng mở hộp kiểm tra cùng nhân viên và ký nhận bàn giao chứng thư.</div>
                </div>
            </div>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
