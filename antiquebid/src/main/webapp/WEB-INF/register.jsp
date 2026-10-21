<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Đăng ký tài khoản đấu giá | AntiqueBid" />
    <jsp:param name="extraCss" value="register.css" />
</jsp:include>

    <div class="auth-wrapper">
        <div class="card auth-card auth-card-wide">
            <div class="auth-header">
                <img src="<%= request.getContextPath() %>/assets/images/logo.svg" alt="AntiqueBid" class="auth-logo-img">
                <h2 class="auth-title">Đăng Ký Thành Viên Đấu Giá</h2>
                <p class="auth-subtitle">Trở thành nhà sưu tầm được xác thực tại AntiqueBid</p>
            </div>

            <% String err = (String) request.getAttribute("errorMessage"); %>
            <% if (err != null) { %>
                <div class="alert alert-danger"><%= err %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/register" method="POST">
                <div class="form-group">
                    <label class="form-label">Họ và tên thật (*)</label>
                    <input type="text" name="fullName" class="form-control" placeholder="Nguyễn Văn An" required>
                    <small class="text-muted text-xs">Bắt buộc trùng khớp với thẻ Căn cước công dân (CCCD gắn chip 12 số) để duyệt định danh.</small>
                </div>

                <div class="grid-2 gap-3">
                    <div class="form-group">
                        <label class="form-label">Email (*)</label>
                        <input type="email" name="email" class="form-control" placeholder="nguyenvanan@gmail.com" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại (*)</label>
                        <input type="tel" name="phone" class="form-control" placeholder="0912 345 678" required>
                    </div>
                </div>

                <div class="grid-2 gap-3">
                    <div class="form-group">
                        <label class="form-label">Mật khẩu (*)</label>
                        <input type="password" name="password" class="form-control" placeholder="Ít nhất 6 ký tự" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Xác nhận mật khẩu (*)</label>
                        <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                    </div>
                </div>

                <div class="text-xs text-muted mb-3">
                    <label class="d-flex align-center gap-2">
                        <input type="checkbox" required checked>
                        <span>Tôi cam kết tuân thủ quy chế đấu giá và hoàn tất hồ sơ xác minh KYC.</span>
                    </label>
                </div>

                <button type="submit" class="btn btn-gold btn-block btn-lg">
                    Tạo Tài Khoản & Bắt Đầu
                </button>
            </form>

            <div class="auth-form-footer">
                Đã có tài khoản? 
                <a href="<%= request.getContextPath() %>/login">Đăng nhập tại đây</a>
            </div>
        </div>
    </div>

<jsp:include page="/WEB-INF/footer.jsp" />
