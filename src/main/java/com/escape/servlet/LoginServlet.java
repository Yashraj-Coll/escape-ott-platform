package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;
import org.json.JSONObject;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String emailOrMobile = request.getParameter("emailOrMobile");
        String password = request.getParameter("password");
        boolean rememberMe = "on".equals(request.getParameter("rememberMe"));
        
        JSONObject jsonResponse = new JSONObject();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // First check if user exists
            String checkUserSql = "SELECT id FROM users WHERE email = ? OR mobile_number = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkUserSql)) {
                checkStmt.setString(1, emailOrMobile);
                checkStmt.setString(2, emailOrMobile);
                ResultSet checkRs = checkStmt.executeQuery();
                
                if (!checkRs.next()) {
                    // User not found
                    jsonResponse.put("success", false);
                    jsonResponse.put("error", "UNREGISTERED");
                    logLoginAttempt(conn, null, false, request.getRemoteAddr(), "User not registered");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
            // Now check credentials
            String sql = "SELECT *, created_at FROM users WHERE (email = ? OR mobile_number = ?) AND password = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, emailOrMobile);
                stmt.setString(2, emailOrMobile);
                stmt.setString(3, password); 
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    // Login successful
                    HttpSession session = request.getSession();
                    int userId = rs.getInt("id");
                    
                    // Set session attributes
                    session.setAttribute("userId", userId);
                    session.setAttribute("userName", rs.getString("first_name"));
                    session.setAttribute("userLastName", rs.getString("last_name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("userMobile", rs.getString("mobile_number"));
                    
                    // Update last login and log attempt
                    updateLastLogin(conn, userId);
                    logLoginAttempt(conn, userId, true, request.getRemoteAddr(), "Login successful");
                    
                    // Handle member since date
                    Date memberSinceDate = rs.getDate("created_at");
                    if (memberSinceDate != null) {
                        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM yyyy");
                        session.setAttribute("memberSince", dateFormat.format(memberSinceDate));
                    } else {
                        session.setAttribute("memberSince", "June 2023");
                    }
                    
                    // Handle remember me
                    if (rememberMe) {
                        String rememberToken = UUID.randomUUID().toString();
                        updateRememberToken(conn, userId, rememberToken);
                        Cookie userCookie = new Cookie("userEmail", emailOrMobile);
                        Cookie tokenCookie = new Cookie("rememberToken", rememberToken);
                        userCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                        tokenCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                        response.addCookie(userCookie);
                        response.addCookie(tokenCookie);
                    } else {
                        // Clear remember token if remember me is not checked
                        updateRememberToken(conn, userId, null);
                    }
                    
                    // Updated subscription plan query
                    String subscriptionSql = """
                        SELECT COALESCE(
                            (SELECT plan_type 
                             FROM user_subscriptions 
                             WHERE user_id = ? 
                             AND status = 'ACTIVE' 
                             AND end_date > CURRENT_TIMESTAMP
                             ORDER BY created_at DESC 
                             LIMIT 1),
                            'Free'
                        ) as current_plan
                    """;
                    
                    try (PreparedStatement subscriptionStmt = conn.prepareStatement(subscriptionSql)) {
                        subscriptionStmt.setInt(1, userId);
                        ResultSet subscriptionRs = subscriptionStmt.executeQuery();
                        
                        if (subscriptionRs.next()) {
                            String currentPlan = subscriptionRs.getString("current_plan");
                            session.setAttribute("subscriptionPlan", currentPlan);
                        }
                    }
                     
                    // Get user role
                    String userRole = rs.getString("user_role");
                    session.setAttribute("userRole", userRole);
                    
                    // Register or update device information
                    registerOrUpdateDevice(conn, userId, session.getId(), request, response);
                    
                    // Return success response with redirect
                    jsonResponse.put("success", true);
                    jsonResponse.put("redirect", "admin".equals(userRole) ? "admin.jsp" : "index.jsp");
                    
                } else {
                    // Wrong password
                    jsonResponse.put("success", false);
                    jsonResponse.put("error", "INVALID_PASSWORD");
                    logLoginAttempt(conn, null, false, request.getRemoteAddr(), "Invalid password");
                }
                
                response.getWriter().write(jsonResponse.toString());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("error", "SERVER_ERROR");
            jsonResponse.put("message", "A database error occurred");
            response.getWriter().write(jsonResponse.toString());
        }
    }
    
    private void updateLastLogin(Connection conn, int userId) throws SQLException {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }

    private void updateRememberToken(Connection conn, int userId, String token) {
        String sql = "UPDATE users SET remember_token = ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (token != null) {
                stmt.setString(1, token);
            } else {
                stmt.setNull(1, Types.VARCHAR);
            }
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private void logLoginAttempt(Connection conn, Integer userId, boolean success, 
                               String ipAddress, String errorMessage) {
        String sql = "INSERT INTO login_attempts (user_id, success, ip_address, error_message, attempt_time) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (userId != null) {
                stmt.setInt(1, userId);
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setBoolean(2, success);
            stmt.setString(3, ipAddress);
            stmt.setString(4, errorMessage);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private void registerOrUpdateDevice(Connection conn, int userId, String sessionId, 
                                      HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException {
        String deviceId = getDeviceIdFromCookie(request);
        boolean isNewDevice = (deviceId == null);
        
        if (isNewDevice) {
            deviceId = UUID.randomUUID().toString();
        }
        
        String sql = isNewDevice
            ? "INSERT INTO user_devices (device_id, user_id, device_name, device_type, browser, location, session_id, active, last_active) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE, CURRENT_TIMESTAMP)"
            : "UPDATE user_devices SET device_name = ?, device_type = ?, browser = ?, location = ?, session_id = ?, active = TRUE, last_active = CURRENT_TIMESTAMP WHERE device_id = ? AND user_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String deviceName = detectDeviceName(request);
            String deviceType = detectDeviceType(request);
            String browser = detectBrowser(request);
            String location = "Unknown"; // You can implement location detection if needed
            
            if (isNewDevice) {
                stmt.setString(1, deviceId);
                stmt.setInt(2, userId);
                stmt.setString(3, deviceName);
                stmt.setString(4, deviceType);
                stmt.setString(5, browser);
                stmt.setString(6, location);
                stmt.setString(7, sessionId);
            } else {
                stmt.setString(1, deviceName);
                stmt.setString(2, deviceType);
                stmt.setString(3, browser);
                stmt.setString(4, location);
                stmt.setString(5, sessionId);
                stmt.setString(6, deviceId);
                stmt.setInt(7, userId);
            }
            
            stmt.executeUpdate();
        }
        
        // Set or update the device ID cookie
        Cookie deviceCookie = new Cookie("deviceId", deviceId);
        deviceCookie.setMaxAge(365 * 24 * 60 * 60); // 1 year
        deviceCookie.setHttpOnly(true);
        deviceCookie.setPath("/");
        response.addCookie(deviceCookie);
    }
    
    private String getDeviceIdFromCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("deviceId".equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
    
    private String detectDeviceName(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent").toLowerCase();
        if (userAgent.contains("mobile")) {
            return "Mobile Device";
        } else if (userAgent.contains("tablet")) {
            return "Tablet";
        } else {
            return "Desktop Computer";
        }
    }
    
    private String detectDeviceType(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent").toLowerCase();
        if (userAgent.contains("mobile")) {
            return "mobile";
        } else if (userAgent.contains("tablet")) {
            return "tablet";
        } else {
            return "desktop";
        }
    }
    
    private String detectBrowser(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        if (userAgent.contains("Brave")) {
            return "Brave";
        } else if (userAgent.contains("Chrome")) {
            return "Chrome";
        } else if (userAgent.contains("Firefox")) {
            return "Firefox";
        } else if (userAgent.contains("Safari")) {
            return "Safari";
        } else if (userAgent.contains("Edge")) {
            return "Edge";
        } else {
            return "Unknown";
        }
    }
}