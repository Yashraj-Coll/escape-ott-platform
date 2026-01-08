package com.escape.servlets.api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.escape.service.MovieService;
import com.escape.util.ErrorHandler;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;


@WebServlet("/api/update-views")
public class UpdateViewsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

@Override
 protected void doPost(HttpServletRequest request, HttpServletResponse response) 
         throws IOException {
     response.setContentType("application/json");
     Map<String, Object> responseData = new HashMap<>();
     
     try {
         JsonObject body = new Gson().fromJson(request.getReader(), JsonObject.class);
         int movieId = body.get("movieId").getAsInt();
         
         boolean success = MovieService.incrementMovieViews(movieId);
         responseData.put("success", success);
         
     } catch (Exception e) {
         response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
         responseData.put("error", "Server error");
     }
     
     response.getWriter().write(new Gson().toJson(responseData));
 }
}