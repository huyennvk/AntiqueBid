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
import java.util.List;

@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/order-detail"})
public class OrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
        if ("/order-detail".equals(path)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    long orderId = Long.parseLong(idStr.trim());
                    Order order = orderDAO.getOrderById(orderId);
                    if (order != null && (order.getBidderId().equals(currentUser.getUserId()) || currentUser.isAdmin())) {
                        req.setAttribute("order", order);
                        req.getRequestDispatcher("/WEB-INF/order_detail.jsp").forward(req, resp);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        List<Order> orders = orderDAO.getOrdersByBidderId(currentUser.getUserId());
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/WEB-INF/orders.jsp").forward(req, resp);
    }
}
