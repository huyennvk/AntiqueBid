package com.huyen.antiquebid.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class FormatUtil {

    private static final DecimalFormat CURRENCY_FORMAT;
    private static final SimpleDateFormat DATETIME_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");

    static {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("vi", "VN"));
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        CURRENCY_FORMAT = new DecimalFormat("#,###", symbols);
    }

    public static String formatVND(BigDecimal amount) {
        if (amount == null) return "0 ₫";
        return CURRENCY_FORMAT.format(amount) + " ₫";
    }

    public static String formatVND(Double amount) {
        if (amount == null) return "0 ₫";
        return CURRENCY_FORMAT.format(amount) + " ₫";
    }

    public static String formatDateTime(Date date) {
        if (date == null) return "—";
        return DATETIME_FORMAT.format(date);
    }

    public static String formatDate(Date date) {
        if (date == null) return "—";
        return DATE_FORMAT.format(date);
    }

    public static String formatRemainingTime(Date endDate) {
        if (endDate == null) return "Đã đóng";
        long diff = endDate.getTime() - System.currentTimeMillis();
        if (diff <= 0) return "Đã kết thúc";

        long seconds = diff / 1000;
        long days = seconds / (24 * 3600);
        seconds %= (24 * 3600);
        long hours = seconds / 3600;
        seconds %= 3600;
        long minutes = seconds / 60;
        long secs = seconds % 60;

        if (days > 0) {
            return String.format("%d ngày %02d:%02d:%02d", days, hours, minutes, secs);
        }
        return String.format("%02d:%02d:%02d", hours, minutes, secs);
    }

    /**
     * Che giấu thông tin danh tính người tham gia đấu giá (Ví dụ: "Huyền Nguyễn" -> "H****n N****n")
     * Đảm bảo tính bảo mật, ẩn danh và chống lộ danh tính người trả giá trên sàn.
     */
    public static String maskName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "Chưa có lượt trả giá";
        }
        String trimmed = name.trim();
        if ("Chưa có lượt trả giá".equalsIgnoreCase(trimmed) || "Chưa có".equalsIgnoreCase(trimmed)) {
            return trimmed;
        }
        String[] parts = trimmed.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.length; i++) {
            String p = parts[i];
            if (p.length() <= 1) {
                sb.append(p).append("****");
            } else if (p.length() == 2) {
                sb.append(p.charAt(0)).append("****");
            } else {
                sb.append(p.charAt(0)).append("****").append(p.charAt(p.length() - 1));
            }
            if (i < parts.length - 1) {
                sb.append(" ");
            }
        }
        return sb.toString();
    }
}

