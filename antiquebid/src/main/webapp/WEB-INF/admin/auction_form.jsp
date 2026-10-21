<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.model.Auction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    request.setAttribute("activePage", "auctions");
    Auction auction = (Auction) request.getAttribute("auction");
    List<AntiqueItem> availableItems = (List<AntiqueItem>) request.getAttribute("availableItems");
    boolean isEdit = (auction != null && auction.getAuctionId() != null);
    String ctx = request.getContextPath();
    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= (isEdit ? "Cập nhật phiên đấu giá" : "Tạo phiên đấu giá mới") + " | Admin" %>' />
    <jsp:param name="extraCss" value="admin_forms.css" />
</jsp:include>

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/admin/sidebar.jsp" />

        <main class="admin-main">
            <div class="admin-form-container">
                <div class="user-page-header">
                    <div>
                        <a href="<%= ctx %>/admin/auctions" class="back-link">&larr; Quay lại danh sách phiên</a>
                    </div>
                    <h1 class="admin-header-title">
                        <%= isEdit ? "Cập Nhật Phiên Đấu Giá #AUC-" + auction.getAuctionId() : "Cấu Hình & Mở Phiên Đấu Giá Mới" %>
                    </h1>
                    <p class="admin-header-desc">
                        Quy định: Mỗi hiện vật chỉ gán cho 1 phiên; thời điểm kết thúc sau thời điểm bắt đầu; giá sàn không thấp hơn giá khởi điểm.
                    </p>
                </div>

                <% String err = (String) request.getAttribute("errorMessage"); %>
                <% if (err != null) { %>
                    <div class="alert alert-danger"><%= err %></div>
                <% } %>

                <div class="admin-form-card">
                    <form action="<%= ctx %>/admin/auction-form" method="POST">
                        <input type="hidden" name="auctionId" value="<%= isEdit ? auction.getAuctionId() : "" %>">

                        <div class="form-group">
                            <label class="form-label">Chọn cổ vật độc bản đưa lên sàn (*)</label>
                            <% if (isEdit) { %>
                                <input type="hidden" name="itemId" value="<%= auction.getItemId() %>">
                                <input type="text" class="form-control disabled-bg" value="<%= auction.getItemCode() %> - <%= auction.getItemName() %>" disabled>
                            <% } else { %>
                                <select name="itemId" class="form-control" required>
                                    <% if (availableItems != null && !availableItems.isEmpty()) { 
                                        for (AntiqueItem it : availableItems) { %>
                                        <option value="<%= it.getItemId() %>">
                                            <%= it.getItemCode() %> - <%= it.getName() %> (<%= it.getCategoryName() %>) - Đã đạt giám định (VALID)
                                        </option>
                                    <% }} else { %>
                                        <option value="">Không có hiện vật nào đang ở trạng thái AVAILABLE. Vui lòng giám định cổ vật trước.</option>
                                    <% } %>
                                </select>
                            <% } %>
                        </div>

                        <div class="grid-2 gap-3">
                            <div class="form-group">
                                <label class="form-label">Thời điểm bắt đầu phiên (startTime) (*)</label>
                                <input type="datetime-local" name="startTime" class="form-control" 
                                       value="<%= (isEdit && auction.getStartTime() != null) ? sdfInput.format(auction.getStartTime()) : "2026-10-20T20:00" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Thời điểm kết thúc phiên (endTime) (*)</label>
                                <input type="datetime-local" name="endTime" class="form-control" 
                                       value="<%= (isEdit && auction.getEndTime() != null) ? sdfInput.format(auction.getEndTime()) : "2026-10-20T23:59" %>" required>
                                <small class="text-xs color-muted">Bắt buộc thời gian kết thúc sau thời gian bắt đầu</small>
                            </div>
                        </div>

                        <div class="grid-3 gap-3">
                            <div class="form-group">
                                <label class="form-label">Giá khởi điểm (VNĐ) (*)</label>
                                <input type="text" name="startingPrice" class="form-control" 
                                       value="<%= isEdit ? auction.getStartingPrice() : "50000000" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Giá sàn ẩn (Reserve Price) (*)</label>
                                <input type="text" name="reservePrice" class="form-control" 
                                       value="<%= isEdit ? auction.getReservePrice() : "60000000" %>" required>
                                <small class="text-xs color-muted">Bảo mật đối với người mua, &gt;= Giá khởi điểm</small>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Bước giá tối thiểu (VNĐ) (*)</label>
                                <input type="text" name="minBidIncrement" class="form-control" 
                                       value="<%= isEdit ? auction.getMinBidIncrement() : "2000000" %>" required>
                                <small class="text-xs color-muted">Giá trị tối thiểu &gt; 0</small>
                            </div>
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-gold btn-lg flex-1">
                                <%= isEdit ? "Lưu Cập Nhật Phiên Đấu Giá" : "⚡ Kích Hoạt & Lên Lịch Mở Phiên" %>
                            </button>
                            <a href="<%= ctx %>/admin/auctions" class="btn btn-dark btn-lg">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
<jsp:include page="/WEB-INF/footer.jsp" />
