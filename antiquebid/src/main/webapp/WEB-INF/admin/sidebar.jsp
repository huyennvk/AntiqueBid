<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String activePage = (String) request.getAttribute("activePage");
    String ctx = request.getContextPath();
%>
<aside class="admin-sidebar">
    <div class="admin-sidebar-header">
        <div class="admin-sidebar-subtitle">Hệ Thống Quản Trị</div>
        <div class="admin-sidebar-title">Admin Control Panel</div>
    </div>

    <ul class="admin-sidebar-menu">
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/dashboard" class="admin-sidebar-link <%= "dashboard".equals(activePage) ? "active" : "" %>">
                📊 Tổng quan & Thống kê
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/items" class="admin-sidebar-link <%= "items".equals(activePage) ? "active" : "" %>">
                🏺 Quản lý hiện vật
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/auctions" class="admin-sidebar-link <%= "auctions".equals(activePage) ? "active" : "" %>">
                ⚡ Quản lý phiên đấu giá
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/orders" class="admin-sidebar-link <%= "orders".equals(activePage) ? "active" : "" %>">
                📦 Quản lý đơn hàng & Vận đơn
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/disputes" class="admin-sidebar-link <%= "disputes".equals(activePage) ? "active" : "" %>">
                ⚖️ Xử lý khiếu nại & Hoàn tiền
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/users" class="admin-sidebar-link <%= "users".equals(activePage) ? "active" : "" %>">
                👥 Quản lý người dùng
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/kyc-review" class="admin-sidebar-link <%= "kyc".equals(activePage) ? "active" : "" %>">
                🪪 Duyệt hồ sơ KYC
            </a>
        </li>
        <li class="admin-sidebar-item">
            <a href="<%= ctx %>/admin/audit-logs" class="admin-sidebar-link <%= "audit".equals(activePage) ? "active" : "" %>">
                📜 Nhật ký hệ thống (Audit)
            </a>
        </li>
        <li class="admin-sidebar-item admin-sidebar-divider">
            <a href="<%= ctx %>/catalogue" class="admin-sidebar-link">
                🌐 Về giao diện khách hàng
            </a>
        </li>
    </ul>
</aside>
