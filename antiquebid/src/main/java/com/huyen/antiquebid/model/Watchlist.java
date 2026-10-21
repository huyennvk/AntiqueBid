package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Watchlist implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long watchlistId;
    private Long userId;
    private Long auctionId;
    private Timestamp addedAt;

    // Joined auction details
    private String itemCode;
    private String itemName;
    private String itemMaterial;
    private String primaryImageUrl;
    private BigDecimal currentHighestBid;
    private BigDecimal startingPrice;
    private Timestamp endTime;
    private String auctionStatus;

    public Watchlist() {
    }

    public Long getWatchlistId() {
        return watchlistId;
    }

    public void setWatchlistId(Long watchlistId) {
        this.watchlistId = watchlistId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getAuctionId() {
        return auctionId;
    }

    public void setAuctionId(Long auctionId) {
        this.auctionId = auctionId;
    }

    public Timestamp getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Timestamp addedAt) {
        this.addedAt = addedAt;
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

    public String getItemMaterial() {
        return itemMaterial;
    }

    public void setItemMaterial(String itemMaterial) {
        this.itemMaterial = itemMaterial;
    }

    public String getPrimaryImageUrl() {
        if (primaryImageUrl != null && !primaryImageUrl.trim().isEmpty()) {
            return primaryImageUrl;
        }
        return "assets/images/antique_default.jpg";
    }

    public void setPrimaryImageUrl(String primaryImageUrl) {
        this.primaryImageUrl = primaryImageUrl;
    }

    public BigDecimal getCurrentHighestBid() {
        return currentHighestBid != null ? currentHighestBid : startingPrice;
    }

    public void setCurrentHighestBid(BigDecimal currentHighestBid) {
        this.currentHighestBid = currentHighestBid;
    }

    public BigDecimal getStartingPrice() {
        return startingPrice;
    }

    public void setStartingPrice(BigDecimal startingPrice) {
        this.startingPrice = startingPrice;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public String getAuctionStatus() {
        return auctionStatus;
    }

    public void setAuctionStatus(String auctionStatus) {
        this.auctionStatus = auctionStatus;
    }
}
