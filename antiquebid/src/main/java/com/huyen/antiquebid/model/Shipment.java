package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Shipment implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long shipmentId;
    private Long orderId;
    private String carrierName;
    private String trackingNumber;
    private String status; // 'PENDING_PICKUP', 'IN_TRANSIT', 'DELIVERED', 'RETURNED'
    private Timestamp shippedAt;
    private Timestamp deliveredAt;
    private String note;

    public Shipment() {
    }

    public Long getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(Long shipmentId) {
        this.shipmentId = shipmentId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDisplay() {
        if ("PENDING_PICKUP".equalsIgnoreCase(status)) return "Chờ lấy hàng";
        if ("IN_TRANSIT".equalsIgnoreCase(status)) return "Đang vận chuyển";
        if ("DELIVERED".equalsIgnoreCase(status)) return "Đã giao hàng thành công";
        if ("RETURNED".equalsIgnoreCase(status)) return "Đã chuyển hoàn";
        return status != null ? status : "Chưa cập nhật";
    }

    public Timestamp getShippedAt() {
        return shippedAt;
    }

    public void setShippedAt(Timestamp shippedAt) {
        this.shippedAt = shippedAt;
    }

    public Timestamp getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(Timestamp deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
