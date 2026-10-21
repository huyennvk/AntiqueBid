<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.User" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "users");
    List<User> users = (List<User>) request.getAttribute("users");
    String ctx = request.getContextPath();
    String msg = request.getParameter("msg");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý người dùng | Admin" />
    <jsp:param name="extraCss" value="admin_users.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-page-header">
                <div>
                    <h1 class="admin-header-title">👥 Quản Lý Người Dùng Hệ Thống</h1>
                    <p class="admin-header-desc">
                        Theo dõi tài khoản khách đấu giá, chỉ số vi phạm và phân quyền/khóa tài khoản
                    </p>
                </div>
                <div>
                    <a href="<%= ctx %>/admin/kyc-review" class="btn btn-gold">🪪 Duyệt Hồ Sơ KYC</a>
                </div>
            </div>

            <% if ("lock_updated".equals(msg)) { %>
                <div class="alert alert-success">✓ Đã cập nhật trạng thái khóa tài khoản thành công!</div>
            <% } %>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Họ và tên</th>
                                <th>Email</th>
                                <th>Điện thoại</th>
                                <th>Vai trò</th>
                                <th>Xác minh KYC</th>
                                <th>Số lần vi phạm</th>
                                <th>Trạng thái</th>
                                <th class="text-right">Khóa / Mở</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null) { for (User u : users) { %>
                                <tr>
                                    <td>#<%= u.getUserId() %></td>
                                    <td><strong><%= u.getFullName() %></strong></td>
                                    <td><%= u.getEmail() %></td>
                                    <td><%= u.getPhone() != null ? u.getPhone() : "—" %></td>
                                    <td>
                                        <% if (u.isAdmin()) { %>
                                            <span class="badge badge-warning">ADMIN (CHỦ SÀN)</span>
                                        <% } else { %>
                                            <span class="badge badge-info">BIDDER</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("VERIFIED".equalsIgnoreCase(u.getKycStatus())) { %>
                                            <span class="badge badge-verified">✓ CCCD ĐÃ DUYỆT</span>
                                            <% if (u.getCitizenId() != null && !u.getCitizenId().isEmpty()) { %>
                                                <div class="text-xs font-mono color-gold mt-1"><%= u.getCitizenId() %></div>
                                            <% } %>
                                        <% } else if ("PENDING".equalsIgnoreCase(u.getKycStatus())) { %>
                                            <span class="badge badge-pending">⏳ CHỜ DUYỆT CCCD</span>
                                            <% if (u.getCitizenId() != null && !u.getCitizenId().isEmpty()) { %>
                                                <div class="text-xs font-mono color-warning mt-1"><%= u.getCitizenId() %></div>
                                            <% } %>
                                        <% } else if ("REJECTED".equalsIgnoreCase(u.getKycStatus())) { %>
                                            <span class="badge badge-danger">✕ TỪ CHỐI CCCD</span>
                                        <% } else { %>
                                            <span class="badge badge-secondary">CHƯA NỘP CCCD</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <strong class="<%= u.getViolationCount() >= 3 ? "color-danger" : (u.getViolationCount() > 0 ? "color-warning" : "color-success") %>">
                                            <%= u.getViolationCount() %> / 3
                                        </strong>
                                    </td>
                                    <td>
                                        <% if (u.isLocked()) { %>
                                            <span class="badge badge-danger">BỊ KHÓA</span>
                                        <% } else { %>
                                            <span class="badge badge-success">HOẠT ĐỘNG</span>
                                        <% } %>
                                    </td>
                                    <td class="text-right">
                                        <% if (!u.isAdmin()) { %>
                                            <form action="<%= ctx %>/admin/user-toggle-lock" method="POST" class="d-inline">
                                                <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                <input type="hidden" name="lock" value="<%= !u.isLocked() %>">
                                                <button type="submit" class="btn btn-sm <%= u.isLocked() ? "btn-success" : "btn-danger" %>"
                                                        onclick="return confirm('Bạn có chắc muốn <%= u.isLocked() ? "mở khóa" : "khóa" %> tài khoản này?');">
                                                    <%= u.isLocked() ? "Mở khóa" : "Khóa tài khoản" %>
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <span class="color-muted text-xs">Hệ thống</span>
                                        <% } %>
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
