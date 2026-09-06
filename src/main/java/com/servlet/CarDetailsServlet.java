package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/car-details")
public class CarDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DB_URL =
            "jdbc:oracle:thin:@localhost:1521:XE";

    private static final String DB_USER     = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");

    @Override
    public void init() throws ServletException {

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new ServletException(
                    "Oracle JDBC Driver not found.", e);
        }

        if (DB_USER == null || DB_PASSWORD == null) {
            throw new ServletException(
                    "DB_USER or DB_PASSWORD environment variable is not set.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        /* ------------------------------------------------------------------ *
         * Validate carId parameter
         * ------------------------------------------------------------------ */

        String carIdParam = request.getParameter("carId");

        if (carIdParam == null || carIdParam.trim().isEmpty()) {
            response.sendRedirect(
                    request.getContextPath() + "/car-search");
            return;
        }

        int carId;

        try {
            carId = Integer.parseInt(carIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath() + "/car-search");
            return;
        }

        /* ------------------------------------------------------------------ *
         * Fetch car from DB
         * ------------------------------------------------------------------ */

        CarModel car = null;

        try (Connection connection =
                     DriverManager.getConnection(
                             DB_URL, DB_USER, DB_PASSWORD)) {

            String sql =
                    "SELECT car_id, model_name, brand, body_type, price_range, "
                    + "fuel_types, mileage, engine, power, torque, "
                    + "seating_capacity, drive_type, safety_rating, "
                    + "length, width, height, boot_space, wheelbase, "
                    + "features, images, source_url "
                    + "FROM car_details "
                    + "WHERE car_id = ?";

            try (PreparedStatement ps =
                         connection.prepareStatement(sql)) {

                ps.setInt(1, carId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {

                        car = new CarModel();

                        car.setCarId(rs.getInt("car_id"));
                        car.setModelName(rs.getString("model_name"));
                        car.setBrand(rs.getString("brand"));
                        car.setBodyType(rs.getString("body_type"));
                        car.setPriceRange(rs.getString("price_range"));
                        car.setFuelTypes(rs.getString("fuel_types"));
                        car.setMileage(rs.getString("mileage"));
                        car.setEngine(rs.getString("engine"));
                        car.setPower(rs.getString("power"));
                        car.setTorque(rs.getString("torque"));
                        car.setSeatingCapacity(rs.getString("seating_capacity"));
                        car.setDriveType(rs.getString("drive_type"));
                        car.setSafetyRating(rs.getString("safety_rating"));
                        car.setLength(rs.getString("length"));
                        car.setWidth(rs.getString("width"));
                        car.setHeight(rs.getString("height"));
                        car.setBootSpace(rs.getString("boot_space"));
                        car.setWheelbase(rs.getString("wheelbase"));
                        car.setFeatures(rs.getString("features"));
                        car.setImages(rs.getString("images"));
                        car.setSourceUrl(rs.getString("source_url"));
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error",
                    "Unable to load car details. Please try again.");
        }

        /* ------------------------------------------------------------------ *
         * If no car found, redirect back to search
         * ------------------------------------------------------------------ */

        if (car == null && request.getAttribute("error") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/car-search");
            return;
        }

        request.setAttribute("car", car);

        request.getRequestDispatcher("/car-details.jsp")
               .forward(request, response);
    }
}
