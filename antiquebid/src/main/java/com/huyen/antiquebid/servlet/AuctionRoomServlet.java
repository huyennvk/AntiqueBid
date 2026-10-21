package com.huyen.antiquebid.servlet;

import com.google.gson.Gson;
import com.huyen.antiquebid.dao.AuctionDAO;
import com.huyen.antiquebid.dao.ItemDAO;
import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.AppraisalCertificate;
import com.huyen.antiquebid.model.Auction;
import com.huyen.antiquebid.model.Bid;
import com.huyen.antiquebid.model.ItemImage;
import com.huyen.antiquebid.model.ProvenanceRecord;
import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.util.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AuctionRoomServlet", urlPatterns = {"/auction-room", "/auction-bid", "/auction-status"})
public class AuctionRoomServlet extends HttpServlet {
    private final AuctionDAO auctionDAO = new AuctionDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/auction-status".equals(path)) {
            handleStatusApi(req, resp);
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/catalogue");
            return;
        }

        try {
            Long auctionId = Long.parseLong(idParam.trim());
            Auction auction = auctionDAO.getAuctionById(auctionId);
            if (auction == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng đấu giá.");
                return;
            }

            List<Bid> bids = auctionDAO.getBidsByAuctionId(auctionId);

            AntiqueItem item = null;
            AppraisalCertificate cert = null;
            ProvenanceRecord provenance = null;
            List<ItemImage> images = null;

            if (auction.getItemId() != null) {
                item = itemDAO.getItemById(auction.getItemId());
                cert = itemDAO.getAppraisalByItemId(auction.getItemId());
                provenance = itemDAO.getProvenanceByItemId(auction.getItemId());
                images = itemDAO.getItemImagesByItemId(auction.getItemId());
            }

            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
            boolean isWatched = false;
            if (currentUser != null) {
                isWatched = auctionDAO.isWatched(currentUser.getUserId(), auctionId);
            }

            req.setAttribute("auction", auction);
            req.setAttribute("item", item);
            req.setAttribute("certificate", cert);
            req.setAttribute("provenance", provenance);
            req.setAttribute("images", images);
            req.setAttribute("bids", bids);
            req.setAttribute("isWatched", isWatched);

            req.getRequestDispatcher("/WEB-INF/auction_room.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/catalogue");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/auction-bid".equals(path)) {
            handleBidApi(req, resp);
            return;
        }
        doGet(req, resp);
    }

    private void handleStatusApi(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String idParam = req.getParameter("id");
        Map<String, Object> result = new HashMap<>();

        if (idParam != null) {
            try {
                Long auctionId = Long.parseLong(idParam.trim());
                Auction auction = auctionDAO.getAuctionById(auctionId);
                if (auction != null) {
                    List<Bid> bids = auctionDAO.getBidsByAuctionId(auctionId);
                    result.put("success", true);
                    result.put("currentHighestBid", auction.getCurrentHighestBid());
                    result.put("currentHighestBidFormatted", FormatUtil.formatVND(auction.getCurrentHighestBid()));
                    result.put("highestBidderName", auction.getHighestBidderName());
                    result.put("nextMinimumBid", auction.getNextMinimumBid());
                    result.put("nextMinimumBidFormatted", FormatUtil.formatVND(auction.getNextMinimumBid()));
                    result.put("remainingSeconds", auction.getRemainingSeconds());
                    result.put("remainingFormatted", FormatUtil.formatRemainingTime(auction.getEndTime()));
                    result.put("status", auction.getStatus());
                    result.put("totalBids", auction.getTotalBids());
                    result.put("bids", bids);
                    resp.getWriter().write(gson.toJson(result));
                    return;
                }
            } catch (Exception ignored) {}
        }

        result.put("success", false);
        result.put("message", "Phiên không hợp lệ");
        resp.getWriter().write(gson.toJson(result));
    }

    private void handleBidApi(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            result.put("success", false);
            result.put("message", "Vui lòng đăng nhập để đặt giá.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        if (currentUser.isAdmin()) {
            result.put("success", false);
            result.put("message", "Admin là chủ sàn, tuyệt đối không được tham gia đặt giá (BR01).");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String auctionIdStr = req.getParameter("auctionId");
        String amountStr = req.getParameter("amount");

        if (auctionIdStr == null || amountStr == null) {
            result.put("success", false);
            result.put("message", "Thiếu dữ liệu đặt giá.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long auctionId = Long.parseLong(auctionIdStr.trim());
            BigDecimal amount = new BigDecimal(amountStr.trim().replace(".", "").replace(",", ""));

            AuctionDAO.BidResult bidResult = auctionDAO.placeBid(auctionId, currentUser.getUserId(), amount);
            result.put("success", bidResult.success);
            result.put("message", bidResult.message);
            if (bidResult.success) {
                result.put("newAmount", bidResult.newAmount);
                result.put("newAmountFormatted", FormatUtil.formatVND(bidResult.newAmount));
            }
        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("message", "Mức giá nhập vào không đúng định dạng.");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Lỗi: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(result));
    }
}
