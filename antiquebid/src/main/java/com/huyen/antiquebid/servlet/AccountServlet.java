package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.UserDAO;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AccountServlet", urlPatterns = {"/account"})
public class AccountServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Reload latest data from DB
        User updated = userDAO.findById(currentUser.getUserId());
        if (updated != null) {
            session.setAttribute("currentUser", updated);
            req.setAttribute("user", updated);
        } else {
            req.setAttribute("user", currentUser);
        }

        // Load CCCD Verification document
        com.huyen.antiquebid.model.VerificationDocument userDoc = userDAO.getLatestKycDocument(currentUser.getUserId());
        req.setAttribute("userDoc", userDoc);

        req.getRequestDispatcher("/WEB-INF/account.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String shippingAddress = req.getParameter("shippingAddress");

        boolean success = userDAO.updateProfile(currentUser.getUserId(), fullName, phone, shippingAddress);
        if (success) {
            User updated = userDAO.findById(currentUser.getUserId());
            session.setAttribute("currentUser", updated);
            req.setAttribute("user", updated);
            req.setAttribute("successMessage", "Cập nhật thông tin tài khoản thành công!");
        } else {
            req.setAttribute("errorMessage", "Không thể cập nhật thông tin. Vui lòng thử lại.");
        }

        req.getRequestDispatcher("/WEB-INF/account.jsp").forward(req, resp);
    }
}
