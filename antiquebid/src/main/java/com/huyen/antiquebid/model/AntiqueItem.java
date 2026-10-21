package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class AntiqueItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long itemId;
    private String itemCode;
    private String name;
    private String description;
    private Integer eraFrom;
    private Integer eraTo;
    private String material;
    private String dimensions;
    private String itemCondition; // 'INTACT', 'SLIGHTLY_DAMAGED', 'HEAVILY_DAMAGED', 'RESTORED'
    private String status; // 'DRAFT', 'APPRAISED_PASSED', 'APPRAISED_FAILED', 'AVAILABLE', 'IN_AUCTION', 'SOLD', 'UNSOLD'
    private boolean archived;
    private int version;
    private Long categoryId;
    private String categoryName;
    private Long createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined appraisal info
    private String certificateNo;
    private String certificateStatus;
    private Double estimateLow;
    private Double estimateHigh;
    private String appraiserName;

    // Primary image url
    private String primaryImageUrl;

    public AntiqueItem() {
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getItemCode() {
        return itemCode;
    }

    public void setItemCode(String itemCode) {
        this.itemCode = itemCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getEraFrom() {
        return eraFrom;
    }

    public void setEraFrom(Integer eraFrom) {
        this.eraFrom = eraFrom;
    }

    public Integer getEraTo() {
        return eraTo;
    }

    public void setEraTo(Integer eraTo) {
        this.eraTo = eraTo;
    }

    public String getEraDisplay() {
        if (eraFrom != null && eraTo != null) {
            if (eraFrom.equals(eraTo)) {
                return "Năm " + eraFrom;
            }
            return "Năm " + eraFrom + " - " + eraTo;
        } else if (eraFrom != null) {
            return "Từ năm " + eraFrom;
        } else if (eraTo != null) {
            return "Đến năm " + eraTo;
        }
        return "Không xác định";
    }

    public String getMaterial() {
        return material;
    }

    public void setMaterial(String material) {
        this.material = material;
    }

    public String getDimensions() {
        return dimensions;
    }

    public void setDimensions(String dimensions) {
        this.dimensions = dimensions;
    }

    public String getItemCondition() {
        return itemCondition;
    }

    public void setItemCondition(String itemCondition) {
        this.itemCondition = itemCondition;
    }

    public String getConditionDisplay() {
        if ("INTACT".equalsIgnoreCase(itemCondition)) return "Nguyên vẹn";
        if ("SLIGHTLY_DAMAGED".equalsIgnoreCase(itemCondition)) return "Tổn hại nhẹ";
        if ("HEAVILY_DAMAGED".equalsIgnoreCase(itemCondition)) return "Tổn hại nhiều";
        if ("RESTORED".equalsIgnoreCase(itemCondition)) return "Đã phục chế";
        return itemCondition != null ? itemCondition : "Nguyên vẹn";
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDisplay() {
        if ("DRAFT".equalsIgnoreCase(status)) return "Bản nháp";
        if ("APPRAISED_PASSED".equalsIgnoreCase(status)) return "Đã đạt giám định";
        if ("APPRAISED_FAILED".equalsIgnoreCase(status)) return "Không đạt giám định";
        if ("AVAILABLE".equalsIgnoreCase(status)) return "Sẵn sàng đấu giá";
        if ("IN_AUCTION".equalsIgnoreCase(status)) return "Đang lên sàn";
        if ("SOLD".equalsIgnoreCase(status)) return "Đã bán";
        if ("UNSOLD".equalsIgnoreCase(status)) return "Chưa bán được";
        return status != null ? status : "Khởi tạo";
    }

    public boolean isArchived() {
        return archived;
    }

    public void setArchived(boolean archived) {
        this.archived = archived;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCertificateNo() {
        return certificateNo;
    }

    public void setCertificateNo(String certificateNo) {
        this.certificateNo = certificateNo;
    }

    public String getCertificateStatus() {
        return certificateStatus;
    }

    public void setCertificateStatus(String certificateStatus) {
        this.certificateStatus = certificateStatus;
    }

    public Double getEstimateLow() {
        return estimateLow;
    }

    public void setEstimateLow(Double estimateLow) {
        this.estimateLow = estimateLow;
    }

    public Double getEstimateHigh() {
        return estimateHigh;
    }

    public void setEstimateHigh(Double estimateHigh) {
        this.estimateHigh = estimateHigh;
    }

    public String getAppraiserName() {
        return appraiserName;
    }

    public void setAppraiserName(String appraiserName) {
        this.appraiserName = appraiserName;
    }

    public String getPrimaryImageUrl() {
        if (primaryImageUrl != null && !primaryImageUrl.trim().isEmpty()) {
            return primaryImageUrl;
        }
        if (itemId != null && itemId >= 1 && itemId <= 5) {
            return "assets/images/item_" + itemId + ".jpg";
        }
        return "assets/images/antique_default.jpg";
    }

    public void setPrimaryImageUrl(String primaryImageUrl) {
        this.primaryImageUrl = primaryImageUrl;
    }
}
