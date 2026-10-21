<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.model.AppraisalCertificate" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="com.huyen.antiquebid.model.Bid" %>
<%@ page import="com.huyen.antiquebid.model.ItemImage" %>
<%@ page import="com.huyen.antiquebid.model.ProvenanceRecord" %>
<%@ page import="com.huyen.antiquebid.model.User" %>
<%@ page import="com.huyen.antiquebid.util.FormatUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    Auction auction = (Auction) request.getAttribute("auction");
    AntiqueItem item = (AntiqueItem) request.getAttribute("item");
    AppraisalCertificate cert = (AppraisalCertificate) request.getAttribute("certificate");
    ProvenanceRecord provenance = (ProvenanceRecord) request.getAttribute("provenance");
    List<ItemImage> images = (List<ItemImage>) request.getAttribute("images");
    List<Bid> bids = (List<Bid>) request.getAttribute("bids");
    Boolean isWatched = (Boolean) request.getAttribute("isWatched");
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    String ctx = request.getContextPath();
    String roomTitle = "Phòng đấu giá: " + (auction != null ? auction.getItemName() : "") + " | Cổ Vật Đường";

    long itemId = (auction != null && auction.getItemId() != null) ? auction.getItemId() : 1L;
    long imgNum = ((itemId - 1) % 5) + 1;
    String primaryFallback = ctx + "/assets/images/item_" + imgNum + ".jpg";
    String mainImgSrc = (auction != null && auction.getPrimaryImageUrl() != null 
                         && !auction.getPrimaryImageUrl().trim().isEmpty() 
                         && !auction.getPrimaryImageUrl().contains("/uploads/")) 
                        ? (ctx + (auction.getPrimaryImageUrl().startsWith("/") ? "" : "/") + auction.getPrimaryImageUrl()) 
                        : primaryFallback;

    // Danh sách các góc ảnh thực tế của hiện vật (Chính diện & Cận cảnh chi tiết)
    List<String[]> galleryImages = new ArrayList<>();
    if (images != null && !images.isEmpty()) {
        for (int idx = 0; idx < images.size(); idx++) {
            ItemImage imgObj = images.get(idx);
            String pth = imgObj.getFilePath();
            if (pth != null && !pth.trim().isEmpty()) {
                String fullPath = ctx + (pth.startsWith("/") ? "" : "/") + pth;
                String label = (idx == 0) ? "Góc chính diện" : 
                               (idx == 1) ? "Cận cảnh chi tiết" : ("Góc chụp " + (idx + 1));
                galleryImages.add(new String[]{fullPath, primaryFallback, label});
            }
        }
    }
    if (galleryImages.isEmpty()) {
        galleryImages.add(new String[]{mainImgSrc, primaryFallback, "Góc chính diện"});
    }

    // Thông tin Giám định & Chứng thư di sản chuẩn hóa
    String certNo = (cert != null && cert.getCertificateNo() != null && !cert.getCertificateNo().trim().isEmpty()) 
                    ? cert.getCertificateNo() 
                    : ("CT-2026-" + String.format("%03d", itemId));
    String appraiserName = (cert != null && cert.getAppraiserName() != null && !cert.getAppraiserName().trim().isEmpty())
                           ? cert.getAppraiserName()
                           : "GS. Nguyễn Văn Thắng";
    String appraiserTitle = (cert != null && cert.getAppraiserTitle() != null && !cert.getAppraiserTitle().trim().isEmpty())
                            ? cert.getAppraiserTitle()
                            : "Chuyên gia Giám định Cổ vật Cấp Quốc gia - Thẻ GĐ-018/VCH";
    String issuingAuthority = (cert != null && cert.getIssuingAuthority() != null && !cert.getIssuingAuthority().trim().isEmpty())
                              ? cert.getIssuingAuthority()
                              : "Hội Đồng Giám Định Di Sản Cổ Vật Đường & Viện Nghiên Cứu Di Sản Quốc Gia";
    String authConclusion = (cert != null && cert.getAuthenticityConclusion() != null && !cert.getAuthenticityConclusion().trim().isEmpty())
                            ? cert.getAuthenticityConclusion()
                            : "Cổ vật thật nguyên bản (Authentic Antique)";
    String culturalValue = (cert != null && cert.getCulturalValue() != null && !cert.getCulturalValue().trim().isEmpty())
                           ? cert.getCulturalValue()
                           : "Hiện vật tiêu biểu cho kỹ nghệ chế tác tinh hoa và giá trị di sản đặc sắc thời kỳ hoàng kim.";
    String scientificMethod = (cert != null && cert.getScientificMethod() != null && !cert.getScientificMethod().trim().isEmpty())
                              ? cert.getScientificMethod()
                              : "Phân tích quang phổ huỳnh quang tia X (XRF) cốt vật liệu; soi kính hiển vi kiểm tra mạng rạn men và cấu trúc vi thể tự nhiên.";
    String referenceMaterial = (cert != null && cert.getReferenceMaterial() != null && !cert.getReferenceMaterial().trim().isEmpty())
                               ? cert.getReferenceMaterial()
                               : "Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu vật lưu trữ tại Viện Khảo Cổ.";
    String appraisalDateStr = (cert != null && cert.getAppraisalDate() != null)
                              ? FormatUtil.formatDate(cert.getAppraisalDate())
                              : "15/08/2026";
    String estimateLowStr = (cert != null && cert.getEstimateLow() != null)
                            ? FormatUtil.formatVND(cert.getEstimateLow())
                            : (auction != null ? FormatUtil.formatVND(auction.getStartingPrice()) : "Đang cập nhật");
    String estimateHighStr = (cert != null && cert.getEstimateHigh() != null)
                             ? FormatUtil.formatVND(cert.getEstimateHigh())
                             : (auction != null ? FormatUtil.formatVND(auction.getStartingPrice().multiply(new java.math.BigDecimal("1.5"))) : "Đang cập nhật");
    String appraisalNote = (cert != null && cert.getNote() != null && !cert.getNote().trim().isEmpty())
                           ? cert.getNote()
                           : "Xác nhận hiện vật đạt chuẩn cổ vật nguyên bản, hoàn toàn nguyên vẹn về chất liệu và cấu trúc niên đại.";

    // Thông tin Nguồn gốc xuất xứ (Provenance)
    String originStr = (provenance != null && provenance.getOrigin() != null && !provenance.getOrigin().trim().isEmpty())
                       ? provenance.getOrigin()
                       : "Cố đô Huế (Việt Nam)";
    String sourceStr = (provenance != null && provenance.getAcquisitionSource() != null && !provenance.getAcquisitionSource().trim().isEmpty())
                       ? provenance.getAcquisitionSource()
                       : "Bộ sưu tập tư nhân quý tộc di sản";
    String rawOwnership = (provenance != null && provenance.getOwnershipHistory() != null && !provenance.getOwnershipHistory().trim().isEmpty())
                          ? provenance.getOwnershipHistory()
                          : "Di sản cung đình triều Nguyễn → Nhà sưu tập tư nhân Lê Hoàng → Giám định pháp lý & bàn giao Cổ Vật Đường";
    
    String[] historySteps = rawOwnership.contains("→") ? rawOwnership.split("→") : new String[]{rawOwnership};
    for (int i = 0; i < historySteps.length; i++) {
        historySteps[i] = historySteps[i].trim();
    }
    String docCode = (provenance != null && provenance.getSupportingDocuments() != null && !provenance.getSupportingDocuments().trim().isEmpty())
                     ? provenance.getSupportingDocuments()
                     : ("/docs/prov/hv" + String.format("%04d", itemId) + ".pdf");

    // Thông số hiện vật (Specs)
    String eraStr = (item != null) ? item.getEraDisplay() : "Thế kỷ 17";
    String materialStr = (item != null && item.getMaterial() != null) ? item.getMaterial() : "Đồng cổ";
    String dimensionsStr = (item != null && item.getDimensions() != null) ? item.getDimensions() : "Tiêu chuẩn hiện vật";
    String conditionStr = (item != null) ? item.getConditionDisplay() : "Nguyên vẹn";
    String itemDesc = (item != null && item.getDescription() != null) ? item.getDescription() : "";

    // Phân loại trạng thái phiên đấu giá
    boolean isScheduled = "SCHEDULED".equalsIgnoreCase(auction.getStatus());
    java.math.BigDecimal startPrice = auction.getStartingPrice();
    java.math.BigDecimal depositVal = startPrice.multiply(new java.math.BigDecimal("0.15"));

    long startMs = (auction.getStartTime() != null) ? auction.getStartTime().getTime() : (System.currentTimeMillis() + 86400000L);
    long regOpenMs = startMs - (7L * 24 * 3600 * 1000);
    long regCloseMs = startMs - (30L * 60 * 1000);
    java.sql.Timestamp regOpenTime = new java.sql.Timestamp(regOpenMs);
    java.sql.Timestamp regCloseTime = new java.sql.Timestamp(regCloseMs);
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= roomTitle %>' />
    <jsp:param name="extraCss" value="auction_room.css?v=lacviet" />
