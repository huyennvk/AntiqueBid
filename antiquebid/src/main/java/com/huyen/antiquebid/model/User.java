package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long userId;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phone;
    private String role; // 'BIDDER', 'ADMIN'
    private boolean locked;
    private Timestamp createdAt;

    // Joined bidder profile info
    private String citizenId; // 12-digit Vietnamese CCCD number
    private String kycStatus; // 'NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'REJECTED'
    private int violationCount;
    private String shippingAddress;

    public User() {
    }

    public User(Long userId, String email, String fullName, String phone, String role, boolean locked) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.locked = locked;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isLocked() {
        return locked;
    }

    public void setLocked(boolean locked) {
        this.locked = locked;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getCitizenId() {
        return citizenId;
    }

    public void setCitizenId(String citizenId) {
        this.citizenId = citizenId;
    }

    public String getMaskedCitizenId() {
        if (citizenId == null || citizenId.trim().isEmpty()) {
            return "Chưa cập nhật";
        }
        String clean = citizenId.trim();
        if (clean.length() == 12) {
            return clean.substring(0, 3) + " ••• ••• " + clean.substring(9);
        }
        return clean;
    }

    public String getKycStatus() {
        return kycStatus != null ? kycStatus : "NOT_SUBMITTED";
    }

    public void setKycStatus(String kycStatus) {
        this.kycStatus = kycStatus;
    }

    public int getViolationCount() {
        return violationCount;
    }

    public void setViolationCount(int violationCount) {
        this.violationCount = violationCount;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(role);
    }

    public boolean isVerifiedBidder() {
        return "BIDDER".equalsIgnoreCase(role) && "VERIFIED".equalsIgnoreCase(kycStatus) && !locked;
    }
}
