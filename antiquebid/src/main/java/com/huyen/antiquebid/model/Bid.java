package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Bid implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long bidId;
    private Long auctionId;
    private Long bidderId;
    private BigDecimal bidAmount;
    private Timestamp bidTime;
    private String status; // 'VALID', 'RETRACTED', 'INVALID'

    // Joined details
    private String bidderName;
    private String bidderPhone;

    public Bid() {
    }

    public Bid(Long auctionId, Long bidderId, BigDecimal bidAmount) {
        this.auctionId = auctionId;
        this.bidderId = bidderId;
        this.bidAmount = bidAmount;
        this.bidTime = new Timestamp(System.currentTimeMillis());
        this.status = "VALID";
    }

    public Long getBidId() {
        return bidId;
    }

    public void setBidId(Long bidId) {
        this.bidId = bidId;
    }

    public Long getAuctionId() {
        return auctionId;
    }

    public void setAuctionId(Long auctionId) {
        this.auctionId = auctionId;
    }

    public Long getBidderId() {
        return bidderId;
    }

    public void setBidderId(Long bidderId) {
        this.bidderId = bidderId;
    }

    public BigDecimal getBidAmount() {
        return bidAmount;
    }

    public void setBidAmount(BigDecimal bidAmount) {
        this.bidAmount = bidAmount;
    }

    public Timestamp getBidTime() {
        return bidTime;
    }

    public void setBidTime(Timestamp bidTime) {
        this.bidTime = bidTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getMaskedBidderName() {
        return com.huyen.antiquebid.util.FormatUtil.maskName(bidderName);
    }
}
