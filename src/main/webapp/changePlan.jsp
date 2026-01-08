<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%
    // Get session attributes
    String userName = (String) session.getAttribute("userName");
    String currentPlan = (String) session.getAttribute("subscriptionPlan");
    String userEmail = (String) session.getAttribute("userEmail");
    String userMobile = (String) session.getAttribute("userMobile");
    int userId = 0;
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get userId from session
    if (session.getAttribute("userId") != null) {
        userId = (int) session.getAttribute("userId");
    }
    
    // Get subscription details from database
    String subscriptionStatus = "";
    String nextBillingDate = "";
    double lastPaymentAmount = 0.0;
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(
             "SELECT status, next_billing_date, last_payment_amount FROM user_subscriptions WHERE user_id = ?"
         )) {
        pstmt.setInt(1, userId);
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                subscriptionStatus = rs.getString("status");
                nextBillingDate = rs.getDate("next_billing_date") != null ? 
                    rs.getDate("next_billing_date").toString() : "";
                lastPaymentAmount = rs.getDouble("last_payment_amount");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Plan - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <style>
        :root {
            --primary-color: #e50914;
            --secondary-color: #0071eb;
        }
        
        body {
            background-color: #f3f3f3;
            color: #333;
            font-family: 'Arial', sans-serif;
        }
        
        .main-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .back-button {
            color: #333;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            transition: color 0.3s ease;
        }
        
        .back-button:hover {
            color: var(--primary-color);
        }
        
        .plan-card {
            background: white;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        
        .plan-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        
        .plan-card.selected {
            border: 2px solid var(--primary-color);
        }
        
        .plan-card.current {
            border: 2px solid #28a745;
        }
        
        .current-plan-badge {
            position: absolute;
            top: 10px;
            right: -35px;
            background: #28a745;
            color: white;
            padding: 5px 40px;
            transform: rotate(45deg);
            font-size: 0.8rem;
        }
        
        .plan-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .plan-name {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
        }
        
        .plan-price {
            font-size: 1.8rem;
            font-weight: bold;
        }
        
        .plan-price small {
            font-size: 1rem;
            color: #666;
        }
        
        .plan-features {
            margin: 20px 0;
        }
        
        .feature-item {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
            color: #666;
        }
        
        .feature-item i {
            color: #28a745;
        }
        
        .quality-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            margin-top: 10px;
        }
        
        .quality-4k { background-color: #28a745; color: white; }
        .quality-hd { background-color: #17a2b8; color: white; }
        .quality-sd { background-color: #6c757d; color: white; }
        
        .btn-change-plan {
            background-color: var(--primary-color);
            border: none;
            color: white;
            padding: 12px 24px;
            font-weight: 600;
            width: 100%;
            margin-top: 20px;
            transition: background-color 0.3s ease;
        }
        
        .btn-change-plan:hover:not(:disabled) {
            background-color: #bd070f;
            color: white;
        }
        
        .btn-change-plan:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }

        /* Notification styles */
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            border-radius: 4px;
            color: white;
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideIn 0.5s ease;
        }

        .notification.success {
            background-color: #28a745;
        }

        .notification.error {
            background-color: #dc3545;
        }

        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        .comparison-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .comparison-table th, 
        .comparison-table td {
            padding: 15px;
            text-align: center;
            border-bottom: 1px solid #ddd;
        }
        
        .comparison-table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        
        .comparison-table tr:last-child td {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <div class="main-container">
        <a href="account.jsp" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Back to Account
        </a>
        
        <h2 class="mb-4">Choose your plan</h2>
        
        <div class="row">
            <!-- Basic Plan -->
            <div class="col-md-4">
                <div class="plan-card <%= currentPlan != null && currentPlan.equals("Basic") ? "current" : "" %>" 
                     onclick="selectPlan('Basic', 199)">
                    <% if (currentPlan != null && currentPlan.equals("Basic")) { %>
                        <div class="current-plan-badge">CURRENT</div>
                    <% } %>
                    <div class="plan-header">
                        <div class="plan-name">Basic</div>
                        <div class="plan-price">₹199<small>/mo</small></div>
                    </div>
                    <div class="quality-badge quality-sd">SD</div>
                    <div class="plan-features">
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Watch on 1 device</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Standard definition</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Ad-free entertainment</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Standard Plan -->
            <div class="col-md-4">
                <div class="plan-card <%= currentPlan != null && currentPlan.equals("Standard") ? "current" : "" %>" 
                     onclick="selectPlan('Standard', 499)">
                    <% if (currentPlan != null && currentPlan.equals("Standard")) { %>
                        <div class="current-plan-badge">CURRENT</div>
                    <% } %>
                    <div class="plan-header">
                        <div class="plan-name">Standard</div>
                        <div class="plan-price">₹499<small>/mo</small></div>
                    </div>
                    <div class="quality-badge quality-hd">HD</div>
                    <div class="plan-features">
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Watch on 2 devices</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Full HD resolution</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Download & watch offline</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Premium Plan -->
            <div class="col-md-4">
                <div class="plan-card <%= currentPlan != null && currentPlan.equals("Premium") ? "current" : "" %>" 
                     onclick="selectPlan('Premium', 699)">
                    <% if (currentPlan != null && currentPlan.equals("Premium")) { %>
                        <div class="current-plan-badge">CURRENT</div>
                    <% } %>
                    <div class="plan-header">
                        <div class="plan-name">Premium</div>
                        <div class="plan-price">₹699<small>/mo</small></div>
                    </div>
                    <div class="quality-badge quality-4k">4K+HDR</div>
                    <div class="plan-features">
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Watch on 4 devices</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Ultra HD & HDR</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check"></i>
                            <span>Spatial audio</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <button id="changePlanBtn" class="btn btn-change-plan" onclick="changePlan()" disabled>
            Continue
        </button>
        
        <!-- Plan Comparison Table -->
        <div class="plan-comparison mt-5">
            <h3>Compare all plans</h3>
            <table class="comparison-table">
                <thead>
                    <tr>
                        <th>Features</th>
                        <th>Basic</th>
                        <th>Standard</th>
                        <th>Premium</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Monthly price</td>
                        <td>₹199</td>
                        <td>₹499</td>
                        <td>₹699</td>
                    </tr>
                    <tr>
                        <td>Video quality</td>
                        <td>SD</td>
                        <td>HD</td>
                        <td>4K+HDR</td>
                    </tr>
                    <tr>
                        <td>Resolution</td>
                        <td>480p</td>
                        <td>1080p</td>
                        <td>4K</td>
                    </tr>
                    <tr>
                        <td>Devices</td>
                        <td>1</td>
                        <td>2</td>
                        <td>4</td>
                    </tr>
                    <tr>
                        <td>Downloads</td>
                        <td><i class="fas fa-times text-danger"></i></td>
                        <td><i class="fas fa-check text-success"></i></td>
                        <td><i class="fas fa-check text-success"></i></td>
                    </tr>
                    <tr>
                        <td>Spatial audio</td>
                        <td><i class="fas fa-times text-danger"></i></td>
                        <td><i class="fas fa-times text-danger"></i></td>
                        <td><i class="fas fa-check text-success"></i></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let selectedPlan = null;
        let selectedPlanPrice = 0;
        const currentPlan = '<%= currentPlan %>';

        function selectPlan(plan, price) {
            if (plan === currentPlan) return;
            
            document.querySelectorAll('.plan-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            const planCards = document.querySelectorAll('.plan-card');
            planCards.forEach(card => {
                if (card.querySelector('.plan-name').textContent === plan && !card.classList.contains('current')) {
                    card.classList.add('selected');
                }
            });
            
            selectedPlan = plan;
            selectedPlanPrice = price;
            document.getElementById('changePlanBtn').disabled = false;
        }

        function showNotification(message, type = 'success') {
            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            const icon = type === 'success' ? 'fa-check-circle' : 'fa-times-circle';
            notification.innerHTML = `
                <i class="fas ${icon}"></i>
                <span>${message}</span>
            `;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.remove();
            }, 3000);
        }

        function changePlan() {
            if (!selectedPlan || selectedPlan === currentPlan) return;
            
            // Create and show loading state
            const loadingBtn = document.getElementById('changePlanBtn');
            loadingBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Loading...';
            loadingBtn.disabled = true;

            const paymentData = {
                plan: selectedPlan,
                amount: selectedPlanPrice,
                userId: <%= userId %>,
                email: '<%= userEmail %>',
                mobile: '<%= userMobile %>'
            };

            const options = {
                key: 'rzp_test_oCj7e2CACazlHk', // Your razorpay key
                amount: paymentData.amount * 100, // amount in paise
                currency: "INR",
                name: "Escape",
                description: `${paymentData.plan} Plan Subscription`,
                handler: function (response) {
                    if (response.razorpay_payment_id) {
                        const finalData = {
                            plan: paymentData.plan,
                            amount: paymentData.amount,
                            transactionId: response.razorpay_payment_id,
                            paymentMethod: "razorpay",
                            userId: paymentData.userId,
                            email: paymentData.email,
                            mobile: paymentData.mobile
                        };

                        fetch('changePlan', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json'
                            },
                            body: JSON.stringify(finalData)
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                showNotification("Payment successful! Redirecting...", "success");
                                setTimeout(() => {
                                    window.location.href = 'account.jsp';
                                }, 2000);
                            } else {
                                showNotification(data.error || 'Plan update failed', 'error');
                                loadingBtn.innerHTML = 'Continue';
                                loadingBtn.disabled = false;
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            showNotification('An error occurred while updating plan', 'error');
                            loadingBtn.innerHTML = 'Continue';
                            loadingBtn.disabled = false;
                        });
                    }
                },
                prefill: {
                    name: '<%= userName %>',
                    email: paymentData.email,
                    contact: paymentData.mobile
                },
                theme: {
                    color: "#e50914"
                },
                modal: {
                    ondismiss: function() {
                        loadingBtn.innerHTML = 'Continue';
                        loadingBtn.disabled = false;
                    },
                    confirm_close: true,
                    escape: true
                },
                retry: {
                    enabled: true,
                    max_count: 3
                }
            };

            try {
                const rzp = new window.Razorpay(options);
                rzp.on('payment.failed', function (response){
                    showNotification("Payment Failed. Please try again.", "error");
                    loadingBtn.innerHTML = 'Continue';
                    loadingBtn.disabled = false;
                });
                rzp.open();
            } catch (err) {
                console.error('Razorpay Error:', err);
                showNotification('Failed to initialize payment. Please try again.', 'error');
                loadingBtn.innerHTML = 'Continue';
                loadingBtn.disabled = false;
            }
        }
    </script>
</body>
</html>