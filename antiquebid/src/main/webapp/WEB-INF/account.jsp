<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.User" %>
<%@ page import="com.huyen.antiquebid.model.VerificationDocument" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    User user = (User) request.getAttribute("user");
    VerificationDocument userDoc = (VerificationDocument) request.getAttribute("userDoc");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Hồ sơ cá nhân | Cổ Vật Đường" />
    <jsp:param name="extraCss" value="account.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-container medium">
            <div class="user-page-header">
                <h1 class="user-page-title">👤 Quản Lý Tài Khoản Cá Nhân</h1>
                <p class="user-page-subtitle">Cập nhật thông tin định danh và địa chỉ giao hàng nhận cổ vật</p>
            </div>

            <% String success = (String) request.getAttribute("successMessage"); %>
            <% if (success != null) { %>
                <div class="alert alert-success"><%= success %></div>
            <% } %>

            <% String error = (String) request.getAttribute("errorMessage"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger"><%= error %></div>
            <% } %>

            <div class="grid-2 gap-4">
                <!-- Left: Form -->
                <div class="user-card">
                    <h3 class="user-card-title">
                        Thông tin cá nhân
                    </h3>
                    <form action="<%= ctx %>/account" method="POST">
                        <div class="form-group">
                            <label class="form-label">Email tài khoản (không thể đổi)</label>
                            <input type="text" class="form-control disabled-bg" value="<%= user.getEmail() %>" disabled>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Họ và tên thật</label>
                            <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label d-flex justify-between">
                                <span>Số Căn cước công dân (CCCD 12 số)</span>
                                <% if ("VERIFIED".equalsIgnoreCase(user.getKycStatus())) { %>
                                    <span class="text-xs color-success fw-bold">✓ ĐÃ XÁC THỰC</span>
                                <% } else if ("PENDING".equalsIgnoreCase(user.getKycStatus())) { %>
                                    <span class="text-xs color-warning fw-bold">⏳ CHỜ DUYỆT</span>
                                <% } else { %>
                                    <a href="<%= ctx %>/kyc" class="text-xs color-gold fw-bold">Xác minh ngay →</a>
                                <% } %>
                            </label>
                            <% if (user.getCitizenId() != null && !user.getCitizenId().trim().isEmpty()) { %>
                                <input type="text" class="form-control disabled-bg fw-bold cccd-code-pill" value="<%= user.getCitizenId() %>" disabled>
                                <small class="text-xs color-muted mt-1 d-block">Mã định danh công dân điện tử đã được xác thực</small>
                            <% } else { %>
                                <input type="text" class="form-control disabled-bg" value="Chưa xác thực CCCD" disabled>
                                <small class="text-xs color-warning mt-1 d-block">⚠️ Quý khách cần xác thực CCCD gắn chip để tham gia trả giá</small>
                            <% } %>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Số điện thoại liên lạc</label>
                            <input type="text" name="phone" class="form-control" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Địa chỉ giao hàng nhận hiện vật</label>
                            <textarea name="shippingAddress" class="form-control" rows="3"><%= user.getShippingAddress() != null ? user.getShippingAddress() : "" %></textarea>
                        </div>

                        <button type="submit" class="btn btn-gold w-100">
                            Lưu Cập Nhật Thông Tin
                        </button>
                    </form>
                </div>

                <!-- Right: Status Cards -->
                <div>
                    <!-- KYC Status Card -->
                    <div class="user-card mb-3 user-card-highlight">
                        <h3 class="user-card-title">🪪 Định Danh Căn Cước Công Dân (CCCD)</h3>
                        <div class="mb-3">
                            <% if ("VERIFIED".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-verified kyc-status-pill">
                                    ✓ ĐÃ XÁC THỰC CCCD GẮN CHIP
                                </span>
                                <p class="text-sm color-success mt-2">
                                    Tài khoản đã hoàn tất định danh công dân điện tử, có đủ thẩm quyền trả giá mọi cổ vật.
                                </p>

                                <div class="cccd-info-list">
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Số định danh CCCD:</span>
                                        <span class="cccd-code-pill"><%= user.getCitizenId() != null ? user.getCitizenId() : "—" %></span>
                                    </div>
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Cơ quan cấp:</span>
                                        <span class="cccd-info-val"><%= userDoc != null ? userDoc.getIssuePlace() : "Cục Cảnh sát QLHC về TTXH" %></span>
                                    </div>
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Ngày cấp:</span>
                                        <span class="cccd-info-val"><%= userDoc != null && userDoc.getIssueDate() != null ? FormatUtil.formatDate(userDoc.getIssueDate()) : "10/05/2021" %></span>
                                    </div>
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Hình thức xác minh:</span>
                                        <span class="cccd-info-val">Căn cước công dân gắn chip (12 số)</span>
                                    </div>
                                </div>

                                <div class="cccd-gallery-title">
                                    📷 Ảnh thẻ CCCD gắn chip đã lưu trữ:
                                </div>
                                <div class="cccd-cards-grid">
                                    <div class="cccd-card-item">
                                        <a href="<%= ctx %>/<%= userDoc != null ? userDoc.getFileUrl() : "assets/images/sample_cccd_front.svg" %>" target="_blank" title="Xem ảnh gốc">
                                            <img src="<%= ctx %>/<%= userDoc != null ? userDoc.getFileUrl() : "assets/images/sample_cccd_front.svg" %>"
                                                 alt="Mặt trước CCCD" class="cccd-card-thumb"
                                                 onerror="this.src='<%= ctx %>/assets/images/sample_cccd_front.svg'">
                                        </a>
                                        <div class="cccd-card-caption">Mặt trước thẻ CCCD</div>
                                    </div>
                                    <div class="cccd-card-item">
                                        <a href="<%= ctx %>/<%= userDoc != null ? userDoc.getFileUrlBack() : "assets/images/sample_cccd_back.svg" %>" target="_blank" title="Xem ảnh gốc">
                                            <img src="<%= ctx %>/<%= userDoc != null ? userDoc.getFileUrlBack() : "assets/images/sample_cccd_back.svg" %>"
                                                 alt="Mặt sau CCCD" class="cccd-card-thumb"
                                                 onerror="this.src='<%= ctx %>/assets/images/sample_cccd_back.svg'">
                                        </a>
                                        <div class="cccd-card-caption">Mặt sau (chip điện tử)</div>
                                    </div>
                                </div>

                            <% } else if ("PENDING".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-pending kyc-status-pill">
                                    ⏳ ĐANG CHỜ PHÊ DUYỆT CCCD
                                </span>
                                <p class="text-sm color-warning mt-2">
                                    Hồ sơ CCCD của quý khách đang được hội đồng quản trị sàn kiểm tra đối chiếu trong vòng 24h.
                                </p>
                                <div class="cccd-info-list">
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Số CCCD nộp:</span>
                                        <span class="cccd-code-pill"><%= userDoc != null && userDoc.getCitizenId() != null ? userDoc.getCitizenId() : (user.getCitizenId() != null ? user.getCitizenId() : "—") %></span>
                                    </div>
                                    <div class="cccd-info-row">
                                        <span class="cccd-info-label">Thời điểm nộp:</span>
                                        <span class="cccd-info-val"><%= userDoc != null ? FormatUtil.formatDateTime(userDoc.getSubmittedAt()) : "Vừa nộp" %></span>
                                    </div>
                                </div>
                                <a href="<%= ctx %>/kyc" class="btn btn-sm btn-outline w-100">Xem Chi Tiết Hồ Sơ Đã Nộp</a>

                            <% } else if ("REJECTED".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-danger kyc-status-pill">
                                    ✕ HỒ SƠ CCCD BỊ TỪ CHỐI
                                </span>
                                <p class="text-sm color-danger mt-2">
                                    <%= userDoc != null && userDoc.getReviewNote() != null ? userDoc.getReviewNote() : "Ảnh CCCD mờ hoặc thông tin không trùng khớp. Vui lòng chụp lại rõ nét." %>
                                </p>
                                <a href="<%= ctx %>/kyc" class="btn btn-sm btn-gold mt-2 w-100">
                                    Nộp Lại Hồ Sơ CCCD Mới
                                </a>

                            <% } else { %>
                                <span class="badge badge-warning kyc-status-pill">
                                    ⚠️ CHƯA XÁC MINH CCCD
                                </span>
                                <p class="text-sm color-muted mt-2">
                                    Sàn Cổ Vật Đường quy định bắt buộc xác thực duy nhất qua <strong>Căn cước công dân gắn chip (CCCD 12 số)</strong> để đảm bảo an toàn giao dịch đấu giá.
                                </p>
                                <a href="<%= ctx %>/kyc" class="btn btn-sm btn-gold mt-3 w-100">
                                    🪪 Xác Minh Qua CCCD Ngay
                                </a>
                            <% } %>
                        </div>
                    </div>

                    <!-- Rule & Violations Card -->
                    <div class="user-card">
                        <h3 class="user-card-title">⚖️ Điểm Uy Tín & Vi Phạm</h3>
                        <div class="reputation-stat-box">
                            Số lần vi phạm quá hạn thanh toán: 
                            <strong class="reputation-score <%= user.getViolationCount() > 0 ? "score-violated" : "score-clean" %>">
                                <%= user.getViolationCount() %> / 3 lần
                            </strong>
                        </div>
                        <p class="text-muted-sm line-relaxed">
                            Quy chế sàn: Nếu khách trúng đấu giá quá 48h không hoàn tất thanh toán, số lần vi phạm tăng 1. Khi đạt ngưỡng 3 lần, tài khoản sẽ tự động bị đình chỉ quyền đấu giá vĩnh viễn.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
