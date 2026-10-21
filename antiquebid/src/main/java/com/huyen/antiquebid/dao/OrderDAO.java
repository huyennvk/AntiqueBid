package com.huyen.antiquebid.dao;

import com.huyen.antiquebid.model.Dispute;
import com.huyen.antiquebid.model.Order;
import com.huyen.antiquebid.model.Payment;
import com.huyen.antiquebid.model.Shipment;
import com.huyen.antiquebid.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderDAO {
    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    public List<Order> getOrdersByBidderId(Long bidderId) {
        return queryOrders("WHERE o.bidder_id = ? ", bidderId, "ORDER BY o.order_id DESC");
    }

    public List<Order> getAllOrdersAdmin(String statusFilter) {
        String where = (statusFilter != null && !statusFilter.isEmpty()) ? "WHERE o.status = '" + statusFilter + "' " : "";
        return queryOrders(where, null, "ORDER BY o.order_id DESC");
    }

    public Order getOrderById(Long orderId) {
        List<Order> list = queryOrders("WHERE o.order_id = ? ", orderId, "");
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean processPayment(Long orderId, String method, String transRef) {
        String sqlOrder = "UPDATE orders SET status = 'PAID', updated_at = GETDATE() WHERE order_id = ? AND status = 'PENDING_PAYMENT'";
        String sqlPayment = "INSERT INTO payments (order_id, amount, payment_method, transaction_ref, status) " +
                            "VALUES (?, (SELECT final_price FROM orders WHERE order_id = ?), ?, ?, 'SUCCESS')";
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psPayment = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setLong(1, orderId);
            int rows = psOrder.executeUpdate();
            if (rows <= 0) {
                conn.rollback();
                return false;
            }

            psPayment = conn.prepareStatement(sqlPayment);
            psPayment.setLong(1, orderId);
            psPayment.setLong(2, orderId);
            psPayment.setString(3, method);
            psPayment.setString(4, transRef);
            psPayment.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi xử lý thanh toán đơn: " + orderId, e);
        } finally {
            DBUtil.close(psOrder, psPayment, conn);
        }
        return false;
    }

    public boolean createShipment(Long orderId, String carrier, String trackingNo) {
        String sqlOrder = "UPDATE orders SET status = 'SHIPPING', updated_at = GETDATE() WHERE order_id = ?";
        String sqlShipment = "INSERT INTO shipments (order_id, carrier_name, tracking_number, status, shipped_at) " +
                             "VALUES (?, ?, ?, 'IN_TRANSIT', GETDATE())";
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psShipment = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setLong(1, orderId);
            psOrder.executeUpdate();

            psShipment = conn.prepareStatement(sqlShipment);
            psShipment.setLong(1, orderId);
            psShipment.setString(2, carrier);
            psShipment.setString(3, trackingNo);
            psShipment.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi tạo vận đơn cho đơn hàng: " + orderId, e);
        } finally {
            DBUtil.close(psOrder, psShipment, conn);
        }
        return false;
    }

    public boolean updateShipmentDelivered(Long orderId) {
        String sqlOrder = "UPDATE orders SET status = 'DELIVERED', updated_at = GETDATE() WHERE order_id = ?";
        String sqlShipment = "UPDATE shipments SET status = 'DELIVERED', delivered_at = GETDATE() WHERE order_id = ?";
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psShipment = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setLong(1, orderId);
            psOrder.executeUpdate();

            psShipment = conn.prepareStatement(sqlShipment);
            psShipment.setLong(1, orderId);
            psShipment.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật giao hàng thành công: " + orderId, e);
        } finally {
            DBUtil.close(psOrder, psShipment, conn);
        }
        return false;
    }

    public boolean createDispute(Long orderId, Long bidderId, String reason) {
        String sql = "INSERT INTO disputes (order_id, bidder_id, reason, status) VALUES (?, ?, ?, 'OPEN')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, orderId);
            ps.setLong(2, bidderId);
            ps.setString(3, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo khiếu nại cho đơn: " + orderId, e);
        } finally {
            DBUtil.close(ps, conn);
        }
        return false;
    }

    public List<Dispute> getAllDisputesAdmin(String statusFilter) {
        List<Dispute> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT d.dispute_id, d.order_id, d.bidder_id, d.reason, d.status, d.resolution_note, " +
            "       d.resolved_by, d.resolved_at, d.created_at, " +
            "       u.full_name as bidder_name, u.phone as bidder_phone, " +
            "       ai.name as item_name, o.final_price " +
            "FROM disputes d " +
            "JOIN orders o ON d.order_id = o.order_id " +
            "JOIN users u ON d.bidder_id = u.user_id " +
            "JOIN auctions a ON o.auction_id = a.auction_id " +
            "JOIN antique_items ai ON a.item_id = ai.item_id "
        );
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("WHERE d.status = ? ");
        }
        sql.append("ORDER BY d.created_at DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ps.setString(1, statusFilter);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Dispute d = new Dispute();
                d.setDisputeId(rs.getLong("dispute_id"));
                d.setOrderId(rs.getLong("order_id"));
                d.setBidderId(rs.getLong("bidder_id"));
                d.setReason(rs.getString("reason"));
                d.setStatus(rs.getString("status"));
                d.setResolutionNote(rs.getString("resolution_note"));
                long resBy = rs.getLong("resolved_by");
                if (!rs.wasNull()) d.setResolvedBy(resBy);
                d.setResolvedAt(rs.getTimestamp("resolved_at"));
                d.setCreatedAt(rs.getTimestamp("created_at"));
                d.setBidderName(rs.getString("bidder_name"));
                d.setBidderPhone(rs.getString("bidder_phone"));
                d.setItemName(rs.getString("item_name"));
                d.setFinalPrice(rs.getDouble("final_price"));
                list.add(d);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách khiếu nại", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public boolean resolveDispute(Long disputeId, Long orderId, boolean refund, String note, Long adminId) {
        String newDisputeStatus = refund ? "RESOLVED_REFUND" : "REJECTED";
        String newOrderStatus = refund ? "REFUNDED" : "DELIVERED";

        String sqlDispute = "UPDATE disputes SET status = ?, resolution_note = ?, resolved_by = ?, resolved_at = GETDATE() WHERE dispute_id = ?";
        String sqlOrder = "UPDATE orders SET status = ?, updated_at = GETDATE() WHERE order_id = ?";

        Connection conn = null;
        PreparedStatement psDispute = null;
        PreparedStatement psOrder = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psDispute = conn.prepareStatement(sqlDispute);
            psDispute.setString(1, newDisputeStatus);
            psDispute.setString(2, note);
            psDispute.setLong(3, adminId != null ? adminId : 1L);
            psDispute.setLong(4, disputeId);
            psDispute.executeUpdate();

            psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setString(1, newOrderStatus);
            psOrder.setLong(2, orderId);
            psOrder.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi xử lý khiếu nại: " + disputeId, e);
        } finally {
            DBUtil.close(psDispute, psOrder, conn);
        }
        return false;
    }

    private List<Order> queryOrders(String whereClause, Long paramId, String orderBy) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.order_id, o.auction_id, o.bidder_id, o.final_price, o.status, " +
            "       o.payment_deadline, o.created_at, o.updated_at, " +
            "       u.full_name as bidder_name, u.email as bidder_email, u.phone as bidder_phone, " +
            "       bp.shipping_address, " +
            "       ai.item_id, ai.item_code, ai.name as item_name, " +
            "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url, " +
            "       p.payment_method, p.transaction_ref, " +
            "       s.carrier_name, s.tracking_number, s.status as shipment_status " +
            "FROM orders o " +
            "JOIN users u ON o.bidder_id = u.user_id " +
            "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
            "JOIN auctions a ON o.auction_id = a.auction_id " +
            "JOIN antique_items ai ON a.item_id = ai.item_id " +
            "LEFT JOIN payments p ON o.order_id = p.order_id " +
            "LEFT JOIN shipments s ON o.order_id = s.order_id "
        );

        sql.append(whereClause.isEmpty() ? "WHERE 1=1 " : whereClause);
        sql.append(orderBy);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (paramId != null) {
                ps.setLong(1, paramId);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getLong("order_id"));
                order.setAuctionId(rs.getLong("auction_id"));
                order.setBidderId(rs.getLong("bidder_id"));
                order.setFinalPrice(rs.getBigDecimal("final_price"));
                order.setStatus(rs.getString("status"));
                order.setPaymentDeadline(rs.getTimestamp("payment_deadline"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                order.setUpdatedAt(rs.getTimestamp("updated_at"));

                order.setBidderName(rs.getString("bidder_name"));
                order.setBidderEmail(rs.getString("bidder_email"));
                order.setBidderPhone(rs.getString("bidder_phone"));
                order.setShippingAddress(rs.getString("shipping_address"));

                order.setItemId(rs.getLong("item_id"));
                order.setItemCode(rs.getString("item_code"));
                order.setItemName(rs.getString("item_name"));
                order.setPrimaryImageUrl(rs.getString("primary_image_url"));

                order.setPaymentMethod(rs.getString("payment_method"));
                order.setTransactionRef(rs.getString("transaction_ref"));
                order.setCarrierName(rs.getString("carrier_name"));
                order.setTrackingNumber(rs.getString("tracking_number"));
                order.setShipmentStatus(rs.getString("shipment_status"));
                list.add(order);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy vấn đơn hàng", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }
}
