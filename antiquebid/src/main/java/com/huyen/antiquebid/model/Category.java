package com.huyen.antiquebid.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private String name;
    private String description;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int itemCount;

    public Category() {
    }

    public Category(Long categoryId, String name, String description, boolean active) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.active = active;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
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

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }
}
