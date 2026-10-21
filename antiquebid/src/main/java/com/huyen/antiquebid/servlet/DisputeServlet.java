package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.OrderDAO;
import com.huyen.antiquebid.model.Order;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "DisputeServlet", urlPatterns = {"/dispute"})
public class DisputeServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(orderIdStr.trim());
            Order order = orderDAO.getOrderById(orderId);
            if (order == null || !order.getBidderId().equals(currentUser.getUserId())) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            req.setAttribute("order", order);
            req.getRequestDispatcher("/WEB-INF/dispute.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String orderIdStr = req.getParameter("orderId");
        String reasonType = req.getParameter("reasonType");
        String details = req.getParameter("details");

        if (orderIdStr == null || details == null || details.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng mô tả chi tiết lý do khiếu nại.");
            doGet(req, resp);
            return;
        }

        try {
            long orderId = Long.parseLong(orderIdStr.trim());
            String fullReason = "[" + (reasonType != null ? reasonType : "KHÁC") + "] " + details.trim();
            boolean success = orderDAO.createDispute(orderId, currentUser.getUserId(), fullReason);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/orders?msg=dispute_submitted");
            } else {
                req.setAttribute("errorMessage", "Không thể gửi khiếu nại. Vui lòng thử lại.");
                doGet(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }
}
