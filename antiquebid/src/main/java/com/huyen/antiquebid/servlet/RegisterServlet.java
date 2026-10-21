package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.UserDAO;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (fullName == null || email == null || password == null ||
            fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng điền đầy đủ các thông tin bắt buộc (*).");
            req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("errorMessage", "Mật khẩu phải chứa ít nhất 6 ký tự.");
            req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
            return;
        }

        User existing = userDAO.findByEmail(email.trim());
        if (existing != null) {
            req.setAttribute("errorMessage", "Email này đã được sử dụng. Vui lòng chọn email khác (BR02).");
            req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
            return;
        }

        boolean success = userDAO.register(email.trim(), password, fullName.trim(), phone != null ? phone.trim() : "", address != null ? address.trim() : "");
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=reg_success");
        } else {
            req.setAttribute("errorMessage", "Đăng ký thất bại do lỗi hệ thống. Vui lòng thử lại.");
            req.getRequestDispatcher("/WEB-INF/register.jsp").forward(req, resp);
        }
    }
}
