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
import java.sql.SQLException;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/updateAccount")
public class UpdateAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getAttribute("session") != null ? 
            (HttpSession) request.getAttribute("session") : request.getSession(false);
            
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String newEmail = request.getParameter("email");
        String newMobile = request.getParameter("mobile");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            boolean updated = false;
            
            // Update email/mobile if provided
            if (newEmail != null && !newEmail.isEmpty() || newMobile != null && !newMobile.isEmpty()) {
                String updateContactSql = "UPDATE users SET email = ?, mobile_number = ? WHERE id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateContactSql)) {
                    stmt.setString(1, newEmail != null && !newEmail.isEmpty() ? newEmail : 
                        (String) session.getAttribute("userEmail"));
                    stmt.setString(2, newMobile != null && !newMobile.isEmpty() ? newMobile : 
                        (String) session.getAttribute("userMobile"));
                    stmt.setInt(3, userId);
                    
                    if (stmt.executeUpdate() > 0) {
                        updated = true;
                        if (newEmail != null && !newEmail.isEmpty()) {
                            session.setAttribute("userEmail", newEmail);
                        }
                        if (newMobile != null && !newMobile.isEmpty()) {
                            session.setAttribute("userMobile", newMobile);
                        }
                    }
                }
            }
            
            // Update password if provided
            if (currentPassword != null && !currentPassword.isEmpty() && 
                newPassword != null && !newPassword.isEmpty()) {
                    
                String checkPasswordSql = "SELECT password FROM users WHERE id = ? AND password = ?";
                try (PreparedStatement checkStmt = conn.prepareStatement(checkPasswordSql)) {
                    checkStmt.setInt(1, userId);
                    checkStmt.setString(2, currentPassword);
                    
                    if (checkStmt.executeQuery().next()) {
                        String updatePasswordSql = "UPDATE users SET password = ? WHERE id = ?";
                        try (PreparedStatement updateStmt = conn.prepareStatement(updatePasswordSql)) {
                            updateStmt.setString(1, newPassword);
                            updateStmt.setInt(2, userId);
                            
                            if (updateStmt.executeUpdate() > 0) {
                                updated = true;
                            }
                        }
                    } else {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("error", "Current password is incorrect");
                        response.getWriter().write(jsonResponse.toString());
                        return;
                    }
                }
            }
            
            if (updated) {
                jsonResponse.addProperty("success", true);
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "No changes were made");
            }
            
        } catch (SQLException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
            e.printStackTrace();
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
}