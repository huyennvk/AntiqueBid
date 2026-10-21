package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.OrderDAO;
import com.huyen.antiquebid.model.Dispute;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminDisputeServlet", urlPatterns = {"/admin/disputes", "/admin/dispute-resolve"})
public class AdminDisputeServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String status = req.getParameter("status");
        List<Dispute> disputes = orderDAO.getAllDisputesAdmin(status);
        req.setAttribute("disputes", disputes);
        req.setAttribute("statusFilter", status);
        req.getRequestDispatcher("/WEB-INF/admin/disputes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String disputeIdStr = req.getParameter("disputeId");
        String orderIdStr = req.getParameter("orderId");
        String action = req.getParameter("action"); // "REFUND" or "REJECT"
        String note = req.getParameter("resolutionNote");

        try {
            long disputeId = Long.parseLong(disputeIdStr.trim());
            long orderId = Long.parseLong(orderIdStr.trim());
            boolean isRefund = "REFUND".equalsIgnoreCase(action);

            boolean success = orderDAO.resolveDispute(disputeId, orderId, isRefund, note, currentUser.getUserId());
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/disputes?msg=resolved_success");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        resp.sendRedirect(req.getContextPath() + "/admin/disputes?error=resolve_failed");
    }
}
