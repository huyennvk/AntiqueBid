package com.huyen.antiquebid.dao;

import com.huyen.antiquebid.model.Auction;
import com.huyen.antiquebid.model.Bid;
import com.huyen.antiquebid.model.Watchlist;
import com.huyen.antiquebid.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AuctionDAO {
    private static final Logger LOGGER = Logger.getLogger(AuctionDAO.class.getName());

    public List<Auction> getLiveAuctions(Long categoryId, String keyword) {
        checkAndUpdateAuctionStatuses();
        return queryAuctions("WHERE a.status = 'ACTIVE' ", categoryId, keyword, "ORDER BY a.end_time ASC");
    }

    public List<Auction> getUpcomingAuctions(Long categoryId, String keyword) {
        checkAndUpdateAuctionStatuses();
        return queryAuctions("WHERE a.status = 'SCHEDULED' ", categoryId, keyword, "ORDER BY a.start_time ASC");
    }

    public List<Auction> getUpcomingAuctions() {
        return getUpcomingAuctions(null, null);
    }

    public List<Auction> getClosedAuctions(Long categoryId, String keyword) {
        checkAndUpdateAuctionStatuses();
        return queryAuctions("WHERE a.status IN ('ENDED_SOLD', 'ENDED_RESERVE_NOT_MET', 'ENDED_NO_BIDS') ", categoryId, keyword, "ORDER BY a.end_time DESC");
    }

    public List<Auction> getClosedAuctions() {
        return getClosedAuctions(null, null);
    }

    public List<Auction> getAllAuctionsAdmin(String statusFilter) {
        checkAndUpdateAuctionStatuses();
        String where = (statusFilter != null && !statusFilter.isEmpty()) ? "WHERE a.status = '" + statusFilter + "' " : "";
        return queryAuctions(where, null, null, "ORDER BY a.auction_id DESC");
    }

    public Auction getAuctionById(Long auctionId) {
        checkAndUpdateAuctionStatuses();
        String sql = "SELECT a.auction_id, a.item_id, a.created_by, a.start_time, a.end_time, " +
                     "       a.starting_price, a.reserve_price, a.min_bid_increment, a.current_highest_bid, " +
                     "       a.highest_bidder_id, a.status, a.is_extended, a.is_paid, a.created_at, " +
                     "       ai.item_code, ai.name as item_name, ai.description as item_description, " +
                     "       ai.material as item_material, ai.dimensions as item_dimensions, " +
                     "       c.name as category_name, " +
                     "       u.full_name as highest_bidder_name, u.phone as highest_bidder_phone, " +
                     "       (SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id AND status = 'VALID') as total_bids, " +
                     "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
                     "FROM auctions a " +
                     "JOIN antique_items ai ON a.item_id = ai.item_id " +
                     "JOIN categories c ON ai.category_id = c.category_id " +
                     "LEFT JOIN users u ON a.highest_bidder_id = u.user_id " +
                     "WHERE a.auction_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, auctionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToAuction(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy thông tin phiên đấu giá ID: " + auctionId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public List<Bid> getBidsByAuctionId(Long auctionId) {
        List<Bid> list = new ArrayList<>();
        String sql = "SELECT b.bid_id, b.auction_id, b.bidder_id, b.bid_amount, b.bid_time, b.status, " +
                     "       u.full_name as bidder_name, u.phone as bidder_phone " +
                     "FROM bids b " +
                     "JOIN users u ON b.bidder_id = u.user_id " +
                     "WHERE b.auction_id = ? AND b.status = 'VALID' " +
                     "ORDER BY b.bid_amount DESC, b.bid_time DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, auctionId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Bid bid = new Bid();
                bid.setBidId(rs.getLong("bid_id"));
                bid.setAuctionId(rs.getLong("auction_id"));
                bid.setBidderId(rs.getLong("bidder_id"));
                bid.setBidAmount(rs.getBigDecimal("bid_amount"));
                bid.setBidTime(rs.getTimestamp("bid_time"));
                bid.setStatus(rs.getString("status"));
                bid.setBidderName(rs.getString("bidder_name"));
                bid.setBidderPhone(rs.getString("bidder_phone"));
                list.add(bid);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy lịch sử đặt giá", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * BR13, BR14, BR15: Atomic bid placement
     */
    public synchronized BidResult placeBid(Long auctionId, Long bidderId, BigDecimal amount) {
        Connection conn = null;
        PreparedStatement psLock = null;
        PreparedStatement psCheckBidder = null;
        PreparedStatement psInsertBid = null;
        PreparedStatement psUpdateAuction = null;
        ResultSet rsAuction = null;
        ResultSet rsBidder = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Check bidder KYC and lock status (BR03, BR04)
            String sqlBidder = "SELECT u.is_locked, bp.kyc_status, bp.violation_count " +
                               "FROM users u " +
                               "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                               "WHERE u.user_id = ?";
            psCheckBidder = conn.prepareStatement(sqlBidder);
            psCheckBidder.setLong(1, bidderId);
            rsBidder = psCheckBidder.executeQuery();
            if (!rsBidder.next()) {
                return new BidResult(false, "Không tìm thấy tài khoản người đấu giá.");
            }
            if (rsBidder.getBoolean("is_locked")) {
                return new BidResult(false, "Tài khoản của bạn đã bị khóa.");
            }
            String kyc = rsBidder.getString("kyc_status");
            if (!"VERIFIED".equalsIgnoreCase(kyc)) {
                return new BidResult(false, "Bạn cần xác minh danh tính (KYC) thành công trước khi tham gia đấu giá.");
            }
            if (rsBidder.getInt("violation_count") >= 3) {
                return new BidResult(false, "Bạn đã vi phạm quá hạn thanh toán 3 lần nên quyền đấu giá bị đình chỉ.");
            }

            // 2. Lock & check auction (BR13)
            String sqlLock = "SELECT auction_id, start_time, end_time, starting_price, min_bid_increment, " +
                             "       current_highest_bid, highest_bidder_id, status " +
                             "FROM auctions WITH (UPDLOCK, ROWLOCK) WHERE auction_id = ?";
            psLock = conn.prepareStatement(sqlLock);
            psLock.setLong(1, auctionId);
            rsAuction = psLock.executeQuery();
            if (!rsAuction.next()) {
                conn.rollback();
                return new BidResult(false, "Phiên đấu giá không tồn tại.");
            }

            String status = rsAuction.getString("status");
            Timestamp startTime = rsAuction.getTimestamp("start_time");
            Timestamp endTime = rsAuction.getTimestamp("end_time");
            long now = System.currentTimeMillis();

            if (!"ACTIVE".equalsIgnoreCase(status) || startTime.getTime() > now || endTime.getTime() <= now) {
                conn.rollback();
                return new BidResult(false, "Phiên đấu giá chưa bắt đầu hoặc đã kết thúc.");
            }

            Long currentLeaderId = rsAuction.getLong("highest_bidder_id");
            if (!rsAuction.wasNull() && currentLeaderId != null && currentLeaderId.equals(bidderId)) {
                conn.rollback();
                return new BidResult(false, "Bạn đang là người trả giá cao nhất. Không được tự nâng giá chính mình (BR14).");
            }

            BigDecimal startingPrice = rsAuction.getBigDecimal("starting_price");
            BigDecimal minIncrement = rsAuction.getBigDecimal("min_bid_increment");
            BigDecimal currentHighest = rsAuction.getBigDecimal("current_highest_bid");

            BigDecimal minAllowed;
            if (currentHighest == null || currentHighest.compareTo(BigDecimal.ZERO) == 0) {
                minAllowed = startingPrice;
            } else {
                minAllowed = currentHighest.add(minIncrement);
            }

            if (amount.compareTo(minAllowed) < 0) {
                conn.rollback();
                return new BidResult(false, "Mức giá phải tối thiểu là " + minAllowed + " VNĐ.");
            }

            // 3. Insert into bids
            String sqlInsert = "INSERT INTO bids (auction_id, bidder_id, bid_amount, bid_time, status) " +
                               "VALUES (?, ?, ?, GETDATE(), 'VALID')";
            psInsertBid = conn.prepareStatement(sqlInsert);
            psInsertBid.setLong(1, auctionId);
            psInsertBid.setLong(2, bidderId);
            psInsertBid.setBigDecimal(3, amount);
            psInsertBid.executeUpdate();

            // 4. Update auction & anti-sniping extension if within 2 minutes of end
            boolean extend = false;
            long timeLeftMillis = endTime.getTime() - now;
            Timestamp newEndTime = endTime;
            if (timeLeftMillis < 2 * 60 * 1000) { // < 2 phút
                newEndTime = new Timestamp(endTime.getTime() + 3 * 60 * 1000); // gia hạn thêm 3 phút
                extend = true;
            }

            String sqlUpdate = "UPDATE auctions SET current_highest_bid = ?, highest_bidder_id = ?, end_time = ?, is_extended = ? WHERE auction_id = ?";
            psUpdateAuction = conn.prepareStatement(sqlUpdate);
            psUpdateAuction.setBigDecimal(1, amount);
            psUpdateAuction.setLong(2, bidderId);
            psUpdateAuction.setTimestamp(3, newEndTime);
            psUpdateAuction.setBoolean(4, extend);
            psUpdateAuction.setLong(5, auctionId);
            psUpdateAuction.executeUpdate();

            conn.commit();
            return new BidResult(true, "Đặt giá thành công! Mức giá mới: " + amount + " VNĐ.", amount, newEndTime);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi khi đặt giá", e);
            return new BidResult(false, "Lỗi hệ thống khi đặt giá: " + e.getMessage());
        } finally {
            DBUtil.close(rsAuction, rsBidder, psLock, psCheckBidder, psInsertBid, psUpdateAuction, conn);
        }
    }

    public boolean createAuction(Auction auction) {
        String sqlAuction = "INSERT INTO auctions (item_id, created_by, start_time, end_time, starting_price, reserve_price, min_bid_increment, current_highest_bid, status) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlItem = "UPDATE antique_items SET status = 'IN_AUCTION' WHERE item_id = ?";

        Connection conn = null;
        PreparedStatement psAuction = null;
        PreparedStatement psItem = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psAuction = conn.prepareStatement(sqlAuction, Statement.RETURN_GENERATED_KEYS);
            psAuction.setLong(1, auction.getItemId());
            psAuction.setLong(2, auction.getCreatedBy() != null ? auction.getCreatedBy() : 1L);
            psAuction.setTimestamp(3, auction.getStartTime());
            psAuction.setTimestamp(4, auction.getEndTime());
            psAuction.setBigDecimal(5, auction.getStartingPrice());
            psAuction.setBigDecimal(6, auction.getReservePrice());
            psAuction.setBigDecimal(7, auction.getMinBidIncrement());
            psAuction.setBigDecimal(8, auction.getStartingPrice());
            psAuction.setString(9, auction.getStatus() != null ? auction.getStatus() : "SCHEDULED");
            psAuction.executeUpdate();

            rs = psAuction.getGeneratedKeys();
            if (rs.next()) {
                auction.setAuctionId(rs.getLong(1));

                psItem = conn.prepareStatement(sqlItem);
                psItem.setLong(1, auction.getItemId());
                psItem.executeUpdate();

                conn.commit();
                return true;
            }
            conn.rollback();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi tạo phiên đấu giá", e);
        } finally {
            DBUtil.close(rs, psAuction, psItem, conn);
        }
        return false;
    }

    public boolean updateAuction(Auction auction) {
        String sql = "UPDATE auctions SET start_time = ?, end_time = ?, starting_price = ?, reserve_price = ?, min_bid_increment = ? " +
                     "WHERE auction_id = ? AND status IN ('DRAFT', 'SCHEDULED')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setTimestamp(1, auction.getStartTime());
            ps.setTimestamp(2, auction.getEndTime());
            ps.setBigDecimal(3, auction.getStartingPrice());
            ps.setBigDecimal(4, auction.getReservePrice());
            ps.setBigDecimal(5, auction.getMinBidIncrement());
            ps.setLong(6, auction.getAuctionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật phiên đấu giá ID: " + auction.getAuctionId(), e);
        } finally {
            DBUtil.close(ps, conn);
        }
        return false;
    }

    public boolean cancelAuction(Long auctionId, String reason, Long adminId) {
        String sqlAuction = "UPDATE auctions SET status = 'CANCELLED' WHERE auction_id = ?";
        String sqlItem = "UPDATE antique_items SET status = 'AVAILABLE' WHERE item_id = (SELECT item_id FROM auctions WHERE auction_id = ?)";
        String sqlAudit = "INSERT INTO audit_logs (user_id, action, target_entity, target_id, details) VALUES (?, 'CANCEL_AUCTION', 'auctions', ?, ?)";

        Connection conn = null;
        PreparedStatement psAuction = null;
        PreparedStatement psItem = null;
        PreparedStatement psAudit = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psAuction = conn.prepareStatement(sqlAuction);
            psAuction.setLong(1, auctionId);
            psAuction.executeUpdate();

            psItem = conn.prepareStatement(sqlItem);
            psItem.setLong(1, auctionId);
            psItem.executeUpdate();

            psAudit = conn.prepareStatement(sqlAudit);
            psAudit.setLong(1, adminId != null ? adminId : 1L);
            psAudit.setLong(2, auctionId);
            psAudit.setString(3, "Hủy phiên đấu giá. Lý do: " + reason);
            psAudit.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi hủy phiên đấu giá: " + auctionId, e);
        } finally {
            DBUtil.close(psAuction, psItem, psAudit, conn);
        }
        return false;
    }

    public void checkAndUpdateAuctionStatuses() {
        // 1. Move SCHEDULED to ACTIVE when start_time reached
        String sqlActivate = "UPDATE auctions SET status = 'ACTIVE' WHERE status = 'SCHEDULED' AND start_time <= GETDATE() AND end_time > GETDATE()";

        // 2. Find ACTIVE auctions that passed end_time to CLOSE
        String sqlExpired = "SELECT auction_id, item_id, current_highest_bid, highest_bidder_id, reserve_price " +
                            "FROM auctions WHERE status = 'ACTIVE' AND end_time <= GETDATE()";

        Connection conn = null;
        Statement stmt = null;
        PreparedStatement psClose = null;
        PreparedStatement psCreateOrder = null;
        PreparedStatement psUpdateItemSold = null;
        PreparedStatement psUpdateItemUnsold = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            stmt.executeUpdate(sqlActivate);

            rs = stmt.executeQuery(sqlExpired);
            List<ExpiredAuctionInfo> expired = new ArrayList<>();
            while (rs.next()) {
                ExpiredAuctionInfo info = new ExpiredAuctionInfo();
                info.auctionId = rs.getLong("auction_id");
                info.itemId = rs.getLong("item_id");
                info.highestBid = rs.getBigDecimal("current_highest_bid");
                long bidderId = rs.getLong("highest_bidder_id");
                info.highestBidderId = rs.wasNull() ? null : bidderId;
                info.reservePrice = rs.getBigDecimal("reserve_price");
                expired.add(info);
            }

            for (ExpiredAuctionInfo info : expired) {
                // Check if reserve price met and valid bidder exists (BR16, BR17)
                boolean won = (info.highestBidderId != null && info.highestBid != null &&
                              (info.reservePrice == null || info.highestBid.compareTo(info.reservePrice) >= 0));

                String newAuctionStatus;
                if (info.highestBidderId == null) {
                    newAuctionStatus = "ENDED_NO_BIDS";
                } else if (info.reservePrice != null && info.highestBid.compareTo(info.reservePrice) < 0) {
                    newAuctionStatus = "ENDED_RESERVE_NOT_MET";
                } else {
                    newAuctionStatus = "ENDED_SOLD";
                }

                psClose = conn.prepareStatement("UPDATE auctions SET status = ?, closed_at = GETDATE() WHERE auction_id = ?");
                psClose.setString(1, newAuctionStatus);
                psClose.setLong(2, info.auctionId);
                psClose.executeUpdate();

                if (won) {
                    // Create Order (BR17) with 48h payment deadline
                    String sqlOrder = "INSERT INTO orders (auction_id, bidder_id, final_price, status, payment_deadline) " +
                                      "VALUES (?, ?, ?, 'PENDING_PAYMENT', DATEADD(HOUR, 48, GETDATE()))";
                    psCreateOrder = conn.prepareStatement(sqlOrder);
                    psCreateOrder.setLong(1, info.auctionId);
                    psCreateOrder.setLong(2, info.highestBidderId);
                    psCreateOrder.setBigDecimal(3, info.highestBid);
                    psCreateOrder.executeUpdate();

                    psUpdateItemSold = conn.prepareStatement("UPDATE antique_items SET status = 'RESERVED_PENDING_PAYMENT' WHERE item_id = ?");
                    psUpdateItemSold.setLong(1, info.itemId);
                    psUpdateItemSold.executeUpdate();
                } else {
                    psUpdateItemUnsold = conn.prepareStatement("UPDATE antique_items SET status = 'AVAILABLE' WHERE item_id = ?");
                    psUpdateItemUnsold.setLong(1, info.itemId);
                    psUpdateItemUnsold.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Lỗi kiểm tra tự động trạng thái phiên", e);
        } finally {
            DBUtil.close(rs, stmt, psClose, psCreateOrder, psUpdateItemSold, psUpdateItemUnsold, conn);
        }
    }

    public List<Watchlist> getWatchlistByUserId(Long userId) {
        List<Watchlist> list = new ArrayList<>();
        String sql = "SELECT wi.watchlist_item_id as watchlist_id, w.bidder_id as user_id, wi.auction_id, wi.added_at, " +
                     "       ai.item_code, ai.name as item_name, ai.material as item_material, " +
                     "       a.current_highest_bid, a.starting_price, a.end_time, a.status as auction_status, " +
                     "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
                     "FROM dbo.watchlists w " +
                     "JOIN dbo.watchlist_items wi ON w.watchlist_id = wi.watchlist_id " +
                     "JOIN dbo.auctions a ON wi.auction_id = a.auction_id " +
                     "JOIN dbo.antique_items ai ON a.item_id = ai.item_id " +
                     "WHERE w.bidder_id = ? " +
                     "ORDER BY wi.added_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Watchlist w = new Watchlist();
                w.setWatchlistId(rs.getLong("watchlist_id"));
                w.setUserId(rs.getLong("user_id"));
                w.setAuctionId(rs.getLong("auction_id"));
                w.setAddedAt(rs.getTimestamp("added_at"));
                w.setItemCode(rs.getString("item_code"));
                w.setItemName(rs.getString("item_name"));
                w.setItemMaterial(rs.getString("item_material"));
                w.setCurrentHighestBid(rs.getBigDecimal("current_highest_bid"));
                w.setStartingPrice(rs.getBigDecimal("starting_price"));
                w.setEndTime(rs.getTimestamp("end_time"));
                w.setAuctionStatus(rs.getString("auction_status"));
                w.setPrimaryImageUrl(rs.getString("primary_image_url"));
                list.add(w);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách theo dõi", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public boolean toggleWatchlist(Long userId, Long auctionId) {
        String sqlFindWatchlist = "SELECT watchlist_id FROM dbo.watchlists WHERE bidder_id = ?";
        String sqlCreateWatchlist = "INSERT INTO dbo.watchlists (bidder_id, total_items, updated_at) VALUES (?, 0, GETDATE())";
        String sqlCheckItem = "SELECT watchlist_item_id FROM dbo.watchlist_items WHERE watchlist_id = ? AND auction_id = ?";
        String sqlInsertItem = "INSERT INTO dbo.watchlist_items (watchlist_id, auction_id, added_at) VALUES (?, ?, GETDATE())";
        String sqlDeleteItem = "DELETE FROM dbo.watchlist_items WHERE watchlist_id = ? AND auction_id = ?";
        String sqlUpdateCount = "UPDATE dbo.watchlists SET total_items = (SELECT COUNT(*) FROM dbo.watchlist_items WHERE watchlist_id = ?), updated_at = GETDATE() WHERE watchlist_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            Long watchlistId = null;
            ps = conn.prepareStatement(sqlFindWatchlist);
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                watchlistId = rs.getLong(1);
            }
            rs.close();
            ps.close();

            if (watchlistId == null) {
                ps = conn.prepareStatement(sqlCreateWatchlist, java.sql.Statement.RETURN_GENERATED_KEYS);
                ps.setLong(1, userId);
                ps.executeUpdate();
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    watchlistId = rs.getLong(1);
                }
                rs.close();
                ps.close();
            }

            if (watchlistId == null) return false;

            boolean exists = false;
            ps = conn.prepareStatement(sqlCheckItem);
            ps.setLong(1, watchlistId);
            ps.setLong(2, auctionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                exists = true;
            }
            rs.close();
            ps.close();

            boolean added;
            if (exists) {
                ps = conn.prepareStatement(sqlDeleteItem);
                ps.setLong(1, watchlistId);
                ps.setLong(2, auctionId);
                ps.executeUpdate();
                ps.close();
                added = false;
            } else {
                ps = conn.prepareStatement(sqlInsertItem);
                ps.setLong(1, watchlistId);
                ps.setLong(2, auctionId);
                ps.executeUpdate();
                ps.close();
                added = true;
            }

            ps = conn.prepareStatement(sqlUpdateCount);
            ps.setLong(1, watchlistId);
            ps.setLong(2, watchlistId);
            ps.executeUpdate();
            return added;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi theo dõi phiên", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return false;
    }

    public boolean isWatched(Long userId, Long auctionId) {
        String sql = "SELECT 1 FROM dbo.watchlists w " +
                     "JOIN dbo.watchlist_items wi ON w.watchlist_id = wi.watchlist_id " +
                     "WHERE w.bidder_id = ? AND wi.auction_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            ps.setLong(2, auctionId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra theo dõi", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return false;
    }

    private List<Auction> queryAuctions(String whereClause, Long categoryId, String keyword, String orderBy) {
        List<Auction> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.auction_id, a.item_id, a.created_by, a.start_time, a.end_time, " +
            "       a.starting_price, a.reserve_price, a.min_bid_increment, a.current_highest_bid, " +
            "       a.highest_bidder_id, a.status, a.is_extended, a.is_paid, a.created_at, " +
            "       ai.item_code, ai.name as item_name, ai.description as item_description, " +
            "       ai.material as item_material, ai.dimensions as item_dimensions, " +
            "       c.name as category_name, " +
            "       u.full_name as highest_bidder_name, u.phone as highest_bidder_phone, " +
            "       (SELECT COUNT(*) FROM bids WHERE auction_id = a.auction_id AND status = 'VALID') as total_bids, " +
            "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
            "FROM auctions a " +
            "JOIN antique_items ai ON a.item_id = ai.item_id " +
            "JOIN categories c ON ai.category_id = c.category_id " +
            "LEFT JOIN users u ON a.highest_bidder_id = u.user_id "
        );

        sql.append(whereClause.isEmpty() ? "WHERE 1=1 " : whereClause);

        if (categoryId != null && categoryId > 0) {
            sql.append("AND ai.category_id = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (ai.name LIKE ? OR ai.item_code LIKE ? OR ai.material LIKE ?) ");
        }
        sql.append(orderBy);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (categoryId != null && categoryId > 0) {
                ps.setLong(idx++, categoryId);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(idx++, searchPattern);
                ps.setString(idx++, searchPattern);
                ps.setString(idx++, searchPattern);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAuction(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn phiên đấu giá", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    private Auction mapResultSetToAuction(ResultSet rs) throws SQLException {
        Auction a = new Auction();
        a.setAuctionId(rs.getLong("auction_id"));
        a.setItemId(rs.getLong("item_id"));
        a.setCreatedBy(rs.getLong("created_by"));
        a.setStartTime(rs.getTimestamp("start_time"));
        a.setEndTime(rs.getTimestamp("end_time"));
        a.setStartingPrice(rs.getBigDecimal("starting_price"));
        a.setReservePrice(rs.getBigDecimal("reserve_price"));
        a.setMinBidIncrement(rs.getBigDecimal("min_bid_increment"));
        a.setCurrentHighestBid(rs.getBigDecimal("current_highest_bid"));
        long hId = rs.getLong("highest_bidder_id");
        if (!rs.wasNull()) a.setHighestBidderId(hId);
        a.setStatus(rs.getString("status"));
        a.setExtended(rs.getBoolean("is_extended"));
        a.setPaid(rs.getBoolean("is_paid"));
        a.setCreatedAt(rs.getTimestamp("created_at"));

        a.setItemCode(rs.getString("item_code"));
        a.setItemName(rs.getString("item_name"));
        a.setItemDescription(rs.getString("item_description"));
        a.setItemMaterial(rs.getString("item_material"));
        a.setItemDimensions(rs.getString("item_dimensions"));
        a.setCategoryName(rs.getString("category_name"));
        a.setHighestBidderName(rs.getString("highest_bidder_name"));
        a.setHighestBidderPhone(rs.getString("highest_bidder_phone"));
        a.setTotalBids(rs.getInt("total_bids"));
        a.setPrimaryImageUrl(rs.getString("primary_image_url"));
        return a;
    }

    public static class BidResult {
        public final boolean success;
        public final String message;
        public final BigDecimal newAmount;
        public final Timestamp newEndTime;

        public BidResult(boolean success, String message) {
            this(success, message, null, null);
        }

        public BidResult(boolean success, String message, BigDecimal newAmount, Timestamp newEndTime) {
            this.success = success;
            this.message = message;
            this.newAmount = newAmount;
            this.newEndTime = newEndTime;
        }
    }

    private static class ExpiredAuctionInfo {
        Long auctionId;
        Long itemId;
        BigDecimal highestBid;
        Long highestBidderId;
        BigDecimal reservePrice;
    }
}
