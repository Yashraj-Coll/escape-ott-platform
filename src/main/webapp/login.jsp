<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - Escape</title>
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
        }

        .logo {
            color: #e50914;
            font-size: 2rem;
            font-weight: bold;
            text-decoration: none;
            padding: 20px;
            display: inline-block;
        }

        .auth-container {
            width: 100%;
            max-width: 314px;
            margin: 60px auto 0;
            padding: 0 20px;
        }

        h1 {
            color: #fff;
            font-size: 32px;
            font-weight: 500;
            margin-bottom: 28px;
        }

        .form-group {
            margin-bottom: 16px;
            position: relative;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            height: 50px;
            background: rgba(51, 51, 51, 0.8);
            border: none;
            border-radius: 4px;
            padding: 16px 20px;
            color: #fff;
            font-size: 16px;
            box-sizing: border-box;
        }

        input:focus {
            outline: none;
            background: #454545;
        }

        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #8c8c8c;
            cursor: pointer;
            padding: 8px;
        }

        .password-toggle:hover {
            color: #fff;
        }

        .auth-button {
            width: 100%;
            height: 48px;
            background: #e50914;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            margin: 24px 0 12px;
        }

        .auth-button:hover {
            background: #f40612;
        }

        .form-options {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 16px 0;
            color: #b3b3b3;
            font-size: 13px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .remember-me input[type="checkbox"] {
            width: 16px;
            height: 16px;
        }

        .forgot-password {
            color: #b3b3b3;
            text-decoration: none;
        }

        .forgot-password:hover {
            text-decoration: underline;
            color: #fff;
        }

        .signup-text {
            text-align: center;
            color: #737373;
            margin-top: 16px;
            font-size: 16px;
        }

        .signup-link {
            color: #fff;
            text-decoration: none;
            margin-left: 4px;
        }

        .signup-link:hover {
            text-decoration: underline;
        }

        .error-message {
            color: #e87c03;
            font-size: 13px;
            margin-top: 6px;
            display: none;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        ::placeholder {
            color: #8c8c8c;
        }

        /* Footer Styles */
        .site-footer {
            background-color: var(--bg-dark);
            padding: 2rem 4rem;
            color: var(--text-light);
            margin-top: 4rem;
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
        <h1>Sign In</h1>
        
        <form action="login" method="POST" id="loginForm">
            <div class="form-group">
                <input type="text" name="emailOrMobile" required
                       placeholder="Email or mobile number">
                <span class="error-message" id="emailMobileError"></span>
            </div>
            
            <div class="form-group">
                <input type="password" name="password" required 
                       placeholder="Password" id="passwordField">
                <i class="fas fa-eye password-toggle" onclick="togglePassword('passwordField')"></i>
                <span class="error-message" id="passwordError"></span>
            </div>
            
            <button type="submit" class="auth-button">Sign In</button>
            
            <div class="form-options">
                <div class="remember-me">
                    <input type="checkbox" id="rememberMe" name="rememberMe">
                    <label for="rememberMe">Remember me</label>
                </div>
                <a href="forgotPassword.jsp" class="forgot-password">Forgot password?</a>
            </div>
            
            <div class="signup-text">
                New to Escape?<a href="signup.jsp" class="signup-link">Sign up now</a>
            </div>
        </form>
    </div>

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

    <script>
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = document.querySelector('.password-toggle');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        function showError(elementId, message) {
            const errorElement = document.getElementById(elementId);
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            
            // Hide error message after 3 seconds
            setTimeout(() => {
                hideError(elementId);
            }, 3000); // 3000 milliseconds = 3 seconds
        }

        function hideError(elementId) {
            const errorElement = document.getElementById(elementId);
            errorElement.style.display = 'none';
        }

        const form = document.getElementById('loginForm');
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Hide any existing error messages
            hideError('emailMobileError');
            hideError('passwordError');
            
            const emailOrMobile = form.emailOrMobile.value;
            const password = form.password.value;

            // Simple client-side validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const mobileRegex = /^[0-9]{10}$/;
            
            if (!emailRegex.test(emailOrMobile) && !mobileRegex.test(emailOrMobile)) {
                showError('emailMobileError', 'Please enter a valid email address or mobile number');
                return;
            }

            // Make the login request
            fetch('login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    emailOrMobile: emailOrMobile,
                    password: password,
                    rememberMe: form.rememberMe.checked
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.href = data.redirect || 'index.jsp';
                } else {
                    if (data.error === 'UNREGISTERED') {
                        showError('emailMobileError', 'This email/mobile number is not registered with us. Please signup first.');
                    } else if (data.error === 'INVALID_PASSWORD') {
                        showError('passwordError', 'Incorrect password. Please try again.');
                    } else {
                        showError('emailMobileError', data.message || 'An error occurred. Please try again.');
                    }
                }
            })
            .catch(error => {
                showError('emailMobileError', 'An error occurred. Please try again.');
                console.error('Error:', error);
            });
        });

        // Check for URL parameters on page load
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const error = urlParams.get('error');
            if (error) {
                if (error === 'unregistered') {
                    showError('emailMobileError', 'This email/mobile number is not registered with us. Please signup first.');
                } else if (error === 'invalid_password') {
                    showError('passwordError', 'Incorrect password. Please try again.');
                }
            }
        });
    </script>
</body>
</html>