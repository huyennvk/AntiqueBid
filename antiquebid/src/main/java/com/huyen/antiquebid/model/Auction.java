package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Auction implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long auctionId;
    private Long itemId;
    private Long createdBy;
    private Timestamp startTime;
    private Timestamp endTime;
    private BigDecimal startingPrice;
    private BigDecimal reservePrice;
    private BigDecimal minBidIncrement;
    private BigDecimal currentHighestBid;
    private Long highestBidderId;
    private String status; // 'DRAFT', 'SCHEDULED', 'ACTIVE', 'CLOSED', 'CANCELLED'
    private boolean extended;
    private boolean paid;
    private Timestamp createdAt;

    // Joined item details
    private String itemCode;
    private String itemName;
    private String itemDescription;
    private String itemMaterial;
    private String itemDimensions;
    private String categoryName;
    private String primaryImageUrl;
    private String highestBidderName;
    private String highestBidderPhone;
    private int totalBids;

    public Auction() {
    }

    public Long getAuctionId() {
        return auctionId;
    }

    public void setAuctionId(Long auctionId) {
        this.auctionId = auctionId;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getStartTime() {
        return startTime;
    }

    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public BigDecimal getStartingPrice() {
        return startingPrice != null ? startingPrice : BigDecimal.ZERO;
    }

    public void setStartingPrice(BigDecimal startingPrice) {
        this.startingPrice = startingPrice;
    }

    public BigDecimal getReservePrice() {
        return reservePrice;
    }

    public void setReservePrice(BigDecimal reservePrice) {
        this.reservePrice = reservePrice;
    }

    public BigDecimal getMinBidIncrement() {
        return minBidIncrement != null ? minBidIncrement : BigDecimal.valueOf(1000000);
    }

    public void setMinBidIncrement(BigDecimal minBidIncrement) {
        this.minBidIncrement = minBidIncrement;
    }

    public BigDecimal getCurrentHighestBid() {
        return currentHighestBid != null ? currentHighestBid : getStartingPrice();
    }

    public void setCurrentHighestBid(BigDecimal currentHighestBid) {
        this.currentHighestBid = currentHighestBid;
    }

    public BigDecimal getNextMinimumBid() {
        if (currentHighestBid == null || currentHighestBid.compareTo(BigDecimal.ZERO) == 0) {
            return getStartingPrice();
        }
        return currentHighestBid.add(getMinBidIncrement());
    }

    public Long getHighestBidderId() {
        return highestBidderId;
    }

    public void setHighestBidderId(Long highestBidderId) {
        this.highestBidderId = highestBidderId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusBadgeClass() {
        if ("ACTIVE".equalsIgnoreCase(status)) return "badge-live";
        if ("SCHEDULED".equalsIgnoreCase(status)) return "badge-upcoming";
        if ("CLOSED".equalsIgnoreCase(status)) return "badge-closed";
        if ("CANCELLED".equalsIgnoreCase(status)) return "badge-danger";
        return "badge-secondary";
    }

    public String getStatusDisplay() {
        if ("ACTIVE".equalsIgnoreCase(status)) return "Đang diễn ra";
        if ("SCHEDULED".equalsIgnoreCase(status)) return "Sắp diễn ra";
        if ("CLOSED".equalsIgnoreCase(status)) return "Đã kết thúc";
        if ("CANCELLED".equalsIgnoreCase(status)) return "Đã hủy";
        if ("DRAFT".equalsIgnoreCase(status)) return "Bản nháp";
        return status != null ? status : "Chưa rõ";
    }

    public boolean isExtended() {
        return extended;
    }

    public void setExtended(boolean extended) {
        this.extended = extended;
    }

    public boolean isPaid() {
        return paid;
    }

    public void setPaid(boolean paid) {
        this.paid = paid;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getItemCode() {
        return itemCode;
    }

    public void setItemCode(String itemCode) {
        this.itemCode = itemCode;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemDescription() {
        return itemDescription;
    }

    public void setItemDescription(String itemDescription) {
        this.itemDescription = itemDescription;
    }

    public String getItemMaterial() {
        return itemMaterial;
    }

    public void setItemMaterial(String itemMaterial) {
        this.itemMaterial = itemMaterial;
    }

    public String getItemDimensions() {
        return itemDimensions;
    }

    public void setItemDimensions(String itemDimensions) {
        this.itemDimensions = itemDimensions;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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

    public String getHighestBidderName() {
        return highestBidderName != null ? highestBidderName : "Chưa có lượt trả giá";
    }

    public String getMaskedHighestBidderName() {
        return com.huyen.antiquebid.util.FormatUtil.maskName(highestBidderName);
    }

    public void setHighestBidderName(String highestBidderName) {
        this.highestBidderName = highestBidderName;
    }

    public String getHighestBidderPhone() {
        return highestBidderPhone;
    }

    public void setHighestBidderPhone(String highestBidderPhone) {
        this.highestBidderPhone = highestBidderPhone;
    }

    public int getTotalBids() {
        return totalBids;
    }

    public void setTotalBids(int totalBids) {
        this.totalBids = totalBids;
    }

    public boolean isLive() {
        if (!"ACTIVE".equalsIgnoreCase(status)) return false;
        long now = System.currentTimeMillis();
        return (startTime != null && startTime.getTime() <= now) && (endTime != null && endTime.getTime() > now);
    }

    public long getRemainingSeconds() {
        if (endTime == null) return 0;
        long diff = (endTime.getTime() - System.currentTimeMillis()) / 1000;
        return Math.max(0, diff);
    }
}
