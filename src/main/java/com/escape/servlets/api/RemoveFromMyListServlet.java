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

@WebServlet("/api/remove-from-mylist")
public class RemoveFromMyListServlet extends HttpServlet {
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

            // Validate movieId
            if (!MovieService.isValidMovie(movieId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Invalid movie ID");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            // Remove from my list
            boolean success = MovieService.removeFromMyList(userId, movieId);
            
            if (success) {
                responseData.put("success", true);
                responseData.put("message", "Removed from My List successfully");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                responseData.put("error", "Failed to remove from My List");
            }

        } catch (Exception e) {
            ErrorHandler.logError("Error in RemoveFromMyListServlet", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }
}