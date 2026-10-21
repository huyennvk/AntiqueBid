package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long orderId;
    private Long auctionId;
    private Long bidderId;
    private BigDecimal finalPrice;
    private String status; // 'PENDING_PAYMENT', 'PAID', 'SHIPPING', 'DELIVERED', 'COMPLETED', 'CANCELLED', 'REFUNDED'
    private Timestamp paymentDeadline;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined info
    private String bidderName;
    private String bidderEmail;
    private String bidderPhone;
    private String shippingAddress;
    private Long itemId;
    private String itemCode;
    private String itemName;
    private String primaryImageUrl;

    // Payment & shipment info
    private String paymentMethod;
    private String transactionRef;
    private String carrierName;
    private String trackingNumber;
    private String shipmentStatus;

    public Order() {
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
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

    public BigDecimal getFinalPrice() {
        return finalPrice != null ? finalPrice : BigDecimal.ZERO;
    }

    public void setFinalPrice(BigDecimal finalPrice) {
        this.finalPrice = finalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusBadgeClass() {
        if ("PENDING_PAYMENT".equalsIgnoreCase(status)) return "badge-warning";
        if ("PAID".equalsIgnoreCase(status)) return "badge-success";
        if ("SHIPPING".equalsIgnoreCase(status)) return "badge-info";
        if ("DELIVERED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status)) return "badge-success";
        if ("CANCELLED".equalsIgnoreCase(status) || "REFUNDED".equalsIgnoreCase(status)) return "badge-danger";
        return "badge-secondary";
    }

    public String getStatusDisplay() {
        if ("PENDING_PAYMENT".equalsIgnoreCase(status)) return "Chờ thanh toán";
        if ("PAID".equalsIgnoreCase(status)) return "Đã thanh toán";
        if ("SHIPPING".equalsIgnoreCase(status)) return "Đang vận chuyển";
        if ("DELIVERED".equalsIgnoreCase(status)) return "Đã giao hàng";
        if ("COMPLETED".equalsIgnoreCase(status)) return "Hoàn tất";
        if ("CANCELLED".equalsIgnoreCase(status)) return "Đã hủy (quá hạn)";
        if ("REFUNDED".equalsIgnoreCase(status)) return "Đã hoàn tiền";
        return status != null ? status : "Khởi tạo";
    }

    public Timestamp getPaymentDeadline() {
        return paymentDeadline;
    }

    public void setPaymentDeadline(Timestamp paymentDeadline) {
        this.paymentDeadline = paymentDeadline;
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

    public String getBidderName() {
        return bidderName;
    }

    public void setBidderName(String bidderName) {
        this.bidderName = bidderName;
    }

    public String getBidderEmail() {
        return bidderEmail;
    }

    public void setBidderEmail(String bidderEmail) {
        this.bidderEmail = bidderEmail;
    }

    public String getBidderPhone() {
        return bidderPhone;
    }

    public void setBidderPhone(String bidderPhone) {
        this.bidderPhone = bidderPhone;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
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

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
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

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionRef() {
        return transactionRef;
    }

    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
    }

    public String getCarrierName() {
        return carrierName;
    }

    public void setCarrierName(String carrierName) {
        this.carrierName = carrierName;
    }

    public String getTrackingNumber() {
        return trackingNumber;
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public String getShipmentStatus() {
        return shipmentStatus;
    }

    public void setShipmentStatus(String shipmentStatus) {
        this.shipmentStatus = shipmentStatus;
    }

    public boolean isPayable() {
        return "PENDING_PAYMENT".equalsIgnoreCase(status);
    }
}
