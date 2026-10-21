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
import java.util.UUID;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/checkout", "/mockpay-gateway"})
public class PaymentServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String idStr = req.getParameter("orderId");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(idStr.trim());
            Order order = orderDAO.getOrderById(orderId);
            if (order == null || !order.getBidderId().equals(currentUser.getUserId())) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            req.setAttribute("order", order);

            String path = req.getServletPath();
            if ("/mockpay-gateway".equals(path)) {
                // MockPay simulator gateway view (Wireframe Hình 2.24)
                String method = req.getParameter("method");
                req.setAttribute("method", method != null ? method : "MOCKPAY_WALLET");
                req.getRequestDispatcher("/WEB-INF/payment_gateway.jsp").forward(req, resp);
                return;
            }

            // Normal checkout view (Wireframe Hình 2.10)
            req.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
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

            if ("/checkout".equals(path)) {
                // User clicked "Tiếp tục thanh toán" -> Redirect to MockPay simulator
                String method = req.getParameter("paymentMethod");
                resp.sendRedirect(req.getContextPath() + "/mockpay-gateway?orderId=" + orderId + "&method=" + method);
                return;
            }

            if ("/mockpay-gateway".equals(path)) {
                String action = req.getParameter("action");
                if ("cancel".equalsIgnoreCase(action)) {
                    resp.sendRedirect(req.getContextPath() + "/orders?msg=payment_cancelled");
                    return;
                }

                String method = req.getParameter("method");
                String transRef = "MP-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

                boolean success = orderDAO.processPayment(orderId, method != null ? method : "MOCKPAY_WALLET", transRef);
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/orders?msg=payment_success&orderId=" + orderId);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/checkout?orderId=" + orderId + "&error=payment_failed");
                }
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }
}
