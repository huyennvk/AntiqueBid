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

@WebServlet(name = "ShipmentServlet", urlPatterns = {"/shipment-tracking"})
public class ShipmentServlet extends HttpServlet {
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
            if (order == null || (!order.getBidderId().equals(currentUser.getUserId()) && !currentUser.isAdmin())) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            req.setAttribute("order", order);
            req.getRequestDispatcher("/WEB-INF/shipment_tracking.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }
}
