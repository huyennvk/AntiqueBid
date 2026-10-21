package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class AppraisalCertificate implements Serializable {
    private static final long serialVersionUID = 1L;

    // Khóa chính chuẩn ERD 18 bảng: appraisal_id
    private Long appraisalId;
    private Long itemId;
    private String result; // 'PASSED', 'REJECTED'
    private String appraiserName;
    private Date appraisalDate;
    private String note;
    private BigDecimal estimateLow;
    private BigDecimal estimateHigh;
    private Long recordedBy;
    private Timestamp recordedAt;
    private String certificateNo;
    private String certificateStatus; // 'VALID', 'REVOKED'
    private Timestamp issuedAt;
    private Timestamp revokedAt;

    public AppraisalCertificate() {
    }

    public Long getAppraisalId() {
        return appraisalId;
    }

    public void setAppraisalId(Long appraisalId) {
        this.appraisalId = appraisalId;
    }

    // Alias tương thích ngược nếu view gọi getCertificateId
    public Long getCertificateId() {
        return appraisalId;
    }

    public void setCertificateId(Long certificateId) {
        this.appraisalId = certificateId;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getAppraiserName() {
        return appraiserName;
    }

    public void setAppraiserName(String appraiserName) {
        this.appraiserName = appraiserName;
    }

    public Date getAppraisalDate() {
        return appraisalDate;
    }

    public void setAppraisalDate(Date appraisalDate) {
        this.appraisalDate = appraisalDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public BigDecimal getEstimateLow() {
        return estimateLow;
    }

    public void setEstimateLow(BigDecimal estimateLow) {
        this.estimateLow = estimateLow;
    }

    public BigDecimal getEstimateHigh() {
        return estimateHigh;
    }

    public void setEstimateHigh(BigDecimal estimateHigh) {
        this.estimateHigh = estimateHigh;
    }

    public Long getRecordedBy() {
        return recordedBy;
    }

    public void setRecordedBy(Long recordedBy) {
        this.recordedBy = recordedBy;
    }

    public Timestamp getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(Timestamp recordedAt) {
        this.recordedAt = recordedAt;
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

    public Timestamp getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(Timestamp issuedAt) {
        this.issuedAt = issuedAt;
    }

    public Timestamp getRevokedAt() {
        return revokedAt;
    }

    public void setRevokedAt(Timestamp revokedAt) {
        this.revokedAt = revokedAt;
    }

    public boolean isValid() {
        return "VALID".equalsIgnoreCase(certificateStatus);
    }

    public boolean isPassed() {
        return "PASSED".equalsIgnoreCase(result);
    }

    // Helper methods phục vụ hiển thị UI (không tạo thêm cột DB, giữ đúng 14 cột theo ERD 18 bảng)
    public String getAuthenticityConclusion() {
        if (isPassed()) {
            return "Cổ vật thật nguyên bản (Authentic Antique)";
        } else if ("REJECTED".equalsIgnoreCase(result)) {
            return "Không đạt tiêu chuẩn xác thực cổ vật";
        }
        return "Đang chờ kết luận giám định";
    }

    public String getAppraiserTitle() {
        return "Chuyên gia Giám định Cổ vật Cấp Quốc gia - Thẻ GĐ-018/VCH";
    }

    public String getIssuingAuthority() {
        return "Hội Đồng Giám Định Di Sản Cổ Vật Đường & Viện Nghiên Cứu Di Sản Quốc Gia";
    }

    public String getScientificMethod() {
        return "Phân tích quang phổ huỳnh quang tia X (XRF) cốt vật liệu; soi kính hiển vi kiểm tra mạng rạn men và cấu trúc vi thể tự nhiên.";
    }

    public String getReferenceMaterial() {
        return "Hồ sơ hiện vật đối chứng Bảo tàng Lịch sử Quốc gia & Mẫu vật lưu trữ tại Viện Khảo Cổ.";
    }

    public String getCulturalValue() {
        return "Hiện vật tiêu biểu cho kỹ nghệ chế tác tinh hoa và giá trị di sản đặc sắc.";
    }
}
