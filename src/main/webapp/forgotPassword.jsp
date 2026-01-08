<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Escape</title>
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

        .auth-container {
            width: 100%;
            max-width: 314px;
            margin: 0 auto;
            padding: 0 40px;
            background: transparent;
            position: relative;
            top: 60px;
        }

        h1 {
            color: #fff;
            font-size: 32px;
            font-weight: 500;
            margin-bottom: 16px;
        }

        .description {
            color: #737373;
            font-size: 16px;
            margin-bottom: 24px;
            line-height: 1.5;
        }

        .form-group {
            margin-bottom: 16px;
            position: relative;
        }

        input[type="text"],
        input[type="email"],
        input[type="tel"] {
            width: 100%;
            height: 50px;
            background: #333;
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

        .signin-text {
            text-align: center;
            color: #737373;
            margin-top: 16px;
            font-size: 16px;
        }

        .signin-link {
            color: #fff;
            text-decoration: none;
            margin-left: 4px;
        }

        .signin-link:hover {
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
        <h1>Forgot Password</h1>
        
        <p class="description">
            We'll send you an email or SMS with instructions to reset your password.
        </p>
        
        <form action="forgotPassword" method="POST" id="forgotPasswordForm">
            <div class="form-group">
                <input type="text" name="emailOrMobile" required
                       placeholder="Email or mobile number">
                <span class="error-message" id="emailMobileError"></span>
            </div>
            
            <button type="submit" class="auth-button">Send Instructions</button>
            
            <div class="signin-text">
                Remember your password? <a href="login.jsp" class="signin-link">Sign in</a>
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
        function showError(elementId, message) {
            const errorElement = document.getElementById(elementId);
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            
            // Hide error message after 3 seconds
            setTimeout(() => {
                hideError(elementId);
            }, 3000);
        }

        function hideError(elementId) {
            const errorElement = document.getElementById(elementId);
            if (errorElement) {
                errorElement.style.display = 'none';
            }
        }

        const form = document.getElementById('forgotPasswordForm');
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const emailOrMobile = form.emailOrMobile.value.trim();
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const mobileRegex = /^[0-9]{10}$/;

            if (!emailRegex.test(emailOrMobile) && !mobileRegex.test(emailOrMobile)) {
                showError('emailMobileError', 'Please enter a valid email address or mobile number');
                return;
            }

            // Make the request
            fetch('forgotPassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    emailOrMobile: emailOrMobile
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.href = data.redirect;
                } else {
                    if (data.error === 'NOT_FOUND') {
                        showError('emailMobileError', 'No account found with this email/mobile. Please signup first.');
                        setTimeout(() => {
                            window.location.href = 'signup.jsp';
                        }, 3000);
                    } else if (data.error === 'RECENT_ATTEMPT') {
                        showError('emailMobileError', data.message);
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
    </script>
</body>
</html>