package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;

@WebServlet("/resetPassword")
public class ResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        String resetToken = (session != null) ? (String) session.getAttribute("resetToken") : null;
        String newPassword = request.getParameter("newPassword");
        
        System.out.println("Reset Token: " + resetToken); // Logging
        System.out.println("New Password: " + newPassword); // Logging
        
        if (resetToken == null || newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset attempt");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sql = "UPDATE users SET password = ?, reset_token = NULL, " +
                             "reset_token_expiry = NULL WHERE reset_token = ? AND reset_token_expiry > NOW()";
                            
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, newPassword); // In production, use password hashing
                    stmt.setString(2, resetToken);
                    
                    int rowsAffected = stmt.executeUpdate();
                    System.out.println("Rows affected: " + rowsAffected); // Logging
                    
                    if (rowsAffected > 0) {
                        // Log successful password reset
                        String logSql = "INSERT INTO password_reset_attempts (user_id, reset_type, used, created_at, expires_at) " +
                                        "SELECT id, 'password_reset', 1, NOW(), NOW() FROM users WHERE reset_token = ?";
                        try (PreparedStatement logStmt = conn.prepareStatement(logSql)) {
                            logStmt.setString(1, resetToken);
                            logStmt.executeUpdate();
                        }
                        
                        // Update user session
                        String sessionSql = "UPDATE user_sessions SET expires_at = DATE_ADD(NOW(), INTERVAL 30 MINUTE) " +
                                            "WHERE session_token = ?";
                        try (PreparedStatement sessionStmt = conn.prepareStatement(sessionSql)) {
                            sessionStmt.setString(1, session.getId());
                            sessionStmt.executeUpdate();
                        }
                        
                        conn.commit();
                        
                        // Clear session attributes
                        session.removeAttribute("resetEmail");
                        session.removeAttribute("resetToken");
                        session.removeAttribute("maskedContact");
                        
                        request.setAttribute("success", "Password has been reset successfully");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    } else {
                        // Check if the token has expired
                        String checkSql = "SELECT reset_token_expiry FROM users WHERE reset_token = ?";
                        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                            checkStmt.setString(1, resetToken);
                            ResultSet rs = checkStmt.executeQuery();
                            if (rs.next()) {
                                Timestamp expiry = rs.getTimestamp("reset_token_expiry");
                                if (expiry != null && expiry.before(new Timestamp(System.currentTimeMillis()))) {
                                    request.setAttribute("error", "Password reset link has expired. Please request a new one.");
                                } else {
                                    request.setAttribute("error", "Password reset failed. Please try again.");
                                }
                            } else {
                                request.setAttribute("error", "Invalid reset token. Please request a new password reset.");
                            }
                        }
                        conn.rollback();
                        request.getRequestDispatcher("resetPassword.jsp").forward(request, response);
                    }
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace(); // Log the full stack trace
            request.setAttribute("error", "Database error occurred: " + e.getMessage());
            request.getRequestDispatcher("resetPassword.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to the reset password page
        response.sendRedirect("resetPassword.jsp");
    }
}