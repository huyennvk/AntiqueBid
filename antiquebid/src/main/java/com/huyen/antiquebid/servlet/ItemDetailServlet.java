package com.huyen.antiquebid.servlet;

import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.dao.ItemDAO;
import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.AppraisalCertificate;
import com.huyen.antiquebid.model.Auction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ItemDetailServlet", urlPatterns = {"/item-detail"})
public class ItemDetailServlet extends HttpServlet {
    private final ItemDAO itemDAO = new ItemDAO();
    private final AuctionDAO auctionDAO = new AuctionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/catalogue");
            return;
        }

        try {
            Long itemId = Long.parseLong(idParam.trim());
            AntiqueItem item = itemDAO.getItemById(itemId);
            if (item == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hiện vật.");
                return;
            }

            AppraisalCertificate cert = itemDAO.getAppraisalByItemId(itemId);

            // Check if there is an active or upcoming auction for this item
            Auction relatedAuction = null;
            for (Auction a : auctionDAO.getLiveAuctions(null, null)) {
                if (a.getItemId().equals(itemId)) {
                    relatedAuction = a;
                    break;
                }
            }
            if (relatedAuction == null) {
                for (Auction a : auctionDAO.getUpcomingAuctions()) {
                    if (a.getItemId().equals(itemId)) {
                        relatedAuction = a;
                        break;
                    }
                }
            }

            HttpSession session = req.getSession(false);
            com.huyen.antiquebid.model.User currentUser = (session != null) ? (com.huyen.antiquebid.model.User) session.getAttribute("currentUser") : null;
            boolean isWatched = false;
            if (currentUser != null && relatedAuction != null) {
                isWatched = auctionDAO.isWatched(currentUser.getUserId(), relatedAuction.getAuctionId());
            }

            req.setAttribute("item", item);
            req.setAttribute("certificate", cert);
            req.setAttribute("relatedAuction", relatedAuction);
            req.setAttribute("isWatched", isWatched);

            req.getRequestDispatcher("/WEB-INF/item_detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/catalogue");
        }
    }
}
