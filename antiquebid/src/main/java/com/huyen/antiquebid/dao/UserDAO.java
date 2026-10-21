package com.huyen.antiquebid.dao;

import com.huyen.antiquebid.model.User;
import com.huyen.antiquebid.model.VerificationDocument;
import com.huyen.antiquebid.util.DBUtil;
import com.huyen.antiquebid.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User authenticate(String email, String password) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, u.role, u.is_locked, u.created_at, " +
                     "       bp.citizen_id, bp.kyc_status, bp.violation_count, bp.shipping_address " +
                     "FROM users u " +
                     "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                     "WHERE u.email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password_hash");
                if (PasswordUtil.verify(password, storedHash)) {
                    User user = mapResultSetToUser(rs);
                    return user;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi xác thực người dùng email: " + email, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public User findById(Long userId) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, u.role, u.is_locked, u.created_at, " +
                     "       bp.citizen_id, bp.kyc_status, bp.violation_count, bp.shipping_address " +
                     "FROM users u " +
                     "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                     "WHERE u.user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm người dùng ID: " + userId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, u.role, u.is_locked, u.created_at, " +
                     "       bp.citizen_id, bp.kyc_status, bp.violation_count, bp.shipping_address " +
                     "FROM users u " +
                     "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                     "WHERE u.email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm email: " + email, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public boolean register(String email, String password, String fullName, String phone, String address) {
        String sqlUser = "INSERT INTO users (email, password_hash, full_name, phone, role, is_locked) VALUES (?, ?, ?, ?, 'BIDDER', 0)";
        String sqlProfile = "INSERT INTO bidder_profiles (user_id, kyc_status, violation_count, shipping_address) VALUES (?, 'NOT_SUBMITTED', 0, ?)";

        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psProfile = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, email);
            psUser.setString(2, PasswordUtil.hashSHA256(password));
            psUser.setString(3, fullName);
            psUser.setString(4, phone);
            psUser.executeUpdate();

            rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                long userId = rs.getLong(1);
                psProfile = conn.prepareStatement(sqlProfile);
                psProfile.setLong(1, userId);
                psProfile.setString(2, address);
                psProfile.executeUpdate();

                conn.commit();
                return true;
            }
            conn.rollback();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi đăng ký tài khoản: " + email, e);
        } finally {
            DBUtil.close(rs, psUser, psProfile, conn);
        }
        return false;
    }

    public boolean updateProfile(Long userId, String fullName, String phone, String address) {
        String sqlUser = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
        String sqlProfile = "UPDATE bidder_profiles SET shipping_address = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psProfile = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, fullName);
            psUser.setString(2, phone);
            psUser.setLong(3, userId);
            psUser.executeUpdate();

            psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setString(1, address);
            psProfile.setLong(2, userId);
            psProfile.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật hồ sơ user: " + userId, e);
        } finally {
            DBUtil.close(psUser, psProfile, conn);
        }
        return false;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, u.role, u.is_locked, u.created_at, " +
                     "       bp.citizen_id, bp.kyc_status, bp.violation_count, bp.shipping_address " +
                     "FROM users u " +
                     "LEFT JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                     "ORDER BY u.user_id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách người dùng", e);
        } finally {
            DBUtil.close(rs, stmt, conn);
        }
        return list;
    }

    public boolean toggleLock(Long userId, boolean lock) {
        String sql = "UPDATE users SET is_locked = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, lock);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khóa tài khoản user: " + userId, e);
        } finally {
            DBUtil.close(ps, conn);
        }
        return false;
    }

    public boolean submitKycDocument(Long userId, String citizenId, java.sql.Date issueDate, String issuePlace, String fileUrl, String fileUrlBack) {
        String sqlDoc = "INSERT INTO verification_documents (bidder_id, doc_type, citizen_id, issue_date, issue_place, file_url, file_url_back) " +
                        "VALUES (?, 'CITIZEN_ID', ?, ?, ?, ?, ?)";
        String sqlProfile = "UPDATE bidder_profiles SET kyc_status = 'PENDING', citizen_id = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement psDoc = null;
        PreparedStatement psProfile = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psDoc = conn.prepareStatement(sqlDoc);
            psDoc.setLong(1, userId);
            psDoc.setString(2, citizenId);
            psDoc.setDate(3, issueDate);
            psDoc.setString(4, issuePlace != null ? issuePlace : "Cục Cảnh sát QLHC về TTXH");
            psDoc.setString(5, fileUrl != null ? fileUrl : "assets/images/sample_cccd_front.svg");
            psDoc.setString(6, fileUrlBack != null ? fileUrlBack : "assets/images/sample_cccd_back.svg");
            psDoc.executeUpdate();

            psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setString(1, citizenId);
            psProfile.setLong(2, userId);
            psProfile.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi nộp hồ sơ KYC: " + userId, e);
        } finally {
            DBUtil.close(psDoc, psProfile, conn);
        }
        return false;
    }

    public boolean submitKycDocument(Long userId, String docType, String fileUrl) {
        return submitKycDocument(userId, null, null, "Cục Cảnh sát QLHC về TTXH", fileUrl, "assets/images/sample_cccd_back.svg");
    }

    public List<VerificationDocument> getAllKycDocuments(String statusFilter) {
        List<VerificationDocument> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT vd.doc_id, vd.bidder_id, vd.doc_type, vd.citizen_id, vd.issue_date, vd.issue_place, " +
            "       vd.file_url, vd.file_url_back, vd.submitted_at, vd.review_note, " +
            "       u.full_name, u.email, bp.kyc_status " +
            "FROM verification_documents vd " +
            "JOIN users u ON vd.bidder_id = u.user_id " +
            "JOIN bidder_profiles bp ON u.user_id = bp.user_id "
        );
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("WHERE bp.kyc_status = ? ");
        }
        sql.append("ORDER BY vd.submitted_at DESC");

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
                VerificationDocument doc = new VerificationDocument();
                doc.setDocId(rs.getLong("doc_id"));
                doc.setBidderId(rs.getLong("bidder_id"));
                doc.setDocType(rs.getString("doc_type"));
                doc.setCitizenId(rs.getString("citizen_id"));
                doc.setIssueDate(rs.getDate("issue_date"));
                doc.setIssuePlace(rs.getString("issue_place"));
                doc.setFileUrl(rs.getString("file_url"));
                doc.setFileUrlBack(rs.getString("file_url_back"));
                doc.setSubmittedAt(rs.getTimestamp("submitted_at"));
                doc.setReviewNote(rs.getString("review_note"));
                doc.setBidderName(rs.getString("full_name"));
                doc.setBidderEmail(rs.getString("email"));
                list.add(doc);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách KYC", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public VerificationDocument getLatestKycDocument(Long userId) {
        String sql = "SELECT TOP 1 vd.doc_id, vd.bidder_id, vd.doc_type, vd.citizen_id, vd.issue_date, vd.issue_place, " +
                     "             vd.file_url, vd.file_url_back, vd.submitted_at, vd.review_note, " +
                     "             u.full_name, u.email, bp.kyc_status " +
                     "FROM verification_documents vd " +
                     "JOIN users u ON vd.bidder_id = u.user_id " +
                     "JOIN bidder_profiles bp ON u.user_id = bp.user_id " +
                     "WHERE vd.bidder_id = ? " +
                     "ORDER BY vd.submitted_at DESC, vd.doc_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                VerificationDocument doc = new VerificationDocument();
                doc.setDocId(rs.getLong("doc_id"));
                doc.setBidderId(rs.getLong("bidder_id"));
                doc.setDocType(rs.getString("doc_type"));
                doc.setCitizenId(rs.getString("citizen_id"));
                doc.setIssueDate(rs.getDate("issue_date"));
                doc.setIssuePlace(rs.getString("issue_place"));
                doc.setFileUrl(rs.getString("file_url"));
                doc.setFileUrlBack(rs.getString("file_url_back"));
                doc.setSubmittedAt(rs.getTimestamp("submitted_at"));
                doc.setReviewNote(rs.getString("review_note"));
                doc.setBidderName(rs.getString("full_name"));
                doc.setBidderEmail(rs.getString("email"));
                return doc;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy hồ sơ KYC mới nhất cho user: " + userId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public boolean reviewKyc(Long docId, Long bidderId, boolean approved, String reviewNote) {
        String newStatus = approved ? "VERIFIED" : "REJECTED";
        String sqlProfile = approved ?
            "UPDATE bidder_profiles SET kyc_status = ?, citizen_id = COALESCE((SELECT citizen_id FROM verification_documents WHERE doc_id = ?), citizen_id) WHERE user_id = ?" :
            "UPDATE bidder_profiles SET kyc_status = ? WHERE user_id = ?";
        String sqlDoc = "UPDATE verification_documents SET review_note = ? WHERE doc_id = ?";

        Connection conn = null;
        PreparedStatement psProfile = null;
        PreparedStatement psDoc = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setString(1, newStatus);
            if (approved) {
                psProfile.setLong(2, docId);
                psProfile.setLong(3, bidderId);
            } else {
                psProfile.setLong(2, bidderId);
            }
            psProfile.executeUpdate();

            psDoc = conn.prepareStatement(sqlDoc);
            psDoc.setString(1, reviewNote);
            psDoc.setLong(2, docId);
            psDoc.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi duyệt KYC: docId=" + docId, e);
        } finally {
            DBUtil.close(psProfile, psDoc, conn);
        }
        return false;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getLong("user_id"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        user.setLocked(rs.getBoolean("is_locked"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        try {
            user.setCitizenId(rs.getString("citizen_id"));
        } catch (SQLException ignored) {
        }
        user.setKycStatus(rs.getString("kyc_status"));
        user.setViolationCount(rs.getInt("violation_count"));
        user.setShippingAddress(rs.getString("shipping_address"));
        return user;
    }
}
