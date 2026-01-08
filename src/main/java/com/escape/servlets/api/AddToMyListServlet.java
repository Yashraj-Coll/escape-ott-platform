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

@WebServlet("/api/add-to-mylist")
public class AddToMyListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        Map<String, Object> responseData = new HashMap<>();
        
        try {
            // Check authentication
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                responseData.put("success", false);
                responseData.put("error", "Please sign in/sign up to add movies to my list");
                responseData.put("shouldRedirect", true);
                responseData.put("redirectUrl", "login.jsp");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            // Check subscription (skip for admin)
            String userRole = (String) session.getAttribute("userRole");
            if (!"admin".equals(userRole)) {
                String subscriptionPlan = (String) session.getAttribute("subscriptionPlan");
                if (subscriptionPlan == null || subscriptionPlan.equals("Free")) {
                    responseData.put("success", false);
                    responseData.put("error", "Please upgrade to a premium plan to create your my list");
                    responseData.put("shouldRedirect", true);
                    responseData.put("redirectUrl", "changePlan.jsp");
                    response.getWriter().write(gson.toJson(responseData));
                    return;
                }
            }

            JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
            int movieId = body.get("movieId").getAsInt();

            // Validate movieId
            if (!MovieService.isValidMovie(movieId)) {
                responseData.put("success", false);
                responseData.put("error", "Invalid movie ID");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            Integer userId = (Integer) session.getAttribute("userId");
            
            // Add to my list
            boolean success = MovieService.addToMyList(userId, movieId);
            
            if (success) {
                responseData.put("success", true);
                responseData.put("message", "Added to My List successfully");
            } else {
                responseData.put("success", false);
                responseData.put("error", "Failed to add to My List");
            }

        } catch (Exception e) {
            ErrorHandler.logError("Error in AddToMyListServlet", e);
            responseData.put("success", false);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }
}