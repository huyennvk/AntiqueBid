package com.huyen.antiquebid.model;

import java.io.Serializable;

public class ProvenanceRecord implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long provenanceId;
    private Long itemId;
    private String origin;
    private String acquisitionSource;
    private String ownershipHistory;
    private String supportingDocuments;

    public ProvenanceRecord() {
    }

    public Long getProvenanceId() {
        return provenanceId;
    }

    public void setProvenanceId(Long provenanceId) {
        this.provenanceId = provenanceId;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getAcquisitionSource() {
        return acquisitionSource;
    }

    public void setAcquisitionSource(String acquisitionSource) {
        this.acquisitionSource = acquisitionSource;
    }

    public String getOwnershipHistory() {
        return ownershipHistory;
    }

    public void setOwnershipHistory(String ownershipHistory) {
        this.ownershipHistory = ownershipHistory;
    }

    public String getSupportingDocuments() {
        return supportingDocuments;
    }

    public void setSupportingDocuments(String supportingDocuments) {
        this.supportingDocuments = supportingDocuments;
    }
}
