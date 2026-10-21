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
    <jsp:param name="pageTitle" value="Xác minh CCCD gắn chip | Cổ Vật Đường" />
    <jsp:param name="extraCss" value="kyc.css" />
</jsp:include>

    <main class="container user-page-container">
        <div class="user-page-container narrow">
            <div class="user-page-header">
                <a href="<%= ctx %>/account" class="back-link">← Quay lại trang hồ sơ</a>
                <h1 class="user-page-title">🪪 Xác Thực Căn Cước Công Dân (CCCD)</h1>
                <p class="user-page-subtitle">
                    Quy chế sàn: Quý khách cần xác thực danh tính duy nhất qua <strong>Căn cước công dân gắn chip (12 số)</strong> để kích hoạt thẩm quyền đặt giá trong các phiên đấu giá cổ vật.
                </p>
            </div>

            <% String success = (String) request.getAttribute("successMessage"); %>
            <% if (success != null) { %>
                <div class="alert alert-success"><%= success %></div>
            <% } %>

            <% String error = (String) request.getAttribute("errorMessage"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger"><%= error %></div>
            <% } %>

            <!-- Current Status Box -->
            <div class="user-card user-card-highlight">
                <div class="d-flex justify-between align-center">
                    <div>
                        <span class="price-label">Trạng thái định danh CCCD:</span>
                        <div class="mt-1">
                            <% if ("VERIFIED".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-verified kyc-status-pill">
                                    ✓ ĐÃ XÁC THỰC CCCD THÀNH CÔNG
                                </span>
                            <% } else if ("PENDING".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-pending kyc-status-pill">
                                    ⏳ HỒ SƠ ĐANG CHỜ DUYỆT (PENDING)
                                </span>
                            <% } else if ("REJECTED".equalsIgnoreCase(user.getKycStatus())) { %>
                                <span class="badge badge-danger kyc-status-pill">
                                    ✕ HỒ SƠ CCCD BỊ TỪ CHỐI (REJECTED)
                                </span>
                            <% } else { %>
                                <span class="badge badge-warning kyc-status-pill">
                                    ⚠️ CHƯA NỘP HỒ SƠ CCCD
                                </span>
                            <% } %>
                        </div>
                    </div>
                    <% if (userDoc != null) { %>
                        <div class="text-right text-xs color-muted">
                            Thời điểm nộp: <strong><%= FormatUtil.formatDateTime(userDoc.getSubmittedAt()) %></strong><br>
                            Số CCCD: <strong class="color-gold"><%= userDoc.getCitizenId() != null ? userDoc.getCitizenId() : (user.getCitizenId() != null ? user.getCitizenId() : "—") %></strong>
                        </div>
                    <% } %>
                </div>

                <% if (userDoc != null && userDoc.getReviewNote() != null && !userDoc.getReviewNote().isEmpty()) { %>
                    <div class="kyc-notice-box kyc-notice-danger mt-3">
                        <strong>Phản hồi từ quản trị viên:</strong> <%= userDoc.getReviewNote() %>
                    </div>
                <% } %>
            </div>

            <!-- KYC Submission Form -->
            <% if (!"VERIFIED".equalsIgnoreCase(user.getKycStatus())) { %>
                <div class="user-card">
                    <h3 class="user-card-title">Hồ sơ Căn cước công dân gắn chip (CCCD)</h3>

                    <form action="<%= ctx %>/kyc" method="POST">
                        <input type="hidden" name="docType" value="CITIZEN_ID">

                        <!-- Document Type Notification (Fixed to CCCD only) -->
                        <div class="form-group">
                            <label class="form-label">Phương thức xác minh pháp lý (*)</label>
                            <div class="cccd-fixed-type">
                                <div class="cccd-chip-icon">CHIP</div>
                                <div>
                                    <strong class="color-primary">Căn cước công dân gắn chip (CCCD 12 chữ số)</strong>
                                    <div class="text-xs color-muted">Hệ thống áp dụng chuẩn xác thực duy nhất theo quy định định danh cá nhân Việt Nam</div>
                                </div>
                            </div>
                        </div>

                        <!-- Full Name (Matched with User) -->
                        <div class="form-group">
                            <label class="form-label">Họ và tên chủ thẻ (*)</label>
                            <input type="text" class="form-control disabled-bg" value="<%= user.getFullName() %>" disabled>
                            <small class="text-xs color-muted mt-1 d-block">
                                Họ tên trên CCCD bắt buộc phải trùng khớp với tên tài khoản để duyệt xác minh.
                            </small>
                        </div>

                        <div class="grid-2 gap-3">
                            <!-- Citizen ID (12 digits) -->
                            <div class="form-group">
                                <label class="form-label">Số Căn cước công dân (12 số) (*)</label>
                                <input type="text" name="citizenId" class="form-control" 
                                       placeholder="Ví dụ: 001202000017" 
                                       pattern="\d{12}" 
                                       maxlength="12" 
                                       value="<%= userDoc != null && userDoc.getCitizenId() != null ? userDoc.getCitizenId() : (user.getCitizenId() != null ? user.getCitizenId() : "") %>" 
                                       required>
                                <small class="text-xs color-muted mt-1 d-block">Nhập đủ 12 chữ số theo thẻ CCCD gắn chip</small>
                            </div>

                            <!-- Issue Date -->
                            <div class="form-group">
                                <label class="form-label">Ngày cấp thẻ CCCD (*)</label>
                                <input type="date" name="issueDate" class="form-control" 
                                       value="<%= userDoc != null && userDoc.getIssueDate() != null ? userDoc.getIssueDate().toString() : "2021-05-10" %>" 
                                       required>
                                <small class="text-xs color-muted mt-1 d-block">Mặt sau thẻ CCCD (Date, month, year)</small>
                            </div>
                        </div>

                        <!-- Issuing Authority -->
                        <div class="form-group">
                            <label class="form-label">Nơi cấp (*)</label>
                            <input type="text" name="issuePlace" class="form-control" 
                                   value="<%= userDoc != null && userDoc.getIssuePlace() != null ? userDoc.getIssuePlace() : "Cục Cảnh sát QLHC về TTXH" %>" 
                                   required>
                        </div>

                        <!-- CCCD Photos (Front and Back) -->
                        <div class="form-group mt-3">
                            <label class="form-label">Ảnh chụp thẻ CCCD gắn chip (2 mặt) (*)</label>
                            
                            <div class="cccd-upload-grid">
                                <!-- Front side -->
                                <div class="cccd-upload-card">
                                    <div class="text-xs fw-bold color-primary mb-2">MẶT TRƯỚC CCCD</div>
                                    <img id="previewFront" 
                                         src="<%= ctx %>/<%= userDoc != null && userDoc.getFileUrl() != null ? userDoc.getFileUrl() : "assets/images/sample_cccd_front.svg" %>" 
                                         alt="Mặt trước CCCD" class="cccd-upload-preview"
                                         onerror="this.src='<%= ctx %>/assets/images/sample_cccd_front.svg'">
                                    <input type="text" name="fileUrl" class="form-control text-xs" 
                                           value="<%= userDoc != null && userDoc.getFileUrl() != null ? userDoc.getFileUrl() : "assets/images/sample_cccd_front.svg" %>" 
                                           placeholder="Tệp ảnh mặt trước">
                                </div>

                                <!-- Back side -->
                                <div class="cccd-upload-card">
                                    <div class="text-xs fw-bold color-primary mb-2">MẶT SAU (GẮN CHIP)</div>
                                    <img id="previewBack" 
                                         src="<%= ctx %>/<%= userDoc != null && userDoc.getFileUrlBack() != null ? userDoc.getFileUrlBack() : "assets/images/sample_cccd_back.svg" %>" 
                                         alt="Mặt sau CCCD" class="cccd-upload-preview"
                                         onerror="this.src='<%= ctx %>/assets/images/sample_cccd_back.svg'">
                                    <input type="text" name="fileUrlBack" class="form-control text-xs" 
                                           value="<%= userDoc != null && userDoc.getFileUrlBack() != null ? userDoc.getFileUrlBack() : "assets/images/sample_cccd_back.svg" %>" 
                                           placeholder="Tệp ảnh mặt sau">
                                </div>
                            </div>
                        </div>

                        <!-- CCCD Standard Rules Box -->
                        <div class="cccd-rules-box">
                            <div class="cccd-rules-title">
                                📋 Yêu cầu quy chuẩn ảnh chụp CCCD:
                            </div>
                            <ul class="cccd-rules-list">
                                <li>Chụp thẳng, vuông góc trên mặt phẳng, thấy rõ toàn bộ 4 góc thẻ.</li>
                                <li>Không bị chói lóa ánh sáng đèn hoặc mất nét thông tin số định danh.</li>
                                <li>Mặt sau phải nhìn rõ chip điện tử màu vàng và 3 dòng mã quét MRZ.</li>
                                <li>Thẻ CCCD còn hạn sử dụng hợp pháp theo quy định của Bộ Công an.</li>
                            </ul>
                        </div>

                        <div class="kyc-notice-box kyc-notice-neutral my-3">
                            🔒 <strong>Bảo mật tuyệt đối:</strong> Thông tin Căn cước công dân chỉ được sử dụng cho mục đích định danh chủ thể pháp lý giao dịch đấu giá cổ vật theo quy định sàn và pháp luật hiện hành.
                        </div>

                        <button type="submit" class="btn btn-gold btn-lg w-100">
                            Xác Nhận & Gửi Hồ Sơ Xác Minh CCCD
                        </button>
                    </form>
                </div>
            <% } else { %>
                <div class="user-card user-empty-state">
                    <div class="user-empty-icon color-success">✓</div>
                    <h3 class="user-empty-title">Định danh Căn cước công dân thành công</h3>
                    <p class="user-empty-desc">
                        Số CCCD: <strong class="color-gold"><%= user.getCitizenId() != null ? user.getCitizenId() : "—" %></strong><br>
                        Tài khoản đã được cấp thẩm quyền tham gia đấu giá toàn bộ cổ vật độc bản trên sàn.
                    </p>
                    <div class="d-flex justify-center gap-2 mt-3">
                        <a href="<%= ctx %>/account" class="btn btn-outline">Xem Hồ Sơ Cá Nhân</a>
                        <a href="<%= ctx %>/catalogue" class="btn btn-gold">Tham Gia Đấu Giá Ngay</a>
                    </div>
                </div>
            <% } %>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
