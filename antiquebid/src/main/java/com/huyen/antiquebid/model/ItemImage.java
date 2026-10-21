package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ItemImage implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long imageId;
    private Long itemId;
    private String filePath;
    private String mimeType;
    private Long fileSize;
    private boolean primary;
    private int displayOrder;
    private Timestamp uploadedAt;

    public ItemImage() {
    }

    public ItemImage(Long imageId, Long itemId, String filePath, boolean primary, int displayOrder) {
        this.imageId = imageId;
        this.itemId = itemId;
        this.filePath = filePath;
        this.primary = primary;
        this.displayOrder = displayOrder;
    }

    public Long getImageId() {
        return imageId;
    }

    public void setImageId(Long imageId) {
        this.imageId = imageId;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public boolean isPrimary() {
        return primary;
    }

    public void setPrimary(boolean primary) {
        this.primary = primary;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}
