package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class AuditLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long logId;
    private Long userId;
    private String userEmail;
    private String action;
    private String targetEntity;
    private Long targetId;
    private String details;
    private String ipAddress;
    private Timestamp createdAt;

    public AuditLog() {
    }

    public AuditLog(Long userId, String action, String targetEntity, Long targetId, String details, String ipAddress) {
        this.userId = userId;
        this.action = action;
        this.targetEntity = targetEntity;
        this.targetId = targetId;
        this.details = details;
        this.ipAddress = ipAddress;
    }

    public Long getLogId() {
        return logId;
    }

    public void setLogId(Long logId) {
        this.logId = logId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTargetEntity() {
        return targetEntity;
    }

    public void setTargetEntity(String targetEntity) {
        this.targetEntity = targetEntity;
    }

    public Long getTargetId() {
        return targetId;
    }

    public void setTargetId(Long targetId) {
        this.targetId = targetId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
