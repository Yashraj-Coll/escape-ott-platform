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
import java.sql.Timestamp;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/verifyCode")
public class VerifyCodeServlet extends HttpServlet {
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
        String code = request.getParameter("code");
        
        // Basic validation
        if (type == null || code == null || code.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid verification code");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // First check if code exists and hasn't expired
            String checkSql = "SELECT id, verification_code, verification_code_expiry FROM users " +
                            "WHERE id = ? AND verification_code = ?";
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, (Integer) session.getAttribute("userId"));
                checkStmt.setString(2, code);
                
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    Timestamp expiry = rs.getTimestamp("verification_code_expiry");
                    if (expiry != null && expiry.after(new Timestamp(System.currentTimeMillis()))) {
                        // Code is valid, update verification status
                        String updateSql = "UPDATE users SET " +
                            (type.equals("email") ? "email_verified" : "mobile_verified") + " = 1, " +
                            "verification_code = NULL, " +
                            "verification_code_expiry = NULL " +
                            "WHERE id = ?";
                            
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                            updateStmt.setInt(1, (Integer) session.getAttribute("userId"));
                            updateStmt.executeUpdate();
                            
                            // Clear verification from session
                            session.removeAttribute("verifying_" + type);
                            
                            jsonResponse.addProperty("success", true);
                        }
                    } else {
                        // Code has expired
                        String clearSql = "UPDATE users SET verification_code = NULL, " +
                                        "verification_code_expiry = NULL WHERE id = ?";
                        try (PreparedStatement clearStmt = conn.prepareStatement(clearSql)) {
                            clearStmt.setInt(1, (Integer) session.getAttribute("userId"));
                            clearStmt.executeUpdate();
                        }
                        
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("error", "Verification code has expired. Please request a new one.");
                    }
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Invalid verification code");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
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