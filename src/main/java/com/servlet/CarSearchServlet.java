package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/car-search")
public class CarSearchServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DB_URL =
            "jdbc:oracle:thin:@localhost:1521:XE";

    private static final String DB_USER     = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");

    private static final int PAGE_SIZE = 8;

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

        String query = request.getParameter("query");
        String budget = request.getParameter("budget");
        String[] bodyTypes = request.getParameterValues("body");
        String[] fuelTypes = request.getParameterValues("fuel");
        String[] brandTypes = request.getParameterValues("brand");
        String[] transmissionTypes = request.getParameterValues("transmission");
        String[] seatingTypes = request.getParameterValues("seating");
        String[] ratingTypes = request.getParameterValues("rating");
        String sort = request.getParameter("sort");

        int page = 1;

        try {
            String pageParam = request.getParameter("page");

            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }

            if (page < 1) {
                page = 1;
            }

        } catch (NumberFormatException e) {
            page = 1;
        }

        int offset = (page - 1) * PAGE_SIZE;

        List<CarModel> cars = new ArrayList<CarModel>();

        int totalCars = 0;

        try (Connection connection =
                     DriverManager.getConnection(
                             DB_URL,
                             DB_USER,
                             DB_PASSWORD)) {

            /*
             * ==========================================================
             * BUILD FILTER CONDITIONS
             * ==========================================================
             */

            StringBuilder where =
                    new StringBuilder(" WHERE 1 = 1 ");

            List<String> parameters =
                    new ArrayList<String>();


            /*
             * ----------------------------------------------------------
             * Search
             *
             * Search only the fields useful for finding a car.
             * ----------------------------------------------------------
             */

            if (query != null && !query.trim().isEmpty()) {

                where.append(
                    " AND ("
                    + " UPPER(model_name) LIKE UPPER(?) "
                    + " OR UPPER(brand) LIKE UPPER(?) "
                    + " OR UPPER(body_type) LIKE UPPER(?) "
                    + ") "
                );

                String search =
                        "%" + query.trim() + "%";

                parameters.add(search);
                parameters.add(search);
                parameters.add(search);
            }


            /*
             * ----------------------------------------------------------
             * Price expression (Lakhs-normalised)
             *
             * price_range is VARCHAR2 and may contain values in
             * either Lakhs ("₹8.5 Lakh") or Crores ("₹1.2 Cr").
             * 1 Crore = 100 Lakhs, so multiply by 100 when the
             * string contains "Cr" so all comparisons and sorts
             * work on a single, consistent unit.
             * ----------------------------------------------------------
             */

            final String priceInLakhs =
                "( CASE "
                + "   WHEN UPPER(price_range) LIKE '%CR%' THEN "
                + "     TO_NUMBER(REGEXP_SUBSTR(price_range,'[0-9]+(\\.[0-9]+)?')) * 100 "
                + "   ELSE "
                + "     TO_NUMBER(REGEXP_SUBSTR(price_range,'[0-9]+(\\.[0-9]+)?')) "
                + " END )";


            /*
             * ----------------------------------------------------------
             * Budget
             * ----------------------------------------------------------
             */

            if (budget != null &&
                !budget.trim().isEmpty()) {


                if (budget.equals("Under ₹10 Lakh")) {

                    where.append(
                        " AND " + priceInLakhs + " < 10 "
                    );

                } else if (budget.equals("₹10 - ₹20 Lakh")) {

                    where.append(
                        " AND " + priceInLakhs + " >= 10 "
                        + " AND " + priceInLakhs + " <= 20 "
                    );

                } else if (budget.equals("₹20 - ₹35 Lakh")) {

                    where.append(
                        " AND " + priceInLakhs + " > 20 "
                        + " AND " + priceInLakhs + " <= 35 "
                    );

                } else if (budget.equals("Above ₹35 Lakh")) {

                    where.append(
                        " AND " + priceInLakhs + " > 35 "
                    );
                }
            }


            /*
             * ----------------------------------------------------------
             * Body type
             * ----------------------------------------------------------
             */

            if (bodyTypes != null &&
                bodyTypes.length > 0) {

                where.append(
                    " AND UPPER(body_type) IN ("
                );

                for (int i = 0;
                     i < bodyTypes.length;
                     i++) {

                    if (i > 0) {
                        where.append(",");
                    }

                    where.append("?");

                    parameters.add(bodyTypes[i]);
                }

                where.append(") ");
            }


            /*
             * ----------------------------------------------------------
             * Fuel type
             *
             * Example:
             * fuel_types = "Petrol, Diesel"
             * ----------------------------------------------------------
             */

            if (fuelTypes != null &&
                fuelTypes.length > 0) {

                where.append(" AND (");

                for (int i = 0;
                     i < fuelTypes.length;
                     i++) {

                    if (i > 0) {
                        where.append(" OR ");
                    }

                    where.append(
                        " UPPER(fuel_types) LIKE UPPER(?) "
                    );

                    parameters.add(
                        "%" + fuelTypes[i] + "%"
                    );
                }

                where.append(") ");
            }


            /*
             * ----------------------------------------------------------
             * Brand
             * ----------------------------------------------------------
             */

            if (brandTypes != null && brandTypes.length > 0) {
                where.append(" AND UPPER(brand) IN (");
                for (int i = 0; i < brandTypes.length; i++) {
                    if (i > 0) {
                        where.append(",");
                    }
                    where.append("UPPER(?)");
                    parameters.add(brandTypes[i]);
                }
                where.append(") ");
            }


            /*
             * ----------------------------------------------------------
             * Transmission
             * ----------------------------------------------------------
             */

            if (transmissionTypes != null && transmissionTypes.length > 0) {
                where.append(" AND (");
                for (int i = 0; i < transmissionTypes.length; i++) {
                    if (i > 0) {
                        where.append(" OR ");
                    }
                    where.append("(UPPER(engine) LIKE UPPER(?) OR UPPER(drive_type) LIKE UPPER(?) OR UPPER(features) LIKE UPPER(?))");
                    String term = "%" + transmissionTypes[i] + "%";
                    parameters.add(term);
                    parameters.add(term);
                    parameters.add(term);
                }
                where.append(") ");
            }


            /*
             * ----------------------------------------------------------
             * Seating capacity
             * ----------------------------------------------------------
             */

            if (seatingTypes != null && seatingTypes.length > 0) {
                where.append(" AND (");
                for (int i = 0; i < seatingTypes.length; i++) {
                    if (i > 0) {
                        where.append(" OR ");
                    }
                    where.append("UPPER(seating_capacity) LIKE UPPER(?)");
                    parameters.add("%" + seatingTypes[i] + "%");
                }
                where.append(") ");
            }


            /*
             * ----------------------------------------------------------
             * Safety Rating
             * ----------------------------------------------------------
             */

            if (ratingTypes != null && ratingTypes.length > 0) {
                where.append(" AND (");
                for (int i = 0; i < ratingTypes.length; i++) {
                    if (i > 0) {
                        where.append(" OR ");
                    }
                    where.append("UPPER(safety_rating) LIKE UPPER(?)");
                    parameters.add("%" + ratingTypes[i] + "%");
                }
                where.append(") ");
            }


            /*
             * ==========================================================
             * COUNT RESULTS
             * ==========================================================
             */

            String countSql =
                "SELECT COUNT(*) "
                + "FROM car_details "
                + where.toString();

            try (PreparedStatement ps =
                    connection.prepareStatement(countSql)) {

                setParameters(ps, parameters);

                try (ResultSet rs =
                        ps.executeQuery()) {

                    if (rs.next()) {
                        totalCars = rs.getInt(1);
                    }
                }
            }


            /*
             * ==========================================================
             * SORTING
             * ==========================================================
             */

            String orderBy;

            if ("Price: Low to High".equals(sort)) {

                orderBy =
                    priceInLakhs + " ASC";

            } else if ("Price: High to Low".equals(sort)) {

                orderBy =
                    priceInLakhs + " DESC";

            } else {

                /*
                 * Default sorting.
                 *
                 * Since there is no popularity column,
                 * use car_id as fallback.
                 */
                orderBy = "car_id DESC";
            }


            /*
             * ==========================================================
             * FETCH SEARCH RESULTS
             *
             * ONLY fetch fields required by the search card.
             * ==========================================================
             */

            int endRow =
                    offset + PAGE_SIZE;


            String sql =
                "SELECT * FROM ("
                + " SELECT a.*, ROWNUM rnum "
                + " FROM ("

                + " SELECT "
                + " car_id, "
                + " model_name, "
                + " brand, "
                + " body_type, "
                + " price_range, "
                + " fuel_types, "
                + " mileage, "
                + " engine, "
                + " drive_type, "
                + " images "

                + " FROM car_details "

                + where.toString()

                + " ORDER BY "
                + orderBy

                + " ) a "

                + " WHERE ROWNUM <= ? "

                + ") "

                + "WHERE rnum > ?";


            try (PreparedStatement ps =
                    connection.prepareStatement(sql)) {

                int index = 1;


                /*
                 * Filter parameters
                 */
                for (String parameter : parameters) {

                    ps.setString(
                        index++,
                        parameter
                    );
                }


                /*
                 * Pagination
                 */
                ps.setInt(
                    index++,
                    endRow
                );

                ps.setInt(
                    index,
                    offset
                );


                try (ResultSet rs =
                        ps.executeQuery()) {

                    while (rs.next()) {

                        CarModel car = new CarModel();

                        car.setCarId(
                            rs.getInt("car_id")
                        );

                        car.setModelName(
                            rs.getString("model_name")
                        );

                        car.setBrand(
                            rs.getString("brand")
                        );

                        car.setBodyType(
                            rs.getString("body_type")
                        );

                        car.setPriceRange(
                            rs.getString("price_range")
                        );

                        car.setFuelTypes(
                            rs.getString("fuel_types")
                        );

                        car.setMileage(
                            rs.getString("mileage")
                        );

                        car.setEngine(
                            rs.getString("engine")
                        );

                        car.setDriveType(
                            rs.getString("drive_type")
                        );

                        car.setImages(
                            rs.getString("images")
                        );

                        cars.add(car);
                    }
                }
            }


        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                "error",
                "Unable to load car search results."
            );
        }


        /*
         * ==========================================================
         * SEND DATA TO JSP
         * ==========================================================
         */

        request.setAttribute(
            "cars",
            cars
        );

        request.setAttribute(
            "totalCars",
            totalCars
        );

        request.setAttribute(
            "currentPage",
            page
        );

        request.setAttribute(
            "totalPages",
            (int) Math.ceil(
                (double) totalCars / PAGE_SIZE
            )
        );

        request.setAttribute(
            "searchQuery",
            query
        );

        request.setAttribute(
            "selectedBudget",
            budget
        );

        request.setAttribute(
            "selectedSort",
            sort
        );

        request.setAttribute(
            "selectedBrands",
            brandTypes
        );

        request.setAttribute(
            "selectedTransmissions",
            transmissionTypes
        );

        request.setAttribute(
            "selectedSeatings",
            seatingTypes
        );

        request.setAttribute(
            "selectedRatings",
            ratingTypes
        );


        /*
         * Return to search page
         */
        request.getRequestDispatcher(
            "/car-search.jsp"
        ).forward(request, response);
    }


    /*
     * Set PreparedStatement parameters.
     */
    private void setParameters(
            PreparedStatement ps,
            List<String> parameters)
            throws Exception {

        for (int i = 0;
             i < parameters.size();
             i++) {

            ps.setString(
                i + 1,
                parameters.get(i)
            );
        }
    }
}