package com.escape.servlets.api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.escape.service.MovieService;
import com.escape.util.ErrorHandler;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/update-continue-watching")
public class UpdateContinueWatchingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        Map<String, Object> responseData = new HashMap<>();
        
        try {
            JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
            int movieId = body.get("movieId").getAsInt();
            float progress = body.get("progress").getAsFloat();
            float duration = body.get("duration").getAsFloat();

            // Validate inputs
            if (!MovieService.isValidMovie(movieId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Invalid movie ID");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            if (!MovieService.isValidProgress(progress)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Invalid progress value");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
           
         // Calculate progress percentage and ensure it's between 0 and 100
            float progressPercentage = Math.min(100, Math.max(0, (progress / duration) * 100));

            // Add progress time validation
            if (progress < 0 || progress > duration) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Invalid progress time");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            // Update progress with exact time
            boolean success = MovieService.updateMovieProgress(userId, movieId, progress);
            
            if (success) {
                responseData.put("success", true);
                responseData.put("message", "Progress updated successfully");
                
                // Get updated continue watching list
                Map<String, Object> userData = MovieService.getUserMovieData(userId);
                responseData.put("continueWatching", userData.get("continueWatching"));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                responseData.put("error", "Failed to update progress");
            }

        } catch (Exception e) {
            ErrorHandler.logError("Error in UpdateContinueWatchingServlet", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }
}