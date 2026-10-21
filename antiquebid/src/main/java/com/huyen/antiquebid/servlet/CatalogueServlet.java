package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.dao.ItemDAO;
import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.Auction;
import com.huyen.antiquebid.model.Category;
import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.model.Watchlist;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "CatalogueServlet", urlPatterns = {"/catalogue", "/home", ""})
public class CatalogueServlet extends HttpServlet {
    private final ItemDAO itemDAO = new ItemDAO();
    private final AuctionDAO auctionDAO = new AuctionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String categoryIdParam = req.getParameter("category");
        String keyword = req.getParameter("keyword");
        String tab = req.getParameter("tab"); // "live", "items", "upcoming"
        String status = req.getParameter("status"); // "all", "live", "upcoming", "ended"
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");

        Long categoryId = null;
        if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
            try {
                categoryId = Long.parseLong(categoryIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<Category> categories = itemDAO.getAllCategories();
        List<Auction> liveAuctions = new java.util.ArrayList<>();
        List<Auction> upcomingAuctions = new java.util.ArrayList<>();
        List<Auction> endedAuctions = new java.util.ArrayList<>();

        boolean showLive = status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status) || "live".equalsIgnoreCase(status);
        boolean showUpcoming = status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status) || "upcoming".equalsIgnoreCase(status);
        boolean showEnded = status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status) || "ended".equalsIgnoreCase(status);

        if (showLive) {
            liveAuctions = auctionDAO.getLiveAuctions(categoryId, keyword);
        }
        if (showUpcoming) {
            upcomingAuctions = auctionDAO.getUpcomingAuctions(categoryId, keyword);
        }
        if (showEnded) {
            endedAuctions = auctionDAO.getClosedAuctions(categoryId, keyword);
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        Set<Long> watchedAuctionIds = new HashSet<>();
        if (currentUser != null) {
            List<Watchlist> watchlists = auctionDAO.getWatchlistByUserId(currentUser.getUserId());
            if (watchlists != null) {
                for (Watchlist w : watchlists) {
                    if (w.getAuctionId() != null) {
                        watchedAuctionIds.add(w.getAuctionId());
                    }
                }
            }
        }

        req.setAttribute("categories", categories);
        req.setAttribute("liveAuctions", liveAuctions);
        req.setAttribute("upcomingAuctions", upcomingAuctions);
        req.setAttribute("endedAuctions", endedAuctions);
        req.setAttribute("selectedCategory", categoryId);
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedStatus", (status != null && !status.trim().isEmpty()) ? status : "all");
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("currentTab", "upcoming".equalsIgnoreCase(tab) ? "upcoming" : "live");
        req.setAttribute("watchedAuctionIds", watchedAuctionIds);

        req.getRequestDispatcher("/WEB-INF/catalogue.jsp").forward(req, resp);
    }
}
