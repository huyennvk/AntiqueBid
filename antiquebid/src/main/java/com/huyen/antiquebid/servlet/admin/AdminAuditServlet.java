package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.ReportDAO;
import com.huyen.antiquebid.model.AuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAuditServlet", urlPatterns = {"/admin/audit-logs"})
public class AdminAuditServlet extends HttpServlet {
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<AuditLog> logs = reportDAO.getAuditLogs(100);
        req.setAttribute("auditLogs", logs);
        req.getRequestDispatcher("/WEB-INF/admin/audit_logs.jsp").forward(req, resp);
    }
}
