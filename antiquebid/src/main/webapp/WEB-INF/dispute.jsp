<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Order" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    String ctx = request.getContextPath();
    String disputeTitle = "Gửi khiếu nại đơn #ORD-" + (order != null ? order.getOrderId() : "") + " | Cổ Vật Đường";
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= disputeTitle %>' />
    <jsp:param name="extraCss" value="dispute.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-container narrow">
            <div class="user-page-header">
                <div>
                    <a href="<%= ctx %>/orders" class="back-link">&larr; Quay lại danh sách đơn hàng</a>
                </div>
                <h1 class="user-page-title">⚖️ Gửi Khiếu Nại Đơn Hàng</h1>
                <p class="user-page-subtitle">
                    Bảo vệ quyền lợi nhà sưu tầm theo chính sách bảo hành và giám định Cổ Vật Đường
                </p>
            </div>

            <% String err = (String) request.getAttribute("errorMessage"); %>
            <% if (err != null) { %>
                <div class="alert alert-danger"><%= err %></div>
            <% } %>

            <!-- Order info summary -->
            <div class="item-summary-strip">
                <img src="<%= ctx %>/<%= order.getPrimaryImageUrl() %>" alt="<%= order.getItemName() %>" class="user-thumb thumb-lg">
                <div>
                    <div class="item-code text-xs"><%= order.getItemCode() %> • Đơn hàng #ORD-<%= order.getOrderId() %></div>
                    <div class="font-bold text-primary text-base"><%= order.getItemName() %></div>
                    <div class="text-sm color-danger font-semibold">Giá trị: <%= FormatUtil.formatVND(order.getFinalPrice()) %></div>
                </div>
            </div>

            <div class="user-card p-large">
                <form action="<%= ctx %>/dispute" method="POST">
                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">

                    <div class="form-group">
                        <label class="form-label">Phân loại lý do khiếu nại (*)</label>
                        <select name="reasonType" class="form-control" required>
                            <option value="TỔN HẠI VẬN CHUYỂN">Cổ vật có dấu hiệu nứt/mẻ/vỡ phát sinh trong quá trình vận chuyển</option>
                            <option value="SAI LỆCH MÔ TẢ">Hiện trạng thực tế không khớp với mô tả trong hồ sơ và chứng thư</option>
                            <option value="CHẬM TRỄ GIAO HÀNG">Quá thời hạn giao hàng cam kết mà chưa nhận được hiện vật</option>
                            <option value="NGHI NGỜ GIÁM ĐỊNH">Có nghi vấn về tính nguyên bản cần đối soát lại với hội đồng giám định</option>
                            <option value="LÝ DO KHÁC">Lý do khiếu nại khác</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mô tả chi tiết nội dung khiếu nại (*)</label>
                        <textarea name="details" class="form-control" rows="5" 
                                  placeholder="Vui lòng cung cấp chi tiết vị trí tổn hại, diễn biến nhận hàng hoặc căn cứ khiếu nại để ban quản trị tiến hành đối soát..." required></textarea>
                    </div>

                    <div class="policy-notice-box">
                        🛡️ <strong>Chính sách bồi thường:</strong> Đơn khiếu nại sẽ được chuyển trực tiếp đến Admin trưởng sàn. Nếu lỗi thuộc về sàn hoặc vận chuyển, bạn sẽ được hoàn tiền 100% qua cổng MockPay trong vòng 48h làm việc.
                    </div>

                    <button type="submit" class="btn btn-gold btn-lg w-100">
                        Gửi Khiếu Nại Cho Ban Quản Trị
                    </button>
                </form>
            </div>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
