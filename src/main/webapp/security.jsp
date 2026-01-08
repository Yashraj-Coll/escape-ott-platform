<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    String userMobile = (String) session.getAttribute("userMobile");
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get verification status from database
    boolean isEmailVerified = false;
    boolean isMobileVerified = false;
    
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT email_verified, mobile_verified FROM users WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, (Integer) session.getAttribute("userId"));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                isEmailVerified = rs.getBoolean("email_verified");
                isMobileVerified = rs.getBoolean("mobile_verified");
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
    <title>Security - Escape</title>
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
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .security-item {
            padding: 16px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .security-item:last-child {
            border-bottom: none;
        }

        .security-item:hover {
            background-color: #f8f8f8;
        }

        .security-item-content {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .verification-badge {
            font-size: 0.8rem;
            padding: 4px 8px;
            border-radius: 4px;
            color: white;
        }

        .verification-badge.bg-success {
            background-color: #198754;
        }

        .verification-badge.bg-danger {
            background-color: #dc3545;
        }

        .alert-warning {
            border-left: 4px solid #ffc107;
        }

        #codeMessage {
            margin-top: 0.5rem;
            font-size: 0.875rem;
        }

        @media (max-width: 768px) {
            .account-nav {
                position: relative;
                width: 100%;
                height: auto;
            }
            
            .account-content {
                margin-left: 0;
                padding: 20px;
            }
        }

        /* Success Animation Styles */
        .success-checkmark {
            width: 80px;
            height: 80px;
            margin: 0 auto;
            margin-bottom: 20px;
        }

        .check-icon {
            width: 80px;
            height: 80px;
            position: relative;
            background-color: #ffffff;
            border-radius: 50%;
        }

        .check-icon::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(45deg);
            width: 14px;
            height: 28px;
            border-bottom: 3px solid #28a745;
            border-right: 3px solid #28a745;
        }

        .success-message {
            text-align: center;
            color: #28a745;
            margin-bottom: 20px;
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
            <a class="nav-link" href="membership.jsp">
                <i class="fas fa-credit-card"></i>
                Membership
            </a>
            <a class="nav-link active" href="security.jsp">
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
        <% if (!isMobileVerified) { %>
            <div class="alert alert-warning mb-4">
                <div class="d-flex gap-2 align-items-center">
                    <i class="fas fa-exclamation-triangle"></i>
                    <div>
                        <strong>Verify your mobile number</strong><br>
                        Verifying your phone number enhances security and can help you access and recover your account. 
                        <a href="#" onclick="showVerificationModal('mobile', '<%= userMobile %>', false)">Verify now</a>.
                    </div>
                </div>
            </div>
        <% } %>

        <h1 class="mb-4">Security</h1>
        
        <div class="section-card">
            <h2 class="mb-4">Account details</h2>
            
            <div class="security-item" onclick="window.location.href='updatePassword.jsp'">
                <div class="security-item-content">
                    <i class="fas fa-lock"></i>
                    <div>
                        <div><strong>Password</strong></div>
                        <div class="text-muted">Last updated 2 months ago</div>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </div>

            <div class="security-item" onclick="showVerificationModal('email', '<%= userEmail %>', <%= isEmailVerified %>)">
                <div class="security-item-content">
                    <i class="fas fa-envelope"></i>
                    <div>
                        <div>
                            <strong>Email</strong>
                            <% if (!isEmailVerified) { %>
                                <span class="verification-badge bg-danger">Needs verification</span>
                            <% } else { %>
                                <span class="verification-badge bg-success">Verified</span>
                            <% } %>
                        </div>
                        <div class="text-muted"><%= userEmail %></div>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </div>

            <div class="security-item" onclick="showVerificationModal('mobile', '<%= userMobile %>', <%= isMobileVerified %>)">
                <div class="security-item-content">
                    <i class="fas fa-mobile-alt"></i>
                    <div>
                        <div>
                            <strong>Mobile phone</strong>
                            <% if (!isMobileVerified) { %>
                                <span class="verification-badge bg-danger">Needs verification</span>
                            <% } else { %>
                                <span class="verification-badge bg-success">Verified</span>
                            <% } %>
                        </div>
                        <div class="text-muted"><%= userMobile %></div>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </div>

            <div class="security-item" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">
                <div class="security-item-content text-danger">
                    <i class="fas fa-trash-alt"></i>
                    <div>
                        <strong>Delete account</strong>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </div>
        </div>
    </div>

    <!-- Delete Account Modal -->
    <div class="modal fade" id="deleteAccountModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Delete Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete your account? This action cannot be undone.</p>
                    <form id="deleteAccountForm">
                        <div class="mb-3">
                            <label for="password" class="form-label">Enter your password to confirm</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="deleteAccountForm" class="btn btn-danger">Delete Account</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-body text-center p-4">
                    <div class="success-checkmark">
                        <div class="check-icon"></div>
                    </div>
                    <div class="success-message">
                        <h5 class="mb-3">Action Completed Successfully</h5>
                        <p id="successMessage"></p>
                    </div>
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">Continue</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Function to show success modal
        function showSuccessModal(message, callback) {
            const successModal = new bootstrap.Modal(document.getElementById('successModal'));
            document.getElementById('successMessage').textContent = message;
            
            const modalElement = document.getElementById('successModal');
            modalElement.addEventListener('hidden.bs.modal', function() {
                if (callback) callback();
            });
            
            successModal.show();
        }

        document.getElementById('deleteAccountForm').onsubmit = function(e) {
            e.preventDefault();
            const deleteAccountModal = bootstrap.Modal.getInstance(document.getElementById('deleteAccountModal'));
            
            fetch('deleteAccount', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'password=' + encodeURIComponent(document.getElementById('password').value)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    deleteAccountModal.hide(); // Hide the delete account modal
                    showSuccessModal(data.message, () => {
                        window.location.href = 'login.jsp';
                    });
                } else {
                    alert(data.error || 'An error occurred while deleting the account');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while processing your request. Please try again later.');
            });
        };

        function showVerificationModal(type, currentValue, isVerified) {
        	let existingModal = document.getElementById('verificationModal');
            if (existingModal) {
                // If there's a bootstrap modal instance, destroy it properly
                const existingModalInstance = bootstrap.Modal.getInstance(existingModal);
                if (existingModalInstance) {
                    existingModalInstance.dispose();
                }
                existingModal.remove();
            }

            let modalContent;
            if (isVerified) {
                modalContent = 
                    '<div class="modal-body">' +
                        '<h5 class="mb-4">Your ' + (type == 'email' ? 'Email' : 'Mobile Phone') + ' is Already Verified!</h5>' +
                        '<p>Do you want to change your ' + (type == 'email' ? 'Email' : 'Mobile Phone') + '?</p>' +
                        '<div id="changeSection" style="display:none;">' +
                            '<div class="mb-3">' +
                                '<label for="newValue" class="form-label">New ' + (type == 'email' ? 'Email' : 'Mobile Number') + '</label>' +
                                '<input type="text" class="form-control" id="newValue" ' +
                                    'placeholder="' + (type == 'email' ? 'Enter new email address' : 'Enter new mobile number') + '">' +
                            '</div>' +
                            '<div id="codeMessage"></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="modal-footer">' +
                        '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>' +
                        '<button type="button" class="btn btn-primary" id="changeContactBtn">Change ' + 
                        (type == 'email' ? 'Email' : 'Mobile') + '</button>' +
                    '</div>';
            } else {
                modalContent = 
                    '<div class="modal-body">' +
                        '<div id="verifySection">' +
                            '<p class="mb-3">We will send a verification code to:</p>' +
                            '<p class="h5 mb-4">' + currentValue + '</p>' +
                            '<div id="codeInputSection" style="display:none;">' +
                                '<div class="mb-3">' +
                                    '<label for="verificationCode" class="form-label">Enter verification code</label>' +
                                    '<input type="text" class="form-control" id="verificationCode" maxlength="6" placeholder="Enter 6-digit code">' +
                                '</div>' +
                                '<div id="codeMessage"></div>' +
                            '</div>' +
                        '</div>' +
                        '<div id="changeSection" style="display:none;">' +
                            '<div class="mb-3">' +
                                '<label for="newValue" class="form-label">New ' + (type == 'email' ? 'Email' : 'Mobile Number') + '</label>' +
                                '<input type="text" class="form-control" id="newValue" ' +
                                    'placeholder="' + (type == 'email' ? 'Enter new email address' : 'Enter new mobile number') + '">' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="modal-footer">' +
                        '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>' +
                        '<button type="button" class="btn btn-primary" id="sendCodeBtn">Send Code</button>' +
                        '<button type="button" class="btn btn-success" id="verifyCodeBtn" style="display:none;">Verify Code</button>' +
                        '<button type="button" class="btn btn-primary" id="changeContactBtn">Change ' + 
                        (type == 'email' ? 'Email' : 'Mobile') + '</button>' +
                    '</div>';
            }

            const modalHTML = 
                '<div class="modal" id="verificationModal" tabindex="-1">' +
                    '<div class="modal-dialog">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header">' +
                                '<h5 class="modal-title">' + (type == 'email' ? 'Email' : 'Mobile Phone') + '</h5>' +
                                '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
                            '</div>' +
                            modalContent +
                        '</div>' +
                    '</div>' +
                '</div>';

            document.body.insertAdjacentHTML('beforeend', modalHTML);

            const modalElement = document.getElementById('verificationModal');
            const modal = new bootstrap.Modal(modalElement);
            const changeContactBtn = document.getElementById('changeContactBtn');
            const changeSection = document.getElementById('changeSection');
            const codeMessage = document.getElementById('codeMessage');
            
         // Add cleanup event listener
            modalElement.addEventListener('hidden.bs.modal', function(event) {
    // Properly cleanup the modal when it's hidden
    const modalInstance = bootstrap.Modal.getInstance(modalElement);
    if (modalInstance) {
        modalInstance.dispose();
    }
    modalElement.remove();
    // Reset body styles
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';
});

            // Handle close button click
            const closeButton = modalElement.querySelector('.btn-close');
            if (closeButton) {
                closeButton.addEventListener('click', function() {
                    const modalInstance = bootstrap.Modal.getInstance(modalElement);
                    if (modalInstance) {
                        modalInstance.hide();
                    }
                });
            }

            // Handle cancel button click
            const cancelButton = modalElement.querySelector('button[data-bs-dismiss="modal"]');
            if (cancelButton) {
                cancelButton.addEventListener('click', function() {
                    const modalInstance = bootstrap.Modal.getInstance(modalElement);
                    if (modalInstance) {
                        modalInstance.hide();
                    }
                });
            }

            modalElement.addEventListener('shown.bs.modal', function() {
                if (!isVerified) {
                    const sendCodeBtn = document.getElementById('sendCodeBtn');
                    const verifyCodeBtn = document.getElementById('verifyCodeBtn');
                    const codeInputSection = document.getElementById('codeInputSection');
                    const verifySection = document.getElementById('verifySection');

                    sendCodeBtn.onclick = function() {
                        fetch('sendVerificationCode', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                            },
                            body: 'type=' + type + '&contact=' + currentValue
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                codeInputSection.style.display = 'block';
                                sendCodeBtn.style.display = 'none';
                                verifyCodeBtn.style.display = 'block';
                                if (codeMessage) {
                                    codeMessage.textContent = 'Verification code sent!';
                                    codeMessage.className = 'text-success mt-2';
                                }
                                console.log('Verification code:', data.code);
                            } else {
                                if (codeMessage) {
                                    codeMessage.textContent = data.error || 'Error sending code';
                                    codeMessage.className = 'text-danger mt-2';
                                }
                            }
                        });
                    };

                    verifyCodeBtn.onclick = function() {
                        const code = document.getElementById('verificationCode').value;
                        fetch('verifyCode', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                            },
                            body: 'type=' + type + '&code=' + code
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                if (codeMessage) {
                                    codeMessage.textContent = 'Verification successful!';
                                    codeMessage.className = 'text-success mt-2';
                                }
                                setTimeout(() => {
                                    modal.hide();
                                    location.reload();
                                }, 2000);
                            } else {
                                if (codeMessage) {
                                    codeMessage.textContent = data.error || 'Invalid code. Please try again.';
                                    codeMessage.className = 'text-danger mt-2';
                                }
                            }
                        });
                    };
                }

                changeContactBtn.onclick = function() {
                    if (isVerified) {
                        if (changeSection.style.display === 'none') {
                            changeSection.style.display = 'block';
                            changeContactBtn.textContent = 'Save Changes';
                        } else {
                            submitChange();
                        }
                    } else {
                        if (changeSection.style.display === 'none') {
                            verifySection.style.display = 'none';
                            changeSection.style.display = 'block';
                            changeContactBtn.textContent = 'Save Changes';
                            if (sendCodeBtn) sendCodeBtn.style.display = 'none';
                            if (verifyCodeBtn) verifyCodeBtn.style.display = 'none';
                        } else {
                            submitChange();
                        }
                    }
                };

                function submitChange() {
                    const newValue = document.getElementById('newValue').value;
                    fetch('updateContact', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'type=' + type + '&newValue=' + newValue
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            location.reload();
                        } else {
                            if (codeMessage) {
                                codeMessage.textContent = data.error || 'Failed to update contact information';
                                codeMessage.className = 'text-danger mt-2';
                            }
                        }
                    });
                }
            });

            modal.show();
        }

        document.addEventListener('DOMContentLoaded', function() {
            const verifyNowLink = document.querySelector('.alert-warning a');
            if (verifyNowLink) {
                verifyNowLink.addEventListener('click', (e) => {
                    e.preventDefault();
                    showVerificationModal('mobile', '<%= userMobile %>', false);
                });
            }
        });
    </script>
</body>
</html>