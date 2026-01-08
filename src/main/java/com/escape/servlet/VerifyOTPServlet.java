package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;

@WebServlet("/verifyOTP")
public class VerifyOTPServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession();
        response.setContentType("application/json");

        // Get email/mobile from session
        String emailOrMobile = (String) session.getAttribute("resetEmail");
        if (emailOrMobile == null) {
            emailOrMobile = (String) session.getAttribute("emailOrMobile");
        }

        // Check if this is an expire OTP request
        if ("true".equals(request.getParameter("expireOTP"))) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                String updateSql = "UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL " +
                                 "WHERE email = ? OR mobile_number = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                    stmt.setString(1, emailOrMobile);
                    stmt.setString(2, emailOrMobile);
                    stmt.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            response.getWriter().write("{\"success\": true}");
            return;
        }
        
        // Get submitted OTP
        String submittedOTP = request.getParameter("otp");
        
        // Validate inputs
        if (emailOrMobile == null || submittedOTP == null || submittedOTP.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"error\": \"Invalid request parameters\"}");
            return;
        }
        
        // If auto expire parameter is true, mark OTP as expired
        if ("true".equals(request.getParameter("autoExpire"))) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                String updateSql = "UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL " +
                                 "WHERE email = ? OR mobile_number = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                    stmt.setString(1, emailOrMobile);
                    stmt.setString(2, emailOrMobile);
                    stmt.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            response.getWriter().write("{\"success\": false, \"error\": \"OTP has expired. Please request a new one.\"}");
            return;
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Check OTP and its expiry
                String sql = "SELECT id, reset_otp, reset_otp_expiry FROM users " +
                            "WHERE (email = ? OR mobile_number = ?)";
                            
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, emailOrMobile);
                    stmt.setString(2, emailOrMobile);
                    
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        String storedOTP = rs.getString("reset_otp");
                        Timestamp expiryTime = rs.getTimestamp("reset_otp_expiry");
                        
                        // First check expiry
                        if (expiryTime != null && expiryTime.before(new Timestamp(System.currentTimeMillis()))) {
                            // Update database to clear expired OTP
                            String updateSql = "UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL " +
                                             "WHERE id = ?";
                            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                                updateStmt.setInt(1, userId);
                                updateStmt.executeUpdate();
                            }
                            conn.commit();
                            response.getWriter().write("{\"success\": false, \"error\": \"OTP Expired!! Please request a new one.\"}");
                            return;
                        }
                        
                        // Then check if OTP exists
                        if (storedOTP == null) {
                            conn.commit();
                            response.getWriter().write("{\"success\": false, \"error\": \"No OTP found. Please request a new one.\"}");
                            return;
                        }
                        
                        // Finally verify OTP
                        if (storedOTP.equals(submittedOTP)) {
                            // Mark OTP as used
                            String updateSql = "UPDATE users SET reset_otp = NULL, reset_otp_expiry = NULL " +
                                             "WHERE id = ?";
                            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                                updateStmt.setInt(1, userId);
                                updateStmt.executeUpdate();
                            }
                            
                            // Update password_reset_attempts
                            String updateAttemptSql = "UPDATE password_reset_attempts SET used = 1 " +
                                                      "WHERE user_id = ? AND otp = ? AND used = 0";
                            try (PreparedStatement updateAttemptStmt = conn.prepareStatement(updateAttemptSql)) {
                                updateAttemptStmt.setInt(1, userId);
                                updateAttemptStmt.setString(2, submittedOTP);
                                updateAttemptStmt.executeUpdate();
                            }
                            
                            // Generate reset token
                            String resetToken = UUID.randomUUID().toString();
                            String tokenSql = "UPDATE users SET reset_token = ?, reset_token_expiry = DATE_ADD(NOW(), INTERVAL 1 HOUR) WHERE id = ?";
                            try (PreparedStatement tokenStmt = conn.prepareStatement(tokenSql)) {
                                tokenStmt.setString(1, resetToken);
                                tokenStmt.setInt(2, userId);
                                tokenStmt.executeUpdate();
                            }
                            
                            session.setAttribute("resetToken", resetToken);
                            
                            if ("true".equals(session.getAttribute("isSignup"))) {
                                // If this is a signup verification, mark email as verified
                                String verifyEmailSql = "UPDATE users SET email_verified = true " +
                                                      "WHERE id = ?";
                                try (PreparedStatement verifyStmt = conn.prepareStatement(verifyEmailSql)) {
                                    verifyStmt.setInt(1, userId);
                                    verifyStmt.executeUpdate();
                                }
                            }
                            
                            conn.commit();
                            
                            // Set verification flag in session
                            session.setAttribute("otpVerified", true);
                            
                            // Determine redirect URL based on context
                            String redirectUrl = "resetPassword.jsp";
                            if (session.getAttribute("isSignup") != null) {
                                redirectUrl = "index.jsp";
                            }
                            
                            response.getWriter().write("{\"success\": true, \"redirect\": \"" + redirectUrl + "\"}");
                        } else {
                            conn.commit();
                            response.getWriter().write("{\"success\": false, \"error\": \"Invalid verification code. Please try again.\"}");
                        }
                    } else {
                        conn.commit();
                        response.getWriter().write("{\"success\": false, \"error\": \"User not found\"}");
                    }
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"error\": \"An error occurred while verifying OTP\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"error\": \"Unexpected error occurred\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to login page if accessed directly
        response.sendRedirect("login.jsp");
    }
}