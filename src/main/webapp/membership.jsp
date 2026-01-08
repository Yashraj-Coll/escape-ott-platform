<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    int userId = 0;
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (session.getAttribute("userId") != null) {
        userId = (int) session.getAttribute("userId");
    }

    // Get subscription and payment details from database
    String currentPlan = "";
    String paymentMethod = "";
    String lastTransactionId = "";
    Timestamp lastPaymentDate = null;
    double lastPaymentAmount = 0.0;
    String cardNumber = "";
    String cardType = "";
    String upiId = "";
    String bankName = "";
    String walletName = "";
    String nextBillingDate = "";
    String memberSince = "";
    ResultSet paymentHistory = null;
    Connection conn = null;
    
    try {
        conn = DatabaseConnection.getConnection();
        
        // Get member since date
        String memberSinceSql = "SELECT DATE_FORMAT(created_at, '%M %Y') as signup_date FROM users WHERE id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(memberSinceSql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                memberSince = rs.getString("signup_date");
            }
        }
        
        // Get current subscription details
        String subscriptionSql = 
            "SELECT us.*, pt.payment_method, pt.card_number, pt.card_type, " +
            "pt.upi_id, pt.bank_name, pt.wallet_name, pt.transaction_id, " +
            "DATE_FORMAT(us.next_billing_date, '%d %M %Y') as formatted_next_billing_date " +
            "FROM user_subscriptions us " +
            "LEFT JOIN payment_transactions pt ON us.last_transaction_id = pt.transaction_id " +
            "WHERE us.user_id = ? AND us.status = 'ACTIVE'";
        
        try (PreparedStatement pstmt = conn.prepareStatement(subscriptionSql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                currentPlan = rs.getString("plan_type");
                lastTransactionId = rs.getString("transaction_id");
                lastPaymentDate = rs.getTimestamp("last_payment_date");
                lastPaymentAmount = rs.getDouble("last_payment_amount");
                paymentMethod = rs.getString("payment_method");
                cardNumber = rs.getString("card_number");
                cardType = rs.getString("card_type");
                upiId = rs.getString("upi_id");
                bankName = rs.getString("bank_name");
                walletName = rs.getString("wallet_name");
                nextBillingDate = rs.getString("formatted_next_billing_date");
                
                // Format payment method display
                if (paymentMethod != null) {
                    switch(paymentMethod) {
                        case "card":
                            paymentMethod = cardType + " card ending in " + 
                                cardNumber.substring(cardNumber.length() - 4);
                            break;
                        case "upi":
                            paymentMethod = "UPI ID: " + upiId;
                            break;
                        case "netbanking":
                            paymentMethod = "Net Banking - " + bankName;
                            break;
                        case "wallet":
                            paymentMethod = walletName + " Wallet";
                            break;
                    }
                }
            }
        }
        
        // Get payment history with plan transitions
        String historySql = 
            "SELECT DISTINCT " +
            "    pt.*, " +
            "    DATE_FORMAT(pt.created_at, '%d %M %Y, %h:%i %p') as formatted_date, " +
            "    sh.old_plan, " +
            "    sh.new_plan, " +
            "    CASE " +
            "        WHEN sh.old_plan = 'Free' OR sh.old_plan IS NULL THEN CONCAT('Subscribed to ', sh.new_plan) " +
            "        ELSE CONCAT('Changed from ', sh.old_plan, ' to ', sh.new_plan) " +
            "    END as plan_change_description " +
            "FROM payment_transactions pt " +
            "LEFT JOIN subscription_history sh ON pt.transaction_id = sh.transaction_id " +
            "WHERE pt.user_id = ? AND pt.status = 'SUCCESS' " +
            "GROUP BY pt.transaction_id, pt.created_at, sh.old_plan, sh.new_plan " +
            "ORDER BY pt.created_at DESC " +
            "LIMIT 10";
        
        PreparedStatement historyStmt = conn.prepareStatement(historySql);
        historyStmt.setInt(1, userId);
        paymentHistory = historyStmt.executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Membership - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f3f3f3;
            color: #333;
        }
        
        .account-nav {
            background: white;
            border-right: 1px solid #ddd;
            height: 100vh;
            position: fixed;
            width: 250px;
            padding: 20px 0;
        }
        
        .account-nav .nav-link {
            color: #333;
            padding: 12px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s ease;
        }
        
        .account-nav .nav-link:hover {
            background-color: #f8f8f8;
            color: #e50914;
        }
        
        .account-nav .nav-link.active {
            background-color: #f3f3f3;
            color: #e50914;
            font-weight: 500;
        }

        .account-nav .nav-link i {
            width: 20px;
            text-align: center;
        }
        
        .account-content {
            margin-left: 250px;
            padding: 40px;
        }
        
        .back-button {
            color: #333;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        
        .back-button:hover {
            color: #e50914;
        }

        .section-card {
            background: white;
            border-radius: 12px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }

        .member-since {
        background: #7b3dbd;
        color: white;
        padding: 8px 16px;
        border-radius: 4px;
        display: inline-block;
        margin-bottom: 16px;
        font-size: 0.95rem;
    }

        .plan-badge {
            background: #e50914;
            color: white;
            padding: 6px 16px;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.9rem;
            display: inline-block;
            margin-right: 12px;
        }

        .plan-details {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 24px;
            margin: 20px 0;
            border: 1px solid #e9ecef;
        }

        .next-billing {
            color: #666;
            font-size: 0.9rem;
            margin-top: 8px;
        }

        .plan-price {
            font-size: 24px;
            font-weight: 600;
            color: #e50914;
        }

        .plan-period {
            color: #666;
            font-size: 0.9rem;
        }

        .payment-history {
            margin-top: 32px;
        }

        .history-item {
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: all 0.3s ease;
        }

        .history-item:hover {
            background-color: #f8f9fa;
        }

        .history-item:last-child {
            border-bottom: none;
        }

        .transaction-id {
            color: #666;
            font-size: 0.85rem;
            margin-bottom: 8px;
        }

        .payment-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            background: #f0f0f0;
            border-radius: 20px;
            font-size: 0.9rem;
            color: #444;
        }

        .payment-badge i {
            color: #666;
        }

        .plan-change {
            margin-top: 8px;
            color: #666;
            font-size: 0.9rem;
        }

        .plan-transition {
            color: #1a73e8;
            font-size: 0.9rem;
            margin-top: 8px;
        }

        .payment-amount {
            font-weight: 600;
            color: #198754;
        }

        .btn-change-plan {
            background: #e50914;
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-change-plan:hover {
            background: #cc0812;
            color: white;
            transform: translateY(-2px);
        }

        .payment-info {
            padding: 20px 0;
            border-bottom: 1px solid #eee;
        }

        .payment-info:last-child {
            border-bottom: none;
        }

        .payment-info-label {
            font-weight: 500;
            color: #444;
        }

        .payment-method {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: #f8f9fa;
            border-radius: 8px;
            font-size: 0.95rem;
        }

        .section-title {
            color: #111;
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 24px;
        }

        .subsection-title {
            color: #333;
            font-size: 1.2rem;
            font-weight: 500;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid #f0f0f0;
        }

        @media (max-width: 768px) {
            .account-nav {
                width: 100%;
                height: auto;
                position: relative;
                margin-bottom: 20px;
            }
            
            .account-content {
                margin-left: 0;
                padding: 20px;
            }
            
            .section-card {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="account-nav">
        <a href="index.jsp" class="back-button px-4 py-2">
            <i class="fas fa-arrow-left"></i>
            Back to Escape
        </a>
        <div class="nav flex-column nav-pills">
            <a class="nav-link" href="account.jsp">
                <i class="fas fa-home"></i>
                Overview
            </a>
            <a class="nav-link active" href="membership.jsp">
                <i class="fas fa-credit-card"></i>
                Membership
            </a>
            <a class="nav-link" href="security.jsp">
                <i class="fas fa-shield-alt"></i>
                Security
            </a>
            <a class="nav-link" href="devices.jsp">
                <i class="fas fa-tablet-alt"></i>
                Devices
            </a>
            <a class="nav-link" href="profiles.jsp">
                <i class="fas fa-user-circle"></i>
                Profiles
            </a>
        </div>
    </div>

    <div class="account-content">
        <h1 class="section-title">Membership &amp; Billing</h1>
        
        <div class="section-card">
            <div class="member-since">Member since <%= memberSince %></div>
            
            <h2 class="subsection-title">Plan Details</h2>
            <div class="plan-details">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="d-flex align-items-center">
                            <span class="plan-badge"><%= currentPlan %></span>
                            <% 
                                String planDescription = "";
                                String planPrice = "";
                                switch(currentPlan) {
                                    case "Basic":
                                        planDescription = "720p • Good video quality";
                                        planPrice = "₹199";
                                        break;
                                    case "Standard":
                                        planDescription = "1080p • Better video quality";
                                        planPrice = "₹499";
                                        break;
                                    case "Premium":
                                        planDescription = "4K+HDR • Best video quality";
                                        planPrice = "₹699";
                                        break;
                                    case "Free":
                                        planDescription = "Limited access";
                                        planPrice = "Free";
                                        break;
                                }
                            %>
                            <span class="text-muted ms-2"><%= planDescription %></span>
                        </div>
                        <% if (!"Free".equals(currentPlan) && nextBillingDate != null) { %>
                            <div class="next-billing">
                                Next billing date: <%= nextBillingDate %>
                            </div>
                        <% } %>
                    </div>
                    <div class="text-end">
                        <div class="plan-price"><%= planPrice %></div>
                        <% if (!"Free".equals(currentPlan)) { %>
                            <div class="plan-period">per month</div>
                        <% } %>
                    </div>
                </div>
                <% if ("Free".equals(currentPlan)) { %>
                    <button class="btn-change-plan mt-4" onclick="window.location.href='changePlan.jsp'">
                        Upgrade Plan
                    </button>
                <% } else { %>
                    <button class="btn-change-plan mt-4" onclick="window.location.href='changePlan.jsp'">
                        Change Plan
                    </button>
                <% } %>
            </div>

            <% if (!"Free".equals(currentPlan)) { %>
            <div class="payment-details mt-5">
                <h3 class="subsection-title">Payment Information</h3>
                <div class="payment-info">
                    <div class="row align-items-center">
                        <div class="col-md-3">
                            <span class="payment-info-label">Payment Method</span>
                        </div>
                        <div class="col-md-9">
                            <% 
                                String icon = "";
                                switch(paymentMethod != null ? paymentMethod.split(" ")[0].toLowerCase() : "") {
                                    case "visa":
                                    case "mastercard":
                                    case "amex":
                                        icon = "fa-credit-card";
                                        break;
                                    case "upi":
                                        icon = "fa-mobile-alt";
                                        break;
                                    case "net":
                                        icon = "fa-university";
                                        break;
                                    default:
                                        icon = "fa-wallet";
                                }
                            %>
                            <div class="payment-method">
                                <i class="fas <%= icon %>"></i>
                                <%= paymentMethod %>
                            </div>
                        </div>
                    </div>
                </div>

                <% if (lastPaymentDate != null && lastTransactionId != null) { %>
                <div class="payment-info">
                    <div class="row">
                        <div class="col-md-3">
                            <span class="payment-info-label">Last Payment</span>
                        </div>
                        <div class="col-md-9">
                            <div class="payment-amount mb-1">₹<%= String.format("%.2f", lastPaymentAmount) %></div>
                            <div class="text-muted small">
                                <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(lastPaymentDate) %>
                            </div>
                            <div class="text-muted small">
                                Transaction ID: <%= lastTransactionId %>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <div class="payment-history">
                <h3 class="subsection-title">Payment History</h3>
                <% if (paymentHistory != null && paymentHistory.isBeforeFirst()) { %>
                    <% while(paymentHistory.next()) { %>
                        <div class="history-item">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <div class="transaction-id">
                                        Transaction ID: <%= paymentHistory.getString("transaction_id") %>
                                    </div>
                                    <div class="payment-badge">
                                        <i class="fas <%= 
                                            paymentHistory.getString("payment_method").equals("card") ? "fa-credit-card" :
                                            paymentHistory.getString("payment_method").equals("upi") ? "fa-mobile-alt" :
                                            paymentHistory.getString("payment_method").equals("netbanking") ? "fa-university" : 
                                            "fa-wallet" 
                                        %>"></i>
                                        <%= paymentHistory.getString("payment_method").substring(0,1).toUpperCase() + 
                                            paymentHistory.getString("payment_method").substring(1) %>
                                    </div>
                                    
                                    <%
                                        String oldPlan = paymentHistory.getString("old_plan");
                                        String newPlan = paymentHistory.getString("new_plan");
                                        if (oldPlan != null && newPlan != null) {
                                            if (oldPlan.equals("Free")) {
                                    %>
                                        <div class="plan-transition">
                                            <i class="fas fa-arrow-circle-up"></i>
                                            Upgraded to <%= newPlan %> plan
                                        </div>
                                    <%      } else { %>
                                        <div class="plan-transition">
                                            <i class="fas fa-exchange-alt"></i>
                                            Changed from <%= oldPlan %> to <%= newPlan %>
                                        </div>
                                    <%      }
                                        }
                                    %>
                                    
                                    <div class="text-muted small mt-2">
                                        <%= paymentHistory.getString("formatted_date") %>
                                    </div>
                                </div>
                                <div class="payment-amount">
                                    ₹<%= String.format("%.2f", paymentHistory.getDouble("amount")) %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="text-muted text-center py-4">
                        No payment history available
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    } catch(SQLException e) {
        e.printStackTrace();
        // Just log the error, don't redirect
        out.println("<div class='alert alert-danger text-center' role='alert'>");
        out.println("    <strong>Error!</strong> Failed to load membership details. Please try again later.");
        out.println("</div>");
    } finally {
        if(conn != null) {
            try { conn.close(); } catch(SQLException e) { }
        }
        if(paymentHistory != null) {
            try { paymentHistory.close(); } catch(SQLException e) { }
        }
    }
%>