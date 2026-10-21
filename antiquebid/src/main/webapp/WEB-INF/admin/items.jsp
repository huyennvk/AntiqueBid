<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "items");
    List<AntiqueItem> items = (List<AntiqueItem>) request.getAttribute("items");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý hiện vật cổ vật | Admin" />
    <jsp:param name="extraCss" value="admin_items.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-page-header">
                <div>
                    <h1 class="admin-header-title">🏺 Quản Lý Hiện Vật Cổ Vật</h1>
                    <p class="admin-header-desc">Hồ sơ di sản độc bản, trạng thái giám định và vòng đời niêm yết</p>
                </div>
                <div>
                    <a href="<%= ctx %>/admin/item-form" class="btn btn-gold">+ Đăng Ký Cổ Vật Mới</a>
                </div>
            </div>

            <% if ("item_saved".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã lưu thông tin cổ vật thành công!</div>
            <% } else if ("appraisal_saved".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã ghi nhận biên bản giám định và cấp chứng thư hợp lệ! Hiện vật đủ điều kiện mở phiên đấu giá.</div>
            <% } %>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã & Hiện vật</th>
                                <th>Danh mục</th>
                                <th>Niên đại</th>
                                <th>Tình trạng</th>
                                <th>Trạng thái sàn</th>
                                <th>Chứng thư giám định</th>
                                <th class="text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (items != null) { for (AntiqueItem item : items) { %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-center gap-2">
                                            <img src="<%= ctx %>/<%= item.getPrimaryImageUrl() %>" alt="" class="admin-table-thumb">
                                            <div>
                                                <div class="item-code text-xs"><%= item.getItemCode() %></div>
                                                <a href="<%= ctx %>/item-detail?id=<%= item.getItemId() %>" target="_blank" class="font-semibold text-primary">
                                                    <%= item.getName() %>
                                                </a>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= item.getCategoryName() %></td>
                                    <td><%= item.getEraDisplay() %></td>
                                    <td><span class="badge badge-success"><%= item.getConditionDisplay() %></span></td>
                                    <td>
                                        <% if ("AVAILABLE".equalsIgnoreCase(item.getStatus())) { %>
                                            <span class="badge badge-verified">SẴN SÀNG LÊN SÀN</span>
                                        <% } else if ("IN_AUCTION".equalsIgnoreCase(item.getStatus())) { %>
                                            <span class="badge badge-live">ĐANG ĐẤU GIÁ</span>
                                        <% } else if ("SOLD".equalsIgnoreCase(item.getStatus())) { %>
                                            <span class="badge badge-secondary">ĐÃ BÁN</span>
                                        <% } else { %>
                                            <span class="badge badge-warning"><%= item.getStatusDisplay() %></span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (item.getCertificateNo() != null) { %>
                                            <span class="color-success font-semibold text-sm">✓ <%= item.getCertificateNo() %></span>
                                            <div class="text-xs color-muted">GĐ: <%= item.getAppraiserName() %></div>
                                        <% } else { %>
                                            <span class="color-warning text-sm">Chưa có chứng thư</span>
                                        <% } %>
                                    </td>
                                    <td class="text-right">
                                        <div class="table-action-group">
                                            <a href="<%= ctx %>/admin/item-form?id=<%= item.getItemId() %>" class="btn btn-sm btn-outline-gold" title="Sửa thông tin">
                                                Sửa
                                            </a>
                                            <a href="<%= ctx %>/admin/appraise?itemId=<%= item.getItemId() %>" class="btn btn-sm btn-dark" title="Giám định & Cấp chứng thư">
                                                Giám định
                                            </a>
                                            <% if ("AVAILABLE".equalsIgnoreCase(item.getStatus())) { %>
                                                <a href="<%= ctx %>/admin/auction-form?itemId=<%= item.getItemId() %>" class="btn btn-sm btn-gold" title="Tạo phiên đấu giá">
                                                    Mở phiên
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

<jsp:include page="/WEB-INF/footer.jsp" />
