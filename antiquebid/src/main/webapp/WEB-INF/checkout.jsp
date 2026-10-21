<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    String ctx = request.getContextPath();
    String checkoutTitle = "Thanh toán đơn hàng #ORD-" + (order != null ? order.getOrderId() : "") + " | Cổ Vật Đường";
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= checkoutTitle %>' />
    <jsp:param name="extraCss" value="checkout.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-container medium">
            <div class="user-page-header">
                <h1 class="user-page-title">💳 Thanh Toán Đơn Hàng Cổ Vật</h1>
                <p class="user-page-subtitle">
                    Đơn hàng #ORD-<%= order.getOrderId() %> • Hạn thanh toán: <%= FormatUtil.formatDateTime(order.getPaymentDeadline()) %>
                </p>
            </div>

            <form action="<%= ctx %>/checkout" method="POST">
                <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">

                <div class="checkout-grid">
                    <!-- Left: Item & Shipping Details -->
                    <div>
                        <!-- Item Summary Card -->
                        <div class="card p-3 mb-3">
                            <h3 class="checkout-card-header">
                                Cổ vật trúng đấu giá
                            </h3>
                            <div class="d-flex gap-3 align-center">
                                <img src="<%= ctx %>/<%= order.getPrimaryImageUrl() %>" alt="<%= order.getItemName() %>" class="checkout-thumb">
                                <div>
                                    <div class="item-code"><%= order.getItemCode() %></div>
                                    <div class="text-base font-semibold text-primary"><%= order.getItemName() %></div>
                                    <div class="text-sm color-muted mt-1">
                                        Phiên đấu giá đã kết thúc thành công
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Shipping Address -->
                        <div class="card p-3 mb-3">
                            <h3 class="checkout-card-header">
                                Địa chỉ giao nhận bảo hiểm
                            </h3>
                            <div class="text-sm line-relaxed">
                                <div>Người nhận: <strong><%= order.getBidderName() %></strong></div>
                                <div>Điện thoại: <strong><%= order.getBidderPhone() %></strong></div>
                                <div>Email: <%= order.getBidderEmail() %></div>
                                <div class="mt-1">
                                    Địa chỉ: <strong><%= order.getShippingAddress() != null ? order.getShippingAddress() : "Chưa cập nhật địa chỉ mặc định" %></strong>
                                </div>
                            </div>
                        </div>

                        <!-- Payment Method Choice -->
                        <div class="card p-3">
                            <h3 class="checkout-card-header">
                                Chọn phương thức thanh toán
                            </h3>
                            <div class="d-flex flex-column gap-2">
                                <label class="checkout-method-card">
                                    <input type="radio" name="paymentMethod" value="MOCKPAY_WALLET" checked>
                                    <div>
                                        <div class="font-semibold text-primary">Ví điện tử MockPay (Khuyên dùng)</div>
                                        <div class="text-xs color-muted">Xác thực thanh toán tức thì qua số dư ví giả lập</div>
                                    </div>
                                </label>

                                <label class="checkout-method-card">
                                    <input type="radio" name="paymentMethod" value="MOCKPAY_CARD">
                                    <div>
                                        <div class="font-semibold text-primary">Thẻ thanh toán quốc tế / ATM (MockPay)</div>
                                        <div class="text-xs color-muted">Hỗ trợ thẻ Visa/Mastercard/JCB/Napas giả lập</div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Invoice Breakdown Card -->
                    <div>
                        <div class="card p-4 border-gold">
                            <h3 class="card-title text-base mb-3">Chi tiết hóa đơn</h3>

                            <div>
                                <div class="checkout-summary-row">
                                    <span class="color-muted">Giá gõ búa thắng phiên:</span>
                                    <strong><%= FormatUtil.formatVND(order.getFinalPrice()) %></strong>
                                </div>
                                <div class="checkout-summary-row">
                                    <span class="color-muted">Phí bảo hiểm di sản:</span>
                                    <strong class="color-success">Miễn phí (Tài trợ)</strong>
                                </div>
                                <div class="checkout-summary-row">
                                    <span class="color-muted">Vận chuyển chuyên dụng:</span>
                                    <strong class="color-success">Miễn phí</strong>
                                </div>
                                <div class="checkout-total-row">
                                    <span>TỔNG THANH TOÁN:</span>
                                    <strong class="price-value text-xl"><%= FormatUtil.formatVND(order.getFinalPrice()) %></strong>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-gold btn-lg w-100 mt-3 font-bold">
                                🚀 Tiến Hành Thanh Toán Qua MockPay
                            </button>

                            <div class="text-xs color-muted text-center mt-2">
                                🔒 Giao dịch được bảo vệ và mã hóa 256-bit
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
