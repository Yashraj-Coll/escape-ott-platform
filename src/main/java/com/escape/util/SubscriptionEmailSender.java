package com.escape.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class SubscriptionEmailSender {
    private static final String HOST = "smtp.gmail.com";
    private static final int PORT = 587;
    private static final String USERNAME = "escapeott.team@gmail.com";
    private static final String PASSWORD = "zfsh zldd ojqo ptes";
    
    public static void sendSubscriptionEmail(String userEmail, String userName, 
            String planName, double amount, String transactionId, String nextBillingDate) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", true);
        props.put("mail.smtp.starttls.enable", true);
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(userEmail));
            message.setSubject("Welcome to Escape " + planName + "!");

            String emailContent = getEmailTemplate()
                .replace("{userName}", userName)
                .replace("{planName}", planName)
                .replace("{amount}", String.format("%.2f", amount))
                .replace("{transactionId}", transactionId)
                .replace("{nextBillingDate}", nextBillingDate)
                .replace("{planBenefits}", getPlanBenefits(planName))
                .replace("{userEmail}", userEmail);

            message.setContent(emailContent, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Subscription confirmation email sent successfully to " + userEmail);
        } catch (MessagingException e) {
            System.err.println("Failed to send subscription email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static String getEmailTemplate() {
        return """
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .header { background-color: #e50914; color: white; padding: 20px; text-align: center; }
                .content { background-color: #f4f4f4; padding: 20px; }
                .plan-details { background-color: #fff; padding: 15px; border-radius: 5px; }
                .button { display: inline-block; background-color: #e50914; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; }
                .divider { border-top: 1px solid #ddd; margin: 20px 0; }
                .footer { text-align: center; font-size: 0.8em; color: #666; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Welcome to Escape Premium!</h1>
            </div>
            <div class="content">
                <p>Dear {userName},</p>
                <p>Thank you for subscribing to Escape! Your payment has been successfully processed, and your subscription is now active.</p>
                <div class="plan-details">
                    <h3>Subscription Details:</h3>
                    <p><strong>Plan:</strong> {planName}</p>
                    <p><strong>Amount Paid:</strong> ₹{amount}</p>
                    <p><strong>Transaction ID:</strong> {transactionId}</p>
                    <p><strong>Next Billing Date:</strong> {nextBillingDate}</p>
                </div>
                <h3>Your Plan Benefits:</h3>
                {planBenefits}
                <p><a href="https://your-website.com/account" class="button">View Account Details</a></p>
                <div class="divider"></div>
                <p>If you have any questions or need assistance, please don't hesitate to contact our support team.</p>
                <p>Happy streaming!</p>
                <p>The Escape Team</p>
            </div>
            <div class="footer">
                <p>This email was sent to {userEmail}</p>
                <p>© 2024 Escape. All rights reserved.</p>
            </div>
        </body>
        </html>
        """;
    }

    private static String getPlanBenefits(String planName) {
        StringBuilder benefits = new StringBuilder("<ul>");
        
        switch(planName) {
            case "Basic":
                benefits.append("<li>Watch on 1 device</li>")
                        .append("<li>Standard definition (480p)</li>")
                        .append("<li>Ad-free entertainment</li>");
                break;
            case "Standard":
                benefits.append("<li>Watch on 2 devices</li>")
                        .append("<li>Full HD resolution (1080p)</li>")
                        .append("<li>Download & watch offline</li>")
                        .append("<li>Ad-free entertainment</li>");
                break;
            case "Premium":
                benefits.append("<li>Watch on 4 devices</li>")
                        .append("<li>Ultra HD (4K) and HDR</li>")
                        .append("<li>Spatial audio support</li>")
                        .append("<li>Download & watch offline</li>")
                        .append("<li>Ad-free entertainment</li>");
                break;
        }
        
        benefits.append("</ul>");
        return benefits.toString();
    }
}