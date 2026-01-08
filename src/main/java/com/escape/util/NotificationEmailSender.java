package com.escape.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.activation.DataHandler;
import jakarta.activation.DataSource;
import jakarta.activation.FileDataSource;
import java.util.Properties;
import java.io.File;

public class NotificationEmailSender {
    private static final String HOST = "smtp.gmail.com";
    private static final int PORT = 587;
    private static final String USERNAME = "escapeott.team@gmail.com";
    private static final String PASSWORD = "zfsh zldd ojqo ptes";
    
    public static void sendNotificationEmail(
            String toEmail, 
            String userName, 
            String title, 
            String message, 
            String categoryName, 
            String movieTitle, 
            String moviePosterPath, 
            String serverUrl) {
            
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
            // Create the message
            MimeMessage emailMessage = new MimeMessage(session);
            emailMessage.setFrom(new InternetAddress(USERNAME));
            emailMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            emailMessage.setSubject(userName + ", we've added something special for you");

            // Create a multipart message
            Multipart multipart = new MimeMultipart("related");

            // First part (the html)
            BodyPart messageBodyPart = new MimeBodyPart();
            String htmlContent = generateEmailContent(
                userName, title, message, categoryName, movieTitle, "cid:moviePoster", serverUrl
            );
            messageBodyPart.setContent(htmlContent, "text/html; charset=utf-8");
            multipart.addBodyPart(messageBodyPart);

            // Second part (the image)
            if (moviePosterPath != null && !moviePosterPath.trim().isEmpty()) {
                messageBodyPart = new MimeBodyPart();
                File posterFile = new File(moviePosterPath);
                if (posterFile.exists()) {
                    DataSource fds = new FileDataSource(posterFile);
                    messageBodyPart.setDataHandler(new DataHandler(fds));
                    messageBodyPart.setHeader("Content-ID", "<moviePoster>");
                    messageBodyPart.setDisposition(MimeBodyPart.INLINE);
                    multipart.addBodyPart(messageBodyPart);
                    System.out.println("Added poster image: " + moviePosterPath);
                } else {
                    System.out.println("Poster file not found: " + moviePosterPath);
                }
            }

            // Set the content
            emailMessage.setContent(multipart);
            
            // Debug logging
            System.out.println("Sending email to: " + toEmail);
            System.out.println("Movie Title: " + movieTitle);
            System.out.println("Category: " + categoryName);
            
            Transport.send(emailMessage);
            System.out.println("Email sent successfully");
            
        } catch (MessagingException e) {
            e.printStackTrace();
            System.out.println("Error sending email: " + e.getMessage());
        }
    }

    private static String generateEmailContent(
            String userName, 
            String title, 
            String message, 
            String categoryName, 
            String movieTitle, 
            String moviePosterPath, 
            String serverUrl) {
            
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head>");
        html.append("<meta charset='utf-8'>");
        html.append("<meta name='viewport' content='width=device-width, initial-scale=1'>");
        html.append("<meta name='color-scheme' content='light dark'>");
        html.append("<meta name='supported-color-schemes' content='light dark'>");
        html.append("<style>");
        
        // Base styles
        html.append("body{margin:0;padding:0;background:#141414;color:#fff;font-family:Arial,Helvetica,sans-serif}");
        html.append(".container{max-width:600px;margin:0 auto;background:#141414;padding:20px}");
        
        // Logo styles
        html.append(".logo{color:#E50914;font-size:28px;font-weight:bold;font-family:'Arial Black',sans-serif;text-transform:uppercase;letter-spacing:1px;text-decoration:none}");
        
        // Content styles
        html.append(".category{color:#999;font-size:16px;margin-bottom:24px}");
        html.append(".greeting{font-size:24px;font-weight:bold;margin-bottom:8px;line-height:1.2}");
        
        // Movie card styles
        html.append(".movie-card{background:#1a1a1a;border-radius:8px;padding:24px;margin-top:24px}");
        html.append(".movie-title{font-size:24px;font-weight:bold;margin-bottom:8px}");
        html.append(".movie-desc{color:#999;margin-bottom:24px;font-size:16px;line-height:1.5}");
        
        // Button styles
        html.append(".button-container{display:flex;flex-direction:column;gap:12px}");
        html.append(".watch-button{background:#E50914;color:#fff;padding:16px;border-radius:4px;text-decoration:none;font-weight:500;text-align:center;margin-bottom:12px}");
        html.append(".mylist-button{background:rgba(255,255,255,0.1);color:#fff;padding:16px;border-radius:4px;text-decoration:none;font-weight:500;text-align:center;border:1px solid rgba(255,255,255,0.3)}");
        
        // Footer styles
        html.append(".footer{margin-top:48px;padding:24px 0;border-top:1px solid #333}");
        html.append(".footer-links{margin-bottom:24px}");
        html.append(".footer-link{color:#999;text-decoration:none;display:inline-block;margin-right:16px;font-size:14px}");
        html.append(".footer-text{color:#999;font-size:12px;line-height:1.5}");
        
        html.append("</style></head><body>");
        html.append("<div class='container'>");

        // Header with logo
        html.append("<div style='padding:20px 0;margin-bottom:24px'>");
        html.append("<span class='logo'>ESCAPE</span>");
        html.append("</div>");

        // Greeting
        html.append("<h1 class='greeting'>").append(userName).append(",<br>we've added something special for you</h1>");
        
        // Category if available
        if (categoryName != null && !categoryName.isEmpty()) {
            html.append("<div class='category'>New in ").append(categoryName).append("</div>");
        }

        // Movie card
        html.append("<div class='movie-card'>");
        
        // Movie poster using Content-ID (cid)
        if (moviePosterPath != null && !moviePosterPath.trim().isEmpty()) {
            html.append("<div style='text-align: center; margin: 20px 0;'>");
            html.append("<img src='").append(moviePosterPath)
                .append("' alt='").append(movieTitle != null ? movieTitle : "Movie Poster")
                .append("' title='").append(movieTitle != null ? movieTitle : "Movie Poster")
                .append("' style='max-width: 100%; height: auto; border-radius: 8px; margin: 0 auto; display: block;'>");
            html.append("</div>");
            
            // Add note about image display
            html.append("<div style='text-align: center; color: #999; font-size: 12px; margin-bottom: 20px;'>");
            html.append("If you can't see the movie poster, please enable images in your email client.");
            html.append("</div>");
        }

        // Movie title
        if (movieTitle != null && !movieTitle.isEmpty()) {
            html.append("<h2 class='movie-title'>").append(movieTitle).append("</h2>");
        }

        // Custom message or default text
        html.append("<p class='movie-desc'>")
            .append(message != null && !message.trim().isEmpty() ? message : "Watch now on Escape")
            .append("</p>");

        // Action buttons
        html.append("<div class='button-container'>");
        String watchUrl = serverUrl + "/watch?movie=" + 
            (movieTitle != null ? movieTitle.replaceAll("\\s+", "-").toLowerCase() : "");
        html.append("<a href='").append(watchUrl).append("' class='watch-button'>▶ Watch Now</a>");
        html.append("<a href='").append(serverUrl).append("/mylist' class='mylist-button'>+ Add to My List</a>");
        html.append("</div>");
        
        html.append("</div>"); // Close movie-card

        // Footer
        html.append("<div class='footer'>");
        
        // Footer links
        html.append("<div class='footer-links'>");
        html.append("<a href='#' class='footer-link'>Help Center</a>");
        html.append("<a href='#' class='footer-link'>Terms of Use</a>");
        html.append("<a href='#' class='footer-link'>Privacy</a>");
        html.append("<a href='#' class='footer-link'>Contact Us</a>");
        html.append("</div>");
        
        // Footer text
        html.append("<p class='footer-text'>");
        html.append("This message was sent as part of your Escape membership.<br>");
        html.append("© 2024 Escape. All rights reserved.");
        html.append("</p>");
        
        html.append("</div>"); // Close footer
        html.append("</div>"); // Close container
        html.append("</body></html>");

        return html.toString();
    }
}