package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.UserDAO;
import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.model.VerificationDocument;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users", "/admin/user-toggle-lock", "/admin/kyc-review"})
public class AdminUserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/kyc-review".equals(path)) {
            String filter = req.getParameter("status");
            List<VerificationDocument> docs = userDAO.getAllKycDocuments(filter);
            req.setAttribute("documents", docs);
            req.setAttribute("statusFilter", filter);
            req.getRequestDispatcher("/WEB-INF/admin/kyc_review.jsp").forward(req, resp);
            return;
        }

        List<User> users = userDAO.getAllUsers();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/WEB-INF/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/user-toggle-lock".equals(path)) {
            String userIdStr = req.getParameter("userId");
            String lockStr = req.getParameter("lock");
            try {
                long userId = Long.parseLong(userIdStr.trim());
                boolean lock = Boolean.parseBoolean(lockStr);
                userDAO.toggleLock(userId, lock);
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=lock_updated");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("/admin/kyc-review".equals(path)) {
            String docIdStr = req.getParameter("docId");
            String bidderIdStr = req.getParameter("bidderId");
            String action = req.getParameter("action"); // "APPROVE" or "REJECT"
            String reviewNote = req.getParameter("reviewNote");

            try {
                long docId = Long.parseLong(docIdStr.trim());
                long bidderId = Long.parseLong(bidderIdStr.trim());
                boolean approved = "APPROVE".equalsIgnoreCase(action);

                boolean success = userDAO.reviewKyc(docId, bidderId, approved, reviewNote);
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/kyc-review?msg=kyc_updated");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/kyc-review?error=kyc_failed");
        }
    }
}
