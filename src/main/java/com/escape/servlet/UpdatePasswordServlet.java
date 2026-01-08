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
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/updatePassword")
public class UpdatePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        
        if (session == null || userId == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        
        // Validate password is not null or empty
        if (currentPassword == null || currentPassword.trim().isEmpty() 
            || newPassword == null || newPassword.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Password cannot be empty");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // First verify current password
            String checkSql = "SELECT id FROM users WHERE id = ? AND password = ?";
                
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setString(2, currentPassword);
                
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Current password is incorrect");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
                
                // Update to new password
                String updateSql = "UPDATE users SET password = ? WHERE id = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, newPassword);
                    updateStmt.setInt(2, userId);
                    
                    int rowsAffected = updateStmt.executeUpdate();
                    if (rowsAffected > 0) {
                        jsonResponse.addProperty("success", true);
                        jsonResponse.addProperty("message", "Password updated successfully");
                    } else {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("error", "Failed to update password");
                    }
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to the update password page
        response.sendRedirect("updatePassword.jsp");
    }
}