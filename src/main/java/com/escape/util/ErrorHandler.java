package com.escape.util;

import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.*;
import java.util.Map;
import java.util.HashMap;

public class ErrorHandler {
    private static final Logger LOGGER = Logger.getLogger(ErrorHandler.class.getName());
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");
    private static final String LOG_FOLDER = "logs";
    private static Handler fileHandler;
    private static final Map<String, Integer> ERROR_COUNT = new HashMap<>();
    private static final int MAX_ERROR_THRESHOLD = 100; // Maximum errors before alert
    private static Date lastReset = new Date();

    static {
        try {
            initializeLogger();
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Failed to initialize logger: " + e.getMessage());
        }
    }

    private static void initializeLogger() throws IOException {
        // Create logs directory if it doesn't exist
        File logDir = new File(LOG_FOLDER);
        if (!logDir.exists()) {
            logDir.mkdirs();
        }

        // Create daily rotating log file
        String logFile = LOG_FOLDER + File.separator + "escape_" + 
                        DATE_FORMAT.format(new Date()) + ".log";
        
        // Close existing file handler if it exists
        if (fileHandler != null) {
            fileHandler.close();
        }

        // Create new file handler
        fileHandler = new FileHandler(logFile, true);
        fileHandler.setFormatter(new SimpleFormatter() {
            @Override
            public String format(LogRecord record) {
                return String.format("[%1$tF %1$tT] [%2$s] %3$s: %4$s %n",
                    new Date(record.getMillis()),
                    record.getLevel(),
                    record.getSourceClassName(),
                    record.getMessage()
                );
            }
        });

        // Remove existing handlers and add new one
        LOGGER.setUseParentHandlers(false);
        Handler[] handlers = LOGGER.getHandlers();
        for (Handler handler : handlers) {
            LOGGER.removeHandler(handler);
        }
        LOGGER.addHandler(fileHandler);
        LOGGER.setLevel(Level.ALL);
    }

    // General error logging
    public static void logError(String message, Throwable error) {
        incrementErrorCount("general");
        LOGGER.log(Level.SEVERE, String.format("%s: %s", message, error.getMessage()), error);
        checkErrorThreshold("general");
    }

    public static void logError(String message) {
        incrementErrorCount("general");
        LOGGER.log(Level.SEVERE, message);
        checkErrorThreshold("general");
    }

    // Database error logging
    public static void logDatabaseError(String operation, SQLException error) {
        incrementErrorCount("database");
        LOGGER.log(Level.SEVERE, String.format("Database error during %s: %s", 
            operation, error.getMessage()), error);
        checkErrorThreshold("database");
    }

    // Security error logging
    public static void logSecurityError(String message, HttpServletRequest request) {
        incrementErrorCount("security");
        String ipAddress = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");
        String requestURL = request.getRequestURL().toString();
        
        LOGGER.log(Level.WARNING, String.format("Security Alert - %s | IP: %s | User-Agent: %s | URL: %s",
            message, ipAddress, userAgent, requestURL));
        checkErrorThreshold("security");
    }

    // Performance logging
    public static void logPerformanceIssue(String operation, long duration) {
        if (duration > 1000) { // Log if operation takes more than 1 second
            incrementErrorCount("performance");
            LOGGER.log(Level.WARNING, String.format("Performance Alert - %s took %d ms",
                operation, duration));
            checkErrorThreshold("performance");
        }
    }

    // Request logging
    public static void logRequest(HttpServletRequest request, String action) {
        String userInfo = request.getRemoteUser() != null ? request.getRemoteUser() : "anonymous";
        String requestInfo = String.format("User: %s, Action: %s, URI: %s, Method: %s",
            userInfo, action, request.getRequestURI(), request.getMethod());
        LOGGER.log(Level.INFO, requestInfo);
    }

    // Warning logging
    public static void logWarning(String message) {
        LOGGER.log(Level.WARNING, message);
    }

    // Info logging
    public static void logInfo(String message) {
        LOGGER.log(Level.INFO, message);
    }

    // Debug logging
    public static void logDebug(String message) {
        LOGGER.log(Level.FINE, message);
    }

    // Error tracking methods
    private static synchronized void incrementErrorCount(String type) {
        ERROR_COUNT.merge(type, 1, Integer::sum);
        
        // Reset counts daily
        if (isNewDay()) {
            ERROR_COUNT.clear();
            lastReset = new Date();
        }
    }

    private static boolean isNewDay() {
        String today = DATE_FORMAT.format(new Date());
        String lastResetDay = DATE_FORMAT.format(lastReset);
        return !today.equals(lastResetDay);
    }

    private static void checkErrorThreshold(String type) {
        int count = ERROR_COUNT.getOrDefault(type, 0);
        if (count >= MAX_ERROR_THRESHOLD) {
            // Alert administrators (implement your alert mechanism here)
            String alertMessage = String.format("Alert: %s errors have exceeded threshold (%d occurrences)",
                type, count);
            LOGGER.log(Level.SEVERE, alertMessage);
            
            // You could add email notification here
            // sendAlertEmail(alertMessage);
        }
    }

    // Cleanup method
    public static void cleanup() {
        if (fileHandler != null) {
            fileHandler.close();
        }
    }

    // Stack trace formatting
    public static String getStackTraceString(Throwable throwable) {
        StringBuilder sb = new StringBuilder();
        sb.append(throwable.toString()).append("\n");
        
        for (StackTraceElement element : throwable.getStackTrace()) {
            sb.append("\tat ").append(element.toString()).append("\n");
        }
        
        return sb.toString();
    }

    // Error message formatting
    public static String formatErrorMessage(String message, Throwable error) {
        return String.format("%s: %s", message, error.getMessage());
    }

    // Method to get current log file path
    public static String getCurrentLogFile() {
        return LOG_FOLDER + File.separator + "escape_" + DATE_FORMAT.format(new Date()) + ".log";
    }

    // Method to rotate logs
    public static void rotateLog() {
        try {
            initializeLogger();
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Failed to rotate log file: " + e.getMessage());
        }
    }
}