<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("resetEmail") == null && session.getAttribute("emailOrMobile") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP - Escape</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
    :root {
            --bg-dark: #000;
            --text-light: #fff;
            --primary-color: #e50914;
        }
    
        body {
            background-color: #000;
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            color: #fff;
            background-image: linear-gradient(to top,
                rgba(0, 0, 0, 0.9) 0,
                rgba(0, 0, 0, 0.5) 60%,
                rgba(0, 0, 0, 0.9) 100%);
        }

        .logo {
            color: #e50914;
            font-size: 2rem;
            font-weight: bold;
            text-decoration: none;
            padding: 20px;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: absolute;
            top: 0;
            left: 0;
        }

        .logo:hover {
            color: #ff0f1a;
        }

        .auth-container {
            width: 100%;
            max-width: 314px;
            margin: 0 auto;
            padding: 0;
            background: transparent;
            position: relative;
            top: 100px;
        }

        h1 {
            color: #fff;
            font-size: 32px;
            font-weight: 500;
            margin-bottom: 16px;
            white-space: nowrap;
            margin-left: -40px;
        }

        .description {
            color: #737373;
            font-size: 16px;
            margin-bottom: 24px;
            white-space: nowrap;
            text-align: left;
            margin-left: -40px;
        }

        .otp-container {
            display: flex;
            gap: 10px;
            justify-content: left;
            margin: 30px 0;
            margin-left: -40px;
        }
        
        .otp-input {
            width: 44px;
            height: 44px;
            text-align: center;
            font-size: 24px;
            border: 1px solid #333;
            border-radius: 4px;
            background: #333;
            color: white;
            transition: all 0.3s ease;
        }
        
        .otp-input:focus {
            border-color: #e50914;
            outline: none;
            background: #454545;
            transform: scale(1.05);
        }

        .auth-button {
            width: calc(100% + 40px);
            height: 48px;
            background: #e50914;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            margin: 24px 0 12px;
            margin-left: -40px;
            transition: all 0.3s ease;
        }

        .auth-button:hover {
            background: #f40612;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(229, 9, 20, 0.3);
        }

        .auth-button:active {
            transform: translateY(0);
        }

        .resend-timer {
            text-align: left;
            color: #737373;
            margin-top: 20px;
            margin-bottom: 20px;
            margin-left: -40px;
        }

        .auth-links {
            text-align: center;
            color: #737373;
            margin-top: 16px;
            font-size: 16px;
            margin-left: -40px;
        }

        #resendBtn {
            color: #fff;
            text-decoration: none;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        #resendBtn:hover {
            color: #e50914;
            text-decoration: underline;
        }

        #resendBtn:disabled {
            color: #737373;
            cursor: not-allowed;
            text-decoration: none;
        }

        #resendWait {
            color: #737373;
        }

        .error-message {
            color: #e50914;
            margin-top: 10px;
            text-align: left;
            margin-left: -40px;
            display: none;
            animation: fadeIn 0.3s ease;
        }

        .success-message {
            color: #2ecc71;
            margin-top: 10px;
            text-align: left;
            margin-left: -40px;
            display: none;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2px solid #fff;
            border-top: 2px solid transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 10px;
            vertical-align: middle;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2px solid #fff;
            border-top: 2px solid transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 10px;
            vertical-align: middle;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Footer Styles */
        .site-footer {
            background-color: var(--bg-dark);
            padding: 2rem 4rem;
            color: var(--text-light);
            margin-top: 8rem;
        }

        .footer-content {
            display: flex;
            justify-content: space-between;
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer-section h3 {
            color: var(--text-light);
            font-size: 1.1rem;
            margin-bottom: 1rem;
        }

        .footer-section ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .footer-section ul li {
            margin-bottom: 0.5rem;
        }

        .footer-section ul li a {
            color: #808080;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-section ul li a:hover {
            color: var(--text-light);
        }

        .social-links {
            display: flex;
            gap: 1rem;
        }

        .social-links a {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-light);
            text-decoration: none;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .social-links a:hover {
            background-color: var(--primary-color);
            transform: translateY(-2px);
        }

        .social-links a svg {
            width: 16px;
            height: 16px;
        }

        .footer-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .copyright {
            color: #808080;
        }

        .footer-legal {
            display: flex;
            gap: 2rem;
        }

        .footer-legal a {
            color: #808080;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-legal a:hover {
            color: var(--text-light);
        }

        @media (max-width: 768px) {
            .site-footer {
                padding: 2rem;
            }
            
            .footer-content {
                flex-direction: column;
                gap: 2rem;
            }
            
            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            
            .footer-legal {
                justify-content: center;
                flex-wrap: wrap;
            }
        }

        @media (max-width: 480px) {
            .site-footer {
                padding: 1.5rem;
            }
            
            .social-links {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <a href="index.jsp" class="logo">ESCAPE</a>

    <div class="auth-container">
        <h1>Enter Verification Code</h1>
        
        <p class="description">
            Enter the verification code we just sent to 
            <% 
                String contact = (String) session.getAttribute("maskedContact");
                String resetEmail = (String) session.getAttribute("resetEmail");
                String displayContact = contact != null ? contact : resetEmail;
            %>
            <%= displayContact %>
        </p>
        
        <form action="verifyOTP" method="POST" id="otpForm">
            <div class="otp-container">
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="text" maxlength="1" class="otp-input" required>
                <input type="hidden" name="otp" id="completeOtp">
            </div>
            
            <div class="resend-timer" style="display: block;">
                Code expires in: <span id="timer">02:00</span>
            </div>
            
            <div class="error-message" id="errorMessage"></div>
            <div class="success-message" id="successMessage"></div>
            
            <button type="submit" class="auth-button">
                <span>Verify</span>
                <span class="spinner" id="submitSpinner"></span>
            </button>
            
            <div class="auth-links">
                <p>
                    Didn't receive the code? 
                    <a href="#" id="resendBtn" style="display: none;">Resend Code</a>
                    <span id="resendWait">Wait for timer</span>
                    <span class="spinner" id="resendSpinner"></span>
                </p>
            </div>
        </form>
    </div>

    <script>
        function showError(message) {
            const errorDiv = document.getElementById('errorMessage');
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
            setTimeout(() => {
                errorDiv.style.display = 'none';
            }, 5000);
        }

        function showSuccess(message) {
            const successDiv = document.getElementById('successMessage');
            successDiv.textContent = message;
            successDiv.style.display = 'block';
            setTimeout(() => {
                successDiv.style.display = 'none';
            }, 5000);
        }

        const otpInputs = document.querySelectorAll('.otp-input');
        const completeOtpInput = document.getElementById('completeOtp');
        const form = document.getElementById('otpForm');

        otpInputs.forEach((input, index) => {
            input.addEventListener('paste', (e) => {
                e.preventDefault();
                const pasteData = e.clipboardData.getData('text').split('');
                otpInputs.forEach((input, i) => {
                    if (pasteData[i]) {
                        input.value = pasteData[i];
                        if (i < otpInputs.length - 1) {
                            otpInputs[i + 1].focus();
                        }
                    }
                });
                updateCompleteOtp();
            });

            input.addEventListener('input', function(e) {
                this.value = this.value.replace(/[^0-9]/g, '');
                
                if (this.value.length === 1) {
                    if (index < otpInputs.length - 1) {
                        otpInputs[index + 1].focus();
                    }
                }
                updateCompleteOtp();
            });

            input.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace') {
                    if (!this.value && index > 0) {
                        otpInputs[index - 1].focus();
                    }
                }
            });
        });

        function updateCompleteOtp() {
            completeOtpInput.value = Array.from(otpInputs)
                .map(input => input.value)
                .join('');
        }

        let timerInterval;
        let displayDuration = 120;  // 2 minutes
        let actualDuration = 15;    // 15 seconds for resend button

        function startTimer() {
            let displayTimer = displayDuration;
            let actualTimer = actualDuration;
            const timerDisplay = document.getElementById('timer');
            const timerContainer = document.querySelector('.resend-timer');
            const resendBtn = document.getElementById('resendBtn');
            const resendWait = document.getElementById('resendWait');
            
            timerContainer.style.display = 'block';
            
            if (timerInterval) {
                clearInterval(timerInterval);
            }
            
            timerInterval = setInterval(function () {
                const minutes = Math.floor(displayTimer / 60);
                const seconds = displayTimer % 60;
                timerDisplay.textContent = minutes.toString().padStart(2, '0') + ':' 
                                    + seconds.toString().padStart(2, '0');
                
                if (actualTimer <= 0 && resendBtn.style.display === 'none') {
                    resendBtn.style.display = 'inline';
                    resendWait.style.display = 'none';
                }
                
                if (displayTimer <= 0) {
                    clearInterval(timerInterval);
                    timerContainer.style.display = 'none';
                    
                    // Show expiration message and clear OTP fields
                    showError('OTP Expired!! Please request a new one.');
                    otpInputs.forEach(input => input.value = '');
                    
                    // Expire OTP in backend
                    fetch('verifyOTP', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'Cache-Control': 'no-cache'
                        },
                        body: 'expireOTP=true'
                    })
                    .then(response => response.json())
                    .catch(error => console.error('Error:', error));
                }
                
                displayTimer--;
                actualTimer--;
            }, 1000);
        }

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const otp = completeOtpInput.value;
            if (otp.length !== 6) {
                showError('Please enter all digits of the verification code');
                return;
            }

            document.getElementById('submitSpinner').style.display = 'inline-block';
            
            fetch('verifyOTP', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Cache-Control': 'no-cache'
                },
                body: 'otp=' + otp
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.href = data.redirect;
                } else {
                    showError(data.error);
                    // Clear OTP fields
                    otpInputs.forEach(input => input.value = '');
                    otpInputs[0].focus();
                }
            })
            .catch(error => {
                showError('An error occurred. Please try again.');
                console.error('Error:', error);
            })
            .finally(() => {
                document.getElementById('submitSpinner').style.display = 'none';
            });
        });

        document.getElementById('resendBtn').addEventListener('click', function(e) {
            e.preventDefault();
            
            this.disabled = true;
            document.getElementById('resendSpinner').style.display = 'inline-block';
            
            fetch('resendOTP', {
                method: 'POST',
                headers: {
                    'Cache-Control': 'no-cache'
                },
                credentials: 'same-origin'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    otpInputs.forEach(input => {
                        input.value = '';
                    });
                    otpInputs[0].focus();
                    
                    this.style.display = 'none';
                    document.getElementById('resendWait').style.display = 'inline';
                    
                    document.querySelector('.resend-timer').style.display = 'block';
                    
                    displayDuration = 120;  // Reset to 2 minutes
                    actualDuration = 15;    // Reset to 15 seconds
                    startTimer();
                    
                    showSuccess('New verification code sent successfully!');
                } else {
                    if (data.error.includes("Session expired")) {
                        window.location.href = 'login.jsp';
                    } else {
                        showError(data.error || 'Failed to resend code. Please try again.');
                        this.disabled = false;
                    }
                }
            })
            .catch(error => {
                showError('An error occurred. Please try again.');
                console.error('Error:', error);
                this.disabled = false;
                })
            .finally(() => {
                document.getElementById('resendSpinner').style.display = 'none';
            });
        });

        // Initialize timer when page loads
        document.addEventListener('DOMContentLoaded', function() {
            startTimer();
            
            // Check for URL error parameters
            const urlParams = new URLSearchParams(window.location.search);
            const error = urlParams.get('error');
            if (error) {
                showError(decodeURIComponent(error));
            }
        });
    </script>
    <!-- Footer Section -->
    <footer class="site-footer">
        <div class="footer-content">
            <div class="footer-section">
                <h3>Company</h3>
                <ul>
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Careers</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>Need Help?</h3>
                <ul>
                    <li><a href="#">Visit Help Center</a></li>
                    <li><a href="#">Share Feedback</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>Connect with Us</h3>
                <div class="social-links">
                    <a href="#" aria-label="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </a>
                    <a href="#" aria-label="X (Twitter)">
                        <svg width="16" height="16" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="Instagram">
                        <i class="fab fa-instagram"></i>
                    </a>
                    <a href="#" aria-label="YouTube">
                        <i class="fab fa-youtube"></i>
                    </a>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <div class="copyright">
                © 2024 ESCAPE. All Rights Reserved.
            </div>
            <div class="footer-legal">
                <a href="#">Terms Of Use</a>
                <a href="#">Privacy Policy</a>
                <a href="#">FAQ</a>
            </div>
        </div>
    </footer>

</body>
</html>