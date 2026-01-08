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
import java.util.Map;

@WebServlet("/api/movie-details/*")
public class GetMovieDetailsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        Map<String, Object> responseData = new HashMap<>();

        try {
            // Extract movieId from path
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Movie ID is required");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            int movieId;
            try {
                movieId = Integer.parseInt(pathInfo.substring(1));
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                responseData.put("error", "Invalid movie ID format");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            // Validate movieId
            if (!MovieService.isValidMovie(movieId)) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                responseData.put("error", "Movie not found");
                response.getWriter().write(gson.toJson(responseData));
                return;
            }

            // Get movie details
            Map<String, Object> movieDetails = MovieService.getMovieDetails(movieId);
            
            if (movieDetails != null && !movieDetails.isEmpty()) {
                responseData.put("success", true);
                responseData.put("movie", movieDetails);
                
                // Get movie statistics
                Map<String, Object> movieStats = MovieService.getMovieStats(movieId);
                responseData.put("stats", movieStats);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                responseData.put("error", "Movie details not found");
            }

        } catch (Exception e) {
            ErrorHandler.logError("Error in GetMovieDetailsServlet", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseData.put("error", "Internal server error");
        }

        response.getWriter().write(gson.toJson(responseData));
    }
}