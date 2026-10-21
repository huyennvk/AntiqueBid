<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    String method = (String) request.getAttribute("method");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= "Cổng thanh toán MockPay Sandbox | #ORD-" + order.getOrderId() %>' />
    <jsp:param name="extraCss" value="payment_gateway.css" />
    <jsp:param name="bodyClass" value="mockpay-wrapper" />
    <jsp:param name="hideNav" value="true" />
</jsp:include>

    <div class="mockpay-container">
        <!-- MockPay Header -->
        <div class="mockpay-header">
            <div class="mockpay-logo">
                <span>💳</span> MockPay
            </div>
            <div class="mockpay-sandbox-tag">
                SANDBOX SIMULATOR (HÌNH 2.24)
            </div>
        </div>

        <!-- Hộp tóm tắt đơn hàng -->
        <div class="p-4 bg-surface-alt border-bottom">
            <div class="d-flex justify-between align-baseline mb-1">
                <span class="text-sm text-muted">Đơn vị thụ hưởng:</span>
                <strong class="text-primary">SÀN ĐẤU GIÁ CỔ VẬT ĐƯỜNG</strong>
            </div>
            <div class="d-flex justify-between align-baseline mb-1">
                <span class="text-sm text-muted">Mã đơn hàng:</span>
                <strong>#ORD-<%= order.getOrderId() %> (<%= order.getItemName() %>)</strong>
            </div>
            <div class="d-flex justify-between align-baseline pt-2 mt-2 border-top border-dashed">
                <span class="text-sm font-bold text-primary">Số tiền thanh toán:</span>
                <strong class="mockpay-amount-val">
                    <%= FormatUtil.formatVND(order.getFinalPrice()) %>
                </strong>
            </div>
        </div>

        <!-- Biểu mẫu xác nhận thanh toán -->
        <div class="mockpay-body">
            <form action="<%= ctx %>/mockpay-gateway" method="POST">
                <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                <input type="hidden" name="method" value="<%= method %>">

                <% if ("MOCKPAY_CARD".equalsIgnoreCase(method)) { %>
                    <!-- Thẻ tín dụng/ghi nợ -->
                    <div class="form-group">
                        <label class="form-label">Số thẻ giả lập (Test Card Number)</label>
                        <input type="text" class="form-control tracking-widest font-bold" value="9704 1988 8888 6666" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Tên chủ thẻ</label>
                        <input type="text" class="form-control" value="<%= order.getBidderName().toUpperCase() %>" required>
                    </div>

                    <div class="grid-2 gap-3">
                        <div class="form-group">
                            <label class="form-label">Ngày hết hạn</label>
                            <input type="text" class="form-control" value="12/29" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Mã CVV</label>
                            <input type="password" class="form-control" value="888" maxlength="3" required>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Ví điện tử MockPay -->
                    <div class="alert alert-info mb-3">
                        <div class="text-sm">Số dư ví MockPay giả lập khả dụng:</div>
                        <div class="text-2xl font-bold my-1 text-primary">500.000.000 ₫</div>
                        <div class="text-xs text-success">✓ Đủ điều kiện thanh toán giao dịch này</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Nhập mã PIN ví MockPay giả lập</label>
                        <input type="password" class="form-control text-center font-bold text-xl tracking-widest" value="1234" maxlength="6" required>
                        <small class="text-muted text-xs">Mã PIN thử nghiệm mặc định: 1234</small>
                    </div>
                <% } %>

                <div class="d-flex flex-column gap-2 mt-4">
                    <button type="submit" name="action" value="confirm" class="btn btn-gold btn-lg btn-block font-bold">
                        ✓ Xác Nhận Thanh Toán <%= FormatUtil.formatVND(order.getFinalPrice()) %>
                    </button>

                    <button type="submit" name="action" value="cancel" class="btn btn-outline-gold btn-block">
                        ✕ Hủy Giao Dịch & Quay Lại
                    </button>
                </div>
            </form>
        </div>

        <div class="p-3 bg-surface-alt border-top text-center text-xs text-muted">
            Hệ thống thanh toán thử nghiệm phục vụ đồ án Phân tích & Thiết kế HTTTQL
        </div>
    </div>

<jsp:include page="/WEB-INF/footer.jsp">
    <jsp:param name="hideFooter" value="true" />
</jsp:include>
