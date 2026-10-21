<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.huyen.antiquebid.model.AntiqueItem" %>
<%@ page import="com.huyen.antiquebid.model.Category" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("activePage", "items");
    AntiqueItem item = (AntiqueItem) request.getAttribute("item");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    boolean isEdit = (item != null && item.getItemId() != null);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/header.jsp">
    <jsp:param name="pageTitle" value='<%= (isEdit ? "Cập nhật hiện vật" : "Đăng ký hiện vật mới") + " | Admin" %>' />
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
                    <h1 class="admin-header-title">
                        <%= isEdit ? "Cập Nhật Hồ Sơ Hiện Vật: " + item.getName() : "Đăng Ký Cổ Vật Mới Vào Kho" %>
                    </h1>
                    <p class="admin-header-desc">
                        Nhập đầy đủ thông tin định danh, niên đại ước tính và phân loại danh mục hiện vật trước khi đưa vào quy trình giám định
                    </p>
                </div>

                <div class="admin-form-card">
                    <form action="<%= ctx %>/admin/item-form" method="POST">
                        <input type="hidden" name="itemId" value="<%= isEdit ? item.getItemId() : "" %>">

                        <div class="grid-2 gap-3">
                            <div class="form-group">
                                <label class="form-label">Mã hiện vật (*)</label>
                                <input type="text" name="itemCode" class="form-control" 
                                       value="<%= isEdit ? item.getItemCode() : "HV-" + System.currentTimeMillis() % 10000 %>" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Danh mục cổ vật (*)</label>
                                <select name="categoryId" class="form-control" required>
                                    <% if (categories != null) { for (Category c : categories) { %>
                                        <option value="<%= c.getCategoryId() %>" <%= (isEdit && item.getCategoryId().equals(c.getCategoryId())) ? "selected" : "" %>>
                                            <%= c.getName() %>
                                        </option>
                                    <% }} %>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Tên hiện vật (*)</label>
                            <input type="text" name="name" class="form-control" 
                                   value="<%= isEdit ? item.getName() : "" %>" placeholder="VD: Bình gốm hoa lam thế kỷ 15" required>
                        </div>

                        <div class="grid-2 gap-3">
                            <div class="form-group">
                                <label class="form-label">Chất liệu chế tác (*)</label>
                                <input type="text" name="material" class="form-control" 
                                       value="<%= isEdit ? item.getMaterial() : "" %>" placeholder="VD: Gốm men lam, Đồng hun, Thép..." required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Kích thước & Trọng lượng</label>
                                <input type="text" name="dimensions" class="form-control" 
                                       value="<%= isEdit ? item.getDimensions() : "" %>" placeholder="VD: Cao 35cm, đường kính 20cm, nặng 1.8kg">
                            </div>
                        </div>

                        <div class="grid-3 gap-3">
                            <div class="form-group">
                                <label class="form-label">Niên đại từ năm (eraFrom)</label>
                                <input type="number" name="eraFrom" class="form-control" 
                                       value="<%= (isEdit && item.getEraFrom() != null) ? item.getEraFrom() : 1400 %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Đến năm (eraTo)</label>
                                <input type="number" name="eraTo" class="form-control" 
                                       value="<%= (isEdit && item.getEraTo() != null) ? item.getEraTo() : 1500 %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Tình trạng hiện vật</label>
                                <select name="itemCondition" class="form-control">
                                    <option value="INTACT" <%= (isEdit && "INTACT".equalsIgnoreCase(item.getItemCondition())) ? "selected" : "" %>>Nguyên vẹn</option>
                                    <option value="SLIGHTLY_DAMAGED" <%= (isEdit && "SLIGHTLY_DAMAGED".equalsIgnoreCase(item.getItemCondition())) ? "selected" : "" %>>Tổn hại nhẹ</option>
                                    <option value="RESTORED" <%= (isEdit && "RESTORED".equalsIgnoreCase(item.getItemCondition())) ? "selected" : "" %>>Đã phục chế</option>
                                    <option value="DAMAGED" <%= (isEdit && "DAMAGED".equalsIgnoreCase(item.getItemCondition())) ? "selected" : "" %>>Tổn hại nhiều</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mô tả lịch sử & Chi tiết nghệ thuật</label>
                            <textarea name="description" class="form-control" rows="4" 
                                      placeholder="Mô tả kỹ thuật điêu khắc, họa tiết, nguồn gốc sưu tầm..."><%= isEdit ? item.getDescription() : "" %></textarea>
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-gold btn-lg flex-1">
                                <%= isEdit ? "Lưu Cập Nhật Hiện Vật" : "Tạo Mới Hồ Sơ Hiện Vật" %>
                            </button>
                            <a href="<%= ctx %>/admin/items" class="btn btn-dark btn-lg">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
<jsp:include page="/WEB-INF/footer.jsp" />
