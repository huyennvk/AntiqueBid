package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Dispute implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long disputeId;
    private Long orderId;
    private Long bidderId;
    private String reason;
    private String status; // 'OPEN', 'UNDER_REVIEW', 'RESOLVED_REFUND', 'REJECTED'
    private String resolutionNote;
    private Long resolvedBy;
    private Timestamp resolvedAt;
    private Timestamp createdAt;

    // Joined info
    private String bidderName;
    private String bidderPhone;
    private String itemName;
    private Double finalPrice;

    public Dispute() {
    }

    public Long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public Long getBidderId() {
        return bidderId;
    }

    public void setBidderId(Long bidderId) {
        this.bidderId = bidderId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusBadgeClass() {
        if ("OPEN".equalsIgnoreCase(status)) return "badge-warning";
        if ("UNDER_REVIEW".equalsIgnoreCase(status)) return "badge-info";
        if ("RESOLVED_REFUND".equalsIgnoreCase(status)) return "badge-success";
        if ("REJECTED".equalsIgnoreCase(status)) return "badge-danger";
        return "badge-secondary";
    }

    public String getStatusDisplay() {
        if ("OPEN".equalsIgnoreCase(status)) return "Mới tiếp nhận";
        if ("UNDER_REVIEW".equalsIgnoreCase(status)) return "Đang xem xét";
        if ("RESOLVED_REFUND".equalsIgnoreCase(status)) return "Chấp nhận hoàn tiền";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối khiếu nại";
        return status != null ? status : "Chờ xử lý";
    }

    public String getResolutionNote() {
        return resolutionNote;
    }

    public void setResolutionNote(String resolutionNote) {
        this.resolutionNote = resolutionNote;
    }

    public Long getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(Long resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getBidderName() {
        return bidderName;
    }

    public void setBidderName(String bidderName) {
        this.bidderName = bidderName;
    }

    public String getBidderPhone() {
        return bidderPhone;
    }

    public void setBidderPhone(String bidderPhone) {
        this.bidderPhone = bidderPhone;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public Double getFinalPrice() {
        return finalPrice;
    }

    public void setFinalPrice(Double finalPrice) {
        this.finalPrice = finalPrice;
    }
}
