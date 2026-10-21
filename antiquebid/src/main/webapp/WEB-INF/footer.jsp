<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String extraJs = request.getParameter("extraJs");
    if (extraJs == null || extraJs.trim().isEmpty()) {
        extraJs = (String) request.getAttribute("extraJs");
    }
    String hideFooter = request.getParameter("hideFooter");
    if (hideFooter == null || hideFooter.trim().isEmpty()) {
        hideFooter = (String) request.getAttribute("hideFooter");
    }
    String ctx = request.getContextPath();
%>
    <% if (!"true".equalsIgnoreCase(hideFooter)) { %>
    <footer class="footer">
        <div class="container">
            <div class="footer-bottom">
                <p>© 2026 AntiqueBid - Hệ thống thông tin quản lý sàn đấu giá cổ vật trực tuyến.</p>
            </div>
        </div>
    </footer>
    <% } %>

    <!-- Script hệ thống cốt lõi: Đồng hồ hệ thống + Đồng hồ đếm ngược tự động toàn sàn -->
    <script src="<%= ctx %>/assets/js/core.js?v=4"></script>

    <!-- Script bổ sung theo từng trang (nếu có) -->
    <% if (extraJs != null && !extraJs.trim().isEmpty()) { %>
        <script src="<%= ctx %>/assets/js/<%= extraJs %>"></script>
    <% } %>
</body>
</html>
