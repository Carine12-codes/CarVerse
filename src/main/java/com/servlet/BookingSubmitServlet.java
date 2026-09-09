package com.servlet;


import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet implementation class BookingSubmitServlet
 *
 * Inserts a new row into the BOOKING table using:
 *   - USER_ID   : from session ("USERID", set at login)
 *   - CAR_ID    : from the hidden field on booking.jsp
 *   - DROP_LOCATION : from the form field on booking.jsp
 *   - PICKUP_LOCATION : NULL for now
 *   - TOTAL_AMOUNT : computed server-side from car_details.price_range,
 *                    never trusted from the client
 *   - BOOKING_ID   : generated here ("BKG" + epoch millis)
 *   - BOOKING_DATE / BOOKING_STATUS : left to their DB column defaults
 */
@WebServlet("/BookingSubmitServlet")
public class BookingSubmitServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DB_URL =
            "jdbc:oracle:thin:@localhost:1521:XE";

    private static final String DB_USER     = "CARVERSE";
    private static final String DB_PASSWORD = "manager";

    /* Matches the first number in strings like "₹8.5 Lakh" or "₹1.2 Cr" */
    private static final Pattern NUMBER_PATTERN =
            Pattern.compile("[0-9]+(\\.[0-9]+)?");

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
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        /*
         * --------------------------------------------------------------
         * Require login — USER_ID is NOT NULL on the BOOKING table.
         * --------------------------------------------------------------
         */

        HttpSession session = request.getSession(false);
        String userId = (session != null)
                ? (String) session.getAttribute("USERID")
                : null;

        if (userId == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.html");
            return;
        }


        /*
         * --------------------------------------------------------------
         * Validate carId
         * --------------------------------------------------------------
         */

        String carIdParam   = request.getParameter("carId");
        String dropLocation = request.getParameter("dropLocation");

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

        if (dropLocation != null) {
            dropLocation = dropLocation.trim();
        }


        try (Connection con = DriverManager.getConnection(
                DB_URL, DB_USER, DB_PASSWORD)) {

            /*
             * ------------------------------------------------------------
             * Fetch the car's price_range so TOTAL_AMOUNT is computed
             * server-side, not accepted from the client.
             * ------------------------------------------------------------
             */

            String priceRange = null;

            String priceSql =
                    "SELECT price_range FROM car_details WHERE car_id = ?";

            try (PreparedStatement ps = con.prepareStatement(priceSql)) {

                ps.setInt(1, carId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        priceRange = rs.getString("price_range");
                    }
                }
            }

            if (priceRange == null) {
                request.setAttribute("error",
                        "Selected car could not be found.");
                request.getRequestDispatcher("/booking.jsp")
                       .forward(request, response);
                return;
            }

            BigDecimal totalAmount = parsePriceToAmount(priceRange);

            if (totalAmount == null) {
                request.setAttribute("error",
                        "Unable to determine the price for this car.");
                request.getRequestDispatcher("/booking.jsp")
                       .forward(request, response);
                return;
            }


            /*
             * ------------------------------------------------------------
             * Generate BOOKING_ID (VARCHAR2(20), no DB sequence used)
             * ------------------------------------------------------------
             */

            String bookingId = "BKG" + System.currentTimeMillis();


            /*
             * ------------------------------------------------------------
             * Insert booking.
             * PICKUP_LOCATION -> NULL for now.
             * BOOKING_DATE / BOOKING_STATUS -> left to column defaults.
             * ------------------------------------------------------------
             */

            String insertSql =
                    "INSERT INTO BOOKING_DETAILS "
                    + "(booking_id, user_id, car_id, pickup_location, "
                    + " drop_location, total_amount) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = con.prepareStatement(insertSql)) {

                ps.setString(1, bookingId);
                ps.setString(2, userId);
                ps.setString(3, String.valueOf(carId));
                ps.setNull(4, Types.VARCHAR);           // PICKUP_LOCATION = NULL

                if (dropLocation != null && !dropLocation.isEmpty()) {
                    ps.setString(5, dropLocation);
                } else {
                    ps.setNull(5, Types.VARCHAR);
                }

                ps.setBigDecimal(6, totalAmount);

                ps.executeUpdate();
            }

            request.setAttribute("bookingId", bookingId);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("dropLocation", dropLocation);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error",
                    "Unable to complete booking. Please try again.");
            request.getRequestDispatcher("/booking.jsp")
                   .forward(request, response);
            return;
        }

        request.getRequestDispatcher("/booking-confirmation.jsp")
               .forward(request, response);
    }


    /**
     * Converts a price string like "₹8.5 Lakh" or "₹1.2 Cr" into an
     * absolute rupee amount:
     *   1 Lakh = 100,000
     *   1 Cr   = 1,00,00,000
     * Returns null if no number could be parsed.
     */
    private BigDecimal parsePriceToAmount(String priceRange) {

        if (priceRange == null || priceRange.trim().isEmpty()) {
            return null;
        }

        Matcher matcher = NUMBER_PATTERN.matcher(priceRange);

        if (!matcher.find()) {
            return null;
        }

        BigDecimal number = new BigDecimal(matcher.group());

        if (priceRange.toUpperCase().contains("CR")) {
            return number.multiply(new BigDecimal("10000000")); // 1 Cr
        } else {
            return number.multiply(new BigDecimal("100000"));   // 1 Lakh
        }
    }
}