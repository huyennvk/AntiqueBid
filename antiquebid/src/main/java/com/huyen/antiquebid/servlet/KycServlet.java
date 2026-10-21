package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.UserDAO;
import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.model.VerificationDocument;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "KycServlet", urlPatterns = {"/kyc"})
public class KycServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        User updated = userDAO.findById(currentUser.getUserId());
        if (updated != null) {
            session.setAttribute("currentUser", updated);
            req.setAttribute("user", updated);
        } else {
            req.setAttribute("user", currentUser);
        }

        VerificationDocument userDoc = userDAO.getLatestKycDocument(currentUser.getUserId());
        req.setAttribute("userDoc", userDoc);

        req.getRequestDispatcher("/WEB-INF/kyc.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String citizenId = req.getParameter("citizenId");
        String issueDateStr = req.getParameter("issueDate");
        String issuePlace = req.getParameter("issuePlace");
        String fileUrl = req.getParameter("fileUrl");
        String fileUrlBack = req.getParameter("fileUrlBack");

        if (citizenId == null || !citizenId.trim().matches("\\d{12}")) {
            req.setAttribute("errorMessage", "Số CCCD không hợp lệ! Vui lòng nhập chính xác 12 chữ số theo quy chuẩn Căn cước công dân gắn chip.");
            doGet(req, resp);
            return;
        }

        java.sql.Date issueDate = null;
        if (issueDateStr != null && !issueDateStr.trim().isEmpty()) {
            try {
                issueDate = java.sql.Date.valueOf(issueDateStr.trim());
            } catch (Exception ignored) {
            }
        }
        if (issueDate == null) {
            issueDate = new java.sql.Date(System.currentTimeMillis() - 365L * 24 * 3600 * 1000 * 3); // Mặc định 3 năm trước
        }

        if (issuePlace == null || issuePlace.trim().isEmpty()) {
            issuePlace = "Cục Cảnh sát QLHC về TTXH";
        }
        if (fileUrl == null || fileUrl.trim().isEmpty()) {
            fileUrl = "assets/images/sample_cccd_front.svg";
        }
        if (fileUrlBack == null || fileUrlBack.trim().isEmpty()) {
            fileUrlBack = "assets/images/sample_cccd_back.svg";
        }

        boolean success = userDAO.submitKycDocument(
            currentUser.getUserId(), 
            citizenId.trim(), 
            issueDate, 
            issuePlace.trim(), 
            fileUrl.trim(), 
            fileUrlBack.trim()
        );

        if (success) {
            User updated = userDAO.findById(currentUser.getUserId());
            session.setAttribute("currentUser", updated);
            req.setAttribute("user", updated);
            req.setAttribute("successMessage", "Hồ sơ Căn cước công dân (CCCD) đã được gửi thành công! Quản trị viên sàn sẽ kiểm tra và phê duyệt trong 24h.");
        } else {
            req.setAttribute("errorMessage", "Không thể gửi hồ sơ xác minh CCCD. Vui lòng kiểm tra lại thông tin và thử lại.");
        }

        doGet(req, resp);
    }
}
