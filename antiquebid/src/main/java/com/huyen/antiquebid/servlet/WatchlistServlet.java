package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.model.Watchlist;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WatchlistServlet", urlPatterns = {"/watchlist", "/watchlist-toggle"})
public class WatchlistServlet extends HttpServlet {
    private final AuctionDAO auctionDAO = new AuctionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            String redirect = req.getParameter("redirect");
            if (redirect == null || redirect.isEmpty()) {
                redirect = "/catalogue";
            }
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + redirect);
            return;
        }

        String path = req.getServletPath();
        if ("/watchlist-toggle".equals(path)) {
            String auctionIdStr = req.getParameter("auctionId");
            if (auctionIdStr != null) {
                try {
                    long auctionId = Long.parseLong(auctionIdStr.trim());
                    boolean added = auctionDAO.toggleWatchlist(currentUser.getUserId(), auctionId);
                    String redirect = req.getParameter("redirect");
                    if (redirect != null && !redirect.isEmpty()) {
                        resp.sendRedirect(req.getContextPath() + redirect);
                        return;
                    }
                    resp.sendRedirect(req.getContextPath() + "/watchlist");
                    return;
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/watchlist");
            return;
        }

        List<Watchlist> watchlists = auctionDAO.getWatchlistByUserId(currentUser.getUserId());
        req.setAttribute("watchlists", watchlists);
        req.getRequestDispatcher("/WEB-INF/watchlist.jsp").forward(req, resp);
    }
}
