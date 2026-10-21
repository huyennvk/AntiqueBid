<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.model.AppraisalCertificate" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    request.setAttribute("activePage", "items");
    AntiqueItem item = (AntiqueItem) request.getAttribute("item");
    AppraisalCertificate cert = (AppraisalCertificate) request.getAttribute("certificate");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value="Biên bản giám định & Cấp chứng thư | Admin" />
    <jsp:param name="extraCss" value="admin_forms.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-form-container">
                <div class="user-page-header">
                    <div>
                        <a href="<%= ctx %>/admin/items" class="back-link">&larr; Quay lại danh sách hiện vật</a>
                    </div>
                    <h1 class="admin-header-title">🔍 Giám Định Hiện Vật & Cấp Chứng Thư</h1>
                    <p class="admin-header-desc">
                        Bản ghi giám định là bất biến. Kết quả PASSED sẽ cấp chứng thư VALID và cho phép niêm yết lên sàn.
                    </p>
                </div>

                <!-- Current item summary -->
                <div class="admin-summary-box d-flex gap-3 align-center">
                    <img src="<%= ctx %>/<%= item.getPrimaryImageUrl() %>" alt="" class="admin-table-thumb thumb-lg">
                    <div>
                        <div class="item-code text-xs"><%= item.getItemCode() %> • <%= item.getCategoryName() %></div>
                        <h3 class="card-title text-base my-1"><%= item.getName() %></h3>
                        <div class="text-sm color-muted">
                            Niên đại: <%= item.getEraDisplay() %> • Chất liệu: <%= item.getMaterial() %>
                        </div>
                    </div>
                </div>

                <div class="admin-form-card">
                    <form action="<%= ctx %>/admin/appraise" method="POST">
                        <input type="hidden" name="itemId" value="<%= item.getItemId() %>">

                        <!-- SECTION 1: KẾT QUẢ CHUYÊN MÔN & TÍNH XÁC THỰC -->
                        <h4 class="form-section-title text-sm color-gold font-bold mb-2 pb-1 border-bottom">
                            I. KẾT QUẢ PHÂN TÍCH CHUYÊN MÔN & TÍNH XÁC THỰC
                        </h4>
                        <div class="grid-2 gap-3 mb-3">
                            <div class="form-group">
                                <label class="form-label">Kết luận giám định (*)</label>
                                <select name="result" class="form-control font-bold" required>
                                    <option value="PASSED" class="color-success">✓ PASSED - Đạt chuẩn di sản (Cấp chứng thư VALID)</option>
                                    <option value="FAILED" class="color-danger">✕ FAILED - Không đạt chuẩn (Từ chối cấp chứng thư)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Xác nhận tính xác thực (*)</label>
                                <select name="authenticityConclusion" class="form-control font-bold" required>
                                    <option value="Cổ vật thật nguyên bản (Authentic Antique)" <%= cert != null && "Cổ vật thật nguyên bản (Authentic Antique)".equals(cert.getAuthenticityConclusion()) ? "selected" : "" %>>
                                        Cổ vật thật nguyên bản (Authentic Antique)
                                    </option>
                                    <option value="Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique)" <%= cert != null && "Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique)".equals(cert.getAuthenticityConclusion()) ? "selected" : "" %>>
                                        Cổ vật phục chế đạt chuẩn bảo tồn (Restored Antique)
                                    </option>
                                    <option value="Đồ phỏng cổ - Giả cổ (Reproduction / Imitation)" <%= cert != null && "Đồ phỏng cổ - Giả cổ (Reproduction / Imitation)".equals(cert.getAuthenticityConclusion()) ? "selected" : "" %>>
                                        Đồ phỏng cổ - Giả cổ (Reproduction / Imitation)
                                    </option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="form-label">Đánh giá giá trị lịch sử, văn hóa, mỹ thuật</label>
                            <input type="text" name="culturalValue" class="form-control" 
                                   value="<%= cert != null && cert.getCulturalValue() != null ? cert.getCulturalValue() : "Hiện vật phản ánh kỹ nghệ chế tác tinh hoa và giá trị di sản đặc sắc thời kỳ hoàng kim." %>" 
                                   placeholder="Ghi nhận giá trị văn hóa, niên đại nghệ thuật, biểu tượng...">
                        </div>

                        <!-- SECTION 2: CƠ SỞ KẾT LUẬN & PHƯƠNG PHÁP KỸ THUẬT -->
                        <h4 class="form-section-title text-sm color-gold font-bold mb-2 pb-1 border-bottom mt-3">
                            II. CƠ SỞ KẾT LUẬN (PHƯƠNG PHÁP KHOA HỌC & TƯ LIỆU THAM KHẢO)
                        </h4>
                        <div class="grid-2 gap-3 mb-3">
                            <div class="form-group">
                                <label class="form-label">Phương pháp khoa học, kỹ thuật đã sử dụng (*)</label>
                                <textarea name="scientificMethod" class="form-control" rows="2" required 
                                          placeholder="Quang phổ huỳnh quang tia X (XRF), soi kính hiển vi quang học, phân tích độ suy biến patina..."><%= cert != null && cert.getScientificMethod() != null ? cert.getScientificMethod() : "Phân tích quang phổ huỳnh quang tia X (XRF) cốt vật liệu; soi kính hiển vi quang học kiểm tra vi vết nứt men và bọt khí tầng sâu." %></textarea>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Tư liệu thư tịch & Mẫu vật đối chiếu (*)</label>
                                <textarea name="referenceMaterial" class="form-control" rows="2" required 
                                          placeholder="Hồ sơ hiện vật Bảo tàng Lịch sử Quốc gia, thư tịch cổ triều Nguyễn..."><%= cert != null && cert.getReferenceMaterial() != null ? cert.getReferenceMaterial() : "Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu vật lưu trữ tại Viện Khảo Cổ." %></textarea>
                            </div>
                        </div>

                        <!-- SECTION 3: TÍNH PHÁP LÝ, CHUYÊN GIA & CON DẤU PHÁP NHÂN -->
                        <h4 class="form-section-title text-sm color-gold font-bold mb-2 pb-1 border-bottom mt-3">
                            III. TÍNH PHÁP LÝ (CHUYÊN GIA GIÁM ĐỊNH & CON DẤU PHÁP NHÂN)
                        </h4>
                        <div class="grid-2 gap-3 mb-3">
                            <div class="form-group">
                                <label class="form-label">Họ tên Chuyên gia giám định (*)</label>
                                <input type="text" name="appraiserName" class="form-control font-bold" 
                                       value="<%= cert != null && cert.getAppraiserName() != null ? cert.getAppraiserName() : "GS. Nguyễn Văn Thắng" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Chức danh & Mã số chứng chỉ hành nghề (*)</label>
                                <input type="text" name="appraiserTitle" class="form-control" 
                                       value="<%= cert != null && cert.getAppraiserTitle() != null ? cert.getAppraiserTitle() : "Chuyên gia Giám định Cổ vật Cấp Quốc gia - Thẻ GĐ-018/VCH" %>" required>
                            </div>
                        </div>

                        <div class="grid-3 gap-3 mb-3">
                            <div class="form-group">
                                <label class="form-label">Pháp nhân tổ chức giám định & Đóng dấu (*)</label>
                                <input type="text" name="issuingAuthority" class="form-control" 
                                       value="<%= cert != null && cert.getIssuingAuthority() != null ? cert.getIssuingAuthority() : "Hội Đồng Giám Định Di Sản Cổ Vật Đường & Viện Nghiên Cứu Di Sản Quốc Gia" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Số chứng thư độc bản (*)</label>
                                <input type="text" name="certificateNo" class="form-control font-bold color-primary" 
                                       value="<%= cert != null && cert.getCertificateNo() != null ? cert.getCertificateNo() : "CT-2026-" + (item.getItemId() < 10 ? "00" + item.getItemId() : "0" + item.getItemId()) %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Ngày giám định (*)</label>
                                <input type="date" name="appraisalDate" class="form-control" 
                                       value="<%= cert != null && cert.getAppraisalDate() != null ? cert.getAppraisalDate() : "2026-10-20" %>" required>
                            </div>
                        </div>

                        <!-- SECTION 4: KHOẢNG GIÁ ƯỚC TÍNH THẨM ĐỊNH & BIÊN BẢN KẾT LUẬN -->
                        <h4 class="form-section-title text-sm color-gold font-bold mb-2 pb-1 border-bottom mt-3">
                            IV. KHOẢNG GIÁ ƯỚC TÍNH THẨM ĐỊNH (PRE-SALE ESTIMATE) & BIÊN BẢN KẾT LUẬN
                        </h4>
                        <p class="text-xs color-muted mb-2">
                            * Lưu ý nghiệp vụ: Khoảng ước tính này là định giá chuyên môn của hội đồng giám định, hoàn toàn độc lập với Giá khởi điểm và Giá sàn bí mật (Reserve Price) của phiên đấu giá.
                        </p>
                        <div class="grid-2 gap-3 mb-3">
                            <div class="form-group">
                                <label class="form-label">Khoảng ước tính: Mức thấp (Estimate Low - VNĐ)</label>
                                <input type="text" name="estimateLow" class="form-control font-bold" 
                                       value="<%= cert != null && cert.getEstimateLow() != null ? cert.getEstimateLow() : "50000000" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Khoảng ước tính: Mức cao (Estimate High - VNĐ)</label>
                                <input type="text" name="estimateHigh" class="form-control font-bold" 
                                       value="<%= cert != null && cert.getEstimateHigh() != null ? cert.getEstimateHigh() : "80000000" %>" required>
                            </div>
                        </div>

                        <div class="form-group mb-4">
                            <label class="form-label">Biên bản nhận xét chi tiết của giám định viên (*)</label>
                            <textarea name="note" class="form-control" rows="3" required placeholder="Ghi nhận phương pháp phân tích quang phổ men, vết gỉ đồng, chứng minh niên đại và kết cấu nguyên vẹn..."><%= cert != null && cert.getNote() != null ? cert.getNote() : "Hiện vật đạt chuẩn giám định chất lượng cao: Cốt vật liệu và hoa văn đồng nhất với niên đại công bố. Dấu vết thời gian tự nhiên, kết cấu bảo tồn tốt. Đủ điều kiện cấp chứng thư bảo chứng độc bản và niêm yết đấu giá công khai." %></textarea>
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-gold btn-lg flex-1 font-bold">
                                📜 Lưu Biên Bản & Cấp Chứng Thư (VALID)
                            </button>
                            <a href="<%= ctx %>/admin/items" class="btn btn-dark btn-lg">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
<jsp:include page="/WEB-INF/footer.jsp" />
