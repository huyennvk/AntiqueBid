<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AuditLog" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "audit");
    List<AuditLog> auditLogs = (List<AuditLog>) request.getAttribute("auditLogs");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Nhật ký hệ thống (Audit Log) | Admin" />
    <jsp:param name="extraCss" value="admin_audit.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="user-page-header">
                <h1 class="admin-header-title">📜 Nhật Ký Hoạt Động Hệ Thống</h1>
                <p class="admin-header-desc">
                    Ghi vết bất biến (Audit Trail) phục vụ đối soát pháp lý, kiểm toán an ninh và truy vết thao tác
                </p>
            </div>

            <div class="card p-4">
                <div class="table-responsive">
                    <table class="table text-sm">
                        <thead>
                            <tr>
                                <th>Log ID</th>
                                <th>Thời điểm</th>
                                <th>Tài khoản thực hiện</th>
                                <th>Hành động (Action)</th>
                                <th>Thực thể đích</th>
                                <th>Chi tiết thao tác</th>
                                <th>Địa chỉ IP</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (auditLogs != null && !auditLogs.isEmpty()) { 
                                for (AuditLog l : auditLogs) { %>
                                <tr>
                                    <td>#<%= l.getLogId() %></td>
                                    <td class="color-muted"><%= FormatUtil.formatDateTime(l.getCreatedAt()) %></td>
                                    <td>
                                        <strong><%= l.getUserEmail() != null ? l.getUserEmail() : "Hệ thống tự động" %></strong>
                                    </td>
                                    <td>
                                        <span class="badge badge-info"><%= l.getAction() %></span>
                                    </td>
                                    <td><%= l.getTargetEntity() %> (<%= l.getTargetId() != null ? "#" + l.getTargetId() : "—" %>)</td>
                                    <td><%= l.getDetails() != null ? l.getDetails() : "—" %></td>
                                    <td class="color-muted"><%= l.getIpAddress() != null ? l.getIpAddress() : "127.0.0.1" %></td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="7" class="admin-empty-cell">
                                        Chưa có bản ghi nhật ký hệ thống nào.
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
