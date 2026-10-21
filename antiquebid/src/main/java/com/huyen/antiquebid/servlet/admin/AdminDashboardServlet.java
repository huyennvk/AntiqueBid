package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.dao.ReportDAO;
import com.huyen.antiquebid.model.Auction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard", "/admin"})
public class AdminDashboardServlet extends HttpServlet {
    private final ReportDAO reportDAO = new ReportDAO();
    private final AuctionDAO auctionDAO = new AuctionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Object> stats = reportDAO.getDashboardStats();
        List<Auction> liveAuctions = auctionDAO.getLiveAuctions(null, null);

        req.setAttribute("stats", stats);
        req.setAttribute("liveAuctions", liveAuctions);
        req.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(req, resp);
    }
}
