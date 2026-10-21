<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.Category" %>
<%@ page import="java.util.List" %>
<%
    String ctx = request.getContextPath();
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null || selectedStatus.trim().isEmpty()) {
        selectedStatus = "all";
    }
    Long selectedCategory = (Long) request.getAttribute("selectedCategory");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
%>

<form action="<%= ctx %>/catalogue" method="GET" class="sidebar-filter-form" id="sidebarFilterForm">
    <!-- Giữ lại từ khóa tìm kiếm từ thanh tìm kiếm dài trên header (nếu có) khi người dùng lọc -->
    <% if (keyword != null && !keyword.trim().isEmpty()) { %>
        <input type="hidden" name="keyword" value="<%= keyword %>">
    <% } %>

    <!-- KHỐI 1: TRẠNG THÁI TÀI SẢN -->
    <div class="sidebar-card">
        <h3 class="sidebar-title">Trạng thái tài sản</h3>
        <div class="sidebar-title-accent">
            <span class="sidebar-title-bar"></span>
            <span class="sidebar-title-dot"></span>
            <span class="sidebar-title-dot"></span>
        </div>

        <div class="sidebar-options-list">
            <label class="sidebar-check-item <%= "all".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">
                <input type="radio" name="status" value="all" 
                       class="sidebar-checkbox" 
                       <%= "all".equalsIgnoreCase(selectedStatus) ? "checked" : "" %>
                       onchange="document.getElementById('sidebarFilterForm').submit()">
                <span class="sidebar-check-text">Tất cả</span>
            </label>

            <label class="sidebar-check-item <%= "upcoming".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">
                <input type="radio" name="status" value="upcoming" 
                       class="sidebar-checkbox" 
                       <%= "upcoming".equalsIgnoreCase(selectedStatus) ? "checked" : "" %>
                       onchange="document.getElementById('sidebarFilterForm').submit()">
                <span class="sidebar-check-text">Sắp diễn ra</span>
            </label>

            <label class="sidebar-check-item <%= "live".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">
                <input type="radio" name="status" value="live" 
                       class="sidebar-checkbox" 
                       <%= "live".equalsIgnoreCase(selectedStatus) ? "checked" : "" %>
                       onchange="document.getElementById('sidebarFilterForm').submit()">
                <span class="sidebar-check-text">Đang diễn ra</span>
            </label>

            <label class="sidebar-check-item <%= "ended".equalsIgnoreCase(selectedStatus) ? "active" : "" %>">
                <input type="radio" name="status" value="ended" 
                       class="sidebar-checkbox" 
                       <%= "ended".equalsIgnoreCase(selectedStatus) ? "checked" : "" %>
                       onchange="document.getElementById('sidebarFilterForm').submit()">
                <span class="sidebar-check-text">Đã kết thúc</span>
            </label>
        </div>
    </div>

    <!-- KHỐI 2: DANH MỤC CỔ VẬT -->
    <div class="sidebar-card">
        <h3 class="sidebar-title">Danh mục cổ vật</h3>
        <div class="sidebar-title-accent">
            <span class="sidebar-title-bar"></span>
            <span class="sidebar-title-dot"></span>
            <span class="sidebar-title-dot"></span>
        </div>

        <div class="sidebar-options-list">
            <label class="sidebar-check-item <%= selectedCategory == null ? "active" : "" %>">
                <input type="radio" name="category" value="" 
                       class="sidebar-checkbox" 
                       <%= selectedCategory == null ? "checked" : "" %>
                       onchange="document.getElementById('sidebarFilterForm').submit()">
                <span class="sidebar-check-text">Tất cả danh mục</span>
            </label>

            <% if (categories != null) { for (Category c : categories) { 
                boolean isCatSelected = (selectedCategory != null && selectedCategory.equals(c.getCategoryId()));
                String icon = "🏛️";
                if (c.getCategoryId() == 1) icon = "🏺";
                else if (c.getCategoryId() == 2) icon = "🪔";
                else if (c.getCategoryId() == 3) icon = "🪵";
                else if (c.getCategoryId() == 4) icon = "📜";
                else if (c.getCategoryId() == 5) icon = "📿";
            %>
                <label class="sidebar-check-item <%= isCatSelected ? "active" : "" %>">
                    <input type="radio" name="category" value="<%= c.getCategoryId() %>" 
                           class="sidebar-checkbox" 
                           <%= isCatSelected ? "checked" : "" %>
                           onchange="document.getElementById('sidebarFilterForm').submit()">
                    <span class="sidebar-check-text"><%= icon %> <%= c.getName() %></span>
                </label>
            <% }} %>
        </div>
    </div>

    <% if ((keyword != null && !keyword.trim().isEmpty()) || selectedCategory != null || !"all".equalsIgnoreCase(selectedStatus)) { %>
        <div style="text-align: center; margin-top: 4px;">
            <a href="<%= ctx %>/catalogue" class="sidebar-btn-reset">✕ Xóa tất cả bộ lọc</a>
        </div>
    <% } %>
</form>
