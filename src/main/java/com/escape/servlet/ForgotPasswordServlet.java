package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;
import java.util.Random;
import org.json.JSONObject;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
            
        String emailOrMobile = request.getParameter("emailOrMobile");
        String otp = generateOTP();
        String ipAddress = request.getRemoteAddr();
        
        JSONObject jsonResponse = new JSONObject();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT id FROM users WHERE email = ? OR mobile_number = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, emailOrMobile);
                stmt.setString(2, emailOrMobile);
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    
                    // Insert into password_reset_attempts
                    String insertSql = "INSERT INTO password_reset_attempts (user_id, otp, created_at, expires_at) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE))";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setString(2, otp);
                        insertStmt.executeUpdate();
                    }
                    
                    // Update users table with OTP
                    String updateSql = "UPDATE users SET reset_otp = ?, reset_otp_expiry = DATE_ADD(NOW(), INTERVAL 5 MINUTE) WHERE id = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setString(1, otp);
                        updateStmt.setInt(2, userId);
                        updateStmt.executeUpdate();
                    }
                    
                    // Store masked contact in session
                    HttpSession session = request.getSession();
                    session.setAttribute("resetEmail", emailOrMobile);
                    String maskedContact = maskContactInfo(emailOrMobile);
                    session.setAttribute("maskedContact", maskedContact);
                    
                    // Log session information
                    String sessionSql = "INSERT INTO user_sessions (user_id, session_token, ip_address, expires_at) VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL 30 MINUTE))";
                    try (PreparedStatement sessionStmt = conn.prepareStatement(sessionSql)) {
                        sessionStmt.setInt(1, userId);
                        sessionStmt.setString(2, session.getId());
                        sessionStmt.setString(3, ipAddress);
                        sessionStmt.executeUpdate();
                    }
                    
                    // In production, send actual email/SMS here
                    System.out.println("OTP for testing: " + otp);
                    
                    jsonResponse.put("success", true);
                    jsonResponse.put("redirect", "verifyOTP.jsp");
                    
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("error", "NOT_FOUND");
                    jsonResponse.put("message", "No account found with this email/mobile number. Please signup first.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("error", "SERVER_ERROR");
            jsonResponse.put("message", "A database error occurred. Please try again.");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private String generateOTP() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }
    
    private String maskContactInfo(String contact) {
        if (contact.contains("@")) {
            // Email masking
            String[] parts = contact.split("@");
            String name = parts[0];
            return name.substring(0, Math.min(2, name.length())) + 
                   "***@" + parts[1];
        } else {
            // Mobile masking
            return "******" + contact.substring(Math.max(0, contact.length() - 4));
        }
    }
}