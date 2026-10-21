package com.huyen.antiquebid.dao;

import com.huyen.antiquebid.model.AntiqueItem;
import com.huyen.antiquebid.model.AppraisalCertificate;
import com.huyen.antiquebid.model.Category;
import com.huyen.antiquebid.model.ItemImage;
import com.huyen.antiquebid.model.ProvenanceRecord;
import com.huyen.antiquebid.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ItemDAO {
    private static final Logger LOGGER = Logger.getLogger(ItemDAO.class.getName());

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.name, c.description, c.is_active, c.created_at, c.updated_at, " +
                     "       COUNT(ai.item_id) as item_count " +
                     "FROM categories c " +
                     "LEFT JOIN antique_items ai ON c.category_id = ai.category_id AND ai.is_archived = 0 " +
                     "WHERE c.is_active = 1 " +
                     "GROUP BY c.category_id, c.name, c.description, c.is_active, c.created_at, c.updated_at " +
                     "ORDER BY c.name ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getLong("category_id"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                c.setActive(rs.getBoolean("is_active"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                c.setUpdatedAt(rs.getTimestamp("updated_at"));
                c.setItemCount(rs.getInt("item_count"));
                list.add(c);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh mục", e);
        } finally {
            DBUtil.close(rs, stmt, conn);
        }
        return list;
    }

    public List<AntiqueItem> getCatalogueItems(Long categoryId, String keyword, String statusFilter) {
        List<AntiqueItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ai.item_id, ai.item_code, ai.name, ai.description, ai.era_from, ai.era_to, " +
            "       ai.material, ai.dimensions, ai.item_condition, ai.status, ai.is_archived, ai.version, " +
            "       ai.category_id, c.name as category_name, ai.created_by, ai.created_at, ai.updated_at, " +
            "       ac.certificate_no, ac.certificate_status, ac.estimate_low, ac.estimate_high, ac.appraiser_name, " +
            "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
            "FROM antique_items ai " +
            "JOIN categories c ON ai.category_id = c.category_id " +
            "LEFT JOIN appraisal_certificates ac ON ai.item_id = ac.item_id AND ac.certificate_status = 'VALID' " +
            "WHERE ai.is_archived = 0 "
        );

        if (categoryId != null && categoryId > 0) {
            sql.append("AND ai.category_id = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (ai.name LIKE ? OR ai.item_code LIKE ? OR ai.material LIKE ?) ");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append("AND ai.status = ? ");
        }

        sql.append("ORDER BY ai.created_at DESC");

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
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToItem(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tìm kiếm danh mục hiện vật", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public AntiqueItem getItemById(Long itemId) {
        String sql = "SELECT ai.item_id, ai.item_code, ai.name, ai.description, ai.era_from, ai.era_to, " +
                     "       ai.material, ai.dimensions, ai.item_condition, ai.status, ai.is_archived, ai.version, " +
                     "       ai.category_id, c.name as category_name, ai.created_by, ai.created_at, ai.updated_at, " +
                     "       ac.certificate_no, ac.certificate_status, ac.estimate_low, ac.estimate_high, ac.appraiser_name, " +
                     "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
                     "FROM antique_items ai " +
                     "JOIN categories c ON ai.category_id = c.category_id " +
                     "LEFT JOIN appraisal_certificates ac ON ai.item_id = ac.item_id AND ac.certificate_status = 'VALID' " +
                     "WHERE ai.item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, itemId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToItem(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy hiện vật ID: " + itemId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public List<AntiqueItem> getAllItemsAdmin() {
        List<AntiqueItem> list = new ArrayList<>();
        String sql = "SELECT ai.item_id, ai.item_code, ai.name, ai.description, ai.era_from, ai.era_to, " +
                     "       ai.material, ai.dimensions, ai.item_condition, ai.status, ai.is_archived, ai.version, " +
                     "       ai.category_id, c.name as category_name, ai.created_by, ai.created_at, ai.updated_at, " +
                     "       ac.certificate_no, ac.certificate_status, ac.estimate_low, ac.estimate_high, ac.appraiser_name, " +
                     "       (SELECT TOP 1 file_path FROM item_images WHERE item_id = ai.item_id AND is_primary = 1) as primary_image_url " +
                     "FROM antique_items ai " +
                     "JOIN categories c ON ai.category_id = c.category_id " +
                     "LEFT JOIN appraisal_certificates ac ON ai.item_id = ac.item_id AND ac.certificate_status = 'VALID' " +
                     "WHERE ai.is_archived = 0 " +
                     "ORDER BY ai.item_id DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                list.add(mapResultSetToItem(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách hiện vật admin", e);
        } finally {
            DBUtil.close(rs, stmt, conn);
        }
        return list;
    }

    public boolean createItem(AntiqueItem item) {
        String sql = "INSERT INTO antique_items (item_code, name, description, era_from, era_to, material, dimensions, item_condition, status, category_id, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, item.getItemCode());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            if (item.getEraFrom() != null) ps.setInt(4, item.getEraFrom()); else ps.setNull(4, Types.INTEGER);
            if (item.getEraTo() != null) ps.setInt(5, item.getEraTo()); else ps.setNull(5, Types.INTEGER);
            ps.setString(6, item.getMaterial());
            ps.setString(7, item.getDimensions());
            ps.setString(8, item.getItemCondition() != null ? item.getItemCondition() : "INTACT");
            ps.setString(9, "DRAFT");
            ps.setLong(10, item.getCategoryId());
            ps.setLong(11, item.getCreatedBy() != null ? item.getCreatedBy() : 1L);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                item.setItemId(rs.getLong(1));
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo mới hiện vật", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return false;
    }

    public boolean updateItem(AntiqueItem item) {
        String sql = "UPDATE antique_items SET name = ?, description = ?, era_from = ?, era_to = ?, " +
                     "material = ?, dimensions = ?, item_condition = ?, category_id = ?, updated_at = GETDATE() " +
                     "WHERE item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            if (item.getEraFrom() != null) ps.setInt(3, item.getEraFrom()); else ps.setNull(3, Types.INTEGER);
            if (item.getEraTo() != null) ps.setInt(4, item.getEraTo()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, item.getMaterial());
            ps.setString(6, item.getDimensions());
            ps.setString(7, item.getItemCondition());
            ps.setLong(8, item.getCategoryId());
            ps.setLong(9, item.getItemId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật hiện vật ID: " + item.getItemId(), e);
        } finally {
            DBUtil.close(ps, conn);
        }
        return false;
    }

    public AppraisalCertificate getAppraisalByItemId(Long itemId) {
        String sql = "SELECT appraisal_id, item_id, result, appraiser_name, appraisal_date, note, " +
                     "       estimate_low, estimate_high, recorded_by, certificate_no, certificate_status, issued_at " +
                     "FROM appraisal_certificates " +
                     "WHERE item_id = ? ORDER BY appraisal_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, itemId);
            rs = ps.executeQuery();
            if (rs.next()) {
                AppraisalCertificate c = new AppraisalCertificate();
                c.setAppraisalId(rs.getLong("appraisal_id"));
                c.setItemId(rs.getLong("item_id"));
                c.setResult(rs.getString("result"));
                c.setAppraiserName(rs.getString("appraiser_name"));
                c.setAppraisalDate(rs.getDate("appraisal_date"));
                c.setNote(rs.getString("note"));
                c.setEstimateLow(rs.getBigDecimal("estimate_low"));
                c.setEstimateHigh(rs.getBigDecimal("estimate_high"));
                c.setRecordedBy(rs.getLong("recorded_by"));
                c.setCertificateNo(rs.getString("certificate_no"));
                c.setCertificateStatus(rs.getString("certificate_status"));
                c.setIssuedAt(rs.getTimestamp("issued_at"));
                return c;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy chứng thư giám định", e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public ProvenanceRecord getProvenanceByItemId(Long itemId) {
        String sql = "SELECT provenance_id, item_id, origin, acquisition_source, ownership_history, supporting_documents " +
                     "FROM provenance_records WHERE item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, itemId);
            rs = ps.executeQuery();
            if (rs.next()) {
                ProvenanceRecord p = new ProvenanceRecord();
                p.setProvenanceId(rs.getLong("provenance_id"));
                p.setItemId(rs.getLong("item_id"));
                p.setOrigin(rs.getString("origin"));
                p.setAcquisitionSource(rs.getString("acquisition_source"));
                p.setOwnershipHistory(rs.getString("ownership_history"));
                p.setSupportingDocuments(rs.getString("supporting_documents"));
                return p;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy hồ sơ nguồn gốc hiện vật: " + itemId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return null;
    }

    public List<ItemImage> getItemImagesByItemId(Long itemId) {
        List<ItemImage> list = new ArrayList<>();
        String sql = "SELECT image_id, item_id, file_path, mime_type, file_size, is_primary, display_order, uploaded_at " +
                     "FROM item_images WHERE item_id = ? ORDER BY display_order ASC, image_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, itemId);
            rs = ps.executeQuery();
            while (rs.next()) {
                ItemImage img = new ItemImage();
                img.setImageId(rs.getLong("image_id"));
                img.setItemId(rs.getLong("item_id"));
                img.setFilePath(rs.getString("file_path"));
                img.setMimeType(rs.getString("mime_type"));
                img.setFileSize(rs.getLong("file_size"));
                img.setPrimary(rs.getBoolean("is_primary"));
                img.setDisplayOrder(rs.getInt("display_order"));
                img.setUploadedAt(rs.getTimestamp("uploaded_at"));
                list.add(img);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách ảnh hiện vật: " + itemId, e);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
        return list;
    }

    public boolean createAppraisal(AppraisalCertificate cert) {
        String sqlCert = "INSERT INTO appraisal_certificates (item_id, result, appraiser_name, appraisal_date, note, " +
                         "       estimate_low, estimate_high, recorded_by, certificate_no, certificate_status, issued_at) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        boolean isPassed = "PASSED".equalsIgnoreCase(cert.getResult());
        String newStatus = isPassed ? "APPRAISED_PASSED" : "APPRAISED_REJECTED";
        String sqlItem = "UPDATE antique_items SET status = ? WHERE item_id = ?";

        Connection conn = null;
        PreparedStatement psCert = null;
        PreparedStatement psItem = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            psCert = conn.prepareStatement(sqlCert);
            psCert.setLong(1, cert.getItemId());
            psCert.setString(2, cert.getResult());
            psCert.setString(3, cert.getAppraiserName());
            psCert.setDate(4, cert.getAppraisalDate() != null ? cert.getAppraisalDate() : new Date(System.currentTimeMillis()));
            psCert.setString(5, cert.getNote());
            psCert.setBigDecimal(6, isPassed && cert.getEstimateLow() != null ? cert.getEstimateLow() : BigDecimal.ZERO);
            psCert.setBigDecimal(7, isPassed && cert.getEstimateHigh() != null ? cert.getEstimateHigh() : BigDecimal.ZERO);
            psCert.setLong(8, cert.getRecordedBy() != null ? cert.getRecordedBy() : 1L);
            if (isPassed) {
                psCert.setString(9, cert.getCertificateNo());
                psCert.setString(10, "VALID");
                psCert.setTimestamp(11, new Timestamp(System.currentTimeMillis()));
            } else {
                psCert.setNull(9, Types.VARCHAR);
                psCert.setNull(10, Types.VARCHAR);
                psCert.setNull(11, Types.TIMESTAMP);
            }
            psCert.executeUpdate();

            psItem = conn.prepareStatement(sqlItem);
            psItem.setString(1, newStatus);
            psItem.setLong(2, cert.getItemId());
            psItem.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Lỗi lưu giám định", e);
        } finally {
            DBUtil.close(psCert, psItem, conn);
        }
        return false;
    }

    private AntiqueItem mapResultSetToItem(ResultSet rs) throws SQLException {
        AntiqueItem item = new AntiqueItem();
        item.setItemId(rs.getLong("item_id"));
        item.setItemCode(rs.getString("item_code"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        int eraFrom = rs.getInt("era_from");
        if (!rs.wasNull()) item.setEraFrom(eraFrom);
        int eraTo = rs.getInt("era_to");
        if (!rs.wasNull()) item.setEraTo(eraTo);
        item.setMaterial(rs.getString("material"));
        item.setDimensions(rs.getString("dimensions"));
        item.setItemCondition(rs.getString("item_condition"));
        item.setStatus(rs.getString("status"));
        item.setArchived(rs.getBoolean("is_archived"));
        item.setVersion(rs.getInt("version"));
        item.setCategoryId(rs.getLong("category_id"));
        item.setCategoryName(rs.getString("category_name"));
        item.setCreatedBy(rs.getLong("created_by"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));

        item.setCertificateNo(rs.getString("certificate_no"));
        item.setCertificateStatus(rs.getString("certificate_status"));
        double low = rs.getDouble("estimate_low");
        if (!rs.wasNull()) item.setEstimateLow(low);
        double high = rs.getDouble("estimate_high");
        if (!rs.wasNull()) item.setEstimateHigh(high);
        item.setAppraiserName(rs.getString("appraiser_name"));

        item.setPrimaryImageUrl(rs.getString("primary_image_url"));
        return item;
    }
}
