package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/deleteAccount")
public class DeleteAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String password = request.getParameter("password");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JsonObject jsonResponse = new JsonObject();
        
        if (userId == null || password == null || password.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid request parameters");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // First verify password
            String verifySQL = "SELECT password FROM users WHERE id = ?";
            try (PreparedStatement verifyStmt = conn.prepareStatement(verifySQL)) {
                verifyStmt.setInt(1, userId);
                ResultSet rs = verifyStmt.executeQuery();
                
                if (!rs.next() || !password.equals(rs.getString("password"))) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Incorrect password");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
         // Delete related records in correct order to handle foreign key constraints
            String[] deleteQueries = {
                "DELETE FROM continue_watching WHERE id = ?",
                "DELETE FROM user_mylist WHERE id = ?",
                "DELETE FROM user_likes WHERE id = ?",
                "DELETE FROM login_attempts WHERE user_id = ?",
                "DELETE FROM password_reset_attempts WHERE user_id = ?",
                "DELETE FROM user_subscriptions WHERE user_id = ?",
                "DELETE FROM payment_transactions WHERE user_id = ?",
                "DELETE FROM subscription_history WHERE user_id = ?",
                "DELETE FROM device_activity_log WHERE user_id = ?",
                "DELETE FROM user_devices WHERE user_id = ?",
                "DELETE FROM user_notifications WHERE user_id = ?",  // Added user_notifications deletion
                "DELETE FROM users WHERE id = ?"
            };
            
            // Execute each delete query
            for (String query : deleteQueries) {
                try (PreparedStatement stmt = conn.prepareStatement(query)) {
                    if (query.contains("user_id")) {
                        stmt.setInt(1, userId);
                    } else {
                        stmt.setInt(1, userId);
                    }
                    stmt.executeUpdate();
                }
            }
            
            // Commit transaction
            conn.commit();
            session.invalidate();
            
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Your account and all related data have been deleted successfully");
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            response.getWriter().write(jsonResponse.toString());
        }
    }
}