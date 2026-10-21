package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.ItemDAO;
import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.AppraisalCertificate;
import com.huyen.antiquebid.model.Category;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminItemServlet", urlPatterns = {"/admin/items", "/admin/item-form", "/admin/appraise"})
public class AdminItemServlet extends HttpServlet {
    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/item-form".equals(path)) {
            List<Category> categories = itemDAO.getAllCategories();
            req.setAttribute("categories", categories);

            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    long id = Long.parseLong(idStr.trim());
                    AntiqueItem item = itemDAO.getItemById(id);
                    req.setAttribute("item", item);
                } catch (NumberFormatException ignored) {}
            }
            req.getRequestDispatcher("/WEB-INF/admin/item_form.jsp").forward(req, resp);
            return;
        }

        if ("/admin/appraise".equals(path)) {
            String idStr = req.getParameter("itemId");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    long id = Long.parseLong(idStr.trim());
                    AntiqueItem item = itemDAO.getItemById(id);
                    AppraisalCertificate existingCert = itemDAO.getAppraisalByItemId(id);
                    req.setAttribute("item", item);
                    req.setAttribute("certificate", existingCert);
                    req.getRequestDispatcher("/WEB-INF/admin/appraisal_form.jsp").forward(req, resp);
                    return;
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/admin/items");
            return;
        }

        // List items
        List<AntiqueItem> items = itemDAO.getAllItemsAdmin();
        req.setAttribute("items", items);
        req.getRequestDispatcher("/WEB-INF/admin/items.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if ("/admin/item-form".equals(path)) {
            String idStr = req.getParameter("itemId");
            String itemCode = req.getParameter("itemCode");
            String name = req.getParameter("name");
            String categoryIdStr = req.getParameter("categoryId");
            String material = req.getParameter("material");
            String dimensions = req.getParameter("dimensions");
            String condition = req.getParameter("itemCondition");
            String eraFromStr = req.getParameter("eraFrom");
            String eraToStr = req.getParameter("eraTo");
            String description = req.getParameter("description");

            AntiqueItem item = new AntiqueItem();
            item.setItemCode(itemCode != null ? itemCode.trim() : "HV-" + System.currentTimeMillis() % 10000);
            item.setName(name);
            item.setMaterial(material);
            item.setDimensions(dimensions);
            item.setItemCondition(condition != null ? condition : "INTACT");
            item.setDescription(description);

            try {
                if (categoryIdStr != null) item.setCategoryId(Long.parseLong(categoryIdStr));
                if (eraFromStr != null && !eraFromStr.trim().isEmpty()) item.setEraFrom(Integer.parseInt(eraFromStr.trim()));
                if (eraToStr != null && !eraToStr.trim().isEmpty()) item.setEraTo(Integer.parseInt(eraToStr.trim()));
            } catch (NumberFormatException ignored) {}

            boolean isNew = (idStr == null || idStr.trim().isEmpty());
            if (isNew) {
                item.setCreatedBy(currentUser.getUserId());
                itemDAO.createItem(item);
            } else {
                item.setItemId(Long.parseLong(idStr.trim()));
                itemDAO.updateItem(item);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/items?msg=item_saved");
            return;
        }

        if ("/admin/appraise".equals(path)) {
            String itemIdStr = req.getParameter("itemId");
            String result = req.getParameter("result");
            String appraiserName = req.getParameter("appraiserName");
            String appraisalDateStr = req.getParameter("appraisalDate");
            String certificateNo = req.getParameter("certificateNo");
            String estimateLowStr = req.getParameter("estimateLow");
            String estimateHighStr = req.getParameter("estimateHigh");
            String note = req.getParameter("note");
            String authConclusion = req.getParameter("authenticityConclusion");
            String scientificMethod = req.getParameter("scientificMethod");

            try {
                long itemId = Long.parseLong(itemIdStr.trim());
                AppraisalCertificate cert = new AppraisalCertificate();
                cert.setItemId(itemId);
                boolean isPassed = "PASSED".equalsIgnoreCase(result);
                cert.setResult(isPassed ? "PASSED" : "REJECTED");
                cert.setAppraiserName(appraiserName != null && !appraiserName.trim().isEmpty() ? appraiserName.trim() : "Hội Đồng Giám Định Di Sản");
                if (appraisalDateStr != null && !appraisalDateStr.trim().isEmpty()) {
                    cert.setAppraisalDate(Date.valueOf(appraisalDateStr.trim()));
                } else {
                    cert.setAppraisalDate(new Date(System.currentTimeMillis()));
                }

                if (isPassed) {
                    cert.setCertificateNo(certificateNo != null && !certificateNo.trim().isEmpty() ? certificateNo.trim() : "CT-" + (System.currentTimeMillis() % 10000));
                    if (estimateLowStr != null && !estimateLowStr.trim().isEmpty()) {
                        cert.setEstimateLow(new BigDecimal(estimateLowStr.trim().replace(".", "").replace(",", "")));
                    }
                    if (estimateHighStr != null && !estimateHighStr.trim().isEmpty()) {
                        cert.setEstimateHigh(new BigDecimal(estimateHighStr.trim().replace(".", "").replace(",", "")));
                    }
                } else {
                    cert.setCertificateNo(null);
                    cert.setEstimateLow(BigDecimal.ZERO);
                    cert.setEstimateHigh(BigDecimal.ZERO);
                }

                StringBuilder sbNote = new StringBuilder();
                if (note != null && !note.trim().isEmpty()) {
                    sbNote.append(note.trim());
                } else {
                    if (isPassed) {
                        sbNote.append(authConclusion != null ? authConclusion : "Cổ vật thật nguyên bản (Authentic Antique)");
                        if (scientificMethod != null && !scientificMethod.trim().isEmpty()) {
                            sbNote.append(". Phương pháp: ").append(scientificMethod.trim());
                        }
                    } else {
                        sbNote.append("Kết quả KHÔNG ĐẠT. Không đủ căn cứ xác minh tính nguyên bản di sản. Từ chối cấp chứng thư.");
                    }
                }
                cert.setNote(sbNote.toString());
                cert.setRecordedBy(currentUser.getUserId());

                boolean success = itemDAO.createAppraisal(cert);
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/items?msg=appraisal_saved");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/items?error=appraisal_failed");
        }
    }
}
