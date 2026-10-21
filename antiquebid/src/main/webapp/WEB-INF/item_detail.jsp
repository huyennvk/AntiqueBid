<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.model.AppraisalCertificate" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%
    AntiqueItem item = (AntiqueItem) request.getAttribute("item");
    AppraisalCertificate cert = (AppraisalCertificate) request.getAttribute("certificate");
    Auction relatedAuction = (Auction) request.getAttribute("relatedAuction");
    Boolean isWatched = (Boolean) request.getAttribute("isWatched");
    String ctx = request.getContextPath();
    String itemTitle = (item != null && item.getName() != null) ? (item.getName() + " | Cổ Vật Đường") : "Chi tiết hiện vật | Cổ Vật Đường";
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= itemTitle %>' />
    <jsp:param name="extraCss" value="item_detail.css" />
</jsp:include>

    <main class="container item-detail-main">
        <!-- Breadcrumb -->
        <div class="item-breadcrumb">
            <a href="<%= ctx %>/catalogue">Danh mục cổ vật</a> &gt; 
            <a href="<%= ctx %>/catalogue?category=<%= item.getCategoryId() %>"><%= item.getCategoryName() %></a> &gt; 
            <span class="item-breadcrumb-current"><%= item.getName() %></span>
        </div>

        <div class="item-detail-grid">
            <!-- Cột Trái: Ảnh hiện vật & Banner đấu giá -->
            <div>
                <div class="item-photo-card">
                    <%
                        long itemId = item.getItemId();
                        long imgNum = ((itemId - 1) % 5) + 1;
                        String fallbackImg = ctx + "/assets/images/item_" + imgNum + ".jpg";
                        String actualImg = (item.getPrimaryImageUrl() != null && !item.getPrimaryImageUrl().trim().isEmpty()) 
                                           ? (ctx + (item.getPrimaryImageUrl().startsWith("/") ? "" : "/") + item.getPrimaryImageUrl() + "?v=ai") 
                                           : fallbackImg;
                    %>
                    <img src="<%= actualImg %>" alt="<%= item.getName() %>" class="item-photo-img" onerror="this.onerror=null; this.src='<%= fallbackImg %>';">
                </div>

                <!-- Banner Đấu Giá Trực Tiếp (nếu có) -->
                <% if (relatedAuction != null && relatedAuction.isLive()) { %>
                    <div class="auction-live-banner">
                        <div class="auction-live-header">
                            <span class="badge badge-live">
                                <span class="badge-pulse"></span> PHIÊN ĐẤU GIÁ ĐANG DIỄN RA
                            </span>
                            <span class="auction-live-timer">
                                ⏱️ Còn: <strong data-countdown-end="<%= relatedAuction.getEndTime() != null ? relatedAuction.getEndTime().getTime() : 0 %>"><%= FormatUtil.formatRemainingTime(relatedAuction.getEndTime()) %></strong>
                            </span>
                        </div>
                        <div class="auction-live-pricing">
                            <div>
                                <span class="price-label">Giá dẫn đầu:</span>
                                <div class="price-value"><%= FormatUtil.formatVND(relatedAuction.getCurrentHighestBid()) %></div>
                            </div>
                            <div class="text-muted text-sm text-right">
                                Bước giá: <%= FormatUtil.formatVND(relatedAuction.getMinBidIncrement()) %>
                            </div>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="<%= ctx %>/auction-room?id=<%= relatedAuction.getAuctionId() %>" class="btn btn-gold btn-lg flex-1">
                                ⚡ THAM GIA ĐẶT GIÁ TRỰC TIẾP
                            </a>
                            <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= relatedAuction.getAuctionId() %>&redirect=/item-detail?id=<%= item.getItemId() %>" 
                               class="btn <%= (isWatched != null && isWatched) ? "btn-outline-gold active" : "btn-dark" %> btn-lg" 
                               style="padding: 14px 20px; white-space: nowrap;"
                               title="<%= (isWatched != null && isWatched) ? "Bỏ theo dõi phiên này" : "Theo dõi phiên này" %>">
                                <%= (isWatched != null && isWatched) ? "★ Đã theo dõi" : "⭐ Theo dõi" %>
                            </a>
                        </div>
                    </div>
                <% } else if (relatedAuction != null && "SCHEDULED".equalsIgnoreCase(relatedAuction.getStatus())) { %>
                    <div class="auction-scheduled-banner">
                        <span class="badge badge-upcoming mb-2">PHIÊN ĐẤU GIÁ SẮP DIỄN RA</span>
                        <div class="text-sm mb-2">
                            Thời gian bắt đầu: <strong><%= FormatUtil.formatDateTime(relatedAuction.getStartTime()) %></strong>
                        </div>
                        <div class="text-sm mb-3">
                            Giá khởi điểm: <strong class="scheduled-price-val"><%= FormatUtil.formatVND(relatedAuction.getStartingPrice()) %></strong>
                        </div>
                        <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= relatedAuction.getAuctionId() %>&redirect=/item-detail?id=<%= item.getItemId() %>" 
                           class="btn <%= (isWatched != null && isWatched) ? "btn-outline-gold active" : "btn-dark" %> btn-block">
                            <%= (isWatched != null && isWatched) ? "★ Đang Trong Danh Sách Theo Dõi" : "⭐ Thêm Vào Danh Sách Theo Dõi" %>
                        </a>
                    </div>
                <% } %>
            </div>

            <!-- Cột Phải: Thông số hiện vật & Chứng thư giám định -->
            <div>
                <div class="item-meta-header">
                    <div class="item-badges-row">
                        <span class="badge badge-info"><%= item.getCategoryName() %></span>
                        <span class="badge badge-success"><%= item.getConditionDisplay() %></span>
                        <span class="badge badge-secondary"><%= item.getStatusDisplay() %></span>
                    </div>
                    <div class="item-code"><%= item.getItemCode() %></div>
                    <h1 class="item-title"><%= item.getName() %></h1>
                    <p class="item-desc-text">
                        <%= item.getDescription() %>
                    </p>
                </div>

                <!-- Bảng thông số kỹ thuật -->
                <div class="specs-card">
                    <h3 class="specs-card-title">
                        Thông Số Kỹ Thuật Hiện Vật
                    </h3>
                    <table class="table text-sm">
                        <tr>
                            <td class="specs-label">Niên đại lịch sử:</td>
                            <td><strong><%= item.getEraDisplay() %></strong></td>
                        </tr>
                        <tr>
                            <td class="specs-label">Chất liệu chế tác:</td>
                            <td><strong><%= item.getMaterial() %></strong></td>
                        </tr>
                        <tr>
                            <td class="specs-label">Kích thước hiện vật:</td>
                            <td><%= item.getDimensions() %></td>
                        </tr>
                        <tr>
                            <td class="specs-label">Tình trạng bảo tồn:</td>
                            <td><span class="badge badge-success"><%= item.getConditionDisplay() %></span></td>
                        </tr>
                        <tr>
                            <td class="specs-label">Tính độc bản:</td>
                            <td>Độc bản duy nhất (Unique Single Piece)</td>
                        </tr>
                    </table>
                </div>

                <!-- Chứng thư giám định độc bản -->
                <% if (cert != null && cert.isPassed()) { %>
                    <div class="cert-card">
                        <div class="cert-seal">
                            GIÁM ĐỊNH<br>
                            CHÍNH HÃNG<br>
                            ★ ĐẠT ★
                        </div>
                        <div class="cert-header-meta">
                            <div class="cert-tagline">
                                CHỨNG THƯ GIÁM ĐỊNH CỔ VẬT HOÀNG GIA
                            </div>
                            <div class="cert-authority text-xs color-muted font-bold">
                                <%= cert.getIssuingAuthority() %>
                            </div>
                            <div class="cert-no">
                                Số chứng thư: <strong><%= cert.getCertificateNo() %></strong>
                            </div>
                        </div>

                        <!-- PHẦN I: THÔNG TIN HIỆN VẬT -->
                        <div class="cert-section-block">
                            <div class="cert-section-head">
                                <span class="cert-sec-num">I</span> THÔNG TIN HIỆN VẬT & NHẬN DẠNG
                            </div>
                            <div class="cert-info-grid">
                                <div><span class="text-muted">Mã số hồ sơ:</span> <strong><%= item.getItemCode() %></strong></div>
                                <div><span class="text-muted">Kích thước:</span> <%= item.getDimensions() %></div>
                                <div><span class="text-muted">Tình trạng:</span> <span class="badge badge-success"><%= item.getConditionDisplay() %></span></div>
                                <div><span class="text-muted">Xác nhận niêm phong:</span> Đã gắn chíp mã hóa bảo mật</div>
                            </div>
                        </div>

                        <!-- PHẦN II: KẾT QUẢ PHÂN TÍCH CHUYÊN MÔN & TÍNH XÁC THỰC -->
                        <div class="cert-section-block">
                            <div class="cert-section-head">
                                <span class="cert-sec-num">II</span> KẾT QUẢ PHÂN TÍCH CHUYÊN MÔN & TÍNH XÁC THỰC
                            </div>
                            <div class="cert-info-grid mb-2">
                                <div><span class="text-muted">Niên đại:</span> <strong><%= item.getEraDisplay() %></strong></div>
                                <div><span class="text-muted">Chất liệu:</span> <strong><%= item.getMaterial() %></strong></div>
                            </div>
                            <div class="cert-authenticity-box">
                                <span class="cert-auth-label">Kết luận xác thực:</span>
                                <span class="cert-auth-badge">
                                    ★ <%= cert.getAuthenticityConclusion() %>
                                </span>
                            </div>
                            <% if (cert.getCulturalValue() != null && !cert.getCulturalValue().isEmpty()) { %>
                                <div class="cert-subtext mt-1">
                                    <span class="text-muted">Giá trị lịch sử - văn hóa:</span> <%= cert.getCulturalValue() %>
                                </div>
                            <% } %>
                        </div>

                        <!-- PHẦN III: CƠ SỞ KẾT LUẬN & PHƯƠNG PHÁP KỸ THUẬT -->
                        <div class="cert-section-block">
                            <div class="cert-section-head">
                                <span class="cert-sec-num">III</span> CƠ SỞ KẾT LUẬN (KHOA HỌC & THAM KHẢO ĐỐI CHIẾU)
                            </div>
                            <div class="cert-method-box">
                                <div class="mb-1">
                                    <strong>🔬 Phương pháp khoa học kỹ thuật:</strong><br>
                                    <span class="text-sm"><%= cert.getScientificMethod() %></span>
                                </div>
                                <div>
                                    <strong>📚 Tài liệu & Mẫu vật đối chiếu:</strong><br>
                                    <span class="text-sm"><%= cert.getReferenceMaterial() %></span>
                                </div>
                            </div>
                        </div>

                        <!-- PHẦN IV: GIÁ TRỊ ƯỚC TÍNH THẨM ĐỊNH (ESTIMATE RANGE) -->
                        <div class="cert-section-block">
                            <div class="cert-section-head">
                                <span class="cert-sec-num">IV</span> GIÁ TRỊ ƯỚC TÍNH THẨM ĐỊNH (ESTIMATE RANGE)
                            </div>
                            <div class="cert-grid mb-2">
                                <div class="cert-val-box">
                                    <div class="cert-val-title">Ước tính thấp (Estimate Low)</div>
                                    <div class="cert-val-price"><%= FormatUtil.formatVND(cert.getEstimateLow()) %></div>
                                </div>
                                <div class="cert-val-box">
                                    <div class="cert-val-title">Ước tính cao (Estimate High)</div>
                                    <div class="cert-val-price"><%= FormatUtil.formatVND(cert.getEstimateHigh()) %></div>
                                </div>
                            </div>

                            <% if (cert.getNote() != null && !cert.getNote().isEmpty()) { %>
                                <div class="cert-note-box">
                                    <div class="text-xs text-muted mb-1 font-bold">KẾT LUẬN HỘI ĐỒNG GIÁM ĐỊNH:</div>
                                    <div class="text-sm"><%= cert.getNote() %></div>
                                </div>
                            <% } %>

                            <div class="cert-signatures-row">
                                <div>
                                    <span>Chuyên gia giám định:</span><br>
                                    <strong><%= cert.getAppraiserName() != null ? cert.getAppraiserName() : "GS. Nguyễn Văn Thắng" %></strong>
                                    <div class="text-xs text-muted"><%= cert.getAppraiserTitle() %></div>
                                </div>
                                <div class="text-right">
                                    <span>Ngày lập chứng thư:</span><br>
                                    <strong><%= FormatUtil.formatDate(cert.getAppraisalDate()) %></strong>
                                    <div class="text-xs text-muted">Hiệu lực: <%= cert.isValid() ? "ĐANG CÓ HIỆU LỰC (VALID)" : "ĐÃ THU HỒI (REVOKED)" %></div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } else if (cert != null && !cert.isPassed()) { %>
                    <div class="alert alert-warning mt-3">
                        <strong>⚠️ Kết quả thẩm định:</strong> Hiện vật này có biên bản thẩm định <strong>KHÔNG ĐẠT (REJECTED)</strong>. Không đủ điều kiện cấp chứng thư cổ vật.
                    </div>
                <% } %>
            </div>
        </div>
    </main>

<jsp:include page="/WEB-INF/footer.jsp" />
