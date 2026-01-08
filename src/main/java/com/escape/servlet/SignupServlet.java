package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;
import org.json.JSONObject;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String mobileNumber = request.getParameter("mobileNumber");
        String password = request.getParameter("password");
        
        JSONObject jsonResponse = new JSONObject();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if email or mobile exists in a single query
            String checkExistingSql = "SELECT email, mobile_number FROM users WHERE email = ? OR mobile_number = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkExistingSql)) {
                checkStmt.setString(1, email);
                checkStmt.setString(2, mobileNumber);
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("error", "ALREADY_REGISTERED");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
            // Insert new user
            String sql = """
                INSERT INTO users (
                    first_name, 
                    last_name, 
                    email, 
                    mobile_number, 
                    password, 
                    user_role, 
                    created_at,
                    last_login
                ) VALUES (?, ?, ?, ?, ?, 'user', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            """;
            
            try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, firstName);
                stmt.setString(2, lastName);
                stmt.setString(3, email);
                stmt.setString(4, mobileNumber);
                stmt.setString(5, password);
                
                int affectedRows = stmt.executeUpdate();
                
                if (affectedRows > 0) {
                    ResultSet generatedKeys = stmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int userId = generatedKeys.getInt(1);
                        
                        // Create session
                        HttpSession session = request.getSession();
                        session.setAttribute("userId", userId);
                        session.setAttribute("userName", firstName);
                        session.setAttribute("userLastName", lastName);
                        session.setAttribute("userEmail", email);
                        session.setAttribute("userMobile", mobileNumber);
                        session.setAttribute("userRole", "user");
                        session.setAttribute("subscriptionPlan", "Free");
                        
                        // Add member since date
                        session.setAttribute("memberSince", java.time.LocalDate.now().getMonth().toString() + " " + 
                                          java.time.LocalDate.now().getYear());
                        
                        // Log signup
                        logSignup(conn, userId, request.getRemoteAddr());
                        
                        // Register initial device
                        registerDevice(conn, userId, session.getId(), request, response);
                        
                        // Return success response
                        jsonResponse.put("success", true);
                        jsonResponse.put("redirect", "index.jsp");
                        
                    } else {
                        throw new SQLException("Failed to retrieve user ID.");
                    }
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("error", "SIGNUP_FAILED");
                    jsonResponse.put("message", "Failed to create account");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("error", "SERVER_ERROR");
            jsonResponse.put("message", "A database error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private void logSignup(Connection conn, int userId, String ipAddress) {
        String sql = """
            INSERT INTO user_activity_log (
                user_id, 
                activity_type, 
                ip_address, 
                activity_time
            ) VALUES (?, 'SIGNUP', ?, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, ipAddress);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private void registerDevice(Connection conn, int userId, String sessionId, 
                              HttpServletRequest request, HttpServletResponse response) 
            throws SQLException {
        String deviceId = java.util.UUID.randomUUID().toString();
        
        String sql = """
            INSERT INTO user_devices (
                device_id, 
                user_id, 
                device_name, 
                device_type, 
                browser, 
                location, 
                session_id, 
                active, 
                last_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String deviceName = detectDeviceName(request);
            String deviceType = detectDeviceType(request);
            String browser = detectBrowser(request);
            String location = "Unknown"; // You can implement location detection if needed
            
            stmt.setString(1, deviceId);
            stmt.setInt(2, userId);
            stmt.setString(3, deviceName);
            stmt.setString(4, deviceType);
            stmt.setString(5, browser);
            stmt.setString(6, location);
            stmt.setString(7, sessionId);
            
            stmt.executeUpdate();
            
            // Set device cookie
            Cookie deviceCookie = new Cookie("deviceId", deviceId);
            deviceCookie.setMaxAge(365 * 24 * 60 * 60); // 1 year
            deviceCookie.setHttpOnly(true);
            deviceCookie.setPath("/");
            response.addCookie(deviceCookie);
        }
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