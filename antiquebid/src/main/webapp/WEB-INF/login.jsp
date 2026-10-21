<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Đăng nhập hệ thống | AntiqueBid" />
    <jsp:param name="extraCss" value="login.css" />
</jsp:include>

    <div class="auth-wrapper">
        <div class="card auth-card">
            <div class="auth-header">
                <img src="<%= request.getContextPath() %>/assets/images/logo.svg" alt="AntiqueBid" class="auth-logo-img">
                <h2 class="auth-title">Đăng Nhập Sàn Đấu Giá</h2>
                <p class="auth-subtitle">Hệ thống giao dịch & đấu giá cổ vật AntiqueBid</p>
            </div>

            <% String err = (String) request.getAttribute("errorMessage"); %>
            <% if (err != null) { %>
                <div class="alert alert-danger"><%= err %></div>
            <% } %>

            <% String msg = request.getParameter("msg"); %>
            <% if ("reg_success".equals(msg)) { %>
                <div class="alert alert-success">Đăng ký tài khoản thành công! Vui lòng đăng nhập.</div>
            <% } else if ("logged_out".equals(msg)) { %>
                <div class="alert alert-info">Bạn đã đăng xuất an toàn khỏi hệ thống.</div>
            <% } %>

            <form action="<%= request.getContextPath() %>/login" method="POST">
                <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") != null ? request.getParameter("redirect") : "" %>">
                
                <div class="form-group">
                    <label class="form-label">Địa chỉ Email</label>
                    <input type="email" name="email" class="form-control" placeholder="vidu@antiquebid.vn" required autofocus>
                </div>

                <div class="form-group">
                    <div class="d-flex justify-between align-center mb-1">
                        <label class="form-label mb-0">Mật khẩu</label>
                        <a href="#" class="text-xs text-gold">Quên mật khẩu?</a>
                    </div>
                    <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-gold btn-block btn-lg mt-2">
                    Đăng Nhập Hệ Thống
                </button>
            </form>

            <div class="auth-form-footer">
                Chưa có tài khoản tham gia đấu giá? 
                <a href="<%= request.getContextPath() %>/register">Đăng ký ngay</a>
            </div>


        </div>
    </div>

<jsp:include page="/WEB-INF/footer.jsp" />
