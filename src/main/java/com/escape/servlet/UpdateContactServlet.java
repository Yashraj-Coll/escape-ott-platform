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

@WebServlet("/updateContact")
public class UpdateContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Session expired");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        String type = request.getParameter("type");
        String newValue = request.getParameter("newValue");
        
        // Validate inputs
        if (type == null || newValue == null || newValue.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid input parameters");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Validate format based on type
        if (type.equals("email")) {
            if (!newValue.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Invalid email format");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
        } else if (type.equals("mobile")) {
            if (!newValue.matches("^[6-9]\\d{9}$")) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Invalid mobile number format. Must be 10 digits starting with 6-9");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if new value already exists for another user
            String checkSql = "SELECT id FROM users WHERE " + 
                            (type.equals("email") ? "email" : "mobile_number") + " = ? AND id != ?";
                            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, newValue);
                checkStmt.setInt(2, (Integer) session.getAttribute("userId"));
                
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", type.equals("email") ? 
                        "Email already registered with another account" : 
                        "Mobile number already registered with another account");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
            // Update contact information
            String updateSql = "UPDATE users SET " + 
                             (type.equals("email") ? "email" : "mobile_number") + " = ?, " +
                             (type.equals("email") ? "email_verified" : "mobile_verified") + " = 0, " +
                             "verification_code = NULL, " +
                             "verification_code_expiry = NULL " +
                             "WHERE id = ?";
            
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, newValue.trim());
                updateStmt.setInt(2, (Integer) session.getAttribute("userId"));
                
                int updated = updateStmt.executeUpdate();
                if (updated > 0) {
                    // Update session attributes
                    if (type.equals("email")) {
                        session.setAttribute("userEmail", newValue.trim());
                    } else {
                        session.setAttribute("userMobile", newValue.trim());
                    }
                    
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", type.equals("email") ? 
                        "Email updated successfully" : "Mobile number updated successfully");
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Failed to update contact information");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            if (e.getSQLState().equals("23000")) {
                jsonResponse.addProperty("error", type.equals("email") ? 
                    "Email already registered" : "Mobile number already registered");
            } else {
                jsonResponse.addProperty("error", "Database error occurred");
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "An unexpected error occurred");
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to home page if accessed directly
        response.sendRedirect("index.jsp");
    }
}