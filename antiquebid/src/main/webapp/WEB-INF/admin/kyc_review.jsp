<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.VerificationDocument" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "kyc");
    List<VerificationDocument> documents = (List<VerificationDocument>) request.getAttribute("documents");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Duyệt hồ sơ xác minh CCCD | Admin" />
    <jsp:param name="extraCss" value="admin_kyc.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-page-header">
                <div>
                    <h1 class="admin-header-title">🪪 Phê Duyệt Hồ Sơ Xác Minh Căn Cước Công Dân (CCCD)</h1>
                    <p class="admin-header-desc">
                        Sàn đấu giá Cổ Vật Đường áp dụng định danh duy nhất qua thẻ CCCD gắn chip 12 chữ số
                    </p>
                </div>
            </div>

            <% if ("kyc_updated".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã cập nhật kết quả thẩm định CCCD thành công!</div>
            <% } %>

            <!-- Filter Status Bar -->
            <div class="admin-filter-pills">
                <a href="<%= ctx %>/admin/kyc-review" class="filter-pill <%= statusFilter == null ? "active" : "" %>">Tất cả hồ sơ</a>
                <a href="<%= ctx %>/admin/kyc-review?status=PENDING" class="filter-pill <%= "PENDING".equals(statusFilter) ? "active" : "" %>">Chờ duyệt (PENDING)</a>
                <a href="<%= ctx %>/admin/kyc-review?status=VERIFIED" class="filter-pill <%= "VERIFIED".equals(statusFilter) ? "active" : "" %>">Đã duyệt (VERIFIED)</a>
                <a href="<%= ctx %>/admin/kyc-review?status=REJECTED" class="filter-pill <%= "REJECTED".equals(statusFilter) ? "active" : "" %>">Bị từ chối</a>
            </div>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Khách hàng</th>
                                <th>Số định danh CCCD</th>
                                <th>Ngày & Nơi cấp</th>
                                <th>Ảnh thẻ CCCD (2 mặt)</th>
                                <th>Thời điểm nộp</th>
                                <th>Ghi chú phản hồi</th>
                                <th class="text-right">Quyết định duyệt</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (documents != null && !documents.isEmpty()) { 
                                for (VerificationDocument doc : documents) { %>
                                <tr>
                                    <td>
                                        <div><strong><%= doc.getBidderName() %></strong></div>
                                        <div class="text-xs color-muted"><%= doc.getBidderEmail() %></div>
                                        <div class="text-xs text-muted">User ID: #<%= doc.getBidderId() %></div>
                                    </td>
                                    <td>
                                        <span class="badge badge-warning" style="font-family: monospace; font-size: 13px; letter-spacing: 1px;">
                                            <%= doc.getCitizenId() != null ? doc.getCitizenId() : "—" %>
                                        </span>
                                        <div class="text-xs color-success mt-1">✓ CCCD gắn chip</div>
                                    </td>
                                    <td class="text-sm">
                                        <div><strong><%= doc.getIssueDate() != null ? FormatUtil.formatDate(doc.getIssueDate()) : "10/05/2021" %></strong></div>
                                        <div class="text-xs color-muted"><%= doc.getIssuePlace() != null ? doc.getIssuePlace() : "Cục Cảnh sát QLHC về TTXH" %></div>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-2">
                                            <div class="text-center">
                                                <a href="<%= ctx %>/<%= doc.getFileUrl() %>" target="_blank" title="Xem ảnh mặt trước">
                                                    <img src="<%= ctx %>/<%= doc.getFileUrl() %>" alt="Mặt trước CCCD"
                                                         class="admin-kyc-thumb" style="width: 76px; height: 48px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border);"
                                                         onerror="this.src='<%= ctx %>/assets/images/sample_cccd_front.svg'">
                                                </a>
                                                <div class="text-xs text-muted mt-1">Mặt trước</div>
                                            </div>
                                            <div class="text-center">
                                                <a href="<%= ctx %>/<%= doc.getFileUrlBack() %>" target="_blank" title="Xem ảnh mặt sau (chip)">
                                                    <img src="<%= ctx %>/<%= doc.getFileUrlBack() %>" alt="Mặt sau CCCD"
                                                         class="admin-kyc-thumb" style="width: 76px; height: 48px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border);"
                                                         onerror="this.src='<%= ctx %>/assets/images/sample_cccd_back.svg'">
                                                </a>
                                                <div class="text-xs text-muted mt-1">Mặt sau</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-sm color-muted">
                                        <%= FormatUtil.formatDateTime(doc.getSubmittedAt()) %>
                                    </td>
                                    <td class="text-sm text-secondary">
                                        <%= doc.getReviewNote() != null ? doc.getReviewNote() : "—" %>
                                    </td>
                                    <td class="text-right">
                                        <form action="<%= ctx %>/admin/kyc-review" method="POST" class="admin-review-box">
                                            <input type="hidden" name="docId" value="<%= doc.getDocId() %>">
                                            <input type="hidden" name="bidderId" value="<%= doc.getBidderId() %>">
                                            <input type="text" name="reviewNote" placeholder="Ghi chú đối chiếu CCCD..." class="form-control admin-review-input">

                                            <div class="d-flex gap-1">
                                                <button type="submit" name="action" value="APPROVE" class="btn btn-sm btn-success">
                                                    ✓ Phê duyệt CCCD
                                                </button>
                                                <button type="submit" name="action" value="REJECT" class="btn btn-sm btn-danger">
                                                    ✕ Từ chối
                                                </button>
                                            </div>
                                        </form>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="7" class="admin-empty-cell">
                                        Không có hồ sơ xác minh CCCD nào trong mục này.
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
