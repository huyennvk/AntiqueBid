package com.huyen.antiquebid.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBUtil {
    private static final Logger LOGGER = Logger.getLogger(DBUtil.class.getName());

    private static final String DEFAULT_URL = 
        "jdbc:sqlserver://127.0.0.1:1433;databaseName=AntiqueBidDB;user=antiquebid_user;password=AntiqueBid@2026;encrypt=false;trustServerCertificate=true;loginTimeout=3;";

    private static final java.util.concurrent.BlockingQueue<Connection> POOL = 
        new java.util.concurrent.ArrayBlockingQueue<>(15);

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Không tìm thấy Microsoft SQL Server JDBC Driver!", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        Connection conn = POOL.poll();
        try {
            if (conn != null && !conn.isClosed() && conn.isValid(1)) {
                return conn;
            }
        } catch (Exception ignored) {
        }

        try {
            return DriverManager.getConnection(DEFAULT_URL);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Lỗi kết nối 127.0.0.1:1433, thử localhost:1433", e);
            String fallback = "jdbc:sqlserver://localhost:1433;databaseName=AntiqueBidDB;user=antiquebid_user;password=AntiqueBid@2026;encrypt=false;trustServerCertificate=true;loginTimeout=3;";
            return DriverManager.getConnection(fallback);
        }
    }

    public static void close(AutoCloseable... closeables) {
        for (AutoCloseable c : closeables) {
            if (c != null) {
                if (c instanceof Connection) {
                    Connection conn = (Connection) c;
                    try {
                        if (!conn.isClosed() && POOL.offer(conn)) {
                            continue; // Đưa lại vào pool, không đóng TCP connection
                        }
                    } catch (Exception ignored) {
                    }
                }
                try {
                    c.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}