</jsp:include>

    <!-- Thanh tiêu đề phòng đấu giá -->
    <div class="auction-room-header">
        <div class="container auction-room-header-inner">
            <div class="auction-room-meta">
                <span class="badge <%= isScheduled ? "badge-upcoming" : "badge-live" %>">
                    <% if (!isScheduled) { %><span class="badge-pulse"></span><% } %>
                    <%= isScheduled ? "SẮP DIỄN RA" : auction.getStatusDisplay().toUpperCase() %>
                </span>
                <span class="item-code"><%= auction.getItemCode() %></span>
                <h2 class="auction-room-title"><%= auction.getItemName() %></h2>
            </div>
            <div>
                <a href="<%= ctx %>/watchlist-toggle?auctionId=<%= auction.getAuctionId() %>&redirect=/auction-room?id=<%= auction.getAuctionId() %>" 
                   class="btn btn-sm <%= (isWatched != null && isWatched) ? "btn-gold" : "btn-outline-gold" %>">
                    <%= (isWatched != null && isWatched) ? "★ Đang theo dõi" : "☆ Theo dõi phiên" %>
                </a>
            </div>
        </div>
    </div>

    <!-- Vùng nội dung chính (Chứa data attributes cho JavaScript realtime) -->
    <main class="container auction-room-main" id="auction-room-container"
          data-auction-id="<%= auction.getAuctionId() %>"
          data-remaining-seconds="<%= auction.getRemainingSeconds() %>"
          data-min-increment="<%= auction.getMinBidIncrement() %>"
          data-context-path="<%= ctx %>">

        <div class="auction-room-grid">
            <!-- Cột Trái: Ảnh sàn đấu, Gallery góc nhìn, Hồ sơ cổ vật (Giám định & Xuất xứ), Lịch sử trả giá -->
            <div>
                <!-- Khung hiển thị ảnh sân khấu chính -->
                <div class="item-stage-card">
                    <div class="item-stage-header">
                        <span class="badge badge-secondary">MÃ: <%= auction.getItemCode() %></span>
                        <span class="stage-angle-badge" id="stage-angle-title">Góc chính diện</span>
                    </div>
                    <img id="main-stage-img" src="<%= mainImgSrc %>" alt="<%= auction.getItemName() %>" class="item-stage-img" onerror="this.onerror=null; this.src='<%= primaryFallback %>';">
                </div>

                <!-- Thanh thumbnail các góc ảnh chụp khác (Gallery) -->
                <div class="stage-gallery-strip">
                    <% for (int i = 0; i < galleryImages.size(); i++) { 
                        String[] gImg = galleryImages.get(i);
                    %>
                        <div class="stage-thumb-wrapper" onclick="selectStageImage(this, '<%= gImg[0] %>', '<%= gImg[1] %>', '<%= gImg[2] %>')">
                            <img src="<%= gImg[0] %>" alt="<%= gImg[2] %>" class="stage-thumb <%= i == 0 ? "active" : "" %>" onerror="this.onerror=null; this.src='<%= gImg[1] %>';">
                            <span class="stage-thumb-label"><%= gImg[2] %></span>
                        </div>
                    <% } %>
                </div>

                <!-- Thẻ Hồ Sơ Cổ Vật: Mô tả tài sản - Chứng thư giám định - Nguồn gốc xuất xứ - Quy chế liên quan -->
                <div class="antique-dossier-card">
                    <div class="dossier-tabs-nav">
                        <button type="button" class="dossier-tab-btn <%= isScheduled ? "active" : "" %>" id="tab-btn-specs" onclick="switchDossierTab('specs')">
                            Mô tả tài sản
                        </button>
                        <button type="button" class="dossier-tab-btn <%= !isScheduled ? "active" : "" %>" id="tab-btn-cert" onclick="switchDossierTab('cert')">
                            Chứng thư giám định
                        </button>
                        <button type="button" class="dossier-tab-btn" id="tab-btn-provenance" onclick="switchDossierTab('provenance')">
                            Nguồn gốc xuất xứ
                        </button>
                        <button type="button" class="dossier-tab-btn" id="tab-btn-rules" onclick="switchDossierTab('rules')">
                            Tài liệu liên quan
                        </button>
                    </div>
                    <div class="dossier-tab-body">
                        <!-- TAB: THÔNG SỐ KỸ THUẬT & MÔ TẢ HIỆN VẬT -->
                        <div class="dossier-tab-pane <%= isScheduled ? "active" : "" %>" id="tab-pane-specs">
                            <table class="specs-table-room mb-3">
                                <tr>
                                    <td class="specs-label">Niên đại lịch sử:</td>
                                    <td><strong><%= eraStr %></strong></td>
                                </tr>
                                <tr>
                                    <td class="specs-label">Chất liệu chế tác:</td>
                                    <td><strong><%= materialStr %></strong></td>
                                </tr>
                                <tr>
                                    <td class="specs-label">Kích thước hiện vật:</td>
                                    <td><%= dimensionsStr %></td>
                                </tr>
                                <tr>
                                    <td class="specs-label">Tình trạng bảo tồn:</td>
                                    <td><span class="badge badge-success"><%= conditionStr %></span></td>
                                </tr>
                                <tr>
                                    <td class="specs-label">Tính độc bản:</td>
                                    <td>Độc bản duy nhất (Unique Single Piece)</td>
                                </tr>
                            </table>
                            <% if (itemDesc != null && !itemDesc.trim().isEmpty()) { %>
                                <div class="text-sm text-secondary p-3 bg-light rounded" style="line-height: 1.6;">
                                    <strong>Mô tả chi tiết:</strong> <%= itemDesc %>
                                </div>
                            <% } %>
                        </div>

                        <!-- TAB: CHỨNG THƯ GIÁM ĐỊNH HOÀNG GIA - TÓM TẮT GỌN GÀNG -->
                        <div class="dossier-tab-pane <%= !isScheduled ? "active" : "" %>" id="tab-pane-cert">
                            <div class="cert-summary-card">
                                <div class="cert-summary-top">
                                    <div class="cert-summary-badge">
                                        <span class="cert-auth-badge">★ <%= authConclusion %></span>
                                        <span class="badge badge-success ml-2">CHỨNG NHẬN HỢP LỆ (VALID)</span>
                                    </div>
                                    <div class="cert-summary-no">
                                        Số chứng thư: <strong><%= certNo %></strong>
                                    </div>
                                </div>

                                <div class="cert-summary-grid">
                                    <div class="cert-summary-item">
                                        <div class="cert-summary-label">Chuyên gia giám định:</div>
                                        <div class="cert-summary-val"><strong><%= appraiserName %></strong> (<%= appraisalDateStr %>)</div>
                                        <div class="text-xs text-muted"><%= issuingAuthority %></div>
                                    </div>
                                    <div class="cert-summary-item">
                                        <div class="cert-summary-label">Khoảng giá ước tính thẩm định (Pre-sale Estimate):</div>
                                        <div class="cert-summary-val cert-estimate-range">
                                            <strong><%= estimateLowStr %></strong> &mdash; <strong><%= estimateHighStr %></strong>
                                        </div>
                                        <div class="text-xs text-muted">Ước tính độc lập của chuyên gia (Khác với giá sàn bảo mật của phiên)</div>
                                    </div>
                                </div>

                                <div class="cert-summary-footer">
                                    <button type="button" class="btn btn-outline-gold btn-sm" onclick="openCertModal()">
                                        📜 Xem Toàn Văn Bản Chứng Thư Chi Tiết (Full Certificate Modal)
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- TAB: NGUỒN GỐC XUẤT XỨ (PROVENANCE) -->
                        <div class="dossier-tab-pane" id="tab-pane-provenance">
                            <div class="provenance-grid">
                                <div class="provenance-item">
                                    <div class="provenance-label">Vùng Đất / Xuất Xứ Địa Lý</div>
                                    <div class="provenance-val">📍 <%= originStr %></div>
                                </div>
                                <div class="provenance-item">
                                    <div class="provenance-label">Phương Thức & Nguồn Thu Thập</div>
                                    <div class="provenance-val">📜 <%= sourceStr %></div>
                                </div>
                            </div>

                            <div class="provenance-timeline-card">
                                <div class="provenance-timeline-title">Lịch Sử Lưu Lạc & Chuyển Nhượng Quyền Sở Hữu</div>
                                <div class="provenance-steps">
                                    <% for (String step : historySteps) { %>
                                        <div class="provenance-step"><%= step %></div>
                                    <% } %>
                                </div>
                            </div>

                            <div class="d-flex justify-between align-center flex-wrap gap-2">
                                <span class="provenance-docs-badge">
                                    ✓ Hồ sơ chứng từ pháp lý & biên bản bàn giao lưu trữ đầy đủ
                                </span>
                                <span class="text-xs text-muted">
                                    Mã lưu trữ: <strong><%= docCode %></strong>
                                </span>
                            </div>
                        </div>

                        <!-- TAB: TÀI LIỆU LIÊN QUAN & QUY CHẾ -->
                        <div class="dossier-tab-pane" id="tab-pane-rules">
                            <div class="specs-table-room mb-3 text-sm" style="line-height: 1.6;">
                                <div class="p-3 bg-light rounded mb-2">
                                    <strong>📜 Quy chế phiên đấu giá trực tuyến:</strong><br>
                                    Phiên đấu giá được tổ chức công khai, minh bạch theo Luật Đấu giá tài sản số 01/2016/QH14 và Quy chế hoạt động Sàn Đấu giá Cổ vật AntiqueBid.
                                </div>
                                <div class="p-3 bg-light rounded mb-2">
                                    <strong>🪪 Điều kiện tham gia:</strong><br>
                                    Người tham gia phải hoàn tất xác thực Căn cước công dân gắn chip (CCCD) và nộp tiền đặt trước đúng hạn quy định.
                                </div>
                                <div class="p-3 bg-light rounded">
                                    <strong>📁 Hồ sơ lưu trữ:</strong><br>
                                    Mã lưu trữ số hóa hồ sơ hiện vật: <strong><%= docCode %></strong> (Kèm biên bản hội đồng giám định di sản).
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bảng lịch sử đặt giá trực tuyến (chỉ hiển thị khi phiên đang diễn ra hoặc đã kết thúc) -->
                <% if (!isScheduled) { %>
                <div class="bid-history-card">
                    <div class="bid-history-header">
                        <h3 class="bid-history-title">📜 Lịch Sử Đặt Giá Trực Tuyến</h3>
                        <span class="badge badge-info" id="total-bids-badge"><%= auction.getTotalBids() %> lượt trả giá</span>
                    </div>

                    <div class="bid-history-scroll table-responsive">
                        <table class="table text-sm">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Người đấu giá</th>
                                    <th>Mức giá đặt</th>
                                    <th>Thời điểm</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody id="bid-history-tbody">
                                <% if (bids != null && !bids.isEmpty()) { 
                                    int idx = 1;
                                    for (Bid b : bids) { %>
                                    <tr class="<%= idx == 1 ? "highest-bid-row" : "" %>">
                                        <td><%= idx++ %></td>
                                        <td><strong><%= b.getMaskedBidderName() %></strong></td>
                                        <td class="price-value text-sm text-danger">
                                            <%= FormatUtil.formatVND(b.getBidAmount()) %>
                                        </td>
                                        <td class="text-muted text-xs">
                                            <%= FormatUtil.formatDateTime(b.getBidTime()) %>
                                        </td>
                                        <td><span class="badge badge-success">Hợp lệ</span></td>
                                    </tr>
                                <% }} else { %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted p-4">
                                            Chưa có lượt trả giá nào. Hãy là người đầu tiên ra giá!
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Cột Phải: Đồng hồ & Bảng điều khiển ra giá HOẶC Bảng thông tin phiên sắp diễn ra -->
            <div>
                <% if (isScheduled) { %>
                    <!-- Khung thông tin phiên sắp diễn ra theo chuẩn Đấu giá Lạc Việt -->
                    <div class="upcoming-info-card">
                        <!-- Đồng hồ đếm ngược bắt đầu trả giá -->
                        <div class="upcoming-cd-section">
                            <div class="upcoming-cd-title">Thời gian đếm ngược bắt đầu trả giá:</div>
                            <div class="upcoming-cd-boxes" id="upcoming-cd-timer" data-start-time="<%= auction.getStartTime() != null ? auction.getStartTime().getTime() : startMs %>">
                                <div class="upcoming-cd-box" id="uc-days-box" style="display: none;">
                                    <span class="upcoming-cd-val" id="uc-days">00</span>
                                    <span class="upcoming-cd-lbl">NGÀY</span>
                                </div>
                                <div class="upcoming-cd-box">
                                    <span class="upcoming-cd-val" id="uc-hours">00</span>
                                    <span class="upcoming-cd-lbl">GIỜ</span>
                                </div>
                                <div class="upcoming-cd-box">
                                    <span class="upcoming-cd-val" id="uc-mins">00</span>
                                    <span class="upcoming-cd-lbl">PHÚT</span>
                                </div>
                                <div class="upcoming-cd-box">
                                    <span class="upcoming-cd-val" id="uc-secs">00</span>
                                    <span class="upcoming-cd-lbl">GIÂY</span>
                                </div>
                            </div>
                        </div>

                        <!-- Bảng chi tiết thông số phiên đấu giá chuẩn Lạc Việt -->
                        <div class="upcoming-details-table">
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Giá khởi điểm:</div>
                                <div class="upcoming-row-val upcoming-val-price"><%= FormatUtil.formatVND(startPrice) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Mã tài sản:</div>
                                <div class="upcoming-row-val upcoming-val-code"><%= auction.getItemCode() %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Thời gian mở đăng ký:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatDateTime(regOpenTime) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Thời gian kết thúc đăng ký:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatDateTime(regCloseTime) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Phí đăng ký tham gia đấu giá:</div>
                                <div class="upcoming-row-val color-red">50.000 VNĐ</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Bước giá:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatVND(auction.getMinBidIncrement()) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Số bước giá tối đa/ lần trả:</div>
                                <div class="upcoming-row-val color-red">Bước giá không giới hạn</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Tiền đặt trước:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatVND(depositVal) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Phương thức đấu giá:</div>
                                <div class="upcoming-row-val color-red">Trả giá lên và liên tục</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Người có tài sản:</div>
                                <div class="upcoming-row-val color-red">Ban Quản Lý & Ủy Thác Sưu Tầm Cổ Vật AntiqueBid</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Nơi xem tài sản:</div>
                                <div class="upcoming-row-val color-red">Phòng Trưng Bày Triển Lãm Hoàng Gia AntiqueBid, Tầng 3 - Tòa Nhà Di Sản, Số 12 Tràng Tiền, Hoàn Kiếm, Hà Nội</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Thời gian xem tài sản:</div>
                                <div class="upcoming-row-val color-red">Giờ hành chính các ngày trước phiên đấu giá 03 ngày</div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Thời gian bắt đầu trả giá:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatDateTime(auction.getStartTime()) %></div>
                            </div>
                            <div class="upcoming-row">
                                <div class="upcoming-row-lbl">Thời gian kết thúc trả giá:</div>
                                <div class="upcoming-row-val color-red"><%= FormatUtil.formatDateTime(auction.getEndTime()) %></div>
                            </div>
                        </div>

                        <!-- Hàng thao tác Đăng ký / Xác minh & Nút chia sẻ -->
                        <div class="upcoming-actions-row">
                            <div class="flex-1">
                                <% if (currentUser == null) { %>
                                    <a href="<%= ctx %>/login?redirect=/auction-room?id=<%= auction.getAuctionId() %>" class="btn btn-upcoming-register">
                                        Đăng Ký Tham Gia Đấu Giá
                                    </a>
                                <% } else if (!"VERIFIED".equalsIgnoreCase(currentUser.getKycStatus())) { %>
                                    <a href="<%= ctx %>/kyc" class="btn btn-upcoming-register">
                                        🪪 Xác Minh CCCD Để Đăng Ký
                                    </a>
                                <% } else { %>
                                    <button type="button" class="btn btn-upcoming-registered" onclick="alert('Quý khách đã hoàn tất xác thực tài khoản qua CCCD gắn chip và đủ điều kiện tham gia trả giá khi phiên chính thức bắt đầu!');">
                                        ✓ Đã Đủ Điều Kiện Tham Gia Phiên
                                    </button>
                                <% } %>
                            </div>
                            <button type="button" class="btn-share-icon" onclick="copyAuctionLink()" title="Chia sẻ liên kết phiên đấu giá">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="18" cy="5" r="3"></circle>
                                    <circle cx="6" cy="12" r="3"></circle>
                                    <circle cx="18" cy="19" r="3"></circle>
                                    <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
                                    <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
                                </svg>
                            </button>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Đồng hồ đếm ngược phiên đang diễn ra -->
                    <div class="countdown-box">
                        <div class="countdown-label">
                            THỜI GIAN CÒN LẠI CỦA PHIÊN
                        </div>
                        <div class="countdown-digits" id="countdown-display">
                            <%= FormatUtil.formatRemainingTime(auction.getEndTime()) %>
                        </div>
                        <div class="countdown-footer">
                            Đồng hồ máy chủ chuẩn • Kết thúc lúc: <%= FormatUtil.formatDateTime(auction.getEndTime()) %>
                        </div>
                    </div>

                    <!-- Thông tin mức giá hiện tại -->
                    <div class="bidding-panel mb-4">
                        <div class="current-price-box d-flex justify-between align-baseline">
                            <div>
                                <span class="price-label">Giá dẫn đầu hiện tại:</span>
                                <div class="current-price-val" id="current-price-display">
                                    <%= FormatUtil.formatVND(auction.getCurrentHighestBid()) %>
                                </div>
                            </div>
                            <div class="text-right">
                                <span class="price-label">Người giữ giá cao nhất:</span>
                                <div id="highest-bidder-display" class="highest-bidder-info font-bold mt-1">
                                    <%= FormatUtil.maskName(auction.getHighestBidderName()) %>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-between text-sm text-secondary pt-2">
                            <span>Giá khởi điểm: <strong><%= FormatUtil.formatVND(auction.getStartingPrice()) %></strong></span>
                            <span>Bước giá: <strong><%= FormatUtil.formatVND(auction.getMinBidIncrement()) %></strong></span>
                        </div>
                    </div>

                    <!-- Bảng điều khiển đặt giá tương tác -->
                    <div class="bidding-panel">
                        <h3 class="font-bold text-base mb-3">⚡ Bảng Điều Khiển Đặt Giá</h3>

                        <% if (currentUser == null) { %>
                            <div class="alert alert-warning mb-3">
                                Bạn cần đăng nhập để tham gia đặt giá tại phòng này.
                            </div>
                            <a href="<%= ctx %>/login?redirect=/auction-room?id=<%= auction.getAuctionId() %>" class="btn btn-gold btn-block">
                                Đăng Nhập Để Đấu Giá
                            </a>
                        <% } else if (currentUser.isAdmin()) { %>
                            <div class="alert alert-danger mb-0">
                                ⛔ <strong>Tài khoản Quản trị:</strong> Admin là ban tổ chức điều hành sàn, không tham gia đặt giá.
                            </div>
                        <% } else if (!"VERIFIED".equalsIgnoreCase(currentUser.getKycStatus())) { %>
                            <div class="alert alert-warning mb-3">
                                ⚠️ <strong>Yêu cầu xác minh CCCD:</strong> Tài khoản của quý khách chưa hoàn tất xác thực Căn cước công dân gắn chip. Vui lòng hoàn thành để được cấp quyền đặt giá.
                            </div>
                            <a href="<%= ctx %>/kyc" class="btn btn-gold btn-block">
                                🪪 Xác Minh Qua CCCD Ngay
                            </a>
                        <% } else if (currentUser.isLocked()) { %>
                            <div class="alert alert-danger">
                                Tài khoản của bạn đã bị khóa quyền đấu giá do vi phạm quy chế.
                            </div>
                        <% } else { %>
                            <!-- Form đặt giá cho đấu giá viên hợp lệ -->
                            <form id="place-bid-form" class="custom-bid-form">
                                <div class="mb-3">
                                    <label class="form-label d-flex justify-between">
                                        <span>Mức giá đặt tiếp theo tối thiểu:</span>
                                        <strong id="next-min-price-display" class="text-danger">
                                            <%= FormatUtil.formatVND(auction.getNextMinimumBid()) %>
                                        </strong>
                                    </label>
                                    <input type="text" id="custom-bid-input" class="form-control text-right font-bold text-danger text-xl p-3" 
                                           data-min-value="<%= auction.getNextMinimumBid() %>"
                                           value='<%= FormatUtil.formatVND(auction.getNextMinimumBid()).replace(" ₫", "") %>'>
                                </div>

                                <!-- Nút cộng nhanh bước giá -->
                                <div class="quick-bids-label">Tăng nhanh theo bước giá:</div>
                                <div class="quick-bids-grid">
                                    <button type="button" class="quick-bid-btn" data-multiplier="1">+1 Bước giá</button>
                                    <button type="button" class="quick-bid-btn" data-multiplier="2">+2 Bước giá</button>
                                    <button type="button" class="quick-bid-btn" data-multiplier="5">+5 Bước giá</button>
                                </div>

                                <button type="submit" class="btn btn-gold btn-lg btn-block">
                                    🔨 XÁC NHẬN ĐẶT GIÁ NGAY
                                </button>
                            </form>

                            <div class="bid-rules-note">
                                🛡️ <strong>Cơ chế chống nhảy giá (Anti-Sniping):</strong> Bất kỳ lượt trả giá hợp lệ nào trong 2 phút cuối sẽ tự động gia hạn thêm 3 phút để đảm bảo tính công bằng.
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
    </main>

    <!-- Modal Toàn Văn Chứng Thư Giám Định -->
    <div id="certFullModal" class="cert-modal-backdrop" onclick="if(event.target === this) closeCertModal();" style="display:none;">
        <div class="cert-modal-dialog">
            <div class="cert-modal-header">
                <h3 class="cert-modal-title">📜 CHỨNG THƯ GIÁM ĐỊNH CỔ VẬT CHÍNH THỨC</h3>
                <button type="button" class="cert-modal-close" onclick="closeCertModal()" title="Đóng">&times;</button>
            </div>
            <div class="cert-modal-body">
                <div class="cert-card-room">
                    <div class="cert-seal-room">
                        GIÁM ĐỊNH<br>
                        CHÍNH HÃNG<br>
                        ★ ĐẠT ★
                    </div>
                    <div class="cert-header-meta">
                        <div class="cert-tagline-room">
                            CHỨNG THƯ GIÁM ĐỊNH CỔ VẬT HOÀNG GIA
                        </div>
                        <div class="cert-authority-room text-xs color-muted font-bold">
                            <%= issuingAuthority %>
                        </div>
                        <div class="cert-no-room">
                            Số chứng thư: <strong><%= certNo %></strong>
                        </div>
                    </div>

                    <!-- MỤC I: THÔNG TIN HIỆN VẬT -->
                    <div class="cert-section-block">
                        <div class="cert-section-head">
                            <span class="cert-sec-num">I</span> THÔNG TIN HIỆN VẬT & NHẬN DẠNG
                        </div>
                        <div class="cert-info-grid">
                            <div><span class="text-muted">Mã số hồ sơ:</span> <strong><%= auction.getItemCode() %></strong></div>
                            <div><span class="text-muted">Tên hiện vật:</span> <strong><%= auction.getItemName() %></strong></div>
                            <div><span class="text-muted">Kích thước:</span> <%= dimensionsStr %></div>
                            <div><span class="text-muted">Tình trạng bảo tồn:</span> <span class="badge badge-success"><%= conditionStr %></span></div>
                        </div>
                    </div>

                    <!-- MỤC II: KẾT QUẢ PHÂN TÍCH CHUYÊN MÔN & TÍNH XÁC THỰC -->
                    <div class="cert-section-block">
                        <div class="cert-section-head">
                            <span class="cert-sec-num">II</span> KẾT QUẢ PHÂN TÍCH CHUYÊN MÔN & TÍNH XÁC THỰC
                        </div>
                        <div class="cert-info-grid mb-2">
                            <div><span class="text-muted">Niên đại:</span> <strong><%= eraStr %></strong></div>
                            <div><span class="text-muted">Chất liệu:</span> <strong><%= materialStr %></strong></div>
                        </div>
                        <div class="cert-authenticity-box">
                            <span class="cert-auth-label">Kết luận xác thực:</span>
                            <span class="cert-auth-badge">
                                ★ <%= authConclusion %>
                            </span>
                        </div>
                        <div class="cert-subtext mt-1">
                            <span class="text-muted">Giá trị lịch sử - văn hóa:</span> <%= culturalValue %>
                        </div>
                    </div>

                    <!-- MỤC III: CƠ SỞ KẾT LUẬN & PHƯƠNG PHÁP KỸ THUẬT -->
                    <div class="cert-section-block">
                        <div class="cert-section-head">
                            <span class="cert-sec-num">III</span> CƠ SỞ KẾT LUẬN (KHOA HỌC & THAM KHẢO ĐỐI CHIẾU)
                        </div>
                        <div class="cert-method-box">
                            <div class="mb-1">
                                <strong>🔬 Phương pháp khoa học kỹ thuật:</strong><br>
                                <span class="text-sm"><%= scientificMethod %></span>
                            </div>
                            <div>
                                <strong>📚 Tài liệu & Mẫu vật đối chiếu:</strong><br>
                                <span class="text-sm"><%= referenceMaterial %></span>
                            </div>
                        </div>
                    </div>

                    <!-- MỤC IV: GIÁ TRỊ ƯỚC TÍNH THẨM ĐỊNH (ESTIMATE RANGE) -->
                    <div class="cert-section-block">
                        <div class="cert-section-head">
                            <span class="cert-sec-num">IV</span> GIÁ TRỊ ƯỚC TÍNH THẨM ĐỊNH (ESTIMATE RANGE)
                        </div>
                        <div class="cert-grid-room mb-2">
                            <div class="cert-val-box-room">
                                <div class="cert-val-title-room">Ước tính thấp (Estimate Low)</div>
                                <div class="cert-val-price-room"><%= estimateLowStr %></div>
                            </div>
                            <div class="cert-val-box-room">
                                <div class="cert-val-title-room">Ước tính cao (Estimate High)</div>
                                <div class="cert-val-price-room"><%= estimateHighStr %></div>
                            </div>
                        </div>

                        <% if (appraisalNote != null && !appraisalNote.trim().isEmpty()) { %>
                            <div class="cert-note-box-room">
                                <div class="text-xs text-muted mb-1 font-bold">KẾT LUẬN HỘI ĐỒNG GIÁM ĐỊNH:</div>
                                <div class="text-sm"><%= appraisalNote %></div>
                            </div>
                        <% } %>

                        <div class="cert-signatures-room">
                            <div>
                                <span>Chuyên gia giám định:</span><br>
                                <strong><%= appraiserName %></strong>
                                <div class="text-xs text-muted"><%= appraiserTitle %></div>
                            </div>
                            <div class="text-right">
                                <span>Ngày lập chứng thư:</span><br>
                                <strong><%= appraisalDateStr %></strong>
                                <div class="text-xs text-muted">Hiệu lực: ĐANG CÓ HIỆU LỰC (VALID)</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="cert-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeCertModal()">Đóng Cửa Sổ</button>
            </div>
        </div>
    </div>

    <!-- Toast thông báo thời gian thực -->
    <div id="bid-toast" class="toast"></div>

    <script>
        function selectStageImage(wrapperElement, fullSrc, fallbackSrc, angleLabel) {
            var mainImg = document.getElementById("main-stage-img");
            var angleBadge = document.getElementById("stage-angle-title");
            if (mainImg) {
                mainImg.style.opacity = "0.5";
                setTimeout(function() {
                    mainImg.src = fullSrc;
                    mainImg.onerror = function() {
                        this.onerror = null;
                        this.src = fallbackSrc;
                    };
                    mainImg.style.opacity = "1";
                }, 150);
            }
            if (angleBadge && angleLabel) {
                angleBadge.innerText = angleLabel;
            }
            document.querySelectorAll(".stage-thumb").forEach(function(t) { t.classList.remove("active"); });
            var imgInside = wrapperElement.querySelector(".stage-thumb") || wrapperElement;
            imgInside.classList.add("active");
        }

        function switchDossierTab(tabName) {
            document.querySelectorAll(".dossier-tab-btn").forEach(function(btn) { btn.classList.remove("active"); });
            document.querySelectorAll(".dossier-tab-pane").forEach(function(pane) { pane.classList.remove("active"); });
            var targetBtn = document.getElementById("tab-btn-" + tabName);
            var targetPane = document.getElementById("tab-pane-" + tabName);
            if (targetBtn) targetBtn.classList.add("active");
            if (targetPane) targetPane.classList.add("active");
        }

        function openCertModal() {
            var modal = document.getElementById('certFullModal');
            if (modal) modal.style.display = 'flex';
        }

        function closeCertModal() {
            var modal = document.getElementById('certFullModal');
            if (modal) modal.style.display = 'none';
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeCertModal();
        });

        // Đếm ngược phiên sắp diễn ra theo chuẩn Lạc Việt
        function initUpcomingCountdown() {
            var timerEl = document.getElementById('upcoming-cd-timer');
            if (!timerEl) return;
            var targetMs = parseInt(timerEl.getAttribute('data-start-time'), 10);
            if (!targetMs || isNaN(targetMs)) return;

            var daysBox = document.getElementById('uc-days-box');
            var daysEl = document.getElementById('uc-days');
            var hoursEl = document.getElementById('uc-hours');
            var minsEl = document.getElementById('uc-mins');
            var secsEl = document.getElementById('uc-secs');

            function updateTimer() {
                var now = Date.now();
                var diff = Math.max(0, targetMs - now);

                var days = Math.floor(diff / (1000 * 60 * 60 * 24));
                var hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                var secs = Math.floor((diff % (1000 * 60)) / 1000);

                if (days > 0) {
                    if (daysBox) daysBox.style.display = 'block';
                    if (daysEl) daysEl.textContent = days < 10 ? '0' + days : days;
                } else {
                    if (daysBox) daysBox.style.display = 'none';
                }

                if (hoursEl) hoursEl.textContent = hours < 10 ? '0' + hours : hours;
                if (minsEl) minsEl.textContent = mins < 10 ? '0' + mins : mins;
                if (secsEl) secsEl.textContent = secs < 10 ? '0' + secs : secs;

                if (diff <= 0) {
                    clearInterval(timerInterval);
                }
            }

            updateTimer();
            var timerInterval = setInterval(updateTimer, 1000);
        }

        function copyAuctionLink() {
            var currentUrl = window.location.href;
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(currentUrl).then(function() {
                    showRoomToast('📋 Đã sao chép liên kết phiên đấu giá vào khay nhớ tạm!');
                }).catch(function() {
                    prompt('Sao chép liên kết phiên đấu giá:', currentUrl);
                });
            } else {
                prompt('Sao chép liên kết phiên đấu giá:', currentUrl);
            }
        }

        function showRoomToast(msg) {
            var toast = document.getElementById('bid-toast');
            if (toast) {
                toast.textContent = msg;
                toast.className = 'toast show';
                setTimeout(function() { toast.className = toast.className.replace('show', ''); }, 3000);
            } else {
                alert(msg);
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            initUpcomingCountdown();
        });
    </script>

<jsp:include page="/WEB-INF/footer.jsp">
    <jsp:param name="extraJs" value="auction.js" />
</jsp:include>

