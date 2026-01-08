package com.escape.servlets.api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.escape.service.MovieService;
import com.escape.util.ErrorHandler;
import com.google.gson.Gson;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/user-data")
public class GetUserDataServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        Map<String, Object> responseData = new HashMap<>();
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            responseData.put("error", "User not authenticated");
            response.getWriter().write(gson.toJson(responseData));
            return;
        }

        try {
            // Get user's movie data (continue watching, my list, liked movies)
            Map<String, Object> userData = MovieService.getUserMovieData(userId);
            
            if (userData != null) {
                responseData.put("success", true);
                responseData.put("userData", userData);
                
                // Add user preferences if any
                Map<String, Object> userPreferences = getUserPreferences(session);
                if (!userPreferences.isEmpty()) {
                    responseData.put("preferences", userPreferences);
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                responseData.put("error", "User data not found");
            }

        } catch (Exception e) {
            ErrorHandler.logError("Error in GetUserDataServlet", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }

    private Map<String, Object> getUserPreferences(HttpSession session) {
        Map<String, Object> preferences = new HashMap<>();
        
        // Add any user preferences stored in session
        String[] preferenceKeys = {"language", "subtitlesEnabled", "autoplayEnabled"};
        for (String key : preferenceKeys) {
            Object value = session.getAttribute("pref_" + key);
            if (value != null) {
                preferences.put(key, value);
            }
        }
        
        return preferences;
    }
}