package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@WebServlet({"/getDevices", "/signOutDevice", "/signOutAllDevices", "/getDeviceActivity"})
public class DeviceManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/getDevices".equals(path)) {
            getDevices(request, response);
        } else if ("/getDeviceActivity".equals(path)) {
            getDeviceActivity(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/signOutDevice".equals(path)) {
            signOutDevice(request, response);
        } else if ("/signOutAllDevices".equals(path)) {
            signOutAllDevices(request, response);
        }
    }
    
    private void getDevices(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String currentSessionId = session.getId();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM user_devices WHERE user_id = ? AND active = true";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                
                JsonArray devices = new JsonArray();
                while (rs.next()) {
                    JsonObject device = new JsonObject();
                    device.addProperty("id", rs.getString("device_id"));
                    device.addProperty("name", rs.getString("device_name"));
                    device.addProperty("type", rs.getString("device_type"));
                    device.addProperty("browser", rs.getString("browser"));
                    device.addProperty("location", rs.getString("location"));
                    device.addProperty("lastActive", formatTimestamp(rs.getTimestamp("last_active")));
                    device.addProperty("isCurrent", rs.getString("session_id").equals(currentSessionId));
                    devices.add(device);
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("devices", devices);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private void signOutDevice(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String deviceId = request.getParameter("deviceId");
        String currentSessionId = session.getId();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Begin transaction
            conn.setAutoCommit(false);
            
            try {
                // Check if trying to sign out current device
                String checkSql = "SELECT session_id FROM user_devices WHERE device_id = ? AND user_id = ?";
                try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                    checkStmt.setString(1, deviceId);
                    checkStmt.setInt(2, userId);
                    ResultSet rs = checkStmt.executeQuery();
                    
                    if (rs.next() && rs.getString("session_id").equals(currentSessionId)) {
                        throw new SQLException("Cannot sign out current device");
                    }
                }
                
                // Deactivate device
                String updateSql = "UPDATE user_devices SET active = false, last_active = ? " +
                                 "WHERE device_id = ? AND user_id = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                    updateStmt.setString(2, deviceId);
                    updateStmt.setInt(3, userId);
                    
                    int rowsAffected = updateStmt.executeUpdate();
                    if (rowsAffected > 0) {
                        // Add to activity log
                        String logSql = "INSERT INTO device_activity_log " +
                                      "(user_id, device_id, activity_type, activity_time) " +
                                      "VALUES (?, ?, 'SIGN_OUT', ?)";
                        try (PreparedStatement logStmt = conn.prepareStatement(logSql)) {
                            logStmt.setInt(1, userId);
                            logStmt.setString(2, deviceId);
                            logStmt.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                            logStmt.executeUpdate();
                        }
                        
                        conn.commit();
                        jsonResponse.addProperty("success", true);
                    } else {
                        throw new SQLException("Device not found or already signed out");
                    }
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", e.getMessage());
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private void signOutAllDevices(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String currentSessionId = session.getId();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try {
                // Deactivate all devices except current
                String updateSql = "UPDATE user_devices SET active = false, last_active = ? " +
                                 "WHERE user_id = ? AND session_id != ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                    updateStmt.setInt(2, userId);
                    updateStmt.setString(3, currentSessionId);
                    
                    updateStmt.executeUpdate();
                    
                    // Log activity for all signed out devices
                    String logSql = "INSERT INTO device_activity_log " +
                                  "(user_id, device_id, activity_type, activity_time) " +
                                  "SELECT ?, device_id, 'SIGN_OUT_ALL', ? " +
                                  "FROM user_devices WHERE user_id = ? AND session_id != ?";
                    try (PreparedStatement logStmt = conn.prepareStatement(logSql)) {
                        logStmt.setInt(1, userId);
                        logStmt.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                        logStmt.setInt(3, userId);
                        logStmt.setString(4, currentSessionId);
                        logStmt.executeUpdate();
                    }
                    
                    conn.commit();
                    jsonResponse.addProperty("success", true);
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private void getDeviceActivity(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT l.*, d.device_name, d.device_type, d.browser, d.location " +
                        "FROM device_activity_log l " +
                        "JOIN user_devices d ON l.device_id = d.device_id " +
                        "WHERE l.user_id = ? " +
                        "ORDER BY l.activity_time DESC LIMIT 10";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                
                JsonArray activities = new JsonArray();
                while (rs.next()) {
                    JsonObject activity = new JsonObject();
                    activity.addProperty("type", rs.getString("activity_type"));
                    activity.addProperty("deviceName", rs.getString("device_name"));
                    activity.addProperty("deviceType", rs.getString("device_type"));
                    activity.addProperty("browser", rs.getString("browser"));
                    activity.addProperty("location", rs.getString("location"));
                    activity.addProperty("timestamp", formatTimestamp(rs.getTimestamp("activity_time")));
                    activities.add(activity);
                }
                
                jsonResponse.addProperty("success", true);
                jsonResponse.add("activities", activities);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private String formatTimestamp(Timestamp timestamp) {
        // Format timestamp to a readable string
        // You can implement your own formatting logic here
        return timestamp.toString();
    }
    
    @Override
    public void init() throws ServletException {
        super.init();
        // Table creation code removed as it's already created in MySQL Workbench
    }
}