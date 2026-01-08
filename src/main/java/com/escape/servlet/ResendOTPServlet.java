package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;
import java.util.Random;

@WebServlet("/resendOTP")
public class ResendOTPServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        response.setContentType("application/json");
        
        if (session == null) {
            response.getWriter().write("{\"success\": false, \"error\": \"Session expired. Please login again.\"}");
            return;
        }
        
        String emailOrMobile = (String) session.getAttribute("resetEmail");
        if (emailOrMobile == null) {
            emailOrMobile = (String) session.getAttribute("emailOrMobile");
        }
        
        if (emailOrMobile == null) {
            response.getWriter().write("{\"success\": false, \"error\": \"Session expired. Please try again.\"}");
            return;
        }
        
        String otp = generateOTP();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // First check if user exists
            String checkSql = "SELECT id FROM users WHERE email = ? OR mobile_number = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, emailOrMobile);
                checkStmt.setString(2, emailOrMobile);
                
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    response.getWriter().write("{\"success\": false, \"error\": \"User not found\"}");
                    return;
                }
            }
            
            // Update OTP
            String sql = "UPDATE users SET reset_otp = ?, reset_otp_expiry = DATE_ADD(NOW(), INTERVAL 15 MINUTE) " +
                        "WHERE email = ? OR mobile_number = ?";
                        
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, otp);
                stmt.setString(2, emailOrMobile);
                stmt.setString(3, emailOrMobile);
                
                int rowsAffected = stmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    // Store the OTP in session for verification
                    session.setAttribute("generatedOTP", otp);
                    
                    // In production, send actual email/SMS here
                    System.out.println("New OTP for testing: " + otp);
                    
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false, \"error\": \"Failed to update OTP\"}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"error\": \"Database error occurred\"}");
        }
    }
    
    private String generateOTP() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }
}