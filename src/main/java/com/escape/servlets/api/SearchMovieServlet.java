package com.escape.servlets.api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.escape.service.MovieService;
import com.escape.util.ErrorHandler;
import com.google.gson.Gson;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/search-movies")
public class SearchMovieServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        Map<String, Object> responseData = new HashMap<>();

        try {
            String query = request.getParameter("query");
            
            if (query == null || query.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Search query is required");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            // Search movies
            List<Map<String, Object>> searchResults = MovieService.searchMovies(query.trim());
            
            responseData.put("success", true);
            responseData.put("results", searchResults);
            responseData.put("count", searchResults.size());

        } catch (Exception e) {
            ErrorHandler.logError("Error in SearchMovieServlet", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }
}