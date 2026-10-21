package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VerificationDocument implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long docId;
    private Long bidderId;
    private String docType = "CITIZEN_ID"; // Chỉ xác thực qua CCCD
    private String citizenId; // 12-digit CCCD
    private java.sql.Date issueDate; // Ngày cấp CCCD
    private String issuePlace; // Nơi cấp (Cục Cảnh sát QLHC về TTXH)
    private String fileUrl; // Ảnh mặt trước CCCD
    private String fileUrlBack; // Ảnh mặt sau CCCD (chứa chip điện tử)
    private Timestamp submittedAt;
    private String reviewNote;

    // Joined details
    private String bidderName;
    private String bidderEmail;

    public VerificationDocument() {
    }

    public Long getDocId() {
        return docId;
    }

    public void setDocId(Long docId) {
        this.docId = docId;
    }

    public Long getBidderId() {
        return bidderId;
    }

    public void setBidderId(Long bidderId) {
        this.bidderId = bidderId;
    }

    public String getDocType() {
        return docType;
    }

    public void setDocType(String docType) {
        this.docType = docType;
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

    public java.sql.Date getIssueDate() {
        return issueDate;
    }

    public void setIssueDate(java.sql.Date issueDate) {
        this.issueDate = issueDate;
    }

    public String getIssuePlace() {
        return issuePlace != null ? issuePlace : "Cục Cảnh sát QLHC về TTXH";
    }

    public void setIssuePlace(String issuePlace) {
        this.issuePlace = issuePlace;
    }

    public String getDocTypeDisplay() {
        return "Căn cước công dân (CCCD)";
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public String getFileUrlBack() {
        return fileUrlBack != null && !fileUrlBack.isEmpty() ? fileUrlBack : "assets/images/sample_cccd_back.svg";
    }

    public void setFileUrlBack(String fileUrlBack) {
        this.fileUrlBack = fileUrlBack;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }

    public String getReviewNote() {
        return reviewNote;
    }

    public void setReviewNote(String reviewNote) {
        this.reviewNote = reviewNote;
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
}
