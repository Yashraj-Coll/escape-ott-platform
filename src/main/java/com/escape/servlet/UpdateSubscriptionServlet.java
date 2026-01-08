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
import java.time.LocalDateTime;
import java.util.stream.Collectors;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet("/updateSubscription")
public class UpdateSubscriptionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Parse request data
            String requestBody = request.getReader().lines().collect(Collectors.joining());
            JsonObject requestData = JsonParser.parseString(requestBody).getAsJsonObject();
            
            int userId = (int) session.getAttribute("userId");
            String newPlan = requestData.get("plan").getAsString();
            String transactionId = requestData.get("transactionId").getAsString();
            
            // Get current plan details
            String currentPlan = getCurrentActivePlan(conn, userId);
            
            // Validate transaction
            validateTransaction(conn, transactionId, userId);
            
            // Deactivate current subscription if exists
            deactivateCurrentSubscription(conn, userId);
            
            // Create new subscription
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime endDate = now.plusMonths(1);
            createNewSubscription(conn, userId, newPlan, now, endDate, transactionId);
            
            // Update user table
            updateUserDetails(conn, userId, newPlan);
            
            // Record in subscription history
            recordSubscriptionHistory(conn, userId, currentPlan, newPlan, transactionId, endDate);
            
            // Update session attributes
            session.setAttribute("subscriptionPlan", newPlan);
            session.setAttribute("userRole", newPlan.equals("Free") ? "user" : "premium");
            
            conn.commit();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Subscription updated successfully");
            
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private String getCurrentActivePlan(Connection conn, int userId) throws SQLException {
        String sql = """
            SELECT COALESCE(
                (SELECT plan_type 
                 FROM user_subscriptions 
                 WHERE user_id = ? 
                 AND status = 'ACTIVE' 
                 AND end_date > CURRENT_TIMESTAMP
                 ORDER BY created_at DESC 
                 LIMIT 1),
                'Free'
            ) as current_plan
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            return rs.next() ? rs.getString("current_plan") : "Free";
        }
    }
    
    private void validateTransaction(Connection conn, String transactionId, int userId) 
            throws SQLException {
        String sql = """
            SELECT status 
            FROM payment_transactions 
            WHERE transaction_id = ? 
            AND user_id = ? 
            AND status = 'SUCCESS'
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, transactionId);
            pstmt.setInt(2, userId);
            ResultSet rs = pstmt.executeQuery();
            if (!rs.next()) {
                throw new SQLException("Invalid or unsuccessful transaction");
            }
        }
    }
    
    private void deactivateCurrentSubscription(Connection conn, int userId) throws SQLException {
        String sql = """
            UPDATE user_subscriptions 
            SET status = 'INACTIVE', 
                end_date = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP
            WHERE user_id = ? 
            AND status = 'ACTIVE'
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        }
    }
    
    private void createNewSubscription(Connection conn, int userId, String plan, 
                                     LocalDateTime startDate, LocalDateTime endDate,
                                     String transactionId) throws SQLException {
        String sql = """
            INSERT INTO user_subscriptions (
                user_id, plan_type, status, start_date, end_date,
                next_billing_date, last_payment_date, last_payment_amount,
                last_transaction_id
            ) VALUES (?, ?, 'ACTIVE', ?, ?, ?, ?, 
                     (SELECT amount FROM payment_transactions WHERE transaction_id = ?),
                     ?)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, plan);
            pstmt.setTimestamp(3, Timestamp.valueOf(startDate));
            pstmt.setTimestamp(4, Timestamp.valueOf(endDate));
            pstmt.setDate(5, java.sql.Date.valueOf(endDate.toLocalDate()));
            pstmt.setTimestamp(6, Timestamp.valueOf(startDate));
            pstmt.setString(7, transactionId);
            pstmt.setString(8, transactionId);
            pstmt.executeUpdate();
        }
    }
    
    private void updateUserDetails(Connection conn, int userId, String plan) throws SQLException {
        String sql = """
            UPDATE users 
            SET subscription_plan = ?,
                user_role = ?,
                updated_at = CURRENT_TIMESTAMP 
            WHERE id = ?
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, plan);
            pstmt.setString(2, plan.equals("Free") ? "user" : "premium");
            pstmt.setInt(3, userId);
            pstmt.executeUpdate();
        }
    }
    
    private void recordSubscriptionHistory(Connection conn, int userId, String oldPlan, 
                                         String newPlan, String transactionId,
                                         LocalDateTime nextBillingDate) throws SQLException {
        String sql = """
            INSERT INTO subscription_history (
                user_id, action_type, old_plan, new_plan,
                transaction_id, next_billing_date, amount_paid
            ) VALUES (?, ?, ?, ?, ?, ?, 
                     (SELECT amount FROM payment_transactions WHERE transaction_id = ?))
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, oldPlan.equals("Free") ? "NEW_SUBSCRIPTION" : "PLAN_CHANGE");
            pstmt.setString(3, oldPlan);
            pstmt.setString(4, newPlan);
            pstmt.setString(5, transactionId);
            pstmt.setDate(6, java.sql.Date.valueOf(nextBillingDate.toLocalDate()));
            pstmt.setString(7, transactionId);
            pstmt.executeUpdate();
        }
    }
}