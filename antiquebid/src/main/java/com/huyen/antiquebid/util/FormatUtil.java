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
}
