package com.huyen.antiquebid.servlet.admin;

import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.dao.ItemDAO;
import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.Auction;
import com.huyen.antiquebid.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "AdminAuctionServlet", urlPatterns = {"/admin/auctions", "/admin/auction-form", "/admin/auction-cancel"})
public class AdminAuctionServlet extends HttpServlet {
    private final AuctionDAO auctionDAO = new AuctionDAO();
    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/admin/auction-form".equals(path)) {
            // Find items with status AVAILABLE for creating new auction (BR07)
            List<AntiqueItem> availableItems = itemDAO.getCatalogueItems(null, null, "AVAILABLE");
            req.setAttribute("availableItems", availableItems);

            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    long id = Long.parseLong(idStr.trim());
                    Auction auction = auctionDAO.getAuctionById(id);
                    req.setAttribute("auction", auction);
                } catch (NumberFormatException ignored) {}
            }
            req.getRequestDispatcher("/WEB-INF/admin/auction_form.jsp").forward(req, resp);
            return;
        }

        // List auctions
        String status = req.getParameter("status");
        List<Auction> auctions = auctionDAO.getAllAuctionsAdmin(status);
        req.setAttribute("auctions", auctions);
        req.setAttribute("statusFilter", status);
        req.getRequestDispatcher("/WEB-INF/admin/auctions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if ("/admin/auction-cancel".equals(path)) {
            String auctionIdStr = req.getParameter("auctionId");
            String reason = req.getParameter("reason");
            try {
                long auctionId = Long.parseLong(auctionIdStr.trim());
                auctionDAO.cancelAuction(auctionId, reason != null ? reason : "Hủy bởi quản trị viên", currentUser.getUserId());
                resp.sendRedirect(req.getContextPath() + "/admin/auctions?msg=auction_cancelled");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/auctions?error=cancel_failed");
            return;
        }

        if ("/admin/auction-form".equals(path)) {
            String auctionIdStr = req.getParameter("auctionId");
            String itemIdStr = req.getParameter("itemId");
            String startTimeStr = req.getParameter("startTime");
            String endTimeStr = req.getParameter("endTime");
            String startingPriceStr = req.getParameter("startingPrice");
            String reservePriceStr = req.getParameter("reservePrice");
            String minIncrementStr = req.getParameter("minBidIncrement");

            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                Date parsedStart = sdf.parse(startTimeStr);
                Date parsedEnd = sdf.parse(endTimeStr);

                // BR08: endTime > startTime
                if (!parsedEnd.after(parsedStart)) {
                    req.setAttribute("errorMessage", "Thời gian kết thúc phải sau thời gian bắt đầu (BR08).");
                    doGet(req, resp);
                    return;
                }

                BigDecimal startingPrice = new BigDecimal(startingPriceStr.trim().replace(".", "").replace(",", ""));
                BigDecimal reservePrice = new BigDecimal(reservePriceStr.trim().replace(".", "").replace(",", ""));
                BigDecimal minIncrement = new BigDecimal(minIncrementStr.trim().replace(".", "").replace(",", ""));

                // BR09: reservePrice >= startingPrice > 0, minIncrement > 0
                if (startingPrice.compareTo(BigDecimal.ZERO) <= 0 || minIncrement.compareTo(BigDecimal.ZERO) <= 0) {
                    req.setAttribute("errorMessage", "Giá khởi điểm và bước giá tối thiểu phải lớn hơn 0 (BR09).");
                    doGet(req, resp);
                    return;
                }
                if (reservePrice.compareTo(startingPrice) < 0) {
                    req.setAttribute("errorMessage", "Giá sàn (Reserve Price) phải lớn hơn hoặc bằng giá khởi điểm (BR09).");
                    doGet(req, resp);
                    return;
                }

                boolean isNew = (auctionIdStr == null || auctionIdStr.trim().isEmpty());
                Auction auction = new Auction();
                auction.setStartTime(new Timestamp(parsedStart.getTime()));
                auction.setEndTime(new Timestamp(parsedEnd.getTime()));
                auction.setStartingPrice(startingPrice);
                auction.setReservePrice(reservePrice);
                auction.setMinBidIncrement(minIncrement);

                long now = System.currentTimeMillis();
                if (parsedStart.getTime() <= now && parsedEnd.getTime() > now) {
                    auction.setStatus("ACTIVE");
                } else if (parsedStart.getTime() > now) {
                    auction.setStatus("SCHEDULED");
                } else {
                    auction.setStatus("CLOSED");
                }

                if (isNew) {
                    auction.setItemId(Long.parseLong(itemIdStr.trim()));
                    auction.setCreatedBy(currentUser.getUserId());
                    boolean success = auctionDAO.createAuction(auction);
                    if (success) {
                        resp.sendRedirect(req.getContextPath() + "/admin/auctions?msg=auction_created");
                        return;
                    }
                } else {
                    auction.setAuctionId(Long.parseLong(auctionIdStr.trim()));
                    boolean success = auctionDAO.updateAuction(auction);
                    if (success) {
                        resp.sendRedirect(req.getContextPath() + "/admin/auctions?msg=auction_updated");
                        return;
                    }
                }
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Lỗi dữ liệu: " + e.getMessage());
                doGet(req, resp);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/admin/auctions?error=action_failed");
        }
    }
}
