package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.OrderDAO;
import com.huyen.antiquebid.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders", "/admin/shipment-form", "/admin/order-deliver"})
public class AdminOrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/shipment-form".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    long orderId = Long.parseLong(orderIdStr.trim());
                    Order order = orderDAO.getOrderById(orderId);
                    req.setAttribute("order", order);
                    req.getRequestDispatcher("/WEB-INF/admin/shipment_form.jsp").forward(req, resp);
                    return;
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        String status = req.getParameter("status");
        List<Order> orders = orderDAO.getAllOrdersAdmin(status);
        req.setAttribute("orders", orders);
        req.setAttribute("statusFilter", status);
        req.getRequestDispatcher("/WEB-INF/admin/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/shipment-form".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            String carrier = req.getParameter("carrierName");
            String trackingNumber = req.getParameter("trackingNumber");

            try {
                long orderId = Long.parseLong(orderIdStr.trim());
                boolean success = orderDAO.createShipment(orderId, carrier, trackingNumber);
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/orders?msg=shipment_created");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/orders?error=shipment_failed");
            return;
        }

        if ("/admin/order-deliver".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            try {
                long orderId = Long.parseLong(orderIdStr.trim());
                orderDAO.updateShipmentDelivered(orderId);
                resp.sendRedirect(req.getContextPath() + "/admin/orders?msg=delivered_success");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }
}
