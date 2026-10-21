<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Dispute" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "disputes");
    List<Dispute> disputes = (List<Dispute>) request.getAttribute("disputes");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Xử lý khiếu nại & Hoàn tiền | Admin" />
    <jsp:param name="extraCss" value="admin_disputes.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="d-flex justify-between align-center mb-4">
                <div>
                    <h1 class="font-bold text-2xl mb-1">⚖️ Xử Lý Khiếu Nại & Hoàn Tiền</h1>
                    <p class="text-sm text-muted">
                        Thẩm định yêu cầu đối soát, bồi thường tổn thất hoặc hoàn tiền qua cổng MockPay
                    </p>
                </div>
            </div>

            <% if ("resolved_success".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã xử lý phân quyết khiếu nại thành công!</div>
            <% } %>

            <!-- Bộ lọc trạng thái -->
            <div class="d-flex gap-2 mb-3">
                <a href="<%= ctx %>/admin/disputes" class="filter-pill <%= statusFilter == null ? "active" : "" %>">Tất cả</a>
                <a href="<%= ctx %>/admin/disputes?status=OPEN" class="filter-pill <%= "OPEN".equals(statusFilter) ? "active" : "" %>">Mới tiếp nhận (Cần xử lý)</a>
                <a href="<%= ctx %>/admin/disputes?status=RESOLVED_REFUND" class="filter-pill <%= "RESOLVED_REFUND".equals(statusFilter) ? "active" : "" %>">Đã hoàn tiền</a>
                <a href="<%= ctx %>/admin/disputes?status=REJECTED" class="filter-pill <%= "REJECTED".equals(statusFilter) ? "active" : "" %>">Đã bác bỏ</a>
            </div>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã khiếu nại</th>
                                <th>Đơn hàng & Hiện vật</th>
                                <th>Khách khiếu nại</th>
                                <th>Nội dung lý do</th>
                                <th>Thời điểm gửi</th>
                                <th>Trạng thái</th>
                                <th class="text-right">Phân quyết xử lý</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (disputes != null && !disputes.isEmpty()) { 
                                for (Dispute d : disputes) { %>
                                <tr>
                                    <td><strong>#DSP-<%= d.getDisputeId() %></strong></td>
                                    <td>
                                        <a href="<%= ctx %>/item-detail?id=<%= d.getItemId() %>" target="_blank" class="text-primary font-bold">
                                            <%= d.getItemName() %>
                                        </a>
                                        <div class="text-xs text-muted">Đơn: #ORD-<%= d.getOrderId() %></div>
                                    </td>
                                    <td>
                                        <strong><%= d.getBidderName() %></strong>
                                    </td>
                                    <td>
                                        <div class="font-bold text-xs"><%= d.getReason() %></div>
                                        <% if (d.getDetailExplanation() != null) { %>
                                            <div class="text-xs text-muted mt-1"><%= d.getDetailExplanation() %></div>
                                        <% } %>
                                        <% if (d.getResolutionNote() != null) { %>
                                            <div class="text-xs text-success mt-1">Ghi chú: <%= d.getResolutionNote() %></div>
                                        <% } %>
                                    </td>
                                    <td class="text-xs text-muted">
                                        <%= FormatUtil.formatDateTime(d.getCreatedAt()) %>
                                    </td>
                                    <td>
                                        <span class="badge <%= d.getStatusBadgeClass() %>">
                                            <%= d.getStatusDisplay() %>
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <% if ("OPEN".equalsIgnoreCase(d.getStatus())) { %>
                                            <div class="d-flex gap-1 justify-end">
                                                <!-- Action 1: Refund via MockPay -->
                                                <form action="<%= ctx %>/admin/dispute-resolve" method="POST">
                                                    <input type="hidden" name="disputeId" value="<%= d.getDisputeId() %>">
                                                    <input type="hidden" name="decision" value="REFUND">
                                                    <input type="hidden" name="note" value="Chấp thuận hoàn tiền 100% qua MockPay">
                                                    <button type="submit" class="btn btn-sm btn-success" title="Hoàn tiền cho khách">
                                                        ✓ Hoàn tiền
                                                    </button>
                                                </form>

                                                <!-- Action 2: Reject Dispute -->
                                                <form action="<%= ctx %>/admin/dispute-resolve" method="POST">
                                                    <input type="hidden" name="disputeId" value="<%= d.getDisputeId() %>">
                                                    <input type="hidden" name="decision" value="REJECT">
                                                    <input type="hidden" name="note" value="Bác bỏ khiếu nại: Hiện vật đúng mô tả và chứng thư gốc">
                                                    <button type="submit" class="btn btn-sm btn-danger" title="Bác bỏ khiếu nại">
                                                        ✕ Bác bỏ
                                                    </button>
                                                </form>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted text-xs">Đã giải quyết</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted p-4">
                                        Không có khiếu nại nào trong danh mục này.
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
