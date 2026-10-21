package com.huyen.antiquebid.dao;

import com.huyen.antiquebid.model.AuditLog;
import com.huyen.antiquebid.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ReportDAO {
    private static final Logger LOGGER = Logger.getLogger(ReportDAO.class.getName());

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();

            // Total users
            rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'BIDDER'");
            if (rs.next()) stats.put("totalBidders", rs.getInt(1));
            rs.close();

            // Verified bidders
            rs = stmt.executeQuery("SELECT COUNT(*) FROM bidder_profiles WHERE kyc_status = 'VERIFIED'");
            if (rs.next()) stats.put("verifiedBidders", rs.getInt(1));
            rs.close();

            // Pending KYC
            rs = stmt.executeQuery("SELECT COUNT(*) FROM bidder_profiles WHERE kyc_status = 'PENDING'");
            if (rs.next()) stats.put("pendingKyc", rs.getInt(1));
            rs.close();

            // Total antique items
            rs = stmt.executeQuery("SELECT COUNT(*) FROM antique_items WHERE is_archived = 0");
            if (rs.next()) stats.put("totalItems", rs.getInt(1));
            rs.close();

            // Active auctions
            rs = stmt.executeQuery("SELECT COUNT(*) FROM auctions WHERE status = 'ACTIVE'");
            if (rs.next()) stats.put("activeAuctions", rs.getInt(1));
            rs.close();

            // Total revenue
            rs = stmt.executeQuery("SELECT ISNULL(SUM(amount), 0) FROM payments WHERE status = 'SUCCESS'");
            if (rs.next()) stats.put("totalRevenue", rs.getBigDecimal(1));
            rs.close();

            // Total orders & pending orders
            rs = stmt.executeQuery("SELECT COUNT(*) FROM orders");
            if (rs.next()) stats.put("totalOrders", rs.getInt(1));
            rs.close();

            rs = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE status = 'PENDING_PAYMENT'");
            if (rs.next()) stats.put("pendingOrders", rs.getInt(1));
            rs.close();

            // Open disputes
            rs = stmt.executeQuery("SELECT COUNT(*) FROM disputes WHERE status = 'OPEN'");
            if (rs.next()) stats.put("openDisputes", rs.getInt(1));
            rs.close();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy số liệu thống kê dashboard", e);
        } finally {
            DBUtil.close(rs, stmt, conn);
        }
        return stats;
    }

    public List<AuditLog> getAuditLogs(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) l.log_id, l.user_id, l.action, l.target_entity, l.target_id, " +
                     "             l.details, l.ip_address, l.created_at, u.email as user_email " +
                     "FROM audit_logs l " +
                     "LEFT JOIN users u ON l.user_id = u.user_id " +
                     "ORDER BY l.log_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit > 0 ? limit : 50);
            rs = ps.executeQuery();
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setLogId(rs.getLong("log_id"));
                long uid = rs.getLong("user_id");
                if (!rs.wasNull()) log.setUserId(uid);
                log.setUserEmail(rs.getString("user_email"));
                log.setAction(rs.getString("action"));
                log.setTargetEntity(rs.getString("target_entity"));
                long tid = rs.getLong("target_id");
                if (!rs.wasNull()) log.setTargetId(tid);
                log.setDetails(rs.getString("details"));
                log.setIpAddress(rs.getString("ip_address"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(log);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy nhật ký hệ thống", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public void logAction(Long userId, String action, String targetEntity, Long targetId, String details, String ip) {
        String sql = "INSERT INTO audit_logs (user_id, action, target_entity, target_id, details, ip_address) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            if (userId != null) ps.setLong(1, userId); else ps.setNull(1, Types.BIGINT);
            ps.setString(2, action);
            ps.setString(3, targetEntity);
            if (targetId != null) ps.setLong(4, targetId); else ps.setNull(4, Types.BIGINT);
            ps.setString(5, details);
            ps.setString(6, ip);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Không thể ghi nhật ký hệ thống: " + action, e);
        } finally {
            DBUtil.close(ps, conn);
        }
    }
}
