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
import java.sql.Timestamp;
import java.util.Random;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/sendVerificationCode")
public class SendVerificationCodeServlet extends HttpServlet {
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
        String contact = request.getParameter("contact");
        
        // Basic validation
        if (type == null || contact == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid parameters");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        // Generate 6-digit verification code
        Random random = new Random();
        String verificationCode = String.format("%06d", random.nextInt(1000000));
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Store verification code in database
            String sql = "UPDATE users SET verification_code = ?, verification_code_expiry = ? " +
                        "WHERE " + (type.equals("email") ? "email" : "mobile_number") + " = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, verificationCode);
                // Set expiry to 10 minutes from now
                stmt.setTimestamp(2, new Timestamp(System.currentTimeMillis() + 600000));
                stmt.setString(3, contact);
                
                int updated = stmt.executeUpdate();
                if (updated > 0) {
                    // In real application, you would send email/SMS here
                    // For testing, we'll just send code in response and log to console
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("code", verificationCode);
                    
                    // Log verification code to console for testing
                    System.out.println("Verification code for " + type + " (" + contact + "): " + verificationCode);
                    
                    // Store contact in session for verification
                    session.setAttribute("verifying_" + type, contact);
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Failed to send verification code");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Database error occurred");
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